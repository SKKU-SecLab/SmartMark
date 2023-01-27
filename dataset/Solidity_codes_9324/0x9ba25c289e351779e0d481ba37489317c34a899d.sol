

pragma solidity ^0.6.11;

interface IMessageProvider {

  event InboxMessageDelivered(uint256 indexed messageNum, bytes data);

  event InboxMessageDeliveredFromOrigin(uint256 indexed messageNum);
}// Apache-2.0


pragma solidity ^0.6.11;


interface IInbox is IMessageProvider {

  function sendL2Message(bytes calldata messageData) external returns (uint256);


  function sendUnsignedTransaction(
    uint256 maxGas,
    uint256 gasPriceBid,
    uint256 nonce,
    address destAddr,
    uint256 amount,
    bytes calldata data
  ) external returns (uint256);


  function sendContractTransaction(
    uint256 maxGas,
    uint256 gasPriceBid,
    address destAddr,
    uint256 amount,
    bytes calldata data
  ) external returns (uint256);


  function sendL1FundedUnsignedTransaction(
    uint256 maxGas,
    uint256 gasPriceBid,
    uint256 nonce,
    address destAddr,
    bytes calldata data
  ) external payable returns (uint256);


  function sendL1FundedContractTransaction(
    uint256 maxGas,
    uint256 gasPriceBid,
    address destAddr,
    bytes calldata data
  ) external payable returns (uint256);


  function createRetryableTicket(
    address destAddr,
    uint256 arbTxCallValue,
    uint256 maxSubmissionCost,
    address submissionRefundAddress,
    address valueRefundAddress,
    uint256 maxGas,
    uint256 gasPriceBid,
    bytes calldata data
  ) external payable returns (uint256);


  function createRetryableTicketNoRefundAliasRewrite(
    address destAddr,
    uint256 arbTxCallValue,
    uint256 maxSubmissionCost,
    address submissionRefundAddress,
    address valueRefundAddress,
    uint256 maxGas,
    uint256 gasPriceBid,
    bytes calldata data
  ) external payable returns (uint256);


  function depositEth(uint256 maxSubmissionCost) external payable returns (uint256);


  function bridge() external view returns (address);


  function pauseCreateRetryables() external;


  function unpauseCreateRetryables() external;


  function startRewriteAddress() external;


  function stopRewriteAddress() external;

}// Apache-2.0


pragma solidity ^0.6.11;

interface IBridge {

  event MessageDelivered(
    uint256 indexed messageIndex,
    bytes32 indexed beforeInboxAcc,
    address inbox,
    uint8 kind,
    address sender,
    bytes32 messageDataHash
  );

  event BridgeCallTriggered(
    address indexed outbox,
    address indexed destAddr,
    uint256 amount,
    bytes data
  );

  event InboxToggle(address indexed inbox, bool enabled);

  event OutboxToggle(address indexed outbox, bool enabled);

  function deliverMessageToInbox(
    uint8 kind,
    address sender,
    bytes32 messageDataHash
  ) external payable returns (uint256);


  function executeCall(
    address destAddr,
    uint256 amount,
    bytes calldata data
  ) external returns (bool success, bytes memory returnData);


  function setInbox(address inbox, bool enabled) external;


  function setOutbox(address inbox, bool enabled) external;



  function activeOutbox() external view returns (address);


  function allowedInboxes(address inbox) external view returns (bool);


  function allowedOutboxes(address outbox) external view returns (bool);


  function inboxAccs(uint256 index) external view returns (bytes32);


  function messageCount() external view returns (uint256);

}// Apache-2.0


pragma solidity ^0.6.11;

interface IOutbox {

  event OutboxEntryCreated(
    uint256 indexed batchNum,
    uint256 outboxEntryIndex,
    bytes32 outputRoot,
    uint256 numInBatch
  );
  event OutBoxTransactionExecuted(
    address indexed destAddr,
    address indexed l2Sender,
    uint256 indexed outboxEntryIndex,
    uint256 transactionIndex
  );

  function l2ToL1Sender() external view returns (address);


  function l2ToL1Block() external view returns (uint256);


  function l2ToL1EthBlock() external view returns (uint256);


  function l2ToL1Timestamp() external view returns (uint256);


  function l2ToL1BatchNum() external view returns (uint256);


  function l2ToL1OutputId() external view returns (bytes32);


  function processOutgoingMessages(bytes calldata sendsData, uint256[] calldata sendLengths)
    external;


  function outboxEntryExists(uint256 batchNum) external view returns (bool);

}// AGPL-3.0-or-later

pragma solidity ^0.6.11;


abstract contract L1CrossDomainEnabled {
  IInbox public immutable inbox;

  event TxToL2(address indexed from, address indexed to, uint256 indexed seqNum, bytes data);

  constructor(address _inbox) public {
    inbox = IInbox(_inbox);
  }

  modifier onlyL2Counterpart(address l2Counterpart) {
    address bridge = inbox.bridge();
    require(msg.sender == bridge, "NOT_FROM_BRIDGE");

    address l2ToL1Sender = IOutbox(IBridge(bridge).activeOutbox()).l2ToL1Sender();
    require(l2ToL1Sender == l2Counterpart, "ONLY_COUNTERPART_GATEWAY");
    _;
  }

  function sendTxToL2(
    address target,
    address user,
    uint256 maxSubmissionCost,
    uint256 maxGas,
    uint256 gasPriceBid,
    bytes memory data
  ) internal returns (uint256) {
    uint256 seqNum = inbox.createRetryableTicket{value: msg.value}(
      target,
      0, // we always assume that l2CallValue = 0
      maxSubmissionCost,
      user,
      user,
      maxGas,
      gasPriceBid,
      data
    );
    emit TxToL2(user, target, seqNum, data);
    return seqNum;
  }

  function sendTxToL2NoAliasing(
    address target,
    address user,
    uint256 l1CallValue,
    uint256 maxSubmissionCost,
    uint256 maxGas,
    uint256 gasPriceBid,
    bytes memory data
  ) internal returns (uint256) {
    uint256 seqNum = inbox.createRetryableTicketNoRefundAliasRewrite{value: l1CallValue}(
      target,
      0, // we always assume that l2CallValue = 0
      maxSubmissionCost,
      user,
      user,
      maxGas,
      gasPriceBid,
      data
    );
    emit TxToL2(user, target, seqNum, data);
    return seqNum;
  }
}pragma solidity >=0.4.21 <0.7.0;

interface ArbSys {

  function arbOSVersion() external pure returns (uint256);


  function arbChainID() external view returns (uint256);


  function arbBlockNumber() external view returns (uint256);


  function withdrawEth(address destination) external payable returns (uint256);


  function sendTxToL1(address destination, bytes calldata calldataForL1)
    external
    payable
    returns (uint256);


  function getTransactionCount(address account) external view returns (uint256);


  function getStorageAt(address account, uint256 index) external view returns (uint256);


  function isTopLevelCall() external view returns (bool);


  event EthWithdrawal(address indexed destAddr, uint256 amount);

  event L2ToL1Transaction(
    address caller,
    address indexed destination,
    uint256 indexed uniqueId,
    uint256 indexed batchNumber,
    uint256 indexInBatch,
    uint256 arbBlockNum,
    uint256 ethBlockNum,
    uint256 timestamp,
    uint256 callvalue,
    bytes data
  );
}// AGPL-3.0-or-later

pragma solidity ^0.6.11;


abstract contract L2CrossDomainEnabled {
  event TxToL1(address indexed from, address indexed to, uint256 indexed id, bytes data);

  function sendTxToL1(
    address user,
    address to,
    bytes memory data
  ) internal returns (uint256) {
    uint256 id = ArbSys(address(100)).sendTxToL1(to, data);

    emit TxToL1(user, to, id, data);

    return id;
  }

  modifier onlyL1Counterpart(address l1Counterpart) {
    require(msg.sender == applyL1ToL2Alias(l1Counterpart), "ONLY_COUNTERPART_GATEWAY");
    _;
  }

  uint160 constant offset = uint160(0x1111000000000000000000000000000000001111);

  function applyL1ToL2Alias(address l1Address) internal pure returns (address l2Address) {
    l2Address = address(uint160(l1Address) + offset);
  }
}// AGPL-3.0-or-later

pragma solidity ^0.6.11;



contract L2GovernanceRelay is L2CrossDomainEnabled {

  address public immutable l1GovernanceRelay;

  constructor(address _l1GovernanceRelay) public {
    l1GovernanceRelay = _l1GovernanceRelay;
  }

  receive() external payable {}

  function relay(address target, bytes calldata targetData)
    external
    onlyL1Counterpart(l1GovernanceRelay)
  {

    (bool ok, ) = target.delegatecall(targetData);
    require(ok, "L2GovernanceRelay/delegatecall-error");
  }
}// AGPL-3.0-or-later

pragma solidity ^0.6.11;




contract L1GovernanceRelay is L1CrossDomainEnabled {

  mapping(address => uint256) public wards;

  function rely(address usr) external auth {

    wards[usr] = 1;
    emit Rely(usr);
  }

  function deny(address usr) external auth {

    wards[usr] = 0;
    emit Deny(usr);
  }

  modifier auth() {

    require(wards[msg.sender] == 1, "L1GovernanceRelay/not-authorized");
    _;
  }

  address public immutable l2GovernanceRelay;

  event Rely(address indexed usr);
  event Deny(address indexed usr);

  constructor(address _inbox, address _l2GovernanceRelay) public L1CrossDomainEnabled(_inbox) {
    wards[msg.sender] = 1;
    emit Rely(msg.sender);

    l2GovernanceRelay = _l2GovernanceRelay;
  }

  receive() external payable {}

  function reclaim(address receiver, uint256 amount) external auth {

    (bool sent, ) = receiver.call{value: amount}("");
    require(sent, "L1GovernanceRelay/failed-to-send-ether");
  }

  function relay(
    address target,
    bytes calldata targetData,
    uint256 l1CallValue,
    uint256 maxGas,
    uint256 gasPriceBid,
    uint256 maxSubmissionCost
  ) external payable auth {

    bytes memory data = abi.encodeWithSelector(
      L2GovernanceRelay.relay.selector,
      target,
      targetData
    );

    sendTxToL2NoAliasing(
      l2GovernanceRelay,
      l2GovernanceRelay, // send any excess ether to the L2 counterpart
      l1CallValue,
      maxSubmissionCost,
      maxGas,
      gasPriceBid,
      data
    );
  }
}