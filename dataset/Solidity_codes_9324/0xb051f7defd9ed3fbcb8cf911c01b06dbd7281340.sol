


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
}



pragma solidity >=0.4.24 <0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

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

    function _isConstructor() private view returns (bool) {
        return !Address.isContract(address(this));
    }
}



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
}



pragma solidity ^0.6.0;

interface IUniswapV2Factory {

    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);


    function feeToSetter() external view returns (address);


    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);


    function allPairs(uint256) external view returns (address pair);


    function allPairsLength() external view returns (uint256);


    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);


    function setFeeTo(address) external;


    function setFeeToSetter(address) external;

}



pragma solidity ^0.6.0;

interface IUniswapV2Pair {

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);


    function symbol() external pure returns (string memory);


    function decimals() external pure returns (uint8);


    function totalSupply() external view returns (uint256);


    function balanceOf(address owner) external view returns (uint256);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 value) external returns (bool);


    function transfer(address to, uint256 value) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);


    function DOMAIN_SEPARATOR() external view returns (bytes32);


    function PERMIT_TYPEHASH() external pure returns (bytes32);


    function nonces(address owner) external view returns (uint256);


    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);


    function factory() external view returns (address);


    function token0() external view returns (address);


    function token1() external view returns (address);


    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );


    function price0CumulativeLast() external view returns (uint256);


    function price1CumulativeLast() external view returns (uint256);


    function kLast() external view returns (uint256);


    function mint(address to) external returns (uint256 liquidity);


    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);


    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;


    function skim(address to) external;


    function sync() external;


    function initialize(address, address) external;

}


pragma solidity >=0.6.2;

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


pragma solidity >=0.6.2;


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


pragma solidity ^0.6.2;


abstract contract Priviledgeable {
    using SafeMath for uint256;
    using SafeMath for uint256;

    event PriviledgeGranted(address indexed admin);
    event PriviledgeRevoked(address indexed admin);

    modifier onlyAdmin() {
        require(
            _priviledgeTable[msg.sender],
            "Priviledgeable: caller is not the owner"
        );
        _;
    }

    mapping(address => bool) private _priviledgeTable;

    constructor() internal {
        _priviledgeTable[msg.sender] = true;
    }

    function addAdmin(address _admin) external onlyAdmin returns (bool) {
        require(_admin != address(0), "Admin address cannot be 0");
        return _addAdmin(_admin);
    }

    function removeAdmin(address _admin) external onlyAdmin returns (bool) {
        require(_admin != address(0), "Admin address cannot be 0");
        _priviledgeTable[_admin] = false;
        emit PriviledgeRevoked(_admin);

        return true;
    }

    function isAdmin(address _who) external view returns (bool) {
        return _priviledgeTable[_who];
    }

    function _addAdmin(address _admin) internal returns (bool) {
        _priviledgeTable[_admin] = true;
        emit PriviledgeGranted(_admin);
    }
}



pragma solidity ^0.6.0;

interface IEmiERC20 {

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);


    function totalSupply() external view returns (uint256);


    function balanceOf(address owner) external view returns (uint256);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 value) external returns (bool);


    function transfer(address to, uint256 value) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

}



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
}



pragma solidity >=0.6.2;


interface IEmiRouter {

    function factory() external pure returns (address);


    function WETH() external pure returns (address);


    function getReserves(IERC20 token0, IERC20 token1)
        external
        view
        returns (
            uint256 _reserve0,
            uint256 _reserve1,
            address poolAddresss
        );


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address ref
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );


    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        address ref
    ) external returns (uint256[] memory amounts);


    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address[] calldata pathDAI
    ) external returns (uint256[] memory amounts);


    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address[] calldata pathDAI
    ) external payable returns (uint256[] memory amounts);


    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address[] calldata pathDAI
    ) external returns (uint256[] memory amounts);


    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address[] calldata pathDAI
    ) external returns (uint256[] memory amounts);


    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address[] calldata pathDAI
    ) external payable returns (uint256[] memory amounts);


    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external view returns (uint256 amountOut);


    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external view returns (uint256 amountIn);


    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);


    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);


    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address[] calldata pathDAI
    ) external;


    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address[] calldata pathDAI
    ) external payable;


    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address[] calldata pathDAI
    ) external;

}



pragma solidity ^0.6.0;


interface IEmiswapRegistry {

    function pools(IERC20 token1, IERC20 token2)
        external
        view
        returns (IEmiswap);


    function isPool(address addr) external view returns (bool);


    function deploy(IERC20 tokenA, IERC20 tokenB) external returns (IEmiswap);

    function getAllPools() external view returns (IEmiswap[] memory);

}

interface IEmiswap {

    function fee() external view returns (uint256);


    function tokens(uint256 i) external view returns (IERC20);


    function deposit(
        uint256[] calldata amounts,
        uint256[] calldata minAmounts,
        address referral
    ) external payable returns (uint256 fairSupply);


    function withdraw(uint256 amount, uint256[] calldata minReturns) external;


    function getBalanceForAddition(IERC20 token)
        external
        view
        returns (uint256);


    function getBalanceForRemoval(IERC20 token) external view returns (uint256);


    function getReturn(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount
    ) external view returns (uint256, uint256);


    function swap(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 minReturn,
        address to,
        address referral
    ) external payable returns (uint256 returnAmount);


    function initialize(IERC20[] calldata assets) external;

}



pragma solidity ^0.6.0;


interface IOneSplit {

    function getExpectedReturn(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags
    )
        external
        view
        returns (uint256 returnAmount, uint256[] memory distribution);

}


pragma solidity ^0.6.2;
pragma experimental ABIEncoderV2;











contract EmiPrice2 is Initializable, Priviledgeable {

    using SafeMath for uint256;
    using SafeMath for uint256;
    address[3] public market;
    address public emiRouter;
    address public uniRouter;
    uint256 constant MARKET_OUR = 0;
    uint256 constant MARKET_UNISWAP = 1;
    uint256 constant MARKET_1INCH = 2;
    uint256 constant MAX_PATH_LENGTH = 5;

 string public codeVersion = "EmiPrice2 v1.0-200-g8d0b0fa";

    function initialize(
        address _market1,
        address _market2,
        address _market3,
        address _emirouter,
        address _unirouter
    ) public initializer {

        require(_market1 != address(0), "Market1 address cannot be 0");
        require(_market2 != address(0), "Market2 address cannot be 0");
        require(_market3 != address(0), "Market3 address cannot be 0");
        require(_emirouter != address(0), "EmiRouter address cannot be 0");
        require(_unirouter != address(0), "UniRouter address cannot be 0");

        market[0] = _market1;
        market[1] = _market2;
        market[2] = _market3;
        emiRouter = _emirouter;
        uniRouter = _unirouter;
        _addAdmin(msg.sender);
    }

    function getCoinPrices(
        address[] calldata _coins,
        address[] calldata _basictokens,
        uint8 _market
    ) external view returns (uint256[] memory prices) {

        require(_market < market.length, "Wrong market index");
        uint256[] memory _prices;

        _prices = new uint256[](_coins.length);

        if (_market == MARKET_UNISWAP) {
            _getUniswapPrice(_coins, _basictokens[0], _prices);
        } else if (_market == MARKET_OUR) {
            _getOurPrice(_coins, _basictokens, _prices);
        } else {
            _get1inchPrice(_coins, _basictokens[0], _prices);
        }

        return _prices;
    }

    function calcRoute(address _target, address _base)
        external
        view
        returns (address[] memory path)
    {

        return _calculateRoute(_target, _base);
    }

    function changeMarket(uint8 idx, address _market) external onlyAdmin {

        require(_market != address(0), "Token address cannot be 0");
        require(idx < 3, "Wrong market index");

        market[idx] = _market;
    }

    function changeUniRouter(address _router) external onlyAdmin {

        require(_router != address(0), "Router address cannot be 0");

        uniRouter = _router;
    }

    function changeEmiRouter(address _router) external onlyAdmin {

        require(_router != address(0), "Router address cannot be 0");

        emiRouter = _router;
    }

    function _getUniswapPrice(
        address[] memory _coins,
        address _base,
        uint256[] memory _prices
    ) internal view {

        uint256 base_decimal = IEmiERC20(_base).decimals();

        for (uint256 i = 0; i < _coins.length; i++) {
            uint256 target_decimal = IEmiERC20(_coins[i]).decimals();

            if (_coins[i] == _base) {
                _prices[i] = 10**18; // special case: 1 for base token
                continue;
            }

            uint256 _in = 10**target_decimal;

            address[] memory _path = new address[](2);
            _path[0] = _coins[i];
            _path[1] = _base;
            uint256[] memory _amts =
                IUniswapV2Router02(uniRouter).getAmountsOut(_in, _path);
            if (_amts.length > 0) {
                _prices[i] = _amts[_amts.length - 1].mul(
                    10**(18 - base_decimal)
                );
            } else {
                _prices[i] = 0;
            }
        }
    }

    function _getOurPrice(
        address[] memory _coins,
        address[] memory _base,
        uint256[] memory _prices
    ) internal view {

        IEmiswapRegistry _factory = IEmiswapRegistry(market[MARKET_OUR]);
        IEmiswap _p;

        if (address(_factory) == address(0)) {
            return;
        }

        for (uint256 i = 0; i < _coins.length; i++) {
            uint256 target_decimal = IEmiERC20(_coins[i]).decimals();

            for (uint256 m = 0; m < _base.length; m++) {
                if (_coins[i] == _base[m]) {
                    _prices[i] = 10**18; // special case: 1 for base token
                    break;
                }
                uint256 base_decimal = IEmiERC20(_base[m]).decimals();

                (address t0, address t1) =
                    (_coins[i] < _base[m])
                        ? (_coins[i], _base[m])
                        : (_base[m], _coins[i]);
                _p = IEmiswap(_factory.pools(IERC20(t0), IERC20(t1))); // do we have direct pair?
                address[] memory _route;

                if (address(_p) == address(0)) {
                    _route = _calculateRoute(_coins[i], _base[m]);
                } else { // just take direct pair
                    _route = new address[](2);
                    _route[0] = _coins[i];
                    _route[1] = _base[m];
                }
                if (_route.length == 0) {
                    continue; // try next base token
                } else {
                    uint256 _in = 10**target_decimal;
                    uint256[] memory _amts =
                        IEmiRouter(emiRouter).getAmountsOut(_in, _route);
                    if (_amts.length > 0) {
                        _prices[i] = _amts[_amts.length - 1].mul(
                            10**(18 - base_decimal)
                        );
                    } else {
                        _prices[i] = 0;
                    }
                    break;
                }
            }
        }
    }

    function _get1inchPrice(
        address[] memory _coins,
        address _base,
        uint256[] memory _prices
    ) internal view {

        IOneSplit _factory = IOneSplit(market[MARKET_1INCH]);

        if (address(_factory) == address(0)) {
            return;
        }
        for (uint256 i = 0; i < _coins.length; i++) {
            uint256 d = uint256(IEmiERC20(_coins[i]).decimals());
            (_prices[i], ) = _factory.getExpectedReturn(
                IERC20(_coins[i]),
                IERC20(_base),
                10**d,
                1,
                0
            );
        }
    }

    function _calculateRoute(address _target, address _base)
        internal
        view
        returns (address[] memory path)
    {

        IEmiswap[] memory pools =
            IEmiswapRegistry(market[MARKET_OUR]).getAllPools(); // gets all pairs
        uint8[] memory pairIdx = new uint8[](pools.length); // vector for storing path step indexes

        _markPathStep(pools, pairIdx, 1, _target); // start from 1 step
        address[] memory _curStep = new address[](pools.length);
        _curStep[0] = _target; // store target address as first current step
        address[] memory _prevStep = new address[](pools.length);

        for (uint8 i = 2; i < MAX_PATH_LENGTH; i++) {
            _moveSteps(_prevStep, _curStep);

            for (uint256 j = 0; j < pools.length; j++) {
                if (pairIdx[j] == i - 1) {
                    address _a = _getAddressFromPrevStep(pools[j], _prevStep);
                    _markPathStep(pools, pairIdx, i, _a);
                    _addToCurrentStep(_curStep, _a);
                }
            }
        }

        uint8 baseIdx = 0;

        for (uint8 i = 0; i < pools.length; i++) {
            if (
                address(pools[i].tokens(1)) == _base ||
                address(pools[i].tokens(0)) == _base
            ) {
                if (baseIdx == 0 || baseIdx > pairIdx[i]) {
                    baseIdx = pairIdx[i];
                }
            }
        }

        if (baseIdx == 0) {
            return new address[](0);
        } else {
            address _a = _base;

            path = new address[](baseIdx + 1);
            path[baseIdx] = _base;

            for (uint8 i = baseIdx; i > 0; i--) {
                for (uint256 j = 0; j < pools.length; j++) {
                    if (
                        pairIdx[j] == i &&
                        (address(pools[j].tokens(1)) == _a ||
                            address(pools[j].tokens(0)) == _a)
                    ) {
                        _a = (address(pools[j].tokens(0)) == _a) // get next token from pair
                            ? address(pools[j].tokens(1))
                            : address(pools[j].tokens(0));
                        path[i - 1] = _a;
                        break;
                    }
                }
            }
            return path;
        }
    }

    function _markPathStep(
        IEmiswap[] memory _pools,
        uint8[] memory _idx,
        uint8 lvl,
        address _token
    ) internal view {

        for (uint256 j = 0; j < _pools.length; j++) {
            if (
                _idx[j] == 0 &&
                (address(_pools[j].tokens(1)) == _token ||
                    address(_pools[j].tokens(0)) == _token)
            ) {
                _idx[j] = lvl;
            }
        }
    }

    function _getAddressFromPrevStep(IEmiswap pair, address[] memory prevStep)
        internal
        view
        returns (address r)
    {

        for (uint256 i = 0; i < prevStep.length; i++) {
            if (
                prevStep[i] != address(0) &&
                (address(pair.tokens(0)) == prevStep[i] ||
                    address(pair.tokens(1)) == prevStep[i])
            ) {
                return
                    (address(pair.tokens(0)) == prevStep[i])
                        ? address(pair.tokens(1))
                        : address(pair.tokens(0));
            }
        }
        return address(0);
    }

    function _moveSteps(address[] memory _to, address[] memory _from)
        internal
        pure
    {

        for (uint256 i = 0; i < _from.length; i++) {
            _to[i] = _from[i];
            _from[i] = address(0);
        }
    }

    function _addToCurrentStep(address[] memory _step, address _token)
        internal
        pure
    {

        uint256 l = 0;

        for (uint256 i = 0; i < _step.length; i++) {
            if (_step[i] == _token) {
                return;
            } else {
                if (_step[i] == address(0)) {
                    break;
                } else {
                    l++;
                }
            }
        }
        _step[l] = _token;
    }
}