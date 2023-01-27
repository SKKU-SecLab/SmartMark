pragma solidity ^0.5.8;

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

  function toString(uint256 _i) internal pure returns (string memory) {

    if (_i == 0) {
      return '0';
    }
    uint256 j = _i;
    uint256 len;
    while (j != 0) {
      len++;
      j /= 10;
    }
    bytes memory bstr = new bytes(len);
    uint256 k = len;
    while (_i != 0) {
      k = k - 1;
      uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
      bytes1 b1 = bytes1(temp);
      bstr[k] = b1;
      _i /= 10;
    }
    return string(bstr);
  }
}
pragma solidity ^0.5.8;

contract ERC20Basic {

  function name() external view returns (string memory _name);


  function symbol() external view returns (string memory _symbol);


  function decimals() external view returns (uint8 _decimals);


  function totalSupply() external view returns (uint256 _totalSupply);


  function balanceOf(address who) public view returns (uint256);


  function transfer(address to, uint256 value) public returns (bool);


  event Transfer(address indexed from, address indexed to, uint256 value);
}
pragma solidity ^0.5.8;


contract BasicToken is ERC20Basic {

  using SafeMath for uint256;
  mapping(address => uint256) public balances;

  function transfer(address _to, uint256 _value) public returns (bool) {

    require(msg.sender != _to, 'cannot send to same account');
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public view returns (uint256 bal) {

    return balances[_owner];
  }
}
pragma solidity ^0.5.8;


contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender)
    public
    view
    returns (uint256);


  function transferFrom(
    address from,
    address to,
    uint256 value
  ) public returns (bool);


  function approve(address spender, uint256 value) public returns (bool);


  event Approval(address indexed owner, address indexed spender, uint256 value);
}
pragma solidity ^0.5.8;


contract Token is ERC20, BasicToken {

  mapping(address => mapping(address => uint256)) private allowed;

  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  ) public returns (bool) {

    uint256 _allowance = allowed[_from][msg.sender];
    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) public returns (bool) {

    assert((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender)
    public
    view
    returns (uint256 remaining)
  {

    return allowed[_owner][_spender];
  }
}
pragma solidity ^0.5.8;

interface ERC165 {

  function supportsInterface(bytes4 _interfaceID) external view returns (bool);

}
pragma solidity ^0.5.8;


contract SupportsInterface is ERC165 {

  mapping(bytes4 => bool) internal supportedInterfaces;

  constructor() public {
    supportedInterfaces[0x01ffc9a7] = true; // ERC165
  }

  function supportsInterface(bytes4 _interfaceID) external view returns (bool) {

    return supportedInterfaces[_interfaceID];
  }
}
pragma solidity ^0.5.8;


contract GrexieToken is Token, SupportsInterface {

  string private constant NAME = 'Grexie';
  string private constant SYMBOL = 'GREX';
  uint8 private constant DECIMALS = 18;

  uint256 private constant TOTAL_SUPPLY = 10**15 * 10**18;

  constructor() public {
    balances[msg.sender] = TOTAL_SUPPLY;
    supportedInterfaces[0x36372b07] = true; // ERC20
    supportedInterfaces[0x06fdde03] = true; // ERC20 name
    supportedInterfaces[0x95d89b41] = true; // ERC20 symbol
    supportedInterfaces[0x313ce567] = true; // ERC20 decimals
  }

  function name() external view returns (string memory _name) {

    return NAME;
  }

  function symbol() external view returns (string memory _symbol) {

    return SYMBOL;
  }

  function decimals() external view returns (uint8 _decimals) {

    return DECIMALS;
  }

  function totalSupply() external view returns (uint256 _totalSupply) {

    return TOTAL_SUPPLY;
  }
}
