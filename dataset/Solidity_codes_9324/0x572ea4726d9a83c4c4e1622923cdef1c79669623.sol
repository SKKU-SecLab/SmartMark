
pragma solidity 0.5.8;

interface ICheckpoint {


}

contract DividendCheckpointStorage {


    address payable public wallet;
    uint256 public EXCLUDED_ADDRESS_LIMIT = 150;

    struct Dividend {
        uint256 checkpointId;
        uint256 created; // Time at which the dividend was created
        uint256 maturity; // Time after which dividend can be claimed - set to 0 to bypass
        uint256 expiry;  // Time until which dividend can be claimed - after this time any remaining amount can be withdrawn by issuer -
        uint256 amount; // Dividend amount in WEI
        uint256 claimedAmount; // Amount of dividend claimed so far
        uint256 totalSupply; // Total supply at the associated checkpoint (avoids recalculating this)
        bool reclaimed;  // True if expiry has passed and issuer has reclaimed remaining dividend
        uint256 totalWithheld;
        uint256 totalWithheldWithdrawn;
        mapping (address => bool) claimed; // List of addresses which have claimed dividend
        mapping (address => bool) dividendExcluded; // List of addresses which cannot claim dividends
        mapping (address => uint256) withheld; // Amount of tax withheld from claim
        bytes32 name; // Name/title - used for identification
    }

    Dividend[] public dividends;

    address[] public excluded;

    mapping (address => uint256) public withholdingTax;

    mapping(address => uint256) public investorWithheld;

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









contract DividendCheckpoint is DividendCheckpointStorage, ICheckpoint, Module {

    using SafeMath for uint256;
    uint256 internal constant e18 = uint256(10) ** uint256(18);

    event SetDefaultExcludedAddresses(address[] _excluded);
    event SetWithholding(address[] _investors, uint256[] _withholding);
    event SetWithholdingFixed(address[] _investors, uint256 _withholding);
    event SetWallet(address indexed _oldWallet, address indexed _newWallet);
    event UpdateDividendDates(uint256 indexed _dividendIndex, uint256 _maturity, uint256 _expiry);

    function _validDividendIndex(uint256 _dividendIndex) internal view {

        require(_dividendIndex < dividends.length, "Invalid dividend");
        require(!dividends[_dividendIndex].reclaimed, "Dividend reclaimed");
        require(now >= dividends[_dividendIndex].maturity, "Dividend maturity in future");
        require(now < dividends[_dividendIndex].expiry, "Dividend expiry in past");
    }

    function configure(
        address payable _wallet
    ) public onlyFactory {

        _setWallet(_wallet);
    }

    function getInitFunction() public pure returns(bytes4) {

        return this.configure.selector;
    }

    function changeWallet(address payable _wallet) external {

        _onlySecurityTokenOwner();
        _setWallet(_wallet);
    }

    function _setWallet(address payable _wallet) internal {

        emit SetWallet(wallet, _wallet);
        wallet = _wallet;
    }

    function getDefaultExcluded() external view returns(address[] memory) {

        return excluded;
    }

    function getTreasuryWallet() public view returns(address payable) {

        if (wallet == address(0)) {
            address payable treasuryWallet = address(uint160(IDataStore(getDataStore()).getAddress(TREASURY)));
            require(address(treasuryWallet) != address(0), "Invalid address");
            return treasuryWallet;
        }
        else
            return wallet;
    }

    function createCheckpoint() public withPerm(OPERATOR) returns(uint256) {

        return securityToken.createCheckpoint();
    }

    function setDefaultExcluded(address[] memory _excluded) public withPerm(ADMIN) {

        require(_excluded.length <= EXCLUDED_ADDRESS_LIMIT, "Too many excluded addresses");
        for (uint256 j = 0; j < _excluded.length; j++) {
            require(_excluded[j] != address(0), "Invalid address");
            for (uint256 i = j + 1; i < _excluded.length; i++) {
                require(_excluded[j] != _excluded[i], "Duplicate exclude address");
            }
        }
        excluded = _excluded;
        emit SetDefaultExcludedAddresses(excluded);
    }

    function setWithholding(address[] memory _investors, uint256[] memory _withholding) public withPerm(ADMIN) {

        require(_investors.length == _withholding.length, "Mismatched input lengths");
        emit SetWithholding(_investors, _withholding);
        for (uint256 i = 0; i < _investors.length; i++) {
            require(_withholding[i] <= e18, "Incorrect withholding tax");
            withholdingTax[_investors[i]] = _withholding[i];
        }
    }

    function setWithholdingFixed(address[] memory _investors, uint256 _withholding) public withPerm(ADMIN) {

        require(_withholding <= e18, "Incorrect withholding tax");
        emit SetWithholdingFixed(_investors, _withholding);
        for (uint256 i = 0; i < _investors.length; i++) {
            withholdingTax[_investors[i]] = _withholding;
        }
    }

    function pushDividendPaymentToAddresses(
        uint256 _dividendIndex,
        address payable[] memory _payees
    )
        public
        withPerm(OPERATOR)
    {

        _validDividendIndex(_dividendIndex);
        Dividend storage dividend = dividends[_dividendIndex];
        for (uint256 i = 0; i < _payees.length; i++) {
            if ((!dividend.claimed[_payees[i]]) && (!dividend.dividendExcluded[_payees[i]])) {
                _payDividend(_payees[i], dividend, _dividendIndex);
            }
        }
    }

    function pushDividendPayment(
        uint256 _dividendIndex,
        uint256 _start,
        uint256 _end
    )
        public
        withPerm(OPERATOR)
    {

        _validDividendIndex(_dividendIndex);
        Dividend storage dividend = dividends[_dividendIndex];
        uint256 checkpointId = dividend.checkpointId;
        address[] memory investors = securityToken.getInvestorsSubsetAt(checkpointId, _start, _end);
        for (uint256 i = 0; i < investors.length; i++) {
            address payable payee = address(uint160(investors[i]));
            if ((!dividend.claimed[payee]) && (!dividend.dividendExcluded[payee])) {
                _payDividend(payee, dividend, _dividendIndex);
            }
        }
    }

    function pullDividendPayment(uint256 _dividendIndex) public whenNotPaused {

        _validDividendIndex(_dividendIndex);
        Dividend storage dividend = dividends[_dividendIndex];
        require(!dividend.claimed[msg.sender], "Dividend already claimed");
        require(!dividend.dividendExcluded[msg.sender], "msg.sender excluded from Dividend");
        _payDividend(msg.sender, dividend, _dividendIndex);
    }

    function _payDividend(address payable _payee, Dividend storage _dividend, uint256 _dividendIndex) internal;


    function reclaimDividend(uint256 _dividendIndex) external;


    function calculateDividend(uint256 _dividendIndex, address _payee) public view returns(uint256, uint256) {

        require(_dividendIndex < dividends.length, "Invalid dividend");
        Dividend storage dividend = dividends[_dividendIndex];
        if (dividend.claimed[_payee] || dividend.dividendExcluded[_payee]) {
            return (0, 0);
        }
        uint256 balance = securityToken.balanceOfAt(_payee, dividend.checkpointId);
        uint256 claim = balance.mul(dividend.amount).div(dividend.totalSupply);
        uint256 withheld = claim.mul(withholdingTax[_payee]).div(e18);
        return (claim, withheld);
    }

    function getDividendIndex(uint256 _checkpointId) public view returns(uint256[] memory) {

        uint256 counter = 0;
        for (uint256 i = 0; i < dividends.length; i++) {
            if (dividends[i].checkpointId == _checkpointId) {
                counter++;
            }
        }

        uint256[] memory index = new uint256[](counter);
        counter = 0;
        for (uint256 j = 0; j < dividends.length; j++) {
            if (dividends[j].checkpointId == _checkpointId) {
                index[counter] = j;
                counter++;
            }
        }
        return index;
    }

    function withdrawWithholding(uint256 _dividendIndex) external;


    function updateDividendDates(uint256 _dividendIndex, uint256 _maturity, uint256 _expiry) external withPerm(ADMIN) {

        require(_dividendIndex < dividends.length, "Invalid dividend");
        require(_expiry > _maturity, "Expiry before maturity");
        Dividend storage dividend = dividends[_dividendIndex];
        require(dividend.expiry > now, "Dividend already expired");
        dividend.expiry = _expiry;
        dividend.maturity = _maturity;
        emit UpdateDividendDates(_dividendIndex, _maturity, _expiry);
    }

    function getDividendsData() external view returns (
        uint256[] memory createds,
        uint256[] memory maturitys,
        uint256[] memory expirys,
        uint256[] memory amounts,
        uint256[] memory claimedAmounts,
        bytes32[] memory names)
    {

        createds = new uint256[](dividends.length);
        maturitys = new uint256[](dividends.length);
        expirys = new uint256[](dividends.length);
        amounts = new uint256[](dividends.length);
        claimedAmounts = new uint256[](dividends.length);
        names = new bytes32[](dividends.length);
        for (uint256 i = 0; i < dividends.length; i++) {
            (createds[i], maturitys[i], expirys[i], amounts[i], claimedAmounts[i], names[i]) = getDividendData(i);
        }
    }

    function getDividendData(uint256 _dividendIndex) public view returns (
        uint256 created,
        uint256 maturity,
        uint256 expiry,
        uint256 amount,
        uint256 claimedAmount,
        bytes32 name)
    {

        created = dividends[_dividendIndex].created;
        maturity = dividends[_dividendIndex].maturity;
        expiry = dividends[_dividendIndex].expiry;
        amount = dividends[_dividendIndex].amount;
        claimedAmount = dividends[_dividendIndex].claimedAmount;
        name = dividends[_dividendIndex].name;
    }

    function getDividendProgress(uint256 _dividendIndex) external view returns (
        address[] memory investors,
        bool[] memory resultClaimed,
        bool[] memory resultExcluded,
        uint256[] memory resultWithheld,
        uint256[] memory resultAmount,
        uint256[] memory resultBalance)
    {

        require(_dividendIndex < dividends.length, "Invalid dividend");
        Dividend storage dividend = dividends[_dividendIndex];
        uint256 checkpointId = dividend.checkpointId;
        investors = securityToken.getInvestorsAt(checkpointId);
        resultClaimed = new bool[](investors.length);
        resultExcluded = new bool[](investors.length);
        resultWithheld = new uint256[](investors.length);
        resultAmount = new uint256[](investors.length);
        resultBalance = new uint256[](investors.length);
        for (uint256 i; i < investors.length; i++) {
            resultClaimed[i] = dividend.claimed[investors[i]];
            resultExcluded[i] = dividend.dividendExcluded[investors[i]];
            resultBalance[i] = securityToken.balanceOfAt(investors[i], dividend.checkpointId);
            if (!resultExcluded[i]) {
                if (resultClaimed[i]) {
                    resultWithheld[i] = dividend.withheld[investors[i]];
                    resultAmount[i] = resultBalance[i].mul(dividend.amount).div(dividend.totalSupply).sub(resultWithheld[i]);
                } else {
                    (uint256 claim, uint256 withheld) = calculateDividend(_dividendIndex, investors[i]);
                    resultWithheld[i] = withheld;
                    resultAmount[i] = claim.sub(withheld);
                }
            }
        }
    }

    function getCheckpointData(uint256 _checkpointId) external view returns (address[] memory investors, uint256[] memory balances, uint256[] memory withholdings) {

        require(_checkpointId <= securityToken.currentCheckpointId(), "Invalid checkpoint");
        investors = securityToken.getInvestorsAt(_checkpointId);
        balances = new uint256[](investors.length);
        withholdings = new uint256[](investors.length);
        for (uint256 i; i < investors.length; i++) {
            balances[i] = securityToken.balanceOfAt(investors[i], _checkpointId);
            withholdings[i] = withholdingTax[investors[i]];
        }
    }

    function isExcluded(address _investor, uint256 _dividendIndex) external view returns (bool) {

        require(_dividendIndex < dividends.length, "Invalid dividend");
        return dividends[_dividendIndex].dividendExcluded[_investor];
    }

    function isClaimed(address _investor, uint256 _dividendIndex) external view returns (bool) {

        require(_dividendIndex < dividends.length, "Invalid dividend");
        return dividends[_dividendIndex].claimed[_investor];
    }

    function getPermissions() public view returns(bytes32[] memory) {

        bytes32[] memory allPermissions = new bytes32[](2);
        allPermissions[0] = ADMIN;
        allPermissions[1] = OPERATOR;
        return allPermissions;
    }

}

interface IOwnable {

    function owner() external view returns(address ownerAddress);


    function renounceOwnership() external;


    function transferOwnership(address _newOwner) external;


}

contract EtherDividendCheckpoint is DividendCheckpoint {

    using SafeMath for uint256;

    event EtherDividendDeposited(
        address indexed _depositor,
        uint256 _checkpointId,
        uint256 _maturity,
        uint256 _expiry,
        uint256 _amount,
        uint256 _totalSupply,
        uint256 indexed _dividendIndex,
        bytes32 indexed _name
    );
    event EtherDividendClaimed(address indexed _payee, uint256 indexed _dividendIndex, uint256 _amount, uint256 _withheld);
    event EtherDividendReclaimed(address indexed _claimer, uint256 indexed _dividendIndex, uint256 _claimedAmount);
    event EtherDividendClaimFailed(address indexed _payee, uint256 indexed _dividendIndex, uint256 _amount, uint256 _withheld);
    event EtherDividendWithholdingWithdrawn(address indexed _claimer, uint256 indexed _dividendIndex, uint256 _withheldAmount);

    constructor(address _securityToken, address _polyToken) public Module(_securityToken, _polyToken) {

    }

    function createDividend(uint256 _maturity, uint256 _expiry, bytes32 _name) external payable withPerm(ADMIN) {

        createDividendWithExclusions(_maturity, _expiry, excluded, _name);
    }

    function createDividendWithCheckpoint(
        uint256 _maturity,
        uint256 _expiry,
        uint256 _checkpointId,
        bytes32 _name
    )
        external
        payable
        withPerm(ADMIN)
    {

        _createDividendWithCheckpointAndExclusions(_maturity, _expiry, _checkpointId, excluded, _name);
    }

    function createDividendWithExclusions(
        uint256 _maturity,
        uint256 _expiry,
        address[] memory _excluded,
        bytes32 _name
    )
        public
        payable
        withPerm(ADMIN)
    {

        uint256 checkpointId = securityToken.createCheckpoint();
        _createDividendWithCheckpointAndExclusions(_maturity, _expiry, checkpointId, _excluded, _name);
    }

    function createDividendWithCheckpointAndExclusions(
        uint256 _maturity,
        uint256 _expiry,
        uint256 _checkpointId,
        address[] memory _excluded,
        bytes32 _name
    )
        public
        payable
        withPerm(ADMIN)
    {

        _createDividendWithCheckpointAndExclusions(_maturity, _expiry, _checkpointId, _excluded, _name);
    }

    function _createDividendWithCheckpointAndExclusions(
        uint256 _maturity,
        uint256 _expiry,
        uint256 _checkpointId,
        address[] memory _excluded,
        bytes32 _name
    )
        internal
    {

        require(_excluded.length <= EXCLUDED_ADDRESS_LIMIT, "Too many addresses excluded");
        require(_expiry > _maturity, "Expiry is before maturity");
        require(_expiry > now, "Expiry is in the past");
        require(msg.value > 0, "No dividend sent");
        require(_checkpointId <= securityToken.currentCheckpointId());
        require(_name[0] != bytes32(0));
        uint256 dividendIndex = dividends.length;
        uint256 currentSupply = securityToken.totalSupplyAt(_checkpointId);
        require(currentSupply > 0, "Invalid supply");
        uint256 excludedSupply = 0;
        dividends.push(
            Dividend(
                _checkpointId,
                now, /*solium-disable-line security/no-block-members*/
                _maturity,
                _expiry,
                msg.value,
                0,
                0,
                false,
                0,
                0,
                _name
            )
        );

        for (uint256 j = 0; j < _excluded.length; j++) {
            require(_excluded[j] != address(0), "Invalid address");
            require(!dividends[dividendIndex].dividendExcluded[_excluded[j]], "duped exclude address");
            excludedSupply = excludedSupply.add(securityToken.balanceOfAt(_excluded[j], _checkpointId));
            dividends[dividendIndex].dividendExcluded[_excluded[j]] = true;
        }
        require(currentSupply > excludedSupply, "Invalid supply");
        dividends[dividendIndex].totalSupply = currentSupply - excludedSupply;
        emit EtherDividendDeposited(msg.sender, _checkpointId, _maturity, _expiry, msg.value, currentSupply, dividendIndex, _name);
    }

    function _payDividend(address payable _payee, Dividend storage _dividend, uint256 _dividendIndex) internal {

        (uint256 claim, uint256 withheld) = calculateDividend(_dividendIndex, _payee);
        _dividend.claimed[_payee] = true;
        uint256 claimAfterWithheld = claim.sub(withheld);
        if (_payee.send(claimAfterWithheld)) {
            _dividend.claimedAmount = _dividend.claimedAmount.add(claim);
            if (withheld > 0) {
                _dividend.totalWithheld = _dividend.totalWithheld.add(withheld);
                _dividend.withheld[_payee] = withheld;
            }
            emit EtherDividendClaimed(_payee, _dividendIndex, claim, withheld);
        } else {
            _dividend.claimed[_payee] = false;
            emit EtherDividendClaimFailed(_payee, _dividendIndex, claim, withheld);
        }
    }

    function reclaimDividend(uint256 _dividendIndex) external withPerm(OPERATOR) {

        require(_dividendIndex < dividends.length, "Incorrect dividend index");
        require(now >= dividends[_dividendIndex].expiry, "Dividend expiry is in the future");
        require(!dividends[_dividendIndex].reclaimed, "Dividend is already claimed");
        Dividend storage dividend = dividends[_dividendIndex];
        dividend.reclaimed = true;
        uint256 remainingAmount = dividend.amount.sub(dividend.claimedAmount);
        address payable wallet = getTreasuryWallet();
        wallet.transfer(remainingAmount);
        emit EtherDividendReclaimed(wallet, _dividendIndex, remainingAmount);
    }

    function withdrawWithholding(uint256 _dividendIndex) external withPerm(OPERATOR) {

        require(_dividendIndex < dividends.length, "Incorrect dividend index");
        Dividend storage dividend = dividends[_dividendIndex];
        uint256 remainingWithheld = dividend.totalWithheld.sub(dividend.totalWithheldWithdrawn);
        dividend.totalWithheldWithdrawn = dividend.totalWithheld;
        address payable wallet = getTreasuryWallet();
        wallet.transfer(remainingWithheld);
        emit EtherDividendWithholdingWithdrawn(wallet, _dividendIndex, remainingWithheld);
    }

}