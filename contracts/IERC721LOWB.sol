// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IERC721LOWB is IERC721 {

    function holderOf(uint256 tokenId) external view returns (address holder);
    function owner() external view returns (address _owner);
    function totalSupply() external view returns (uint n);
    
    function setHolder(uint256 tokenId, address newHolder, uint256 rentDay) external;

}
