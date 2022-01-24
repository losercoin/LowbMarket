// contracts/LowbMarket.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC721LOWB.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract LowbMarket {

    address public nonFungibleTokenAddress;
    address public lowbTokenAddress;

    address public owner;

    /* Inverse basis point. */
    uint public constant INVERSE_BASIS_POINT = 10000;
    uint public fee;

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
    mapping (uint => Offer) public itemsOfferedForSale;

    // A record of the highest bid
    mapping (uint => mapping (address => Bid)) public itemBids;

    mapping (address => uint) public pendingWithdrawals;
    mapping (uint => uint) public newTokenOffer;

    event ItemNoLongerForSale(uint indexed itemId);
    event ItemOffered(uint indexed itemId, uint minValue, address indexed toAddress);
    event NewItemsOffered(uint indexed groupId, uint minValue);
    event NewBidEntered(uint indexed groupId, uint value, address indexed fromAddress);
    event BidWithdrawn(uint indexed itemId, uint value, address indexed fromAddress);
    event ItemBought(uint indexed itemId, uint value, address indexed fromAddress, address indexed toAddress);
    event ItemMint(uint indexed itemId, uint value, address indexed toAddress);

    constructor(address lowbToken_, address nonFungibleToken_) {
        require(nonFungibleToken_ != address(0));
        nonFungibleTokenAddress = nonFungibleToken_;
        lowbTokenAddress = lowbToken_;
        owner = msg.sender;
        fee = 250;
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

    function offerItemForSaleToAddress(uint itemId, uint minSalePriceInWei, address toAddress) public {
        IERC721 token = IERC721(nonFungibleTokenAddress);
        require(token.ownerOf(itemId) == msg.sender, "You don't own this token.");
        require(token.getApproved(itemId) == address(this), "Approve this token first.");

        itemsOfferedForSale[itemId] = Offer(true, itemId, msg.sender, minSalePriceInWei, toAddress);
        emit ItemOffered(itemId, minSalePriceInWei, toAddress);
    }

    function deposit(uint amount) public {
        require(amount > 0, "You deposit nothing!");
        IERC20 token = IERC20(lowbTokenAddress);
        require(token.transferFrom(tx.origin, address(this), amount), "Lowb transfer failed");
        pendingWithdrawals[tx.origin] +=  amount;
    }

    function withdraw(uint amount) public {
        require(amount <= pendingWithdrawals[tx.origin], "amount larger than that pending to withdraw");  
        pendingWithdrawals[tx.origin] -= amount;
        IERC20 token = IERC20(lowbTokenAddress);
        require(token.transfer(tx.origin, amount), "Lowb transfer failed");
    }

    function _makeDeal(uint itemId, uint amount) private returns (uint) {
        IERC721LOWB nft = IERC721LOWB(nonFungibleTokenAddress);
        uint groupId = nft.groupOf(itemId);
        uint royalty = nft.royaltyOf(groupId);
        uint fee_amount = amount / INVERSE_BASIS_POINT * fee;
        uint royalty_amount = amount / INVERSE_BASIS_POINT * royalty;
        uint actual_amount = amount - fee_amount - royalty_amount;
        address creator = nft.creatorOf(groupId);
        require(actual_amount > 0, "Fees should less than the transaction value.");
        pendingWithdrawals[creator] += royalty_amount;
        pendingWithdrawals[address(this)] += fee_amount;
        return actual_amount;
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

        uint actual_amount = _makeDeal(itemId, amount);
        pendingWithdrawals[seller] += actual_amount;
        emit ItemBought(itemId, amount, seller, msg.sender);
    }

    function enterBid(uint groupId, uint amount) public {
        require(pendingWithdrawals[msg.sender] >= amount, "Please deposit enough lowb before bid!");
        require(amount > 0, "Please bid with some lowb!");

        IERC721LOWB nft = IERC721LOWB(nonFungibleTokenAddress);
        uint itemId = nft.groupStart(groupId);
        require(nft.ownerOf(itemId) != address(0), "Token not created yet.");

        require(itemBids[groupId][msg.sender].value == 0, "You've already entered a bid!");

        // Lock the current bid
        pendingWithdrawals[msg.sender] -= amount;
        address latestBidder = itemBids[groupId][address(0)].nextBidder;
        itemBids[groupId][latestBidder].prevBidder = msg.sender;
        itemBids[groupId][msg.sender] = Bid(address(0), latestBidder, amount);
        itemBids[groupId][address(0)].nextBidder = msg.sender;

        emit NewBidEntered(groupId, amount, msg.sender);
    }

    function acceptBid(uint itemId, address bidder) public {
        IERC721LOWB nft = IERC721LOWB(nonFungibleTokenAddress);
        require(nft.ownerOf(itemId) == msg.sender, "You don't own this token.");
        require(nft.getApproved(itemId) == address(this), "Approve this token first.");
        
        address seller = msg.sender;
        uint groupId = nft.groupOf(itemId);
        uint amount = itemBids[groupId][bidder].value;
        require(amount > 0, "No bid from this address for this item yet.");

        nft.safeTransferFrom(seller, bidder, itemId);
        itemsOfferedForSale[itemId] = Offer(false, itemId, bidder, 0, address(0));

        itemBids[groupId][bidder].value = 0;
        address nextBidder = itemBids[groupId][bidder].nextBidder;
        address prevBidder = itemBids[groupId][bidder].prevBidder;
        itemBids[groupId][prevBidder].nextBidder = nextBidder;
        itemBids[groupId][nextBidder].prevBidder = prevBidder;
        
        uint actual_amount = _makeDeal(itemId, amount);
        pendingWithdrawals[seller] += actual_amount;
        emit ItemBought(itemId, amount, seller, bidder);
    }

    function withdrawBid(uint groupId) public {
        uint amount = itemBids[groupId][msg.sender].value;
        require(amount > 0, "You don't have a bid for it.");
        emit BidWithdrawn(groupId, amount, msg.sender);
        
        itemBids[groupId][msg.sender].value = 0;
        address nextBidder = itemBids[groupId][msg.sender].nextBidder;
        address prevBidder = itemBids[groupId][msg.sender].prevBidder;
        itemBids[groupId][prevBidder].nextBidder = nextBidder;
        itemBids[groupId][nextBidder].prevBidder = prevBidder;
        // Refund the bid money
        pendingWithdrawals[msg.sender] += amount;
    }

    function approveBid(uint groupId, address bidder) public {
        IERC721LOWB nft = IERC721LOWB(nonFungibleTokenAddress);
        uint itemId = nft.groupStart(groupId);
        require(nft.ownerOf(itemId) == msg.sender, "You don't have access to approve this bid for the new token.");
        require(nft.getApproved(itemId) == address(this), "Approve this contract to claim the new tokens first.");

        uint amount = itemBids[groupId][bidder].value;
        require(amount > 0, "No bid from this address for this item yet.");
        
        uint tokenId = nft.claim(bidder, groupId);
        
        itemBids[groupId][bidder].value = 0;
        address nextBidder = itemBids[groupId][bidder].nextBidder;
        address prevBidder = itemBids[groupId][bidder].prevBidder;
        itemBids[groupId][prevBidder].nextBidder = nextBidder;
        itemBids[groupId][nextBidder].prevBidder = prevBidder;

        uint actual_amount = _makeDeal(itemId, amount);
        address creator = nft.creatorOf(groupId);
        pendingWithdrawals[creator] += actual_amount;
        emit ItemMint(tokenId, amount, bidder);
    }

    function offerItemsForPublicSale(uint groupId, uint minSalePriceInWei) public {
        IERC721LOWB nft = IERC721LOWB(nonFungibleTokenAddress);
        uint itemId = nft.groupStart(groupId);
        require(nft.ownerOf(itemId) == msg.sender, "You don't have access to approve this bid for the new token.");
        require(nft.getApproved(itemId) == address(this), "Approve this contract to claim the new tokens first.");
        require(minSalePriceInWei > 0, "Token price should not be zero.");

        newTokenOffer[groupId] = minSalePriceInWei;
        emit NewItemsOffered(groupId, minSalePriceInWei);
    }

    function buyNewItem(uint groupId, uint amount) public {
        require(newTokenOffer[groupId] > 0, "this item is not for sale now");
        require(amount >= newTokenOffer[groupId], "You didn't send enough LOWB.");

        IERC721LOWB nft = IERC721LOWB(nonFungibleTokenAddress);
        uint itemId = nft.groupStart(groupId);
        require(nft.getApproved(itemId) == address(this), "Require approvement to claim the new tokens.");

        IERC20 lowb = IERC20(lowbTokenAddress);
        require(lowb.transferFrom(msg.sender, address(this), amount), "Lowb transfer failed");

        uint tokenId = nft.claim(msg.sender, groupId);

        uint actual_amount = _makeDeal(itemId, amount);
        address creator = nft.creatorOf(groupId);
        pendingWithdrawals[creator] += actual_amount;
        emit ItemMint(tokenId, amount, msg.sender);
    }

    function pullFunds() public {
        require(msg.sender == owner, "Only owner can pull the funds!");
        IERC20 lowb = IERC20(lowbTokenAddress);
        lowb.transfer(msg.sender, pendingWithdrawals[address(this)]);
        pendingWithdrawals[address(this)] = 0;
    }

}