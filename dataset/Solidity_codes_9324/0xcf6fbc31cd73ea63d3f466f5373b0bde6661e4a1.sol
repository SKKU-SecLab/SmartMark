
pragma solidity 0.5.8;

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

contract Wallet is Module {


}

contract VestingEscrowWalletStorage {


    struct Schedule {
        bytes32 templateName;
        uint256 claimedTokens;
        uint256 startTime;
    }

    struct Template {
        uint256 numberOfTokens;
        uint256 duration;
        uint256 frequency;
        uint256 index;
    }

    uint256 public unassignedTokens;
    address public treasuryWallet;
    address[] public beneficiaries;
    mapping(address => bool) internal beneficiaryAdded;

    mapping(address => Schedule[]) public schedules;
    mapping(address => bytes32[]) internal userToTemplates;
    mapping(address => mapping(bytes32 => uint256)) internal userToTemplateIndex;
    mapping(bytes32 => address[]) internal templateToUsers;
    mapping(bytes32 => mapping(address => uint256)) internal templateToUserIndex;
    mapping(bytes32 => Template) templates;

    bytes32[] public templateNames;
}

contract VestingEscrowWallet is VestingEscrowWalletStorage, Wallet {

    using SafeMath for uint256;

    enum State {CREATED, STARTED, COMPLETED}

    event AddSchedule(
        address indexed _beneficiary,
        bytes32 _templateName,
        uint256 _startTime
    );
    event ModifySchedule(
        address indexed _beneficiary,
        bytes32 _templateName,
        uint256 _startTime
    );
    event RevokeAllSchedules(address indexed _beneficiary);
    event RevokeSchedule(address indexed _beneficiary, bytes32 _templateName);
    event DepositTokens(uint256 _numberOfTokens, address _sender);
    event SendToTreasury(uint256 _numberOfTokens, address _sender);
    event SendTokens(address indexed _beneficiary, uint256 _numberOfTokens);
    event AddTemplate(bytes32 _name, uint256 _numberOfTokens, uint256 _duration, uint256 _frequency);
    event RemoveTemplate(bytes32 _name);
    event TreasuryWalletChanged(address _newWallet, address _oldWallet);

    constructor (address _securityToken, address _polyAddress)
    public
    Module(_securityToken, _polyAddress)
    {
    }

    function getInitFunction() public pure returns (bytes4) {

        return this.configure.selector;
    }

    function configure(address _treasuryWallet) public onlyFactory {

        _setWallet(_treasuryWallet);
    }

    function changeTreasuryWallet(address _newTreasuryWallet) public {

        _onlySecurityTokenOwner();
        _setWallet(_newTreasuryWallet);
    }

    function _setWallet(address _newTreasuryWallet) internal {

        emit TreasuryWalletChanged(_newTreasuryWallet, treasuryWallet);
        treasuryWallet = _newTreasuryWallet;
    }

    function depositTokens(uint256 _numberOfTokens) external withPerm(ADMIN) {

        _depositTokens(_numberOfTokens);
    }

    function _depositTokens(uint256 _numberOfTokens) internal {

        require(_numberOfTokens > 0, "Should be > 0");
        require(
            securityToken.transferFrom(msg.sender, address(this), _numberOfTokens),
            "Failed transferFrom"
        );
        unassignedTokens = unassignedTokens.add(_numberOfTokens);
        emit DepositTokens(_numberOfTokens, msg.sender);
    }

    function sendToTreasury(uint256 _amount) public withPerm(OPERATOR) {

        require(_amount > 0, "Amount cannot be zero");
        require(_amount <= unassignedTokens, "Amount is greater than unassigned tokens");
        unassignedTokens = unassignedTokens - _amount;
        require(securityToken.transfer(getTreasuryWallet(), _amount), "Transfer failed");
        emit SendToTreasury(_amount, msg.sender);
    }

    function getTreasuryWallet() public view returns(address) {

        if (treasuryWallet == address(0)) {
            address wallet = IDataStore(getDataStore()).getAddress(TREASURY);
            require(wallet != address(0), "Invalid address");
            return wallet;
        } else
            return treasuryWallet;
    }

    function pushAvailableTokens(address _beneficiary) public withPerm(OPERATOR) {

        _sendTokens(_beneficiary);
    }

    function pullAvailableTokens() external whenNotPaused {

        _sendTokens(msg.sender);
    }

    function addTemplate(bytes32 _name, uint256 _numberOfTokens, uint256 _duration, uint256 _frequency) external withPerm(ADMIN) {

        _addTemplate(_name, _numberOfTokens, _duration, _frequency);
    }

    function _addTemplate(bytes32 _name, uint256 _numberOfTokens, uint256 _duration, uint256 _frequency) internal {

        require(_name != bytes32(0), "Invalid name");
        require(!_isTemplateExists(_name), "Already exists");
        _validateTemplate(_numberOfTokens, _duration, _frequency);
        templateNames.push(_name);
        templates[_name] = Template(_numberOfTokens, _duration, _frequency, templateNames.length - 1);
        emit AddTemplate(_name, _numberOfTokens, _duration, _frequency);
    }

    function removeTemplate(bytes32 _name) external withPerm(ADMIN) {

        require(_isTemplateExists(_name), "Template not found");
        require(templateToUsers[_name].length == 0, "Template is used");
        uint256 index = templates[_name].index;
        if (index != templateNames.length - 1) {
            templateNames[index] = templateNames[templateNames.length - 1];
            templates[templateNames[index]].index = index;
        }
        templateNames.length--;
        delete templates[_name];
        emit RemoveTemplate(_name);
    }

    function getTemplateCount() external view returns(uint256) {

        return templateNames.length;
    }

    function getAllTemplateNames() external view returns(bytes32[] memory) {

        return templateNames;
    }

    function addSchedule(
        address _beneficiary,
        bytes32 _templateName,
        uint256 _numberOfTokens,
        uint256 _duration,
        uint256 _frequency,
        uint256 _startTime
    )
        external
        withPerm(ADMIN)
    {

        _addSchedule(_beneficiary, _templateName, _numberOfTokens, _duration, _frequency, _startTime);
    }

    function _addSchedule(
        address _beneficiary,
        bytes32 _templateName,
        uint256 _numberOfTokens,
        uint256 _duration,
        uint256 _frequency,
        uint256 _startTime
    )
        internal
    {

        _addTemplate(_templateName, _numberOfTokens, _duration, _frequency);
        _addScheduleFromTemplate(_beneficiary, _templateName, _startTime);
    }

    function addScheduleFromTemplate(address _beneficiary, bytes32 _templateName, uint256 _startTime) external withPerm(ADMIN) {

        _addScheduleFromTemplate(_beneficiary, _templateName, _startTime);
    }

    function _addScheduleFromTemplate(address _beneficiary, bytes32 _templateName, uint256 _startTime) internal {

        require(_beneficiary != address(0), "Invalid address");
        require(_isTemplateExists(_templateName), "Template not found");
        uint256 index = userToTemplateIndex[_beneficiary][_templateName];
        require(
            schedules[_beneficiary].length == 0 ||
            schedules[_beneficiary][index].templateName != _templateName,
            "Already added"
        );
        require(_startTime >= now, "Date in the past");
        uint256 numberOfTokens = templates[_templateName].numberOfTokens;
        if (numberOfTokens > unassignedTokens) {
            _depositTokens(numberOfTokens.sub(unassignedTokens));
        }
        unassignedTokens = unassignedTokens.sub(numberOfTokens);
        if (!beneficiaryAdded[_beneficiary]) {
            beneficiaries.push(_beneficiary);
            beneficiaryAdded[_beneficiary] = true;
        }
        schedules[_beneficiary].push(Schedule(_templateName, 0, _startTime));
        userToTemplates[_beneficiary].push(_templateName);
        userToTemplateIndex[_beneficiary][_templateName] = schedules[_beneficiary].length - 1;
        templateToUsers[_templateName].push(_beneficiary);
        templateToUserIndex[_templateName][_beneficiary] = templateToUsers[_templateName].length - 1;
        emit AddSchedule(_beneficiary, _templateName, _startTime);
    }

    function modifySchedule(address _beneficiary, bytes32 _templateName, uint256 _startTime) external withPerm(ADMIN) {

        _modifySchedule(_beneficiary, _templateName, _startTime);
    }

    function _modifySchedule(address _beneficiary, bytes32 _templateName, uint256 _startTime) internal {

        _checkSchedule(_beneficiary, _templateName);
        require(_startTime > now, "Date in the past");
        uint256 index = userToTemplateIndex[_beneficiary][_templateName];
        Schedule storage schedule = schedules[_beneficiary][index];
        require(now < schedule.startTime, "Schedule started");
        schedule.startTime = _startTime;
        emit ModifySchedule(_beneficiary, _templateName, _startTime);
    }

    function revokeSchedule(address _beneficiary, bytes32 _templateName) external withPerm(ADMIN) {

        _checkSchedule(_beneficiary, _templateName);
        uint256 index = userToTemplateIndex[_beneficiary][_templateName];
        _sendTokensPerSchedule(_beneficiary, index);
        uint256 releasedTokens = _getReleasedTokens(_beneficiary, index);
        unassignedTokens = unassignedTokens.add(templates[_templateName].numberOfTokens.sub(releasedTokens));
        _deleteUserToTemplates(_beneficiary, _templateName);
        _deleteTemplateToUsers(_beneficiary, _templateName);
        emit RevokeSchedule(_beneficiary, _templateName);
    }

    function _deleteUserToTemplates(address _beneficiary, bytes32 _templateName) internal {

        uint256 index = userToTemplateIndex[_beneficiary][_templateName];
        Schedule[] storage userSchedules = schedules[_beneficiary];
        if (index != userSchedules.length - 1) {
            userSchedules[index] = userSchedules[userSchedules.length - 1];
            userToTemplates[_beneficiary][index] = userToTemplates[_beneficiary][userToTemplates[_beneficiary].length - 1];
            userToTemplateIndex[_beneficiary][userSchedules[index].templateName] = index;
        }
        userSchedules.length--;
        userToTemplates[_beneficiary].length--;
        delete userToTemplateIndex[_beneficiary][_templateName];
    }

    function _deleteTemplateToUsers(address _beneficiary, bytes32 _templateName) internal {

        uint256 templateIndex = templateToUserIndex[_templateName][_beneficiary];
        if (templateIndex != templateToUsers[_templateName].length - 1) {
            templateToUsers[_templateName][templateIndex] = templateToUsers[_templateName][templateToUsers[_templateName].length - 1];
            templateToUserIndex[_templateName][templateToUsers[_templateName][templateIndex]] = templateIndex;
        }
        templateToUsers[_templateName].length--;
        delete templateToUserIndex[_templateName][_beneficiary];
    }

    function revokeAllSchedules(address _beneficiary) public withPerm(ADMIN) {

        _revokeAllSchedules(_beneficiary);
    }

    function _revokeAllSchedules(address _beneficiary) internal {

        require(_beneficiary != address(0), "Invalid address");
        _sendTokens(_beneficiary);
        Schedule[] storage userSchedules = schedules[_beneficiary];
        for (uint256 i = 0; i < userSchedules.length; i++) {
            uint256 releasedTokens = _getReleasedTokens(_beneficiary, i);
            Template memory template = templates[userSchedules[i].templateName];
            unassignedTokens = unassignedTokens.add(template.numberOfTokens.sub(releasedTokens));
            delete userToTemplateIndex[_beneficiary][userSchedules[i].templateName];
            _deleteTemplateToUsers(_beneficiary, userSchedules[i].templateName);
        }
        delete schedules[_beneficiary];
        delete userToTemplates[_beneficiary];
        emit RevokeAllSchedules(_beneficiary);
    }

    function getSchedule(address _beneficiary, bytes32 _templateName) external view returns(uint256, uint256, uint256, uint256, uint256, State) {

        _checkSchedule(_beneficiary, _templateName);
        uint256 index = userToTemplateIndex[_beneficiary][_templateName];
        Schedule memory schedule = schedules[_beneficiary][index];
        return (
            templates[schedule.templateName].numberOfTokens,
            templates[schedule.templateName].duration,
            templates[schedule.templateName].frequency,
            schedule.startTime,
            schedule.claimedTokens,
            _getScheduleState(_beneficiary, _templateName)
        );
    }

    function _getScheduleState(address _beneficiary, bytes32 _templateName) internal view returns(State) {

        _checkSchedule(_beneficiary, _templateName);
        uint256 index = userToTemplateIndex[_beneficiary][_templateName];
        Schedule memory schedule = schedules[_beneficiary][index];
        if (now < schedule.startTime) {
            return State.CREATED;
        } else if (now > schedule.startTime && now < schedule.startTime.add(templates[_templateName].duration)) {
            return State.STARTED;
        } else {
            return State.COMPLETED;
        }
    }

    function getTemplateNames(address _beneficiary) external view returns(bytes32[] memory) {

        require(_beneficiary != address(0), "Invalid address");
        return userToTemplates[_beneficiary];
    }

    function getScheduleCount(address _beneficiary) external view returns(uint256) {

        require(_beneficiary != address(0), "Invalid address");
        return schedules[_beneficiary].length;
    }

    function _getAvailableTokens(address _beneficiary, uint256 _index) internal view returns(uint256) {

        Schedule memory schedule = schedules[_beneficiary][_index];
        uint256 releasedTokens = _getReleasedTokens(_beneficiary, _index);
        return releasedTokens.sub(schedule.claimedTokens);
    }

    function _getReleasedTokens(address _beneficiary, uint256 _index) internal view returns(uint256) {

        Schedule memory schedule = schedules[_beneficiary][_index];
        Template memory template = templates[schedule.templateName];
        if (now > schedule.startTime) {
            uint256 periodCount = template.duration.div(template.frequency);
            uint256 periodNumber = (now.sub(schedule.startTime)).div(template.frequency);
            if (periodNumber > periodCount) {
                periodNumber = periodCount;
            }
            return template.numberOfTokens.mul(periodNumber).div(periodCount);
        } else {
            return 0;
        }
    }

    function pushAvailableTokensMulti(uint256 _fromIndex, uint256 _toIndex) public withPerm(OPERATOR) {

        require(_toIndex < beneficiaries.length, "Array out of bound");
        for (uint256 i = _fromIndex; i <= _toIndex; i++) {
            if (schedules[beneficiaries[i]].length !=0)
                pushAvailableTokens(beneficiaries[i]);
        }
    }

    function addScheduleMulti(
        address[] memory _beneficiaries,
        bytes32[] memory _templateNames,
        uint256[] memory _numberOfTokens,
        uint256[] memory _durations,
        uint256[] memory _frequencies,
        uint256[] memory _startTimes
    )
        public
        withPerm(ADMIN)
    {

        require(
            _beneficiaries.length == _templateNames.length && /*solium-disable-line operator-whitespace*/
            _beneficiaries.length == _numberOfTokens.length && /*solium-disable-line operator-whitespace*/
            _beneficiaries.length == _durations.length && /*solium-disable-line operator-whitespace*/
            _beneficiaries.length == _frequencies.length && /*solium-disable-line operator-whitespace*/
            _beneficiaries.length == _startTimes.length,
            "Arrays sizes mismatch"
        );
        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            _addSchedule(_beneficiaries[i], _templateNames[i], _numberOfTokens[i], _durations[i], _frequencies[i], _startTimes[i]);
        }
    }

    function addScheduleFromTemplateMulti(
        address[] memory _beneficiaries,
        bytes32[] memory _templateNames,
        uint256[] memory _startTimes
    )
        public
        withPerm(ADMIN)
    {

        require(_beneficiaries.length == _templateNames.length && _beneficiaries.length == _startTimes.length, "Arrays sizes mismatch");
        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            _addScheduleFromTemplate(_beneficiaries[i], _templateNames[i], _startTimes[i]);
        }
    }

    function revokeSchedulesMulti(address[] memory _beneficiaries) public withPerm(ADMIN) {

        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            _revokeAllSchedules(_beneficiaries[i]);
        }
    }

    function modifyScheduleMulti(
        address[] memory _beneficiaries,
        bytes32[] memory _templateNames,
        uint256[] memory _startTimes
    )
        public
        withPerm(ADMIN)
    {

        require(
            _beneficiaries.length == _templateNames.length && /*solium-disable-line operator-whitespace*/
            _beneficiaries.length == _startTimes.length,
            "Arrays sizes mismatch"
        );
        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            _modifySchedule(_beneficiaries[i], _templateNames[i], _startTimes[i]);
        }
    }

    function _checkSchedule(address _beneficiary, bytes32 _templateName) internal view {

        require(_beneficiary != address(0), "Invalid address");
        uint256 index = userToTemplateIndex[_beneficiary][_templateName];
        require(
            index < schedules[_beneficiary].length &&
            schedules[_beneficiary][index].templateName == _templateName,
            "Schedule not found"
        );
    }

    function _isTemplateExists(bytes32 _name) internal view returns(bool) {

        return templates[_name].numberOfTokens > 0;
    }

    function _validateTemplate(uint256 _numberOfTokens, uint256 _duration, uint256 _frequency) internal view {

        require(_numberOfTokens > 0, "Zero amount");
        require(_duration % _frequency == 0, "Invalid frequency");
        uint256 periodCount = _duration.div(_frequency);
        require(_numberOfTokens % periodCount == 0);
        uint256 amountPerPeriod = _numberOfTokens.div(periodCount);
        require(amountPerPeriod % securityToken.granularity() == 0, "Invalid granularity");
    }

    function _sendTokens(address _beneficiary) internal {

        for (uint256 i = 0; i < schedules[_beneficiary].length; i++) {
            _sendTokensPerSchedule(_beneficiary, i);
        }
    }

    function _sendTokensPerSchedule(address _beneficiary, uint256 _index) internal {

        uint256 amount = _getAvailableTokens(_beneficiary, _index);
        if (amount > 0) {
            schedules[_beneficiary][_index].claimedTokens = schedules[_beneficiary][_index].claimedTokens.add(amount);
            require(securityToken.transfer(_beneficiary, amount), "Transfer failed");
            emit SendTokens(_beneficiary, amount);
        }
    }

    function getPermissions() public view returns(bytes32[] memory) {

        bytes32[] memory allPermissions = new bytes32[](2);
        allPermissions[0] = ADMIN;
        allPermissions[1] = OPERATOR;
        return allPermissions;
    }

}