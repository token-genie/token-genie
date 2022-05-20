import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { Challenges } from "../typechain";
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Challenges", function () {
	let challenges: Challenges;
	let deployer: SignerWithAddress;
  let acc1: SignerWithAddress;
  let user: SignerWithAddress;

  const DEFAULT_ADMIN_ROLE = "0x0000000000000000000000000000000000000000000000000000000000000000";
  const oneStarTokenInWei = ethers.utils.parseEther("1");

  const MANAGER_ROLE = ethers.utils.solidityKeccak256(
    ["string"],
    ["MANAGER_ROLE"]
  );
  
  const USER_ROLE = ethers.utils.solidityKeccak256(
    ["string"],
    ["USER_ROLE"]
  );
  
  
  beforeEach("deploy contract", async () => {
    
    const accounts = await ethers.getSigners();
    
    deployer = accounts[0];
		acc1 = accounts[1];
    

    const Challenges = await ethers.getContractFactory("Challenges");
		challenges = await Challenges.deploy();
		await challenges.deployed();
	});

  describe("deploy", () => {
    it("deployer has the DEFAULT_ADMIN_ROLE role", async function () {
      expect(
        await challenges.hasRole(
          DEFAULT_ADMIN_ROLE,
          deployer.address.toLowerCase()
        )).to.be.true;
    });
    
    it("deployer has the MANAGER role", async function () {
      expect(
        await challenges.hasRole(
          MANAGER_ROLE,
          deployer.address.toLowerCase()
          )).to.be.true;
    });
    
    it("non-deployer to not have DEFAULT_ADMIN_ROLE role", async function () {
      expect(
        await challenges.hasRole(
          DEFAULT_ADMIN_ROLE,
          acc1.address.toLowerCase()
        )).to.be.false;
        });
      });

      describe("create a challenge", () => {
      it("should emit added event when challenge is added by an account that has MANAGER_ROLE", async function () {
        await expect(challenges.connect(deployer).createChallenge({value: oneStarTokenInWei}))
          .to.emit(challenges, "ChallengeCreated")
          .withArgs(deployer.address, oneStarTokenInWei);
      });
      
      it("should revert if the caller does not have MANAGER_ROLE", async () => {
        await expect(challenges.connect(acc1).createChallenge({value: oneStarTokenInWei}))
        .to.be.revertedWith(
          `AccessControl: account ${acc1.address.toLowerCase()} is missing role ${MANAGER_ROLE.toLowerCase()}`
        );
      });
      })


});