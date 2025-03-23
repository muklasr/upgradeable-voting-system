## Upgradeable Voting-System

**Voting-System that allow to upgrade the smart contracts**

### Tech
#### Framework
- Foundry

#### Libraries
- openzeppelin-contracts
- openzeppelin-contracts-upgradeable

#### Test
- Hardhat (Because we need to test using OpenZeppelin plugin)

### Learning Notes
> What I learned while building this project
- Deployed smart contract is immutable.
- Create upgradeable smart contract using OpenZeppelin.
- Use proxy pattern → Proxy holds state & delegates logic to implementation contracts.
- Foundry vs Hardhat:
    - Foundry → Fast, efficient for testing & fuzzing, uses Rust-like CLI.
    - Hardhat → Best for plugin ecosystem, scripting, and deployment automation.
    - Mixing Foundry & Hardhat is not best practice due to tool differences.
- Overriding deployed non-virtual function is tricky.
    - Solution: Use state variable to force execution of new logic.
- Changing storage layout can break upgrades.
    - Modifying structs directly = bad (causes storage misalignment).
    - Solution: Use mappings instead of modifying structs.
- Function behavior after upgrade:
    - New require() or logic using old storage layout = upgrade safe.
    - Only changing string in function = still calls old function.
    - Adding new state variable (not in existing struct) = safe upgrade.
- Rollout deployment strategies in Web3:
    - Feature flags → Toggle features dynamically.
    - Split proxy → A/B testing for contract versions.
    - Opt-in upgrade → Users choose when to migrate.
- Upgrade is instant for all users using proxy → No gradual rollout unless custom logic is added.