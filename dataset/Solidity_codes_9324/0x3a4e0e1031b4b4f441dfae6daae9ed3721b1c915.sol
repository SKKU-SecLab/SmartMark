pragma solidity ^0.6.0;

interface IDSProxyFactory {

  function build() external returns (address payable);

}

interface IDSProxy {

  function setOwner(address) external;

}

contract ProxyCoin {


  mapping(address => uint256) s_balances;
  address[] s_proxies;
  mapping(address => mapping(address => uint256)) s_allowances;

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);

  function balanceOf(address owner) public view returns (uint256 balance) {

    return s_balances[owner];
  }

  function internalTransfer(address from, address to, uint256 value) internal returns (bool success) {

    if (value <= s_balances[from]) {
      s_balances[from] -= value;
      s_balances[to] += value;
      emit Transfer(from, to, value);
      return true;
    } else {
      return false;
    }
  }

  function transfer(address to, uint256 value) public returns (bool success) {

    address from = msg.sender;
    return internalTransfer(from, to, value);
  }

  function transferFrom(address from, address to, uint256 value) public returns (bool success) {

    address spender = msg.sender;
    if(value <= s_allowances[from][spender] && internalTransfer(from, to, value)) {
      s_allowances[from][spender] -= value;
      return true;
    } else {
      return false;
    }
  }

  function approve(address spender, uint256 value) public returns (bool success) {

    address owner = msg.sender;
    if (value != 0 && s_allowances[owner][spender] != 0) {
      return false;
    }
    s_allowances[owner][spender] = value;
    emit Approval(owner, spender, value);
    return true;
  }

  function allowance(address owner, address spender) public view returns (uint256 remaining) {

    return s_allowances[owner][spender];
  }


  uint8 constant public decimals = 0;
  string constant public name = "proxy.cash";
  string constant public symbol = "DS-Proxy";

  IDSProxyFactory public DSFactory;

  uint256 supply;


  constructor(address _dsFactory) public {
    DSFactory = IDSProxyFactory(_dsFactory);
    supply = 0;
  }

  function totalSupply() public view returns (uint256) {


    return supply;
  }

  function makeChild() internal returns (address payable) {

    return DSFactory.build();
  }

  function mint(uint256 value) public {

    for (uint256 i = 0; i < value; i++) {
      address proxy = address(makeChild());
      s_proxies.push(proxy);
    }
    supply += value;
    s_balances[msg.sender] += value;
  }

  function claim() public returns (bool) {

    return _claim(msg.sender);
  }

  function claimFor(address newOwner) public returns (bool) {

    return _claim(newOwner);
  }

  function _claim(address newOwner) internal returns (bool success) {

    uint256 from_balance = s_balances[msg.sender];
    if (from_balance == 0) {
      return false;
    }


    uint lastPos = s_proxies.length - 1;
    address proxy = s_proxies[lastPos];
    s_proxies.pop();

    IDSProxy(proxy).setOwner(newOwner);

    s_balances[msg.sender] = from_balance - 1;

    supply -= 1;

    return true;
  }
}