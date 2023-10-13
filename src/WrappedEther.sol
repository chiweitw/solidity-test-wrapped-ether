// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// import ERC20 from openzeppelin
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract WrappedEther is ERC20 {
    constructor() ERC20("Wrapped Ether", "WETH") {}

    // Declare Deposit and Withdraw Event. When an event is emitted, it stores the arguments passed in transaction logs.
    event Deposit(address indexed account, uint amount);
    event Withdraw(address indexed account, uint amount);

    function deposit() external payable {
        _mint(msg.sender, msg.value);
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint _amount) external {
        // check if the balance >= withdrawl amount
        require(balanceOf(msg.sender) >= _amount);
        _burn(msg.sender, _amount);
        payable(msg.sender).transfer(_amount);
        emit Withdraw(msg.sender, _amount);
    }
}