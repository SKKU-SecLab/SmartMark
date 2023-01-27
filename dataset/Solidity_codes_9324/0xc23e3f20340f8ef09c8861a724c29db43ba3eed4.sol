

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


    function depositEth(uint256 maxSubmissionCost) external payable returns (uint256);


    function bridge() external view returns (IBridge);


    function pauseCreateRetryables() external;


    function unpauseCreateRetryables() external;


    function startRewriteAddress() external;


    function stopRewriteAddress() external;

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

        uint256 checkTime = gasUsed.add(avmGasSpeedLimitPerBlock.sub(1)).div(
            avmGasSpeedLimitPerBlock
        );

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

abstract contract WhitelistConsumer {
    address public whitelist;

    event WhitelistSourceUpdated(address newSource);

    modifier onlyWhitelisted() {
        if (whitelist != address(0)) {
            require(Whitelist(whitelist).isAllowed(msg.sender), "NOT_WHITELISTED");
        }
        _;
    }

    function updateWhitelistSource(address newSource) external {
        require(msg.sender == whitelist, "NOT_FROM_LIST");
        whitelist = newSource;
        emit WhitelistSourceUpdated(newSource);
    }
}

contract Whitelist {

    address public owner;
    mapping(address => bool) public isAllowed;

    event OwnerUpdated(address newOwner);
    event WhitelistUpgraded(address newWhitelist, address[] targets);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {

        require(msg.sender == owner, "ONLY_OWNER");
        _;
    }

    function setOwner(address newOwner) external onlyOwner {

        owner = newOwner;
        emit OwnerUpdated(newOwner);
    }

    function setWhitelist(address[] memory user, bool[] memory val) external onlyOwner {

        require(user.length == val.length, "INVALID_INPUT");

        for (uint256 i = 0; i < user.length; i++) {
            isAllowed[user[i]] = val[i];
        }
    }

    function triggerConsumers(address newWhitelist, address[] memory targets) external onlyOwner {

        for (uint256 i = 0; i < targets.length; i++) {
            WhitelistConsumer(targets[i]).updateWhitelistSource(newWhitelist);
        }
        emit WhitelistUpgraded(newWhitelist, targets);
    }
}// Apache-2.0


pragma solidity ^0.6.11;

library AddressAliasHelper {

    uint160 constant offset = uint160(0x1111000000000000000000000000000000001111);

    function applyL1ToL2Alias(address l1Address) internal pure returns (address l2Address) {

        l2Address = address(uint160(l1Address) + offset);
    }

    function undoL1ToL2Alias(address l2Address) internal pure returns (address l1Address) {

        l1Address = address(uint160(l2Address) - offset);
    }
}// MIT


pragma solidity ^0.6.11;

library BytesLib {

    function toAddress(bytes memory _bytes, uint256 _start) internal pure returns (address) {

        require(_bytes.length >= (_start + 20), "Read out of bounds");
        address tempAddress;

        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }

    function toUint8(bytes memory _bytes, uint256 _start) internal pure returns (uint8) {

        require(_bytes.length >= (_start + 1), "Read out of bounds");
        uint8 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x1), _start))
        }

        return tempUint;
    }

    function toUint(bytes memory _bytes, uint256 _start) internal pure returns (uint256) {

        require(_bytes.length >= (_start + 32), "Read out of bounds");
        uint256 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }

        return tempUint;
    }

    function toBytes32(bytes memory _bytes, uint256 _start) internal pure returns (bytes32) {

        require(_bytes.length >= (_start + 32), "Read out of bounds");
        bytes32 tempBytes32;

        assembly {
            tempBytes32 := mload(add(add(_bytes, 0x20), _start))
        }

        return tempBytes32;
    }
}
interface IBeacon {

    function implementation() external view returns (address);

}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract BeaconProxy is Proxy {

    bytes32 private constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    constructor(address beacon, bytes memory data) public payable {
        assert(_BEACON_SLOT == bytes32(uint256(keccak256("eip1967.proxy.beacon")) - 1));
        _setBeacon(beacon, data);
    }

    function _beacon() internal view virtual returns (address beacon) {

        bytes32 slot = _BEACON_SLOT;
        assembly {
            beacon := sload(slot)
        }
    }

    function _implementation() internal view virtual override returns (address) {

        return IBeacon(_beacon()).implementation();
    }

    function _setBeacon(address beacon, bytes memory data) internal virtual {

        require(
            Address.isContract(beacon),
            "BeaconProxy: beacon is not a contract"
        );
        require(
            Address.isContract(IBeacon(beacon).implementation()),
            "BeaconProxy: beacon implementation is not a contract"
        );
        bytes32 slot = _BEACON_SLOT;

        assembly {
            sstore(slot, beacon)
        }

        if (data.length > 0) {
            Address.functionDelegateCall(_implementation(), data, "BeaconProxy: function call failed");
        }
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract UpgradeableBeacon is IBeacon, Ownable {

    address private _implementation;

    event Upgraded(address indexed implementation);

    constructor(address implementation_) public {
        _setImplementation(implementation_);
    }

    function implementation() public view virtual override returns (address) {

        return _implementation;
    }

    function upgradeTo(address newImplementation) public virtual onlyOwner {

        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    function _setImplementation(address newImplementation) private {

        require(Address.isContract(newImplementation), "UpgradeableBeacon: implementation is not a contract");
        _implementation = newImplementation;
    }
}// Apache-2.0


pragma solidity ^0.6.11;




contract Outbox is IOutbox, Cloneable {

    using BytesLib for bytes;

    struct OutboxEntry {
        bytes32 root;
        mapping(bytes32 => bool) spentOutput;
    }

    bytes1 internal constant MSG_ROOT = 0;

    uint8 internal constant SendType_sendTxToL1 = 3;

    address public rollup;
    IBridge public bridge;

    mapping(uint256 => OutboxEntry) public outboxEntries;

    struct L2ToL1Context {
        uint128 l2Block;
        uint128 l1Block;
        uint128 timestamp;
        uint128 batchNum;
        bytes32 outputId;
        address sender;
    }
    L2ToL1Context internal context;
    uint128 public constant OUTBOX_VERSION = 1;

    function initialize(address _rollup, IBridge _bridge) external {

        require(rollup == address(0), "ALREADY_INIT");
        rollup = _rollup;
        bridge = _bridge;
    }

    function l2ToL1Sender() external view override returns (address) {

        return context.sender;
    }

    function l2ToL1Block() external view override returns (uint256) {

        return uint256(context.l2Block);
    }

    function l2ToL1EthBlock() external view override returns (uint256) {

        return uint256(context.l1Block);
    }

    function l2ToL1Timestamp() external view override returns (uint256) {

        return uint256(context.timestamp);
    }

    function l2ToL1BatchNum() external view override returns (uint256) {

        return uint256(context.batchNum);
    }

    function l2ToL1OutputId() external view override returns (bytes32) {

        return context.outputId;
    }

    function processOutgoingMessages(bytes calldata sendsData, uint256[] calldata sendLengths)
        external
        override
    {

        require(msg.sender == rollup, "ONLY_ROLLUP");
        uint256 messageCount = sendLengths.length;
        uint256 offset = 0;
        for (uint256 i = 0; i < messageCount; i++) {
            handleOutgoingMessage(bytes(sendsData[offset:offset + sendLengths[i]]));
            offset += sendLengths[i];
        }
    }

    function handleOutgoingMessage(bytes memory data) private {

        if (data[0] == MSG_ROOT) {
            require(data.length == 97, "BAD_LENGTH");
            uint256 batchNum = data.toUint(1);
            require(!outboxEntryExists(batchNum), "ENTRY_ALREADY_EXISTS");

            uint256 numInBatch = data.toUint(33);
            bytes32 outputRoot = data.toBytes32(65);

            OutboxEntry memory newOutboxEntry = OutboxEntry(outputRoot);
            outboxEntries[batchNum] = newOutboxEntry;
            emit OutboxEntryCreated(batchNum, batchNum, outputRoot, numInBatch);
        }
    }

    function executeTransaction(
        uint256 batchNum,
        bytes32[] calldata proof,
        uint256 index,
        address l2Sender,
        address destAddr,
        uint256 l2Block,
        uint256 l1Block,
        uint256 l2Timestamp,
        uint256 amount,
        bytes calldata calldataForL1
    ) external virtual {

        bytes32 outputId;
        {
            bytes32 userTx = calculateItemHash(
                l2Sender,
                destAddr,
                l2Block,
                l1Block,
                l2Timestamp,
                amount,
                calldataForL1
            );

            outputId = recordOutputAsSpent(batchNum, proof, index, userTx);
            emit OutBoxTransactionExecuted(destAddr, l2Sender, batchNum, index);
        }

        L2ToL1Context memory prevContext = context;

        context = L2ToL1Context({
            sender: l2Sender,
            l2Block: uint128(l2Block),
            l1Block: uint128(l1Block),
            timestamp: uint128(l2Timestamp),
            batchNum: uint128(batchNum),
            outputId: outputId
        });

        executeBridgeCall(destAddr, amount, calldataForL1);

        context = prevContext;
    }

    function recordOutputAsSpent(
        uint256 batchNum,
        bytes32[] memory proof,
        uint256 path,
        bytes32 item
    ) internal returns (bytes32) {

        require(proof.length < 256, "PROOF_TOO_LONG");
        require(path < 2**proof.length, "PATH_NOT_MINIMAL");

        bytes32 calcRoot = calculateMerkleRoot(proof, path, item);
        OutboxEntry storage outboxEntry = outboxEntries[batchNum];
        require(outboxEntry.root != bytes32(0), "NO_OUTBOX_ENTRY");

        bytes32 uniqueKey = keccak256(abi.encodePacked(path, proof.length));

        require(!outboxEntry.spentOutput[uniqueKey], "ALREADY_SPENT");
        require(calcRoot == outboxEntry.root, "BAD_ROOT");

        outboxEntry.spentOutput[uniqueKey] = true;
        return uniqueKey;
    }

    function executeBridgeCall(
        address destAddr,
        uint256 amount,
        bytes memory data
    ) internal {

        (bool success, bytes memory returndata) = bridge.executeCall(destAddr, amount, data);
        if (!success) {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert("BRIDGE_CALL_FAILED");
            }
        }
    }

    function calculateItemHash(
        address l2Sender,
        address destAddr,
        uint256 l2Block,
        uint256 l1Block,
        uint256 l2Timestamp,
        uint256 amount,
        bytes calldata calldataForL1
    ) public pure returns (bytes32) {

        return
            keccak256(
                abi.encodePacked(
                    SendType_sendTxToL1,
                    uint256(uint160(bytes20(l2Sender))),
                    uint256(uint160(bytes20(destAddr))),
                    l2Block,
                    l1Block,
                    l2Timestamp,
                    amount,
                    calldataForL1
                )
            );
    }

    function calculateMerkleRoot(
        bytes32[] memory proof,
        uint256 path,
        bytes32 item
    ) public pure returns (bytes32) {

        return MerkleLib.calculateRoot(proof, path, keccak256(abi.encodePacked(item)));
    }

    function outboxEntryExists(uint256 batchNum) public view override returns (bool) {

        return outboxEntries[batchNum].root != bytes32(0);
    }
}// MIT

pragma solidity >=0.6.2 <0.8.0;

library AddressUpgradeable {

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

pragma solidity >=0.4.24 <0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    uint256[49] private __gap;
}// Apache-2.0


pragma solidity ^0.6.11;



contract Bridge is OwnableUpgradeable, IBridge {

    using Address for address;
    struct InOutInfo {
        uint256 index;
        bool allowed;
    }

    mapping(address => InOutInfo) private allowedInboxesMap;
    mapping(address => InOutInfo) private allowedOutboxesMap;

    address[] public allowedInboxList;
    address[] public allowedOutboxList;

    address public override activeOutbox;

    bytes32[] public override inboxAccs;

    function initialize() external initializer {

        __Ownable_init();
    }

    function allowedInboxes(address inbox) external view override returns (bool) {

        return allowedInboxesMap[inbox].allowed;
    }

    function allowedOutboxes(address outbox) external view override returns (bool) {

        return allowedOutboxesMap[outbox].allowed;
    }

    function deliverMessageToInbox(
        uint8 kind,
        address sender,
        bytes32 messageDataHash
    ) external payable override returns (uint256) {

        require(allowedInboxesMap[msg.sender].allowed, "NOT_FROM_INBOX");
        return
            addMessageToInbox(
                kind,
                sender,
                block.number,
                block.timestamp, // solhint-disable-line not-rely-on-time
                tx.gasprice,
                messageDataHash
            );
    }

    function addMessageToInbox(
        uint8 kind,
        address sender,
        uint256 blockNumber,
        uint256 blockTimestamp,
        uint256 gasPrice,
        bytes32 messageDataHash
    ) internal returns (uint256) {

        uint256 count = inboxAccs.length;
        bytes32 messageHash = Messages.messageHash(
            kind,
            sender,
            blockNumber,
            blockTimestamp,
            count,
            gasPrice,
            messageDataHash
        );
        bytes32 prevAcc = 0;
        if (count > 0) {
            prevAcc = inboxAccs[count - 1];
        }
        inboxAccs.push(Messages.addMessageToInbox(prevAcc, messageHash));
        emit MessageDelivered(count, prevAcc, msg.sender, kind, sender, messageDataHash);
        return count;
    }

    function executeCall(
        address destAddr,
        uint256 amount,
        bytes calldata data
    ) external override returns (bool success, bytes memory returnData) {

        require(allowedOutboxesMap[msg.sender].allowed, "NOT_FROM_OUTBOX");
        if (data.length > 0) require(destAddr.isContract(), "NO_CODE_AT_DEST");
        address currentOutbox = activeOutbox;
        activeOutbox = msg.sender;
        (success, returnData) = destAddr.call{ value: amount }(data);
        activeOutbox = currentOutbox;
        emit BridgeCallTriggered(msg.sender, destAddr, amount, data);
    }

    function setInbox(address inbox, bool enabled) external override onlyOwner {

        InOutInfo storage info = allowedInboxesMap[inbox];
        bool alreadyEnabled = info.allowed;
        emit InboxToggle(inbox, enabled);
        if ((alreadyEnabled && enabled) || (!alreadyEnabled && !enabled)) {
            return;
        }
        if (enabled) {
            allowedInboxesMap[inbox] = InOutInfo(allowedInboxList.length, true);
            allowedInboxList.push(inbox);
        } else {
            allowedInboxList[info.index] = allowedInboxList[allowedInboxList.length - 1];
            allowedInboxesMap[allowedInboxList[info.index]].index = info.index;
            allowedInboxList.pop();
            delete allowedInboxesMap[inbox];
        }
    }

    function setOutbox(address outbox, bool enabled) external override onlyOwner {

        InOutInfo storage info = allowedOutboxesMap[outbox];
        bool alreadyEnabled = info.allowed;
        emit OutboxToggle(outbox, enabled);
        if ((alreadyEnabled && enabled) || (!alreadyEnabled && !enabled)) {
            return;
        }
        if (enabled) {
            allowedOutboxesMap[outbox] = InOutInfo(allowedOutboxList.length, true);
            allowedOutboxList.push(outbox);
        } else {
            allowedOutboxList[info.index] = allowedOutboxList[allowedOutboxList.length - 1];
            allowedOutboxesMap[allowedOutboxList[info.index]].index = info.index;
            allowedOutboxList.pop();
            delete allowedOutboxesMap[outbox];
        }
    }

    function messageCount() external view override returns (uint256) {

        return inboxAccs.length;
    }
}// Apache-2.0


pragma solidity ^0.6.11;




contract Inbox is IInbox, WhitelistConsumer, Cloneable {

    uint8 internal constant ETH_TRANSFER = 0;
    uint8 internal constant L2_MSG = 3;
    uint8 internal constant L1MessageType_L2FundedByL1 = 7;
    uint8 internal constant L1MessageType_submitRetryableTx = 9;

    uint8 internal constant L2MessageType_unsignedEOATx = 0;
    uint8 internal constant L2MessageType_unsignedContractTx = 1;

    IBridge public override bridge;

    bool public isCreateRetryablePaused;
    bool public shouldRewriteSender;

    function initialize(IBridge _bridge, address _whitelist) external {

        require(address(bridge) == address(0), "ALREADY_INIT");
        bridge = _bridge;
        WhitelistConsumer.whitelist = _whitelist;
    }

    function sendL2MessageFromOrigin(bytes calldata messageData)
        external
        onlyWhitelisted
        returns (uint256)
    {

        require(msg.sender == tx.origin, "origin only");
        uint256 msgNum = deliverToBridge(L2_MSG, msg.sender, keccak256(messageData));
        emit InboxMessageDeliveredFromOrigin(msgNum);
        return msgNum;
    }

    function sendL2Message(bytes calldata messageData)
        external
        override
        onlyWhitelisted
        returns (uint256)
    {

        uint256 msgNum = deliverToBridge(L2_MSG, msg.sender, keccak256(messageData));
        emit InboxMessageDelivered(msgNum, messageData);
        return msgNum;
    }

    function sendL1FundedUnsignedTransaction(
        uint256 maxGas,
        uint256 gasPriceBid,
        uint256 nonce,
        address destAddr,
        bytes calldata data
    ) external payable virtual override onlyWhitelisted returns (uint256) {

        return
            _deliverMessage(
                L1MessageType_L2FundedByL1,
                msg.sender,
                abi.encodePacked(
                    L2MessageType_unsignedEOATx,
                    maxGas,
                    gasPriceBid,
                    nonce,
                    uint256(uint160(bytes20(destAddr))),
                    msg.value,
                    data
                )
            );
    }

    function sendL1FundedContractTransaction(
        uint256 maxGas,
        uint256 gasPriceBid,
        address destAddr,
        bytes calldata data
    ) external payable virtual override onlyWhitelisted returns (uint256) {

        return
            _deliverMessage(
                L1MessageType_L2FundedByL1,
                msg.sender,
                abi.encodePacked(
                    L2MessageType_unsignedContractTx,
                    maxGas,
                    gasPriceBid,
                    uint256(uint160(bytes20(destAddr))),
                    msg.value,
                    data
                )
            );
    }

    function sendUnsignedTransaction(
        uint256 maxGas,
        uint256 gasPriceBid,
        uint256 nonce,
        address destAddr,
        uint256 amount,
        bytes calldata data
    ) external virtual override onlyWhitelisted returns (uint256) {

        return
            _deliverMessage(
                L2_MSG,
                msg.sender,
                abi.encodePacked(
                    L2MessageType_unsignedEOATx,
                    maxGas,
                    gasPriceBid,
                    nonce,
                    uint256(uint160(bytes20(destAddr))),
                    amount,
                    data
                )
            );
    }

    function sendContractTransaction(
        uint256 maxGas,
        uint256 gasPriceBid,
        address destAddr,
        uint256 amount,
        bytes calldata data
    ) external virtual override onlyWhitelisted returns (uint256) {

        return
            _deliverMessage(
                L2_MSG,
                msg.sender,
                abi.encodePacked(
                    L2MessageType_unsignedContractTx,
                    maxGas,
                    gasPriceBid,
                    uint256(uint160(bytes20(destAddr))),
                    amount,
                    data
                )
            );
    }

    modifier onlyOwner() {

        address rollup = Bridge(address(bridge)).owner();
        address owner = RollupBase(rollup).owner();
        require(msg.sender == owner, "NOT_ROLLUP");
        _;
    }

    event PauseToggled(bool enabled);

    function pauseCreateRetryables() external override onlyOwner {

        require(!isCreateRetryablePaused, "ALREADY_PAUSED");
        isCreateRetryablePaused = true;
        emit PauseToggled(true);
    }

    function unpauseCreateRetryables() external override onlyOwner {

        require(isCreateRetryablePaused, "NOT_PAUSED");
        isCreateRetryablePaused = false;
        emit PauseToggled(false);
    }

    event RewriteToggled(bool enabled);

    function startRewriteAddress() external override onlyOwner {

        require(!shouldRewriteSender, "ALREADY_REWRITING");
        shouldRewriteSender = true;
        emit RewriteToggled(true);
    }

    function stopRewriteAddress() external override onlyOwner {

        require(shouldRewriteSender, "NOT_REWRITING");
        shouldRewriteSender = false;
        emit RewriteToggled(false);
    }

    function depositEth(uint256 maxSubmissionCost)
        external
        payable
        virtual
        override
        onlyWhitelisted
        returns (uint256)
    {

        require(!isCreateRetryablePaused, "CREATE_RETRYABLES_PAUSED");
        address sender = msg.sender;
        address destinationAddress = msg.sender;

        if (shouldRewriteSender) {
            if (!Address.isContract(sender) && tx.origin == msg.sender) {
                sender = AddressAliasHelper.undoL1ToL2Alias(sender);
            } else {
                destinationAddress = AddressAliasHelper.applyL1ToL2Alias(destinationAddress);
            }
        }

        return
            _deliverMessage(
                L1MessageType_submitRetryableTx,
                sender,
                abi.encodePacked(
                    uint256(uint160(bytes20(destinationAddress))),
                    uint256(0),
                    msg.value,
                    maxSubmissionCost,
                    uint256(uint160(bytes20(destinationAddress))),
                    uint256(uint160(bytes20(destinationAddress))),
                    uint256(0),
                    uint256(0),
                    uint256(0),
                    ""
                )
            );
    }

    function createRetryableTicketNoRefundAliasRewrite(
        address destAddr,
        uint256 l2CallValue,
        uint256 maxSubmissionCost,
        address excessFeeRefundAddress,
        address callValueRefundAddress,
        uint256 maxGas,
        uint256 gasPriceBid,
        bytes calldata data
    ) public payable virtual onlyWhitelisted returns (uint256) {

        require(!isCreateRetryablePaused, "CREATE_RETRYABLES_PAUSED");

        return
            _deliverMessage(
                L1MessageType_submitRetryableTx,
                msg.sender,
                abi.encodePacked(
                    uint256(uint160(bytes20(destAddr))),
                    l2CallValue,
                    msg.value,
                    maxSubmissionCost,
                    uint256(uint160(bytes20(excessFeeRefundAddress))),
                    uint256(uint160(bytes20(callValueRefundAddress))),
                    maxGas,
                    gasPriceBid,
                    data.length,
                    data
                )
            );
    }

    function createRetryableTicket(
        address destAddr,
        uint256 l2CallValue,
        uint256 maxSubmissionCost,
        address excessFeeRefundAddress,
        address callValueRefundAddress,
        uint256 maxGas,
        uint256 gasPriceBid,
        bytes calldata data
    ) external payable virtual override onlyWhitelisted returns (uint256) {

        require(msg.value >= maxSubmissionCost + l2CallValue, "insufficient value");

        if (shouldRewriteSender && Address.isContract(excessFeeRefundAddress)) {
            excessFeeRefundAddress = AddressAliasHelper.applyL1ToL2Alias(excessFeeRefundAddress);
        }
        if (shouldRewriteSender && Address.isContract(callValueRefundAddress)) {
            callValueRefundAddress = AddressAliasHelper.applyL1ToL2Alias(callValueRefundAddress);
        }

        return
            createRetryableTicketNoRefundAliasRewrite(
                destAddr,
                l2CallValue,
                maxSubmissionCost,
                excessFeeRefundAddress,
                callValueRefundAddress,
                maxGas,
                gasPriceBid,
                data
            );
    }

    function unsafeCreateRetryableTicket(
        address destAddr,
        uint256 l2CallValue,
        uint256 maxSubmissionCost,
        address excessFeeRefundAddress,
        address callValueRefundAddress,
        uint256 maxGas,
        uint256 gasPriceBid,
        bytes calldata data
    ) external payable virtual returns (uint256) {

        return
            createRetryableTicketNoRefundAliasRewrite(
                destAddr,
                l2CallValue,
                maxSubmissionCost,
                excessFeeRefundAddress,
                callValueRefundAddress,
                maxGas,
                gasPriceBid,
                data
            );
    }

    function _deliverMessage(
        uint8 _kind,
        address _sender,
        bytes memory _messageData
    ) internal returns (uint256) {

        uint256 msgNum = deliverToBridge(_kind, _sender, keccak256(_messageData));
        emit InboxMessageDelivered(msgNum, _messageData);
        return msgNum;
    }

    function deliverToBridge(
        uint8 kind,
        address sender,
        bytes32 messageDataHash
    ) internal returns (uint256) {

        return bridge.deliverMessageToInbox{ value: msg.value }(kind, sender, messageDataHash);
    }
}