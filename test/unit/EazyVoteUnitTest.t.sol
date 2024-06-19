// SPDX-License-Identifier: MIT

pragma solidity ^0.8.23;

import {Test, console} from "forge-std/Test.sol";
import {EazyVoteDeploy} from "../../script/EazyVoteDeploy.s.sol";
import {EazyVote} from "../../src/EazyVote.sol";

contract EazyVoteUnitTest is Test {
    //
    EazyVoteDeploy eazyVoteDeploy;
    EazyVote eazyVote;

    function setUp() public {
        eazyVoteDeploy = new EazyVoteDeploy();
        eazyVote = eazyVoteDeploy.run();
    }

    function testSuccessfullyCreateNewElection() public {
        uint256 eazyVoteElectionTotalBefore = eazyVote.getElections().length;
        eazyVote.createNewElection(1, 2);
        uint256 eazyVoteElectionTotalAfter = eazyVote.getElections().length;
        assertEq(eazyVoteElectionTotalBefore, 0);
        assertEq(eazyVoteElectionTotalAfter, 1);
    }

    function testSuccessfullyAddNewCandidate() public {
        uint256 eazyVoteTotalCandidateBefore = eazyVote.getCandidates().length;
        eazyVote.addNewCandidate(
            0,
            "Yobel",
            "Yobel.jpg", 
            "Ora et Labora", 
            "Lorem Ipsum Dolor Sit Amet"
        );
        uint256 eazyVoteTotalCandidateAfter = eazyVote.getCandidates().length;
        assertEq(eazyVoteTotalCandidateBefore, 0);
        assertEq(eazyVoteTotalCandidateAfter, 1);
    }
    //
}