
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


interface IICHICommon is IICHIOwnable, InterfaceCommon {}// BUSL-1.1


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
}// BUSL-1.1

pragma solidity 0.7.6;


abstract contract ICHIModuleCommon is IModule, ICHICommon {
    
    ModuleType public immutable override moduleType;
    string public override moduleDescription;
    address public immutable override oneTokenFactory;

    event ModuleDeployed(address sender, ModuleType moduleType, string description);
    event DescriptionUpdated(address sender, string description);
   
    modifier onlyKnownToken {
        require(IOneTokenFactory(oneTokenFactory).isOneToken(msg.sender), "ICHIModuleCommon: msg.sender is not a known oneToken");
        _;
    }
    
    modifier onlyTokenOwner (address oneToken) {
        require(msg.sender == IOneTokenV1Base(oneToken).owner(), "ICHIModuleCommon: msg.sender is not oneToken owner");
        _;
    }

    modifier onlyModuleOrFactory {
        if(!IOneTokenFactory(oneTokenFactory).isModule(msg.sender)) {
            require(msg.sender == oneTokenFactory, "ICHIModuleCommon: msg.sender is not module owner, token factory or registed module");
        }
        _;
    }
    
    constructor (address oneTokenFactory_, ModuleType moduleType_, string memory description_) {
        require(oneTokenFactory_ != NULL_ADDRESS, "ICHIModuleCommon: oneTokenFactory cannot be empty");
        require(bytes(description_).length > 0, "ICHIModuleCommon: description cannot be empty");
        oneTokenFactory = oneTokenFactory_;
        moduleType = moduleType_;
        moduleDescription = description_;
        emit ModuleDeployed(msg.sender, moduleType_, description_);
    }

    function updateDescription(string memory description) external onlyOwner override {
        require(bytes(description).length > 0, "ICHIModuleCommon: description cannot be empty");
        moduleDescription = description;
        emit DescriptionUpdated(msg.sender, description);
    }  
}// BUSL-1.1

pragma solidity 0.7.6;


abstract contract OracleCommon is IOracle, ICHIModuleCommon {

    uint256 constant NORMAL = 18;
    bytes32 constant public override MODULE_TYPE = keccak256(abi.encodePacked("ICHI V1 Oracle Implementation"));
    address public override indexToken;

    event OracleDeployed(address sender, string description, address indexToken);
    event OracleInitialized(address sender, address baseToken, address indexToken);
    
    constructor(address oneTokenFactory_, string memory description_, address indexToken_) 
        ICHIModuleCommon(oneTokenFactory_, ModuleType.Oracle, description_) 
    { 
        require(indexToken_ != NULL_ADDRESS, "OracleCommon: indexToken cannot be empty");
        indexToken = indexToken_;
        emit OracleDeployed(msg.sender, description_, indexToken_);
    }

    function init(address baseToken) external onlyModuleOrFactory virtual override {
        emit OracleInitialized(msg.sender, baseToken, indexToken);
    }

    function normalizedToTokens(address token, uint256 amountNormal) public view override returns(uint256 amountTokens) {
        IERC20Extended t = IERC20Extended(token);
        uint256 nativeDecimals = t.decimals();
        require(nativeDecimals <= 18, "OracleCommon: unsupported token precision (greater than 18)");
        if(nativeDecimals == NORMAL) return amountNormal;
        return amountNormal / ( 10 ** (NORMAL - nativeDecimals));
    }

    function tokensToNormalized(address token, uint256 amountTokens) public view override returns(uint256 amountNormal) {
        IERC20Extended t = IERC20Extended(token);
        uint256 nativeDecimals = t.decimals();
        require(nativeDecimals <= 18, "OracleCommon: unsupported token precision (greater than 18)");
        if(nativeDecimals == NORMAL) return amountTokens;
        return amountTokens * ( 10 ** (NORMAL - nativeDecimals));
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
pragma solidity 0.7.6;

library FullMath {

    function mulDiv(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {

        uint256 prod0; // Least significant 256 bits of the product
        uint256 prod1; // Most significant 256 bits of the product
        assembly {
            let mm := mulmod(a, b, not(0))
            prod0 := mul(a, b)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }

        if (prod1 == 0) {
            require(denominator > 0);
            assembly {
                result := div(prod0, denominator)
            }
            return result;
        }

        require(denominator > prod1);


        uint256 remainder;
        assembly {
            remainder := mulmod(a, b, denominator)
        }
        assembly {
            prod1 := sub(prod1, gt(remainder, prod0))
            prod0 := sub(prod0, remainder)
        }

        uint256 twos = -denominator & denominator;
        assembly {
            denominator := div(denominator, twos)
        }

        assembly {
            prod0 := div(prod0, twos)
        }
        assembly {
            twos := add(div(sub(0, twos), twos), 1)
        }
        prod0 |= prod1 * twos;

        uint256 inv = (3 * denominator) ^ 2;
        inv *= 2 - denominator * inv; // inverse mod 2**8
        inv *= 2 - denominator * inv; // inverse mod 2**16
        inv *= 2 - denominator * inv; // inverse mod 2**32
        inv *= 2 - denominator * inv; // inverse mod 2**64
        inv *= 2 - denominator * inv; // inverse mod 2**128
        inv *= 2 - denominator * inv; // inverse mod 2**256

        result = prod0 * inv;
        return result;
    }

    function mulDivRoundingUp(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {

        result = mulDiv(a, b, denominator);
        if (mulmod(a, b, denominator) > 0) {
            require(result < type(uint256).max);
            result++;
        }
    }
}// GPL-2.0-or-later
pragma solidity 0.7.6;

library TickMath {

    int24 internal constant MIN_TICK = -887272;
    int24 internal constant MAX_TICK = -MIN_TICK;

    uint160 internal constant MIN_SQRT_RATIO = 4295128739;
    uint160 internal constant MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970342;

    function getSqrtRatioAtTick(int24 tick) internal pure returns (uint160 sqrtPriceX96) {

        uint256 absTick = tick < 0 ? uint256(-int256(tick)) : uint256(int256(tick));
        require(absTick <= uint256(MAX_TICK), 'T');

        uint256 ratio = absTick & 0x1 != 0 ? 0xfffcb933bd6fad37aa2d162d1a594001 : 0x100000000000000000000000000000000;
        if (absTick & 0x2 != 0) ratio = (ratio * 0xfff97272373d413259a46990580e213a) >> 128;
        if (absTick & 0x4 != 0) ratio = (ratio * 0xfff2e50f5f656932ef12357cf3c7fdcc) >> 128;
        if (absTick & 0x8 != 0) ratio = (ratio * 0xffe5caca7e10e4e61c3624eaa0941cd0) >> 128;
        if (absTick & 0x10 != 0) ratio = (ratio * 0xffcb9843d60f6159c9db58835c926644) >> 128;
        if (absTick & 0x20 != 0) ratio = (ratio * 0xff973b41fa98c081472e6896dfb254c0) >> 128;
        if (absTick & 0x40 != 0) ratio = (ratio * 0xff2ea16466c96a3843ec78b326b52861) >> 128;
        if (absTick & 0x80 != 0) ratio = (ratio * 0xfe5dee046a99a2a811c461f1969c3053) >> 128;
        if (absTick & 0x100 != 0) ratio = (ratio * 0xfcbe86c7900a88aedcffc83b479aa3a4) >> 128;
        if (absTick & 0x200 != 0) ratio = (ratio * 0xf987a7253ac413176f2b074cf7815e54) >> 128;
        if (absTick & 0x400 != 0) ratio = (ratio * 0xf3392b0822b70005940c7a398e4b70f3) >> 128;
        if (absTick & 0x800 != 0) ratio = (ratio * 0xe7159475a2c29b7443b29c7fa6e889d9) >> 128;
        if (absTick & 0x1000 != 0) ratio = (ratio * 0xd097f3bdfd2022b8845ad8f792aa5825) >> 128;
        if (absTick & 0x2000 != 0) ratio = (ratio * 0xa9f746462d870fdf8a65dc1f90e061e5) >> 128;
        if (absTick & 0x4000 != 0) ratio = (ratio * 0x70d869a156d2a1b890bb3df62baf32f7) >> 128;
        if (absTick & 0x8000 != 0) ratio = (ratio * 0x31be135f97d08fd981231505542fcfa6) >> 128;
        if (absTick & 0x10000 != 0) ratio = (ratio * 0x9aa508b5b7a84e1c677de54f3e99bc9) >> 128;
        if (absTick & 0x20000 != 0) ratio = (ratio * 0x5d6af8dedb81196699c329225ee604) >> 128;
        if (absTick & 0x40000 != 0) ratio = (ratio * 0x2216e584f5fa1ea926041bedfe98) >> 128;
        if (absTick & 0x80000 != 0) ratio = (ratio * 0x48a170391f7dc42444e8fa2) >> 128;

        if (tick > 0) ratio = type(uint256).max / ratio;

        sqrtPriceX96 = uint160((ratio >> 32) + (ratio % (1 << 32) == 0 ? 0 : 1));
    }

    function getTickAtSqrtRatio(uint160 sqrtPriceX96) internal pure returns (int24 tick) {

        require(sqrtPriceX96 >= MIN_SQRT_RATIO && sqrtPriceX96 < MAX_SQRT_RATIO, 'R');
        uint256 ratio = uint256(sqrtPriceX96) << 32;

        uint256 r = ratio;
        uint256 msb = 0;

        assembly {
            let f := shl(7, gt(r, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(6, gt(r, 0xFFFFFFFFFFFFFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(5, gt(r, 0xFFFFFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(4, gt(r, 0xFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(3, gt(r, 0xFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(2, gt(r, 0xF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(1, gt(r, 0x3))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := gt(r, 0x1)
            msb := or(msb, f)
        }

        if (msb >= 128) r = ratio >> (msb - 127);
        else r = ratio << (127 - msb);

        int256 log_2 = (int256(msb) - 128) << 64;

        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(63, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(62, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(61, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(60, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(59, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(58, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(57, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(56, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(55, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(54, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(53, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(52, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(51, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(50, f))
        }

        int256 log_sqrt10001 = log_2 * 255738958999603826347141; // 128.128 number

        int24 tickLow = int24((log_sqrt10001 - 3402992956809132418596140100660247210) >> 128);
        int24 tickHi = int24((log_sqrt10001 + 291339464771989622907027621153398088495) >> 128);

        tick = tickLow == tickHi ? tickLow : getSqrtRatioAtTick(tickHi) <= sqrtPriceX96 ? tickHi : tickLow;
    }
}// GPL-2.0-or-later
pragma solidity 0.7.6;

interface IUniswapV3PoolImmutables {

    function factory() external view returns (address);


    function token0() external view returns (address);


    function token1() external view returns (address);


    function fee() external view returns (uint24);


    function tickSpacing() external view returns (int24);


    function maxLiquidityPerTick() external view returns (uint128);

}// GPL-2.0-or-later
pragma solidity 0.7.6;

interface IUniswapV3PoolState {

    function slot0()
        external
        view
        returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        );


    function feeGrowthGlobal0X128() external view returns (uint256);


    function feeGrowthGlobal1X128() external view returns (uint256);


    function protocolFees() external view returns (uint128 token0, uint128 token1);


    function liquidity() external view returns (uint128);


    function ticks(int24 tick)
        external
        view
        returns (
            uint128 liquidityGross,
            int128 liquidityNet,
            uint256 feeGrowthOutside0X128,
            uint256 feeGrowthOutside1X128,
            int56 tickCumulativeOutside,
            uint160 secondsPerLiquidityOutsideX128,
            uint32 secondsOutside,
            bool initialized
        );


    function tickBitmap(int16 wordPosition) external view returns (uint256);


    function positions(bytes32 key)
        external
        view
        returns (
            uint128 _liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );


    function observations(uint256 index)
        external
        view
        returns (
            uint32 blockTimestamp,
            int56 tickCumulative,
            uint160 secondsPerLiquidityCumulativeX128,
            bool initialized
        );

}// GPL-2.0-or-later
pragma solidity 0.7.6;

interface IUniswapV3PoolDerivedState {

    function observe(uint32[] calldata secondsAgos)
        external
        view
        returns (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s);


    function snapshotCumulativesInside(int24 tickLower, int24 tickUpper)
        external
        view
        returns (
            int56 tickCumulativeInside,
            uint160 secondsPerLiquidityInsideX128,
            uint32 secondsInside
        );

}// GPL-2.0-or-later
pragma solidity 0.7.6;

interface IUniswapV3PoolActions {

    function initialize(uint160 sqrtPriceX96) external;


    function mint(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount,
        bytes calldata data
    ) external returns (uint256 amount0, uint256 amount1);


    function collect(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);


    function burn(
        int24 tickLower,
        int24 tickUpper,
        uint128 amount
    ) external returns (uint256 amount0, uint256 amount1);


    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external returns (int256 amount0, int256 amount1);


    function flash(
        address recipient,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;


    function increaseObservationCardinalityNext(uint16 observationCardinalityNext) external;

}// GPL-2.0-or-later
pragma solidity 0.7.6;

interface IUniswapV3PoolOwnerActions {

    function setFeeProtocol(uint8 feeProtocol0, uint8 feeProtocol1) external;


    function collectProtocol(
        address recipient,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);

}// GPL-2.0-or-later
pragma solidity 0.7.6;

interface IUniswapV3PoolEvents {

    event Initialize(uint160 sqrtPriceX96, int24 tick);

    event Mint(
        address sender,
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    event Collect(
        address indexed owner,
        address recipient,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount0,
        uint128 amount1
    );

    event Burn(
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    event Swap(
        address indexed sender,
        address indexed recipient,
        int256 amount0,
        int256 amount1,
        uint160 sqrtPriceX96,
        uint128 liquidity,
        int24 tick
    );

    event Flash(
        address indexed sender,
        address indexed recipient,
        uint256 amount0,
        uint256 amount1,
        uint256 paid0,
        uint256 paid1
    );

    event IncreaseObservationCardinalityNext(
        uint16 observationCardinalityNextOld,
        uint16 observationCardinalityNextNew
    );

    event SetFeeProtocol(uint8 feeProtocol0Old, uint8 feeProtocol1Old, uint8 feeProtocol0New, uint8 feeProtocol1New);

    event CollectProtocol(address indexed sender, address indexed recipient, uint128 amount0, uint128 amount1);
}// GPL-2.0-or-later
pragma solidity 0.7.6;


interface IUniswapV3Pool is
    IUniswapV3PoolImmutables,
    IUniswapV3PoolState,
    IUniswapV3PoolDerivedState,
    IUniswapV3PoolActions,
    IUniswapV3PoolOwnerActions,
    IUniswapV3PoolEvents
{


}// GPL-2.0-or-later
pragma solidity 0.7.6;

library LowGasSafeMath {

    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x + y) >= x);
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x - y) <= x);
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require(x == 0 || (z = x * y) / x == y);
    }

    function add(int256 x, int256 y) internal pure returns (int256 z) {

        require((z = x + y) >= x == (y >= 0));
    }

    function sub(int256 x, int256 y) internal pure returns (int256 z) {

        require((z = x - y) <= x == (y >= 0));
    }
}// GPL-2.0-or-later
pragma solidity 0.7.6;

library PoolAddress {

    bytes32 internal constant POOL_INIT_CODE_HASH = 0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54;

    struct PoolKey {
        address token0;
        address token1;
        uint24 fee;
    }

    function getPoolKey(
        address tokenA,
        address tokenB,
        uint24 fee
    ) internal pure returns (PoolKey memory) {

        if (tokenA > tokenB) (tokenA, tokenB) = (tokenB, tokenA);
        return PoolKey({token0: tokenA, token1: tokenB, fee: fee});
    }

    function computeAddress(address factory, PoolKey memory key) internal pure returns (address pool) {

        require(key.token0 < key.token1);
        pool = address(
            uint256(
                keccak256(
                    abi.encodePacked(
                        hex'ff',
                        factory,
                        keccak256(abi.encode(key.token0, key.token1, key.fee)),
                        POOL_INIT_CODE_HASH
                    )
                )
            )
        );
    }
}// GPL-2.0-or-later
pragma solidity 0.7.6;


library OracleLibrary {

    function consult(address pool, uint32 period) internal view returns (int24 timeWeightedAverageTick) {

        require(period != 0, 'BP');
        IUniswapV3Pool oracle = IUniswapV3Pool(pool);

        uint32[] memory secondAgos = new uint32[](2);
        secondAgos[0] = period;
        secondAgos[1] = 0;

        (int56[] memory tickCumulatives, ) = oracle.observe(secondAgos);
        int56 tickCumulativesDelta = tickCumulatives[1] - tickCumulatives[0];

        timeWeightedAverageTick = int24(tickCumulativesDelta / period);

        if (tickCumulativesDelta < 0 && (tickCumulativesDelta % period != 0)) timeWeightedAverageTick--;
    }

    function getQuoteAtTick(
        int24 tick,
        uint128 baseAmount,
        address baseToken,
        address quoteToken
    ) internal pure returns (uint256 quoteAmount) {

        uint160 sqrtRatioX96 = TickMath.getSqrtRatioAtTick(tick);

        if (sqrtRatioX96 <= type(uint128).max) {
            uint256 ratioX192 = uint256(sqrtRatioX96) * sqrtRatioX96;
            quoteAmount = baseToken < quoteToken
                ? FullMath.mulDiv(ratioX192, baseAmount, 1 << 192)
                : FullMath.mulDiv(1 << 192, baseAmount, ratioX192);
        } else {
            uint256 ratioX128 = FullMath.mulDiv(sqrtRatioX96, sqrtRatioX96, 1 << 64);
            quoteAmount = baseToken < quoteToken
                ? FullMath.mulDiv(ratioX128, baseAmount, 1 << 128)
                : FullMath.mulDiv(1 << 128, baseAmount, ratioX128);
        }
    }
}// GPL-2.0-or-later
pragma solidity 0.7.6;

interface IUniswapV3Factory {

    event OwnerChanged(address indexed oldOwner, address indexed newOwner);

    event PoolCreated(
        address indexed token0,
        address indexed token1,
        uint24 indexed fee,
        int24 tickSpacing,
        address pool
    );

    event FeeAmountEnabled(uint24 indexed fee, int24 indexed tickSpacing);

    function owner() external view returns (address);


    function feeAmountTickSpacing(uint24 fee) external view returns (int24);


    function getPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external view returns (address pool);


    function createPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external returns (address pool);


    function setOwner(address _owner) external;


    function enableFeeAmount(uint24 fee, int24 tickSpacing) external;

}// GPL-2.0-or-later
pragma solidity 0.7.6;

library SafeUint128 {

    function toUint128(uint256 y) internal pure returns (uint128 z) {

        require((z = uint128(y)) == y, "SafeUint128: overflow");
    }
}// GNU

pragma solidity 0.7.6;



contract UniswapV3OracleSimple is OracleCommon {


    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant UNI_V3_FACTORY = 0x1F98431c8aD98523631AE4a59f267346ea31F984;

    using AddressSet for AddressSet.Set;

    address public immutable uniswapFactory;
    uint24 public immutable ethPoolFee;

    struct Settings {
        bool oneStep;
        uint32 period;
        uint24 poolFee;
    }

    mapping(address => Settings) public registeredTokens; 
    AddressSet.Set registeredTokensSet;

    event RegisterToken(address sender, address token, bool oneStep, uint32 period, uint24 poolFee);
    event ReregisterToken(address sender, address token, bool oneStep, uint32 period, uint24 poolFee);

    constructor(
        address oneTokenFactory_, 
        address uniswapFactory_, 
        address indexToken_, 
        uint24 ethPoolFee_)
    OracleCommon(
        oneTokenFactory_, 
        "ICHI Simple Uniswap V3 Oracle", 
        indexToken_)
    {
        require(uniswapFactory_ != NULL_ADDRESS, "UniswapV3OracleSimple: uniswapFactory cannot be empty");
        require(ethPoolFee_ > 0, "UniswapV3OracleSimple: ethPoolFee must be > 0");
        uniswapFactory = uniswapFactory_;
        indexToken = indexToken_;
        ethPoolFee = ethPoolFee_;
    }

    function init(address token) external onlyModuleOrFactory override {

        require(registeredTokensSet.exists(token), "UniswapV3OracleSimple: token must be registered with the Oracle before it's iniialized from the Factory");
        emit OracleInitialized(msg.sender, token, indexToken);
    }

    function read(address token, uint256 amountTokens) external view override returns(uint256 amountUsd, uint256 volatility) {

        amountUsd = tokensToNormalized(indexToken, consult(token, amountTokens));
        volatility = 1;
    }

    function amountRequired(address token, uint256 amountUsd) external view override returns(uint256 amountTokens, uint256 volatility) {

        require(registeredTokensSet.exists(token), "UniswapV3OracleSimple: unknown token");

        Settings storage s = registeredTokens[token];
        ( amountTokens, volatility ) = (s.oneStep) ?
            amountRequiredOneStep(token, amountUsd, s.period, s.poolFee) :
            amountRequiredTwoSteps(token, amountUsd, s.period, s.poolFee);
    }

    function amountRequiredOneStep(address token, uint256 amountUsd, uint32 period, uint24 poolFee) internal view returns(uint256 amountTokens, uint256 volatility) {

        uint256 p1Tokens = 0;
        uint256 p2Tokens = 0;
        amountUsd = normalizedToTokens(indexToken, amountUsd);
        address pool = PoolAddress.computeAddress(uniswapFactory, PoolAddress.getPoolKey(indexToken, token, poolFee));
        int24 tick = poolValues(pool);
        p1Tokens = _fetchSpot(indexToken, token, tick, amountUsd);
        p2Tokens = (period > 0) ? _fetchTwap(pool, indexToken, token, period, amountUsd) : p1Tokens;
        amountTokens = (p1Tokens > p2Tokens) ? p1Tokens: p2Tokens;
        volatility = 1;
    }

    function amountRequiredTwoSteps(address token, uint256 amountUsd, uint32 period, uint24 poolFee) internal view returns(uint256 amountTokens, uint256 volatility) {

        uint256 p1Tokens = 0;
        uint256 p2Tokens = 0;
        amountUsd = normalizedToTokens(indexToken, amountUsd);
        address pool = PoolAddress.computeAddress(uniswapFactory, PoolAddress.getPoolKey(indexToken, WETH, ethPoolFee));
        int24 tick = poolValues(pool);
        uint256 amountTokensStepOne = _fetchSpot(indexToken, WETH, tick, amountUsd);
        pool = PoolAddress.computeAddress(uniswapFactory, PoolAddress.getPoolKey(WETH, token, poolFee));
        tick = poolValues(pool);
        p1Tokens = _fetchSpot(WETH, token, tick, amountTokensStepOne);
        p2Tokens = (period > 0) ? _fetchTwap(pool, WETH, token, period, amountTokensStepOne) : p1Tokens;
        amountTokens = (p1Tokens > p2Tokens) ? p1Tokens : p2Tokens;
        volatility = 1;
    }

    function update(address token) external override {}


    function consult(address token, uint256 amountTokens) public view returns (uint256 amountOut) {

        require(registeredTokensSet.exists(token), "UniswapV3OracleSimple: unknown token");

        Settings storage s = registeredTokens[token];
        amountOut = (s.oneStep) ? 
            consultOneStep (token, amountTokens, s.period, s.poolFee) : 
            consultTwoSteps(token, amountTokens, s.period, s.poolFee);
    }

    function poolValues(address pool) internal view returns (int24 tick) {

        IUniswapV3Pool oracle = IUniswapV3Pool(pool);
        (, int24 tick_, , , , , bool unlocked_) = oracle.slot0();
        require(unlocked_, "UniswapV3OracleSimple: the pool is locked");
        tick = tick_;
    }

    function consultOneStep(address token, uint256 amountTokens, uint32 period, uint24 poolFee) internal view returns (uint256 amountOut) {

        uint256 p1Out = 0;
        uint256 p2Out = 0;
        address pool = PoolAddress.computeAddress(uniswapFactory, PoolAddress.getPoolKey(token, indexToken, poolFee));
        int24 tick = poolValues(pool);
        p1Out = _fetchSpot(token, indexToken, tick, amountTokens);
        p2Out = (period > 0) ? _fetchTwap(pool, token, indexToken, period, amountTokens) : p1Out;
        amountOut = (p1Out > p2Out) ? p2Out : p1Out;
    }

    function consultTwoSteps(address token, uint256 amountTokens, uint32 period, uint24 poolFee) internal view returns (uint256 amountOut) {

        uint256 p1Out = 0;
        uint256 p2Out = 0;
        address pool1 = PoolAddress.computeAddress(uniswapFactory, PoolAddress.getPoolKey(token, WETH, poolFee));
        int24 tick = poolValues(pool1);
        uint256 p1amountOneStepOne = _fetchSpot(token, WETH, tick, amountTokens);
        address pool2 = PoolAddress.computeAddress(uniswapFactory, PoolAddress.getPoolKey(WETH, indexToken, ethPoolFee));
        tick = poolValues(pool2);
        p1Out = _fetchSpot(WETH, indexToken, tick, p1amountOneStepOne);
        p2Out = p1Out;

        if (period > 0) {
            uint256 p2amountOneStepOne = _fetchTwap(pool1, WETH, indexToken, period, amountTokens);
            p2Out = _fetchSpot(WETH, indexToken, tick, p2amountOneStepOne);
        }

        amountOut = (p1Out > p2Out) ? p2Out : p1Out;
    }

    function _fetchTwap(
        address _pool,
        address _tokenIn,
        address _tokenOut,
        uint32 _twapPeriod,
        uint256 _amountIn
    ) internal view returns (uint256 amountOut) {

        int256 twapTick = OracleLibrary.consult(_pool, _twapPeriod);
        return
            OracleLibrary.getQuoteAtTick(
                int24(twapTick), // can assume safe being result from consult()
                SafeUint128.toUint128(_amountIn),
                _tokenIn,
                _tokenOut
            );
    }

    function _fetchSpot(
        address _tokenIn,
        address _tokenOut,
        int24 _tick,
        uint256 _amountIn
    ) internal pure returns (uint256 amountOut) { 

        return
            OracleLibrary.getQuoteAtTick(
                _tick,
                SafeUint128.toUint128(_amountIn),
                _tokenIn,
                _tokenOut
            );
    }


    function poolExists(address token0, address token1, uint24 poolFee) private view returns (bool) {

        IUniswapV3Factory factory = IUniswapV3Factory(UNI_V3_FACTORY);
        return factory.getPool(token0, token1, poolFee) != NULL_ADDRESS;
    }

    function checkTokenSettings(address token, bool oneStep, uint24 poolFee) private view {

        require(token != NULL_ADDRESS, "UniswapV3OracleSimple: token cannot be null");
        require(poolFee > 0, "UniswapV3OracleSimple: poolFee must be > 0");

        address tokenToCheck = indexToken;
        if (!oneStep) {
            tokenToCheck = WETH;

            require(poolExists(WETH, indexToken, ethPoolFee), "UniswapV3OracleSimple: unknown ETH/indexToken pair");
        }

        require(poolExists(token, tokenToCheck, poolFee), "UniswapV3OracleSimple: unknown pair");
    }

    function registerToken(address token, bool oneStep, uint32 period, uint24 poolFee) external onlyOwner {

        checkTokenSettings(token, oneStep, poolFee);
        registeredTokensSet.insert(token, "UniswapV3OracleSimple: token is already registered");
        Settings storage s = registeredTokens[token];
        s.oneStep = oneStep;
        s.period = period;
        s.poolFee = poolFee;
        emit RegisterToken(msg.sender, token, oneStep, period, poolFee);
    }

    function reregisterToken(address token, bool oneStep, uint32 period, uint24 poolFee) external onlyOwner {

        require(registeredTokensSet.exists(token), "UniswapV3OracleSimple: token hasn't been registered before");
        checkTokenSettings(token, oneStep, poolFee);
        Settings storage s = registeredTokens[token];
        s.oneStep = oneStep;
        s.period = period;
        s.poolFee = poolFee;

        emit ReregisterToken(msg.sender, token, oneStep, period, poolFee);
    }
}