
pragma solidity ^0.4.15;

contract ERC223Interface {

    uint public totalSupply;
    function balanceOf(address who) constant returns (uint);

    function transfer(address to, uint value);

    function transfer(address to, uint value, bytes data);

    event Transfer(address indexed from, address indexed to, uint value, bytes data);
}


contract ContractReceiver {


    struct TKN {
        address sender;
        uint value;
        bytes data;
        bytes4 sig;
    }


    function tokenFallback(address _from, uint _value, bytes _data){

      TKN memory tkn;
      tkn.sender = _from;
      tkn.value = _value;
      tkn.data = _data;
      uint32 u = uint32(_data[3]) + (uint32(_data[2]) << 8) + (uint32(_data[1]) << 16) + (uint32(_data[0]) << 24);
      tkn.sig = bytes4(u);

    }

    function rewiewToken  () returns (address, uint, bytes, bytes4) {
        TKN memory tkn;

        return (tkn.sender, tkn.value, tkn.data, tkn.sig);

    }
}

 
contract ERC223ReceivingContract { 

    function tokenFallback(address _from, uint _value, bytes _data);

}

contract SafeMath {

  function safeMul(uint a, uint b) internal returns (uint) {

    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint a, uint b) internal returns (uint) {

    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function safeSub(uint a, uint b) internal returns (uint) {

    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint a, uint b) internal returns (uint) {

    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  function max64(uint64 a, uint64 b) internal constant returns (uint64) {

    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {

    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {

    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {

    return a < b ? a : b;
  }

}

contract FNCTToken is ERC223Interface, SafeMath {


    mapping(address => uint) balances; // List of user balances.
    address  public owner;
    
    string public name = "Finecs Token";
    string public symbol = "FNC";
    uint8 public decimals = 18;
    uint public totalSupply = 500000000 * (10 ** uint(decimals));//Crowdsale supply
    uint public poolReserve = 30000000 * (10 ** uint(decimals));//Reserve pool
    uint public poolTeam = 30000000 * (10 ** uint(decimals));//Team pool
    uint public poolBounty = 30000000 * (10 ** uint(decimals));//Bounty pool
    uint public poolAdvisors = 30000000 * (10 ** uint(decimals));//Advisors pool
    uint public poolSale = 180000000 * (10 ** uint(decimals));//Sale pool
	uint public sellPrice = 1000000000000000 wei;//Tokens are sold for this manual price, rather than predefined price.

    function FNCTToken () {
        bytes memory empty;
        owner = msg.sender;
        balances[owner] = safeAdd(balances[owner], totalSupply);
        Transfer(0, this, totalSupply, empty);
        Transfer(this, owner, totalSupply, empty);
    }

    function transfer(address _to, uint _value, bytes _data) {

        uint codeLength;

        assembly {
            codeLength := extcodesize(_to)
        }

        balances[msg.sender] = safeSub(balances[msg.sender],_value);
        balances[_to] = safeAdd(balances[_to], _value);
        if(codeLength>0) {
           ContractReceiver receiver = ContractReceiver(_to);
            receiver.tokenFallback(msg.sender, _value, _data);
        }
        Transfer(msg.sender, _to, _value, _data);
    }

    function transfer(address _to, uint _value) {

        uint codeLength;
        bytes memory empty;

        assembly {
            codeLength := extcodesize(_to)
        }

        balances[msg.sender] = safeSub(balances[msg.sender],_value);
        balances[_to] = safeAdd(balances[_to], _value);
        if(codeLength>0) {
            ContractReceiver receiver = ContractReceiver(_to);
            receiver.tokenFallback(msg.sender, _value, empty);
        }
        Transfer(msg.sender, _to, _value, empty);
    }


    function balanceOf(address _owner) constant returns (uint balance) {

        return balances[_owner];
    }
}