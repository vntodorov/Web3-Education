// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

/**
 * @title A sample contract for practicing random stuff
 * @author vntodorov
 * @notice This contract is a practice one
 */
contract BaseContract {
    error BaseContract__CannotParticipateWithZeroValue();

    error BaseContract__NoSuchAddressToDelete();

    mapping(address => uint256) private s_participantsWithAmount;

    function addParticipantWithValue(
        address participantToAdd,
        uint256 value
    ) public {
        if (value <= 0) {
            revert BaseContract__CannotParticipateWithZeroValue();
        }
        s_participantsWithAmount[participantToAdd] += value;
    }

    function deleteParticipant(address participantToDelete) public {
        if (s_participantsWithAmount[participantToDelete] == 0) {
            revert BaseContract__NoSuchAddressToDelete();
        }
        delete s_participantsWithAmount[participantToDelete];
    }
}
