
pragma solidity 0.5.1;

contract Token {

  function balanceOf(address) public view returns (uint256);

}

contract BalanceScanner {

  function etherBalances(address[] calldata addresses) external view returns (uint256[] memory balances) {

    balances = new uint256[](addresses.length);

    for (uint256 i = 0; i < addresses.length; i++) {
      balances[i] = addresses[i].balance;
    }
  }

  function tokenBalances(address[] calldata addresses, address token) external view returns (uint256[] memory balances) {

    balances = new uint256[](addresses.length);
    Token tokenContract = Token(token);

    for (uint256 i = 0; i < addresses.length; i++) {
      balances[i] = tokenContract.balanceOf(addresses[i]);
    }
  }

  function tokensBalance(address owner, address[] calldata contracts) external view returns (uint256[] memory balances) {

    balances = new uint256[](contracts.length);

    for(uint256 i = 0; i < contracts.length; i++) {
      uint256 size = codeSize(contracts[i]);

      if(size == 0) {
        balances[i] = 0;
      } else {
        Token tokenContract = Token(contracts[i]);
        balances[i] = tokenContract.balanceOf(owner);
      }
    }
  }

  function codeSize(address _address) internal view returns (uint256 size) {

    assembly {
      size := extcodesize(_address)
    }
  }
}