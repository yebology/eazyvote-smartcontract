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

    modifier onlyVoteOneTimeInOneElection(address _voter, uint256 _electionId) {
        uint256 length = electionVoter[_electionId].length;
        for (uint256 i = 0; i < length; i++) {
            if (electionVoter[_electionId][i] == _voter) {
                revert VoterAlreadyVote(_voter, _electionId);
            }
        }
        _;
    }

    modifier electionMustStillOpen(uint256 _electionId) {
        if (elections[_electionId].electionStatus == Status.CLOSED) {
            revert ElectionIsNotOpen(_electionId);
        }
        _;
    }

    function createNewElection(
        string memory _electionTitle,
        string memory _electionPicture,
        address _electionCreator,
        uint256 _electionStart,
        uint256 _electionEnd,
        string memory _electionDescription
    ) external {
        elections.push(
            Election({
                id: elections.length,
                electionTitle: _electionTitle,
                electionPicture: _electionPicture,
                electionCreator: _electionCreator,
                electionStart: _electionStart,
                electionEnd: _electionEnd,
                electionDescription: _electionDescription,
                electionStatus: Status.CLOSED
            })
        );
        emit newElectionHasBeenCreated(elections.length - 1);
    }

    function changeElectionStatus(
        uint256 _electionId,
        string memory _message
    ) external {
        if (
            keccak256(abi.encodePacked(_message)) ==
            keccak256(abi.encodePacked("OPEN"))
        ) {
            elections[_electionId].electionStatus = Status.OPEN;
        } else if (
            keccak256((abi.encodePacked(_message))) ==
            keccak256(abi.encodePacked("CLOSED"))
        ) {
            elections[_electionId].electionStatus = Status.CLOSED;
        }
        emit electionHasChangedStatus(
            _electionId,
            elections[_electionId].electionStatus
        );
    }

    function addNewCandidate(
        uint256 _electionId,
        string memory _candidateName,
        string memory _candidatePhoto,
        string memory _candidateVision,
        string memory _candidateMission
    ) external {
        candidates.push(
            Candidate({
                id: candidates.length,
                totalVote: 0,
                candidateName: _candidateName,
                candidatePhoto: _candidatePhoto,
                candidateVision: _candidateVision,
                candidateMission: _candidateMission
            })
        );
        electionCandidate[_electionId].push(candidates.length - 1);
        emit newCandidateHasBeenAdded(_electionId, candidates.length - 1);
    }

    function voteCandidate(
        address _voter,
        uint256 _electionId,
        uint256 _candidateId
    )
        external
        electionMustStillOpen(_electionId)
        onlyVoteOneTimeInOneElection(_voter, _electionId)
    {
        electionVoter[_electionId].push(_voter);
        candidates[_candidateId].totalVote += 1;
        emit newVoteHasBeenAdded(_voter, _electionId, _candidateId);
    }

    function giveFeedback(address _user, string memory _textFeedback) external {
        feedbacks.push(
            Feedback({
                id: feedbacks.length,
                user: _user,
                textFeedback: _textFeedback
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
        uint256 _electionId
    ) external view returns (uint256) {
        return electionVoter[_electionId].length;
    }

    function getCandidatesIdInOneElection(
        uint256 _electionId
    ) external view returns (uint256[] memory) {
        uint256[] memory candidateIds = electionCandidate[_electionId];
        return candidateIds;
    }
    //
}
