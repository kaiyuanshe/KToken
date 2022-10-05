// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract KToken is IERC20 {

    string public constant name = "FDU VIS Coin";
    string public constant symbol = "FVC";
    uint8 public constant decimals = 0;
    address public Owner;

    mapping(address => uint256) balances;
    uint256 TotalSupply;
    using SafeMath for uint256;

   constructor() public {
        TotalSupply = 100000000;
        Owner = msg.sender;
        balances[Owner] = TotalSupply;
    }

    function totalSupply() public override view returns (uint256) {
        return TotalSupply;
    }

    function balanceOf(address _owner) public override view returns (uint256) {
        return balances[_owner];
    }

    function transfer(address _receiver, uint256 _amount) public override returns (bool) {
	require(msg.sender == Owner, "Transfer Disabled");
        require(_amount <= balances[Owner], "Contract Balance Insufficient");
        balances[Owner] = balances[Owner].sub(_amount);
        balances[_receiver] = balances[_receiver].add(_amount);
        emit Transfer(Owner, _receiver, _amount);
        return true;
    }

    function transferFrom(address _sender, address _receiver, uint256 _amount) public override pure returns (bool) {
        require(false, "Transfer Disabled");
        return false;
    }

    function approve(address _spender, uint256 _amount) public override pure returns (bool) {
        require(false, "Approval Disabled");
        return false;
    }

    function allowance(address _owner, address _spender) public override pure returns (uint256) {
        require(false, "Approval Disabled");
        return 0;
    }
}

library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}
