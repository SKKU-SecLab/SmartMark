
pragma solidity 0.6.12;

interface ICoFiXFactory {

    event PairCreated(address indexed token, address pair, uint256);
    event NewGovernance(address _new);
    event NewController(address _new);
    event NewFeeReceiver(address _new);
    event NewFeeVaultForLP(address token, address feeVault);
    event NewVaultForLP(address _new);
    event NewVaultForTrader(address _new);
    event NewVaultForCNode(address _new);

    function createPair(
        address token
        )
        external
        returns (address pair);


    function getPair(address token) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);


    function getTradeMiningStatus(address token) external view returns (bool status);

    function setTradeMiningStatus(address token, bool status) external;

    function getFeeVaultForLP(address token) external view returns (address feeVault); // for LPs

    function setFeeVaultForLP(address token, address feeVault) external;


    function setGovernance(address _new) external;

    function setController(address _new) external;

    function setFeeReceiver(address _new) external;

    function setVaultForLP(address _new) external;

    function setVaultForTrader(address _new) external;

    function setVaultForCNode(address _new) external;

    function getController() external view returns (address controller);

    function getFeeReceiver() external view returns (address feeReceiver); // For CoFi Holders

    function getVaultForLP() external view returns (address vaultForLP);

    function getVaultForTrader() external view returns (address vaultForTrader);

    function getVaultForCNode() external view returns (address vaultForCNode);

}// GPL-3.0-or-later

pragma solidity 0.6.12;

library TransferHelper {

    function safeApprove(address token, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {

        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}// MIT

pragma solidity ^0.6.0;

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
}// GPL-3.0-or-later

pragma solidity 0.6.12;


interface IUniswapV2Pair {

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

}

library UniswapV2Library {

    using SafeMath for uint;

    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {

        require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
    }

    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {

        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f' // init code hash
            ))));
    }

    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {

        (address token0,) = sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IUniswapV2Pair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {

        require(amountA > 0, 'UniswapV2Library: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {

        require(amountIn > 0, 'UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(997);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {

        require(amountOut > 0, 'UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(1000);
        uint denominator = reserveOut.sub(amountOut).mul(997);
        amountIn = (numerator / denominator).add(1);
    }

    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {

        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {

        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}// GPL-3.0-or-later

pragma solidity 0.6.12;

interface ICoFiXRouter02 {

    function factory() external pure returns (address);

    function WETH() external pure returns (address);


    enum DEX_TYPE { COFIX, UNISWAP }


    function addLiquidity(
        address token,
        uint amountETH,
        uint amountToken,
        uint liquidityMin,
        address to,
        uint deadline
    ) external payable returns (uint liquidity);


    function addLiquidityAndStake(
        address token,
        uint amountETH,
        uint amountToken,
        uint liquidityMin,
        address to,
        uint deadline
    ) external payable returns (uint liquidity);


    function removeLiquidityGetToken(
        address token,
        uint liquidity,
        uint amountTokenMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken);


    function removeLiquidityGetETH(
        address token,
        uint liquidity,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountETH);


    function swapExactETHForTokens(
        address token,
        uint amountIn,
        uint amountOutMin,
        address to,
        address rewardTo,
        uint deadline
    ) external payable returns (uint _amountIn, uint _amountOut);


    function swapExactTokensForETH(
        address token,
        uint amountIn,
        uint amountOutMin,
        address to,
        address rewardTo,
        uint deadline
    ) external payable returns (uint _amountIn, uint _amountOut);


    function swapExactTokensForTokens(
        address tokenIn,
        address tokenOut,
        uint amountIn,
        uint amountOutMin,
        address to,
        address rewardTo,
        uint deadline
    ) external payable returns (uint _amountIn, uint _amountOut);


    function hybridSwapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        DEX_TYPE[] calldata dexes,
        address to,
        address rewardTo,
        uint deadline
    ) external payable returns (uint[] memory amounts);


    function hybridSwapExactETHForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        DEX_TYPE[] calldata dexes,
        address to,
        address rewardTo,
        uint deadline
    ) external payable returns (uint[] memory amounts);


    function hybridSwapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        DEX_TYPE[] calldata dexes,
        address to,
        address rewardTo,
        uint deadline
    ) external payable returns (uint[] memory amounts);


}// MIT

pragma solidity ^0.6.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// GPL-3.0-or-later

pragma solidity 0.6.12;

interface IWETH {

    function deposit() external payable;

    function transfer(address to, uint value) external returns (bool);

    function withdraw(uint) external;

    function balanceOf(address account) external view returns (uint);

}// GPL-3.0-or-later

pragma solidity 0.6.12;

interface ICoFiXERC20 {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

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

}// GPL-3.0-or-later

pragma solidity 0.6.12;

interface ICoFiXPair is ICoFiXERC20 {


    struct OraclePrice {
        uint256 ethAmount;
        uint256 erc20Amount;
        uint256 blockNum;
        uint256 K;
        uint256 theta;
    }

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, address outToken, uint outAmount, address indexed to);
    event Swap(
        address indexed sender,
        uint amountIn,
        uint amountOut,
        address outToken,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1);


    function mint(address to) external payable returns (uint liquidity, uint oracleFeeChange);

    function burn(address outToken, address to) external payable returns (uint amountOut, uint oracleFeeChange);

    function swapWithExact(address outToken, address to) external payable returns (uint amountIn, uint amountOut, uint oracleFeeChange, uint256[4] memory tradeInfo);

    function swapForExact(address outToken, uint amountOutExact, address to) external payable returns (uint amountIn, uint amountOut, uint oracleFeeChange, uint256[4] memory tradeInfo);

    function skim(address to) external;

    function sync() external;


    function initialize(address, address, string memory, string memory) external;


    function getNAVPerShare(uint256 ethAmount, uint256 erc20Amount) external view returns (uint256 navps);

}// GPL-3.0-or-later

pragma solidity 0.6.12;

interface ICoFiXVaultForLP {


    enum POOL_STATE {INVALID, ENABLED, DISABLED}

    event NewPoolAdded(address pool, uint256 index);
    event PoolEnabled(address pool);
    event PoolDisabled(address pool);

    function setGovernance(address _new) external;

    function setInitCoFiRate(uint256 _new) external;

    function setDecayPeriod(uint256 _new) external;

    function setDecayRate(uint256 _new) external;


    function addPool(address pool) external;

    function enablePool(address pool) external;

    function disablePool(address pool) external;

    function setPoolWeight(address pool, uint256 weight) external;

    function batchSetPoolWeight(address[] memory pools, uint256[] memory weights) external;

    function distributeReward(address to, uint256 amount) external;


    function getPendingRewardOfLP(address pair) external view returns (uint256);

    function currentPeriod() external view returns (uint256);

    function currentCoFiRate() external view returns (uint256);

    function currentPoolRate(address pool) external view returns (uint256 poolRate);

    function currentPoolRateByPair(address pair) external view returns (uint256 poolRate);


    function stakingPoolForPair(address pair) external view returns (address pool);


    function getPoolInfo(address pool) external view returns (POOL_STATE state, uint256 weight);

    function getPoolInfoByPair(address pair) external view returns (POOL_STATE state, uint256 weight);


    function getEnabledPoolCnt() external view returns (uint256);


    function getCoFiStakingPool() external view returns (address pool);


}// MIT

pragma solidity 0.6.12;


interface ICoFiXStakingRewards {


    function rewardsVault() external view returns (address);


    function lastBlockRewardApplicable() external view returns (uint256);


    function rewardPerToken() external view returns (uint256);


    function earned(address account) external view returns (uint256);


    function accrued() external view returns (uint256);


    function rewardRate() external view returns (uint256);


    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function stakingToken() external view returns (address);


    function rewardsToken() external view returns (address);



    function stake(uint256 amount) external;


    function stakeForOther(address other, uint256 amount) external;


    function withdraw(uint256 amount) external;


    function emergencyWithdraw() external;


    function getReward() external;


    function getRewardAndStake() external;


    function exit() external;


    function addReward(uint256 amount) external;


    event RewardAdded(address sender, uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event StakedForOther(address indexed user, address indexed other, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
}// GPL-3.0-or-later

pragma solidity 0.6.12;

interface ICoFiXVaultForTrader {


    event RouterAllowed(address router);
    event RouterDisallowed(address router);

    event ClearPendingRewardOfCNode(uint256 pendingAmount);
    event ClearPendingRewardOfLP(uint256 pendingAmount);

    function setGovernance(address gov) external;


    function setExpectedYieldRatio(uint256 r) external;

    function setLRatio(uint256 lRatio) external;

    function setTheta(uint256 theta) external;


    function allowRouter(address router) external;


    function disallowRouter(address router) external;


    function calcCoFiRate(uint256 bt_phi, uint256 xt, uint256 np) external view returns (uint256 at);


    function currentCoFiRate(address pair, uint256 np) external view returns (uint256);


    function currentThreshold(address pair, uint256 np, uint256 cofiRate) external view returns (uint256);


    function stdMiningRateAndAmount(address pair, uint256 np, uint256 thetaFee) external view returns (uint256 cofiRate, uint256 stdAmount);


    function calcDensity(uint256 _stdAmount) external view returns (uint256);


    function calcLambda(uint256 x, uint256 y) external pure returns (uint256);


    function actualMiningAmountAndDensity(address pair, uint256 thetaFee, uint256 x, uint256 y, uint256 np) external view returns (uint256 amount, uint256 density, uint256 cofiRate);


    function distributeReward(address pair, uint256 thetaFee, uint256 x, uint256 y, uint256 np, address rewardTo) external;


    function clearPendingRewardOfCNode() external;


    function clearPendingRewardOfLP(address pair) external;


    function getPendingRewardOfCNode() external view returns (uint256);


    function getPendingRewardOfLP(address pair) external view returns (uint256);


    function getCoFiRateCache(address pair) external view returns (uint256 cofiRate, uint256 updatedBlock);

}// GPL-3.0-or-later
pragma solidity 0.6.12;



contract CoFiXRouter02 is ICoFiXRouter02 {

    using SafeMath for uint;

    address public immutable override factory;
    address public immutable uniFactory;
    address public immutable override WETH;

    uint256 internal constant NEST_ORACLE_FEE = 0.01 ether;

    modifier ensure(uint deadline) {

        require(deadline >= block.timestamp, 'CRouter: EXPIRED');
        _;
    }

    constructor(address _factory, address _uniFactory, address _WETH) public {
        factory = _factory;
        uniFactory = _uniFactory;
        WETH = _WETH;
    }

    receive() external payable {}

    function pairFor(address _factory, address token) internal view returns (address pair) {

        return ICoFiXFactory(_factory).getPair(token);
    }

    function addLiquidity(
        address token,
        uint amountETH,
        uint amountToken,
        uint liquidityMin,
        address to,
        uint deadline
    ) external override payable ensure(deadline) returns (uint liquidity)
    {

        if (ICoFiXFactory(factory).getPair(token) == address(0)) {
            ICoFiXFactory(factory).createPair(token);
        }
        require(msg.value > amountETH, "CRouter: insufficient msg.value");
        uint256 _oracleFee = msg.value.sub(amountETH);
        address pair = pairFor(factory, token);
        if (amountToken > 0 ) { // support for tokens which do not allow to transfer zero values
            TransferHelper.safeTransferFrom(token, msg.sender, pair, amountToken);
        }
        if (amountETH > 0) {
            IWETH(WETH).deposit{value: amountETH}();
            assert(IWETH(WETH).transfer(pair, amountETH));
        }
        uint256 oracleFeeChange;
        (liquidity, oracleFeeChange) = ICoFiXPair(pair).mint{value: _oracleFee}(to);
        require(liquidity >= liquidityMin, "CRouter: less liquidity than expected");
        if (oracleFeeChange > 0) TransferHelper.safeTransferETH(msg.sender, oracleFeeChange);
    }

    function addLiquidityAndStake(
        address token,
        uint amountETH,
        uint amountToken,
        uint liquidityMin,
        address to,
        uint deadline
    ) external override payable ensure(deadline) returns (uint liquidity)
    {

        require(msg.value > amountETH, "CRouter: insufficient msg.value");
        uint256 _oracleFee = msg.value.sub(amountETH);
        address pair = pairFor(factory, token);
        require(pair != address(0), "CRouter: invalid pair");
        if (amountToken > 0 ) { // support for tokens which do not allow to transfer zero values
            TransferHelper.safeTransferFrom(token, msg.sender, pair, amountToken);
        }
        if (amountETH > 0) {
            IWETH(WETH).deposit{value: amountETH}();
            assert(IWETH(WETH).transfer(pair, amountETH));
        }
        uint256 oracleFeeChange;
        (liquidity, oracleFeeChange) = ICoFiXPair(pair).mint{value: _oracleFee}(address(this));
        require(liquidity >= liquidityMin, "CRouter: less liquidity than expected");

        address pool = ICoFiXVaultForLP(ICoFiXFactory(factory).getVaultForLP()).stakingPoolForPair(pair);
        require(pool != address(0), "CRouter: invalid staking pool");
        ICoFiXPair(pair).approve(pool, liquidity);
        ICoFiXStakingRewards(pool).stakeForOther(to, liquidity);
        ICoFiXPair(pair).approve(pool, 0); // ensure
        if (oracleFeeChange > 0) TransferHelper.safeTransferETH(msg.sender, oracleFeeChange);
    }

    function removeLiquidityGetToken(
        address token,
        uint liquidity,
        uint amountTokenMin,
        address to,
        uint deadline
    ) external override payable ensure(deadline) returns (uint amountToken)
    {

        require(msg.value > 0, "CRouter: insufficient msg.value");
        address pair = pairFor(factory, token);
        ICoFiXPair(pair).transferFrom(msg.sender, pair, liquidity); // send liquidity to pair
        uint oracleFeeChange; 
        (amountToken, oracleFeeChange) = ICoFiXPair(pair).burn{value: msg.value}(token, to);
        require(amountToken >= amountTokenMin, "CRouter: got less than expected");
        if (oracleFeeChange > 0) TransferHelper.safeTransferETH(msg.sender, oracleFeeChange);
    }

    function removeLiquidityGetETH(
        address token,
        uint liquidity,
        uint amountETHMin,
        address to,
        uint deadline
    ) external override payable ensure(deadline) returns (uint amountETH)
    {

        require(msg.value > 0, "CRouter: insufficient msg.value");
        address pair = pairFor(factory, token);
        ICoFiXPair(pair).transferFrom(msg.sender, pair, liquidity); // send liquidity to pair
        uint oracleFeeChange; 
        (amountETH, oracleFeeChange) = ICoFiXPair(pair).burn{value: msg.value}(WETH, address(this));
        require(amountETH >= amountETHMin, "CRouter: got less than expected");
        IWETH(WETH).withdraw(amountETH);
        TransferHelper.safeTransferETH(to, amountETH);
        if (oracleFeeChange > 0) TransferHelper.safeTransferETH(msg.sender, oracleFeeChange);
    }

    function swapExactETHForTokens(
        address token,
        uint amountIn,
        uint amountOutMin,
        address to,
        address rewardTo,
        uint deadline
    ) external override payable ensure(deadline) returns (uint _amountIn, uint _amountOut)
    {

        require(msg.value > amountIn, "CRouter: insufficient msg.value");
        IWETH(WETH).deposit{value: amountIn}();
        address pair = pairFor(factory, token);
        assert(IWETH(WETH).transfer(pair, amountIn));
        uint oracleFeeChange; 
        uint256[4] memory tradeInfo;
        (_amountIn, _amountOut, oracleFeeChange, tradeInfo) = ICoFiXPair(pair).swapWithExact{
            value: msg.value.sub(amountIn)}(token, to);
        require(_amountOut >= amountOutMin, "CRouter: got less than expected");

        address vaultForTrader = ICoFiXFactory(factory).getVaultForTrader();
        if (tradeInfo[0] > 0 && rewardTo != address(0) && vaultForTrader != address(0)) {
            ICoFiXVaultForTrader(vaultForTrader).distributeReward(pair, tradeInfo[0], tradeInfo[1], tradeInfo[2], tradeInfo[3], rewardTo);
        }

        if (oracleFeeChange > 0) TransferHelper.safeTransferETH(msg.sender, oracleFeeChange);
    }

    function swapExactTokensForTokens(
        address tokenIn,
        address tokenOut,
        uint amountIn,
        uint amountOutMin,
        address to,
        address rewardTo,
        uint deadline
    ) external override payable ensure(deadline) returns (uint _amountIn, uint _amountOut) {


        require(msg.value > 0, "CRouter: insufficient msg.value");
        address[2] memory pairs; // [pairIn, pairOut]

        pairs[0] = pairFor(factory, tokenIn);
        TransferHelper.safeTransferFrom(tokenIn, msg.sender, pairs[0], amountIn);
        uint oracleFeeChange;
        uint256[4] memory tradeInfo;
        (_amountIn, _amountOut, oracleFeeChange, tradeInfo) = ICoFiXPair(pairs[0]).swapWithExact{value: msg.value}(WETH, address(this));

        address vaultForTrader = ICoFiXFactory(factory).getVaultForTrader();
        if (tradeInfo[0] > 0 && rewardTo != address(0) && vaultForTrader != address(0)) {
            ICoFiXVaultForTrader(vaultForTrader).distributeReward(pairs[0], tradeInfo[0], tradeInfo[1], tradeInfo[2], tradeInfo[3], rewardTo);
        }

        pairs[1] = pairFor(factory, tokenOut);
        assert(IWETH(WETH).transfer(pairs[1], _amountOut)); // swap with all amountOut in last swap
        (, _amountOut, oracleFeeChange, tradeInfo) = ICoFiXPair(pairs[1]).swapWithExact{value: oracleFeeChange}(tokenOut, to);
        require(_amountOut >= amountOutMin, "CRouter: got less than expected");

        if (tradeInfo[0] > 0 && rewardTo != address(0) && vaultForTrader != address(0)) {
            ICoFiXVaultForTrader(vaultForTrader).distributeReward(pairs[1], tradeInfo[0], tradeInfo[1], tradeInfo[2], tradeInfo[3], rewardTo);
        }

        if (oracleFeeChange > 0) TransferHelper.safeTransferETH(msg.sender, oracleFeeChange);
    }

    function swapExactTokensForETH(
        address token,
        uint amountIn,
        uint amountOutMin,
        address to,
        address rewardTo,
        uint deadline
    ) external override payable ensure(deadline) returns (uint _amountIn, uint _amountOut)
    {

        require(msg.value > 0, "CRouter: insufficient msg.value");
        address pair = pairFor(factory, token);
        TransferHelper.safeTransferFrom(token, msg.sender, pair, amountIn);
        uint oracleFeeChange; 
        uint256[4] memory tradeInfo;
        (_amountIn, _amountOut, oracleFeeChange, tradeInfo) = ICoFiXPair(pair).swapWithExact{value: msg.value}(WETH, address(this));
        require(_amountOut >= amountOutMin, "CRouter: got less than expected");
        IWETH(WETH).withdraw(_amountOut);
        TransferHelper.safeTransferETH(to, _amountOut);

        address vaultForTrader = ICoFiXFactory(factory).getVaultForTrader();
        if (tradeInfo[0] > 0 && rewardTo != address(0) && vaultForTrader != address(0)) {
            ICoFiXVaultForTrader(vaultForTrader).distributeReward(pair, tradeInfo[0], tradeInfo[1], tradeInfo[2], tradeInfo[3], rewardTo);
        }

        if (oracleFeeChange > 0) TransferHelper.safeTransferETH(msg.sender, oracleFeeChange);
    }

    function hybridSwapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        DEX_TYPE[] calldata dexes,
        address to,
        address rewardTo,
        uint deadline
    ) external override payable ensure(deadline) returns (uint[] memory amounts) {

        require(path.length >= 2, "CRouter: invalid path");
        require(dexes.length == path.length - 1, "CRouter: invalid dexes");
        _checkOracleFee(dexes, msg.value);

        TransferHelper.safeTransferFrom(
            path[0], msg.sender,  getPairForDEX(path[0], path[1], dexes[0]), amountIn
        );

        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        _hybridSwap(path, dexes, amounts, to, rewardTo);

        require(amounts[amounts.length - 1] >= amountOutMin, "CRouter: insufficient output amount ");
    }

    function hybridSwapExactETHForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        DEX_TYPE[] calldata dexes,
        address to,
        address rewardTo,
        uint deadline
    ) external override payable ensure(deadline) returns (uint[] memory amounts) {

        require(path.length >= 2 && path[0] == WETH, "CRouter: invalid path");
        require(dexes.length == path.length - 1, "CRouter: invalid dexes");
        _checkOracleFee(dexes, msg.value.sub(amountIn)); // would revert if msg.value is less than amountIn

        IWETH(WETH).deposit{value: amountIn}();
        assert(IWETH(WETH).transfer(getPairForDEX(path[0], path[1], dexes[0]), amountIn));

        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        _hybridSwap(path, dexes, amounts, to, rewardTo);

        require(amounts[amounts.length - 1] >= amountOutMin, "CRouter: insufficient output amount ");
    }

    function hybridSwapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        DEX_TYPE[] calldata dexes,
        address to,
        address rewardTo,
        uint deadline
    ) external override payable ensure(deadline) returns (uint[] memory amounts) {

        require(path.length >= 2 && path[path.length - 1] == WETH, "CRouter: invalid path");
        require(dexes.length == path.length - 1, "CRouter: invalid dexes");
        _checkOracleFee(dexes, msg.value);

        TransferHelper.safeTransferFrom(
            path[0], msg.sender, getPairForDEX(path[0], path[1], dexes[0]), amountIn
        );

        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        _hybridSwap(path, dexes, amounts, address(this), rewardTo);

        require(amounts[amounts.length - 1] >= amountOutMin, "CRouter: insufficient output amount ");

        IWETH(WETH).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }


    function _checkOracleFee(DEX_TYPE[] memory dexes, uint256 oracleFee) internal pure {

        uint cofixCnt;
        for (uint i; i < dexes.length; i++) {
            if (dexes[i] == DEX_TYPE.COFIX) {
                cofixCnt++;
            }
        }
        require(oracleFee == NEST_ORACLE_FEE.mul(cofixCnt), "CRouter: wrong oracle fee");
    }

    function _hybridSwap(address[] memory path, DEX_TYPE[] memory dexes, uint[] memory amounts, address _to, address rewardTo) internal {

        for (uint i; i < path.length - 1; i++) {
            if (dexes[i] == DEX_TYPE.COFIX) {
                _swapOnCoFiX(i, path, dexes, amounts, _to, rewardTo);
            } else if (dexes[i] == DEX_TYPE.UNISWAP) {
                _swapOnUniswap(i, path, dexes, amounts, _to);
            } else {
                revert("CRouter: unknown dex");
            }
        }
    }

    function _swapOnUniswap(uint i, address[] memory path, DEX_TYPE[] memory dexes, uint[] memory amounts, address _to) internal {

        address pair = getPairForDEX(path[i], path[i + 1], DEX_TYPE.UNISWAP);

        (address token0,) = UniswapV2Library.sortTokens(path[i], path[i + 1]);
        {
            (uint reserveIn, uint reserveOut) = UniswapV2Library.getReserves(uniFactory, path[i], path[i + 1]);
            amounts[i + 1] = UniswapV2Library.getAmountOut(amounts[i], reserveIn, reserveOut);
        }
        uint amountOut = amounts[i + 1];
        (uint amount0Out, uint amount1Out) = path[i] == token0 ? (uint(0), amountOut) : (amountOut, uint(0));

        address to;
        {
            if (i < path.length - 2) {
                to = getPairForDEX(path[i + 1], path[i + 2], dexes[i + 1]);
            } else {
                to = _to;
            }
        }

        IUniswapV2Pair(pair).swap(
            amount0Out, amount1Out, to, new bytes(0)
        );
    }
    
    function _swapOnCoFiX(uint i, address[] memory path, DEX_TYPE[] memory dexes, uint[] memory amounts, address _to, address rewardTo) internal {

            address pair = getPairForDEX(path[i], path[i + 1], DEX_TYPE.COFIX);
            address to;
            if (i < path.length - 2) {
                to = getPairForDEX(path[i + 1], path[i + 2], dexes[i + 1]);
            } else {
                to = _to;
            }
            {
                uint256[4] memory tradeInfo;
                (,amounts[i+1],,tradeInfo) = ICoFiXPair(pair).swapWithExact{value: NEST_ORACLE_FEE}(path[i + 1], to);

                address vaultForTrader = ICoFiXFactory(factory).getVaultForTrader();
                if (tradeInfo[0] > 0 && rewardTo != address(0) && vaultForTrader != address(0)) {
                    ICoFiXVaultForTrader(vaultForTrader).distributeReward(pair, tradeInfo[0], tradeInfo[1], tradeInfo[2], tradeInfo[3], rewardTo);
                }
            }
    } 

    function isCoFiXNativeSupported(address input, address output) public view returns (bool supported, address pair) {

        if (input != WETH && output != WETH)
            return (false, pair);
        if (input != WETH) {
            pair = pairFor(factory, input);
        } else if (output != WETH) {
            pair = pairFor(factory, output);
        }
        if (pair != address(0)) // TODO: add check for reserves
            supported = true;
        return (supported, pair);
    }

    function getPairForDEX(address input, address output, DEX_TYPE dex) public view returns (address pair) {

        if (dex == DEX_TYPE.COFIX) {
            bool supported;
            (supported, pair) = isCoFiXNativeSupported(input, output);
            if (!supported) {
                revert("CRouter: not available on CoFiX");
            }
        } else if (dex == DEX_TYPE.UNISWAP) {
            pair = UniswapV2Library.pairFor(uniFactory, input, output);
        } else {
            revert("CRouter: unknown dex");
        }
    }

    function hybridPair(address input, address output) public view returns (bool useCoFiX, address pair) {

        (useCoFiX, pair) = isCoFiXNativeSupported(input, output);
        if (useCoFiX) {
            return (useCoFiX, pair);
        }
        return (false, UniswapV2Library.pairFor(uniFactory, input, output));
    }
}