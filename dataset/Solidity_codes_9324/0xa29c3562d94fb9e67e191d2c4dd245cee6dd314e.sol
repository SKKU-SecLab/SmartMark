pragma solidity ^0.8.0;

interface LinkTokenInterface {

  function allowance(address owner, address spender) external view returns (uint256 remaining);


  function approve(address spender, uint256 value) external returns (bool success);


  function balanceOf(address owner) external view returns (uint256 balance);


  function decimals() external view returns (uint8 decimalPlaces);


  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);


  function increaseApproval(address spender, uint256 subtractedValue) external;


  function name() external view returns (string memory tokenName);


  function symbol() external view returns (string memory tokenSymbol);


  function totalSupply() external view returns (uint256 totalTokensIssued);


  function transfer(address to, uint256 value) external returns (bool success);


  function transferAndCall(
    address to,
    uint256 value,
    bytes calldata data
  ) external returns (bool success);


  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool success);

}// MIT
pragma solidity ^0.8.0;

interface VRFCoordinatorV2Interface {

  function getRequestConfig()
    external
    view
    returns (
      uint16,
      uint32,
      bytes32[] memory
    );


  function requestRandomWords(
    bytes32 keyHash,
    uint64 subId,
    uint16 minimumRequestConfirmations,
    uint32 callbackGasLimit,
    uint32 numWords
  ) external returns (uint256 requestId);


  function createSubscription() external returns (uint64 subId);


  function getSubscription(uint64 subId)
    external
    view
    returns (
      uint96 balance,
      uint64 reqCount,
      address owner,
      address[] memory consumers
    );


  function requestSubscriptionOwnerTransfer(uint64 subId, address newOwner) external;


  function acceptSubscriptionOwnerTransfer(uint64 subId) external;


  function addConsumer(uint64 subId, address consumer) external;


  function removeConsumer(uint64 subId, address consumer) external;


  function cancelSubscription(uint64 subId, address to) external;

}// MIT
pragma solidity ^0.8.14;


contract PvSubscriptionManager {

  VRFCoordinatorV2Interface immutable COORDINATOR;
  LinkTokenInterface immutable LINKTOKEN;

  uint64 public s_subscriptionId;
  address s_owner;

  constructor(
    address _vrfCoordinator,
    address _linkToken
  ) {
    COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);
    LINKTOKEN = LinkTokenInterface(_linkToken);

    s_owner = msg.sender;
    
    s_subscriptionId = COORDINATOR.createSubscription();
  }

  function topUpSubscription(uint256 amount) external onlyOwner {

    LINKTOKEN.transferAndCall(address(COORDINATOR), amount, abi.encode(s_subscriptionId));
  }

  function addConsumer(address consumerAddress) external onlyOwner {

    COORDINATOR.addConsumer(s_subscriptionId, consumerAddress);
  }

  function removeConsumer(address consumerAddress) external onlyOwner {

    COORDINATOR.removeConsumer(s_subscriptionId, consumerAddress);
  }

  function cancelSubscription(address receivingWallet) external onlyOwner {

    COORDINATOR.cancelSubscription(s_subscriptionId, receivingWallet);
    s_subscriptionId = 0;
  }

  function withdraw(uint256 amount, address to) external onlyOwner {

    LINKTOKEN.transfer(to, amount);
  }

  function getSubscription() external view returns (
      uint96 balance,
      uint64 reqCount,
      address owner,
      address[] memory consumers
  ) {

      return COORDINATOR.getSubscription(s_subscriptionId);
  }

  modifier onlyOwner() {

    require(msg.sender == s_owner);
    _;
  }
}