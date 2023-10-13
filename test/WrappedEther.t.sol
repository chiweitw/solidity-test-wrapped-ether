// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { Test, console2 } from "forge-std/Test.sol";
import { WrappedEther } from "../src/WrappedEther.sol";

contract WrappedEtherTest is Test {
    WrappedEther public weth;
    address user1;
    address user2;

    function setUp() public {
        weth = new WrappedEther();
        user1 = makeAddr("Alice");
        user2 = makeAddr("Bob");
    }

    // 測項 1: deposit 應該將與 msg.value 相等的 ERC20 token mint 給 user
    function testDeposit() public {
        uint amount = 1 ether; // declare desposit amount
        deal(user1, amount);  // set ether balance for user1 
        vm.startPrank(user1); // Set msg.sender for subsequent calls
        weth.deposit{value: amount}();
        uint256 wethBalance = weth.balanceOf(user1);

        assertEq(wethBalance, amount); // weth balance of user1 should equal to deposit amount 
        vm.stopPrank();
    }
}