pragma solidity ^0.8.0;

import './NFTCollection.sol';

contract NFTMarketplace {
  NFTCollection nftCollection;

  event saleNFT(uint indexed tokenId, string price);
  event buyNFT(address from, address to, uint256 tokenId, string price);

  constructor (address _address) {
    nftCollection = NFTCollection(_address);
  }

  function prepareForSale(uint256 tokenId, string memory price) public {
    require(msg.sender != address(0));
    nftCollection.transferFrom(msg.sender, address(this), tokenId);
    emit saleNFT(tokenId, price);
  }

  function sellNFT(address from, uint256 tokenId, string memory price) public {
    nftCollection.transferFrom(address(this), msg.sender, tokenId);
    emit buyNFT(from, msg.sender, tokenId, price);
  }
}