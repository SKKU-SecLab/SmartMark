


pragma solidity 0.5.8;

interface IModule {

    function getInitFunction() external pure returns(bytes4 initFunction);


    function getPermissions() external view returns(bytes32[] memory permissions);


}


pragma solidity 0.5.8;

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


pragma solidity 0.5.8;

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


pragma solidity 0.5.8;

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


pragma solidity 0.5.8;

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


pragma solidity 0.5.8;

interface ICheckPermission {

    function checkPermission(address _delegate, address _module, bytes32 _perm) external view returns(bool hasPerm);

}


pragma solidity ^0.5.2;

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


pragma solidity 0.5.8;


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


pragma solidity ^0.5.2;

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


pragma solidity 0.5.8;










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


pragma solidity 0.5.8;

interface ITransferManager {

    enum Result {INVALID, NA, VALID, FORCE_VALID}

    function executeTransfer(address _from, address _to, uint256 _amount, bytes calldata _data) external returns(Result result);


    function verifyTransfer(address _from, address _to, uint256 _amount, bytes calldata _data) external view returns(Result result, bytes32 partition);


    function getTokensByPartition(bytes32 _partition, address _tokenHolder, uint256 _additionalBalance) external view returns(uint256 amount);


}


pragma solidity 0.5.8;



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


pragma solidity ^0.5.2;

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


pragma solidity 0.5.8;

contract ManualApprovalTransferManagerStorage {


    struct ManualApproval {
        address from;
        address to;
        uint256 initialAllowance;
        uint256 allowance;
        uint256 expiryTime;
        bytes32 description;
    }

    mapping (address => mapping (address => uint256)) public approvalIndex;

    ManualApproval[] public approvals;

}


pragma solidity 0.5.8;




contract ManualApprovalTransferManager is ManualApprovalTransferManagerStorage, TransferManager {

    using SafeMath for uint256;

    event AddManualApproval(
        address indexed _from,
        address indexed _to,
        uint256 _allowance,
        uint256 _expiryTime,
        bytes32 _description,
        address indexed _addedBy
    );

    event ModifyManualApproval(
        address indexed _from,
        address indexed _to,
        uint256 _expiryTime,
        uint256 _allowance,
        bytes32 _description,
        address indexed _editedBy
    );

    event RevokeManualApproval(
        address indexed _from,
        address indexed _to,
        address indexed _addedBy
    );

    constructor(address _securityToken, address _polyToken) public Module(_securityToken, _polyToken) {

    }

    function getInitFunction() public pure returns(bytes4) {

        return bytes4(0);
    }

    function executeTransfer(
        address _from,
        address _to,
        uint256 _amount,
        bytes calldata /* _data */
    )
        external
        onlySecurityToken
        returns(Result)
    {


        (Result success, bytes32 esc) = _verifyTransfer(_from, _to, _amount);
        if (esc != bytes32(0)) {
            uint256 index = approvalIndex[_from][_to] - 1;
            ManualApproval storage approval = approvals[index];
            approval.allowance = approval.allowance.sub(_amount);
        }
        return (success);
    }


    function verifyTransfer(
        address _from,
        address _to,
        uint256 _amount,
        bytes memory /* _data */
    )
        public
        view
        returns(Result, bytes32)
    {

        return _verifyTransfer(_from, _to, _amount);
    }

    function _verifyTransfer(
        address _from,
        address _to,
        uint256 _amount
    )
        internal
        view
        returns(Result, bytes32)
    {

        uint256 index = approvalIndex[_from][_to];
        if (!paused && index != 0) {
            index--; //Actual index is storedIndex - 1
            ManualApproval memory approval = approvals[index];
            if ((approval.expiryTime >= now) && (approval.allowance >= _amount)) {
                return (Result.VALID, bytes32(uint256(address(this)) << 96));
            }
        }
        return (Result.NA, bytes32(0));
    }


    function addManualApproval(
        address _from,
        address _to,
        uint256 _allowance,
        uint256 _expiryTime,
        bytes32 _description
    )
        external
        withPerm(ADMIN)
    {

        _addManualApproval(_from, _to, _allowance, _expiryTime, _description);
    }

    function _addManualApproval(address _from, address _to, uint256 _allowance, uint256 _expiryTime, bytes32 _description) internal {

        require(_expiryTime > now, "Invalid expiry time");
        require(_allowance > 0, "Invalid allowance");
        if (approvalIndex[_from][_to] != 0) {
            uint256 index = approvalIndex[_from][_to] - 1;
            require(approvals[index].expiryTime < now || approvals[index].allowance == 0, "Approval already exists");
            _revokeManualApproval(_from, _to);
        }
        approvals.push(ManualApproval(_from, _to, _allowance, _allowance, _expiryTime, _description));
        approvalIndex[_from][_to] = approvals.length;
        emit AddManualApproval(_from, _to, _allowance, _expiryTime, _description, msg.sender);
    }

    function addManualApprovalMulti(
        address[] memory _from,
        address[] memory _to,
        uint256[] memory _allowances,
        uint256[] memory _expiryTimes,
        bytes32[] memory _descriptions
    )
        public
        withPerm(ADMIN)
    {

        _checkInputLengthArray(_from, _to, _allowances, _expiryTimes, _descriptions);
        for (uint256 i = 0; i < _from.length; i++){
            _addManualApproval(_from[i], _to[i], _allowances[i], _expiryTimes[i], _descriptions[i]);
        }
    }

    function modifyManualApproval(
        address _from,
        address _to,
        uint256 _expiryTime,
        uint256 _changeInAllowance,
        bytes32 _description,
        bool _increase
    )
        external
        withPerm(ADMIN)
    {

        _modifyManualApproval(_from, _to, _expiryTime, _changeInAllowance, _description, _increase);
    }

    function _modifyManualApproval(
        address _from,
        address _to,
        uint256 _expiryTime,
        uint256 _changeInAllowance,
        bytes32 _description,
        bool _increase
    )
        internal
    {

        require(_expiryTime > now, "Invalid expiry time");
        uint256 index = approvalIndex[_from][_to];
        require(index != 0, "Approval not present");
        index--; //Index is stored in an incremented form. 0 represnts non existant.
        ManualApproval storage approval = approvals[index];
        uint256 allowance = approval.allowance;
        uint256 initialAllowance = approval.initialAllowance;
        uint256 expiryTime = approval.expiryTime;
        require(allowance != 0, "Approval has been exhausted");
        require(expiryTime > now, "Approval has expired");

        if (_changeInAllowance > 0) {
            if (_increase) {
                allowance = allowance.add(_changeInAllowance);
                initialAllowance = initialAllowance.add(_changeInAllowance);
            } else {
                if (_changeInAllowance >= allowance) {
                    if (_changeInAllowance >= initialAllowance) {
                        initialAllowance = 0;
                    }
                    else {
                        initialAllowance = initialAllowance.sub(allowance);
                    }
                    allowance = 0;
                } else {
                    allowance = allowance.sub(_changeInAllowance);
                    initialAllowance = initialAllowance.sub(_changeInAllowance);
                }
            }
            approval.allowance = allowance;
            approval.initialAllowance = initialAllowance;
        }
        if (expiryTime != _expiryTime) {
            approval.expiryTime = _expiryTime;
        }
        if (approval.description != _description) {
            approval.description = _description;
        }
        emit ModifyManualApproval(_from, _to, _expiryTime, allowance, _description, msg.sender);
    }

    function modifyManualApprovalMulti(
        address[] memory _from,
        address[] memory _to,
        uint256[] memory _expiryTimes,
        uint256[] memory _changeInAllowance,
        bytes32[] memory _descriptions,
        bool[] memory _increase
    )
        public
        withPerm(ADMIN)
    {

        _checkInputLengthArray(_from, _to, _changeInAllowance, _expiryTimes, _descriptions);
        require(_increase.length == _changeInAllowance.length, "Input array length mismatch");
        for (uint256 i = 0; i < _from.length; i++) {
            _modifyManualApproval(_from[i], _to[i], _expiryTimes[i], _changeInAllowance[i], _descriptions[i], _increase[i]);
        }
    }

    function revokeManualApproval(address _from, address _to) external withPerm(ADMIN) {

        _revokeManualApproval(_from, _to);
    }

    function _revokeManualApproval(address _from, address _to) internal {

        uint256 index = approvalIndex[_from][_to];
        require(index != 0, "Approval not exist");

        index--; //Index is stored after incrementation so that 0 represents non existant index
        uint256 lastApprovalIndex = approvals.length - 1;
        if (index != lastApprovalIndex) {
            approvals[index] = approvals[lastApprovalIndex];
            approvalIndex[approvals[index].from][approvals[index].to] = index + 1;
        }
        delete approvalIndex[_from][_to];
        approvals.length--;
        emit RevokeManualApproval(_from, _to, msg.sender);
    }

    function revokeManualApprovalMulti(address[] calldata _from, address[] calldata _to) external withPerm(ADMIN) {

        require(_from.length == _to.length, "Input array length mismatch");
        for(uint256 i = 0; i < _from.length; i++){
            _revokeManualApproval(_from[i], _to[i]);
        }
    }

    function _checkInputLengthArray(
        address[] memory _from,
        address[] memory _to,
        uint256[] memory _expiryTimes,
        uint256[] memory _allowances,
        bytes32[] memory _descriptions
    )
        internal
        pure
    {

        require(_from.length == _to.length &&
        _to.length == _allowances.length &&
        _allowances.length == _expiryTimes.length &&
        _expiryTimes.length == _descriptions.length,
        "Input array length mismatch"
        );
    }

    function getActiveApprovalsToUser(address _user) external view returns(address[] memory, address[] memory, uint256[] memory, uint256[] memory, uint256[] memory, bytes32[] memory) {

        uint256 counter = 0;
        uint256 approvalsLength = approvals.length;
        for (uint256 i = 0; i < approvalsLength; i++) {
            if ((approvals[i].from == _user || approvals[i].to == _user)
                && approvals[i].expiryTime >= now)
                counter ++;
        }

        address[] memory from = new address[](counter);
        address[] memory to = new address[](counter);
        uint256[] memory initialAllowance = new uint256[](counter);
        uint256[] memory allowance = new uint256[](counter);
        uint256[] memory expiryTime = new uint256[](counter);
        bytes32[] memory description = new bytes32[](counter);

        counter = 0;
        for (uint256 i = 0; i < approvalsLength; i++) {
            if ((approvals[i].from == _user || approvals[i].to == _user)
                && approvals[i].expiryTime >= now) {

                from[counter]=approvals[i].from;
                to[counter]=approvals[i].to;
                initialAllowance[counter]=approvals[i].initialAllowance;
                allowance[counter]=approvals[i].allowance;
                expiryTime[counter]=approvals[i].expiryTime;
                description[counter]=approvals[i].description;
                counter ++;
            }
        }
        return (from, to, initialAllowance, allowance, expiryTime, description);
    }

    function getApprovalDetails(address _from, address _to) external view returns(uint256, uint256, uint256, bytes32) {

        uint256 index = approvalIndex[_from][_to];
        if (index != 0) {
            index--;
            assert(index < approvals.length);
            ManualApproval storage approval = approvals[index];
            return(
                approval.expiryTime,
                approval.initialAllowance,
                approval.allowance,
                approval.description
            );
        }
        return (uint256(0), uint256(0), uint256(0), bytes32(0));
    }

    function getTotalApprovalsLength() external view returns(uint256) {

        return approvals.length;
    }

    function getAllApprovals() external view returns(address[] memory, address[] memory, uint256[] memory, uint256[] memory, uint256[] memory, bytes32[] memory) {

        uint256 approvalsLength = approvals.length;
        address[] memory from = new address[](approvalsLength);
        address[] memory to = new address[](approvalsLength);
        uint256[] memory initialAllowance = new uint256[](approvalsLength);
        uint256[] memory allowance = new uint256[](approvalsLength);
        uint256[] memory expiryTime = new uint256[](approvalsLength);
        bytes32[] memory description = new bytes32[](approvalsLength);

        for (uint256 i = 0; i < approvalsLength; i++) {

            from[i]=approvals[i].from;
            to[i]=approvals[i].to;
            initialAllowance[i]=approvals[i].initialAllowance;
            allowance[i]=approvals[i].allowance;
            expiryTime[i]=approvals[i].expiryTime;
            description[i]=approvals[i].description;

        }

        return (from, to, initialAllowance, allowance, expiryTime, description);

    }

    function getPermissions() public view returns(bytes32[] memory) {

        bytes32[] memory allPermissions = new bytes32[](1);
        allPermissions[0] = ADMIN;
        return allPermissions;
    }
}