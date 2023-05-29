import { ethers } from "hardhat";

async function main() {
  const KNUCoin = await ethers.getContractFactory("KNUCOIN");
  const coin = await KNUCoin.deploy(475393530, 4, "KNUCOIN", "KNUCOIN");

  await coin.deployed();

  console.log(`KNUCoin deployed to ${coin.address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
