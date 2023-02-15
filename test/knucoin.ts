import { expect } from "chai";
import { ethers } from "hardhat";
import { Contract } from "hardhat/internal/hardhat-network/stack-traces/model";
import { KNUCoin } from "../typechain-types";
import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";

describe('KNUCoin ERC20 Contract', () => {
  let knuCoin: KNUCoin;
  
  async function deployCoin() {
    const ONE_GWEI = 1_000_000_000;
    const lockedAmount = ONE_GWEI;
    const [ owner, otherAccount ] = await ethers.getSigners();
    const KNUCoinFactory = await ethers.getContractFactory("KNUCoin");
    knuCoin = await KNUCoinFactory.deploy({value: lockedAmount});
    return { knuCoin, owner, otherAccount };
  }

  describe('Deployment', () => {
    it('should set the right owner', async () => {
      const { knuCoin, owner } = await loadFixture(deployCoin);
      expect(await knuCoin.owner()).to.equal(owner.address);
    });
  });

  describe('Mint and burn ownership', () => {
    it('should complete mint', async () => {
      const amount = ethers.BigNumber.from(100);
      const { knuCoin, owner } = await loadFixture(deployCoin);
      await knuCoin.mint(amount);
      expect(await knuCoin.balanceOf(owner.address)).to.equal(amount);
    });

    it('should revert mint', async () => {
      const amount = ethers.BigNumber.from(100);
      const { knuCoin, otherAccount } = await loadFixture(deployCoin);
      await expect(knuCoin.connect(otherAccount).mint(amount)).to.be.revertedWith('You aren\'t the owner');
    });

    it('should complete burn', async () => {
      const amount = ethers.BigNumber.from(100);
      const { knuCoin, owner } = await loadFixture(deployCoin);
      await knuCoin.mint(amount);      
      await knuCoin.burn(amount);
      expect(await knuCoin.balanceOf(owner.address)).to.equal(0);
    });

    it('should revert burn', async () => {
      const amount = ethers.BigNumber.from(100);
      const { knuCoin, otherAccount } = await loadFixture(deployCoin);
      await expect(knuCoin.connect(otherAccount).burn(amount)).to.be.revertedWith('You aren\'t the owner');
    });
  });

  describe('Trasnfers', () => {
    it('should mint throw transfer event', async () => {
      const amount = ethers.BigNumber.from(100);
      const { knuCoin } = await loadFixture(deployCoin);
      await expect(knuCoin.mint(amount)).to.emit(knuCoin, 'Transfer');
    });

    it('should burn throw transfer event', async () => {
      const amount = ethers.BigNumber.from(100);
      const { knuCoin } = await loadFixture(deployCoin);
      knuCoin.mint(amount);
      await expect(knuCoin.burn(amount)).to.emit(knuCoin, 'Transfer');
    });
  });
})