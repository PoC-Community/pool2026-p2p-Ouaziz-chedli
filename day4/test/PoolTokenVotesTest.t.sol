// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "forge-std/Test.sol";
import "../src/PoolToken.sol";

contract PoolTokenVotesTest is Test {
    PoolToken public poolToken;
    address public owner;
    address public alice;
    address public bob;

    function setUp() public {
        owner = address(this);
        alice = address(0x123);
        bob = address(0x456);
        poolToken = new PoolToken(1000 * 10 ** 18);

        // Distribute tokens to Alice for delegation tests
        poolToken.transfer(alice, 100 * 10 ** 18);
    }

    function testInitialVotingPowerIsZero() view public {
        assertEq(poolToken.balanceOf(owner), 900 * 10 ** 18);
        assertEq(poolToken.getVotes(owner), 0);
    }

    function testDelegateToSelf() public {
        poolToken.delegate(owner);
        assertEq(poolToken.getVotes(owner), 900 * 10 ** 18);
    }

    function testDelegateToOther() public {
        vm.prank(alice);
        poolToken.delegate(bob);
        assertEq(poolToken.getVotes(bob), 100 * 10 ** 18);
        assertEq(poolToken.getVotes(alice), 0);
    }

    function testGetPastVotes() public {
        poolToken.delegate(owner);
        uint256 pastBlock = block.number;
        vm.roll(block.number + 1);
        assertEq(poolToken.getPastVotes(owner, pastBlock), 900 * 10 ** 18);
    }
}
