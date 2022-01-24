// contracts/LowbMarket.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./LowbMarketOther.sol";

contract LowbMarketHelper {

    address public lowbMarketAddress;

    constructor(address lowbMarket_) {
        lowbMarketAddress = lowbMarket_;
    }

    function getOffers(uint from, uint to) public view returns (LowbMarketOther.Offer[] memory) {
        require(from > 0 && to >= from, "Invalid index");
        LowbMarketOther market = LowbMarketOther(lowbMarketAddress);
        LowbMarketOther.Offer[] memory offers = new LowbMarketOther.Offer[](to-from+1);
        for (uint i=from; i<=to; i++) {
            offers[i-from] = market.itemsOfferedForSale(i);
        }
        return offers;
    }

    function getNewOffers(uint from, uint to) public view returns (uint[] memory) {
        require(from > 0 && to >= from, "Invalid index");
        LowbMarketOther market = LowbMarketOther(lowbMarketAddress);
        uint[] memory offers = new uint[](to-from+1);
        for (uint i=from; i<=to; i++) {
            offers[i-from] = market.newTokenOffer(i);
        }
        return offers;
    }

    function getBidsOf(address addr, uint from, uint to) public view returns (LowbMarketOther.Bid[] memory) {
        require(from > 0 && to >= from, "Invalid index");
        LowbMarketOther market = LowbMarketOther(lowbMarketAddress);
        LowbMarketOther.Bid[] memory bids = new LowbMarketOther.Bid[](to-from+1);
        for (uint i=from; i<=to; i++) {
            bids[i-from] = market.itemBids(i, addr);
        }
        return bids;
    }

    function getHighestBids(uint from, uint to) public view returns (LowbMarketOther.Bid[] memory) {
        require(from > 0 && to >= from, "Invalid index");
        LowbMarketOther market = LowbMarketOther(lowbMarketAddress);
        LowbMarketOther.Bid[] memory bids = new LowbMarketOther.Bid[](to-from+1);
        LowbMarketOther.Bid memory bid;
        for (uint i=from; i<=to; i++) {
            bid = market.itemBids(i, address(0));
            while (bid.nextBidder != address(0)) {
                bid = market.itemBids(i, bid.nextBidder);
                if (bid.value >= bids[i-from].value) {
                    bids[i-from] = bid;
                }
            }
        }
        return bids;
    }
}