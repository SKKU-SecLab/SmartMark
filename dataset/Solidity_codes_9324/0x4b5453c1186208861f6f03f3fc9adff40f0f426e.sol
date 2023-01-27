
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


contract STOStorage {

    bytes32 internal constant INVESTORFLAGS = "INVESTORFLAGS";

    mapping (uint8 => bool) public fundRaiseTypes;
    mapping (uint8 => uint256) public fundsRaised;

    uint256 public startTime;
    uint256 public endTime;
    uint256 public pausedTime;
    uint256 public investorCount;
    address payable public wallet;
    uint256 public totalTokensSold;

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

interface ISTO {


    enum FundRaiseType {ETH, POLY, SC}

    event SetFundRaiseTypes(FundRaiseType[] _fundRaiseTypes);

    function getTokensSold() external view returns(uint256 soldTokens);


    function getRaised(FundRaiseType _fundRaiseType) external view returns(uint256 raisedAmount);


    function pause() external;


}

contract STO is ISTO, STOStorage, Module {

    using SafeMath for uint256;

    function getRaised(FundRaiseType _fundRaiseType) public view returns(uint256) {

        return fundsRaised[uint8(_fundRaiseType)];
    }

    function getTokensSold() external view returns (uint256);


    function pause() public {

        require(now < endTime, "STO has been finalized");
        super.pause();
    }

    function _setFundRaiseType(FundRaiseType[] memory _fundRaiseTypes) internal {

        require(_fundRaiseTypes.length > 0 && _fundRaiseTypes.length <= 3, "Raise type is not specified");
        fundRaiseTypes[uint8(FundRaiseType.ETH)] = false;
        fundRaiseTypes[uint8(FundRaiseType.POLY)] = false;
        fundRaiseTypes[uint8(FundRaiseType.SC)] = false;
        for (uint8 j = 0; j < _fundRaiseTypes.length; j++) {
            fundRaiseTypes[uint8(_fundRaiseTypes[j])] = true;
        }
        emit SetFundRaiseTypes(_fundRaiseTypes);
    }

    function _canBuy(address _investor) internal view returns(bool) {

        IDataStore dataStore = getDataStore();
        uint256 flags = dataStore.getUint256(_getKey(INVESTORFLAGS, _investor));
        return(flags & (uint256(1) << 1) == 0);
    }

    function _getKey(bytes32 _key1, address _key2) internal pure returns(bytes32) {

        return bytes32(keccak256(abi.encodePacked(_key1, _key2)));
    }
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

contract USDTieredSTOStorage {


    bytes32 internal constant INVESTORSKEY = 0xdf3a8dd24acdd05addfc6aeffef7574d2de3f844535ec91e8e0f3e45dba96731; //keccak256(abi.encodePacked("INVESTORS"))
    
    struct Tier {
        uint256 rate;
        uint256 rateDiscountPoly;
        uint256 tokenTotal;
        uint256 tokensDiscountPoly;
        uint256 mintedTotal;
        mapping(uint8 => uint256) minted;
        uint256 mintedDiscountPoly;
    }

    mapping(address => uint256) public nonAccreditedLimitUSDOverride;

    mapping(bytes32 => mapping(bytes32 => string)) oracleKeys;

    bool public allowBeneficialInvestments;

    bool public isFinalized;

    address public treasuryWallet;

    IERC20[] internal usdTokens;

    uint256 public currentTier;

    uint256 public fundsRaisedUSD;

    mapping (address => uint256) public stableCoinsRaised;

    mapping(address => uint256) public investorInvestedUSD;

    mapping(address => mapping(uint8 => uint256)) public investorInvested;

    mapping (address => bool) internal usdTokenEnabled;

    uint256 public nonAccreditedLimitUSD;

    uint256 public minimumInvestmentUSD;

    uint256 public finalAmountReturned;

    Tier[] public tiers;

    mapping(bytes32 => mapping(bytes32 => address)) customOracles;
}

contract USDTieredSTO is USDTieredSTOStorage, STO {

    using SafeMath for uint256;

    string internal constant POLY_ORACLE = "PolyUsdOracle";
    string internal constant ETH_ORACLE = "EthUsdOracle";


    event SetAllowBeneficialInvestments(bool _allowed);
    event SetNonAccreditedLimit(address _investor, uint256 _limit);
    event TokenPurchase(
        address indexed _purchaser,
        address indexed _beneficiary,
        uint256 _tokens,
        uint256 _usdAmount,
        uint256 _tierPrice,
        uint256 _tier
    );
    event FundsReceived(
        address indexed _purchaser,
        address indexed _beneficiary,
        uint256 _usdAmount,
        FundRaiseType _fundRaiseType,
        uint256 _receivedValue,
        uint256 _spentValue,
        uint256 _rate
    );
    event ReserveTokenMint(address indexed _owner, address indexed _wallet, uint256 _tokens, uint256 _latestTier);
    event SetAddresses(address indexed _wallet, IERC20[] _usdTokens);
    event SetLimits(uint256 _nonAccreditedLimitUSD, uint256 _minimumInvestmentUSD);
    event SetTimes(uint256 _startTime, uint256 _endTime);
    event SetTiers(
        uint256[] _ratePerTier,
        uint256[] _ratePerTierDiscountPoly,
        uint256[] _tokensPerTierTotal,
        uint256[] _tokensPerTierDiscountPoly
    );
    event SetTreasuryWallet(address _oldWallet, address _newWallet);


    modifier validETH() {

        require(_getOracle(bytes32("ETH"), bytes32("USD")) != address(0), "Invalid Oracle");
        require(fundRaiseTypes[uint8(FundRaiseType.ETH)], "ETH not allowed");
        _;
    }

    modifier validPOLY() {

        require(_getOracle(bytes32("POLY"), bytes32("USD")) != address(0), "Invalid Oracle");
        require(fundRaiseTypes[uint8(FundRaiseType.POLY)], "POLY not allowed");
        _;
    }

    modifier validSC(address _usdToken) {

        require(fundRaiseTypes[uint8(FundRaiseType.SC)] && usdTokenEnabled[_usdToken], "USD not allowed");
        _;
    }


    constructor(address _securityToken, address _polyAddress) public Module(_securityToken, _polyAddress) {

    }

    function configure(
        uint256 _startTime,
        uint256 _endTime,
        uint256[] memory _ratePerTier,
        uint256[] memory _ratePerTierDiscountPoly,
        uint256[] memory _tokensPerTierTotal,
        uint256[] memory _tokensPerTierDiscountPoly,
        uint256 _nonAccreditedLimitUSD,
        uint256 _minimumInvestmentUSD,
        FundRaiseType[] memory _fundRaiseTypes,
        address payable _wallet,
        address _treasuryWallet,
        IERC20[] memory _usdTokens
    )
        public
        onlyFactory
    {

        oracleKeys[bytes32("ETH")][bytes32("USD")] = ETH_ORACLE;
        oracleKeys[bytes32("POLY")][bytes32("USD")] = POLY_ORACLE;
        require(endTime == 0, "Already configured");
        _modifyTimes(_startTime, _endTime);
        _modifyTiers(_ratePerTier, _ratePerTierDiscountPoly, _tokensPerTierTotal, _tokensPerTierDiscountPoly);
        _setFundRaiseType(_fundRaiseTypes);
        _modifyAddresses(_wallet, _treasuryWallet, _usdTokens);
        _modifyLimits(_nonAccreditedLimitUSD, _minimumInvestmentUSD);
    }

    function modifyFunding(FundRaiseType[] calldata _fundRaiseTypes) external withPerm(OPERATOR) {

        _isSTOStarted();
        _setFundRaiseType(_fundRaiseTypes);
    }

    function modifyLimits(uint256 _nonAccreditedLimitUSD, uint256 _minimumInvestmentUSD) external withPerm(OPERATOR) {

        _isSTOStarted();
        _modifyLimits(_nonAccreditedLimitUSD, _minimumInvestmentUSD);
    }

    function modifyTiers(
        uint256[] calldata _ratePerTier,
        uint256[] calldata _ratePerTierDiscountPoly,
        uint256[] calldata _tokensPerTierTotal,
        uint256[] calldata _tokensPerTierDiscountPoly
    )
        external
        withPerm(OPERATOR)
    {

        _isSTOStarted();
        _modifyTiers(_ratePerTier, _ratePerTierDiscountPoly, _tokensPerTierTotal, _tokensPerTierDiscountPoly);
    }

    function modifyTimes(uint256 _startTime, uint256 _endTime) external withPerm(OPERATOR) {

        _isSTOStarted();
        _modifyTimes(_startTime, _endTime);
    }

    function _isSTOStarted() internal view {

        require(now < startTime, "Already started");
    }

    function modifyAddresses(address payable _wallet, address _treasuryWallet, IERC20[] calldata _usdTokens) external {

        _onlySecurityTokenOwner();
        _modifyAddresses(_wallet, _treasuryWallet, _usdTokens);
    }

    function modifyOracle(FundRaiseType _fundRaiseType, address _oracleAddress) external {

        _onlySecurityTokenOwner();
        if (_fundRaiseType == FundRaiseType.ETH) {
            customOracles[bytes32("ETH")][bytes32("USD")] = _oracleAddress;
        } else {
            require(_fundRaiseType == FundRaiseType.POLY, "Invalid currency");
            customOracles[bytes32("POLY")][bytes32("USD")] = _oracleAddress;
        }
    }

    function _modifyLimits(uint256 _nonAccreditedLimitUSD, uint256 _minimumInvestmentUSD) internal {

        minimumInvestmentUSD = _minimumInvestmentUSD;
        nonAccreditedLimitUSD = _nonAccreditedLimitUSD;
        emit SetLimits(minimumInvestmentUSD, nonAccreditedLimitUSD);
    }

    function _modifyTiers(
        uint256[] memory _ratePerTier,
        uint256[] memory _ratePerTierDiscountPoly,
        uint256[] memory _tokensPerTierTotal,
        uint256[] memory _tokensPerTierDiscountPoly
    )
        internal
    {

        require(
            _tokensPerTierTotal.length > 0 &&
            _ratePerTier.length == _tokensPerTierTotal.length &&
            _ratePerTierDiscountPoly.length == _tokensPerTierTotal.length &&
            _tokensPerTierDiscountPoly.length == _tokensPerTierTotal.length,
            "Invalid Input"
        );
        delete tiers;
        for (uint256 i = 0; i < _ratePerTier.length; i++) {
            require(_ratePerTier[i] > 0 && _tokensPerTierTotal[i] > 0, "Invalid value");
            require(_tokensPerTierDiscountPoly[i] <= _tokensPerTierTotal[i], "Too many discounted tokens");
            require(_ratePerTierDiscountPoly[i] <= _ratePerTier[i], "Invalid discount");
            tiers.push(Tier(_ratePerTier[i], _ratePerTierDiscountPoly[i], _tokensPerTierTotal[i], _tokensPerTierDiscountPoly[i], 0, 0));
        }
        emit SetTiers(_ratePerTier, _ratePerTierDiscountPoly, _tokensPerTierTotal, _tokensPerTierDiscountPoly);
    }

    function _modifyTimes(uint256 _startTime, uint256 _endTime) internal {

        require((_endTime > _startTime) && (_startTime > now), "Invalid times");
        startTime = _startTime;
        endTime = _endTime;
        emit SetTimes(_startTime, _endTime);
    }

    function _modifyAddresses(address payable _wallet, address _treasuryWallet, IERC20[] memory _usdTokens) internal {

        require(_wallet != address(0), "Invalid wallet");
        wallet = _wallet;
        emit SetTreasuryWallet(treasuryWallet, _treasuryWallet);
        treasuryWallet = _treasuryWallet;
        _modifyUSDTokens(_usdTokens);
    }

    function _modifyUSDTokens(IERC20[] memory _usdTokens) internal {

        uint256 i;
        for(i = 0; i < usdTokens.length; i++) {
            usdTokenEnabled[address(usdTokens[i])] = false;
        }
        usdTokens = _usdTokens;
        for(i = 0; i < _usdTokens.length; i++) {
            require(address(_usdTokens[i]) != address(0) && _usdTokens[i] != polyToken, "Invalid USD token");
            usdTokenEnabled[address(_usdTokens[i])] = true;
        }
        emit SetAddresses(wallet, _usdTokens);
    }


    function finalize() external withPerm(ADMIN) {

        require(!isFinalized, "STO is finalized");
        isFinalized = true;
        uint256 tempReturned;
        uint256 tempSold;
        uint256 remainingTokens;
        for (uint256 i = 0; i < tiers.length; i++) {
            remainingTokens = tiers[i].tokenTotal.sub(tiers[i].mintedTotal);
            tempReturned = tempReturned.add(remainingTokens);
            tempSold = tempSold.add(tiers[i].mintedTotal);
            if (remainingTokens > 0) {
                tiers[i].mintedTotal = tiers[i].tokenTotal;
            }
        }
        address walletAddress = (treasuryWallet == address(0) ? IDataStore(getDataStore()).getAddress(TREASURY) : treasuryWallet);
        require(walletAddress != address(0), "Invalid address");
        uint256 granularity = securityToken.granularity();
        tempReturned = tempReturned.div(granularity);
        tempReturned = tempReturned.mul(granularity);
        securityToken.issue(walletAddress, tempReturned, "");
        emit ReserveTokenMint(msg.sender, walletAddress, tempReturned, currentTier);
        finalAmountReturned = tempReturned;
        totalTokensSold = tempSold;
    }

    function changeNonAccreditedLimit(address[] calldata _investors, uint256[] calldata _nonAccreditedLimit) external withPerm(OPERATOR) {

        require(_investors.length == _nonAccreditedLimit.length, "Length mismatch");
        for (uint256 i = 0; i < _investors.length; i++) {
            nonAccreditedLimitUSDOverride[_investors[i]] = _nonAccreditedLimit[i];
            emit SetNonAccreditedLimit(_investors[i], _nonAccreditedLimit[i]);
        }
    }

    function getAccreditedData() external view returns (address[] memory investors, bool[] memory accredited, uint256[] memory overrides) {

        IDataStore dataStore = getDataStore();
        investors = dataStore.getAddressArray(INVESTORSKEY);
        accredited = new bool[](investors.length);
        overrides = new uint256[](investors.length);
        for (uint256 i = 0; i < investors.length; i++) {
            accredited[i] = _getIsAccredited(investors[i], dataStore);
            overrides[i] = nonAccreditedLimitUSDOverride[investors[i]];
        }
    }

    function changeAllowBeneficialInvestments(bool _allowBeneficialInvestments) external withPerm(OPERATOR) {

        require(_allowBeneficialInvestments != allowBeneficialInvestments);
        allowBeneficialInvestments = _allowBeneficialInvestments;
        emit SetAllowBeneficialInvestments(allowBeneficialInvestments);
    }


    function() external payable {
        buyWithETHRateLimited(msg.sender, 0);
    }

    function buyWithETH(address _beneficiary) external payable returns (uint256, uint256, uint256) {

        return buyWithETHRateLimited(_beneficiary, 0);
    }

    function buyWithPOLY(address _beneficiary, uint256 _investedPOLY) external returns (uint256, uint256, uint256) {

        return buyWithPOLYRateLimited(_beneficiary, _investedPOLY, 0);
    }

    function buyWithUSD(address _beneficiary, uint256 _investedSC, IERC20 _usdToken) external returns (uint256, uint256, uint256) {

        return buyWithUSDRateLimited(_beneficiary, _investedSC, 0, _usdToken);
    }

    function buyWithETHRateLimited(address _beneficiary, uint256 _minTokens) public payable validETH returns (uint256, uint256, uint256) {

        (uint256 rate, uint256 spentUSD, uint256 spentValue, uint256 initialMinted) = _getSpentvalues(_beneficiary,  msg.value, FundRaiseType.ETH, _minTokens);
        investorInvested[_beneficiary][uint8(FundRaiseType.ETH)] = investorInvested[_beneficiary][uint8(FundRaiseType.ETH)].add(spentValue);
        fundsRaised[uint8(FundRaiseType.ETH)] = fundsRaised[uint8(FundRaiseType.ETH)].add(spentValue);
        wallet.transfer(spentValue);
        msg.sender.transfer(msg.value.sub(spentValue));
        emit FundsReceived(msg.sender, _beneficiary, spentUSD, FundRaiseType.ETH, msg.value, spentValue, rate);
        return (spentUSD, spentValue, getTokensMinted().sub(initialMinted));
    }

    function buyWithPOLYRateLimited(address _beneficiary, uint256 _investedPOLY, uint256 _minTokens) public validPOLY returns (uint256, uint256, uint256) {

        return _buyWithTokens(_beneficiary, _investedPOLY, FundRaiseType.POLY, _minTokens, polyToken);
    }

    function buyWithUSDRateLimited(address _beneficiary, uint256 _investedSC, uint256 _minTokens, IERC20 _usdToken)
        public validSC(address(_usdToken)) returns (uint256, uint256, uint256)
    {

        return _buyWithTokens(_beneficiary, _investedSC, FundRaiseType.SC, _minTokens, _usdToken);
    }

    function _buyWithTokens(address _beneficiary, uint256 _tokenAmount, FundRaiseType _fundRaiseType, uint256 _minTokens, IERC20 _token) internal returns (uint256, uint256, uint256) {

        (uint256 rate, uint256 spentUSD, uint256 spentValue, uint256 initialMinted) = _getSpentvalues(_beneficiary, _tokenAmount, _fundRaiseType, _minTokens);
        investorInvested[_beneficiary][uint8(_fundRaiseType)] = investorInvested[_beneficiary][uint8(_fundRaiseType)].add(spentValue);
        fundsRaised[uint8(_fundRaiseType)] = fundsRaised[uint8(_fundRaiseType)].add(spentValue);
        if(address(_token) != address(polyToken))
            stableCoinsRaised[address(_token)] = stableCoinsRaised[address(_token)].add(spentValue);
        require(_token.transferFrom(msg.sender, wallet, spentValue), "Transfer failed");
        emit FundsReceived(msg.sender, _beneficiary, spentUSD, _fundRaiseType, _tokenAmount, spentValue, rate);
        return (spentUSD, spentValue, getTokensMinted().sub(initialMinted));
    }

    function _getSpentvalues(address _beneficiary, uint256 _amount, FundRaiseType _fundRaiseType, uint256 _minTokens) internal returns(uint256 rate, uint256 spentUSD, uint256 spentValue, uint256 initialMinted) {

        initialMinted = getTokensMinted();
        rate = getRate(_fundRaiseType);
        (spentUSD, spentValue) = _buyTokens(_beneficiary, _amount, rate, _fundRaiseType);
        require(getTokensMinted().sub(initialMinted) >= _minTokens, "Insufficient minted");
    }


    function _buyTokens(
        address _beneficiary,
        uint256 _investmentValue,
        uint256 _rate,
        FundRaiseType _fundRaiseType
    )
        internal
        whenNotPaused
        returns(uint256 spentUSD, uint256 spentValue)
    {

        if (!allowBeneficialInvestments) {
            require(_beneficiary == msg.sender, "Beneficiary != funder");
        }

        require(_canBuy(_beneficiary), "Unauthorized");

        uint256 originalUSD = DecimalMath.mul(_rate, _investmentValue);
        uint256 allowedUSD = _buyTokensChecks(_beneficiary, _investmentValue, originalUSD);

        for (uint256 i = currentTier; i < tiers.length; i++) {
            bool gotoNextTier;
            uint256 tempSpentUSD;
            if (currentTier != i)
                currentTier = i;
            if (tiers[i].mintedTotal < tiers[i].tokenTotal) {
                (tempSpentUSD, gotoNextTier) = _calculateTier(_beneficiary, i, allowedUSD.sub(spentUSD), _fundRaiseType);
                spentUSD = spentUSD.add(tempSpentUSD);
                if (!gotoNextTier)
                    break;
            }
        }

        if (spentUSD > 0) {
            if (investorInvestedUSD[_beneficiary] == 0)
                investorCount = investorCount + 1;
            investorInvestedUSD[_beneficiary] = investorInvestedUSD[_beneficiary].add(spentUSD);
            fundsRaisedUSD = fundsRaisedUSD.add(spentUSD);
        }

        spentValue = DecimalMath.div(spentUSD, _rate);
    }

    function _buyTokensChecks(
        address _beneficiary,
        uint256 _investmentValue,
        uint256 investedUSD
    )
        internal
        view
        returns(uint256 netInvestedUSD)
    {

        require(isOpen(), "STO not open");
        require(_investmentValue > 0, "No funds sent");

        require(investedUSD.add(investorInvestedUSD[_beneficiary]) >= minimumInvestmentUSD, "Investment < min");
        netInvestedUSD = investedUSD;
        if (!_isAccredited(_beneficiary)) {
            uint256 investorLimitUSD = (nonAccreditedLimitUSDOverride[_beneficiary] == 0) ? nonAccreditedLimitUSD : nonAccreditedLimitUSDOverride[_beneficiary];
            require(investorInvestedUSD[_beneficiary] < investorLimitUSD, "Over Non-accredited investor limit");
            if (investedUSD.add(investorInvestedUSD[_beneficiary]) > investorLimitUSD)
                netInvestedUSD = investorLimitUSD.sub(investorInvestedUSD[_beneficiary]);
        }
    }

    function _calculateTier(
        address _beneficiary,
        uint256 _tier,
        uint256 _investedUSD,
        FundRaiseType _fundRaiseType
    )
        internal
        returns(uint256 spentUSD, bool gotoNextTier)
     {

        uint256 tierSpentUSD;
        uint256 tierPurchasedTokens;
        uint256 investedUSD = _investedUSD;
        Tier storage tierData = tiers[_tier];
        if ((_fundRaiseType == FundRaiseType.POLY) && (tierData.tokensDiscountPoly > tierData.mintedDiscountPoly)) {
            uint256 discountRemaining = tierData.tokensDiscountPoly.sub(tierData.mintedDiscountPoly);
            uint256 totalRemaining = tierData.tokenTotal.sub(tierData.mintedTotal);
            if (totalRemaining < discountRemaining)
                (spentUSD, tierPurchasedTokens, gotoNextTier) = _purchaseTier(_beneficiary, tierData.rateDiscountPoly, totalRemaining, investedUSD, _tier);
            else
                (spentUSD, tierPurchasedTokens, gotoNextTier) = _purchaseTier(_beneficiary, tierData.rateDiscountPoly, discountRemaining, investedUSD, _tier);
            investedUSD = investedUSD.sub(spentUSD);
            tierData.mintedDiscountPoly = tierData.mintedDiscountPoly.add(tierPurchasedTokens);
            tierData.minted[uint8(_fundRaiseType)] = tierData.minted[uint8(_fundRaiseType)].add(tierPurchasedTokens);
            tierData.mintedTotal = tierData.mintedTotal.add(tierPurchasedTokens);
        }
        if (investedUSD > 0 &&
            tierData.tokenTotal.sub(tierData.mintedTotal) > 0 &&
            (_fundRaiseType != FundRaiseType.POLY || tierData.tokensDiscountPoly <= tierData.mintedDiscountPoly)
        ) {
            (tierSpentUSD, tierPurchasedTokens, gotoNextTier) = _purchaseTier(_beneficiary, tierData.rate, tierData.tokenTotal.sub(tierData.mintedTotal), investedUSD, _tier);
            spentUSD = spentUSD.add(tierSpentUSD);
            tierData.minted[uint8(_fundRaiseType)] = tierData.minted[uint8(_fundRaiseType)].add(tierPurchasedTokens);
            tierData.mintedTotal = tierData.mintedTotal.add(tierPurchasedTokens);
        }
    }

    function _purchaseTier(
        address _beneficiary,
        uint256 _tierPrice,
        uint256 _tierRemaining,
        uint256 _investedUSD,
        uint256 _tier
    )
        internal
        returns(uint256 spentUSD, uint256 purchasedTokens, bool gotoNextTier)
    {

        purchasedTokens = DecimalMath.div(_investedUSD, _tierPrice);
        uint256 granularity = securityToken.granularity();

        if (purchasedTokens > _tierRemaining) {
            purchasedTokens = _tierRemaining.div(granularity);
            gotoNextTier = true;
        } else {
            purchasedTokens = purchasedTokens.div(granularity);
        }

        purchasedTokens = purchasedTokens.mul(granularity);
        spentUSD = DecimalMath.mul(purchasedTokens, _tierPrice);

        if (spentUSD > _investedUSD) {
            spentUSD = _investedUSD;
        }

        if (purchasedTokens > 0) {
            securityToken.issue(_beneficiary, purchasedTokens, "");
            emit TokenPurchase(msg.sender, _beneficiary, purchasedTokens, spentUSD, _tierPrice, _tier);
        }
    }

    function _isAccredited(address _investor) internal view returns(bool) {

        IDataStore dataStore = getDataStore();
        return _getIsAccredited(_investor, dataStore);
    }

    function _getIsAccredited(address _investor, IDataStore dataStore) internal view returns(bool) {

        uint256 flags = dataStore.getUint256(_getKey(INVESTORFLAGS, _investor));
        uint256 flag = flags & uint256(1); //isAccredited is flag 0 so we don't need to bit shift flags.
        return flag > 0 ? true : false;
    }


    function isOpen() public view returns(bool) {

        if (isFinalized || now < startTime || now >= endTime || capReached())
            return false;
        return true;
    }

    function capReached() public view returns (bool) {

        if (isFinalized) {
            return (finalAmountReturned == 0);
        }
        return (tiers[tiers.length - 1].mintedTotal == tiers[tiers.length - 1].tokenTotal);
    }

    function getRate(FundRaiseType _fundRaiseType) public returns (uint256) {

        if (_fundRaiseType == FundRaiseType.ETH) {
            return IOracle(_getOracle(bytes32("ETH"), bytes32("USD"))).getPrice();
        } else if (_fundRaiseType == FundRaiseType.POLY) {
            return IOracle(_getOracle(bytes32("POLY"), bytes32("USD"))).getPrice();
        } else if (_fundRaiseType == FundRaiseType.SC) {
            return 10**18;
        }
    }

    function convertToUSD(FundRaiseType _fundRaiseType, uint256 _amount) public returns(uint256) {

        return DecimalMath.mul(_amount, getRate(_fundRaiseType));
    }

    function convertFromUSD(FundRaiseType _fundRaiseType, uint256 _amount) public returns(uint256) {

        return DecimalMath.div(_amount, getRate(_fundRaiseType));
    }

    function getTokensSold() public view returns (uint256) {

        if (isFinalized)
            return totalTokensSold;
        return getTokensMinted();
    }

    function getTokensMinted() public view returns (uint256 tokensMinted) {

        for (uint256 i = 0; i < tiers.length; i++) {
            tokensMinted = tokensMinted.add(tiers[i].mintedTotal);
        }
    }

    function getTokensSoldFor(FundRaiseType _fundRaiseType) external view returns (uint256 tokensSold) {

        for (uint256 i = 0; i < tiers.length; i++) {
            tokensSold = tokensSold.add(tiers[i].minted[uint8(_fundRaiseType)]);
        }
    }

    function getTokensMintedByTier(uint256 _tier) external view returns(uint256[] memory) {

        uint256[] memory tokensMinted = new uint256[](3);
        tokensMinted[0] = tiers[_tier].minted[uint8(FundRaiseType.ETH)];
        tokensMinted[1] = tiers[_tier].minted[uint8(FundRaiseType.POLY)];
        tokensMinted[2] = tiers[_tier].minted[uint8(FundRaiseType.SC)];
        return tokensMinted;
    }

    function getTokensSoldByTier(uint256 _tier) external view returns (uint256) {

        uint256 tokensSold;
        tokensSold = tokensSold.add(tiers[_tier].minted[uint8(FundRaiseType.ETH)]);
        tokensSold = tokensSold.add(tiers[_tier].minted[uint8(FundRaiseType.POLY)]);
        tokensSold = tokensSold.add(tiers[_tier].minted[uint8(FundRaiseType.SC)]);
        return tokensSold;
    }

    function getNumberOfTiers() external view returns (uint256) {

        return tiers.length;
    }

    function getUsdTokens() external view returns (IERC20[] memory) {

        return usdTokens;
    }

    function getPermissions() public view returns(bytes32[] memory allPermissions) {

        allPermissions = new bytes32[](2);
        allPermissions[0] = OPERATOR;
        allPermissions[1] = ADMIN;
        return allPermissions;
    }

    function getSTODetails() external view returns(uint256, uint256, uint256, uint256[] memory, uint256[] memory, uint256, uint256, uint256, bool[] memory) {

        uint256[] memory cap = new uint256[](tiers.length);
        uint256[] memory rate = new uint256[](tiers.length);
        for(uint256 i = 0; i < tiers.length; i++) {
            cap[i] = tiers[i].tokenTotal;
            rate[i] = tiers[i].rate;
        }
        bool[] memory _fundRaiseTypes = new bool[](3);
        _fundRaiseTypes[0] = fundRaiseTypes[uint8(FundRaiseType.ETH)];
        _fundRaiseTypes[1] = fundRaiseTypes[uint8(FundRaiseType.POLY)];
        _fundRaiseTypes[2] = fundRaiseTypes[uint8(FundRaiseType.SC)];
        return (
            startTime,
            endTime,
            currentTier,
            cap,
            rate,
            fundsRaisedUSD,
            investorCount,
            getTokensSold(),
            _fundRaiseTypes
        );
    }

    function getInitFunction() public pure returns(bytes4) {

        return this.configure.selector;
    }

    function _getOracle(bytes32 _currency, bytes32 _denominatedCurrency) internal view returns(address oracleAddress) {

        oracleAddress = customOracles[_currency][_denominatedCurrency];
        if (oracleAddress == address(0))
            oracleAddress =  IPolymathRegistry(securityToken.polymathRegistry()).getAddress(oracleKeys[_currency][_denominatedCurrency]);
    }
}