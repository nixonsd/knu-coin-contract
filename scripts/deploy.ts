import { ethers } from 'hardhat';

import * as dotenv from 'dotenv';
dotenv.config();

async function main() {
  const KNUCoin = await ethers.getContractFactory('KNUCOIN');
  const coin = await KNUCoin.deploy(
    Number(process.env.TEACHER_TELEGRAM_ID as string), 
    Number(process.env.TEACHER_ARRANGEMENT_LIMIT as string), 
    process.env.CONTRACT_NAME as string, 
    process.env.CONTRACT_SYMBOL as string,
    );

  await coin.deployed();

  console.log(`KNUCoin deployed to ${coin.address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
