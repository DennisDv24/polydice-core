//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


// First realease with all the functionalitiy but without the
// game control automatization.

contract PolydiceGameV2 is VRFConsumerBase, Ownable {
	
	address payable public player;
	mapping(address => uint256) public passLineBetAmounts;
	uint256 public lastRandom;

	uint256 public fee;	
	bytes32 public keyhash;

	constructor(
		address _vrfCoordinator,
		address _link,
		uint256 _fee,
		bytes32 _keyhash
	) public VRFConsumerBase(_vrfCoordinator, _link) {
		player = payable(msg.sender);
		fee = _fee;
		keyhash = _keyhash;
	}
	

	function passLineBet() public payable {
		passLineBetAmounts[msg.sender] = msg.value;
	}

	function doDiceRollAndFulfillBets() public {
		bytes32 requestId = requestRandomness(keyhash, fee);
	}

	function fulfillRandomness(
		bytes32 _requestId,
		uint256 _randomness
	) internal override {
		require(_randomness > 0, "Random number not found");
		lastRandom = _randomness;
	}

}
