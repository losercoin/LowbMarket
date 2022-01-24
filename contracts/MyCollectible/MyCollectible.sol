// contracts/GameItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract MyCollectible is ERC721EnumerableUpgradeable, OwnableUpgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter public serialIds;

    uint private _serialTokenStart;
    uint private _serialGroupStart;
    mapping (uint => uint) public serialTokenStart;
    mapping (uint => uint) public serialGroupStart;
    mapping (uint => uint) public serialMaxGroup;
    mapping (uint => uint) public serialMaxSupply;
    mapping (uint => uint) public serialCurrentGroup;
    mapping (uint => uint) public serialCurrentSupply;

    mapping (uint => address) public creatorOf;
    mapping (uint => uint) public royaltyOf;
    mapping (uint => uint) public serialOf;
    mapping (uint => string) private _groupURI;
    mapping (uint => uint) public groupStart;
    mapping (uint => uint) public groupCurrentSupply;
    mapping (uint => uint) public groupMaxSupply;

    mapping (uint => uint) public groupOf;

    /* Inverse basis point. */
    uint public constant INVERSE_BASIS_POINT = 10000;

    event SerialAdded(uint indexed serialId, uint maxGroup, uint maxSupply);
    event GroupPublished(uint indexed groupId, uint indexed serialId, uint maxSupply);
    event NewItemClaimed(uint indexed itemId, uint indexed groupId, address indexed toAddress);

    function initialize() initializer public {
        __ERC721_init("Loser NFT", "LOWX");
        OwnableUpgradeable.__Ownable_init();
    }

    function addSerial(uint256 maxGroup, uint256 maxSupply)
        public onlyOwner
        returns (uint256)
    {
        serialIds.increment();
        uint256 newSerialId = serialIds.current();
        serialTokenStart[newSerialId] = _serialTokenStart + 1; // start token id of this serial
        serialGroupStart[newSerialId] = _serialGroupStart + 1; // start group id of this serial
        serialMaxSupply[newSerialId] = maxSupply;
        serialMaxGroup[newSerialId] = maxGroup;
        _serialTokenStart += maxSupply;
        _serialGroupStart += maxGroup;

        emit SerialAdded(newSerialId, maxGroup, maxSupply);

        return newSerialId;
    }

    function publish(address to, uint256 serial, uint256 maxSupply, string memory _tokenURI, uint256 royalty)
        public onlyOwner
        returns (uint256)
    {
        require(serial <= serialIds.current(), "Unknown serial.");
        require(royalty >= 0 && royalty <= INVERSE_BASIS_POINT, "Royalty should be between 0 - 100%.");
        require(serialCurrentGroup[serial] < serialMaxGroup[serial], "All groups of this serial have been published.");
        require(serialCurrentSupply[serial] < serialMaxSupply[serial], "All tokens of this serial have been published.");
        
        uint256 groupId = serialGroupStart[serial] + serialCurrentGroup[serial];
        serialCurrentGroup[serial] ++;

        uint256 tokenId = serialTokenStart[serial] + serialCurrentSupply[serial];
        serialCurrentSupply[serial] += maxSupply;

        groupStart[groupId] = tokenId;
        groupMaxSupply[groupId] = maxSupply;
        _groupURI[groupId] = _tokenURI;
        creatorOf[groupId] = to;
        royaltyOf[groupId] = royalty;

        _mint(to, tokenId);
        groupOf[tokenId] = groupId;
        groupCurrentSupply[groupId] = 1;

        emit GroupPublished(groupId, serial, maxSupply);

        return groupId;
    }

    function claim(address to, uint256 groupId)
        public 
        returns (uint256)
    {
        require(groupCurrentSupply[groupId] < groupMaxSupply[groupId], "All tokens of this group has been minted.");
        uint256 startId = groupStart[groupId];
        require(ownerOf(startId) == msg.sender || getApproved(startId) == msg.sender, "You don't have the access to mint this token.");
        uint256 newtokenId = startId + groupCurrentSupply[groupId];

        _mint(to, newtokenId);
        groupOf[newtokenId] = groupId;
        groupCurrentSupply[groupId] += 1;

        emit NewItemClaimed(newtokenId, groupId, to);

        return newtokenId;
    }

    function tokenURI(uint256 tokenId)
        public view override
        returns (string memory)
    {
        uint256 groupId = groupOf[tokenId];
        return _groupURI[groupId];
    }
}