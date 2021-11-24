//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


// First realease with all the functionalitiy but without the
// game control automatization.

contract PolydiceGameV2 is VRFConsumerBase, Ownable {
	
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

	function doDiceRollAndFulfillBets() public {
		// TODO if youre waiting for other random number from chainlink you
		// cant roll the dices again
		bytes32 requestId = requestRandomness(keyhash, fee);
		emit RequestedRandomness(requestId);
	}

	function fulfillRandomness(
		bytes32 _requestId,
		uint256 _randomness
	) internal override {
		if(_randomness == lastRandom || _randomness == 0) {
			emit ReceivedRandomness(false, 0);
			require(_randomness > 0, "Random number not found");
		} 

		lastRandom = _randomness;
		emit ReceivedRandomness(true, lastRandom);
		
		calcDiceValues();
		fulfillPassLines();
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

	function fulfillPassLines() private {
		for (uint i = 0; i < currentPlayers; i++) {
			fulfillPassLine(passLinePlayers[i]);
		}	
	}
	

	// TODO refactor into a "gotCrabs" function or something
	// TODO implement a banking system (to fix what haappens on the
	// nested if)
	function fulfillPassLine(address payable player) private {
		if (diceSum == 7 || diceSum == 11) {
			if(address(this).balance < passLineBetAmounts[player] * 2){
				player.transfer(address(this).balance);		
			}
			else {
				player.transfer(passLineBetAmounts[player] * 2);
			}
			passLineBetAmounts[player] = 0;
		} else if(diceSum == 2 || diceSum == 3 || diceSum == 12) {
			passLineBetAmounts[player] = 0;
		} else {
			// TODO add here the on/off shit
		}
	}




}
