
pragma solidity 0.5.8;

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

interface IModuleRegistry {



    event Pause(address account);
    event Unpause(address account);
    event ModuleUsed(address indexed _moduleFactory, address indexed _securityToken);
    event ModuleRegistered(address indexed _moduleFactory, address indexed _owner);
    event ModuleVerified(address indexed _moduleFactory);
    event ModuleUnverified(address indexed _moduleFactory);
    event ModuleRemoved(address indexed _moduleFactory, address indexed _decisionMaker);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    function useModule(address _moduleFactory) external;


    function useModule(address _moduleFactory, bool _isUpgrade) external;


    function registerModule(address _moduleFactory) external;


    function removeModule(address _moduleFactory) external;


    function isCompatibleModule(address _moduleFactory, address _securityToken) external view returns(bool isCompatible);


    function verifyModule(address _moduleFactory) external;


    function unverifyModule(address _moduleFactory) external;


    function getFactoryDetails(address _factoryAddress) external view returns(bool isVerified, address factoryOwner, address[] memory usingTokens);


    function getTagsByTypeAndToken(uint8 _moduleType, address _securityToken) external view returns(bytes32[] memory tags, address[] memory factories);


    function getTagsByType(uint8 _moduleType) external view returns(bytes32[] memory tags, address[] memory factories);


    function getAllModulesByType(uint8 _moduleType) external view returns(address[] memory factories);

    function getModulesByType(uint8 _moduleType) external view returns(address[] memory factories);


    function getModulesByTypeAndToken(uint8 _moduleType, address _securityToken) external view returns(address[] memory factories);


    function updateFromRegistry() external;


    function owner() external view returns(address ownerAddress);


    function isPaused() external view returns(bool paused);


    function reclaimERC20(address _tokenContract) external;


    function pause() external;


    function unpause() external;


    function transferOwnership(address _newOwner) external;


}

interface IModuleFactory {

    event ChangeSetupCost(uint256 _oldSetupCost, uint256 _newSetupCost);
    event ChangeCostType(bool _isOldCostInPoly, bool _isNewCostInPoly);
    event GenerateModuleFromFactory(
        address _module,
        bytes32 indexed _moduleName,
        address indexed _moduleFactory,
        address _creator,
        uint256 _setupCost,
        uint256 _setupCostInPoly
    );
    event ChangeSTVersionBound(string _boundType, uint8 _major, uint8 _minor, uint8 _patch);

    function deploy(bytes calldata _data) external returns(address moduleAddress);


    function version() external view returns(string memory moduleVersion);


    function name() external view returns(bytes32 moduleName);


    function title() external view returns(string memory moduleTitle);


    function description() external view returns(string memory moduleDescription);


    function setupCost() external returns(uint256 usdSetupCost);


    function getTypes() external view returns(uint8[] memory moduleTypes);


    function getTags() external view returns(bytes32[] memory moduleTags);


    function changeSetupCost(uint256 _newSetupCost) external;


    function changeCostAndType(uint256 _setupCost, bool _isCostInPoly) external;


    function changeSTVersionBounds(string calldata _boundType, uint8[] calldata _newVersion) external;


    function setupCostInPoly() external returns (uint256 polySetupCost);


    function getLowerSTVersionBounds() external view returns(uint8[] memory lowerBounds);


    function getUpperSTVersionBounds() external view returns(uint8[] memory upperBounds);


    function changeTags(bytes32[] calldata _tagsData) external;


    function changeName(bytes32 _name) external;


    function changeDescription(string calldata _description) external;


    function changeTitle(string calldata _title) external;


}

interface ISecurityTokenRegistry {


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

    function generateSecurityToken(
        string calldata _name,
        string calldata _ticker,
        string calldata _tokenDetails,
        bool _divisible
    )
        external;


    function generateNewSecurityToken(
        string calldata _name,
        string calldata _ticker,
        string calldata _tokenDetails,
        bool _divisible,
        address _treasuryWallet,
        uint256 _protocolVersion
    )
        external;


    function refreshSecurityToken(
        string calldata _name,
        string calldata _ticker,
        string calldata _tokenDetails,
        bool _divisible,
        address _treasuryWallet
    )
        external returns (address securityToken);


    function modifySecurityToken(
        string calldata _name,
        string calldata _ticker,
        address _owner,
        address _securityToken,
        string calldata _tokenDetails,
        uint256 _deployedAt
    )
    external;


    function modifyExistingSecurityToken(
        string calldata _ticker,
        address _owner,
        address _securityToken,
        string calldata _tokenDetails,
        uint256 _deployedAt
    )
        external;


    function modifyExistingTicker(
        address _owner,
        string calldata _ticker,
        uint256 _registrationDate,
        uint256 _expiryDate,
        bool _status
    )
        external;


    function registerTicker(address _owner, string calldata _ticker, string calldata _tokenName) external;


    function registerNewTicker(address _owner, string calldata _ticker) external;


    function isSecurityToken(address _securityToken) external view returns(bool isValid);


    function transferOwnership(address _newOwner) external;


    function getSecurityTokenAddress(string calldata _ticker) external view returns(address tokenAddress);


    function getSecurityTokenData(address _securityToken) external view returns (
        string memory tokenSymbol,
        address tokenAddress,
        string memory tokenDetails,
        uint256 tokenTime
    );


    function getSTFactoryAddress() external view returns(address stFactoryAddress);


    function getSTFactoryAddressOfVersion(uint256 _protocolVersion) external view returns(address stFactory);


    function getLatestProtocolVersion() external view returns(uint8[] memory protocolVersion);


    function getTickersByOwner(address _owner) external view returns(bytes32[] memory tickers);


    function getTokensByOwner(address _owner) external view returns(address[] memory tokens);


    function getTokens() external view returns(address[] memory tokens);


    function getTickerDetails(string calldata _ticker) external view returns(address tickerOwner, uint256 tickerRegistration, uint256 tickerExpiry, string memory tokenName, bool tickerStatus);


    function modifyTicker(
        address _owner,
        string calldata _ticker,
        string calldata _tokenName,
        uint256 _registrationDate,
        uint256 _expiryDate,
        bool _status
    )
    external;


    function removeTicker(string calldata _ticker) external;


    function transferTickerOwnership(address _newOwner, string calldata _ticker) external;


    function changeExpiryLimit(uint256 _newExpiry) external;


    function changeTickerRegistrationFee(uint256 _tickerRegFee) external;


    function changeSecurityLaunchFee(uint256 _stLaunchFee) external;


    function changeFeesAmountAndCurrency(uint256 _tickerRegFee, uint256 _stLaunchFee, bool _isFeeInPoly) external;


    function setProtocolFactory(address _STFactoryAddress, uint8 _major, uint8 _minor, uint8 _patch) external;


    function removeProtocolFactory(uint8 _major, uint8 _minor, uint8 _patch) external;


    function setLatestVersion(uint8 _major, uint8 _minor, uint8 _patch) external;


    function updatePolyTokenAddress(address _newAddress) external;


    function updateFromRegistry() external;


    function getSecurityTokenLaunchFee() external returns(uint256 fee);


    function getTickerRegistrationFee() external returns(uint256 fee);


    function setGetterRegistry(address _getterContract) external;


    function getFees(bytes32 _feeType) external returns (uint256 usdFee, uint256 polyFee);


    function getTokensByDelegate(address _delegate) external view returns(address[] memory tokens);


    function getExpiryLimit() external view returns(uint256 expiry);


    function getTickerStatus(string calldata _ticker) external view returns(bool status);


    function getIsFeeInPoly() external view returns(bool isInPoly);


    function getTickerOwner(string calldata _ticker) external view returns(address owner);


    function isPaused() external view returns(bool paused);


    function pause() external;


    function unpause() external;


    function reclaimERC20(address _tokenContract) external;


    function owner() external view returns(address ownerAddress);


    function tickerAvailable(string calldata _ticker) external view returns(bool);


}

interface IPolymathRegistry {


    event ChangeAddress(string _nameKey, address indexed _oldAddress, address indexed _newAddress);
    
    function getAddress(string calldata _nameKey) external view returns(address registryAddress);


    function changeAddress(string calldata _nameKey, address _newAddress) external;


}

interface IFeatureRegistry {


    event ChangeFeatureStatus(string _nameKey, bool _newStatus);

    function setFeatureStatus(string calldata _nameKey, bool _newStatus) external;


    function getFeatureStatus(string calldata _nameKey) external view returns(bool hasFeature);


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

interface IOwnable {

    function owner() external view returns(address ownerAddress);


    function renounceOwnership() external;


    function transferOwnership(address _newOwner) external;


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

contract ModuleRegistry is IModuleRegistry, EternalStorage {


    bytes32 constant INITIALIZE = 0x9ef7257c3339b099aacf96e55122ee78fb65a36bd2a6c19249882be9c98633bf; //keccak256("initialised")
    bytes32 constant LOCKED = 0xab99c6d7581cbb37d2e578d3097bfdd3323e05447f1fd7670b6c3a3fb9d9ff79; //keccak256("locked")
    bytes32 constant POLYTOKEN = 0xacf8fbd51bb4b83ba426cdb12f63be74db97c412515797993d2a385542e311d7; //keccak256("polyToken")
    bytes32 constant PAUSED = 0xee35723ac350a69d2a92d3703f17439cbaadf2f093a21ba5bf5f1a53eb2a14d9; //keccak256("paused")
    bytes32 constant OWNER = 0x02016836a56b71f0d02689e69e326f4f4c1b9057164ef592671cf0d37c8040c0; //keccak256("owner")
    bytes32 constant POLYMATHREGISTRY = 0x90eeab7c36075577c7cc5ff366e389fefa8a18289b949bab3529ab4471139d4d; //keccak256("polymathRegistry")
    bytes32 constant FEATURE_REGISTRY = 0xed9ca06607835ad25ecacbcb97f2bc414d4a51ecf391b5ae42f15991227ab146; //keccak256("featureRegistry")
    bytes32 constant SECURITY_TOKEN_REGISTRY = 0x12ada4f7ee6c2b7b933330be61fefa007a1f497dc8df1b349b48071a958d7a81; //keccak256("securityTokenRegistry")


    modifier onlyOwner() {

        require(msg.sender == owner(), "sender must be owner");
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

    modifier nonReentrant() {

        set(LOCKED, getUintValue(LOCKED) + 1);
        uint256 localCounter = getUintValue(LOCKED);
        _;
        require(localCounter == getUintValue(LOCKED));
    }

    modifier whenNotPaused() {

        require(!isPaused(), "Already paused");
        _;
    }

    modifier whenPaused() {

        require(isPaused(), "Should not be paused");
        _;
    }


    constructor() public {

    }

    function initialize(address _polymathRegistry, address _owner) external payable {

        require(!getBoolValue(INITIALIZE), "already initialized");
        require(_owner != address(0) && _polymathRegistry != address(0), "0x address is invalid");
        set(POLYMATHREGISTRY, _polymathRegistry);
        set(OWNER, _owner);
        set(PAUSED, false);
        set(INITIALIZE, true);
    }

    function _customModules() internal view returns (bool) {

        return IFeatureRegistry(getAddressValue(FEATURE_REGISTRY)).getFeatureStatus("customModulesAllowed");
    }


    function useModule(address _moduleFactory) external {

        useModule(_moduleFactory, false);
    }

    function useModule(address _moduleFactory, bool _isUpgrade) public nonReentrant {

        if (_customModules()) {
            require(
                getBoolValue(Encoder.getKey("verified", _moduleFactory)) || getAddressValue(Encoder.getKey("factoryOwner", _moduleFactory))
                    == IOwnable(msg.sender).owner(),
                "ModuleFactory must be verified or SecurityToken owner must be ModuleFactory owner"
            );
        } else {
            require(getBoolValue(Encoder.getKey("verified", _moduleFactory)), "ModuleFactory must be verified");
        }
        if (ISecurityTokenRegistry(getAddressValue(SECURITY_TOKEN_REGISTRY)).isSecurityToken(msg.sender)) {
            require(isCompatibleModule(_moduleFactory, msg.sender), "Incompatible versions");
            if (!_isUpgrade) {
                pushArray(Encoder.getKey("reputation", _moduleFactory), msg.sender);
                emit ModuleUsed(_moduleFactory, msg.sender);
            }
        }
    }

    function isCompatibleModule(address _moduleFactory, address _securityToken) public view returns(bool) {

        uint8[] memory _latestVersion = ISecurityToken(_securityToken).getVersion();
        uint8[] memory _lowerBound = IModuleFactory(_moduleFactory).getLowerSTVersionBounds();
        uint8[] memory _upperBound = IModuleFactory(_moduleFactory).getUpperSTVersionBounds();
        bool _isLowerAllowed = VersionUtils.lessThanOrEqual(_lowerBound, _latestVersion);
        bool _isUpperAllowed = VersionUtils.greaterThanOrEqual(_upperBound, _latestVersion);
        return (_isLowerAllowed && _isUpperAllowed);
    }

    function registerModule(address _moduleFactory) external whenNotPausedOrOwner nonReentrant {

        address factoryOwner = IOwnable(_moduleFactory).owner();
        set(Encoder.getKey("factoryOwner", _moduleFactory), factoryOwner);
        if (_customModules()) {
            require(
                msg.sender == factoryOwner || msg.sender == owner(),
                "msg.sender must be the Module Factory owner or registry curator"
            );
        } else {
            require(msg.sender == owner(), "Only owner allowed to register modules");
        }
        require(getUintValue(Encoder.getKey("registry", _moduleFactory)) == 0, "Module factory should not be pre-registered");
        IModuleFactory moduleFactory = IModuleFactory(_moduleFactory);
        uint256 i;
        uint256 j;
        uint8[] memory moduleTypes = moduleFactory.getTypes();
        for (i = 1; i < moduleTypes.length; i++) {
            for (j = 0; j < i; j++) {
                require(moduleTypes[i] != moduleTypes[j], "Type mismatch");
            }
        }
        require(moduleTypes.length != 0, "Factory must have type");
        uint8 moduleType = moduleTypes[0];
        require(uint256(moduleType) != 0, "Invalid type");
        set(Encoder.getKey("registry", _moduleFactory), uint256(moduleType));
        set(
            Encoder.getKey("moduleListIndex", _moduleFactory),
            uint256(getArrayAddress(Encoder.getKey("moduleList", uint256(moduleType))).length)
        );
        pushArray(Encoder.getKey("moduleList", uint256(moduleType)), _moduleFactory);
        emit ModuleRegistered(_moduleFactory, factoryOwner);
    }

    function removeModule(address _moduleFactory) external whenNotPausedOrOwner {

        uint256 moduleType = getUintValue(Encoder.getKey("registry", _moduleFactory));

        require(moduleType != 0, "Module factory should be registered");
        require(
            msg.sender == owner() || msg.sender == getAddressValue(Encoder.getKey("factoryOwner", _moduleFactory)),
            "msg.sender must be the Module Factory owner or registry curator"
        );
        uint256 index = getUintValue(Encoder.getKey("moduleListIndex", _moduleFactory));
        uint256 last = getArrayAddress(Encoder.getKey("moduleList", moduleType)).length - 1;
        address temp = getArrayAddress(Encoder.getKey("moduleList", moduleType))[last];

        if (index != last) {
            setArrayIndexValue(Encoder.getKey("moduleList", moduleType), index, temp);
            set(Encoder.getKey("moduleListIndex", temp), index);
        }
        deleteArrayAddress(Encoder.getKey("moduleList", moduleType), last);

        set(Encoder.getKey("registry", _moduleFactory), uint256(0));
        setArray(Encoder.getKey("reputation", _moduleFactory), new address[](0));
        set(Encoder.getKey("verified", _moduleFactory), false);
        set(Encoder.getKey("moduleListIndex", _moduleFactory), uint256(0));
        set(Encoder.getKey("factoryOwner", _moduleFactory), address(0));
        emit ModuleRemoved(_moduleFactory, msg.sender);
    }

    function verifyModule(address _moduleFactory) external onlyOwner {

        require(getUintValue(Encoder.getKey("registry", _moduleFactory)) != uint256(0), "Module factory must be registered");
        set(Encoder.getKey("verified", _moduleFactory), true);
        emit ModuleVerified(_moduleFactory);
    }

    function unverifyModule(address _moduleFactory) external nonReentrant {

        bool isOwner = msg.sender == owner();
        bool isFactory = msg.sender == _moduleFactory;
        bool isFactoryOwner = msg.sender == getAddressValue(Encoder.getKey("factoryOwner", _moduleFactory));
        require(isOwner || isFactory || isFactoryOwner, "Not authorised");
        require(getUintValue(Encoder.getKey("registry", _moduleFactory)) != uint256(0), "Module factory must be registered");
        set(Encoder.getKey("verified", _moduleFactory), false);
        emit ModuleUnverified(_moduleFactory);
    }

    function getTagsByTypeAndToken(uint8 _moduleType, address _securityToken) external view returns(bytes32[] memory, address[] memory) {

        address[] memory modules = getModulesByTypeAndToken(_moduleType, _securityToken);
        return _tagsByModules(modules);
    }

    function getTagsByType(uint8 _moduleType) external view returns(bytes32[] memory, address[] memory) {

        address[] memory modules = getModulesByType(_moduleType);
        return _tagsByModules(modules);
    }

    function _tagsByModules(address[] memory _modules) internal view returns(bytes32[] memory, address[] memory) {

        uint256 counter = 0;
        uint256 i;
        uint256 j;
        for (i = 0; i < _modules.length; i++) {
            counter = counter + IModuleFactory(_modules[i]).getTags().length;
        }
        bytes32[] memory tags = new bytes32[](counter);
        address[] memory modules = new address[](counter);
        bytes32[] memory tempTags;
        counter = 0;
        for (i = 0; i < _modules.length; i++) {
            tempTags = IModuleFactory(_modules[i]).getTags();
            for (j = 0; j < tempTags.length; j++) {
                tags[counter] = tempTags[j];
                modules[counter] = _modules[i];
                counter++;
            }
        }
        return (tags, modules);
    }

    function getFactoryDetails(address _factoryAddress) external view returns(bool, address, address[] memory) {

        return (getBoolValue(Encoder.getKey("verified", _factoryAddress)), getAddressValue(Encoder.getKey("factoryOwner", _factoryAddress)), getArrayAddress(Encoder.getKey("reputation", _factoryAddress)));
    }

    function getModulesByType(uint8 _moduleType) public view returns(address[] memory) {

        address[] memory _addressList = getArrayAddress(Encoder.getKey("moduleList", uint256(_moduleType)));
        uint256 _len = _addressList.length;
        uint256 counter = 0;
        for (uint256 i = 0; i < _len; i++) {
            if (getBoolValue(Encoder.getKey("verified", _addressList[i]))) {
                counter++;
            }
        }
        address[] memory _tempArray = new address[](counter);
        counter = 0;
        for (uint256 j = 0; j < _len; j++) {
            if (getBoolValue(Encoder.getKey("verified", _addressList[j]))) {
                _tempArray[counter] = _addressList[j];
                counter++;
            }
        }
        return _tempArray;
    }


    function getAllModulesByType(uint8 _moduleType) external view returns(address[] memory) {

        return getArrayAddress(Encoder.getKey("moduleList", uint256(_moduleType)));
    }

    function getModulesByTypeAndToken(uint8 _moduleType, address _securityToken) public view returns(address[] memory) {

        address[] memory _addressList = getArrayAddress(Encoder.getKey("moduleList", uint256(_moduleType)));
        uint256 _len = _addressList.length;
        bool _isCustomModuleAllowed = _customModules();
        uint256 counter = 0;
        for (uint256 i = 0; i < _len; i++) {
            if (_isCustomModuleAllowed) {
                if (getBoolValue(
                    Encoder.getKey("verified", _addressList[i])) || getAddressValue(Encoder.getKey("factoryOwner", _addressList[i])) == IOwnable(_securityToken).owner()
                ) if (isCompatibleModule(_addressList[i], _securityToken)) counter++;
            } else if (getBoolValue(Encoder.getKey("verified", _addressList[i]))) {
                if (isCompatibleModule(_addressList[i], _securityToken)) counter++;
            }
        }
        address[] memory _tempArray = new address[](counter);
        counter = 0;
        for (uint256 j = 0; j < _len; j++) {
            if (_isCustomModuleAllowed) {
                if (getAddressValue(Encoder.getKey("factoryOwner", _addressList[j])) == IOwnable(_securityToken).owner() || getBoolValue(
                    Encoder.getKey("verified", _addressList[j])
                )) {
                    if (isCompatibleModule(_addressList[j], _securityToken)) {
                        _tempArray[counter] = _addressList[j];
                        counter++;
                    }
                }
            } else if (getBoolValue(Encoder.getKey("verified", _addressList[j]))) {
                if (isCompatibleModule(_addressList[j], _securityToken)) {
                    _tempArray[counter] = _addressList[j];
                    counter++;
                }
            }
        }
        return _tempArray;
    }

    function reclaimERC20(address _tokenContract) external onlyOwner {

        require(_tokenContract != address(0), "0x address is invalid");
        IERC20 token = IERC20(_tokenContract);
        uint256 balance = token.balanceOf(address(this));
        require(token.transfer(owner(), balance), "token transfer failed");
    }

    function pause() external whenNotPaused onlyOwner {

        set(PAUSED, true);
        emit Pause(msg.sender);
    }

    function unpause() external whenPaused onlyOwner {

        set(PAUSED, false);
        emit Unpause(msg.sender);
    }

    function updateFromRegistry() external onlyOwner {

        address _polymathRegistry = getAddressValue(POLYMATHREGISTRY);
        set(SECURITY_TOKEN_REGISTRY, IPolymathRegistry(_polymathRegistry).getAddress("SecurityTokenRegistry"));
        set(FEATURE_REGISTRY, IPolymathRegistry(_polymathRegistry).getAddress("FeatureRegistry"));
        set(POLYTOKEN, IPolymathRegistry(_polymathRegistry).getAddress("PolyToken"));
    }

    function transferOwnership(address _newOwner) external onlyOwner {

        require(_newOwner != address(0), "Invalid address");
        emit OwnershipTransferred(owner(), _newOwner);
        set(OWNER, _newOwner);
    }

    function owner() public view returns(address) {

        return getAddressValue(OWNER);
    }

    function isPaused() public view returns(bool) {

        return getBoolValue(PAUSED);
    }
}