// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "./VotingUpgradeable.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract VotingFactory {
    event VotingDeployed(address proxyAddress);

    function deployVoting(uint256 duration) external returns (address) {
        VotingUpgradeable voting = new VotingUpgradeable();
        ERC1967Proxy proxy =
            new ERC1967Proxy(address(voting), abi.encodeWithSelector(voting.initialize.selector, duration));

        emit VotingDeployed(address(proxy));
        return address(proxy);
    }
}
