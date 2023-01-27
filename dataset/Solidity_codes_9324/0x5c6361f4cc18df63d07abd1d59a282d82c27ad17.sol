pragma solidity ^0.5.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}pragma solidity ^0.5.0;

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
}pragma solidity ^0.5.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}pragma solidity ^0.5.5;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}pragma solidity ^0.5.0;


library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT
pragma solidity >=0.5.0;

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

}// MIT
pragma solidity >=0.5.0;


interface IUniswapV2Router02 {

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

}pragma solidity 0.5.16;

interface IStrategy {

    
    function unsalvagableTokens(address tokens) external view returns (bool);

    
    function governance() external view returns (address);

    function controller() external view returns (address);

    function underlying() external view returns (address);

    function vault() external view returns (address);


    function withdrawAllToVault() external;

    function withdrawToVault(uint256 amount) external;


    function investedUnderlyingBalance() external view returns (uint256); // itsNotMuch()


    function salvage(address recipient, address token, uint256 amount) external;


    function doHardWork() external;

    function depositArbCheck() external view returns(bool);

}pragma solidity 0.5.16;

interface IVault {


    function initializeVault(
      address _storage,
      address _underlying,
      uint256 _toInvestNumerator,
      uint256 _toInvestDenominator
    ) external ;


    function balanceOf(address) external view returns (uint256);


    function underlyingBalanceInVault() external view returns (uint256);

    function underlyingBalanceWithInvestment() external view returns (uint256);


    function governance() external view returns (address);

    function controller() external view returns (address);

    function underlying() external view returns (address);

    function strategy() external view returns (address);


    function setStrategy(address _strategy) external;

    function announceStrategyUpdate(address _strategy) external;

    function setVaultFractionToInvest(uint256 numerator, uint256 denominator) external;


    function deposit(uint256 amountWei) external;

    function depositFor(uint256 amountWei, address holder) external;


    function withdrawAll() external;

    function withdraw(uint256 numberOfShares) external;

    function getPricePerFullShare() external view returns (uint256);


    function underlyingBalanceWithInvestmentForHolder(address holder) view external returns (uint256);


    function doHardWork() external;

}pragma solidity >=0.4.24 <0.7.0;


contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  function isConstructor() private view returns (bool) {

    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}pragma solidity 0.5.16;


contract BaseUpgradeableStrategyStorage {


  bytes32 internal constant _UNDERLYING_SLOT = 0xa1709211eeccf8f4ad5b6700d52a1a9525b5f5ae1e9e5f9e5a0c2fc23c86e530;
  bytes32 internal constant _VAULT_SLOT = 0xefd7c7d9ef1040fc87e7ad11fe15f86e1d11e1df03c6d7c87f7e1f4041f08d41;

  bytes32 internal constant _REWARD_TOKEN_SLOT = 0xdae0aafd977983cb1e78d8f638900ff361dc3c48c43118ca1dd77d1af3f47bbf;
  bytes32 internal constant _REWARD_POOL_SLOT = 0x3d9bb16e77837e25cada0cf894835418b38e8e18fbec6cfd192eb344bebfa6b8;
  bytes32 internal constant _SELL_FLOOR_SLOT = 0xc403216a7704d160f6a3b5c3b149a1226a6080f0a5dd27b27d9ba9c022fa0afc;
  bytes32 internal constant _SELL_SLOT = 0x656de32df98753b07482576beb0d00a6b949ebf84c066c765f54f26725221bb6;
  bytes32 internal constant _PAUSED_INVESTING_SLOT = 0xa07a20a2d463a602c2b891eb35f244624d9068572811f63d0e094072fb54591a;

  bytes32 internal constant _PROFIT_SHARING_NUMERATOR_SLOT = 0xe3ee74fb7893020b457d8071ed1ef76ace2bf4903abd7b24d3ce312e9c72c029;
  bytes32 internal constant _PROFIT_SHARING_DENOMINATOR_SLOT = 0x0286fd414602b432a8c80a0125e9a25de9bba96da9d5068c832ff73f09208a3b;

  bytes32 internal constant _NEXT_IMPLEMENTATION_SLOT = 0x29f7fcd4fe2517c1963807a1ec27b0e45e67c60a874d5eeac7a0b1ab1bb84447;
  bytes32 internal constant _NEXT_IMPLEMENTATION_TIMESTAMP_SLOT = 0x414c5263b05428f1be1bfa98e25407cc78dd031d0d3cd2a2e3d63b488804f22e;
  bytes32 internal constant _NEXT_IMPLEMENTATION_DELAY_SLOT = 0x82b330ca72bcd6db11a26f10ce47ebcfe574a9c646bccbc6f1cd4478eae16b31;

  bytes32 internal constant _REWARD_CLAIMABLE_SLOT = 0xbc7c0d42a71b75c3129b337a259c346200f901408f273707402da4b51db3b8e7;
  bytes32 internal constant _MULTISIG_SLOT = 0x3e9de78b54c338efbc04e3a091b87dc7efb5d7024738302c548fc59fba1c34e6;

  constructor() public {
    assert(_UNDERLYING_SLOT == bytes32(uint256(keccak256("eip1967.strategyStorage.underlying")) - 1));
    assert(_VAULT_SLOT == bytes32(uint256(keccak256("eip1967.strategyStorage.vault")) - 1));
    assert(_REWARD_TOKEN_SLOT == bytes32(uint256(keccak256("eip1967.strategyStorage.rewardToken")) - 1));
    assert(_REWARD_POOL_SLOT == bytes32(uint256(keccak256("eip1967.strategyStorage.rewardPool")) - 1));
    assert(_SELL_FLOOR_SLOT == bytes32(uint256(keccak256("eip1967.strategyStorage.sellFloor")) - 1));
    assert(_SELL_SLOT == bytes32(uint256(keccak256("eip1967.strategyStorage.sell")) - 1));
    assert(_PAUSED_INVESTING_SLOT == bytes32(uint256(keccak256("eip1967.strategyStorage.pausedInvesting")) - 1));

    assert(_PROFIT_SHARING_NUMERATOR_SLOT == bytes32(uint256(keccak256("eip1967.strategyStorage.profitSharingNumerator")) - 1));
    assert(_PROFIT_SHARING_DENOMINATOR_SLOT == bytes32(uint256(keccak256("eip1967.strategyStorage.profitSharingDenominator")) - 1));

    assert(_NEXT_IMPLEMENTATION_SLOT == bytes32(uint256(keccak256("eip1967.strategyStorage.nextImplementation")) - 1));
    assert(_NEXT_IMPLEMENTATION_TIMESTAMP_SLOT == bytes32(uint256(keccak256("eip1967.strategyStorage.nextImplementationTimestamp")) - 1));
    assert(_NEXT_IMPLEMENTATION_DELAY_SLOT == bytes32(uint256(keccak256("eip1967.strategyStorage.nextImplementationDelay")) - 1));

    assert(_REWARD_CLAIMABLE_SLOT == bytes32(uint256(keccak256("eip1967.strategyStorage.rewardClaimable")) - 1));
    assert(_MULTISIG_SLOT == bytes32(uint256(keccak256("eip1967.strategyStorage.multiSig")) - 1));
  }

  function _setUnderlying(address _address) internal {

    setAddress(_UNDERLYING_SLOT, _address);
  }

  function underlying() public view returns (address) {

    return getAddress(_UNDERLYING_SLOT);
  }

  function _setRewardPool(address _address) internal {

    setAddress(_REWARD_POOL_SLOT, _address);
  }

  function rewardPool() public view returns (address) {

    return getAddress(_REWARD_POOL_SLOT);
  }

  function _setRewardToken(address _address) internal {

    setAddress(_REWARD_TOKEN_SLOT, _address);
  }

  function rewardToken() public view returns (address) {

    return getAddress(_REWARD_TOKEN_SLOT);
  }

  function _setVault(address _address) internal {

    setAddress(_VAULT_SLOT, _address);
  }

  function vault() public view returns (address) {

    return getAddress(_VAULT_SLOT);
  }

  function _setSell(bool _value) internal {

    setBoolean(_SELL_SLOT, _value);
  }

  function sell() public view returns (bool) {

    return getBoolean(_SELL_SLOT);
  }

  function _setPausedInvesting(bool _value) internal {

    setBoolean(_PAUSED_INVESTING_SLOT, _value);
  }

  function pausedInvesting() public view returns (bool) {

    return getBoolean(_PAUSED_INVESTING_SLOT);
  }

  function _setSellFloor(uint256 _value) internal {

    setUint256(_SELL_FLOOR_SLOT, _value);
  }

  function sellFloor() public view returns (uint256) {

    return getUint256(_SELL_FLOOR_SLOT);
  }

  function _setProfitSharingNumerator(uint256 _value) internal {

    setUint256(_PROFIT_SHARING_NUMERATOR_SLOT, _value);
  }

  function profitSharingNumerator() public view returns (uint256) {

    return getUint256(_PROFIT_SHARING_NUMERATOR_SLOT);
  }

  function _setProfitSharingDenominator(uint256 _value) internal {

    setUint256(_PROFIT_SHARING_DENOMINATOR_SLOT, _value);
  }

  function profitSharingDenominator() public view returns (uint256) {

    return getUint256(_PROFIT_SHARING_DENOMINATOR_SLOT);
  }

  function allowedRewardClaimable() public view returns (bool) {

    return getBoolean(_REWARD_CLAIMABLE_SLOT);
  }

  function _setRewardClaimable(bool _value) internal {

    setBoolean(_REWARD_CLAIMABLE_SLOT, _value);
  }

  function multiSig() public view returns(address) {

    return getAddress(_MULTISIG_SLOT);
  }

  function _setMultiSig(address _address) internal {

    setAddress(_MULTISIG_SLOT, _address);
  }


  function _setNextImplementation(address _address) internal {

    setAddress(_NEXT_IMPLEMENTATION_SLOT, _address);
  }

  function nextImplementation() public view returns (address) {

    return getAddress(_NEXT_IMPLEMENTATION_SLOT);
  }

  function _setNextImplementationTimestamp(uint256 _value) internal {

    setUint256(_NEXT_IMPLEMENTATION_TIMESTAMP_SLOT, _value);
  }

  function nextImplementationTimestamp() public view returns (uint256) {

    return getUint256(_NEXT_IMPLEMENTATION_TIMESTAMP_SLOT);
  }

  function _setNextImplementationDelay(uint256 _value) internal {

    setUint256(_NEXT_IMPLEMENTATION_DELAY_SLOT, _value);
  }

  function nextImplementationDelay() public view returns (uint256) {

    return getUint256(_NEXT_IMPLEMENTATION_DELAY_SLOT);
  }

  function setBoolean(bytes32 slot, bool _value) internal {

    setUint256(slot, _value ? 1 : 0);
  }

  function getBoolean(bytes32 slot) internal view returns (bool) {

    return (getUint256(slot) == 1);
  }

  function setAddress(bytes32 slot, address _address) internal {

    assembly {
      sstore(slot, _address)
    }
  }

  function setUint256(bytes32 slot, uint256 _value) internal {

    assembly {
      sstore(slot, _value)
    }
  }

  function getAddress(bytes32 slot) internal view returns (address str) {

    assembly {
      str := sload(slot)
    }
  }

  function getUint256(bytes32 slot) internal view returns (uint256 str) {

    assembly {
      str := sload(slot)
    }
  }
}pragma solidity 0.5.16;

contract Storage {


  address public governance;
  address public controller;

  constructor() public {
    governance = msg.sender;
  }

  modifier onlyGovernance() {

    require(isGovernance(msg.sender), "Not governance");
    _;
  }

  function setGovernance(address _governance) public onlyGovernance {

    require(_governance != address(0), "new governance shouldn't be empty");
    governance = _governance;
  }

  function setController(address _controller) public onlyGovernance {

    require(_controller != address(0), "new controller shouldn't be empty");
    controller = _controller;
  }

  function isGovernance(address account) public view returns (bool) {

    return account == governance;
  }

  function isController(address account) public view returns (bool) {

    return account == controller;
  }
}pragma solidity 0.5.16;


contract GovernableInit is Initializable {


  bytes32 internal constant _STORAGE_SLOT = 0xa7ec62784904ff31cbcc32d09932a58e7f1e4476e1d041995b37c917990b16dc;

  modifier onlyGovernance() {

    require(Storage(_storage()).isGovernance(msg.sender), "Not governance");
    _;
  }

  constructor() public {
    assert(_STORAGE_SLOT == bytes32(uint256(keccak256("eip1967.governableInit.storage")) - 1));
  }

  function initialize(address _store) public initializer {

    _setStorage(_store);
  }

  function _setStorage(address newStorage) private {

    bytes32 slot = _STORAGE_SLOT;
    assembly {
      sstore(slot, newStorage)
    }
  }

  function setStorage(address _store) public onlyGovernance {

    require(_store != address(0), "new storage shouldn't be empty");
    _setStorage(_store);
  }

  function _storage() internal view returns (address str) {

    bytes32 slot = _STORAGE_SLOT;
    assembly {
      str := sload(slot)
    }
  }

  function governance() public view returns (address) {

    return Storage(_storage()).governance();
  }
}pragma solidity 0.5.16;


contract ControllableInit is GovernableInit {


  constructor() public {
  }

  function initialize(address _storage) public initializer {

    GovernableInit.initialize(_storage);
  }

  modifier onlyController() {

    require(Storage(_storage()).isController(msg.sender), "Not a controller");
    _;
  }

  modifier onlyControllerOrGovernance(){

    require((Storage(_storage()).isController(msg.sender) || Storage(_storage()).isGovernance(msg.sender)),
      "The caller must be controller or governance");
    _;
  }

  function controller() public view returns (address) {

    return Storage(_storage()).controller();
  }
}pragma solidity 0.5.16;

interface IController {


    event SharePriceChangeLog(
      address indexed vault,
      address indexed strategy,
      uint256 oldSharePrice,
      uint256 newSharePrice,
      uint256 timestamp
    );

    function greyList(address _target) external view returns(bool);


    function addVaultAndStrategy(address _vault, address _strategy) external;

    function doHardWork(address _vault) external;


    function salvage(address _token, uint256 amount) external;

    function salvageStrategy(address _strategy, address _token, uint256 amount) external;


    function notifyFee(address _underlying, uint256 fee) external;

    function profitSharingNumerator() external view returns (uint256);

    function profitSharingDenominator() external view returns (uint256);


    function feeRewardForwarder() external view returns(address);

    function setFeeRewardForwarder(address _value) external;


    function addHardWorker(address _worker) external;

}pragma solidity 0.5.16;

interface IFeeRewardForwarderV6 {

    function poolNotifyFixedTarget(address _token, uint256 _amount) external;


    function notifyFeeAndBuybackAmounts(uint256 _feeAmount, address _pool, uint256 _buybackAmount) external;

    function notifyFeeAndBuybackAmounts(address _token, uint256 _feeAmount, address _pool, uint256 _buybackAmount) external;

    function profitSharingPool() external view returns (address);

    function configureLiquidation(address[] calldata _path, bytes32[] calldata _dexes) external;

}// MIT
pragma solidity 0.5.16;

interface ILiquidator {

  event Swap(
    address indexed buyToken,
    address indexed sellToken,
    address indexed target,
    address initiator,
    uint256 amountIn,
    uint256 slippage,
    uint256 total
  );

  function swapTokenOnMultipleDEXes(
    uint256 amountIn,
    uint256 amountOutMin,
    address target,
    bytes32[] calldata dexes,
    address[] calldata path
  ) external;


  function swapTokenOnDEX(
    uint256 amountIn,
    uint256 amountOutMin,
    address target,
    bytes32 dexName,
    address[] calldata path
  ) external;


  function getAllDexes() external view returns (bytes32[] memory);

}// MIT
pragma solidity 0.5.16;

interface ILiquidatorRegistry {


  function universalLiquidator() external view returns(address);


  function setUniversalLiquidator(address _ul) external;


  function getPath(
    bytes32 dex,
    address inputToken,
    address outputToken
  ) external view returns(address[] memory);


  function setPath(
    bytes32 dex,
    address inputToken,
    address outputToken,
    address[] calldata path
  ) external;

}pragma solidity 0.5.16;


contract BaseUpgradeableStrategyUL is Initializable, ControllableInit, BaseUpgradeableStrategyStorage {

  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  bytes32 internal constant _UL_REGISTRY_SLOT = 0x7a4b558e8ed4a66729f4a918db093413f0f1ae77c0de7c88bea8b99e084b2a17;
  bytes32 internal constant _UL_SLOT = 0xebfe408f65547b28326a79acf512c0f9a2bf4211ece39254d7c3ec96dd3dd242;

  mapping(address => mapping(address => address[])) public storedLiquidationPaths;
  mapping(address => mapping(address => bytes32[])) public storedLiquidationDexes;

  event ProfitsNotCollected(bool sell, bool floor);
  event ProfitLogInReward(uint256 profitAmount, uint256 feeAmount, uint256 timestamp);
  event ProfitAndBuybackLog(uint256 profitAmount, uint256 feeAmount, uint256 timestamp);

  modifier restricted() {

    require(msg.sender == vault() || msg.sender == controller()
      || msg.sender == governance(),
      "The sender has to be the controller, governance, or vault");
    _;
  }

  modifier onlyNotPausedInvesting() {

    require(!pausedInvesting(), "Action blocked as the strategy is in emergency state");
    _;
  }

  constructor() public BaseUpgradeableStrategyStorage() {
    assert(_UL_REGISTRY_SLOT == bytes32(uint256(keccak256("eip1967.strategyStorage.ULRegistry")) - 1));
    assert(_UL_SLOT == bytes32(uint256(keccak256("eip1967.strategyStorage.UL")) - 1));
  }

  function initialize(
    address _storage,
    address _underlying,
    address _vault,
    address _rewardPool,
    address _rewardToken,
    uint256 _profitSharingNumerator,
    uint256 _profitSharingDenominator,
    bool _sell,
    uint256 _sellFloor,
    uint256 _implementationChangeDelay,
    address _universalLiquidatorRegistry
  ) public initializer {

    ControllableInit.initialize(
      _storage
    );
    _setUnderlying(_underlying);
    _setVault(_vault);
    _setRewardPool(_rewardPool);
    _setRewardToken(_rewardToken);
    _setProfitSharingNumerator(_profitSharingNumerator);
    _setProfitSharingDenominator(_profitSharingDenominator);

    _setSell(_sell);
    _setSellFloor(_sellFloor);
    _setNextImplementationDelay(_implementationChangeDelay);
    _setPausedInvesting(false);
    _setUniversalLiquidatorRegistry(_universalLiquidatorRegistry);
    _setUniversalLiquidator(ILiquidatorRegistry(universalLiquidatorRegistry()).universalLiquidator());
  }

  function scheduleUpgrade(address impl) public onlyGovernance {

    _setNextImplementation(impl);
    _setNextImplementationTimestamp(block.timestamp.add(nextImplementationDelay()));
  }

  function _finalizeUpgrade() internal {

    _setNextImplementation(address(0));
    _setNextImplementationTimestamp(0);
  }

  function shouldUpgrade() external view returns (bool, address) {

    return (
      nextImplementationTimestamp() != 0
        && block.timestamp > nextImplementationTimestamp()
        && nextImplementation() != address(0),
      nextImplementation()
    );
  }


  function notifyProfitInRewardToken(uint256 _rewardBalance) internal {

    if( _rewardBalance > 0 ){
      uint256 feeAmount = _rewardBalance.mul(profitSharingNumerator()).div(profitSharingDenominator());
      emit ProfitLogInReward(_rewardBalance, feeAmount, block.timestamp);
      IERC20(rewardToken()).safeApprove(controller(), 0);
      IERC20(rewardToken()).safeApprove(controller(), feeAmount);

      IController(controller()).notifyFee(
        rewardToken(),
        feeAmount
      );
    } else {
      emit ProfitLogInReward(0, 0, block.timestamp);
    }
  }

  function notifyProfitAndBuybackInRewardToken(uint256 _rewardBalance, address pool, uint256 _buybackRatio) internal {

    if( _rewardBalance > 0 ){
      uint256 feeAmount = _rewardBalance.mul(profitSharingNumerator()).div(profitSharingDenominator());
      uint256 buybackAmount = _rewardBalance.sub(feeAmount).mul(_buybackRatio).div(10000);

      address forwarder = IController(controller()).feeRewardForwarder();
      emit ProfitAndBuybackLog(_rewardBalance, feeAmount, block.timestamp);

      IERC20(rewardToken()).safeApprove(forwarder, 0);
      IERC20(rewardToken()).safeApprove(forwarder, _rewardBalance);

      IFeeRewardForwarderV6(forwarder).notifyFeeAndBuybackAmounts(
        rewardToken(),
        feeAmount,
        pool,
        buybackAmount
      );
    } else {
      emit ProfitAndBuybackLog(0, 0, block.timestamp);
    }
  }

  function _setUniversalLiquidatorRegistry(address _address) internal {

    setAddress(_UL_REGISTRY_SLOT, _address);
  }

  function universalLiquidatorRegistry() public view returns (address) {

    return getAddress(_UL_REGISTRY_SLOT);
  }

  function _setUniversalLiquidator(address _address) internal {

    setAddress(_UL_SLOT, _address);
  }

  function universalLiquidator() public view returns (address) {

    return getAddress(_UL_SLOT);
  }

  function configureLiquidation(address[] memory path, bytes32[] memory dexes) public onlyGovernance {

    address fromToken = path[0];
    address toToken = path[path.length - 1];

    require(dexes.length == path.length - 1, "lengths do not match");

    storedLiquidationPaths[fromToken][toToken] = path;
    storedLiquidationDexes[fromToken][toToken] = dexes;
  }
}// MIT


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

}pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;


interface IAsset {

}

interface IBVault {


    function getInternalBalance(address user, IERC20[] calldata tokens) external view returns (uint256[] memory);


    function manageUserBalance(UserBalanceOp[] calldata ops) external payable;


    struct UserBalanceOp {
        UserBalanceOpKind kind;
        IAsset asset;
        uint256 amount;
        address sender;
        address payable recipient;
    }


    enum UserBalanceOpKind { DEPOSIT_INTERNAL, WITHDRAW_INTERNAL, TRANSFER_INTERNAL, TRANSFER_EXTERNAL }

    event InternalBalanceChanged(address indexed user, IERC20 indexed token, int256 delta);

    event ExternalBalanceTransfer(IERC20 indexed token, address indexed sender, address recipient, uint256 amount);


    enum PoolSpecialization { GENERAL, MINIMAL_SWAP_INFO, TWO_TOKEN }

    function registerPool(PoolSpecialization specialization) external returns (bytes32);


    event PoolRegistered(bytes32 indexed poolId, address indexed poolAddress, PoolSpecialization specialization);

    function getPool(bytes32 poolId) external view returns (address, PoolSpecialization);


    function registerTokens(
        bytes32 poolId,
        IERC20[] calldata tokens,
        address[] calldata assetManagers
    ) external;


    event TokensRegistered(bytes32 indexed poolId, IERC20[] tokens, address[] assetManagers);

    function deregisterTokens(bytes32 poolId, IERC20[] calldata tokens) external;


    event TokensDeregistered(bytes32 indexed poolId, IERC20[] tokens);

    function getPoolTokenInfo(bytes32 poolId, IERC20 token)
        external
        view
        returns (
            uint256 cash,
            uint256 managed,
            uint256 lastChangeBlock,
            address assetManager
        );


    function getPoolTokens(bytes32 poolId)
        external
        view
        returns (
            IERC20[] memory tokens,
            uint256[] memory balances,
            uint256 lastChangeBlock
        );


    function joinPool(
        bytes32 poolId,
        address sender,
        address recipient,
        JoinPoolRequest calldata request
    ) external payable;


    enum JoinKind { INIT, EXACT_TOKENS_IN_FOR_BPT_OUT, TOKEN_IN_FOR_EXACT_BPT_OUT }
    enum ExitKind { EXACT_BPT_IN_FOR_ONE_TOKEN_OUT, EXACT_BPT_IN_FOR_TOKENS_OUT, BPT_IN_FOR_EXACT_TOKENS_OUT }

    struct JoinPoolRequest {
        IAsset[] assets;
        uint256[] maxAmountsIn;
        bytes userData;
        bool fromInternalBalance;
    }

    function exitPool(
        bytes32 poolId,
        address sender,
        address payable recipient,
        ExitPoolRequest calldata request
    ) external;


    struct ExitPoolRequest {
        IAsset[] assets;
        uint256[] minAmountsOut;
        bytes userData;
        bool toInternalBalance;
    }

    event PoolBalanceChanged(
        bytes32 indexed poolId,
        address indexed liquidityProvider,
        IERC20[] tokens,
        int256[] deltas,
        uint256[] protocolFeeAmounts
    );

    enum PoolBalanceChangeKind { JOIN, EXIT }


    enum SwapKind { GIVEN_IN, GIVEN_OUT }

    function swap(
        SingleSwap calldata singleSwap,
        FundManagement calldata funds,
        uint256 limit,
        uint256 deadline
    ) external payable returns (uint256);


    struct SingleSwap {
        bytes32 poolId;
        SwapKind kind;
        IAsset assetIn;
        IAsset assetOut;
        uint256 amount;
        bytes userData;
    }

    function batchSwap(
        SwapKind kind,
        BatchSwapStep[] calldata swaps,
        IAsset[] calldata assets,
        FundManagement calldata funds,
        int256[] calldata limits,
        uint256 deadline
    ) external payable returns (int256[] memory);


    struct BatchSwapStep {
        bytes32 poolId;
        uint256 assetInIndex;
        uint256 assetOutIndex;
        uint256 amount;
        bytes userData;
    }

    event Swap(
        bytes32 indexed poolId,
        IERC20 indexed tokenIn,
        IERC20 indexed tokenOut,
        uint256 amountIn,
        uint256 amountOut
    );

    struct FundManagement {
        address sender;
        bool fromInternalBalance;
        address payable recipient;
        bool toInternalBalance;
    }

    function queryBatchSwap(
        SwapKind kind,
        BatchSwapStep[] calldata swaps,
        IAsset[] calldata assets,
        FundManagement calldata funds
    ) external returns (int256[] memory assetDeltas);

}pragma solidity 0.5.16;


contract BalancerStrategyRatio is IStrategy, BaseUpgradeableStrategyUL {


  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  bytes32 internal constant _POOLID_SLOT = 0x3fd729bfa2e28b7806b03a6e014729f59477b530f995be4d51defc9dad94810b;
  bytes32 internal constant _BVAULT_SLOT = 0x85cbd475ba105ca98d9a2db62dcf7cf3c0074b36303ef64160d68a3e0fdd3c67;
  bytes32 internal constant _POOL_RATIO_SLOT = 0x5035d5d1de514bace8329602f2219cf1405001cc4a9602199da87cd5f4f17032;
  bytes32 internal constant _LIQUIDATION_RATIO_SLOT = 0x88a908c31cfd33a7a64870721e6da89f529116031d2cb9ed0bf1c4ba0873d19f;

  mapping (address => address[]) public swapRoutes;

  constructor() public BaseUpgradeableStrategyUL() {
    assert(_POOLID_SLOT == bytes32(uint256(keccak256("eip1967.strategyStorage.poolId")) - 1));
    assert(_BVAULT_SLOT == bytes32(uint256(keccak256("eip1967.strategyStorage.bVault")) - 1));
    assert(_POOL_RATIO_SLOT == bytes32(uint256(keccak256("eip1967.strategyStorage.poolRatio")) - 1));
    assert(_LIQUIDATION_RATIO_SLOT == bytes32(uint256(keccak256("eip1967.strategyStorage.liquidationRatio")) - 1));
  }

  function initializeStrategy(
    address _storage,
    address _underlying,
    address _vault,
    address _rewardPool,
    address _rewardToken,
    address _bVault,
    bytes32 _poolID,
    uint256 _liquidationRatio,
    uint256 _ratioToken0
  ) public initializer {


    BaseUpgradeableStrategyUL.initialize(
      _storage,
      _underlying,
      _vault,
      _rewardPool,
      _rewardToken,
      300, // profit sharing numerator
      1000, // profit sharing denominator
      true, // sell
      1e18, // sell floor
      12 hours, // implementation change delay
      address(0x7882172921E99d590E097cD600554339fBDBc480) //UL Registry
    );

    (address _lpt,) = IBVault(_bVault).getPool(_poolID);
    require(_lpt == _underlying, "Underlying mismatch");
    require(_ratioToken0 < 1000, "Invalid ratio"); //Ratio base = 1000
    require(_liquidationRatio < 1000, "Invalid ratio"); //Ratio base = 1000

    setLiquidationRatio(_liquidationRatio);
    _setPoolRatio(_ratioToken0);
    _setPoolId(_poolID);
    _setBVault(_bVault);
  }

  function depositArbCheck() public view returns(bool) {

    return true;
  }

  function underlyingBalance() internal view returns (uint256 bal) {

      bal = IERC20(underlying()).balanceOf(address(this));
  }

  function unsalvagableTokens(address token) public view returns (bool) {

    return (token == rewardToken() || token == underlying());
  }

  function _liquidateReward(uint256 rewardAmount) internal {

    if (!sell() || rewardAmount < sellFloor()) {
      emit ProfitsNotCollected(sell(), rewardAmount < sellFloor());
      return;
    }

    uint256 rewardBalance = IERC20(rewardToken()).balanceOf(address(this));
    notifyProfitInRewardToken(rewardAmount);
    uint256 remainingRewardBalance = IERC20(rewardToken()).balanceOf(address(this));
    uint256 toLiquidate = rewardAmount.sub(rewardBalance.sub(remainingRewardBalance));

    if (toLiquidate == 0) {
      return;
    }

    IERC20(rewardToken()).safeApprove(universalLiquidator(), 0);
    IERC20(rewardToken()).safeApprove(universalLiquidator(), toLiquidate);

    (IERC20[] memory componentTokens,,) = IBVault(bVault()).getPoolTokens(poolId());
    address lpComponentToken0 = address(componentTokens[0]);
    address lpComponentToken1 = address(componentTokens[1]);

    uint256 toToken0 = toLiquidate.mul(poolRatio()).div(1000);
    uint256 toToken1 = toLiquidate.sub(toToken0);

    uint256 token0Amount;

    if (storedLiquidationDexes[rewardToken()][lpComponentToken0].length > 0) {
      ILiquidator(universalLiquidator()).swapTokenOnMultipleDEXes(
        toToken0,
        1,
        address(this), // target
        storedLiquidationDexes[rewardToken()][lpComponentToken0],
        storedLiquidationPaths[rewardToken()][lpComponentToken0]
      );
      token0Amount = IERC20(lpComponentToken0).balanceOf(address(this));
    } else {
      token0Amount = toToken0;
    }

    uint256 token1Amount;

    if (storedLiquidationDexes[rewardToken()][lpComponentToken1].length > 0) {
      ILiquidator(universalLiquidator()).swapTokenOnMultipleDEXes(
        toToken1,
        1,
        address(this), // target
        storedLiquidationDexes[rewardToken()][lpComponentToken1],
        storedLiquidationPaths[rewardToken()][lpComponentToken1]
      );
      token1Amount = IERC20(lpComponentToken1).balanceOf(address(this));
    } else {
      token1Amount = toToken1;
    }

    IERC20(lpComponentToken0).safeApprove(bVault(), 0);
    IERC20(lpComponentToken0).safeApprove(bVault(), token0Amount);

    IERC20(lpComponentToken1).safeApprove(bVault(), 0);
    IERC20(lpComponentToken1).safeApprove(bVault(), token1Amount);

    IAsset[] memory assets = new IAsset[](2);
    assets[0] = IAsset(lpComponentToken0);
    assets[1] = IAsset(lpComponentToken1);

    IBVault.JoinKind joinKind = IBVault.JoinKind.EXACT_TOKENS_IN_FOR_BPT_OUT;
    uint256[] memory amountsIn = new uint256[](2);
    amountsIn[0] = token0Amount;
    amountsIn[1] = token1Amount;
    uint256 minAmountOut = 1;

    bytes memory userData = abi.encode(joinKind, amountsIn, minAmountOut);

    IBVault.JoinPoolRequest memory request;
    request.assets = assets;
    request.maxAmountsIn = amountsIn;
    request.userData = userData;
    request.fromInternalBalance = false;

    IBVault(bVault()).joinPool(
      poolId(),
      address(this),
      address(this),
      request
      );
  }

  function withdrawAllToVault() public restricted {

    uint256 rewardBalance = IERC20(rewardToken()).balanceOf(address(this));
    _liquidateReward(rewardBalance);
    IERC20(underlying()).safeTransfer(vault(), IERC20(underlying()).balanceOf(address(this)));
  }

  function withdrawToVault(uint256 amount) public restricted {

    uint256 entireBalance = IERC20(underlying()).balanceOf(address(this));

    if (amount >= entireBalance){
      withdrawAllToVault();
    } else {
      IERC20(underlying()).safeTransfer(vault(), amount);
    }
  }

  function investedUnderlyingBalance() external view returns (uint256) {

    return underlyingBalance();
  }

  function salvage(address recipient, address token, uint256 amount) external onlyControllerOrGovernance {

    require(!unsalvagableTokens(token), "token is defined as not salvagable");
    IERC20(token).safeTransfer(recipient, amount);
  }

  function doHardWork() external onlyNotPausedInvesting restricted {

    uint256 rewardBalance = IERC20(rewardToken()).balanceOf(address(this));
    _liquidateReward(rewardBalance.mul(liquidationRatio()).div(1000));
  }

  function liquidateAll() external onlyGovernance {

    uint256 rewardBalance = IERC20(rewardToken()).balanceOf(address(this));
    _liquidateReward(rewardBalance);
  }

  function setSell(bool s) public onlyGovernance {

    _setSell(s);
  }

  function setSellFloor(uint256 floor) public onlyGovernance {

    _setSellFloor(floor);
  }

  function _setPoolId(bytes32 _value) internal {

    setBytes32(_POOLID_SLOT, _value);
  }

  function poolId() public view returns (bytes32) {

    return getBytes32(_POOLID_SLOT);
  }

  function _setBVault(address _address) internal {

    setAddress(_BVAULT_SLOT, _address);
  }

  function bVault() public view returns (address) {

    return getAddress(_BVAULT_SLOT);
  }

  function _setPoolRatio(uint256 _ratio) internal {

    setUint256(_POOL_RATIO_SLOT, _ratio);
  }

  function poolRatio() public view returns (uint256) {

    return getUint256(_POOL_RATIO_SLOT);
  }

  function setLiquidationRatio(uint256 _ratio) public onlyGovernance {

    require(_ratio < 1000, "Invalid ratio"); //Ratio base = 1000
    setUint256(_LIQUIDATION_RATIO_SLOT, _ratio);
  }

  function liquidationRatio() public view returns (uint256) {

    return getUint256(_LIQUIDATION_RATIO_SLOT);
  }

  function setBytes32(bytes32 slot, bytes32 _value) internal {

    assembly {
      sstore(slot, _value)
    }
  }

  function getBytes32(bytes32 slot) internal view returns (bytes32 str) {

    assembly {
      str := sload(slot)
    }
  }

  function finalizeUpgrade() external onlyGovernance {

    _finalizeUpgrade();
    (IERC20[] memory componentTokens,,) = IBVault(bVault()).getPoolTokens(poolId());
    address lpComponentToken0 = address(componentTokens[0]);
    address lpComponentToken1 = address(componentTokens[1]);
    storedLiquidationPaths[rewardToken()][lpComponentToken0] = new address[](0);
    storedLiquidationDexes[rewardToken()][lpComponentToken0] = new bytes32[](0);
    storedLiquidationPaths[rewardToken()][lpComponentToken1] = new address[](0);
    storedLiquidationDexes[rewardToken()][lpComponentToken1] = new bytes32[](0);
  }
}pragma solidity 0.5.16;


contract BalancerStrategyMainnet_DAI_WETH is BalancerStrategyRatio {


  address public dai_weth_unused; // just a differentiator for the bytecode

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {

    address underlying = address(0x0b09deA16768f0799065C475bE02919503cB2a35);
    address dai = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    address weth = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address bal = address(0xba100000625a3754423978a60c9317c58a424e3D);
    bytes32 uniDex = 0xde2d1a51640f78257713031680d1f306297d957426e912ab21317b9cc9495a41;
    BalancerStrategyRatio.initializeStrategy(
      _storage,
      underlying,
      _vault,
      address(0x6d19b2bF3A36A61530909Ae65445a906D98A2Fa8), // claiming contract
      bal,
      address(0xBA12222222228d8Ba445958a75a0704d566BF2C8), //balancer vault
      0x0b09dea16768f0799065c475be02919503cb2a3500020000000000000000001a,  // Pool id
      500, //Liquidation ratio, liquidate 50% on doHardWork
      400 //Ratio, token0 = BAL, 40% of pool
    );
    storedLiquidationPaths[bal][dai] = [bal, dai];
    storedLiquidationDexes[bal][dai] = [uniDex];
    storedLiquidationPaths[bal][weth] = [bal, weth];
    storedLiquidationDexes[bal][weth] = [uniDex];
  }
}