-include .env

deploy-sepolia:
	forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url $(SEPOILA_RPC) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv