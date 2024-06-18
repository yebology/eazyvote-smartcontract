// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

contract EazyVote {
    //
    enum Status {
        OPEN,
        CLOSED
    }

    struct Candidate {
        uint256 voteCount;
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

    address private owner;
    uint256 private totalElection;
    Election[] private elections;

    modifier onlyVoteOneTimeInOneElection(uint256 userId) {
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createElection(
        uint256 electionStart,
        uint256 electionEnd
    ) public {

    }

    function addNewCandidate(
        uint256 electionId,
        string memory candidateName,
        string memory candidatePhoto,
        string memory candidateVision,
        string memory candidateMission
    ) public {

    }

    function voteCandidate(
        uint256 electionId,
        uint256 candidateId
    ) public {

    }

    function getElections() external view returns(Election[]) {
        return elections;
    }
    //
}