// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {Vault} from "../src/Vault.sol";

contract DeployVault is Script {
    function run() external returns (address) {
        // Use an existing ERC20 token on Sepolia or deploy your own
        // Example: USDC on Sepolia = 0x6Aed6068EA2b0F08987c3d8818149375e9b19C94
        address tokenAddress = vm.envAddress("TOKEN_ADDRESS");

        vm.startBroadcast();
        Vault vault = new Vault(tokenAddress);
        vm.stopBroadcast();

        return address(vault);
    }
}
