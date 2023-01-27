



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

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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





pragma solidity 0.6.12;

interface ISushiFactory {

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





pragma solidity 0.6.12;

interface ISushiPair {

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





pragma solidity 0.6.12;

interface IWETH {

    function deposit() external payable;


    function transfer(address to, uint value) external returns (bool);


    function withdraw(uint) external;

}





pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

interface ISushiChef {

    struct SushiPoolInfo {
        IERC20 lpToken;           // Address of LP token contract.
        uint256 allocPoint;       // How many allocation points assigned to this pool. MDXs to distribute per block.
        uint256 lastRewardBlock;  // Last block number that MDXs distribution occurs.
        uint256 accMdxPerShare; // Accumulated MDXs per share, times 1e12.
    }

    function pendingSushi(uint256 _pid, address _user) external view returns (uint256);

    function deposit(uint256 _pid, uint256 _amount) external;

    function withdraw(uint256 _pid, uint256 _amount) external;

    function sushiPerBlock() external view returns(uint256);

    function poolInfo(uint256 i) external view returns(SushiPoolInfo memory);

    function totalAllocPoint() external view returns(uint256);

}





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

        (bool success,) = to.call{value : value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}





pragma solidity 0.6.12;


library SushiSwapLibrary {

    using SafeMath for uint;

    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {

        require(tokenA != tokenB, 'SushiSwapLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'SushiSwapLibrary: ZERO_ADDRESS');
    }

    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {

        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'e18a34eb0e04b04f7a0ac29a6e80748dca96319b42c54d679cb821dca90c6303' // init code hash
            ))));
    }

    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {

        (address token0,) = sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1,) = ISushiPair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {

        require(amountA > 0, 'SushiSwapLibrary: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'SushiSwapLibrary: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {

        require(amountIn > 0, 'SushiSwapLibrary: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'SushiSwapLibrary: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(997);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {

        require(amountOut > 0, 'SushiSwapLibrary: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'SushiSwapLibrary: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(1000);
        uint denominator = reserveOut.sub(amountOut).mul(997);
        amountIn = (numerator / denominator).add(1);
    }

    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {

        require(path.length >= 2, 'SushiSwapLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {

        require(path.length >= 2, 'SushiSwapLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}





pragma solidity 0.6.12;











contract MasterChef is Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256 sushiRewardDebt;
    }
    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. HPTs to distribute per block.
        uint256 lastRewardBlock; // Last block number that HPTs distribution occurs.
        uint256 accHptPerShare; // Accumulated HPTs per share, times 1e12. See below.
        uint256 sushiChefPid;
        uint256 lpBalance;
        uint256 accSushiPerShare;
    }

    IERC20 public hpt;
    uint256 public hptPerBlock;
    PoolInfo[] public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    uint256 public totalAllocPoint = 0;
    uint256 public startBlock;
    uint256 public hptRewardBalance;
    uint256 public sushiRewardBalance;
    uint256 public hptRewardTotal;
    uint256 public sushiRewardTotal;
    address public factory;
    address public WETH;
    ISushiChef public sushiChef;
    uint256 public sushiProfitRate;
    IERC20 public sushi;
    uint256 one = 1e18;
    address public treasuryAddress;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );

    event AmtNotEnoughSend(
        address indexed user,
        address currency,
        uint256 shouldAmt,
        uint256 actAmt
    );

    constructor(
        IERC20 _hpt,
        uint256 _hptPerBlock,
        uint256 _startBlock,
        address _sushiFactory,
        address _WETH,
        ISushiChef _sushiChef,
        uint256 _sushiProfitRate,
        IERC20 _sushi,
        address _treasuryAddress
    ) public {
        hpt = _hpt;
        hptPerBlock = _hptPerBlock;
        startBlock = _startBlock;
        factory = _sushiFactory;
        WETH = _WETH;
        sushiChef = _sushiChef;
        sushiProfitRate = _sushiProfitRate;
        sushi = _sushi;
        treasuryAddress = _treasuryAddress;
    }

    function setTreasuryAddress(address _treasuryAddress) public onlyOwner {

        treasuryAddress = _treasuryAddress;
    }

    function setHptPerBlock(uint _hptPerBlock) public onlyOwner {

        massUpdatePools();
        hptPerBlock = _hptPerBlock;
    }

    function sushiRewardPerBlock(uint256 _pid) external view returns(uint256) {

        PoolInfo storage pool = poolInfo[_pid];
        uint256 sushiTotalAllocPoint = sushiChef.totalAllocPoint();
        ISushiChef.SushiPoolInfo memory sushiPoolInfo = sushiChef.poolInfo(pool.sushiChefPid);
        uint totalAmount = sushiPoolInfo.lpToken.balanceOf(address(sushiChef));

        uint256 sushiPerBlock = sushiChef.sushiPerBlock().mul(sushiPoolInfo.allocPoint).div(sushiTotalAllocPoint);
        sushiPerBlock = sushiPerBlock.mul(pool.lpBalance).div(totalAmount);
        sushiPerBlock = sushiPerBlock.mul(one.sub(sushiProfitRate)).div(one);
        return sushiPerBlock;
    }

    function hptRewardPerBlock(uint _pid) external view returns(uint)  {

        PoolInfo storage pool = poolInfo[_pid];
        return hptPerBlock.mul(pool.allocPoint).div(totalAllocPoint);
    }

    function setSushiProfitRate(uint _sushiProfitRate) public onlyOwner {

        massUpdatePools();
        sushiProfitRate = _sushiProfitRate;
    }

    function poolLength() external view returns (uint256) {

        return poolInfo.length;
    }

    function revoke() public onlyOwner {

        hpt.transfer(msg.sender, hpt.balanceOf(address(this)));
    }

    function add(
        uint256 _allocPoint,
        IERC20 _lpToken,
        uint _sushiChefPid
    ) public onlyOwner {

        massUpdatePools();
        uint256 lastRewardBlock =
        block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(
            PoolInfo({
            lpToken: _lpToken,
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            accHptPerShare: 0,
            sushiChefPid: _sushiChefPid,
            lpBalance: 0,
            accSushiPerShare: 0
            })
        );
    }

    function set(
        uint256 _pid,
        uint256 _allocPoint,
        uint _sushiChefPid
    ) public onlyOwner {

        massUpdatePools();
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(
            _allocPoint
        );
        poolInfo[_pid].allocPoint = _allocPoint;
        poolInfo[_pid].sushiChefPid = _sushiChefPid;
    }

    function getMultiplier(uint256 _from, uint256 _to)
    public
    pure
    returns (uint256)
    {

        return _to.sub(_from);
    }

    function pendingHpt(uint256 _pid, address _user)
    external
    view
    returns (uint256)
    {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accHptPerShare = pool.accHptPerShare;
        uint256 lpSupply = pool.lpBalance;
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier =
            getMultiplier(pool.lastRewardBlock, block.number);
            uint256 hptReward =
            multiplier.mul(hptPerBlock).mul(pool.allocPoint).div(
                totalAllocPoint
            );
            accHptPerShare = accHptPerShare.add(
                hptReward.mul(1e12).div(lpSupply)
            );
        }
        return user.amount.mul(accHptPerShare).div(1e12).sub(user.rewardDebt);
    }

    function pendingSushi(uint256 _pid, address _user)
    external
    view
    returns (uint256)
    {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accSushiPerShare = pool.accSushiPerShare;
        uint256 lpSupply = pool.lpBalance;
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 sushiReward = sushiChef.pendingSushi(pool.sushiChefPid, address(this));
            accSushiPerShare = accSushiPerShare.add(
                sushiReward.mul(1e12).div(lpSupply)
            );
        }
        return user.amount.mul(accSushiPerShare).div(1e12).sub(user.sushiRewardDebt);
    }

    function massUpdatePools() public {

        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    function updatePool(uint256 _pid) public {

        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpBalance;
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 hptReward =
        multiplier.mul(hptPerBlock).mul(pool.allocPoint).div(
            totalAllocPoint
        );
        hptRewardBalance = hptRewardBalance.add(hptReward);
        hptRewardTotal = hptRewardTotal.add(hptReward);
        pool.accHptPerShare = pool.accHptPerShare.add(
            hptReward.mul(1e12).div(lpSupply)
        );

        uint256 sushiBalancePrior = sushi.balanceOf(address(this));
        sushiChef.withdraw(pool.sushiChefPid, 0);
        uint256 sushiBalanceNew = sushi.balanceOf(address(this));
        if (sushiBalanceNew > sushiBalancePrior) {
            uint256 delta = sushiBalanceNew.sub(sushiBalancePrior);
            uint256 sushiProfit = delta.mul(sushiProfitRate).div(one);
            sushi.transfer(treasuryAddress, sushiProfit);

            uint256 sushiReward = delta.sub(sushiProfit);
            sushiRewardBalance = sushiRewardBalance.add(sushiReward);
            sushiRewardTotal = sushiRewardTotal.add(sushiReward);
            pool.accSushiPerShare = pool.accSushiPerShare.add(
                sushiReward.mul(1e12).div(lpSupply)
            );
        }

        pool.lastRewardBlock = block.number;
    }

    function depositTokens(uint256 _pid,
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin) public {

        uint _amount;
        address pair = getPair(tokenA, tokenB);
        PoolInfo storage pool = poolInfo[_pid];
        require(pair == address(pool.lpToken), "wrong pid");
        updatePool(_pid);
        if (amountADesired != 0) {
            (, , _amount) = addLiquidity(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin, address(this));
            pool.lpToken.approve(address(sushiChef), _amount);
            sushiChef.deposit(pool.sushiChefPid, _amount);
        }
        deposit(_pid, _amount);
    }

    function depositETH(uint256 _pid,
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin) public payable {

        uint _amount;
        address pair = getPair(token, WETH);
        PoolInfo storage pool = poolInfo[_pid];
        require(pair == address(pool.lpToken), "wrong pid");
        updatePool(_pid);
        if (amountTokenDesired != 0) {
            (, , _amount) = addLiquidityETH(token, amountTokenDesired, amountTokenMin, amountETHMin, address(this));
            pool.lpToken.approve(address(sushiChef), _amount);
            sushiChef.deposit(pool.sushiChefPid, _amount);
        }
        deposit(_pid, _amount);
    }

    function deposit(uint256 _pid, uint256 _amount) internal {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        if (user.amount > 0) {
            uint256 hptPending =
            user.amount.mul(pool.accHptPerShare).div(1e12).sub(
                user.rewardDebt
            );
            safeHptTransfer(msg.sender, hptPending);

            uint256 sushiPending =
            user.amount.mul(pool.accSushiPerShare).div(1e12).sub(
                user.sushiRewardDebt
            );
            safeSushiTransfer(msg.sender, sushiPending);
        }
        pool.lpBalance = pool.lpBalance.add(_amount);
        user.amount = user.amount.add(_amount);
        user.rewardDebt = user.amount.mul(pool.accHptPerShare).div(1e12);
        user.sushiRewardDebt = user.amount.mul(pool.accSushiPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }

    function withdrawTokens(uint256 _pid,
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin) public {

        address pair = getPair(tokenA, tokenB);
        PoolInfo storage pool = poolInfo[_pid];
        require(pair == address(pool.lpToken), "wrong pid");
        updatePool(_pid);
        withdraw(_pid, liquidity);
        if (liquidity != 0) {
            sushiChef.withdraw(pool.sushiChefPid, liquidity);
            removeLiquidity(tokenA, tokenB, liquidity, amountAMin, amountBMin, msg.sender);
        }
    }

    function withdrawETH(uint256 _pid,
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin) public {

        address pair = getPair(token, WETH);
        PoolInfo storage pool = poolInfo[_pid];
        require(pair == address(pool.lpToken), "wrong pid");
        updatePool(_pid);
        withdraw(_pid, liquidity);
        if (liquidity != 0) {
            sushiChef.withdraw(pool.sushiChefPid, liquidity);
            uint amountToken;
            uint amountETH;
            (amountToken, amountETH) = removeLiquidity(token, WETH, liquidity, amountTokenMin, amountETHMin, address(this));
            TransferHelper.safeTransfer(token, msg.sender, amountToken);
            IWETH(WETH).withdraw(amountETH);
            TransferHelper.safeTransferETH(msg.sender, amountETH);
        }
    }

    function withdraw(uint256 _pid, uint256 _amount) internal {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");

        uint256 pending =
        user.amount.mul(pool.accHptPerShare).div(1e12).sub(
            user.rewardDebt
        );
        safeHptTransfer(msg.sender, pending);

        uint256 sushiPending =
        user.amount.mul(pool.accSushiPerShare).div(1e12).sub(
            user.sushiRewardDebt
        );
        safeSushiTransfer(msg.sender, sushiPending);

        pool.lpBalance = pool.lpBalance.sub(_amount);
        user.amount = user.amount.sub(_amount);
        user.rewardDebt = user.amount.mul(pool.accHptPerShare).div(1e12);
        user.sushiRewardDebt = user.amount.mul(pool.accSushiPerShare).div(1e12);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function emergencyWithdrawTokens(uint256 _pid,
        address tokenA,
        address tokenB,
        uint amountAMin,
        uint amountBMin) public {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        address pair = getPair(tokenA, tokenB);
        require(pair == address(pool.lpToken), "wrong pid");
        updatePool(_pid);

        sushiChef.withdraw(pool.sushiChefPid, user.amount);
        removeLiquidity(tokenA, tokenB, user.amount, amountAMin, amountBMin, msg.sender);

        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
        pool.lpBalance = pool.lpBalance.sub(user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
        user.sushiRewardDebt = 0;
    }

    function emergencyWithdrawETH(uint256 _pid,
        address token,
        uint amountTokenMin,
        uint amountETHMin) public {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        address pair = getPair(token, WETH);
        require(pair == address(pool.lpToken), "wrong pid");
        updatePool(_pid);

        sushiChef.withdraw(pool.sushiChefPid, user.amount);
        uint amountToken;
        uint amountETH;
        (amountToken, amountETH) = removeLiquidity(token, WETH, user.amount, amountTokenMin, amountETHMin, address(this));
        TransferHelper.safeTransfer(token, msg.sender, amountToken);
        IWETH(WETH).withdraw(amountETH);

        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
        pool.lpBalance = pool.lpBalance.sub(user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
        user.sushiRewardDebt = 0;

        TransferHelper.safeTransferETH(msg.sender, amountETH);
    }

    function safeHptTransfer(address _to, uint256 _amount) internal {

        hptRewardBalance = hptRewardBalance.sub(_amount);
        uint256 hptBal = hpt.balanceOf(address(this));
        if (_amount > hptBal) {
            hpt.transfer(_to, hptBal);
            emit AmtNotEnoughSend(_to, address(hpt), _amount, hptBal);
        } else {
            hpt.transfer(_to, _amount);
        }
    }

    function safeSushiTransfer(address _to, uint256 _amount) internal {

        sushiRewardBalance = sushiRewardBalance.sub(_amount);
        uint256 sushiBal = sushi.balanceOf(address(this));
        if (_amount > sushiBal) {
            sushi.transfer(_to, sushiBal);
            emit AmtNotEnoughSend(_to, address(sushi), _amount, sushiBal);
        } else {
            sushi.transfer(_to, _amount);
        }
    }

    function getPair(address tokenA, address tokenB) internal view returns (address pair){

        pair = ISushiFactory(factory).getPair(tokenA, tokenB);
    }

    function _addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin
    ) internal view returns (uint amountA, uint amountB) {

        (uint reserveA, uint reserveB) = SushiSwapLibrary.getReserves(factory, tokenA, tokenB);
        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (amountADesired, amountBDesired);
        } else {
            uint amountBOptimal = SushiSwapLibrary.quote(amountADesired, reserveA, reserveB);
            if (amountBOptimal <= amountBDesired) {
                require(amountBOptimal >= amountBMin, 'Router: INSUFFICIENT_B_AMOUNT');
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                uint amountAOptimal = SushiSwapLibrary.quote(amountBDesired, reserveB, reserveA);
                assert(amountAOptimal <= amountADesired);
                require(amountAOptimal >= amountAMin, 'Router: INSUFFICIENT_A_AMOUNT');
                (amountA, amountB) = (amountAOptimal, amountBDesired);
            }
        }
    }

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to
    ) internal returns (uint amountA, uint amountB, uint liquidity) {

        (amountA, amountB) = _addLiquidity(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin);
        address pair = getPair(tokenA, tokenB);
        TransferHelper.safeTransferFrom(tokenA, msg.sender, pair, amountA);
        TransferHelper.safeTransferFrom(tokenB, msg.sender, pair, amountB);
        liquidity = ISushiPair(pair).mint(to);
    }

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to
    ) internal returns (uint amountToken, uint amountETH, uint liquidity) {

        (amountToken, amountETH) = _addLiquidity(
            token,
            WETH,
            amountTokenDesired,
            msg.value,
            amountTokenMin,
            amountETHMin
        );
        address pair = getPair(token, WETH);
        TransferHelper.safeTransferFrom(token, msg.sender, pair, amountToken);
        IWETH(WETH).deposit{value : amountETH}();
        assert(IWETH(WETH).transfer(pair, amountETH));
        liquidity = ISushiPair(pair).mint(to);
        if (msg.value > amountETH) TransferHelper.safeTransferETH(msg.sender, msg.value - amountETH);
    }

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to
    ) internal returns (uint amountA, uint amountB) {

        address pair = getPair(tokenA, tokenB);
        ISushiPair(pair).transfer(pair, liquidity);
        (uint amount0, uint amount1) = ISushiPair(pair).burn(to);
        (address token0,) = SushiSwapLibrary.sortTokens(tokenA, tokenB);
        (amountA, amountB) = tokenA == token0 ? (amount0, amount1) : (amount1, amount0);
        require(amountA >= amountAMin, 'Router: INSUFFICIENT_A_AMOUNT');
        require(amountB >= amountBMin, 'Router: INSUFFICIENT_B_AMOUNT');
    }

    fallback() external {}
    receive() payable external {}
}