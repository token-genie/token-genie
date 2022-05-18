import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { getStarToken } from "../lib/deploy.helpers";
import { StarToken } from "../typechain";

describe("StarToken Tests", () =>{
    let starTokenContract: StarToken;
    let deployer: SignerWithAddress;
    let acc1: SignerWithAddress;

    const oneStarTokenInWei = ethers.utils.parseEther("1");
    const MINTER_ROLE = ethers.utils.solidityKeccak256(['string'],['MINTER_ROLE']);

    beforeEach(async () => {
        starTokenContract = await getStarToken({ contractName: "StarToken", deployParams: [] });
        [deployer, acc1] = await ethers.getSigners();
    });

    describe("mint", () => {
        it("Should revert if the caller does not have minter role", async () => {
            await expect(
                starTokenContract.connect(acc1).mint(deployer.address, oneStarTokenInWei)
            ).to.be.revertedWith(`AccessControl: account ${acc1.address.toLowerCase()} is missing role ${MINTER_ROLE.toLowerCase()}`);
          });

        it("Should work when called by the owner", async () => {
        await starTokenContract.mint(deployer.address, oneStarTokenInWei);
    
        const balance = await starTokenContract.balanceOf(deployer.address);
        expect(balance).to.equal(oneStarTokenInWei);
        });    
    })


});