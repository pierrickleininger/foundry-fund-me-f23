// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract FundMeTests is Test {
    using Strings for address;

    FundMe fundMe;

    function setUp() external {
        console.log("Initialize FundMe contract");
        fundMe = new FundMe();
    }

    function testMinimumIsFive() public view {
        console.log("Test if MINIMUM_USD is 5");
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsSender() public view {
        console.log("Test if contract owner is equal to message sender");
        console.log(
            string.concat("Contract owner : ", fundMe.i_owner().toHexString())
        );
        console.log(
            string.concat("Message sender : ", msg.sender.toHexString())
        );
        console.log(
            string.concat("FundMeTests : ", address(this).toHexString())
        );
        assertEq(fundMe.i_owner(), address(this));
    }
}
