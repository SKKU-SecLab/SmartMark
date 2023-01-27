


pragma solidity >=0.5.0;

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


pragma solidity >=0.5.0;

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




pragma solidity >=0.6.0 <0.8.0;

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




pragma solidity >=0.6.0 <0.8.0;




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




pragma solidity >=0.6.0 <0.8.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

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

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
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


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(value)));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(value)));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(value)));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint256(_at(set._inner, index)));
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
}




pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}




pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
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
}







pragma solidity >0.4.13;

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



pragma solidity 0.6.12;

interface IStakingAdapter {

    function claim() external;

    function deposit(uint amount) external;

    function withdraw(uint amount) external;

    function emergencyWithdraw() external;

    function rewardTokenAddress() external view returns(address);

    function lpTokenAddress() external view returns(address);

    function pending() external view returns (uint256);

    function balance() external view returns (uint256);

}



pragma solidity 0.6.12;


interface ITideToken is IERC20 {

  function owner() external view returns (address);

  function mint(address _to, uint256 _amount) external;

  function setParent(address _newConfig) external;

  function wipeout(address _recipient, uint256 _amount) external;

}




pragma solidity 0.6.12;

contract Poseidon is Ownable, DSMath {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount;     // How many LP tokens the user has provided.
        uint256 tidalRewardDebt; // Reward debt. See explanation below.
        uint256 riptideRewardDebt; // Reward debt. See explanation below.
        uint256 otherRewardDebt;
    }

    struct PoolInfo {
        IERC20 lpToken;           // Address of LP token contract.
        uint256 allocPoint;       // How many allocation points assigned to this pool. SUSHIs to distribute per block.
        uint256 withdrawFee; // Amount of LP liquidated on withdraw (often 0)
        uint256 lastRewardBlock;  // Last block number that SUSHIs distribution occurs.
        uint256 accTidalPerShare; // Accumulated SUSHIs per share, times 1e12. See below.
        uint256 accRiptidePerShare; // Accumulated SUSHIs per share, times 1e12. See below.
        uint256 accOtherPerShare; // Accumulated OTHERs per share, times 1e12. See below.
        IStakingAdapter adapter; // Manages external farming
        IERC20 otherToken; // The OTHER reward token for this pool, if any
    }

    IUniswapV2Router02 router;

    ITideToken public tidal;
    ITideToken public riptide;

    address public devaddr;
    address public feeaddr;
    uint256 public baseRewardPerBlock = 2496e11; // base reward token emission (0.0002496)
    uint256 public devDivisor = 238; // dev fund of 4.2%, 1000/238 = 4.20168...

    PoolInfo[] public poolInfo;
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
    uint256 public totalAllocPoint = 0;
    uint256 public startBlock;

    mapping (address => bool) private poolIsAdded;

    address public phase;
    uint256 public constant TIDAL_CAP = 69e18;
    uint256 public constant TIDAL_VERTEX = 42e18;

    bool public stormy = false;
    uint256 public stormDivisor = 2;

    address public zeus;

    address public surf;
    address public whirlpool;


    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    constructor(
        IUniswapV2Router02 _router,
        ITideToken _tidal,
        ITideToken _riptide,
        address _surf, // 0xEa319e87Cf06203DAe107Dd8E5672175e3Ee976c
        address _whirlpool, // 0x999b1e6EDCb412b59ECF0C5e14c20948Ce81F40b
        address _devaddr,
        uint256 _startBlock
    ) public {
        router = _router;
        tidal = _tidal;
        riptide = _riptide;
        surf = _surf;
        whirlpool = _whirlpool;
        devaddr = _devaddr;
        feeaddr = _devaddr;
        startBlock = _startBlock;
        phase = address(_tidal);
    }

    modifier validAdapter(IStakingAdapter _adapter) {

        require(address(_adapter) != address(0), "no adapter specified");
        require(_adapter.rewardTokenAddress() != address(0), "no other reward token specified in staking adapter");
        require(_adapter.lpTokenAddress() != address(0), "no staking token specified in staking adapter");
        _;
    }

    modifier onlyZeus() {

        require(msg.sender == zeus, "only zeus can call this method");
        _;
    }

    function poolLength() external view returns (uint256) {

        return poolInfo.length;
    }

    function add(uint256 _allocPoint, IERC20 _lpToken, uint256 _withdrawFee, bool _withUpdate) public onlyOwner {

        require(poolIsAdded[address(_lpToken)] == false, 'add: pool already added');
        poolIsAdded[address(_lpToken)] = true;

        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(PoolInfo({
            lpToken: _lpToken,
            allocPoint: _allocPoint,
            withdrawFee: _withdrawFee,
            lastRewardBlock: lastRewardBlock,
            accTidalPerShare: 0,
            accRiptidePerShare: 0,
            accOtherPerShare: 0,
            adapter: IStakingAdapter(0),
            otherToken: IERC20(0)
        }));
    }

    function addWithRestaking(uint256 _allocPoint, uint256 _withdrawFee, bool _withUpdate, IStakingAdapter _adapter) public onlyOwner validAdapter(_adapter) {

        IERC20 _lpToken = IERC20(_adapter.lpTokenAddress());

        require(poolIsAdded[address(_lpToken)] == false, 'add: pool already added');
        poolIsAdded[address(_lpToken)] = true;
        
        if (_withUpdate) {
            massUpdatePools();
        }

        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(PoolInfo({
            lpToken: _lpToken,
            allocPoint: _allocPoint,
            withdrawFee: _withdrawFee,
            lastRewardBlock: lastRewardBlock,
            accTidalPerShare: 0,
            accRiptidePerShare: 0,
            accOtherPerShare: 0,
            adapter: _adapter,
            otherToken: IERC20(_adapter.rewardTokenAddress())
        }));
    }

    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate) public onlyOwner {

        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    function setRestaking(uint256 _pid, IStakingAdapter _adapter, bool _claim) public onlyOwner validAdapter(_adapter) {

        if (_claim) {
            updatePool(_pid);
        }
        if (isRestaking(_pid)) {
            withdrawRestakedLP(_pid);
        }
        PoolInfo storage pool = poolInfo[_pid];
        require(address(pool.lpToken) == _adapter.lpTokenAddress(), "LP mismatch");
        pool.accOtherPerShare = 0;
        pool.adapter = _adapter;
        pool.otherToken = IERC20(_adapter.rewardTokenAddress());

        uint256 poolBal = pool.lpToken.balanceOf(address(this));
        if (poolBal > 0) {
            pool.lpToken.safeTransfer(address(pool.adapter), poolBal);
            pool.adapter.deposit(poolBal);
        }
    }

    function removeRestaking(uint256 _pid, bool _claim) public onlyOwner {

        require(isRestaking(_pid), "not a restaking pool");
        if (_claim) {
            updatePool(_pid);
        }
        withdrawRestakedLP(_pid);
        poolInfo[_pid].adapter = IStakingAdapter(address(0));
        require(!isRestaking(_pid), "failed to remove restaking");
    }

    function setWeather(bool _isStormy, bool _withUpdate) public onlyZeus {

        if (_withUpdate) {
            massUpdatePools();
        }
        stormy = _isStormy;
    }

    function setWeatherConfig(address _newZeus, uint256 _newStormDivisor) public onlyOwner {

        require(_newStormDivisor != 0, "Cannot divide by zero");
        stormDivisor = _newStormDivisor;
        zeus = _newZeus; // can be address(0)
    }

    function setRewardPerBlock(uint256 _newReward) public onlyOwner {

        baseRewardPerBlock = _newReward;
    }

    function setSurfConfig(address _newSurf, address _newWhirlpool) public onlyOwner {

        surf = _newSurf;
        whirlpool = _newWhirlpool;
    }

    function _tokensPerBlock(address _tideToken) internal view returns (uint256) {

        if (phase == _tideToken) {
            if (stormy) {
                return baseRewardPerBlock.div(stormDivisor);
            } else {
                return baseRewardPerBlock;
            }
        } else {
            return 0;
        }
    }

    function tokensPerBlock(address _tideToken) external view returns (uint256) {

        return _tokensPerBlock(_tideToken);
    }

    function pendingTokens(uint256 _pid, address _user) external view returns (uint256, uint256) {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accTidalPerShare = pool.accTidalPerShare;
        uint256 accRiptidePerShare = pool.accRiptidePerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (isRestaking(_pid)) {
            lpSupply = pool.adapter.balance();
        }
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 span = block.number.sub(pool.lastRewardBlock);
            uint256 pendingTidal = 0;
            uint256 pendingRiptide = 0;
            if (phase == address(tidal)) {
                pendingTidal = span.mul(_tokensPerBlock(address(tidal))).mul(pool.allocPoint).div(totalAllocPoint);
            } else if (phase == address(riptide)) {
                pendingRiptide = span.mul(_tokensPerBlock(address(riptide))).mul(pool.allocPoint).div(totalAllocPoint);
            }
            accTidalPerShare = accTidalPerShare.add(pendingTidal.mul(1e12).div(lpSupply));
            accRiptidePerShare = accRiptidePerShare.add(pendingRiptide.mul(1e12).div(lpSupply));
        }
        uint256 unclaimedTidal = user.amount.mul(accTidalPerShare).div(1e12).sub(user.tidalRewardDebt);
        uint256 unclaimedRiptide = user.amount.mul(accRiptidePerShare).div(1e12).sub(user.riptideRewardDebt);
        return (unclaimedTidal, unclaimedRiptide);
    }

    function pendingOther(uint256 _pid, address _user) external view returns (uint256) {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accOtherPerShare = pool.accOtherPerShare;
        uint256 lpSupply = pool.adapter.balance();
 
        if (lpSupply != 0) {
            uint256 otherReward = pool.adapter.pending();
            accOtherPerShare = accOtherPerShare.add(otherReward.mul(1e12).div(lpSupply));
        }
        return user.amount.mul(accOtherPerShare).div(1e12).sub(user.otherRewardDebt);
    }

    function massUpdatePools() public {

        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    function updatePool(uint256 _pid) public {


        updatePhase();

        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }

        uint256 lpSupply = getPoolSupply(_pid);
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        if (isRestaking(_pid)) {
            uint256 pendingOtherTokens = pool.adapter.pending();
            if (pendingOtherTokens >= 0) {
                uint256 otherBalanceBefore = pool.otherToken.balanceOf(address(this));
                pool.adapter.claim();
                uint256 otherBalanceAfter = pool.otherToken.balanceOf(address(this));
                pendingOtherTokens = otherBalanceAfter.sub(otherBalanceBefore);
                pool.accOtherPerShare = pool.accOtherPerShare.add(pendingOtherTokens.mul(1e12).div(lpSupply));
            }
        }

        uint256 span = block.number.sub(pool.lastRewardBlock);
        if (phase == address(tidal)) {
            uint256 tidalReward = span.mul(_tokensPerBlock(address(tidal))).mul(pool.allocPoint).div(totalAllocPoint);
            uint256 devTidalReward = tidalReward.mul(10).div(devDivisor);
            if (tidal.totalSupply().add(tidalReward).add(devTidalReward) > TIDAL_CAP) {
                uint256 totalTidalReward = TIDAL_CAP.sub(tidal.totalSupply());
                uint256 newDevTidalReward = totalTidalReward.mul(10).div(devDivisor-10); // ~ reverse percentage approximation
                uint256 newTidalReward = totalTidalReward.sub(newDevTidalReward);
                tidal.mint(devaddr, newDevTidalReward); 
                tidal.mint(address(this), newTidalReward);
                pool.accTidalPerShare = pool.accTidalPerShare.add(newTidalReward.mul(1e12).div(lpSupply));

                uint256 totalRiptideReward = tidalReward.sub(totalTidalReward);
                uint256 newDevRiptideReward = totalRiptideReward.mul(10).div(devDivisor-10);
                uint256 newRiptideReward = totalRiptideReward.sub(newDevRiptideReward);
                riptide.mint(devaddr, newDevRiptideReward);
                riptide.mint(devaddr, newRiptideReward);
                pool.accRiptidePerShare = pool.accRiptidePerShare.add(newRiptideReward.mul(1e12).div(lpSupply));
            } else {
                tidal.mint(devaddr, devTidalReward); 
                tidal.mint(address(this), tidalReward);
                pool.accTidalPerShare = pool.accTidalPerShare.add(tidalReward.mul(1e12).div(lpSupply));
            }
        } else {
            uint256 riptideReward = span.mul(_tokensPerBlock(address(riptide))).mul(pool.allocPoint).div(totalAllocPoint);
            riptide.mint(devaddr, riptideReward.mul(10).div(devDivisor));
            riptide.mint(address(this), riptideReward);
            pool.accRiptidePerShare = pool.accRiptidePerShare.add(riptideReward.mul(1e12).div(lpSupply));
        }
        pool.lastRewardBlock = block.number;
    }

    function getPoolSupply(uint256 _pid) internal view returns (uint256 lpSupply) {

        PoolInfo memory pool = poolInfo[_pid];
        if (isRestaking(_pid)) {
            lpSupply = pool.adapter.balance();
        } else {
            lpSupply = pool.lpToken.balanceOf(address(this));
        }
    }

    function isRestaking(uint256 _pid) public view returns (bool outcome) {

        if (address(poolInfo[_pid].adapter) != address(0)) {
            outcome = true;
        } else {
            outcome = false;
        }
    }

    function deposit(uint256 _pid, uint256 _amount) public {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        uint256 pendingOtherTokens = 0;
        if (user.amount > 0) {
            uint256 pendingTidal = user.amount.mul(pool.accTidalPerShare).div(1e12).sub(user.tidalRewardDebt);
            if(pendingTidal > 0) {
                safeTideTransfer(msg.sender, pendingTidal, tidal);
            }
            uint256 pendingRiptide = user.amount.mul(pool.accRiptidePerShare).div(1e12).sub(user.riptideRewardDebt);
            if(pendingRiptide > 0) {
                safeTideTransfer(msg.sender, pendingRiptide, riptide);
            }
            pendingOtherTokens = user.amount.mul(pool.accOtherPerShare).div(1e12).sub(user.otherRewardDebt);
        }
        if(_amount > 0) {
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            if (isRestaking(_pid)) {
                pool.lpToken.safeTransfer(address(pool.adapter), _amount);
                pool.adapter.deposit(_amount);
            }
            user.amount = user.amount.add(_amount);
        }
        if (pendingOtherTokens > 0) {
            safeOtherTransfer(msg.sender, pendingOtherTokens, _pid);
        }
        user.tidalRewardDebt = user.amount.mul(pool.accTidalPerShare).div(1e12);
        user.riptideRewardDebt = user.amount.mul(pool.accRiptidePerShare).div(1e12);
        user.otherRewardDebt = user.amount.mul(pool.accOtherPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }


    function withdraw(uint256 _pid, uint256 _amount) public {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 pendingTidal = user.amount.mul(pool.accTidalPerShare).div(1e12).sub(user.tidalRewardDebt);
        if(pendingTidal > 0) {
            safeTideTransfer(msg.sender, pendingTidal, tidal);
        }
        uint256 pendingRiptide = user.amount.mul(pool.accRiptidePerShare).div(1e12).sub(user.riptideRewardDebt);
        if(pendingRiptide > 0) {
            safeTideTransfer(msg.sender, pendingRiptide, riptide);
        }
        uint256 pendingOtherTokens = user.amount.mul(pool.accOtherPerShare).div(1e12).sub(user.otherRewardDebt);
        if(_amount > 0) {
            uint256 amount = _amount;
            user.amount = user.amount.sub(amount);
            if (isRestaking(_pid)) {
                pool.adapter.withdraw(amount);
            }
            if (pool.withdrawFee > 0) {
                uint256 fee = wmul(amount, pool.withdrawFee);
                amount = amount.sub(fee);
                processWithdrawFee(address(pool.lpToken), fee);
            }
            pool.lpToken.safeTransfer(address(msg.sender), amount);
        }
        if (pendingOtherTokens > 0) {
            safeOtherTransfer(msg.sender, pendingOtherTokens, _pid);
        }
        user.tidalRewardDebt = user.amount.mul(pool.accTidalPerShare).div(1e12);
        user.riptideRewardDebt = user.amount.mul(pool.accRiptidePerShare).div(1e12);
        user.otherRewardDebt = user.amount.mul(pool.accOtherPerShare).div(1e12);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function processWithdrawFee(address _lpToken, uint256 _fee) private {

        address token0 = IUniswapV2Pair(_lpToken).token0();
        address token1 = IUniswapV2Pair(_lpToken).token1();

        IERC20(_lpToken).approve(address(router), _fee);
        (uint256 token0Amount, uint256 token1Amount) = router.removeLiquidity(token0, token1, _fee, 0, 0, address(this), block.timestamp);
        IERC20(_lpToken).approve(address(router), 0);

        address[] memory surfPath = new address[](2);
        surfPath[1] = surf;

        if (token0 == surf) {
            surfPath[0] = token1;
            router.swapExactTokensForTokens(
                token1Amount,
                0,
                surfPath,
                whirlpool,
                block.timestamp
            );
            IERC20(token0).transfer(whirlpool, token0Amount);
        } else if (token1 == surf) {
            surfPath[0] = token0;
            router.swapExactTokensForTokens(
                token0Amount,
                0,
                surfPath,
                whirlpool,
                block.timestamp
            );
            IERC20(token1).transfer(whirlpool, token1Amount);
        } else {
            IERC20(token0).transfer(feeaddr, token0Amount);
            IERC20(token1).transfer(feeaddr, token1Amount);
        }
    }

    function emergencyWithdraw(uint256 _pid) public {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 amount = user.amount;
        user.amount = 0;
        user.tidalRewardDebt = 0;
        user.riptideRewardDebt = 0;
        if (isRestaking(_pid)) {
            pool.adapter.withdraw(amount);
        }
        if (pool.withdrawFee > 0) {
            uint256 fee = wmul(amount, pool.withdrawFee);
            amount = amount.sub(fee);
            pool.lpToken.transfer(feeaddr, fee);
        }
        pool.lpToken.safeTransfer(address(msg.sender), amount);
        emit EmergencyWithdraw(msg.sender, _pid, amount);
    }

    function withdrawRestakedLP(uint256 _pid) internal {

        require(isRestaking(_pid), "not a restaking pool");
        PoolInfo storage pool = poolInfo[_pid];
        uint lpBalanceBefore = pool.lpToken.balanceOf(address(this));
        pool.adapter.emergencyWithdraw();
        uint lpBalanceAfter = pool.lpToken.balanceOf(address(this));
        emit EmergencyWithdraw(address(pool.adapter), _pid, lpBalanceAfter.sub(lpBalanceBefore));
    }


    function safeTideTransfer(address _to, uint256 _amount, ITideToken _tideToken) internal {

        uint256 tokenBal = _tideToken.balanceOf(address(this));
        if (_amount > tokenBal) {
            _tideToken.transfer(_to, tokenBal);
        } else {
            _tideToken.transfer(_to, _amount);
        }
    }

    function safeOtherTransfer(address _to, uint256 _amount, uint256 _pid) internal {

        PoolInfo storage pool = poolInfo[_pid];
        uint256 otherBal = pool.otherToken.balanceOf(address(this));
        if (_amount > otherBal) {
            pool.otherToken.transfer(_to, otherBal);
        } else {
            pool.otherToken.transfer(_to, _amount);
        }
    }

    function dev(address _devaddr) public onlyOwner {

        devaddr = _devaddr;
    }

    function setNewDevDivisor(uint256 _newDivisor) public onlyOwner {

        require(_newDivisor >= 145, "Dev fee too high"); // ~6.9% max
        devDivisor = _newDivisor;
    }

    function fee(address _feeaddr) public onlyOwner {

        feeaddr = _feeaddr;
    }

    function transferTokenOwnership(address _owned, address _newOwner) public onlyOwner {

        Ownable(_owned).transferOwnership(_newOwner);
    }

    function setNewTidalToken(address _newTidal) public onlyOwner {

        require(ITideToken(_newTidal).owner() == address(this), "Poseidon not the owner");
        if (phase == address(tidal)) phase = _newTidal;
        tidal = ITideToken(_newTidal);
    }

    function setNewRiptideToken(address _newRiptide) public onlyOwner {

        require(ITideToken(_newRiptide).owner() == address(this), "Poseidon not the owner");
        if (phase == address(riptide)) phase = _newRiptide;
        riptide = ITideToken(_newRiptide);
    }

    function getPhase() public view returns (address) {

        return phase;
    }

    function updatePhase() internal {

        if (phase == address(tidal) && tidal.totalSupply() >= TIDAL_CAP){
            phase = address(riptide);
        }
        else if (phase == address(riptide) && tidal.totalSupply() < TIDAL_VERTEX) {
            phase = address(tidal);
        }
    }

}