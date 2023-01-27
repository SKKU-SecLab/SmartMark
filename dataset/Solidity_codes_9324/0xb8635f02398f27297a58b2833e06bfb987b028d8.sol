pragma solidity ^0.7.0;

interface Token {

  function totalSupply () external view returns (uint256 supply);

  function balanceOf (address _owner) external view returns (uint256 balance);

  function transfer (address _to, uint256 _value)
  external returns (bool success);

  function transferFrom (address _from, address _to, uint256 _value)
  external returns (bool success);

  function approve (address _spender, uint256 _value)
  external returns (bool success);

  function allowance (address _owner, address _spender)
  external view returns (uint256 remaining);

  event Transfer (address indexed _from, address indexed _to, uint256 _value);

  event Approval (
    address indexed _owner, address indexed _spender, uint256 _value);
}
pragma solidity ^0.7.0;

contract SafeMath {

  uint256 constant private MAX_UINT256 =
    0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

  function safeAdd (uint256 x, uint256 y)
  pure internal
  returns (uint256 z) {
    assert (x <= MAX_UINT256 - y);
    return x + y;
  }

  function safeSub (uint256 x, uint256 y)
  pure internal
  returns (uint256 z) {
    assert (x >= y);
    return x - y;
  }

  function safeMul (uint256 x, uint256 y)
  pure internal
  returns (uint256 z) {
    if (y == 0) return 0; // Prevent division by zero at the next line
    assert (x <= MAX_UINT256 / y);
    return x * y;
  }
}
pragma solidity ^0.7.0;


abstract contract AbstractToken is Token, SafeMath {
  constructor () {
  }

  function balanceOf (address _owner) override public view returns (uint256 balance) {
    return accounts [_owner];
  }

  function transfer (address _to, uint256 _value)
  override public returns (bool success) {
    uint256 fromBalance = accounts [msg.sender];
    if (fromBalance < _value) return false;
    if (_value > 0 && msg.sender != _to) {
      accounts [msg.sender] = safeSub (fromBalance, _value);
      accounts [_to] = safeAdd (accounts [_to], _value);
    }
    emit Transfer (msg.sender, _to, _value);
    return true;
  }

  function transferFrom (address _from, address _to, uint256 _value)
  override public returns (bool success) {
    uint256 spenderAllowance = allowances [_from][msg.sender];
    if (spenderAllowance < _value) return false;
    uint256 fromBalance = accounts [_from];
    if (fromBalance < _value) return false;

    allowances [_from][msg.sender] =
      safeSub (spenderAllowance, _value);

    if (_value > 0 && _from != _to) {
      accounts [_from] = safeSub (fromBalance, _value);
      accounts [_to] = safeAdd (accounts [_to], _value);
    }
    emit Transfer (_from, _to, _value);
    return true;
  }

  function approve (address _spender, uint256 _value)
  override public returns (bool success) {
    allowances [msg.sender][_spender] = _value;
    emit Approval (msg.sender, _spender, _value);

    return true;
  }

  function allowance (address _owner, address _spender)
  override public view returns (uint256 remaining) {
    return allowances [_owner][_spender];
  }

  mapping (address => uint256) internal accounts;

  mapping (address => mapping (address => uint256)) internal allowances;
}
pragma solidity ^0.7.0;


contract AABBGoldToken is AbstractToken {

  uint256 tokenCount;

  constructor (uint256 _tokenCount) {
    accounts [msg.sender] = _tokenCount;
    tokenCount = _tokenCount;
  }

  function totalSupply () override public view returns (uint256 supply) {
    return tokenCount;
  }

  function name () public pure returns (string memory result) {
    return "AABB Gold";
  }

  function symbol () public pure returns (string memory result) {
    return "AABBG";
  }

  function decimals () public pure returns (uint8 result) {
    return 8;
  }

  function approve (address _spender, uint256 _currentValue, uint256 _newValue)
    public returns (bool success) {
    if (allowance (msg.sender, _spender) == _currentValue)
      return approve (_spender, _newValue);
    else return false;
  }
}

