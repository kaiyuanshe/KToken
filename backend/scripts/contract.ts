import path from 'path'
const ethers = require('ethers');
require("dotenv").config();

// contract instance
const contract = require(path.join(__dirname, '../../compiled/KTokenV3.json'));
const contractInterface = contract.abi;

// Sepolia testnet
const network = "sepolia";
const provider = new ethers.InfuraProvider(
    network,
    process.env.INFURA_API_KEY // Infura 提供的接口密钥，一般是 https://sepolia.infura.io/v3/ 后面接的一串数字，这个 key 用来连接 Infura 的 RPC 端口
);
const signer = new ethers.Wallet(process.env.SEPOLIA_PVK, provider); // Ethereum Sepolia 测试网上账户的私钥，一般是合约的 Owner，发送积分的交易使用该账户发放，要确保该账户有足够的钱来支付 gas fee

const contractInstance = new ethers.Contract(
    process.env.SEPOLIA_CONTRACT_ADDRESS, // 部署在 Ethereum Sepolia 测试网上合约的地址
    contractInterface,
    signer
);

// 给 to 地址转 amount 个 token。注意，amount 个数量上传到区块链上，小数点会往后挪 18 位，即 amount == 1，token == 0.000000000000000001
export const transfer = async (to: string, amount: number) => {
    let transaction = await contractInstance.transfer(to, amount)
    let receipt = await transaction.wait()
    console.log(`Transfer to ${to} ${amount} tokens`);
    console.log(`The tx address is: ${transaction.hash}`)
};

// 读取 address 的账户余额
export const getBalanceOf = async (address: string) => {
    let balance = await contractInstance.balanceOf(address)
    console.log(`The balance of ${address} is: ${balance}`)
};

// 读取合约所定义的 token 的名字 (KToken)
export const getName = async () => {
    let name = await contractInstance.name()
    console.log(`The token name is ${name}`)
}

// 读取合约所定义的 token 的符号 (KTN)
export const getSymbol = async () => {
    let symbol = await contractInstance.symbol()
    console.log(`The token symbol is ${symbol}`)
}

// 读取ERC20合约的 Owner，我们合约中定义了只有 Owner 才能发放 token。
export const getOwner = async () => {
    let owner = await contractInstance.owner()
    console.log(`The contract owner is ${owner}`)
}

// 读取ERC20合约的小数位数，我们的位数是 18，参考 transfer 方法
export const getDecimal = async () => {
    let decimal = await contractInstance.decimals()
    console.log(`The token decimal is ${decimal}`)
}

// 读取合约所定义的 token 的总数量，我们目前发放 1亿枚 token
export const getTotalSupply = async () => {
    let totalSupply = await contractInstance.totalSupply()
    console.log(`The token total supply is ${totalSupply}`)
}

// get all transactions related with an address
// 
// Log data structure {
//     provider: InfuraProvider {
//       projectId: 'xxx',
//       projectSecret: null
//     },
//     transactionHash: 'xxx',
//     blockHash: 'xxx',
//     blockNumber: xxx,
//     removed: false,
//     address: 'xxx', // contract address
//     data: '0x0000000000000000000000000000000000000000000000000000000000000001',
//     topics: [
//       '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef',
//       '0x0000000000000000000000003061f83708b755fccc71f9689f0512e7e63237c1',
//       '0x00000000000000000000000057c641e614fb9ca266c8a8e0ab4285d2fad74d63'
//     ],
//     index: 24,
//     transactionIndex: 22
// }
export const getAllTransactions = async (address: string) => {
    
    const currentLatestBlockNumber = await provider.getBlock("latest")    
    const logs = await provider.getLogs({
        fromBlock: 4763210, // contract is deployed in this block
        toBlock: currentLatestBlockNumber.number,
        topics: [ethers.id('Transfer(address,address,uint256)')],
        address: process.env.SEPOLIA_CONTRACT_ADDRESS
    });
    
}

// getAllTransactions("0x57C641e614fB9Ca266C8a8e0Ab4285d2fAd74D63")
