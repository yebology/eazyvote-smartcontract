// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

contract EazyVote {
    //
    enum Status {
        OPEN,
        CLOSED
    }

    struct Candidate {
        uint256 id;
        address[] voter;
        string candidateName;
        string candidatePhoto;
        string candidateVision;
        string candidateMission;
    }

    struct Election {
        uint256 id;
        uint256 electionStart;
        uint256 electionEnd;
        Candidate[] candidates;
        Status electionStatus;
    }

    uint256 private totalElection;
    Election[] private elections;

    error ElectionIsNotOpen(uint256 electionId);
    error VoterAlreadyVote(address voter, uint256 electionId);

    event newElectionHasBeenCreated(uint256 indexed electionId);
    event newCandidateHasBeenAdded(
        uint256 indexed electionId,
        uint256 indexed candidateId
    );
    event newVoteHasBeenAdded(
        address indexed voter,
        uint256 electionId,
        uint256 indexed candidateId
    );
    event electionHasChangedStatus(uint256 electionId, Status electionStatus);

    modifier onlyVoteOneTimeInOneElection(address voter, uint256 electionId) {
        Election memory election = elections[electionId];
        Candidate[] memory candidates = election.candidates;
        for (uint256 i = 0; i < candidates.length; i++) {
            if (candidates[i].voter.length >= 1) {
                for (uint256 j = 0; j < candidates[i].voter.length; j++) {
                    address candidateVoter = candidates[i].voter[j];
                    if (candidateVoter == voter) {
                        revert VoterAlreadyVote(voter, electionId);
                    }
                }
            }
        }
        _;
    }

    modifier electionMustStillOpen(uint256 electionId) {
        Election memory election = elections[electionId];
        if (election.electionStatus == Status.CLOSED) {
            revert ElectionIsNotOpen(electionId);
        }
        _;
    }

    function createNewElection(
        uint256 electionStart,
        uint256 electionEnd
    ) external {
        Election memory newElection;
        newElection.id = elections.length;
        newElection.electionStart = electionStart;
        newElection.electionEnd = electionEnd;
        newElection.electionStatus = Status.CLOSED;
        elections.push(newElection);
        totalElection += 1;
        emit newElectionHasBeenCreated(newElection.id);
    }

    function changeElectionStatus(
        uint256 electionId,
        string memory message
    ) external {
        if (
            keccak256(abi.encodePacked(message)) ==
            keccak256(abi.encodePacked("OPEN"))
        ) {
            elections[electionId].electionStatus = Status.OPEN;
        } else if (
            keccak256((abi.encodePacked(message))) ==
            keccak256(abi.encodePacked("CLOSED"))
        ) {
            elections[electionId].electionStatus = Status.CLOSED;
        }
        emit electionHasChangedStatus(
            electionId,
            elections[electionId].electionStatus
        );
    }

    function addNewCandidate(
        uint256 electionId,
        string memory candidateName,
        string memory candidatePhoto,
        string memory candidateVision,
        string memory candidateMission
    ) external {
        Candidate memory newCandidate;
        newCandidate.id = elections[electionId].candidates.length;
        newCandidate.candidateName = candidateName;
        newCandidate.candidatePhoto = candidatePhoto;
        newCandidate.candidateVision = candidateVision;
        newCandidate.candidateMission = candidateMission;
        elections[electionId].candidates.push(newCandidate);
        emit newCandidateHasBeenAdded(
            electionId,
            elections[electionId].candidates.length
        );
    }

    function voteCandidate(
        address voter,
        uint256 electionId,
        uint256 candidateId
    )
        external
        electionMustStillOpen(electionId)
        onlyVoteOneTimeInOneElection(voter, electionId)
    {
        elections[electionId].candidates[candidateId].voter.push(voter);
        emit newVoteHasBeenAdded(voter, electionId, candidateId);
    }

    function getElections() external view returns (Election[] memory) {
        return elections;
    }
    //
}
