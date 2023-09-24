// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract CommentingAndReporting is AccessControl {
    struct Comment {
        uint256 itemId;
        uint256 marketplaceId;
        uint256 sellerId;
        uint256 buyerId;
        address commenter;
        string text;
    }

    struct Report {
        uint256 commentId;
        address reporter;
        string reason;
    }

    Comment[] public comments;
    Report[] public reports;

    event CommentAdded(
        uint256 indexed itemId,
        uint256 indexed marketplaceId,
        address indexed commenter,
        uint256 commentId,
        string text
    );
    event CommentReported(uint256 indexed commentId, address indexed reporter, string reason);

    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");

    constructor() {
        _setupRole(OWNER_ROLE, msg.sender);
    }

    modifier onlyOwner() {
        require(hasRole(OWNER_ROLE, msg.sender), "Caller is not the owner");
        _;
    }

    // Add a comment to an item
    function addComment(uint256 itemId, uint256 marketplaceId, uint256 sellerId, uint256 buyerId, string memory text) external {
        require(bytes(text).length > 0, "Comment text cannot be empty");
        require(itemId > 0, "Invalid item ID");

        uint256 commentId = comments.length;
        comments.push(Comment(itemId, marketplaceId, sellerId, buyerId, msg.sender, text));

        emit CommentAdded(itemId, marketplaceId, msg.sender, commentId, text);
    }

    // Report a comment as inappropriate
    function reportComment(uint256 commentId, string memory reason) external {
        require(bytes(reason).length > 0, "Reason cannot be empty");
        require(commentId < comments.length, "Invalid comment ID");

        reports.push(Report(commentId, msg.sender, reason));

        emit CommentReported(commentId, msg.sender, reason);
    }

    // Get all comments for a specific item
    function getCommentsForItem(uint256 itemId) external view returns (Comment[] memory) {
        Comment[] memory itemComments = new Comment[](comments.length);
        uint256 count = 0;

        for (uint256 i = 0; i < comments.length; i++) {
            if (comments[i].itemId == itemId) {
                itemComments[count] = comments[i];
                count++;
            }
        }

        return itemComments;
    }

    // Get all reported comments
    function getReportedComments() external view onlyOwner returns (Report[] memory) {
        return reports;
    }

    // Get the chain ID
    function getChainId() external view returns (uint256) {
        return block.chainid;
    }
}