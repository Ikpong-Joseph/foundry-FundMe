// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    FundMe fundMe;
    uint256 public usd;
    address USER = makeAddr("user"); // Creates a new address for USER.
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant VALUE_SENT = 1 ether;

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: VALUE_SENT}();
        _;
    }

    // Set up the environment before each test
    function setUp() public {
        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUSerCanFundInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        assert(address(fundMe).balance == 0);
    }
}