// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Ecommerce {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    uint256 public userCount = 0;
    uint256 public productCount = 0;

    struct User {
        string name;
        uint256 age;
        string location;
        bool isMerchant;
        uint256[] products;
    }

    struct Product {
        uint256 id;
        address owner;
        string name;
        string description;
        uint256 price;
    }

    event UserAdded(address userAddress, string name, bool isMerchant);
    event ProductAdded(
        uint256 id,
        address owner,
        string name,
        string description,
        uint256 price
    );
    event ProductBought(
        uint256 id,
        address newOwner,
        string name,
        string description,
        uint256 amountPaid
    );

    mapping(address => User) public users;
    mapping(address => bool) public userAdded;

    mapping(uint256 => Product) public products;
    mapping(uint256 => bool) public productAdded;

    // modifier -> runs before the function it is attached to
    // helps avoid code repitition
    modifier onlyOwner() {
        require(owner == msg.sender, "Only owner can call this function");
        // go ahead and run function being modified
        _;
    }

    modifier addUserOnce() {
        require(userAdded[msg.sender] == true, "User cannot be added twice");
        _;
    }

    modifier addProductByOnlyRegisteredUser() {
        require(userAdded[msg.sender] == true, "You are not a registered user");
        _;
    }

    modifier onlyMerchantCanAddProduct() {
        require(
            users[msg.sender].isMerchant == true,
            "Only merchants can add products"
        );
        _;
    }

    function join(
        string memory _name,
        uint256 _age,
        string memory _location,
        bool _isMerchant
    ) external addUserOnce {
        uint256[] memory emptyProductsArray;
        users[msg.sender] = User({
            name: _name,
            location: _location,
            age: _age,
            isMerchant: _isMerchant,
            products: emptyProductsArray
        });
        userAdded[msg.sender] = true;
        userCount += 1;
        emit UserAdded(msg.sender, _name, _isMerchant);
    }

    function addProduct(
        string memory _name,
        string memory _description,
        uint256 _price
    ) external addProductByOnlyRegisteredUser onlyMerchantCanAddProduct {
        productCount += 1;
        products[productCount] = Product({
            name: _name,
            description: _description,
            owner: msg.sender,
            id: productCount,
            price: _price
        });
        productAdded[productCount] = true;
        users[msg.sender].products.push(productCount);
        emit ProductAdded(
            productCount,
            msg.sender,
            _name,
            _description,
            _price
        );
    }

    function buyProduct(uint256 _id)
        external
        payable
        addProductByOnlyRegisteredUser
    {
        Product storage _product = products[_id];
        require(productAdded[_id] == true, "This product does not exist");
        require(
            msg.value >= _product.price,
            "You did not send enough ether to but this product"
        );
        // payable(_product.owner) -> cast address to enable it receive ether
        address payable addressOwner = payable(_product.owner);
        // transfer -> one of three methods for sending ether in solidity
        // send, call are the others
        addressOwner.transfer(_product.price);
        // update with new owner -> the person who just paid for the product
        _product.owner = msg.sender;
        emit ProductBought(
            _id,
            msg.sender,
            _product.name,
            _product.description,
            _product.price
        );
    }

    // returns the ether balance of the smart contract in wei.
    // wei is the smallest unit of ether. 1 ether = 1000000000000000000 wei
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}
