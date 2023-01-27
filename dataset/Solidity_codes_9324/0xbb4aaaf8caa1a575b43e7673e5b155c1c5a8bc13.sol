
pragma solidity 0.5.1;

contract BalanceScanner {

  function etherBalances(address[] calldata addresses) external view returns (uint256[] memory balances) {

    balances = new uint256[](addresses.length);

    for (uint256 i = 0; i < addresses.length; i++) {
      balances[i] = addresses[i].balance;
    }
  }

  function tokenBalances(address[] calldata addresses, address token) external returns (uint256[] memory balances) {

    balances = new uint256[](addresses.length);

    for (uint256 i = 0; i < addresses.length; i++) {
      balances[i] = tokenBalance(addresses[i], token);
    }
  }

  function tokensBalance(address owner, address[] calldata contracts) external returns (uint256[] memory balances) {

    balances = new uint256[](contracts.length);

    for (uint256 i = 0; i < contracts.length; i++) {
      balances[i] = tokenBalance(owner, contracts[i]);
    }
  }

  function tokenBalance(address owner, address token) internal returns (uint256 balance) {

    balance = 0;
    uint256 size = codeSize(token);

    if (size > 0) {
      (bool success, bytes memory data) = token.call(abi.encodeWithSelector(bytes4(0x70a08231), owner));
      if (success) {
        (balance) = abi.decode(data, (uint256));
      }
    }
  }

  function codeSize(address _address) internal view returns (uint256 size) {

    assembly {
      size := extcodesize(_address)
    }
  }
}