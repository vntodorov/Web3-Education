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

        assertEq(baseContract.getParticipant(0), participant);
    }

    function testUnseccefulyAddParticipantWithValueBelowZero() public {
        vm.expectRevert(
            BaseContract.BaseContract__CannotParticipateWithZeroValue.selector
        );
        baseContract.addParticipantWithValue(participant, 0);
    }
}
