#!/bin/bash

source .env

# # Make sure you have these environment variables set
# export PRIVATE_KEY_TEST=0x...
# export RPC_SEPOLIA=https://...
# export POOL_TOKEN_ADDRESS=0x...  # From Exercise day 2

# Deploy RewardToken + Vault
forge script script/DeployDeFiVault.s.sol:DeployDeFiVault \
  --rpc-url $RPC_SEPOLIA \
  --broadcast

# # Save the addresses from the output
# export REWARD_TOKEN_ADDRESS=0x...  # From deployment logs
# export VAULT_ADDRESS=0x...         # From deployment logs
