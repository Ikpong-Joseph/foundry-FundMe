## About

**This, a Crowdsourcing smartcontract -- FundMe-- that receives ETH donations of at least $5 in value, is my first Foundry project inspired by the Cyfrin Updraft Patrick Colins' Foundry Course.**

This repo consists of:

-   **Source Contracts(src)**:
    - `FundMe.sol`: The main src logic allowing funding with ETH of $5 minimum value, and withdrawals by onlyOwner.
    - `PriceConverter.sol`: A PriceConverter library that returns the ETH value in USD.
-   **Scripts**
    - `DeployFundMe.s.sol`: Used to deploy the `FundMe.sol` during tests
    - `HelperConfig.s.sol`: Used to set what network the contracts are deployed to based on block.chainid
    - `Interactions.s.sol`: Used to demonstrate how the main functions of *Fund* and *Withdraw* of `FundMe.sol`are to be interacted with or behave.
-   **Tests**
    - `InteractionsTest.t.sol`: Tests the `Interactions.s.sol` script.
    - `mockv3aggregator.t.sol`: Tests the `PriceConverter.sol` library.
    - `FundMeTest.t.sol`: Tests the `FundMe.sol` contract and its `DeployFundMe.s.sol` script.

## Usage

```
git clone https://github.com/Ikpong-Joseph/foundry-FundMe.git
cd foundry-fund-me-f23
forge build
```
After cloning and cd, you can also use ```npx thirdweb deploy``` to interact with it on browser.

---
Thank you for your interest in my humble project/learnings! For questions or suggestions, reach out to us or open an issue on [GitHub](https://github.com/Ikpong-Joseph/foundry-FundMe). Happy reviewing! 🚀