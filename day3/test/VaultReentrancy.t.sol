// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {Vault} from "../src/Vault.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {MaliciousToken} from "./mocks/MaliciousToken.sol";

contract VaultReentrancyTest is Test {
    Vault public vault;
    MaliciousToken public maliciousToken;
    address public owner;
    address public attacker;
    uint256 public constant INITIAL_SUPPLY = 10000 ether;

    function setUp() public {
        owner = address(this);
        attacker = address(0x123);

        // Deploy malicious token and vault
        maliciousToken = new MaliciousToken();
        vault = new Vault(address(maliciousToken));

        // Set vault address in malicious token
        maliciousToken.setVault(address(vault));

        // Mint tokens to attacker
        maliciousToken.mint(attacker, INITIAL_SUPPLY);

        // Attacker approves vault to spend tokens
        vm.startPrank(attacker);
        maliciousToken.approve(address(vault), INITIAL_SUPPLY);
        vm.stopPrank();
    }

    function test_ReentrancyAttack() public {
        uint256 depositAmount = 1000 ether;

        // First, attacker deposits normally (no attack)
        vm.startPrank(attacker);
        vault.deposit(depositAmount);
        vm.stopPrank();

        // Enable attack
        maliciousToken.setAttacking(true);

        // Now attempt withdrawal with attack enabled
        vm.startPrank(attacker);
        vm.expectRevert(); // Reentrancy guard blocks the reentrant withdrawAll
        vault.withdraw(depositAmount);
        vm.stopPrank();

        // Verify: attacker still has their shares
        assertEq(vault.sharesOf(attacker), depositAmount);
    }
}
