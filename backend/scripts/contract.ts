import path from 'path'
const ethers = require('ethers');
require("dotenv").config();

// contract instance
const contract = require(path.join(__dirname, '/../../../onchain/artifacts/contracts/ktoken-v3.sol/KTokenV3.json'));
const contractInterface = contract.abi;

// Sepolia
const network = "sepolia";
const provider = new ethers.InfuraProvider(
    network,
    process.env.INFURA_API_KEY
);
const signer = new ethers.Wallet(process.env.SEPOLIA_PVK, provider);

const contractInstance = new ethers.Contract(
    process.env.SEPOLIA_CONTRACT_ADDRESS,
    contractInterface,
    signer
);

export const transfer = async (to: string, amount: number) => {
    let transaction = await contractInstance.transfer(to, amount)
    let receipt = await transaction.wait()
    console.log(`Transfer to ${to} ${amount} tokens`);
    console.log(`The tx address is: ${transaction.hash}`)
};

export const getBalanceOf = async (address: string) => {
    let balance = await contractInstance.balanceOf(address)
    console.log(`The balance of ${address} is: ${balance}`)
};

export const getName = async () => {
    let name = await contractInstance.name()
    console.log(`The token name is ${name}`)
}

export const getSymbol = async () => {
    let symbol = await contractInstance.symbol()
    console.log(`The token symbol is ${symbol}`)
}

export const getOwner = async () => {
    let owner = await contractInstance.owner()
    console.log(`The contract owner is ${owner}`)
}

export const getDecimal = async () => {
    let decimal = await contractInstance.decimals()
    console.log(`The token decimal is ${decimal}`)
}

export const getTotalSupply = async () => {
    let totalSupply = await contractInstance.totalSupply()
    console.log(`The token total supply is ${totalSupply}`)
}