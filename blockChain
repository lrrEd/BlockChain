// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Game{
    
    address public playerA;
    bytes32 public commitmentA;// the crypto input of playerA
    
    address public playerB;
    bool public choiceB;

    mapping(address => uint256) public balances;
    
    bool gameRunning;
    
    uint256 expiration;
    
    
    
    function startGame(bytes32 commitment) public payable{//the first player starts game
        require(playerA==address(0), "game is running"); //only when there is no one in game , can players start game
        if(balances[msg.sender] < 1 ether){
            require(msg.value >= 1 ether, "1 ETH is required as deposit");
        }
        playerA = msg.sender;
        commitmentA = commitment;
        balances[msg.sender] += msg.value;
        gameRunning = true;
    }
    
    function joinGame(bool choice) public payable{
        require(msg.sender != playerA, "one player can make choice only once");
        require(gameRunning , "no game is running");
        require(playerB == address(0), "already two players");
        
        if(balances[msg.sender] < 1 ether){
            require(msg.value >= 1 ether, "1 ETH is required as deposit");
        }
        balances[msg.sender] += msg.value;
        choiceB = choice;
        playerB = address(msg.sender);
        expiration = block.timestamp + 1;
    }
    
    function cancelGame() public {
        require(gameRunning, "there is no game running");
        require(playerA == msg.sender && playerB == address(0), "game is running, cannot be canceled");
        //resetGame();
    }
    
    function claimTimeOut() public {
        require(block.timestamp >= expiration, "game is running, time not expirated");
        require(gameRunning, "no game running, cannot claim time out");
        balances[playerB] += 1 ether;
        balances[playerA] -= 1 ether;
        resetGame();
    }

    
    function reveal(bool choiceA, bytes32 nonce) public{
        require(playerB > address(0),"the second player hasn't make choice");
        require(block.timestamp < expiration, "time expirated");
        require(keccak256(abi.encodePacked(choiceA, nonce)) == commitmentA);
        if(choiceA == choiceB){
            balances[playerA] += 1 ether;
            balances[playerB] -= 1 ether;
        }else {
            balances[playerB] += 1 ether;
            balances[playerA] -= 1 ether;
        }
            resetGame();
    }
    
    function withdrawBalance() public payable{
        require(balances[msg.sender] > 0, "balance is zero");
        require(!gameRunning, "game is running, cannot withdraw balance");
        uint256 balance = balances[msg.sender];
        balances[msg.sender] = 0;
        payable(msg.sender).transfer(balance);
    }
    
    function resetGame() internal {
        delete playerA;
        delete playerB;
        delete commitmentA;
        delete choiceB;
        delete expiration;
        gameRunning = false;
    }
    
}
