// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract CommentingAndReporting is Ownable {
    struct Comment {
        uint256 itemId;
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

    // Mapping from item ID to an array of comment IDs
    mapping(uint256 => uint256[]) public itemToComments;

    event CommentAdded(uint256 indexed commentId, address indexed commenter, uint256 indexed itemId, string text);
    event CommentReported(uint256 indexed commentId, address indexed reporter, string reason);

    constructor() {
        // Constructor can be left empty or customized as needed
    }

    // Add a comment to an item
    function addComment(uint256 itemId, string memory text) external {
        require(bytes(text).length > 0, "Comment text cannot be empty");
        require(itemId > 0, "Invalid item ID");

        uint256 commentId = comments.length;
        comments.push(Comment(itemId, msg.sender, text));
        itemToComments[itemId].push(commentId);

        emit CommentAdded(commentId, msg.sender, itemId, text);
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
        uint256[] storage commentIds = itemToComments[itemId];
        Comment[] memory itemComments = new Comment[](commentIds.length);

        for (uint256 i = 0; i < commentIds.length; i++) {
            itemComments[i] = comments[commentIds[i]];
        }

        return itemComments;
    }

    // Get all reported comments
    function getReportedComments() external view onlyOwner returns (Report[] memory) {
        return reports;
    }
}
