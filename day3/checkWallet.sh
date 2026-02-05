#/bin/bash

souce .env

curl https://sepolia.drpc.org \
  -X POST \
  -H "Content-Type: application/json" \
  --data '{
    "jsonrpc": "2.0",
    "method": "eth_getBalance",
    "params": ["0x2Ac5519FBaE5A2bC547Aa72b5aDa6256576fcd57", "latest"],
    "id": 1
  }'   


# cast balance 0x2Ac5519FBaE5A2bC547Aa72b5aDa6256576fcd57 --rpc-url https://sepolia.drpc.org

#   cast call "0xd38e5c25935291ffd51c9d66c3b7384494bb099a" \
# "balanceOf(address)(uint256)" \
# "$PRIVATE_KEY_TEST" \
# --rpc-url "$RPC_SEPOLIA"


# cast balance "0x2Ac5519FBaE5A2bC547Aa72b5aDa6256576fcd57" --rpc-url https://rpc.sepolia.org