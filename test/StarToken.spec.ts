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
    it("1ETH should mint 200,000 StarTokens", async () => {
      // Checking initial contract balance
      let contractBalance = await ethers.provider.getBalance(starTokenContract.address);
      expect(contractBalance).to.equal(0);

      //Acc1 mints 1ETH worth of tokens
      await starTokenContract
        .connect(acc1)
        .mint(acc1.address, 200000, { value: ethers.utils.parseEther("1") });
      const balance = await starTokenContract.balanceOf(acc1.address);
      expect(balance).to.equal(200000);
    
      //Contract now has 1ETH stored
      contractBalance = await ethers.provider.getBalance(starTokenContract.address);
      expect(contractBalance).to.equal(ethers.utils.parseEther("1"));
    });

    it("1ETH should not mint any other amounts", async () => {
      // Checking initial contract balance
      let contractBalance = await ethers.provider.getBalance(starTokenContract.address);
      expect(contractBalance).to.equal(0);

      let randomAmount: number = Math.floor(Math.random() * (2 ^ (50 - 1)) + 1);
      if (randomAmount == 200000) randomAmount++;

      await expect(
        starTokenContract.connect(acc1).mint(deployer.address, randomAmount)
      ).to.be.revertedWith(`StarToken: Incorrect Mint Price`);

      //Contract balance is not changed
      contractBalance = await ethers.provider.getBalance(starTokenContract.address);
      expect(contractBalance).to.equal(0);
    });
  });

  describe("withdraw", () => {
    it("Should revert if the caller does not have DEFAULT_ADMIN_ROLE role", async () => {
      // Checking initial contract balance
      let contractBalance = await ethers.provider.getBalance(starTokenContract.address);
      expect(contractBalance).to.equal(0);

      //Acc2 Purchases 200000 Tokens
      await starTokenContract
        .connect(acc2)
        .mint(acc2.address, 200000, { value: ethers.utils.parseEther("1") });
      
      //Contract now has 1ETH stored
      contractBalance = await ethers.provider.getBalance(starTokenContract.address);
      expect(contractBalance).to.equal(ethers.utils.parseEther("1"));

      // Acc1 Tries to Widthraw Funds
      await expect(
        starTokenContract.connect(acc1).widthdraw(acc1.address)
      ).to.be.revertedWith(
        `AccessControl: account ${acc1.address.toLowerCase()} is missing role ${DEFAULT_ADMIN_ROLE.toLowerCase()}`
      );
      
      //Contract balance is still the same
      contractBalance = await ethers.provider.getBalance(starTokenContract.address);
      expect(contractBalance).to.equal(ethers.utils.parseEther("1"));
    });

    it("Should work when called by the owner", async () => {
      // Checking initial contract balance
      let contractBalance = await ethers.provider.getBalance(starTokenContract.address);
      expect(contractBalance).to.equal(0);

      let deployerInitialBalance = await ethers.provider.getBalance(deployer.address);

      //Acc2 Purchases 200000 Tokens
      await starTokenContract
        .connect(acc2)
        .mint(acc2.address, 200000, { value: ethers.utils.parseEther("1") });
          
      //Contract now has 1ETH stored
      contractBalance = await ethers.provider.getBalance(starTokenContract.address);
      expect(contractBalance).to.equal(ethers.utils.parseEther("1"));

      let withdrawTx = await starTokenContract.connect(deployer).widthdraw(deployer.address)
      let txReceipt = await withdrawTx.wait();
      let withdrawGas = ethers.BigNumber.from(
        txReceipt.gasUsed.mul(txReceipt.effectiveGasPrice)
      );
      
      let deployerLaterBalance = await ethers.provider.getBalance(deployer.address);
      contractBalance = await ethers.provider.getBalance(starTokenContract.address);

      expect(contractBalance).to.equal(0);
      expect(deployerLaterBalance).to.equal(deployerInitialBalance.sub(withdrawGas).add(ethers.utils.parseEther("1")))
    });
  });
});
