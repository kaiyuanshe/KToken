const express = require("express");

const fs = require('fs');
const Web3 = require('web3');
const Transaction = require('ethereumjs-tx').Transaction;
const Common = require('ethereumjs-common').default;
const web3 = new Web3("https://ropsten.infura.io/v3/2e64466ceab94408862131e1c46283a4");

const app = express();
const port = 12121;

const nameMap = new Map();
nameMap.set('AmbitionCX','0x78275EdDBC5447A9E5692A07334a15D269CaF934');

app.use(express.json());

const PRIVATE_KEY  = "839215081938bbb154c6de41f4ee37dc0fb72537433a713bd19967b63035c36d";
const account = web3.eth.accounts.privateKeyToAccount(PRIVATE_KEY);
const CONTRACT_ADDRESS = "0x82768d3d0ad9575023b539038b2accd651aff2f2";
const contractABI = JSON.parse(fs.readFileSync('/home/kysktoken/KToken/Xlab/abi.json', 'UTF-8'));

const transfer_token = async (aimAddress, amount) => {  
	const AIM_ADDRESS = aimAddress;
	var count = await web3.eth.getTransactionCount(account.address, 'pending');
	var contractInstance = new web3.eth.Contract(contractABI, CONTRACT_ADDRESS, {from: account.address});
	var transferData = contractInstance.methods.transfer(AIM_ADDRESS, amount);
	const gas = await transferData.estimateGas({from: account.address});
	const gasPrice = await web3.eth.getGasPrice();

	const rawTransaction = {
		from    : account.address,
		to      : CONTRACT_ADDRESS,
		value	: "0x0",
		nonce	: web3.utils.toHex(count),
		data    : transferData.encodeABI(),
		gasLimit: web3.utils.toHex(gas),
		gasPrice: web3.utils.toHex(gasPrice)
	};
	const transaction = new Transaction(rawTransaction, {chain: 'ropsten', hardfork: 'petersburg'});
	transaction.sign(Buffer.from(account.privateKey.substring(2,66), 'hex'));
	var serializedTx = transaction.serialize();
	web3.eth.sendSignedTransaction('0x' + serializedTx.toString('hex'), (err, txHash) => {
		console.log('err:', err, "txHash:", txHash);
	});
}

app.get("/", (req, res) => res.send(`
<html>
	<head><title>KToken</title></head>
	<body>
		<h1>KToken server</h1>
		<a href="https://github.com/kaiyuanshe/KToken">Learn more about KToken in Github!</a>
	</body>
</html>
`));

app.post("/github", (req, res) => {

	const agent = req.header('User-Agent');
	const application = agent.substr(0, agent.indexOf('/'));
	const externalEvent = req.header('X-Github-Event');
	const externalAction = req.body.action;
	console.log(application, externalEvent, externalAction);
	
	if (externalEvent === "issues" && externalAction === "opened"){
		const username = req.body.issue.user.login;
		const aimAddress = nameMap.get(username);
		transfer_token(aimAddress, 30);
	}

	if (externalEvent === "issues" && externalAction === "labeled"){
		if (req.body.issue.labels[0].name === "help wanted"){
			const username = req.body.issue.user.login;
			const aimAddress = nameMap.get(username);
			transfer_token(aimAddress, 20);
		}
	}

	if (externalEvent === "star" && externalAction === "created"){
		const username = req.body.repository.owner.login;
		const aimAddress = nameMap.get(username);
		transfer_token(aimAddress, 10);
	}
	res.status(200).send();
});

app.listen(port, () =>
	console.log(`KToken server listening at http://139.217.226.92:${port}`)
);
