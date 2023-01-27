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
pragma solidity ^0.8.0;

abstract contract VRFConsumerBaseV2 {
  error OnlyCoordinatorCanFulfill(address have, address want);
  address private immutable vrfCoordinator;

  constructor(address _vrfCoordinator) {
    vrfCoordinator = _vrfCoordinator;
  }

  function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal virtual;

  function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external {
    if (msg.sender != vrfCoordinator) {
      revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);
    }
    fulfillRandomWords(requestId, randomWords);
  }
}// MIT
pragma solidity ^0.8.7;


contract RandomNumberConsumerV2 is VRFConsumerBaseV2 {

    VRFCoordinatorV2Interface internal COORDINATOR;
    LinkTokenInterface internal LINK_TOKEN;

    bytes32 immutable s_keyHash;

    uint64 public s_subscriptionId;

    uint32 immutable s_callbackGasLimit = 600000;

    uint16 immutable s_requestConfirmations = 3;

    mapping(string => uint256) private s_requestKeyToRequestId;
    mapping(uint256 => uint256) private s_requestIdToRequestIndex;
    mapping(uint256 => uint256[]) internal s_requestIndexToRandomWords;

    address s_owner;

    uint256 public requestCounter;

    event ReturnedRandomness(uint256[] randomWords);

    constructor(
        address vrfCoordinator,
        address link,
        bytes32 keyHash
    ) VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        LINK_TOKEN = LinkTokenInterface(link);
        s_keyHash = keyHash;
        s_owner = msg.sender;
        createNewSubscription();
    }

    modifier onlyOwner() {

        require(msg.sender == s_owner);
        _;
    }

    function createNewSubscription() private onlyOwner {

        address[] memory consumers = new address[](1);
        consumers[0] = address(this);
        s_subscriptionId = COORDINATOR.createSubscription();
        COORDINATOR.addConsumer(s_subscriptionId, consumers[0]);
    }

    function isVRFContract() external pure returns (bool) {

        return true;
    }

    function requestRandomWords(string memory _requestKey, uint32 _numWords) external onlyOwner {

        require(s_requestKeyToRequestId[_requestKey] == 0, "RequestKey already used");
        uint256 requestId = COORDINATOR.requestRandomWords(
            s_keyHash,
            s_subscriptionId,
            s_requestConfirmations,
            s_callbackGasLimit,
            _numWords
        );
        s_requestKeyToRequestId[_requestKey] = requestId;
        s_requestIdToRequestIndex[requestId] = requestCounter;
        requestCounter += 1;
    }

    function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) internal override {

        uint256 requestIndex = s_requestIdToRequestIndex[_requestId];
        s_requestIndexToRandomWords[requestIndex] = _randomWords;
        emit ReturnedRandomness(_randomWords);
    }

    function cancelSubscription() external {

        COORDINATOR.cancelSubscription(s_subscriptionId, msg.sender);
    }

    function fund(uint96 _amount) public {

        LINK_TOKEN.transferAndCall(
            address(COORDINATOR),
            _amount,
            abi.encode(s_subscriptionId)
        );
    }

    function hasRequestKey(string memory _requestKey) public view returns (bool) {

        return s_requestKeyToRequestId[_requestKey] != 0;
    }

    function getRequestId(string memory _requestKey) public view returns (uint256) {

        return s_requestKeyToRequestId[_requestKey];
    }

    function getRandomWords(string memory _requestKey) public view returns (uint256[] memory) {

        require(hasRequestKey(_requestKey), "Didn't request using the requestKey");
        uint256 requestIndex = s_requestIdToRequestIndex[s_requestKeyToRequestId[_requestKey]];
        require(s_requestIndexToRandomWords[requestIndex].length != 0, "not yet");
        return s_requestIndexToRandomWords[requestIndex];
    }
}