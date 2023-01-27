
pragma solidity 0.7.6;

interface IICHIOwnable {

    
    function renounceOwnership() external;

    function transferOwnership(address newOwner) external;

    function owner() external view returns (address);

}// BUSL-1.1

pragma solidity 0.7.6;
pragma abicoder v2;

interface InterfaceCommon {


    enum ModuleType { Version, Controller, Strategy, MintMaster, Oracle }

}// BUSL-1.1

pragma solidity 0.7.6;


interface IICHICommon is IICHIOwnable, InterfaceCommon {}// MIT


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

}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
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

pragma solidity >=0.6.0 <0.8.0;


library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
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
}// BUSL-1.1

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


contract ICHIERC20 is IERC20, Context, ICHIInitializable {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;




    function initERC20(string memory name_, string memory symbol_) internal initializer {

        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ICHIERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ICHIERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ICHIERC20: transfer from the zero address");
        require(recipient != address(0), "ICHIERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ICHIERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ICHIERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ICHIERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ICHIERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ICHIERC20: approve from the zero address");
        require(spender != address(0), "ICHIERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address /* from */, address /* to */, uint256 /* amount */) internal virtual { }

}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract ICHIERC20Burnable is ICHIERC20 {
    
    using SafeMath for uint256;

    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "ICHIERC20Burnable: burn amount exceeds allowance");

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
    }
}// BUSL-1.1

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

interface IController {
    
    function oneTokenFactory() external returns(address);
    function description() external returns(string memory);
    function init() external;
    function periodic() external;
    function MODULE_TYPE() external view returns(bytes32);    
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


interface IStrategy is IModule {
    
    function init() external;
    function execute() external;
    function setAllowance(address token, uint256 amount) external;
    function toVault(address token, uint256 amount) external;
    function fromVault(address token, uint256 amount) external;
    function closeAllPositions() external returns(bool);
    function closePositions(address token) external returns(bool success);
    function oneToken() external view returns(address);
}// BUSL-1.1

pragma solidity 0.7.6;


interface IMintMaster is IModule {
    
    function oneTokenOracles(address) external view returns(address);
    function init(address oneTokenOracle) external;
    function updateMintingRatio(address collateralToken) external returns(uint256 ratio, uint256 maxOrderVolume);
    function getMintingRatio(address collateral) external view returns(uint256 ratio, uint256 maxOrderVolume);
    function getMintingRatio2(address oneToken, address collateralToken) external view returns(uint256 ratio, uint256 maxOrderVolume);  
    function getMintingRatio4(address oneToken, address oneTokenOracle, address collateralToken, address collateralOracle) external view returns(uint256 ratio, uint256 maxOrderVolume); 
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


contract OneTokenV1Base is IOneTokenV1Base, ICHICommon, ICHIERC20Burnable {

    using SafeERC20 for IERC20;
    using AddressSet for AddressSet.Set;

    bytes32 public constant override MODULE_TYPE = keccak256(abi.encodePacked("ICHI V1 OneToken Implementation"));

    address public override oneTokenFactory;
    address public override controller;
    address public override mintMaster;
    address public override memberToken;
    AddressSet.Set collateralTokenSet;
    AddressSet.Set otherTokenSet;

    struct Asset {
        address oracle;
        address strategy;
    }

    AddressSet.Set assetSet;
    mapping(address => Asset) public override assets;

    event Initialized(address sender, string name, string symbol, address controller, address mintMaster, address memberToken, address collateral);
    event ControllerChanged(address sender, address controller);
    event MintMasterChanged(address sender, address mintMaster, address oneTokenOracle);
    event StrategySet(address sender, address token, address strategy, uint256 allowance);
    event StrategyExecuted(address indexed sender, address indexed token, address indexed strategy);
    event StrategyRemoved(address sender, address token, address strategy);
    event StrategyClosed(address sender, address token, address strategy);
    event ToStrategy(address sender, address strategy, address token, uint256 amount);
    event FromStrategy(address sender, address strategy, address token, uint256 amount);
    event StrategyAllowanceIncreased(address sender, address token, address strategy, uint256 amount);
    event StrategyAllowanceDecreased(address sender, address token, address strategy, uint256 amount);
    event AssetAdded(address sender, address token, address oracle);
    event AssetRemoved(address sender, address token);
    event NewFactory(address sender, address factory);

    modifier onlyOwnerOrController {
        if(msg.sender != owner()) {
            require(msg.sender == controller, "OTV1B: not owner or controller");
        }
        _;
    }

    function init(
        string memory name_,
        string memory symbol_,
        address oneTokenOracle_,
        address controller_,
        address mintMaster_,
        address memberToken_,
        address collateral_
    )
        external
        initializer
        override
    {
        initOwnable();

        oneTokenFactory = msg.sender;
        initERC20(name_, symbol_); // decimals is always 18

        require(bytes(name_).length > 0 && bytes(symbol_).length > 0, "OTV1B: name and symbol are RQD");

        require(IOneTokenFactory(oneTokenFactory).isValidModuleType(oneTokenOracle_, ModuleType.Oracle), "OTV1B: unknown oracle");
        require(IOneTokenFactory(oneTokenFactory).isValidModuleType(controller_, ModuleType.Controller), "OTV1B: unknown controller");
        require(IOneTokenFactory(oneTokenFactory).isValidModuleType(mintMaster_, ModuleType.MintMaster), "OTV1B: unknown mint master");
        require(IOneTokenFactory(oneTokenFactory).isForeignToken(memberToken_), "OTV1B: unknown MEM token");
        require(IOneTokenFactory(oneTokenFactory).isCollateral(collateral_), "OTV1B: unknown collateral");

        controller = controller_;
        mintMaster = mintMaster_;

        memberToken = memberToken_;

        collateralTokenSet.insert(collateral_, "OTV1B: ERR inserting collateral");
        otherTokenSet.insert(memberToken_, "OTV1B: ERR inserting MEM token");
        assetSet.insert(collateral_, "OTV1B: ERR inserting collateral as asset");
        assetSet.insert(memberToken_, "OTV1B: ERR inserting MEM token as asset");

        Asset storage mt = assets[memberToken_];
        Asset storage ct = assets[collateral_];


        mt.oracle = IOneTokenFactory(oneTokenFactory).foreignTokenOracleAtIndex(memberToken_, 0);
        ct.oracle = IOneTokenFactory(oneTokenFactory).foreignTokenOracleAtIndex(collateral_, 0);

        IController(controller_).init();
        IMintMaster(mintMaster_).init(oneTokenOracle_);
       
        IOracle(oneTokenOracle_).update(address(this));
        IOracle(mt.oracle).update(memberToken);
        IOracle(ct.oracle).update(collateral_);

        emit Initialized(msg.sender, name_, symbol_, controller_, mintMaster_, memberToken_, collateral_);
    }

    function changeController(address controller_) external onlyOwner override {
        require(IOneTokenFactory(oneTokenFactory).isModule(controller_), "OTV1B: unregistered controller");
        require(IOneTokenFactory(oneTokenFactory).isValidModuleType(controller_, ModuleType.Controller), "OTV1B: unknown controller");
        IController(controller_).init();
        controller = controller_;
        emit ControllerChanged(msg.sender, controller_);
    }

    function changeMintMaster(address mintMaster_, address oneTokenOracle_) external onlyOwner override {
        require(IOneTokenFactory(oneTokenFactory).isModule(mintMaster_), "OTV1B: unregistered mint master");
        require(IOneTokenFactory(oneTokenFactory).isValidModuleType(mintMaster_, ModuleType.MintMaster), "OTV1B: unknown mint master");
        require(IOneTokenFactory(oneTokenFactory).isOracle(address(this), oneTokenOracle_), "OTV1B: unregistered oneToken oracle");
        IOracle(oneTokenOracle_).update(address(this));
        IMintMaster(mintMaster_).init(oneTokenOracle_);
        mintMaster = mintMaster_;
        emit MintMasterChanged(msg.sender, mintMaster_, oneTokenOracle_);
    }

    function addAsset(address token, address oracle) external onlyOwner override {
        require(IOneTokenFactory(oneTokenFactory).isOracle(token, oracle), "OTV1B: unknown oracle or token");
        (bool isCollateral_, /* uint256 oracleCount */) = IOneTokenFactory(oneTokenFactory).foreignTokenInfo(token);
        Asset storage a = assets[token];
        a.oracle = oracle;
        IOracle(oracle).update(token);
        if(isCollateral_) {
            collateralTokenSet.insert(token, "OTV1B: collateral already exists");
        } else {
            otherTokenSet.insert(token, "OTV1B: token already exists");
        }
        assetSet.insert(token, "OTV1B: ERR inserting asset");
        emit AssetAdded(msg.sender, token, oracle);
    }

    function removeAsset(address token) external onlyOwner override {
        (uint256 inVault, uint256 inStrategy) = balances(token);
        require(inVault == 0, "OTV1B: can't remove token with vault balance > 0");
        require(inStrategy == 0, "OTV1B: can't remove asset with strategy balance > 0");
        require(assetSet.exists(token), "OTV1B: unknown token");
        if(collateralTokenSet.exists(token)) collateralTokenSet.remove(token, "OTV1B: ERR removing collateral token");
        if(otherTokenSet.exists(token)) otherTokenSet.remove(token, "OTV1B: ERR removing MEM token");
        assetSet.remove(token, "OTV1B: ERR removing asset");
        delete assets[token];
        emit AssetRemoved(msg.sender, token);
    }

    function setStrategy(address token, address strategy, uint256 allowance) external onlyOwner override {

        require(assetSet.exists(token), "OTV1B: unknown token");
        require(IOneTokenFactory(oneTokenFactory).isModule(strategy), "OTV1B: unknown strategy");
        require(IOneTokenFactory(oneTokenFactory).isValidModuleType(strategy, ModuleType.Strategy), "OTV1B: unknown strategy");
        require(IStrategy(strategy).oneToken() == address(this), "OTV1B: can't assign strategy that doesn't recognize this vault");
        require(IStrategy(strategy).owner() == owner(), "OTV1B: unknown strategy owner");


        Asset storage a = assets[token];
        closeStrategy(token);

        IStrategy(strategy).init();
        IERC20(token).safeApprove(strategy, allowance);

        a.strategy = strategy;
        emit StrategySet(msg.sender, token, strategy, allowance);
    }

    function removeStrategy(address token) external onlyOwner override {
        Asset storage a = assets[token];
        closeStrategy(token);
        address strategy = a.strategy;
        a.strategy = NULL_ADDRESS;
        emit StrategyRemoved(msg.sender, token, strategy);
    }

    function closeStrategy(address token) public override onlyOwnerOrController {
        require(assetSet.exists(token), "OTV1B:cs: unknown token");
        Asset storage a = assets[token];
        address oldStrategy = a.strategy;
        if(oldStrategy != NULL_ADDRESS) IERC20(token).safeApprove(oldStrategy, 0);
        emit StrategyClosed(msg.sender, token, oldStrategy);
    }

    function executeStrategy(address token) external onlyOwnerOrController override {
        require(assetSet.exists(token), "OTV1B:es: unknown token");
        Asset storage a = assets[token];
        address strategy = a.strategy;
        IStrategy(strategy).execute();
        emit StrategyExecuted(msg.sender, token, strategy);
    }

    function toStrategy(address strategy, address token, uint256 amount) external onlyOwnerOrController {
        Asset storage a = assets[token];
        require(a.strategy == strategy, "OTV1B: not the token strategy");
        IERC20(token).safeTransfer(strategy, amount);
        emit ToStrategy(msg.sender, strategy, token, amount);
    }

    function fromStrategy(address strategy, address token, uint256 amount) external onlyOwnerOrController {
        Asset storage a = assets[token];
        require(a.strategy == strategy, "OTV1B: not the token strategy");
        IStrategy(strategy).toVault(token, amount);
        emit FromStrategy(msg.sender, strategy, token, amount);
    }

    function increaseStrategyAllowance(address token, uint256 amount) external onlyOwnerOrController override {
        Asset storage a = assets[token];
        address strategy = a.strategy;
        require(a.strategy != NULL_ADDRESS, "OTV1B: no strategy");
        IERC20(token).safeIncreaseAllowance(strategy, amount);
        emit StrategyAllowanceIncreased(msg.sender, token, strategy, amount);
    }

    function decreaseStrategyAllowance(address token, uint256 amount) external onlyOwnerOrController override {
        Asset storage a = assets[token];
        address strategy = a.strategy;
        require(a.strategy != NULL_ADDRESS, "OTV1B: no strategy");
        IERC20(token).safeDecreaseAllowance(strategy, amount);
        emit StrategyAllowanceDecreased(msg.sender, token, strategy, amount);
    }

    function setFactory(address newFactory) external override onlyOwner {
        require(IOneTokenFactory(newFactory).MODULE_TYPE() == COMPONENT_FACTORY, "OTV1B: new factory doesn't emit factory fingerprint");
        oneTokenFactory = newFactory;
        emit NewFactory(msg.sender, newFactory);
    }


    function balances(address token) public view override returns(uint256 inVault, uint256 inStrategy) {
        IERC20 asset = IERC20(token);
        inVault = asset.balanceOf(address(this));
        address strategy = assets[token].strategy;
        if(strategy != NULL_ADDRESS) inStrategy = asset.balanceOf(strategy);
    }

    function collateralTokenCount() external view override returns(uint256) {
        return collateralTokenSet.count();
    }

    function collateralTokenAtIndex(uint256 index) external view override returns(address) {
        return collateralTokenSet.keyAtIndex(index);
    }

    function isCollateral(address token) public view override returns(bool) {
        return collateralTokenSet.exists(token);
    }

    function otherTokenCount() external view override returns(uint256) {
        return otherTokenSet.count();
    }

    function otherTokenAtIndex(uint256 index) external view override returns(address) {
        return otherTokenSet.keyAtIndex(index);
    }

    function isOtherToken(address token) external view override returns(bool) {
        return otherTokenSet.exists(token);
    }

    function assetCount() external view override returns(uint256) {
        return assetSet.count();
    }

    function assetAtIndex(uint256 index) external view override returns(address) {
        return assetSet.keyAtIndex(index);
    }

    function isAsset(address token) external view override returns(bool) {
        return assetSet.exists(token);
    }
}// BUSL-1.1

pragma solidity 0.7.6;


contract OneTokenV1 is IOneTokenV1, OneTokenV1Base {

    using AddressSet for AddressSet.Set;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 public override mintingFee; // defaults to 0%
    uint256 public override redemptionFee; // defaults to 0%

    mapping(address => uint256) public liabilities;
  
    event Minted(address indexed sender, address indexed collateral, uint256 oneTokens, uint256 memberTokens, uint256 collateralTokens);
    event Redeemed(address indexed sender, address indexed collateral, uint256 amount);
    event NewMintingFee(address sender, uint256 fee);
    event NewRedemptionFee(address sender, uint256 fee);
    

    function mint(address collateralToken, uint256 oneTokens) external initialized override {
        require(collateralTokenSet.exists(collateralToken), "OTV1: offer a collateral token");
        require(oneTokens > 0, "OTV1: order must be > 0");
        
        IOracle(assets[collateralToken].oracle).update(collateralToken);
        IOracle(assets[memberToken].oracle).update(memberToken);
        
        (uint256 mintingRatio, uint256 maxOrderVolume) = updateMintingRatio(collateralToken);

        require(oneTokens <= maxOrderVolume, "OTV1: order exceeds limit");

        uint256 collateralUSDValue = oneTokens.mul(mintingRatio).div(PRECISION);
        uint256 memberTokensUSDValue = oneTokens.sub(collateralUSDValue);
        collateralUSDValue = collateralUSDValue.add(oneTokens.mul(mintingFee).div(PRECISION));

        (uint256 memberTokensReq, /* volatility */) = IOracle(assets[memberToken].oracle).amountRequired(memberToken, memberTokensUSDValue);

        uint256 memberTokenAllowance = IERC20(memberToken).allowance(msg.sender, address(this));

        if(memberTokensReq > memberTokenAllowance) {
            uint256 memberTokenRate = memberTokensUSDValue.mul(PRECISION).div(memberTokensReq);
            memberTokensReq = memberTokenAllowance;
            memberTokensUSDValue = memberTokenRate.mul(memberTokensReq).div(PRECISION);
            collateralUSDValue = oneTokens.sub(memberTokensUSDValue);
            collateralUSDValue = collateralUSDValue.add(oneTokens.mul(mintingFee).div(PRECISION));
        }

        require(IERC20(memberToken).balanceOf(msg.sender) >= memberTokensReq, "OTV1: NSF: member token");

        (uint256 collateralTokensReq, /* volatility */) = IOracle(assets[collateralToken].oracle).amountRequired(collateralToken, collateralUSDValue);

        require(IERC20(collateralToken).balanceOf(msg.sender) >= collateralTokensReq, "OTV1: NSF: collateral token");
        require(collateralTokensReq > 0, "OTV1: order too small");

        IERC20(memberToken).safeTransferFrom(msg.sender, address(this), memberTokensReq);
        IERC20(collateralToken).safeTransferFrom(msg.sender, address(this), collateralTokensReq);
        
        _mint(msg.sender, oneTokens);

        emit Minted(msg.sender, collateralToken, oneTokens, memberTokensReq, collateralTokensReq);
    }

    function redeem(address collateral, uint256 amount) external override {
        require(isCollateral(collateral), "OTV1: unknown collateral");
        require(amount > 0, "OTV1: amount must be > 0");
        require(balanceOf(msg.sender) >= amount, "OTV1: NSF: oneToken");
        IOracle co = IOracle(assets[collateral].oracle);
        co.update(collateral);

        _burn(msg.sender, amount);

        uint256 netUsd = amount.sub(amount.mul(redemptionFee).div(PRECISION));
        (uint256 netTokens, /* uint256 volatility */)  = co.amountRequired(collateral, netUsd);

        IERC20(collateral).safeTransfer(msg.sender, netTokens);
        emit Redeemed(msg.sender, collateral, amount);
        
        updateMintingRatio(collateral);

        IController(controller).periodic();
    }

    function setMintingFee(uint256 fee) external onlyOwner override {
        require(fee <= PRECISION, "OTV1: fee must be <= 100%");
        mintingFee = fee;
        emit NewMintingFee(msg.sender, fee);
    }

    function setRedemptionFee(uint256 fee) external onlyOwner override {
        require(fee <= PRECISION, "OTV1: fee must be <= 100%");
        redemptionFee = fee;
        emit NewRedemptionFee(msg.sender, fee);
    }    

    function updateMintingRatio(address collateralToken) public override returns(uint256 ratio, uint256 maxOrderVolume) {
        return IMintMaster(mintMaster).updateMintingRatio(collateralToken);
    }

    function getMintingRatio(address collateralToken) external view override returns(uint256 ratio, uint256 maxOrderVolume) {
        return IMintMaster(mintMaster).getMintingRatio(collateralToken);
    }

    function getHoldings(address token) external view override returns(uint256 vaultBalance, uint256 strategyBalance) {   
        IERC20 t = IERC20(token);
        vaultBalance = t.balanceOf(address(this));
        Asset storage a = assets[token];
        if(a.strategy != NULL_ADDRESS) strategyBalance = t.balanceOf(a.strategy);
    } 
}