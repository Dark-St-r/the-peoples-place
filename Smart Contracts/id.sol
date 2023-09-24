// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract UniqueIDIssuer {
    uint256 public marketplaceId;
    uint256 public sellerId;
    uint256 public buyerId;
    uint256 public itemId;

    // Chain ID of the Polygon network
    uint256 public chainId = 1101; // Replace with the actual Polygon chain ID

    constructor() {
        marketplaceId = 1;
        sellerId = 1;
        buyerId = 1;
        itemId = 1;
    }

    function getNextMarketplaceId() external returns (uint256) {
        uint256 id = marketplaceId + (chainId * 1000000);
        marketplaceId++;
        return id;
    }

    function getNextSellerId() external returns (uint256) {
        uint256 id = sellerId + (chainId * 1000000);
        sellerId++;
        return id;
    }

    function getNextBuyerId() external returns (uint256) {
        uint256 id = buyerId + (chainId * 1000000);
        buyerId++;
        return id;
    }

    function getNextItemId() external returns (uint256) {
        uint256 id = itemId + (chainId * 1000000);
        itemId++;
        return id;
    }
}