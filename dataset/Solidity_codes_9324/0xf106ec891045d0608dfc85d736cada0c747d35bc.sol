

pragma solidity 0.4.24;

interface IBridgeValidators {

    function isValidator(address _validator) external view returns (bool);

    function requiredSignatures() external view returns (uint256);

    function owner() external view returns (address);

}


pragma solidity 0.4.24;


library Message {

    function addressArrayContains(address[] array, address value) internal pure returns (bool) {

        for (uint256 i = 0; i < array.length; i++) {
            if (array[i] == value) {
                return true;
            }
        }
        return false;
    }

    function parseMessage(bytes message)
        internal
        pure
        returns (address recipient, uint256 amount, bytes32 txHash, address contractAddress)
    {

        require(isMessageValid(message));
        assembly {
            recipient := mload(add(message, 20))
            amount := mload(add(message, 52))
            txHash := mload(add(message, 84))
            contractAddress := mload(add(message, 104))
        }
    }

    function isMessageValid(bytes _msg) internal pure returns (bool) {

        return _msg.length == requiredMessageLength();
    }

    function requiredMessageLength() internal pure returns (uint256) {

        return 104;
    }

    function recoverAddressFromSignedMessage(bytes signature, bytes message, bool isAMBMessage)
        internal
        pure
        returns (address)
    {

        require(signature.length == 65);
        bytes32 r;
        bytes32 s;
        bytes1 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := mload(add(signature, 0x60))
        }
        require(uint8(v) == 27 || uint8(v) == 28);
        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0);

        return ecrecover(hashMessage(message, isAMBMessage), uint8(v), r, s);
    }

    function hashMessage(bytes message, bool isAMBMessage) internal pure returns (bytes32) {

        bytes memory prefix = "\x19Ethereum Signed Message:\n";
        if (isAMBMessage) {
            return keccak256(abi.encodePacked(prefix, uintToString(message.length), message));
        } else {
            string memory msgLength = "104";
            return keccak256(abi.encodePacked(prefix, msgLength, message));
        }
    }

    function hasEnoughValidSignatures(
        bytes _message,
        bytes _signatures,
        IBridgeValidators _validatorContract,
        bool isAMBMessage
    ) internal view {

        require(isAMBMessage || isMessageValid(_message));
        uint256 requiredSignatures = _validatorContract.requiredSignatures();
        uint256 amount;
        assembly {
            amount := and(mload(add(_signatures, 1)), 0xff)
        }
        require(amount >= requiredSignatures);
        bytes32 hash = hashMessage(_message, isAMBMessage);
        address[] memory encounteredAddresses = new address[](requiredSignatures);

        for (uint256 i = 0; i < requiredSignatures; i++) {
            uint8 v;
            bytes32 r;
            bytes32 s;
            uint256 posr = 33 + amount + 32 * i;
            uint256 poss = posr + 32 * amount;
            assembly {
                v := mload(add(_signatures, add(2, i)))
                r := mload(add(_signatures, posr))
                s := mload(add(_signatures, poss))
            }

            address recoveredAddress = ecrecover(hash, v, r, s);
            require(_validatorContract.isValidator(recoveredAddress));
            require(!addressArrayContains(encounteredAddresses, recoveredAddress));
            encounteredAddresses[i] = recoveredAddress;
        }
    }

    function uintToString(uint256 i) internal pure returns (string) {

        if (i == 0) return "0";
        uint256 j = i;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length - 1;
        while (i != 0) {
            bstr[k--] = bytes1(48 + (i % 10));
            i /= 10;
        }
        return string(bstr);
    }
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

contract ValidatorStorage {

    bytes32 internal constant VALIDATOR_CONTRACT = 0x5a74bb7e202fb8e4bf311841c7d64ec19df195fee77d7e7ae749b27921b6ddfe; // keccak256(abi.encodePacked("validatorContract"))
}


pragma solidity 0.4.24;




contract Validatable is EternalStorage, ValidatorStorage {

    function validatorContract() public view returns (IBridgeValidators) {

        return IBridgeValidators(addressStorage[VALIDATOR_CONTRACT]);
    }

    modifier onlyValidator() {

        require(validatorContract().isValidator(msg.sender));
        _;
    }

    function requiredSignatures() public view returns (uint256) {

        return validatorContract().requiredSignatures();
    }

}


pragma solidity 0.4.24;

interface IUpgradeabilityOwnerStorage {

    function upgradeabilityOwner() external view returns (address);

}


pragma solidity 0.4.24;


contract Upgradeable {

    modifier onlyIfUpgradeabilityOwner() {

        require(msg.sender == IUpgradeabilityOwnerStorage(this).upgradeabilityOwner());
        _;
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


pragma solidity 0.4.24;


contract InitializableBridge is Initializable {

    bytes32 internal constant DEPLOYED_AT_BLOCK = 0xb120ceec05576ad0c710bc6e85f1768535e27554458f05dcbb5c65b8c7a749b0; // keccak256(abi.encodePacked("deployedAtBlock"))

    function deployedAtBlock() external view returns (uint256) {

        return uintStorage[DEPLOYED_AT_BLOCK];
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









contract BasicBridge is
    InitializableBridge,
    Validatable,
    Ownable,
    Upgradeable,
    Claimable,
    VersionableBridge,
    DecimalShiftBridge
{

    event GasPriceChanged(uint256 gasPrice);
    event RequiredBlockConfirmationChanged(uint256 requiredBlockConfirmations);

    bytes32 internal constant GAS_PRICE = 0x55b3774520b5993024893d303890baa4e84b1244a43c60034d1ced2d3cf2b04b; // keccak256(abi.encodePacked("gasPrice"))
    bytes32 internal constant REQUIRED_BLOCK_CONFIRMATIONS = 0x916daedf6915000ff68ced2f0b6773fe6f2582237f92c3c95bb4d79407230071; // keccak256(abi.encodePacked("requiredBlockConfirmations"))

    function setGasPrice(uint256 _gasPrice) external onlyOwner {

        _setGasPrice(_gasPrice);
    }

    function gasPrice() external view returns (uint256) {

        return uintStorage[GAS_PRICE];
    }

    function setRequiredBlockConfirmations(uint256 _blockConfirmations) external onlyOwner {

        _setRequiredBlockConfirmations(_blockConfirmations);
    }

    function _setRequiredBlockConfirmations(uint256 _blockConfirmations) internal {

        require(_blockConfirmations > 0);
        uintStorage[REQUIRED_BLOCK_CONFIRMATIONS] = _blockConfirmations;
        emit RequiredBlockConfirmationChanged(_blockConfirmations);
    }

    function requiredBlockConfirmations() external view returns (uint256) {

        return uintStorage[REQUIRED_BLOCK_CONFIRMATIONS];
    }

    function _setGasPrice(uint256 _gasPrice) internal {

        uintStorage[GAS_PRICE] = _gasPrice;
        emit GasPriceChanged(_gasPrice);
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


pragma solidity 0.4.24;








contract BasicHomeBridge is EternalStorage, Validatable, BasicBridge, BasicTokenBridge {

    using SafeMath for uint256;

    event UserRequestForSignature(address recipient, uint256 value);
    event AffirmationCompleted(address recipient, uint256 value, bytes32 transactionHash);
    event SignedForUserRequest(address indexed signer, bytes32 messageHash);
    event SignedForAffirmation(address indexed signer, bytes32 transactionHash);
    event CollectedSignatures(
        address authorityResponsibleForRelay,
        bytes32 messageHash,
        uint256 NumberOfCollectedSignatures
    );

    function executeAffirmation(address recipient, uint256 value, bytes32 transactionHash) external onlyValidator {

        bytes32 hashMsg = keccak256(abi.encodePacked(recipient, value, transactionHash));
        if (withinExecutionLimit(value)) {
            bytes32 hashSender = keccak256(abi.encodePacked(msg.sender, hashMsg));
            require(!affirmationsSigned(hashSender));
            setAffirmationsSigned(hashSender, true);

            uint256 signed = numAffirmationsSigned(hashMsg);
            require(!isAlreadyProcessed(signed));
            signed = signed + 1;

            setNumAffirmationsSigned(hashMsg, signed);

            emit SignedForAffirmation(msg.sender, transactionHash);

            if (signed >= requiredSignatures()) {
                setNumAffirmationsSigned(hashMsg, markAsProcessed(signed));
                if (value > 0) {
                    require(onExecuteAffirmation(recipient, value, transactionHash, hashMsg));
                }
                emit AffirmationCompleted(recipient, value, transactionHash);
            }
        } else {
            onFailedAffirmation(recipient, value, transactionHash, hashMsg);
        }
    }

    function submitSignature(bytes signature, bytes message) external onlyValidator {

        require(Message.isMessageValid(message));
        require(msg.sender == Message.recoverAddressFromSignedMessage(signature, message, false));
        bytes32 hashMsg = keccak256(abi.encodePacked(message));
        bytes32 hashSender = keccak256(abi.encodePacked(msg.sender, hashMsg));

        uint256 signed = numMessagesSigned(hashMsg);
        require(!isAlreadyProcessed(signed));
        signed = signed + 1;
        if (signed > 1) {
            require(!messagesSigned(hashSender));
        } else {
            setMessages(hashMsg, message);
        }
        setMessagesSigned(hashSender, true);

        bytes32 signIdx = keccak256(abi.encodePacked(hashMsg, (signed - 1)));
        setSignatures(signIdx, signature);

        setNumMessagesSigned(hashMsg, signed);

        emit SignedForUserRequest(msg.sender, hashMsg);

        uint256 reqSigs = requiredSignatures();
        if (signed >= reqSigs) {
            setNumMessagesSigned(hashMsg, markAsProcessed(signed));
            emit CollectedSignatures(msg.sender, hashMsg, reqSigs);

            onSignaturesCollected(message);
        }
    }

    function setMessagesSigned(bytes32 _hash, bool _status) internal {

        boolStorage[keccak256(abi.encodePacked("messagesSigned", _hash))] = _status;
    }

    function onExecuteAffirmation(address, uint256, bytes32, bytes32) internal returns (bool);


    function onFailedAffirmation(address, uint256, bytes32, bytes32) internal;


    function onSignaturesCollected(bytes) internal;


    function numAffirmationsSigned(bytes32 _withdrawal) public view returns (uint256) {

        return uintStorage[keccak256(abi.encodePacked("numAffirmationsSigned", _withdrawal))];
    }

    function setAffirmationsSigned(bytes32 _withdrawal, bool _status) internal {

        boolStorage[keccak256(abi.encodePacked("affirmationsSigned", _withdrawal))] = _status;
    }

    function setNumAffirmationsSigned(bytes32 _withdrawal, uint256 _number) internal {

        uintStorage[keccak256(abi.encodePacked("numAffirmationsSigned", _withdrawal))] = _number;
    }

    function affirmationsSigned(bytes32 _withdrawal) public view returns (bool) {

        return boolStorage[keccak256(abi.encodePacked("affirmationsSigned", _withdrawal))];
    }

    function signature(bytes32 _hash, uint256 _index) external view returns (bytes) {

        bytes32 signIdx = keccak256(abi.encodePacked(_hash, _index));
        return bytesStorage[keccak256(abi.encodePacked("signatures", signIdx))];
    }

    function messagesSigned(bytes32 _message) public view returns (bool) {

        return boolStorage[keccak256(abi.encodePacked("messagesSigned", _message))];
    }

    function setSignatures(bytes32 _hash, bytes _signature) internal {

        bytesStorage[keccak256(abi.encodePacked("signatures", _hash))] = _signature;
    }

    function setMessages(bytes32 _hash, bytes _message) internal {

        bytesStorage[keccak256(abi.encodePacked("messages", _hash))] = _message;
    }

    function message(bytes32 _hash) external view returns (bytes) {

        return bytesStorage[keccak256(abi.encodePacked("messages", _hash))];
    }

    function setNumMessagesSigned(bytes32 _message, uint256 _number) internal {

        uintStorage[keccak256(abi.encodePacked("numMessagesSigned", _message))] = _number;
    }

    function markAsProcessed(uint256 _v) internal pure returns (uint256) {

        return _v | (2**255);
    }

    function isAlreadyProcessed(uint256 _number) public pure returns (bool) {

        return _number & (2**255) == 2**255;
    }

    function numMessagesSigned(bytes32 _message) public view returns (uint256) {

        return uintStorage[keccak256(abi.encodePacked("numMessagesSigned", _message))];
    }

    function requiredMessageLength() public pure returns (uint256) {

        return Message.requiredMessageLength();
    }
}


pragma solidity 0.4.24;

contract FeeTypes {

    bytes32 internal constant HOME_FEE = 0x89d93e5e92f7e37e490c25f0e50f7f4aad7cc94b308a566553280967be38bcf1; // keccak256(abi.encodePacked("home-fee"))
    bytes32 internal constant FOREIGN_FEE = 0xdeb7f3adca07d6d1f708c1774389db532a2b2f18fd05a62b957e4089f4696ed5; // keccak256(abi.encodePacked("foreign-fee"))

    modifier validFeeType(bytes32 _feeType) {

        require(_feeType == HOME_FEE || _feeType == FOREIGN_FEE);
        _;
    }
}


pragma solidity 0.4.24;




contract RewardableBridge is Ownable, FeeTypes {

    event FeeDistributedFromAffirmation(uint256 feeAmount, bytes32 indexed transactionHash);
    event FeeDistributedFromSignatures(uint256 feeAmount, bytes32 indexed transactionHash);

    bytes32 internal constant FEE_MANAGER_CONTRACT = 0x779a349c5bee7817f04c960f525ee3e2f2516078c38c68a3149787976ee837e5; // keccak256(abi.encodePacked("feeManagerContract"))
    bytes4 internal constant GET_HOME_FEE = 0x94da17cd; // getHomeFee()
    bytes4 internal constant GET_FOREIGN_FEE = 0xffd66196; // getForeignFee()
    bytes4 internal constant GET_FEE_MANAGER_MODE = 0xf2ba9561; // getFeeManagerMode()
    bytes4 internal constant SET_HOME_FEE = 0x34a9e148; // setHomeFee(uint256)
    bytes4 internal constant SET_FOREIGN_FEE = 0x286c4066; // setForeignFee(uint256)
    bytes4 internal constant CALCULATE_FEE = 0x9862f26f; // calculateFee(uint256,bool,bytes32)
    bytes4 internal constant DISTRIBUTE_FEE_FROM_SIGNATURES = 0x59d78464; // distributeFeeFromSignatures(uint256)
    bytes4 internal constant DISTRIBUTE_FEE_FROM_AFFIRMATION = 0x054d46ec; // distributeFeeFromAffirmation(uint256)

    function _getFee(bytes32 _feeType) internal view validFeeType(_feeType) returns (uint256 fee) {

        address feeManager = feeManagerContract();
        bytes4 method = _feeType == HOME_FEE ? GET_HOME_FEE : GET_FOREIGN_FEE;
        bytes memory callData = abi.encodeWithSelector(method);

        assembly {
            let result := callcode(gas, feeManager, 0x0, add(callData, 0x20), mload(callData), 0, 32)

            if and(eq(returndatasize, 32), result) {
                fee := mload(0)
            }
        }
    }

    function getFeeManagerMode() external view returns (bytes4 mode) {

        bytes memory callData = abi.encodeWithSelector(GET_FEE_MANAGER_MODE);
        address feeManager = feeManagerContract();
        assembly {
            let result := callcode(gas, feeManager, 0x0, add(callData, 0x20), mload(callData), 0, 4)

            if and(eq(returndatasize, 32), result) {
                mode := mload(0)
            }
        }
    }

    function feeManagerContract() public view returns (address) {

        return addressStorage[FEE_MANAGER_CONTRACT];
    }

    function setFeeManagerContract(address _feeManager) external onlyOwner {

        require(_feeManager == address(0) || AddressUtils.isContract(_feeManager));
        addressStorage[FEE_MANAGER_CONTRACT] = _feeManager;
    }

    function _setFee(address _feeManager, uint256 _fee, bytes32 _feeType) internal validFeeType(_feeType) {

        bytes4 method = _feeType == HOME_FEE ? SET_HOME_FEE : SET_FOREIGN_FEE;
        require(_feeManager.delegatecall(abi.encodeWithSelector(method, _fee)));
    }

    function calculateFee(uint256 _value, bool _recover, address _impl, bytes32 _feeType)
        internal
        view
        returns (uint256 fee)
    {

        bytes memory callData = abi.encodeWithSelector(CALCULATE_FEE, _value, _recover, _feeType);
        assembly {
            let result := callcode(gas, _impl, 0x0, add(callData, 0x20), mload(callData), 0, 32)

            switch and(eq(returndatasize, 32), result)
                case 1 {
                    fee := mload(0)
                }
                default {
                    revert(0, 0)
                }
        }
    }

    function distributeFeeFromSignatures(uint256 _fee, address _feeManager, bytes32 _txHash) internal {

        if (_fee > 0) {
            require(_feeManager.delegatecall(abi.encodeWithSelector(DISTRIBUTE_FEE_FROM_SIGNATURES, _fee)));
            emit FeeDistributedFromSignatures(_fee, _txHash);
        }
    }

    function distributeFeeFromAffirmation(uint256 _fee, address _feeManager, bytes32 _txHash) internal {

        if (_fee > 0) {
            require(_feeManager.delegatecall(abi.encodeWithSelector(DISTRIBUTE_FEE_FROM_AFFIRMATION, _fee)));
            emit FeeDistributedFromAffirmation(_fee, _txHash);
        }
    }
}


pragma solidity 0.4.24;


contract RewardableHomeBridgeNativeToErc is RewardableBridge {

    function setHomeFee(uint256 _fee) external onlyOwner {

        _setFee(feeManagerContract(), _fee, HOME_FEE);
    }

    function setForeignFee(uint256 _fee) external onlyOwner {

        _setFee(feeManagerContract(), _fee, FOREIGN_FEE);
    }

    function getForeignFee() public view returns (uint256) {

        return _getFee(FOREIGN_FEE);
    }

    function getHomeFee() public view returns (uint256) {

        return _getFee(HOME_FEE);
    }
}


pragma solidity 0.4.24;






contract HomeBridgeNativeToErc is EternalStorage, BasicHomeBridge, RewardableHomeBridgeNativeToErc {

    function() public payable {
        require(msg.data.length == 0);
        nativeTransfer(msg.sender);
    }

    function nativeTransfer(address _receiver) internal {

        require(msg.value > 0);
        require(withinLimit(msg.value));
        addTotalSpentPerDay(getCurrentDay(), msg.value);
        uint256 valueToTransfer = msg.value;
        address feeManager = feeManagerContract();
        if (feeManager != address(0)) {
            uint256 fee = calculateFee(valueToTransfer, false, feeManager, HOME_FEE);
            valueToTransfer = valueToTransfer.sub(fee);
        }
        emit UserRequestForSignature(_receiver, valueToTransfer);
    }

    function relayTokens(address _receiver) external payable {

        nativeTransfer(_receiver);
    }

    function initialize(
        address _validatorContract,
        uint256[3] _dailyLimitMaxPerTxMinPerTxArray, // [ 0 = _dailyLimit, 1 = _maxPerTx, 2 = _minPerTx ]
        uint256 _homeGasPrice,
        uint256 _requiredBlockConfirmations,
        uint256[2] _foreignDailyLimitForeignMaxPerTxArray, // [ 0 = _foreignDailyLimit, 1 = _foreignMaxPerTx ]
        address _owner,
        int256 _decimalShift
    ) external onlyRelevantSender returns (bool) {

        _initialize(
            _validatorContract,
            _dailyLimitMaxPerTxMinPerTxArray,
            _homeGasPrice,
            _requiredBlockConfirmations,
            _foreignDailyLimitForeignMaxPerTxArray,
            _owner,
            _decimalShift
        );
        setInitialize();
        return isInitialized();
    }

    function rewardableInitialize(
        address _validatorContract,
        uint256[3] _dailyLimitMaxPerTxMinPerTxArray, // [ 0 = _dailyLimit, 1 = _maxPerTx, 2 = _minPerTx ]
        uint256 _homeGasPrice,
        uint256 _requiredBlockConfirmations,
        uint256[2] _foreignDailyLimitForeignMaxPerTxArray, // [ 0 = _foreignDailyLimit, 1 = _foreignMaxPerTx ]
        address _owner,
        address _feeManager,
        uint256[2] _homeFeeForeignFeeArray, // [ 0 = _homeFee, 1 = _foreignFee ]
        int256 _decimalShift
    ) external onlyRelevantSender returns (bool) {

        _initialize(
            _validatorContract,
            _dailyLimitMaxPerTxMinPerTxArray,
            _homeGasPrice,
            _requiredBlockConfirmations,
            _foreignDailyLimitForeignMaxPerTxArray,
            _owner,
            _decimalShift
        );
        require(AddressUtils.isContract(_feeManager));
        addressStorage[FEE_MANAGER_CONTRACT] = _feeManager;
        _setFee(_feeManager, _homeFeeForeignFeeArray[0], HOME_FEE);
        _setFee(_feeManager, _homeFeeForeignFeeArray[1], FOREIGN_FEE);
        setInitialize();
        return isInitialized();
    }

    function getBridgeMode() external pure returns (bytes4 _data) {

        return 0x92a8d7fe; // bytes4(keccak256(abi.encodePacked("native-to-erc-core")))
    }

    function claimTokens(address _token, address _to) external onlyIfUpgradeabilityOwner {

        require(_token != address(0));
        claimValues(_token, _to);
    }

    function _initialize(
        address _validatorContract,
        uint256[3] _dailyLimitMaxPerTxMinPerTxArray, // [ 0 = _dailyLimit, 1 = _maxPerTx, 2 = _minPerTx ]
        uint256 _homeGasPrice,
        uint256 _requiredBlockConfirmations,
        uint256[2] _foreignDailyLimitForeignMaxPerTxArray, // [ 0 = _foreignDailyLimit, 1 = _foreignMaxPerTx ]
        address _owner,
        int256 _decimalShift
    ) internal {

        require(!isInitialized());
        require(AddressUtils.isContract(_validatorContract));

        addressStorage[VALIDATOR_CONTRACT] = _validatorContract;
        uintStorage[DEPLOYED_AT_BLOCK] = block.number;
        _setLimits(_dailyLimitMaxPerTxMinPerTxArray);
        _setGasPrice(_homeGasPrice);
        _setRequiredBlockConfirmations(_requiredBlockConfirmations);
        _setExecutionLimits(_foreignDailyLimitForeignMaxPerTxArray);
        _setDecimalShift(_decimalShift);
        _setOwner(_owner);
    }

    function onSignaturesCollected(bytes _message) internal {

        address feeManager = feeManagerContract();
        if (feeManager != address(0)) {
            (, uint256 amount, bytes32 txHash, ) = Message.parseMessage(_message);
            uint256 fee = calculateFee(amount, true, feeManager, HOME_FEE);
            distributeFeeFromSignatures(fee, feeManager, txHash);
        }
    }

    function onExecuteAffirmation(address _recipient, uint256 _value, bytes32 _txHash, bytes32 _hashMsg)
        internal
        returns (bool)
    {

        addTotalExecutedPerDay(getCurrentDay(), _value);
        uint256 valueToTransfer = _shiftValue(_value);

        address feeManager = feeManagerContract();
        if (feeManager != address(0)) {
            uint256 fee = calculateFee(valueToTransfer, false, feeManager, FOREIGN_FEE);
            distributeFeeFromAffirmation(fee, feeManager, _txHash);
            valueToTransfer = valueToTransfer.sub(fee);
        }

        Address.safeSendValue(_recipient, valueToTransfer);
        return true;
    }

    function onFailedAffirmation(address _recipient, uint256 _value, bytes32 _txHash, bytes32 _hashMsg) internal {

        revert();
    }

    function _setGasPrice(uint256 _gasPrice) internal {

        require(_gasPrice > 0);
        super._setGasPrice(_gasPrice);
    }
}