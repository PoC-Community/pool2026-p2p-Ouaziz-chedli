
No files changed, compilation skipped
Deployer: 0x2Ac5519FBaE5A2bC547Aa72b5aDa6256576fcd57
Deployed to: 0x5EEafA0e610C33f1c2FF8d5d3967fe26C655B67e // 
Transaction hash: 0xfe00595bb35c765019e24e99663349f129587b0d5b177b0a15979c44f1e8bbd7

No files changed, compilation skipped
Deployer: 0x2Ac5519FBaE5A2bC547Aa72b5aDa6256576fcd57
Deployed to: 0xf76ba2e3FFcb3c1C7C7a1e03db2AeEBc2820fb49
Transaction hash: 0x0f214a3956d03b543e98799017d595b110c1d5c1b376d48578f7bc480078da17


# Vérifier le baseURI
cast call 0xf76ba2e3FFcb3c1C7C7a1e03db2AeEBc2820fb49 "baseURI()" --rpc-url $RPC_URL

# Mint un NFT
cast send 0xf76ba2e3FFcb3c1C7C7a1e03db2AeEBc2820fb49 "mint(address)" 0x2Ac5519FBaE5A2bC547Aa72b5aDa6256576fcd57 \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY

# Vérifier le tokenURI
cast call 0xf76ba2e3FFcb3c1C7C7a1e03db2AeEBc2820fb49 "tokenURI(uint256)" 1 --rpc-url $RPC_URL



forge verify-contract 0xf76ba2e3FFcb3c1C7C7a1e03db2AeEBc2820fb49 src/PoolNFT.sol:PoolNFT \
  --chain sepolia \
  --etherscan-api-key "$ETHERSCAN_API_KEY"

# Vérifier le baseURI
cast call 0xb4c0Bdf04A0e0108907E81E906Ab9492fCe4f7a8 "baseURI()" --rpc-url $RPC_URL

# Mint un NFT
cast send 0xb4c0Bdf04A0e0108907E81E906Ab9492fCe4f7a8 "mint(address)" <YOUR_WALLET> \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY

# Vérifier le tokenURI
cast call 0xb4c0Bdf04A0e0108907E81E906Ab9492fCe4f7a8 "tokenURI(uint256)" 1 --rpc-url $RPC_URL

Compiler run successful!
Deployer: 0x2Ac5519FBaE5A2bC547Aa72b5aDa6256576fcd57
Deployed to: 0xb4c0Bdf04A0e0108907E81E906Ab9492fCe4f7a8
Transaction hash: 0xfee83e3d29529e4620e4b68b5c9e16ea3b1811feca04dadb59faed1509791125
➜  day2 git:(master) ✗ 