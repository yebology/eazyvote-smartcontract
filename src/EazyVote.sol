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
    mapping(address voter => uint256[] electionId) history;

    Election[] private elections;
    Candidate[] private candidates;
    Feedback[] private feedbacks;

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
    event newFeedbackHasBeenAdded(
        uint256 indexed id,
        address indexed user,
        string textFeedback
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

    function createNewElection(
        string memory _electionTitle,
        string memory _electionPicture,
        uint256 _electionStart,
        uint256 _electionEnd,
        string memory _electionDescription,
        string[] memory _candidateNames,
        string[] memory _candidatePhotos,
        string[] memory _candidateVisions,
        string[] memory _candidateMissions
    ) external {
        require(
            _candidateNames.length == _candidatePhotos.length &&
                _candidatePhotos.length == _candidateVisions.length &&
                _candidateVisions.length == _candidateMissions.length,
            "Candidate array must have the same length!"
        );

        elections.push(
            Election({
                id: elections.length,
                electionTitle: _electionTitle,
                electionPicture: _electionPicture,
                electionCreator: msg.sender,
                electionStart: _electionStart,
                electionEnd: _electionEnd,
                electionDescription: _electionDescription,
                electionStatus: Status.CLOSED
            })
        );
        uint256 length = _candidateNames.length;
        for (uint256 i = 0; i < length; i++) {
            addNewCandidate(
                elections.length - 1,
                _candidateNames[i],
                _candidatePhotos[i],
                _candidateVisions[i],
                _candidateMissions[i]
            );
        }
        emit newElectionHasBeenCreated(elections.length - 1);
    }

    function checkAndChangeElectionStatus() external {
        uint256 length = elections.length;
        for (uint256 i = 0; i < length; i++) {
            Status newStatus = elections[i].electionStatus;
            if (
                block.timestamp >= elections[i].electionEnd &&
                elections[i].electionStatus != Status.CLOSED
            ) {
                newStatus = Status.CLOSED;
            } else if (
                block.timestamp >= elections[i].electionStart &&
                block.timestamp < elections[i].electionEnd &&
                elections[i].electionStatus != Status.OPEN
            ) {
                newStatus = Status.OPEN;
            }
            if (newStatus != elections[i].electionStatus) {
                elections[i].electionStatus = newStatus;
                emit electionHasChangedStatus(i, elections[i].electionStatus);
            }
        }
    }

    function addNewCandidate(
        uint256 _electionId,
        string memory _candidateName,
        string memory _candidatePhoto,
        string memory _candidateVision,
        string memory _candidateMission
    ) private {
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
        uint256 _electionId,
        uint256 _candidateId
    ) external onlyVoteOneTimeInOneElection(msg.sender, _electionId) {
        require(
            elections[_electionId].electionStatus == Status.OPEN,
            "Election is not open yet!"
        );
        electionVoter[_electionId].push(msg.sender);
        history[msg.sender].push(_electionId);
        candidates[_candidateId].totalVote += 1;
        emit newVoteHasBeenAdded(msg.sender, _electionId, _candidateId);
    }

    function giveFeedback(string memory _textFeedback) external {
        feedbacks.push(
            Feedback({
                id: feedbacks.length,
                user: msg.sender,
                textFeedback: _textFeedback
            })
        );
        emit newFeedbackHasBeenAdded(feedbacks.length, msg.sender, _textFeedback);
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

    function getHistoryId() external view returns (uint256[] memory) {
        uint256 length = history[msg.sender].length;
        uint256[] memory allHistory = new uint256[](length);
        for (uint256 i = 0; i < length; i++) {
            allHistory[i] = history[msg.sender][i];
        }
        return allHistory;
    }
    //
}
