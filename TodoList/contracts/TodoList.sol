// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

// creates a contract object just like classes are created in other languages
contract TodoList {
    // uint -> unsigned integer used to store numbers 0 and above
    // public -> visibility modifier
    uint256 public count;

    // struct -> used for grouping related together
    struct Task {
        uint256 id;
        string content;
        bool completed;
    }

    // mapping -> similar to hash tables/ dictionaries
    // uint -> key, Task is the value of the mapping
    // mapping are not iterable
    mapping(uint256 => Task) public tasks;

    // event -> used for logging in the smart contract
    // logs are stored in the blockchain and are accessible
    // using address of the conreact. A generated event is not
    // accessible from within the contract, not even the one which
    // have the created and emitted them
    event TaskCreated(uint256 id, string content, bool completed);

    event TaskCompleted(uint256 id, bool completed);

    // memory -> location where the data would be stored. Function arguments
    // are stored temporarily, unlike state variables like 'count' above, that
    // get stored in the 'storage'
    function createTask(string memory _content) public {
        count = count + 1;
        tasks[count] = Task(count, _content, false);
        emit TaskCreated(count, _content, false);
    }

    function checkTask(uint256 _id) public {
        Task memory _task = tasks[_id];
        _task.completed = true;
        tasks[_id] = _task;
        emit TaskCompleted(_id, true);
    }
}
