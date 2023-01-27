
pragma solidity ^0.5.0;




contract Token {

  function transfer(address to, uint tokens) public returns (bool success);

}

contract Exchange {

  function balanceOf(address token, address user) public view returns (uint);

}

contract DeltaBalances {

    
  address payable public admin; 

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






  function getFunctionSelector(string calldata functionSignature) external pure returns (bytes4) {

    return bytes4(keccak256(abi.encodePacked(functionSignature)));
  }

  function tokenBalances(address user,  address[] calldata tokens) external view returns (uint[] memory balances) {

    balances = new uint[](tokens.length);
    
    for(uint i = 0; i < tokens.length; i++) {
      if(tokens[i] != address(0x0)) { 
        balances[i] = tokenBalance(user, tokens[i]); // check token balance and catch errors
      } else {
        balances[i] = user.balance; // ETH balance    
      }
    }    
    return balances;
  }
  
  function tokenAllowances(address spenderContract, address user, address[] calldata tokens) external view returns (uint[] memory allowances) {

    allowances = new uint[](tokens.length);
    
    for(uint i = 0; i < tokens.length; i++) {
      allowances[i] = tokenAllowance(spenderContract, user, tokens[i]); // check token allowance and catch errors
    }    
    return allowances;
  }


  function depositedBalances(address exchange, address user, address[] calldata tokens) external view returns (uint[] memory balances) {

    balances = new uint[](tokens.length);
    Exchange ex = Exchange(exchange);
    
    for(uint i = 0; i < tokens.length; i++) {
      balances[i] = ex.balanceOf(tokens[i], user); //Errors if exchange does not implement 'balanceOf' correctly, use depositedBalancesGeneric instead.
    }    
    return balances;
  }

  function depositedBalancesGeneric(address exchange, bytes4 selector, address user, address[] calldata tokens, bool userFirst) external view returns (uint[] memory balances) {

    balances = new uint[](tokens.length);
    
    if(userFirst) {
      for(uint i = 0; i < tokens.length; i++) {
        balances[i] = getNumberTwoArgs(exchange, selector, user, tokens[i]);
      } 
    } else {
      for(uint i = 0; i < tokens.length; i++) {
        balances[i] = getNumberTwoArgs(exchange, selector, tokens[i], user);
      } 
    }
    return balances;
  }
  
  function depositedEtherGeneric(address exchange, bytes4 selector, address user) external view returns (uint) {

    return getNumberOneArg(exchange, selector, user);
  }

  


  function tokenBalance(address user, address token) internal view returns (uint) {

    return getNumberOneArg(token, 0x70a08231, user);
  }
  
  
  function tokenAllowance(address spenderContract, address user, address token) internal view returns (uint) {

      return getNumberTwoArgs(token, 0xdd62ed3e, user, spenderContract);
  }
  
  
  
  
  
  function getNumberOneArg(address contractAddr, bytes4 selector, address arg1) internal view returns (uint) {

    if(isAContract(contractAddr)) {
      (bool success, bytes memory result) = contractAddr.staticcall(abi.encodeWithSelector(selector, arg1));
      if(success && result.length == 32) {
        return abi.decode(result, (uint)); // return the result as uint
      } else {
        return 0; // function call failed, return 0
      }
    } else {
      return 0; // not a valid contract, return 0 instead of error
    }
  }
  
  function getNumberTwoArgs(address contractAddr, bytes4 selector, address arg1, address arg2) internal view returns (uint) {

    if(isAContract(contractAddr)) {
      (bool success, bytes memory result) = contractAddr.staticcall(abi.encodeWithSelector(selector, arg1, arg2));
      if(success && result.length == 32) {
        return abi.decode(result, (uint)); // return the result as uint
      } else {
        return 0; // function call failed, return 0
      }
    } else {
      return 0; // not a valid contract, return 0 instead of error
    }
  }
  
  function isAContract(address contractAddr) internal view returns (bool) {

    uint256 codeSize;
    assembly { codeSize := extcodesize(contractAddr) } // contract code size
    return codeSize > 0; 
  }
}