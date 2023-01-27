
pragma solidity ^0.4.25;

library SafeMath {


  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {

    return _a / _b;
  }

  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {

    assert(_b <= _a);
    return _a - _b;
  }

  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}


library BytesLib {

  function toAddress(bytes _bytes, uint _start) internal pure returns (address) {

    require(_bytes.length >= (_start + 20));
    address tempAddress;

    assembly {
      tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
    }

    return tempAddress;
  }

  function toUint(bytes _bytes, uint _start) internal pure returns (uint256) {

    require(_bytes.length >= (_start + 32));
    uint256 tempUint;

    assembly {
      tempUint := mload(add(add(_bytes, 0x20), _start))
    }

    return tempUint;
  }

  function slice(bytes _bytes, uint _start, uint _length) internal  pure returns (bytes) {

    require(_bytes.length >= (_start + _length));
    bytes memory tempBytes;

    assembly {
      switch iszero(_length)
        case 0 {
          tempBytes := mload(0x40)

          let lengthmod := and(_length, 31)

          let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
          let end := add(mc, _length)

          for {
            let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
          } lt(mc, end) {
            mc := add(mc, 0x20)
            cc := add(cc, 0x20)
          } {
            mstore(mc, mload(cc))
          }

          mstore(tempBytes, _length)

          mstore(0x40, and(add(mc, 31), not(31)))
        }
        default {
          tempBytes := mload(0x40)
          mstore(0x40, add(tempBytes, 0x20))
        }
    }
    return tempBytes;
  }

}

contract ERC223 {

  uint public totalSupply;
  function balanceOf(address who) constant returns (uint);


  function name() constant returns (string _name);

  function symbol() constant returns (string _symbol);

  function decimals() constant returns (uint8 _decimals);

  function totalSupply() constant returns (uint256 _supply);


  function transfer(address to, uint value) returns (bool ok);

  function transfer(address to, uint value, bytes data) returns (bool ok);

  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event ERC223Transfer(address indexed _from, address indexed _to, uint256 _value, bytes _data);
}

contract ContractReceiver {

  function tokenFallback(address _from, uint _value, bytes _data);

}

contract ERC20 {

  function totalSupply() public view returns (uint256);


  function balanceOf(address _who) public view returns (uint256);


  function allowance(address _owner, address _spender)
    public view returns (uint256);


  function transfer(address _to, uint256 _value) public returns (bool);


  function approve(address _spender, uint256 _value)
    public returns (bool);


  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);


  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

contract TokenAirdrop is ContractReceiver {

  using SafeMath for uint256;
  using BytesLib for bytes;

  mapping(address => mapping(address => uint256)) private balances;
  address private etherAddress = 0x0;

  event Airdrop(
    address from,
    address to,
    bytes message,
    address token,
    uint amount,
    uint time
  );
  event Claim(
    address claimer,
    address token,
    uint amount,
    uint time
  );


  function tokenFallback(address from, uint value, bytes data) public {

    require(data.length > 20);
    address beneficiary = data.toAddress(0);
    bytes memory message = data.slice(20, data.length - 20);
    balances[beneficiary][msg.sender] = balances[beneficiary][msg.sender].add(value);
    emit Airdrop(from, beneficiary, message, msg.sender, value, now);
  }

  function giftEther(address to, bytes message) public payable {

    require(msg.value > 0);
    balances[to][etherAddress] = balances[to][etherAddress].add(msg.value);
    emit Airdrop(msg.sender, to, message, etherAddress, msg.value, now);
  }

  function giftERC20(address to, uint amount, address token, bytes message) public {

    ERC20(token).transferFrom(msg.sender, address(this), amount);
    balances[to][token] = balances[to][token].add(amount);
    emit Airdrop(msg.sender, to, message, token, amount, now);
  }

  function claim(address token) public {

    uint amount = balanceOf(msg.sender, token);
    require(amount > 0);
    balances[msg.sender][token] = 0;
    require(sendTokensTo(msg.sender, amount, token));
    emit Claim(msg.sender, token, amount, now);
  }

  function balanceOf(address person, address token) public view returns(uint) {

    return balances[person][token];
  }

  function sendTokensTo(address destination, uint256 amount, address tkn) private returns(bool) {

    if (tkn == etherAddress) {
      destination.transfer(amount);
    } else {
      require(ERC20(tkn).transfer(destination, amount));
    }
    return true;
  }
}