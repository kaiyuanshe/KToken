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

contract TestToken is IERC20 {

    string public constant name = "KToken";
    string public constant symbol = "KTN";
    uint8 public constant decimals = 0;
    address public Owner;
    bool public isExchangeEnable;

    mapping(address => uint256) balances;
    mapping(address => uint256) points;
    mapping(address => mapping (address => uint256)) allowed;
    uint256 TotalSupply;
    using SafeMath for uint256;

   constructor() public {
        TotalSupply = 1000000;
        Owner = msg.sender;
        balances[Owner] = TotalSupply;
        isExchangeEnable = false;
    }

    function totalSupply() public override view returns (uint256) {
        return TotalSupply;
    }

    function balanceOf(address _tokenOwner) public override view returns (uint256) {
        return balances[_tokenOwner];
    }

    function pointOf(address _tokenOwner) public view returns (uint256) {
        return points[_tokenOwner];
    }

    function enableTokenExchange() public {
        require(msg.sender == Owner, "Only Owner");
        isExchangeEnable = true;
    }

    function disableTokenExchange() public {
        require(msg.sender == Owner, "Only Owner");
        isExchangeEnable = false;
    }

    function transfer(address _receiver, uint256 _amount) public override returns (bool) {
        require(msg.sender == Owner, "Transfer Disabled");
        require(_amount <= balances[Owner], "Contract Balance Insufficient");
        balances[Owner] = balances[Owner].sub(_amount);
        balances[_receiver] = balances[_receiver].add(_amount);
        points[_receiver] = points[_receiver].add(_amount);
        emit Transfer(Owner, _receiver, _amount);
        return true;
    }

    function transferFrom(address _sender, address _receiver, uint256 _amount) public override returns (bool) {
        require(isExchangeEnable = true, "Exchange Disabled");
        require(_amount <= balances[_sender], "Balance Insufficient");
        require(_amount <= allowed[_sender][msg.sender], "Allowance Insufficient");

        balances[_sender] = balances[_sender].sub(_amount);
        allowed[_sender][msg.sender] = allowed[_sender][msg.sender].sub(_amount);
        balances[_receiver] = balances[_receiver].add(_amount);
        emit Transfer(_sender, _receiver, _amount);
        return true;
    }

    function approve(address _spender, uint256 _amount) public override returns (bool) {
        require(isExchangeEnable = true, "Exchange Disabled");
        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    function allowance(address _owner, address _spender) public override view returns (uint256) {
        return allowed[_owner][_spender];
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
