// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "lib/openzeppelin-contracts/contracts/governance/Governor.sol";
import "lib/openzeppelin-contracts/contracts/governance/extensions/GovernorSettings.sol";
import "lib/openzeppelin-contracts/contracts/governance/extensions/GovernorCountingSimple.sol";
import "lib/openzeppelin-contracts/contracts/governance/extensions/GovernorVotes.sol";
import "lib/openzeppelin-contracts/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import "lib/openzeppelin-contracts/contracts/governance/extensions/GovernorTimelockControl.sol";
import "lib/openzeppelin-contracts/contracts/governance/TimelockController.sol";
import "lib/openzeppelin-contracts/contracts/governance/utils/IVotes.sol";
import "../src/PoolToken.sol";
import "../src/Vault.sol";
import "../src/VaultGovernor.sol";
import "forge-std/Test.sol";

contract VaultGovernanceTest is Test {
    VaultGovernor public governor;
    PoolToken public token;
    Vault public vault;
    address public owner;
    address public alice;

    function setUp() public {
        // Deploy a mock token that implements IVotes
        token = new PoolToken(1_000_000 ether); // Initial supply of 1M tokens
        vault = new Vault(address(token));
        // Deploy the governor with the mock token
        governor = new VaultGovernor(
            token,
            1, // voting delay
            5, // voting period
            4 // quorum percentage
        );
        vault.setGovernor(address(governor));
        owner = address(this);
        alice = address(0x123);

        // Give Alice tokens for deposits
        token.transfer(alice, 2_000 ether);
    }

    function testSetWithdrawalFee() public {
        vm.prank(address(governor));

        vault.setWithdrawalFee(500); // Set fee to 5%
        assertEq(vault.withdrawalFeeBps(), 500);
        vm.prank(address(governor));
        vault.setWithdrawalFee(200); // Update fee to 2%
        assertEq(vault.withdrawalFeeBps(), 200);
        // end the prank
        vm.stopPrank();
    }

    function testNonGovernorCannotSetFee() public {
        vm.prank(alice);
        vm.expectRevert();
        vault.setWithdrawalFee(300); // Should revert since Alice is not the governor
        vm.stopPrank();
    }

    function testFeeCannotExceedMax() public {
        vm.prank(address(governor));
        vm.expectRevert();
        vault.setWithdrawalFee(1500); // Should revert since fee exceeds MAX_FEE
        vm.stopPrank();
    }

    function testWithdrawalWithFee() public {
        vm.prank(address(governor));
        vault.setWithdrawalFee(500); // Set fee to 5%

        // Alice deposits then withdraws
        vm.startPrank(alice);
        token.approve(address(vault), 1_000 ether);
        vault.deposit(1_000 ether);
        vault.withdraw(500 ether);
        vm.stopPrank();

        // Expected: initial 2,000 - 1,000 + (500 - 5% fee)
        uint256 expectedWithdrawal = 500 ether - (500 ether * 500) / 10000;
        uint256 expectedFinalBalance = 2_000 ether -
            1_000 ether +
            expectedWithdrawal;
        assertEq(token.balanceOf(alice), expectedFinalBalance);
    }
}
