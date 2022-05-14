const fs = require('fs');
const solc = require('solc');

// Get Path and Load Contract
const source = fs.readFileSync('ktoken.sol', 'utf8');
function findImports(path) {
  if (fs.existsSync(path)) {
    return {
      contents: fs.readFileSync(path, 'utf8'),
    };
  } else if (fs.existsSync('./node_modules/' + path)) {
    return {
      contents: fs.readFileSync('./node_modules/' + path, 'utf8'),
    };
  } else {
    return { error: 'File not found' };
  }
}

// Compile Contract
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

const tempFile = JSON.parse(
  solc.compile(JSON.stringify(input), { import: findImports })
);
const contractFile = tempFile.contracts['ktoken.sol']['KToken'];

// Export Contract Data
module.exports = contractFile;
