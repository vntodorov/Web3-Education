// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "lib/forge-std/src/Test.sol";
import {BaseContract} from "src/BaseContract.sol";
import {DeployBaseContract} from "script/DeployBaseContract.s.sol";

contract BaseContractTest is Test {
    DeployBaseContract private deployBaseContract;

    BaseContract private baseContract;

    address private participant = makeAddr("participant");

    uint256 public constant STARTING_PARTICIPANT_BALANCE = 10 ether;

    function setUp() external {
        deployBaseContract = new DeployBaseContract();
        baseContract = deployBaseContract.run();
    }

    function testSuccessfulyAddParticipantWithValue() public {
        baseContract.addParticipantWithValue(
            participant,
            STARTING_PARTICIPANT_BALANCE
        );

        assertEq(
            baseContract.getParticipantWithAmount(participant),
            STARTING_PARTICIPANT_BALANCE
        );
        assert(baseContract.getParticipant(0) == participant);
    }

    function testUnseccefulyAddParticipantWithZeroValue() public {
        vm.expectRevert(
            BaseContract.BaseContract__CannotParticipateWithZeroValue.selector
        );
        baseContract.addParticipantWithValue(participant, 0);
    }

    function testSuccessfulyDeleteParticipant() public {
        baseContract.addParticipantWithValue(
            participant,
            STARTING_PARTICIPANT_BALANCE
        );

        baseContract.deleteParticipant(participant);

        assertEq(baseContract.getParticipant(0), address(0));
        assert(baseContract.getParticipantWithAmount(participant) == 0);
    }
}
