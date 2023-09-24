// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SocialGraph {
    struct UserInfo {
        string did;
        bool isRegistered;
    }

    mapping(address => UserInfo) public users;

    event UserRegistered(address indexed userAddress, string did);
    event DidUpdated(address indexed userAddress, string did);

    // Chain ID of the Polygon network
    uint256 public chainId = 1101; // Replace with the actual Polygon chain ID

    modifier notRegistered() {
        require(!users[msg.sender].isRegistered, "User is already registered");
        _;
    }

    modifier isRegistered() {
        require(users[msg.sender].isRegistered, "User is not registered");
        _;
    }

    function registerUser(string memory did) external notRegistered {
        require(bytes(did).length > 0, "DID cannot be empty");

        UserInfo storage newUser = users[msg.sender];
        newUser.did = did;
        newUser.isRegistered = true;

        emit UserRegistered(msg.sender, did);
    }

    function updateDid(string memory newDid) external isRegistered {
        require(bytes(newDid).length > 0, "New DID cannot be empty");

        UserInfo storage existingUser = users[msg.sender];
        existingUser.did = newDid;

        emit DidUpdated(msg.sender, newDid);
    }

    function getDid() external view isRegistered returns (string memory) {
        return users[msg.sender].did;
    }

    function getChainId() external view returns (uint256) {
        return chainId;
    }
}