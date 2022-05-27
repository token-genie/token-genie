import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { StarToken, Rewards } from "../typechain";
import { getRewards, getStarToken } from "../lib/deploy.helpers";

describe("Rewards", function () {
  let starTokenContract: StarToken;
  let rewardsContract: Rewards;
  let deployer: SignerWithAddress;
  let acc1: SignerWithAddress;
  let acc2: SignerWithAddress;

  const oneStarToken = ethers.utils.parseEther("1");
  // const MINTER_ROLE = ethers.utils.solidityKeccak256(
  //   ["string"],
  //   ["MINTER_ROLE"]
  // );

  // const DEFAULT_ADMIN_ROLE =
  //   "0x0000000000000000000000000000000000000000000000000000000000000000";

  // const MANAGER_ROLE = ethers.utils.solidityKeccak256(
  //   ["string"],
  //   ["MANAGER_ROLE"]
  // );

  // const USER_ROLE = ethers.utils.solidityKeccak256(["string"], ["USER_ROLE"]);

  beforeEach("deploy contracts", async () => {
    [deployer, acc1, acc2] = await ethers.getSigners();

    starTokenContract = await getStarToken({
      contractName: "StarToken",
      deployParams: [],
    });

    rewardsContract = await getRewards({
      contractName: "Rewards",
      deployParams: [starTokenContract.address],
    });
  });

  describe("stake a reward", () => {
    it("will fail if ETH is zero", async function () {
      await expect(
        rewardsContract.connect(acc1).stakeReward(oneStarToken.mul(5))
      ).to.be.revertedWith(`zero reward`);
    });

    it("will stake ETH amount in rewards", async () => {
      let contractBalance = await ethers.provider.getBalance(
        rewardsContract.address
      );

      expect(contractBalance).to.equal(0);

      // acc1 stake 2 ETH
      await rewardsContract.connect(acc1).stakeReward(oneStarToken.mul(20), {
        value: ethers.utils.parseEther("2"),
      });
      contractBalance = await ethers.provider.getBalance(
        rewardsContract.address
      );

      expect(contractBalance).to.equal(ethers.utils.parseEther("2"));

      // acc2 stake 3 ETH
      await rewardsContract.connect(acc2).stakeReward(oneStarToken.mul(40), {
        value: ethers.utils.parseEther("3"),
      });

      contractBalance = await ethers.provider.getBalance(
        rewardsContract.address
      );

      expect(contractBalance).to.equal(ethers.utils.parseEther("5"));
    });
  });
});
