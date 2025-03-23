require("@nomicfoundation/hardhat-toolbox");
require("@openzeppelin/hardhat-upgrades");

module.exports = {
  solidity: "0.8.22",
  paths: {
    sources: "./src",   // Match Foundry contract folder
    tests: "./test",    // Match Foundry's test folder
    cache: "./cache_hardhat",
    artifacts: "./artifacts_hardhat"
  },
  networks: {
    hardhat: {
      chainId: 31337
    }
  }
};
