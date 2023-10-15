// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { Test, console2 } from "forge-std/Test.sol";
import { WrappedEther } from "../src/WrappedEther.sol";

contract WrappedEtherTest is Test {
    WrappedEther public weth;
    address user1;
    address user2;
    uint256 amount = 1 ether; // general amount for tests

    event Deposit(address indexed account, uint amount);
    event Withdraw(address indexed account, uint amount);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function setUp() public {
        weth = new WrappedEther();
        user1 = makeAddr("Alice");
        user2 = makeAddr("Bob");
        vm.startPrank(user1); // Set msg.sender for subsequent calls
        deal(user1, amount);  // set enough ether balance for user1 
    }

    // 測項 1: deposit 應該將與 msg.value 相等的 ERC20 token mint 給 user
    function testDeposit() public {
        weth.deposit{value: amount}();
        assertEq(weth.balanceOf(user1), amount);
        vm.stopPrank();
    }

    // 測項 2: deposit 應該將 msg.value 的 ether 轉入合約
    function testDepositETHtoContract() public {
        weth.deposit{value: amount}();
        assertEq(address(weth).balance, amount);
        vm.stopPrank();
    }

    // 測項 3: deposit 應該要 emit Deposit event
    function testDepositEmitEvent() public {
        vm.expectEmit();
        emit Deposit(user1, amount); // Emit the event expect to see
        weth.deposit{value: amount}(); // Perform the call
        vm.stopPrank();
    }

    // 測項 4: withdraw 應該要 burn 掉與 input parameters 一樣的 erc20 token
    function testWithdrawBurnERC20Token() public {
        weth.deposit{value: amount}();
        uint256 initTotalSupply = weth.totalSupply();
        weth.withdraw(amount);
        assertEq(initTotalSupply - weth.totalSupply(), amount);
        vm.stopPrank();
    }

    // 測項 5: withdraw 應該將 burn 掉的 erc20 換成 ether 轉給 user
    function testWithdrawTransferEtherToUser() public {
        weth.deposit{value: amount}();
        uint256 initBalance = user1.balance;
        weth.withdraw(amount);
        assertEq(user1.balance - initBalance, amount);
        vm.stopPrank();
    }

    // 測項 6: withdraw 應該要 emit Withdraw event
    function testWithdrawEmitEvent() public {
        weth.deposit{value: amount}();
        vm.expectEmit();
        emit Withdraw(user1, amount); // Emit the event expect to see
        weth.withdraw(amount); // Perform the call
        vm.stopPrank();
    }

    // 測項 7: transfer 應該要將 erc20 token 轉給別人
    function testTransfer() public {
        weth.deposit{value: amount}();
        weth.transfer(user2, amount);
        assertEq(weth.balanceOf(user2), amount);
        vm.stopPrank();
    }

    // 測項 8: approve 應該要給他人 allowance
    function testApprove() public {
        weth.deposit{value: amount}();
        weth.approve(user2, amount);
        assertEq(weth.allowance(user1, user2), amount);
        vm.stopPrank();
    }

    // 測項 9: transferFrom 應該要可以使用他人的 allowance
    function testTransferFrom() public {
        testApprove();
        vm.startPrank(user2); // switch to user2
        assertTrue(weth.transferFrom(user1, user2, amount));
        vm.stopPrank();
    }

    // 測項 10: transferFrom 後應該要減除用完的 allowance
    function testTransFormAllowanceChange() public {
        testApprove();
        vm.startPrank(user2); // switch to user2
        uint256 initAllowance = weth.allowance(user1, user2); // check initial allowance
        weth.transferFrom(user1, user2, amount);
        assertEq(initAllowance - weth.allowance(user1, user2), amount);
        vm.stopPrank();
    }

    // test deposit - revert deposit when insufficient fund
    function testDepositInsufficientFund() public {
        vm.expectRevert();
        weth.deposit{value: amount + 1}();
        vm.stopPrank();
    }

    // test withdraw - revert withdraw when insufficient fund
    function testWithdrawlInsufficientFund() public {
        weth.deposit{value: amount}();
        vm.expectRevert();
        weth.withdraw(amount + 1);
    }

    // test approve -  should emit event
    function testApproveEmitEvent() public {
        weth.deposit{value: amount}();
        vm.expectEmit();
        emit Approval(user1, user2, amount);
        weth.approve(user2, amount);
        vm.stopPrank();
    }

    // test transfer -  should emit event
    function testTransferEmitEvent() public {
        weth.deposit{value: amount}();
        vm.expectEmit();
        emit Transfer(user1, user2, amount);
        weth.transfer(user2, amount);
        vm.stopPrank();
    }

    // test transfer - revert when balance not anough
    function testTransferInsufficientBalance() public {
        weth.deposit{value: amount}();
        vm.expectRevert();
        weth.transfer(user2, amount + 1);
        vm.stopPrank();
    }

    // test transfrom - revert when allowance not enough
    function testTransfromInsufficientAllowance() public {
        testApprove();
        vm.startPrank(user2);
        vm.expectRevert();
        weth.transferFrom(user1, user2, amount + 1);
        vm.stopPrank();
    }
}