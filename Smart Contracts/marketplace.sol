// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./id.sol";

contract Marketplace {
    address public owner;
    address public uniqueIDIssuer; // Address of the UniqueIDIssuer contract

    // Chain ID of the Polygon network
    uint256 public chainId = 1101; // Replace with the actual Polygon chain ID

    struct Item {
        uint256 id;
        uint256 marketplaceId;
        uint256 sellerId;
        uint256 buyerId;
        string name;
        uint256 price;
        bool isAvailable;
    }

    mapping(uint256 => Item) public items;

    event ItemListed(uint256 indexed itemId, uint256 indexed marketplaceId, uint256 indexed sellerId, string name, uint256 price);
    event ItemSold(uint256 indexed itemId, uint256 indexed buyerId, uint256 price); // Modified event

    constructor(address _uniqueIDIssuer) {
        owner = msg.sender;
        uniqueIDIssuer = _uniqueIDIssuer;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function listNewItem(string memory name, uint256 price) external {
        require(price > 0, "Price must be greater than zero");

        // Get unique IDs from the UniqueIDIssuer contract
        uint256 marketplaceId = UniqueIDIssuer(uniqueIDIssuer).getNextMarketplaceId();
        uint256 sellerId = UniqueIDIssuer(uniqueIDIssuer).getNextSellerId();
        uint256 itemId = UniqueIDIssuer(uniqueIDIssuer).getNextItemId();

        // Incorporate the chain ID into the marketplace ID
        marketplaceId += (chainId * 1000000);

        Item storage newItem = items[itemId];
        newItem.id = itemId;
        newItem.marketplaceId = marketplaceId;
        newItem.sellerId = sellerId;
        newItem.buyerId = 0; // Initialize buyerId to 0, indicating it's not sold yet
        newItem.name = name;
        newItem.price = price;
        newItem.isAvailable = true;

        emit ItemListed(itemId, marketplaceId, sellerId, name, price);
    }

    function buyItem(uint256 itemId) external payable {
        Item storage item = items[itemId];

        require(item.isAvailable, "Item is not available");
        require(msg.value >= item.price, "Insufficient funds to purchase");
        require(msg.sender != owner, "Owner cannot buy their own item");

        // Transfer the funds to the seller
        (bool success, ) = payable(owner).call{value: item.price}("");
        require(success, "Transfer failed.");

        // Get unique IDs from the UniqueIDIssuer contract
        uint256 buyerId = UniqueIDIssuer(uniqueIDIssuer).getNextBuyerId();

        item.isAvailable = false;
        item.buyerId = buyerId;

        emit ItemSold(itemId, buyerId, item.price); // Modified event
    }

    function withdrawBalance() external onlyOwner {
        require(address(this).balance > 0, "Insufficient balance to withdraw");
        payable(owner).transfer(address(this).balance);
    }

    // Get the chain ID
    function getChainId() external view returns (uint256) {
        return chainId;
    }

    // Fallback function to receive payments
    receive() external payable {}
}