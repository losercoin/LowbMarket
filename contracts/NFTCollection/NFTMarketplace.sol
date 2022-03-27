// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './NFTCollection.sol';
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract NFTMarketplace {
  NFTCollection nftCollection;
  IERC20 lowbToken;

  mapping (uint256 => uint256) private tokenPrice;
  mapping (uint256 => address) private tokenSeller;

  event saleNFT(uint indexed tokenId, uint256 price);
  event buyNFT(address from, address to, uint256 tokenId, uint256 price);

  receive() external payable {}


  constructor (address _address, address _lowbAddress) {
    nftCollection = NFTCollection(_address);
    lowbToken = IERC20(_lowbAddress);
  }

  function prepareForSale(uint256 tokenId, uint256 price) public {
    require(msg.sender != address(0));
    tokenPrice[tokenId] = price;
    tokenSeller[tokenId] = msg.sender;
    nftCollection.transferFrom(msg.sender, address(this), tokenId);
    emit saleNFT(tokenId, price);
  }

  function sellNFT(address from, uint256 tokenId) payable public {
    uint256 price = tokenPrice[tokenId];
    require(msg.value >= price, "INSUFFICIENT BNB"); 
    nftCollection.transferFrom(address(this), msg.sender, tokenId);
    payable(tokenSeller[tokenId]).transfer(price);
    emit buyNFT(from, msg.sender, tokenId, price);
  }
}
