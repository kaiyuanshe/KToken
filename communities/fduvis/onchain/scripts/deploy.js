async function main() {

    const [deployer] = await ethers.getSigners();  
    console.log("Deploying contracts with the account:", deployer.address);
    console.log("Account balance:", (await deployer.getBalance()).toString());
  
    const Token = await ethers.getContractFactory("KToken");
    const token = await Token.deploy();
  
    console.log("Token address:", token.address);
  }
  
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });

// contract address: 0xDAA0fB931ef3bA2335F10A3d92174CfF73c49C57