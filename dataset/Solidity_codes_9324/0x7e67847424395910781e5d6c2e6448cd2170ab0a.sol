


pragma solidity 0.4.24;

interface IAMB {

    function messageSender() external view returns (address);

    function maxGasPerTx() external view returns (uint256);

    function transactionHash() external view returns (bytes32);

    function messageId() external view returns (bytes32);

    function messageSourceChainId() external view returns (bytes32);

    function messageCallStatus(bytes32 _messageId) external view returns (bool);

    function failedMessageDataHash(bytes32 _messageId) external view returns (bytes32);

    function failedMessageReceiver(bytes32 _messageId) external view returns (address);

    function failedMessageSender(bytes32 _messageId) external view returns (address);

    function requireToPassMessage(address _contract, bytes _data, uint256 _gas) external returns (bytes32);

    function requireToConfirmMessage(address _contract, bytes _data, uint256 _gas) external returns (bytes32);

    function sourceChainId() external view returns (uint256);

    function destinationChainId() external view returns (uint256);

}


pragma solidity 0.4.24;

contract EternalStorage {

    mapping(bytes32 => uint256) internal uintStorage;
    mapping(bytes32 => string) internal stringStorage;
    mapping(bytes32 => address) internal addressStorage;
    mapping(bytes32 => bytes) internal bytesStorage;
    mapping(bytes32 => bool) internal boolStorage;
    mapping(bytes32 => int256) internal intStorage;

}


pragma solidity 0.4.24;

interface IUpgradeabilityOwnerStorage {

    function upgradeabilityOwner() external view returns (address);

}


pragma solidity 0.4.24;



contract Ownable is EternalStorage {

    bytes4 internal constant UPGRADEABILITY_OWNER = 0x6fde8202; // upgradeabilityOwner()

    event OwnershipTransferred(address previousOwner, address newOwner);

    modifier onlyOwner() {

        require(msg.sender == owner());
        _;
    }

    modifier onlyRelevantSender() {

        require(
            !address(this).call(abi.encodeWithSelector(UPGRADEABILITY_OWNER)) || // covers usage without calling through storage proxy
                msg.sender == IUpgradeabilityOwnerStorage(this).upgradeabilityOwner() || // covers usage through regular proxy calls
                msg.sender == address(this) // covers calls through upgradeAndCall proxy method
        );
        _;
    }

    bytes32 internal constant OWNER = 0x02016836a56b71f0d02689e69e326f4f4c1b9057164ef592671cf0d37c8040c0; // keccak256(abi.encodePacked("owner"))

    function owner() public view returns (address) {

        return addressStorage[OWNER];
    }

    function transferOwnership(address newOwner) external onlyOwner {

        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) internal {

        require(newOwner != address(0));
        emit OwnershipTransferred(owner(), newOwner);
        addressStorage[OWNER] = newOwner;
    }
}


pragma solidity 0.4.24;


contract Initializable is EternalStorage {

    bytes32 internal constant INITIALIZED = 0x0a6f646cd611241d8073675e00d1a1ff700fbf1b53fcf473de56d1e6e4b714ba; // keccak256(abi.encodePacked("isInitialized"))

    function setInitialize() internal {

        boolStorage[INITIALIZED] = true;
    }

    function isInitialized() public view returns (bool) {

        return boolStorage[INITIALIZED];
    }
}


pragma solidity ^0.4.24;


library AddressUtils {


  function isContract(address _addr) internal view returns (bool) {

    uint256 size;
    assembly { size := extcodesize(_addr) }
    return size > 0;
  }

}


pragma solidity ^0.4.24;


library SafeMath {


  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {

    return _a / _b;
  }

  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {

    assert(_b <= _a);
    return _a - _b;
  }

  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}


pragma solidity 0.4.24;



contract DecimalShiftBridge is EternalStorage {

    using SafeMath for uint256;

    bytes32 internal constant DECIMAL_SHIFT = 0x1e8ecaafaddea96ed9ac6d2642dcdfe1bebe58a930b1085842d8fc122b371ee5; // keccak256(abi.encodePacked("decimalShift"))

    function _setDecimalShift(int256 _shift) internal {

        require(_shift > -77 && _shift < 77);
        uintStorage[DECIMAL_SHIFT] = uint256(_shift);
    }

    function decimalShift() public view returns (int256) {

        return int256(uintStorage[DECIMAL_SHIFT]);
    }

    function _unshiftValue(uint256 _value) internal view returns (uint256) {

        return _shiftUint(_value, -decimalShift());
    }

    function _shiftValue(uint256 _value) internal view returns (uint256) {

        return _shiftUint(_value, decimalShift());
    }

    function _shiftUint(uint256 _value, int256 _shift) private pure returns (uint256) {

        if (_shift == 0) {
            return _value;
        }
        if (_shift > 0) {
            return _value.mul(10**uint256(_shift));
        }
        return _value.div(10**uint256(-_shift));
    }
}


pragma solidity 0.4.24;





contract BasicTokenBridge is EternalStorage, Ownable, DecimalShiftBridge {

    using SafeMath for uint256;

    event DailyLimitChanged(uint256 newLimit);
    event ExecutionDailyLimitChanged(uint256 newLimit);

    bytes32 internal constant MIN_PER_TX = 0xbbb088c505d18e049d114c7c91f11724e69c55ad6c5397e2b929e68b41fa05d1; // keccak256(abi.encodePacked("minPerTx"))
    bytes32 internal constant MAX_PER_TX = 0x0f8803acad17c63ee38bf2de71e1888bc7a079a6f73658e274b08018bea4e29c; // keccak256(abi.encodePacked("maxPerTx"))
    bytes32 internal constant DAILY_LIMIT = 0x4a6a899679f26b73530d8cf1001e83b6f7702e04b6fdb98f3c62dc7e47e041a5; // keccak256(abi.encodePacked("dailyLimit"))
    bytes32 internal constant EXECUTION_MAX_PER_TX = 0xc0ed44c192c86d1cc1ba51340b032c2766b4a2b0041031de13c46dd7104888d5; // keccak256(abi.encodePacked("executionMaxPerTx"))
    bytes32 internal constant EXECUTION_DAILY_LIMIT = 0x21dbcab260e413c20dc13c28b7db95e2b423d1135f42bb8b7d5214a92270d237; // keccak256(abi.encodePacked("executionDailyLimit"))

    function totalSpentPerDay(uint256 _day) public view returns (uint256) {

        return uintStorage[keccak256(abi.encodePacked("totalSpentPerDay", _day))];
    }

    function totalExecutedPerDay(uint256 _day) public view returns (uint256) {

        return uintStorage[keccak256(abi.encodePacked("totalExecutedPerDay", _day))];
    }

    function dailyLimit() public view returns (uint256) {

        return uintStorage[DAILY_LIMIT];
    }

    function executionDailyLimit() public view returns (uint256) {

        return uintStorage[EXECUTION_DAILY_LIMIT];
    }

    function maxPerTx() public view returns (uint256) {

        return uintStorage[MAX_PER_TX];
    }

    function executionMaxPerTx() public view returns (uint256) {

        return uintStorage[EXECUTION_MAX_PER_TX];
    }

    function minPerTx() public view returns (uint256) {

        return uintStorage[MIN_PER_TX];
    }

    function withinLimit(uint256 _amount) public view returns (bool) {

        uint256 nextLimit = totalSpentPerDay(getCurrentDay()).add(_amount);
        return dailyLimit() >= nextLimit && _amount <= maxPerTx() && _amount >= minPerTx();
    }

    function withinExecutionLimit(uint256 _amount) public view returns (bool) {

        uint256 nextLimit = totalExecutedPerDay(getCurrentDay()).add(_amount);
        return executionDailyLimit() >= nextLimit && _amount <= executionMaxPerTx();
    }

    function getCurrentDay() public view returns (uint256) {

        return now / 1 days;
    }

    function addTotalSpentPerDay(uint256 _day, uint256 _value) internal {

        uintStorage[keccak256(abi.encodePacked("totalSpentPerDay", _day))] = totalSpentPerDay(_day).add(_value);
    }

    function addTotalExecutedPerDay(uint256 _day, uint256 _value) internal {

        uintStorage[keccak256(abi.encodePacked("totalExecutedPerDay", _day))] = totalExecutedPerDay(_day).add(_value);
    }

    function setDailyLimit(uint256 _dailyLimit) external onlyOwner {

        require(_dailyLimit > maxPerTx() || _dailyLimit == 0);
        uintStorage[DAILY_LIMIT] = _dailyLimit;
        emit DailyLimitChanged(_dailyLimit);
    }

    function setExecutionDailyLimit(uint256 _dailyLimit) external onlyOwner {

        require(_dailyLimit > executionMaxPerTx() || _dailyLimit == 0);
        uintStorage[EXECUTION_DAILY_LIMIT] = _dailyLimit;
        emit ExecutionDailyLimitChanged(_dailyLimit);
    }

    function setExecutionMaxPerTx(uint256 _maxPerTx) external onlyOwner {

        require(_maxPerTx < executionDailyLimit());
        uintStorage[EXECUTION_MAX_PER_TX] = _maxPerTx;
    }

    function setMaxPerTx(uint256 _maxPerTx) external onlyOwner {

        require(_maxPerTx == 0 || (_maxPerTx > minPerTx() && _maxPerTx < dailyLimit()));
        uintStorage[MAX_PER_TX] = _maxPerTx;
    }

    function setMinPerTx(uint256 _minPerTx) external onlyOwner {

        require(_minPerTx > 0 && _minPerTx < dailyLimit() && _minPerTx < maxPerTx());
        uintStorage[MIN_PER_TX] = _minPerTx;
    }

    function maxAvailablePerTx() public view returns (uint256) {

        uint256 _maxPerTx = maxPerTx();
        uint256 _dailyLimit = dailyLimit();
        uint256 _spent = totalSpentPerDay(getCurrentDay());
        uint256 _remainingOutOfDaily = _dailyLimit > _spent ? _dailyLimit - _spent : 0;
        return _maxPerTx < _remainingOutOfDaily ? _maxPerTx : _remainingOutOfDaily;
    }

    function _setLimits(uint256[3] _limits) internal {

        require(
            _limits[2] > 0 && // minPerTx > 0
                _limits[1] > _limits[2] && // maxPerTx > minPerTx
                _limits[0] > _limits[1] // dailyLimit > maxPerTx
        );

        uintStorage[DAILY_LIMIT] = _limits[0];
        uintStorage[MAX_PER_TX] = _limits[1];
        uintStorage[MIN_PER_TX] = _limits[2];

        emit DailyLimitChanged(_limits[0]);
    }

    function _setExecutionLimits(uint256[2] _limits) internal {

        require(_limits[1] < _limits[0]); // foreignMaxPerTx < foreignDailyLimit

        uintStorage[EXECUTION_DAILY_LIMIT] = _limits[0];
        uintStorage[EXECUTION_MAX_PER_TX] = _limits[1];

        emit ExecutionDailyLimitChanged(_limits[0]);
    }
}


pragma solidity ^0.4.24;


contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address _who) public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
}


pragma solidity ^0.4.24;



contract ERC20 is ERC20Basic {

  function allowance(address _owner, address _spender)
    public view returns (uint256);


  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);


  function approve(address _spender, uint256 _value) public returns (bool);

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}


pragma solidity 0.4.24;


contract ERC677 is ERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value, bytes data);

    function transferAndCall(address, uint256, bytes) external returns (bool);


    function increaseAllowance(address spender, uint256 addedValue) public returns (bool);

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool);

}

contract LegacyERC20 {

    function transfer(address _spender, uint256 _value) public; // returns (bool);

    function transferFrom(address _owner, address _spender, uint256 _value) public; // returns (bool);

}


pragma solidity 0.4.24;

contract ERC677Receiver {

    function onTokenTransfer(address _from, uint256 _value, bytes _data) external returns (bool);

}


pragma solidity 0.4.24;

contract ERC677Storage {

    bytes32 internal constant ERC677_TOKEN = 0xa8b0ade3e2b734f043ce298aca4cc8d19d74270223f34531d0988b7d00cba21d; // keccak256(abi.encodePacked("erc677token"))
}


pragma solidity 0.4.24;

library Bytes {

    function bytesToBytes32(bytes _bytes) internal pure returns (bytes32 result) {

        assembly {
            result := mload(add(_bytes, 32))
        }
    }

    function bytesToAddress(bytes _bytes) internal pure returns (address addr) {

        assembly {
            addr := mload(add(_bytes, 20))
        }
    }
}


pragma solidity 0.4.24;


contract ChooseReceiverHelper {

    function chooseReceiver(address _from, bytes _data) internal view returns (address recipient) {

        recipient = _from;
        if (_data.length > 0) {
            require(_data.length == 20);
            recipient = Bytes.bytesToAddress(_data);
            require(recipient != address(0));
            require(recipient != bridgeContractOnOtherSide());
        }
    }

    function bridgeContractOnOtherSide() internal view returns (address);

}


pragma solidity 0.4.24;







contract BaseERC677Bridge is BasicTokenBridge, ERC677Receiver, ERC677Storage, ChooseReceiverHelper {

    function _erc677token() internal view returns (ERC677) {

        return ERC677(addressStorage[ERC677_TOKEN]);
    }

    function setErc677token(address _token) internal {

        require(AddressUtils.isContract(_token));
        addressStorage[ERC677_TOKEN] = _token;
    }

    function onTokenTransfer(address _from, uint256 _value, bytes _data) external returns (bool) {

        ERC677 token = _erc677token();
        require(msg.sender == address(token));
        require(withinLimit(_value));
        addTotalSpentPerDay(getCurrentDay(), _value);
        bridgeSpecificActionsOnTokenTransfer(token, _from, _value, _data);
        return true;
    }

    function bridgeSpecificActionsOnTokenTransfer(ERC677 _token, address _from, uint256 _value, bytes _data) internal;

}


pragma solidity 0.4.24;


contract BaseOverdrawManagement is EternalStorage {

    event MediatorAmountLimitExceeded(address recipient, uint256 value, bytes32 indexed messageId);
    event AmountLimitExceeded(address recipient, uint256 value, bytes32 indexed transactionHash, bytes32 messageId);
    event AssetAboveLimitsFixed(bytes32 indexed messageId, uint256 value, uint256 remaining);

    bytes32 internal constant OUT_OF_LIMIT_AMOUNT = 0x145286dc85799b6fb9fe322391ba2d95683077b2adf34dd576dedc437e537ba7; // keccak256(abi.encodePacked("outOfLimitAmount"))

    function outOfLimitAmount() public view returns (uint256) {

        return uintStorage[OUT_OF_LIMIT_AMOUNT];
    }

    function setOutOfLimitAmount(uint256 _value) internal {

        uintStorage[OUT_OF_LIMIT_AMOUNT] = _value;
    }

    function txAboveLimits(bytes32 _messageId) internal view returns (address recipient, uint256 value) {

        recipient = addressStorage[keccak256(abi.encodePacked("txOutOfLimitRecipient", _messageId))];
        value = uintStorage[keccak256(abi.encodePacked("txOutOfLimitValue", _messageId))];
    }

    function setTxAboveLimits(address _recipient, uint256 _value, bytes32 _messageId) internal {

        addressStorage[keccak256(abi.encodePacked("txOutOfLimitRecipient", _messageId))] = _recipient;
        setTxAboveLimitsValue(_value, _messageId);
    }

    function setTxAboveLimitsValue(uint256 _value, bytes32 _messageId) internal {

        uintStorage[keccak256(abi.encodePacked("txOutOfLimitValue", _messageId))] = _value;
    }

    function fixAssetsAboveLimits(bytes32 messageId, bool unlockOnForeign, uint256 valueToUnlock) external;

}


pragma solidity 0.4.24;

contract ReentrancyGuard {

    function lock() internal returns (bool res) {

        assembly {
            res := sload(0x6168652c307c1e813ca11cfb3a601f1cf3b22452021a5052d8b05f1f1f8a3e92) // keccak256(abi.encodePacked("lock"))
        }
    }

    function setLock(bool _lock) internal {

        assembly {
            sstore(0x6168652c307c1e813ca11cfb3a601f1cf3b22452021a5052d8b05f1f1f8a3e92, _lock) // keccak256(abi.encodePacked("lock"))
        }
    }
}


pragma solidity 0.4.24;


contract Upgradeable {

    modifier onlyIfUpgradeabilityOwner() {

        require(msg.sender == IUpgradeabilityOwnerStorage(this).upgradeabilityOwner());
        _;
    }
}


pragma solidity 0.4.24;

contract Sacrifice {

    constructor(address _recipient) public payable {
        selfdestruct(_recipient);
    }
}


pragma solidity 0.4.24;


library Address {

    function safeSendValue(address _receiver, uint256 _value) internal {

        if (!_receiver.send(_value)) {
            (new Sacrifice).value(_value)(_receiver);
        }
    }
}


pragma solidity 0.4.24;



library SafeERC20 {

    using SafeMath for uint256;

    function safeTransfer(address _token, address _to, uint256 _value) internal {

        LegacyERC20(_token).transfer(_to, _value);
        assembly {
            if returndatasize {
                returndatacopy(0, 0, 32)
                if iszero(mload(0)) {
                    revert(0, 0)
                }
            }
        }
    }

    function safeTransferFrom(address _token, address _from, uint256 _value) internal {

        LegacyERC20(_token).transferFrom(_from, address(this), _value);
        assembly {
            if returndatasize {
                returndatacopy(0, 0, 32)
                if iszero(mload(0)) {
                    revert(0, 0)
                }
            }
        }
    }
}


pragma solidity 0.4.24;



contract Claimable {

    using SafeERC20 for address;

    modifier validAddress(address _to) {

        require(_to != address(0));
        _;
    }

    function claimValues(address _token, address _to) internal validAddress(_to) {

        if (_token == address(0)) {
            claimNativeCoins(_to);
        } else {
            claimErc20Tokens(_token, _to);
        }
    }

    function claimNativeCoins(address _to) internal {

        uint256 value = address(this).balance;
        Address.safeSendValue(_to, value);
    }

    function claimErc20Tokens(address _token, address _to) internal {

        ERC20Basic token = ERC20Basic(_token);
        uint256 balance = token.balanceOf(this);
        _token.safeTransfer(_to, balance);
    }
}


pragma solidity 0.4.24;

contract VersionableBridge {

    function getBridgeInterfacesVersion() external pure returns (uint64 major, uint64 minor, uint64 patch) {

        return (5, 2, 0);
    }

    function getBridgeMode() external pure returns (bytes4);

}


pragma solidity 0.4.24;





contract BasicAMBMediator is Ownable {

    bytes32 internal constant BRIDGE_CONTRACT = 0x811bbb11e8899da471f0e69a3ed55090fc90215227fc5fb1cb0d6e962ea7b74f; // keccak256(abi.encodePacked("bridgeContract"))
    bytes32 internal constant MEDIATOR_CONTRACT = 0x98aa806e31e94a687a31c65769cb99670064dd7f5a87526da075c5fb4eab9880; // keccak256(abi.encodePacked("mediatorContract"))
    bytes32 internal constant REQUEST_GAS_LIMIT = 0x2dfd6c9f781bb6bbb5369c114e949b69ebb440ef3d4dd6b2836225eb1dc3a2be; // keccak256(abi.encodePacked("requestGasLimit"))

    modifier onlyMediator {

        require(msg.sender == address(bridgeContract()));
        require(messageSender() == mediatorContractOnOtherSide());
        _;
    }

    function setBridgeContract(address _bridgeContract) external onlyOwner {

        _setBridgeContract(_bridgeContract);
    }

    function setMediatorContractOnOtherSide(address _mediatorContract) external onlyOwner {

        _setMediatorContractOnOtherSide(_mediatorContract);
    }

    function setRequestGasLimit(uint256 _requestGasLimit) external onlyOwner {

        _setRequestGasLimit(_requestGasLimit);
    }

    function bridgeContract() public view returns (IAMB) {

        return IAMB(addressStorage[BRIDGE_CONTRACT]);
    }

    function mediatorContractOnOtherSide() public view returns (address) {

        return addressStorage[MEDIATOR_CONTRACT];
    }

    function requestGasLimit() public view returns (uint256) {

        return uintStorage[REQUEST_GAS_LIMIT];
    }

    function _setBridgeContract(address _bridgeContract) internal {

        require(AddressUtils.isContract(_bridgeContract));
        addressStorage[BRIDGE_CONTRACT] = _bridgeContract;
    }

    function _setMediatorContractOnOtherSide(address _mediatorContract) internal {

        addressStorage[MEDIATOR_CONTRACT] = _mediatorContract;
    }

    function _setRequestGasLimit(uint256 _requestGasLimit) internal {

        require(_requestGasLimit <= maxGasPerTx());
        uintStorage[REQUEST_GAS_LIMIT] = _requestGasLimit;
    }

    function messageSender() internal view returns (address) {

        return bridgeContract().messageSender();
    }

    function messageId() internal view returns (bytes32) {

        return bridgeContract().messageId();
    }

    function maxGasPerTx() internal view returns (uint256) {

        return bridgeContract().maxGasPerTx();
    }
}


pragma solidity 0.4.24;


contract TransferInfoStorage is EternalStorage {

    function setMessageValue(bytes32 _messageId, uint256 _value) internal {

        uintStorage[keccak256(abi.encodePacked("messageValue", _messageId))] = _value;
    }

    function messageValue(bytes32 _messageId) internal view returns (uint256) {

        return uintStorage[keccak256(abi.encodePacked("messageValue", _messageId))];
    }

    function setMessageRecipient(bytes32 _messageId, address _recipient) internal {

        addressStorage[keccak256(abi.encodePacked("messageRecipient", _messageId))] = _recipient;
    }

    function messageRecipient(bytes32 _messageId) internal view returns (address) {

        return addressStorage[keccak256(abi.encodePacked("messageRecipient", _messageId))];
    }

    function setMessageFixed(bytes32 _messageId) internal {

        boolStorage[keccak256(abi.encodePacked("messageFixed", _messageId))] = true;
    }

    function messageFixed(bytes32 _messageId) public view returns (bool) {

        return boolStorage[keccak256(abi.encodePacked("messageFixed", _messageId))];
    }
}


pragma solidity 0.4.24;




contract TokenBridgeMediator is BasicAMBMediator, BasicTokenBridge, TransferInfoStorage {

    event FailedMessageFixed(bytes32 indexed messageId, address recipient, uint256 value);
    event TokensBridgingInitiated(address indexed sender, uint256 value, bytes32 indexed messageId);
    event TokensBridged(address indexed recipient, uint256 value, bytes32 indexed messageId);

    function passMessage(address _from, address _receiver, uint256 _value) internal {

        bytes4 methodSelector = this.handleBridgedTokens.selector;
        bytes memory data = abi.encodeWithSelector(methodSelector, _receiver, _value);

        bytes32 _messageId = bridgeContract().requireToPassMessage(
            mediatorContractOnOtherSide(),
            data,
            requestGasLimit()
        );

        setMessageValue(_messageId, _value);
        setMessageRecipient(_messageId, _from);

        emit TokensBridgingInitiated(_from, _value, _messageId);
    }

    function handleBridgedTokens(address _recipient, uint256 _value) external onlyMediator {

        if (withinExecutionLimit(_value)) {
            addTotalExecutedPerDay(getCurrentDay(), _value);
            executeActionOnBridgedTokens(_recipient, _value);
        } else {
            executeActionOnBridgedTokensOutOfLimit(_recipient, _value);
        }
    }

    function requestFailedMessageFix(bytes32 _messageId) external {

        require(!bridgeContract().messageCallStatus(_messageId));
        require(bridgeContract().failedMessageReceiver(_messageId) == address(this));
        require(bridgeContract().failedMessageSender(_messageId) == mediatorContractOnOtherSide());

        bytes4 methodSelector = this.fixFailedMessage.selector;
        bytes memory data = abi.encodeWithSelector(methodSelector, _messageId);
        bridgeContract().requireToPassMessage(mediatorContractOnOtherSide(), data, requestGasLimit());
    }

    function fixFailedMessage(bytes32 _messageId) external onlyMediator {

        require(!messageFixed(_messageId));

        address recipient = messageRecipient(_messageId);
        uint256 value = messageValue(_messageId);
        setMessageFixed(_messageId);
        executeActionOnFixedTokens(recipient, value);
        emit FailedMessageFixed(_messageId, recipient, value);
    }

    function executeActionOnBridgedTokensOutOfLimit(address _recipient, uint256 _value) internal;


    function executeActionOnBridgedTokens(address _recipient, uint256 _value) internal;


    function executeActionOnFixedTokens(address _recipient, uint256 _value) internal;

}


pragma solidity 0.4.24;











contract BasicAMBErc677ToErc677 is
    Initializable,
    ReentrancyGuard,
    Upgradeable,
    Claimable,
    VersionableBridge,
    BaseOverdrawManagement,
    BaseERC677Bridge,
    TokenBridgeMediator
{

    function initialize(
        address _bridgeContract,
        address _mediatorContract,
        address _erc677token,
        uint256[3] _dailyLimitMaxPerTxMinPerTxArray, // [ 0 = _dailyLimit, 1 = _maxPerTx, 2 = _minPerTx ]
        uint256[2] _executionDailyLimitExecutionMaxPerTxArray, // [ 0 = _executionDailyLimit, 1 = _executionMaxPerTx ]
        uint256 _requestGasLimit,
        int256 _decimalShift,
        address _owner
    ) public onlyRelevantSender returns (bool) {

        require(!isInitialized());

        _setBridgeContract(_bridgeContract);
        _setMediatorContractOnOtherSide(_mediatorContract);
        setErc677token(_erc677token);
        _setLimits(_dailyLimitMaxPerTxMinPerTxArray);
        _setExecutionLimits(_executionDailyLimitExecutionMaxPerTxArray);
        _setRequestGasLimit(_requestGasLimit);
        _setDecimalShift(_decimalShift);
        _setOwner(_owner);
        setInitialize();

        return isInitialized();
    }

    function erc677token() public view returns (ERC677) {

        return _erc677token();
    }

    function bridgeContractOnOtherSide() internal view returns (address) {

        return mediatorContractOnOtherSide();
    }

    function relayTokens(address _receiver, uint256 _value) external {

        require(!lock());
        ERC677 token = erc677token();
        address to = address(this);
        require(withinLimit(_value));
        addTotalSpentPerDay(getCurrentDay(), _value);

        setLock(true);
        token.transferFrom(msg.sender, to, _value);
        setLock(false);
        bridgeSpecificActionsOnTokenTransfer(token, msg.sender, _value, abi.encodePacked(_receiver));
    }

    function onTokenTransfer(address _from, uint256 _value, bytes _data) external returns (bool) {

        ERC677 token = erc677token();
        require(msg.sender == address(token));
        if (!lock()) {
            require(withinLimit(_value));
            addTotalSpentPerDay(getCurrentDay(), _value);
        }
        bridgeSpecificActionsOnTokenTransfer(token, _from, _value, _data);
        return true;
    }

    function getBridgeInterfacesVersion() external pure returns (uint64 major, uint64 minor, uint64 patch) {

        return (1, 4, 0);
    }

    function getBridgeMode() external pure returns (bytes4 _data) {

        return 0x76595b56; // bytes4(keccak256(abi.encodePacked("erc-to-erc-amb")))
    }

    function executeActionOnBridgedTokensOutOfLimit(address _recipient, uint256 _value) internal {

        bytes32 _messageId = messageId();
        address recipient;
        uint256 value;
        (recipient, value) = txAboveLimits(_messageId);
        require(recipient == address(0) && value == 0);
        setOutOfLimitAmount(outOfLimitAmount().add(_value));
        setTxAboveLimits(_recipient, _value, _messageId);
        emit MediatorAmountLimitExceeded(_recipient, _value, _messageId);
    }

    function fixAssetsAboveLimits(bytes32 messageId, bool unlockOnOtherSide, uint256 valueToUnlock)
        external
        onlyIfUpgradeabilityOwner
    {

        (address recipient, uint256 value) = txAboveLimits(messageId);
        require(recipient != address(0) && value > 0 && value >= valueToUnlock);
        setOutOfLimitAmount(outOfLimitAmount().sub(valueToUnlock));
        uint256 pendingValue = value.sub(valueToUnlock);
        setTxAboveLimitsValue(pendingValue, messageId);
        emit AssetAboveLimitsFixed(messageId, valueToUnlock, pendingValue);
        if (unlockOnOtherSide) {
            require(valueToUnlock <= maxPerTx());
            passMessage(recipient, recipient, valueToUnlock);
        }
    }
}


pragma solidity 0.4.24;


contract IBurnableMintableERC677Token is ERC677 {

    function mint(address _to, uint256 _amount) public returns (bool);

    function burn(uint256 _value) public;

    function claimTokens(address _token, address _to) external;

}


pragma solidity 0.4.24;



contract HomeAMBErc677ToErc677 is BasicAMBErc677ToErc677 {

    function executeActionOnBridgedTokens(address _recipient, uint256 _value) internal {

        uint256 value = _shiftValue(_value);
        bytes32 _messageId = messageId();
        IBurnableMintableERC677Token(erc677token()).mint(_recipient, value);
        emit TokensBridged(_recipient, value, _messageId);
    }

    function bridgeSpecificActionsOnTokenTransfer(ERC677 _token, address _from, uint256 _value, bytes _data) internal {

        if (!lock()) {
            IBurnableMintableERC677Token(_token).burn(_value);
            passMessage(_from, chooseReceiver(_from, _data), _value);
        }
    }

    function claimTokens(address _token, address _to) external onlyIfUpgradeabilityOwner {

        claimValues(_token, _to);
    }

    function executeActionOnFixedTokens(address _recipient, uint256 _value) internal {

        IBurnableMintableERC677Token(erc677token()).mint(_recipient, _value);
    }
}