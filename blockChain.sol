// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Game{
    
    address public playerA;
    bytes32 public commitmentA;// the crypto input of playerA
    
    address public playerB;
    bool public choiceB;

    mapping(address => uint256) public balances;
    
    bool public gameRunning;// the state of game
    
    uint256 expiration;// time expiration
    
    
    /**
     * The first player starts game.
     * Players should set msg.value not less than 1 ether, 
     * or ensure its account has at least 1 ether as deposit.
     *  example commitment: 0xe98211167d25b391f8978e0582b7bf9e40716a2d81836046892e34085e2c5343
     *  hash of (true, 0x1234567891234567891234567891234500000000000000000000000000000000)
     **/
    function startGame(bytes32 commitment) public payable{
        require(playerA==address(0), "game is running"); //only when there is no one in game , can players start game
        if(balances[msg.sender] < 1 ether){
            require(msg.value >= 1 ether, "1 ETH is required as deposit");
        }
        playerA = msg.sender;
        commitmentA = commitment;
        balances[msg.sender] += msg.value;
        gameRunning = true;
        expiration = block.timestamp + 180; // one game can last 5 hours mostly
    }
    
    /**
     * The second player joins game
     * one player cannot make choice twice
     **/
    function joinGame(bool choice) public payable{
        require(msg.sender != playerA, "one player can make choice only once");
        require(gameRunning , "no game is running");
        require(playerB == address(0), "already two players");
        
        if(balances[msg.sender] < 1 ether){
            require(msg.value >= 1 ether, "1 ETH is required as deposit");
        }
        playerB = msg.sender;
        balances[msg.sender] += msg.value;
        choiceB = choice;
        expiration = block.timestamp + 1;
    }
    
    /**
     * If no one wants to join game, playerA can cancel game
     **/
    function cancelGame() public {
        require(gameRunning, "there is no game running");
        require(playerA == msg.sender && playerB == address(0), "game is running, cannot be canceled");
        resetGame();
    }
    
    /**
     *  1) two players have made decisions, but A refuses to reveal, B wins (time expiration is 4 hours)
     *  2) A starts game, no one joins game, A forget to cancel game (time expiration is 5 hours)
     *  once time expired, anyone can end this game
     **/
    function timeOut() public {
        require(block.timestamp >= expiration, "game is running, time not expirated");
        require(gameRunning, "no game running, cannot claim time out");
        if(playerB != address(0)){
            balances[playerB] += 1 ether;
            balances[playerA] -= 1 ether;
        }
        resetGame();
    }

    /**
     *  playerA reveals the result
     **/
    function reveal(bool choiceA, bytes32 nonce) public{
        require(playerB != address(0),"the second player hasn't make choice");
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
    
    /**
     * each player can withdraw money at anytime except when game is running
     * */
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
