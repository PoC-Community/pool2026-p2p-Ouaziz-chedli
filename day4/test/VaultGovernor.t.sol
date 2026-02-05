// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Governor} from "@openzeppelin/contracts/governance/Governor.sol";
import {GovernorSettings} from "@openzeppelin/contracts/governance/extensions/GovernorSettings.sol";
import {GovernorCountingSimple} from "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import {GovernorVotes} from "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import {GovernorVotesQuorumFraction} from "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import {GovernorTimelockControl} from "@openzeppelin/contracts/governance/extensions/GovernorTimelockControl.sol";
import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";
import {IVotes} from "@openzeppelin/contracts/governance/utils/IVotes.sol";
import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../src/VaultGovernor.sol";
import "../src/PoolToken.sol";

contract VaultGovernorTest is Test {
    VaultGovernor public governor;
    IVotes public token;

    function setUp() public {
        // Deploy a mock token that implements IVotes
        token = IVotes(address(new PoolToken(1_000_000 ether))); // Initial supply of 1M tokens

        // Deploy the governor with the mock token
        governor = new VaultGovernor(
            token,
            1, // voting delay
            5, // voting period
            4 // quorum percentage
        );
    }

    function testGovernorParameters() public view {
        assertEq(governor.votingDelay(), 1);
        assertEq(governor.votingPeriod(), 5);
        assertEq(governor.quorum(0), 0); // No votes, so quorum should be 0
    }

    function testQuorumCalculation() public {
        // The initial supply should be 1M tokens (1,000,000 * 10 ** 18)
        // Delegate tokens to enable voting power
        PoolToken(address(token)).delegate(address(this));

        // Move to the next block to ensure voting power is active
        vm.roll(block.number + 1);
        // Check that the quorum is calculated correctly based on total supply
        // Quorum should be 4% of 1M token supply = 40,000 tokens (in wei)
        uint256 expectedQuorum = (1_000_000 ether * 4) / 100; // 4% of total supply

        // Query quorum at the PREVIOUS block (block.number - 1)
        assertEq(governor.quorum(block.number - 1), expectedQuorum);
    }

    function testCreateProposal() public {
        // Delegate tokens to the proposer first
        PoolToken(address(token)).delegate(address(this));
        vm.roll(block.number + 1);

        // Build targets, values, calldatas arrays
        address[] memory targets = new address[](1);
        uint256[] memory values = new uint256[](1);
        bytes[] memory calldatas = new bytes[](1);
        targets[0] = address(0);
        values[0] = 0;
        calldatas[0] = "";

        uint256 proposalId = governor.propose(
            targets,
            values,
            calldatas,
            "Test Proposal"
        );
        assertTrue(proposalId > 0);
    }
}
