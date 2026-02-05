// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract Vault is ReentrancyGuard, Ownable {
    uint256 public totalShares;
    mapping(address => uint256) public sharesOf;
    IERC20 public immutable asset;

    using SafeERC20 for IERC20;

    event Deposit(address indexed user, uint256 assets, uint256 shares);
    event Withdraw(address indexed user, uint256 assets, uint256 shares);
    event RewardAdded(uint256 amount);

    error ZeroAmount();
    error InsufficientShares();
    error ZeroShares();

    constructor(address assetAddress) Ownable(msg.sender) {
        asset = IERC20(assetAddress);
    }

    function _convertToShares(uint256 assets) internal view returns (uint256) {
        if (totalShares == 0) return assets;
        uint256 _totalAssets = asset.balanceOf(address(this));
        if (_totalAssets == 0) return 0;
        uint256 shares = (assets * totalShares) / _totalAssets;
        return shares;
    }

    function _convertToAssets(uint256 shares) internal view returns (uint256) {
        if (totalShares == 0) return 0;
        uint256 _totalAssets = asset.balanceOf(address(this));
        if (_totalAssets == 0) return 0;
        uint256 assets = (shares * _totalAssets) / totalShares;
        return assets;
    }

    function deposit(uint256 assets) external nonReentrant returns (uint256) {
        if (assets == 0) revert ZeroAmount();
        uint256 shares = _convertToShares(assets);
        if (shares == 0) revert ZeroShares();

        sharesOf[msg.sender] += shares;
        totalShares += shares;

        asset.safeTransferFrom(msg.sender, address(this), assets);
        emit Deposit(msg.sender, assets, shares);
        return shares;
    }

    function withdraw(uint256 shares) external nonReentrant returns (uint256) {
        return _withdraw(shares);
    }

    function withdrawAll() external nonReentrant returns (uint256) {
        return _withdraw(sharesOf[msg.sender]);
    }

    function _withdraw(uint256 shares) internal returns (uint256) {
        if (shares == 0) revert ZeroShares();
        uint256 msgSenderShares = sharesOf[msg.sender];
        if (msgSenderShares < shares) revert InsufficientShares();
        uint256 assets = _convertToAssets(shares);
        sharesOf[msg.sender] -= shares;
        totalShares -= shares;
        asset.safeTransfer(msg.sender, assets);
        emit Withdraw(msg.sender, assets, shares);
        return assets;
    }

    function previewDeposit(uint256 assets) public view returns (uint256) {
        if (assets == 0) return 0;
        uint256 shares = _convertToShares(assets);
        if (shares == 0) return 0;
        return shares;
    }

    function previewWithdraw(uint256 shares) public view returns (uint256) {
        if (shares == 0) return 0;
        uint256 msgSenderShares = sharesOf[msg.sender];
        if (msgSenderShares < shares) return 0;
        uint256 assets = _convertToAssets(shares);
        return assets;
    }

    function totalAssets() public view returns (uint256) {
        return asset.balanceOf(address(this));
    }

    function currentRatio() external view returns (uint256) {
        if (totalShares == 0) return 1e18;
        uint256 totalAssets_ = asset.balanceOf(address(this));
        return (totalAssets_ * 1e18) / totalShares;
    }

    function assetsOf(address user) external view returns (uint256) {
        uint256 userShares = sharesOf[user];
        if (userShares == 0) return 0;
        uint256 assets = _convertToAssets(userShares);
        return assets;
    }

    function addReward(uint256 amount) external onlyOwner nonReentrant {
        if (amount == 0) revert ZeroAmount();
        if (totalShares == 0) revert ZeroShares();
        asset.safeTransferFrom(msg.sender, address(this), amount);
        emit RewardAdded(amount);
    }
}
