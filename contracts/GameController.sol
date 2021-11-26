//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./PolydiceGame.sol";

contract GameController is VRFConsumerBase, Ownable {
	
	PolydiceGame private game;
	uint256 public bankFunds;
	
	uint256 fee;
	bytes32 keyhash;

	uint256 public timesRolledTheDices;

	uint256 public lastRandom;

	event RequestedRandomness(bytes32 requestId);
	event ReceivedRandomness(bool hasArrived, uint256 random);
	event DicesForRandomNumber(uint256 random, uint8 dice1, uint8 dice2);

	constructor(
		address _vrfCoordinator,
		address _link,
		uint256 _fee,
		bytes32 _keyhash
	) public payable VRFConsumerBase(_vrfCoordinator, _link) {
		bankFunds = msg.value;
		fee = _fee;
		keyhash = _keyhash;
		game = new PolydiceGame();
		timesRolledTheDices = 0;
	}
	
	
	function doDiceRolls() public {
		// TODO if youre waiting for other random number from chainlink you
		// cant roll the dices again (gameState = GameState.RollingDices)
		require(game.betsCanBeFulfilledWith(bankFunds), "The bank doesn't have enough money");
		bytes32 requestId = requestRandomness(keyhash, fee);
		emit RequestedRandomness(requestId);
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
		(uint8 d1, uint8 d2) = calcDiceValues();
		game.fulfillBets(d1, d2);
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
	function calcDiceValues() private returns (uint8, uint8) {
		uint8 dice1value = (uint8) ((lastRandom % (10**39)) % 6) + 1;
		uint8 dice2value = (uint8) ((lastRandom - dice1value)/(10**39) % 6) + 1;
		emit DicesForRandomNumber(lastRandom, dice1value, dice2value);
		timesRolledTheDices++;
		return (dice1value, dice2value);
	}

}
