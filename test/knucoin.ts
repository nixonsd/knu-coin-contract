import { expect } from "chai";
import { ethers } from "hardhat";
import { Contract } from "hardhat/internal/hardhat-network/stack-traces/model";
import { KNUCoin } from "../typechain-types";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";

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
    
  });
})