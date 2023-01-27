
pragma solidity ^0.4.21;

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
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
}



contract ERC20Interface {

    function totalSupply() public constant returns (uint);

    function balanceOf(address tokenOwner) public constant returns (uint balance);

    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);

    function transfer(address to, uint tokens) public returns (bool success);

    function approve(address spender, uint tokens) public returns (bool success);

    function transferFrom(address from, address to, uint tokens) public returns (bool success);


    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


contract ApproveAndCallFallBack {

    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;

}

contract Owned {

    address public owner;
    address private newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    function Owned() public {

        owner = msg.sender;
    }

    modifier onlyOwner {

        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {

        owner = _newOwner;
        OwnershipTransferred(msg.sender, _newOwner);
    }

}

contract OdinToken is ERC20Interface, Owned {


  using SafeMath for uint256;

    string public symbol;
    string public name;
    uint8 public decimals;
    uint private _totalSupply;
    bool private _whitelistAll;

    struct balanceData {  
       bool locked;
       uint balance;
       uint airDropQty;
    }

    mapping(address => balanceData) balances;
    mapping(address => mapping(address => uint)) allowed;


    function OdinToken() public {

        
        address owner;
        owner = msg.sender;
        symbol = "ODIN";
        name = "ODIN Token";
        decimals = 18;
        _whitelistAll=false;
        _totalSupply = 100000000000000000000000;
        balances[owner].balance = _totalSupply;

        Transfer(address(0), msg.sender, _totalSupply);
    }


    function totalSupply() public constant returns (uint) {

        return _totalSupply - balances[owner].balance;
    }

    function whitelistAddress(address to) public returns (bool)    {

		require(msg.sender == owner);
		balances[to].airDropQty = 0;
		return true;
    }


    function whitelistAllAddresses() public returns (bool) {

        require (msg.sender == owner);
        _whitelistAll = true;
        return true;
    }


    function balanceOf(address tokenOwner) public constant returns (uint balance) {

        return balances[tokenOwner].balance;
    }

    function transfer(address to, uint tokens) public returns (bool success) {


        require (msg.sender != to);                             // cannot send to yourself
        require(to != address(0));                              // cannot send to address(0)
        require(tokens <= balances[msg.sender].balance);        // do you have enough to send?
        
        uint sep_1_2018_ts = 1535760000;
        uint dec_31_2018_ts = 1546214400;
        uint mar_31_2019_ts = 1553990400;
        uint jun_30_2019_ts = 1561852800;
        uint oct_2_2019_ts = 1569974400;

        if (!_whitelistAll) {

             if (msg.sender != owner && block.timestamp < sep_1_2018_ts && balances[msg.sender].airDropQty>0) {
                 require(tokens < 0);
            }

            if (msg.sender != owner && block.timestamp < dec_31_2018_ts && balances[msg.sender].airDropQty>0) {
                require((balances[msg.sender].balance - tokens) >= (balances[msg.sender].airDropQty / 10 * 9));
            }

            if (msg.sender != owner && block.timestamp < mar_31_2019_ts && balances[msg.sender].airDropQty>0) {
                require((balances[msg.sender].balance - tokens) >= balances[msg.sender].airDropQty / 4 * 3);
            }

            if (msg.sender != owner && block.timestamp < jun_30_2019_ts && balances[msg.sender].airDropQty>0) {
                require((balances[msg.sender].balance - tokens) >= balances[msg.sender].airDropQty / 2);
            }

            if (msg.sender != owner && block.timestamp < jun_30_2019_ts && balances[msg.sender].airDropQty>0) {
                require((balances[msg.sender].balance - tokens) >= balances[msg.sender].airDropQty / 4);
            }
            

        }
        
        balances[msg.sender].balance = balances[msg.sender].balance.sub(tokens);
        balances[to].balance = balances[to].balance.add(tokens);
        if (msg.sender == owner) {
            balances[to].airDropQty = balances[to].airDropQty.add(tokens);
        }
        Transfer(msg.sender, to, tokens);
        return true;
    }


    function approve(address spender, uint tokens) public returns (bool success) {

        return false;
    }


    function transferFrom(address from, address to, uint tokens) public returns (bool success) {

        return false;
    }


    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {

        return 0;
    }


    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {

        return false;
    }

    function () {
        throw;
    }
}