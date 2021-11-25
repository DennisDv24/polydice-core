//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


// First realease with all the functionalitiy but without the
// game control automatization.

contract PolydiceGame is VRFConsumerBase, Ownable {
	
	mapping(address => uint256) public passLineBetAmounts;
	address payable[] public passLinePlayers;
	uint256 public currentPlayers;

	uint256 public lastRandom;

	uint8 public dice1value;
	uint8 public dice2value;
	uint8 public diceSum;
	uint256 public timesRolledTheDices;

	uint256 public fee;	
	bytes32 public keyhash;

	uint256 public MAX_PLAYERS = 10;
	
	event RequestedRandomness(bytes32 requestId);
	event ReceivedRandomness(bool hasArrived, uint256 random);
	event DicesForRandomNumber(uint256 random, uint8 dice1, uint8 dice2);

	constructor(
		address _vrfCoordinator,
		address _link,
		uint256 _fee,
		bytes32 _keyhash
	) public VRFConsumerBase(_vrfCoordinator, _link) {
		fee = _fee;
		keyhash = _keyhash;
		passLinePlayers = new address payable[](MAX_PLAYERS);
		currentPlayers = 0;
		timesRolledTheDices = 0;
	}
	

	function passLineBet() public payable {
		if(!isOnPlayers(msg.sender)) {
			addToPlayers(msg.sender);
		}
		passLineBetAmounts[msg.sender] += msg.value;
	}

	function isOnPlayers(address player) private returns(bool) {
		return passLineBetAmounts[player] > 0;
	}


	function addToPlayers(address player) private {
		passLinePlayers[currentPlayers] = payable(player);
		currentPlayers++;
	}

	function doDiceRolls() public {
		// TODO if youre waiting for other random number from chainlink you
		// cant roll the dices again
		require(betsCanBeFulfilled(), "The bank doesn't have enough money");
		bytes32 requestId = requestRandomness(keyhash, fee);
		emit RequestedRandomness(requestId);
	}

	function betsCanBeFulfilled() public returns(bool) {
		// based on the game rules,
		// for example, if a player can make an 2x
		// and the bank doenst have 1x his value,
		// then the bets can't be fulfilled
		return true;
	}
	

	// In local you can just call this function with
	// an non random '_randomness', because in local
	// or in forks the random numbers wont work.
	function fulfillRandomness(
		bytes32 _requestId,
		uint256 _randomness
	) internal override {
		checkIfTheBetsCanFulfill(_randomness);
		updateRandomNumber(_randomness);
		calcDiceValues();
		fulfillBets();
	}

	function checkIfTheBetsCanFulfill(uint256 _randomness) public returns(bool) {
		if(!randomHasBeenCorrectlyCalculated(_randomness)) {
			emit ReceivedRandomness(false, 0);
			require(_randomness > 0, "Random number not found");
		} 
	}

	function randomHasBeenCorrectlyCalculated(uint256 _randomness) public returns(bool) {
		return _randomness != lastRandom && _randomness != 0;
	}	
	
	function updateRandomNumber(uint256 _randomness) private {
		lastRandom = _randomness;
		emit ReceivedRandomness(true, lastRandom);
	}
	
	// The number as string has length 78,
	// so you do some aritmetic operaions
	// to divide the random number into
	// 2 random dice values
	function calcDiceValues() private {
		dice1value = (uint8) ((lastRandom % (10**39)) % 6) + 1;
		dice2value = (uint8) ((lastRandom - dice1value)/(10**39) % 6) + 1;
		emit DicesForRandomNumber(lastRandom, dice1value, dice2value);
		diceSum = dice1value + dice2value;
		timesRolledTheDices++;
	}
	
	function fulfillBets() private {
		fulfillPassLines();
	}

	function fulfillPassLines() private {
		for (uint i = 0; i < currentPlayers; i++) {
			fulfillPassLine(passLinePlayers[i]);
		}	
	}
	

	// TODO refactor into a "gotCrabs" function or something
	// TODO implement a banking system (to fix what haappens on the
	// nested if)
	function fulfillPassLine(address payable player) private {
		if (hasWonPassLine(player)) {
			if(address(this).balance < passLineBetAmounts[player] * 2){
				player.transfer(address(this).balance);		
			}
			passLineBetAmounts[player] = 0;
		} else if(hasLostPassLine(player)) {
			passLineBetAmounts[player] = 0;
		} else {
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
