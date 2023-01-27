
pragma solidity ^0.4.25;


contract Exchange {

  function balanceOf(address token, address user) public view returns (uint);

}

contract Token {

  function balanceOf(address tokenOwner) public view returns (uint balance);

  function transfer(address to, uint tokens) public returns (bool success);

  function allowance(address tokenOwner, address spenderContract) public view returns (uint remaining);

}

contract DeltaBalances {

    
  address public admin; 

  constructor() public {
    admin = msg.sender;
  }

  modifier isAdmin() {

    require(msg.sender == admin);
    _;
  }


  function withdraw() external isAdmin {

    admin.transfer(address(this).balance);
  }

  function withdrawToken(address token, uint amount) external isAdmin {

    require(token != address(0x0) && Token(token).transfer(msg.sender, amount));
  }


  function tokenBalances(address user,  address[] tokens) external view returns (uint[]) {

    uint[] memory balances = new uint[](tokens.length);
    
    for(uint i = 0; i < tokens.length; i++) {
      if(tokens[i] != address(0x0)) { 
        balances[i] = tokenBalance(user, tokens[i]); // check token balance and catch errors
      } else {
        balances[i] = user.balance; // ETH balance    
      }
    }    
    return balances;
  }


  function depositedBalances(address exchange, address user, address[] tokens) external view returns (uint[]) {

    Exchange ex = Exchange(exchange);
    uint[] memory balances = new uint[](tokens.length);
    
    for(uint i = 0; i < tokens.length; i++) {
      balances[i] = ex.balanceOf(tokens[i], user); //might error if exchange does not implement balanceOf correctly
    }    
    return balances;
  }

  function tokenAllowances(address spenderContract, address user, address[] tokens) external view returns (uint[]) {

    uint[] memory allowances = new uint[](tokens.length);
    
    for(uint i = 0; i < tokens.length; i++) {
      allowances[i] = tokenAllowance(spenderContract, user, tokens[i]); // check token allowance and catch errors
    }    
    return allowances;
  }


  function tokenBalance(address user, address token) internal view returns (uint) {

    uint256 tokenCode;
    assembly { tokenCode := extcodesize(token) } // contract code size
   
    if(tokenCode > 0 && token.call(0x70a08231, user)) {    // bytes4(keccak256("balanceOf(address)")) == 0x70a08231  
      return Token(token).balanceOf(user);
    } else {
      return 0; // not a valid token, return 0 instead of error
    }
  }
  
  
  function tokenAllowance(address spenderContract, address user, address token) internal view returns (uint) {

    uint256 tokenCode;
    assembly { tokenCode := extcodesize(token) } // contract code size
   
    if(tokenCode > 0 && token.call(0xdd62ed3e, user, spenderContract)) {    // bytes4(keccak256("allowance(address,address)")) == 0xdd62ed3e
      return Token(token).allowance(user, spenderContract);
    } else {
      return 0; // not a valid token, return 0 instead of error
    }
  }
}