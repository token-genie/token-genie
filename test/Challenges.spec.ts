import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { Challenges, StarToken } from "../typechain";
import { getStarToken } from "../lib/deploy.helpers";

const { expect } = require("chai");
const { ethers } = require("hardhat");



describe("Challenges", function () {
  let starTokenContract: StarToken;
	let challenges: Challenges;
	let deployer: SignerWithAddress;
  let acc1: SignerWithAddress;
  let acc2: SignerWithAddress;
  let user: SignerWithAddress;

  const oneStarTokenInWei = ethers.utils.parseEther("1");
  const MINTER_ROLE = ethers.utils.solidityKeccak256(
    ["string"],
    ["MINTER_ROLE"]
  );

  const DEFAULT_ADMIN_ROLE = "0x0000000000000000000000000000000000000000000000000000000000000000";

  const MANAGER_ROLE = ethers.utils.solidityKeccak256(
    ["string"],
    ["MANAGER_ROLE"]
  );
  
  const USER_ROLE = ethers.utils.solidityKeccak256(
    ["string"],
    ["USER_ROLE"]
  );
  
  
  beforeEach("deploy contracts", async () => {
    const accounts = await ethers.getSigners();
    
    deployer = accounts[0];
		acc1 = accounts[1];
    acc2 = accounts[2];
    

    starTokenContract = await getStarToken({
      contractName: "StarToken",
      deployParams: [],
    });

    const Challenges = await ethers.getContractFactory("Challenges");
		challenges = await Challenges.deploy(starTokenContract.address);
		await challenges.deployed();
	});

  describe("deploy star token", () => {
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

  describe("deploy challenge", () => {
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
        await expect(challenges.connect(deployer).createChallenge(10))
          .to.emit(challenges, "ChallengeCreated")
          .withArgs(deployer.address, 10, 1);
      });
      
      it("should revert if the caller does not have MANAGER_ROLE", async () => {
        await expect(challenges.connect(acc1).createChallenge(10))
        .to.be.revertedWith(
          `AccessControl: account ${acc1.address.toLowerCase()} is missing role ${MANAGER_ROLE.toLowerCase()}`
        );
      });
      })

      describe("approves the user for a challenge", () => {
          it("should revert if the caller does not have MANAGER_ROLE", async () => {
            await expect(challenges.connect(acc1).approveUser(deployer.address, 0))
            .to.be.revertedWith(
              `AccessControl: account ${acc1.address.toLowerCase()} is missing role ${MANAGER_ROLE.toLowerCase()}`
            );
          });

          it("gives the user the USER_ROLE", async() => {
            await challenges.connect(deployer).approveUser(acc1.address, 0);
            expect(await challenges.hasRole(
              USER_ROLE,
              acc1.address.toLowerCase()
            )).to.be.true;
          })

          it("approves the user as expected", async() => {
            // Creates the challenge
            await expect(challenges.connect(deployer).createChallenge(10))
            .to.emit(challenges, "ChallengeCreated")
            .withArgs(deployer.address, 10, 1);
            
            // Approves the user and checks that the user is added
            await expect(challenges.connect(deployer).approveUser(acc1.address, 0))
            .to.emit(challenges, "UserApproved")
            .withArgs(0, true);
          })
        });

        describe("the user can complete a challenge that they are approved into", () => {
          it("should revert if the caller does not have USER_ROLE", async () => {
            await expect(challenges.connect(deployer).challengeComplete(0))
            .to.be.revertedWith(
              `AccessControl: account ${deployer.address.toLowerCase()} is missing role ${USER_ROLE.toLowerCase()}`
            );
          })

          it("user can declare that they have completed a challenge", async () => {
            // Creates the challengeuser can declare that they have completed a challenge:
            await expect(challenges.connect(deployer).createChallenge(10))
            .to.emit(challenges, "ChallengeCreated")
            .withArgs(deployer.address, 10, 1);
            
            // Approves the user and checks that the user is added
            await expect(challenges.connect(deployer).approveUser(acc1.address, 0))
            .to.emit(challenges, "UserApproved")
            .withArgs(0, true);
            
            // Completes the challenge
            await expect(challenges.connect(acc1).challengeComplete(0))
            .to.emit(challenges, "ChallengeCompleted")
            .withArgs(0,true);
          })

        });
        

        describe("approves that the challenge is completed for a given user", () => {
          it("should revert if the caller does not have MANAGER_ROLE", async () => {
            await expect(challenges.connect(acc1).approveUser(deployer.address, 0))
            .to.be.revertedWith(
              `AccessControl: account ${acc1.address.toLowerCase()} is missing role ${MANAGER_ROLE.toLowerCase()}`
            );
          });

          it("approves the challenge completed as expected", async () => {
            // Creates the challenge
            await expect(challenges.connect(deployer).createChallenge(10))
            .to.emit(challenges, "ChallengeCreated")
            .withArgs(deployer.address, 10, 1);
            
            // Approves the user and checks that the user is added
            await expect(challenges.connect(deployer).approveUser(acc1.address, 0))
            .to.emit(challenges, "UserApproved")
            .withArgs(0, true);

            // Does not complete the challenge
            await expect(challenges.connect(acc1).challengeComplete(0))
            .to.emit(challenges, "ChallengeCompleted")
            .withArgs(0, true);

            // approves that the challenge is completed
            await expect(challenges.connect(deployer).approveChallengeComplete(acc1.address, 0))
            .to.emit(challenges, "ChallengeApproved")
            .withArgs(0, false, 10);
          });
        });
        
       
        
});