
pragma solidity ^0.8.0;

interface ILight {

  event Swap(
    uint256 indexed nonce,
    uint256 timestamp,
    address indexed signerWallet,
    address signerToken,
    uint256 signerAmount,
    uint256 signerFee,
    address indexed senderWallet,
    address senderToken,
    uint256 senderAmount
  );

  event Cancel(uint256 indexed nonce, address indexed signerWallet);

  event Authorize(address indexed signer, address indexed signerWallet);

  event Revoke(address indexed signer, address indexed signerWallet);

  event SetFee(uint256 indexed signerFee);

  event SetFeeWallet(address indexed feeWallet);

  function swap(
    uint256 nonce,
    uint256 expiry,
    address signerWallet,
    address signerToken,
    uint256 signerAmount,
    address senderToken,
    uint256 senderAmount,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;


  function swapWithRecipient(
    address recipient,
    uint256 nonce,
    uint256 expiry,
    address signerWallet,
    address signerToken,
    uint256 signerAmount,
    address senderToken,
    uint256 senderAmount,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;


  function authorize(address sender) external;


  function revoke() external;


  function cancel(uint256[] calldata nonces) external;


  function nonceUsed(address, uint256) external view returns (bool);


  function authorized(address) external view returns (address);

}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// Apache-2.0

pragma solidity ^0.8.7;


interface IWETH is IERC20 {

  function deposit() external payable;


  function withdraw(uint256) external;

}// MIT

pragma solidity ^0.8.0;


contract Wrapper {

  ILight public lightContract;
  IWETH public wethContract;

  constructor(address _lightContract, address _wethContract) {
    lightContract = ILight(_lightContract);
    wethContract = IWETH(_wethContract);
  }

  receive() external payable {
    if (msg.sender != address(wethContract)) {
      revert("DO_NOT_SEND_ETHER");
    }
  }

  function swap(
    uint256 nonce,
    uint256 expiry,
    address signerWallet,
    address signerToken,
    uint256 signerAmount,
    address senderToken,
    uint256 senderAmount,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) public payable {

    if (senderToken == address(wethContract)) {
      require(senderAmount == msg.value, "VALUE_MUST_BE_SENT");
      wethContract.deposit{value: msg.value}();
    }

    lightContract.swapWithRecipient(
      msg.sender,
      nonce,
      expiry,
      signerWallet,
      signerToken,
      signerAmount,
      senderToken,
      senderAmount,
      v,
      r,
      s
    );

    if (signerToken == address(wethContract)) {
      wethContract.withdraw(signerAmount);
      (bool success, ) = msg.sender.call{value: signerAmount}("");
      require(success, "ETH_RETURN_FAILED");
    }
  }
}