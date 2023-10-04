-include .env

build:; forge build

deploy-sepolia:
	forge script script/DeployCounter.s.sol:DeployCounter --rpc-url $(SEPOLIA_RPC) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv

upgrade-sepolia:
	forge script script/UpgradeCounter.s.sol:UpgradeCounter --rpc-url $(SEPOLIA_RPC) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) --ffi -vvvv

test-sepolia:
	forge test --fork-url $(SEPOLIA_RPC) -vvv