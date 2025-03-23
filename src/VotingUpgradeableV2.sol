// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "./VotingUpgradeable.sol";

contract VotingUpgradeableV2 is VotingUpgradeable {
    uint256 public candidatesCount;
    mapping(address => bool) public isRegistered;

    event Registered(address indexed voter);

    modifier registered() {
        require(!isRegistered[msg.sender], "You already registered");
        _;
    }

    function resetVotes() external onlyOwner {
        for (uint256 i = 0; i < candidates.length; i++) {
            candidates[i].voteCount = 0;
        }
    }

    function addCandidate(string memory _name) public override onlyOwner {
        for (uint256 i = 0; i < candidates.length; i++) {
            require(
                keccak256(abi.encodePacked(candidates[i].name)) != keccak256(abi.encodePacked(_name)),
                "Candidate name already exists"
            );
        }

        candidates.push(Candidate(_name, 0));
        candidatesCount++;
        emit CandidateAdded(_name);
    }

    function register() public {
        isRegistered[msg.sender] = true;
        emit Registered(msg.sender);
    }

    function vote(uint256 _candidateIndex) external override votingActive registered {
        require(!hasVoted[msg.sender], "Already voted");
        require(_candidateIndex < candidates.length, "Invalid candidate");

        hasVoted[msg.sender] = true;
        candidates[_candidateIndex].voteCount++;

        emit Voted(msg.sender, _candidateIndex);
    }

    function getVoteCount(uint256 _candidateId) public view returns (uint256) {
        require(_candidateId < candidates.length, "Invalid candidate");
        return candidates[_candidateId].voteCount;
    }
}
