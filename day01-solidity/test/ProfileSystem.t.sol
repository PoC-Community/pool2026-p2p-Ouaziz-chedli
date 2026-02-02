// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/ProfileSystem.sol";

contract ProfileTest is Test {
    ProfileSystem public system;
    address user1 = address(0x1);

    function setUp() public {
        system = new ProfileSystem();
    }

    function testCreateProfile() public {
        vm.startPrank(user1); // Simulate user1 calling
        system.createProfile("Alice");

        // Read from public mapping
        (uint256 level, , , string memory name) = system.profiles(user1);

        assertEq(name, "Alice");
        assertEq(level, 1);
        vm.stopPrank();
    }

    function testCannotCreateEmptyProfile() public {
        vm.startPrank(user1); // Simulate user1 calling
        vm.expectRevert(ProfileSystem.EmptyUsername.selector);
        system.createProfile("");
        vm.stopPrank();
    }

    function testCannotCreateDuplicateProfile() public {
        vm.startPrank(user1);
        system.createProfile("Alice");
        vm.expectRevert(ProfileSystem.UserAlreadyExists.selector);
        system.createProfile("Alice");
        vm.stopPrank();
    }

    function testLevelUp() public {
        vm.startPrank(user1);
        system.createProfile("Alice");
        vm.expectRevert(ProfileSystem.UserAlreadyExists.selector);
        system.createProfile("Alice");
        vm.stopPrank();
    }

    function testCannotLevelUpIfNotRegistered() public {
        vm.startPrank(user1);
        system.createProfile("Alice");
        // Read from public mapping
        system.levelUp();
        (uint256 level, , , string memory name) = system.profiles(user1);
        assertEq(name, "Alice");
        assertEq(level, 2);
        vm.stopPrank();
    }
}
