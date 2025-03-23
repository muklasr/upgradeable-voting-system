// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract VotingUpgradeable is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    struct Candidate {
        string name;
        uint256 voteCount;
    }

    mapping(address => bool) public hasVoted;
    Candidate[] public candidates;
    uint256 public votingDeadline;

    string public proposal;

    event CandidateAdded(string name);
    event Voted(address indexed voter, uint256 candidateIndex);

    modifier votingActive() {
        require(block.timestamp < votingDeadline, "Voting has ended");
        _;
    }

    function initialize(uint256 _duration, string memory _proposal) public initializer {
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
        votingDeadline = block.timestamp + _duration;

        proposal = _proposal;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    function addCandidate(string memory _name) external virtual onlyOwner {
        candidates.push(Candidate(_name, 0));
        emit CandidateAdded(_name);
    }

    function vote(uint256 _candidateIndex) external virtual votingActive {
        require(!hasVoted[msg.sender], "Already voted");
        require(_candidateIndex < candidates.length, "Invalid candidate");

        hasVoted[msg.sender] = true;
        candidates[_candidateIndex].voteCount++;

        emit Voted(msg.sender, _candidateIndex);
    }

    function getResults() external view returns (Candidate[] memory) {
        require(block.timestamp >= votingDeadline, "Voting is still ongoing");
        return candidates;
    }
}
