// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract NFTCollection is ERC721, ERC721Enumerable {

  event mintNFT(uint256 indexed tokenId, address indexed owner, string uri, string name, string description);
  event saleNFT(uint indexed tokenId, string price);

  constructor(address _address) ERC721("Lowb Collection", "Lowb") {

  }

  function _beforeTokenTransfer(address from, address to, uint tokenId) internal override(ERC721, ERC721Enumerable) {
    super._beforeTokenTransfer(from, to, tokenId);
  }

  function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns(bool) {
    return super.supportsInterface(interfaceId);
  }

  function safeMint(uint256 tokenId, string memory uri, string memory name, string memory description) public {
    _safeMint(msg.sender, tokenId);
    emit mintNFT(tokenId, msg.sender, uri, name, description);
  }

  function prepareForSale(uint256 tokenId, string memory price) payable public {
    require(msg.sender != address(0));
    require(_exists(tokenId));
    emit saleNFT(tokenId, price);
  }

}