const hre = require("hardhat");

async function main() {
  const KTokenV3 = await hre.ethers.deployContract("KTokenV3");
  await KTokenV3.waitForDeployment();

  console.log("KTokenV3 was deployed to:", KTokenV3.target);
}

main().catch((error) => {
    console.error(error);
    process.exit(1);
  });