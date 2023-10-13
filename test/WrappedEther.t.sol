// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { Test, console2 } from "forge-std/Test.sol";
import { WrappedEther } from "../src/WrappedEther.sol";

contract WrappedEtherTest is Test {
    WrappedEther public weth;
    address user1;
    address user2;
    uint256 msgValue;

    function setUp() public {
        weth = new WrappedEther();
        user1 = makeAddr("Alice");
        user2 = makeAddr("Bob");
        msgValue = 1 ether;
        vm.startPrank(user1); // Set msg.sender for subsequent calls
        deal(user1, msgValue);  // set enough ether balance for user1 
    }

    // 測項 1: deposit 應該將與 msg.value 相等的 ERC20 token mint 給 user
    function testDeposit() public {
        weth.deposit{value: msgValue}();
        uint256 user1WethBalance = weth.balanceOf(user1);

        assertEq(user1WethBalance, msgValue);
        vm.stopPrank();
    }

    // 測項 2: deposit 應該將 msg.value 的 ether 轉入合約
    function testDepositETHtoContract() public {
        weth.deposit{value: msgValue}();
        uint256 wethEthBalance = address(weth).balance;

        assertEq(wethEthBalance, msgValue); // wethETHBalance from 0 to msgValue
        vm.stopPrank();
    }
}