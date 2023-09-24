// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Marketplace {
    address public owner;
    uint256 public itemIdCounter;

    struct Item {
        uint256 id;
        address seller;
        string name;
        uint256 price;
        bool isAvailable;
    }

    mapping(uint256 => Item) public items;

    event ItemListed(uint256 indexed itemId, address indexed seller, string name, uint256 price);
    event ItemSold(uint256 indexed itemId, address indexed seller, address indexed buyer, string name, uint256 price);

    constructor() {
        owner = msg.sender;
        itemIdCounter = 1; // Start item IDs from 1
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function listNewItem(string memory name, uint256 price) external {
        require(price > 0, "Price must be greater than zero");

        Item storage newItem = items[itemIdCounter];
        newItem.id = itemIdCounter;
        newItem.seller = msg.sender;
        newItem.name = name;
        newItem.price = price;
        newItem.isAvailable = true;

        emit ItemListed(itemIdCounter, msg.sender, name, price);
        itemIdCounter++;
    }

    function buyItem(uint256 itemId) external payable {
        Item storage item = items[itemId];

        require(item.isAvailable, "Item is not available");
        require(msg.value >= item.price, "Insufficient funds to purchase");
        require(msg.sender != item.seller, "You cannot buy your own item");

        item.isAvailable = false;

        // Transfer the funds to the seller
        payable(item.seller).transfer(item.price);

        emit ItemSold(itemId, item.seller, msg.sender, item.name, item.price);
    }

    function withdrawBalance() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}