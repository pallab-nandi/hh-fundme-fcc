const { assert } = require("chai");
const { deployments, ethers, getNamedAccounts } = require("hardhat");

describe("FundMe", function () {

  let fundMe;
  let deployer;
  let mockV3Aggregator;
  beforeEach(async function () {
    //deploy contract using hardhat
    deployer = (await getNamedAccounts()).deployer;
    await deployments.fixture("all");
    fundMe = await ethers.getContract("FundMe", deployer);
    mockV3Aggregator = await ethers.getContract("MockV3Aggregator", deployer);
  })

  describe("constructor", function () {
    it("sets the aggregator address correctly", async function () {
      const response = await fundMe.getPriceFeed();
      const mockAddress = await mockV3Aggregator.getAddress();
      assert.equal(response, mockAddress);
    })
  })
})