
const hre = require("hardhat");

async function main() {

  const InsuranceFactory = await hre.ethers.getContractFactory("InsuranceFactory");
  const insuranceFactory = await InsuranceFactory.deploy();

  await insuranceFactory.deployed();
  console.log("Factory deployed to:", insuranceFactory.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.log(error);
    process.exit(1);
  });
