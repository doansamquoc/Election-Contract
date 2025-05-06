import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: "0.8.28",
  networks: {
    sepolia: {
      url: process.env.RPC_URL,
      accounts: [`0x${process.env.PRIVATE_KEY}`],
    },
  },
};

export default config;
