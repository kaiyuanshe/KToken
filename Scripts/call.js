const fs = require('fs');
const Web3 = require('web3');
const solc = require('solc');

// private network
require('dotenv').config();
const privatekey = process.env.PRIVATE_KEY;
const web3 = new Web3('https://:' + process.env.PROJECT_SECRET + '@ropsten.infura.io/v3/' + process.env.INFURA_ID);
const account = web3.eth.accounts.privateKeyToAccount(privatekey);
const account_from = {
  privateKey: account.privateKey,
  accountaddress: account.address,
};
//console.log(account_from.accountaddress);
const source = fs.readFileSync('ktoken.sol', 'utf8');

const input = {
  language: 'Solidity',
  sources: {
    'ktoken.sol': {
      content: source,
    },
  },
  settings: {
    outputSelection: {
      '*': {
        '*': ['*'],
      },
    },
  },
};

const tempFile = JSON.parse(solc.compile(JSON.stringify(input)));
const contractFile = tempFile.contracts['ktoken.sol']['KToken'];
const bytecode = contractFile.evm.bytecode.object;
const abi = contractFile.abi;
const contract = new web3.eth.Contract(abi, process.env.CONTRACT_ADDRESS);

const Transfer = async () => {
    const transferTx = contract.methods.transfer(process.env.RECEIVER, 1).encodeABI();
    const transferTransaction = await web3.eth.accounts.signTransaction({
        to: process.env.CONTRACT_ADDRESS,
        data: transferTx,
        gas: 5000000,
    },
    account_from.privateKey
  );

  // Send Tx and Wait for Receipt
  const txReceipt = await web3.eth.sendSignedTransaction(transferTransaction.rawTransaction);
  console.log(txReceipt);
}

const Call = async() => {
	contract.methods.balanceOf(account.address).call().then((result) => {
		console.log(`Return data: `, result);
	});
}

Transfer().then(() => process.exit(0)).catch((error) => { console.log(error); process.exit(1); });
// Call();
