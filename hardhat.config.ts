import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

import * as dotenv from 'dotenv';
dotenv.config();

const config: HardhatUserConfig = {
  solidity: {
    version: '0.8.17',
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  defaultNetwork: 'localhost',
  networks: {
    hardhat: {},
    polygon: {
      url: 'https://polygon-rpc.comm',
      accounts: [ process.env.PRIVATE_KEY as string ],
    }
  },
  etherscan: {
    apiKey: process.env.POLYGONSCAN_API_KEY as string,
  },
};

export default config;
