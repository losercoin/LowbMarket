// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract NFTCollection is ERC721, ERC721Enumerable {

  event mintNFT(uint256 tokenId, string uri, string name, string description);

  constructor() ERC721("Lowb Collection", "Lowb") {

  }

  function _beforeTokenTransfer(address from, address to, uint tokenId) internal override(ERC721, ERC721Enumerable) {
    super._beforeTokenTransfer(from, to, tokenId);
  }

  function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns(bool) {
    return super.supportsInterface(interfaceId);
  }

  function safeMint(uint256 tokenId, string memory uri, string memory name, string memory description) public {
    _safeMint(msg.sender, tokenId);
    emit mintNFT(tokenId, uri, name, description);
  }

}