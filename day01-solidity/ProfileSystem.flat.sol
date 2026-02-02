// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// src/ProfileSystem.sol

contract ProfileSystem {
    enum Role {
        GUEST,
        USER,
        ADMIN
    }
    struct UserProfile {
        uint64 level;
        uint32 lastUpdated;
        Role role;
        string username;
    }
    mapping(address => UserProfile) public profiles;
    error UserAlreadyExists();
    error EmptyUsername();
    error UserNotRegistered();

    modifier onlyRegistered() {
        if (profiles[msg.sender].level == 0) {
            revert UserNotRegistered();
        }
        _;
    }

    function createProfile(string calldata _name) external {
        if (bytes(_name).length == 0) {
            revert EmptyUsername();
        }
        if (profiles[msg.sender].level != 0) {
            revert UserAlreadyExists();
        }
        profiles[msg.sender] = UserProfile({
            username: _name,
            level: 1,
            role: Role.USER,
            lastUpdated: uint32(block.timestamp)
        });
        emit ProfileCreated(msg.sender, _name);
    }

    function levelUp() external onlyRegistered {
        UserProfile storage p = profiles[msg.sender];
        p.level += 1;
        p.lastUpdated = uint32(block.timestamp);
        emit LevelUp(msg.sender, p.level);
    }

    event LevelUp(address indexed user, uint256 newLevel);
    event ProfileCreated(address indexed user, string username);
}

