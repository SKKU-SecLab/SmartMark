
pragma solidity ^0.5.0;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0);
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);
        return a % b;
    }
}

interface IERC20 {

    function transfer(address to, uint256 value) external returns (bool);


    function approve(address spender, uint256 value) external returns (bool);


    function transferFrom(address from, address to, uint256 value) external returns (bool);


    function totalSupply() external view returns (uint256);


    function balanceOf(address who) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IOwnable {

    function owner() external view returns(address ownerAddress);


    function renounceOwnership() external;


    function transferOwnership(address _newOwner) external;


}

interface ISTFactory {


    event LogicContractSet(string _version, address _logicContract, bytes _upgradeData);
    event TokenUpgraded(
        address indexed _securityToken,
        uint256 indexed _version
    );
    event DefaultTransferManagerUpdated(address indexed _oldTransferManagerFactory, address indexed _newTransferManagerFactory);
    event DefaultDataStoreUpdated(address indexed _oldDataStoreFactory, address indexed _newDataStoreFactory);

    function deployToken(
        string calldata _name,
        string calldata _symbol,
        uint8 _decimals,
        string calldata _tokenDetails,
        address _issuer,
        bool _divisible,
        address _treasuryWallet //In v2.x this is the Polymath Registry
    )
    external
    returns(address tokenAddress);


    function setLogicContract(string calldata _version, address _logicContract, bytes calldata _initializationData, bytes calldata _upgradeData) external;


    function upgradeToken(uint8 _maxModuleType) external;


    function updateDefaultTransferManager(address _transferManagerFactory) external;


    function updateDefaultDataStore(address _dataStoreFactory) external;

}

interface ISecurityToken {

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function decimals() external view returns(uint8);

    function totalSupply() external view returns(uint256);

    function balanceOf(address owner) external view returns(uint256);

    function allowance(address owner, address spender) external view returns(uint256);

    function transfer(address to, uint256 value) external returns(bool);

    function transferFrom(address from, address to, uint256 value) external returns(bool);

    function approve(address spender, uint256 value) external returns(bool);

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function canTransfer(address _to, uint256 _value, bytes calldata _data) external view returns (byte statusCode, bytes32 reasonCode);


    event ModuleAdded(
        uint8[] _types,
        bytes32 indexed _name,
        address indexed _moduleFactory,
        address _module,
        uint256 _moduleCost,
        uint256 _budget,
        bytes32 _label,
        bool _archived
    );

    event UpdateTokenDetails(string _oldDetails, string _newDetails);
    event UpdateTokenName(string _oldName, string _newName);
    event GranularityChanged(uint256 _oldGranularity, uint256 _newGranularity);
    event FreezeIssuance();
    event FreezeTransfers(bool _status);
    event CheckpointCreated(uint256 indexed _checkpointId, uint256 _investorLength);
    event SetController(address indexed _oldController, address indexed _newController);
    event TreasuryWalletChanged(address _oldTreasuryWallet, address _newTreasuryWallet);
    event DisableController();
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event TokenUpgraded(uint8 _major, uint8 _minor, uint8 _patch);

    event ModuleArchived(uint8[] _types, address _module); //Event emitted by the tokenLib.
    event ModuleUnarchived(uint8[] _types, address _module); //Event emitted by the tokenLib.
    event ModuleRemoved(uint8[] _types, address _module); //Event emitted by the tokenLib.
    event ModuleBudgetChanged(uint8[] _moduleTypes, address _module, uint256 _oldBudget, uint256 _budget); //Event emitted by the tokenLib.

    event TransferByPartition(
        bytes32 indexed _fromPartition,
        address _operator,
        address indexed _from,
        address indexed _to,
        uint256 _value,
        bytes _data,
        bytes _operatorData
    );

    event AuthorizedOperator(address indexed operator, address indexed tokenHolder);
    event RevokedOperator(address indexed operator, address indexed tokenHolder);
    event AuthorizedOperatorByPartition(bytes32 indexed partition, address indexed operator, address indexed tokenHolder);
    event RevokedOperatorByPartition(bytes32 indexed partition, address indexed operator, address indexed tokenHolder);

    event IssuedByPartition(bytes32 indexed partition, address indexed to, uint256 value, bytes data);
    event RedeemedByPartition(bytes32 indexed partition, address indexed operator, address indexed from, uint256 value, bytes data, bytes operatorData);

    event DocumentRemoved(bytes32 indexed _name, string _uri, bytes32 _documentHash);
    event DocumentUpdated(bytes32 indexed _name, string _uri, bytes32 _documentHash);

    event ControllerTransfer(
        address _controller,
        address indexed _from,
        address indexed _to,
        uint256 _value,
        bytes _data,
        bytes _operatorData
    );

    event ControllerRedemption(
        address _controller,
        address indexed _tokenHolder,
        uint256 _value,
        bytes _data,
        bytes _operatorData
    );

    event Issued(address indexed _operator, address indexed _to, uint256 _value, bytes _data);
    event Redeemed(address indexed _operator, address indexed _from, uint256 _value, bytes _data);

    function initialize(address _getterDelegate) external;


    function canTransferByPartition(
        address _from,
        address _to,
        bytes32 _partition,
        uint256 _value,
        bytes calldata _data
    )
        external
        view
        returns (byte statusCode, bytes32 reasonCode, bytes32 partition);


    function canTransferFrom(address _from, address _to, uint256 _value, bytes calldata _data) external view returns (byte statusCode, bytes32 reasonCode);


    function setDocument(bytes32 _name, string calldata _uri, bytes32 _documentHash) external;


    function removeDocument(bytes32 _name) external;


    function getDocument(bytes32 _name) external view returns (string memory documentUri, bytes32 documentHash, uint256 documentTime);


    function getAllDocuments() external view returns (bytes32[] memory documentNames);


    function isControllable() external view returns (bool controlled);


    function isModule(address _module, uint8 _type) external view returns(bool isValid);


    function issue(address _tokenHolder, uint256 _value, bytes calldata _data) external;


    function issueMulti(address[] calldata _tokenHolders, uint256[] calldata _values) external;


    function issueByPartition(bytes32 _partition, address _tokenHolder, uint256 _value, bytes calldata _data) external;


    function redeemByPartition(bytes32 _partition, uint256 _value, bytes calldata _data) external;


    function redeem(uint256 _value, bytes calldata _data) external;


    function redeemFrom(address _tokenHolder, uint256 _value, bytes calldata _data) external;


    function operatorRedeemByPartition(
        bytes32 _partition,
        address _tokenHolder,
        uint256 _value,
        bytes calldata _data,
        bytes calldata _operatorData
    ) external;


    function checkPermission(address _delegate, address _module, bytes32 _perm) external view returns(bool hasPermission);


    function getModule(address _module) external view returns (bytes32 moduleName, address moduleAddress, address factoryAddress, bool isArchived, uint8[] memory moduleTypes, bytes32 moduleLabel);


    function getModulesByName(bytes32 _name) external view returns(address[] memory modules);


    function getModulesByType(uint8 _type) external view returns(address[] memory modules);


    function getTreasuryWallet() external view returns(address treasuryWallet);


    function totalSupplyAt(uint256 _checkpointId) external view returns(uint256 supply);


    function balanceOfAt(address _investor, uint256 _checkpointId) external view returns(uint256 balance);


    function createCheckpoint() external returns(uint256 checkpointId);


    function getCheckpointTimes() external view returns(uint256[] memory checkpointTimes);


    function getInvestors() external view returns(address[] memory investors);


    function getInvestorsAt(uint256 _checkpointId) external view returns(address[] memory investors);


    function getInvestorsSubsetAt(uint256 _checkpointId, uint256 _start, uint256 _end) external view returns(address[] memory investors);


    function iterateInvestors(uint256 _start, uint256 _end) external view returns(address[] memory investors);


    function currentCheckpointId() external view returns(uint256 checkpointId);


    function isOperator(address _operator, address _tokenHolder) external view returns (bool isValid);


    function isOperatorForPartition(bytes32 _partition, address _operator, address _tokenHolder) external view returns (bool isValid);


    function partitionsOf(address _tokenHolder) external view returns (bytes32[] memory partitions);


    function dataStore() external view returns (address dataStoreAddress);


    function changeDataStore(address _dataStore) external;



    function changeTreasuryWallet(address _wallet) external;


    function withdrawERC20(address _tokenContract, uint256 _value) external;


    function changeModuleBudget(address _module, uint256 _change, bool _increase) external;


    function updateTokenDetails(string calldata _newTokenDetails) external;


    function changeName(string calldata _name) external;


    function changeGranularity(uint256 _granularity) external;


    function freezeTransfers() external;


    function unfreezeTransfers() external;


    function freezeIssuance(bytes calldata _signature) external;


    function addModuleWithLabel(
        address _moduleFactory,
        bytes calldata _data,
        uint256 _maxCost,
        uint256 _budget,
        bytes32 _label,
        bool _archived
    ) external;


    function addModule(address _moduleFactory, bytes calldata _data, uint256 _maxCost, uint256 _budget, bool _archived) external;


    function archiveModule(address _module) external;


    function unarchiveModule(address _module) external;


    function removeModule(address _module) external;


    function setController(address _controller) external;


    function controllerTransfer(address _from, address _to, uint256 _value, bytes calldata _data, bytes calldata _operatorData) external;


    function controllerRedeem(address _tokenHolder, uint256 _value, bytes calldata _data, bytes calldata _operatorData) external;


    function disableController(bytes calldata _signature) external;


    function getVersion() external view returns(uint8[] memory version);


    function getInvestorCount() external view returns(uint256 investorCount);


    function holderCount() external view returns(uint256 count);


    function transferWithData(address _to, uint256 _value, bytes calldata _data) external;


    function transferFromWithData(address _from, address _to, uint256 _value, bytes calldata _data) external;


    function transferByPartition(bytes32 _partition, address _to, uint256 _value, bytes calldata _data) external returns (bytes32 partition);


    function balanceOfByPartition(bytes32 _partition, address _tokenHolder) external view returns(uint256 balance);


    function granularity() external view returns(uint256 granularityAmount);


    function polymathRegistry() external view returns(address registryAddress);


    function upgradeModule(address _module) external;


    function upgradeToken() external;


    function isIssuable() external view returns (bool issuable);


    function authorizeOperator(address _operator) external;


    function revokeOperator(address _operator) external;


    function authorizeOperatorByPartition(bytes32 _partition, address _operator) external;


    function revokeOperatorByPartition(bytes32 _partition, address _operator) external;


    function operatorTransferByPartition(
        bytes32 _partition,
        address _from,
        address _to,
        uint256 _value,
        bytes calldata _data,
        bytes calldata _operatorData
    )
        external
        returns (bytes32 partition);


    function transfersFrozen() external view returns (bool isFrozen);


    function transferOwnership(address newOwner) external;


    function isOwner() external view returns (bool);


    function owner() external view returns (address ownerAddress);


    function controller() external view returns(address controllerAddress);


    function moduleRegistry() external view returns(address moduleRegistryAddress);


    function securityTokenRegistry() external view returns(address securityTokenRegistryAddress);


    function polyToken() external view returns(address polyTokenAddress);


    function tokenFactory() external view returns(address tokenFactoryAddress);


    function getterDelegate() external view returns(address delegate);


    function controllerDisabled() external view returns(bool isDisabled);


    function initialized() external view returns(bool isInitialized);


    function tokenDetails() external view returns(string memory details);


    function updateFromRegistry() external;


}

interface IPolymathRegistry {


    event ChangeAddress(string _nameKey, address indexed _oldAddress, address indexed _newAddress);
    
    function getAddress(string calldata _nameKey) external view returns(address registryAddress);


    function changeAddress(string calldata _nameKey, address _newAddress) external;


}

interface IOracle {

    function getCurrencyAddress() external view returns(address currency);


    function getCurrencySymbol() external view returns(bytes32 symbol);


    function getCurrencyDenominated() external view returns(bytes32 denominatedCurrency);


    function getPrice() external returns(uint256 price);


}

contract EternalStorage {

    mapping(bytes32 => uint256) internal uintStorage;
    mapping(bytes32 => string) internal stringStorage;
    mapping(bytes32 => address) internal addressStorage;
    mapping(bytes32 => bytes) internal bytesStorage;
    mapping(bytes32 => bool) internal boolStorage;
    mapping(bytes32 => int256) internal intStorage;
    mapping(bytes32 => bytes32) internal bytes32Storage;

    mapping(bytes32 => bytes32[]) internal bytes32ArrayStorage;
    mapping(bytes32 => uint256[]) internal uintArrayStorage;
    mapping(bytes32 => address[]) internal addressArrayStorage;
    mapping(bytes32 => string[]) internal stringArrayStorage;


    function set(bytes32 _key, uint256 _value) internal {

        uintStorage[_key] = _value;
    }

    function set(bytes32 _key, address _value) internal {

        addressStorage[_key] = _value;
    }

    function set(bytes32 _key, bool _value) internal {

        boolStorage[_key] = _value;
    }

    function set(bytes32 _key, bytes32 _value) internal {

        bytes32Storage[_key] = _value;
    }

    function set(bytes32 _key, string memory _value) internal {

        stringStorage[_key] = _value;
    }

    function set(bytes32 _key, bytes memory _value) internal {

        bytesStorage[_key] = _value;
    }


    function deleteArrayAddress(bytes32 _key, uint256 _index) internal {

        address[] storage array = addressArrayStorage[_key];
        require(_index < array.length, "Index should less than length of the array");
        array[_index] = array[array.length - 1];
        array.length = array.length - 1;
    }

    function deleteArrayBytes32(bytes32 _key, uint256 _index) internal {

        bytes32[] storage array = bytes32ArrayStorage[_key];
        require(_index < array.length, "Index should less than length of the array");
        array[_index] = array[array.length - 1];
        array.length = array.length - 1;
    }

    function deleteArrayUint(bytes32 _key, uint256 _index) internal {

        uint256[] storage array = uintArrayStorage[_key];
        require(_index < array.length, "Index should less than length of the array");
        array[_index] = array[array.length - 1];
        array.length = array.length - 1;
    }

    function deleteArrayString(bytes32 _key, uint256 _index) internal {

        string[] storage array = stringArrayStorage[_key];
        require(_index < array.length, "Index should less than length of the array");
        array[_index] = array[array.length - 1];
        array.length = array.length - 1;
    }


    function pushArray(bytes32 _key, address _value) internal {

        addressArrayStorage[_key].push(_value);
    }

    function pushArray(bytes32 _key, bytes32 _value) internal {

        bytes32ArrayStorage[_key].push(_value);
    }

    function pushArray(bytes32 _key, string memory _value) internal {

        stringArrayStorage[_key].push(_value);
    }

    function pushArray(bytes32 _key, uint256 _value) internal {

        uintArrayStorage[_key].push(_value);
    }


    function setArray(bytes32 _key, address[] memory _value) internal {

        addressArrayStorage[_key] = _value;
    }

    function setArray(bytes32 _key, uint256[] memory _value) internal {

        uintArrayStorage[_key] = _value;
    }

    function setArray(bytes32 _key, bytes32[] memory _value) internal {

        bytes32ArrayStorage[_key] = _value;
    }

    function setArray(bytes32 _key, string[] memory _value) internal {

        stringArrayStorage[_key] = _value;
    }


    function getArrayAddress(bytes32 _key) public view returns(address[] memory) {

        return addressArrayStorage[_key];
    }

    function getArrayBytes32(bytes32 _key) public view returns(bytes32[] memory) {

        return bytes32ArrayStorage[_key];
    }

    function getArrayUint(bytes32 _key) public view returns(uint[] memory) {

        return uintArrayStorage[_key];
    }


    function setArrayIndexValue(bytes32 _key, uint256 _index, address _value) internal {

        addressArrayStorage[_key][_index] = _value;
    }

    function setArrayIndexValue(bytes32 _key, uint256 _index, uint256 _value) internal {

        uintArrayStorage[_key][_index] = _value;
    }

    function setArrayIndexValue(bytes32 _key, uint256 _index, bytes32 _value) internal {

        bytes32ArrayStorage[_key][_index] = _value;
    }

    function setArrayIndexValue(bytes32 _key, uint256 _index, string memory _value) internal {

        stringArrayStorage[_key][_index] = _value;
    }


    function getUintValue(bytes32 _variable) public view returns(uint256) {

        return uintStorage[_variable];
    }

    function getBoolValue(bytes32 _variable) public view returns(bool) {

        return boolStorage[_variable];
    }

    function getStringValue(bytes32 _variable) public view returns(string memory) {

        return stringStorage[_variable];
    }

    function getAddressValue(bytes32 _variable) public view returns(address) {

        return addressStorage[_variable];
    }

    function getBytes32Value(bytes32 _variable) public view returns(bytes32) {

        return bytes32Storage[_variable];
    }

    function getBytesValue(bytes32 _variable) public view returns(bytes memory) {

        return bytesStorage[_variable];
    }

}

library Util {

    function upper(string memory _base) internal pure returns(string memory) {

        bytes memory _baseBytes = bytes(_base);
        for (uint i = 0; i < _baseBytes.length; i++) {
            bytes1 b1 = _baseBytes[i];
            if (b1 >= 0x61 && b1 <= 0x7A) {
                b1 = bytes1(uint8(b1) - 32);
            }
            _baseBytes[i] = b1;
        }
        return string(_baseBytes);
    }

    function stringToBytes32(string memory _source) internal pure returns(bytes32) {

        return bytesToBytes32(bytes(_source), 0);
    }

    function bytesToBytes32(bytes memory _b, uint _offset) internal pure returns(bytes32) {

        bytes32 result;

        for (uint i = 0; i < _b.length; i++) {
            result |= bytes32(_b[_offset + i] & 0xFF) >> (i * 8);
        }
        return result;
    }

    function bytes32ToString(bytes32 _source) internal pure returns(string memory) {

        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        uint j = 0;
        for (j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(_source) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }

    function getSig(bytes memory _data) internal pure returns(bytes4 sig) {

        uint len = _data.length < 4 ? _data.length : 4;
        for (uint256 i = 0; i < len; i++) {
          sig |= bytes4(_data[i] & 0xFF) >> (i * 8);
        }
        return sig;
    }
}

library Encoder {

    function getKey(string memory _key) internal pure returns(bytes32) {

        return bytes32(keccak256(abi.encodePacked(_key)));
    }

    function getKey(string memory _key1, address _key2) internal pure returns(bytes32) {

        return bytes32(keccak256(abi.encodePacked(_key1, _key2)));
    }

    function getKey(string memory _key1, string memory _key2) internal pure returns(bytes32) {

        return bytes32(keccak256(abi.encodePacked(_key1, _key2)));
    }

    function getKey(string memory _key1, uint256 _key2) internal pure returns(bytes32) {

        return bytes32(keccak256(abi.encodePacked(_key1, _key2)));
    }

    function getKey(string memory _key1, bytes32 _key2) internal pure returns(bytes32) {

        return bytes32(keccak256(abi.encodePacked(_key1, _key2)));
    }

    function getKey(string memory _key1, bool _key2) internal pure returns(bytes32) {

        return bytes32(keccak256(abi.encodePacked(_key1, _key2)));
    }

}


library VersionUtils {


    function lessThanOrEqual(uint8[] memory _current, uint8[] memory _new) internal pure returns(bool) {

        require(_current.length == 3);
        require(_new.length == 3);
        uint8 i = 0;
        for (i = 0; i < _current.length; i++) {
            if (_current[i] == _new[i]) continue;
            if (_current[i] < _new[i]) return true;
            if (_current[i] > _new[i]) return false;
        }
        return true;
    }

    function greaterThanOrEqual(uint8[] memory _current, uint8[] memory _new) internal pure returns(bool) {

        require(_current.length == 3);
        require(_new.length == 3);
        uint8 i = 0;
        for (i = 0; i < _current.length; i++) {
            if (_current[i] == _new[i]) continue;
            if (_current[i] > _new[i]) return true;
            if (_current[i] < _new[i]) return false;
        }
        return true;
    }

    function pack(uint8 _major, uint8 _minor, uint8 _patch) internal pure returns(uint24) {

        return (uint24(_major) << 16) | (uint24(_minor) << 8) | uint24(_patch);
    }

    function unpack(uint24 _packedVersion) internal pure returns(uint8[] memory) {

        uint8[] memory _unpackVersion = new uint8[](3);
        _unpackVersion[0] = uint8(_packedVersion >> 16);
        _unpackVersion[1] = uint8(_packedVersion >> 8);
        _unpackVersion[2] = uint8(_packedVersion);
        return _unpackVersion;
    }


    function packKYC(uint64 _a, uint64 _b, uint64 _c, uint8 _d) internal pure returns(uint256) {

        return (uint256(_a) << 136) | (uint256(_b) << 72) | (uint256(_c) << 8) | uint256(_d);
    }

    function unpackKYC(uint256 _packedVersion) internal pure returns(uint64 canSendAfter, uint64 canReceiveAfter, uint64 expiryTime, uint8 added) {

        canSendAfter = uint64(_packedVersion >> 136);
        canReceiveAfter = uint64(_packedVersion >> 72);
        expiryTime = uint64(_packedVersion >> 8);
        added = uint8(_packedVersion);
    }
}

library DecimalMath {

    using SafeMath for uint256;

    uint256 internal constant e18 = uint256(10) ** uint256(18);

    function mul(uint256 x, uint256 y) internal pure returns(uint256 z) {

        z = SafeMath.add(SafeMath.mul(x, y), (e18) / 2) / (e18);
    }

    function div(uint256 x, uint256 y) internal pure returns(uint256 z) {

        z = SafeMath.add(SafeMath.mul(x, (e18)), y / 2) / y;
    }

}

contract Proxy {

    function _implementation() internal view returns(address);


    function _fallback() internal {

        _delegate(_implementation());
    }

    function _delegate(address implementation) internal {

        assembly {
            calldatacopy(0, 0, calldatasize)
            let result := delegatecall(gas, implementation, 0, calldatasize, 0, 0)
            returndatacopy(0, 0, returndatasize)
            switch result
            case 0 { revert(0, returndatasize) }
            default { return(0, returndatasize) }
        }
    }

    function() external payable {
        _fallback();
    }
}


















contract SecurityTokenRegistry is EternalStorage, Proxy {



    using SafeMath for uint256;

    bytes32 constant INITIALIZE = 0x9ef7257c3339b099aacf96e55122ee78fb65a36bd2a6c19249882be9c98633bf; //keccak256("initialised")
    bytes32 constant POLYTOKEN = 0xacf8fbd51bb4b83ba426cdb12f63be74db97c412515797993d2a385542e311d7; //keccak256("polyToken")
    bytes32 constant STLAUNCHFEE = 0xd677304bb45536bb7fdfa6b9e47a3c58fe413f9e8f01474b0a4b9c6e0275baf2; //keccak256("stLaunchFee")
    bytes32 constant TICKERREGFEE = 0x2fcc69711628630fb5a42566c68bd1092bc4aa26826736293969fddcd11cb2d2; //keccak256("tickerRegFee")
    bytes32 constant EXPIRYLIMIT = 0x604268e9a73dfd777dcecb8a614493dd65c638bad2f5e7d709d378bd2fb0baee; //keccak256("expiryLimit")
    bytes32 constant PAUSED = 0xee35723ac350a69d2a92d3703f17439cbaadf2f093a21ba5bf5f1a53eb2a14d9; //keccak256("paused")
    bytes32 constant OWNER = 0x02016836a56b71f0d02689e69e326f4f4c1b9057164ef592671cf0d37c8040c0; //keccak256("owner")
    bytes32 constant POLYMATHREGISTRY = 0x90eeab7c36075577c7cc5ff366e389fefa8a18289b949bab3529ab4471139d4d; //keccak256("polymathRegistry")
    bytes32 constant STRGETTER = 0x982f24b3bd80807ec3cb227ba152e15c07d66855fa8ae6ca536e689205c0e2e9; //keccak256("STRGetter")
    bytes32 constant IS_FEE_IN_POLY = 0x7152e5426955da44af11ecd67fec5e2a3ba747be974678842afa9394b9a075b6; //keccak256("IS_FEE_IN_POLY")
    bytes32 constant ACTIVE_USERS = 0x425619ce6ba8e9f80f17c0ef298b6557e321d70d7aeff2e74dd157bd87177a9e; //keccak256("activeUsers")
    bytes32 constant LATEST_VERSION = 0x4c63b69b9117452b9f11af62077d0cda875fb4e2dbe07ad6f31f728de6926230; //keccak256("latestVersion")

    string constant POLY_ORACLE = "StablePolyUsdOracle";

    event Pause(address account);
    event Unpause(address account);
    event TickerRemoved(string _ticker, address _removedBy);
    event ChangeExpiryLimit(uint256 _oldExpiry, uint256 _newExpiry);
    event ChangeSecurityLaunchFee(uint256 _oldFee, uint256 _newFee);
    event ChangeTickerRegistrationFee(uint256 _oldFee, uint256 _newFee);
    event ChangeFeeCurrency(bool _isFeeInPoly);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event ChangeTickerOwnership(string _ticker, address indexed _oldOwner, address indexed _newOwner);
    event NewSecurityToken(
        string _ticker,
        string _name,
        address indexed _securityTokenAddress,
        address indexed _owner,
        uint256 _addedAt,
        address _registrant,
        bool _fromAdmin,
        uint256 _usdFee,
        uint256 _polyFee,
        uint256 _protocolVersion
    );
    event NewSecurityToken(
        string _ticker,
        string _name,
        address indexed _securityTokenAddress,
        address indexed _owner,
        uint256 _addedAt,
        address _registrant,
        bool _fromAdmin,
        uint256 _registrationFee
    );
    event RegisterTicker(
        address indexed _owner,
        string _ticker,
        uint256 indexed _registrationDate,
        uint256 indexed _expiryDate,
        bool _fromAdmin,
        uint256 _registrationFeePoly,
        uint256 _registrationFeeUsd
    );
    event RegisterTicker(
        address indexed _owner,
        string _ticker,
        string _name,
        uint256 indexed _registrationDate,
        uint256 indexed _expiryDate,
        bool _fromAdmin,
        uint256 _registrationFee
    );
    event SecurityTokenRefreshed(
        string _ticker,
        string _name,
        address indexed _securityTokenAddress,
        address indexed _owner,
        uint256 _addedAt,
        address _registrant,
        uint256 _protocolVersion
    );
    event ProtocolFactorySet(address indexed _STFactory, uint8 _major, uint8 _minor, uint8 _patch);
    event LatestVersionSet(uint8 _major, uint8 _minor, uint8 _patch);
    event ProtocolFactoryRemoved(address indexed _STFactory, uint8 _major, uint8 _minor, uint8 _patch);

    modifier onlyOwner() {

        _onlyOwner();
        _;
    }

    function _onlyOwner() internal view {

        require(msg.sender == owner(), "Only owner");
    }

    modifier onlyOwnerOrSelf() {

        require(msg.sender == owner() || msg.sender == address(this), "Only owner or self");
        _;
    }

    modifier whenNotPausedOrOwner() {

        _whenNotPausedOrOwner();
        _;
    }

    function _whenNotPausedOrOwner() internal view {

        if (msg.sender != owner()) {
            require(!isPaused(), "Paused");
        }
    }

    modifier whenNotPaused() {

        require(!isPaused(), "Paused");
        _;
    }

    modifier whenPaused() {

        require(isPaused(), "Not paused");
        _;
    }


    constructor() public {
        set(INITIALIZE, true);
    }

    function initialize(
        address _polymathRegistry,
        uint256 _stLaunchFee,
        uint256 _tickerRegFee,
        address _owner,
        address _getterContract
    )
        public
    {

        require(!getBoolValue(INITIALIZE),"Initialized");
        require(
            _owner != address(0) && _polymathRegistry != address(0) && _getterContract != address(0),
            "Invalid address"
        );
        set(STLAUNCHFEE, _stLaunchFee);
        set(TICKERREGFEE, _tickerRegFee);
        set(EXPIRYLIMIT, uint256(60 * 1 days));
        set(PAUSED, false);
        set(OWNER, _owner);
        set(POLYMATHREGISTRY, _polymathRegistry);
        set(INITIALIZE, true);
        set(STRGETTER, _getterContract);
        _updateFromRegistry();
    }

    function updateFromRegistry() external onlyOwner {

        _updateFromRegistry();
    }

    function _updateFromRegistry() internal {

        address polymathRegistry = getAddressValue(POLYMATHREGISTRY);
        set(POLYTOKEN, IPolymathRegistry(polymathRegistry).getAddress("PolyToken"));
    }

    function _takeFee(bytes32 _feeType) internal returns (uint256, uint256) {

        (uint256 usdFee, uint256 polyFee) = getFees(_feeType);
        if (polyFee > 0)
            require(IERC20(getAddressValue(POLYTOKEN)).transferFrom(msg.sender, address(this), polyFee), "Insufficent allowance");
        return (usdFee, polyFee);
    }

    function getFees(bytes32 _feeType) public returns (uint256 usdFee, uint256 polyFee) {

        bool isFeesInPoly = getBoolValue(IS_FEE_IN_POLY);
        uint256 rawFee = getUintValue(_feeType);
        address polymathRegistry = getAddressValue(POLYMATHREGISTRY);
        uint256 polyRate = IOracle(IPolymathRegistry(polymathRegistry).getAddress(POLY_ORACLE)).getPrice();
        if (!isFeesInPoly) { //Fee is in USD and not poly
            usdFee = rawFee;
            polyFee = DecimalMath.div(rawFee, polyRate);
        } else {
            usdFee = DecimalMath.mul(rawFee, polyRate);
            polyFee = rawFee;
        }
    }

    function getSecurityTokenLaunchFee() public returns(uint256 polyFee) {

        (, polyFee) = getFees(STLAUNCHFEE);
    }

    function getTickerRegistrationFee() public returns(uint256 polyFee) {

        (, polyFee) = getFees(TICKERREGFEE);
    }

    function setGetterRegistry(address _getterContract) public onlyOwnerOrSelf {

        require(_getterContract != address(0));
        set(STRGETTER, _getterContract);
    }

    function _implementation() internal view returns(address) {

        return getAddressValue(STRGETTER);
    }


    function registerNewTicker(address _owner, string memory _ticker) public whenNotPausedOrOwner {

        require(_owner != address(0), "Bad address");
        require(bytes(_ticker).length > 0 && bytes(_ticker).length <= 10, "Bad ticker");
        (uint256 usdFee, uint256 polyFee) = _takeFee(TICKERREGFEE);
        string memory ticker = Util.upper(_ticker);
        require(tickerAvailable(ticker), "Ticker reserved");
        address previousOwner = _tickerOwner(ticker);
        if (previousOwner != address(0)) {
            _deleteTickerOwnership(previousOwner, ticker);
        }
        _addTicker(_owner, ticker, now, now.add(getUintValue(EXPIRYLIMIT)), false, false, polyFee, usdFee);
    }

    function registerTicker(address _owner, string calldata _ticker, string calldata _tokenName) external {

        registerNewTicker(_owner, _ticker);
        (, uint256 polyFee) = getFees(TICKERREGFEE);
        emit RegisterTicker(_owner, _ticker, _tokenName, now, now.add(getUintValue(EXPIRYLIMIT)), false, polyFee);
    }

    function _addTicker(
        address _owner,
        string memory _ticker,
        uint256 _registrationDate,
        uint256 _expiryDate,
        bool _status,
        bool _fromAdmin,
        uint256 _polyFee,
        uint256 _usdFee
    )
        internal
    {

        _setTickerOwnership(_owner, _ticker);
        _storeTickerDetails(_ticker, _owner, _registrationDate, _expiryDate, _status);
        emit RegisterTicker(_owner, _ticker, _registrationDate, _expiryDate, _fromAdmin, _polyFee, _usdFee);
    }

    function modifyExistingTicker(
        address _owner,
        string memory _ticker,
        uint256 _registrationDate,
        uint256 _expiryDate,
        bool _status
    )
        public
        onlyOwner
    {

        require(bytes(_ticker).length > 0 && bytes(_ticker).length <= 10, "Bad ticker");
        require(_expiryDate != 0 && _registrationDate != 0, "Bad dates");
        require(_registrationDate <= _expiryDate, "Bad dates");
        require(_owner != address(0), "Bad address");
        string memory ticker = Util.upper(_ticker);
        _modifyTicker(_owner, ticker, _registrationDate, _expiryDate, _status);
    }

    function modifyTicker(
        address _owner,
        string calldata _ticker,
        string calldata _tokenName,
        uint256 _registrationDate,
        uint256 _expiryDate,
        bool _status
    )
        external
    {

        modifyExistingTicker(_owner, _ticker, _registrationDate, _expiryDate, _status);
        emit RegisterTicker(_owner, _ticker, _tokenName, now, now.add(getUintValue(EXPIRYLIMIT)), false, 0);
    }

    function _modifyTicker(
        address _owner,
        string memory _ticker,
        uint256 _registrationDate,
        uint256 _expiryDate,
        bool _status
    )
        internal
    {

        address currentOwner = _tickerOwner(_ticker);
        if (currentOwner != address(0)) {
            _deleteTickerOwnership(currentOwner, _ticker);
        }
        if (_tickerStatus(_ticker) && !_status) {
            set(Encoder.getKey("tickerToSecurityToken", _ticker), address(0));
        }
        if (_status) {
            require(getAddressValue(Encoder.getKey("tickerToSecurityToken", _ticker)) != address(0), "Not registered");
        }
        _addTicker(_owner, _ticker, _registrationDate, _expiryDate, _status, true, uint256(0), uint256(0));
    }

    function _tickerOwner(string memory _ticker) internal view returns(address) {

        return getAddressValue(Encoder.getKey("registeredTickers_owner", _ticker));
    }

    function removeTicker(string memory _ticker) public onlyOwner {

        string memory ticker = Util.upper(_ticker);
        address owner = _tickerOwner(ticker);
        require(owner != address(0), "Bad ticker");
        _deleteTickerOwnership(owner, ticker);
        set(Encoder.getKey("tickerToSecurityToken", ticker), address(0));
        _storeTickerDetails(ticker, address(0), 0, 0, false);
        emit TickerRemoved(ticker, msg.sender);
    }

    function tickerAvailable(string memory _ticker) public view returns(bool) {

        if (_tickerOwner(_ticker) != address(0)) {
            if ((now > getUintValue(Encoder.getKey("registeredTickers_expiryDate", _ticker))) && !_tickerStatus(_ticker)) {
                return true;
            } else return false;
        }
        return true;
    }

    function _tickerStatus(string memory _ticker) internal view returns(bool) {

        return getBoolValue(Encoder.getKey("registeredTickers_status", _ticker));
    }

    function _setTickerOwnership(address _owner, string memory _ticker) internal {

        bytes32 _ownerKey = Encoder.getKey("userToTickers", _owner);
        uint256 length = uint256(getArrayBytes32(_ownerKey).length);
        pushArray(_ownerKey, Util.stringToBytes32(_ticker));
        set(Encoder.getKey("tickerIndex", _ticker), length);
        bytes32 seenKey = Encoder.getKey("seenUsers", _owner);
        if (!getBoolValue(seenKey)) {
            pushArray(ACTIVE_USERS, _owner);
            set(seenKey, true);
        }
    }

    function _storeTickerDetails(
        string memory _ticker,
        address _owner,
        uint256 _registrationDate,
        uint256 _expiryDate,
        bool _status
    )
        internal
    {

        bytes32 key = Encoder.getKey("registeredTickers_owner", _ticker);
        set(key, _owner);
        key = Encoder.getKey("registeredTickers_registrationDate", _ticker);
        set(key, _registrationDate);
        key = Encoder.getKey("registeredTickers_expiryDate", _ticker);
        set(key, _expiryDate);
        key = Encoder.getKey("registeredTickers_status", _ticker);
        set(key, _status);
    }

    function transferTickerOwnership(address _newOwner, string memory _ticker) public whenNotPausedOrOwner {

        string memory ticker = Util.upper(_ticker);
        require(_newOwner != address(0), "Bad address");
        bytes32 ownerKey = Encoder.getKey("registeredTickers_owner", ticker);
        require(getAddressValue(ownerKey) == msg.sender, "Only owner");
        if (_tickerStatus(ticker)) require(
            IOwnable(getAddressValue(Encoder.getKey("tickerToSecurityToken", ticker))).owner() == _newOwner,
            "Owner mismatch"
        );
        _deleteTickerOwnership(msg.sender, ticker);
        _setTickerOwnership(_newOwner, ticker);
        set(ownerKey, _newOwner);
        emit ChangeTickerOwnership(ticker, msg.sender, _newOwner);
    }

    function _deleteTickerOwnership(address _owner, string memory _ticker) internal {

        uint256 index = uint256(getUintValue(Encoder.getKey("tickerIndex", _ticker)));
        bytes32 ownerKey = Encoder.getKey("userToTickers", _owner);
        bytes32[] memory tickers = getArrayBytes32(ownerKey);
        assert(index < tickers.length);
        assert(_tickerOwner(_ticker) == _owner);
        deleteArrayBytes32(ownerKey, index);
        if (getArrayBytes32(ownerKey).length > index) {
            bytes32 switchedTicker = getArrayBytes32(ownerKey)[index];
            set(Encoder.getKey("tickerIndex", Util.bytes32ToString(switchedTicker)), index);
        }
    }

    function changeExpiryLimit(uint256 _newExpiry) public onlyOwner {

        require(_newExpiry >= 1 days, "Bad dates");
        emit ChangeExpiryLimit(getUintValue(EXPIRYLIMIT), _newExpiry);
        set(EXPIRYLIMIT, _newExpiry);
    }


    function generateSecurityToken(
        string calldata _name,
        string calldata _ticker,
        string calldata _tokenDetails,
        bool _divisible
    )
        external
    {

        generateNewSecurityToken(_name, _ticker, _tokenDetails, _divisible, msg.sender, VersionUtils.pack(2, 0, 0));
    }

    function generateNewSecurityToken(
        string memory _name,
        string memory _ticker,
        string memory _tokenDetails,
        bool _divisible,
        address _treasuryWallet,
        uint256 _protocolVersion
    )
        public
        whenNotPausedOrOwner
    {

        require(bytes(_name).length > 0 && bytes(_ticker).length > 0, "Bad ticker");
        require(_treasuryWallet != address(0), "0x0 not allowed");
        if (_protocolVersion == 0) {
            _protocolVersion = getUintValue(LATEST_VERSION);
        }
        _ticker = Util.upper(_ticker);
        bytes32 statusKey = Encoder.getKey("registeredTickers_status", _ticker);
        require(!getBoolValue(statusKey), "Already deployed");
        set(statusKey, true);
        address issuer = msg.sender;
        require(_tickerOwner(_ticker) == issuer, "Not authorised");
        require(getUintValue(Encoder.getKey("registeredTickers_expiryDate", _ticker)) >= now, "Ticker expired");
        (uint256 _usdFee, uint256 _polyFee) = _takeFee(STLAUNCHFEE);
        address newSecurityTokenAddress =
            _deployToken(_name, _ticker, _tokenDetails, issuer, _divisible, _treasuryWallet, _protocolVersion);
        if (_protocolVersion == VersionUtils.pack(2, 0, 0)) {
            emit NewSecurityToken(
                _ticker, _name, newSecurityTokenAddress, issuer, now, issuer, false, _polyFee
            );
        } else {
            emit NewSecurityToken(
                _ticker, _name, newSecurityTokenAddress, issuer, now, issuer, false, _usdFee, _polyFee, _protocolVersion
            );
        }
    }

    function refreshSecurityToken(
        string memory _name,
        string memory _ticker,
        string memory _tokenDetails,
        bool _divisible,
        address _treasuryWallet
    )
        public whenNotPausedOrOwner returns (address)
    {

        require(bytes(_name).length > 0 && bytes(_ticker).length > 0, "Bad ticker");
        require(_treasuryWallet != address(0), "0x0 not allowed");
        string memory ticker = Util.upper(_ticker);
        require(_tickerStatus(ticker), "not deployed");
        address st = getAddressValue(Encoder.getKey("tickerToSecurityToken", ticker));
        address stOwner = IOwnable(st).owner();
        require(msg.sender == stOwner, "Unauthroized");
        require(ISecurityToken(st).transfersFrozen(), "Transfers not frozen");
        uint256 protocolVersion = getUintValue(LATEST_VERSION);
        address newSecurityTokenAddress =
            _deployToken(_name, ticker, _tokenDetails, stOwner, _divisible, _treasuryWallet, protocolVersion);
        emit SecurityTokenRefreshed(
            _ticker, _name, newSecurityTokenAddress, stOwner, now, stOwner, protocolVersion
        );
    }

    function _deployToken(
        string memory _name,
        string memory _ticker,
        string memory _tokenDetails,
        address _issuer,
        bool _divisible,
        address _wallet,
        uint256 _protocolVersion
    )
        internal
        returns(address newSecurityTokenAddress)
    {

        uint8[] memory upperLimit = new uint8[](3);
        upperLimit[0] = 2;
        upperLimit[1] = 99;
        upperLimit[2] = 99;
        if (VersionUtils.lessThanOrEqual(VersionUtils.unpack(uint24(_protocolVersion)), upperLimit)) {
            _wallet = getAddressValue(POLYMATHREGISTRY);
        }

        newSecurityTokenAddress = ISTFactory(getAddressValue(Encoder.getKey("protocolVersionST", _protocolVersion))).deployToken(
            _name,
            _ticker,
            18,
            _tokenDetails,
            _issuer,
            _divisible,
            _wallet
        );

        _storeSecurityTokenData(newSecurityTokenAddress, _ticker, _tokenDetails, now);
        set(Encoder.getKey("tickerToSecurityToken", _ticker), newSecurityTokenAddress);
    }

    function modifyExistingSecurityToken(
        string memory _ticker,
        address _owner,
        address _securityToken,
        string memory _tokenDetails,
        uint256 _deployedAt
    )
        public
        onlyOwner
    {

        require(bytes(_ticker).length <= 10, "Bad ticker");
        require(_deployedAt != 0 && _owner != address(0), "Bad data");
        string memory ticker = Util.upper(_ticker);
        require(_securityToken != address(0), "Bad address");
        uint256 registrationTime = getUintValue(Encoder.getKey("registeredTickers_registrationDate", ticker));
        uint256 expiryTime = getUintValue(Encoder.getKey("registeredTickers_expiryDate", ticker));
        if (registrationTime == 0) {
            registrationTime = now;
            expiryTime = registrationTime.add(getUintValue(EXPIRYLIMIT));
        }
        set(Encoder.getKey("tickerToSecurityToken", ticker), _securityToken);
        _modifyTicker(_owner, ticker, registrationTime, expiryTime, true);
        _storeSecurityTokenData(_securityToken, ticker, _tokenDetails, _deployedAt);
        emit NewSecurityToken(
            ticker, ISecurityToken(_securityToken).name(), _securityToken, _owner, _deployedAt, msg.sender, true, uint256(0), uint256(0), 0
        );
    }

    function modifySecurityToken(
        string calldata /* */,
        string calldata _ticker,
        address _owner,
        address _securityToken,
        string calldata _tokenDetails,
        uint256 _deployedAt
    )
        external
    {

        modifyExistingSecurityToken(_ticker, _owner, _securityToken, _tokenDetails, _deployedAt);
    }

    function _storeSecurityTokenData(
        address _securityToken,
        string memory _ticker,
        string memory _tokenDetails,
        uint256 _deployedAt
    ) internal {

        set(Encoder.getKey("securityTokens_ticker", _securityToken), _ticker);
        set(Encoder.getKey("securityTokens_tokenDetails", _securityToken), _tokenDetails);
        set(Encoder.getKey("securityTokens_deployedAt", _securityToken), _deployedAt);
    }

    function isSecurityToken(address _securityToken) external view returns(bool) {

        return (keccak256(bytes(getStringValue(Encoder.getKey("securityTokens_ticker", _securityToken)))) != keccak256(""));
    }


    function transferOwnership(address _newOwner) public onlyOwner {

        require(_newOwner != address(0), "Bad address");
        emit OwnershipTransferred(getAddressValue(OWNER), _newOwner);
        set(OWNER, _newOwner);
    }

    function pause() external whenNotPaused onlyOwner {

        set(PAUSED, true);
        emit Pause(msg.sender);
    }

    function unpause() external whenPaused onlyOwner {

        set(PAUSED, false);
        emit Unpause(msg.sender);
    }

    function changeTickerRegistrationFee(uint256 _tickerRegFee) public onlyOwner {

        uint256 fee = getUintValue(TICKERREGFEE);
        require(fee != _tickerRegFee, "Bad fee");
        _changeTickerRegistrationFee(fee, _tickerRegFee);
    }

    function _changeTickerRegistrationFee(uint256 _oldFee, uint256 _newFee) internal {

        emit ChangeTickerRegistrationFee(_oldFee, _newFee);
        set(TICKERREGFEE, _newFee);
    }

    function changeSecurityLaunchFee(uint256 _stLaunchFee) public onlyOwner {

        uint256 fee = getUintValue(STLAUNCHFEE);
        require(fee != _stLaunchFee, "Bad fee");
        _changeSecurityLaunchFee(fee, _stLaunchFee);
    }

    function _changeSecurityLaunchFee(uint256 _oldFee, uint256 _newFee) internal {

        emit ChangeSecurityLaunchFee(_oldFee, _newFee);
        set(STLAUNCHFEE, _newFee);
    }

    function changeFeesAmountAndCurrency(uint256 _tickerRegFee, uint256 _stLaunchFee, bool _isFeeInPoly) public onlyOwner {

        uint256 tickerFee = getUintValue(TICKERREGFEE);
        uint256 stFee = getUintValue(STLAUNCHFEE);
        bool isOldFeesInPoly = getBoolValue(IS_FEE_IN_POLY);
        require(isOldFeesInPoly != _isFeeInPoly, "Currency unchanged");
        _changeTickerRegistrationFee(tickerFee, _tickerRegFee);
        _changeSecurityLaunchFee(stFee, _stLaunchFee);
        emit ChangeFeeCurrency(_isFeeInPoly);
        set(IS_FEE_IN_POLY, _isFeeInPoly);
    }

    function reclaimERC20(address _tokenContract) public onlyOwner {

        require(_tokenContract != address(0), "Bad address");
        IERC20 token = IERC20(_tokenContract);
        uint256 balance = token.balanceOf(address(this));
        require(token.transfer(owner(), balance), "Transfer failed");
    }

    function setProtocolFactory(address _STFactoryAddress, uint8 _major, uint8 _minor, uint8 _patch) public onlyOwner {

        _setProtocolFactory(_STFactoryAddress, _major, _minor, _patch);
    }

    function _setProtocolFactory(address _STFactoryAddress, uint8 _major, uint8 _minor, uint8 _patch) internal {

        require(_STFactoryAddress != address(0), "Bad address");
        uint24 _packedVersion = VersionUtils.pack(_major, _minor, _patch);
        address stFactoryAddress = getAddressValue(Encoder.getKey("protocolVersionST", uint256(_packedVersion)));
        require(stFactoryAddress == address(0), "Already exists");
        set(Encoder.getKey("protocolVersionST", uint256(_packedVersion)), _STFactoryAddress);
        emit ProtocolFactorySet(_STFactoryAddress, _major, _minor, _patch);
    }

    function removeProtocolFactory(uint8 _major, uint8 _minor, uint8 _patch) public onlyOwner {

        uint24 _packedVersion = VersionUtils.pack(_major, _minor, _patch);
        require(getUintValue(LATEST_VERSION) != _packedVersion, "Cannot remove latestVersion");
        emit ProtocolFactoryRemoved(getAddressValue(Encoder.getKey("protocolVersionST", _packedVersion)), _major, _minor, _patch);
        set(Encoder.getKey("protocolVersionST", uint256(_packedVersion)), address(0));
    }

    function setLatestVersion(uint8 _major, uint8 _minor, uint8 _patch) public onlyOwner {

        _setLatestVersion(_major, _minor, _patch);
    }

    function _setLatestVersion(uint8 _major, uint8 _minor, uint8 _patch) internal {

        uint24 _packedVersion = VersionUtils.pack(_major, _minor, _patch);
        require(getAddressValue(Encoder.getKey("protocolVersionST", _packedVersion)) != address(0), "No factory");
        set(LATEST_VERSION, uint256(_packedVersion));
        emit LatestVersionSet(_major, _minor, _patch);
    }

    function updatePolyTokenAddress(address _newAddress) public onlyOwner {

        require(_newAddress != address(0), "Bad address");
        set(POLYTOKEN, _newAddress);
    }

    function isPaused() public view returns(bool) {

        return getBoolValue(PAUSED);
    }

    function owner() public view returns(address) {

        return getAddressValue(OWNER);
    }
}