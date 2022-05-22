import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { getStarToken } from "../lib/deploy.helpers";
import { StarToken } from "../typechain";

describe("StarToken Tests", () => {
  let starTokenContract: StarToken;
  let deployer: SignerWithAddress;
  let acc1: SignerWithAddress;
  let acc2: SignerWithAddress;


  const DEFAULT_ADMIN_ROLE =
    "0x0000000000000000000000000000000000000000000000000000000000000000";
  

  function generateRandomNumber() {
    return Math.floor(Math.random() * (2 ^ (50 - 1)) + 1);
  }

  async function checkBalance(
    account: SignerWithAddress,
    expectedBalance: Number
  ) {
    let balance = await starTokenContract.balanceOf(account.address);
    await expect(balance).to.equal(expectedBalance);
  }

  beforeEach(async () => {
    starTokenContract = await getStarToken({
      contractName: "StarToken",
      deployParams: [],
    });
    [deployer, acc1, acc2] = await ethers.getSigners();
  });

  describe("deploy", () => {
    it("deployer has the DEFAULT_ADMIN_ROLE role", async function () {
      expect(
        await starTokenContract.hasRole(
          DEFAULT_ADMIN_ROLE,
          deployer.address.toLowerCase()
        )
      ).to.be.true;
    });

    it("non-deployer to not have DEFAULT_ADMIN_ROLE role", async function () {
      expect(
        await starTokenContract.hasRole(
          DEFAULT_ADMIN_ROLE,
          acc1.address.toLowerCase()
        )
      ).to.be.false;
    });
  });

  describe("mint", () => {
    it("It should not mint if minting is paused", async () => {
      // Pause Contract
      await starTokenContract.pause();

      // Generate Random Number
      let randomAmount = generateRandomNumber();

      // Try to mint
      await expect(
        starTokenContract.connect(acc1).mint(acc1.address, randomAmount)
      ).to.be.revertedWith(`Pausable: paused`);

      // Check Balance = 0
      await checkBalance(acc1, 0);
    });

    it("It should mint if minting is unpaused", async () => {
      // Pause Contract
      await starTokenContract.pause();

      // Generate Random Number
      let randomAmount = generateRandomNumber();

      // Try to mint
      await expect(
        starTokenContract.connect(acc1).mint(acc1.address, randomAmount)
      ).to.be.revertedWith(`Pausable: paused`);

      // Check Balance = 0
      await checkBalance(acc1, 0);

      // Unpause contract
      await starTokenContract.unpause();

      // Retry Minting
      await starTokenContract.connect(acc1).mint(acc1.address, randomAmount);

      // Check Balance = randomAmount
      await checkBalance(acc1, randomAmount);
    });

    it("It should mint the amount requested to mint", async () => {
      // Generate Random Number
      let randomAmount = generateRandomNumber();

      // Try to mint
      await starTokenContract.connect(acc1).mint(acc1.address, randomAmount);

      // Check Balance = randomAmount
      await checkBalance(acc1, randomAmount);
    });
  });
});
