const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

describe("VotingUpgradeableV2", function () {
    let VotingUpgradeable, VotingUpgradeableV2, voting, proxy, addr1, addr2;

    before(async function () {
        [owner, addr1, addr2] = await ethers.getSigners();

        // Deploy the initial upgradeable contract with a proxy
        VotingUpgradeable = await ethers.getContractFactory("VotingUpgradeable");
        proxy = await upgrades.deployProxy(VotingUpgradeable, [3600, "Proposal 1"], { initializer: "initialize" });

        await proxy.waitForDeployment(); // Ensure proxy is deployed

        // Attach proxy to the instance
        voting = VotingUpgradeable.attach(proxy.target);

        // Add candidates and votes
        await voting.addCandidate("Mulyono");
        await voting.addCandidate("Mulyani");

        await voting.connect(addr1).vote(0);
        await voting.connect(addr2).vote(1);

        await network.provider.send("evm_increaseTime", [4000]); // Move 4000 seconds forward
        await network.provider.send("evm_mine"); // Mine a new block
    });

    it("Should upgrade to VotingUpgradeableV2 and keep state", async function () {
        VotingUpgradeableV2 = await ethers.getContractFactory("VotingUpgradeableV2");
        proxy = await upgrades.upgradeProxy(proxy, VotingUpgradeableV2);

        // Reattach the upgraded contract
        voting = VotingUpgradeableV2.attach(proxy.target);

        expect(await voting.proposal()).to.equal("Proposal 1");

        // Fetch results and map them properly
        const results = await voting.getResults();
        const formattedResults = results.map(r => [r.name, r.voteCount]);

        expect(formattedResults).to.deep.equal([
            ["Mulyono", 1],
            ["Mulyani", 1]
        ]);
    });

    it("Should reset all votes when resetVotes() is called", async function () {
        await voting.resetVotes();
        const results = await voting.getResults();

        results.forEach(candidate => {
            expect(candidate.voteCount).to.equal(0);
        });
    });
});
