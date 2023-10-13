// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { Test, console2 } from "forge-std/Test.sol";
import { WrappedEther } from "../src/WrappedEther.sol";

contract WrappedEtherTest is Test {
    WrappedEther public weth;
    address user1;
    address user2;
    uint256 depositAmount = 1 ether;
    uint256 withdrawAmount = 1 ether;

    event Deposit(address indexed account, uint amount);
    event Withdraw(address indexed account, uint amount);


    function setUp() public {
        weth = new WrappedEther();
        user1 = makeAddr("Alice");
        user2 = makeAddr("Bob");
        vm.startPrank(user1); // Set msg.sender for subsequent calls
        deal(user1, depositAmount);  // set enough ether balance for user1 
    }

    // 測項 1: deposit 應該將與 msg.value 相等的 ERC20 token mint 給 user
    function testDeposit() public {
         weth.deposit{value: depositAmount}();

        assertEq(weth.balanceOf(user1), depositAmount);
        vm.stopPrank();
    }

    // 測項 2: deposit 應該將 msg.value 的 ether 轉入合約
    function testDepositETHtoContract() public {
         weth.deposit{value: depositAmount}();

        assertEq(address(weth).balance, depositAmount);
        vm.stopPrank();
    }

    // 測項 3: deposit 應該要 emit Deposit event
    function testDepositEmitEvent() public {
        vm.expectEmit();
        emit Deposit(user1, depositAmount); // Emit the event expect to see
        weth.deposit{value: depositAmount}(); // Perform the call

        vm.stopPrank();
    }

    // 測項 4: withdraw 應該要 burn 掉與 input parameters 一樣的 erc20 token
    function testWithdrawBurnERC20Token() public {
         weth.deposit{value: depositAmount}();
        uint256 initTotalSupply = weth.totalSupply();
        weth.withdraw(withdrawAmount);

        assertEq(initTotalSupply - weth.totalSupply(), withdrawAmount);
    }

    // 測項 5: withdraw 應該將 burn 掉的 erc20 換成 ether 轉給 user
    function testWithdrawTransferEtherToUser() public {
        weth.deposit{value: depositAmount}();
        uint256 initBalance = user1.balance;
        weth.withdraw(withdrawAmount);

        assertEq(user1.balance - initBalance, withdrawAmount);
    }

    // 測項 6: withdraw 應該要 emit Withdraw event
    function testWithdrawEmitEvent() public {
        weth.deposit{value: depositAmount}();
        vm.expectEmit();
        emit Withdraw(user1, withdrawAmount); // Emit the event expect to see
        weth.withdraw(withdrawAmount); // Perform the call

        vm.stopPrank();
    }
}