// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Dappazon {
    address public owner;

    struct Item {
        uint256 id;
        string name;
        string category;
        string image;
        uint256 cost;
        uint256 rating;
        uint256 stock;
    }

    struct Order {
     uint256 time;
     Item item;
    }

    mapping(uint256 => Item) public items;
    mapping(address => mapping(uint256 => Order)) public orders;
    mapping(address => uint256) public orderCount;
    
    event Buy(address buyer, uint256 orderId, uint256 itemId);
    event List(string name, uint256 cost, uint256 quantity);

    constructor() {
        owner = msg.sender;
        
    }
    modifier onlyOwner(){
     require(msg.sender == owner);
     _;
    }

    function list(
        uint256 _id,
        string memory _name,
        string memory _category,
        string memory _image,
        uint256 _cost,
        uint256 _rating,
        uint256 _stock
    ) public onlyOwner {
        // Create Item
        Item memory item = Item(
            _id,
            _name,
            _category,
            _image,
            _cost,
            _rating,
            _stock
        );

        // Add Item to mapping
        items[_id] = item;

        // Emit event
        emit List(_name, _cost, _stock);
    } 


    function buy(uint256 _id) public payable{

     // fetch item
     Item memory item = items[_id];

     // require enough ether to buy item
     require(msg.value >= item.cost);

     // require item to be in stock
     require(item.stock > 0);

     // create order
     Order memory order = Order(block.timestamp,item);

     // add the order to the user 

     orderCount[msg.sender]++;// order id
     orders[msg.sender][orderCount[msg.sender]] = order;

     // subtract stock
     items[_id].stock = item.stock - 1;

     // emit event
     emit Buy(msg.sender, orderCount[msg.sender],item.id);

    }

    function withdraw()public onlyOwner{   
     (bool success, ) = owner.call{value: address(this).balance}("");
     require(success);
    }
}