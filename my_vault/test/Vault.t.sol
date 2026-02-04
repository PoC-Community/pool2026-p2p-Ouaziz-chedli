// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {Vault} from "../src/Vault.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

// Simple mock ERC20 for testing
contract MockToken is ERC20 {
    constructor() ERC20("Mock", "MOCK") {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

contract VaultTest is Test {
    Vault public vault;
    MockToken public token;
    address public owner;
    address public user;
    uint256 public constant INITIAL_SUPPLY = 10000 ether;

    function setUp() public {
        owner = address(this);
        user = address(0x123);

        // Deploy real mock token
        token = new MockToken();
        vault = new Vault(address(token));

        // Mint tokens to owner and user
        token.mint(owner, INITIAL_SUPPLY);
        token.mint(user, INITIAL_SUPPLY);
    }

    function test_Deposit() public {
        uint256 depositAmount = 1000 ether;

        vm.startPrank(user);
        token.approve(address(vault), depositAmount);
        vault.deposit(depositAmount);
        vm.stopPrank();

        assertEq(vault.sharesOf(user), depositAmount);
    }

    function test_Withdraw() public {
        uint256 depositAmount = 1000 ether;

        vm.startPrank(user);
        token.approve(address(vault), depositAmount);
        vault.deposit(depositAmount);

        uint256 sharesToWithdraw = vault.sharesOf(user);
        vault.withdraw(sharesToWithdraw);
        vm.stopPrank();

        assertEq(vault.sharesOf(user), 0);
    }

    function test_AddReward() public {
        uint256 depositAmount = 1000 ether;

        // First, user deposits
        vm.startPrank(user);
        token.approve(address(vault), depositAmount);
        vault.deposit(depositAmount);
        vm.stopPrank(); 

        // Then, owner adds reward
        uint256 rewardAmount = 100 ether;
        token.approve(address(vault), rewardAmount);
        vault.addReward(rewardAmount);

        assertEq(token.balanceOf(address(vault)), depositAmount + rewardAmount);
    }

    function test_Ratio() public {
        uint256 depositAmount = 1000 ether;

        vm.startPrank(user);
        token.approve(address(vault), depositAmount);
        vault.deposit(depositAmount);
        vm.stopPrank();

        uint256 rewardAmount = 100 ether;
        token.approve(address(vault), rewardAmount);
        vault.addReward(rewardAmount);

        // Expected: 1100 assets / 1000 shares = 1.1e18
        uint256 expectedRatio = 1.1e18;
        uint256 actualRatio = vault.currentRatio();
        assertEq(actualRatio, expectedRatio);
    }

    function test_WithdrawAll() public {
        uint256 depositAmount = 1000 ether;

        vm.startPrank(user);
        token.approve(address(vault), depositAmount);
        vault.deposit(depositAmount);
        vm.stopPrank();

        uint256 rewardAmount = 100 ether;
        token.approve(address(vault), rewardAmount);
        vault.addReward(rewardAmount);

        vm.startPrank(user);
        vault.withdrawAll();
        vm.stopPrank();

        uint256 expectedBalance = INITIAL_SUPPLY -
            depositAmount +
            depositAmount +
            rewardAmount;
        assertEq(token.balanceOf(user), expectedBalance);
    }

    function test_PreviewDeposit() public view {
        uint256 depositAmount = 1000 ether;
        uint256 expectedShares = depositAmount; // Initial 1:1 ratio
        uint256 actualShares = vault.previewDeposit(depositAmount);
        assertEq(actualShares, expectedShares);
    }
}
