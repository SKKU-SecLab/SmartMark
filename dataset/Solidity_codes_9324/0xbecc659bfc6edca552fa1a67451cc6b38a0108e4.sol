


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




abstract contract AccessControl is Context {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }

    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }

    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, _roles[role].adminRole, adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
        }
    }
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

interface IFeeCollector {

  function deposit(bool[] calldata _depositTokensEnabled, uint256[] calldata _minTokenOut, uint256 _minPoolAmountOut) external; // called by whitelisted address

  function setSplitAllocation(uint256[] calldata _allocations) external; // allocation of fees sent SmartTreasury vs FeeTreasury


  function addBeneficiaryAddress(address _newBeneficiary, uint256[] calldata _newAllocation) external;

  function removeBeneficiaryAt(uint256 _index, uint256[] calldata _newAllocation) external;

  function replaceBeneficiaryAt(uint256 _index, address _newBeneficiary, uint256[] calldata _newAllocation) external;

  function setSmartTreasuryAddress(address _smartTreasuryAddress) external; // If for any reason the pool needs to be migrated, call this function. Called by admin


  function addAddressToWhiteList(address _addressToAdd) external; // Whitelist address. Called by admin

  function removeAddressFromWhiteList(address _addressToRemove) external; // Remove from whitelist. Called by admin


  function registerTokenToDepositList(address _tokenAddress) external; // Register a token which can converted to ETH and deposited to smart treasury. Called by admin

  function removeTokenFromDepositList(address _tokenAddress) external; // Unregister a token. Called by admin


  function withdraw(address _token, address _toAddress, uint256 _amount) external;

  function withdrawUnderlying(address _toAddress, uint256 _amount, uint256[] calldata minTokenOut) external;


  function replaceAdmin(address _newAdmin) external; // called by admin

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









contract FeeCollector is IFeeCollector, AccessControl {

  using EnumerableSet for EnumerableSet.AddressSet;
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  IUniswapV2Router02 private constant uniswapRouterV2 = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

  address private immutable weth;

  EnumerableSet.AddressSet private depositTokens;

  uint256[] private allocations; // 100000 = 100%. allocation sent to beneficiaries
  address[] private beneficiaries; // Who are the beneficiaries of the fees generated from IDLE. The first beneficiary is always going to be the smart treasury

  uint128 public constant MAX_BENEFICIARIES = 5;
  uint128 public constant MIN_BENEFICIARIES = 2;
  uint256 public constant FULL_ALLOC = 100000;

  uint256 public constant MAX_NUM_FEE_TOKENS = 15; // Cap max tokens to 15
  bytes32 public constant WHITELISTED = keccak256("WHITELISTED_ROLE");

  modifier smartTreasurySet {

    require(beneficiaries[0]!=address(0), "Smart Treasury not set");
    _;
  }

  modifier onlyAdmin {

    require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Unauthorised");
    _;
  }

  modifier onlyWhitelisted {

    require(hasRole(WHITELISTED, msg.sender), "Unauthorised");
    _;
  }

  constructor (
    address _weth,
    address _feeTreasuryAddress,
    address _idleRebalancer,
    address _multisig,
    address[] memory _initialDepositTokens
  ) public {
    require(_weth != address(0), "WETH cannot be the 0 address");
    require(_feeTreasuryAddress != address(0), "Fee Treasury cannot be 0 address");
    require(_idleRebalancer != address(0), "Rebalancer cannot be 0 address");
    require(_multisig != address(0), "Multisig cannot be 0 address");

    require(_initialDepositTokens.length <= MAX_NUM_FEE_TOKENS);
    
    _setupRole(DEFAULT_ADMIN_ROLE, _multisig); // setup multisig as admin
    _setupRole(WHITELISTED, _multisig); // setup multisig as whitelisted address
    _setupRole(WHITELISTED, _idleRebalancer); // setup multisig as whitelisted address

    weth = _weth;

    allocations = new uint256[](3); // setup fee split ratio
    allocations[0] = 80000;
    allocations[1] = 15000;
    allocations[2] = 5000;

    beneficiaries = new address[](3); // setup beneficiaries
    beneficiaries[1] = _feeTreasuryAddress; // setup fee treasury address
    beneficiaries[2] = _idleRebalancer; // setup fee treasury address

    address _depositToken;
    for (uint256 index = 0; index < _initialDepositTokens.length; index++) {
      _depositToken = _initialDepositTokens[index];
      require(_depositToken != address(0), "Token cannot be 0 address");
      require(_depositToken != _weth, "WETH not supported"); // There is no WETH -> WETH pool in uniswap
      require(depositTokens.contains(_depositToken) == false, "Already exists");

      IERC20(_depositToken).safeIncreaseAllowance(address(uniswapRouterV2), type(uint256).max); // max approval
      depositTokens.add(_depositToken);
    }
  }

  function deposit(
    bool[] memory _depositTokensEnabled,
    uint256[] memory _minTokenOut,
    uint256 _minPoolAmountOut
  ) public override smartTreasurySet onlyWhitelisted {

    _deposit(_depositTokensEnabled, _minTokenOut, _minPoolAmountOut);
  }

  function _deposit(
    bool[] memory _depositTokensEnabled,
    uint256[] memory _minTokenOut,
    uint256 _minPoolAmountOut
  ) internal {

    uint256 counter = depositTokens.length();
    require(_depositTokensEnabled.length == counter, "Invalid length");
    require(_minTokenOut.length == counter, "Invalid length");

    uint256 _currentBalance;
    IERC20 _tokenInterface;

    uint256 wethBalance;

    address[] memory path = new address[](2);
    path[1] = weth; // output will always be weth
    
    for (uint256 index = 0; index < counter; index++) {
      if (_depositTokensEnabled[index] == false) {continue;}

      _tokenInterface = IERC20(depositTokens.at(index));

      _currentBalance = _tokenInterface.balanceOf(address(this));
      
      if (_currentBalance > 0) {
        
        path[0] = address(_tokenInterface);
        
        uniswapRouterV2.swapExactTokensForTokensSupportingFeeOnTransferTokens(
          _currentBalance,
          _minTokenOut[index], 
          path,
          address(this),
          block.timestamp.add(1800)
        );
      }
    }

    wethBalance = IERC20(weth).balanceOf(address(this));
    if (wethBalance > 0){
      uint256[] memory feeBalances = _amountsFromAllocations(allocations, wethBalance);
      uint256 smartTreasuryFee = feeBalances[0];

      if (wethBalance.sub(smartTreasuryFee) > 0){
          for (uint256 a_index = 1; a_index < allocations.length; a_index++){
            IERC20(weth).safeTransfer(beneficiaries[a_index], feeBalances[a_index]);
          }
        }

      if (smartTreasuryFee > 0) {
        ConfigurableRightsPool crp = ConfigurableRightsPool(beneficiaries[0]); // the smart treasury is at index 0
        crp.joinswapExternAmountIn(weth, smartTreasuryFee, _minPoolAmountOut);
      }
    }
  }

  function setSplitAllocation(uint256[] calldata _allocations) external override smartTreasurySet onlyAdmin {

    _depositAllTokens();

    _setSplitAllocation(_allocations);
  }

  function _setSplitAllocation(uint256[] memory _allocations) internal {

    require(_allocations.length == beneficiaries.length, "Invalid length");
    
    uint256 sum=0;
    for (uint256 i=0; i<_allocations.length; i++) {
      sum = sum.add(_allocations[i]);
    }

    require(sum == FULL_ALLOC, "Ratio does not equal 100000");

    allocations = _allocations;
  }

  function _depositAllTokens() internal {

    uint256 numTokens = depositTokens.length();
    bool[] memory depositTokensEnabled = new bool[](numTokens);
    uint256[] memory minTokenOut = new uint256[](numTokens);

    for (uint256 i = 0; i < numTokens; i++) {
      depositTokensEnabled[i] = true;
      minTokenOut[i] = 1;
    }

    _deposit(depositTokensEnabled, minTokenOut, 1);
  }

  function addBeneficiaryAddress(address _newBeneficiary, uint256[] calldata _newAllocation) external override smartTreasurySet onlyAdmin {

    require(beneficiaries.length < MAX_BENEFICIARIES, "Max beneficiaries");
    require(_newBeneficiary!=address(0), "beneficiary cannot be 0 address");

    for (uint256 i = 0; i < beneficiaries.length; i++) {
      require(beneficiaries[i] != _newBeneficiary, "Duplicate beneficiary");
    }

    _depositAllTokens();

    beneficiaries.push(_newBeneficiary);

    _setSplitAllocation(_newAllocation);
  }

  function removeBeneficiaryAt(uint256 _index, uint256[] calldata _newAllocation) external override smartTreasurySet onlyAdmin {

    require(_index >= 1, "Invalid beneficiary to remove");
    require(_index < beneficiaries.length, "Out of range");
    require(beneficiaries.length > MIN_BENEFICIARIES, "Min beneficiaries");
    
    _depositAllTokens();

    beneficiaries[_index] = beneficiaries[beneficiaries.length-1];
    beneficiaries.pop();
    
    _setSplitAllocation(_newAllocation);
  }

  function replaceBeneficiaryAt(uint256 _index, address _newBeneficiary, uint256[] calldata _newAllocation) external override smartTreasurySet onlyAdmin {

    require(_index >= 1, "Invalid beneficiary to remove");
    require(_newBeneficiary!=address(0), "Beneficiary cannot be 0 address");

    for (uint256 i = 0; i < beneficiaries.length; i++) {
      require(beneficiaries[i] != _newBeneficiary, "Duplicate beneficiary");
    }

    _depositAllTokens();
    
    beneficiaries[_index] = _newBeneficiary;

    _setSplitAllocation(_newAllocation);
  }
  
  function setSmartTreasuryAddress(address _smartTreasuryAddress) external override onlyAdmin {

    require(_smartTreasuryAddress!=address(0), "Smart treasury cannot be 0 address");

    if (beneficiaries[0] != address(0)) {
      IERC20(weth).safeApprove(beneficiaries[0], 0); // set approval for previous fee address to 0
    }
    IERC20(weth).safeIncreaseAllowance(_smartTreasuryAddress, type(uint256).max);
    beneficiaries[0] = _smartTreasuryAddress;
  }

  function addAddressToWhiteList(address _addressToAdd) external override onlyAdmin{

    grantRole(WHITELISTED, _addressToAdd);
  }

  function removeAddressFromWhiteList(address _addressToRemove) external override onlyAdmin {

    revokeRole(WHITELISTED, _addressToRemove);
  }
    
  function registerTokenToDepositList(address _tokenAddress) external override onlyAdmin {

    require(depositTokens.length() < MAX_NUM_FEE_TOKENS, "Too many tokens");
    require(_tokenAddress != address(0), "Token cannot be 0 address");
    require(_tokenAddress != weth, "WETH not supported"); // There is no WETH -> WETH pool in uniswap
    require(depositTokens.contains(_tokenAddress) == false, "Already exists");

    IERC20(_tokenAddress).safeIncreaseAllowance(address(uniswapRouterV2), type(uint256).max); // max approval
    depositTokens.add(_tokenAddress);
  }

  function removeTokenFromDepositList(address _tokenAddress) external override onlyAdmin {

    IERC20(_tokenAddress).safeApprove(address(uniswapRouterV2), 0); // 0 approval for uniswap
    depositTokens.remove(_tokenAddress);
  }

  function withdraw(address _token, address _toAddress, uint256 _amount) external override onlyAdmin {

    IERC20(_token).safeTransfer(_toAddress, _amount);
  }

  function _amountsFromAllocations(uint256[] memory _allocations, uint256 total) internal pure returns (uint256[] memory newAmounts) {

    newAmounts = new uint256[](_allocations.length);
    uint256 currBalance;
    uint256 allocatedBalance;

    for (uint256 i = 0; i < _allocations.length; i++) {
      if (i == _allocations.length - 1) {
        newAmounts[i] = total.sub(allocatedBalance);
      } else {
        currBalance = total.mul(_allocations[i]).div(FULL_ALLOC);
        allocatedBalance = allocatedBalance.add(currBalance);
        newAmounts[i] = currBalance;
      }
    }
    return newAmounts;
  }

  function withdrawUnderlying(address _toAddress, uint256 _amount, uint256[] calldata minTokenOut) external override smartTreasurySet onlyAdmin{

    ConfigurableRightsPool crp = ConfigurableRightsPool(beneficiaries[0]);
    BPool smartTreasuryBPool = crp.bPool();

    uint256 numTokensInPool = smartTreasuryBPool.getNumTokens();
    require(minTokenOut.length == numTokensInPool, "Invalid length");


    address[] memory poolTokens = smartTreasuryBPool.getCurrentTokens();
    uint256[] memory feeCollectorTokenBalances = new uint256[](numTokensInPool);

    for (uint256 i=0; i<poolTokens.length; i++) {
      feeCollectorTokenBalances[i] = IERC20(poolTokens[i]).balanceOf(address(this));
    }

    crp.exitPool(_amount, minTokenOut);

    IERC20 tokenInterface;
    uint256 tokenBalanceToTransfer;
    for (uint256 i=0; i<poolTokens.length; i++) {
      tokenInterface = IERC20(poolTokens[i]);

      tokenBalanceToTransfer = tokenInterface.balanceOf(address(this)).sub( // get the new balance of token
        feeCollectorTokenBalances[i] // subtract previous balance
      );

      if (tokenBalanceToTransfer > 0) {
        tokenInterface.safeTransfer(
          _toAddress,
          tokenBalanceToTransfer
        ); // transfer to `_toAddress`
      }
    }
  }

  function replaceAdmin(address _newAdmin) external override onlyAdmin {

    grantRole(DEFAULT_ADMIN_ROLE, _newAdmin);
    revokeRole(DEFAULT_ADMIN_ROLE, msg.sender); // caller must be admin
  }

  function getSplitAllocation() external view returns (uint256[] memory) { return (allocations); }


  function isAddressWhitelisted(address _address) external view returns (bool) {return (hasRole(WHITELISTED, _address)); }

  function isAddressAdmin(address _address) external view returns (bool) {return (hasRole(DEFAULT_ADMIN_ROLE, _address)); }


  function getBeneficiaries() external view returns (address[] memory) { return (beneficiaries); }

  function getSmartTreasuryAddress() external view returns (address) { return (beneficiaries[0]); }


  function isTokenInDespositList(address _tokenAddress) external view returns (bool) {return (depositTokens.contains(_tokenAddress)); }

  function getNumTokensInDepositList() external view returns (uint256) {return (depositTokens.length());}


  function getDepositTokens() external view returns (address[] memory) {

    uint256 numTokens = depositTokens.length();

    address[] memory depositTokenList = new address[](numTokens);
    for (uint256 index = 0; index < numTokens; index++) {
      depositTokenList[index] = depositTokens.at(index);
    }
    return (depositTokenList);
  }
}