

pragma solidity ^0.4.21;

contract Token {

  function balanceOf(address) public view returns (uint);

  function allowance(address,address) public view returns (uint);

}

contract BalanceChecker {

  function() public payable {
    revert("BalanceChecker does not accept payments");
  }

  function tokenBalance(address user, address token) public view returns (uint) {

    uint256 tokenCode;
    assembly { tokenCode := extcodesize(token) } // contract code size
  
    if (tokenCode > 0 && token.call(bytes4(0x70a08231), user)) {  
      return Token(token).balanceOf(user);
    } else {
      return 0;
    }
  }

  function tokenAllowance(address owner, address spender, address token) public view returns (uint) {

    uint256 tokenCode;
    assembly { tokenCode := extcodesize(token) } // contract code size
  
    if (tokenCode > 0 && token.call(bytes4(0xdd62ed3e), owner, spender)) {  
      return Token(token).allowance(owner,spender);
    } else {
      return 0;
    }
  }
  function balances(address[] users, address[] tokens) external view returns (uint[]) {

    uint[] memory addrBalances = new uint[](tokens.length * users.length);
    
    for(uint i = 0; i < users.length; i++) {
      for (uint j = 0; j < tokens.length; j++) {
        uint addrIdx = j + tokens.length * i;
        if (tokens[j] != address(0x0)) { 
          addrBalances[addrIdx] = tokenBalance(users[i], tokens[j]);
        } else {
          addrBalances[addrIdx] = users[i].balance;   
        }
      }  
    }
  
    return addrBalances;
  }
function allowances(address[] users, address spender, address token) external view returns (uint[]) {

    uint[] memory _allowances = new uint[](users.length);
    
    for (uint i = 0; i < users.length; i++) {
        if (token != address(0x0)) { 
            _allowances[i] = tokenAllowance(users[i], spender, token);
        } else {
            _allowances[i] = Token(0x0).allowance(users[i],spender); 
        }
    }  
    return _allowances;
  }
}