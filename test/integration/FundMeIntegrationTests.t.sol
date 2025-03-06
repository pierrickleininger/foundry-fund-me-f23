//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract FundMeIntegrationTests is Test {
    FundMe fundMe;

    address private immutable USER_ADDRESS = makeAddr("user");
    uint256 private constant USER_INITIAL_BALANCE = 1 ether;
    uint256 private constant INSUFFICIENT_FUND_AMOUNT = 0.001 ether;
    uint256 private constant FUND_AMOUNT = 0.1 ether;
    uint256 private constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER_ADDRESS, USER_INITIAL_BALANCE);
    }

    function testUserCanFund() public {
        vm.prank(USER_ADDRESS);
        fundMe.fund{value: FUND_AMOUNT}();

        address funder = fundMe.getFunder(0);
        assertEq(USER_ADDRESS, funder);

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        assert(address(fundMe).balance == 0);
    }
}
