

pragma solidity 0.4.24;

interface IAMB {

    function messageSender() external view returns (address);

    function maxGasPerTx() external view returns (uint256);

    function transactionHash() external view returns (bytes32);

    function messageCallStatus(bytes32 _txHash) external view returns (bool);

    function failedMessageDataHash(bytes32 _txHash) external view returns (bytes32);

    function failedMessageReceiver(bytes32 _txHash) external view returns (address);

    function failedMessageSender(bytes32 _txHash) external view returns (address);

    function requireToPassMessage(address _contract, bytes _data, uint256 _gas) external;

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

        require(newOwner != address(0));
        setOwner(newOwner);
    }

    function setOwner(address newOwner) internal {

        emit OwnershipTransferred(owner(), newOwner);
        addressStorage[OWNER] = newOwner;
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




contract BasicTokenBridge is EternalStorage, Ownable {

    using SafeMath for uint256;

    event DailyLimitChanged(uint256 newLimit);
    event ExecutionDailyLimitChanged(uint256 newLimit);

    bytes32 internal constant MIN_PER_TX = 0xbbb088c505d18e049d114c7c91f11724e69c55ad6c5397e2b929e68b41fa05d1; // keccak256(abi.encodePacked("minPerTx"))
    bytes32 internal constant MAX_PER_TX = 0x0f8803acad17c63ee38bf2de71e1888bc7a079a6f73658e274b08018bea4e29c; // keccak256(abi.encodePacked("maxPerTx"))
    bytes32 internal constant DAILY_LIMIT = 0x4a6a899679f26b73530d8cf1001e83b6f7702e04b6fdb98f3c62dc7e47e041a5; // keccak256(abi.encodePacked("dailyLimit"))
    bytes32 internal constant EXECUTION_MAX_PER_TX = 0xc0ed44c192c86d1cc1ba51340b032c2766b4a2b0041031de13c46dd7104888d5; // keccak256(abi.encodePacked("executionMaxPerTx"))
    bytes32 internal constant EXECUTION_DAILY_LIMIT = 0x21dbcab260e413c20dc13c28b7db95e2b423d1135f42bb8b7d5214a92270d237; // keccak256(abi.encodePacked("executionDailyLimit"))
    bytes32 internal constant DECIMAL_SHIFT = 0x1e8ecaafaddea96ed9ac6d2642dcdfe1bebe58a930b1085842d8fc122b371ee5; // keccak256(abi.encodePacked("decimalShift"))

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

    function decimalShift() public view returns (uint256) {

        return uintStorage[DECIMAL_SHIFT];
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

    function setTotalSpentPerDay(uint256 _day, uint256 _value) internal {

        uintStorage[keccak256(abi.encodePacked("totalSpentPerDay", _day))] = _value;
    }

    function setTotalExecutedPerDay(uint256 _day, uint256 _value) internal {

        uintStorage[keccak256(abi.encodePacked("totalExecutedPerDay", _day))] = _value;
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







contract BaseERC677Bridge is BasicTokenBridge, ERC677Receiver, ERC677Storage {

    function erc677token() public view returns (ERC677) {

        return ERC677(addressStorage[ERC677_TOKEN]);
    }

    function setErc677token(address _token) internal {

        require(AddressUtils.isContract(_token));
        addressStorage[ERC677_TOKEN] = _token;
    }

    function onTokenTransfer(address _from, uint256 _value, bytes _data) external returns (bool) {

        ERC677 token = erc677token();
        require(msg.sender == address(token));
        require(withinLimit(_value));
        setTotalSpentPerDay(getCurrentDay(), totalSpentPerDay(getCurrentDay()).add(_value));
        bridgeSpecificActionsOnTokenTransfer(token, _from, _value, _data);
        return true;
    }

    function chooseReceiver(address _from, bytes _data) internal view returns (address recipient) {

        recipient = _from;
        if (_data.length > 0) {
            require(_data.length == 20);
            recipient = Bytes.bytesToAddress(_data);
            require(recipient != address(0));
            require(recipient != bridgeContractOnOtherSide());
        }
    }

    function bridgeSpecificActionsOnTokenTransfer(ERC677 _token, address _from, uint256 _value, bytes _data) internal;


    function bridgeContractOnOtherSide() internal view returns (address);

}


pragma solidity 0.4.24;


contract BaseOverdrawManagement is EternalStorage {

    event AmountLimitExceeded(address recipient, uint256 value, bytes32 transactionHash);
    event AssetAboveLimitsFixed(bytes32 indexed transactionHash, uint256 value, uint256 remaining);

    bytes32 internal constant OUT_OF_LIMIT_AMOUNT = 0x145286dc85799b6fb9fe322391ba2d95683077b2adf34dd576dedc437e537ba7; // keccak256(abi.encodePacked("outOfLimitAmount"))

    function outOfLimitAmount() public view returns (uint256) {

        return uintStorage[OUT_OF_LIMIT_AMOUNT];
    }

    function fixedAssets(bytes32 _txHash) public view returns (bool) {

        return boolStorage[keccak256(abi.encodePacked("fixedAssets", _txHash))];
    }

    function setOutOfLimitAmount(uint256 _value) internal {

        uintStorage[OUT_OF_LIMIT_AMOUNT] = _value;
    }

    function txAboveLimits(bytes32 _txHash) internal view returns (address recipient, uint256 value) {

        recipient = addressStorage[keccak256(abi.encodePacked("txOutOfLimitRecipient", _txHash))];
        value = uintStorage[keccak256(abi.encodePacked("txOutOfLimitValue", _txHash))];
    }

    function setTxAboveLimits(address _recipient, uint256 _value, bytes32 _txHash) internal {

        addressStorage[keccak256(abi.encodePacked("txOutOfLimitRecipient", _txHash))] = _recipient;
        setTxAboveLimitsValue(_value, _txHash);
    }

    function setTxAboveLimitsValue(uint256 _value, bytes32 _txHash) internal {

        uintStorage[keccak256(abi.encodePacked("txOutOfLimitValue", _txHash))] = _value;
    }

    function setFixedAssets(bytes32 _txHash) internal {

        boolStorage[keccak256(abi.encodePacked("fixedAssets", _txHash))] = true;
    }

    function fixAssetsAboveLimits(bytes32 txHash, bool unlockOnForeign, uint256 valueToUnlock) external;

}


pragma solidity 0.4.24;


contract ReentrancyGuard is EternalStorage {

    bytes32 internal constant LOCK = 0x6168652c307c1e813ca11cfb3a601f1cf3b22452021a5052d8b05f1f1f8a3e92; // keccak256(abi.encodePacked("lock"))

    function lock() internal returns (bool) {

        return boolStorage[LOCK];
    }

    function setLock(bool _lock) internal {

        boolStorage[LOCK] = _lock;
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



contract Claimable {

    bytes4 internal constant TRANSFER = 0xa9059cbb; // transfer(address,uint256)

    modifier validAddress(address _to) {

        require(_to != address(0));
        _;
    }

    function claimValues(address _token, address _to) internal {

        if (_token == address(0)) {
            claimNativeCoins(_to);
        } else {
            claimErc20Tokens(_token, _to);
        }
    }

    function claimNativeCoins(address _to) internal {

        uint256 value = address(this).balance;
        if (!_to.send(value)) {
            (new Sacrifice).value(value)(_to);
        }
    }

    function claimErc20Tokens(address _token, address _to) internal {

        ERC20Basic token = ERC20Basic(_token);
        uint256 balance = token.balanceOf(this);
        safeTransfer(_token, _to, balance);
    }

    function safeTransfer(address _token, address _to, uint256 _value) internal {

        bytes memory returnData;
        bool returnDataResult;
        bytes memory callData = abi.encodeWithSelector(TRANSFER, _to, _value);
        assembly {
            let result := call(gas, _token, 0x0, add(callData, 0x20), mload(callData), 0, 32)
            returnData := mload(0)
            returnDataResult := mload(0)

            switch result
                case 0 {
                    revert(0, 0)
                }
        }

        if (returnData.length > 0) {
            require(returnDataResult);
        }
    }
}


pragma solidity 0.4.24;

contract VersionableBridge {

    function getBridgeInterfacesVersion() external pure returns (uint64 major, uint64 minor, uint64 patch) {

        return (3, 0, 0);
    }

    function getBridgeMode() external pure returns (bytes4);

}


pragma solidity 0.4.24;












contract BasicAMBErc677ToErc677 is
    Initializable,
    Ownable,
    ReentrancyGuard,
    Upgradeable,
    Claimable,
    VersionableBridge,
    BaseOverdrawManagement,
    BaseERC677Bridge
{

    event FailedMessageFixed(bytes32 indexed dataHash, address recipient, uint256 value);

    bytes32 internal constant BRIDGE_CONTRACT = 0x811bbb11e8899da471f0e69a3ed55090fc90215227fc5fb1cb0d6e962ea7b74f; // keccak256(abi.encodePacked("bridgeContract"))
    bytes32 internal constant MEDIATOR_CONTRACT = 0x98aa806e31e94a687a31c65769cb99670064dd7f5a87526da075c5fb4eab9880; // keccak256(abi.encodePacked("mediatorContract"))
    bytes32 internal constant REQUEST_GAS_LIMIT = 0x2dfd6c9f781bb6bbb5369c114e949b69ebb440ef3d4dd6b2836225eb1dc3a2be; // keccak256(abi.encodePacked("requestGasLimit"))
    bytes32 internal constant NONCE = 0x7ab1577440dd7bedf920cb6de2f9fc6bf7ba98c78c85a3fa1f8311aac95e1759; // keccak256(abi.encodePacked("nonce"))

    function initialize(
        address _bridgeContract,
        address _mediatorContract,
        address _erc677token,
        uint256[] _dailyLimitMaxPerTxMinPerTxArray, // [ 0 = _dailyLimit, 1 = _maxPerTx, 2 = _minPerTx ]
        uint256[] _executionDailyLimitExecutionMaxPerTxArray, // [ 0 = _executionDailyLimit, 1 = _executionMaxPerTx ]
        uint256 _requestGasLimit,
        uint256 _decimalShift,
        address _owner
    ) external onlyRelevantSender returns (bool) {

        require(!isInitialized());
        require(
            _dailyLimitMaxPerTxMinPerTxArray[2] > 0 && // _minPerTx > 0
                _dailyLimitMaxPerTxMinPerTxArray[1] > _dailyLimitMaxPerTxMinPerTxArray[2] && // _maxPerTx > _minPerTx
                _dailyLimitMaxPerTxMinPerTxArray[0] > _dailyLimitMaxPerTxMinPerTxArray[1] // _dailyLimit > _maxPerTx
        );
        require(_executionDailyLimitExecutionMaxPerTxArray[1] < _executionDailyLimitExecutionMaxPerTxArray[0]); // _executionMaxPerTx < _executionDailyLimit

        _setBridgeContract(_bridgeContract);
        _setMediatorContractOnOtherSide(_mediatorContract);
        setErc677token(_erc677token);
        uintStorage[DAILY_LIMIT] = _dailyLimitMaxPerTxMinPerTxArray[0];
        uintStorage[MAX_PER_TX] = _dailyLimitMaxPerTxMinPerTxArray[1];
        uintStorage[MIN_PER_TX] = _dailyLimitMaxPerTxMinPerTxArray[2];
        uintStorage[EXECUTION_DAILY_LIMIT] = _executionDailyLimitExecutionMaxPerTxArray[0];
        uintStorage[EXECUTION_MAX_PER_TX] = _executionDailyLimitExecutionMaxPerTxArray[1];
        _setRequestGasLimit(_requestGasLimit);
        uintStorage[DECIMAL_SHIFT] = _decimalShift;
        setOwner(_owner);
        setNonce(keccak256(abi.encodePacked(address(this))));
        setInitialize();

        emit DailyLimitChanged(_dailyLimitMaxPerTxMinPerTxArray[0]);
        emit ExecutionDailyLimitChanged(_executionDailyLimitExecutionMaxPerTxArray[0]);

        return isInitialized();
    }

    function bridgeContractOnOtherSide() internal view returns (address) {

        return mediatorContractOnOtherSide();
    }

    function passMessage(address _from, uint256 _value) internal {

        bytes4 methodSelector = this.handleBridgedTokens.selector;
        bytes memory data = abi.encodeWithSelector(methodSelector, _from, _value, nonce());

        bytes32 dataHash = keccak256(data);
        setMessageHashValue(dataHash, _value);
        setMessageHashRecipient(dataHash, _from);
        setNonce(dataHash);

        bridgeContract().requireToPassMessage(mediatorContractOnOtherSide(), data, requestGasLimit());
    }

    function relayTokens(address _from, address _receiver, uint256 _value) external {

        require(_from == msg.sender || _from == _receiver);
        _relayTokens(_from, _receiver, _value);
    }

    function _relayTokens(address _from, address _receiver, uint256 _value) internal {

        require(!lock());
        ERC677 token = erc677token();
        address to = address(this);
        require(withinLimit(_value));
        setTotalSpentPerDay(getCurrentDay(), totalSpentPerDay(getCurrentDay()).add(_value));

        setLock(true);
        token.transferFrom(_from, to, _value);
        setLock(false);
        bridgeSpecificActionsOnTokenTransfer(token, _from, _value, abi.encodePacked(_receiver));
    }

    function relayTokens(address _receiver, uint256 _value) external {

        _relayTokens(msg.sender, _receiver, _value);
    }

    function onTokenTransfer(address _from, uint256 _value, bytes _data) external returns (bool) {

        ERC677 token = erc677token();
        require(msg.sender == address(token));
        if (!lock()) {
            require(withinLimit(_value));
            setTotalSpentPerDay(getCurrentDay(), totalSpentPerDay(getCurrentDay()).add(_value));
        }
        bridgeSpecificActionsOnTokenTransfer(token, _from, _value, _data);
        return true;
    }

    function getBridgeInterfacesVersion() external pure returns (uint64 major, uint64 minor, uint64 patch) {

        return (1, 1, 0);
    }

    function getBridgeMode() external pure returns (bytes4 _data) {

        return 0x76595b56; // bytes4(keccak256(abi.encodePacked("erc-to-erc-amb")))
    }

    function setBridgeContract(address _bridgeContract) external onlyOwner {

        _setBridgeContract(_bridgeContract);
    }

    function _setBridgeContract(address _bridgeContract) internal {

        require(AddressUtils.isContract(_bridgeContract));
        addressStorage[BRIDGE_CONTRACT] = _bridgeContract;
    }

    function bridgeContract() public view returns (IAMB) {

        return IAMB(addressStorage[BRIDGE_CONTRACT]);
    }

    function setMediatorContractOnOtherSide(address _mediatorContract) external onlyOwner {

        _setMediatorContractOnOtherSide(_mediatorContract);
    }

    function _setMediatorContractOnOtherSide(address _mediatorContract) internal {

        addressStorage[MEDIATOR_CONTRACT] = _mediatorContract;
    }

    function mediatorContractOnOtherSide() public view returns (address) {

        return addressStorage[MEDIATOR_CONTRACT];
    }

    function setRequestGasLimit(uint256 _requestGasLimit) external onlyOwner {

        _setRequestGasLimit(_requestGasLimit);
    }

    function _setRequestGasLimit(uint256 _requestGasLimit) internal {

        require(_requestGasLimit <= maxGasPerTx());
        uintStorage[REQUEST_GAS_LIMIT] = _requestGasLimit;
    }

    function requestGasLimit() public view returns (uint256) {

        return uintStorage[REQUEST_GAS_LIMIT];
    }

    function messageSender() internal view returns (address) {

        return bridgeContract().messageSender();
    }

    function transactionHash() internal view returns (bytes32) {

        return bridgeContract().transactionHash();
    }

    function maxGasPerTx() internal view returns (uint256) {

        return bridgeContract().maxGasPerTx();
    }

    function nonce() internal view returns (bytes32) {

        return Bytes.bytesToBytes32(bytesStorage[NONCE]);
    }

    function setNonce(bytes32 _hash) internal {

        bytesStorage[NONCE] = abi.encodePacked(_hash);
    }

    function setMessageHashValue(bytes32 _hash, uint256 _value) internal {

        uintStorage[keccak256(abi.encodePacked("messageHashValue", _hash))] = _value;
    }

    function messageHashValue(bytes32 _hash) internal view returns (uint256) {

        return uintStorage[keccak256(abi.encodePacked("messageHashValue", _hash))];
    }

    function setMessageHashRecipient(bytes32 _hash, address _recipient) internal {

        addressStorage[keccak256(abi.encodePacked("messageHashRecipient", _hash))] = _recipient;
    }

    function messageHashRecipient(bytes32 _hash) internal view returns (address) {

        return addressStorage[keccak256(abi.encodePacked("messageHashRecipient", _hash))];
    }

    function setMessageHashFixed(bytes32 _hash) internal {

        boolStorage[keccak256(abi.encodePacked("messageHashFixed", _hash))] = true;
    }

    function messageHashFixed(bytes32 _hash) public view returns (bool) {

        return boolStorage[keccak256(abi.encodePacked("messageHashFixed", _hash))];
    }

    function handleBridgedTokens(
        address _recipient,
        uint256 _value,
        bytes32 /* nonce */
    ) external {

        require(msg.sender == address(bridgeContract()));
        require(messageSender() == mediatorContractOnOtherSide());
        if (withinExecutionLimit(_value)) {
            setTotalExecutedPerDay(getCurrentDay(), totalExecutedPerDay(getCurrentDay()).add(_value));
            executeActionOnBridgedTokens(_recipient, _value);
        } else {
            bytes32 txHash = transactionHash();
            address recipient;
            uint256 value;
            (recipient, value) = txAboveLimits(txHash);
            require(recipient == address(0) && value == 0);
            setOutOfLimitAmount(outOfLimitAmount().add(_value));
            setTxAboveLimits(_recipient, _value, txHash);
            emit AmountLimitExceeded(_recipient, _value, txHash);
        }
    }

    function fixAssetsAboveLimits(bytes32 txHash, bool unlockOnForeign, uint256 valueToUnlock)
        external
        onlyIfUpgradeabilityOwner
    {

        require(!fixedAssets(txHash));
        require(valueToUnlock <= maxPerTx());
        address recipient;
        uint256 value;
        (recipient, value) = txAboveLimits(txHash);
        require(recipient != address(0) && value > 0 && value >= valueToUnlock);
        setOutOfLimitAmount(outOfLimitAmount().sub(valueToUnlock));
        uint256 pendingValue = value.sub(valueToUnlock);
        setTxAboveLimitsValue(pendingValue, txHash);
        emit AssetAboveLimitsFixed(txHash, valueToUnlock, pendingValue);
        if (pendingValue == 0) {
            setFixedAssets(txHash);
        }
        if (unlockOnForeign) {
            passMessage(recipient, valueToUnlock);
        }
    }

    function requestFailedMessageFix(bytes32 _txHash) external {

        require(!bridgeContract().messageCallStatus(_txHash));
        require(bridgeContract().failedMessageReceiver(_txHash) == address(this));
        require(bridgeContract().failedMessageSender(_txHash) == mediatorContractOnOtherSide());
        bytes32 dataHash = bridgeContract().failedMessageDataHash(_txHash);

        bytes4 methodSelector = this.fixFailedMessage.selector;
        bytes memory data = abi.encodeWithSelector(methodSelector, dataHash);
        bridgeContract().requireToPassMessage(mediatorContractOnOtherSide(), data, requestGasLimit());
    }

    function fixFailedMessage(bytes32 _dataHash) external {

        require(msg.sender == address(bridgeContract()));
        require(messageSender() == mediatorContractOnOtherSide());
        require(!messageHashFixed(_dataHash));

        address recipient = messageHashRecipient(_dataHash);
        uint256 value = messageHashValue(_dataHash);
        setMessageHashFixed(_dataHash);
        executeActionOnFixedTokens(recipient, value);
        emit FailedMessageFixed(_dataHash, recipient, value);
    }

    function claimTokens(address _token, address _to) public onlyIfUpgradeabilityOwner validAddress(_to) {

        claimValues(_token, _to);
    }

    function executeActionOnBridgedTokens(address _recipient, uint256 _value) internal;


    function executeActionOnFixedTokens(address, uint256) internal;

}


pragma solidity 0.4.24;


contract ForeignAMBErc677ToErc677 is BasicAMBErc677ToErc677 {

    function executeActionOnBridgedTokens(address _recipient, uint256 _value) internal {

        uint256 value = _value.div(10**decimalShift());
        erc677token().transfer(_recipient, value);
    }

    function bridgeSpecificActionsOnTokenTransfer(
        ERC677, /* _token */
        address _from,
        uint256 _value,
        bytes _data
    ) internal {

        if (!lock()) {
            passMessage(chooseReceiver(_from, _data), _value);
        }
    }

    function executeActionOnFixedTokens(address _recipient, uint256 _value) internal {

        erc677token().transfer(_recipient, _value);
    }
}