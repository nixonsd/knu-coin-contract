import { ethers } from "hardhat";

async function main() {
  const lockedAmount = ethers.utils.parseEther("0.001");

  const KNUCoin = await ethers.getContractFactory("KNUCOIN");
  const coin = await KNUCoin.deploy(475393530, "KNUCOIN", "KNUCN");

  await coin.deployed();

  console.log(`KNUCoin with 0.001 ETH deployed to ${coin.address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
