// contracts/LowbMarket.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IERC721LOWB is IERC721 {

    function groupOf(uint256 tokenId) external view returns (uint256 groupId);

    function creatorOf(uint256 groupId) external view returns (address creator);

    function groupStart(uint256 groupId) external view returns (uint256 tokenId);

    function royaltyOf(uint256 groupId) external view returns (uint256 royalty);

    function claim(address to, uint256 groupId) external returns (uint256 tokenId);

}