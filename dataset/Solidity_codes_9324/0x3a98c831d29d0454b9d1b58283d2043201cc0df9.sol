




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
}





abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}





interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}





library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}






contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

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





library AddressArrayUtils {

    function indexOf(address[] memory A, address a) internal pure returns (uint256, bool) {
        uint256 length = A.length;
        for (uint256 i = 0; i < length; i++) {
            if (A[i] == a) {
                return (i, true);
            }
        }
        return (uint256(-1), false);
    }

    function contains(address[] memory A, address a) internal pure returns (bool) {
        (, bool isIn) = indexOf(A, a);
        return isIn;
    }

    function hasDuplicate(address[] memory A) internal pure returns(bool) {
        require(A.length > 0, "A is empty");

        for (uint256 i = 0; i < A.length - 1; i++) {
            address current = A[i];
            for (uint256 j = i + 1; j < A.length; j++) {
                if (current == A[j]) {
                    return true;
                }
            }
        }
        return false;
    }

    function remove(address[] memory A, address a)
        internal
        pure
        returns (address[] memory)
    {
        (uint256 index, bool isIn) = indexOf(A, a);
        if (!isIn) {
            revert("Address not in array.");
        } else {
            (address[] memory _A,) = pop(A, index);
            return _A;
        }
    }

    function pop(address[] memory A, uint256 index)
        internal
        pure
        returns (address[] memory, address)
    {
        uint256 length = A.length;
        require(index < A.length, "Index must be < A length");
        address[] memory newAddresses = new address[](length - 1);
        for (uint256 i = 0; i < index; i++) {
            newAddresses[i] = A[i];
        }
        for (uint256 j = index + 1; j < length; j++) {
            newAddresses[j - 1] = A[j];
        }
        return (newAddresses, A[index]);
    }

    function extend(address[] memory A, address[] memory B) internal pure returns (address[] memory) {
        uint256 aLength = A.length;
        uint256 bLength = B.length;
        address[] memory newAddresses = new address[](aLength + bLength);
        for (uint256 i = 0; i < aLength; i++) {
            newAddresses[i] = A[i];
        }
        for (uint256 j = 0; j < bLength; j++) {
            newAddresses[aLength + j] = B[j];
        }
        return newAddresses;
    }
}



pragma experimental "ABIEncoderV2";

interface IICManagerV2 {
    function methodologist() external returns(address);

    function operator() external returns(address);

    function interactModule(address _module, bytes calldata _encoded) external;
}





abstract contract BaseAdapter {


    modifier onlyOperator() {
        require(msg.sender == manager.operator(), "Must be operator");
        _;
    }

    modifier onlyMethodologist() {
        require(msg.sender == manager.methodologist(), "Must be methodologist");
        _;
    }

    modifier onlyEOA() {
        require(msg.sender == tx.origin, "Caller must be EOA Address");
        _;
    }


    IICManagerV2 public manager;


    
    function invokeManager(address _module, bytes memory _encoded) internal {
        manager.interactModule(_module, _encoded);
    }
}





interface ICErc20 is IERC20 {

    function borrowBalanceCurrent(address _account) external returns (uint256);

    function borrowBalanceStored(address _account) external view returns (uint256);

    function balanceOfUnderlying(address _account) external returns (uint256);

    function exchangeRateCurrent() external returns (uint256);

    function exchangeRateStored() external view returns (uint256);

    function underlying() external returns (address);

    function mint(uint256 _mintAmount) external returns (uint256);

    function redeem(uint256 _redeemTokens) external returns (uint256);

    function redeemUnderlying(uint256 _redeemAmount) external returns (uint256);

    function borrow(uint256 _borrowAmount) external returns (uint256);

    function repayBorrow(uint256 _repayAmount) external returns (uint256);
}




interface IComptroller {

    function enterMarkets(address[] memory cTokens) external returns (uint256[] memory);

    function exitMarket(address cTokenAddress) external returns (uint256);

    function claimComp(address holder) external;

    function markets(address cTokenAddress) external view returns (bool, uint256, bool);
}





interface ISetToken is IERC20 {


    enum ModuleState {
        NONE,
        PENDING,
        INITIALIZED
    }

    struct Position {
        address component;
        address module;
        int256 unit;
        uint8 positionState;
        bytes data;
    }

    struct ComponentPosition {
      int256 virtualUnit;
      address[] externalPositionModules;
      mapping(address => ExternalPosition) externalPositions;
    }

    struct ExternalPosition {
      int256 virtualUnit;
      bytes data;
    }


    
    function addComponent(address _component) external;
    function removeComponent(address _component) external;
    function editDefaultPositionUnit(address _component, int256 _realUnit) external;
    function addExternalPositionModule(address _component, address _positionModule) external;
    function removeExternalPositionModule(address _component, address _positionModule) external;
    function editExternalPositionUnit(address _component, address _positionModule, int256 _realUnit) external;
    function editExternalPositionData(address _component, address _positionModule, bytes calldata _data) external;

    function invoke(address _target, uint256 _value, bytes calldata _data) external returns(bytes memory);

    function editPositionMultiplier(int256 _newMultiplier) external;

    function mint(address _account, uint256 _quantity) external;
    function burn(address _account, uint256 _quantity) external;

    function lock() external;
    function unlock() external;

    function addModule(address _module) external;
    function removeModule(address _module) external;
    function initializeModule() external;

    function setManager(address _manager) external;

    function manager() external view returns (address);
    function moduleStates(address _module) external view returns (ModuleState);
    function getModules() external view returns (address[] memory);
    
    function getDefaultPositionRealUnit(address _component) external view returns(int256);
    function getExternalPositionRealUnit(address _component, address _positionModule) external view returns(int256);
    function getComponents() external view returns(address[] memory);
    function getExternalPositionModules(address _component) external view returns(address[] memory);
    function getExternalPositionData(address _component, address _positionModule) external view returns(bytes memory);
    function isExternalPositionModule(address _component, address _module) external view returns(bool);
    function isComponent(address _component) external view returns(bool);
    
    function positionMultiplier() external view returns (int256);
    function getPositions() external view returns (Position[] memory);
    function getTotalComponentRealUnits(address _component) external view returns(int256);

    function isInitializedModule(address _module) external view returns(bool);
    function isPendingModule(address _module) external view returns(bool);
    function isLocked() external view returns (bool);
}





interface ICompoundLeverageModule {
    function sync(
        ISetToken _setToken
    ) external;

    function lever(
        ISetToken _setToken,
        address _borrowAsset,
        address _collateralAsset,
        uint256 _borrowQuantity,
        uint256 _minReceiveQuantity,
        string memory _tradeAdapterName,
        bytes memory _tradeData
    ) external;

    function delever(
        ISetToken _setToken,
        address _collateralAsset,
        address _repayAsset,
        uint256 _redeemQuantity,
        uint256 _minRepayQuantity,
        string memory _tradeAdapterName,
        bytes memory _tradeData
    ) external;

    function gulp(
        ISetToken _setToken,
        address _collateralAsset,
        uint256 _minNotionalReceiveQuantity,
        string memory _tradeAdapterName,
        bytes memory _tradeData
    ) external;
}




interface ICompoundPriceOracle {

    function getUnderlyingPrice(address _asset) external view returns(uint256);
}




library SignedSafeMath {
    int256 constant private _INT256_MIN = -2**255;

    function mul(int256 a, int256 b) internal pure returns (int256) {
        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == _INT256_MIN), "SignedSafeMath: multiplication overflow");

        int256 c = a * b;
        require(c / a == b, "SignedSafeMath: multiplication overflow");

        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != 0, "SignedSafeMath: division by zero");
        require(!(b == -1 && a == _INT256_MIN), "SignedSafeMath: division overflow");

        int256 c = a / b;

        return c;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a), "SignedSafeMath: subtraction overflow");

        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a), "SignedSafeMath: addition overflow");

        return c;
    }
}








library PreciseUnitMath {
    using SafeMath for uint256;
    using SignedSafeMath for int256;

    uint256 constant internal PRECISE_UNIT = 10 ** 18;
    int256 constant internal PRECISE_UNIT_INT = 10 ** 18;

    uint256 constant internal MAX_UINT_256 = type(uint256).max;
    int256 constant internal MAX_INT_256 = type(int256).max;
    int256 constant internal MIN_INT_256 = type(int256).min;

    function preciseUnit() internal pure returns (uint256) {
        return PRECISE_UNIT;
    }

    function preciseUnitInt() internal pure returns (int256) {
        return PRECISE_UNIT_INT;
    }

    function maxUint256() internal pure returns (uint256) {
        return MAX_UINT_256;
    }

    function maxInt256() internal pure returns (int256) {
        return MAX_INT_256;
    }

    function minInt256() internal pure returns (int256) {
        return MIN_INT_256;
    }

    function preciseMul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a.mul(b).div(PRECISE_UNIT);
    }

    function preciseMul(int256 a, int256 b) internal pure returns (int256) {
        return a.mul(b).div(PRECISE_UNIT_INT);
    }

    function preciseMulCeil(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0 || b == 0) {
            return 0;
        }
        return a.mul(b).sub(1).div(PRECISE_UNIT).add(1);
    }

    function preciseDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        return a.mul(PRECISE_UNIT).div(b);
    }


    function preciseDiv(int256 a, int256 b) internal pure returns (int256) {
        return a.mul(PRECISE_UNIT_INT).div(b);
    }

    function preciseDivCeil(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "Cant divide by 0");

        return a > 0 ? a.mul(PRECISE_UNIT).sub(1).div(b).add(1) : 0;
    }

    function divDown(int256 a, int256 b) internal pure returns (int256) {
        require(b != 0, "Cant divide by 0");
        require(a != MIN_INT_256 || b != -1, "Invalid input");

        int256 result = a.div(b);
        if (a ^ b < 0 && a % b != 0) {
            result -= 1;
        }

        return result;
    }

    function conservativePreciseMul(int256 a, int256 b) internal pure returns (int256) {
        return divDown(a.mul(b), PRECISE_UNIT_INT);
    }

    function conservativePreciseDiv(int256 a, int256 b) internal pure returns (int256) {
        return divDown(a.mul(PRECISE_UNIT_INT), b);
    }

    function safePower(
        uint256 a,
        uint256 pow
    )
        internal
        pure
        returns (uint256)
    {
        require(a > 0, "Value must be positive");

        uint256 result = 1;
        for (uint256 i = 0; i < pow; i++){
            uint256 previousResult = result;

            result = previousResult.mul(a);
        }

        return result;
    }
}



pragma solidity 0.6.10;




contract FlexibleLeverageStrategyAdapter is BaseAdapter {
    using Address for address;
    using AddressArrayUtils for address[];
    using PreciseUnitMath for uint256;
    using SafeMath for uint256;


    enum ShouldRebalance {
        NONE,
        REBALANCE,
        RIPCORD
    }


    struct ActionInfo {
        uint256 collateralPrice;                   // Price of underlying in precise units (10e18)
        uint256 borrowPrice;                       // Price of underlying in precise units (10e18)
        uint256 collateralBalance;                 // Balance of underlying held in Compound in base units (e.g. USDC 10e6)
        uint256 borrowBalance;                     // Balance of underlying borrowed from Compound in base units
        uint256 collateralValue;                   // Valuation in USD adjusted for decimals in precise units (10e18)
        uint256 borrowValue;                       // Valuation in USD adjusted for decimals in precise units (10e18)
        uint256 setTotalSupply;                    // Total supply of SetToken
    }

    struct LeverageTokenSettings {
        ISetToken setToken;                              // Instance of leverage token
        ICompoundLeverageModule leverageModule;          // Instance of Compound leverage module
        IICManagerV2 manager;                            // Instance of manager contract of SetToken

        IComptroller comptroller;                        // Instance of Compound Comptroller
        ICompoundPriceOracle priceOracle;                // Compound open oracle feed

        ICErc20 targetCollateralCToken;                  // Instance of target collateral cToken asset
        ICErc20 targetBorrowCToken;                      // Instance of target borrow cToken asset
        address collateralAsset;                         // Address of underlying collateral
        address borrowAsset;                             // Address of underlying borrow asset
        
        uint256 targetLeverageRatio;                     // Long term target ratio in precise units (10e18)
        uint256 minLeverageRatio;                        // In precise units (10e18). If current leverage is below, rebalance target is this ratio
        uint256 maxLeverageRatio;                        // In precise units (10e18). If current leverage is above, rebalance target is this ratio
        uint256 recenteringSpeed;                        // % at which to rebalance back to target leverage in precise units (10e18)
        uint256 rebalanceInterval;                       // Period of time required since last rebalance timestamp in seconds

        uint256 unutilizedLeveragePercentage;            // Percent of max borrow left unutilized in precise units (1% = 10e16)
        uint256 twapMaxTradeSize;                        // Max trade size in collateral base units
        uint256 twapCooldownPeriod;                      // Cooldown period required since last trade timestamp in seconds
        uint256 slippageTolerance;                       // % in precise units to price min token receive amount from trade quantities

        uint256 etherReward;                             // ETH reward for incentivized rebalances
        uint256 incentivizedLeverageRatio;               // Leverage ratio for incentivized rebalances
        uint256 incentivizedSlippageTolerance;           // Slippage tolerance percentage for incentivized rebalances
        uint256 incentivizedTwapCooldownPeriod;          // TWAP cooldown in seconds for incentivized rebalances
        uint256 incentivizedTwapMaxTradeSize;            // Max trade size for incentivized rebalances in collateral base units

        string exchangeName;                             // Name of exchange that is being used for leverage
        bytes exchangeData;                              // Arbitrary exchange data passed into rebalance function
    }


    event TraderStatusUpdated(address indexed _trader, bool _status);
    event AnyoneTradeUpdated(bool indexed _status);


    modifier onlyAllowedTrader(address _caller) {
        require(_isAllowedTrader(_caller), "Address not permitted to trade");
        _;
    }

    modifier noRebalanceInProgress() {
        require(twapLeverageRatio == 0, "Rebalance is currently in progress");
        _;
    }


    ISetToken public setToken;
    ICompoundLeverageModule public leverageModule;

    IComptroller public comptroller;
    ICompoundPriceOracle public priceOracle;

    ICErc20 public targetCollateralCToken;
    ICErc20 public targetBorrowCToken;
    address public collateralAsset;
    address public borrowAsset;
    uint256 internal collateralAssetDecimals;
    uint256 internal borrowAssetDecimals;
    
    uint256 public targetLeverageRatio;
    uint256 public minLeverageRatio;
    uint256 public maxLeverageRatio;
    uint256 public recenteringSpeed;
    uint256 public rebalanceInterval;

    uint256 public unutilizedLeveragePercentage;
    uint256 public twapMaxTradeSize;
    uint256 public twapCooldownPeriod;
    uint256 public slippageTolerance;

    uint256 public etherReward;
    uint256 public incentivizedLeverageRatio;
    uint256 public incentivizedSlippageTolerance;
    uint256 public incentivizedTwapCooldownPeriod;
    uint256 public incentivizedTwapMaxTradeSize;

    string public exchangeName;
    bytes public exchangeData;

    uint256 public twapLeverageRatio;

    uint256 public lastTradeTimestamp;

    bool public anyoneTrade;

    mapping(address => bool) public tradeAllowList;


    constructor(LeverageTokenSettings memory _leverageTokenSettings) public {  
        require (
            _leverageTokenSettings.minLeverageRatio <= _leverageTokenSettings.targetLeverageRatio,
            "Must be valid min leverage"
        );
        require (
            _leverageTokenSettings.maxLeverageRatio >= _leverageTokenSettings.targetLeverageRatio,
            "Must be valid max leverage"
        );
        require (
            _leverageTokenSettings.recenteringSpeed <= PreciseUnitMath.preciseUnit() && _leverageTokenSettings.recenteringSpeed > 0,
            "Must be valid recentering speed"
        );
        require (
            _leverageTokenSettings.unutilizedLeveragePercentage <= PreciseUnitMath.preciseUnit(),
            "Unutilized leverage must be <100%"
        );
        require (
            _leverageTokenSettings.slippageTolerance <= PreciseUnitMath.preciseUnit(),
            "Slippage tolerance must be <100%"
        );
        require (
            _leverageTokenSettings.incentivizedSlippageTolerance <= PreciseUnitMath.preciseUnit(),
            "Incentivized slippage tolerance must be <100%"
        );
        require (
            _leverageTokenSettings.incentivizedLeverageRatio >= _leverageTokenSettings.maxLeverageRatio,
            "Incentivized leverage ratio must be > max leverage ratio"
        );

        setToken = _leverageTokenSettings.setToken;
        leverageModule = _leverageTokenSettings.leverageModule;
        manager = _leverageTokenSettings.manager;

        comptroller = _leverageTokenSettings.comptroller;
        priceOracle = _leverageTokenSettings.priceOracle;
        targetCollateralCToken = _leverageTokenSettings.targetCollateralCToken;
        targetBorrowCToken = _leverageTokenSettings.targetBorrowCToken;
        collateralAsset = _leverageTokenSettings.collateralAsset;
        borrowAsset = _leverageTokenSettings.borrowAsset;

        collateralAssetDecimals = ERC20(collateralAsset).decimals();
        borrowAssetDecimals = ERC20(borrowAsset).decimals();

        targetLeverageRatio = _leverageTokenSettings.targetLeverageRatio;
        minLeverageRatio = _leverageTokenSettings.minLeverageRatio;
        maxLeverageRatio = _leverageTokenSettings.maxLeverageRatio;
        recenteringSpeed = _leverageTokenSettings.recenteringSpeed;
        rebalanceInterval = _leverageTokenSettings.rebalanceInterval;

        unutilizedLeveragePercentage = _leverageTokenSettings.unutilizedLeveragePercentage;
        twapMaxTradeSize = _leverageTokenSettings.twapMaxTradeSize;
        twapCooldownPeriod = _leverageTokenSettings.twapCooldownPeriod;
        slippageTolerance = _leverageTokenSettings.slippageTolerance;

        incentivizedTwapMaxTradeSize = _leverageTokenSettings.incentivizedTwapMaxTradeSize;
        incentivizedTwapCooldownPeriod = _leverageTokenSettings.incentivizedTwapCooldownPeriod;
        incentivizedSlippageTolerance = _leverageTokenSettings.incentivizedSlippageTolerance;
        etherReward = _leverageTokenSettings.etherReward;
        incentivizedLeverageRatio = _leverageTokenSettings.incentivizedLeverageRatio;

        exchangeName = _leverageTokenSettings.exchangeName;
        exchangeData = _leverageTokenSettings.exchangeData;
    }


    function engage() external onlyOperator {
        ActionInfo memory engageInfo = _createActionInfo();

        require(engageInfo.setTotalSupply > 0, "SetToken must have > 0 supply");
        require(engageInfo.collateralBalance > 0, "Collateral balance must be > 0");
        require(engageInfo.borrowBalance == 0, "Debt must be 0");

        _lever(
            PreciseUnitMath.preciseUnit(), // 1x leverage in precise units
            targetLeverageRatio,
            engageInfo
        ); 
    }

    function rebalance() external onlyEOA onlyAllowedTrader(msg.sender) {

        ActionInfo memory rebalanceInfo = _createActionInfo();
        require(rebalanceInfo.borrowBalance > 0, "Borrow balance must exist");

        uint256 currentLeverageRatio = _calculateCurrentLeverageRatio(
            rebalanceInfo.collateralValue,
            rebalanceInfo.borrowValue
        );

        require(currentLeverageRatio < incentivizedLeverageRatio, "Must call ripcord");

        uint256 newLeverageRatio;
        if (twapLeverageRatio != 0) {
            if (_updateStateAndExitIfAdvantageous(currentLeverageRatio)) {
                return;
            }

            require(lastTradeTimestamp.add(twapCooldownPeriod) < block.timestamp, "Cooldown period must have elapsed");

            newLeverageRatio = twapLeverageRatio;
        } else {
            require(
                block.timestamp.sub(lastTradeTimestamp) > rebalanceInterval
                || currentLeverageRatio > maxLeverageRatio
                || currentLeverageRatio < minLeverageRatio,
                "Rebalance interval not yet elapsed"
            );
            newLeverageRatio = _calculateNewLeverageRatio(currentLeverageRatio);
        }
        
        if (newLeverageRatio < currentLeverageRatio) {
            _delever(
                currentLeverageRatio,
                newLeverageRatio,
                rebalanceInfo,
                slippageTolerance,
                twapMaxTradeSize
            );
        } else {
            _lever(
                currentLeverageRatio,
                newLeverageRatio,
                rebalanceInfo
            );
        }
    }

    function ripcord() external onlyEOA {
        if (twapLeverageRatio != 0) {
            require(
                lastTradeTimestamp.add(incentivizedTwapCooldownPeriod) < block.timestamp,
                "Incentivized cooldown period must have elapsed"
            );
        }

        ActionInfo memory ripcordInfo = _createActionInfo();
        require(ripcordInfo.borrowBalance > 0, "Borrow balance must exist");

        uint256 currentLeverageRatio = _calculateCurrentLeverageRatio(
            ripcordInfo.collateralValue,
            ripcordInfo.borrowValue
        );

        require(currentLeverageRatio >= incentivizedLeverageRatio, "Must be above incentivized leverage ratio");
        
        _delever(
            currentLeverageRatio,
            maxLeverageRatio, // The target new leverage ratio is always the max leverage ratio
            ripcordInfo,
            incentivizedSlippageTolerance,
            incentivizedTwapMaxTradeSize
        );

        _transferEtherRewardToCaller(etherReward);
    }

    function disengage() external onlyOperator {
        ActionInfo memory disengageInfo = _createActionInfo();

        require(disengageInfo.setTotalSupply > 0, "SetToken must have > 0 supply");
        require(disengageInfo.collateralBalance > 0, "Collateral balance must be > 0");
        require(disengageInfo.borrowBalance > 0, "Borrow balance must exist");

        uint256 currentLeverageRatio = _calculateCurrentLeverageRatio(
            disengageInfo.collateralValue,
            disengageInfo.borrowValue
        );

        _delever(
            currentLeverageRatio,
            PreciseUnitMath.preciseUnit(), // This is reducing back to a leverage ratio of 1
            disengageInfo,
            slippageTolerance,
            twapMaxTradeSize
        );
    }

    function gulp() external noRebalanceInProgress onlyEOA {
        bytes memory gulpCallData = abi.encodeWithSignature(
            "gulp(address,address,uint256,string,bytes)",
            address(setToken),
            collateralAsset,
            0,
            exchangeName,
            exchangeData
        );

        invokeManager(address(leverageModule), gulpCallData);
    }

    function setMinLeverageRatio(uint256 _minLeverageRatio) external onlyOperator noRebalanceInProgress {
        minLeverageRatio = _minLeverageRatio;
    }

    function setMaxLeverageRatio(uint256 _maxLeverageRatio) external onlyOperator noRebalanceInProgress {
        maxLeverageRatio = _maxLeverageRatio;
    }

    function setRecenteringSpeedPercentage(uint256 _recenteringSpeed) external onlyOperator noRebalanceInProgress {
        recenteringSpeed = _recenteringSpeed;
    }

    function setRebalanceInterval(uint256 _rebalanceInterval) external onlyOperator noRebalanceInProgress {
        rebalanceInterval = _rebalanceInterval;
    }

    function setUnutilizedLeveragePercentage(uint256 _unutilizedLeveragePercentage) external onlyOperator noRebalanceInProgress {
        unutilizedLeveragePercentage = _unutilizedLeveragePercentage;
    }

    function setMaxTradeSize(uint256 _twapMaxTradeSize) external onlyOperator noRebalanceInProgress {
        twapMaxTradeSize = _twapMaxTradeSize;
    }

    function setSlippageTolerance(uint256 _slippageTolerance) external onlyOperator noRebalanceInProgress {
        slippageTolerance = _slippageTolerance;
    }

    function setCooldownPeriod(uint256 _twapCooldownPeriod) external onlyOperator noRebalanceInProgress {
        twapCooldownPeriod = _twapCooldownPeriod;
    }

    function setIncentivizedMaxTradeSize(uint256 _incentivizedTwapMaxTradeSize) external onlyOperator noRebalanceInProgress {
        incentivizedTwapMaxTradeSize = _incentivizedTwapMaxTradeSize;
    }

    function setIncentivizedCooldownPeriod(uint256 _incentivizedTwapCooldownPeriod) external onlyOperator noRebalanceInProgress {
        incentivizedTwapCooldownPeriod = _incentivizedTwapCooldownPeriod;
    }

    function setIncentivizedLeverageRatio(uint256 _incentivizedLeverageRatio) external onlyOperator noRebalanceInProgress {
        incentivizedLeverageRatio = _incentivizedLeverageRatio;
    }

    function setIncentivizedSlippageTolerance(uint256 _incentivizedSlippageTolerance) external onlyOperator noRebalanceInProgress {
        incentivizedSlippageTolerance = _incentivizedSlippageTolerance;
    }

    function setEtherReward(uint256 _etherReward) external onlyOperator noRebalanceInProgress {
        etherReward = _etherReward;
    }

    function withdrawEtherBalance() external onlyOperator noRebalanceInProgress {
        msg.sender.transfer(address(this).balance);
    }

    function setExchange(string calldata _exchangeName) external onlyOperator noRebalanceInProgress {
        exchangeName = _exchangeName;
    }

    function setExchangeData(bytes calldata _exchangeData) external onlyOperator noRebalanceInProgress {
        exchangeData = _exchangeData;
    }

    function updateTraderStatus(address[] calldata _traders, bool[] calldata _statuses) external onlyOperator noRebalanceInProgress {
        require(_traders.length == _statuses.length, "Array length mismatch");
        require(_traders.length > 0, "Array length must be > 0");
        require(!_traders.hasDuplicate(), "Cannot duplicate traders");

        for (uint256 i = 0; i < _traders.length; i++) {
            address trader = _traders[i];
            bool status = _statuses[i];
            tradeAllowList[trader] = status;
            emit TraderStatusUpdated(trader, status);
        }
    }

    function updateAnyoneTrade(bool _status) external onlyOperator noRebalanceInProgress {
        anyoneTrade = _status;
        emit AnyoneTradeUpdated(_status);
    }

    receive() external payable {}


    function getCurrentLeverageRatio() public view returns(uint256) {
        ActionInfo memory currentLeverageInfo = _createActionInfo();

        return _calculateCurrentLeverageRatio(currentLeverageInfo.collateralValue, currentLeverageInfo.borrowValue);
    }

    function getCurrentEtherIncentive() external view returns(uint256) {
        uint256 currentLeverageRatio = getCurrentLeverageRatio();

        if (currentLeverageRatio >= incentivizedLeverageRatio) {
            return etherReward < address(this).balance ? etherReward : address(this).balance;
        } else {
            return 0;
        }
    }

    function shouldRebalance() external view returns(ShouldRebalance) {
        uint256 currentLeverageRatio = getCurrentLeverageRatio();

        if (twapLeverageRatio != 0) {
            if (
                currentLeverageRatio >= incentivizedLeverageRatio
                && lastTradeTimestamp.add(incentivizedTwapCooldownPeriod) < block.timestamp
            ) {
                return ShouldRebalance.RIPCORD;
            }

            if (
                currentLeverageRatio < incentivizedLeverageRatio
                && lastTradeTimestamp.add(twapCooldownPeriod) < block.timestamp
            ) {
                return ShouldRebalance.REBALANCE;
            }
        } else {
            if (currentLeverageRatio >= incentivizedLeverageRatio) {
                return ShouldRebalance.RIPCORD;
            }

            if (
                block.timestamp.sub(lastTradeTimestamp) > rebalanceInterval
                || currentLeverageRatio > maxLeverageRatio
                || currentLeverageRatio < minLeverageRatio
            ) {
                return ShouldRebalance.REBALANCE;
            }
        }

        return ShouldRebalance.NONE;
    }


    function _lever(
        uint256 _currentLeverageRatio,
        uint256 _newLeverageRatio,
        ActionInfo memory _actionInfo
    )
        internal
    {
        uint256 totalRebalanceNotional = _newLeverageRatio
            .sub(_currentLeverageRatio)
            .preciseDiv(_currentLeverageRatio)
            .preciseMul(_actionInfo.collateralBalance);

        uint256 maxBorrow = _calculateMaxBorrowCollateral(_actionInfo, true);

        uint256 chunkRebalanceNotional = Math.min(Math.min(maxBorrow, totalRebalanceNotional), twapMaxTradeSize);

        uint256 collateralRebalanceUnits = chunkRebalanceNotional.preciseDiv(_actionInfo.setTotalSupply);

        uint256 borrowUnits = _calculateBorrowUnits(collateralRebalanceUnits, _actionInfo);

        uint256 minReceiveUnits = _calculateMinCollateralReceiveUnits(collateralRebalanceUnits);

        bytes memory leverCallData = abi.encodeWithSignature(
            "lever(address,address,address,uint256,uint256,string,bytes)",
            address(setToken),
            borrowAsset,
            collateralAsset,
            borrowUnits,
            minReceiveUnits,
            exchangeName,
            exchangeData
        );

        invokeManager(address(leverageModule), leverCallData);

        _updateTradeState(chunkRebalanceNotional, totalRebalanceNotional, _newLeverageRatio);
    }

    function _delever(
        uint256 _currentLeverageRatio,
        uint256 _newLeverageRatio,
        ActionInfo memory _actionInfo,
        uint256 _slippageTolerance,
        uint256 _twapMaxTradeSize
    )
        internal
    {
        uint256 totalRebalanceNotional = _currentLeverageRatio
            .sub(_newLeverageRatio)
            .preciseDiv(_currentLeverageRatio)
            .preciseMul(_actionInfo.collateralBalance);

        uint256 maxBorrow = _calculateMaxBorrowCollateral(_actionInfo, false);

        uint256 chunkRebalanceNotional = Math.min(Math.min(maxBorrow, totalRebalanceNotional), _twapMaxTradeSize);

        uint256 collateralRebalanceUnits = chunkRebalanceNotional.preciseDiv(_actionInfo.setTotalSupply);

        uint256 minRepayUnits = _calculateMinRepayUnits(collateralRebalanceUnits, _slippageTolerance, _actionInfo);

        bytes memory deleverCallData = abi.encodeWithSignature(
            "delever(address,address,address,uint256,uint256,string,bytes)",
            address(setToken),
            collateralAsset,
            borrowAsset,
            collateralRebalanceUnits,
            minRepayUnits,
            exchangeName,
            exchangeData
        );

        invokeManager(address(leverageModule), deleverCallData);

        _updateTradeState(chunkRebalanceNotional, totalRebalanceNotional, _newLeverageRatio);
    }

    function _updateStateAndExitIfAdvantageous(uint256 _currentLeverageRatio) internal returns (bool) {
        if (
            (twapLeverageRatio < targetLeverageRatio && _currentLeverageRatio >= twapLeverageRatio) 
            || (twapLeverageRatio > targetLeverageRatio && _currentLeverageRatio <= twapLeverageRatio)
        ) {
            _updateTradeState(0, 0, 0);

            return true;
        } else {
            return false;
        }
    }

    function _updateTradeState(
        uint256 _chunkRebalanceNotional,
        uint256 _totalRebalanceNotional,
        uint256 _newLeverageRatio
    )
        internal
    {
        lastTradeTimestamp = block.timestamp;

        if (_chunkRebalanceNotional == _totalRebalanceNotional) {
            delete twapLeverageRatio;
        }

        if(_chunkRebalanceNotional != _totalRebalanceNotional && _newLeverageRatio != twapLeverageRatio) {
            twapLeverageRatio = _newLeverageRatio;
        }
    }

    function _transferEtherRewardToCaller(uint256 _etherReward) internal {
        _etherReward < address(this).balance ? msg.sender.transfer(_etherReward) : msg.sender.transfer(address(this).balance);
    }

    function _createActionInfo() internal view returns(ActionInfo memory) {
        ActionInfo memory rebalanceInfo;

        rebalanceInfo.collateralPrice = priceOracle.getUnderlyingPrice(address(targetCollateralCToken));
        rebalanceInfo.borrowPrice = priceOracle.getUnderlyingPrice(address(targetBorrowCToken));

        uint256 cTokenBalance = targetCollateralCToken.balanceOf(address(setToken));
        rebalanceInfo.collateralBalance = cTokenBalance.preciseMul(targetCollateralCToken.exchangeRateStored());
        rebalanceInfo.borrowBalance = targetBorrowCToken.borrowBalanceStored(address(setToken));
        rebalanceInfo.collateralValue = rebalanceInfo.collateralPrice.preciseMul(rebalanceInfo.collateralBalance).preciseDiv(10 ** collateralAssetDecimals);
        rebalanceInfo.borrowValue = rebalanceInfo.borrowPrice.preciseMul(rebalanceInfo.borrowBalance).preciseDiv(10 ** borrowAssetDecimals);
        rebalanceInfo.setTotalSupply = setToken.totalSupply();

        return rebalanceInfo;
    }

    function _calculateNewLeverageRatio(uint256 _currentLeverageRatio) internal view returns(uint256) {
        uint256 a = targetLeverageRatio.preciseMul(recenteringSpeed);
        uint256 b = PreciseUnitMath.preciseUnit().sub(recenteringSpeed).preciseMul(_currentLeverageRatio);
        uint256 c = a.add(b);
        uint256 d = Math.min(c, maxLeverageRatio);
        return Math.max(minLeverageRatio, d);
    }

    function _calculateMaxBorrowCollateral(ActionInfo memory _actionInfo, bool _isLever) internal view returns(uint256) {
        ( , uint256 collateralFactorMantissa, ) = comptroller.markets(address(targetCollateralCToken));

        uint256 netBorrowLimit = _actionInfo.collateralValue
            .preciseMul(collateralFactorMantissa)
            .preciseMul(PreciseUnitMath.preciseUnit().sub(unutilizedLeveragePercentage));

        if (_isLever) {
            return netBorrowLimit
                .sub(_actionInfo.borrowValue)
                .preciseDiv(_actionInfo.collateralPrice)
                .preciseMul(10 ** collateralAssetDecimals);
        } else {
            return _actionInfo.collateralBalance
                .preciseMul(netBorrowLimit.sub(_actionInfo.borrowValue))
                .preciseDiv(netBorrowLimit);
        }
    }

    function _calculateBorrowUnits(uint256 _collateralRebalanceUnits, ActionInfo memory _actionInfo) internal view returns (uint256) {
        uint256 pairPrice = _actionInfo.collateralPrice.preciseDiv(_actionInfo.borrowPrice);
        return _collateralRebalanceUnits
            .preciseDiv(10 ** collateralAssetDecimals)
            .preciseMul(pairPrice)
            .preciseMul(10 ** borrowAssetDecimals);
    }

    function _calculateMinCollateralReceiveUnits(uint256 _collateralRebalanceUnits) internal view returns (uint256) {
        return _collateralRebalanceUnits.preciseMul(PreciseUnitMath.preciseUnit().sub(slippageTolerance));
    }

    function _calculateMinRepayUnits(uint256 _collateralRebalanceUnits, uint256 _slippageTolerance, ActionInfo memory _actionInfo) internal view returns (uint256) {
        uint256 pairPrice = _actionInfo.collateralPrice.preciseDiv(_actionInfo.borrowPrice);

        return _collateralRebalanceUnits
            .preciseDiv(10 ** collateralAssetDecimals)
            .preciseMul(pairPrice)
            .preciseMul(10 ** borrowAssetDecimals)
            .preciseMul(PreciseUnitMath.preciseUnit().sub(_slippageTolerance));
    }

    function _calculateCurrentLeverageRatio(
        uint256 _collateralValue,
        uint256 _borrowValue
    )
        internal
        pure
        returns(uint256)
    {
        return _collateralValue.preciseDiv(_collateralValue.sub(_borrowValue));
    }

    function _isAllowedTrader(address _caller) internal view virtual returns (bool) {
        return anyoneTrade || tradeAllowList[_caller];
    }

}