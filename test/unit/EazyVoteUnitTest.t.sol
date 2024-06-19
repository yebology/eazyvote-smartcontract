// SPDX-License-Identifier: MIT

pragma solidity ^0.8.23;

import {Test, console} from "forge-std/Test.sol";
import {EazyVoteDeploy} from "../../script/EazyVoteDeploy.s.sol";
import {EazyVote} from "../../src/EazyVote.sol";

contract EazyVoteUnitTest is Test {
    //
    
    EazyVoteDeploy eazyVoteDeploy;
    EazyVote eazyVote;

    modifier createNewElection() {
        eazyVote.createNewElection(1, 4);
        eazyVote.createNewElection(2, 5);
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
    {}

    function testSucessfullyShowTotalCandidateInOneElection()
        public
        createNewElection()
        addNewCandidate(0, "Bitcoin")
        addNewCandidate(1, "Ethereum")
    {
        uint256 expectedTotalCandidate = 2;
        uint256 actualTotalCandidate = eazyVote
            .getCandidatesInOneElection(0)
            .length;
        assertEq(expectedTotalCandidate, actualTotalCandidate);
    }

    function testSuccessfullyVoteCandidate()
        public
        createNewElection
        addNewCandidate(0, "Manta")
        addNewCandidate(0, "BGB")
    {
        uint256 expectedTotalVote = 1;
        eazyVote.voteCandidate(msg.sender, 0, 1);
        uint256 actualTotalVote = eazyVote.getCandidatesInOneElection(0)[1].totalVote;
        assertEq(expectedTotalVote, actualTotalVote);
    }

    function testSuccessfullyVoteCandidateOnAnotherElection() public {}

    function testRevertIfElectionIsNotOpen() public {}

    function testChangeElectionStatus() public createNewElection() {
        EazyVote.Status expectedCurrentElectionStatus = EazyVote.Status.CLOSED;
        EazyVote.Status actualCurrentElectionStatus = eazyVote.getElections()[0].electionStatus;
        eazyVote.changeElectionStatus(0, "OPEN");
        EazyVote.Status expectedElectionStatusAfterChangeStatus = EazyVote.Status.OPEN;
        EazyVote.Status actualElectionStatusAfterChangeStatus = eazyVote.getElections()[0].electionStatus;
        assertEq(uint256(expectedCurrentElectionStatus), uint256(actualCurrentElectionStatus));
        assertEq(uint256(expectedElectionStatusAfterChangeStatus), uint256(actualElectionStatusAfterChangeStatus));
    }
    //
}
