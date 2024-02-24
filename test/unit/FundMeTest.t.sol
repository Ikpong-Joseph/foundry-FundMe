// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    uint256 public usd;
    address USER = makeAddr("user"); // Creates a new address for USER.
    address USER2 = makeAddr("user2");
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant VALUE_SENT = 1 ether;

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: VALUE_SENT}();
        _;
    }

    // Set up the environment before each test
    function setUp() public {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        usd = fundMe.getMinimumUSD();
        vm.deal(USER, STARTING_BALANCE);
        vm.deal(USER2, STARTING_BALANCE);
    }

    function testMinimumDollarIsFive() public {
        // console.log("Minimum USD should be...");
        // console.log(usd);
        assertEq(fundMe.getMinimumUSD(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testAggregatorV3Version() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutSufficientEth() public {
        vm.expectRevert(); // cheatcode used to ensure the next line, whatever, fails
        fundMe.fund(); //This line, empty eth value is normally meant to cause a failing test.
        //Result is a passing test. Since fundMe.fund() is a failing condition. /*Confusing I know.*/
    }

    function testFundersStoresAreUpdated() public {
        vm.prank(USER);
        fundMe.fund{value: VALUE_SENT}();
        uint amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, VALUE_SENT);

        /*BREAKDOWN
        * This test checks if the amount funded by a particular addresss, USER, is same as the amount sent by that address.
        *
        * vm.prank(USER); Creates a new "user" address to call the next line of code.
        * fundMe.fund{value: VALUE_SENT}(); Calls the fund function of fundMe contract by sending VALUE_SENT worth of ETH (value means ETH).
        * uint amountFunded = fundMe.getAddressToAmountFunded(USER); Since USER called the fundMe.fund, USER is the funder.
                        uint amountFunded = the amount of VALUE_SENT by USER.
        * assertEq(amountFunded, VALUE_SENT); Checks if uint amountFunded is = VALUE_SENT.
        * Check the function getAddressToAmountFunded in fundMe.sol . It is a getter function for the mapping s_addressToAmountFunded.
        * PS. getAddressToAmountFunded can only be checked since original fundMe.fund() updates the mapping s_addressToAmountFunded.
        */
    }

    function testFunderIsAddedToFundersArray() public {
        vm.prank(USER);
        fundMe.fund{value: VALUE_SENT}();

        vm.prank(USER2);
        fundMe.fund{value: VALUE_SENT}();

        address funderAddress = fundMe.getFunders(0);
        assertEq(funderAddress, USER);

        /* BREAKDOWN
        * This is to check if a funders address exists in the funders[], and at its index; 0/1/2...

        * vm.prank(USER); fundMe.fund{value: VALUE_SENT}(); Sets a  USER address and calls fund()
            Since it is first, it is automatically at fundMe.getFunders(0);

        *vm.prank(USER2); fundMe.fund{value: VALUE_SENT}();  Sets a USER@ address that now calls fund()
            This USER2 is set at undMe.getFunders(1);

        * Since address funderAddress = fundMe.getFunders(index); can only be set once,

        * This will pass
            address funderAddress = fundMe.getFunders(0);
            assertEq(funderAddress, USER);
        * This too will pass
            address funderAddress = fundMe.getFunders(1);
            assertEq(funderAddress, USER2);

        * No need to makeAddr multiple accounts. Just vm.prank(USER) whenever you need a new address calling a transaction.

        * assertEq(left , right): The assert checks if left = right.
        */
    }

    function testOnlyOwnerCanWithdrawFails() public funded {
        vm.prank(USER);
        vm.expectRevert(); // I expect the next line to fail since
        fundMe.withdraw();
    }

    function testFundMeBalanceEqualsValueSent() public funded {
        uint256 fundMeBalance = address(fundMe).balance;
        assertEq(fundMeBalance, VALUE_SENT);
    }

    function testOnlyOwnerCanWithdrawPasses() public funded {
        //arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeContractBalance = address(fundMe).balance;

        //act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeContractBalance = address(fundMe).balance;

        //assert
        // assertEq(startingOwnerBalance , 0); // Checks if starting owner balance was 0. This logic will likely fail.
        // assertEq(endingOwnerBalance, startingFundMeContractBalance); // Checks if ending Owner balance = starrrting contract balance (i.e Owner withdrew all). This fails too.
        assertEq(endingFundMeContractBalance, 0); // Checking if contract's end balance = 0
        assertEq(
            endingOwnerBalance,
            startingFundMeContractBalance + startingOwnerBalance
        ); // A more accurate logic.
        // Checks if the funded contract balance is added to the starting owner balance, whatever it was.
    }

    function testWthhdrawFromMultipleFunders() public funded {
        uint160 totalNumberOfFunders = 10;
        uint160 startingIndexOfFunders = 1;

        for (
            uint160 i = startingIndexOfFunders;
            i < totalNumberOfFunders;
            i++
        ) {
            hoax(address(i), VALUE_SENT);
            fundMe.fund{value: VALUE_SENT}();
        }

        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingFundMeOwnerBalance = fundMe.getOwner().balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank;

        uint256 endingFundMeBalance = address(fundMe).balance;
        uint256 endingFundMeOwnerBalance = fundMe.getOwner().balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(
            endingFundMeOwnerBalance,
            startingFundMeBalance + startingFundMeOwnerBalance
        );

        /*BREAKDOWN
         *hoax(aaddress(i), VALUE_SENT); acts as vm.prank and vm.deal in one-- hoax.
         */
    }

    /*CALCULATE TX GAS COST
     * forge snapshot --match-test [Replace with test name]
     */
}
