require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");
const dotenv = require("dotenv");

dotenv.config()


/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.0",
  plugins : ["@nomiclabs/hardhat-ethers"],
  networks : {
    baobab : {
      url: `https://public-node-api.klaytnapi.com/v1/baobab`,
      accounts : [process.env.ACCOUNT_PK]
    }
  }
};

