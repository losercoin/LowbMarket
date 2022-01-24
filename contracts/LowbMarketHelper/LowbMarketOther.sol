// contracts/LowbMarket.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface LowbMarketOther {

    struct Offer {
        bool isForSale;
        uint itemId;
        address seller;
        uint minValue;          // in lowb
        address onlySellTo;     // specify to sell only to a specific person
    }

    struct Bid {
        address prevBidder;
        address nextBidder;
        uint value;
    }

    // A record of items that are offered for sale at a specific minimum value, and perhaps to a specific person
    function itemsOfferedForSale(uint) external view returns (Offer memory);

    // A record of the highest bid
    function itemBids(uint, address) external view returns (Bid memory);
    //mapping (uint => mapping (address => Bid)) public itemBids;

    function newTokenOffer(uint) external view returns (uint);
    //mapping (uint => uint) public newTokenOffer;

}