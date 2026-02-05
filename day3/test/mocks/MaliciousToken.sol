// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Vault} from "../../src/Vault.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract MaliciousToken is ERC20 {
    address public vault;
    bool public attacking;
    uint256 public attackCount;
    uint256 public constant MAX_ATTACKS = 3;

    event AttackTriggered(uint256 attackCount);

    constructor() ERC20("Malicious", "MAL") {}

    function transfer(
        address to,
        uint256 amount
    ) public override returns (bool) {
        // Override transfer (called by vault.withdraw via safeTransfer)
        if (to != vault && attacking && attackCount < MAX_ATTACKS) {
            attackCount++;
            emit AttackTriggered(attackCount);
            Vault(vault).withdrawAll(); // Attempt reentrant call
        }
        return super.transfer(to, amount);
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

    function setVault(address _vault) public {
        vault = _vault;
    }

    function setAttacking(bool _attacking) external {
        attacking = _attacking;
    }
}
