require("@nomiclabs/hardhat-waffle");
// require('dotenv').config({ path: './.env.local' })

/** @type import('hardhat/config').HardhatUserConfig */

// const privateKey = process.env.NEXT_PUBLIC_PRIVATE_KEY

module.exports = {
  solidity: "0.8.17",
  defaultNetwork: "ganache",
  networks: {
    hardhat: {},
    ganache: {
      url: "HTTP://127.0.0.1:7545",
      accounts: ["6ca2bb252dc6a27d0f29a76b634fbdf03a35e16b30f57a09e9f0c4bf76ddc71c"]
    }
  }
};