// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {Test} from "forge-std/Test.sol";
import {PoolToken} from "../src/PoolToken.sol";

contract PoolTokenTest is Test {
    PoolToken public token;
    address public owner;
    address public user;
    uint256 public constant INITIAL_SUPPLY = 10000 ether;

    function setUp() public {
        owner = address(this);
        user = address(0x1);
        token = new PoolToken(INITIAL_SUPPLY);
    }

    function testInitialSupply() public view {
        assertEq(token.totalSupply(), INITIAL_SUPPLY);
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY);
    }

    function testOnlyOwnerCanMint() public {
        vm.prank(user);
        vm.expectRevert();
        token.mint(user, 1000 ether);
    }
}
