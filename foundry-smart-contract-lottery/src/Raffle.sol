// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

/**
 * @title A sample Raffle contract
 * @author vntodorov
 * @notice This contract is for creating a sample Raffle
 * @dev Implements Chainlink VRFv2.5
 */
contract Riffle is VRFConsumerBaseV2Plus {
    /* Errors */
    error Raffle__SendMoreToEnterRaffle();

    error Raffle__TransferFailed();

    error Raffle__RaffleNotOpen();

    /* Type Declarations */
    enum RaffleState {
        OPEN,
        CALCULATING
    }

    uint16 private constant REQUEST_CONFIRMATIONS = 3;

    uint32 private constant NUM_WORDS = 1;

    uint256 private immutable i_entranceFee;

    // @dev The duration of the lottery in seconds
    uint256 private immutable i_interval;

    bytes32 private immutable i_keyHash;

    uint256 private immutable i_subscriptionId;

    uint32 private immutable i_callbackGasLimit;

    address payable[] private s_players;

    uint256 private s_lastTimeStamp;

    address private s_recentWinner;

    RaffleState private s_raffleState;

    /* Events */
    event RaffleEntered(address indexed player);

    event WinnerPicked(address indexed winner);

    constructor(
        uint256 entranceFee,
        uint256 interval,
        address vrfCoordinator,
        bytes32 gasLane,
        uint256 subscriptionId,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2Plus(vrfCoordinator) {
        i_entranceFee = entranceFee;
        i_interval = interval;
        i_keyHash = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;

        s_lastTimeStamp = block.timestamp;
        s_raffleState = RaffleState.OPEN;
    }

    function enterRaffle() external payable {
        if (msg.value > i_entranceFee) {
            revert Raffle__SendMoreToEnterRaffle();
        }

        if (s_raffleState != RaffleState.OPEN) {
            revert Raffle__RaffleNotOpen();
        }

        s_players.push(payable(msg.sender));

        emit RaffleEntered(msg.sender);
    }

    /**
     * @dev This is the function that the Chainlink node will call to see
     * if the lottery is ready to have a winner picked.
     * The following should be true in order to upkeepNeeded to be true:
     * 1. The time interval has passed between raffle runs
     * 2. The loterry is open
     * 3. The contract has ETH
     * 4. Implicitly, your subscription has LINK
     * @param - ignored
     * @return upkeepNeeded - true if it's time to restart the lottery
     * @return - ignored
     */
    function checkUpkeep(
        bytes calldata /* checkData */
    ) public view returns (bool upkeepNeeded, bytes memory /* performData */) {
        upkeepNeeded = (block.timestamp - s_lastTimeStamp) > i_interval;
    }

    function pickWinner() external {
        if ((block.timestamp - s_lastTimeStamp) < i_interval) {
            revert();
        }

        s_raffleState = RaffleState.CALCULATING;

        VRFV2PlusClient.RandomWordsRequest memory request = VRFV2PlusClient
            .RandomWordsRequest({
                keyHash: i_keyHash,
                subId: i_subscriptionId,
                requestConfirmations: REQUEST_CONFIRMATIONS,
                callbackGasLimit: i_callbackGasLimit,
                numWords: NUM_WORDS,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            });

        uint256 requestId = s_vrfCoordinator.requestRandomWords(request);
    }

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] calldata randomWords
    ) internal override {
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable recentWinner = s_players[indexOfWinner];
        s_recentWinner = recentWinner;
        s_raffleState = RaffleState.OPEN;
        s_players = new address payable[](0);
        s_lastTimeStamp = block.timestamp;
        emit WinnerPicked(s_recentWinner);

        (bool success, ) = recentWinner.call{value: address(this).balance}("");
        if (!success) {
            revert Raffle__TransferFailed();
        }
    }

    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }
}
