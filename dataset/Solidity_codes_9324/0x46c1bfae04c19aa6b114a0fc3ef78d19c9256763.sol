
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.1;

library Address {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

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

pragma solidity ^0.8.0;


library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}pragma solidity >=0.5.0;

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

}pragma solidity >=0.5.0;

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

}pragma solidity >=0.6.2;

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

}pragma solidity >=0.6.2;


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

}pragma solidity 0.8.6;

library Math {

    function sqrt(uint256 y) internal pure returns (uint256 z) {

        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}// MIT

pragma solidity 0.8.6;


contract LiquidityBootstrapAuction is ReentrancyGuard, Ownable {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    IERC20 public immutable asto;
    IERC20 public immutable usdc;
    uint256 public immutable totalRewardAmount;
    uint256 public auctionStartTime;
    uint256 public totalDepositedUSDC;
    uint256 public totalDepositedASTO;
    address public liquidityPair;
    uint256 public lpTokenAmount;
    uint16 public constant REWARDS_RELEASE_DURATION_IN_WEEKS = 12;
    uint16 public constant HOURS_PER_DAY = 24;
    uint256 internal constant SECONDS_PER_WEEK = 604800;
    uint256 public constant SECONDS_PER_DAY = 86400;
    uint256 public constant SECONDS_PER_HOUR = 3600;

    mapping(address => uint256) public depositedUSDC;
    mapping(address => uint256) public depositedASTO;
    mapping(address => bool) public usdcWithdrawnOnDay6;
    mapping(address => bool) public usdcWithdrawnOnDay7;
    mapping(address => uint256) public rewardClaimed;
    mapping(address => uint256) public lpClaimed;

    struct Timeline {
        uint256 auctionStartTime;
        uint256 astoDepositEndTime;
        uint256 usdcDepositEndTime;
        uint256 auctionEndTime;
    }

    struct Stats {
        uint256 totalDepositedASTO;
        uint256 totalDepositedUSDC;
        uint256 depositedASTO;
        uint256 depositedUSDC;
    }

    event ASTODeposited(address indexed recipient, uint256 amount, Stats stats);
    event USDCDeposited(address indexed recipient, uint256 amount, Stats stats);
    event USDCWithdrawn(address indexed recipient, uint256 amount, Stats stats);
    event RewardsClaimed(address indexed recipient, uint256 amount);
    event LiquidityAdded(uint256 astoAmount, uint256 usdcAmount, uint256 lpTokenAmount);
    event TokenWithdrawn(address indexed recipient, uint256 tokenAmount);

    constructor(
        address multisig,
        IERC20 _asto,
        IERC20 _usdc,
        uint256 rewardAmount,
        uint256 startTime
    ) {
        require(address(_asto) != address(0), "invalid token address");
        require(address(_usdc) != address(0), "invalid token address");

        asto = _asto;
        usdc = _usdc;
        totalRewardAmount = rewardAmount;
        auctionStartTime = startTime;
        _transferOwnership(multisig);
    }

    function deposit(uint256 astoAmount, uint256 usdcAmount) external {

        if (astoAmount > 0) {
            depositASTO(astoAmount);
        }

        if (usdcAmount > 0) {
            depositUSDC(usdcAmount);
        }
    }

    function depositASTO(uint256 amount) public nonReentrant {

        require(astoDepositAllowed(), "deposit not allowed");
        require(asto.balanceOf(msg.sender) >= amount, "insufficient balance");

        depositedASTO[msg.sender] += amount;
        totalDepositedASTO += amount;
        emit ASTODeposited(msg.sender, amount, stats(msg.sender));

        asto.safeTransferFrom(msg.sender, address(this), amount);
    }

    function depositUSDC(uint256 amount) public nonReentrant {

        require(usdcDepositAllowed(), "deposit not allowed");
        require(usdc.balanceOf(msg.sender) >= amount, "insufficient balance");

        depositedUSDC[msg.sender] += amount;
        totalDepositedUSDC += amount;
        emit USDCDeposited(msg.sender, amount, stats(msg.sender));

        usdc.safeTransferFrom(msg.sender, address(this), amount);
    }

    function withdrawableUSDCAmount(address recipient) public view returns (uint256) {

        if (currentTime() < auctionStartTime || currentTime() >= auctionEndTime()) {
            return 0;
        }

        if (currentTime() < usdcDepositEndTime()) {
            return depositedUSDC[recipient];
        } else if (currentTime() >= usdcWithdrawLastDay()) {
            if (usdcWithdrawnOnDay7[recipient]) {
                return 0;
            }
            uint256 elapsedTime = currentTime() - usdcWithdrawLastDay();
            uint256 maxAmount = depositedUSDC[recipient] / 2;

            if (elapsedTime > SECONDS_PER_DAY) {
                return 0;
            }

            uint256 elapsedTimeRatio = (SECONDS_PER_DAY - elapsedTime) / SECONDS_PER_HOUR + 1;

            return (maxAmount * elapsedTimeRatio) / HOURS_PER_DAY;
        }
        return usdcWithdrawnOnDay6[recipient] ? 0 : depositedUSDC[msg.sender] / 2;
    }

    function withdrawUSDC(uint256 amount) external nonReentrant {

        require(usdcWithdrawAllowed(), "withdraw not allowed");
        require(amount > 0, "amount should greater than zero");
        require(amount <= withdrawableUSDCAmount(msg.sender), "amount exceeded allowance");

        if (currentTime() >= usdcWithdrawLastDay()) {
            usdcWithdrawnOnDay7[msg.sender] = true;
        } else if (currentTime() >= usdcDepositEndTime()) {
            usdcWithdrawnOnDay6[msg.sender] = true;
        }

        depositedUSDC[msg.sender] -= amount;
        totalDepositedUSDC -= amount;

        emit USDCWithdrawn(msg.sender, amount, stats(msg.sender));

        usdc.safeTransfer(msg.sender, amount);
    }

    function optimalDeposit(
        uint256 amtA,
        uint256 amtB,
        uint256 resA,
        uint256 resB
    ) internal pure returns (uint256) {

        require(amtA.mul(resB) >= amtB.mul(resA), "invalid token amount");

        uint256 a = 997;
        uint256 b = uint256(1997).mul(resA);
        uint256 _c = (amtA.mul(resB)).sub(amtB.mul(resA));
        uint256 c = _c.mul(1000).div(amtB.add(resB)).mul(resA);

        uint256 d = a.mul(c).mul(4);
        uint256 e = Math.sqrt(b.mul(b).add(d));

        uint256 numerator = e.sub(b);
        uint256 denominator = a.mul(2);

        return numerator.div(denominator);
    }

    function addLiquidityToExchange(address router, address factory) external nonReentrant onlyOwner {

        require(currentTime() >= auctionEndTime(), "auction not finished");
        require(totalDepositedUSDC > 0, "no USDC deposited");
        require(totalDepositedASTO > 0, "no ASTO deposited");

        usdc.approve(router, type(uint256).max);
        asto.approve(router, type(uint256).max);

        uint256 usdcSent;
        uint256 astoSent;

        (usdcSent, astoSent, lpTokenAmount) = IUniswapV2Router02(router).addLiquidity(
            address(usdc),
            address(asto),
            totalDepositedUSDC,
            totalDepositedASTO,
            0,
            0,
            address(this),
            block.timestamp
        );

        liquidityPair = IUniswapV2Factory(factory).getPair(address(asto), address(usdc));

        if (usdcSent == totalDepositedUSDC && astoSent == totalDepositedASTO) {
            emit LiquidityAdded(astoSent, usdcSent, lpTokenAmount);
            return;
        }


        uint256 resASTO;
        uint256 resUSDC;
        if (IUniswapV2Pair(liquidityPair).token0() == address(asto)) {
            (resASTO, resUSDC, ) = IUniswapV2Pair(liquidityPair).getReserves();
        } else {
            (resUSDC, resASTO, ) = IUniswapV2Pair(liquidityPair).getReserves();
        }

        uint256 swapAmt;
        address[] memory path = new address[](2);
        bool isReserved;
        uint256 balance;
        if (usdcSent == totalDepositedUSDC) {
            balance = totalDepositedASTO - astoSent;
            swapAmt = optimalDeposit(balance, 0, resASTO, resUSDC);
            (path[0], path[1]) = (address(asto), address(usdc));
        } else {
            balance = totalDepositedUSDC - usdcSent;
            swapAmt = optimalDeposit(balance, 0, resUSDC, resASTO);
            (path[0], path[1]) = (address(usdc), address(asto));
            isReserved = true;
        }

        require(swapAmt > 0, "swapAmt must great then 0");

        uint256[] memory amounts = IUniswapV2Router02(router).swapExactTokensForTokens(
            swapAmt,
            0,
            path,
            address(this),
            block.timestamp
        );

        (uint256 amountA, , uint256 moreLPAmount) = IUniswapV2Router02(router).addLiquidity(
            isReserved ? address(usdc) : address(asto),
            isReserved ? address(asto) : address(usdc),
            balance - swapAmt,
            amounts[1],
            0,
            0,
            address(this),
            block.timestamp
        );

        lpTokenAmount += moreLPAmount;
        uint256 totalASTOSent = isReserved ? astoSent : astoSent + swapAmt + amountA;
        uint256 totalUSDCSent = isReserved ? usdcSent + swapAmt + amountA : usdcSent;
        emit LiquidityAdded(totalASTOSent, totalUSDCSent, lpTokenAmount);
    }

    function claimLPToken() external nonReentrant {

        uint256 claimable = claimableLPAmount(msg.sender);
        require(claimable > 0, "no claimable token");

        lpClaimed[msg.sender] += claimable;

        require(IUniswapV2Pair(liquidityPair).transfer(msg.sender, claimable), "insufficient LP token balance");
    }

    function claimableLPAmount(address recipient) public view returns (uint256) {

        if (currentTime() < lpTokenReleaseTime()) {
            return 0;
        }
        uint256 claimableLPTokensForASTO = (lpTokenAmount * depositedASTO[recipient]) / (2 * totalDepositedASTO);
        uint256 claimableLPTokensForUSDC = (lpTokenAmount * depositedUSDC[recipient]) / (2 * totalDepositedUSDC);
        uint256 total = claimableLPTokensForASTO + claimableLPTokensForUSDC;
        return total - lpClaimed[recipient];
    }

    function claimRewards(uint256 amount) external nonReentrant {

        uint256 amountVested;
        (, amountVested) = claimableRewards(msg.sender);

        require(amount <= amountVested, "amount not claimable");
        rewardClaimed[msg.sender] += amount;

        require(asto.balanceOf(address(this)) >= amount, "insufficient ASTO balance");
        asto.safeTransfer(msg.sender, amount);

        emit RewardsClaimed(msg.sender, amount);
    }

    function claimableRewards(address recipient) public view returns (uint16, uint256) {

        if (currentTime() < auctionEndTime()) {
            return (0, 0);
        }

        uint256 elapsedTime = currentTime() - auctionEndTime();
        uint16 elapsedWeeks = uint16(elapsedTime / SECONDS_PER_WEEK);

        if (elapsedWeeks >= REWARDS_RELEASE_DURATION_IN_WEEKS) {
            uint256 remaining = calculateRewards(recipient) - rewardClaimed[recipient];
            return (REWARDS_RELEASE_DURATION_IN_WEEKS, remaining);
        } else {
            uint256 amountVestedPerWeek = calculateRewards(recipient) / REWARDS_RELEASE_DURATION_IN_WEEKS;
            uint256 amountVested = amountVestedPerWeek * elapsedWeeks - rewardClaimed[recipient];
            return (elapsedWeeks, amountVested);
        }
    }

    function calculateRewards(address recipient) public view returns (uint256) {

        return calculateASTORewards(recipient) + calculateUSDCRewards(recipient);
    }

    function calculateASTORewards(address recipient) public view returns (uint256) {

        if (totalDepositedASTO == 0) {
            return 0;
        }
        return (astoRewardAmount() * depositedASTO[recipient]) / totalDepositedASTO;
    }

    function calculateUSDCRewards(address recipient) public view returns (uint256) {

        if (totalDepositedUSDC == 0) {
            return 0;
        }
        return (usdcRewardAmount() * depositedUSDC[recipient]) / totalDepositedUSDC;
    }

    function withdrawToken(address token, uint256 amount) external onlyOwner {

        require(token != address(0), "invalid token address");
        uint256 balance = IERC20(token).balanceOf(address(this));
        require(amount <= balance, "amount should not exceed balance");
        IERC20(token).safeTransfer(msg.sender, amount);
        emit TokenWithdrawn(msg.sender, amount);
    }

    function astoDepositAllowed() public view returns (bool) {

        return currentTime() >= auctionStartTime && currentTime() < astoDepositEndTime();
    }

    function usdcDepositAllowed() public view returns (bool) {

        return currentTime() >= auctionStartTime && currentTime() < usdcDepositEndTime();
    }

    function usdcWithdrawAllowed() public view returns (bool) {

        return currentTime() >= auctionStartTime && currentTime() < auctionEndTime();
    }

    function astoDepositEndTime() public view returns (uint256) {

        return auctionStartTime + 3 days;
    }

    function usdcDepositEndTime() public view returns (uint256) {

        return auctionStartTime + 5 days;
    }

    function usdcWithdrawLastDay() public view returns (uint256) {

        return auctionStartTime + 6 days;
    }

    function auctionEndTime() public view returns (uint256) {

        return auctionStartTime + 7 days;
    }

    function lpTokenReleaseTime() public view returns (uint256) {

        return auctionEndTime() + 12 weeks;
    }

    function astoRewardAmount() public view returns (uint256) {

        return (totalRewardAmount * 75) / 100;
    }

    function usdcRewardAmount() public view returns (uint256) {

        return (totalRewardAmount * 25) / 100;
    }

    function setStartTime(uint256 newStartTime) external onlyOwner {

        auctionStartTime = newStartTime;
    }

    function timeline() public view returns (Timeline memory) {

        return Timeline(auctionStartTime, astoDepositEndTime(), usdcDepositEndTime(), auctionEndTime());
    }

    function stats(address depositor) public view returns (Stats memory) {

        return Stats(totalDepositedASTO, totalDepositedUSDC, depositedASTO[depositor], depositedUSDC[depositor]);
    }

    function currentTime() public view virtual returns (uint256) {

        return block.timestamp;
    }
}