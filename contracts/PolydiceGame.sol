//SPDX-License-Identifier: MIT

pragma ^0.8.6;

import "./GameState.sol";

contract PolydiceGame is VRFConsumerBase, Ownable {
	
	address payable private gameHost;
	address payable[] private players;
	mapping(address => bool) isAlreadyInGame;

	GameState private gameState;

	address private lastWinner;
	
	constructor(
		address _vrfCoordinator,
		address _link
	) public VRFConsumerBase(_vrfCoordinator, _link) {
		gameHost = msg.sender;
		gameState = GameState.CanStartNewGame;
	}
	
	function checkAndRestartGameState() private {
		require(gameState == GameState.CanStartNewGame);
		gameState = GameState.StartingNewGame;
	}
	
	function clearLastGameData() private {
		players = new address payable[](0);
	}

	function startNewGame() public onlyOwner {
		checkAndRestartGameState();
		clearLastGameData();
		gameState = GameState.WaitingForPlayers;
	}
	
	// TODO test if msg.sender is also available in those functions
	function checkIfPlayerCanJoin() private {
		require(gameState == GameState.WaitingForPlayers);
		// require(msg.value >= getEntranceFee());
		require(!isAlreadyInGame(msg.sender));
	}
	
	function addPlayerToGame() private {
		players.push(payable(msg.sender));
		// TODO test if isAlreadyInGame[randomAddress] would be false
		isAlreadyInGame[address] = true;
	}

	function joinGame() public payable {
		checkIfPlayerCanJoin();
		addPlayerToGame();
	}	

	mapping(address => uint256) betAmount;
	// NOTE should the amount to gamble be an argument
	function passLine() public payable {
		betAmount.add(msg.value);
	}
	
	// This function will be called every time you want a random number
	// so it will fullfill al the bets
	function doGameIteration() {
		
	}


	function endGame() public onlyOwner {
		//bla bla bla 
		// NOTE ni idea de como funciona el juego
	}










}
