// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ElectionContract {
    event ElectionCreated(bytes32 indexed electionId, string title);

    struct Election {
        address creator;
        uint256 startTime;
        uint256 endTime;
        uint256 createdAt;
        string title;
        string desc;
        bool exists;
    }

    mapping(bytes32 => Election) public elections;
    mapping(bytes32 => string[]) public options;
    mapping(bytes32 => uint256[]) public votes;
    mapping(bytes32 => mapping(address => bool)) public hasVoted;

    bytes32[] public electionIds;
    bytes32[] public notStartedElections;
    bytes32[] public ongoingElections;
    bytes32[] public endedElections;

    function createElection(
        uint256 startTime,
        uint256 endTime,
        string memory title,
        string memory desc,
        string[] memory _options
    ) public returns (bytes32) {
        require(startTime < endTime, "Invalid time range");
        require(_options.length >= 2, "Need at least two options");

        bytes32 electionId = keccak256(
            abi.encodePacked(msg.sender, block.timestamp, title)
        );

        Election storage newElection = elections[electionId];
        newElection.creator = msg.sender;
        newElection.startTime = startTime;
        newElection.endTime = endTime;
        newElection.createdAt = block.timestamp;
        newElection.title = title;
        newElection.desc = desc;
        newElection.exists = true;

        options[electionId] = _options;
        votes[electionId] = new uint256[](_options.length);

        electionIds.push(electionId);

        if (block.timestamp < startTime) {
            notStartedElections.push(electionId);
        } else if (block.timestamp >= startTime && block.timestamp <= endTime) {
            ongoingElections.push(electionId);
        } else {
            endedElections.push(electionId);
        }

        emit ElectionCreated(electionId, title);
        return electionId;
    }

    function getElectionMetadata(
        bytes32 electionId
    )
        public
        view
        returns (
            address creator,
            uint256 startTime,
            uint256 endTime,
            uint256 createdAt,
            string memory title,
            string memory desc,
            string[] memory _options
        )
    {
        Election storage e = elections[electionId];
        require(e.exists, "Election does not exist");
        return (
            e.creator,
            e.startTime,
            e.endTime,
            e.createdAt,
            e.title,
            e.desc,
            options[electionId]
        );
    }

    function getElectionsByState(
        string memory state
    ) public view returns (bytes32[] memory) {
        if (keccak256(abi.encodePacked(state)) == keccak256("notStarted")) {
            return notStartedElections;
        } else if (keccak256(abi.encodePacked(state)) == keccak256("ongoing")) {
            return ongoingElections;
        } else if (keccak256(abi.encodePacked(state)) == keccak256("ended")) {
            return endedElections;
        } else {
            revert("Invalid state");
        }
    }

    function getResults(
        bytes32 electionId
    ) public view returns (uint256[] memory) {
        require(elections[electionId].exists, "Election does not exist");
        return votes[electionId];
    }

    function vote(bytes32 electionId, uint256 optionIndex) public {
        Election storage e = elections[electionId];
        require(e.exists, "Election does not exist");
        require(block.timestamp >= e.startTime, "Election not started");
        require(block.timestamp <= e.endTime, "Election ended");
        require(optionIndex < options[electionId].length, "Invalid option");
        require(!hasVoted[electionId][msg.sender], "You have already voted");

        votes[electionId][optionIndex]++;
        hasVoted[electionId][msg.sender] = true;
    }

    function hasUserVoted(
        bytes32 electionId,
        address user
    ) public view returns (bool) {
        return hasVoted[electionId][user];
    }

    // view-only getters for arrays by index
    function getElectionId(uint256 index) public view returns (bytes32) {
        return electionIds[index];
    }

    function getNotStartedElection(
        uint256 index
    ) public view returns (bytes32) {
        return notStartedElections[index];
    }

    function getOngoingElection(uint256 index) public view returns (bytes32) {
        return ongoingElections[index];
    }

    function getEndedElections(uint256 index) public view returns (bytes32) {
        return endedElections[index];
    }
}
