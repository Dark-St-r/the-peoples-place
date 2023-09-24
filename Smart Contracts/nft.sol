// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTMarketplace is ERC721Enumerable, Ownable {
    uint256 public itemIdCounter;

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

    event ItemListed(uint256 indexed itemId, uint256 indexed sellerId, string name, uint256 price);
    event ItemSold(uint256 indexed itemId, uint256 marketplaceId, uint256 sellerId, uint256 buyerId, string name, uint256 price);

    // Chain ID of the Polygon network
    uint256 public chainId = 1101; // Replace with the actual Polygon chain ID

    constructor() ERC721("NFTMarketplace", "NFTM") {
        itemIdCounter = 1; // Start item IDs from 1
    }

    function listNewItem(uint256 marketplaceId, uint256 sellerId, string memory name, uint256 price) external onlyOwner {
        require(price > 0, "Price must be greater than zero");

        uint256 itemId = itemIdCounter;
        Item storage newItem = items[itemId];
        newItem.id = itemId;
        newItem.marketplaceId = marketplaceId;
        newItem.sellerId = sellerId;
        newItem.buyerId = 0; // Initialize buyerId to 0, indicating it's not sold yet
        newItem.name = name;
        newItem.price = price;
        newItem.isAvailable = true;

        _safeMint(msg.sender, itemId);
        emit ItemListed(itemId, sellerId, name, price);
        itemIdCounter++;
    }

    function buyItem(uint256 itemId, uint256 buyerId) external payable {
        Item storage item = items[itemId];

        require(item.isAvailable, "Item is not available");
        require(msg.value >= item.price, "Insufficient funds to purchase");
        require(_msgSender() != ownerOf(itemId), "You cannot buy your own item");

        item.isAvailable = false;
        item.buyerId = buyerId;

        // Transfer the funds to the seller
        payable(ownerOf(itemId)).transfer(item.price);

        emit ItemSold(itemId, item.marketplaceId, item.sellerId, buyerId, item.name, item.price);
    }

    function withdrawBalance() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    // Get the chain ID
    function getChainId() external view returns (uint256) {
        return chainId;
    }
}