// contracts/LowbMarket.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract LowbMarket {

    address public nonFungibleTokenAddress;
    address public lowbTokenAddress;

    struct Offer {
        bool isForSale;
        uint itemId;
        address seller;
        uint minValue;          // in lowb
        address onlySellTo;     // specify to sell only to a specific person
    }

    struct Bid {
        bool hasBid;
        uint itemIndex;
        address bidder;
        uint value;
    }

    // A record of items that are offered for sale at a specific minimum value, and perhaps to a specific person
    mapping (uint => Offer) public itemsOfferedForSale;

    // A record of the highest bid
    mapping (uint => Bid) public itemBids;

    mapping (address => uint) public pendingWithdrawals;

    event ItemNoLongerForSale(uint itemId);
    event ItemOffered(uint itemId, uint minValue, address toAddress);
    event NewBidEntered(uint itemId, uint value, address fromAddress);
    event BidWithdrawn(uint itemId, uint value, address fromAddress);
    event ItemBought(uint itemId, uint value, address fromAddress, address toAddress);

    constructor(address lowbToken_, address nonFungibleToken_) {
        require(nonFungibleToken_ != address(0));
        nonFungibleTokenAddress = nonFungibleToken_;
        lowbTokenAddress = lowbToken_;
    }

    function itemNoLongerForSale(uint itemId) public {
        IERC721 token = IERC721(nonFungibleTokenAddress);
        require(token.ownerOf(itemId) == msg.sender, "You don't own this token.");

        itemsOfferedForSale[itemId] = Offer(false, itemId, msg.sender, 0, address(0));
        emit ItemNoLongerForSale(itemId);
    }

    function offerItemForSale(uint itemId, uint minSalePriceInWei) public {
        IERC721 token = IERC721(nonFungibleTokenAddress);
        require(token.ownerOf(itemId) == msg.sender, "You don't own this token.");
        require(token.getApproved(itemId) == address(this), "Approve this token first.");

        itemsOfferedForSale[itemId] = Offer(true, itemId, msg.sender, minSalePriceInWei, address(0));
        emit ItemOffered(itemId, minSalePriceInWei, address(0));
    }

    function offerItemForSale(uint itemId, uint minSalePriceInWei, address toAddress) public {
        IERC721 token = IERC721(nonFungibleTokenAddress);
        require(token.ownerOf(itemId) == msg.sender, "You don't own this token.");
        require(token.getApproved(itemId) == address(this), "Approve this token first.");

        itemsOfferedForSale[itemId] = Offer(true, itemId, msg.sender, minSalePriceInWei, toAddress);
        emit ItemOffered(itemId, minSalePriceInWei, toAddress);
    }

    function deposit(uint amount) public {
        require(amount > 0, "You deposit nothing!");
        IERC20 token = IERC20(lowbTokenAddress);
        require(token.transferFrom(msg.sender, address(this), amount), "Lowb transfer failed");
        pendingWithdrawals[msg.sender] +=  amount;
    }

    function withdraw(uint amount) public {
        require(amount <= pendingWithdrawals[msg.sender], "amount larger than that pending to withdraw");  
        pendingWithdrawals[msg.sender] -= amount;
        IERC20 token = IERC20(lowbTokenAddress);
        require(token.transfer(msg.sender, amount), "Lowb transfer failed");
    }

    function buyItem(uint itemId, uint amount) public {
        Offer memory offer = itemsOfferedForSale[itemId];
        require(offer.isForSale, "This item not actually for sale.");
        require(offer.onlySellTo == address(0) || offer.onlySellTo == msg.sender, "this item not supposed to be sold to this user");
        require(amount >= offer.minValue, "You didn't send enough LOWB.");

        IERC721 nft = IERC721(nonFungibleTokenAddress);
        require(offer.seller == nft.ownerOf(itemId), "Seller no longer owner of this item.");

        IERC20 lowb = IERC20(lowbTokenAddress);
        require(lowb.transferFrom(msg.sender, address(this), amount), "Lowb transfer failed");

        address seller = offer.seller;
        nft.safeTransferFrom(seller, msg.sender, itemId);

        itemNoLongerForSale(itemId);
        pendingWithdrawals[seller] += amount;
        emit ItemBought(itemId, amount, seller, msg.sender);

        // Check for the case where there is a bid from the new owner and refund it.
        // Any other bid can stay in place.
        Bid memory bid = itemBids[itemId];
        if (bid.bidder == msg.sender) {
            // Kill bid and refund value
            pendingWithdrawals[msg.sender] += bid.value;
            itemBids[itemId] = Bid(false, itemId, address(0), 0);
        }
    }

    function enterBid(uint itemId, uint amount) public {
        require(pendingWithdrawals[msg.sender] >= amount, "Please deposit enough lowb before bid!");

        IERC721 nft = IERC721(nonFungibleTokenAddress);
        require(nft.ownerOf(itemId) != address(0), "Token not created yet.");               
        require(nft.ownerOf(itemId) != msg.sender, "You already own it.");

        Bid memory existing = itemBids[itemId];
        require(amount > existing.value, "The new bid should be larger than existing bids");
        
        if (existing.value > 0) {
            // Refund the failing bid
            pendingWithdrawals[existing.bidder] += existing.value;
            // Lock the current bid
            pendingWithdrawals[existing.bidder] -= existing.value;
        }
        itemBids[itemId] = Bid(true, itemId, msg.sender, amount);
        emit NewBidEntered(itemId, amount, msg.sender);
    }

    function acceptBid(uint itemId) public {
        IERC721 nft = IERC721(nonFungibleTokenAddress);
        require(nft.ownerOf(itemId) == msg.sender, "You don't own this token.");
        require(nft.getApproved(itemId) == address(this), "Approve this token first.");
        
        address seller = msg.sender;
        Bid memory bid = itemBids[itemId];
        require(bid.value > 0, "Nobody bid for this item yet.");

        nft.safeTransferFrom(seller, msg.sender, itemId);
        itemsOfferedForSale[itemId] = Offer(false, itemId, bid.bidder, 0, address(0));
        uint amount = bid.value;
        itemBids[itemId] = Bid(false, itemId, address(0), 0);
        pendingWithdrawals[seller] += amount;
        emit ItemBought(itemId, bid.value, seller, bid.bidder);
    }

    function withdrawBid(uint itemId) public {
        Bid memory bid = itemBids[itemId];
        require(bid.bidder == msg.sender, "You don't have a bid for it.");
        emit BidWithdrawn(itemId, bid.value, msg.sender);
        uint amount = bid.value;
        itemBids[itemId] = Bid(false, itemId, address(0), 0);
        // Refund the bid money
        pendingWithdrawals[msg.sender] += amount;
    }

}