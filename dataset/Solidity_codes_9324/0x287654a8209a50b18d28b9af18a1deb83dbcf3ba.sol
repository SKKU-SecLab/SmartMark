
pragma solidity >=0.7.2;
pragma experimental ABIEncoderV2;


interface AggregatorV3Interface {


  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);


  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );


}

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
}

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
}

library ProtocolAdapterTypes {

    enum OptionType {Invalid, Put, Call}

    enum PurchaseMethod {Invalid, Contract, ZeroEx}

    struct OptionTerms {
        address underlying;
        address strikeAsset;
        address collateralAsset;
        uint256 expiry;
        uint256 strikePrice;
        ProtocolAdapterTypes.OptionType optionType;
        address paymentToken;
    }

    struct ZeroExOrder {
        address exchangeAddress;
        address buyTokenAddress;
        address sellTokenAddress;
        address allowanceTarget;
        uint256 protocolFee;
        uint256 makerAssetAmount;
        uint256 takerAssetAmount;
        bytes swapData;
    }
}

interface IProtocolAdapter {

    event Purchased(
        address indexed caller,
        string indexed protocolName,
        address indexed underlying,
        uint256 amount,
        uint256 optionID
    );

    event Exercised(
        address indexed caller,
        address indexed options,
        uint256 indexed optionID,
        uint256 amount,
        uint256 exerciseProfit
    );

    function protocolName() external pure returns (string memory);


    function nonFungible() external pure returns (bool);


    function purchaseMethod()
        external
        pure
        returns (ProtocolAdapterTypes.PurchaseMethod);


    function optionsExist(ProtocolAdapterTypes.OptionTerms calldata optionTerms)
        external
        view
        returns (bool);


    function getOptionsAddress(
        ProtocolAdapterTypes.OptionTerms calldata optionTerms
    ) external view returns (address);


    function premium(
        ProtocolAdapterTypes.OptionTerms calldata optionTerms,
        uint256 purchaseAmount
    ) external view returns (uint256 cost);


    function exerciseProfit(
        address options,
        uint256 optionID,
        uint256 amount
    ) external view returns (uint256 profit);


    function canExercise(
        address options,
        uint256 optionID,
        uint256 amount
    ) external view returns (bool);


    function purchase(
        ProtocolAdapterTypes.OptionTerms calldata optionTerms,
        uint256 amount,
        uint256 maxCost
    ) external payable returns (uint256 optionID);


    function exercise(
        address options,
        uint256 optionID,
        uint256 amount,
        address recipient
    ) external payable;


    function createShort(
        ProtocolAdapterTypes.OptionTerms calldata optionTerms,
        uint256 amount
    ) external returns (uint256);


    function closeShort() external returns (uint256);

}

library GammaTypes {

    struct Vault {
        address[] shortOtokens;
        address[] longOtokens;
        address[] collateralAssets;
        uint256[] shortAmounts;
        uint256[] longAmounts;
        uint256[] collateralAmounts;
    }
}

interface OtokenInterface {

    function addressBook() external view returns (address);


    function underlyingAsset() external view returns (address);


    function strikeAsset() external view returns (address);


    function collateralAsset() external view returns (address);


    function strikePrice() external view returns (uint256);


    function expiryTimestamp() external view returns (uint256);


    function isPut() external view returns (bool);


    function init(
        address _addressBook,
        address _underlyingAsset,
        address _strikeAsset,
        address _collateralAsset,
        uint256 _strikePrice,
        uint256 _expiry,
        bool _isPut
    ) external;


    function mintOtoken(address account, uint256 amount) external;


    function burnOtoken(address account, uint256 amount) external;

}

interface IOtokenFactory {

    event OtokenCreated(
        address tokenAddress,
        address creator,
        address indexed underlying,
        address indexed strike,
        address indexed collateral,
        uint256 strikePrice,
        uint256 expiry,
        bool isPut
    );

    function oTokens(uint256 index) external returns (address);


    function getOtokensLength() external view returns (uint256);


    function getOtoken(
        address _underlyingAsset,
        address _strikeAsset,
        address _collateralAsset,
        uint256 _strikePrice,
        uint256 _expiry,
        bool _isPut
    ) external view returns (address);


    function createOtoken(
        address _underlyingAsset,
        address _strikeAsset,
        address _collateralAsset,
        uint256 _strikePrice,
        uint256 _expiry,
        bool _isPut
    ) external returns (address);

}

interface IController {

    enum ActionType {
        OpenVault,
        MintShortOption,
        BurnShortOption,
        DepositLongOption,
        WithdrawLongOption,
        DepositCollateral,
        WithdrawCollateral,
        SettleVault,
        Redeem,
        Call
    }

    struct ActionArgs {
        ActionType actionType;
        address owner;
        address secondAddress;
        address asset;
        uint256 vaultId;
        uint256 amount;
        uint256 index;
        bytes data;
    }

    struct RedeemArgs {
        address receiver;
        address otoken;
        uint256 amount;
    }

    function getPayout(address _otoken, uint256 _amount)
        external
        view
        returns (uint256);


    function operate(ActionArgs[] calldata _actions) external;


    function getAccountVaultCounter(address owner)
        external
        view
        returns (uint256);


    function oracle() external view returns (address);


    function getVault(address _owner, uint256 _vaultId)
        external
        view
        returns (GammaTypes.Vault memory);


    function getProceed(address _owner, uint256 _vaultId)
        external
        view
        returns (uint256);


    function isSettlementAllowed(
        address _underlying,
        address _strike,
        address _collateral,
        uint256 _expiry
    ) external view returns (bool);

}

interface OracleInterface {

    function isLockingPeriodOver(address _asset, uint256 _expiryTimestamp)
        external
        view
        returns (bool);


    function isDisputePeriodOver(address _asset, uint256 _expiryTimestamp)
        external
        view
        returns (bool);


    function getExpiryPrice(address _asset, uint256 _expiryTimestamp)
        external
        view
        returns (uint256, bool);


    function getDisputer() external view returns (address);


    function getPricer(address _asset) external view returns (address);


    function getPrice(address _asset) external view returns (uint256);


    function getPricerLockingPeriod(address _pricer)
        external
        view
        returns (uint256);


    function getPricerDisputePeriod(address _pricer)
        external
        view
        returns (uint256);



    function setAssetPricer(address _asset, address _pricer) external;


    function setLockingPeriod(address _pricer, uint256 _lockingPeriod) external;


    function setDisputePeriod(address _pricer, uint256 _disputePeriod) external;


    function setExpiryPrice(
        address _asset,
        uint256 _expiryTimestamp,
        uint256 _price
    ) external;


    function disputeExpiryPrice(
        address _asset,
        uint256 _expiryTimestamp,
        uint256 _price
    ) external;


    function setDisputer(address _disputer) external;

}

interface IWETH {

    function deposit() external payable;


    function withdraw(uint256) external;


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

}


interface IUniswapV2Router01 {

    function factory() external pure returns (address);


    function WETH() external pure returns (address);


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );


    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );


    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);


    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);


    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);


    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);


    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);


    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);


    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);


    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);


    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);


    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);


    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

}

interface IUniswapV2Router02 is IUniswapV2Router01 {

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);


    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);


    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;


    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;


    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

}

contract DSMath {

    function add(uint x, uint y) internal pure returns (uint z) {

        require((z = x + y) >= x, "ds-math-add-overflow");
    }
    function sub(uint x, uint y) internal pure returns (uint z) {

        require((z = x - y) <= x, "ds-math-sub-underflow");
    }
    function mul(uint x, uint y) internal pure returns (uint z) {

        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }

    function min(uint x, uint y) internal pure returns (uint z) {

        return x <= y ? x : y;
    }
    function max(uint x, uint y) internal pure returns (uint z) {

        return x >= y ? x : y;
    }
    function imin(int x, int y) internal pure returns (int z) {

        return x <= y ? x : y;
    }
    function imax(int x, int y) internal pure returns (int z) {

        return x >= y ? x : y;
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function wmul(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, y), WAD / 2) / WAD;
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, y), RAY / 2) / RAY;
    }
    function wdiv(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, WAD), y / 2) / y;
    }
    function rdiv(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, RAY), y / 2) / y;
    }

    function rpow(uint x, uint n) internal pure returns (uint z) {

        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
}

interface IERC20Detailed is IERC20 {

    function decimals() external returns (uint8);

}

contract GammaAdapter is IProtocolAdapter, DSMath {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public immutable gammaController;

    address public immutable oTokenFactory;

    uint256 private constant SWAP_WINDOW = 900;

    string private constant _name = "OPYN_GAMMA";
    bool private constant _nonFungible = false;

    uint256 private constant OTOKEN_DECIMALS = 10**8;

    uint256 private constant SLIPPAGE_TOLERANCE = 0.75 ether;

    address public immutable MARGIN_POOL;

    AggregatorV3Interface public immutable USDCETHPriceFeed;

    address public immutable UNISWAP_ROUTER;

    address public immutable WETH;

    address public immutable USDC;

    address public immutable ZERO_EX_EXCHANGE_V3;

    constructor(
        address _oTokenFactory,
        address _gammaController,
        address _marginPool,
        address _usdcEthPriceFeed,
        address _uniswapRouter,
        address _weth,
        address _usdc,
        address _zeroExExchange
    ) {
        require(_oTokenFactory != address(0), "!_oTokenFactory");
        require(_gammaController != address(0), "!_gammaController");
        require(_marginPool != address(0), "!_marginPool");
        require(_usdcEthPriceFeed != address(0), "!_usdcEthPriceFeed");
        require(_uniswapRouter != address(0), "!_uniswapRouter");
        require(_weth != address(0), "!_weth");
        require(_usdc != address(0), "!_usdc");
        require(_zeroExExchange != address(0), "!_zeroExExchange");

        oTokenFactory = _oTokenFactory;
        gammaController = _gammaController;
        MARGIN_POOL = _marginPool;
        USDCETHPriceFeed = AggregatorV3Interface(_usdcEthPriceFeed);
        UNISWAP_ROUTER = _uniswapRouter;
        WETH = _weth;
        USDC = _usdc;
        ZERO_EX_EXCHANGE_V3 = _zeroExExchange;
    }

    receive() external payable {}

    function protocolName() external pure override returns (string memory) {

        return _name;
    }

    function nonFungible() external pure override returns (bool) {

        return _nonFungible;
    }

    function purchaseMethod()
        external
        pure
        override
        returns (ProtocolAdapterTypes.PurchaseMethod)
    {

        return ProtocolAdapterTypes.PurchaseMethod.ZeroEx;
    }

    function optionsExist(ProtocolAdapterTypes.OptionTerms calldata optionTerms)
        external
        view
        override
        returns (bool)
    {

        return lookupOToken(optionTerms) != address(0);
    }

    function getOptionsAddress(
        ProtocolAdapterTypes.OptionTerms calldata optionTerms
    ) external view override returns (address) {

        return lookupOToken(optionTerms);
    }

    function premium(ProtocolAdapterTypes.OptionTerms calldata, uint256)
        external
        pure
        override
        returns (uint256 cost)
    {

        return 0;
    }

    function exerciseProfit(
        address options,
        uint256,
        uint256 amount
    ) public view override returns (uint256 profit) {

        IController controller = IController(gammaController);
        OracleInterface oracle = OracleInterface(controller.oracle());
        OtokenInterface otoken = OtokenInterface(options);

        uint256 spotPrice = oracle.getPrice(otoken.underlyingAsset());
        uint256 strikePrice = otoken.strikePrice();
        bool isPut = otoken.isPut();

        if (!isPut && spotPrice <= strikePrice) {
            return 0;
        } else if (isPut && spotPrice >= strikePrice) {
            return 0;
        }

        return controller.getPayout(options, amount.div(10**10));
    }

    function canExercise(
        address options,
        uint256,
        uint256 amount
    ) public view override returns (bool) {

        OtokenInterface otoken = OtokenInterface(options);

        address underlying = otoken.underlyingAsset();
        uint256 expiry = otoken.expiryTimestamp();

        if (!isSettlementAllowed(underlying, expiry)) {
            return false;
        }
        if (exerciseProfit(options, 0, amount) > 0) {
            return true;
        }
        return false;
    }

    function purchase(
        ProtocolAdapterTypes.OptionTerms calldata,
        uint256,
        uint256
    ) external payable override returns (uint256) {}


    function purchaseWithZeroEx(
        ProtocolAdapterTypes.OptionTerms calldata optionTerms,
        ProtocolAdapterTypes.ZeroExOrder calldata zeroExOrder
    ) external payable {

        require(
            msg.value >= zeroExOrder.protocolFee,
            "Value cannot cover protocolFee"
        );
        require(
            zeroExOrder.sellTokenAddress == USDC,
            "Sell token has to be USDC"
        );

        IUniswapV2Router02 router = IUniswapV2Router02(UNISWAP_ROUTER);

        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = zeroExOrder.sellTokenAddress;

        (, int256 latestPrice, , , ) = USDCETHPriceFeed.latestRoundData();

        uint256 soldETH =
            zeroExOrder.takerAssetAmount.mul(uint256(latestPrice)).div(
                10**assetDecimals(zeroExOrder.sellTokenAddress)
            );

        router.swapETHForExactTokens{value: soldETH}(
            zeroExOrder.takerAssetAmount,
            path,
            address(this),
            block.timestamp + SWAP_WINDOW
        );

        require(
            IERC20(zeroExOrder.sellTokenAddress).balanceOf(address(this)) >=
                zeroExOrder.takerAssetAmount,
            "Not enough takerAsset balance"
        );

        IERC20(zeroExOrder.sellTokenAddress).safeApprove(
            zeroExOrder.allowanceTarget,
            0
        );
        IERC20(zeroExOrder.sellTokenAddress).safeApprove(
            zeroExOrder.allowanceTarget,
            zeroExOrder.takerAssetAmount
        );

        require(
            address(this).balance >= zeroExOrder.protocolFee,
            "Not enough balance for protocol fee"
        );

        (bool success, ) =
            ZERO_EX_EXCHANGE_V3.call{value: zeroExOrder.protocolFee}(
                zeroExOrder.swapData
            );

        require(success, "0x swap failed");

        require(
            IERC20(zeroExOrder.buyTokenAddress).balanceOf(address(this)) >=
                zeroExOrder.makerAssetAmount,
            "Not enough buyToken balance"
        );

        emit Purchased(
            msg.sender,
            _name,
            optionTerms.underlying,
            soldETH.add(zeroExOrder.protocolFee),
            0
        );
    }

    function exercise(
        address options,
        uint256,
        uint256 amount,
        address recipient
    ) public payable override {

        OtokenInterface otoken = OtokenInterface(options);

        require(
            block.timestamp >= otoken.expiryTimestamp(),
            "oToken not expired yet"
        );

        uint256 scaledAmount = amount.div(10**10);

        uint256 profit = exerciseProfit(options, 0, amount);

        require(profit > 0, "Not profitable to exercise");

        IController.ActionArgs memory action =
            IController.ActionArgs(
                IController.ActionType.Redeem,
                address(this), // owner
                address(this), // receiver -  we need this contract to receive so we can swap at the end
                options, // asset, otoken
                0, // vaultId
                scaledAmount,
                0, //index
                "" //data
            );

        IController.ActionArgs[] memory actions =
            new IController.ActionArgs[](1);
        actions[0] = action;

        IController(gammaController).operate(actions);

        uint256 profitInUnderlying =
            swapExercisedProfitsToUnderlying(options, profit, recipient);

        emit Exercised(msg.sender, options, 0, amount, profitInUnderlying);
    }

    function swapExercisedProfitsToUnderlying(
        address otokenAddress,
        uint256 profitInCollateral,
        address recipient
    ) internal returns (uint256 profitInUnderlying) {

        OtokenInterface otoken = OtokenInterface(otokenAddress);
        address collateral = otoken.collateralAsset();
        IERC20 collateralToken = IERC20(collateral);

        require(
            collateralToken.balanceOf(address(this)) >= profitInCollateral,
            "Not enough collateral from exercising"
        );

        IUniswapV2Router02 router = IUniswapV2Router02(UNISWAP_ROUTER);

        IWETH weth = IWETH(WETH);

        if (collateral == address(weth)) {
            profitInUnderlying = profitInCollateral;
            weth.withdraw(profitInCollateral);
            (bool success, ) = recipient.call{value: profitInCollateral}("");
            require(success, "Failed to transfer exercise profit");
        } else {
            require(collateral == USDC, "!USDC");

            address[] memory path = new address[](2);
            path[0] = collateral;
            path[1] = address(weth);

            (, int256 latestPrice, , , ) = USDCETHPriceFeed.latestRoundData();

            profitInUnderlying = wdiv(profitInCollateral, uint256(latestPrice))
                .mul(10**assetDecimals(collateral));

            require(profitInUnderlying > 0, "Swap is unprofitable");

            collateralToken.safeApprove(UNISWAP_ROUTER, 0);
            collateralToken.safeApprove(UNISWAP_ROUTER, profitInCollateral);

            uint256[] memory amountsOut =
                router.swapExactTokensForETH(
                    profitInCollateral,
                    wmul(profitInUnderlying, SLIPPAGE_TOLERANCE),
                    path,
                    recipient,
                    block.timestamp + SWAP_WINDOW
                );

            profitInUnderlying = amountsOut[1];
        }
    }

    function createShort(
        ProtocolAdapterTypes.OptionTerms calldata optionTerms,
        uint256 depositAmount
    ) external override returns (uint256) {

        IController controller = IController(gammaController);
        uint256 newVaultID =
            (controller.getAccountVaultCounter(address(this))).add(1);

        address oToken = lookupOToken(optionTerms);
        require(oToken != address(0), "Invalid oToken");

        address collateralAsset = optionTerms.collateralAsset;
        if (collateralAsset == address(0)) {
            collateralAsset = WETH;
        }
        IERC20 collateralToken = IERC20(collateralAsset);

        uint256 collateralDecimals =
            uint256(IERC20Detailed(collateralAsset).decimals());
        uint256 mintAmount;

        if (optionTerms.optionType == ProtocolAdapterTypes.OptionType.Call) {
            mintAmount = depositAmount;
            uint256 scaleBy = 10**(collateralDecimals.sub(8)); // oTokens have 8 decimals

            if (mintAmount > scaleBy && collateralDecimals > 8) {
                mintAmount = depositAmount.div(scaleBy); // scale down from 10**18 to 10**8
                require(
                    mintAmount > 0,
                    "Must deposit more than 10**8 collateral"
                );
            }
        } else {
            mintAmount = wdiv(depositAmount, optionTerms.strikePrice)
                .mul(OTOKEN_DECIMALS)
                .div(10**collateralDecimals);
        }

        collateralToken.safeApprove(MARGIN_POOL, 0);
        collateralToken.safeApprove(MARGIN_POOL, depositAmount);

        IController.ActionArgs[] memory actions =
            new IController.ActionArgs[](3);

        actions[0] = IController.ActionArgs(
            IController.ActionType.OpenVault,
            address(this), // owner
            address(this), // receiver -  we need this contract to receive so we can swap at the end
            address(0), // asset, otoken
            newVaultID, // vaultId
            0, // amount
            0, //index
            "" //data
        );

        actions[1] = IController.ActionArgs(
            IController.ActionType.DepositCollateral,
            address(this), // owner
            address(this), // address to transfer from
            collateralAsset, // deposited asset
            newVaultID, // vaultId
            depositAmount, // amount
            0, //index
            "" //data
        );

        actions[2] = IController.ActionArgs(
            IController.ActionType.MintShortOption,
            address(this), // owner
            address(this), // address to transfer to
            oToken, // deposited asset
            newVaultID, // vaultId
            mintAmount, // amount
            0, //index
            "" //data
        );

        controller.operate(actions);

        return mintAmount;
    }

    function closeShort() external override returns (uint256) {

        IController controller = IController(gammaController);

        uint256 vaultID = controller.getAccountVaultCounter(address(this));

        GammaTypes.Vault memory vault =
            controller.getVault(address(this), vaultID);

        require(vault.shortOtokens.length > 0, "No active short");

        IERC20 collateralToken = IERC20(vault.collateralAssets[0]);
        OtokenInterface otoken = OtokenInterface(vault.shortOtokens[0]);

        bool settlementAllowed =
            isSettlementAllowed(
                otoken.underlyingAsset(),
                otoken.expiryTimestamp()
            );

        uint256 startCollateralBalance =
            collateralToken.balanceOf(address(this));

        IController.ActionArgs[] memory actions;

        if (settlementAllowed) {
            actions = new IController.ActionArgs[](1);

            actions[0] = IController.ActionArgs(
                IController.ActionType.SettleVault,
                address(this), // owner
                address(this), // address to transfer to
                address(0), // not used
                vaultID, // vaultId
                0, // not used
                0, // not used
                "" // not used
            );

            controller.operate(actions);
        } else {
            actions = new IController.ActionArgs[](2);

            actions[0] = IController.ActionArgs(
                IController.ActionType.BurnShortOption,
                address(this), // owner
                address(this), // address to transfer to
                address(otoken), // otoken address
                vaultID, // vaultId
                vault.shortAmounts[0], // amount
                0, //index
                "" //data
            );

            actions[1] = IController.ActionArgs(
                IController.ActionType.WithdrawCollateral,
                address(this), // owner
                address(this), // address to transfer to
                address(collateralToken), // withdrawn asset
                vaultID, // vaultId
                vault.collateralAmounts[0], // amount
                0, //index
                "" //data
            );

            controller.operate(actions);
        }

        uint256 endCollateralBalance = collateralToken.balanceOf(address(this));

        return endCollateralBalance.sub(startCollateralBalance);
    }

    function isSettlementAllowed(address underlying, uint256 expiry)
        private
        view
        returns (bool)
    {

        IController controller = IController(gammaController);
        OracleInterface oracle = OracleInterface(controller.oracle());

        bool underlyingFinalized =
            oracle.isDisputePeriodOver(underlying, expiry);

        bool strikeFinalized = oracle.isDisputePeriodOver(USDC, expiry);


        return underlyingFinalized && strikeFinalized;
    }

    function assetDecimals(address asset) private view returns (uint256) {

        if (asset == USDC) {
            return 6;
        }
        return 18;
    }

    function lookupOToken(ProtocolAdapterTypes.OptionTerms memory optionTerms)
        public
        view
        returns (address oToken)
    {

        IOtokenFactory factory = IOtokenFactory(oTokenFactory);

        bool isPut =
            optionTerms.optionType == ProtocolAdapterTypes.OptionType.Put;
        address underlying = optionTerms.underlying;

        if (optionTerms.underlying == address(0)) {
            underlying = WETH;
        }

        address collateralAsset;
        if (isPut) {
            collateralAsset = USDC;
        } else {
            collateralAsset = underlying;
        }

        oToken = factory.getOtoken(
            underlying,
            optionTerms.strikeAsset,
            collateralAsset,
            optionTerms.strikePrice.div(10**10),
            optionTerms.expiry,
            isPut
        );
    }
}