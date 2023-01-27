
pragma solidity 0.6.6;
pragma experimental ABIEncoderV2;


interface IUniswapV2Pair {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);


    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;


    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);


    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;


    function initialize(address, address) external;

}

interface IUniswapV2Factory {

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);


    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);


    function createPair(address tokenA, address tokenB) external returns (address pair);


    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

}

interface IUniswapV2Router01 {

    function factory() external pure returns (address);

    function WETH() external pure returns (address);


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);


    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

}

interface IUniswapV2Router02 is IUniswapV2Router01 {

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);


    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

}

abstract contract WarpControlI {
    function getMaxWithdrawAllowed(address account, address lpToken)
        public
        virtual
        returns (uint256);

    function viewMaxWithdrawAllowed(address account, address lpToken)
        public
        virtual
        view
        returns (uint256);

    function getPriceOfCollateral(address lpToken)
        public
        virtual
        view
        returns (uint256);

    function addMemberToGroup(address _refferalCode, address _member)
        public
        virtual;

    function checkIfGroupMember(address _account)
        public
        virtual
        view
        returns (bool);

    function getTotalAvailableCollateralValue(address _account)
        public
        virtual
        returns (uint256);

    function getTotalBorrowedValue(address _account)
        public
        virtual
        returns (uint256);

    function calcBorrowLimit(uint256 _collateralValue)
        public
        virtual
        pure
        returns (uint256);

    function calcCollateralRequired(uint256 _borrowAmount)
        public
        virtual
        view
        returns (uint256);

    function getBorrowLimit(address _account) public virtual returns (uint256);

    function liquidateAccount(address _borrower) public virtual;
}

interface IFlashLoanReceiver {

  function executeOperation(
    address[] calldata assets,
    uint256[] calldata amounts,
    uint256[] calldata premiums,
    address initiator,
    bytes calldata params
  ) external returns (bool);

}

abstract contract FlashLoanReceiverBase is IFlashLoanReceiver {
  using SafeERC20 for IERC20;
  using SafeMath for uint256;

  ILendingPoolAddressesProvider public immutable ADDRESSES_PROVIDER;
  ILendingPool public immutable LENDING_POOL;

  constructor(ILendingPoolAddressesProvider provider) public {
    ADDRESSES_PROVIDER = provider;
    LENDING_POOL = ILendingPool(provider.getLendingPool());
  }
}

library SafeMath {

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    require(c >= a, 'SafeMath: addition overflow');

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    return sub(a, b, 'SafeMath: subtraction overflow');
  }

  function sub(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {

    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, 'SafeMath: multiplication overflow');

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    return div(a, b, 'SafeMath: division by zero');
  }

  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {

    require(b > 0, errorMessage);
    uint256 c = a / b;

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {

    return mod(a, b, 'SafeMath: modulo by zero');
  }

  function mod(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {

    require(b != 0, errorMessage);
    return a % b;
  }
}

library Address {

  function isContract(address account) internal view returns (bool) {

    bytes32 codehash;
    bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
    assembly {
      codehash := extcodehash(account)
    }
    return (codehash != accountHash && codehash != 0x0);
  }

  function sendValue(address payable recipient, uint256 amount) internal {

    require(address(this).balance >= amount, 'Address: insufficient balance');

    (bool success, ) = recipient.call{value: amount}('');
    require(success, 'Address: unable to send value, recipient may have reverted');
  }
}

library SafeERC20 {

  using SafeMath for uint256;
  using Address for address;

  function safeTransfer(
    IERC20 token,
    address to,
    uint256 value
  ) internal {

    callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
  }

  function safeTransferFrom(
    IERC20 token,
    address from,
    address to,
    uint256 value
  ) internal {

    callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
  }

  function safeApprove(
    IERC20 token,
    address spender,
    uint256 value
  ) internal {

    require(
      (value == 0) || (token.allowance(address(this), spender) == 0),
      'SafeERC20: approve from non-zero to non-zero allowance'
    );
    callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
  }

  function callOptionalReturn(IERC20 token, bytes memory data) private {

    require(address(token).isContract(), 'SafeERC20: call to non-contract');

    (bool success, bytes memory returndata) = address(token).call(data);
    require(success, 'SafeERC20: low-level call failed');

    if (returndata.length > 0) {
      require(abi.decode(returndata, (bool)), 'SafeERC20: ERC20 operation did not succeed');
    }
  }
}

library DataTypes {

  struct ReserveData {
    ReserveConfigurationMap configuration;
    uint128 liquidityIndex;
    uint128 variableBorrowIndex;
    uint128 currentLiquidityRate;
    uint128 currentVariableBorrowRate;
    uint128 currentStableBorrowRate;
    uint40 lastUpdateTimestamp;
    address aTokenAddress;
    address stableDebtTokenAddress;
    address variableDebtTokenAddress;
    address interestRateStrategyAddress;
    uint8 id;
  }

  struct ReserveConfigurationMap {
    uint256 data;
  }

  struct UserConfigurationMap {
    uint256 data;
  }

  enum InterestRateMode {NONE, STABLE, VARIABLE}
}

interface IERC20 {

  function totalSupply() external view returns (uint256);


  function balanceOf(address account) external view returns (uint256);


  function transfer(address recipient, uint256 amount) external returns (bool);


  function allowance(address owner, address spender) external view returns (uint256);


  function approve(address spender, uint256 amount) external returns (bool);


  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);


  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface ILendingPoolAddressesProvider {

  event LendingPoolUpdated(address indexed newAddress);
  event ConfigurationAdminUpdated(address indexed newAddress);
  event EmergencyAdminUpdated(address indexed newAddress);
  event LendingPoolConfiguratorUpdated(address indexed newAddress);
  event LendingPoolCollateralManagerUpdated(address indexed newAddress);
  event PriceOracleUpdated(address indexed newAddress);
  event LendingRateOracleUpdated(address indexed newAddress);
  event ProxyCreated(bytes32 id, address indexed newAddress);
  event AddressSet(bytes32 id, address indexed newAddress, bool hasProxy);

  function setAddress(bytes32 id, address newAddress) external;


  function setAddressAsProxy(bytes32 id, address impl) external;


  function getAddress(bytes32 id) external view returns (address);


  function getLendingPool() external view returns (address);


  function setLendingPoolImpl(address pool) external;


  function getLendingPoolConfigurator() external view returns (address);


  function setLendingPoolConfiguratorImpl(address configurator) external;


  function getLendingPoolCollateralManager() external view returns (address);


  function setLendingPoolCollateralManager(address manager) external;


  function getPoolAdmin() external view returns (address);


  function setPoolAdmin(address admin) external;


  function getEmergencyAdmin() external view returns (address);


  function setEmergencyAdmin(address admin) external;


  function getPriceOracle() external view returns (address);


  function setPriceOracle(address priceOracle) external;


  function getLendingRateOracle() external view returns (address);


  function setLendingRateOracle(address lendingRateOracle) external;

}

interface ILendingPool {

  event Deposit(
    address indexed reserve,
    address user,
    address indexed onBehalfOf,
    uint256 amount,
    uint16 indexed referral
  );

  event Withdraw(address indexed reserve, address indexed user, address indexed to, uint256 amount);

  event Borrow(
    address indexed reserve,
    address user,
    address indexed onBehalfOf,
    uint256 amount,
    uint256 borrowRateMode,
    uint256 borrowRate,
    uint16 indexed referral
  );

  event Repay(
    address indexed reserve,
    address indexed user,
    address indexed repayer,
    uint256 amount
  );

  event Swap(address indexed reserve, address indexed user, uint256 rateMode);

  event ReserveUsedAsCollateralEnabled(address indexed reserve, address indexed user);

  event ReserveUsedAsCollateralDisabled(address indexed reserve, address indexed user);

  event RebalanceStableBorrowRate(address indexed reserve, address indexed user);

  event FlashLoan(
    address indexed target,
    address indexed initiator,
    address indexed asset,
    uint256 amount,
    uint256 premium,
    uint16 referralCode
  );

  event Paused();

  event Unpaused();

  event LiquidationCall(
    address indexed collateralAsset,
    address indexed debtAsset,
    address indexed user,
    uint256 debtToCover,
    uint256 liquidatedCollateralAmount,
    address liquidator,
    bool receiveAToken
  );

  event ReserveDataUpdated(
    address indexed reserve,
    uint256 liquidityRate,
    uint256 stableBorrowRate,
    uint256 variableBorrowRate,
    uint256 liquidityIndex,
    uint256 variableBorrowIndex
  );

  function deposit(
    address asset,
    uint256 amount,
    address onBehalfOf,
    uint16 referralCode
  ) external;


  function withdraw(
    address asset,
    uint256 amount,
    address to
  ) external;


  function borrow(
    address asset,
    uint256 amount,
    uint256 interestRateMode,
    uint16 referralCode,
    address onBehalfOf
  ) external;


  function repay(
    address asset,
    uint256 amount,
    uint256 rateMode,
    address onBehalfOf
  ) external;


  function swapBorrowRateMode(address asset, uint256 rateMode) external;


  function rebalanceStableBorrowRate(address asset, address user) external;


  function setUserUseReserveAsCollateral(address asset, bool useAsCollateral) external;


  function liquidationCall(
    address collateralAsset,
    address debtAsset,
    address user,
    uint256 debtToCover,
    bool receiveAToken
  ) external;


  function flashLoan(
    address receiverAddress,
    address[] calldata assets,
    uint256[] calldata amounts,
    uint256[] calldata modes,
    address onBehalfOf,
    bytes calldata params,
    uint16 referralCode
  ) external;


  function getUserAccountData(address user)
    external
    view
    returns (
      uint256 totalCollateralETH,
      uint256 totalDebtETH,
      uint256 availableBorrowsETH,
      uint256 currentLiquidationThreshold,
      uint256 ltv,
      uint256 healthFactor
    );


  function initReserve(
    address reserve,
    address aTokenAddress,
    address stableDebtAddress,
    address variableDebtAddress,
    address interestRateStrategyAddress
  ) external;


  function setReserveInterestRateStrategyAddress(address reserve, address rateStrategyAddress)
    external;


  function setConfiguration(address reserve, uint256 configuration) external;


  function getConfiguration(address asset) external view returns (DataTypes.ReserveConfigurationMap memory);


  function getUserConfiguration(address user) external view returns (DataTypes.UserConfigurationMap memory);


  function getReserveNormalizedIncome(address asset) external view returns (uint256);


  function getReserveNormalizedVariableDebt(address asset) external view returns (uint256);


  function getReserveData(address asset) external view returns (DataTypes.ReserveData memory);


  function finalizeTransfer(
    address asset,
    address from,
    address to,
    uint256 amount,
    uint256 balanceFromAfter,
    uint256 balanceToBefore
  ) external;


  function getReservesList() external view returns (address[] memory);


  function getAddressesProvider() external view returns (ILendingPoolAddressesProvider);


  function setPause(bool val) external;


  function paused() external view returns (bool);

}

contract MyV2FlashLoan is FlashLoanReceiverBase {

    using SafeMath for uint256;

    address public uniRouterAddress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address public uniFactoryAddress = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address public sushiRouterAddress = 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F;
    address public sushiFactoryAddress = 0xC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2Ac;
    address public warpControlAddress = 0x8E0Fa7c5C7Fa86A059e865A90b50a90351df716a;

    address public daiAddress = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public usdcAddress = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public usdtAddress = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address public wbtcAddress = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    address public wethAddress = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    IERC20 usdcToken = IERC20(usdcAddress);

    constructor(ILendingPoolAddressesProvider _addressProvider) FlashLoanReceiverBase(_addressProvider) public
    {

    }

    event log(string s);
    event log(string s, uint v);
    event log(string s, address v);

    struct opVars
    {
        address borrower;
        address warpControlAddress;
        address warpTeam;
        WarpControlI warpControl;
        IUniswapV2Router02 router;
        IUniswapV2Factory factory;
        IUniswapV2Pair pair;
        uint256 amount;
        address token0;
        address token1;
        uint256 usdcNeededForLoan;
        uint256[3] remainingAmounts;
        uint256 balance;
    }

    function executeOperation(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        address initiator,
        bytes calldata params
    )
        external
        override
        returns (bool)
    {



        opVars memory vars;


        for (uint i = 0; i < assets.length; i++) {

            IERC20(assets[i]).safeApprove(vars.warpControlAddress, 1e64);
        }

        (vars.borrower, vars.warpControlAddress, vars.warpTeam) = abi.decode(params, (address, address, address));
        vars.warpControl = WarpControlI(vars.warpControlAddress);
        vars.warpControl.liquidateAccount(vars.borrower);


        vars.router = IUniswapV2Router02(uniRouterAddress);
        vars.factory = IUniswapV2Factory(uniFactoryAddress);

        vars.token0 = wethAddress;
        vars.token1 = daiAddress;
        convertToUSDC(vars);

        vars.token0 = wethAddress;
        vars.token1 = usdcAddress;
        convertToUSDC(vars);

        vars.token0 = wethAddress;
        vars.token1 = usdtAddress;
        convertToUSDC(vars);

        vars.token0 = wethAddress;
        vars.token1 = wbtcAddress;
        convertToUSDC(vars);

        vars.router = IUniswapV2Router02(sushiRouterAddress);
        vars.factory = IUniswapV2Factory(sushiFactoryAddress);

        vars.token0 = wethAddress;
        vars.token1 = daiAddress;
        convertToUSDC(vars);

        vars.token0 = wethAddress;
        vars.token1 = usdcAddress;
        convertToUSDC(vars);

        vars.token0 = wethAddress;
        vars.token1 = usdtAddress;
        convertToUSDC(vars);

        vars.token0 = wethAddress;
        vars.token1 = wbtcAddress;
        convertToUSDC(vars);

        vars.router = IUniswapV2Router02(uniRouterAddress);
        vars.factory = IUniswapV2Factory(uniFactoryAddress);

        for (uint i = 0; i < assets.length; i++) {

            vars.amount = amounts[i].add(premiums[i]);
            IERC20(assets[i]).safeApprove(address(LENDING_POOL), vars.amount);

            if(assets[i] != usdcAddress)
            {
              vars.token0 = assets[i];
              convertUSDCToToken(vars);

              vars.balance = IERC20(assets[i]).balanceOf(address(this));
              if(vars.balance > vars.amount)
                vars.remainingAmounts[i] = vars.balance - vars.amount;
            }
            else // is usdc
            {
              vars.balance = IERC20(assets[i]).balanceOf(address(this));
              if(vars.balance > vars.amount)
                vars.remainingAmounts[i] = vars.balance - vars.amount;
            }
        }

        for (uint i = 0; i < assets.length; i++) {
          if(vars.remainingAmounts[i] > 0)
             IERC20(assets[i]).safeTransfer(vars.warpTeam, vars.remainingAmounts[i]);
        }

        return true;
    }

    function liquidateWarpAccount(
        address[] memory assets,
        uint256[] memory amounts,
        uint256[] memory modes,
        address borrower,
        address warpControl,
        address warpTeam
        ) public {

        address receiverAddress = address(this);


        address onBehalfOf = address(this);
        bytes memory params = abi.encode(borrower, warpControl, warpTeam);
        uint16 referralCode = 0;

        LENDING_POOL.flashLoan(
            receiverAddress,
            assets,
            amounts,
            modes,
            onBehalfOf,
            params,
            referralCode
        );
    }

    function getPath(address token0, address token1) private returns(address[] memory)
    {

        address[] memory path = new address[](2);
        path[0] = token0;
        path[1] = token1;

        return path;
    }

    function convertUSDCToToken(opVars memory vars) private
    {

        IERC20 usdcToken = IERC20(usdcAddress);
        usdcToken.approve(address(vars.router), 1e64);

        vars.router.swapTokensForExactTokens(vars.amount, 1e64, getPath(usdcAddress, vars.token0), address(this), 1e18);
    }

    function convertToUSDC(opVars memory vars) private
    {

        vars.pair = IUniswapV2Pair(vars.factory.getPair(vars.token0, vars.token1));
        vars.amount = vars.pair.balanceOf(address(this));

        if(vars.amount == 0)
          return;

        vars.pair.approve(address(vars.router), vars.amount);
        (uint amountToken, uint amountETH) = vars.router.removeLiquidityETH(vars.token1, vars.amount, 0, 0, address(this), 1e18);

        vars.router.swapExactETHForTokens.value(amountETH)(0, getPath(vars.router.WETH(), usdcAddress), address(this), 1e18);

        if(vars.token1 != usdcAddress)
        {
          IERC20 daiToken = IERC20(vars.token1);
          daiToken.approve(address(vars.router), amountToken);
          vars.router.swapExactTokensForTokens(amountToken, 0, getPath(vars.token1, usdcAddress), address(this), 1e18);
        }
    }

    fallback () external payable { }
}