
pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// BUSL-1.1

pragma solidity 0.7.6;

interface IICHIOwnable {

    
    function renounceOwnership() external;

    function transferOwnership(address newOwner) external;

    function owner() external view returns (address);

}// MIT


pragma solidity >=0.6.0 <0.8.0;

contract ICHIOwnable is IICHIOwnable, Context {

    
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    modifier onlyOwner() {

        require(owner() == _msgSender(), "ICHIOwnable: caller is not the owner");
        _;
    }    

    constructor() {
        _transferOwnership(msg.sender);
    }

    function initOwnable() internal {

        require(owner() == address(0), "ICHIOwnable: already initialized");
        _transferOwnership(msg.sender);
    }

    function owner() public view virtual override returns (address) {

        return _owner;
    }

    function renounceOwnership() public virtual override onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }


    function transferOwnership(address newOwner) public virtual override onlyOwner {

        _transferOwnership(newOwner);
    }


    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "ICHIOwnable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// MIT

pragma solidity >=0.6.2 <0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}// MIT

pragma solidity 0.7.6;


contract ICHIInitializable {


    bool private _initialized;
    bool private _initializing;

    modifier initializer() {

        require(_initializing || _isConstructor() || !_initialized, "ICHIInitializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    modifier initialized {

        require(_initialized, "ICHIInitializable: contract is not initialized");
        _;
    }

    function _isConstructor() private view returns (bool) {

        return !Address.isContract(address(this));
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// BUSL-1.1

pragma solidity 0.7.6;


interface IERC20Extended is IERC20 {

    
    function decimals() external view returns(uint8);

    function symbol() external view returns(string memory);

    function name() external view returns(string memory);

}// BUSL-1.1

pragma solidity 0.7.6;
pragma abicoder v2;

interface InterfaceCommon {


    enum ModuleType { Version, Controller, Strategy, MintMaster, Oracle }

}// BUSL-1.1

pragma solidity 0.7.6;


interface IICHICommon is IICHIOwnable, InterfaceCommon {}// BUSL-1.1


pragma solidity 0.7.6;


contract ICHICommon is IICHICommon, ICHIOwnable, ICHIInitializable {


    uint256 constant PRECISION = 10 ** 18;
    uint256 constant INFINITE = uint256(0-1);
    address constant NULL_ADDRESS = address(0);
    

    bytes32 constant COMPONENT_CONTROLLER = keccak256(abi.encodePacked("ICHI V1 Controller"));
    bytes32 constant COMPONENT_VERSION = keccak256(abi.encodePacked("ICHI V1 OneToken Implementation"));
    bytes32 constant COMPONENT_STRATEGY = keccak256(abi.encodePacked("ICHI V1 Strategy Implementation"));
    bytes32 constant COMPONENT_MINTMASTER = keccak256(abi.encodePacked("ICHI V1 MintMaster Implementation"));
    bytes32 constant COMPONENT_ORACLE = keccak256(abi.encodePacked("ICHI V1 Oracle Implementation"));
    bytes32 constant COMPONENT_VOTERROLL = keccak256(abi.encodePacked("ICHI V1 VoterRoll Implementation"));
    bytes32 constant COMPONENT_FACTORY = keccak256(abi.encodePacked("ICHI OneToken Factory"));
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Proxy {
    function _delegate(address implementation) internal virtual {
        assembly {
            calldatacopy(0, 0, calldatasize())

            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    function _implementation() internal view virtual returns (address);

    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    fallback () external payable virtual {
        _fallback();
    }

    receive () external payable virtual {
        _fallback();
    }

    function _beforeFallback() internal virtual {
    }
}// MIT



pragma solidity >=0.6.0 <0.8.0;


contract UpgradeableProxy is Proxy {

    constructor(address _logic, bytes memory _data) payable {
        assert(_IMPLEMENTATION_SLOT == bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1));
        _setImplementation(_logic);
        if(_data.length > 0) {
            Address.functionDelegateCall(_logic, _data);
        }
    }

    event Upgraded(address indexed implementation);

    bytes32 private constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    function _implementation() internal view virtual override returns (address impl) {

        bytes32 slot = _IMPLEMENTATION_SLOT;
        assembly {
            impl := sload(slot)
        }
    }

    function _upgradeTo(address newImplementation) internal virtual {

        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    function _setImplementation(address newImplementation) private {

        require(Address.isContract(newImplementation), "UpgradeableProxy: new implementation is not a contract");

        bytes32 slot = _IMPLEMENTATION_SLOT;

        assembly {
            sstore(slot, newImplementation)
        }
    }
}// MIT


pragma solidity >=0.6.0 <0.8.0;


contract TransparentUpgradeableProxy is UpgradeableProxy {

    constructor(address _logic, address admin_, bytes memory _data) payable UpgradeableProxy(_logic, _data) {
        assert(_ADMIN_SLOT == bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1));
        _setAdmin(admin_);
    }

    event AdminChanged(address previousAdmin, address newAdmin);

    bytes32 private constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    modifier ifAdmin() {

        if (msg.sender == _admin()) {
            _;
        } else {
            _fallback();
        }
    }

    function admin() external ifAdmin returns (address admin_) {

        admin_ = _admin();
    }

    function implementation() external ifAdmin returns (address implementation_) {

        implementation_ = _implementation();
    }

    function changeAdmin(address newAdmin) external virtual ifAdmin {

        require(newAdmin != address(0), "TransparentUpgradeableProxy: new admin is the zero address");
        emit AdminChanged(_admin(), newAdmin);
        _setAdmin(newAdmin);
    }

    function upgradeTo(address newImplementation) external virtual ifAdmin {

        _upgradeTo(newImplementation);
    }

    function upgradeToAndCall(address newImplementation, bytes calldata data) external payable virtual ifAdmin {

        _upgradeTo(newImplementation);
        Address.functionDelegateCall(newImplementation, data);
    }

    function _admin() internal view virtual returns (address adm) {

        bytes32 slot = _ADMIN_SLOT;
        assembly {
            adm := sload(slot)
        }
    }

    function _setAdmin(address newAdmin) private {

        bytes32 slot = _ADMIN_SLOT;

        assembly {
            sstore(slot, newAdmin)
        }
    }

    function _beforeFallback() internal virtual override {

        require(msg.sender != _admin(), "TransparentUpgradeableProxy: admin cannot fallback to proxy target");
        super._beforeFallback();
    }
}// BUSL-1.1

pragma solidity 0.7.6;


contract OneTokenProxy is TransparentUpgradeableProxy {


    constructor (address _logic, address admin_, bytes memory _data) 
        TransparentUpgradeableProxy(_logic, admin_, _data) {
    }
}// MIT


pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract ProxyAdmin is Ownable {


    function getProxyImplementation(TransparentUpgradeableProxy proxy) public view virtual returns (address) {

        (bool success, bytes memory returndata) = address(proxy).staticcall(hex"5c60da1b");
        require(success);
        return abi.decode(returndata, (address));
    }

    function getProxyAdmin(TransparentUpgradeableProxy proxy) public view virtual returns (address) {

        (bool success, bytes memory returndata) = address(proxy).staticcall(hex"f851a440");
        require(success);
        return abi.decode(returndata, (address));
    }

    function changeProxyAdmin(TransparentUpgradeableProxy proxy, address newAdmin) public virtual onlyOwner {

        proxy.changeAdmin(newAdmin);
    }

    function upgrade(TransparentUpgradeableProxy proxy, address implementation) public virtual onlyOwner {

        proxy.upgradeTo(implementation);
    }

    function upgradeAndCall(TransparentUpgradeableProxy proxy, address implementation, bytes memory data) public payable virtual onlyOwner {

        proxy.upgradeToAndCall{value: msg.value}(implementation, data);
    }
}// BUSL-1.1

pragma solidity 0.7.6;


contract OneTokenProxyAdmin is ProxyAdmin {}// BUSL-1.1


pragma solidity 0.7.6;


library AddressSet {

    
    struct Set {
        mapping(address => uint256) keyPointers;
        address[] keyList;
    }

    function insert(Set storage self, address key, string memory errorMessage) internal {

        require(!exists(self, key), errorMessage);
        self.keyList.push(key);
        self.keyPointers[key] = self.keyList.length-1;
    }

    function remove(Set storage self, address key, string memory errorMessage) internal {

        require(exists(self, key), errorMessage);
        uint256 last = count(self) - 1;
        uint256 rowToReplace = self.keyPointers[key];
        address keyToMove = self.keyList[last];
        self.keyPointers[keyToMove] = rowToReplace;
        self.keyList[rowToReplace] = keyToMove;
        delete self.keyPointers[key];
        self.keyList.pop();
    }

    function count(Set storage self) internal view returns(uint256) {

        return(self.keyList.length);
    }

    function exists(Set storage self, address key) internal view returns(bool) {

        if(self.keyList.length == 0) return false;
        return self.keyList[self.keyPointers[key]] == key;
    }

    function keyAtIndex(Set storage self, uint256 index) internal view returns(address) {

        return self.keyList[index];
    }
}// BUSL-1.1

pragma solidity 0.7.6;


interface IOneTokenFactory is InterfaceCommon {


    function oneTokenProxyAdmins(address) external returns(address);

    function deployOneTokenProxy(
        string memory name,
        string memory symbol,
        address governance, 
        address version,
        address controller,
        address mintMaster,              
        address memberToken, 
        address collateral,
        address oneTokenOracle
    ) 
        external 
        returns(address newOneTokenProxy, address proxyAdmin);


    function admitModule(address module, ModuleType moduleType, string memory name, string memory url) external;

    function updateModule(address module, string memory name, string memory url) external;

    function removeModule(address module) external;


    function admitForeignToken(address foreignToken, bool collateral, address oracle) external;

    function updateForeignToken(address foreignToken, bool collateral) external;

    function removeForeignToken(address foreignToken) external;


    function assignOracle(address foreignToken, address oracle) external;

    function removeOracle(address foreignToken, address oracle) external; 


    
    function MODULE_TYPE() external view returns(bytes32);


    function oneTokenCount() external view returns(uint256);

    function oneTokenAtIndex(uint256 index) external view returns(address);

    function isOneToken(address oneToken) external view returns(bool);

 

    function moduleCount() external view returns(uint256);

    function moduleAtIndex(uint256 index) external view returns(address module);

    function isModule(address module) external view returns(bool);

    function isValidModuleType(address module, ModuleType moduleType) external view returns(bool);



    function foreignTokenCount() external view returns(uint256);

    function foreignTokenAtIndex(uint256 index) external view returns(address);

    function foreignTokenInfo(address foreignToken) external view returns(bool collateral, uint256 oracleCount);

    function foreignTokenOracleCount(address foreignToken) external view returns(uint256);

    function foreignTokenOracleAtIndex(address foreignToken, uint256 index) external view returns(address);

    function isOracle(address foreignToken, address oracle) external view returns(bool);

    function isForeignToken(address foreignToken) external view returns(bool);

    function isCollateral(address foreignToken) external view returns(bool);

}// BUSL-1.1

pragma solidity 0.7.6;


interface IOneTokenV1Base is IICHICommon, IERC20 {

    
    function init(string memory name_, string memory symbol_, address oneTokenOracle_, address controller_,  address mintMaster_, address memberToken_, address collateral_) external;

    function changeController(address controller_) external;

    function changeMintMaster(address mintMaster_, address oneTokenOracle) external;

    function addAsset(address token, address oracle) external;

    function removeAsset(address token) external;

    function setStrategy(address token, address strategy, uint256 allowance) external;

    function executeStrategy(address token) external;

    function removeStrategy(address token) external;

    function closeStrategy(address token) external;

    function increaseStrategyAllowance(address token, uint256 amount) external;

    function decreaseStrategyAllowance(address token, uint256 amount) external;

    function setFactory(address newFactory) external;


    function MODULE_TYPE() external view returns(bytes32);

    function oneTokenFactory() external view returns(address);

    function controller() external view returns(address);

    function mintMaster() external view returns(address);

    function memberToken() external view returns(address);

    function assets(address) external view returns(address, address);

    function balances(address token) external view returns(uint256 inVault, uint256 inStrategy);

    function collateralTokenCount() external view returns(uint256);

    function collateralTokenAtIndex(uint256 index) external view returns(address);

    function isCollateral(address token) external view returns(bool);

    function otherTokenCount() external view  returns(uint256);

    function otherTokenAtIndex(uint256 index) external view returns(address); 

    function isOtherToken(address token) external view returns(bool);

    function assetCount() external view returns(uint256);

    function assetAtIndex(uint256 index) external view returns(address); 

    function isAsset(address token) external view returns(bool);

}// BUSL-1.1

pragma solidity 0.7.6;


interface IOneTokenV1 is IOneTokenV1Base {


    function mintingFee() external view returns(uint);

    function redemptionFee() external view returns(uint);

    function mint(address collateral, uint oneTokens) external;

    function redeem(address collateral, uint amount) external;

    function setMintingFee(uint fee) external;

    function setRedemptionFee(uint fee) external;

    function updateMintingRatio(address collateralToken) external returns(uint ratio, uint maxOrderVolume);

    function getMintingRatio(address collateralToken) external view returns(uint ratio, uint maxOrderVolume);

    function getHoldings(address token) external view returns(uint vaultBalance, uint strategyBalance);

}// BUSL-1.1

pragma solidity 0.7.6;


interface IModule is IICHICommon { 

       
    function oneTokenFactory() external view returns(address);

    function updateDescription(string memory description) external;

    function moduleDescription() external view returns(string memory);

    function MODULE_TYPE() external view returns(bytes32);

    function moduleType() external view returns(ModuleType);

}// BUSL-1.1

pragma solidity 0.7.6;


interface IOracle is IModule {


    function init(address baseToken) external;

    function update(address token) external;

    function indexToken() external view returns(address);


    function read(address token, uint amountTokens) external view returns(uint amountUsd, uint volatility);


    function amountRequired(address token, uint amountUsd) external view returns(uint amountTokens, uint volatility);


    function normalizedToTokens(address token, uint amountNormal) external view returns(uint amountTokens);


    function tokensToNormalized(address token, uint amountTokens) external view returns(uint amountNormal);

}// BUSL-1.1

pragma solidity 0.7.6;


contract OneTokenFactory is IOneTokenFactory, ICHICommon {


    using AddressSet for AddressSet.Set;
    bytes32 public constant override MODULE_TYPE = keccak256(abi.encodePacked("ICHI OneToken Factory"));
    bytes constant NULL_DATA = "";

    AddressSet.Set oneTokenSet;
    mapping(address => address) public override oneTokenProxyAdmins;

    struct Module {
        string name;
        string url;
        ModuleType moduleType;
    }

    AddressSet.Set moduleSet;
    mapping(address => Module) public modules;


    struct ForeignToken {
        bool isCollateral;
        AddressSet.Set oracleSet;
    }

    AddressSet.Set foreignTokenSet;
    mapping(address => ForeignToken) foreignTokens;


    event OneTokenDeployed(address sender, address newOneTokenProxy, string name, string symbol, address governance, address version, address controller, address mintMaster, address oneTokenOracle, address memberToken, address collateral);
    event OneTokenAdmin(address sender, address newOneTokenProxy, address proxyAdmin);
    event ModuleAdmitted(address sender, address module, ModuleType moduleType, string name, string url);
    event ModuleUpdated(address sender, address module, string name, string url);
    event ModuleRemoved(address sender, address module);
    event ForeignTokenAdmitted(address sender, address foreignToken, bool isCollateral, address oracle);
    event ForeignTokenUpdated(address sender, address foreignToken, bool isCollateral);
    event ForeignTokenRemoved(address sender, address foreignToken);
    event AddOracle(address sender, address foreignToken, address oracle);
    event RemoveOracle(address sender, address foreignToken, address oracle);

    function deployOneTokenProxy(
        string memory name,
        string memory symbol,
        address governance,
        address version,
        address controller,
        address mintMaster,
        address oneTokenOracle,
        address memberToken,
        address collateral
    )
        external
        onlyOwner
        override
        returns(address newOneTokenProxy, address proxyAdmin)
    {

        require(bytes(name).length > 0, "OneTokenFactory: token name is required");
        require(bytes(symbol).length > 0, "OneTokenfactory: token symbol is required");
        require(governance != NULL_ADDRESS, "OneTokenFactory: governance address is required");

        require(isModule(version), "OneTokenFactory: version is not approved");
        require(isModule(controller), "OneTokenFactory: controller is not approved");
        require(isModule(mintMaster), "OneTokenFactory: mintMaster is not approved");
        require(isModule(oneTokenOracle), "OneTokenFactory: oneTokenOracle is not approved");
        require(isValidModuleType(version, ModuleType.Version), "OneTokenFactory: version, wrong MODULE_TYPE");
        require(isValidModuleType(controller, InterfaceCommon.ModuleType.Controller), "OneTokenFactory: controller, wrong MODULE_TYPE");
        require(isValidModuleType(mintMaster, InterfaceCommon.ModuleType.MintMaster), "OneTokenFactory: mintMaster, wrong MODULE_TYPE");
        require(isValidModuleType(oneTokenOracle, ModuleType.Oracle), "OneTokenFactory: oneTokenOracle, wrong MODULE_TYPE");

        require(foreignTokenSet.exists(memberToken), "OneTokenFactory: unknown member token");
        require(foreignTokenSet.exists(collateral), "OneTokenFactory: unknown collateral");
        require(foreignTokens[collateral].isCollateral, "OneTokenFactory: specified token is not recognized as collateral");
        require(IERC20Extended(collateral).decimals() <= 18, "OneTokenFactory: collateral with +18 decimals precision is not supported");

        OneTokenProxyAdmin _admin = new OneTokenProxyAdmin();
        _admin.transferOwnership(governance);
        proxyAdmin = address(_admin);

        OneTokenProxy _proxy = new OneTokenProxy(version, address(_admin), NULL_DATA);
        newOneTokenProxy = address(_proxy);

        oneTokenProxyAdmins[newOneTokenProxy] = address(proxyAdmin);

        admitForeignToken(newOneTokenProxy, true, oneTokenOracle);
        oneTokenSet.insert(newOneTokenProxy, "OneTokenFactory: Internal error registering initialized oneToken.");

        IOneTokenV1 oneToken = IOneTokenV1(newOneTokenProxy);
        oneToken.init(name, symbol, oneTokenOracle, controller, mintMaster, memberToken, collateral);

        oneToken.transferOwnership(governance);

        emitDeploymentEvent(newOneTokenProxy, name, symbol, governance, version, controller, mintMaster, oneTokenOracle, memberToken, collateral);
        emit OneTokenAdmin(msg.sender, newOneTokenProxy, proxyAdmin);
    }

    function emitDeploymentEvent(
        address proxy, string memory name, string memory symbol, address governance, address version, address controller, address mintMaster, address oneTokenOracle, address memberToken, address collateral) private {

        emit OneTokenDeployed(msg.sender, proxy, name, symbol, governance, version, controller, mintMaster, oneTokenOracle, memberToken, collateral);
    }


    function admitModule(address module, ModuleType moduleType, string memory name, string memory url) external onlyOwner override {

        require(isValidModuleType(module, moduleType), "OneTokenFactory: invalid fingerprint for module type");
        if(moduleType != ModuleType.Version) {
            require(IModule(module).oneTokenFactory() == address(this), "OneTokenFactory: module is not bound to this factory.");
        }
        moduleSet.insert(module, "OneTokenFactory, Set: module is already admitted.");
        updateModule(module, name, url);
        modules[module].moduleType = moduleType;
        emit ModuleAdmitted(msg.sender, module, moduleType, name, url);
    }

    function updateModule(address module, string memory name, string memory url) public onlyOwner override {

        require(moduleSet.exists(module), "OneTokenFactory, Set: unknown module");
        modules[module].name = name;
        modules[module].url = url;
        emit ModuleUpdated(msg.sender, module, name, url);
    }

    function removeModule(address module) external onlyOwner override  {

        require(moduleSet.exists(module), "OneTokenFactory, Set: unknown module");
        delete modules[module];
        moduleSet.remove(module, "OneTokenFactory, Set: unknown module");
        emit ModuleRemoved(msg.sender, module);
    }


    function admitForeignToken(address foreignToken, bool collateral, address oracle) public onlyOwner override {

        require(isModule(oracle), "OneTokenFactory: oracle is not registered.");
        require(isValidModuleType(oracle, ModuleType.Oracle), "OneTokenFactory, Set: unknown oracle");
        IOracle o = IOracle(oracle);
        o.init(foreignToken);
        o.update(foreignToken);
        foreignTokenSet.insert(foreignToken, "OneTokenFactory: foreign token is already admitted");
        ForeignToken storage f = foreignTokens[foreignToken];
        f.isCollateral = collateral;
        f.oracleSet.insert(oracle, "OneTokenFactory, Set: Internal error inserting oracle.");
        emit ForeignTokenAdmitted(msg.sender, foreignToken, collateral, oracle);
    }

    function updateForeignToken(address foreignToken, bool collateral) external onlyOwner override {

        require(foreignTokenSet.exists(foreignToken), "OneTokenFactory, Set: unknown foreign token");
        ForeignToken storage f = foreignTokens[foreignToken];
        f.isCollateral = collateral;
        emit ForeignTokenUpdated(msg.sender, foreignToken, collateral);
    }

    function removeForeignToken(address foreignToken) external onlyOwner override {

        require(foreignTokenSet.exists(foreignToken), "OneTokenFactory, Set: unknown foreign token");
        delete foreignTokens[foreignToken];
        foreignTokenSet.remove(foreignToken, "OneTokenfactory, Set: internal error removing foreign token");
        emit ForeignTokenRemoved(msg.sender, foreignToken);
    }

    function assignOracle(address foreignToken, address oracle) external onlyOwner override {

        require(foreignTokenSet.exists(foreignToken), "OneTokenFactory: unknown foreign token");
        require(isModule(oracle), "OneTokenFactory: oracle is not registered.");
        require(isValidModuleType(oracle, ModuleType.Oracle), "OneTokenFactory: Internal error checking oracle");
        IOracle o = IOracle(oracle);
        o.init(foreignToken);
        o.update(foreignToken);
        require(foreignTokens[o.indexToken()].isCollateral, "OneTokenFactory: Oracle Index Token is not registered collateral");
        foreignTokens[foreignToken].oracleSet.insert(oracle, "OneTokenFactory, Set: oracle is already assigned to foreign token.");
        emit AddOracle(msg.sender, foreignToken, oracle);
    }

    function removeOracle(address foreignToken, address oracle) external onlyOwner override {

        foreignTokens[foreignToken].oracleSet.remove(oracle, "OneTokenFactory, Set: oracle is not assigned to foreign token or unknown foreign token.");
        emit RemoveOracle(msg.sender, foreignToken, oracle);
    }


    function oneTokenCount() external view override returns(uint256) {

        return oneTokenSet.count();
    }

    function oneTokenAtIndex(uint256 index) external view override returns(address) {

        return oneTokenSet.keyAtIndex(index);
    }

    function isOneToken(address oneToken) external view override returns(bool) {

        return oneTokenSet.exists(oneToken);
    }


    function moduleCount() external view override returns(uint256) {

        return moduleSet.count();
    }

    function moduleAtIndex(uint256 index) external view override returns(address module) {

        return moduleSet.keyAtIndex(index);
    }

    function isModule(address module) public view override returns(bool) {

        return moduleSet.exists(module);
    }

    function isValidModuleType(address module, ModuleType moduleType) public view override returns(bool) {

        IModule m = IModule(module);
        bytes32 candidateSelfDeclaredType = m.MODULE_TYPE();


        if(moduleType == ModuleType.Version) {
            if(candidateSelfDeclaredType == COMPONENT_VERSION) return true;
        }
        if(moduleType == ModuleType.Controller) {
            if(candidateSelfDeclaredType == COMPONENT_CONTROLLER) return true;
        }
        if(moduleType == ModuleType.Strategy) {
            if(candidateSelfDeclaredType == COMPONENT_STRATEGY) return true;
        }
        if(moduleType == ModuleType.MintMaster) {
            if(candidateSelfDeclaredType == COMPONENT_MINTMASTER) return true;
        }
        if(moduleType == ModuleType.Oracle) {
            if(candidateSelfDeclaredType == COMPONENT_ORACLE) return true;
        }
        return false;
    }


    function foreignTokenCount() external view override returns(uint256) {

        return foreignTokenSet.count();
    }

    function foreignTokenAtIndex(uint256 index) external view override returns(address) {

        return foreignTokenSet.keyAtIndex(index);
    }

    function foreignTokenInfo(address foreignToken) external view override returns(bool collateral, uint256 oracleCount) {

        ForeignToken storage f = foreignTokens[foreignToken];
        collateral = f.isCollateral;
        oracleCount = f.oracleSet.count();
    }

    function foreignTokenOracleCount(address foreignToken) external view override returns(uint256) {

        return foreignTokens[foreignToken].oracleSet.count();
    }

    function foreignTokenOracleAtIndex(address foreignToken, uint256 index) external view override returns(address) {

        return foreignTokens[foreignToken].oracleSet.keyAtIndex(index);
    }

    function isOracle(address foreignToken, address oracle) external view override returns(bool) {

        return foreignTokens[foreignToken].oracleSet.exists(oracle);
    }

    function isForeignToken(address foreignToken) external view override returns(bool) {

        return foreignTokenSet.exists(foreignToken);
    }

    function isCollateral(address foreignToken) external view override returns(bool) {

        return foreignTokens[foreignToken].isCollateral;
    }
}