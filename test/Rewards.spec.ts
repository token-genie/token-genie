import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { getRewards, getStarToken } from "../lib/deploy.helpers";
import { Rewards } from "../typechain";

describe("Rewards Tests", () => {
  let rewardsContract: Rewards;
  let deployer: SignerWithAddress;
  let acc1: SignerWithAddress;

  beforeEach(async () => {
    const starTokenContract = await getStarToken({
      contractName: "StarToken",
      deployParams: [],
    });

    await starTokenContract.deployed();

    rewardsContract = await getRewards({
      contractName: "Rewards",
      deployParams: [starTokenContract.address],
    });

    [deployer, acc1] = await ethers.getSigners();
  });
});
