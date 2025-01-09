// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

/**
 * @title A sample Raffle contract
 * @author vntodorov
 * @notice This contract is for creating a sample Raffle
 * @dev Implements Chainlink VRFv2.5
 */
contract Riffle {
    /* Errors */
    error Raffle_SendMoreToEnterRaffle();

    uint256 private immutable i_entranceFee;

    address payable[] private s_players;

    constructor(uint256 entranceFee) {
        i_entranceFee = entranceFee;
    }

    function enterRaffle() public payable {
        if (msg.value > i_entranceFee) {
            revert Raffle_SendMoreToEnterRaffle();
        }

        s_players.push(payable(msg.sender));
    }

    function pickWinner() public {}

    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }
}
