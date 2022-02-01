// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract CrowdFunding {
    address public owner;
    uint256 public ownerBalance = 0;

    mapping(address => uint256) public users;
    mapping(address => bool) public userAdded;
    uint256 userCount = 0;

    event UserAdded(address user);

    mapping(address => uint256) public donations;
    uint256 public donationsCount = 0;

    struct FundRaiser {
        address owner;
        string title;
        string description;
        uint256 target;
        uint256 amountRaised;
        uint256 balance;
        bool targetReached;
    }

    event FundRaiserCreated(
        address owner,
        string title,
        string description,
        uint256 target
    );

    mapping(uint256 => FundRaiser) public fundRaisers;
    mapping(uint256 => bool) public fundRaiserAdded;

    event Funded(
        address owner,
        uint256 amountSent,
        uint256 fundId,
        string fundTitle
    );

    uint256 fundRaiserCount = 0;

    event Redeemed(
        address owner,
        uint256 amount,
        uint256 fundRaiserId,
        string fundTitle
    );

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function join() external {
        require(userAdded[msg.sender] == false, "You are already registered");
        userCount += 1;
        users[msg.sender] = userCount;
        userAdded[msg.sender] = true;
        emit UserAdded(msg.sender);
    }

    function startFundRaiser(
        string memory _title,
        string memory _desc,
        uint256 target
    ) external {
        require(userAdded[msg.sender], "Sorry, you are not a registered user");
        fundRaiserCount += 1;
        fundRaisers[fundRaiserCount] = FundRaiser(
            msg.sender,
            _title,
            _desc,
            target,
            0,
            0,
            false
        );
        fundRaiserAdded[fundRaiserCount] = true;
        emit FundRaiserCreated(msg.sender, _title, _desc, target);
    }

    function fund(uint256 _id) external payable {
        require(msg.value > 0, "Not enough ether sent");
        require(
            fundRaiserAdded[_id],
            "This Id does not exist in the fundraisers list"
        );
        FundRaiser storage _fund = fundRaisers[_id];
        _fund.balance += msg.value;
        _fund.amountRaised += msg.value;
        if (_fund.targetReached == false) {
            if (_fund.amountRaised >= _fund.target) {
                _fund.targetReached = true;
            }
        }
        donations[msg.sender] += msg.value;
        donationsCount += 1;
        emit Funded(msg.sender, msg.value, _id, _fund.title);
    }

    function redeemFunds(uint256 _fundRaiserId, uint256 amount) external {
        require(
            fundRaiserAdded[_fundRaiserId],
            "This Id does not exist in the fundraisers list"
        );
        FundRaiser storage _fund = fundRaisers[_fundRaiserId];
        require(
            msg.sender == _fund.owner,
            "You are not the owner of this fundraiser"
        );
        require(_fund.balance >= amount, "Insufficient balance");
        require(_fund.targetReached, "Target has not been reached");
        uint256 ownerShare = amount / 10;
        uint256 amountSendable = amount - ownerShare;
        (bool sent, ) = payable(msg.sender).call{value: amountSendable}("");
        require(sent, "Failed to send ether");
        _fund.balance -= amount;
        ownerBalance += ownerShare;
        emit Redeemed(msg.sender, amountSendable, _fundRaiserId, _fund.title);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function withdraw() external onlyOwner {
        (bool sent, ) = payable(msg.sender).call{value: ownerBalance}("");
        require(sent, "Failed to send ether");
        ownerBalance = 0;
    }
}
