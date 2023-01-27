
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


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
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
}// MIT

pragma solidity ^0.8.0;

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
}// MIT

pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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

library EnumerableSet {


    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {

        return set._values;
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
    }

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {

        return _values(set._inner);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
    }

    function values(AddressSet storage set) internal view returns (address[] memory) {

        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }


    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }

    function values(UintSet storage set) internal view returns (uint256[] memory) {

        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}// MIT
pragma solidity ^0.8.0;

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

}// GPL-2.0
pragma solidity 0.8.8;


interface IWETH {

    function deposit() external payable;


    function transfer(address to, uint256 value) external returns (bool);


    function withdraw(uint256) external;

}

interface IUniswapV2Factory {

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address);

}

interface IUniswapV2Pair {

    function token0() external pure returns (address);


    function token1() external pure returns (address);


    function getReserves()
        external
        view
        returns (
            uint112 _reserve0,
            uint112 _reserve1,
            uint32 _blockTimestampLast
        );

}

interface IUniswapV2Router02 {

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

abstract contract Zap {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    IERC20 public immutable koromaru; // Koromaru token
    IERC20 public immutable koromaruUniV2; // Uniswap V2 LP token for Koromaru

    IUniswapV2Factory public immutable UniSwapV2FactoryAddress;
    IUniswapV2Router02 public uniswapRouter;
    address public immutable WETHAddress;

    uint256 private constant swapDeadline =
        0xf000000000000000000000000000000000000000000000000000000000000000;

    struct ZapVariables {
        uint256 LP;
        uint256 koroAmount;
        uint256 wethAmount;
        address tokenToZap;
        uint256 amountToZap;
    }

    event ZappedIn(address indexed account, uint256 amount);
    event ZappedOut(
        address indexed account,
        uint256 amount,
        uint256 koroAmount,
        uint256 Eth
    );

    constructor(
        address _koromaru,
        address _koromaruUniV2,
        address _UniSwapV2FactoryAddress,
        address _uniswapRouter
    ) {
        koromaru = IERC20(_koromaru);
        koromaruUniV2 = IERC20(_koromaruUniV2);

        UniSwapV2FactoryAddress = IUniswapV2Factory(_UniSwapV2FactoryAddress);
        uniswapRouter = IUniswapV2Router02(_uniswapRouter);

        WETHAddress = uniswapRouter.WETH();
    }

    function ZapIn(uint256 _amount, bool _multi)
        internal
        returns (
            uint256 _LP,
            uint256 _WETHBalance,
            uint256 _KoromaruBalance
        )
    {
        (uint256 _koroAmount, uint256 _ethAmount) = _moveTokensToContract(
            _amount
        );
        _approveRouterIfNotApproved();

        (_LP, _WETHBalance, _KoromaruBalance) = !_multi
            ? _zapIn(_koroAmount, _ethAmount)
            : _zapInMulti(_koroAmount, _ethAmount);
        require(_LP > 0, "ZapIn: Invalid LP amount");

        emit ZappedIn(msg.sender, _LP);
    }

    function zapOut(uint256 _koroLPAmount)
        internal
        returns (uint256 _koroTokens, uint256 _ether)
    {
        _approveRouterIfNotApproved();

        uint256 balanceBefore = koromaru.balanceOf(address(this));
        _ether = uniswapRouter.removeLiquidityETHSupportingFeeOnTransferTokens(
            address(koromaru),
            _koroLPAmount,
            1,
            1,
            address(this),
            swapDeadline
        );
        require(_ether > 0, "ZapOut: Eth Output Low");

        uint256 balanceAfter = koromaru.balanceOf(address(this));
        require(balanceAfter > balanceBefore, "ZapOut: Nothing to ZapOut");
        _koroTokens = balanceAfter.sub(balanceBefore);

        emit ZappedOut(msg.sender, _koroLPAmount, _koroTokens, _ether);
    }

    function _zapIn(uint256 _koroAmount, uint256 _wethAmount)
        internal
        returns (
            uint256 _LP,
            uint256 _WETHBalance,
            uint256 _KoromaruBalance
        )
    {
        ZapVariables memory zapVars;

        zapVars.tokenToZap; // koro or eth
        zapVars.amountToZap; // koro or weth

        (address _Token0, address _Token1) = _getKoroLPPairs(
            address(koromaruUniV2)
        );

        if (_koroAmount > 0 && _wethAmount < 1) {
            zapVars.amountToZap = _koroAmount;
            zapVars.tokenToZap = address(koromaru);
        } else if (_wethAmount > 0 && _koroAmount < 1) {
            zapVars.amountToZap = _wethAmount;
            zapVars.tokenToZap = WETHAddress;
        }

        (uint256 token0Out, uint256 token1Out) = _executeSwapForPairs(
            zapVars.tokenToZap,
            _Token0,
            _Token1,
            zapVars.amountToZap
        );

        (_LP, _WETHBalance, _KoromaruBalance) = _toLiquidity(
            _Token0,
            _Token1,
            token0Out,
            token1Out
        );
    }

    function _zapInMulti(uint256 _koroAmount, uint256 _wethAmount)
        internal
        returns (
            uint256 _LPToken,
            uint256 _WETHBalance,
            uint256 _KoromaruBalance
        )
    {
        ZapVariables memory zapVars;

        zapVars.koroAmount = _koroAmount;
        zapVars.wethAmount = _wethAmount;

        zapVars.tokenToZap; // koro or eth
        zapVars.amountToZap; // koro or weth

        {
            (
                uint256 _kLP,
                uint256 _kWETHBalance,
                uint256 _kKoromaruBalance
            ) = _zapIn(zapVars.koroAmount, 0);
            _LPToken += _kLP;
            _WETHBalance += _kWETHBalance;
            _KoromaruBalance += _kKoromaruBalance;
        }
        {
            (
                uint256 _kLP,
                uint256 _kWETHBalance,
                uint256 _kKoromaruBalance
            ) = _zapIn(0, zapVars.wethAmount);
            _LPToken += _kLP;
            _WETHBalance += _kWETHBalance;
            _KoromaruBalance += _kKoromaruBalance;
        }
    }

    function _toLiquidity(
        address _Token0,
        address _Token1,
        uint256 token0Out,
        uint256 token1Out
    )
        internal
        returns (
            uint256 _LP,
            uint256 _WETHBalance,
            uint256 _KoromaruBalance
        )
    {
        _approveToken(_Token0, address(uniswapRouter), token0Out);
        _approveToken(_Token1, address(uniswapRouter), token1Out);

        (uint256 amountA, uint256 amountB, uint256 LP) = uniswapRouter
            .addLiquidity(
                _Token0,
                _Token1,
                token0Out,
                token1Out,
                1,
                1,
                address(this),
                swapDeadline
            );

        _LP = LP;
        _WETHBalance = token0Out.sub(amountA);
        _KoromaruBalance = token1Out.sub(amountB);
    }

    function _approveRouterIfNotApproved() private {
        if (koromaru.allowance(address(this), address(uniswapRouter)) == 0) {
            koromaru.approve(address(uniswapRouter), type(uint256).max);
        }

        if (
            koromaruUniV2.allowance(address(this), address(uniswapRouter)) == 0
        ) {
            koromaruUniV2.approve(address(uniswapRouter), type(uint256).max);
        }
    }

    function _moveTokensToContract(uint256 _amount)
        internal
        returns (uint256 _koroAmount, uint256 _ethAmount)
    {
        _ethAmount = msg.value;

        if (msg.value > 0) IWETH(WETHAddress).deposit{value: _ethAmount}();

        if (msg.value < 1) {
            require(_amount > 0, "KOROFARM: Invalid ZapIn Call");
        }

        if (_amount > 0) {
            koromaru.safeTransferFrom(msg.sender, address(this), _amount);
        }

        _koroAmount = _amount;
    }

    function _getKoroLPPairs(address _pairAddress)
        internal
        pure
        returns (address token0, address token1)
    {
        IUniswapV2Pair uniPair = IUniswapV2Pair(_pairAddress);
        token0 = uniPair.token0();
        token1 = uniPair.token1();
    }

    function _executeSwapForPairs(
        address _inToken,
        address _token0,
        address _token1,
        uint256 _amount
    ) internal returns (uint256 _token0Out, uint256 _token1Out) {
        IUniswapV2Pair koroPair = IUniswapV2Pair(address(koromaruUniV2));

        (uint256 resv0, uint256 resv1, ) = koroPair.getReserves();

        if (_inToken == _token0) {
            uint256 swapAmount = determineSwapInAmount(resv0, _amount);
            if (swapAmount < 1) swapAmount = _amount.div(2);
            _token1Out = _swapTokenForToken(_inToken, _token1, swapAmount);
            _token0Out = _amount.sub(swapAmount);
        } else {
            uint256 swapAmount = determineSwapInAmount(resv1, _amount);
            if (swapAmount < 1) swapAmount = _amount.div(2);
            _token0Out = _swapTokenForToken(_inToken, _token0, swapAmount);
            _token1Out = _amount.sub(swapAmount);
        }
    }

    function _swapTokenForToken(
        address _swapFrom,
        address _swapTo,
        uint256 _tokensToSwap
    ) internal returns (uint256 tokenBought) {
        if (_swapFrom == _swapTo) {
            return _tokensToSwap;
        }

        _approveToken(
            _swapFrom,
            address(uniswapRouter),
            _tokensToSwap.mul(1e12)
        );

        address pair = UniSwapV2FactoryAddress.getPair(_swapFrom, _swapTo);

        require(pair != address(0), "SwapTokenForToken: Swap path error");
        address[] memory path = new address[](2);
        path[0] = _swapFrom;
        path[1] = _swapTo;

        uint256 balanceBefore = IERC20(_swapTo).balanceOf(address(this));
        uniswapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _tokensToSwap,
            0,
            path,
            address(this),
            swapDeadline
        );
        uint256 balanceAfter = IERC20(_swapTo).balanceOf(address(this));

        tokenBought = balanceAfter.sub(balanceBefore);


        require(tokenBought > 0, "SwapTokenForToken: Error Swapping Tokens 2");
    }

    function determineSwapInAmount(uint256 _pairResIn, uint256 _userAmountIn)
        internal
        pure
        returns (uint256)
    {
        return
            (_sqrt(
                _pairResIn *
                    ((_userAmountIn * 3988000) + (_pairResIn * 3988009))
            ) - (_pairResIn * 1997)) / 1994;
    }

    function _sqrt(uint256 _val) internal pure returns (uint256 z) {
        if (_val > 3) {
            z = _val;
            uint256 x = _val / 2 + 1;
            while (x < z) {
                z = x;
                x = (_val / x + x) / 2;
            }
        } else if (_val != 0) {
            z = 1;
        }
    }

    function _approveToken(
        address token,
        address spender,
        uint256 amount
    ) internal {
        IERC20 _token = IERC20(token);
        _token.safeApprove(spender, 0);
        _token.safeApprove(spender, amount);
    }

}

contract KoroFarms is Ownable, Pausable, ReentrancyGuard, Zap {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    struct UserInfo {
        uint256 amount;
        uint256 koroDebt;
        uint256 ethDebt;
        uint256 unpaidKoro;
        uint256 unpaidEth;
        uint256 lastRewardHarvestedTime;
    }

    struct FarmInfo {
        uint256 accKoroRewardsPerShare;
        uint256 accEthRewardsPerShare;
        uint256 lastRewardTimestamp;
    }

    AggregatorV3Interface internal priceFeed;
    uint256 internal immutable koromaruDecimals;
    uint256 internal constant EthPriceFeedDecimal = 1e8;
    uint256 internal constant precisionScaleUp = 1e30;
    uint256 internal constant secsPerDay = 1 days / 1 seconds;
    uint256 private taxRefundPercentage;
    uint256 internal constant _1hundred_Percent = 10000;
    uint256 public APR; // 100% = 10000, 50% = 5000, 15% = 1500
    uint256 rewardHarvestingInterval;
    uint256 public koroRewardAllocation;
    uint256 public ethRewardAllocation;
    uint256 internal maxLPLimit;
    uint256 internal zapKoroLimit;

    FarmInfo public farmInfo;
    mapping(address => UserInfo) public userInfo;

    uint256 public totalEthRewarded; // total amount of eth given as rewards
    uint256 public totalKoroRewarded; // total amount of Koro given as rewards


    event Compound(address indexed account, uint256 koro, uint256 eth);
    event Withdraw(address indexed account, uint256 amount);
    event Deposit(address indexed account, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event KoroRewardsHarvested(address indexed account, uint256 Kororewards);
    event EthRewardsHarvested(address indexed account, uint256 Ethrewards);
    event APRUpdated(uint256 OldAPR, uint256 NewAPR);
    event Paused();
    event Unpaused();
    event IncreaseKoroRewardPool(uint256 amount);
    event IncreaseEthRewardPool(uint256 amount);


    constructor(
        address _koromaru,
        address _koromaruUniV2,
        address _UniSwapV2FactoryAddress,
        address _uniswapRouter,
        uint256 _apr,
        uint256 _taxToRefund,
        uint256 _koromaruTokenDecimals,
        uint256 _koroRewardAllocation,
        uint256 _rewardHarvestingInterval,
        uint256 _zapKoroLimit
    ) Zap(_koromaru, _koromaruUniV2, _UniSwapV2FactoryAddress, _uniswapRouter) {
        require(
            _koroRewardAllocation <= 10000,
            "setRewardAllocations: Invalid rewards allocation"
        );
        require(_apr <= 10000, "SetDailyAPR: Invalid APR Value");

        approveRouterIfNotApproved();

        koromaruDecimals = 10**_koromaruTokenDecimals;
        zapKoroLimit = _zapKoroLimit * 10**_koromaruTokenDecimals;
        APR = _apr;
        koroRewardAllocation = _koroRewardAllocation;
        ethRewardAllocation = _1hundred_Percent.sub(_koroRewardAllocation);
        taxRefundPercentage = _taxToRefund;

        farmInfo = FarmInfo({
            lastRewardTimestamp: block.timestamp,
            accKoroRewardsPerShare: 0,
            accEthRewardsPerShare: 0
        });

        rewardHarvestingInterval = _rewardHarvestingInterval * 1 seconds;
        priceFeed = AggregatorV3Interface(
            0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        );
    }

    function updatePriceFeed(address _usdt_eth_aggregator) external onlyOwner {

        priceFeed = AggregatorV3Interface(_usdt_eth_aggregator);
    }

    function setTaxRefundPercent(uint256 _taxToRefund) external onlyOwner {

        taxRefundPercentage = _taxToRefund;
    }

    function setZapLimit(uint256 _limit) external onlyOwner {

        zapKoroLimit = _limit * koromaruDecimals;
    }

    function setDailyAPR(uint256 _dailyAPR) external onlyOwner {

        updateFarm();
        require(_dailyAPR <= 10000, "SetDailyAPR: Invalid APR Value");
        uint256 oldAPr = APR;
        APR = _dailyAPR;
        emit APRUpdated(oldAPr, APR);
    }

    function setRewardAllocations(uint256 _koroAllocation) external onlyOwner {

        require(
            _koroAllocation <= 10000,
            "setRewardAllocations: Invalid rewards allocation"
        );
        koroRewardAllocation = _koroAllocation;
        ethRewardAllocation = _1hundred_Percent.sub(_koroAllocation);
    }

    function setMaxLPLimit(uint256 _maxLPLimit) external onlyOwner {

        maxLPLimit = _maxLPLimit;
    }

    function resetPriceFeed() external onlyOwner {

        priceFeed = AggregatorV3Interface(
            0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        );
    }

    function withdrawForeignToken(address _token)
        external
        nonReentrant
        onlyOwner
    {

        require(_token != address(0), "KOROFARM: Invalid Token");
        require(
            _token != address(koromaru),
            "KOROFARM: Token cannot be same as koromaru tokens"
        );
        require(
            _token != address(koromaruUniV2),
            "KOROFARM: Token cannot be same as farmed tokens"
        );

        uint256 amount = IERC20(_token).balanceOf(address(this));
        if (amount > 0) {
            IERC20(_token).safeTransfer(msg.sender, amount);
        }
    }

    function depositKoroRewards(uint256 _amount)
        external
        onlyOwner
        nonReentrant
    {

        require(_amount > 0, "KOROFARM: Invalid Koro Amount");

        koromaru.safeTransferFrom(msg.sender, address(this), _amount);
        emit IncreaseKoroRewardPool(_amount);
    }

    function depositEthRewards() external payable onlyOwner nonReentrant {

        require(msg.value > 0, "KOROFARM: Invalid Eth Amount");
        emit IncreaseEthRewardPool(msg.value);
    }

    function pauseAndRemoveRewardPools() external onlyOwner whenNotPaused {

        uint256 koroBalance = koromaru.balanceOf(address(this));
        uint256 ethBalance = payable(address(this)).balance;
        if (koroBalance > 0) {
            koromaru.safeTransfer(msg.sender, koroBalance);
        }

        if (ethBalance > 0) {
            (bool sent, ) = payable(msg.sender).call{value: ethBalance}("");
            require(sent, "Failed to send Ether");
        }
    }

    function pause() external onlyOwner whenNotPaused {

        _pause();
        emit Paused();
    }

    function unpause() external onlyOwner whenPaused {

        _unpause();
        emit Unpaused();
    }


    function getPendingRewards(address _farmer)
        public
        view
        returns (uint256 pendinKoroTokens, uint256 pendingEthWei)
    {

        UserInfo storage user = userInfo[_farmer];
        uint256 accKoroRewardsPerShare = farmInfo.accKoroRewardsPerShare;
        uint256 accEthRewardsPerShare = farmInfo.accEthRewardsPerShare;
        uint256 stakedTVL = getStakedTVL();

        if (block.timestamp > farmInfo.lastRewardTimestamp && stakedTVL != 0) {
            uint256 timeElapsed = block.timestamp.sub(
                farmInfo.lastRewardTimestamp
            );
            uint256 koroReward = timeElapsed.mul(
                getNumberOfKoroRewardsPerSecond(koroRewardAllocation)
            );
            uint256 ethReward = timeElapsed.mul(
                getAmountOfEthRewardsPerSecond(ethRewardAllocation)
            );

            accKoroRewardsPerShare = accKoroRewardsPerShare.add(
                koroReward.mul(precisionScaleUp).div(stakedTVL)
            );
            accEthRewardsPerShare = accEthRewardsPerShare.add(
                ethReward.mul(precisionScaleUp).div(stakedTVL)
            );
        }

        pendinKoroTokens = user
            .amount
            .mul(accKoroRewardsPerShare)
            .div(precisionScaleUp)
            .sub(user.koroDebt)
            .add(user.unpaidKoro);

        pendingEthWei = user
            .amount
            .mul(accEthRewardsPerShare)
            .div(precisionScaleUp)
            .sub(user.ethDebt)
            .add(user.unpaidEth);
    }

    function getStakedTVL() public view returns (uint256) {

        uint256 stakedLP = koromaruUniV2.balanceOf(address(this));
        uint256 totalLPsupply = koromaruUniV2.totalSupply();
        return stakedLP.mul(getTVLUsingKoro()).div(totalLPsupply);
    }

    function updateFarm() public whenNotPaused returns (FarmInfo memory farm) {

        farm = farmInfo;

        uint256 WETHBalance = IERC20(WETHAddress).balanceOf(address(this));
        if (WETHBalance > 0) IWETH(WETHAddress).withdraw(WETHBalance);

        if (block.timestamp > farm.lastRewardTimestamp) {
            uint256 stakedTVL = getStakedTVL();

            if (stakedTVL > 0) {
                uint256 timeElapsed = block.timestamp.sub(
                    farm.lastRewardTimestamp
                );
                uint256 koroReward = timeElapsed.mul(
                    getNumberOfKoroRewardsPerSecond(koroRewardAllocation)
                );
                uint256 ethReward = timeElapsed.mul(
                    getAmountOfEthRewardsPerSecond(ethRewardAllocation)
                );
                farm.accKoroRewardsPerShare = farm.accKoroRewardsPerShare.add(
                    (koroReward.mul(precisionScaleUp) / stakedTVL)
                );
                farm.accEthRewardsPerShare = farm.accEthRewardsPerShare.add(
                    (ethReward.mul(precisionScaleUp) / stakedTVL)
                );
            }

            farm.lastRewardTimestamp = block.timestamp;
            farmInfo = farm;
        }
    }

    function depositKoroTokensOnly(uint256 _amount)
        external
        whenNotPaused
        nonReentrant
    {

        require(_amount > 0, "KOROFARM: Invalid Koro Amount");
        require(
            _amount <= zapKoroLimit,
            "KOROFARM: Can't deposit more than Zap Limit"
        );

        (uint256 lpZappedIn, , ) = ZapIn(_amount, false);

        userInfo[msg.sender].unpaidKoro += _amount.mul(taxRefundPercentage).div(
            _1hundred_Percent
        );

        onDeposit(msg.sender, lpZappedIn);
    }

    function depositKoroLPTokensOnly(uint256 _amount)
        external
        whenNotPaused
        nonReentrant
    {

        require(_amount > 0, "KOROFARM: Invalid KoroLP Amount");
        koromaruUniV2.safeTransferFrom(msg.sender, address(this), _amount);
        onDeposit(msg.sender, _amount);
    }

    function depositMultipleAssets(uint256 _koro, uint256 _koroLp)
        external
        payable
        whenNotPaused
        nonReentrant
    {

        require(
            _koro <= zapKoroLimit,
            "KOROFARM: Can't deposit more than Zap Limit"
        );

        (uint256 lpZappedIn, , ) = msg.value > 0
            ? ZapIn(_koro, true)
            : ZapIn(_koro, false);

        if (_koroLp > 0)
            koromaruUniV2.safeTransferFrom(
                address(msg.sender),
                address(this),
                _koroLp
            );

        uint256 sumOfLps = lpZappedIn + _koroLp;

        userInfo[msg.sender].unpaidKoro += _koro.mul(taxRefundPercentage).div(
            _1hundred_Percent
        );

        onDeposit(msg.sender, sumOfLps);
    }

    function depositEthOnly() external payable whenNotPaused nonReentrant {

        require(msg.value > 0, "KOROFARM: Invalid Eth Amount");

        (uint256 lpZappedIn, , ) = ZapIn(0, false);

        onDeposit(msg.sender, lpZappedIn);
    }

    function withdraw(bool _useZapOut) external whenNotPaused nonReentrant {

        uint256 balance = userInfo[msg.sender].amount;
        require(balance > 0, "Withdraw: You have no balance");
        updateFarm();

        if (_useZapOut) {
            zapLPOut(balance);
        } else {
            koromaruUniV2.transfer(msg.sender, balance);
        }

        onWithdraw(msg.sender);
        emit Withdraw(msg.sender, balance);
    }

    function harvest() external whenNotPaused nonReentrant {

        updateFarm();
        harvestRewards(msg.sender);
    }

    function compound() external whenNotPaused nonReentrant {

        updateFarm();
        UserInfo storage user = userInfo[msg.sender];
        require(
            block.timestamp - user.lastRewardHarvestedTime >=
                rewardHarvestingInterval,
            "HarvestRewards: Not yet ripe"
        );

        uint256 koroCompounded;
        uint256 ethCompounded;

        uint256 pendinKoroTokens = user
            .amount
            .mul(farmInfo.accKoroRewardsPerShare)
            .div(precisionScaleUp)
            .sub(user.koroDebt)
            .add(user.unpaidKoro);

        uint256 pendingEthWei = user
            .amount
            .mul(farmInfo.accEthRewardsPerShare)
            .div(precisionScaleUp)
            .sub(user.ethDebt)
            .add(user.unpaidEth);
        {
            uint256 koromaruBalance = koromaru.balanceOf(address(this));
            if (pendinKoroTokens > 0) {
                if (pendinKoroTokens > koromaruBalance) {
                    user.unpaidKoro = pendinKoroTokens.sub(koromaruBalance);
                    totalKoroRewarded = totalKoroRewarded.add(koromaruBalance);
                    koroCompounded = koromaruBalance;
                } else {
                    user.unpaidKoro = 0;
                    totalKoroRewarded = totalKoroRewarded.add(pendinKoroTokens);
                    koroCompounded = pendinKoroTokens;
                }
            }
        }

        {
            uint256 ethBalance = getEthBalance();
            if (pendingEthWei > ethBalance) {
                user.unpaidEth = pendingEthWei.sub(ethBalance);
                totalEthRewarded = totalEthRewarded.add(ethBalance);
                IWETH(WETHAddress).deposit{value: ethBalance}();
                ethCompounded = ethBalance;
            } else {
                user.unpaidEth = 0;
                totalEthRewarded = totalEthRewarded.add(pendingEthWei);
                IWETH(WETHAddress).deposit{value: pendingEthWei}();
                ethCompounded = pendingEthWei;
            }
        }
        (uint256 LP, , ) = _zapInMulti(koroCompounded, ethCompounded);

        onCompound(msg.sender, LP);
        emit Compound(msg.sender, koroCompounded, ethCompounded);
    }

    function timeToHarvest(address _user)
        public
        view
        whenNotPaused
        returns (uint256)
    {

        UserInfo storage user = userInfo[_user];
        if (
            block.timestamp - user.lastRewardHarvestedTime >=
            rewardHarvestingInterval
        ) {
            return 0;
        }
        return
            user.lastRewardHarvestedTime.sub(
                block.timestamp.sub(rewardHarvestingInterval)
            );
    }

    function emergencyWithdraw() external nonReentrant {

        UserInfo storage user = userInfo[msg.sender];
        koromaruUniV2.safeTransfer(address(msg.sender), user.amount);
        emit EmergencyWithdraw(msg.sender, user.amount);

        userInfo[msg.sender] = UserInfo(0, 0, 0, 0, 0, 0);
    }



    function getUSDDailyRewards() public view whenNotPaused returns (uint256) {

        uint256 stakedLP = koromaruUniV2.balanceOf(address(this));
        uint256 totalLPsupply = koromaruUniV2.totalSupply();
        uint256 stakedTVL = stakedLP.mul(getTVLUsingKoro()).div(totalLPsupply);
        return APR.mul(stakedTVL).div(_1hundred_Percent);
    }

    function getUSDRewardsPerSecond() internal view returns (uint256) {

        uint256 dailyRewards = getUSDDailyRewards();
        return dailyRewards.div(secsPerDay);
    }

    function getNumberOfKoroRewardsPerSecond(uint256 _koroRewardAllocation)
        internal
        view
        returns (uint256)
    {

        uint256 priceOfUintKoro = getLatestKoroPrice(); // 1e18
        uint256 rewardsPerSecond = getUSDRewardsPerSecond(); // 1e18

        return
            rewardsPerSecond
                .mul(_koroRewardAllocation)
                .mul(koromaruDecimals)
                .div(priceOfUintKoro)
                .div(_1hundred_Percent); //to be div by koro decimals (i.e 1**(18-18+korodecimals)
    }

    function getAmountOfEthRewardsPerSecond(uint256 _ethRewardAllocation)
        internal
        view
        returns (uint256)
    {

        uint256 priceOfUintEth = getLatestEthPrice(); // 1e8
        uint256 rewardsPerSecond = getUSDRewardsPerSecond(); // 1e18
        uint256 scaleUpToWei = 1e8;

        return
            rewardsPerSecond
                .mul(_ethRewardAllocation)
                .mul(scaleUpToWei)
                .div(priceOfUintEth)
                .div(_1hundred_Percent); // to be div by 1e18 (i.e 1**(18-8+8)
    }

    function getRewardsPerSecond()
        public
        view
        whenNotPaused
        returns (uint256 koroRewards, uint256 ethRewards)
    {

        require(
            koroRewardAllocation.add(ethRewardAllocation) == _1hundred_Percent,
            "getRewardsPerSecond: Invalid reward allocation ratio"
        );

        koroRewards = getNumberOfKoroRewardsPerSecond(koroRewardAllocation);
        ethRewards = getAmountOfEthRewardsPerSecond(ethRewardAllocation);
    }

    function getTVL() public view returns (uint256 tvl) {

        IUniswapV2Pair koroPair = IUniswapV2Pair(address(koromaruUniV2));
        address token0 = koroPair.token0();
        (uint256 resv0, uint256 resv1, ) = koroPair.getReserves();
        uint256 TVLEth = 2 *
            (address(token0) == address(koromaru) ? resv1 : resv0);
        uint256 priceOfEth = getLatestEthPrice();

        tvl = TVLEth.mul(priceOfEth).div(EthPriceFeedDecimal);
    }

    function getTVLUsingKoro() public view whenNotPaused returns (uint256 tvl) {

        IUniswapV2Pair koroPair = IUniswapV2Pair(address(koromaruUniV2));
        address token0 = koroPair.token0();
        (uint256 resv0, uint256 resv1, ) = koroPair.getReserves();
        uint256 TVLKoro = 2 *
            (address(token0) == address(koromaru) ? resv0 : resv1);
        uint256 priceOfKoro = getLatestKoroPrice();

        tvl = TVLKoro.mul(priceOfKoro).div(koromaruDecimals);
    }

    function getLatestEthPrice() internal view returns (uint256) {

        (, int256 price, , , ) = priceFeed.latestRoundData();
        return uint256(price);
    }

    function getLatestKoroPrice() internal view returns (uint256) {

        IUniswapV2Pair koroPair = IUniswapV2Pair(address(koromaruUniV2));
        address token0 = koroPair.token0();
        bool isKoro = address(token0) == address(koromaru);

        (uint256 resv0, uint256 resv1, ) = koroPair.getReserves();
        uint256 oneKoro = 1 * koromaruDecimals;

        uint256 optimalWethAmount = uniswapRouter.getAmountOut(
            oneKoro,
            isKoro ? resv0 : resv1,
            isKoro ? resv1 : resv0
        ); //uniswapRouter.quote(oneKoro, isKoro ? resv1 : resv0, isKoro ? resv0 : resv1);
        uint256 priceOfEth = getLatestEthPrice();

        return optimalWethAmount.mul(priceOfEth).div(EthPriceFeedDecimal);
    }

    function onDeposit(address _user, uint256 _amount) internal {

        require(!reachedMaxLimit(), "KOROFARM: Farm is full");
        UserInfo storage user = userInfo[_user];
        updateFarm();

        if (user.amount > 0) {
            user.unpaidKoro = user
                .amount
                .mul(farmInfo.accKoroRewardsPerShare)
                .div(precisionScaleUp)
                .sub(user.koroDebt)
                .add(user.unpaidKoro);

            user.unpaidEth = user
                .amount
                .mul(farmInfo.accEthRewardsPerShare)
                .div(precisionScaleUp)
                .sub(user.ethDebt)
                .add(user.unpaidEth);
        }

        user.amount = user.amount.add(_amount);
        user.koroDebt = user.amount.mul(farmInfo.accKoroRewardsPerShare).div(
            precisionScaleUp
        );
        user.ethDebt = user.amount.mul(farmInfo.accEthRewardsPerShare).div(
            precisionScaleUp
        );

        if (
            (block.timestamp - user.lastRewardHarvestedTime >=
                rewardHarvestingInterval) || (rewardHarvestingInterval == 0)
        ) {
            user.lastRewardHarvestedTime = block.timestamp;
        }

        emit Deposit(_user, _amount);
    }

    function onWithdraw(address _user) internal {

        harvestRewards(_user);
        userInfo[msg.sender].amount = 0;

        userInfo[msg.sender].koroDebt = 0;
        userInfo[msg.sender].ethDebt = 0;
    }

    function onCompound(address _user, uint256 _amount) internal {

        require(!reachedMaxLimit(), "KOROFARM: Farm is full");
        UserInfo storage user = userInfo[_user];

        user.amount = user.amount.add(_amount);
        user.koroDebt = user.amount.mul(farmInfo.accKoroRewardsPerShare).div(
            precisionScaleUp
        );
        user.ethDebt = user.amount.mul(farmInfo.accEthRewardsPerShare).div(
            precisionScaleUp
        );

        user.lastRewardHarvestedTime = block.timestamp;
    }

    function harvestRewards(address _user) internal {

        UserInfo storage user = userInfo[_user];
        require(
            block.timestamp - user.lastRewardHarvestedTime >=
                rewardHarvestingInterval,
            "HarvestRewards: Not yet ripe"
        );

        uint256 pendinKoroTokens = user
            .amount
            .mul(farmInfo.accKoroRewardsPerShare)
            .div(precisionScaleUp)
            .sub(user.koroDebt)
            .add(user.unpaidKoro);

        uint256 pendingEthWei = user
            .amount
            .mul(farmInfo.accEthRewardsPerShare)
            .div(precisionScaleUp)
            .sub(user.ethDebt)
            .add(user.unpaidEth);

        {
            uint256 koromaruBalance = koromaru.balanceOf(address(this));
            if (pendinKoroTokens > 0) {
                if (pendinKoroTokens > koromaruBalance) {
                    koromaru.safeTransfer(_user, koromaruBalance);
                    user.unpaidKoro = pendinKoroTokens.sub(koromaruBalance);
                    totalKoroRewarded = totalKoroRewarded.add(koromaruBalance);
                    emit KoroRewardsHarvested(_user, koromaruBalance);
                } else {
                    koromaru.safeTransfer(_user, pendinKoroTokens);
                    user.unpaidKoro = 0;
                    totalKoroRewarded = totalKoroRewarded.add(pendinKoroTokens);
                    emit KoroRewardsHarvested(_user, pendinKoroTokens);
                }
            }
        }
        {
            uint256 ethBalance = getEthBalance();
            if (pendingEthWei > ethBalance) {
                (bool sent, ) = _user.call{value: ethBalance}("");
                require(sent, "Failed to send Ether");
                user.unpaidEth = pendingEthWei.sub(ethBalance);
                totalEthRewarded = totalEthRewarded.add(ethBalance);
                emit EthRewardsHarvested(_user, ethBalance);
            } else {
                (bool sent, ) = _user.call{value: pendingEthWei}("");
                require(sent, "Failed to send Ether");
                user.unpaidEth = 0;
                totalEthRewarded = totalEthRewarded.add(pendingEthWei);
                emit EthRewardsHarvested(_user, pendingEthWei);
            }
        }
        user.koroDebt = user.amount.mul(farmInfo.accKoroRewardsPerShare).div(
            precisionScaleUp
        );
        user.ethDebt = user.amount.mul(farmInfo.accEthRewardsPerShare).div(
            precisionScaleUp
        );
        user.lastRewardHarvestedTime = block.timestamp;
    }

    function zapLPOut(uint256 _amount)
        private
        returns (uint256 _koroTokens, uint256 _ether)
    {

        (_koroTokens, _ether) = zapOut(_amount);
        (bool sent, ) = msg.sender.call{value: _ether}("");
        require(sent, "Failed to send Ether");
        koromaru.safeTransfer(msg.sender, _koroTokens);
    }

    function getEthBalance() public view returns (uint256) {

        return address(this).balance;
    }

    function getUserInfo(address _user)
        public
        view
        returns (
            uint256 amount,
            uint256 stakedInUsd,
            uint256 timeToHarves,
            uint256 pendingKoro,
            uint256 pendingEth
        )
    {

        amount = userInfo[_user].amount;
        timeToHarves = timeToHarvest(_user);
        (pendingKoro, pendingEth) = getPendingRewards(_user);

        uint256 stakedLP = koromaruUniV2.balanceOf(address(this));
        stakedInUsd = stakedLP > 0
            ? userInfo[_user].amount.mul(getStakedTVL()).div(stakedLP)
            : 0;
    }

    function getFarmInfo()
        public
        view
        returns (
            uint256 tvl,
            uint256 totalStaked,
            uint256 circSupply,
            uint256 dailyROI,
            uint256 ethDistribution,
            uint256 koroDistribution
        )
    {

        tvl = getStakedTVL();
        totalStaked = koromaruUniV2.balanceOf(address(this));
        circSupply = getCirculatingSupplyLocked();
        dailyROI = APR;
        ethDistribution = ethRewardAllocation;
        koroDistribution = koroRewardAllocation;
    }

    function getCirculatingSupplyLocked() public view returns (uint256) {

        address deadWallet = address(
            0x000000000000000000000000000000000000dEaD
        );
        IUniswapV2Pair koroPair = IUniswapV2Pair(address(koromaruUniV2));
        address token0 = koroPair.token0();
        (uint256 resv0, uint256 resv1, ) = koroPair.getReserves();
        uint256 koroResv = address(token0) == address(koromaru) ? resv0 : resv1;
        uint256 lpSupply = koromaruUniV2.totalSupply();
        uint256 koroCirculatingSupply = koromaru.totalSupply().sub(
            koromaru.balanceOf(deadWallet)
        );
        uint256 stakedLp = koromaruUniV2.balanceOf(address(this));

        return
            (stakedLp.mul(koroResv).mul(1e18).div(lpSupply)).div(
                koroCirculatingSupply
            ); // divide by 1e18
    }

    function approveRouterIfNotApproved() private {

        if (koromaru.allowance(address(this), address(uniswapRouter)) == 0) {
            koromaru.safeApprove(address(uniswapRouter), type(uint256).max);
        }

        if (
            koromaruUniV2.allowance(address(this), address(uniswapRouter)) == 0
        ) {
            koromaruUniV2.approve(address(uniswapRouter), type(uint256).max);
        }
    }

    function reachedMaxLimit() public view returns (bool) {

        uint256 lockedLP = koromaruUniV2.balanceOf(address(this));
        if (maxLPLimit < 1) return false; // unlimited

        if (lockedLP >= maxLPLimit) return true;

        return false;
    }


    receive() external payable {
        emit IncreaseEthRewardPool(msg.value);
    }
}