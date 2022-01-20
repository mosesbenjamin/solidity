// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Voting {
    // address -> holds 20 bytes addresses like 0x205aE213B67751fa825C8F3A5903Ab2c1D7B1B77
    address owner;

    // constructor -> is run when the contract is deployed
    constructor() {
        // msg -> object with a number of attributes in every smart contract of
        // which sender is one of.
        //  msg.sender returns the address of the caller of a smart contract
        owner = msg.sender;
    }

    uint256 public candidateCount = 0;

    uint256 public votersCount = 0;

    struct Candidate {
        uint256 id;
        string name;
    }

    struct Voters {
        uint256 id;
        string name;
        bool voted;
    }

    // mapping -> you cannot get the length of a mapping
    mapping(address => Candidate) public candidates;
    mapping(address => bool) public candidateInserted;
    mapping(address => uint256) public votes;

    mapping(address => Voters) public voters;
    mapping(address => bool) public voterInserted;

    function addCandidate(address _addr, string memory _name) public {
        // require is an in-built function in solifity that can take two args;
        // a condition that must be met and an error message that would be
        // thrown otherwise
        require(msg.sender == owner, "Only the owner can call this function");
        require(candidateInserted[_addr] == false, "Candidate cannot be added");
        candidateCount = candidateCount + 1;
        candidates[_addr] = Candidate(candidateCount, _name);
        candidateInserted[_addr] = true;
    }

    function addVoter(address _addr, string memory _name) public {
        require(msg.sender == owner, "Only owner can call this function");
        require(voterInserted[_addr] == false, "Voter cannot be added");
        votersCount = votersCount + 1;
        voters[_addr] = Voters(votersCount, _name, false);
        voterInserted[_addr] = true;
    }

    function vote(address _candidateAddress) public {
        require(
            voterInserted[msg.sender] == true,
            "You are not among the voters"
        );
        Voters storage voter = voters[msg.sender];
        require(voter.voted == false, "You cannot vote twice");
        votes[_candidateAddress] = votes[_candidateAddress] + 1;
        voter.voted = true;
    }
}
