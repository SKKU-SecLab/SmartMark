
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

contract LockUpTransferManagerStorage {


    struct LockUp {
        uint256 lockupAmount; // Amount to be locked
        uint256 startTime; // when this lockup starts (seconds)
        uint256 lockUpPeriodSeconds; // total period of lockup (seconds)
        uint256 releaseFrequencySeconds; // how often to release a tranche of tokens (seconds)
    }

    mapping (bytes32 => LockUp) public lockups;
    mapping (address => bytes32[]) internal userToLockups;
    mapping (bytes32 => address[]) internal lockupToUsers;
    mapping (address => mapping(bytes32 => uint256)) internal userToLockupIndex;
    mapping (bytes32 => mapping(address => uint256)) internal lockupToUserIndex;

    bytes32[] lockupArray;

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

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

contract LockUpTransferManager is LockUpTransferManagerStorage, TransferManager {

    using SafeMath for uint256;

    event AddLockUpToUser(
        address indexed _userAddress,
        bytes32 indexed _lockupName
    );

    event RemoveLockUpFromUser(
        address indexed _userAddress,
        bytes32 indexed _lockupName
    );

    event ModifyLockUpType(
        uint256 _lockupAmount,
        uint256 _startTime,
        uint256 _lockUpPeriodSeconds,
        uint256 _releaseFrequencySeconds,
        bytes32 indexed _lockupName
    );

    event AddNewLockUpType(
        bytes32 indexed _lockupName,
        uint256 _lockupAmount,
        uint256 _startTime,
        uint256 _lockUpPeriodSeconds,
        uint256 _releaseFrequencySeconds
    );

    event RemoveLockUpType(bytes32 indexed _lockupName);

    constructor (address _securityToken, address _polyAddress)
    public
    Module(_securityToken, _polyAddress)
    {
    }

    function executeTransfer(address  _from, address /*_to*/, uint256  _amount, bytes calldata /*_data*/) external returns(Result) {

        (Result success,) = _verifyTransfer(_from, _amount);
        return success;
    }

    function verifyTransfer(
        address  _from,
        address /* _to*/,
        uint256  _amount,
        bytes memory /* _data */
    )
        public
        view
        returns(Result, bytes32)
    {

        return _verifyTransfer(_from, _amount);
    }

    function _verifyTransfer(
        address  _from,
        uint256  _amount
    )
        internal
        view
        returns(Result, bytes32)
    {

        if (!paused && _from != address(0) && userToLockups[_from].length != 0) {
            return _checkIfValidTransfer(_from, _amount);
        }
        return (Result.NA, bytes32(0));
    }


    function addNewLockUpType(
        uint256 _lockupAmount,
        uint256 _startTime,
        uint256 _lockUpPeriodSeconds,
        uint256 _releaseFrequencySeconds,
        bytes32 _lockupName
    )
        external
        withPerm(ADMIN)
    {

        _addNewLockUpType(
            _lockupAmount,
            _startTime,
            _lockUpPeriodSeconds,
            _releaseFrequencySeconds,
            _lockupName
        );
    }

    function addNewLockUpTypeMulti(
        uint256[] memory _lockupAmounts,
        uint256[] memory _startTimes,
        uint256[] memory _lockUpPeriodsSeconds,
        uint256[] memory _releaseFrequenciesSeconds,
        bytes32[] memory _lockupNames
    )
        public
        withPerm(ADMIN)
    {

        require(
            _lockupNames.length == _lockUpPeriodsSeconds.length && /*solium-disable-line operator-whitespace*/
            _lockupNames.length == _releaseFrequenciesSeconds.length && /*solium-disable-line operator-whitespace*/
            _lockupNames.length == _startTimes.length && /*solium-disable-line operator-whitespace*/
            _lockupNames.length == _lockupAmounts.length,
            "Length mismatch"
        );
        for (uint256 i = 0; i < _lockupNames.length; i++) {
            _addNewLockUpType(
                _lockupAmounts[i],
                _startTimes[i],
                _lockUpPeriodsSeconds[i],
                _releaseFrequenciesSeconds[i],
                _lockupNames[i]
            );
        }
    }

    function addLockUpByName(
        address _userAddress,
        bytes32 _lockupName
    )
        external
        withPerm(ADMIN)
    {

        _addLockUpByName(_userAddress, _lockupName);
    }

    function addLockUpByNameMulti(
        address[] memory _userAddresses,
        bytes32[] memory _lockupNames
    )
        public
        withPerm(ADMIN)
    {

        _checkLengthOfArray(_userAddresses.length, _lockupNames.length);
        for (uint256 i = 0; i < _userAddresses.length; i++) {
            _addLockUpByName(_userAddresses[i], _lockupNames[i]);
        }
    }

    function addNewLockUpToUser(
        address _userAddress,
        uint256 _lockupAmount,
        uint256 _startTime,
        uint256 _lockUpPeriodSeconds,
        uint256 _releaseFrequencySeconds,
        bytes32 _lockupName
    )
        external
        withPerm(ADMIN)
    {

        _addNewLockUpToUser(
            _userAddress,
            _lockupAmount,
            _startTime,
            _lockUpPeriodSeconds,
            _releaseFrequencySeconds,
            _lockupName
        );
    }

    function addNewLockUpToUserMulti(
        address[] memory _userAddresses,
        uint256[] memory _lockupAmounts,
        uint256[] memory _startTimes,
        uint256[] memory _lockUpPeriodsSeconds,
        uint256[] memory _releaseFrequenciesSeconds,
        bytes32[] memory _lockupNames
    )
        public
        withPerm(ADMIN)
    {

        require(
            _userAddresses.length == _lockUpPeriodsSeconds.length && /*solium-disable-line operator-whitespace*/
            _userAddresses.length == _releaseFrequenciesSeconds.length && /*solium-disable-line operator-whitespace*/
            _userAddresses.length == _startTimes.length && /*solium-disable-line operator-whitespace*/
            _userAddresses.length == _lockupAmounts.length &&
            _userAddresses.length == _lockupNames.length,
            "Length mismatch"
        );
        for (uint256 i = 0; i < _userAddresses.length; i++) {
            _addNewLockUpToUser(_userAddresses[i], _lockupAmounts[i], _startTimes[i], _lockUpPeriodsSeconds[i], _releaseFrequenciesSeconds[i], _lockupNames[i]);
        }
    }

    function removeLockUpFromUser(address _userAddress, bytes32 _lockupName) external withPerm(ADMIN) {

        _removeLockUpFromUser(_userAddress, _lockupName);
    }

    function removeLockupType(bytes32 _lockupName) external withPerm(ADMIN) {

        _removeLockupType(_lockupName);
    }

    function removeLockupTypeMulti(bytes32[] memory _lockupNames) public withPerm(ADMIN) {

        for (uint256 i = 0; i < _lockupNames.length; i++) {
            _removeLockupType(_lockupNames[i]);
        }
    }

    function removeLockUpFromUserMulti(address[] memory _userAddresses, bytes32[] memory _lockupNames) public withPerm(ADMIN) {

        _checkLengthOfArray(_userAddresses.length, _lockupNames.length);
        for (uint256 i = 0; i < _userAddresses.length; i++) {
            _removeLockUpFromUser(_userAddresses[i], _lockupNames[i]);
        }
    }

    function modifyLockUpType(
        uint256 _lockupAmount,
        uint256 _startTime,
        uint256 _lockUpPeriodSeconds,
        uint256 _releaseFrequencySeconds,
        bytes32 _lockupName
    )
        external
        withPerm(ADMIN)
    {

        _modifyLockUpType(
            _lockupAmount,
            _startTime,
            _lockUpPeriodSeconds,
            _releaseFrequencySeconds,
            _lockupName
        );
    }

    function modifyLockUpTypeMulti(
        uint256[] memory _lockupAmounts,
        uint256[] memory _startTimes,
        uint256[] memory _lockUpPeriodsSeconds,
        uint256[] memory _releaseFrequenciesSeconds,
        bytes32[] memory _lockupNames
    )
        public
        withPerm(ADMIN)
    {

        require(
            _lockupNames.length == _lockUpPeriodsSeconds.length && /*solium-disable-line operator-whitespace*/
            _lockupNames.length == _releaseFrequenciesSeconds.length && /*solium-disable-line operator-whitespace*/
            _lockupNames.length == _startTimes.length && /*solium-disable-line operator-whitespace*/
            _lockupNames.length == _lockupAmounts.length,
            "Length mismatch"
        );
        for (uint256 i = 0; i < _lockupNames.length; i++) {
            _modifyLockUpType(
                _lockupAmounts[i],
                _startTimes[i],
                _lockUpPeriodsSeconds[i],
                _releaseFrequenciesSeconds[i],
                _lockupNames[i]
            );
        }
    }

    function getLockUp(bytes32 _lockupName) public view returns (
        uint256 lockupAmount,
        uint256 startTime,
        uint256 lockUpPeriodSeconds,
        uint256 releaseFrequencySeconds,
        uint256 unlockedAmount
    ) {

        if (lockups[_lockupName].lockupAmount != 0) {
            return (
                lockups[_lockupName].lockupAmount,
                lockups[_lockupName].startTime,
                lockups[_lockupName].lockUpPeriodSeconds,
                lockups[_lockupName].releaseFrequencySeconds,
                _getUnlockedAmountForLockup(_lockupName)
            );
        }
        return (uint256(0), uint256(0), uint256(0), uint256(0), uint256(0));
    }

    function getAllLockupData() external view returns(
        bytes32[] memory lockupNames,
        uint256[] memory lockupAmounts,
        uint256[] memory startTimes,
        uint256[] memory lockUpPeriodSeconds,
        uint256[] memory releaseFrequencySeconds,
        uint256[] memory unlockedAmounts
    )
    {

        uint256 length = lockupArray.length;
        lockupAmounts = new uint256[](length);
        startTimes = new uint256[](length);
        lockUpPeriodSeconds = new uint256[](length);
        releaseFrequencySeconds = new uint256[](length);
        unlockedAmounts = new uint256[](length);
        lockupNames = new bytes32[](length);
        for (uint256 i = 0; i < length; i++) {
            (lockupAmounts[i], startTimes[i], lockUpPeriodSeconds[i], releaseFrequencySeconds[i], unlockedAmounts[i]) = getLockUp(lockupArray[i]);
            lockupNames[i] = lockupArray[i];
        }
    }

    function getListOfAddresses(bytes32 _lockupName) external view returns(address[] memory) {

        _validLockUpCheck(_lockupName);
        return lockupToUsers[_lockupName];
    }

    function getAllLockups() external view returns(bytes32[] memory) {

        return lockupArray;
    }

    function getLockupsNamesToUser(address _user) external view returns(bytes32[] memory) {

        return userToLockups[_user];
    }

    function getLockedTokenToUser(address _userAddress) public view returns(uint256) {

        _checkZeroAddress(_userAddress);
        bytes32[] memory userLockupNames = userToLockups[_userAddress];
        uint256 totalRemainingLockedAmount = 0;
        for (uint256 i = 0; i < userLockupNames.length; i++) {
            uint256 remainingLockedAmount = lockups[userLockupNames[i]].lockupAmount.sub(_getUnlockedAmountForLockup(userLockupNames[i]));
            totalRemainingLockedAmount = totalRemainingLockedAmount.add(remainingLockedAmount);
        }
        return totalRemainingLockedAmount;
    }

    function _checkIfValidTransfer(address _userAddress, uint256 _amount) internal view returns (Result, bytes32) {

        uint256 totalRemainingLockedAmount = getLockedTokenToUser(_userAddress);
        uint256 currentBalance = securityToken.balanceOf(_userAddress);
        if ((currentBalance.sub(_amount)) >= totalRemainingLockedAmount) {
            return (Result.NA, bytes32(0));
        }
        return (Result.INVALID, bytes32(uint256(address(this)) << 96));
    }

    function _getUnlockedAmountForLockup(bytes32 _lockupName) internal view returns (uint256) {

        if (lockups[_lockupName].startTime > now) {
            return 0;
        } else if (lockups[_lockupName].startTime.add(lockups[_lockupName].lockUpPeriodSeconds) <= now) {
            return lockups[_lockupName].lockupAmount;
        } else {
            uint256 noOfPeriods = (lockups[_lockupName].lockUpPeriodSeconds).div(lockups[_lockupName].releaseFrequencySeconds);
            uint256 elapsedPeriod = (now.sub(lockups[_lockupName].startTime)).div(lockups[_lockupName].releaseFrequencySeconds);
            uint256 unLockedAmount = (lockups[_lockupName].lockupAmount.mul(elapsedPeriod)).div(noOfPeriods);
            return unLockedAmount;
        }
    }

    function _removeLockupType(bytes32 _lockupName) internal {

        _validLockUpCheck(_lockupName);
        require(lockupToUsers[_lockupName].length == 0, "Users attached to lockup");
        delete(lockups[_lockupName]);
        uint256 i = 0;
        for (i = 0; i < lockupArray.length; i++) {
            if (lockupArray[i] == _lockupName) {
                break;
            }
        }
        if (i != lockupArray.length -1) {
            lockupArray[i] = lockupArray[lockupArray.length -1];
        }
        lockupArray.length--;
        emit RemoveLockUpType(_lockupName);
    }

    function _modifyLockUpType(
        uint256 _lockupAmount,
        uint256 _startTime,
        uint256 _lockUpPeriodSeconds,
        uint256 _releaseFrequencySeconds,
        bytes32 _lockupName
    )
        internal
    {

        if (_startTime == 0) {
            _startTime = now;
        }
        _checkValidStartTime(_startTime);
        _validLockUpCheck(_lockupName);
        _checkLockUpParams(
            _lockupAmount,
            _lockUpPeriodSeconds,
            _releaseFrequencySeconds
        );

        lockups[_lockupName] =  LockUp(
            _lockupAmount,
            _startTime,
            _lockUpPeriodSeconds,
            _releaseFrequencySeconds
        );

        emit ModifyLockUpType(
            _lockupAmount,
            _startTime,
            _lockUpPeriodSeconds,
            _releaseFrequencySeconds,
            _lockupName
        );
    }

    function _removeLockUpFromUser(address _userAddress, bytes32 _lockupName) internal {

        _checkZeroAddress(_userAddress);
        _checkValidName(_lockupName);
        require(
            userToLockups[_userAddress][userToLockupIndex[_userAddress][_lockupName]] == _lockupName,
            "User not in lockup"
        );

        uint256 _lockupIndex = lockupToUserIndex[_lockupName][_userAddress];
        uint256 _len = lockupToUsers[_lockupName].length;
        if ( _lockupIndex != _len - 1) {
            lockupToUsers[_lockupName][_lockupIndex] = lockupToUsers[_lockupName][_len - 1];
            lockupToUserIndex[_lockupName][lockupToUsers[_lockupName][_lockupIndex]] = _lockupIndex;
        }
        lockupToUsers[_lockupName].length--;
        delete(lockupToUserIndex[_lockupName][_userAddress]);
        uint256 _userIndex = userToLockupIndex[_userAddress][_lockupName];
        _len = userToLockups[_userAddress].length;
        if ( _userIndex != _len - 1) {
            userToLockups[_userAddress][_userIndex] = userToLockups[_userAddress][_len - 1];
            userToLockupIndex[_userAddress][userToLockups[_userAddress][_userIndex]] = _userIndex;
        }
        userToLockups[_userAddress].length--;
        delete(userToLockupIndex[_userAddress][_lockupName]);
        emit RemoveLockUpFromUser(_userAddress, _lockupName);
    }

    function _addNewLockUpToUser(
        address _userAddress,
        uint256 _lockupAmount,
        uint256 _startTime,
        uint256 _lockUpPeriodSeconds,
        uint256 _releaseFrequencySeconds,
        bytes32 _lockupName
    )
        internal
    {

        _checkZeroAddress(_userAddress);
        _addNewLockUpType(
            _lockupAmount,
            _startTime,
            _lockUpPeriodSeconds,
            _releaseFrequencySeconds,
            _lockupName
        );
        _addLockUpByName(_userAddress, _lockupName);
    }

    function _addLockUpByName(
        address _userAddress,
        bytes32 _lockupName
    )
        internal
    {

        _checkZeroAddress(_userAddress);
        _checkValidStartTime(lockups[_lockupName].startTime);
        if(userToLockups[_userAddress].length > 0) {
            require(
                userToLockups[_userAddress][userToLockupIndex[_userAddress][_lockupName]] != _lockupName,
                "User already in lockup"
            );
        }
        userToLockupIndex[_userAddress][_lockupName] = userToLockups[_userAddress].length;
        lockupToUserIndex[_lockupName][_userAddress] = lockupToUsers[_lockupName].length;
        userToLockups[_userAddress].push(_lockupName);
        lockupToUsers[_lockupName].push(_userAddress);
        emit AddLockUpToUser(_userAddress, _lockupName);
    }

    function _addNewLockUpType(
        uint256 _lockupAmount,
        uint256 _startTime,
        uint256 _lockUpPeriodSeconds,
        uint256 _releaseFrequencySeconds,
        bytes32 _lockupName
    )
        internal
    {

        if (_startTime == 0) {
            _startTime = now;
        }
        _checkValidName(_lockupName);
        require(lockups[_lockupName].lockupAmount == 0, "Already exist");
        _checkValidStartTime(_startTime);
        _checkLockUpParams(_lockupAmount, _lockUpPeriodSeconds, _releaseFrequencySeconds);
        lockups[_lockupName] = LockUp(_lockupAmount, _startTime, _lockUpPeriodSeconds, _releaseFrequencySeconds);
        lockupArray.push(_lockupName);
        emit AddNewLockUpType(_lockupName, _lockupAmount, _startTime, _lockUpPeriodSeconds, _releaseFrequencySeconds);
    }

    function _checkLockUpParams(
        uint256 _lockupAmount,
        uint256 _lockUpPeriodSeconds,
        uint256 _releaseFrequencySeconds
    )
        internal
        pure
    {

        require(
            _lockUpPeriodSeconds != 0 &&
            _releaseFrequencySeconds != 0 &&
            _lockupAmount != 0,
            "Cannot be zero"
        );
    }

    function _checkValidStartTime(uint256 _startTime) internal view {

        require(_startTime >= now, "Invalid startTime or expired");
    }

    function _checkZeroAddress(address _userAddress) internal pure {

        require(_userAddress != address(0), "Invalid address");
    }

    function _validLockUpCheck(bytes32 _lockupName) internal view {

        require(lockups[_lockupName].startTime != 0, "Doesn't exist");
    }

    function _checkValidName(bytes32 _name) internal pure {

        require(_name != bytes32(0), "Invalid name");
    }

    function _checkLengthOfArray(uint256 _length1, uint256 _length2) internal pure {

        require(_length1 == _length2, "Length mismatch");
    }

    function getTokensByPartition(bytes32 _partition, address _tokenHolder, uint256 _additionalBalance) external view returns(uint256){

        uint256 currentBalance = (msg.sender == address(securityToken)) ? (securityToken.balanceOf(_tokenHolder)).add(_additionalBalance) : securityToken.balanceOf(_tokenHolder);
        uint256 lockedBalance = Math.min(getLockedTokenToUser(_tokenHolder), currentBalance);
        if (paused) {
            return (_partition == UNLOCKED ? currentBalance : uint256(0));
        } else {
            if (_partition == LOCKED)
                return lockedBalance;
            else if (_partition == UNLOCKED)
                return currentBalance.sub(lockedBalance);
        }
        return uint256(0);
    }

    function getInitFunction() public pure returns (bytes4) {

        return bytes4(0);
    }

    function getPermissions() public view returns(bytes32[] memory) {

        bytes32[] memory allPermissions = new bytes32[](1);
        allPermissions[0] = ADMIN;
        return allPermissions;
    }
}