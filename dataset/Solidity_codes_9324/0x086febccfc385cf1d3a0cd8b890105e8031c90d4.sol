
pragma solidity 0.5.8;

interface IModule {

    function getInitFunction() external pure returns(bytes4 initFunction);


    function getPermissions() external view returns(bytes32[] memory permissions);


}

contract Pausable {

    event Pause(address account);
    event Unpause(address account);

    bool public paused = false;

    modifier whenNotPaused() {

        require(!paused, "Contract is paused");
        _;
    }

    modifier whenPaused() {

        require(paused, "Contract is not paused");
        _;
    }

    function _pause() internal whenNotPaused {

        paused = true;
        emit Pause(msg.sender);
    }

    function _unpause() internal whenPaused {

        paused = false;
        emit Unpause(msg.sender);
    }

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

interface IDataStore {

    function setSecurityToken(address _securityToken) external;


    function setUint256(bytes32 _key, uint256 _data) external;


    function setBytes32(bytes32 _key, bytes32 _data) external;


    function setAddress(bytes32 _key, address _data) external;


    function setString(bytes32 _key, string calldata _data) external;


    function setBytes(bytes32 _key, bytes calldata _data) external;


    function setBool(bytes32 _key, bool _data) external;


    function setUint256Array(bytes32 _key, uint256[] calldata _data) external;


    function setBytes32Array(bytes32 _key, bytes32[] calldata _data) external ;


    function setAddressArray(bytes32 _key, address[] calldata _data) external;


    function setBoolArray(bytes32 _key, bool[] calldata _data) external;


    function insertUint256(bytes32 _key, uint256 _data) external;


    function insertBytes32(bytes32 _key, bytes32 _data) external;


    function insertAddress(bytes32 _key, address _data) external;


    function insertBool(bytes32 _key, bool _data) external;


    function deleteUint256(bytes32 _key, uint256 _index) external;


    function deleteBytes32(bytes32 _key, uint256 _index) external;


    function deleteAddress(bytes32 _key, uint256 _index) external;


    function deleteBool(bytes32 _key, uint256 _index) external;


    function setUint256Multi(bytes32[] calldata _keys, uint256[] calldata _data) external;


    function setBytes32Multi(bytes32[] calldata _keys, bytes32[] calldata _data) external;


    function setAddressMulti(bytes32[] calldata _keys, address[] calldata _data) external;


    function setBoolMulti(bytes32[] calldata _keys, bool[] calldata _data) external;


    function insertUint256Multi(bytes32[] calldata _keys, uint256[] calldata _data) external;


    function insertBytes32Multi(bytes32[] calldata _keys, bytes32[] calldata _data) external;


    function insertAddressMulti(bytes32[] calldata _keys, address[] calldata _data) external;


    function insertBoolMulti(bytes32[] calldata _keys, bool[] calldata _data) external;


    function getUint256(bytes32 _key) external view returns(uint256);


    function getBytes32(bytes32 _key) external view returns(bytes32);


    function getAddress(bytes32 _key) external view returns(address);


    function getString(bytes32 _key) external view returns(string memory);


    function getBytes(bytes32 _key) external view returns(bytes memory);


    function getBool(bytes32 _key) external view returns(bool);


    function getUint256Array(bytes32 _key) external view returns(uint256[] memory);


    function getBytes32Array(bytes32 _key) external view returns(bytes32[] memory);


    function getAddressArray(bytes32 _key) external view returns(address[] memory);


    function getBoolArray(bytes32 _key) external view returns(bool[] memory);


    function getUint256ArrayLength(bytes32 _key) external view returns(uint256);


    function getBytes32ArrayLength(bytes32 _key) external view returns(uint256);


    function getAddressArrayLength(bytes32 _key) external view returns(uint256);


    function getBoolArrayLength(bytes32 _key) external view returns(uint256);


    function getUint256ArrayElement(bytes32 _key, uint256 _index) external view returns(uint256);


    function getBytes32ArrayElement(bytes32 _key, uint256 _index) external view returns(bytes32);


    function getAddressArrayElement(bytes32 _key, uint256 _index) external view returns(address);


    function getBoolArrayElement(bytes32 _key, uint256 _index) external view returns(bool);


    function getUint256ArrayElements(bytes32 _key, uint256 _startIndex, uint256 _endIndex) external view returns(uint256[] memory);


    function getBytes32ArrayElements(bytes32 _key, uint256 _startIndex, uint256 _endIndex) external view returns(bytes32[] memory);


    function getAddressArrayElements(bytes32 _key, uint256 _startIndex, uint256 _endIndex) external view returns(address[] memory);


    function getBoolArrayElements(bytes32 _key, uint256 _startIndex, uint256 _endIndex) external view returns(bool[] memory);

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

interface ICheckPermission {

    function checkPermission(address _delegate, address _module, bytes32 _perm) external view returns(bool hasPerm);

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

contract ModuleStorage {

    address public factory;

    ISecurityToken public securityToken;

    bytes32 public constant ADMIN = "ADMIN";
    bytes32 public constant OPERATOR = "OPERATOR";

    bytes32 internal constant TREASURY = 0xaae8817359f3dcb67d050f44f3e49f982e0359d90ca4b5f18569926304aaece6; // keccak256(abi.encodePacked("TREASURY_WALLET"))

    IERC20 public polyToken;

    constructor(address _securityToken, address _polyAddress) public {
        securityToken = ISecurityToken(_securityToken);
        factory = msg.sender;
        polyToken = IERC20(_polyAddress);
    }

}

contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Module is IModule, ModuleStorage, Pausable {

    constructor (address _securityToken, address _polyAddress) public
    ModuleStorage(_securityToken, _polyAddress)
    {
    }

    modifier withPerm(bytes32 _perm) {

        require(_checkPerm(_perm, msg.sender), "Invalid permission");
        _;
    }

    function _checkPerm(bytes32 _perm, address _caller) internal view returns (bool) {

        bool isOwner = _caller == Ownable(address(securityToken)).owner();
        bool isFactory = _caller == factory;
        return isOwner || isFactory || ICheckPermission(address(securityToken)).checkPermission(_caller, address(this), _perm);
    }

    function _onlySecurityTokenOwner() internal view {

        require(msg.sender == Ownable(address(securityToken)).owner(), "Sender is not owner");
    }

    modifier onlyFactory() {

        require(msg.sender == factory, "Sender is not factory");
        _;
    }

    function pause() public {

        _onlySecurityTokenOwner();
        super._pause();
    }

    function unpause() public {

        _onlySecurityTokenOwner();
        super._unpause();
    }

    function getDataStore() public view returns(IDataStore) {

        return IDataStore(securityToken.dataStore());
    }

    function reclaimERC20(address _tokenContract) external {

        _onlySecurityTokenOwner();
        require(_tokenContract != address(0), "Invalid address");
        IERC20 token = IERC20(_tokenContract);
        uint256 balance = token.balanceOf(address(this));
        require(token.transfer(msg.sender, balance), "Transfer failed");
    }

    function reclaimETH() external {

        _onlySecurityTokenOwner();
        msg.sender.transfer(address(this).balance);
    }
}

interface ITransferManager {

    enum Result {INVALID, NA, VALID, FORCE_VALID}

    function executeTransfer(address _from, address _to, uint256 _amount, bytes calldata _data) external returns(Result result);


    function verifyTransfer(address _from, address _to, uint256 _amount, bytes calldata _data) external view returns(Result result, bytes32 partition);


    function getTokensByPartition(bytes32 _partition, address _tokenHolder, uint256 _additionalBalance) external view returns(uint256 amount);


}

contract TransferManager is ITransferManager, Module {


    bytes32 public constant LOCKED = "LOCKED";
    bytes32 public constant UNLOCKED = "UNLOCKED";

    modifier onlySecurityToken() {

        require(msg.sender == address(securityToken), "Sender is not owner");
        _;
    }


    function getTokensByPartition(bytes32 _partition, address _tokenHolder, uint256 /*_additionalBalance*/) external view returns(uint256) {

        if (_partition == UNLOCKED)
            return securityToken.balanceOf(_tokenHolder);
        return uint256(0);
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


library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        if (signature.length != 65) {
            return (address(0));
        }

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return address(0);
        }

        if (v != 27 && v != 28) {
            return address(0);
        }

        return ecrecover(hash, v, r, s);
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}

contract GeneralTransferManagerStorage {


    bytes32 public constant WHITELIST = "WHITELIST";
    bytes32 public constant INVESTORSKEY = 0xdf3a8dd24acdd05addfc6aeffef7574d2de3f844535ec91e8e0f3e45dba96731; //keccak256(abi.encodePacked("INVESTORS"))
    bytes32 public constant INVESTORFLAGS = "INVESTORFLAGS";
    uint256 internal constant ONE = uint256(1);

    enum TransferType { GENERAL, ISSUANCE, REDEMPTION }

    address public issuanceAddress;

    struct Defaults {
        uint64 canSendAfter;
        uint64 canReceiveAfter;
    }

    Defaults public defaults;

    mapping(address => mapping(uint256 => bool)) public nonceMap;

    struct TransferRequirements {
        bool fromValidKYC;
        bool toValidKYC;
        bool fromRestricted;
        bool toRestricted;
    }

    mapping(uint8 => TransferRequirements) public transferRequirements;
}

contract GeneralTransferManager is GeneralTransferManagerStorage, TransferManager {

    using SafeMath for uint256;
    using ECDSA for bytes32;

    event ChangeIssuanceAddress(address _issuanceAddress);

    event ChangeDefaults(uint64 _defaultCanSendAfter, uint64 _defaultCanReceiveAfter);

    event ModifyKYCData(
        address indexed _investor,
        address indexed _addedBy,
        uint64 _canSendAfter,
        uint64 _canReceiveAfter,
        uint64 _expiryTime
    );

    event ModifyInvestorFlag(
        address indexed _investor,
        uint8 indexed _flag,
        bool _value
    );

    event ModifyTransferRequirements(
        TransferType indexed _transferType,
        bool _fromValidKYC,
        bool _toValidKYC,
        bool _fromRestricted,
        bool _toRestricted
    );

    constructor(address _securityToken, address _polyToken)
    public
    Module(_securityToken, _polyToken)
    {

    }

    function getInitFunction() public pure returns(bytes4) {

        return bytes4(0);
    }

    function changeDefaults(uint64 _defaultCanSendAfter, uint64 _defaultCanReceiveAfter) public withPerm(ADMIN) {

        defaults.canSendAfter = _defaultCanSendAfter;
        defaults.canReceiveAfter = _defaultCanReceiveAfter;
        emit ChangeDefaults(_defaultCanSendAfter, _defaultCanReceiveAfter);
    }

    function changeIssuanceAddress(address _issuanceAddress) public withPerm(ADMIN) {

        issuanceAddress = _issuanceAddress;
        emit ChangeIssuanceAddress(_issuanceAddress);
    }

    function executeTransfer(
        address _from,
        address _to,
        uint256 /*_amount*/,
        bytes calldata _data
    ) external returns(Result) {

        if (_data.length > 32) {
            address target;
            uint256 nonce;
            uint256 validFrom;
            uint256 validTo;
            bytes memory data;
            (target, nonce, validFrom, validTo, data) = abi.decode(_data, (address, uint256, uint256, uint256, bytes));
            if (target == address(this))
                _processTransferSignature(nonce, validFrom, validTo, data);
        }
        (Result success,) = _verifyTransfer(_from, _to);
        return success;
    }

    function _processTransferSignature(uint256 _nonce, uint256 _validFrom, uint256 _validTo, bytes memory _data) internal {

        address[] memory investor;
        uint256[] memory canSendAfter;
        uint256[] memory canReceiveAfter;
        uint256[] memory expiryTime;
        bytes memory signature;
        (investor, canSendAfter, canReceiveAfter, expiryTime, signature) =
            abi.decode(_data, (address[], uint256[], uint256[], uint256[], bytes));
        _modifyKYCDataSignedMulti(investor, canSendAfter, canReceiveAfter, expiryTime, _validFrom, _validTo, _nonce, signature);
    }

    function verifyTransfer(
        address _from,
        address _to,
        uint256 /*_amount*/,
        bytes memory /* _data */
    )
        public
        view
        returns(Result, bytes32)
    {

        return _verifyTransfer(_from, _to);
    }

    function _verifyTransfer(
        address _from,
        address _to
    )
        internal
        view
        returns(Result, bytes32)
    {

        if (!paused) {
            TransferRequirements memory txReq;
            uint64 canSendAfter;
            uint64 fromExpiry;
            uint64 toExpiry;
            uint64 canReceiveAfter;

            if (_from == issuanceAddress) {
                txReq = transferRequirements[uint8(TransferType.ISSUANCE)];
            } else if (_to == address(0)) {
                txReq = transferRequirements[uint8(TransferType.REDEMPTION)];
            } else {
                txReq = transferRequirements[uint8(TransferType.GENERAL)];
            }

            (canSendAfter, fromExpiry, canReceiveAfter, toExpiry) = _getValuesForTransfer(_from, _to);

            if ((txReq.fromValidKYC && !_validExpiry(fromExpiry)) || (txReq.toValidKYC && !_validExpiry(toExpiry))) {
                return (Result.NA, bytes32(0));
            }

            (canSendAfter, canReceiveAfter) = _adjustTimes(canSendAfter, canReceiveAfter);

            if ((txReq.fromRestricted && !_validLockTime(canSendAfter)) || (txReq.toRestricted && !_validLockTime(canReceiveAfter))) {
                return (Result.NA, bytes32(0));
            }

            return (Result.VALID, getAddressBytes32());
        }
        return (Result.NA, bytes32(0));
    }

    function modifyTransferRequirements(
        TransferType _transferType,
        bool _fromValidKYC,
        bool _toValidKYC,
        bool _fromRestricted,
        bool _toRestricted
    ) public withPerm(ADMIN) {

        _modifyTransferRequirements(
            _transferType,
            _fromValidKYC,
            _toValidKYC,
            _fromRestricted,
            _toRestricted
        );
    }

    function modifyTransferRequirementsMulti(
        TransferType[] memory _transferTypes,
        bool[] memory _fromValidKYC,
        bool[] memory _toValidKYC,
        bool[] memory _fromRestricted,
        bool[] memory _toRestricted
    ) public withPerm(ADMIN) {

        require(
            _transferTypes.length == _fromValidKYC.length &&
            _fromValidKYC.length == _toValidKYC.length &&
            _toValidKYC.length == _fromRestricted.length &&
            _fromRestricted.length == _toRestricted.length,
            "Mismatched input lengths"
        );

        for (uint256 i = 0; i <  _transferTypes.length; i++) {
            _modifyTransferRequirements(
                _transferTypes[i],
                _fromValidKYC[i],
                _toValidKYC[i],
                _fromRestricted[i],
                _toRestricted[i]
            );
        }
    }

    function _modifyTransferRequirements(
        TransferType _transferType,
        bool _fromValidKYC,
        bool _toValidKYC,
        bool _fromRestricted,
        bool _toRestricted
    ) internal {

        transferRequirements[uint8(_transferType)] =
            TransferRequirements(
                _fromValidKYC,
                _toValidKYC,
                _fromRestricted,
                _toRestricted
            );

        emit ModifyTransferRequirements(
            _transferType,
            _fromValidKYC,
            _toValidKYC,
            _fromRestricted,
            _toRestricted
        );
    }


    function modifyKYCData(
        address _investor,
        uint64 _canSendAfter,
        uint64 _canReceiveAfter,
        uint64 _expiryTime
    )
        public
        withPerm(ADMIN)
    {

        _modifyKYCData(_investor, _canSendAfter, _canReceiveAfter, _expiryTime);
    }

    function _modifyKYCData(address _investor, uint64 _canSendAfter, uint64 _canReceiveAfter, uint64 _expiryTime) internal {

        require(_investor != address(0), "Invalid investor");
        IDataStore dataStore = getDataStore();
        if (!_isExistingInvestor(_investor, dataStore)) {
           dataStore.insertAddress(INVESTORSKEY, _investor);
        }
        uint256 _data = VersionUtils.packKYC(_canSendAfter, _canReceiveAfter, _expiryTime, uint8(1));
        dataStore.setUint256(_getKey(WHITELIST, _investor), _data);
        emit ModifyKYCData(_investor, msg.sender, _canSendAfter, _canReceiveAfter, _expiryTime);
    }

    function modifyKYCDataMulti(
        address[] memory _investors,
        uint64[] memory _canSendAfter,
        uint64[] memory _canReceiveAfter,
        uint64[] memory _expiryTime
    )
        public
        withPerm(ADMIN)
    {

        require(
            _investors.length == _canSendAfter.length &&
            _canSendAfter.length == _canReceiveAfter.length &&
            _canReceiveAfter.length == _expiryTime.length,
            "Mismatched input lengths"
        );
        for (uint256 i = 0; i < _investors.length; i++) {
            _modifyKYCData(_investors[i], _canSendAfter[i], _canReceiveAfter[i], _expiryTime[i]);
        }
    }

    function modifyInvestorFlag(
        address _investor,
        uint8 _flag,
        bool _value
    )
        public
        withPerm(ADMIN)
    {

        _modifyInvestorFlag(_investor, _flag, _value);
    }


    function _modifyInvestorFlag(address _investor, uint8 _flag, bool _value) internal {

        require(_investor != address(0), "Invalid investor");
        IDataStore dataStore = getDataStore();
        if (!_isExistingInvestor(_investor, dataStore)) {
           dataStore.insertAddress(INVESTORSKEY, _investor);
           dataStore.setUint256(_getKey(WHITELIST, _investor), uint256(1));
        }
        uint256 flags = dataStore.getUint256(_getKey(INVESTORFLAGS, _investor));
        if (_value)
            flags = flags | (ONE << _flag);
        else
            flags = flags & ~(ONE << _flag);
        dataStore.setUint256(_getKey(INVESTORFLAGS, _investor), flags);
        emit ModifyInvestorFlag(_investor, _flag, _value);
    }

    function modifyInvestorFlagMulti(
        address[] memory _investors,
        uint8[] memory _flag,
        bool[] memory _value
    )
        public
        withPerm(ADMIN)
    {

        require(
            _investors.length == _flag.length &&
            _flag.length == _value.length,
            "Mismatched input lengths"
        );
        for (uint256 i = 0; i < _investors.length; i++) {
            _modifyInvestorFlag(_investors[i], _flag[i], _value[i]);
        }
    }

    function modifyKYCDataSigned(
        address _investor,
        uint256 _canSendAfter,
        uint256 _canReceiveAfter,
        uint256 _expiryTime,
        uint256 _validFrom,
        uint256 _validTo,
        uint256 _nonce,
        bytes memory _signature
    )
        public
    {

        require(
            _modifyKYCDataSigned(_investor, _canSendAfter, _canReceiveAfter, _expiryTime, _validFrom, _validTo, _nonce, _signature),
            "Invalid signature or data"
        );
    }

    function _modifyKYCDataSigned(
        address _investor,
        uint256 _canSendAfter,
        uint256 _canReceiveAfter,
        uint256 _expiryTime,
        uint256 _validFrom,
        uint256 _validTo,
        uint256 _nonce,
        bytes memory _signature
    )
        internal
        returns(bool)
    {

        if(_validFrom > now || _validTo < now || _investor == address(0))
            return false;
        bytes32 hash = keccak256(
            abi.encodePacked(this, _investor, _canSendAfter, _canReceiveAfter, _expiryTime, _validFrom, _validTo, _nonce)
        );
        if (_checkSig(hash, _signature, _nonce)) {
            require(
                uint64(_canSendAfter) == _canSendAfter &&
                uint64(_canReceiveAfter) == _canReceiveAfter &&
                uint64(_expiryTime) == _expiryTime,
                "uint64 overflow"
            );
            _modifyKYCData(_investor, uint64(_canSendAfter), uint64(_canReceiveAfter), uint64(_expiryTime));
            return true;
        }
        return false;
    }

    function modifyKYCDataSignedMulti(
        address[] memory _investor,
        uint256[] memory _canSendAfter,
        uint256[] memory _canReceiveAfter,
        uint256[] memory _expiryTime,
        uint256 _validFrom,
        uint256 _validTo,
        uint256 _nonce,
        bytes memory _signature
    )
        public
    {

        require(
            _modifyKYCDataSignedMulti(_investor, _canSendAfter, _canReceiveAfter, _expiryTime, _validFrom, _validTo, _nonce, _signature),
            "Invalid signature or data"
        );
    }

    function _modifyKYCDataSignedMulti(
        address[] memory _investor,
        uint256[] memory _canSendAfter,
        uint256[] memory _canReceiveAfter,
        uint256[] memory _expiryTime,
        uint256 _validFrom,
        uint256 _validTo,
        uint256 _nonce,
        bytes memory _signature
    )
        internal
        returns(bool)
    {

        if (_investor.length != _canSendAfter.length ||
            _canSendAfter.length != _canReceiveAfter.length ||
            _canReceiveAfter.length != _expiryTime.length
        ) {
            return false;
        }

        if (_validFrom > now || _validTo < now) {
            return false;
        }

        bytes32 hash = keccak256(
            abi.encodePacked(this, _investor, _canSendAfter, _canReceiveAfter, _expiryTime, _validFrom, _validTo, _nonce)
        );

        if (_checkSig(hash, _signature, _nonce)) {
            for (uint256 i = 0; i < _investor.length; i++) {
                if (uint64(_canSendAfter[i]) == _canSendAfter[i] &&
                    uint64(_canReceiveAfter[i]) == _canReceiveAfter[i] &&
                    uint64(_expiryTime[i]) == _expiryTime[i]
                )
                    _modifyKYCData(_investor[i], uint64(_canSendAfter[i]), uint64(_canReceiveAfter[i]), uint64(_expiryTime[i]));
            }
            return true;
        }
        return false;
    }

    function _checkSig(bytes32 _hash, bytes memory _signature, uint256 _nonce) internal returns(bool) {

        address signer = _hash.toEthSignedMessageHash().recover(_signature);
        if (nonceMap[signer][_nonce] || !_checkPerm(OPERATOR, signer)) {
            return false;
        }
        nonceMap[signer][_nonce] = true;
        return true;
    }

    function _validExpiry(uint64 _expiryTime) internal view returns(bool valid) {

        if (_expiryTime >= uint64(now)) /*solium-disable-line security/no-block-members*/
            valid = true;
    }

    function _validLockTime(uint64 _lockTime) internal view returns(bool valid) {

        if (_lockTime <= uint64(now)) /*solium-disable-line security/no-block-members*/
            valid = true;
    }

    function _adjustTimes(uint64 _canSendAfter, uint64 _canReceiveAfter) internal view returns(uint64, uint64) {

        if (_canSendAfter == 0) {
            _canSendAfter = defaults.canSendAfter;
        }
        if (_canReceiveAfter == 0) {
            _canReceiveAfter = defaults.canReceiveAfter;
        }
        return (_canSendAfter, _canReceiveAfter);
    }

    function _getKey(bytes32 _key1, address _key2) internal pure returns(bytes32) {

        return bytes32(keccak256(abi.encodePacked(_key1, _key2)));
    }

    function _getKYCValues(address _investor, IDataStore dataStore) internal view returns(
        uint64 canSendAfter,
        uint64 canReceiveAfter,
        uint64 expiryTime,
        uint8 added
    )
    {

        uint256 data = dataStore.getUint256(_getKey(WHITELIST, _investor));
        (canSendAfter, canReceiveAfter, expiryTime, added)  = VersionUtils.unpackKYC(data);
    }

    function _isExistingInvestor(address _investor, IDataStore dataStore) internal view returns(bool) {

        uint256 data = dataStore.getUint256(_getKey(WHITELIST, _investor));
        return uint8(data) == 0 ? false : true;
    }

    function _getValuesForTransfer(address _from, address _to) internal view returns(uint64 canSendAfter, uint64 fromExpiry, uint64 canReceiveAfter, uint64 toExpiry) {

        IDataStore dataStore = getDataStore();
        (canSendAfter, , fromExpiry, ) = _getKYCValues(_from, dataStore);
        (, canReceiveAfter, toExpiry, ) = _getKYCValues(_to, dataStore);
    }

    function getAllInvestors() public view returns(address[] memory investors) {

        IDataStore dataStore = getDataStore();
        investors = dataStore.getAddressArray(INVESTORSKEY);
    }

    function getInvestors(uint256 _fromIndex, uint256 _toIndex) public view returns(address[] memory investors) {

        IDataStore dataStore = getDataStore();
        investors = dataStore.getAddressArrayElements(INVESTORSKEY, _fromIndex, _toIndex);
    }

    function getAllInvestorFlags() public view returns(address[] memory investors, uint256[] memory flags) {

        investors = getAllInvestors();
        flags = new uint256[](investors.length);
        for (uint256 i = 0; i < investors.length; i++) {
            flags[i] = _getInvestorFlags(investors[i]);
        }
    }

    function getInvestorFlag(address _investor, uint8 _flag) public view returns(bool value) {

        uint256 flag = (_getInvestorFlags(_investor) >> _flag) & ONE;
        value = flag > 0 ? true : false;
    }

    function getInvestorFlags(address _investor) public view returns(uint256 flags) {

        flags = _getInvestorFlags(_investor);
    }

    function _getInvestorFlags(address _investor) internal view returns(uint256 flags) {

        IDataStore dataStore = getDataStore();
        flags = dataStore.getUint256(_getKey(INVESTORFLAGS, _investor));
    }

    function getAllKYCData() external view returns(
        address[] memory investors,
        uint256[] memory canSendAfters,
        uint256[] memory canReceiveAfters,
        uint256[] memory expiryTimes
    ) {

        investors = getAllInvestors();
        (canSendAfters, canReceiveAfters, expiryTimes) = _kycData(investors);
        return (investors, canSendAfters, canReceiveAfters, expiryTimes);
    }

    function getKYCData(address[] calldata _investors) external view returns(
        uint256[] memory,
        uint256[] memory,
        uint256[] memory
    ) {

        return _kycData(_investors);
    }

    function _kycData(address[] memory _investors) internal view returns(
        uint256[] memory,
        uint256[] memory,
        uint256[] memory
    ) {

        uint256[] memory canSendAfters = new uint256[](_investors.length);
        uint256[] memory canReceiveAfters = new uint256[](_investors.length);
        uint256[] memory expiryTimes = new uint256[](_investors.length);
        for (uint256 i = 0; i < _investors.length; i++) {
            (canSendAfters[i], canReceiveAfters[i], expiryTimes[i], ) = _getKYCValues(_investors[i], getDataStore());
        }
        return (canSendAfters, canReceiveAfters, expiryTimes);
    }

    function getPermissions() public view returns(bytes32[] memory) {

        bytes32[] memory allPermissions = new bytes32[](1);
        allPermissions[0] = ADMIN;
        return allPermissions;
    }

    function getTokensByPartition(bytes32 _partition, address _tokenHolder, uint256 _additionalBalance) external view returns(uint256) {

        uint256 currentBalance = (msg.sender == address(securityToken)) ? (securityToken.balanceOf(_tokenHolder)).add(_additionalBalance) : securityToken.balanceOf(_tokenHolder);
        uint256 canSendAfter;
        (canSendAfter,,,) = _getKYCValues(_tokenHolder, getDataStore());
        canSendAfter = (canSendAfter == 0 ? defaults.canSendAfter:  canSendAfter);
        bool unlockedCheck = paused ? _partition == UNLOCKED : (_partition == UNLOCKED && now >= canSendAfter);
        if (((_partition == LOCKED && now < canSendAfter) && !paused) || unlockedCheck)
            return currentBalance;
        else
            return 0;
    }

    function getAddressBytes32() public view returns(bytes32) {

        return bytes32(uint256(address(this)) << 96);
    }

}