// SPDX-License-Identifier: MIT

pragma solidity ^0.8.23;

import {Test, console} from "forge-std/Test.sol";
import {EazyVoteDeploy} from "../script/EazyVoteDeploy.s.sol";
import {EazyVote} from "../src/EazyVote.sol";

contract EazyVoteTest is Test {
    //
    EazyVoteDeploy eazyVoteDeploy;
    EazyVote eazyVote;

    modifier createNewElection() {
        eazyVote.createNewElection(
            "Coin Selection",
            "coin.jpg",
            msg.sender,
            block.timestamp,
            block.timestamp + 1 hours,
            "Lorem ipsum dolor sit amet"
        );
        eazyVote.createNewElection(
            "Best Crypto Community",
            "coin.jpg",
            msg.sender,
            block.timestamp + 1 hours,
            block.timestamp + 2 hours,
            "Lorem ipsum dolor sit amet"
        );
        _;
    }

    modifier addNewCandidate(uint256 electionId, string memory candidateName) {
        eazyVote.addNewCandidate(
            electionId,
            candidateName,
            "Lorem.jpg",
            "Ora et Labora",
            "Lorem Ipsum Dolor Sit Amet"
        );
        _;
    }

    modifier checkAndChangeElectionStatus() {
        eazyVote.checkAndChangeElectionStatus();
        _;
    }

    function setUp() public {
        eazyVoteDeploy = new EazyVoteDeploy();
        eazyVote = eazyVoteDeploy.run();
    }

    function testSuccessfullyCreateNewElection() public {
        uint256 eazyVoteElectionTotalBefore = eazyVote.getElections().length;
        eazyVote.createNewElection(
            "Fried Noodle vs Chicken Noodle",
            "food.jpg",
            msg.sender,
            block.timestamp + 1 hours,
            block.timestamp + 3 hours,
            "Lorem ipsum dolor"
        );
        uint256 eazyVoteElectionTotalAfter = eazyVote.getElections().length;
        assertEq(eazyVoteElectionTotalBefore, 0); //
        assertEq(eazyVoteElectionTotalAfter, 1);
    }

    function testSuccessfullyAddNewCandidate() public {
        uint256 eazyVoteTotalCandidateBefore = eazyVote.getCandidates().length;
        eazyVote.addNewCandidate(
            0,
            "Hello",
            "HelloWorld.jpg",
            "Ora et Labora",
            "Lorem Ipsum Dolor Sit Amet"
        );
        uint256 eazyVoteTotalCandidateAfter = eazyVote.getCandidates().length;
        assertEq(eazyVoteTotalCandidateBefore, 0);
        assertEq(eazyVoteTotalCandidateAfter, 1);
    }

    function testRevertIfVoterAlreadyVote()
        public
        createNewElection
        addNewCandidate(0, "Solana")
        addNewCandidate(0, "Doge")
        checkAndChangeElectionStatus
    {
        eazyVote.voteCandidate(msg.sender, 0, 0);
        vm.expectRevert(
            abi.encodeWithSelector(
                EazyVote.VoterAlreadyVote.selector,
                msg.sender,
                0
            )
        );
        eazyVote.voteCandidate(msg.sender, 0, 1);
    }

    function testSucessfullyShowTotalCandidateInOneElection()
        public
        createNewElection
        addNewCandidate(0, "Bitcoin")
        addNewCandidate(0, "Ethereum")
    {
        uint256 expectedTotalCandidate = 2;
        uint256 actualTotalCandidate = eazyVote
            .getCandidatesIdInOneElection(0)
            .length;
        assertEq(expectedTotalCandidate, actualTotalCandidate);
    }

    function testSuccessfullyVoteCandidate()
        public
        createNewElection
        addNewCandidate(0, "Manta")
        addNewCandidate(0, "BGB")
        checkAndChangeElectionStatus
    {
        uint256 expectedTotalVote = 1;
        eazyVote.voteCandidate(msg.sender, 0, 1);
        uint256 actualTotalVote = eazyVote.getCandidates()[1].totalVote;
        assertEq(expectedTotalVote, actualTotalVote);
    }

    function testSuccessfullyReturnCandidatesIdInOneElection()
        public
        createNewElection
        addNewCandidate(0, "FLOKI")
        addNewCandidate(0, "LUNA")
    {
        uint256 expectedCandidateFirstId = eazyVote.getCandidates()[0].id;
        uint256 actualCandidateFirstId = eazyVote.getCandidatesIdInOneElection(
            0
        )[0];
        uint256 expectedCandidateSecondId = eazyVote.getCandidates()[1].id;
        uint256 actualCandidateSecondId = eazyVote.getCandidatesIdInOneElection(
            0
        )[1];
        assertEq(expectedCandidateFirstId, actualCandidateFirstId);
        assertEq(expectedCandidateSecondId, actualCandidateSecondId);
    }

    function testRevertIfElectionIsNotOpen()
        public
        createNewElection
        addNewCandidate(0, "PEPE")
    {
        vm.expectRevert(
            abi.encodeWithSelector(EazyVote.ElectionIsNotOpen.selector, 0)
        );
        eazyVote.voteCandidate(msg.sender, 0, 0);
    }

    function testSuccessfullyGiveFeedback() public {
        uint256 expectedFeedbacksCount = 1;
        eazyVote.giveFeedback(msg.sender, "Lorem ipsum dolor sit amet");
        uint256 actualFeedbacksCount = eazyVote.getFeedbacks().length;
        assertEq(expectedFeedbacksCount, actualFeedbacksCount);
    }

    function testSuccessfullyCloseElection()
        public
        createNewElection
        checkAndChangeElectionStatus
    {
        EazyVote.Status expectedElectionStatus = EazyVote.Status.CLOSED;
        EazyVote.Status actualElectionStatus = eazyVote
        .getElections()[1].electionStatus;
        assertEq(
            uint256(expectedElectionStatus),
            uint256(actualElectionStatus)
        );
    }

    function testSuccessfullyGetTotalVoterInOneElection()
        public
        createNewElection
        addNewCandidate(0, "FLOKI")
        checkAndChangeElectionStatus
    {
        uint256 expectedTotalVoter = 1;
        eazyVote.voteCandidate(msg.sender, 0, 0);
        uint256 actualTotalVoter = eazyVote.getTotalVoterInOneElection(0);
        assertEq(expectedTotalVoter, actualTotalVoter);
    }

    function testSuccessfullyGetHistory()
        public
        createNewElection
        addNewCandidate(0, "MANTA")
        checkAndChangeElectionStatus
    {
        uint256 expectedHistoryLength = 1;
        eazyVote.voteCandidate(msg.sender, 0, 0);
        uint256 actualHistoryLength = eazyVote.getHistoryId(msg.sender).length;
        assertEq(expectedHistoryLength, actualHistoryLength);
    }
    //
}
