// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "lib/forge-std/src/Script.sol";
import {FundMe} from "src/FundMe.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";

contract DeployFundMe is Script {

    function run() external returns (FundMe) {
        HelperConfig helperConfig= new HelperConfig(); 
        address ethusdPriceFeed = helperConfig.activeNetwork();

        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethusdPriceFeed); // The addreess in FundMe() is for ETH/USD pricefeed on sepoila testnet.
        vm.stopBroadcast();
        return fundMe;
    }
}