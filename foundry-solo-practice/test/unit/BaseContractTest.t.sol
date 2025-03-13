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

    function testUnsuccessfulyDeleteParticipant() public {
        vm.expectRevert(
            BaseContract.BaseContract__NoSuchAddressToDelete.selector
        );
        baseContract.deleteParticipant(participant);
    }

    function testVerifyOwner() public view {
        assertEq(baseContract.getOwner(), msg.sender);
    }

    function testVerifyOwnerFailure() public {
        vm.startPrank(participant);
        baseContract = new BaseContract();
        vm.stopPrank();

        assertNotEq(baseContract.getOwner(), msg.sender);
        assertEq(baseContract.getOwner(), participant);
    }

    function testOwnerCanWithdraw() public {
        uint256 startingContractBalance = address(baseContract).balance;
        uint256 startingOwnerBalance = baseContract.getOwner().balance;

        baseContract.addParticipantWithValue(
            participant,
            STARTING_PARTICIPANT_BALANCE
        );

        uint256 endingContractBalance = address(baseContract).balance;
        uint256 endingOwnerBalance = baseContract.getOwner().balance;

        assertEq(endingContractBalance, 0);
        assertEq(
            startingContractBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawFromNotOwner() public {
        vm.expectRevert(
            BaseContract.BaseContract__OnlyOwnerCanWithdraw.selector
        );
        vm.startPrank(participant);
        baseContract.withdraw();
        vm.stopPrank();
    }
}
