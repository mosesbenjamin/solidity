// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract GuessAWord {
    address public owner;
    // byte32 -> stores values of 32 bytes size and below. It stores values in hexadecimal.
    bytes32 public correctWord =
        0x3bf63e344ceb27303a6c41784b087cf05d1fea6f2cfa8e1d0a79dfb54a98c671;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "You are not the owner");
        _;
    }

    function setWord(string memory word) external onlyOwner {
        // abi.encodePacked() -> converts the word passed to the function to bytes32 because keccak256 takes only bytes values as input
        // keccak256 -> as a hashing fuction hashes the value using keccak256
        correctWord = keccak256(abi.encodePacked(word));
    }

    function guess(string memory word) external view returns (bool) {
        return keccak256(abi.encodePacked(word)) == correctWord;
    }
}
