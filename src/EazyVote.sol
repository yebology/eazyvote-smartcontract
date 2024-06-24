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
        uint256 totalVote;
        string candidateName;
        string candidatePhoto;
        string candidateVision;
        string candidateMission;
    }
    struct Election {
        uint256 id;
        string electionTitle;
        string electionPicture;
        address electionCreator;
        uint256 electionStart;
        uint256 electionEnd;
        string electionDescription;
        Status electionStatus;
    }
    struct Feedback {
        uint256 id;
        address user;
        string textFeedback;
    }

    mapping(uint256 electionId => uint256[] candidateId) electionCandidate;
    mapping(uint256 electionId => address[] voter) electionVoter;

    Election[] private elections;
    Candidate[] private candidates;
    Feedback[] private feedbacks;

    error ElectionIsNotOpen(uint256 electionId);
    error VoterAlreadyVote(address voter, uint256 electionId);

    event newElectionHasBeenCreated(uint256 indexed electionId);
    event newCandidateHasBeenAdded(
        uint256 indexed electionId,
        uint256 indexed candidateId
    );
    event newVoteHasBeenAdded(
        address indexed voter,
        uint256 indexed electionId,
        uint256 indexed candidateId
    );
    event electionHasChangedStatus(
        uint256 indexed electionId,
        Status electionStatus
    );

    modifier onlyVoteOneTimeInOneElection(address voter, uint256 electionId) {
        uint256 length = electionVoter[electionId].length;
        for (uint256 i = 0; i < length; i++) {
            if (electionVoter[electionId][i] == voter) {
                revert VoterAlreadyVote(voter, electionId);
            }
        }
        _;
    }

    modifier electionMustStillOpen(uint256 electionId) {
        if (elections[electionId].electionStatus == Status.CLOSED) {
            revert ElectionIsNotOpen(electionId);
        }
        _;
    }

    function createNewElection(
        string memory electionTitle,
        string memory electionPicture,
        address electionCreator,
        uint256 electionStart,
        uint256 electionEnd,
        string memory electionDescription
    ) external {
        elections.push(
            Election({
                id: elections.length,
                electionTitle: electionTitle,
                electionPicture: electionPicture,
                electionCreator: electionCreator,
                electionStart: electionStart,
                electionEnd: electionEnd,
                electionDescription: electionDescription,
                electionStatus: Status.CLOSED
            })
        );
        emit newElectionHasBeenCreated(elections.length - 1);
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
        candidates.push(
            Candidate({
                id: candidates.length,
                totalVote: 0,
                candidateName: candidateName,
                candidatePhoto: candidatePhoto,
                candidateVision: candidateVision,
                candidateMission: candidateMission
            })
        );
        electionCandidate[electionId].push(candidates.length - 1);
        emit newCandidateHasBeenAdded(electionId, candidates.length - 1);
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
        electionVoter[electionId].push(voter);
        candidates[candidateId].totalVote += 1;
        emit newVoteHasBeenAdded(voter, electionId, candidateId);
    }

    function giveFeedback(address user, string memory textFeedback) external {
        feedbacks.push(
            Feedback({
                id: feedbacks.length,
                user: user,
                textFeedback: textFeedback
            })
        );
    }

    function getElections() external view returns (Election[] memory) {
        return elections;
    }

    function getCandidates() external view returns (Candidate[] memory) {
        return candidates;
    }

    function getFeedbacks() external view returns (Feedback[] memory) {
        return feedbacks;
    }

    function getTotalVoterInOneElection(
        uint256 electionId
    ) external view returns (uint256) {
        return electionVoter[electionId].length;
    }

    function getCandidatesIdInOneElection(
        uint256 electionId
    ) external view returns (uint256[] memory) {
        uint256[] memory candidateIds = electionCandidate[electionId];
        return candidateIds;
    }
    //
}
