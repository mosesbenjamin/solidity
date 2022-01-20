// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract PiggyBank {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    event Deposit(uint256 amount);
    event Withdraw(uint256 amount);

    // receive() -> in-built function that handles receiving ether into a contract
    // fallback() -> another on-built function that does the same thing but with
    // little modifications
    // external -> a visibility modifier that allows for a function to only be
    // accessed outside the smart contract (for now ??)
    // payable -> makes it possible for a function to receive ether
    // msg.value -> amount of ether sent into the smart contract in that tsx
    receive() external payable {
        emit Deposit(msg.value);
    }

    // view -> specifies that the function doesn't modify the state variables
    // returns(uint) -> specifies that the function return value must be of
    // unsigned integer type
    function getBalance() external view returns (uint256) {
        uint256 balance;

        // assigns the total number of ether to balance
        balance = address(this).balance;
        return balance;
    }

    function withdraw() external {
        require(owner == msg.sender, "Only owner can call this function");

        // emits total ether in the contract about to be withdrawn
        emit Withdraw(address(this).balance);

        // sends the total ether in the contract to the owner(msg.sender) and
        // destroys the contract
        // payable -> makes it possible for the owner address to be able to receive
        // ether
        selfdestruct(payable(msg.sender));
    }
}
