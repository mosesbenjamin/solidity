// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Wallet {
    mapping(address => uint256) public balances;

    event Withdraw(address receiver, uint256 amount);
    event Sent(address sender, address receiver, uint256 amount);

    bool locked;

    modifier noReEntrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }

    receive() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) external noReEntrant {
        uint256 balance = balances[msg.sender];
        require(
            amount <= balance,
            "You don't have enough ether in your balance"
        );
        // call is similar to the transfer but it returns a boolean
        // value(sent) and a bytes32 value.
        (bool sent, ) = payable(msg.sender).call{value: amount}("");
        require(sent, "Failed to send Ether");
        emit Withdraw(msg.sender, amount);
    }

    function send(address payable receiver, uint256 amount) external {
        uint256 balance = balances[msg.sender];
        require(
            amount <= balance,
            "You don't have enough ether in your balance"
        );
        balance -= amount;
        balances[receiver] += amount;
        emit Sent(msg.sender, receiver, amount);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
