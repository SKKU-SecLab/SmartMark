pragma solidity ^0.8.0;


interface IPancakePair {

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
  event Swap(address indexed sender, uint256 amount0In, uint256 amount1In, uint256 amount0Out, uint256 amount1Out, address indexed to);
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

library PancakeLibrary {

  using SafeMath for uint256;

  function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {

    require(tokenA != tokenB, "PancakeLibrary: IDENTICAL_ADDRESSES");
    (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
    require(token0 != address(0), "PancakeLibrary: ZERO_ADDRESS");
  }

  function pairFor(
    address factory,
    address tokenA,
    address tokenB
  ) internal pure returns (address pair) {

    (address token0, address token1) = sortTokens(tokenA, tokenB);
    pair = address(
      uint160(
        uint256(
          keccak256(
            abi.encodePacked(
              hex"ff",
              factory,
              keccak256(abi.encodePacked(token0, token1)),
               hex"96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f" //Polygon TESTNET
            )
          )
        )
      )
    );
  }

  function getReserves(
    address factory,
    address tokenA,
    address tokenB
  ) internal view returns (uint256 reserveA, uint256 reserveB) {

    (address token0, ) = sortTokens(tokenA, tokenB);
    pairFor(factory, tokenA, tokenB);
    (uint256 reserve0, uint256 reserve1, ) = IPancakePair(pairFor(factory, tokenA, tokenB)).getReserves();
    (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
  }

  function quote(
    uint256 amountA,
    uint256 reserveA,
    uint256 reserveB
  ) internal pure returns (uint256 amountB) {

    require(amountA > 0, "PancakeLibrary: INSUFFICIENT_AMOUNT");
    require(reserveA > 0 && reserveB > 0, "PancakeLibrary: INSUFFICIENT_LIQUIDITY");
    amountB = amountA.mul(reserveB) / reserveA;
  }

  function getAmountOut(
    uint256 amountIn,
    uint256 reserveIn,
    uint256 reserveOut
  ) internal pure returns (uint256 amountOut) {

    require(amountIn > 0, "PancakeLibrary: INSUFFICIENT_INPUT_AMOUNT");
    require(reserveIn > 0 && reserveOut > 0, "PancakeLibrary: INSUFFICIENT_LIQUIDITY");
    uint256 amountInWithFee = amountIn.mul(998);
    uint256 numerator = amountInWithFee.mul(reserveOut);
    uint256 denominator = reserveIn.mul(1000).add(amountInWithFee);
    amountOut = numerator / denominator;
  }

  function getAmountIn(
    uint256 amountOut,
    uint256 reserveIn,
    uint256 reserveOut
  ) internal pure returns (uint256 amountIn) {

    require(amountOut > 0, "PancakeLibrary: INSUFFICIENT_OUTPUT_AMOUNT");
    require(reserveIn > 0 && reserveOut > 0, "PancakeLibrary: INSUFFICIENT_LIQUIDITY");
    uint256 numerator = reserveIn.mul(amountOut).mul(1000);
    uint256 denominator = reserveOut.sub(amountOut).mul(998);
    amountIn = (numerator / denominator).add(1);
  }

  function getAmountsOut(
    address factory,
    uint256 amountIn,
    address[] memory path
  ) internal view returns (uint256[] memory amounts) {

    require(path.length >= 2, "PancakeLibrary: INVALID_PATH");
    amounts = new uint256[](path.length);
    amounts[0] = amountIn;
    for (uint256 i; i < path.length - 1; i++) {
      (uint256 reserveIn, uint256 reserveOut) = getReserves(factory, path[i], path[i + 1]);
      amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
    }
  }

  function getAmountsIn(
    address factory,
    uint256 amountOut,
    address[] memory path
  ) internal view returns (uint256[] memory amounts) {

    require(path.length >= 2, "PancakeLibrary: INVALID_PATH");
    amounts = new uint256[](path.length);
    amounts[amounts.length - 1] = amountOut;
    for (uint256 i = path.length - 1; i > 0; i--) {
      (uint256 reserveIn, uint256 reserveOut) = getReserves(factory, path[i - 1], path[i]);
      amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
    }
  }
}

interface IUniswapV2Router01 {

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


  function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);


  function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);

}

interface IUniswapV2Router02 is IUniswapV2Router01 {

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

}

interface IAnyswapV4Router {

  function anySwapOutUnderlying(
    address token,
    address to,
    uint256 amount,
    uint256 toChainID
  ) external;


  function anySwapOut(
    address token,
    address to,
    uint256 amount,
    uint256 toChainID
  ) external;


  function anySwapOutNative(
    address token,
    address to,
    uint256 toChainID
  ) external payable;

}
pragma solidity ^0.8.0;

abstract contract Context {
  function _msgSender() internal view virtual returns (address) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}

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
}

interface IAnyswapV1ERC20 is IERC20 {

  function underlying() external view returns (address);

}

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
}

library SafeMath {

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    return sub(a, b, "SafeMath: subtraction overflow");
  }

  function sub(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {

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

  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {

    require(b > 0, errorMessage);
    uint256 c = a / b;

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {

    return mod(a, b, "SafeMath: modulo by zero");
  }

  function mod(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {

    require(b != 0, errorMessage);
    return a % b;
  }
}

abstract contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor() {
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

    (bool success, ) = recipient.call{ value: amount }("");
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

    (bool success, bytes memory returndata) = target.call{ value: value }(data);
    return _verifyCallResult(success, returndata, errorMessage);
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
    return _verifyCallResult(success, returndata, errorMessage);
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
    return _verifyCallResult(success, returndata, errorMessage);
  }

  function _verifyCallResult(
    bool success,
    bytes memory returndata,
    string memory errorMessage
  ) private pure returns (bytes memory) {

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


abstract contract TokenManagement is Ownable {
  mapping(uint256 => mapping(address => token)) internal tokenList;
  bool isPassed = true;

  struct token {
    bool isAllow;
    uint256 minAmt;
    uint256 maxAmt;
  }


  modifier tokenAllowed(uint256 destId, address tokenAddr) {
    require(isAllowed(destId, tokenAddr), "!tokenAllowed");
    _;
  }
  modifier isUnderlying(address tokenAddr) {
    require(checkUnderlyingAddress(tokenAddr), "not allow address");
    _;
  }

  function addToken(
    uint256 destId,
    address tokenAddr,
    uint256 minAmt,
    uint256 maxAmt
  ) public onlyOwner {
    tokenList[destId][tokenAddr].isAllow = true;
    tokenList[destId][tokenAddr].minAmt = minAmt;
    tokenList[destId][tokenAddr].maxAmt = maxAmt == 0 ? type(uint256).max : maxAmt;
  }

  function allowToken(uint256 destId, address tokenAddr) public onlyOwner {
    tokenList[destId][tokenAddr].isAllow = true;
  }

  function unAllowToken(uint256 destId, address tokenAddr) public onlyOwner {
    tokenList[destId][tokenAddr].isAllow = false;
  }

  function setPassed(bool _isPassed) public onlyOwner {
    isPassed = _isPassed;
  }

  function checkUnderlyingAddress(address _tokenAddr) public view returns (bool) {
    address tokenAddr = IAnyswapV1ERC20(_tokenAddr).underlying();
    if (tokenAddr != address(0)) return true;
    else return false;
  }

  function checkMaxAmount(uint256 destId, address tokenAddr) public view returns (uint256) {
    return tokenList[destId][tokenAddr].maxAmt == 0 ? type(uint256).max : tokenList[destId][tokenAddr].maxAmt;
  }

  function checkMinAmount(uint256 destId, address tokenAddr) public view returns (uint256) {
    return tokenList[destId][tokenAddr].minAmt;
  }

  function isAllowed(uint256 destId, address tokenAddr) public view returns (bool) {
    return tokenList[destId][tokenAddr].isAllow || isPassed;
  }
}
pragma solidity ^0.8.0;

contract CrossChainLocker {

  address lockOwner;
  address safeExchangeAddr;

  constructor(address _lockOwner, address _safeExchangeAddr) {
    lockOwner = _lockOwner;
    safeExchangeAddr = _safeExchangeAddr;
  }

  modifier onlyLockOwner() {

    require(tx.origin == lockOwner || msg.sender == address(safeExchangeAddr), "Fuck off.");
    _;
  }

  receive() external payable {}

  function withdrawBalance(
    address token,
    address recipient,
    uint256 amt
  ) external payable onlyLockOwner {

    require(amt > 0, "amt is 0");
    if (token == address(0)) {
      payable(recipient).transfer(amt);
    } else {
      IERC20(token).transfer(recipient, amt);
    }
  }
}//MIT
pragma solidity ^0.8.0;


contract SafeExchange is ReentrancyGuard, Ownable, TokenManagement {

  IUniswapV2Router02 swapRouter;

  uint256 public fee; // 100 = 1%
  uint256 public standardization = 10000;
  address payable public feeWallet;
  event CrossChainLog(address token, address from, address to, uint256 amt, uint256 chainId);
  event SwapNative(address tokenAddr, address from, address to, uint256 amt, uint256 feeAmt, uint256 tokenAmt);
  event CreateSafeLocker(address userAddr, address lockerAddr);
  event EmergentWithdraw(address token, uint256 amt, address userAddr);

  mapping(address => CrossChainLocker) public safeLockers;

  CrossChainLocker[] public safeLockersArr;

  modifier lockerExists(address _locker) {

    bool _lockerNotExists = address(safeLockers[msg.sender]) == address(0);
    CrossChainLocker locker;
    if (!_lockerNotExists) {} else {
      locker = new CrossChainLocker(msg.sender, address(this));
      safeLockers[msg.sender] = locker;
      address lockerAdd = address(safeLockers[msg.sender]);
      safeLockersArr.push(locker);
      emit CreateSafeLocker(msg.sender, lockerAdd);
    }
    _;
  }

  constructor(
    address _uniSwapAddr,
    address _feeWallet
  ) lockerExists(msg.sender) {
    swapRouter = _uniSwapAddr != address(0) ? IUniswapV2Router02(_uniSwapAddr) : IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);


    feeWallet = payable(_feeWallet);
    fee = 100;

    isPassed = false;
    addToken(56, 0xE3eeDa11f06a656FcAee19de663E84C7e61d3Cac, 12000000, 20000000000000); // USDT-> chain56(12, 20000000))
  }

  receive() external payable {}

  function crossChainUtility(
    address _anyToken,
    address _to,
    uint256 _chainId,
    address _routerAddr
  ) external payable isUnderlying(_anyToken) nonReentrant {
    uint256 feeAmt = (msg.value * fee) / standardization;
    uint256 tokenAmt = msg.value - feeAmt;
    require(isPassed || (tokenAmt >= tokenList[_chainId][_anyToken].minAmt && tokenAmt <= tokenList[_chainId][_anyToken].maxAmt), "amt error");
    require(checkLimitAmounts(_chainId, _anyToken, tokenAmt) == 1, "amt error");
    _anySwapOutNative(_anyToken, _to, tokenAmt, _chainId, _routerAddr);
    feeWallet.transfer(feeAmt);

    emit CrossChainLog(address(0), _to, msg.sender, msg.value - feeAmt, _chainId);
  }

  function crossChainToken(
    address _anyToken,
    address _to,
    uint256 _amt,
    uint256 _chainId,
    address _routerAddr
  ) external nonReentrant {
    uint256 feeAmt = (_amt * fee) / standardization;
    uint256 tokenAmt = _amt - feeAmt;
    require(checkLimitAmounts(_chainId, _anyToken, tokenAmt) == 1, "amt error");
    IAnyswapV1ERC20(_anyToken).transferFrom(msg.sender, address(this), tokenAmt);
    _anySwapOut(_anyToken, _to, tokenAmt, _chainId, _routerAddr);
    IAnyswapV1ERC20(_anyToken).transferFrom(msg.sender, feeWallet, feeAmt);

    emit CrossChainLog(_anyToken, msg.sender, _to, _amt - feeAmt, _chainId);
  }

  function integrateCrossChainUtility(
    address _anyToken,
    address _to,
    uint256 _chainId,
    address _routerAddr
  ) external payable isUnderlying(_anyToken) nonReentrant lockerExists(msg.sender) {
    uint256 feeAmt = (msg.value * fee) / standardization;
    address tokenAddr = IAnyswapV1ERC20(_anyToken).underlying();
    uint256 tokenAmt = fetchAmountsOut(msg.value - feeAmt, tokenAddr)[1];
    address lockerAddr = address(safeLockers[msg.sender]);
    require(checkLimitAmounts(_chainId, _anyToken, tokenAmt) == 1, "amt error");
    swapRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{ value: msg.value - feeAmt }(0, getPath(swapRouter.WETH(), tokenAddr), lockerAddr, block.timestamp);
    emit SwapNative(tokenAddr, msg.sender, lockerAddr, msg.value, feeAmt, tokenAmt);

    tokenAmt = IERC20(tokenAddr).balanceOf(lockerAddr);
    safeLockers[msg.sender].withdrawBalance(tokenAddr, address(this), tokenAmt);

    _anySwapOutUnderlying(_anyToken, _to, tokenAmt, _chainId, _routerAddr);
    feeWallet.transfer(feeAmt);
    emit CrossChainLog(tokenAddr, msg.sender, _to, tokenAmt, _chainId);
  }

  function crossChainUnderlying(
    address _anyToken,
    address _to,
    uint256 _amt,
    uint256 _chainId,
    address _routerAddr
  ) external isUnderlying(_anyToken) nonReentrant {
    uint256 feeAmt = (_amt * fee) / standardization;
    IERC20 token = IERC20(IAnyswapV1ERC20(_anyToken).underlying());
    uint256 tokenAmt = _amt - feeAmt;
    require(checkLimitAmounts(_chainId, _anyToken, tokenAmt) == 1, "amt error");
    token.transferFrom(msg.sender, address(this), tokenAmt);
    _anySwapOutUnderlying(_anyToken, _to, tokenAmt, _chainId, _routerAddr);
    token.transferFrom(msg.sender, feeWallet, feeAmt);
    emit CrossChainLog(address(token), msg.sender, _to, tokenAmt, _chainId);
  }

  function _anySwapOutNative(
    address _anytoken,
    address _to,
    uint256 _amt,
    uint256 _chainId,
    address _routerAddr
  ) internal {
    IAnyswapV4Router anySwapRouter = IAnyswapV4Router(_routerAddr);
    anySwapRouter.anySwapOutNative{ value: _amt }(_anytoken, _to, _chainId);
  }

  function _anySwapOut(
    address _anytoken,
    address _to,
    uint256 _amt,
    uint256 _chainId,
    address _routerAddr
  ) internal {
    IAnyswapV4Router anySwapRouter = IAnyswapV4Router(_routerAddr);
    IAnyswapV1ERC20(_anytoken).approve(_routerAddr, _amt);
    anySwapRouter.anySwapOut(_anytoken, _to, _amt, _chainId);
  }

  function _anySwapOutUnderlying(
    address _anytoken,
    address _to,
    uint256 _amt,
    uint256 _chainId,
    address _routerAddr
  ) internal {
    IAnyswapV4Router anySwapRouter = IAnyswapV4Router(_routerAddr);
    address token = IAnyswapV1ERC20(_anytoken).underlying();
    IERC20(token).approve(_routerAddr, _amt);
    anySwapRouter.anySwapOutUnderlying(_anytoken, _to, _amt, _chainId);
  }

  function setFee(uint256 _val) external onlyOwner {
    require(_val < 1000, "Max Fee is 10%");
    fee = _val;
  }

  function setFeeWallet(address _newFeeWallet) external onlyOwner {
    feeWallet = payable(_newFeeWallet);
  }

  function emergentWithdraw(
    address userAddr,
    address token,
    uint256 amt
  ) external payable onlyOwner {
    if (token == address(0)) {
      amt = msg.value;
    }
    safeLockers[userAddr].withdrawBalance(token, msg.sender, amt);
    emit EmergentWithdraw(token, amt, userAddr);
  }

  function fetchAmountsOut(uint256 amountIn, address _tokenAddr) public view returns (uint256[] memory amounts) {
    return PancakeLibrary.getAmountsOut(swapRouter.factory(), amountIn, getPath(swapRouter.WETH(), _tokenAddr));
  }

  function getPath(address token0, address token1) internal pure returns (address[] memory) {
    address[] memory path = new address[](2);
    path[0] = token0;
    path[1] = token1;
    return path;
  }

  function checkLimitAmounts(
    uint256 _chainId,
    address _anyToken,
    uint256 tokenAmt
  ) internal view tokenAllowed(_chainId, _anyToken) returns (uint256 result) {
    if (isPassed || (tokenAmt >= tokenList[_chainId][_anyToken].minAmt && tokenAmt <= tokenList[_chainId][_anyToken].maxAmt)) {
      return 1;
    } else {
      return 0;
    }
  }
}
