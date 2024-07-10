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
        string[] memory candidateNames = new string[](3);
        candidateNames[0] = "BGB";
        candidateNames[1] = "MANTA";
        candidateNames[2] = "ETH";

        string[] memory candidatePhotos = new string[](3);
        candidatePhotos[0] = "bgb.jpg";
        candidatePhotos[1] = "manta.jpg";
        candidatePhotos[2] = "eth.jpg";

        string[] memory candidateVisions = new string[](3);
        candidateVisions[0] = "lorem";
        candidateVisions[1] = "ipsum";
        candidateVisions[2] = "dolor";

        string[] memory candidateMissions = new string[](3);
        candidateMissions[0] = "amet";
        candidateMissions[1] = "dolor";
        candidateMissions[2] = "lorem";

        eazyVote.createNewElection(
            "Coin Selection",
            "coin.jpg",
            block.timestamp,
            block.timestamp + 1 hours,
            "Lorem ipsum dolor sit amet",
            candidateNames,
            candidatePhotos,
            candidateVisions,
            candidateMissions
        );

        eazyVote.createNewElection(
            "Best Crypto Community",
            "coin.jpg",
            block.timestamp + 1 hours,
            block.timestamp + 2 hours,
            "Lorem ipsum dolor sit amet",
            candidateNames,
            candidatePhotos,
            candidateVisions,
            candidateMissions
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

    function testSuccessfullyCreateNewElection() public createNewElection {
        uint256 eazyVoteElectionTotal = eazyVote.getElections().length;
        uint256 eazyVoteCandidatesTotal = eazyVote.getCandidates().length;
        uint256 eazyVoteCandidatesTotalInFirstElection = eazyVote
            .getCandidatesIdInOneElection(0)
            .length;
        uint256 eazyVoteCandidatesTotalInSecondElection = eazyVote
            .getCandidatesIdInOneElection(1)
            .length;
        assertEq(eazyVoteElectionTotal, 2);
        assertEq(eazyVoteCandidatesTotal, 6);
        assertEq(eazyVoteCandidatesTotalInFirstElection, 3);
        assertEq(eazyVoteCandidatesTotalInSecondElection, 3);
    }

    function testRevertIfVoterAlreadyVote()
        public
        createNewElection
        checkAndChangeElectionStatus
    {
        address voter = msg.sender;
        vm.startPrank(voter);
        eazyVote.voteCandidate(0, 0);
        vm.expectRevert(
            abi.encodeWithSelector(
                EazyVote.VoterAlreadyVote.selector,
                msg.sender,
                0
            )
        );
        eazyVote.voteCandidate(0, 1);
        vm.stopPrank();
    }

    function testRevertIfElectionIsNotOpen() public createNewElection {
        vm.expectRevert(bytes("Election is not open yet!"));
        eazyVote.voteCandidate(0, 0);
    }

    function testRevertIfCandidateArrayLengthMismatch() public {
        string[] memory candidateNames = new string[](1);
        candidateNames[0] = "BGB";

        string[] memory candidatePhotos = new string[](1);
        candidatePhotos[0] = "bgb.jpg";

        string[] memory candidateVisions = new string[](0);

        string[] memory candidateMissions = new string[](0);

        vm.expectRevert(bytes("Candidate array must have the same length!"));
        eazyVote.createNewElection(
            "Title",
            "picture.jpg",
            block.timestamp,
            block.timestamp + 1 hours,
            "Description",
            candidateNames,
            candidatePhotos,
            candidateVisions,
            candidateMissions
        );
    }

    function testSuccessfullyVoteCandidate()
        public
        createNewElection
        checkAndChangeElectionStatus
    {
        uint256 expectedTotalVote = 1;
        eazyVote.voteCandidate(0, 1);
        uint256 actualTotalVote = eazyVote.getCandidates()[1].totalVote;
        assertEq(expectedTotalVote, actualTotalVote);
    }

    function testSuccessfullyReturnCandidatesIdInOneElection()
        public
        createNewElection
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

    function testSuccessfullyGiveFeedback() public {
        uint256 expectedFeedbacksCount = 1;
        eazyVote.giveFeedback("Lorem ipsum dolor sit amet");
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
        checkAndChangeElectionStatus
    {
        uint256 expectedTotalVoter = 1;
        eazyVote.voteCandidate(0, 0);
        uint256 actualTotalVoter = eazyVote.getTotalVoterInOneElection(0);
        assertEq(expectedTotalVoter, actualTotalVoter);
    }

    function testSuccessfullyGetHistory()
        public
        createNewElection
        checkAndChangeElectionStatus
    {
        uint256 expectedHistoryLength = 1;
        address user = msg.sender;
        vm.startPrank(user);
        eazyVote.voteCandidate(0, 0);
        uint256 actualHistoryLength = eazyVote.getHistoryId(user).length;
        assertEq(expectedHistoryLength, actualHistoryLength);
        vm.stopPrank();
    }
    //
}
