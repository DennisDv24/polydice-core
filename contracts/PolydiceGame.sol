//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

contract PolydiceGame {
	
	mapping(address => uint256) public passLineBetAmounts;
	address payable[] public passLinePlayers;
	uint256 public currentPlayers;

	uint8 public dice1value;
	uint8 public dice2value;
	uint8 public diceSum;

	uint256 public fee;	
	bytes32 public keyhash;

	// Should be a variable for automatic games?
	uint256 public MAX_PLAYERS = 10; 
	
	// Args: game configurations, like the constant "MAX_PLAYERS"
	constructor() public {
		passLinePlayers = new address payable[](MAX_PLAYERS);
		currentPlayers = 0;
	}
	
	function passLineBet() public payable {
		if(!isOnPlayers(msg.sender))
			addToPlayers(msg.sender);
		passLineBetAmounts[msg.sender] += msg.value;
	}

		function isOnPlayers(address player) private returns(bool) {
			return passLineBetAmounts[player] > 0;
		}

		function addToPlayers(address player) private {
			passLinePlayers[currentPlayers] = payable(player);
			currentPlayers++;
		}

	function betsCanBeFulfilledWith(uint256 bankFunds) public returns(bool) {
		// based on the game rules,
		// for example, if a player can make an 2x
		// and the bank doenst have 1x his value,
		// then the bets can't be fulfilled
		return true;
	}
	
	function fulfillBets(uint8 dice1, uint8 dice2) external {
		dice1value = dice1;
		dice2value = dice2;
		diceSum = dice1 + dice2;
		fulfillPassLines();
	}

	function fulfillPassLines() private {
		for (uint i = 0; i < currentPlayers; i++) 
			fulfillPassLine(passLinePlayers[i]);
	}
	

	function fulfillPassLine(address payable player) private {
		if (hasWonPassLine(player)) {
			player.transfer(passLineBetAmounts[player] * 2);
			passLineBetAmounts[player] = 0;
		} else if(hasLostPassLine(player)) 
			passLineBetAmounts[player] = 0;
		else {
			// TODO add here the on/off shit
		}
	}

	function hasWonPassLine(address player) private returns(bool) {
		return diceSum == 7 || diceSum == 11;
	}

	function hasLostPassLine(address player) private returns(bool) {
		return diceSum == 2 || diceSum == 3 || diceSum == 12;
	}


}
