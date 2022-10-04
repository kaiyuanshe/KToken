require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config();

const END_POINT = process.env.END_POINT;
const PRIVATE_KEY = process.env.PRIVATE_KEY;

/** @type import('hardhat/config').HardhatUserConfig */

module.exports = {
  solidity: "0.8.17",
  networks: {
    goerli: {
      url: END_POINT,
      accounts: [PRIVATE_KEY]
    }
  }
};