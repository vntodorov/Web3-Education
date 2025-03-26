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

    error BaseContract__OnlyOwnerCanWithdraw();

    error BaseContract__TransferFailed();

    error BaseContract__CannotParticipateWithAmountBelowTheRequired();

    uint256 private constant REQUIRED_MINIMUM_PARTICIPATION = 1 ether;

    mapping(address => uint256) private s_participantsWithAmount;

    address[] private s_participants;

    address private s_owner;

    constructor() {
        s_owner = msg.sender;
    }

    function addParticipantWithValue(
        address participantToAdd,
        uint256 value
    ) public {
        if (value <= 0) {
            revert BaseContract__CannotParticipateWithZeroValue();
        }

        if (value < REQUIRED_MINIMUM_PARTICIPATION) {
            revert BaseContract__CannotParticipateWithAmountBelowTheRequired();
        }

        s_participantsWithAmount[participantToAdd] += value;
        s_participants.push(participantToAdd);
    }

    function deleteParticipant(address participantToDelete) public {
        if (s_participantsWithAmount[participantToDelete] == 0) {
            revert BaseContract__NoSuchAddressToDelete();
        }
        delete s_participantsWithAmount[participantToDelete];

        uint256 indexToRemove = findIndexOfParticipant(participantToDelete);
        if (indexToRemove < s_participants.length) {
            s_participants[indexToRemove] = s_participants[
                s_participants.length - 1
            ];
        }
        s_participants.pop();
    }

    function withdraw() public payable {
        require(msg.sender == s_owner, BaseContract__OnlyOwnerCanWithdraw());
        (bool sucess, ) = msg.sender.call{value: address(this).balance}("");
        require(sucess, BaseContract__TransferFailed());
    }

    function findIndexOfParticipant(
        address participantToDelete
    ) internal view returns (uint256) {
        for (uint256 i = 0; i < s_participants.length; i++) {
            if (s_participants[i] == participantToDelete) {
                return i;
            }
        }
        revert BaseContract__NoSuchAddressToDelete();
    }

    /**
     * Getter Functions
     */

    function getAmountOfParticipant(
        address participantAddress
    ) external view returns (uint256) {
        return s_participantsWithAmount[participantAddress];
    }

    function getParticipant(
        uint256 indexOfParticipant
    ) external view returns (address) {
        if (s_participants.length <= 0) {
            return address(0);
        }
        return s_participants[indexOfParticipant];
    }

    function getOwner() external view returns (address) {
        return s_owner;
    }

    function getRequiredMinimumParticipationAmount()
        external
        pure
        returns (uint256)
    {
        return REQUIRED_MINIMUM_PARTICIPATION;
    }
}
