
pragma solidity ^0.7.0;

interface IBasket {

    function BURN_FEE() external view returns (bytes32);


    function DEFAULT_ADMIN_ROLE() external view returns (bytes32);


    function FEE_DIVISOR() external view returns (uint256);


    function FEE_RECIPIENT() external view returns (bytes32);


    function GOVERNANCE() external view returns (bytes32);


    function GOVERNANCE_ADMIN() external view returns (bytes32);


    function INITIALIZED() external view returns (bytes32);


    function MARKET_MAKER() external view returns (bytes32);


    function MARKET_MAKER_ADMIN() external view returns (bytes32);


    function MIGRATOR() external view returns (bytes32);


    function MINT_FEE() external view returns (bytes32);


    function TIMELOCK() external view returns (bytes32);


    function TIMELOCK_ADMIN() external view returns (bytes32);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function approveModule(address _module) external;


    function approvedModules(address) external view returns (bool);


    function assets(uint256) external view returns (address);


    function balanceOf(address account) external view returns (uint256);


    function burn(uint256 _amount) external;


    function decimals() external view returns (uint8);


    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);


    function getAssetsAndBalances() external view returns (address[] memory, uint256[] memory);


    function getFees()
        external
        view
        returns (
            uint256,
            uint256,
            address
        );


    function getOne() external view returns (address[] memory, uint256[] memory);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function getRoleMember(bytes32 role, uint256 index) external view returns (address);


    function getRoleMemberCount(bytes32 role) external view returns (uint256);


    function grantRole(bytes32 role, address account) external;


    function hasRole(bytes32 role, address account) external view returns (bool);


    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);


    function mint(uint256 _amountOut) external;


    function name() external view returns (string memory);


    function pause() external;


    function paused() external view returns (bool);


    function renounceRole(bytes32 role, address account) external;


    function rescueERC20(address _asset, uint256 _amount) external;


    function revokeModule(address _module) external;


    function revokeRole(bytes32 role, address account) external;


    function setAssets(address[] memory _assets) external;


    function setFee(
        uint256 _mintFee,
        uint256 _burnFee,
        address _recipient
    ) external;


    function symbol() external view returns (string memory);


    function totalSupply() external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    function unpause() external;


    function viewMint(uint256 _amountOut) external view returns (uint256[] memory _amountsIn);

}

pragma solidity ^0.7.3;

interface IComptroller {

    function _addCompMarkets(address[] memory cTokens) external;


    function _become(address unitroller) external;


    function _borrowGuardianPaused() external view returns (bool);


    function _dropCompMarket(address cToken) external;


    function _grantComp(address recipient, uint256 amount) external;


    function _mintGuardianPaused() external view returns (bool);


    function _setBorrowCapGuardian(address newBorrowCapGuardian) external;


    function _setBorrowPaused(address cToken, bool state) external returns (bool);


    function _setCloseFactor(uint256 newCloseFactorMantissa) external returns (uint256);


    function _setCollateralFactor(address cToken, uint256 newCollateralFactorMantissa) external returns (uint256);


    function _setCompRate(uint256 compRate_) external;


    function _setContributorCompSpeed(address contributor, uint256 compSpeed) external;


    function _setLiquidationIncentive(uint256 newLiquidationIncentiveMantissa) external returns (uint256);


    function _setMarketBorrowCaps(address[] memory cTokens, uint256[] memory newBorrowCaps) external;


    function _setMintPaused(address cToken, bool state) external returns (bool);


    function _setPauseGuardian(address newPauseGuardian) external returns (uint256);


    function _setPriceOracle(address newOracle) external returns (uint256);


    function _setSeizePaused(bool state) external returns (bool);


    function _setTransferPaused(bool state) external returns (bool);


    function _supportMarket(address cToken) external returns (uint256);


    function accountAssets(address, uint256) external view returns (address);


    function admin() external view returns (address);


    function allMarkets(uint256) external view returns (address);


    function borrowAllowed(
        address cToken,
        address borrower,
        uint256 borrowAmount
    ) external returns (uint256);


    function borrowCapGuardian() external view returns (address);


    function borrowCaps(address) external view returns (uint256);


    function borrowGuardianPaused(address) external view returns (bool);


    function borrowVerify(
        address cToken,
        address borrower,
        uint256 borrowAmount
    ) external;


    function checkMembership(address account, address cToken) external view returns (bool);


    function claimComp(address holder, address[] memory cTokens) external;


    function claimComp(
        address[] memory holders,
        address[] memory cTokens,
        bool borrowers,
        bool suppliers
    ) external;


    function claimComp(address holder) external;


    function closeFactorMantissa() external view returns (uint256);


    function compAccrued(address) external view returns (uint256);


    function compBorrowState(address) external view returns (uint224 index, uint32);


    function compBorrowerIndex(address, address) external view returns (uint256);


    function compClaimThreshold() external view returns (uint256);


    function compContributorSpeeds(address) external view returns (uint256);


    function compInitialIndex() external view returns (uint224);


    function compRate() external view returns (uint256);


    function compSpeeds(address) external view returns (uint256);


    function compSupplierIndex(address, address) external view returns (uint256);


    function compSupplyState(address) external view returns (uint224 index, uint32);


    function comptrollerImplementation() external view returns (address);


    function enterMarkets(address[] memory cTokens) external returns (uint256[] memory);


    function exitMarket(address cTokenAddress) external returns (uint256);


    function getAccountLiquidity(address account)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );


    function getAllMarkets() external view returns (address[] memory);


    function getAssetsIn(address account) external view returns (address[] memory);


    function getBlockNumber() external view returns (uint256);


    function getCompAddress() external view returns (address);


    function getHypotheticalAccountLiquidity(
        address account,
        address cTokenModify,
        uint256 redeemTokens,
        uint256 borrowAmount
    )
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );


    function isComptroller() external view returns (bool);


    function lastContributorBlock(address) external view returns (uint256);


    function liquidateBorrowAllowed(
        address cTokenBorrowed,
        address cTokenCollateral,
        address liquidator,
        address borrower,
        uint256 repayAmount
    ) external returns (uint256);


    function liquidateBorrowVerify(
        address cTokenBorrowed,
        address cTokenCollateral,
        address liquidator,
        address borrower,
        uint256 actualRepayAmount,
        uint256 seizeTokens
    ) external;


    function liquidateCalculateSeizeTokens(
        address cTokenBorrowed,
        address cTokenCollateral,
        uint256 actualRepayAmount
    ) external view returns (uint256, uint256);


    function liquidationIncentiveMantissa() external view returns (uint256);


    function markets(address)
        external
        view
        returns (
            bool isListed,
            uint256 collateralFactorMantissa,
            bool isComped
        );


    function maxAssets() external view returns (uint256);


    function mintAllowed(
        address cToken,
        address minter,
        uint256 mintAmount
    ) external returns (uint256);


    function mintGuardianPaused(address) external view returns (bool);


    function mintVerify(
        address cToken,
        address minter,
        uint256 actualMintAmount,
        uint256 mintTokens
    ) external;


    function oracle() external view returns (address);


    function pauseGuardian() external view returns (address);


    function pendingAdmin() external view returns (address);


    function pendingComptrollerImplementation() external view returns (address);


    function redeemAllowed(
        address cToken,
        address redeemer,
        uint256 redeemTokens
    ) external returns (uint256);


    function redeemVerify(
        address cToken,
        address redeemer,
        uint256 redeemAmount,
        uint256 redeemTokens
    ) external;


    function refreshCompSpeeds() external;


    function repayBorrowAllowed(
        address cToken,
        address payer,
        address borrower,
        uint256 repayAmount
    ) external returns (uint256);


    function repayBorrowVerify(
        address cToken,
        address payer,
        address borrower,
        uint256 actualRepayAmount,
        uint256 borrowerIndex
    ) external;


    function seizeAllowed(
        address cTokenCollateral,
        address cTokenBorrowed,
        address liquidator,
        address borrower,
        uint256 seizeTokens
    ) external returns (uint256);


    function seizeGuardianPaused() external view returns (bool);


    function seizeVerify(
        address cTokenCollateral,
        address cTokenBorrowed,
        address liquidator,
        address borrower,
        uint256 seizeTokens
    ) external;


    function transferAllowed(
        address cToken,
        address src,
        address dst,
        uint256 transferTokens
    ) external returns (uint256);


    function transferGuardianPaused() external view returns (bool);


    function transferVerify(
        address cToken,
        address src,
        address dst,
        uint256 transferTokens
    ) external;


    function updateContributorRewards(address contributor) external;

}

pragma solidity ^0.7.0;

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

    function decimals() external view returns (uint8);


    function name() external view returns (string memory);

}
pragma solidity >=0.5.0;
pragma experimental ABIEncoderV2;

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

}

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

}

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
}

interface IUniswapV3PoolImmutables {

    function factory() external view returns (address);


    function token0() external view returns (address);


    function token1() external view returns (address);


    function fee() external view returns (uint24);


    function tickSpacing() external view returns (int24);


    function maxLiquidityPerTick() external view returns (uint128);

}

interface IUniswapV3PoolOwnerActions {

    function setFeeProtocol(uint8 feeProtocol0, uint8 feeProtocol1) external;


    function collectProtocol(
        address recipient,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);

}

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

}

interface IUniswapV3Pool is
    IUniswapV3PoolImmutables,
    IUniswapV3PoolState,
    IUniswapV3PoolDerivedState,
    IUniswapV3PoolActions,
    IUniswapV3PoolOwnerActions,
    IUniswapV3PoolEvents
{


}

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

}

interface IUniswapV3PoolDeployer {

    function parameters()
        external
        view
        returns (
            address factory,
            address token0,
            address token1,
            uint24 fee,
            int24 tickSpacing
        );

}

interface IUniswapV3Quoter {

    function WETH9() external view returns (address);


    function factory() external view returns (address);


    function quoteExactInput(bytes memory path, uint256 amountIn) external returns (uint256 amountOut);


    function quoteExactInputSingle(
        address tokenIn,
        address tokenOut,
        uint24 fee,
        uint256 amountIn,
        uint160 sqrtPriceLimitX96
    ) external returns (uint256 amountOut);


    function quoteExactOutput(bytes memory path, uint256 amountOut) external returns (uint256 amountIn);


    function quoteExactOutputSingle(
        address tokenIn,
        address tokenOut,
        uint24 fee,
        uint256 amountOut,
        uint160 sqrtPriceLimitX96
    ) external returns (uint256 amountIn);


    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes memory path
    ) external view;

}

interface IUniswapV3SwapCallback {

    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external;

}

interface IUniswapV3Router is IUniswapV3SwapCallback {

    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);


    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);


    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    function exactOutputSingle(ExactOutputSingleParams calldata params) external payable returns (uint256 amountIn);


    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    function exactOutput(ExactOutputParams calldata params) external payable returns (uint256 amountIn);

}
pragma solidity >=0.5.0;


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
}

library CallbackValidation {

    function verifyCallback(
        address factory,
        address tokenA,
        address tokenB,
        uint24 fee
    ) internal view returns (IUniswapV3Pool pool) {

        return verifyCallback(factory, PoolAddress.getPoolKey(tokenA, tokenB, fee));
    }

    function verifyCallback(address factory, PoolAddress.PoolKey memory poolKey)
        internal
        view
        returns (IUniswapV3Pool pool)
    {

        pool = IUniswapV3Pool(PoolAddress.computeAddress(factory, poolKey));
        require(msg.sender == address(pool));
    }
}// MIT

pragma solidity ^0.7.3;

interface IWETH {

    function name() external view returns (string memory);


    function approve(address guy, uint256 wad) external returns (bool);


    function totalSupply() external view returns (uint256);


    function transferFrom(
        address src,
        address dst,
        uint256 wad
    ) external returns (bool);


    function withdraw(uint256 wad) external;


    function decimals() external view returns (uint8);


    function balanceOf(address) external view returns (uint256);


    function symbol() external view returns (string memory);


    function transfer(address dst, uint256 wad) external returns (bool);


    function deposit() external payable;


    function allowance(address, address) external view returns (uint256);

}
  

pragma solidity >=0.6.0 <0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// AGPL-3.0-only
pragma solidity ^0.7.0;


library SafeERC20 {

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, value)
        );

        require(success && (data.length == 0 || abi.decode(data, (bool))), "TRANSFER_FROM_FAILED");
    }

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(IERC20.transfer.selector, to, value)
        );

        require(success && (data.length == 0 || abi.decode(data, (bool))), "TRANSFER_FAILED");
    }

    function safeApprove(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(IERC20.approve.selector, to, value)
        );

        require(success && (data.length == 0 || abi.decode(data, (bool))), "APPROVE_FAILED");
    }

    function safeTransferETH(address to, uint256 value) internal {

        (bool success, ) = to.call{value: value}(new bytes(0));

        require(success, "ETH_TRANSFER_FAILED");
    }
}// AGPL-3.0-only 
pragma solidity ^0.7.0;


library SafeMath {

    function add(uint x, uint y) internal pure returns (uint z) {

        require((z = x + y) >= x, "ds-math-add-overflow");
    }

    function sub(uint x, uint y) internal pure returns (uint z) {

        require((z = x - y) <= x, "ds-math-sub-underflow");
    }

    function mul(uint x, uint y) internal pure returns (uint z) {

        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "ds-math-divide-by-0");
        return a / b;
    }
}// MIT

pragma solidity ^0.7.3;



contract SocialZapperBase is ReentrancyGuard {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public governance;
    address public bmi;

    address internal constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    mapping(address => uint256) public curId;

    mapping(address => mapping(address => mapping(uint256 => uint256))) public deposits;

    mapping(address => mapping(address => mapping(uint256 => bool))) public claimed;

    mapping(address => mapping(uint256 => uint256)) public totalDeposited;

    mapping(address => mapping(uint256 => uint256)) public zapped;

    mapping(address => bool) public approvedWeavers;


    constructor(address _governance, address _bmi) {
        governance = _governance;
        bmi = _bmi;
    }

    modifier onlyGov() {

        require(msg.sender == governance, "!governance");
        _;
    }

    modifier onlyWeavers {

        require(msg.sender == governance || approvedWeavers[msg.sender], "!weaver");
        _;
    }

    receive() external payable {}


    function approveWeaver(address _weaver) public onlyGov {

        approvedWeavers[_weaver] = true;
    }

    function revokeWeaver(address _weaver) public onlyGov {

        approvedWeavers[_weaver] = false;
    }

    function setGov(address _governance) public onlyGov {

        governance = _governance;
    }

    function recoverERC20(address _token) public onlyWeavers {

        IERC20(_token).safeTransfer(governance, IERC20(_token).balanceOf(address(this)));
    }

    function recoverERC20(address _token, uint256 _amount) public onlyWeavers {

        IERC20(_token).safeTransfer(governance, _amount);
    }


    function deposit(address _token, uint256 _amount) public nonReentrant {

        IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);

        deposits[_token][msg.sender][curId[_token]] = deposits[_token][msg.sender][curId[_token]].add(_amount);
        totalDeposited[_token][curId[_token]] = totalDeposited[_token][curId[_token]].add(_amount);
    }

    function withdraw(address _token, uint256 _amount) public nonReentrant {

        deposits[_token][msg.sender][curId[_token]] = deposits[_token][msg.sender][curId[_token]].sub(_amount);
        totalDeposited[_token][curId[_token]] = totalDeposited[_token][curId[_token]].sub(_amount);

        IERC20(_token).safeTransfer(msg.sender, _amount);
    }


    function _withdrawZapped(
        address _target,
        address _token,
        uint256 _id
    ) internal nonReentrant {

        require(_id < curId[_token], "!weaved");
        require(!claimed[_token][msg.sender][_id], "already-claimed");
        uint256 userDeposited = deposits[_token][msg.sender][_id];
        require(userDeposited > 0, "!deposit");

        uint256 ratio = userDeposited.mul(1e18).div(totalDeposited[_token][_id]);
        uint256 userZappedAmount = zapped[_token][_id].mul(ratio).div(1e18);
        claimed[_token][msg.sender][_id] = true;

        if (_target == WETH) {
            IWETH(_target).withdraw(userZappedAmount);
            (bool s, ) = msg.sender.call{ value: userZappedAmount }("0x");
            require(s, "!withdraw");
        } else {
            IERC20(address(_target)).safeTransfer(msg.sender, userZappedAmount);
        }
    }

    function _withdrawZappedMany(
        address _target,
        address[] memory _tokens,
        uint256[] memory _ids
    ) internal {

        assert(_tokens.length == _ids.length);

        for (uint256 i = 0; i < _tokens.length; i++) {
            _withdrawZapped(_target, _tokens[i], _ids[i]);
        }
    }
}

pragma solidity ^0.7.3;




contract SocialBDIBurner is SocialZapperBase {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address internal constant UNIV3_FACTORY = address(0x1F98431c8aD98523631AE4a59f267346ea31F984);
    address internal constant UNIV2_FACTORY = address(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);
    address internal constant SUSHI_FACTORY = address(0xC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2Ac);


    address internal constant BDI = address(0x0309c98B1bffA350bcb3F9fB9780970CA32a5060);

    address internal constant XSUSHI = 0x8798249c2E607446EfB7Ad49eC89dD1865Ff4272;

    address internal constant COMPTROLLER = 0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B;

    address internal constant CUNI = 0x35A18000230DA775CAc24873d00Ff85BccdeD550;
    address internal constant CCOMP = 0x70e36f6BF80a52b3B46b3aF8e106CC0ed743E8e4;

    address internal constant CURVE_LINK_POOL = 0xF178C0b5Bb7e7aBF4e12A4838C7b7c5bA2C623c0;

    address internal constant linkCRV = 0xcee60cFa923170e4f8204AE08B4fA6A3F5656F3a;
    address internal constant yvCurveLink = 0xf2db9a7c0ACd427A680D640F02d90f6186E71725;
    address internal constant yvUNI = 0xFBEB78a723b8087fD2ea7Ef1afEc93d35E8Bed42;
    address internal constant yvYFI = 0xE14d13d8B3b85aF791b2AADD661cDBd5E6097Db1;
    address internal constant yvSNX = 0xF29AE508698bDeF169B89834F76704C3B205aedf;

    address internal constant LINK = 0x514910771AF9Ca656af840dff83E8264EcF986CA;
    address internal constant CRV = 0xD533a949740bb3306d119CC777fa900bA034cd52;
    address internal constant UNI = 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984;
    address internal constant COMP = 0xc00e94Cb662C3520282E6f5717214004A7f26888;
    address internal constant YFI = 0x0bc529c00C6401aEF6D220BE8C6Ea1667F6Ad93e;
    address internal constant SNX = 0xC011a73ee8576Fb46F5E1c5751cA3B9Fe0af2a6F;
    address internal constant MKR = 0x9f8F72aA9304c8B593d555F12eF6589cC3A579A2;
    address internal constant REN = 0x408e41876cCCDC0F92210600ef50372656052a38;
    address internal constant KNC = 0xdd974D5C2e2928deA5F71b9825b8b646686BD200;
    address internal constant LRC = 0xBBbbCA6A901c926F240b89EacB641d8Aec7AEafD;
    address internal constant BAL = 0xba100000625a3754423978a60c9317c58a424e3D;
    address internal constant AAVE = 0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9;
    address internal constant MTA = 0xa3BeD4E1c75D00fa6f4E5E6922DB7261B5E9AcD2;
    address internal constant SUSHI = 0x6B3595068778DD592e39A122f4f5a5cF09C90fE2;
    address internal constant ZRX = 0xE41d2489571d322189246DaFA5ebDe1F4699F498;

    struct SwapV3Calldata {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address[] targets;
        bytes[] data;
    }

    constructor(address _governance) SocialZapperBase(_governance, BDI) {
        (address[] memory components, ) = IBasket(BDI).getOne();
        for (uint256 i = 0; i < components.length; i++) {
            IERC20(components[i]).safeApprove(BDI, type(uint256).max);
        }

        address[] memory markets = new address[](2);
        markets[0] = CCOMP;
        markets[1] = CUNI;
        IComptroller(COMPTROLLER).enterMarkets(markets);

        IERC20(COMP).safeApprove(CCOMP, type(uint256).max);
        IERC20(UNI).safeApprove(CUNI, type(uint256).max);
        IERC20(UNI).safeApprove(yvUNI, type(uint256).max);
        IERC20(YFI).safeApprove(yvYFI, type(uint256).max);
        IERC20(SNX).safeApprove(yvSNX, type(uint256).max);
        IERC20(SUSHI).safeApprove(XSUSHI, type(uint256).max);
        IERC20(LINK).safeApprove(CURVE_LINK_POOL, type(uint256).max);
        IERC20(linkCRV).safeApprove(yvCurveLink, type(uint256).max);
    }

    function socialBurn(
        address[] memory targets,
        bytes[] memory data,
        uint256 _minRecv
    ) public onlyWeavers returns (uint256) {

        uint256 _before = IERC20(WETH).balanceOf(address(this));

        bool success;
        bytes memory m;
        for (uint256 i = 0; i < targets.length; i++) {
            (success, m) = targets[i].call(data[i]);
            require(success, string(m));
        }

        uint256 _after = IERC20(WETH).balanceOf(address(this));
        uint256 _wethRecv = _after.sub(_before);

        require(_wethRecv > _minRecv, "min-weth-recv");

        zapped[BDI][curId[BDI]] = _wethRecv;
        curId[BDI]++;

        return _wethRecv;
    }

    function uniswapV3SwapCallback(
        int256,
        int256,
        bytes calldata data
    ) external {

        SwapV3Calldata memory fsCalldata = abi.decode(data, (SwapV3Calldata));
        CallbackValidation.verifyCallback(UNIV3_FACTORY, fsCalldata.tokenIn, fsCalldata.tokenOut, fsCalldata.fee);

        bool success;
        bytes memory m;
        for (uint256 i = 0; i < fsCalldata.targets.length; i++) {
            (success, m) = fsCalldata.targets[i].call(fsCalldata.data[i]);
            require(success, string(m));
        }
    }

    function withdrawETH(address _token, uint256 _id) public {

        _withdrawZapped(WETH, _token, _id);
    }

    function withdrawETHMany(address[] memory _tokens, uint256[] memory _ids) public {

        _withdrawZappedMany(WETH, _tokens, _ids);
    }
}
