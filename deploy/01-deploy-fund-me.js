const { network } = require("hardhat");
const { networkConfig, developmentChains } = require('../helper-hardhat-config');
const { verify } = require('../utils/verify');

require('dotenv').config();

// module.exports = async (hre) => {
//   const { getNamedAccounts, deployments } = hre
// }

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainID = network.config.chainId;

  //using specific address for specific chain
  // const ethUSDPriceFeedAddress = networkConfig[chainID]["ethUSDPriceFeed"];
  let ethUSDPriceFeedAddress;
  if (developmentChains.includes(network.name)) {
    const ethUsdAggregator = await deployments.get("MockV3Aggregator");
    ethUSDPriceFeedAddress = ethUsdAggregator.address;
  } else {
    ethUSDPriceFeedAddress = networkConfig[chainID]["ethUSDPriceFeed"];
  }

  //when going for localhost or hardhat network we want to use a mock
  const args = [ethUSDPriceFeedAddress];
  const fundMe = await deploy("FundMe", {
    from: deployer,
    args: args, // put price feed address
    log: true,
    waitConfirmations: network.config.blockConfirmations || 1
  });

  const contractAddress = await fundMe.address;

  if (!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
    await verify(contractAddress, args);
  }
  log("--------------------------------------");
}

module.exports.tags = ["all", "fundme"]