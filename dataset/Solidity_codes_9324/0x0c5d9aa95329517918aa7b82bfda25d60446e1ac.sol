
pragma solidity 0.6.11;

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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

}

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
}

contract Locker is Ownable, ReentrancyGuard {

    using SafeMath for uint;
    using SafeERC20 for IERC20;
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;
    
    
    uint public constant MAX_LOCK_DURATION = 365 days;
    address public constant PLATFORM_TOKEN = 0x961C8c0B1aaD0c0b10a51FeF6a867E3091BCef17;
    
    uint public constant MINIMUM_BASETOKEN_PERCENT_ETH_X_100 = 100;
    uint public constant ONE_HUNDRED_X_100 = 10000;
    uint public constant SLIPPAGE_TOLERANCE_X_100 = 300;

    
    
    event Locked(uint indexed id, address indexed token, address indexed recipient, uint amount, uint unlockTimestamp, uint platformTokensLocked, bool claimed);
    event Unlocked(uint indexed id, address indexed token, address indexed recipient, uint amount, uint unlockTimestamp, uint platformTokensLocked, bool claimed);
    
    struct Lock {
        address token;
        uint unlockTimestamp;
        uint amount;
        address recipient;
        bool claimed;
        uint platformTokensLocked;
    }
    
    uint public locksLength;
    
    mapping (address => uint) public tokenBalances;
    
    mapping (uint => Lock) public locks;
    
    EnumerableSet.AddressSet private lockedTokens;
    EnumerableSet.AddressSet private baseTokens;
    
    
    EnumerableSet.UintSet private activeLockIds;
    EnumerableSet.UintSet private inactiveLockIds;
    
    mapping (address => EnumerableSet.UintSet) private activeLockIdsByRecipient;
    mapping (address => EnumerableSet.UintSet) private activeLockIdsByToken;
    
    mapping (address => EnumerableSet.UintSet) private inactiveLockIdsByRecipient;
    mapping (address => EnumerableSet.UintSet) private inactiveLockIdsByToken;
    
    modifier noContractsAllowed() {

        require(!(address(msg.sender).isContract()) && tx.origin == msg.sender, "No Contracts Allowed!");
        _;
    }
    
    IUniswapV2Router02 public uniswapRouterV2;
    
    constructor() public {
        uniswapRouterV2 = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        addBaseToken(uniswapRouterV2.WETH());
    }
    
    function getActiveLockIdsLength() external view returns (uint) {

        return activeLockIds.length();
    }
    function getActiveLockIds(uint startIndex, uint endIndex) external view returns (uint[] memory result) {

        require(endIndex > startIndex, "Invalid indexes provided!");
        require(endIndex <= activeLockIds.length(), "Invalid endIndex!");
        result = new uint[](endIndex.sub(startIndex));
        for (uint i = 0; i < endIndex.sub(startIndex); i = i.add(1)) {
            result[i] = activeLockIds.at(startIndex.add(i));   
        }
    }
    
    function getInactiveLockIdsLength() external view returns (uint) {

        return inactiveLockIds.length();
    }
    function getInactiveLockIds(uint startIndex, uint endIndex) external view returns (uint[] memory result) {

        require(endIndex > startIndex, "Invalid indexes provided!");
        require(endIndex <= inactiveLockIds.length(), "Invalid endIndex!");
        result = new uint[](endIndex.sub(startIndex));
        for (uint i = 0; i < endIndex.sub(startIndex); i = i.add(1)) {
            result[i] = inactiveLockIds.at(startIndex.add(i));   
        }
    }
    
    function getInactiveLockIdsLengthByToken(address token) external view returns (uint) {

        return inactiveLockIdsByToken[token].length();
    }
    function getInactiveLockIdsByToken(address token, uint startIndex, uint endIndex) external view returns (uint[] memory result) {

        require(endIndex > startIndex, "Invalid indexes provided!");
        require(endIndex <= inactiveLockIdsByToken[token].length(), "Invalid endIndex!");
        result = new uint[](endIndex.sub(startIndex));
        for (uint i = 0; i < endIndex.sub(startIndex); i = i.add(1)) {
            result[i] = inactiveLockIdsByToken[token].at(startIndex.add(i));   
        }
    }
    
    function getInactiveLockIdsLengthByRecipient(address recipient) external view returns (uint) {

        return inactiveLockIdsByRecipient[recipient].length();
    }
    function getInactiveLockIdsByRecipient(address recipient, uint startIndex, uint endIndex) external view returns (uint[] memory result) {

        require(endIndex > startIndex, "Invalid indexes provided!");
        require(endIndex <= inactiveLockIdsByRecipient[recipient].length(), "Invalid endIndex!");
        result = new uint[](endIndex.sub(startIndex));
        for (uint i = 0; i < endIndex.sub(startIndex); i = i.add(1)) {
            result[i] = inactiveLockIdsByRecipient[recipient].at(startIndex.add(i));   
        }
    }
    
    function getActiveLockIdsLengthByToken(address token) external view returns (uint) {

        return activeLockIdsByToken[token].length();
    }
    function getActiveLockIdsByToken(address token, uint startIndex, uint endIndex) external view returns (uint[] memory result) {

        require(endIndex > startIndex, "Invalid indexes provided!");
        require(endIndex <= activeLockIdsByToken[token].length(), "Invalid endIndex!");
        result = new uint[](endIndex.sub(startIndex));
        for (uint i = 0; i < endIndex.sub(startIndex); i = i.add(1)) {
            result[i] = activeLockIdsByToken[token].at(startIndex.add(i));   
        }
    }
    
    function getActiveLockIdsLengthByRecipient(address recipient) external view returns (uint) {

        return activeLockIdsByRecipient[recipient].length();
    }
    function getActiveLockIdsByRecipient(address recipient, uint startIndex, uint endIndex) external view returns (uint[] memory result) {

        require(endIndex > startIndex, "Invalid indexes provided!");
        require(endIndex <= activeLockIdsByRecipient[recipient].length(), "Invalid endIndex!");
        result = new uint[](endIndex.sub(startIndex));
        for (uint i = 0; i < endIndex.sub(startIndex); i = i.add(1)) {
            result[i] = activeLockIdsByRecipient[recipient].at(startIndex.add(i));   
        }
    }
    
    function getBaseTokensLength() external view returns (uint) {

        return baseTokens.length();
    }
    function getBaseTokens(uint startIndex, uint endIndex) external view returns (address[] memory result) {

        require(endIndex > startIndex, "Invalid indexes provided!");
        require(endIndex <= baseTokens.length(), "Invalid endIndex!");
        result = new address[](endIndex.sub(startIndex));
        for (uint i = 0; i < endIndex.sub(startIndex); i = i.add(1)) {
            result[i] = baseTokens.at(startIndex.add(i));   
        }
    }
    
    
    
    function createLock(address pair, address baseToken, uint amount, uint unlockTimestamp) external noContractsAllowed nonReentrant payable {

        require(amount > 0, "Cannot lock 0 liquidity!");
        require(unlockTimestamp.sub(block.timestamp) <= MAX_LOCK_DURATION, "Cannot lock for too long!");
        
        IUniswapV2Pair _pair = IUniswapV2Pair(pair);
        
        require(_pair.token0() == baseToken || _pair.token1() == baseToken, "Base token does not exist in pair!");
        require(baseTokens.contains(baseToken), "Base token does not exist!");
        
        uint minLockCreationFee = getMinLockCreationFeeInWei(pair, baseToken, amount);
        require(minLockCreationFee > 0, "Trying to lock too small amount!");
        require(msg.value >= minLockCreationFee, "Insufficient Ether fee sent!");
        
        transferTokenIn(pair, _msgSender(), amount);
        
        uint oldPlatformTokenBalance = IERC20(PLATFORM_TOKEN).balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = uniswapRouterV2.WETH();
        path[1] = PLATFORM_TOKEN;
        
        uint estimatedAmountOut = uniswapRouterV2.getAmountsOut(msg.value, path)[1];
        uint amountOutMin = estimatedAmountOut.mul(ONE_HUNDRED_X_100.sub(SLIPPAGE_TOLERANCE_X_100)).div(ONE_HUNDRED_X_100);
        
        uniswapRouterV2.swapExactETHForTokens{value: msg.value}(amountOutMin, path, address(this), block.timestamp);
        
        uint newPlatformTokenBalance = IERC20(PLATFORM_TOKEN).balanceOf(address(this));
        uint platformTokensLocked = newPlatformTokenBalance.sub(oldPlatformTokenBalance);
        require(platformTokensLocked > 0, "0 platform tokens swapped!");
        addPlatformTokenBalance(platformTokensLocked);
        
        
        locksLength = locksLength.add(1);
        
        Lock memory lock;
        
        lock.recipient = _msgSender();
        lock.unlockTimestamp = unlockTimestamp;
        lock.amount = lock.amount.add(amount);
        lock.token = pair;
        lock.platformTokensLocked = platformTokensLocked;
        
        locks[locksLength] = lock;
        
        addActiveLockId(locksLength);
        
        emit Locked(locksLength, pair, _msgSender(), amount, unlockTimestamp, platformTokensLocked, lock.claimed);
    }
    
    function claimUnlocked(uint lockId) external noContractsAllowed nonReentrant {

        require(activeLockIds.contains(lockId), "Lock not yet active!");
        require(!locks[lockId].claimed, "Already claimed!");
        require(locks[lockId].recipient == _msgSender(), "Invalid lock recipient");
        require(block.timestamp >= locks[lockId].unlockTimestamp, "Not yet unlocked! Please wait till unlock time!");
        locks[lockId].claimed = true;
        
        transferTokenOut(locks[lockId].token, locks[lockId].recipient, locks[lockId].amount);
        
        IERC20(PLATFORM_TOKEN).safeTransfer(locks[lockId].recipient, locks[lockId].platformTokensLocked);
        
        deductPlatformTokenBalance(locks[lockId].platformTokensLocked);
        
        removeActiveLockId(lockId);
        emit Unlocked(lockId, locks[lockId].token, locks[lockId].recipient, locks[lockId].amount, locks[lockId].unlockTimestamp, locks[lockId].platformTokensLocked, locks[lockId].claimed);
    }
    
    function transferTokenOut(address token, address recipient, uint amount) private {

        IERC20(token).safeTransfer(recipient, amount);
        tokenBalances[token] = tokenBalances[token].sub(amount);
        if (tokenBalances[token] == 0) {
            lockedTokens.remove(token);
        }
    }
    function transferTokenIn(address token, address from, uint amount) private {

        IERC20(token).safeTransferFrom(from, address(this), amount);
        tokenBalances[token] = tokenBalances[token].add(amount);
        lockedTokens.add(token);
    }
    function addPlatformTokenBalance(uint amount) private {

        tokenBalances[PLATFORM_TOKEN] = tokenBalances[PLATFORM_TOKEN].add(amount);
    }
    function deductPlatformTokenBalance(uint amount) private {

        tokenBalances[PLATFORM_TOKEN] = tokenBalances[PLATFORM_TOKEN].sub(amount);
    }
    
    function addBaseToken(address baseToken) public onlyOwner {

        baseTokens.add(baseToken);
    }
    function removeBaseToken(address baseToken) public onlyOwner {

        baseTokens.remove(baseToken);
    }
    
    function addActiveLockId(uint lockId) private {

        activeLockIds.add(lockId);
        activeLockIdsByRecipient[locks[lockId].recipient].add(lockId);
        activeLockIdsByToken[locks[lockId].token].add(lockId);
    }
    function removeActiveLockId(uint lockId) private {

        activeLockIds.remove(lockId);
        activeLockIdsByRecipient[locks[lockId].recipient].remove(lockId);
        activeLockIdsByToken[locks[lockId].token].remove(lockId);
        
        inactiveLockIds.add(lockId);
        inactiveLockIdsByRecipient[locks[lockId].recipient].add(lockId);
        inactiveLockIdsByToken[locks[lockId].token].add(lockId);
    }
    
    function claimExtraTokens(address token) external onlyOwner {

        uint diff = IERC20(token).balanceOf(address(this)).sub(tokenBalances[token]);
        IERC20(token).safeTransfer(_msgSender(), diff);
    }
    
    receive () external payable {
    }
    
    function claimEther() external onlyOwner {

        msg.sender.transfer(address(this).balance);
    }
    
    function getLockedTokensLength() external view returns (uint) {

        return lockedTokens.length();
    }
    function getLockedTokens(uint startIndex, uint endIndex) external view returns (address[] memory tokens) {

        require(endIndex > startIndex, "Invalid indexes provided!");
        require(endIndex <= lockedTokens.length(), "Invalid endIndex!");
        tokens = new address[](endIndex.sub(startIndex));
        for (uint i = 0; i < endIndex.sub(startIndex); i = i.add(1)) {
            tokens[i] = lockedTokens.at(startIndex.add(i));   
        }
    }
    
    function getTokensBalances(address[] memory tokens) external view returns (uint[] memory balances) {

        balances = new uint[](tokens.length);
        for (uint i = 0; i < tokens.length; i = i.add(1)) {
            balances[i] = tokenBalances[tokens[i]];
        }
    }
    
    function getLockById(uint id) public view returns (
        address token,
        uint unlockTimestamp,
        uint amount,
        address recipient,
        bool claimed,
        uint platformTokensLocked
    ) {

        token = locks[id].token;
        unlockTimestamp = locks[id].unlockTimestamp;
        amount = locks[id].amount;
        recipient = locks[id].recipient;
        claimed = locks[id].claimed;
        platformTokensLocked = locks[id].platformTokensLocked;
    }
    
    function getLocksByIds(uint[] memory ids) public view returns (
        uint[] memory _ids,
        address[] memory tokens,
        uint[] memory unlockTimestamps,
        uint[] memory amounts,
        address[] memory recipients,
        bool[] memory claimeds,
        uint[] memory platformTokensLockeds
    ) {

        _ids = ids;
        tokens = new address[](ids.length);
        unlockTimestamps = new uint[](ids.length);
        amounts = new uint[](ids.length);
        recipients = new address[](ids.length);
        claimeds = new bool[](ids.length);
        platformTokensLockeds = new uint[](ids.length);
        for (uint i = 0; i < ids.length; i = i.add(1)) {
            (address token, uint unlockTimestamp, uint amount, address recipient, bool claimed, uint platformTokensLocked) = getLockById(ids[i]);
        
            tokens[i] = token;
            unlockTimestamps[i] = unlockTimestamp;
            amounts[i] = amount;
            recipients[i] = recipient;
            claimeds[i] = claimed;
            platformTokensLockeds[i] = platformTokensLocked;
        }
    }
    
    function getMinLockCreationFeeInWei(address pair, address baseToken, uint amount) public view returns (uint) {

        uint baseTokenBalance = IERC20(baseToken).balanceOf(pair);
        uint totalSupply = IERC20(pair).totalSupply();
        uint baseTokenInReceivedLP = baseTokenBalance.mul(amount).div(totalSupply);
        uint feeBaseToken = baseTokenInReceivedLP.mul(MINIMUM_BASETOKEN_PERCENT_ETH_X_100).div(ONE_HUNDRED_X_100);

        if (baseToken == uniswapRouterV2.WETH()) return feeBaseToken;
        
        address[] memory path = new address[](2);
        
        path[0] = baseToken;
        path[1] = uniswapRouterV2.WETH();
        uint ethAmount = uniswapRouterV2.getAmountsOut(feeBaseToken, path)[1];
        return ethAmount;
    }
}