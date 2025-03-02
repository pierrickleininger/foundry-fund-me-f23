// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract FundMeTests is Test {
    using Strings for address;

    DeployFundMe deployFundMe;
    FundMe fundMe;

    address private immutable USER_ADDRESS = makeAddr("user");
    uint256 private constant USER_INITIAL_BALANCE = 1 ether;
    uint256 private constant INSUFFICIENT_FUND_AMOUNT = 0.001 ether;
    uint256 private constant FUND_AMOUNT = 0.1 ether;

    function setUp() external {
        console.log("Initialize FundMe contract");
        deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        deal(USER_ADDRESS, USER_INITIAL_BALANCE);
    }

    function testMinimumIsFive() public view {
        console.log("Test if MINIMUM_USD is 5");
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsSender() public view {
        console.log("Test if contract owner is equal to message sender");
        console.log(
            string.concat("Contract owner : ", fundMe.getOwner().toHexString())
        );
        console.log(
            string.concat("Message sender : ", msg.sender.toHexString())
        );
        console.log(
            string.concat("FundMeTests : ", address(this).toHexString())
        );
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsIfLessThanFiveDollars() public {
        vm.expectRevert();
        fundMe.fund{value: INSUFFICIENT_FUND_AMOUNT}();
    }

    function testFundUpdatesFundedDataStructure() public funded {
        uint256 fundedAmount = fundMe.getAddressToAmountFunded(USER_ADDRESS);
        assertEq(FUND_AMOUNT, fundedAmount);
    }

    function testAddFunderToFundersArray() public funded {
        address funder = fundMe.getFunder(0);
        assertEq(USER_ADDRESS, funder);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER_ADDRESS);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testOwnerCanWithdraw() public funded {
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
    }

    function testWithdrawWithSingleFunder() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            endingOwnerBalance
        );

        assertEq(0, endingFundMeBalance);
    }

    function testWithdrawFromMultipleFunders() public funded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 2;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), FUND_AMOUNT);
            fundMe.fund{value: FUND_AMOUNT}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            endingOwnerBalance
        );

        assertEq(0, endingFundMeBalance);
    }

    function testWithdrawResetsArrays() public funded {
        // Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 fundedAmount = fundMe.getAddressToAmountFunded(USER_ADDRESS);
        assertEq(0, fundedAmount);

        vm.expectRevert();
        fundMe.getFunder(0);
    }

    modifier funded() {
        vm.prank(USER_ADDRESS);
        fundMe.fund{value: FUND_AMOUNT}();
        _;
    }
}
