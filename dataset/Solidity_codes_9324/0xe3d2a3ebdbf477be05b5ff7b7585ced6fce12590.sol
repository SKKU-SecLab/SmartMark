pragma solidity >=0.7.0 <0.9.0;

contract Enum {

    enum Operation {Call, DelegateCall}
}// LGPL-3.0-only

pragma solidity >=0.7.0 <0.9.0;


interface IAvatar {

    function enableModule(address module) external;


    function disableModule(address prevModule, address module) external;


    function execTransactionFromModule(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation
    ) external returns (bool success);


    function execTransactionFromModuleReturnData(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation
    ) external returns (bool success, bytes memory returnData);


    function isModuleEnabled(address module) external view returns (bool);


    function getModulesPaginated(address start, uint256 pageSize)
        external
        view
        returns (address[] memory array, address next);

}// MIT

pragma solidity ^0.8.0;

abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}// LGPL-3.0-only

pragma solidity >=0.7.0 <0.9.0;


abstract contract FactoryFriendly is OwnableUpgradeable {
    function setUp(bytes memory initializeParams) public virtual;
}// LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;


interface IGuard {

    function checkTransaction(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation,
        uint256 safeTxGas,
        uint256 baseGas,
        uint256 gasPrice,
        address gasToken,
        address payable refundReceiver,
        bytes memory signatures,
        address msgSender
    ) external;


    function checkAfterExecution(bytes32 txHash, bool success) external;

}// LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;


abstract contract BaseGuard is IERC165 {
    function supportsInterface(bytes4 interfaceId)
        external
        pure
        override
        returns (bool)
    {
        return
            interfaceId == type(IGuard).interfaceId || // 0xe6d7a83a
            interfaceId == type(IERC165).interfaceId; // 0x01ffc9a7
    }

    function checkTransaction(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation,
        uint256 safeTxGas,
        uint256 baseGas,
        uint256 gasPrice,
        address gasToken,
        address payable refundReceiver,
        bytes memory signatures,
        address msgSender
    ) external virtual;

    function checkAfterExecution(bytes32 txHash, bool success) external virtual;
}// LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;


contract Guardable is OwnableUpgradeable {

    event ChangedGuard(address guard);

    address public guard;

    function setGuard(address _guard) external onlyOwner {

        if (_guard != address(0)) {
            require(
                BaseGuard(_guard).supportsInterface(type(IGuard).interfaceId),
                "Guard does not implement IERC165"
            );
        }
        guard = _guard;
        emit ChangedGuard(guard);
    }

    function getGuard() external view returns (address _guard) {

        return guard;
    }
}// LGPL-3.0-only

pragma solidity >=0.7.0 <0.9.0;


abstract contract Module is FactoryFriendly, Guardable {
    event AvatarSet(address indexed previousAvatar, address indexed newAvatar);
    event TargetSet(address indexed previousTarget, address indexed newTarget);

    address public avatar;
    address public target;

    function setAvatar(address _avatar) public onlyOwner {
        address previousAvatar = avatar;
        avatar = _avatar;
        emit AvatarSet(previousAvatar, _avatar);
    }

    function setTarget(address _target) public onlyOwner {
        address previousTarget = target;
        target = _target;
        emit TargetSet(previousTarget, _target);
    }

    function exec(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation
    ) internal returns (bool success) {
        if (guard != address(0)) {
            IGuard(guard).checkTransaction(
                to,
                value,
                data,
                operation,
                0,
                0,
                0,
                address(0),
                payable(0),
                bytes("0x"),
                address(0)
            );
        }
        success = IAvatar(target).execTransactionFromModule(
            to,
            value,
            data,
            operation
        );
        if (guard != address(0)) {
            IGuard(guard).checkAfterExecution(bytes32("0x"), success);
        }
        return success;
    }

    function execAndReturnData(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation
    ) internal returns (bool success, bytes memory returnData) {
        if (guard != address(0)) {
            IGuard(guard).checkTransaction(
                to,
                value,
                data,
                operation,
                0,
                0,
                0,
                address(0),
                payable(0),
                bytes("0x"),
                address(0)
            );
        }
        (success, returnData) = IAvatar(target)
            .execTransactionFromModuleReturnData(to, value, data, operation);
        if (guard != address(0)) {
            IGuard(guard).checkAfterExecution(bytes32("0x"), success);
        }
        return (success, returnData);
    }
}// MIT
pragma solidity >=0.8.0;

interface ITellor{

    function addresses(bytes32) external view returns(address);

    function uints(bytes32) external view returns(uint256);

    function burn(uint256 _amount) external;

    function changeDeity(address _newDeity) external;

    function changeOwner(address _newOwner) external;

    function changeTellorContract(address _tContract) external;

    function changeControllerContract(address _newController) external;

    function changeGovernanceContract(address _newGovernance) external;

    function changeOracleContract(address _newOracle) external;

    function changeTreasuryContract(address _newTreasury) external;

    function changeUint(bytes32 _target, uint256 _amount) external;

    function migrate() external;

    function mint(address _reciever, uint256 _amount) external;

    function init() external;

    function getAllDisputeVars(uint256 _disputeId) external view returns (bytes32,bool,bool,bool,address,address,address,uint256[9] memory,int256);

    function getDisputeIdByDisputeHash(bytes32 _hash) external view returns (uint256);

    function getDisputeUintVars(uint256 _disputeId, bytes32 _data) external view returns(uint256);

    function getLastNewValueById(uint256 _requestId) external view returns (uint256, bool);

    function retrieveData(uint256 _requestId, uint256 _timestamp) external view returns (uint256);

    function getNewValueCountbyRequestId(uint256 _requestId) external view returns (uint256);

    function getAddressVars(bytes32 _data) external view returns (address);

    function getUintVar(bytes32 _data) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function isMigrated(address _addy) external view returns (bool);

    function allowance(address _user, address _spender) external view  returns (uint256);

    function allowedToTrade(address _user, uint256 _amount) external view returns (bool);

    function approve(address _spender, uint256 _amount) external returns (bool);

    function approveAndTransferFrom(address _from, address _to, uint256 _amount) external returns(bool);

    function balanceOf(address _user) external view returns (uint256);

    function balanceOfAt(address _user, uint256 _blockNumber)external view returns (uint256);

    function transfer(address _to, uint256 _amount)external returns (bool success);

    function transferFrom(address _from,address _to,uint256 _amount) external returns (bool success) ;

    function depositStake() external;

    function requestStakingWithdraw() external;

    function withdrawStake() external;

    function changeStakingStatus(address _reporter, uint _status) external;

    function slashReporter(address _reporter, address _disputer) external;

    function getStakerInfo(address _staker) external view returns (uint256, uint256);

    function getTimestampbyRequestIDandIndex(uint256 _requestId, uint256 _index) external view returns (uint256);

    function getNewCurrentVariables()external view returns (bytes32 _c,uint256[5] memory _r,uint256 _d,uint256 _t);

    function getNewValueCountbyQueryId(bytes32 _queryId) external view returns(uint256);

    function getTimestampbyQueryIdandIndex(bytes32 _queryId, uint256 _index) external view returns(uint256);

    function retrieveData(bytes32 _queryId, uint256 _timestamp) external view returns(bytes memory);

    enum VoteResult {FAILED,PASSED,INVALID}
    function setApprovedFunction(bytes4 _func, bool _val) external;

    function beginDispute(bytes32 _queryId,uint256 _timestamp) external;

    function delegate(address _delegate) external;

    function delegateOfAt(address _user, uint256 _blockNumber) external view returns (address);

    function executeVote(uint256 _disputeId) external;

    function proposeVote(address _contract,bytes4 _function, bytes calldata _data, uint256 _timestamp) external;

    function tallyVotes(uint256 _disputeId) external;

    function governance() external view returns (address);

    function updateMinDisputeFee() external;

    function verify() external pure returns(uint);

    function vote(uint256 _disputeId, bool _supports, bool _invalidQuery) external;

    function voteFor(address[] calldata _addys,uint256 _disputeId, bool _supports, bool _invalidQuery) external;

    function getDelegateInfo(address _holder) external view returns(address,uint);

    function isFunctionApproved(bytes4 _func) external view returns(bool);

    function isApprovedGovernanceContract(address _contract) external returns (bool);

    function getVoteRounds(bytes32 _hash) external view returns(uint256[] memory);

    function getVoteCount() external view returns(uint256);

    function getVoteInfo(uint256 _disputeId) external view returns(bytes32,uint256[9] memory,bool[2] memory,VoteResult,bytes memory,bytes4,address[2] memory);

    function getDisputeInfo(uint256 _disputeId) external view returns(uint256,uint256,bytes memory, address);

    function getOpenDisputesOnId(bytes32 _queryId) external view returns(uint256);

    function didVote(uint256 _disputeId, address _voter) external view returns(bool);

    function getReportTimestampByIndex(bytes32 _queryId, uint256 _index) external view returns(uint256);

    function getValueByTimestamp(bytes32 _queryId, uint256 _timestamp) external view returns(bytes memory);

    function getBlockNumberByTimestamp(bytes32 _queryId, uint256 _timestamp) external view returns(uint256);

    function getReportingLock() external view returns(uint256);

    function getReporterByTimestamp(bytes32 _queryId, uint256 _timestamp) external view returns(address);

    function reportingLock() external view returns(uint256);

    function removeValue(bytes32 _queryId, uint256 _timestamp) external;

    function getReportsSubmittedByAddress(address _reporter) external view returns(uint256);

    function getTipsByUser(address _user) external view returns(uint256);

    function tipQuery(bytes32 _queryId, uint256 _tip, bytes memory _queryData) external;

    function submitValue(bytes32 _queryId, bytes calldata _value, uint256 _nonce, bytes memory _queryData) external;

    function burnTips() external;

    function changeReportingLock(uint256 _newReportingLock) external;

    function changeTimeBasedReward(uint256 _newTimeBasedReward) external;

    function getReporterLastTimestamp(address _reporter) external view returns(uint256);

    function getTipsById(bytes32 _queryId) external view returns(uint256);

    function getTimeBasedReward() external view returns(uint256);

    function getTimestampCountById(bytes32 _queryId) external view returns(uint256);

    function getTimestampIndexByTimestamp(bytes32 _queryId, uint256 _timestamp) external view returns(uint256);

    function getCurrentReward(bytes32 _queryId) external view returns(uint256, uint256);

    function getCurrentValue(bytes32 _queryId) external view returns(bytes memory);

    function getTimeOfLastNewValue() external view returns(uint256);

    function issueTreasury(uint256 _maxAmount, uint256 _rate, uint256 _duration) external;

    function payTreasury(address _investor,uint256 _id) external;

    function buyTreasury(uint256 _id,uint256 _amount) external;

    function getTreasuryDetails(uint256 _id) external view returns(uint256,uint256,uint256,uint256);

    function getTreasuryFundsByUser(address _user) external view returns(uint256);

    function getTreasuryAccount(uint256 _id, address _investor) external view returns(uint256,uint256,bool);

    function getTreasuryCount() external view returns(uint256);

    function getTreasuryOwners(uint256 _id) external view returns(address[] memory);

    function wasPaid(uint256 _id, address _investor) external view returns(bool);

    function changeAddressVar(bytes32 _id, address _addy) external;


    function killContract() external;

    function migrateFor(address _destination,uint256 _amount) external;

    function rescue51PercentAttack(address _tokenHolder) external;

    function rescueBrokenDataReporting() external;

    function rescueFailedUpdate() external;

}// MIT
pragma solidity >=0.8.0;


contract UsingTellor {

    ITellor public tellor;

    constructor(address payable _tellor) {
        tellor = ITellor(_tellor);
    }

    function getCurrentValue(bytes32 _queryId)
        public
        view
        returns (
            bool _ifRetrieve,
            bytes memory _value,
            uint256 _timestampRetrieved
        )
    {

        uint256 _count = getNewValueCountbyQueryId(_queryId);

        if (_count == 0) {
            return (false, bytes(""), 0);
        }
        uint256 _time = getTimestampbyQueryIdandIndex(_queryId, _count - 1);
        _value = retrieveData(_queryId, _time);
        if (keccak256(_value) != keccak256(bytes("")))
            return (true, _value, _time);
        return (false, bytes(""), _time);
    }

    function getDataBefore(bytes32 _queryId, uint256 _timestamp)
        public
        view
        returns (
            bool _ifRetrieve,
            bytes memory _value,
            uint256 _timestampRetrieved
        )
    {

        (bool _found, uint256 _index) = getIndexForDataBefore(
            _queryId,
            _timestamp
        );
        if (!_found) return (false, bytes(""), 0);
        uint256 _time = getTimestampbyQueryIdandIndex(_queryId, _index);
        _value = retrieveData(_queryId, _time);
        if (keccak256(_value) != keccak256(bytes("")))
            return (true, _value, _time);
        return (false, bytes(""), 0);
    }

    function getIndexForDataBefore(bytes32 _queryId, uint256 _timestamp)
        public
        view
        returns (bool _found, uint256 _index)
    {

        uint256 _count = getNewValueCountbyQueryId(_queryId);

        if (_count > 0) {
            uint256 middle;
            uint256 start = 0;
            uint256 end = _count - 1;
            uint256 _time;

            _time = getTimestampbyQueryIdandIndex(_queryId, start);
            if (_time >= _timestamp) return (false, 0);
            _time = getTimestampbyQueryIdandIndex(_queryId, end);
            if (_time < _timestamp) return (true, end);

            while (true) {
                middle = (end - start) / 2 + 1 + start;
                _time = getTimestampbyQueryIdandIndex(_queryId, middle);
                if (_time < _timestamp) {
                    uint256 _nextTime = getTimestampbyQueryIdandIndex(
                        _queryId,
                        middle + 1
                    );
                    if (_nextTime >= _timestamp) {
                        return (true, middle);
                    } else {
                        start = middle + 1;
                    }
                } else {
                    uint256 _prevTime = getTimestampbyQueryIdandIndex(
                        _queryId,
                        middle - 1
                    );
                    if (_prevTime < _timestamp) {
                        return (true, middle - 1);
                    } else {
                        end = middle - 1;
                    }
                }
            }
        }
        return (false, 0);
    }

    function getNewValueCountbyQueryId(bytes32 _queryId)
        public
        view
        returns (uint256)
    {

        if (
            tellor == ITellor(0x18431fd88adF138e8b979A7246eb58EA7126ea16) ||
            tellor == ITellor(0xe8218cACb0a5421BC6409e498d9f8CC8869945ea)
        ) {
            return tellor.getTimestampCountById(_queryId);
        } else {
            return tellor.getNewValueCountbyQueryId(_queryId);
        }
    }

    function getTimestampbyQueryIdandIndex(bytes32 _queryId, uint256 _index)
        public
        view
        returns (uint256)
    {

        if (
            tellor == ITellor(0x18431fd88adF138e8b979A7246eb58EA7126ea16) ||
            tellor == ITellor(0xe8218cACb0a5421BC6409e498d9f8CC8869945ea)
        ) {
            return tellor.getReportTimestampByIndex(_queryId, _index);
        } else {
            return tellor.getTimestampbyQueryIdandIndex(_queryId, _index);
        }
    }

    function isInDispute(bytes32 _queryId, uint256 _timestamp)
        public
        view
        returns (bool)
    {

        ITellor _governance;
        if (
            tellor == ITellor(0x18431fd88adF138e8b979A7246eb58EA7126ea16) ||
            tellor == ITellor(0xe8218cACb0a5421BC6409e498d9f8CC8869945ea)
        ) {
            ITellor _newTellor = ITellor(
                0x88dF592F8eb5D7Bd38bFeF7dEb0fBc02cf3778a0
            );
            _governance = ITellor(
                _newTellor.addresses(
                    0xefa19baa864049f50491093580c5433e97e8d5e41f8db1a61108b4fa44cacd93
                )
            );
        } else {
            _governance = ITellor(tellor.governance());
        }
        return
            _governance
                .getVoteRounds(
                    keccak256(abi.encodePacked(_queryId, _timestamp))
                )
                .length > 0;
    }

    function retrieveData(bytes32 _queryId, uint256 _timestamp)
        public
        view
        returns (bytes memory)
    {

        if (
            tellor == ITellor(0x18431fd88adF138e8b979A7246eb58EA7126ea16) ||
            tellor == ITellor(0xe8218cACb0a5421BC6409e498d9f8CC8869945ea)
        ) {
            return tellor.getValueByTimestamp(_queryId, _timestamp);
        } else {
            return tellor.retrieveData(_queryId, _timestamp);
        }
    }
}// LGPL-3.0-only
pragma solidity >=0.8.0;


contract TellorModule is Module, UsingTellor {

    event ProposalAdded(bytes32 indexed queryId, string indexed proposalId);
    event TellorModuleSetup(
        address indexed initiator,
        address indexed avatar,
        address target
    );
    bool private _initialized;
    uint32 public resultExpiration;
    bytes32 public constant DOMAIN_SEPARATOR_TYPEHASH =
        0x47e79534a245952e8b16893a336b85a3d9ea9fa8c573f3d803afb92a79469218;
    mapping(bytes32 => mapping(bytes32 => bool))
        public executedProposalTransactions;
    bytes32 public constant INVALIDATED =
        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
    uint32 public cooldown;
    mapping(bytes32 => bytes32) public queryIds;
    bytes32 public constant TRANSACTION_TYPEHASH =
        0x72e9670a7ee00f5fbf1049b8c38e3f22fab7e9b85029e85cf9412f17fdd5c2ad;

    constructor(
        address _avatar,
        address _target,
        address payable _tellorAddress,
        uint32 _cooldown,
        uint32 _expiration
    ) UsingTellor(_tellorAddress) {
        bytes memory initParams = abi.encode(
            _avatar,
            _target,
            _cooldown,
            _expiration
        );
        setUp(initParams);
    }

    function addProposal(string memory _proposalId, bytes32[] memory _txHashes)
        public
    {

        string memory _proposal = buildProposal(_proposalId, _txHashes);
        bytes32 _proposalHash = keccak256(bytes(_proposal));
        require(
            queryIds[_proposalHash] == bytes32(0),
            "Proposal has already been submitted"
        );
        bytes32 _queryId = getQueryId(_proposalId);
        queryIds[_proposalHash] = _queryId;
        emit ProposalAdded(_queryId, _proposalId);
    }

    function buildProposal(
        string memory _proposalId,
        bytes32[] memory _txHashes
    ) public pure returns (string memory) {

        string memory _txsHash = _bytes32ToAsciiString(
            keccak256(abi.encodePacked(_txHashes))
        );
        return
            string(abi.encodePacked(_proposalId, bytes3(0xe2909f), _txsHash));
    }

    function executeProposal(
        string memory _proposalId,
        bytes32[] memory _txHashes,
        address _to,
        uint256 _value,
        bytes memory _data,
        Enum.Operation _operation
    ) public {

        executeProposalWithIndex(
            _proposalId,
            _txHashes,
            _to,
            _value,
            _data,
            _operation,
            0
        );
    }

    function executeProposalWithIndex(
        string memory _proposalId,
        bytes32[] memory _txHashes,
        address _to,
        uint256 _value,
        bytes memory _data,
        Enum.Operation _operation,
        uint256 _txIndex
    ) public {

        bytes32 _proposalHash = keccak256(
            bytes(buildProposal(_proposalId, _txHashes))
        );
        bytes32 _queryId = queryIds[_proposalHash];
        require(
            _queryId != bytes32(0),
            "No query id set for provided proposal"
        );
        require(_queryId != INVALIDATED, "Proposal has been invalidated");
        bytes32 _txHash = getTransactionHash(
            _to,
            _value,
            _data,
            _operation,
            _txIndex
        );
        require(_txHashes[_txIndex] == _txHash, "Unexpected transaction hash");
        (
            bool _ifRetrieve,
            bytes memory _valueRetrieved,
            uint256 _timestampReceived
        ) = getDataBefore(_queryId, block.timestamp);
        require(_ifRetrieve, "Data not retrieved");
        require(
            _timestampReceived + uint256(cooldown) < block.timestamp,
            "Wait for additional cooldown"
        );
        bool _didPass = abi.decode(_valueRetrieved, (bool));
        require(_didPass, "Transaction was not approved");
        uint32 _expiration = resultExpiration;
        require(
            _expiration == 0 ||
                _timestampReceived + uint256(_expiration) >= block.timestamp,
            "Result has expired"
        );
        require(
            _txIndex == 0 ||
                executedProposalTransactions[_proposalHash][
                    _txHashes[_txIndex - 1]
                ],
            "Previous transaction not executed yet"
        );
        require(
            !executedProposalTransactions[_proposalHash][_txHash],
            "Cannot execute transaction again"
        );
        executedProposalTransactions[_proposalHash][_txHash] = true;
        require(
            exec(_to, _value, _data, _operation),
            "Module transaction failed"
        );
    }

    function getQueryId(string memory _proposalId)
        public
        pure
        returns (bytes32)
    {

        bytes32 _queryId = keccak256(
            abi.encode("Snapshot", abi.encode(_proposalId))
        );
        return _queryId;
    }

    function getChainId() public view returns (uint256) {

        uint256 _id;
        assembly {
            _id := chainid()
        }
        return _id;
    }

    function generateTransactionHashData(
        address _to,
        uint256 _value,
        bytes memory _data,
        Enum.Operation _operation,
        uint256 _nonce
    ) internal view returns (bytes memory) {

        uint256 _chainId = getChainId();
        bytes32 _domainSeparator = keccak256(
            abi.encode(DOMAIN_SEPARATOR_TYPEHASH, _chainId, this)
        );
        bytes32 _transactionHash = keccak256(
            abi.encode(
                TRANSACTION_TYPEHASH,
                _to,
                _value,
                keccak256(_data),
                _operation,
                _nonce
            )
        );
        return
            abi.encodePacked(
                bytes1(0x19),
                bytes1(0x01),
                _domainSeparator,
                _transactionHash
            );
    }

    function getTransactionHash(
        address _to,
        uint256 _value,
        bytes memory _data,
        Enum.Operation _operation,
        uint256 _nonce
    ) public view returns (bytes32) {

        return
            keccak256(
                generateTransactionHashData(
                    _to,
                    _value,
                    _data,
                    _operation,
                    _nonce
                )
            );
    }

    function markProposalWithExpiredResultAsInvalid(bytes32 _proposalHash)
        public
    {

        uint32 _expirationDuration = resultExpiration;
        require(_expirationDuration > 0, "Results are valid forever");
        bytes32 _queryId = queryIds[_proposalHash];
        require(_queryId != INVALIDATED, "Proposal is already invalidated");
        require(
            _queryId != bytes32(0),
            "No query id set for provided proposal"
        );
        (
            bool _ifRetrieve,
            bytes memory _valueRetrieved,
            uint256 _timestampRetrieved
        ) = getDataBefore(_queryId, block.timestamp);
        require(_ifRetrieve, "Data not retrieved");
        bool _didPass = abi.decode(_valueRetrieved, (bool));
        require(_didPass, "Transaction was not approved");
        require(
            _timestampRetrieved + uint256(_expirationDuration) <
                block.timestamp,
            "Result has not expired yet"
        );
        queryIds[_proposalHash] = INVALIDATED;
    }

    function setUp(bytes memory _initParams) public override {

        (
            address _avatar,
            address _target,
            uint32 _cooldown,
            uint32 _expiration
        ) = abi.decode(_initParams, (address, address, uint32, uint32));
        require(
            !_initialized,
            "Initializable: contract is already initialized"
        );
        _initialized = true;

        require(_avatar != address(0), "Avatar can not be zero address");
        require(_target != address(0), "Target can not be zero address");
        require(
            _expiration == 0 || _expiration - _cooldown >= 60,
            "There need to be at least 60s between end of cooldown and expiration"
        );
        avatar = _avatar;
        target = _target;
        resultExpiration = _expiration;
        cooldown = _cooldown;
        emit TellorModuleSetup(msg.sender, _avatar, _target);
    }

    function _bytes32ToAsciiString(bytes32 _bytes)
        internal
        pure
        returns (string memory)
    {

        bytes memory s = new bytes(64);
        for (uint256 i = 0; i < 32; i++) {
            uint8 b = uint8(bytes1(_bytes << (i * 8)));
            uint8 hi = uint8(b) / 16;
            uint8 lo = uint8(b) % 16;
            s[2 * i] = _char(hi);
            s[2 * i + 1] = _char(lo);
        }
        return string(s);
    }

    function _char(uint8 _b) internal pure returns (bytes1 c) {

        if (_b < 10) return bytes1(_b + 0x30);
        else return bytes1(_b + 0x57);
    }
}