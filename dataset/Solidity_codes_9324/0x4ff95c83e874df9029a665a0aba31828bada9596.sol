


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



pragma solidity >=0.6.0 <=0.7.5;

interface ISmartTreasuryBootstrap {

  function swap(uint256[] calldata minBalances) external; // Exchange fees + IDLE if required for ETH

  function initialise() external;

  function bootstrap() external; // Create smart treasury pool, using parameters from spec and call begin updating weights

  function renounce() external; // transfer ownership to governance. 

}



pragma solidity = 0.6.8;
pragma experimental ABIEncoderV2;

interface BPool {

  event LOG_SWAP(
    address indexed caller,
    address indexed tokenIn,
    address indexed tokenOut,
    uint256         tokenAmountIn,
    uint256         tokenAmountOut
  );

  event LOG_JOIN(
    address indexed caller,
    address indexed tokenIn,
    uint256         tokenAmountIn
  );

  event LOG_EXIT(
    address indexed caller,
    address indexed tokenOut,
    uint256         tokenAmountOut
  );

  event LOG_CALL(
    bytes4  indexed sig,
    address indexed caller,
    bytes           data
  ) anonymous;

  function isPublicSwap() external view returns (bool);

  function isFinalized() external view returns (bool);

  function isBound(address t) external view returns (bool);

  function getNumTokens() external view returns (uint);

  function getCurrentTokens() external view returns (address[] memory tokens);

  function getFinalTokens() external view returns (address[] memory tokens);

  function getDenormalizedWeight(address token) external view returns (uint);

  function getTotalDenormalizedWeight() external view returns (uint);

  function getNormalizedWeight(address token) external view returns (uint);

  function getBalance(address token) external view returns (uint);

  function getSwapFee() external view returns (uint);

  function getController() external view returns (address);


  function setSwapFee(uint swapFee) external;

  function setController(address manager) external;

  function setPublicSwap(bool public_) external;

  function finalize() external;

  function bind(address token, uint balance, uint denorm) external;

  function unbind(address token) external;

  function gulp(address token) external;


  function getSpotPrice(address tokenIn, address tokenOut) external view returns (uint spotPrice);

  function getSpotPriceSansFee(address tokenIn, address tokenOut) external view returns (uint spotPrice);


  function joinPool(uint poolAmountOut, uint[] calldata maxAmountsIn) external;   

  function exitPool(uint poolAmountIn, uint[] calldata minAmountsOut) external;


  function swapExactAmountIn(
    address tokenIn,
    uint tokenAmountIn,
    address tokenOut,
    uint minAmountOut,
    uint maxPrice
  ) external returns (uint tokenAmountOut, uint spotPriceAfter);


  function swapExactAmountOut(
    address tokenIn,
    uint maxAmountIn,
    address tokenOut,
    uint tokenAmountOut,
    uint maxPrice
  ) external returns (uint tokenAmountIn, uint spotPriceAfter);


  function joinswapExternAmountIn(
    address tokenIn,
    uint tokenAmountIn,
    uint minPoolAmountOut
  ) external returns (uint poolAmountOut);


  function joinswapPoolAmountOut(
    address tokenIn,
    uint poolAmountOut,
    uint maxAmountIn
  ) external returns (uint tokenAmountIn);


  function exitswapPoolAmountIn(
    address tokenOut,
    uint poolAmountIn,
    uint minAmountOut
  ) external returns (uint tokenAmountOut);


  function exitswapExternAmountOut(
    address tokenOut,
    uint tokenAmountOut,
    uint maxPoolAmountIn
  ) external returns (uint poolAmountIn);


  function totalSupply() external view returns (uint);

  function balanceOf(address whom) external view returns (uint);

  function allowance(address src, address dst) external view returns (uint);


  function approve(address dst, uint amt) external returns (bool);

  function transfer(address dst, uint amt) external returns (bool);

  function transferFrom(
    address src, address dst, uint amt
  ) external returns (bool);

}

interface ConfigurableRightsPool {

  event LogCall(
    bytes4  indexed sig,
    address indexed caller,
    bytes data
  ) anonymous;

  event LogJoin(
    address indexed caller,
    address indexed tokenIn,
    uint tokenAmountIn
  );

  event LogExit(
    address indexed caller,
    address indexed tokenOut,
    uint tokenAmountOut
  );

  event CapChanged(
    address indexed caller,
    uint oldCap,
    uint newCap
  );
    
  event NewTokenCommitted(
    address indexed token,
    address indexed pool,
    address indexed caller
  );

  function createPool(
    uint initialSupply
  ) external;


  function createPool(
    uint initialSupply,
    uint minimumWeightChangeBlockPeriodParam,
    uint addTokenTimeLockInBlocksParam
  ) external;


  function updateWeightsGradually(
    uint[] calldata newWeights,
    uint startBlock,
    uint endBlock
  ) external;


  function joinswapExternAmountIn(
    address tokenIn,
    uint tokenAmountIn,
    uint minPoolAmountOut
  ) external;

  
  function whitelistLiquidityProvider(address provider) external;

  function removeWhitelistedLiquidityProvider(address provider) external;

  function canProvideLiquidity(address provider) external returns (bool);

  function getController() external view returns (address);

  function setController(address newOwner) external;


  function transfer(address recipient, uint amount) external returns (bool);

  function balanceOf(address account) external returns (uint);

  function totalSupply() external returns (uint);

  function bPool() external view returns (BPool);


  function exitPool(uint poolAmountIn, uint[] calldata minAmountsOut) external;

}

interface IBFactory {

  event LOG_NEW_POOL(
    address indexed caller,
    address indexed pool
  );

  event LOG_BLABS(
    address indexed caller,
    address indexed blabs
  );

  function isBPool(address b) external view returns (bool);

  function newBPool() external returns (BPool);

}

interface ICRPFactory {

  event LogNewCrp(
    address indexed caller,
    address indexed pool
  );

  struct PoolParams {
    string poolTokenSymbol;
    string poolTokenName;
    address[] constituentTokens;
    uint[] tokenBalances;
    uint[] tokenWeights;
    uint swapFee;
  }

  struct Rights {
    bool canPauseSwapping;
    bool canChangeSwapFee;
    bool canChangeWeights;
    bool canAddRemoveTokens;
    bool canWhitelistLPs;
    bool canChangeCap;
  }

  function newCrp(
    address factoryAddress,
    PoolParams calldata poolParams,
    Rights calldata rights
  ) external returns (ConfigurableRightsPool);

}


pragma solidity = 0.6.8;


library BalancerConstants {


    uint public constant BONE = 10**18;
    uint public constant MIN_WEIGHT = BONE;
    uint public constant MAX_WEIGHT = BONE * 50;
    uint public constant MAX_TOTAL_WEIGHT = BONE * 50;
    uint public constant MIN_BALANCE = BONE / 10**6;
    uint public constant MAX_BALANCE = BONE * 10**12;
    uint public constant MIN_POOL_SUPPLY = BONE * 100;
    uint public constant MAX_POOL_SUPPLY = BONE * 10**9;
    uint public constant MIN_FEE = BONE / 10**6;
    uint public constant MAX_FEE = BONE / 10;
    uint public constant EXIT_FEE = 0;
    uint public constant MAX_IN_RATIO = BONE / 2;
    uint public constant MAX_OUT_RATIO = (BONE / 3) + 1 wei;
    uint public constant MIN_ASSET_LIMIT = 2;
    uint public constant MAX_ASSET_LIMIT = 8;
    uint public constant MAX_UINT = uint(-1);
}


pragma solidity = 0.6.8;









contract SmartTreasuryBootstrap is ISmartTreasuryBootstrap, Ownable {

  using EnumerableSet for EnumerableSet.AddressSet;
  using SafeERC20 for IERC20;
  using SafeMath for uint256;

  address public immutable timelock;
  address public immutable feeCollectorAddress;

  address private crpaddress;

  uint256 private idlePerWeth; // internal price oracle for IDLE

  enum ContractState { DEPLOYED, SWAPPED, INITIALISED, BOOTSTRAPPED, RENOUNCED }
  ContractState private contractState;

  IBFactory private immutable balancer_bfactory;
  ICRPFactory private immutable balancer_crpfactory;

  IUniswapV2Router02 private constant uniswapRouterV2 = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

  IERC20 private immutable idle;
  IERC20 private immutable weth;

  EnumerableSet.AddressSet private depositTokens;

  constructor (
    address _balancerBFactory,
    address _balancerCRPFactory,
    address _idle,
    address _weth,
    address _timelock,
    address _feeCollectorAddress,
    address _multisig,
    address[] memory _initialDepositTokens
  ) public {
    require(_balancerBFactory != address(0), "BFactory cannot be the 0 address");
    require(_balancerCRPFactory != address(0), "CRPFactory cannot be the 0 address");
    require(_idle != address(0), "IDLE cannot be the 0 address");
    require(_weth != address(0), "WETH cannot be the 0 address");
    require(_timelock != address(0), "Timelock cannot be the 0 address");
    require(_feeCollectorAddress != address(0), "FeeCollector cannot be the 0 address");
    require(_multisig != address(0), "Multisig cannot be 0 address");

    balancer_bfactory = IBFactory(_balancerBFactory);
    balancer_crpfactory = ICRPFactory(_balancerCRPFactory);

    idle = IERC20(_idle);
    weth = IERC20(_weth);

    timelock = _timelock;
    feeCollectorAddress = _feeCollectorAddress;

    address _depositToken;
    for (uint256 index = 0; index < _initialDepositTokens.length; index++) {
      _depositToken = _initialDepositTokens[index];
      require(_depositToken != address(_weth), "WETH fees are not supported"); // There is no WETH -> WETH pool in uniswap
      require(_depositToken != address(_idle), "IDLE fees are not supported"); // Dont swap IDLE to WETH

      IERC20(_depositToken).safeIncreaseAllowance(address(uniswapRouterV2), type(uint256).max); // max approval
      depositTokens.add(_depositToken);
    }

    transferOwnership(_multisig);
    contractState = ContractState.DEPLOYED;
  }

  function swap(uint256[] calldata minTokenOut) external override onlyOwner {

    require(contractState==ContractState.DEPLOYED || contractState==ContractState.SWAPPED, "Invalid state");
    uint256 counter = depositTokens.length();

    require(minTokenOut.length == counter, "Invalid length");

    address[] memory path = new address[](2);
    path[1] = address(weth);

    address _tokenAddress;
    IERC20 _tokenInterface;
    uint256 _currentBalance;

    for (uint256 index = 0; index < counter; index++) {
      _tokenAddress = depositTokens.at(index);
      _tokenInterface = IERC20(_tokenAddress);

      _currentBalance = _tokenInterface.balanceOf(address(this));

      path[0] = _tokenAddress;
      
      uniswapRouterV2.swapExactTokensForTokensSupportingFeeOnTransferTokens(
        _currentBalance,
        minTokenOut[index],
        path,
        address(this),
        block.timestamp.add(1800)
      );
    }

    contractState = ContractState.SWAPPED;
  }

  function initialise() external override onlyOwner {

    require(contractState == ContractState.SWAPPED, "Invalid State");
    require(crpaddress==address(0), "Cannot initialise if CRP already exists");
    require(idlePerWeth!=0, "IDLE price not set");
    
    uint256 idleBalance = idle.balanceOf(address(this));
    uint256 wethBalance = weth.balanceOf(address(this));

    require(idleBalance > uint256(100).mul(10**18), "Cannot initialise without idle in contract");
    require(wethBalance > uint256(1).mul(10**18), "Cannot initialise without weth in contract");

    address[] memory tokens = new address[](2);
    tokens[0] = address(idle);
    tokens[1] = address(weth);

    uint256[] memory balances = new uint256[](2);
    balances[0] = idleBalance;
    balances[1] = wethBalance;

    
    uint256 idleValueInWeth = balances[0].mul(10**18).div(idlePerWeth);
    uint256 wethValue = balances[1];

    uint256 totalValueInPool = idleValueInWeth.add(wethValue); // expressed in WETH

    uint256[] memory weights = new uint256[](2);
    weights[0] = idleValueInWeth.mul(BalancerConstants.BONE * 25).div(totalValueInPool); // IDLE value / total value
    weights[1] = wethValue.mul(BalancerConstants.BONE * 25).div(totalValueInPool); // WETH value / total value

    require(weights[0] >= BalancerConstants.BONE  && weights[0] <= BalancerConstants.BONE.mul(24), "Invalid weights");

    ICRPFactory.PoolParams memory params = ICRPFactory.PoolParams({
      poolTokenSymbol: "ISTT",
      poolTokenName: "Idle Smart Treasury Token",
      constituentTokens: tokens,
      tokenBalances: balances,
      tokenWeights: weights,
      swapFee: 5 * 10**15 // .5% fee = 5000000000000000
    });

    ICRPFactory.Rights memory rights = ICRPFactory.Rights({
      canPauseSwapping:   true,
      canChangeSwapFee:   true,
      canChangeWeights:   true,
      canAddRemoveTokens: true,
      canWhitelistLPs:    true,
      canChangeCap:       false
    });
    

    ConfigurableRightsPool crp = balancer_crpfactory.newCrp(
      address(balancer_bfactory),
      params,
      rights
    );

    crp.whitelistLiquidityProvider(address(this));
    crp.whitelistLiquidityProvider(timelock);
    crp.whitelistLiquidityProvider(feeCollectorAddress);

    crpaddress = address(crp);

    idle.safeIncreaseAllowance(crpaddress, balances[0]); // approve transfer of idle
    weth.safeIncreaseAllowance(crpaddress, balances[1]); // approve transfer of idle

    contractState = ContractState.INITIALISED;
  }

  function bootstrap() external override onlyOwner {

    require(contractState == ContractState.INITIALISED, "Invalid State");
    require(crpaddress!=address(0), "Cannot bootstrap if CRP does not exist");
    
    ConfigurableRightsPool crp = ConfigurableRightsPool(crpaddress);

    crp.createPool(
      1000 * 10 ** 18, // mint 1000 shares
      3 days, // minimumWeightChangeBlockPeriodParam
      3 days  // addTokenTimeLockInBlocksParam
    );

    uint256[] memory finalWeights = new uint256[](2);
    finalWeights[0] = BalancerConstants.BONE.mul(225).div(10); // 90 %
    finalWeights[1] = BalancerConstants.BONE.mul(25).div(10); // 10 %


    crp.updateWeightsGradually(
      finalWeights,
      block.timestamp,
      block.timestamp.add(30 days)  // ~ 1 months
    );

    contractState = ContractState.BOOTSTRAPPED;
  }

  function renounce() external override onlyOwner {

    require(contractState == ContractState.BOOTSTRAPPED, "Invalid State");
    require(crpaddress != address(0), "Cannot renounce if CRP does not exist");

    ConfigurableRightsPool crp = ConfigurableRightsPool(crpaddress);
    
    require(address(crp.bPool()) != address(0), "Cannot renounce if bPool does not exist");

    crp.removeWhitelistedLiquidityProvider(address(this));
    crp.setController(timelock);

    IERC20(crpaddress).safeTransfer(feeCollectorAddress, crp.balanceOf(address(this)));
    
    contractState = ContractState.RENOUNCED;
  }

  function withdraw(address _token, address _toAddress, uint256 _amount) external {

    require((msg.sender == owner() && contractState == ContractState.RENOUNCED) || msg.sender == timelock, "Only admin");

    IERC20 token = IERC20(_token);
    token.safeTransfer(_toAddress, _amount);
  }

  function setIDLEPrice(uint256 _idlePerWeth) external onlyOwner {

    idlePerWeth = _idlePerWeth;
  }

  function registerTokenToDepositList(address _tokenAddress) public onlyOwner {

    require(_tokenAddress != address(weth), "WETH fees are not supported"); // There is no WETH -> WETH pool in uniswap
    require(_tokenAddress != address(idle), "IDLE fees are not supported"); // Dont swap IDLE to WETH

    IERC20(_tokenAddress).safeIncreaseAllowance(address(uniswapRouterV2), type(uint256).max); // max approval
    depositTokens.add(_tokenAddress);
  }

  function removeTokenFromDepositList(address _tokenAddress) external onlyOwner {

    IERC20(_tokenAddress).safeApprove(address(uniswapRouterV2), 0); // 0 approval for uniswap
    depositTokens.remove(_tokenAddress);
  }

  function getState() external view returns (ContractState) {return contractState; }

  function getIDLEperWETH() external view returns (uint256) {return idlePerWeth; }

  function getCRPAddress() external view returns (address) { return crpaddress; }

  function getCRPBPoolAddress() external view returns (address) {

    require(crpaddress!=address(0), "CRP is not configured yet");
    return address(ConfigurableRightsPool(crpaddress).bPool());
  }
  function tokenInDepositList(address _tokenAddress) external view returns (bool) {return depositTokens.contains(_tokenAddress);}

  function getDepositTokens() external view returns (address[] memory) {

    uint256 numTokens = depositTokens.length();

    address[] memory depositTokenList = new address[](numTokens);
    for (uint256 index = 0; index < numTokens; index++) {
      depositTokenList[index] = depositTokens.at(index);
    }
    return (depositTokenList);
  }
}