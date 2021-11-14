const fs = require('fs');
const Web3 = require('web3');
const web3 = new Web3("https://ropsten.infura.io/v3/2e64466ceab94408862131e1c46283a4");

const CONTRACT_ADDRESS = "0x82768d3d0ad9575023b539038b2accd651aff2f2";
const PRIVATE_KEY  = "839215081938bbb154c6de41f4ee37dc0fb72537433a713bd19967b63035c36d";
const account = web3.eth.accounts.privateKeyToAccount(PRIVATE_KEY);
const contractAbi = JSON.parse(fs.readFileSync('abi.json', 'UTF-8'));
var contractInstance = new web3.eth.Contract(contractAbi, CONTRACT_ADDRESS, {from: account.address});
var args = process.argv.slice(2);

const callAirData = (account) => {
	try {
        	contractInstance.methods.balanceOf(account).call((err, result) => {
               		console.log(result);
        });
	} catch (error) {
		console.log("invalid account");
	}
}
callAirData(args[0]);
