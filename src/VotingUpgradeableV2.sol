// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "forge-std/console.sol";

import "./VotingUpgradeable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract VotingUpgradeableV2 is AccessControlUpgradeable, VotingUpgradeable {
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    uint256 public candidatesCount;
    mapping(address => bool) public isRegistered;

    event Registered(address indexed voter);

    function initialize(uint256 _duration, string memory _proposal) public override initializer {
        console.log("Initializing VotingUpgradeableV2...");
        super.initialize(_duration, _proposal);
        __AccessControl_init();
        __UUPSUpgradeable_init();
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
        console.log("Initialized");
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyRole(UPGRADER_ROLE) {}

    modifier registered() {
        require(!isRegistered[msg.sender], "You already registered");
        _;
    }

    function resetVotes() external onlyRole(DEFAULT_ADMIN_ROLE) {
        for (uint256 i = 0; i < candidates.length; i++) {
            candidates[i].voteCount = 0;
        }
    }

    function addCandidate(string memory _name) public override onlyRole(DEFAULT_ADMIN_ROLE) {
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
        require(!isRegistered[msg.sender], "You are already registered");
        isRegistered[msg.sender] = true;
        emit Registered(msg.sender);
    }

    function isVoterRegistered(address _voter) public view returns (bool) {
        return isRegistered[_voter];
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

    function supportsInterface(bytes4 interfaceId) public view override(AccessControlUpgradeable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
