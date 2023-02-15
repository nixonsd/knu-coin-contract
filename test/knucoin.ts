import { expect } from "chai";
import { ethers } from "hardhat";
import { KNUCoin } from "../typechain-types";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

describe('KNUCoin ERC20 Contract', () => {
  let knuCoin: KNUCoin;
  let initialAmount = ethers.BigNumber.from(100000);
  let owner: SignerWithAddress;
  let addr1: SignerWithAddress;
	let addr2: SignerWithAddress
	let addrs: SignerWithAddress[];
  
  beforeEach(async () => {
    [ owner, addr1, addr2, ...addrs ] = await ethers.getSigners();
    const KNUCoinFactory = await ethers.getContractFactory("KNUCoin");
    knuCoin = await KNUCoinFactory.deploy(initialAmount);
  });

  describe('Deployment', () => {
    it('should set the right owner', async () => {
      expect(await knuCoin.owner()).to.equal(owner.address);
    });

    it('should set initial balance', async () => {
      expect(await knuCoin.totalSupply()).to.equal(initialAmount);
    });
  });

  describe('Mint and burn ownership', () => {
    it('should complete mint', async () => {
      const amount = ethers.BigNumber.from(100);
      await knuCoin.mint(amount);
      expect(await knuCoin.balanceOf(owner.address)).to.equal(initialAmount.add(amount));
    });

    it('should revert mint', async () => {
      const amount = ethers.BigNumber.from(100);
      await expect(knuCoin.connect(addr1).mint(amount)).to.be.revertedWith('You aren\'t the owner');
    });

    it('should complete burn', async () => {
      const amount = ethers.BigNumber.from(100);
      await knuCoin.mint(amount);      
      await knuCoin.burn(amount);
      expect(await knuCoin.balanceOf(owner.address)).to.equal(initialAmount);
    });

    it('should revert burn', async () => {
      const amount = ethers.BigNumber.from(100);
      await expect(knuCoin.connect(addr1).burn(amount)).to.be.revertedWith('You aren\'t the owner');
    });
  });

  describe('Transactions', () => {
    it("should update balances after transfers", async function () {
			const initialOwnerBalance = await knuCoin.balanceOf(owner.address);
			await knuCoin.transfer(addr1.address, 100);
			await knuCoin.transfer(addr2.address, 50);

			const finalOwnerBalance = await knuCoin.balanceOf(owner.address);
			expect(finalOwnerBalance).to.equal(initialOwnerBalance.sub(150));

			const addr1Balance = await knuCoin.balanceOf(addr1.address);
			expect(addr1Balance).to.equal(100);

			const addr2Balance = await knuCoin.balanceOf(addr2.address);
			expect(addr2Balance).to.equal(50);
		});
  });
})