//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract Owner {

    address private owner;

    constructor() {
        owner = msg.sender;
    }

    struct WhiteData {
        address wallet;
        bool whitelist;
    }

    enum Status { Created,  Approved, Closed }

    mapping(string => address) public logins;
    mapping(address => WhiteData) public whiteList;

    modifier checkOfWhiteLists(address adr) {
        require(whiteList[adr].whitelist, unicode"Вы не в вайтлисте");
        _;
    }
    modifier checkStatusProduct(uint product_id, Status status) {
        require(products[product_id].status == status, unicode"Неверный статус продукта");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, unicode"У вас нет доступа");
        _;
    }

    function createUser(string memory  _login) public {
        require(logins[_login] == address(0), unicode"Пользователь с таким логином уже существует");
        logins[_login] =  msg.sender;
    }

    function updateWhiteList(address wallet) public onlyOwner {
        require(!whiteList[wallet].whitelist, unicode"Пользователь уже в вайтлисте");
        whiteList[wallet] = WhiteData(wallet, true);
    }

    function send_money(address payable adr_to) public payable {
        adr_to.transfer(msg.value);
    }

    struct Product {
        uint product_id;
        string name;
        address owner;
        uint value;
        Status status;
        string info;
    }

    Product[]  products;

    function createProduct(string memory name, uint value,  string memory info) public checkOfWhiteLists(msg.sender) {
        products.push(Product(products.length, name, msg.sender, value, Status.Created, info));
    }

    function approveProduct(uint product_id) public checkStatusProduct(product_id, Status.Created) onlyOwner {
        products[product_id].status = Status.Approved;
    }

    function buyProduct(uint product_id) public payable  checkStatusProduct(product_id, Status.Approved) {
        products[product_id].status = Status.Closed;
        uint256 fee =  products[product_id].value*1/100;
        uint value = products[product_id].value - fee;
        payable(products[product_id].owner).transfer(value);
        products[product_id].owner = msg.sender;
    }

    function sellProduct(uint product_id) public  checkStatusProduct(product_id, Status.Closed) {
        products[product_id].status = Status.Approved;
    }

    function withdrawFee() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}
