

pragma solidity ^0.6.11;

interface ICloneable {

    function isMaster() external view returns (bool);

}// Apache-2.0


pragma solidity ^0.6.11;


contract Cloneable is ICloneable {

    string private constant NOT_CLONE = "NOT_CLONE";

    bool private isMasterCopy;

    constructor() public {
        isMasterCopy = true;
    }

    function isMaster() external view override returns (bool) {

        return isMasterCopy;
    }

    function safeSelfDestruct(address payable dest) internal {

        require(!isMasterCopy, NOT_CLONE);
        selfdestruct(dest);
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
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

interface ISequencerInbox {

    event SequencerBatchDelivered(
        uint256 indexed firstMessageNum,
        bytes32 indexed beforeAcc,
        uint256 newMessageCount,
        bytes32 afterAcc,
        bytes transactions,
        uint256[] lengths,
        uint256[] sectionsMetadata,
        uint256 seqBatchIndex,
        address sequencer
    );

    event SequencerBatchDeliveredFromOrigin(
        uint256 indexed firstMessageNum,
        bytes32 indexed beforeAcc,
        uint256 newMessageCount,
        bytes32 afterAcc,
        uint256 seqBatchIndex
    );

    event DelayedInboxForced(
        uint256 indexed firstMessageNum,
        bytes32 indexed beforeAcc,
        uint256 newMessageCount,
        uint256 totalDelayedMessagesRead,
        bytes32[2] afterAccAndDelayed,
        uint256 seqBatchIndex
    );


    event IsSequencerUpdated(address addr, bool isSequencer);
    event MaxDelayUpdated(uint256 newMaxDelayBlocks, uint256 newMaxDelaySeconds);


    function setMaxDelay(uint256 newMaxDelayBlocks, uint256 newMaxDelaySeconds) external;


    function setIsSequencer(address addr, bool isSequencer) external;


    function messageCount() external view returns (uint256);


    function maxDelayBlocks() external view returns (uint256);


    function maxDelaySeconds() external view returns (uint256);


    function inboxAccs(uint256 index) external view returns (bytes32);


    function getInboxAccsLength() external view returns (uint256);


    function proveInboxContainsMessage(bytes calldata proof, uint256 inboxCount)
        external
        view
        returns (uint256, bytes32);


    function sequencer() external view returns (address);


    function isSequencer(address seq) external view returns (bool);

}// Apache-2.0


pragma solidity ^0.6.11;


interface IOneStepProof {

    function executeStep(
        address[2] calldata bridges,
        uint256 initialMessagesRead,
        bytes32[2] calldata accs,
        bytes calldata proof,
        bytes calldata bproof
    )
        external
        view
        returns (
            uint64 gas,
            uint256 afterMessagesRead,
            bytes32[4] memory fields
        );


    function executeStepDebug(
        address[2] calldata bridges,
        uint256 initialMessagesRead,
        bytes32[2] calldata accs,
        bytes calldata proof,
        bytes calldata bproof
    ) external view returns (string memory startMachine, string memory afterMachine);

}// Apache-2.0


pragma solidity ^0.6.11;


interface IChallenge {

    function initializeChallenge(
        IOneStepProof[] calldata _executors,
        address _resultReceiver,
        bytes32 _executionHash,
        uint256 _maxMessageCount,
        address _asserter,
        address _challenger,
        uint256 _asserterTimeLeft,
        uint256 _challengerTimeLeft,
        ISequencerInbox _sequencerBridge,
        IBridge _delayedBridge
    ) external;


    function currentResponderTimeLeft() external view returns (uint256);


    function lastMoveBlock() external view returns (uint256);


    function timeout() external;


    function asserter() external view returns (address);


    function challenger() external view returns (address);


    function clearChallenge() external;

}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Proxy {
    function _delegate(address implementation) internal virtual {
        assembly {
            calldatacopy(0, 0, calldatasize())

            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    function _implementation() internal view virtual returns (address);

    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    fallback () external payable virtual {
        _fallback();
    }

    receive () external payable virtual {
        _fallback();
    }

    function _beforeFallback() internal virtual {
    }
}// MIT

pragma solidity >=0.6.2 <0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// Apache-2.0


pragma solidity ^0.6.11;

interface INode {

    function initialize(
        address _rollup,
        bytes32 _stateHash,
        bytes32 _challengeHash,
        bytes32 _confirmData,
        uint256 _prev,
        uint256 _deadlineBlock
    ) external;


    function destroy() external;


    function addStaker(address staker) external returns (uint256);


    function removeStaker(address staker) external;


    function childCreated(uint256) external;


    function newChildConfirmDeadline(uint256 deadline) external;


    function stateHash() external view returns (bytes32);


    function challengeHash() external view returns (bytes32);


    function confirmData() external view returns (bytes32);


    function prev() external view returns (uint256);


    function deadlineBlock() external view returns (uint256);


    function noChildConfirmedBeforeBlock() external view returns (uint256);


    function stakerCount() external view returns (uint256);


    function stakers(address staker) external view returns (bool);


    function firstChildBlock() external view returns (uint256);


    function latestChildNumber() external view returns (uint256);


    function requirePastDeadline() external view;


    function requirePastChildConfirmDeadline() external view;

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


    function executeTransaction(
        uint256 outboxIndex,
        bytes32[] calldata proof,
        uint256 index,
        address l2Sender,
        address destAddr,
        uint256 l2Block,
        uint256 l1Block,
        uint256 l2Timestamp,
        uint256 amount,
        bytes calldata calldataForL1) external;

}// Apache-2.0


pragma solidity ^0.6.11;


interface IRollupUser {

    function initialize(address _stakeToken) external;


    function completeChallenge(address winningStaker, address losingStaker) external;


    function returnOldDeposit(address stakerAddress) external;


    function requireUnresolved(uint256 nodeNum) external view;


    function requireUnresolvedExists() external view;


    function countStakedZombies(INode node) external view returns (uint256);

}

interface IRollupAdmin {

    event OwnerFunctionCalled(uint256 indexed id);

    function setOutbox(IOutbox _outbox) external;


    function removeOldOutbox(address _outbox) external;


    function setInbox(address _inbox, bool _enabled) external;


    function pause() external;


    function resume() external;


    function setFacets(address newAdminFacet, address newUserFacet) external;


    function setValidator(address[] memory _validator, bool[] memory _val) external;


    function setOwner(address newOwner) external;


    function setMinimumAssertionPeriod(uint256 newPeriod) external;


    function setConfirmPeriodBlocks(uint256 newConfirmPeriod) external;


    function setExtraChallengeTimeBlocks(uint256 newExtraTimeBlocks) external;


    function setAvmGasSpeedLimitPerBlock(uint256 newAvmGasSpeedLimitPerBlock) external;


    function setBaseStake(uint256 newBaseStake) external;


    function setStakeToken(address newStakeToken) external;


    function setSequencerInboxMaxDelay(
        uint256 newSequencerInboxMaxDelayBlocks,
        uint256 newSequencerInboxMaxDelaySeconds
    ) external;


    function setChallengeExecutionBisectionDegree(uint256 newChallengeExecutionBisectionDegree)
        external;


    function updateWhitelistConsumers(
        address whitelist,
        address newWhitelist,
        address[] memory targets
    ) external;


    function setWhitelistEntries(
        address whitelist,
        address[] memory user,
        bool[] memory val
    ) external;


    function setIsSequencer(address newSequencer, bool isSequencer) external;


    function upgradeBeacon(address beacon, address newImplementation) external;


    function forceResolveChallenge(address[] memory stackerA, address[] memory stackerB) external;


    function forceRefundStaker(address[] memory stacker) external;


    function forceCreateNode(
        bytes32 expectedNodeHash,
        bytes32[3][2] calldata assertionBytes32Fields,
        uint256[4][2] calldata assertionIntFields,
        bytes calldata sequencerBatchProof,
        uint256 beforeProposedBlock,
        uint256 beforeInboxMaxCount,
        uint256 prevNode
    ) external;


    function forceConfirmNode(
        uint256 nodeNum,
        bytes32 beforeSendAcc,
        bytes calldata sendsData,
        uint256[] calldata sendLengths,
        uint256 afterSendCount,
        bytes32 afterLogAcc,
        uint256 afterLogCount
    ) external;

}// Apache-2.0


pragma solidity ^0.6.11;

interface IMessageProvider {

    event InboxMessageDelivered(uint256 indexed messageNum, bytes data);

    event InboxMessageDeliveredFromOrigin(uint256 indexed messageNum);
}// Apache-2.0


pragma solidity ^0.6.11;



contract RollupEventBridge is IMessageProvider, Cloneable {

    uint8 internal constant INITIALIZATION_MSG_TYPE = 11;
    uint8 internal constant ROLLUP_PROTOCOL_EVENT_TYPE = 8;

    uint8 internal constant CREATE_NODE_EVENT = 0;
    uint8 internal constant CONFIRM_NODE_EVENT = 1;
    uint8 internal constant REJECT_NODE_EVENT = 2;
    uint8 internal constant STAKE_CREATED_EVENT = 3;

    IBridge bridge;
    address rollup;

    modifier onlyRollup() {

        require(msg.sender == rollup, "ONLY_ROLLUP");
        _;
    }

    function initialize(address _bridge, address _rollup) external {

        require(rollup == address(0), "ALREADY_INIT");
        bridge = IBridge(_bridge);
        rollup = _rollup;
    }

    function rollupInitialized(
        uint256 confirmPeriodBlocks,
        uint256 avmGasSpeedLimitPerBlock,
        address owner,
        bytes calldata extraConfig
    ) external onlyRollup {

        bytes memory initMsg = abi.encodePacked(
            keccak256("ChallengePeriodEthBlocks"),
            confirmPeriodBlocks,
            keccak256("SpeedLimitPerSecond"),
            avmGasSpeedLimitPerBlock / 100, // convert avm gas to arbgas
            keccak256("ChainOwner"),
            uint256(uint160(bytes20(owner))),
            extraConfig
        );
        uint256 num = bridge.deliverMessageToInbox(
            INITIALIZATION_MSG_TYPE,
            address(0),
            keccak256(initMsg)
        );
        emit InboxMessageDelivered(num, initMsg);
    }

    function nodeCreated(
        uint256 nodeNum,
        uint256 prev,
        uint256 deadline,
        address asserter
    ) external onlyRollup {

        deliverToBridge(
            abi.encodePacked(
                CREATE_NODE_EVENT,
                nodeNum,
                prev,
                block.number,
                deadline,
                uint256(uint160(bytes20(asserter)))
            )
        );
    }

    function nodeConfirmed(uint256 nodeNum) external onlyRollup {

        deliverToBridge(abi.encodePacked(CONFIRM_NODE_EVENT, nodeNum));
    }

    function nodeRejected(uint256 nodeNum) external onlyRollup {

        deliverToBridge(abi.encodePacked(REJECT_NODE_EVENT, nodeNum));
    }

    function stakeCreated(address staker, uint256 nodeNum) external onlyRollup {

        deliverToBridge(
            abi.encodePacked(
                STAKE_CREATED_EVENT,
                uint256(uint160(bytes20(staker))),
                nodeNum,
                block.number
            )
        );
    }

    function deliverToBridge(bytes memory message) private {

        emit InboxMessageDelivered(
            bridge.deliverMessageToInbox(
                ROLLUP_PROTOCOL_EVENT_TYPE,
                msg.sender,
                keccak256(message)
            ),
            message
        );
    }
}// Apache-2.0


pragma solidity ^0.6.11;


interface IRollupCore {

    function _stakerMap(address stakerAddress)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            address,
            bool
        );


    event RollupCreated(bytes32 machineHash);

    event NodeCreated(
        uint256 indexed nodeNum,
        bytes32 indexed parentNodeHash,
        bytes32 nodeHash,
        bytes32 executionHash,
        uint256 inboxMaxCount,
        uint256 afterInboxBatchEndCount,
        bytes32 afterInboxBatchAcc,
        bytes32[3][2] assertionBytes32Fields,
        uint256[4][2] assertionIntFields
    );

    event NodeConfirmed(
        uint256 indexed nodeNum,
        bytes32 afterSendAcc,
        uint256 afterSendCount,
        bytes32 afterLogAcc,
        uint256 afterLogCount
    );

    event NodeRejected(uint256 indexed nodeNum);

    event RollupChallengeStarted(
        address indexed challengeContract,
        address asserter,
        address challenger,
        uint256 challengedNode
    );

    event UserStakeUpdated(address indexed user, uint256 initialBalance, uint256 finalBalance);

    event UserWithdrawableFundsUpdated(
        address indexed user,
        uint256 initialBalance,
        uint256 finalBalance
    );

    function getNode(uint256 nodeNum) external view returns (INode);


    function getStakerAddress(uint256 stakerNum) external view returns (address);


    function isStaked(address staker) external view returns (bool);


    function latestStakedNode(address staker) external view returns (uint256);


    function currentChallenge(address staker) external view returns (address);


    function amountStaked(address staker) external view returns (uint256);


    function zombieAddress(uint256 zombieNum) external view returns (address);


    function zombieLatestStakedNode(uint256 zombieNum) external view returns (uint256);


    function zombieCount() external view returns (uint256);


    function isZombie(address staker) external view returns (bool);


    function withdrawableFunds(address owner) external view returns (uint256);


    function firstUnresolvedNode() external view returns (uint256);


    function latestConfirmed() external view returns (uint256);


    function latestNodeCreated() external view returns (uint256);


    function lastStakeBlock() external view returns (uint256);


    function stakerCount() external view returns (uint256);


    function getNodeHash(uint256 index) external view returns (bytes32);

}// Apache-2.0


pragma solidity ^0.6.11;

library MerkleLib {

    function generateRoot(bytes32[] memory _hashes) internal pure returns (bytes32) {

        bytes32[] memory prevLayer = _hashes;
        while (prevLayer.length > 1) {
            bytes32[] memory nextLayer = new bytes32[]((prevLayer.length + 1) / 2);
            for (uint256 i = 0; i < nextLayer.length; i++) {
                if (2 * i + 1 < prevLayer.length) {
                    nextLayer[i] = keccak256(
                        abi.encodePacked(prevLayer[2 * i], prevLayer[2 * i + 1])
                    );
                } else {
                    nextLayer[i] = prevLayer[2 * i];
                }
            }
            prevLayer = nextLayer;
        }
        return prevLayer[0];
    }

    function calculateRoot(
        bytes32[] memory nodes,
        uint256 route,
        bytes32 item
    ) internal pure returns (bytes32) {

        uint256 proofItems = nodes.length;
        require(proofItems <= 256);
        bytes32 h = item;
        for (uint256 i = 0; i < proofItems; i++) {
            if (route % 2 == 0) {
                h = keccak256(abi.encodePacked(nodes[i], h));
            } else {
                h = keccak256(abi.encodePacked(h, nodes[i]));
            }
            route /= 2;
        }
        return h;
    }
}// Apache-2.0


pragma solidity ^0.6.11;


library ChallengeLib {

    using SafeMath for uint256;

    function firstSegmentSize(uint256 totalCount, uint256 bisectionCount)
        internal
        pure
        returns (uint256)
    {

        return totalCount / bisectionCount + (totalCount % bisectionCount);
    }

    function otherSegmentSize(uint256 totalCount, uint256 bisectionCount)
        internal
        pure
        returns (uint256)
    {

        return totalCount / bisectionCount;
    }

    function bisectionChunkHash(
        uint256 _segmentStart,
        uint256 _segmentLength,
        bytes32 _startHash,
        bytes32 _endHash
    ) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked(_segmentStart, _segmentLength, _startHash, _endHash));
    }

    function assertionHash(uint256 _avmGasUsed, bytes32 _restHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked(_avmGasUsed, _restHash));
    }

    function assertionRestHash(
        uint256 _totalMessagesRead,
        bytes32 _machineState,
        bytes32 _sendAcc,
        uint256 _sendCount,
        bytes32 _logAcc,
        uint256 _logCount
    ) internal pure returns (bytes32) {

        return
            keccak256(
                abi.encodePacked(
                    _totalMessagesRead,
                    _machineState,
                    _sendAcc,
                    _sendCount,
                    _logAcc,
                    _logCount
                )
            );
    }

    function updatedBisectionRoot(
        bytes32[] memory _chainHashes,
        uint256 _challengedSegmentStart,
        uint256 _challengedSegmentLength
    ) internal pure returns (bytes32) {

        uint256 bisectionCount = _chainHashes.length - 1;
        bytes32[] memory hashes = new bytes32[](bisectionCount);
        uint256 chunkSize = ChallengeLib.firstSegmentSize(_challengedSegmentLength, bisectionCount);
        uint256 segmentStart = _challengedSegmentStart;
        hashes[0] = ChallengeLib.bisectionChunkHash(
            segmentStart,
            chunkSize,
            _chainHashes[0],
            _chainHashes[1]
        );
        segmentStart = segmentStart.add(chunkSize);
        chunkSize = ChallengeLib.otherSegmentSize(_challengedSegmentLength, bisectionCount);
        for (uint256 i = 1; i < bisectionCount; i++) {
            hashes[i] = ChallengeLib.bisectionChunkHash(
                segmentStart,
                chunkSize,
                _chainHashes[i],
                _chainHashes[i + 1]
            );
            segmentStart = segmentStart.add(chunkSize);
        }
        return MerkleLib.generateRoot(hashes);
    }

    function verifySegmentProof(
        bytes32 challengeState,
        bytes32 item,
        bytes32[] calldata _merkleNodes,
        uint256 _merkleRoute
    ) internal pure returns (bool) {

        return challengeState == MerkleLib.calculateRoot(_merkleNodes, _merkleRoute, item);
    }
}// Apache-2.0


pragma solidity ^0.6.11;



library RollupLib {

    using SafeMath for uint256;

    struct Config {
        bytes32 machineHash;
        uint256 confirmPeriodBlocks;
        uint256 extraChallengeTimeBlocks;
        uint256 avmGasSpeedLimitPerBlock;
        uint256 baseStake;
        address stakeToken;
        address owner;
        address sequencer;
        uint256 sequencerDelayBlocks;
        uint256 sequencerDelaySeconds;
        bytes extraConfig;
    }

    struct ExecutionState {
        uint256 gasUsed;
        bytes32 machineHash;
        uint256 inboxCount;
        uint256 sendCount;
        uint256 logCount;
        bytes32 sendAcc;
        bytes32 logAcc;
        uint256 proposedBlock;
        uint256 inboxMaxCount;
    }

    function stateHash(ExecutionState memory execState) internal pure returns (bytes32) {

        return
            keccak256(
                abi.encodePacked(
                    execState.gasUsed,
                    execState.machineHash,
                    execState.inboxCount,
                    execState.sendCount,
                    execState.logCount,
                    execState.sendAcc,
                    execState.logAcc,
                    execState.proposedBlock,
                    execState.inboxMaxCount
                )
            );
    }

    struct Assertion {
        ExecutionState beforeState;
        ExecutionState afterState;
    }

    function decodeExecutionState(
        bytes32[3] memory bytes32Fields,
        uint256[4] memory intFields,
        uint256 proposedBlock,
        uint256 inboxMaxCount
    ) internal pure returns (ExecutionState memory) {

        return
            ExecutionState(
                intFields[0],
                bytes32Fields[0],
                intFields[1],
                intFields[2],
                intFields[3],
                bytes32Fields[1],
                bytes32Fields[2],
                proposedBlock,
                inboxMaxCount
            );
    }

    function decodeAssertion(
        bytes32[3][2] memory bytes32Fields,
        uint256[4][2] memory intFields,
        uint256 beforeProposedBlock,
        uint256 beforeInboxMaxCount,
        uint256 inboxMaxCount
    ) internal view returns (Assertion memory) {

        return
            Assertion(
                decodeExecutionState(
                    bytes32Fields[0],
                    intFields[0],
                    beforeProposedBlock,
                    beforeInboxMaxCount
                ),
                decodeExecutionState(bytes32Fields[1], intFields[1], block.number, inboxMaxCount)
            );
    }

    function executionStateChallengeHash(ExecutionState memory state)
        internal
        pure
        returns (bytes32)
    {

        return
            ChallengeLib.assertionHash(
                state.gasUsed,
                ChallengeLib.assertionRestHash(
                    state.inboxCount,
                    state.machineHash,
                    state.sendAcc,
                    state.sendCount,
                    state.logAcc,
                    state.logCount
                )
            );
    }

    function executionHash(Assertion memory assertion) internal pure returns (bytes32) {

        return
            ChallengeLib.bisectionChunkHash(
                assertion.beforeState.gasUsed,
                assertion.afterState.gasUsed - assertion.beforeState.gasUsed,
                RollupLib.executionStateChallengeHash(assertion.beforeState),
                RollupLib.executionStateChallengeHash(assertion.afterState)
            );
    }

    function assertionGasUsed(RollupLib.Assertion memory assertion)
        internal
        pure
        returns (uint256)
    {

        return assertion.afterState.gasUsed.sub(assertion.beforeState.gasUsed);
    }

    function challengeRoot(
        Assertion memory assertion,
        bytes32 assertionExecHash,
        uint256 blockProposed
    ) internal pure returns (bytes32) {

        return challengeRootHash(assertionExecHash, blockProposed, assertion.afterState.inboxCount);
    }

    function challengeRootHash(
        bytes32 execution,
        uint256 proposedTime,
        uint256 maxMessageCount
    ) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked(execution, proposedTime, maxMessageCount));
    }

    function confirmHash(Assertion memory assertion) internal pure returns (bytes32) {

        return
            confirmHash(
                assertion.beforeState.sendAcc,
                assertion.afterState.sendAcc,
                assertion.afterState.logAcc,
                assertion.afterState.sendCount,
                assertion.afterState.logCount
            );
    }

    function confirmHash(
        bytes32 beforeSendAcc,
        bytes32 afterSendAcc,
        bytes32 afterLogAcc,
        uint256 afterSendCount,
        uint256 afterLogCount
    ) internal pure returns (bytes32) {

        return
            keccak256(
                abi.encodePacked(
                    beforeSendAcc,
                    afterSendAcc,
                    afterSendCount,
                    afterLogAcc,
                    afterLogCount
                )
            );
    }

    function feedAccumulator(
        bytes memory messageData,
        uint256[] memory messageLengths,
        bytes32 beforeAcc
    ) internal pure returns (bytes32) {

        uint256 offset = 0;
        uint256 messageCount = messageLengths.length;
        uint256 dataLength = messageData.length;
        bytes32 messageAcc = beforeAcc;
        for (uint256 i = 0; i < messageCount; i++) {
            uint256 messageLength = messageLengths[i];
            require(offset + messageLength <= dataLength, "DATA_OVERRUN");
            bytes32 messageHash;
            assembly {
                messageHash := keccak256(add(messageData, add(offset, 32)), messageLength)
            }
            messageAcc = keccak256(abi.encodePacked(messageAcc, messageHash));
            offset += messageLength;
        }
        require(offset == dataLength, "DATA_LENGTH");
        return messageAcc;
    }

    function nodeHash(
        bool hasSibling,
        bytes32 lastHash,
        bytes32 assertionExecHash,
        bytes32 inboxAcc
    ) internal pure returns (bytes32) {

        uint8 hasSiblingInt = hasSibling ? 1 : 0;
        return keccak256(abi.encodePacked(hasSiblingInt, lastHash, assertionExecHash, inboxAcc));
    }
}// Apache-2.0


pragma solidity ^0.6.11;

interface INodeFactory {

    function createNode(
        bytes32 _stateHash,
        bytes32 _challengeHash,
        bytes32 _confirmData,
        uint256 _prev,
        uint256 _deadlineBlock
    ) external returns (address);

}// Apache-2.0


pragma solidity ^0.6.11;



contract RollupCore is IRollupCore {

    using SafeMath for uint256;

    struct Zombie {
        address stakerAddress;
        uint256 latestStakedNode;
    }

    struct Staker {
        uint256 index;
        uint256 latestStakedNode;
        uint256 amountStaked;
        address currentChallenge;
        bool isStaked;
    }

    uint256 private _latestConfirmed;
    uint256 private _firstUnresolvedNode;
    uint256 private _latestNodeCreated;
    uint256 private _lastStakeBlock;
    mapping(uint256 => INode) private _nodes;
    mapping(uint256 => bytes32) private _nodeHashes;

    address payable[] private _stakerList;
    mapping(address => Staker) public override _stakerMap;

    Zombie[] private _zombies;

    mapping(address => uint256) private _withdrawableFunds;

    function getNode(uint256 nodeNum) public view override returns (INode) {

        return _nodes[nodeNum];
    }

    function getStakerAddress(uint256 stakerNum) external view override returns (address) {

        return _stakerList[stakerNum];
    }

    function isStaked(address staker) public view override returns (bool) {

        return _stakerMap[staker].isStaked;
    }

    function latestStakedNode(address staker) public view override returns (uint256) {

        return _stakerMap[staker].latestStakedNode;
    }

    function currentChallenge(address staker) public view override returns (address) {

        return _stakerMap[staker].currentChallenge;
    }

    function amountStaked(address staker) public view override returns (uint256) {

        return _stakerMap[staker].amountStaked;
    }

    function zombieAddress(uint256 zombieNum) public view override returns (address) {

        return _zombies[zombieNum].stakerAddress;
    }

    function zombieLatestStakedNode(uint256 zombieNum) public view override returns (uint256) {

        return _zombies[zombieNum].latestStakedNode;
    }

    function zombieCount() public view override returns (uint256) {

        return _zombies.length;
    }

    function isZombie(address staker) public view override returns (bool) {

        for (uint256 i = 0; i < _zombies.length; i++) {
            if (staker == _zombies[i].stakerAddress) {
                return true;
            }
        }
        return false;
    }

    function withdrawableFunds(address owner) external view override returns (uint256) {

        return _withdrawableFunds[owner];
    }

    function firstUnresolvedNode() public view override returns (uint256) {

        return _firstUnresolvedNode;
    }

    function latestConfirmed() public view override returns (uint256) {

        return _latestConfirmed;
    }

    function latestNodeCreated() public view override returns (uint256) {

        return _latestNodeCreated;
    }

    function lastStakeBlock() external view override returns (uint256) {

        return _lastStakeBlock;
    }

    function stakerCount() public view override returns (uint256) {

        return _stakerList.length;
    }

    function initializeCore(INode initialNode) internal {

        _nodes[0] = initialNode;
        _firstUnresolvedNode = 1;
    }

    function nodeCreated(INode node, bytes32 nodeHash) internal {

        _latestNodeCreated++;
        _nodes[_latestNodeCreated] = node;
        _nodeHashes[_latestNodeCreated] = nodeHash;
    }

    function getNodeHash(uint256 index) public view override returns (bytes32) {

        return _nodeHashes[index];
    }

    function _rejectNextNode() internal {

        destroyNode(_firstUnresolvedNode);
        _firstUnresolvedNode++;
    }

    function confirmNextNode(
        bytes32 beforeSendAcc,
        bytes calldata sendsData,
        uint256[] calldata sendLengths,
        uint256 afterSendCount,
        bytes32 afterLogAcc,
        uint256 afterLogCount,
        IOutbox outbox,
        RollupEventBridge rollupEventBridge
    ) internal {

        confirmNode(
            _firstUnresolvedNode,
            beforeSendAcc,
            sendsData,
            sendLengths,
            afterSendCount,
            afterLogAcc,
            afterLogCount,
            outbox,
            rollupEventBridge
        );
    }

    function confirmNode(
        uint256 nodeNum,
        bytes32 beforeSendAcc,
        bytes calldata sendsData,
        uint256[] calldata sendLengths,
        uint256 afterSendCount,
        bytes32 afterLogAcc,
        uint256 afterLogCount,
        IOutbox outbox,
        RollupEventBridge rollupEventBridge
    ) internal {

        bytes32 afterSendAcc = RollupLib.feedAccumulator(sendsData, sendLengths, beforeSendAcc);

        INode node = getNode(nodeNum);
        require(
            node.confirmData() ==
                RollupLib.confirmHash(
                    beforeSendAcc,
                    afterSendAcc,
                    afterLogAcc,
                    afterSendCount,
                    afterLogCount
                ),
            "CONFIRM_DATA"
        );

        outbox.processOutgoingMessages(sendsData, sendLengths);

        destroyNode(_latestConfirmed);
        _latestConfirmed = nodeNum;
        _firstUnresolvedNode = nodeNum + 1;

        rollupEventBridge.nodeConfirmed(nodeNum);
        emit NodeConfirmed(nodeNum, afterSendAcc, afterSendCount, afterLogAcc, afterLogCount);
    }

    function createNewStake(address payable stakerAddress, uint256 depositAmount) internal {

        uint256 stakerIndex = _stakerList.length;
        _stakerList.push(stakerAddress);
        _stakerMap[stakerAddress] = Staker(
            stakerIndex,
            _latestConfirmed,
            depositAmount,
            address(0), // new staker is not in challenge
            true
        );
        _lastStakeBlock = block.number;
        emit UserStakeUpdated(stakerAddress, 0, depositAmount);
    }

    function inChallenge(address stakerAddress1, address stakerAddress2)
        internal
        view
        returns (address)
    {

        Staker storage staker1 = _stakerMap[stakerAddress1];
        Staker storage staker2 = _stakerMap[stakerAddress2];
        address challenge = staker1.currentChallenge;
        require(challenge != address(0), "NO_CHAL");
        require(challenge == staker2.currentChallenge, "DIFF_IN_CHAL");
        return challenge;
    }

    function clearChallenge(address stakerAddress) internal {

        Staker storage staker = _stakerMap[stakerAddress];
        staker.currentChallenge = address(0);
    }

    function challengeStarted(
        address staker1,
        address staker2,
        address challenge
    ) internal {

        _stakerMap[staker1].currentChallenge = challenge;
        _stakerMap[staker2].currentChallenge = challenge;
    }

    function increaseStakeBy(address stakerAddress, uint256 amountAdded) internal {

        Staker storage staker = _stakerMap[stakerAddress];
        uint256 initialStaked = staker.amountStaked;
        uint256 finalStaked = initialStaked.add(amountAdded);
        staker.amountStaked = finalStaked;
        emit UserStakeUpdated(stakerAddress, initialStaked, finalStaked);
    }

    function reduceStakeTo(address stakerAddress, uint256 target) internal returns (uint256) {

        Staker storage staker = _stakerMap[stakerAddress];
        uint256 current = staker.amountStaked;
        require(target <= current, "TOO_LITTLE_STAKE");
        uint256 amountWithdrawn = current.sub(target);
        staker.amountStaked = target;
        increaseWithdrawableFunds(stakerAddress, amountWithdrawn);
        emit UserStakeUpdated(stakerAddress, current, target);
        return amountWithdrawn;
    }

    function turnIntoZombie(address stakerAddress) internal {

        Staker storage staker = _stakerMap[stakerAddress];
        _zombies.push(Zombie(stakerAddress, staker.latestStakedNode));
        deleteStaker(stakerAddress);
    }

    function zombieUpdateLatestStakedNode(uint256 zombieNum, uint256 latest) internal {

        _zombies[zombieNum].latestStakedNode = latest;
    }

    function removeZombie(uint256 zombieNum) internal {

        _zombies[zombieNum] = _zombies[_zombies.length - 1];
        _zombies.pop();
    }

    function withdrawStaker(address stakerAddress) internal {

        Staker storage staker = _stakerMap[stakerAddress];
        uint256 initialStaked = staker.amountStaked;
        increaseWithdrawableFunds(stakerAddress, initialStaked);
        deleteStaker(stakerAddress);
        emit UserStakeUpdated(stakerAddress, initialStaked, 0);
    }

    function stakeOnNode(
        address stakerAddress,
        uint256 nodeNum,
        uint256 confirmPeriodBlocks
    ) internal {

        Staker storage staker = _stakerMap[stakerAddress];
        INode node = _nodes[nodeNum];
        uint256 newStakerCount = node.addStaker(stakerAddress);
        staker.latestStakedNode = nodeNum;
        if (newStakerCount == 1) {
            INode parent = _nodes[node.prev()];
            parent.newChildConfirmDeadline(block.number.add(confirmPeriodBlocks));
        }
    }

    function withdrawFunds(address owner) internal returns (uint256) {

        uint256 amount = _withdrawableFunds[owner];
        _withdrawableFunds[owner] = 0;
        emit UserWithdrawableFundsUpdated(owner, amount, 0);
        return amount;
    }

    function increaseWithdrawableFunds(address owner, uint256 amount) internal {

        uint256 initialWithdrawable = _withdrawableFunds[owner];
        uint256 finalWithdrawable = initialWithdrawable.add(amount);
        _withdrawableFunds[owner] = finalWithdrawable;
        emit UserWithdrawableFundsUpdated(owner, initialWithdrawable, finalWithdrawable);
    }

    function deleteStaker(address stakerAddress) private {

        Staker storage staker = _stakerMap[stakerAddress];
        uint256 stakerIndex = staker.index;
        _stakerList[stakerIndex] = _stakerList[_stakerList.length - 1];
        _stakerMap[_stakerList[stakerIndex]].index = stakerIndex;
        _stakerList.pop();
        delete _stakerMap[stakerAddress];
    }

    function destroyNode(uint256 nodeNum) internal {

        _nodes[nodeNum].destroy();
        _nodes[nodeNum] = INode(0);
    }

    function nodeDeadline(
        uint256 avmGasSpeedLimitPerBlock,
        uint256 gasUsed,
        uint256 confirmPeriodBlocks,
        INode prevNode
    ) internal view returns (uint256 deadlineBlock) {

        uint256 checkTime =
            gasUsed.add(avmGasSpeedLimitPerBlock.sub(1)).div(avmGasSpeedLimitPerBlock);

        deadlineBlock = max(block.number.add(confirmPeriodBlocks), prevNode.deadlineBlock()).add(
            checkTime
        );

        uint256 olderSibling = prevNode.latestChildNumber();
        if (olderSibling != 0) {
            deadlineBlock = max(deadlineBlock, getNode(olderSibling).deadlineBlock());
        }
        return deadlineBlock;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a > b ? a : b;
    }

    struct StakeOnNewNodeFrame {
        uint256 currentInboxSize;
        INode node;
        bytes32 executionHash;
        INode prevNode;
        bytes32 lastHash;
        bool hasSibling;
        uint256 deadlineBlock;
        uint256 gasUsed;
        uint256 sequencerBatchEnd;
        bytes32 sequencerBatchAcc;
    }

    struct CreateNodeDataFrame {
        uint256 prevNode;
        uint256 confirmPeriodBlocks;
        uint256 avmGasSpeedLimitPerBlock;
        ISequencerInbox sequencerInbox;
        RollupEventBridge rollupEventBridge;
        INodeFactory nodeFactory;
    }

    uint8 internal constant MAX_SEND_COUNT = 100;

    function createNewNode(
        RollupLib.Assertion memory assertion,
        bytes32[3][2] calldata assertionBytes32Fields,
        uint256[4][2] calldata assertionIntFields,
        bytes calldata sequencerBatchProof,
        CreateNodeDataFrame memory inputDataFrame,
        bytes32 expectedNodeHash
    ) internal returns (bytes32 newNodeHash) {

        StakeOnNewNodeFrame memory memoryFrame;
        {
            memoryFrame.gasUsed = RollupLib.assertionGasUsed(assertion);
            memoryFrame.prevNode = getNode(inputDataFrame.prevNode);
            memoryFrame.currentInboxSize = inputDataFrame.sequencerInbox.messageCount();

            require(
                RollupLib.stateHash(assertion.beforeState) == memoryFrame.prevNode.stateHash(),
                "PREV_STATE_HASH"
            );

            require(
                assertion.afterState.inboxCount <= memoryFrame.currentInboxSize,
                "INBOX_PAST_END"
            );
            (memoryFrame.sequencerBatchEnd, memoryFrame.sequencerBatchAcc) = inputDataFrame
                .sequencerInbox
                .proveInboxContainsMessage(sequencerBatchProof, assertion.afterState.inboxCount);
        }

        {
            memoryFrame.executionHash = RollupLib.executionHash(assertion);

            memoryFrame.deadlineBlock = nodeDeadline(
                inputDataFrame.avmGasSpeedLimitPerBlock,
                memoryFrame.gasUsed,
                inputDataFrame.confirmPeriodBlocks,
                memoryFrame.prevNode
            );

            memoryFrame.hasSibling = memoryFrame.prevNode.latestChildNumber() > 0;
            if (memoryFrame.hasSibling) {
                memoryFrame.lastHash = getNodeHash(memoryFrame.prevNode.latestChildNumber());
            } else {
                memoryFrame.lastHash = getNodeHash(inputDataFrame.prevNode);
            }

            memoryFrame.node = INode(
                inputDataFrame.nodeFactory.createNode(
                    RollupLib.stateHash(assertion.afterState),
                    RollupLib.challengeRoot(assertion, memoryFrame.executionHash, block.number),
                    RollupLib.confirmHash(assertion),
                    inputDataFrame.prevNode,
                    memoryFrame.deadlineBlock
                )
            );
        }

        {
            uint256 nodeNum = latestNodeCreated() + 1;
            memoryFrame.prevNode.childCreated(nodeNum);

            newNodeHash = RollupLib.nodeHash(
                memoryFrame.hasSibling,
                memoryFrame.lastHash,
                memoryFrame.executionHash,
                memoryFrame.sequencerBatchAcc
            );
            require(newNodeHash == expectedNodeHash, "UNEXPECTED_NODE_HASH");

            nodeCreated(memoryFrame.node, newNodeHash);
            inputDataFrame.rollupEventBridge.nodeCreated(
                nodeNum,
                inputDataFrame.prevNode,
                memoryFrame.deadlineBlock,
                msg.sender
            );
        }

        emit NodeCreated(
            latestNodeCreated(),
            getNodeHash(inputDataFrame.prevNode),
            newNodeHash,
            memoryFrame.executionHash,
            memoryFrame.currentInboxSize,
            memoryFrame.sequencerBatchEnd,
            memoryFrame.sequencerBatchAcc,
            assertionBytes32Fields,
            assertionIntFields
        );

        return newNodeHash;
    }
}// Apache-2.0


pragma solidity ^0.6.11;


interface IChallengeFactory {

    function createChallenge(
        address _resultReceiver,
        bytes32 _executionHash,
        uint256 _maxMessageCount,
        address _asserter,
        address _challenger,
        uint256 _asserterTimeLeft,
        uint256 _challengerTimeLeft,
        ISequencerInbox _sequencerBridge,
        IBridge _delayedBridge
    ) external returns (address);

}// Apache-2.0


pragma solidity ^0.6.11;

library Messages {

    function messageHash(
        uint8 kind,
        address sender,
        uint256 blockNumber,
        uint256 timestamp,
        uint256 inboxSeqNum,
        uint256 gasPriceL1,
        bytes32 messageDataHash
    ) internal pure returns (bytes32) {

        return
            keccak256(
                abi.encodePacked(
                    kind,
                    sender,
                    blockNumber,
                    timestamp,
                    inboxSeqNum,
                    gasPriceL1,
                    messageDataHash
                )
            );
    }

    function addMessageToInbox(bytes32 inbox, bytes32 message) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked(inbox, message));
    }
}// Apache-2.0


pragma solidity ^0.6.11;

library ProxyUtil {

    function getProxyAdmin() internal view returns (address admin) {

        bytes32 slot = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;
        assembly {
            admin := sload(slot)
        }
    }
}// Apache-2.0


pragma solidity ^0.6.11;






abstract contract RollupBase is Cloneable, RollupCore, Pausable {
    uint256 public confirmPeriodBlocks;
    uint256 public extraChallengeTimeBlocks;
    uint256 public avmGasSpeedLimitPerBlock;
    uint256 public baseStake;

    IBridge public delayedBridge;
    ISequencerInbox public sequencerBridge;
    IOutbox public outbox;
    RollupEventBridge public rollupEventBridge;
    IChallengeFactory public challengeFactory;
    INodeFactory public nodeFactory;
    address public owner;
    address public stakeToken;
    uint256 public minimumAssertionPeriod;

    uint256 public STORAGE_GAP_1;
    uint256 public STORAGE_GAP_2;
    uint256 public challengeExecutionBisectionDegree;

    address[] internal facets;

    mapping(address => bool) isValidator;

    function arbGasSpeedLimitPerBlock() external view returns (uint256) {
        return avmGasSpeedLimitPerBlock;
    }
}

contract Rollup is Proxy, RollupBase {

    using Address for address;

    constructor(uint256 _confirmPeriodBlocks) public Cloneable() Pausable() {
        confirmPeriodBlocks = _confirmPeriodBlocks;
        require(isInit(), "CONSTRUCTOR_NOT_INIT");
    }

    function isInit() internal view returns (bool) {

        return confirmPeriodBlocks != 0;
    }

    function initialize(
        bytes32 _machineHash,
        uint256[4] calldata _rollupParams,
        address _stakeToken,
        address _owner,
        bytes calldata _extraConfig,
        address[6] calldata connectedContracts,
        address[2] calldata _facets,
        uint256[2] calldata sequencerInboxParams
    ) public {

        require(!isInit(), "ALREADY_INIT");

        require(_facets[0].isContract(), "FACET_0_NOT_CONTRACT");
        require(_facets[1].isContract(), "FACET_1_NOT_CONTRACT");
        (bool success, ) = _facets[1].delegatecall(
            abi.encodeWithSelector(IRollupUser.initialize.selector, _stakeToken)
        );
        require(success, "FAIL_INIT_FACET");

        delayedBridge = IBridge(connectedContracts[0]);
        sequencerBridge = ISequencerInbox(connectedContracts[1]);
        outbox = IOutbox(connectedContracts[2]);
        delayedBridge.setOutbox(connectedContracts[2], true);
        rollupEventBridge = RollupEventBridge(connectedContracts[3]);
        delayedBridge.setInbox(connectedContracts[3], true);

        rollupEventBridge.rollupInitialized(
            _rollupParams[0],
            _rollupParams[2],
            _owner,
            _extraConfig
        );

        challengeFactory = IChallengeFactory(connectedContracts[4]);
        nodeFactory = INodeFactory(connectedContracts[5]);

        INode node = createInitialNode(_machineHash);
        initializeCore(node);

        confirmPeriodBlocks = _rollupParams[0];
        extraChallengeTimeBlocks = _rollupParams[1];
        avmGasSpeedLimitPerBlock = _rollupParams[2];
        baseStake = _rollupParams[3];
        owner = _owner;
        minimumAssertionPeriod = 75;
        challengeExecutionBisectionDegree = 400;

        sequencerBridge.setMaxDelay(sequencerInboxParams[0], sequencerInboxParams[1]);

        facets = _facets;

        emit RollupCreated(_machineHash);
        require(isInit(), "INITIALIZE_NOT_INIT");
    }

    function postUpgradeInit() external {

        address proxyAdmin = ProxyUtil.getProxyAdmin();
        require(msg.sender == proxyAdmin, "NOT_FROM_ADMIN");


        STORAGE_GAP_1 = 0;
        STORAGE_GAP_2 = 0;
    }

    function createInitialNode(bytes32 _machineHash) private returns (INode) {

        bytes32 state = RollupLib.stateHash(
            RollupLib.ExecutionState(
                0, // total gas used
                _machineHash,
                0, // inbox count
                0, // send count
                0, // log count
                0, // send acc
                0, // log acc
                block.number, // block proposed
                1 // Initialization message already in inbox
            )
        );
        return
            INode(
                nodeFactory.createNode(
                    state,
                    0, // challenge hash (not challengeable)
                    0, // confirm data
                    0, // prev node
                    block.number // deadline block (not challengeable)
                )
            );
    }


    function getFacets() external view returns (address, address) {

        return (getAdminFacet(), getUserFacet());
    }

    function getAdminFacet() public view returns (address) {

        return facets[0];
    }

    function getUserFacet() public view returns (address) {

        return facets[1];
    }

    function _implementation() internal view virtual override returns (address) {

        require(msg.data.length >= 4, "NO_FUNC_SIG");
        address rollupOwner = owner;
        address target = rollupOwner != address(0) && rollupOwner == msg.sender
            ? getAdminFacet()
            : getUserFacet();
        require(target.isContract(), "TARGET_NOT_CONTRACT");
        return target;
    }
}// Apache-2.0

pragma solidity ^0.6.11;


abstract contract AbsRollupUserFacet is RollupBase, IRollupUser {
    function initialize(address _stakeToken) public virtual override;

    modifier onlyValidator {
        require(isValidator[msg.sender], "NOT_VALIDATOR");
        _;
    }

    function rejectNextNode(address stakerAddress) external onlyValidator whenNotPaused {
        requireUnresolvedExists();
        uint256 latestConfirmedNodeNum = latestConfirmed();
        uint256 firstUnresolvedNodeNum = firstUnresolvedNode();
        INode firstUnresolvedNode_ = getNode(firstUnresolvedNodeNum);

        if (firstUnresolvedNode_.prev() == latestConfirmedNodeNum) {

            require(isStaked(stakerAddress), "NOT_STAKED");

            requireUnresolved(latestStakedNode(stakerAddress));

            require(!firstUnresolvedNode_.stakers(stakerAddress), "STAKED_ON_TARGET");

            firstUnresolvedNode_.requirePastDeadline();

            getNode(latestConfirmedNodeNum).requirePastChildConfirmDeadline();

            removeOldZombies(0);

            require(
                firstUnresolvedNode_.stakerCount() == countStakedZombies(firstUnresolvedNode_),
                "HAS_STAKERS"
            );
        }
        _rejectNextNode();
        rollupEventBridge.nodeRejected(firstUnresolvedNodeNum);

        emit NodeRejected(firstUnresolvedNodeNum);
    }

    function confirmNextNode(
        bytes32 beforeSendAcc,
        bytes calldata sendsData,
        uint256[] calldata sendLengths,
        uint256 afterSendCount,
        bytes32 afterLogAcc,
        uint256 afterLogCount
    ) external onlyValidator whenNotPaused {
        requireUnresolvedExists();

        require(stakerCount() > 0, "NO_STAKERS");

        INode node = getNode(firstUnresolvedNode());

        node.requirePastDeadline();

        require(node.prev() == latestConfirmed(), "INVALID_PREV");

        getNode(latestConfirmed()).requirePastChildConfirmDeadline();

        removeOldZombies(0);

        require(
            node.stakerCount() == stakerCount().add(countStakedZombies(node)),
            "NOT_ALL_STAKED"
        );

        confirmNextNode(
            beforeSendAcc,
            sendsData,
            sendLengths,
            afterSendCount,
            afterLogAcc,
            afterLogCount,
            outbox,
            rollupEventBridge
        );
    }

    function _newStake(uint256 depositAmount) internal onlyValidator whenNotPaused {
        require(!isStaked(msg.sender), "ALREADY_STAKED");
        require(!isZombie(msg.sender), "STAKER_IS_ZOMBIE");
        require(depositAmount >= currentRequiredStake(), "NOT_ENOUGH_STAKE");

        createNewStake(msg.sender, depositAmount);

        rollupEventBridge.stakeCreated(msg.sender, latestConfirmed());
    }

    function stakeOnExistingNode(uint256 nodeNum, bytes32 nodeHash)
        external
        onlyValidator
        whenNotPaused
    {
        require(isStaked(msg.sender), "NOT_STAKED");

        require(getNodeHash(nodeNum) == nodeHash, "NODE_REORG");
        require(
            nodeNum >= firstUnresolvedNode() && nodeNum <= latestNodeCreated(),
            "NODE_NUM_OUT_OF_RANGE"
        );
        INode node = getNode(nodeNum);
        require(latestStakedNode(msg.sender) == node.prev(), "NOT_STAKED_PREV");
        stakeOnNode(msg.sender, nodeNum, confirmPeriodBlocks);
    }

    function stakeOnNewNode(
        bytes32 expectedNodeHash,
        bytes32[3][2] calldata assertionBytes32Fields,
        uint256[4][2] calldata assertionIntFields,
        uint256 beforeProposedBlock,
        uint256 beforeInboxMaxCount,
        bytes calldata sequencerBatchProof
    ) external onlyValidator whenNotPaused {
        require(isStaked(msg.sender), "NOT_STAKED");

        RollupLib.Assertion memory assertion =
            RollupLib.decodeAssertion(
                assertionBytes32Fields,
                assertionIntFields,
                beforeProposedBlock,
                beforeInboxMaxCount,
                sequencerBridge.messageCount()
            );

        {
            uint256 timeSinceLastNode = block.number.sub(assertion.beforeState.proposedBlock);
            require(timeSinceLastNode >= minimumAssertionPeriod, "TIME_DELTA");

            uint256 gasUsed = RollupLib.assertionGasUsed(assertion);
            require(
                assertion.afterState.inboxCount >= assertion.beforeState.inboxMaxCount ||
                    gasUsed >= timeSinceLastNode.mul(avmGasSpeedLimitPerBlock) ||
                    assertion.afterState.sendCount.sub(assertion.beforeState.sendCount) ==
                    MAX_SEND_COUNT,
                "TOO_SMALL"
            );

            require(
                assertion.afterState.sendCount.sub(assertion.beforeState.sendCount) <=
                    MAX_SEND_COUNT,
                "TOO_MANY_SENDS"
            );

            require(gasUsed <= timeSinceLastNode.mul(avmGasSpeedLimitPerBlock).mul(4), "TOO_LARGE");
        }
        createNewNode(
            assertion,
            assertionBytes32Fields,
            assertionIntFields,
            sequencerBatchProof,
            CreateNodeDataFrame({
                avmGasSpeedLimitPerBlock: avmGasSpeedLimitPerBlock,
                confirmPeriodBlocks: confirmPeriodBlocks,
                prevNode: latestStakedNode(msg.sender), // Ensure staker is staked on the previous node
                sequencerInbox: sequencerBridge,
                rollupEventBridge: rollupEventBridge,
                nodeFactory: nodeFactory
            }),
            expectedNodeHash
        );

        stakeOnNode(msg.sender, latestNodeCreated(), confirmPeriodBlocks);
    }

    function returnOldDeposit(address stakerAddress) external override onlyValidator whenNotPaused {
        require(latestStakedNode(stakerAddress) <= latestConfirmed(), "TOO_RECENT");
        requireUnchallengedStaker(stakerAddress);
        withdrawStaker(stakerAddress);
    }

    function _addToDeposit(address stakerAddress, uint256 depositAmount)
        internal
        onlyValidator
        whenNotPaused
    {
        requireUnchallengedStaker(stakerAddress);
        increaseStakeBy(stakerAddress, depositAmount);
    }

    function reduceDeposit(uint256 target) external onlyValidator whenNotPaused {
        requireUnchallengedStaker(msg.sender);
        uint256 currentRequired = currentRequiredStake();
        if (target < currentRequired) {
            target = currentRequired;
        }
        reduceStakeTo(msg.sender, target);
    }

    function createChallenge(
        address payable[2] calldata stakers,
        uint256[2] calldata nodeNums,
        bytes32[2] calldata executionHashes,
        uint256[2] calldata proposedTimes,
        uint256[2] calldata maxMessageCounts
    ) external onlyValidator whenNotPaused {
        require(nodeNums[0] < nodeNums[1], "WRONG_ORDER");
        require(nodeNums[1] <= latestNodeCreated(), "NOT_PROPOSED");
        require(latestConfirmed() < nodeNums[0], "ALREADY_CONFIRMED");

        INode node1 = getNode(nodeNums[0]);
        INode node2 = getNode(nodeNums[1]);

        require(node1.prev() == node2.prev(), "DIFF_PREV");

        requireUnchallengedStaker(stakers[0]);
        requireUnchallengedStaker(stakers[1]);

        require(node1.stakers(stakers[0]), "STAKER1_NOT_STAKED");
        require(node2.stakers(stakers[1]), "STAKER2_NOT_STAKED");

        require(
            node1.challengeHash() ==
                RollupLib.challengeRootHash(
                    executionHashes[0],
                    proposedTimes[0],
                    maxMessageCounts[0]
                ),
            "CHAL_HASH1"
        );

        require(
            node2.challengeHash() ==
                RollupLib.challengeRootHash(
                    executionHashes[1],
                    proposedTimes[1],
                    maxMessageCounts[1]
                ),
            "CHAL_HASH2"
        );

        uint256 commonEndTime =
            getNode(node1.prev())
                .firstChildBlock() // Dispute start: dispute timer for a node starts when its first child is created
                .add(
                node1.deadlineBlock().sub(proposedTimes[0]).add(extraChallengeTimeBlocks) // add dispute window to dispute start time
            );
        if (commonEndTime < proposedTimes[1]) {
            completeChallengeImpl(stakers[0], stakers[1]);
            return;
        }
        address challengeAddress =
            challengeFactory.createChallenge(
                address(this),
                executionHashes[0],
                maxMessageCounts[0],
                stakers[0],
                stakers[1],
                commonEndTime.sub(proposedTimes[0]),
                commonEndTime.sub(proposedTimes[1]),
                sequencerBridge,
                delayedBridge
            ); // trusted external call

        challengeStarted(stakers[0], stakers[1], challengeAddress);

        emit RollupChallengeStarted(challengeAddress, stakers[0], stakers[1], nodeNums[0]);
    }

    function completeChallenge(address winningStaker, address losingStaker)
        external
        override
        whenNotPaused
    {
        require(msg.sender == inChallenge(winningStaker, losingStaker), "WRONG_SENDER");

        completeChallengeImpl(winningStaker, losingStaker);
    }

    function completeChallengeImpl(address winningStaker, address losingStaker) private {
        uint256 remainingLoserStake = amountStaked(losingStaker);
        uint256 winnerStake = amountStaked(winningStaker);
        if (remainingLoserStake > winnerStake) {
            remainingLoserStake = remainingLoserStake.sub(reduceStakeTo(losingStaker, winnerStake));
        }

        uint256 amountWon = remainingLoserStake / 2;
        increaseStakeBy(winningStaker, amountWon);
        remainingLoserStake = remainingLoserStake.sub(amountWon);
        clearChallenge(winningStaker);
        increaseWithdrawableFunds(owner, remainingLoserStake);
        turnIntoZombie(losingStaker);
    }

    function removeZombie(uint256 zombieNum, uint256 maxNodes)
        external
        onlyValidator
        whenNotPaused
    {
        require(zombieNum <= zombieCount(), "NO_SUCH_ZOMBIE");
        address zombieStakerAddress = zombieAddress(zombieNum);
        uint256 latestNodeStaked = zombieLatestStakedNode(zombieNum);
        uint256 nodesRemoved = 0;
        uint256 firstUnresolved = firstUnresolvedNode();
        while (latestNodeStaked >= firstUnresolved && nodesRemoved < maxNodes) {
            INode node = getNode(latestNodeStaked);
            node.removeStaker(zombieStakerAddress);
            latestNodeStaked = node.prev();
            nodesRemoved++;
        }
        if (latestNodeStaked < firstUnresolved) {
            removeZombie(zombieNum);
        } else {
            zombieUpdateLatestStakedNode(zombieNum, latestNodeStaked);
        }
    }

    function removeOldZombies(uint256 startIndex) public onlyValidator whenNotPaused {
        uint256 currentZombieCount = zombieCount();
        uint256 firstUnresolved = firstUnresolvedNode();
        for (uint256 i = startIndex; i < currentZombieCount; i++) {
            while (zombieLatestStakedNode(i) < firstUnresolved) {
                removeZombie(i);
                currentZombieCount--;
                if (i >= currentZombieCount) {
                    return;
                }
            }
        }
    }

    function currentRequiredStake(
        uint256 _blockNumber,
        uint256 _firstUnresolvedNodeNum,
        uint256 _latestCreatedNode
    ) internal view returns (uint256) {
        if (_firstUnresolvedNodeNum - 1 == _latestCreatedNode) {
            return baseStake;
        }
        uint256 firstUnresolvedDeadline = getNode(_firstUnresolvedNodeNum).deadlineBlock();
        if (_blockNumber < firstUnresolvedDeadline) {
            return baseStake;
        }
        uint24[10] memory numerators =
            [1, 122971, 128977, 80017, 207329, 114243, 314252, 129988, 224562, 162163];
        uint24[10] memory denominators =
            [1, 114736, 112281, 64994, 157126, 80782, 207329, 80017, 128977, 86901];
        uint256 firstUnresolvedAge = _blockNumber.sub(firstUnresolvedDeadline);
        uint256 periodsPassed = firstUnresolvedAge.mul(10).div(confirmPeriodBlocks);
        if (periodsPassed.div(10) >= 255) {
            return type(uint256).max;
        }
        uint256 baseMultiplier = 2**periodsPassed.div(10);
        uint256 withNumerator = baseMultiplier * numerators[periodsPassed % 10];
        if (withNumerator / baseMultiplier != numerators[periodsPassed % 10]) {
            return type(uint256).max;
        }
        uint256 multiplier = withNumerator.div(denominators[periodsPassed % 10]);
        if (multiplier == 0) {
            multiplier = 1;
        }
        uint256 fullStake = baseStake * multiplier;
        if (fullStake / baseStake != multiplier) {
            return type(uint256).max;
        }
        return fullStake;
    }

    function requiredStake(
        uint256 blockNumber,
        uint256 firstUnresolvedNodeNum,
        uint256 latestCreatedNode
    ) external view returns (uint256) {
        return currentRequiredStake(blockNumber, firstUnresolvedNodeNum, latestCreatedNode);
    }

    function currentRequiredStake() public view returns (uint256) {
        uint256 firstUnresolvedNodeNum = firstUnresolvedNode();

        return currentRequiredStake(block.number, firstUnresolvedNodeNum, latestNodeCreated());
    }

    function countStakedZombies(INode node) public view override returns (uint256) {
        uint256 currentZombieCount = zombieCount();
        uint256 stakedZombieCount = 0;
        for (uint256 i = 0; i < currentZombieCount; i++) {
            if (node.stakers(zombieAddress(i))) {
                stakedZombieCount++;
            }
        }
        return stakedZombieCount;
    }

    function requireUnresolvedExists() public view override {
        uint256 firstUnresolved = firstUnresolvedNode();
        require(
            firstUnresolved > latestConfirmed() && firstUnresolved <= latestNodeCreated(),
            "NO_UNRESOLVED"
        );
    }

    function requireUnresolved(uint256 nodeNum) public view override {
        require(nodeNum >= firstUnresolvedNode(), "ALREADY_DECIDED");
        require(nodeNum <= latestNodeCreated(), "DOESNT_EXIST");
    }

    function requireUnchallengedStaker(address stakerAddress) private view {
        require(isStaked(stakerAddress), "NOT_STAKED");
        require(currentChallenge(stakerAddress) == address(0), "IN_CHAL");
    }

    function withdrawStakerFunds(address payable destination) external virtual returns (uint256);
}

contract RollupUserFacet is AbsRollupUserFacet {

    function initialize(address _stakeToken) public override {

        require(_stakeToken == address(0), "NO_TOKEN_ALLOWED");
    }

    function newStake() external payable onlyValidator whenNotPaused {

        _newStake(msg.value);
    }

    function addToDeposit(address stakerAddress) external payable onlyValidator whenNotPaused {

        _addToDeposit(stakerAddress, msg.value);
    }

    function withdrawStakerFunds(address payable destination)
        external
        override
        onlyValidator
        whenNotPaused
        returns (uint256)
    {

        uint256 amount = withdrawFunds(msg.sender);
        destination.transfer(amount);
        return amount;
    }
}

contract ERC20RollupUserFacet is AbsRollupUserFacet {

    function initialize(address _stakeToken) public override {

        require(_stakeToken != address(0), "NEED_STAKE_TOKEN");
        require(stakeToken == address(0), "ALREADY_INIT");
        stakeToken = _stakeToken;
    }

    function newStake(uint256 tokenAmount) external onlyValidator whenNotPaused {

        _newStake(tokenAmount);
        require(
            IERC20(stakeToken).transferFrom(msg.sender, address(this), tokenAmount),
            "TRANSFER_FAIL"
        );
    }

    function addToDeposit(address stakerAddress, uint256 tokenAmount)
        external
        onlyValidator
        whenNotPaused
    {

        _addToDeposit(stakerAddress, tokenAmount);
        require(
            IERC20(stakeToken).transferFrom(msg.sender, address(this), tokenAmount),
            "TRANSFER_FAIL"
        );
    }

    function withdrawStakerFunds(address payable destination)
        external
        override
        onlyValidator
        whenNotPaused
        returns (uint256)
    {

        uint256 amount = withdrawFunds(msg.sender);
        require(IERC20(stakeToken).transfer(destination, amount), "TRANSFER_FAILED");
        return amount;
    }
}// Apache-2.0


pragma solidity ^0.6.11;




contract Challenge is Cloneable, IChallenge {

    using SafeMath for uint256;

    enum Turn { NoChallenge, Asserter, Challenger }

    event InitiatedChallenge();
    event Bisected(
        bytes32 indexed challengeRoot,
        uint256 challengedSegmentStart,
        uint256 challengedSegmentLength,
        bytes32[] chainHashes
    );
    event AsserterTimedOut();
    event ChallengerTimedOut();
    event OneStepProofCompleted();
    event ContinuedExecutionProven();

    string private constant CHAL_INIT_STATE = "CHAL_INIT_STATE";
    string private constant BIS_DEADLINE = "BIS_DEADLINE";
    string private constant BIS_SENDER = "BIS_SENDER";
    string private constant BIS_PREV = "BIS_PREV";
    string private constant TIMEOUT_DEADLINE = "TIMEOUT_DEADLINE";

    bytes32 private constant UNREACHABLE_ASSERTION = bytes32(uint256(0));

    IOneStepProof[] public executors;
    address[2] public bridges;

    RollupUserFacet internal resultReceiver;

    uint256 maxMessageCount;

    address public override asserter;
    address public override challenger;

    uint256 public override lastMoveBlock;
    uint256 public asserterTimeLeft;
    uint256 public challengerTimeLeft;

    Turn public turn;

    bytes32 public challengeState;

    modifier onlyOnTurn {

        require(msg.sender == currentResponder(), BIS_SENDER);
        require(block.number.sub(lastMoveBlock) <= currentResponderTimeLeft(), BIS_DEADLINE);

        _;

        if (turn == Turn.Challenger) {
            challengerTimeLeft = challengerTimeLeft.sub(block.number.sub(lastMoveBlock));
            turn = Turn.Asserter;
        } else {
            asserterTimeLeft = asserterTimeLeft.sub(block.number.sub(lastMoveBlock));
            turn = Turn.Challenger;
        }
        lastMoveBlock = block.number;
    }

    function initializeChallenge(
        IOneStepProof[] calldata _executors,
        address _resultReceiver,
        bytes32 _executionHash,
        uint256 _maxMessageCount,
        address _asserter,
        address _challenger,
        uint256 _asserterTimeLeft,
        uint256 _challengerTimeLeft,
        ISequencerInbox _sequencerBridge,
        IBridge _delayedBridge
    ) external override {

        require(turn == Turn.NoChallenge, CHAL_INIT_STATE);

        executors = _executors;

        resultReceiver = RollupUserFacet(_resultReceiver);

        maxMessageCount = _maxMessageCount;

        asserter = _asserter;
        challenger = _challenger;
        asserterTimeLeft = _asserterTimeLeft;
        challengerTimeLeft = _challengerTimeLeft;

        turn = Turn.Challenger;

        challengeState = _executionHash;

        lastMoveBlock = block.number;
        bridges = [address(_sequencerBridge), address(_delayedBridge)];

        emit InitiatedChallenge();
    }

    function bisectExecution(
        bytes32[] calldata _merkleNodes,
        uint256 _merkleRoute,
        uint256 _challengedSegmentStart,
        uint256 _challengedSegmentLength,
        bytes32 _oldEndHash,
        uint256 _gasUsedBefore,
        bytes32 _assertionRest,
        bytes32[] calldata _chainHashes
    ) external onlyOnTurn {

        if (_chainHashes[_chainHashes.length - 1] != UNREACHABLE_ASSERTION) {
            require(_challengedSegmentLength > 1, "TOO_SHORT");
        }
        uint256 challengeExecutionBisectionDegree =
            resultReceiver.challengeExecutionBisectionDegree();
        require(
            _chainHashes.length ==
                bisectionDegree(_challengedSegmentLength, challengeExecutionBisectionDegree) + 1,
            "CUT_COUNT"
        );
        require(_chainHashes[_chainHashes.length - 1] != _oldEndHash, "SAME_END");

        require(
            _chainHashes[0] == ChallengeLib.assertionHash(_gasUsedBefore, _assertionRest),
            "segment pre-fields"
        );
        require(_chainHashes[0] != UNREACHABLE_ASSERTION, "UNREACHABLE_START");

        require(
            _gasUsedBefore < _challengedSegmentStart.add(_challengedSegmentLength),
            "invalid segment length"
        );

        bytes32 bisectionHash =
            ChallengeLib.bisectionChunkHash(
                _challengedSegmentStart,
                _challengedSegmentLength,
                _chainHashes[0],
                _oldEndHash
            );
        require(
            ChallengeLib.verifySegmentProof(
                challengeState,
                bisectionHash,
                _merkleNodes,
                _merkleRoute
            ),
            BIS_PREV
        );

        bytes32 newChallengeState =
            ChallengeLib.updatedBisectionRoot(
                _chainHashes,
                _challengedSegmentStart,
                _challengedSegmentLength
            );
        challengeState = newChallengeState;

        emit Bisected(
            newChallengeState,
            _challengedSegmentStart,
            _challengedSegmentLength,
            _chainHashes
        );
    }

    function proveContinuedExecution(
        bytes32[] calldata _merkleNodes,
        uint256 _merkleRoute,
        uint256 _challengedSegmentStart,
        uint256 _challengedSegmentLength,
        bytes32 _oldEndHash,
        uint256 _gasUsedBefore,
        bytes32 _assertionRest
    ) external onlyOnTurn {

        bytes32 beforeChainHash = ChallengeLib.assertionHash(_gasUsedBefore, _assertionRest);

        bytes32 bisectionHash =
            ChallengeLib.bisectionChunkHash(
                _challengedSegmentStart,
                _challengedSegmentLength,
                beforeChainHash,
                _oldEndHash
            );
        require(
            ChallengeLib.verifySegmentProof(
                challengeState,
                bisectionHash,
                _merkleNodes,
                _merkleRoute
            ),
            BIS_PREV
        );

        require(
            _gasUsedBefore >= _challengedSegmentStart.add(_challengedSegmentLength),
            "NOT_CONT"
        );
        require(beforeChainHash != _oldEndHash, "WRONG_END");
        emit ContinuedExecutionProven();
        _currentWin();
    }

    function oneStepProveExecution(
        bytes32[] calldata _merkleNodes,
        uint256 _merkleRoute,
        uint256 _challengedSegmentStart,
        uint256 _challengedSegmentLength,
        bytes32 _oldEndHash,
        uint256 _initialMessagesRead,
        bytes32[2] calldata _initialAccs,
        uint256[3] memory _initialState,
        bytes memory _executionProof,
        bytes memory _bufferProof,
        uint8 prover
    ) external onlyOnTurn {

        bytes32 rootHash;
        {
            (uint64 gasUsed, uint256 totalMessagesRead, bytes32[4] memory proofFields) =
                executors[prover].executeStep(
                    bridges,
                    _initialMessagesRead,
                    _initialAccs,
                    _executionProof,
                    _bufferProof
                );

            require(totalMessagesRead <= maxMessageCount, "TOO_MANY_MESSAGES");

            require(
                _initialState[0] < _challengedSegmentStart.add(_challengedSegmentLength),
                "OSP_CONT"
            );
            require(
                _initialState[0].add(gasUsed) >=
                    _challengedSegmentStart.add(_challengedSegmentLength),
                "OSP_SHORT"
            );

            require(
                _oldEndHash !=
                    oneStepProofExecutionAfter(
                        _initialAccs[0],
                        _initialAccs[1],
                        _initialState,
                        gasUsed,
                        totalMessagesRead,
                        proofFields
                    ),
                "WRONG_END"
            );

            rootHash = ChallengeLib.bisectionChunkHash(
                _challengedSegmentStart,
                _challengedSegmentLength,
                oneStepProofExecutionBefore(
                    _initialMessagesRead,
                    _initialAccs[0],
                    _initialAccs[1],
                    _initialState,
                    proofFields
                ),
                _oldEndHash
            );
        }

        require(
            ChallengeLib.verifySegmentProof(challengeState, rootHash, _merkleNodes, _merkleRoute),
            BIS_PREV
        );

        emit OneStepProofCompleted();
        _currentWin();
    }

    function timeout() external override {

        uint256 timeSinceLastMove = block.number.sub(lastMoveBlock);
        require(timeSinceLastMove > currentResponderTimeLeft(), TIMEOUT_DEADLINE);

        if (turn == Turn.Asserter) {
            emit AsserterTimedOut();
            _challengerWin();
        } else {
            emit ChallengerTimedOut();
            _asserterWin();
        }
    }

    function currentResponder() public view returns (address) {

        if (turn == Turn.Asserter) {
            return asserter;
        } else if (turn == Turn.Challenger) {
            return challenger;
        } else {
            require(false, "NO_TURN");
        }
    }

    function currentResponderTimeLeft() public view override returns (uint256) {

        if (turn == Turn.Asserter) {
            return asserterTimeLeft;
        } else if (turn == Turn.Challenger) {
            return challengerTimeLeft;
        } else {
            require(false, "NO_TURN");
        }
    }

    function clearChallenge() external override {

        require(msg.sender == address(resultReceiver), "NOT_RES_RECEIVER");
        safeSelfDestruct(msg.sender);
    }

    function _currentWin() private {

        challengeState = bytes32(0);

    }

    function _asserterWin() private {

        resultReceiver.completeChallenge(asserter, challenger);
        safeSelfDestruct(msg.sender);
    }

    function _challengerWin() private {

        resultReceiver.completeChallenge(challenger, asserter);
        safeSelfDestruct(msg.sender);
    }

    function bisectionDegree(uint256 _chainLength, uint256 targetDegree)
        private
        pure
        returns (uint256)
    {

        if (_chainLength < targetDegree) {
            return _chainLength;
        } else {
            return targetDegree;
        }
    }

    function oneStepProofExecutionBefore(
        uint256 _initialMessagesRead,
        bytes32 _initialSendAcc,
        bytes32 _initialLogAcc,
        uint256[3] memory _initialState,
        bytes32[4] memory proofFields
    ) private pure returns (bytes32) {

        return
            ChallengeLib.assertionHash(
                _initialState[0],
                ChallengeLib.assertionRestHash(
                    _initialMessagesRead,
                    proofFields[0],
                    _initialSendAcc,
                    _initialState[1],
                    _initialLogAcc,
                    _initialState[2]
                )
            );
    }

    function oneStepProofExecutionAfter(
        bytes32 _initialSendAcc,
        bytes32 _initialLogAcc,
        uint256[3] memory _initialState,
        uint64 gasUsed,
        uint256 totalMessagesRead,
        bytes32[4] memory proofFields
    ) private pure returns (bytes32) {

        uint256 newSendCount = _initialState[1].add((_initialSendAcc == proofFields[2] ? 0 : 1));
        uint256 newLogCount = _initialState[2].add((_initialLogAcc == proofFields[3] ? 0 : 1));
        return
            ChallengeLib.assertionHash(
                _initialState[0].add(gasUsed),
                ChallengeLib.assertionRestHash(
                    totalMessagesRead,
                    proofFields[1],
                    proofFields[2],
                    newSendCount,
                    proofFields[3],
                    newLogCount
                )
            );
    }
}