const express = require('express');
const bodyParser = require('body-parser');
const createConnectionPool = require('@databases/pg');
const {sql} = require('@databases/pg');
const Web3 = require('web3');
const fs = require('fs');
const Transaction = require('ethereumjs-tx').Transaction;

const app = express();
const port = 8083;
require('dotenv').config();
app.use(bodyParser.json());

async function sendTransaction(toAddress, amount) {

  const web3_endpoint = process.env.WEB3_ENDPOINT;
  const web3 = new Web3(web3_endpoint);
  web3.eth.defaultChain = 'goerli';

  const private_key = process.env.PRIVATE_KEY;
  const account = web3.eth.accounts.privateKeyToAccount(private_key);

  const nonce = await web3.eth.getTransactionCount(account.address, 'pending');
  const abiArray = JSON.parse(fs.readFileSync('abi.json', 'utf-8'));
  const contractAddress = process.env.CONTRACT_ADDRESS;
  const contract = new web3.eth.Contract(abiArray, contractAddress);

  const default_gas_limit = 60000;
  const default_gas_price = web3.utils.toWei('5', 'gwei');
  const rawTransaction = {
    "from"    : account.address,
    "to"      : contractAddress,
    "value"   : "0x0",
    "nonce"   : web3.utils.toHex(nonce),
    "gasLimit": web3.utils.toHex(default_gas_limit),
    "gasPrice": web3.utils.toHex(default_gas_price),
    "data"    : contract.methods.transfer(toAddress, amount).encodeABI(),
    "chainId" : 5
  };

  const transaction = new Transaction(rawTransaction, { chain: 'goerli' });
  transaction.sign(Buffer.from(account.privateKey.substring(2,66), 'hex'));
  var serializedTransaction = transaction.serialize();
  web3.eth.sendSignedTransaction('0x' + serializedTransaction.toString('hex'), (err, txHash) => {
    if (!err) { console.log(txHash); }
    else { console.log(err); }
  });
}

app.get('/', (req, res) => {
  res.send('Yuque webhook listening on this website.');
})

app.post('/', async (req, res) => {

  // A user is recognized by id, login, and name
  const user_id = req.body.data.actor_id;

  // GMT, 8 hours behind beijing time
  const update_time = req.body.data.updated_at;

  // publish, update, comment_create, comment_reply_create
  const action_type = req.body.data.action_type;

  // target documentation
  const doc_path = req.body.data.path;

  let doc_title;
  if ( action_type.includes("comment") ) {
    doc_title = req.body.data.commentable.title;
  } else {
    doc_title = req.body.data.title;
  }

  const db = createConnectionPool('postgres://' + process.env.PG_ENDPOINT);
  // check if duplicated
  let previousAction = await db.query(sql`select * from yq_actions where f_user=${user_id} and f_action=${action_type} and f_time=${update_time}`);
  if( previousAction.length == 0 ){
    // token according to the action
    let token_amount = 0;
    switch (action_type) {
      case 'publish': token_amount = 1; break;
      case 'update': token_amount = 1; break;
      case 'comment_create': token_amount = 1; break;
      case 'comment_reply_create': token_amount = 1; break;
      default:
        res.end(`${action_type} action not supported.`);
    };
    // read address from database
    let addressMessage = await db.query(sql`select user_wallet from yq_users where user_id=${user_id}`);
    let target_address = addressMessage[0].user_wallet;

    // Transfor tokens to address
    await sendTransaction(target_address, token_amount.toString());
    await db.query(sql`
        insert into yq_actions(f_user, f_path, f_doc, f_action, f_time, f_amount)
        values (${user_id}, ${doc_path}, ${doc_title}, ${action_type}, ${update_time}, ${token_amount})
    `);
    await db.dispose();
  } // if action is not duplicated
})

app.listen(port, function () {
  console.log(`Yuque webhook listening on port ${port}`);
});