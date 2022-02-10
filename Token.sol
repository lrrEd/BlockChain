// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

import './CustomLib.sol';

contract Token{

    using customLib for uint;

    uint256 public tokenPrice;
    address private owner;
    uint256 private tokenBought;
    uint256 private balance;
    uint256 private maxFee = 5; 
    // charge maximum 5% tokens as handling fees

    mapping(address => uint256) private balances;

    event Purchase(address buyer, uint256 amount);

    event Transfer(address sender, address receiver, uint256 amount);

    event Sell(address seller, uint256 amount);

    event Price(uint256 price);

    constructor(uint256 initialPrice) payable {
        owner = msg.sender;
        require(msg.value >= 100*initialPrice, "require initial balance more than 100 tokens");
        balance = msg.value;
        tokenPrice = initialPrice;
    }

    function buyToken(uint256 amount) public payable returns (bool) {
        require(msg.value == tokenPrice * amount, "money is not accurate, no changes");
        balances[msg.sender] += amount;
        tokenBought += amount;
        emit Purchase(msg.sender, amount);
        return true;
    }
    
    function transfer(address recipient, uint256 amount) public returns (bool) {
        require(balances[msg.sender] >= amount, "balance is not enough");
        
        uint256 transferValue = amount;
        if (amount>5){
            uint256 fee = amount / 20;
            if (fee > maxFee){
                fee = maxFee;
            }
            transferValue -= fee;
            tokenBought -= fee;
        }
        
        balances[msg.sender] -= amount;
        balances[recipient] += transferValue;

        emit Transfer(msg.sender, recipient, transferValue);
        return true;
    }

    function sellToken(uint256 amount) public payable returns (bool) {
        if(amount==0){
            return true;
        }
        require(amount>1);
        require(balances[msg.sender] >= amount, "balance is not enough to sell");
        balances[msg.sender] -= amount;
        tokenBought -= amount;
        uint256 value = amount * tokenPrice;
        //calls the function customSend in the customLib above
        customLib.customSend(value, msg.sender);
        emit Sell(msg.sender,amount);
        return true;
    }

    function changePrice(uint256 price) public returns (bool) {
        require(owner == msg.sender, "only the owner can change token price");
        require(tokenBought * price <= address(this).balance, "contract's balance not enough to pay");
        tokenPrice = price;
        emit Price(price);
        return true;
    }

    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }

}
