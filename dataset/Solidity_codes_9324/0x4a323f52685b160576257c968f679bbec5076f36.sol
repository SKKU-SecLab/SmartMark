


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


pragma solidity 0.6.12;

interface BMathInterface {

  function calcInGivenOut(
    uint256 tokenBalanceIn,
    uint256 tokenWeightIn,
    uint256 tokenBalanceOut,
    uint256 tokenWeightOut,
    uint256 tokenAmountOut,
    uint256 swapFee
  ) external pure returns (uint256 tokenAmountIn);


  function calcSingleInGivenPoolOut(
    uint256 tokenBalanceIn,
    uint256 tokenWeightIn,
    uint256 poolSupply,
    uint256 totalWeight,
    uint256 poolAmountOut,
    uint256 swapFee
  ) external pure returns (uint256 tokenAmountIn);

}


pragma solidity 0.6.12;



interface BPoolInterface is IERC20, BMathInterface {

  function joinPool(uint256 poolAmountOut, uint256[] calldata maxAmountsIn) external;


  function exitPool(uint256 poolAmountIn, uint256[] calldata minAmountsOut) external;


  function swapExactAmountIn(
    address,
    uint256,
    address,
    uint256,
    uint256
  ) external returns (uint256, uint256);


  function swapExactAmountOut(
    address,
    uint256,
    address,
    uint256,
    uint256
  ) external returns (uint256, uint256);


  function joinswapExternAmountIn(
    address,
    uint256,
    uint256
  ) external returns (uint256);


  function joinswapPoolAmountOut(
    address,
    uint256,
    uint256
  ) external returns (uint256);


  function exitswapPoolAmountIn(
    address,
    uint256,
    uint256
  ) external returns (uint256);


  function exitswapExternAmountOut(
    address,
    uint256,
    uint256
  ) external returns (uint256);


  function getDenormalizedWeight(address) external view returns (uint256);


  function getBalance(address) external view returns (uint256);


  function getSwapFee() external view returns (uint256);


  function getTotalDenormalizedWeight() external view returns (uint256);


  function getCommunityFee()
    external
    view
    returns (
      uint256,
      uint256,
      uint256,
      address
    );


  function calcAmountWithCommunityFee(
    uint256,
    uint256,
    address
  ) external view returns (uint256, uint256);


  function getRestrictions() external view returns (address);


  function isPublicSwap() external view returns (bool);


  function isFinalized() external view returns (bool);


  function isBound(address t) external view returns (bool);


  function getCurrentTokens() external view returns (address[] memory tokens);


  function getFinalTokens() external view returns (address[] memory tokens);


  function setSwapFee(uint256) external;


  function setCommunityFeeAndReceiver(
    uint256,
    uint256,
    uint256,
    address
  ) external;


  function setController(address) external;


  function setPublicSwap(bool) external;


  function finalize() external;


  function bind(
    address,
    uint256,
    uint256
  ) external;


  function rebind(
    address,
    uint256,
    uint256
  ) external;


  function unbind(address) external;


  function gulp(address) external;


  function callVoting(
    address voting,
    bytes4 signature,
    bytes calldata args,
    uint256 value
  ) external;


  function getMinWeight() external view returns (uint256);


  function getMaxBoundTokens() external view returns (uint256);

}


pragma solidity 0.6.12;

interface PowerIndexWrapperInterface {

  function getFinalTokens() external view returns (address[] memory tokens);


  function getCurrentTokens() external view returns (address[] memory tokens);


  function getBalance(address _token) external view returns (uint256);


  function setPiTokenForUnderlyingsMultiple(address[] calldata _underlyingTokens, address[] calldata _piTokens)
    external;


  function setPiTokenForUnderlying(address _underlyingTokens, address _piToken) external;


  function updatePiTokenEthFees(address[] calldata _underlyingTokens) external;


  function withdrawOddEthFee(address payable _recipient) external;


  function calcEthFeeForTokens(address[] memory tokens) external view returns (uint256 feeSum);


  function joinPool(uint256 poolAmountOut, uint256[] calldata maxAmountsIn) external payable;


  function exitPool(uint256 poolAmountIn, uint256[] calldata minAmountsOut) external payable;


  function swapExactAmountIn(
    address,
    uint256,
    address,
    uint256,
    uint256
  ) external payable returns (uint256, uint256);


  function swapExactAmountOut(
    address,
    uint256,
    address,
    uint256,
    uint256
  ) external payable returns (uint256, uint256);


  function joinswapExternAmountIn(
    address,
    uint256,
    uint256
  ) external payable returns (uint256);


  function joinswapPoolAmountOut(
    address,
    uint256,
    uint256
  ) external payable returns (uint256);


  function exitswapPoolAmountIn(
    address,
    uint256,
    uint256
  ) external payable returns (uint256);


  function exitswapExternAmountOut(
    address,
    uint256,
    uint256
  ) external payable returns (uint256);

}


pragma solidity 0.6.12;


interface TokenInterface is IERC20 {

  function deposit() external payable;


  function withdraw(uint256) external;

}


pragma solidity 0.6.12;

interface IPoolRestrictions {

  function getMaxTotalSupply(address _pool) external view returns (uint256);


  function isVotingSignatureAllowed(address _votingAddress, bytes4 _signature) external view returns (bool);


  function isVotingSenderAllowed(address _votingAddress, address _sender) external view returns (bool);


  function isWithoutFee(address _addr) external view returns (bool);

}


pragma solidity >=0.5.0;

interface IUniswapV2Pair {

  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value);

  function name() external pure returns (string memory);


  function symbol() external pure returns (string memory);


  function decimals() external pure returns (uint8);


  function totalSupply() external view returns (uint256);


  function balanceOf(address owner) external view returns (uint256);


  function allowance(address owner, address spender) external view returns (uint256);


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
  event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
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


  function burn(address to) external returns (uint256 amount0, uint256 amount1);


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


pragma solidity >=0.5.0;

interface IUniswapV2Factory {

  event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

  function feeTo() external view returns (address);


  function feeToSetter() external view returns (address);


  function migrator() external view returns (address);


  function getPair(address tokenA, address tokenB) external view returns (address pair);


  function allPairs(uint256) external view returns (address pair);


  function allPairsLength() external view returns (uint256);


  function createPair(address tokenA, address tokenB) external returns (address pair);


  function setFeeTo(address) external;


  function setFeeToSetter(address) external;


  function setMigrator(address) external;

}


pragma solidity =0.6.12;


library SafeMathUniswap {

    function add(uint x, uint y) internal pure returns (uint z) {

        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {

        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {

        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
}


pragma solidity >=0.5.0;




library UniswapV2Library {

    using SafeMathUniswap for uint;

    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {

        require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
    }

    function pairFor(address factory, address tokenA, address tokenB) internal view returns (address pair) {

        return IUniswapV2Factory(factory).getPair(tokenA, tokenB);
    }

    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {

        (address token0,) = sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IUniswapV2Pair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {

        require(amountA > 0, 'UniswapV2Library: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {

        require(amountIn > 0, 'UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(997);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {

        require(amountOut > 0, 'UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(1000);
        uint denominator = reserveOut.sub(amountOut).mul(997);
        amountIn = (numerator / denominator).add(1);
    }

    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {

        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {

        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}


pragma solidity 0.6.12;

contract EthPiptSwap is Ownable {

  using SafeMath for uint256;
  using SafeERC20 for IERC20;
  using SafeERC20 for TokenInterface;
  using SafeERC20 for BPoolInterface;

  TokenInterface public weth;
  TokenInterface public cvp;
  BPoolInterface public pipt;
  PowerIndexWrapperInterface public piptWrapper;

  uint256[] public feeLevels;
  uint256[] public feeAmounts;
  address public feePayout;
  address public feeManager;

  mapping(address => address) public uniswapEthPairByTokenAddress;
  mapping(address => address) public uniswapEthPairToken0;
  mapping(address => bool) public reApproveTokens;
  uint256 public defaultSlippage;

  struct CalculationStruct {
    uint256 tokenAmount;
    uint256 ethAmount;
    uint256 tokenReserve;
    uint256 ethReserve;
  }

  event SetTokenSetting(address indexed token, bool indexed reApprove, address indexed uniswapPair);
  event SetDefaultSlippage(uint256 newDefaultSlippage);
  event SetPiptWrapper(address _piptWrapper);
  event SetFees(
    address indexed sender,
    uint256[] newFeeLevels,
    uint256[] newFeeAmounts,
    address indexed feePayout,
    address indexed feeManager
  );

  event EthToPiptSwap(
    address indexed user,
    uint256 ethInAmount,
    uint256 ethSwapFee,
    uint256 poolOutAmount,
    uint256 poolCommunityFee
  );
  event OddEth(address indexed user, uint256 amount);
  event PiptToEthSwap(
    address indexed user,
    uint256 poolInAmount,
    uint256 poolCommunityFee,
    uint256 ethOutAmount,
    uint256 ethSwapFee
  );
  event PayoutCVP(address indexed receiver, uint256 wethAmount, uint256 cvpAmount);

  constructor(
    address _weth,
    address _cvp,
    address _pipt,
    address _piptWrapper,
    address _feeManager
  ) public Ownable() {
    weth = TokenInterface(_weth);
    cvp = TokenInterface(_cvp);
    pipt = BPoolInterface(_pipt);
    piptWrapper = PowerIndexWrapperInterface(_piptWrapper);
    feeManager = _feeManager;
    defaultSlippage = 0.02 ether;
  }

  modifier onlyFeeManagerOrOwner() {

    require(msg.sender == feeManager || msg.sender == owner(), "NOT_FEE_MANAGER");
    _;
  }

  receive() external payable {
    if (msg.sender != tx.origin) {
      return;
    }
    swapEthToPipt(defaultSlippage);
  }

  function swapEthToPipt(uint256 _slippage) public payable returns (uint256 poolAmountOutAfterFee, uint256 oddEth) {

    address[] memory tokens = getPiptTokens();

    uint256 wrapperFee = getWrapFee(tokens);
    (, uint256 swapAmount) = calcEthFee(msg.value, wrapperFee);

    (, , uint256 poolAmountOut) = calcSwapEthToPiptInputs(swapAmount, tokens, _slippage);

    weth.deposit{ value: msg.value }();

    return _swapWethToPiptByPoolOut(msg.value, poolAmountOut, tokens, wrapperFee);
  }

  function swapEthToPiptByPoolOut(uint256 _poolAmountOut)
    external
    payable
    returns (uint256 poolAmountOutAfterFee, uint256 oddEth)
  {

    weth.deposit{ value: msg.value }();

    address[] memory tokens = getPiptTokens();
    return _swapWethToPiptByPoolOut(msg.value, _poolAmountOut, tokens, getWrapFee(tokens));
  }

  function swapPiptToEth(uint256 _poolAmountIn) external payable returns (uint256 ethOutAmount) {

    ethOutAmount = _swapPiptToWeth(_poolAmountIn);

    weth.withdraw(ethOutAmount);
    msg.sender.transfer(ethOutAmount);
  }

  function convertOddToCvpAndSendToPayout(address[] memory oddTokens) external {

    require(msg.sender == tx.origin && !Address.isContract(msg.sender), "CONTRACT_NOT_ALLOWED");

    uint256 len = oddTokens.length;

    for (uint256 i = 0; i < len; i++) {
      _swapTokenForWethOut(oddTokens[i], TokenInterface(oddTokens[i]).balanceOf(address(this)));
    }

    uint256 wethBalance = weth.balanceOf(address(this));
    uint256 cvpOut = _swapWethForTokenOut(address(cvp), wethBalance);

    cvp.safeTransfer(feePayout, cvpOut);

    emit PayoutCVP(feePayout, wethBalance, cvpOut);
  }

  function setFees(
    uint256[] calldata _feeLevels,
    uint256[] calldata _feeAmounts,
    address _feePayout,
    address _feeManager
  ) external onlyFeeManagerOrOwner {

    feeLevels = _feeLevels;
    feeAmounts = _feeAmounts;
    feePayout = _feePayout;
    feeManager = _feeManager;

    emit SetFees(msg.sender, _feeLevels, _feeAmounts, _feePayout, _feeManager);
  }

  function setTokensSettings(
    address[] memory _tokens,
    address[] memory _pairs,
    bool[] memory _reapprove
  ) external onlyOwner {

    uint256 len = _tokens.length;
    require(len == _pairs.length && len == _reapprove.length, "LENGTHS_NOT_EQUAL");
    for (uint256 i = 0; i < len; i++) {
      _setUniswapSettingAndPrepareToken(_tokens[i], _pairs[i]);
      reApproveTokens[_tokens[i]] = _reapprove[i];
      emit SetTokenSetting(_tokens[i], _reapprove[i], _pairs[i]);
    }
  }

  function fetchUnswapPairsFromFactory(address _factory, address[] calldata _tokens) external onlyOwner {

    uint256 len = _tokens.length;
    for (uint256 i = 0; i < len; i++) {
      _setUniswapSettingAndPrepareToken(_tokens[i], IUniswapV2Factory(_factory).getPair(_tokens[i], address(weth)));
    }
  }

  function setDefaultSlippage(uint256 _defaultSlippage) external onlyOwner {

    defaultSlippage = _defaultSlippage;
    emit SetDefaultSlippage(_defaultSlippage);
  }

  function setPiptWrapper(address _piptWrapper) external onlyOwner {

    piptWrapper = PowerIndexWrapperInterface(_piptWrapper);
    emit SetPiptWrapper(_piptWrapper);
  }

  function calcSwapEthToPiptInputs(
    uint256 _ethValue,
    address[] memory _tokens,
    uint256 _slippage
  )
    public
    view
    returns (
      uint256[] memory tokensInPipt,
      uint256[] memory ethInUniswap,
      uint256 poolOut
    )
  {

    _ethValue = _ethValue.sub(_ethValue.mul(_slippage).div(1 ether));

    CalculationStruct[] memory calculations = new CalculationStruct[](_tokens.length);

    uint256 totalEthRequired = 0;
    {
      uint256 piptTotalSupply = pipt.totalSupply();
      uint256 poolRatio =
        piptTotalSupply.mul(1 ether).div(getPiptTokenBalance(_tokens[0])).mul(1 ether).div(piptTotalSupply);

      for (uint256 i = 0; i < _tokens.length; i++) {
        calculations[i].tokenAmount = poolRatio.mul(getPiptTokenBalance(_tokens[i])).div(1 ether);
        calculations[i].ethAmount = getAmountInForUniswapValue(
          _uniswapPairFor(_tokens[i]),
          calculations[i].tokenAmount,
          true
        );
        totalEthRequired = totalEthRequired.add(calculations[i].ethAmount);
      }
    }

    tokensInPipt = new uint256[](_tokens.length);
    ethInUniswap = new uint256[](_tokens.length);
    for (uint256 i = 0; i < _tokens.length; i++) {
      ethInUniswap[i] = _ethValue.mul(calculations[i].ethAmount.mul(1 ether).div(totalEthRequired)).div(1 ether);
      tokensInPipt[i] = calculations[i].tokenAmount.mul(_ethValue.mul(1 ether).div(totalEthRequired)).div(1 ether);
    }

    poolOut = pipt.totalSupply().mul(tokensInPipt[0]).div(getPiptTokenBalance(_tokens[0]));
  }

  function calcSwapPiptToEthInputs(uint256 _poolAmountIn, address[] memory _tokens)
    public
    view
    returns (
      uint256[] memory tokensOutPipt,
      uint256[] memory ethOutUniswap,
      uint256 totalEthOut,
      uint256 poolAmountFee
    )
  {

    tokensOutPipt = new uint256[](_tokens.length);
    ethOutUniswap = new uint256[](_tokens.length);

    (, , uint256 communityExitFee, ) = pipt.getCommunityFee();

    uint256 poolAmountInAfterFee;
    (poolAmountInAfterFee, poolAmountFee) = pipt.calcAmountWithCommunityFee(
      _poolAmountIn,
      communityExitFee,
      address(this)
    );

    uint256 poolRatio = poolAmountInAfterFee.mul(1 ether).div(pipt.totalSupply());

    totalEthOut = 0;
    for (uint256 i = 0; i < _tokens.length; i++) {
      tokensOutPipt[i] = poolRatio.mul(getPiptTokenBalance(_tokens[i])).div(1 ether);
      ethOutUniswap[i] = getAmountOutForUniswapValue(_uniswapPairFor(_tokens[i]), tokensOutPipt[i], true);
      totalEthOut = totalEthOut.add(ethOutUniswap[i]);
    }
  }

  function calcNeedEthToPoolOut(uint256 _poolAmountOut, uint256 _slippage) public view returns (uint256) {

    uint256 ratio = _poolAmountOut.mul(1 ether).div(pipt.totalSupply()).add(100);

    address[] memory tokens = getPiptTokens();
    uint256 len = tokens.length;

    CalculationStruct[] memory calculations = new CalculationStruct[](len);
    uint256[] memory tokensInPipt = new uint256[](len);

    uint256 totalEthSwap = 0;
    for (uint256 i = 0; i < len; i++) {
      tokensInPipt[i] = ratio.mul(getPiptTokenBalance(tokens[i])).div(1 ether);
      totalEthSwap = getAmountInForUniswapValue(_uniswapPairFor(tokens[i]), tokensInPipt[i], true).add(totalEthSwap);
    }
    return totalEthSwap.add(totalEthSwap.mul(_slippage).div(1 ether));
  }

  function calcEthFee(uint256 ethAmount, uint256 wrapperFee) public view returns (uint256 ethFee, uint256 ethAfterFee) {

    uint256 len = feeLevels.length;
    for (uint256 i = 0; i < len; i++) {
      if (ethAmount >= feeLevels[i]) {
        ethFee = ethAmount.mul(feeAmounts[i]).div(1 ether);
        break;
      }
    }
    ethFee = ethFee.add(wrapperFee);
    ethAfterFee = ethAmount.sub(ethFee);
  }

  function calcEthFee(uint256 ethAmount) external view returns (uint256 ethFee, uint256 ethAfterFee) {

    (ethFee, ethAfterFee) = calcEthFee(ethAmount, getWrapFee(getPiptTokens()));
  }

  function getFeeLevels() external view returns (uint256[] memory) {

    return feeLevels;
  }

  function getFeeAmounts() external view returns (uint256[] memory) {

    return feeAmounts;
  }

  function getWrapFee(address[] memory tokens) public view returns (uint256 wrapperFee) {

    if (address(piptWrapper) != address(0)) {
      wrapperFee = piptWrapper.calcEthFeeForTokens(tokens);
    }
  }

  function getPiptTokens() public view returns (address[] memory) {

    return address(piptWrapper) == address(0) ? pipt.getCurrentTokens() : piptWrapper.getCurrentTokens();
  }

  function getPiptTokenBalance(address _token) public view returns (uint256) {

    return address(piptWrapper) == address(0) ? pipt.getBalance(_token) : piptWrapper.getBalance(_token);
  }

  function getAmountInForUniswap(
    IUniswapV2Pair _tokenPair,
    uint256 _swapAmount,
    bool _isEthIn
  ) public view returns (uint256 amountIn, bool isInverse) {

    isInverse = uniswapEthPairToken0[address(_tokenPair)] == address(weth);
    if (_isEthIn ? !isInverse : isInverse) {
      (uint256 ethReserve, uint256 tokenReserve, ) = _tokenPair.getReserves();
      amountIn = UniswapV2Library.getAmountIn(_swapAmount, tokenReserve, ethReserve);
    } else {
      (uint256 tokenReserve, uint256 ethReserve, ) = _tokenPair.getReserves();
      amountIn = UniswapV2Library.getAmountIn(_swapAmount, tokenReserve, ethReserve);
    }
  }

  function getAmountInForUniswapValue(
    IUniswapV2Pair _tokenPair,
    uint256 _swapAmount,
    bool _isEthIn
  ) public view returns (uint256 amountIn) {

    (amountIn, ) = getAmountInForUniswap(_tokenPair, _swapAmount, _isEthIn);
  }

  function getAmountOutForUniswap(
    IUniswapV2Pair _tokenPair,
    uint256 _swapAmount,
    bool _isEthOut
  ) public view returns (uint256 amountOut, bool isInverse) {

    isInverse = uniswapEthPairToken0[address(_tokenPair)] == address(weth);
    if (_isEthOut ? isInverse : !isInverse) {
      (uint256 ethReserve, uint256 tokenReserve, ) = _tokenPair.getReserves();
      amountOut = UniswapV2Library.getAmountOut(_swapAmount, tokenReserve, ethReserve);
    } else {
      (uint256 tokenReserve, uint256 ethReserve, ) = _tokenPair.getReserves();
      amountOut = UniswapV2Library.getAmountOut(_swapAmount, tokenReserve, ethReserve);
    }
  }

  function getAmountOutForUniswapValue(
    IUniswapV2Pair _tokenPair,
    uint256 _swapAmount,
    bool _isEthOut
  ) public view returns (uint256 ethAmount) {

    (ethAmount, ) = getAmountOutForUniswap(_tokenPair, _swapAmount, _isEthOut);
  }

  function _setUniswapSettingAndPrepareToken(address _token, address _pair) internal {

    uniswapEthPairByTokenAddress[_token] = _pair;
    uniswapEthPairToken0[_pair] = IUniswapV2Pair(_pair).token0();
  }

  function _uniswapPairFor(address token) internal view returns (IUniswapV2Pair) {

    return IUniswapV2Pair(uniswapEthPairByTokenAddress[token]);
  }

  function _swapWethToPiptByPoolOut(
    uint256 _wethAmount,
    uint256 _poolAmountOut,
    address[] memory tokens,
    uint256 wrapperFee
  ) internal returns (uint256 poolAmountOutAfterFee, uint256 oddEth) {

    require(_wethAmount > 0, "ETH_REQUIRED");

    {
      address poolRestrictions = pipt.getRestrictions();
      if (address(poolRestrictions) != address(0)) {
        uint256 maxTotalSupply = IPoolRestrictions(poolRestrictions).getMaxTotalSupply(address(pipt));
        require(pipt.totalSupply().add(_poolAmountOut) <= maxTotalSupply, "PIPT_MAX_SUPPLY");
      }
    }

    (uint256 feeAmount, uint256 swapAmount) = calcEthFee(_wethAmount, wrapperFee);
    (uint256[] memory tokensInPipt, uint256 totalEthSwap) = _prepareTokensForJoin(tokens, _poolAmountOut);

    {
      uint256 poolAmountOutFee;
      (, uint256 communityJoinFee, , ) = pipt.getCommunityFee();
      (poolAmountOutAfterFee, poolAmountOutFee) = pipt.calcAmountWithCommunityFee(
        _poolAmountOut,
        communityJoinFee,
        address(this)
      );

      emit EthToPiptSwap(msg.sender, swapAmount, feeAmount, _poolAmountOut, poolAmountOutFee);
    }

    _joinPool(_poolAmountOut, tokensInPipt, wrapperFee);
    totalEthSwap = totalEthSwap.add(wrapperFee);
    pipt.safeTransfer(msg.sender, poolAmountOutAfterFee);

    oddEth = swapAmount.sub(totalEthSwap);
    if (oddEth > 0) {
      weth.withdraw(oddEth);
      msg.sender.transfer(oddEth);
      emit OddEth(msg.sender, oddEth);
    }
  }

  function _prepareTokensForJoin(address[] memory _tokens, uint256 _poolAmountOut)
    internal
    returns (uint256[] memory tokensInPipt, uint256 totalEthSwap)
  {

    uint256 len = _tokens.length;
    tokensInPipt = new uint256[](len);
    uint256 ratio = _poolAmountOut.mul(1 ether).div(pipt.totalSupply()).add(100);
    for (uint256 i = 0; i < len; i++) {
      tokensInPipt[i] = ratio.mul(getPiptTokenBalance(_tokens[i])).div(1 ether);
      totalEthSwap = totalEthSwap.add(_swapWethForTokenIn(_tokens[i], tokensInPipt[i]));

      address approveAddress = address(piptWrapper) == address(0) ? address(pipt) : address(piptWrapper);
      if (reApproveTokens[_tokens[i]]) {
        TokenInterface(_tokens[i]).approve(approveAddress, 0);
      }
      TokenInterface(_tokens[i]).approve(approveAddress, tokensInPipt[i]);
    }
  }

  function _swapPiptToWeth(uint256 _poolAmountIn) internal returns (uint256) {

    address[] memory tokens = getPiptTokens();
    uint256 len = tokens.length;

    (uint256[] memory tokensOutPipt, uint256[] memory ethOutUniswap, uint256 totalEthOut, uint256 poolAmountFee) =
      calcSwapPiptToEthInputs(_poolAmountIn, tokens);

    pipt.safeTransferFrom(msg.sender, address(this), _poolAmountIn);

    uint256 wrapperFee = getWrapFee(tokens);

    (uint256 ethFeeAmount, uint256 ethOutAmount) = calcEthFee(totalEthOut, wrapperFee);

    _exitPool(_poolAmountIn, tokensOutPipt, wrapperFee);

    for (uint256 i = 0; i < len; i++) {
      IUniswapV2Pair tokenPair = _uniswapPairFor(tokens[i]);
      TokenInterface(tokens[i]).safeTransfer(address(tokenPair), tokensOutPipt[i]);
      tokenPair.swap(uint256(0), ethOutUniswap[i], address(this), new bytes(0));
    }

    emit PiptToEthSwap(msg.sender, _poolAmountIn, poolAmountFee, ethOutAmount, ethFeeAmount);

    return ethOutAmount;
  }

  function _joinPool(
    uint256 _poolAmountOut,
    uint256[] memory _maxAmountsIn,
    uint256 _wrapperFee
  ) internal {

    if (address(piptWrapper) == address(0)) {
      pipt.joinPool(_poolAmountOut, _maxAmountsIn);
    } else {
      if (address(this).balance < _wrapperFee) {
        weth.withdraw(_wrapperFee);
      }
      piptWrapper.joinPool{ value: _wrapperFee }(_poolAmountOut, _maxAmountsIn);
    }
  }

  function _exitPool(
    uint256 _poolAmountIn,
    uint256[] memory _minAmountsOut,
    uint256 _wrapperFee
  ) internal {

    pipt.approve(address(piptWrapper) == address(0) ? address(pipt) : address(piptWrapper), _poolAmountIn);

    if (address(piptWrapper) == address(0)) {
      pipt.exitPool(_poolAmountIn, _minAmountsOut);
    } else {
      piptWrapper.exitPool{ value: _wrapperFee }(_poolAmountIn, _minAmountsOut);
    }
  }

  function _swapWethForTokenIn(address _erc20, uint256 _erc20Out) internal returns (uint256 ethIn) {

    IUniswapV2Pair tokenPair = _uniswapPairFor(_erc20);
    bool isInverse;
    (ethIn, isInverse) = getAmountInForUniswap(tokenPair, _erc20Out, true);
    weth.safeTransfer(address(tokenPair), ethIn);
    tokenPair.swap(isInverse ? uint256(0) : _erc20Out, isInverse ? _erc20Out : uint256(0), address(this), new bytes(0));
  }

  function _swapWethForTokenOut(address _erc20, uint256 _ethIn) internal returns (uint256 erc20Out) {

    IUniswapV2Pair tokenPair = _uniswapPairFor(_erc20);
    bool isInverse;
    (erc20Out, isInverse) = getAmountOutForUniswap(tokenPair, _ethIn, false);
    weth.safeTransfer(address(tokenPair), _ethIn);
    tokenPair.swap(isInverse ? uint256(0) : erc20Out, isInverse ? erc20Out : uint256(0), address(this), new bytes(0));
  }

  function _swapTokenForWethOut(address _erc20, uint256 _erc20In) internal returns (uint256 ethOut) {

    IUniswapV2Pair tokenPair = _uniswapPairFor(_erc20);
    bool isInverse;
    (ethOut, isInverse) = getAmountOutForUniswap(tokenPair, _erc20In, true);
    IERC20(_erc20).safeTransfer(address(tokenPair), _erc20In);
    tokenPair.swap(isInverse ? ethOut : uint256(0), isInverse ? uint256(0) : ethOut, address(this), new bytes(0));
  }
}



pragma solidity 0.6.12;


contract Erc20PiptSwap is EthPiptSwap {

  event Erc20ToPiptSwap(
    address indexed user,
    address indexed swapToken,
    uint256 erc20InAmount,
    uint256 ethInAmount,
    uint256 poolOutAmount
  );
  event PiptToErc20Swap(
    address indexed user,
    address indexed swapToken,
    uint256 poolInAmount,
    uint256 ethOutAmount,
    uint256 erc20OutAmount
  );

  constructor(
    address _weth,
    address _cvp,
    address _pipt,
    address _piptWrapper,
    address _feeManager
  ) public EthPiptSwap(_weth, _cvp, _pipt, _piptWrapper, _feeManager) {}

  function swapErc20ToPipt(
    address _swapToken,
    uint256 _swapAmount,
    uint256 _slippage
  ) external payable returns (uint256 poolAmountOut) {

    IERC20(_swapToken).safeTransferFrom(msg.sender, address(this), _swapAmount);

    uint256 ethAmount = _swapTokenForWethOut(_swapToken, _swapAmount);

    address[] memory tokens = getPiptTokens();
    uint256 wrapperFee = getWrapFee(tokens);
    (, uint256 ethSwapAmount) = calcEthFee(ethAmount, wrapperFee);
    (, , poolAmountOut) = calcSwapEthToPiptInputs(ethSwapAmount, tokens, _slippage);

    _swapWethToPiptByPoolOut(ethAmount, poolAmountOut, tokens, wrapperFee);

    emit Erc20ToPiptSwap(msg.sender, _swapToken, _swapAmount, ethAmount, poolAmountOut);
  }

  function swapPiptToErc20(address _swapToken, uint256 _poolAmountIn) external payable returns (uint256 erc20Out) {

    uint256 ethOut = _swapPiptToWeth(_poolAmountIn);

    erc20Out = _swapWethForTokenOut(_swapToken, ethOut);

    IERC20(_swapToken).safeTransfer(msg.sender, erc20Out);

    emit PiptToErc20Swap(msg.sender, _swapToken, _poolAmountIn, ethOut, erc20Out);
  }

  function calcSwapErc20ToPiptInputs(
    address _swapToken,
    uint256 _swapAmount,
    address[] memory _tokens,
    uint256 _slippage,
    bool _withFee
  )
    external
    view
    returns (
      uint256[] memory tokensInPipt,
      uint256[] memory ethInUniswap,
      uint256 poolOut
    )
  {

    uint256 ethAmount = getAmountOutForUniswapValue(_uniswapPairFor(_swapToken), _swapAmount, true);

    if (_withFee) {
      (, ethAmount) = calcEthFee(ethAmount, getWrapFee(_tokens));
    }
    return calcSwapEthToPiptInputs(ethAmount, _tokens, _slippage);
  }

  function calcNeedErc20ToPoolOut(
    address _swapToken,
    uint256 _poolAmountOut,
    uint256 _slippage
  ) external view returns (uint256) {

    uint256 resultEth = calcNeedEthToPoolOut(_poolAmountOut, _slippage);

    IUniswapV2Pair tokenPair = _uniswapPairFor(_swapToken);
    (uint256 token1Reserve, uint256 token2Reserve, ) = tokenPair.getReserves();
    if (tokenPair.token0() == address(weth)) {
      return UniswapV2Library.getAmountIn(resultEth.mul(1003).div(1000), token2Reserve, token1Reserve);
    } else {
      return UniswapV2Library.getAmountIn(resultEth.mul(1003).div(1000), token1Reserve, token2Reserve);
    }
  }

  function calcSwapPiptToErc20Inputs(
    address _swapToken,
    uint256 _poolAmountIn,
    address[] memory _tokens,
    bool _withFee
  )
    external
    view
    returns (
      uint256[] memory tokensOutPipt,
      uint256[] memory ethOutUniswap,
      uint256 totalErc20Out,
      uint256 poolAmountFee
    )
  {

    uint256 totalEthOut;

    (tokensOutPipt, ethOutUniswap, totalEthOut, poolAmountFee) = calcSwapPiptToEthInputs(_poolAmountIn, _tokens);
    if (_withFee) {
      (, totalEthOut) = calcEthFee(totalEthOut, getWrapFee(_tokens));
    }
    totalErc20Out = getAmountOutForUniswapValue(_uniswapPairFor(_swapToken), totalEthOut, false);
  }

  function calcErc20Fee(address _swapToken, uint256 _swapAmount)
    external
    view
    returns (
      uint256 erc20Fee,
      uint256 erc20AfterFee,
      uint256 ethFee,
      uint256 ethAfterFee
    )
  {

    IUniswapV2Pair tokenPair = _uniswapPairFor(_swapToken);

    uint256 ethAmount = getAmountOutForUniswapValue(tokenPair, _swapAmount, true);

    (ethFee, ethAfterFee) = calcEthFee(ethAmount, getWrapFee(getPiptTokens()));

    if (ethFee != 0) {
      erc20Fee = getAmountOutForUniswapValue(tokenPair, ethFee, false);
    }
    erc20AfterFee = getAmountOutForUniswapValue(tokenPair, ethAfterFee, false);
  }
}