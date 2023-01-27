
pragma solidity ^0.8.4;


interface TOKEN {

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

}

contract BurnVendor {


  TOKEN public akitaToken;

  uint256 constant public tokensPerEth = 2004150000 * 130 / 100;// 30% discounted!

  uint256 constant public burnMultiplier = 10;

  address payable constant public gitcoinAddress = payable(0xde21F729137C5Af1b01d73aF1dC21eFfa2B8a0d6);

  address constant public burnAddress = 0xDead000000000000000000000000000000000d06;

  constructor(address akitaAddress) {
    akitaToken = TOKEN(akitaAddress);
  }

  receive() external payable {
    buy();
  }

  event Buy(address who, uint256 value, uint256 amount, uint256 burn);

  function buy() public payable {


    uint256 amountOfTokensToBuy = msg.value * tokensPerEth;

    uint256 amountOfTokensToBurn = amountOfTokensToBuy * burnMultiplier;

    akitaToken.transferFrom(gitcoinAddress, burnAddress, amountOfTokensToBurn);

    akitaToken.transferFrom(gitcoinAddress, msg.sender, amountOfTokensToBuy);

    (bool sent, ) = gitcoinAddress.call{value: msg.value}("");
    require(sent, "Failed to send ETH to Gitcoin Multisig");

    emit Buy(msg.sender, msg.value, amountOfTokensToBuy, amountOfTokensToBurn);

  }

}