//SPDX-License-Identifier: MIT

pragma ^0.8.6;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


// First realease with all the functionalitiy but without the
// game control automatization.

contract PolydiceGame is VRFConsumerBase, Ownable {
	
	constructor(
		address _vrfCoordinator,
		address _link
	) public VRFConsumerBase(_vrfCoordinator, _link) {

	}
	
	mapping(address => uint256) passLineBetAmounts;

	function passLineBet() payable {
		passLineBetAmounts.add(msg.value);
	}

	function doDiceRollAndFulfillBets() {
			
	}

}
