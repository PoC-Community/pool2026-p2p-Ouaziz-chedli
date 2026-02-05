// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/VaultWithHarvest.sol";
import "../src/PoolToken.sol"; // From Exercise 01;
import "../src/RewardToken.sol"; // From Exercise 5.1

/**
 * @notice Mock Uniswap Router for testing
 * @dev Simulates swap behavior with a fixed ratio
 */
contract MockUniswapRouter {
    uint256 public swapRatio = 100; // 1 RWRD = 1 POOL (100%)

    function setSwapRatio(uint256 _ratio) external {
        swapRatio = _ratio;
    }

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts) {
        require(deadline >= block.timestamp, "Expired");

        IERC20 tokenIn = IERC20(path[0]);
        IERC20 tokenOut = IERC20(path[1]);

        // Calculate output based on ratio
        uint256 amountOut = (amountIn * swapRatio) / 100;
        require(amountOut >= amountOutMin, "Slippage");

        // Transfer tokens
        tokenIn.transferFrom(msg.sender, address(this), amountIn);
        tokenOut.transfer(to, amountOut);

        amounts = new uint[](2);
        amounts[0] = amountIn;
        amounts[1] = amountOut;
    }

    function getAmountsOut(
        uint amountIn,
        address[] calldata path
    ) external view returns (uint[] memory amounts) {
        amounts = new uint[](2);
        amounts[0] = amountIn;
        amounts[1] = (amountIn * swapRatio) / 100;
    }
}

contract VaultWithHarvestTest is Test {
    VaultWithHarvest vault;
    PoolToken poolToken;
    RewardToken rewardToken;
    MockUniswapRouter router;

    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() public {
        // Deploy tokens
        poolToken = new PoolToken(1_000_000e18);
        rewardToken = new RewardToken(1_000_000e18);

        // Deploy mock router
        router = new MockUniswapRouter();

        // Fund router with POOL tokens for swaps
        poolToken.transfer(address(router), 100_000e18);

        // Deploy vault
        vault = new VaultWithHarvest(
            address(poolToken),
            address(rewardToken),
            address(router)
        );

        // Setup users
        poolToken.transfer(alice, 10_000e18);
        poolToken.transfer(bob, 10_000e18);
    }

    function testHarvestIncreasesRatio() public {
        // 1. Alice deposits 1000 POOL
        vm.startPrank(alice);
        poolToken.approve(address(vault), 1000e18);
        vault.deposit(1000e18);
        vm.stopPrank();

        uint256 ratioBefore = vault.currentRatio();

        // 2. Send 100 RWRD to vault (simulate rewards)
        rewardToken.transfer(address(vault), 100e18);

        // 3. Wait for cooldown
        vm.warp(block.timestamp + 1 hours);

        // 4. Call harvest()
        vault.harvest();

        // 5. Verify ratio has increased
        uint256 ratioAfter = vault.currentRatio();
        assertGt(
            ratioAfter,
            ratioBefore,
            "Ratio should increase after harvest"
        );

        // 6. Verify Alice can withdraw more than her initial deposit
        vm.prank(alice);
        uint256 aliceShares = vault.sharesOf(alice);
        uint256 aliceAssets = vault.previewWithdraw(aliceShares);
        assertGt(
            aliceAssets,
            1000e18,
            "Alice should have more assets than deposited"
        );
        // - testHarvestRevertsWithNoRewards
    }

    function testHarvestRevertsWithNoRewards() public {
        // 1. Alice deposits 1000 POOL
        vm.startPrank(alice);
        poolToken.approve(address(vault), 1000e18);
        vault.deposit(1000e18);
        vm.stopPrank();
        // 2. Wait for cooldown
        vm.warp(block.timestamp + 1 hours);
        // 3. Call harvest() without sending rewards
        vm.expectRevert(VaultWithHarvest.NoRewardsToHarvest.selector);
        vault.harvest();
    }

    function testHarvestRevertsDuringCooldown() public {
        // 1. Alice deposits 1000 POOL
        vm.startPrank(alice);
        poolToken.approve(address(vault), 1000e18);
        vault.deposit(1000e18);
        vm.stopPrank();
        // 2. Send 100 RWRD to vault (simulate rewards)
        rewardToken.transfer(address(vault), 100e18);
        // 3. Call harvest() immediately (should revert due to cooldown)
        vm.expectRevert(
            abi.encodeWithSelector(
                VaultWithHarvest.HarvestCooldownNotMet.selector,
                vault.harvestCooldown() - 0 // time remaining
            )
        );
        vault.harvest();
    }

    // TODO: Add more tests
    // - testHarvestRevertsWithNoStakers
    function testHarvestRevertsWithNoStakers() public {
        // 1. Send 100 RWRD to vault (simulate rewards)
        rewardToken.transfer(address(vault), 100e18);
        // 2. Wait for cooldown
        vm.warp(block.timestamp + 1 hours);
        // 3. Call harvest() without any stakers
        vm.expectRevert(VaultWithHarvest.NoStakers.selector);
        vault.harvest();
    }

    // - testSlippageProtection
    function testSlippageProtection() public {
        // 1. Alice deposits 1000 POOL
        vm.startPrank(alice);
        poolToken.approve(address(vault), 1000e18);
        vault.deposit(1000e18);
        vm.stopPrank();

        // 2. Send 100 RWRD to vault (simulate rewards)
        // ...existing code...
        rewardToken.transfer(address(vault), 100e18);

        // Don't warp time - harvest immediately
        uint256 expectedTimeRemaining = vault.harvestCooldown(); // Full cooldown
        vm.expectRevert(
            abi.encodeWithSelector(
                VaultWithHarvest.HarvestCooldownNotMet.selector,
                expectedTimeRemaining
            )
        );
        vault.harvest();
    }
}
