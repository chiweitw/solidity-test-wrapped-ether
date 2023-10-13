// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { Test, console2 } from "forge-std/Test.sol";
import { WrappedEther } from "../src/WrappedEther.sol";

contract WrappedEtherTest is Test {
    WrappedEther public weth;
    address user1;
    address user2;
    uint256 msgValue;

    event Deposit(address indexed account, uint amount);

    function setUp() public {
        weth = new WrappedEther();
        user1 = makeAddr("Alice");
        user2 = makeAddr("Bob");
        msgValue = 1 ether;
        // vm.startPrank(user1); // Set msg.sender for subsequent calls
        // deal(user1, msgValue);  // set enough ether balance for user1 
    }

    function setDepositBase() public {
        vm.startPrank(user1); // Set msg.sender for subsequent calls
        deal(user1, msgValue);  // set enough ether balance for user1 
        weth.deposit{value: msgValue}(); // execute deposit
    }

    // 測項 1: deposit 應該將與 msg.value 相等的 ERC20 token mint 給 user
    function testDeposit() public {
        setDepositBase();

        assertEq(weth.balanceOf(user1), msgValue);
        vm.stopPrank();
    }

    // 測項 2: deposit 應該將 msg.value 的 ether 轉入合約
    function testDepositETHtoContract() public {
        setDepositBase();

        assertEq(address(weth).balance, msgValue);
        vm.stopPrank();
    }

    // 測項 3: deposit 應該要 emit Deposit event
    function testDepositEmitEvent() public {
        vm.expectEmit();
        
        emit Deposit(user1, msgValue); // Emit the event expect to see
        setDepositBase(); // Perform the call

        vm.stopPrank();
    }
}