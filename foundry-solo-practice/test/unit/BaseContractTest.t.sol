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

    function testSuccessfullyAddParticipantWithValue() public {
        baseContract.addParticipantWithValue(
            participant,
            STARTING_PARTICIPANT_BALANCE
        );

        assertEq(
            baseContract.getAmountOfParticipant(participant),
            STARTING_PARTICIPANT_BALANCE
        );
        assert(baseContract.getParticipant(0) == participant);
    }

    function testUnsuccessfullyAddParticipantWithZeroValue() public {
        vm.expectRevert(
            BaseContract.BaseContract__CannotParticipateWithZeroValue.selector
        );
        baseContract.addParticipantWithValue(participant, 0 ether);
    }

    function testUnsuccessfullyAddParticipantWithValueBelowRequired() public {
        vm.expectRevert(
            BaseContract
                .BaseContract__CannotParticipateWithAmountBelowTheRequired
                .selector
        );
        baseContract.addParticipantWithValue(participant, 0.1 ether);
    }

    function testSuccessfullyDeleteParticipant() public {
        baseContract.addParticipantWithValue(
            participant,
            STARTING_PARTICIPANT_BALANCE
        );

        baseContract.deleteParticipant(participant);

        assertEq(baseContract.getParticipant(0), address(0));
        assert(baseContract.getAmountOfParticipant(participant) == 0);
    }

    function testUnsuccessfullyDeleteParticipant() public {
        vm.expectRevert(
            BaseContract.BaseContract__NoSuchAddressToDelete.selector
        );
        baseContract.deleteParticipant(participant);
    }

    function testOwnerCanWithdraw() public {
        uint256 startingContractBalance = address(baseContract).balance;
        uint256 startingOwnerBalance = baseContract.getOwnerBalance();

        baseContract.addParticipantWithValue(
            participant,
            STARTING_PARTICIPANT_BALANCE
        );

        uint256 endingContractBalance = address(baseContract).balance;
        uint256 endingOwnerBalance = baseContract.getOwnerBalance();

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

    function testSuccessfullyGetOwnerBecauseParticipant() public {
        baseContract.addParticipantWithValue(
            participant,
            STARTING_PARTICIPANT_BALANCE
        );
        vm.startPrank(participant);
        assertEq(baseContract.getOwner(), baseContract.getOwner());
        vm.stopPrank();
    }

    function testUnsuccessfullyGetOwnerBecauseNotParticipant() public {
        vm.expectRevert(
            BaseContract.BaseContract__NoPermissionToSeeOwnner.selector
        );
        baseContract.getOwner();
    }

    function testSuccessfullyFundContract() public {
        baseContract.fund{value: STARTING_PARTICIPANT_BALANCE}();
        assertEq(
            baseContract.getCurrentContractBalance(),
            STARTING_PARTICIPANT_BALANCE
        );
    }
}
