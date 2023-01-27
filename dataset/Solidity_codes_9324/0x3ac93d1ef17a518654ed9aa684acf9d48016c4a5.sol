pragma solidity >=0.5.0 <0.8.0;

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
}// MIT

pragma solidity ^0.7.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.7.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.7.0;

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
}// MIT

pragma solidity ^0.7.0;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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

pragma solidity ^0.7.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol) {
        _name = name;
        _symbol = symbol;
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

}// MIT

pragma solidity ^0.7.0;

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// GPL-2.0-or-later
pragma solidity >=0.6.0;


library TransferHelper {
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'STF');
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.transfer.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'ST');
    }

    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.approve.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'SA');
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'STE');
    }
}// MIT

pragma solidity ^0.7.0;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}// MIT

pragma solidity ^0.7.0;


interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function transferFrom(address from, address to, uint256 tokenId) external;

    function approve(address to, uint256 tokenId) external;

    function getApproved(uint256 tokenId) external view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator) external view returns (bool);

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}// MIT

pragma solidity ^0.7.0;


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);
}// MIT

pragma solidity ^0.7.0;


interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    function tokenByIndex(uint256 index) external view returns (uint256);
}// GPL-2.0-or-later
pragma solidity >=0.7.5;
pragma abicoder v2;

interface IPoolInitializer {
    function createAndInitializePoolIfNecessary(
        address token0,
        address token1,
        uint24 fee,
        uint160 sqrtPriceX96
    ) external payable returns (address pool);
}// GPL-2.0-or-later
pragma solidity >=0.7.5;


interface IERC721Permit is IERC721 {
    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function permit(
        address spender,
        uint256 tokenId,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable;
}// GPL-2.0-or-later
pragma solidity >=0.7.5;

interface IPeripheryPayments {
    function unwrapWETH9(uint256 amountMinimum, address recipient) external payable;

    function refundETH() external payable;

    function sweepToken(
        address token,
        uint256 amountMinimum,
        address recipient
    ) external payable;
}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IPeripheryImmutableState {
    function factory() external view returns (address);

    function WETH9() external view returns (address);
}// GPL-2.0-or-later
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
}// GPL-2.0-or-later
pragma solidity >=0.7.5;



interface INonfungiblePositionManager is
    IPoolInitializer,
    IPeripheryPayments,
    IPeripheryImmutableState,
    IERC721Metadata,
    IERC721Enumerable,
    IERC721Permit
{
    event IncreaseLiquidity(uint256 indexed tokenId, uint128 liquidity, uint256 amount0, uint256 amount1);
    event DecreaseLiquidity(uint256 indexed tokenId, uint128 liquidity, uint256 amount0, uint256 amount1);
    event Collect(uint256 indexed tokenId, address recipient, uint256 amount0, uint256 amount1);

    function positions(uint256 tokenId)
        external
        view
        returns (
            uint96 nonce,
            address operator,
            address token0,
            address token1,
            uint24 fee,
            int24 tickLower,
            int24 tickUpper,
            uint128 liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );

    struct MintParams {
        address token0;
        address token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        address recipient;
        uint256 deadline;
    }

    function mint(MintParams calldata params)
        external
        payable
        returns (
            uint256 tokenId,
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        );

    struct IncreaseLiquidityParams {
        uint256 tokenId;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }

    function increaseLiquidity(IncreaseLiquidityParams calldata params)
        external
        payable
        returns (
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        );

    struct DecreaseLiquidityParams {
        uint256 tokenId;
        uint128 liquidity;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }

    function decreaseLiquidity(DecreaseLiquidityParams calldata params)
        external
        payable
        returns (uint256 amount0, uint256 amount1);

    struct CollectParams {
        uint256 tokenId;
        address recipient;
        uint128 amount0Max;
        uint128 amount1Max;
    }

    function collect(CollectParams calldata params) external payable returns (uint256 amount0, uint256 amount1);

    function burn(uint256 tokenId) external payable;
}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IUniswapV3SwapCallback {
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external;
}// GPL-2.0-or-later
pragma solidity >=0.7.5;


interface ISwapRouter is IUniswapV3SwapCallback {
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
}// MIT
pragma solidity =0.7.6;


interface IUniswapV3PoolState {
      function slot0() external view returns (uint160 sqrtPriceX96, int24 tick, uint16 observationIndex, uint16 observationCardinality, uint16 observationCardinalityNext, uint8 feeProtocol, bool unlocked);
}

contract Cleopatra is ERC20, Ownable {

    struct QueuedWallsUpdate {
        bool inQueue;
        int24[2][] newLiquidityWallsRanges;
        uint[] newLiquidityWallsRatios; 
        bool[] newLiquidityWallsInToken;
    }

    struct WallInfo {
        uint tokenId;
        uint128 liquidity;
    }

    uint baseFeesAmount; // base fees amount on each buy (base 10000)
    uint baseFeesAmountForRefferal; // base fees amount when referral is used(replace baseFeesAmount) (base 10000)
    uint feesAmountRatioForRefferer; // ratio (percent) of baseFeesAmountForRefferal gived to refferer when refferal is used (base 10000)
    uint PRPLL_fees; // ratio (percent) of base fees used to PRPLL (the rest is transferrer to the development address) (base 10000)
    mapping (address => bool) public feesExcludedAddresses;
    mapping (address => bool) public taxedPool; // mapping of taxed pool

    int24[2][] public liquidityWallsRanges; // price range where each liquidity wall will be between
    uint[] public liquidityWallsRatios; // percent of all liquidity owned by the contract which will be placed in the walls
    bool[] public liquidityWallsInToken; // mapping of liquidity wall type (true for wall in Cleopatra and false for wall in WETH)
    QueuedWallsUpdate public queuedWalls; // store queued wall update
    mapping (uint => WallInfo) public liquidityWallsTokenIds; // associate each wall id in array to WallInfo
    uint sellThresholdAmount; // token balance required to sell Cleopatra

    INonfungiblePositionManager public nonfungiblePositionManager;
    IUniswapV3PoolState public pairPool;
    uint24 public mainPoolFee;
    ISwapRouter public swapRouter;
    address public pairToken;

    mapping (address => uint) refferalCodeByAddress;
    mapping (uint => address) reffererAddressByRefferalCode;
    mapping (address => bool) public usedRefferal;
    uint public tokensNeededForRefferalNumber; // minimum token required to generate a refferal code
    uint constant public maxRefferalCode = 999999999999999999;

    address public bootstrapToken;
    bool public allowBridge;
    uint public totalTokenDepositedToBridge;

    bool initialized;

    constructor(string memory _name, string memory _symbol, address _pairToken, INonfungiblePositionManager _nonfungiblePositionManager, ISwapRouter _swapRouter) ERC20(_name, _symbol) {
        _mint(msg.sender, 21000000e18);

        pairToken = _pairToken;

        nonfungiblePositionManager = _nonfungiblePositionManager;
        swapRouter = _swapRouter;
    }


    function updateExternalAddressAndPoolFee(INonfungiblePositionManager _nonfungiblePositionManager, ISwapRouter _swapRouter, address _pairToken, IUniswapV3PoolState _pairPool, uint24 _mainPoolFee) external onlyOwner {
        nonfungiblePositionManager = _nonfungiblePositionManager;
        swapRouter = _swapRouter;
        pairToken = _pairToken;
        pairPool = _pairPool;
        mainPoolFee = _mainPoolFee;
    }

    function setFeesExcludedAddress(address _account, bool _isExcluded) external onlyOwner {
        feesExcludedAddresses[_account] = _isExcluded;
    }

    function setTaxedPool(address _pool, bool _isTaxed) external onlyOwner {
        taxedPool[_pool] = _isTaxed;
    }

    function setFeesAmount(uint _baseFeesAmount, uint _baseFeesAmountForRefferal, uint _feesAmountRatioForRefferer, uint _PRPLL_fees) external onlyOwner {
        require(_baseFeesAmount <= 5000);
        require(_baseFeesAmountForRefferal <= 5000);
        require(_feesAmountRatioForRefferer <= 5000);
        require(_PRPLL_fees <= 10000);
        baseFeesAmount = _baseFeesAmount;
        baseFeesAmountForRefferal = _baseFeesAmountForRefferal;
        feesAmountRatioForRefferer = _feesAmountRatioForRefferer;
        PRPLL_fees = _PRPLL_fees;
    }

    function queueLiquidityWallsParameters(int24[2][] calldata _liquidityWallsRanges, uint[] calldata _liquidityWallsRatios, bool[] calldata _liquidityWallsInToken) external onlyOwner {
        require(_liquidityWallsRanges.length == _liquidityWallsRatios.length && _liquidityWallsRatios.length == _liquidityWallsInToken.length);

        queuedWalls = QueuedWallsUpdate(true, _liquidityWallsRanges, _liquidityWallsRatios, _liquidityWallsInToken);
    }

    function setSellThresholdAmount(uint _sellThresholdAmount) external onlyOwner {
        sellThresholdAmount = _sellThresholdAmount;
    }

    function setTokensNeededForRefferalNumber(uint _tokensNeededForRefferalNumber) external onlyOwner {
        tokensNeededForRefferalNumber = _tokensNeededForRefferalNumber;
    }

    function approveUniswap() external onlyOwner {
        TransferHelper.safeApprove(address(this), address(nonfungiblePositionManager), uint(-1));
        TransferHelper.safeApprove(pairToken, address(nonfungiblePositionManager), uint(-1));
        TransferHelper.safeApprove(address(this), address(swapRouter), uint(-1));
        TransferHelper.safeApprove(pairToken, address(swapRouter), uint(-1));
    }

    function setBootstrap(address _bootstrapToken, bool _allowBridge) public {
        bootstrapToken = _bootstrapToken;
        allowBridge = _allowBridge;
    }


    function bridgeToCLEO() external {
        uint amount = IERC20(bootstrapToken).balanceOf(msg.sender);
        IERC20(bootstrapToken).transferFrom(msg.sender, address(this), amount);
        transfer(msg.sender, amount);
    }

    function addReserveToBridge() external onlyOwner {
        uint amount = balanceOf(msg.sender);
        transferFrom(msg.sender, address(this), amount);
        totalTokenDepositedToBridge += amount;
    }

    function retrieveCLEO() external onlyOwner {
        transfer(msg.sender, totalTokenDepositedToBridge);
        totalTokenDepositedToBridge = 0;
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transferWithFees(msg.sender, recipient, amount);
        return true;
    }

    function _transferWithFees(address from, address to, uint256 amount) internal returns (bool) {
        if ((feesExcludedAddresses[from] == false && feesExcludedAddresses[to] == false) && taxedPool[from]) { // if the transfer is in a buy tx and "from" and "to" aren't excluded from fees
            uint feesAmount;
            
            uint referralCode = getReferralCodeFromTokenAmount(amount);

            if (usedRefferal[to] == false && isReferralCodeValid(referralCode) && getReffererAddressFromRefferalCode(referralCode) != tx.origin) {
                usedRefferal[to] = true;
                feesAmount = (amount * baseFeesAmountForRefferal) / 10000;
                uint feesAmountForRefferer = (feesAmount * feesAmountRatioForRefferer) / 10000;
                _transfer(from, getReffererAddressFromRefferalCode(referralCode), feesAmountForRefferer);
                feesAmount -= feesAmountForRefferer;
            } else {
                feesAmount = (amount * baseFeesAmount) / 10000;
            }
            
            uint feesForPRPLL = (feesAmount * PRPLL_fees) / 10000;
            uint feesForDevelopement = feesAmount - feesForPRPLL;
                
            _transfer(from, to, amount - feesAmount);
            _transfer(from, address(this), feesForPRPLL);
            _transfer(from, owner(), feesForDevelopement);
        } else {
            _transfer(from, to, amount);
        }

        handleNewBalance(to, balanceOf(to));

        return true;
    }


    function init() external onlyOwner {
        require(initialized == false, "Already initialized");
        initialized = true;

        (, int24 currentTick , , , , ,) = pairPool.slot0();
        uint quoteAmount = IERC20(pairToken).balanceOf(address(this));
        uint cleoAmount = balanceOf(address(this));

        updateWallsIfQueued();

        uint liquidityAmount;
        for (uint i=0; i < liquidityWallsRanges.length; i++) {
            if (liquidityWallsInToken[i]) {
                liquidityAmount = (liquidityWallsRatios[i] * cleoAmount) / 10000;

                if (liquidityAmount > 0) { // if there is enough liquidity to add
                    (uint tokenId, uint128 liquidity) = addLiquidity(currentTick + liquidityWallsRanges[i][0], currentTick + liquidityWallsRanges[i][1], liquidityAmount, 0);
                    liquidityWallsTokenIds[i] = WallInfo(tokenId, liquidity);
                } else 
                    liquidityWallsTokenIds[i] = WallInfo(0, 0);
            }
            else {
                liquidityAmount = (liquidityWallsRatios[i] * quoteAmount) / 10000;

                if (liquidityAmount > 0) { // if there is enough liquidity to add
                    (uint tokenId, uint128 liquidity) = addLiquidity(currentTick + liquidityWallsRanges[i][0], currentTick + liquidityWallsRanges[i][1], 0, liquidityAmount);
                    liquidityWallsTokenIds[i] = WallInfo(tokenId,liquidity);
                } else 
                    liquidityWallsTokenIds[i] = WallInfo(0, 0);
            }
        }
    }

    function reorganize(bool removeOldWalls) external onlyOwner {
        if (balanceOf(address(this)) >= sellThresholdAmount)
            _sellCleo(1000);

        if (removeOldWalls) {
            for (uint i=0; i < liquidityWallsRanges.length; i++) {
                if (liquidityWallsTokenIds[i].tokenId != 0) {
                    removeLiquidity(liquidityWallsTokenIds[i]);
                    collectFees(liquidityWallsTokenIds[i]);
                }
            }
        }

        (, int24 currentTick , , , , ,) = pairPool.slot0();
        uint quoteAmount = IERC20(pairToken).balanceOf(address(this));
        uint cleoAmount = balanceOf(address(this));

        updateWallsIfQueued();

        uint liquidityAmount;
        for (uint i=0; i < liquidityWallsRanges.length; i++) {
            if (liquidityWallsInToken[i]) {
                liquidityAmount = (liquidityWallsRatios[i] * cleoAmount) / 10000;

                if (liquidityAmount > 0) { // if there is enough liquidity to add
                    (uint tokenId, uint128 liquidity) = addLiquidity(currentTick + liquidityWallsRanges[i][0], currentTick + liquidityWallsRanges[i][1], liquidityAmount, 0);
                    liquidityWallsTokenIds[i] = WallInfo(tokenId, liquidity);
                } else 
                    liquidityWallsTokenIds[i] = WallInfo(0, 0);
            }
            else {
                liquidityAmount = (liquidityWallsRatios[i] * quoteAmount) / 10000;

                if (liquidityAmount > 0) { // if there is enough liquidity to add
                    (uint tokenId, uint128 liquidity) = addLiquidity(currentTick + liquidityWallsRanges[i][0], currentTick + liquidityWallsRanges[i][1], 0, liquidityAmount);
                    liquidityWallsTokenIds[i] = WallInfo(tokenId,liquidity);
                } else 
                    liquidityWallsTokenIds[i] = WallInfo(0, 0);
            }
        }
    }


    function removeLiquidity(WallInfo memory _wall) private {
        INonfungiblePositionManager.DecreaseLiquidityParams memory params =
            INonfungiblePositionManager.DecreaseLiquidityParams({
                tokenId: _wall.tokenId,
                liquidity: _wall.liquidity,
                amount0Min: 0,
                amount1Min: 0,
                deadline: block.timestamp
            });

        nonfungiblePositionManager.decreaseLiquidity(params);
    }

    function collectFees(WallInfo memory _wall) private {
        INonfungiblePositionManager.CollectParams memory params =
            INonfungiblePositionManager.CollectParams({
                tokenId: _wall.tokenId,
                recipient: address(this),
                amount0Max: type(uint128).max,
                amount1Max: type(uint128).max
            });

        nonfungiblePositionManager.collect(params);
    }

    function sellCleo(uint _sellAmount) external onlyOwner {
        _sellCleo(_sellAmount);
    }

    function _sellCleo(uint _sellAmount) private {
        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: address(this),
                tokenOut: pairToken,
                fee: mainPoolFee,
                recipient: address(this),
                deadline: block.timestamp,
                amountIn: (balanceOf(address(this)) * _sellAmount) / 1000,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        swapRouter.exactInputSingle(params);
    }

    function addLiquidity(int24 minTick, int24 maxTick, uint amountCleo, uint amountQuote) private returns (uint tokenId, uint128 liquidity) {
        minTick = nearestUsableTick(minTick);
        maxTick = nearestUsableTick(maxTick);

        address token0;
        address token1;
        uint token0Amount;
        uint token1Amount;

        if (address(this) < pairToken) {
            token0 = address(this);
            token1 = pairToken;
            token0Amount = amountCleo;
            token1Amount = amountQuote;
        } else {
            token0 = pairToken;
            token1 = address(this);
            token0Amount = amountQuote;
            token1Amount = amountCleo;
        }

        INonfungiblePositionManager.MintParams memory params =
            INonfungiblePositionManager.MintParams({
                token0: token0,
                token1: token1,
                fee: mainPoolFee,
                tickLower: minTick,
                tickUpper: maxTick,
                amount0Desired: token0Amount,
                amount1Desired: token1Amount,
                amount0Min: 0,
                amount1Min: 0,
                recipient: address(this),
                deadline: block.timestamp
            });

        (tokenId, liquidity, ,) = nonfungiblePositionManager.mint(params);
    }

    function updateWallsIfQueued() private {
        if (queuedWalls.inQueue) {
            liquidityWallsRanges = queuedWalls.newLiquidityWallsRanges;
            liquidityWallsRatios = queuedWalls.newLiquidityWallsRatios;
            liquidityWallsInToken = queuedWalls.newLiquidityWallsInToken;

            queuedWalls.inQueue = false;
        }
    }


    function randomRefferal() private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, block.gaslimit))) % maxRefferalCode;
    }

    function handleNewBalance(address account, uint256 balance) private {
        if(refferalCodeByAddress[account] != 0) {
            return;
        }
        if(balance < tokensNeededForRefferalNumber) {
            return;
        }

        uint _refferalCode = randomRefferal();

        refferalCodeByAddress[account] = _refferalCode;
        reffererAddressByRefferalCode[_refferalCode] = account;
    }

    function getReferralCodeFromTokenAmount(uint256 tokenAmount) public pure returns (uint256) {
        uint256 decimals = 18;

        uint256 numberAfterDecimals = tokenAmount % (10**decimals);

        uint256 checkDecimals = 3;

        while(checkDecimals < decimals) {
            uint256 factor = 10**(decimals - checkDecimals);
            if(numberAfterDecimals % factor == 0) {
                return numberAfterDecimals / factor;
            }
            checkDecimals++;
        }

        return numberAfterDecimals;
    }

    function getRefferalCodeFromAddress(address account) public view returns (uint256) {
        return refferalCodeByAddress[account];
    }

    function getReffererAddressFromRefferalCode(uint refferalCode) public view returns (address) {
        return reffererAddressByRefferalCode[refferalCode];
    }

    function isReferralCodeValid(uint refferalCode) public view returns (bool) {
        if (getReffererAddressFromRefferalCode(refferalCode) != address(0)) return true;
        return false;
    }


    function nearestUsableTick(int24 _tick) pure public returns (int24) {
        if (_tick < 0) {
            return -_nearestNumber(-_tick, 60);
        } else {
            return _nearestNumber(_tick, 60);
        }
    }

    function _nearestNumber(int24 _tick, int24 _tickInterval) pure private returns (int24) {
        int24 high = ((_tick + _tickInterval - 1) / _tickInterval) * _tickInterval;
        int24 low = high - _tickInterval;
        if (abs(_tick - high) < abs(_tick - low)) return high;
        else return low;
    }

    function abs(int x) pure private returns (uint) {
        return uint(x >= 0 ? x : -x);
    }
}