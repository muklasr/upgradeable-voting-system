// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/VotingUpgradeable.sol";
import "../src/VotingUpgradeableV2.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract DeployVoting is Script {
    function run() external {
        vm.startBroadcast();

        // Deploy implementation contract
        VotingUpgradeableV2 impl = new VotingUpgradeableV2();

        // Deploy proxy contract
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(
            address(impl),
            msg.sender, // Admin
            abi.encodeWithSignature("initialize(uint256,string)", 3600, "Proposal 1")
        );

        // Cast proxy address to VotingUpgradeableV2
        VotingUpgradeableV2 voting = VotingUpgradeableV2(address(proxy));

        vm.stopBroadcast();
    }
}
