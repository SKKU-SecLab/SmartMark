

pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;

interface IBadStaticCallERC20 {


    function balanceOf(address account) external returns (uint256);


    function allowance(address owner, address spender) external returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);

}


pragma solidity ^0.5.5;

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
}


pragma solidity ^0.5.0;




library SafeStaticCallERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeApprove(IBadStaticCallERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeProxyERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function callOptionalReturn(IBadStaticCallERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeProxyERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeProxyERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeProxyERC20: ERC20 operation did not succeed");
        }
    }
}





pragma solidity ^0.5.12;

contract BColor {

    function getColor()
        external view
        returns (bytes32);

}

contract BBronze is BColor {

    function getColor()
        external view
        returns (bytes32) {

            return bytes32("BRONZE");
        }
}





pragma solidity ^0.5.12;


contract BConst is BBronze {

    uint public constant BONE              = 10**18;

    uint public constant MIN_BOUND_TOKENS  = 2;
    uint public constant MAX_BOUND_TOKENS  = 8;

    uint public constant MIN_FEE           = BONE / 10**6;
    uint public constant MAX_FEE           = BONE / 10;
    uint public constant EXIT_FEE          = 0;

    uint public constant MIN_WEIGHT        = BONE;
    uint public constant MAX_WEIGHT        = BONE * 50;
    uint public constant MAX_TOTAL_WEIGHT  = BONE * 50;
    uint public constant MIN_BALANCE       = BONE / 10**12;

    uint public constant INIT_POOL_SUPPLY  = BONE * 100;

    uint public constant MIN_BPOW_BASE     = 1 wei;
    uint public constant MAX_BPOW_BASE     = (2 * BONE) - 1 wei;
    uint public constant BPOW_PRECISION    = BONE / 10**10;

    uint public constant MAX_IN_RATIO      = BONE / 2;
    uint public constant MAX_OUT_RATIO     = (BONE / 3) + 1 wei;
}





pragma solidity ^0.5.12;


contract BNum is BConst {


    function btoi(uint a)
        internal pure
        returns (uint)
    {

        return a / BONE;
    }

    function bfloor(uint a)
        internal pure
        returns (uint)
    {

        return btoi(a) * BONE;
    }

    function badd(uint a, uint b)
        internal pure
        returns (uint)
    {

        uint c = a + b;
        require(c >= a, "ERR_ADD_OVERFLOW");
        return c;
    }

    function bsub(uint a, uint b)
        internal pure
        returns (uint)
    {

        (uint c, bool flag) = bsubSign(a, b);
        require(!flag, "ERR_SUB_UNDERFLOW");
        return c;
    }

    function bsubSign(uint a, uint b)
        internal pure
        returns (uint, bool)
    {

        if (a >= b) {
            return (a - b, false);
        } else {
            return (b - a, true);
        }
    }

    function bmul(uint a, uint b)
        internal pure
        returns (uint)
    {

        uint c0 = a * b;
        require(a == 0 || c0 / a == b, "ERR_MUL_OVERFLOW");
        uint c1 = c0 + (BONE / 2);
        require(c1 >= c0, "ERR_MUL_OVERFLOW");
        uint c2 = c1 / BONE;
        return c2;
    }

    function bdiv(uint a, uint b)
        internal pure
        returns (uint)
    {

        require(b != 0, "ERR_DIV_ZERO");
        uint c0 = a * BONE;
        require(a == 0 || c0 / a == BONE, "ERR_DIV_INTERNAL"); // bmul overflow
        uint c1 = c0 + (b / 2);
        require(c1 >= c0, "ERR_DIV_INTERNAL"); //  badd require
        uint c2 = c1 / b;
        return c2;
    }

    function bpowi(uint a, uint n)
        internal pure
        returns (uint)
    {

        uint z = n % 2 != 0 ? a : BONE;

        for (n /= 2; n != 0; n /= 2) {
            a = bmul(a, a);

            if (n % 2 != 0) {
                z = bmul(z, a);
            }
        }
        return z;
    }

    function bpow(uint base, uint exp)
        internal pure
        returns (uint)
    {

        require(base >= MIN_BPOW_BASE, "ERR_BPOW_BASE_TOO_LOW");
        require(base <= MAX_BPOW_BASE, "ERR_BPOW_BASE_TOO_HIGH");

        uint whole  = bfloor(exp);
        uint remain = bsub(exp, whole);

        uint wholePow = bpowi(base, btoi(whole));

        if (remain == 0) {
            return wholePow;
        }

        uint partialResult = bpowApprox(base, remain, BPOW_PRECISION);
        return bmul(wholePow, partialResult);
    }

    function bpowApprox(uint base, uint exp, uint precision)
        internal pure
        returns (uint)
    {

        uint a     = exp;
        (uint x, bool xneg)  = bsubSign(base, BONE);
        uint term = BONE;
        uint sum   = term;
        bool negative = false;


        for (uint i = 1; term >= precision; i++) {
            uint bigK = i * BONE;
            (uint c, bool cneg) = bsubSign(a, bsub(bigK, BONE));
            term = bmul(term, bmul(c, x));
            term = bdiv(term, bigK);
            if (term == 0) break;

            if (xneg) negative = !negative;
            if (cneg) negative = !negative;
            if (negative) {
                sum = bsub(sum, term);
            } else {
                sum = badd(sum, term);
            }
        }

        return sum;
    }

}





pragma solidity ^0.5.12;


contract BMath is BBronze, BConst, BNum {

    function calcSpotPrice(
        uint tokenBalanceIn,
        uint tokenWeightIn,
        uint tokenBalanceOut,
        uint tokenWeightOut,
        uint swapFee
    )
        public pure
        returns (uint spotPrice)
    {

        uint numer = bdiv(tokenBalanceIn, tokenWeightIn);
        uint denom = bdiv(tokenBalanceOut, tokenWeightOut);
        uint ratio = bdiv(numer, denom);
        uint scale = bdiv(BONE, bsub(BONE, swapFee));
        return  (spotPrice = bmul(ratio, scale));
    }

    function calcOutGivenIn(
        uint tokenBalanceIn,
        uint tokenWeightIn,
        uint tokenBalanceOut,
        uint tokenWeightOut,
        uint tokenAmountIn,
        uint swapFee
    )
        public pure
        returns (uint tokenAmountOut)
    {

        uint weightRatio = bdiv(tokenWeightIn, tokenWeightOut);
        uint adjustedIn = bsub(BONE, swapFee);
        adjustedIn = bmul(tokenAmountIn, adjustedIn);
        uint y = bdiv(tokenBalanceIn, badd(tokenBalanceIn, adjustedIn));
        uint foo = bpow(y, weightRatio);
        uint bar = bsub(BONE, foo);
        tokenAmountOut = bmul(tokenBalanceOut, bar);
        return tokenAmountOut;
    }

    function calcInGivenOut(
        uint tokenBalanceIn,
        uint tokenWeightIn,
        uint tokenBalanceOut,
        uint tokenWeightOut,
        uint tokenAmountOut,
        uint swapFee
    )
        public pure
        returns (uint tokenAmountIn)
    {

        uint weightRatio = bdiv(tokenWeightOut, tokenWeightIn);
        uint diff = bsub(tokenBalanceOut, tokenAmountOut);
        uint y = bdiv(tokenBalanceOut, diff);
        uint foo = bpow(y, weightRatio);
        foo = bsub(foo, BONE);
        tokenAmountIn = bsub(BONE, swapFee);
        tokenAmountIn = bdiv(bmul(tokenBalanceIn, foo), tokenAmountIn);
        return tokenAmountIn;
    }

    function calcPoolOutGivenSingleIn(
        uint tokenBalanceIn,
        uint tokenWeightIn,
        uint poolSupply,
        uint totalWeight,
        uint tokenAmountIn,
        uint swapFee
    )
        public pure
        returns (uint poolAmountOut)
    {

        uint normalizedWeight = bdiv(tokenWeightIn, totalWeight);
        uint zaz = bmul(bsub(BONE, normalizedWeight), swapFee);
        uint tokenAmountInAfterFee = bmul(tokenAmountIn, bsub(BONE, zaz));

        uint newTokenBalanceIn = badd(tokenBalanceIn, tokenAmountInAfterFee);
        uint tokenInRatio = bdiv(newTokenBalanceIn, tokenBalanceIn);

        uint poolRatio = bpow(tokenInRatio, normalizedWeight);
        uint newPoolSupply = bmul(poolRatio, poolSupply);
        poolAmountOut = bsub(newPoolSupply, poolSupply);
        return poolAmountOut;
    }

    function calcSingleInGivenPoolOut(
        uint tokenBalanceIn,
        uint tokenWeightIn,
        uint poolSupply,
        uint totalWeight,
        uint poolAmountOut,
        uint swapFee
    )
        public pure
        returns (uint tokenAmountIn)
    {

        uint normalizedWeight = bdiv(tokenWeightIn, totalWeight);
        uint newPoolSupply = badd(poolSupply, poolAmountOut);
        uint poolRatio = bdiv(newPoolSupply, poolSupply);

        uint boo = bdiv(BONE, normalizedWeight);
        uint tokenInRatio = bpow(poolRatio, boo);
        uint newTokenBalanceIn = bmul(tokenInRatio, tokenBalanceIn);
        uint tokenAmountInAfterFee = bsub(newTokenBalanceIn, tokenBalanceIn);
        uint zar = bmul(bsub(BONE, normalizedWeight), swapFee);
        tokenAmountIn = bdiv(tokenAmountInAfterFee, bsub(BONE, zar));
        return tokenAmountIn;
    }

    function calcSingleOutGivenPoolIn(
        uint tokenBalanceOut,
        uint tokenWeightOut,
        uint poolSupply,
        uint totalWeight,
        uint poolAmountIn,
        uint swapFee
    )
        public pure
        returns (uint tokenAmountOut)
    {

        uint normalizedWeight = bdiv(tokenWeightOut, totalWeight);
        uint poolAmountInAfterExitFee = bmul(poolAmountIn, bsub(BONE, EXIT_FEE));
        uint newPoolSupply = bsub(poolSupply, poolAmountInAfterExitFee);
        uint poolRatio = bdiv(newPoolSupply, poolSupply);

        uint tokenOutRatio = bpow(poolRatio, bdiv(BONE, normalizedWeight));
        uint newTokenBalanceOut = bmul(tokenOutRatio, tokenBalanceOut);

        uint tokenAmountOutBeforeSwapFee = bsub(tokenBalanceOut, newTokenBalanceOut);

        uint zaz = bmul(bsub(BONE, normalizedWeight), swapFee);
        tokenAmountOut = bmul(tokenAmountOutBeforeSwapFee, bsub(BONE, zaz));
        return tokenAmountOut;
    }

    function calcPoolInGivenSingleOut(
        uint tokenBalanceOut,
        uint tokenWeightOut,
        uint poolSupply,
        uint totalWeight,
        uint tokenAmountOut,
        uint swapFee
    )
        public pure
        returns (uint poolAmountIn)
    {


        uint normalizedWeight = bdiv(tokenWeightOut, totalWeight);
        uint zoo = bsub(BONE, normalizedWeight);
        uint zar = bmul(zoo, swapFee);
        uint tokenAmountOutBeforeSwapFee = bdiv(tokenAmountOut, bsub(BONE, zar));

        uint newTokenBalanceOut = bsub(tokenBalanceOut, tokenAmountOutBeforeSwapFee);
        uint tokenOutRatio = bdiv(newTokenBalanceOut, tokenBalanceOut);

        uint poolRatio = bpow(tokenOutRatio, normalizedWeight);
        uint newPoolSupply = bmul(poolRatio, poolSupply);
        uint poolAmountInAfterExitFee = bsub(poolSupply, newPoolSupply);

        poolAmountIn = bdiv(poolAmountInAfterExitFee, bsub(BONE, EXIT_FEE));
        return poolAmountIn;
    }


}


pragma solidity ^0.5.0;

interface BPool {


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

  function rebind(address token, uint balance, uint denorm) external;

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


  function calcSpotPrice(
    uint tokenBalanceIn,
    uint tokenWeightIn,
    uint tokenBalanceOut,
    uint tokenWeightOut,
    uint swapFee
  ) external pure returns (uint spotPrice);


  function calcOutGivenIn(
    uint tokenBalanceIn,
    uint tokenWeightIn,
    uint tokenBalanceOut,
    uint tokenWeightOut,
    uint tokenAmountIn,
    uint swapFee
  ) external pure returns (uint tokenAmountOut);


  function calcInGivenOut(
    uint tokenBalanceIn,
    uint tokenWeightIn,
    uint tokenBalanceOut,
    uint tokenWeightOut,
    uint tokenAmountOut,
    uint swapFee
  ) external pure returns (uint tokenAmountIn);


  function calcPoolOutGivenSingleIn(
    uint tokenBalanceIn,
    uint tokenWeightIn,
    uint poolSupply,
    uint totalWeight,
    uint tokenAmountIn,
    uint swapFee
  ) external pure returns (uint poolAmountOut);


  function calcSingleInGivenPoolOut(
    uint tokenBalanceIn,
    uint tokenWeightIn,
    uint poolSupply,
    uint totalWeight,
    uint poolAmountOut,
    uint swapFee
  ) external pure returns (uint tokenAmountIn);


  function calcSingleOutGivenPoolIn(
    uint tokenBalanceOut,
    uint tokenWeightOut,
    uint poolSupply,
    uint totalWeight,
    uint poolAmountIn,
    uint swapFee
  ) external pure returns (uint tokenAmountOut);


  function calcPoolInGivenSingleOut(
    uint tokenBalanceOut,
    uint tokenWeightOut,
    uint poolSupply,
    uint totalWeight,
    uint tokenAmountOut,
    uint swapFee
  ) external pure returns (uint poolAmountIn);


}


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;




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
}


pragma solidity ^0.5.0;

contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.5.0;

contract Ownable is Context {

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

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


pragma solidity >=0.5.0;


contract Destructible is Ownable {

  function destroy() public onlyOwner {

    selfdestruct(address(bytes20(owner())));
  }

  function destroyAndSend(address payable _recipient) public onlyOwner {

    selfdestruct(_recipient);
  }
}


pragma solidity >=0.4.24;


contract Pausable is Ownable {

  event Pause();
  event Unpause();

  bool public paused = false;


  modifier whenNotPaused() {

    require(!paused, "The contract is paused");
    _;
  }

  modifier whenPaused() {

    require(paused, "The contract is not paused");
    _;
  }

  function pause() public onlyOwner whenNotPaused {

    paused = true;
    emit Pause();
  }

  function unpause() public onlyOwner whenPaused {

    paused = false;
    emit Unpause();
  }
}


pragma solidity >=0.4.24;





contract Withdrawable is Ownable {

  using SafeERC20 for IERC20;
  address constant ETHER = address(0);

  event LogWithdrawToken(
    address indexed _from,
    address indexed _token,
    uint amount
  );

  function withdrawAll(address _tokenAddress) public onlyOwner {

    uint tokenBalance;
    if (_tokenAddress == ETHER) {
      address self = address(this); // workaround for a possible solidity bug
      tokenBalance = self.balance;
    } else {
      tokenBalance = IBadStaticCallERC20(_tokenAddress).balanceOf(address(this));
    }
    _withdraw(_tokenAddress, tokenBalance);
  }

  function _withdraw(address _tokenAddress, uint _amount) internal {

    if (_tokenAddress == ETHER) {
      msg.sender.transfer(_amount);
    } else {
      IERC20(_tokenAddress).safeTransfer(msg.sender, _amount);
    }
    emit LogWithdrawToken(msg.sender, _tokenAddress, _amount);
  }

}


pragma solidity ^0.5.0;





contract WithFee is Ownable {

  using SafeERC20 for IERC20;
  using SafeMath for uint;
  address payable public feeWallet;
  uint public storedSpread;
  uint constant spreadDecimals = 6;
  uint constant spreadUnit = 10 ** spreadDecimals;

  event LogFee(address token, uint amount);

  constructor(address payable _wallet, uint _spread) public {
    require(_wallet != address(0), "_wallet == address(0)");
    require(_spread < spreadUnit, "spread >= spreadUnit");
    feeWallet = _wallet;
    storedSpread = _spread;
  }

  function setFeeWallet(address payable _wallet) external onlyOwner {

    require(_wallet != address(0), "_wallet == address(0)");
    feeWallet = _wallet;
  }

  function setSpread(uint _spread) external onlyOwner {

    storedSpread = _spread;
  }

  function _getFee(uint underlyingTokenTotal) internal view returns(uint) {

    return underlyingTokenTotal.mul(storedSpread).div(spreadUnit);
  }

  function _payFee(address feeToken, uint fee) internal {

    if (fee > 0) {
      if (feeToken == address(0)) {
        feeWallet.transfer(fee);
      } else {
        IERC20(feeToken).safeTransfer(feeWallet, fee);
      }
      emit LogFee(feeToken, fee);
    }
  }

}


pragma solidity >=0.4.0;

interface IErc20Swap {

    function getRate(address src, address dst, uint256 srcAmount) external view returns(uint expectedRate, uint slippageRate);  // real rate = returned value / 1e18

    function swap(address src, uint srcAmount, address dest, uint maxDestAmount, uint minConversionRate) external payable;


    event LogTokenSwap(
        address indexed _userAddress,
        address indexed _userSentTokenAddress,
        uint _userSentTokenAmount,
        address indexed _userReceivedTokenAddress,
        uint _userReceivedTokenAmount
    );
}


pragma solidity >=0.5.0;










contract NetworkBasedTokenSwap is Withdrawable, Pausable, Destructible, WithFee, IErc20Swap
{

  using SafeMath for uint;
  using SafeERC20 for IERC20;
  address constant ETHER = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

  mapping (address => mapping (address => uint)) spreadCustom;

  event UnexpectedIntialBalance(address token, uint amount);

  constructor(
    address payable _wallet,
    uint _spread
  )
    public WithFee(_wallet, _spread)
  {}

  function() external payable {
  }

  function setSpread(address tokenA, address tokenB, uint spread) public onlyOwner {

    uint value = spread > spreadUnit ? spreadUnit : spread;
    spreadCustom[tokenA][tokenB] = value;
    spreadCustom[tokenB][tokenA] = value;
  }

  function getSpread(address tokenA, address tokenB) public view returns(uint) {

    uint value = spreadCustom[tokenA][tokenB];
    if (value == 0) return storedSpread;
    if (value >= spreadUnit) return 0;
    else return value;
  }

  function getNetworkRate(address src, address dest, uint256 srcAmount) internal view returns(uint expectedRate, uint slippageRate);


  function getRate(address src, address dest, uint256 srcAmount) external view
    returns(uint expectedRate, uint slippageRate)
  {

    (uint256 kExpected, uint256 kSplippage) = getNetworkRate(src, dest, srcAmount);
    uint256 spread = getSpread(src, dest);
    expectedRate = kExpected.mul(spreadUnit - spread).div(spreadUnit);
    slippageRate = kSplippage.mul(spreadUnit - spread).div(spreadUnit);
  }

  function _freeUnexpectedTokens(address token) private {

    uint256 unexpectedBalance = token == ETHER
      ? _myEthBalance().sub(msg.value)
      : IBadStaticCallERC20(token).balanceOf(address(this));
    if (unexpectedBalance > 0) {
      _transfer(token, address(bytes20(owner())), unexpectedBalance);
      emit UnexpectedIntialBalance(token, unexpectedBalance);
    }
  }

  function swap(address src, uint srcAmount, address dest, uint maxDestAmount, uint minConversionRate) public payable {

    require(src != dest, "src == dest");
    require(srcAmount > 0, "srcAmount == 0");

    _freeUnexpectedTokens(src);
    _freeUnexpectedTokens(dest);

    if (src == ETHER) {
      require(msg.value == srcAmount, "msg.value != srcAmount");
    } else {
      require(
        IBadStaticCallERC20(src).allowance(msg.sender, address(this)) >= srcAmount,
        "ERC20 allowance < srcAmount"
      );
      IERC20(src).safeTransferFrom(msg.sender, address(this), srcAmount);
    }

    uint256 spread = getSpread(src, dest);

    uint256 adaptedMinRate = minConversionRate.mul(spreadUnit).div(spreadUnit - spread);
    uint256 adaptedMaxDestAmount = maxDestAmount.mul(spreadUnit).div(spreadUnit - spread);
    uint256 destTradedAmount = doNetworkTrade(src, srcAmount, dest, adaptedMaxDestAmount, adaptedMinRate);

    uint256 notTraded = _myBalance(src);
    uint256 srcTradedAmount = srcAmount.sub(notTraded);
    require(srcTradedAmount > 0, "no traded tokens");
    require(
      _myBalance(dest) >= destTradedAmount,
      "No enough dest tokens after trade"
    );
    uint256 toUserAmount = _payFee(dest, destTradedAmount, spread);
    _transfer(dest, msg.sender, toUserAmount);
    if (notTraded > 0) {
      _transfer(src, msg.sender, notTraded);
    }

    emit LogTokenSwap(
      msg.sender,
      src,
      srcTradedAmount,
      dest,
      toUserAmount
    );
  }

  function doNetworkTrade(address src, uint srcAmount, address dest, uint maxDestAmount, uint minConversionRate) internal returns(uint256);


  function _payFee(address token, uint destTradedAmount, uint spread) private returns(uint256 toUserAmount) {

    uint256 fee = destTradedAmount.mul(spread).div(spreadUnit);
    toUserAmount = destTradedAmount.sub(fee);
    super._payFee(token == ETHER ? address(0) : token, fee);
  }

  function _myEthBalance() private view returns(uint256) {

    address self = address(this);
    return self.balance;
  }

  function _myBalance(address token) private returns(uint256) {

    return token == ETHER
      ? _myEthBalance()
      : IBadStaticCallERC20(token).balanceOf(address(this));
  }

  function _transfer(address token, address payable recipient, uint256 amount) private {

    if (token == ETHER) {
      recipient.transfer(amount);
    } else {
      IERC20(token).safeTransfer(recipient, amount);
    }
  }

}


pragma solidity ^0.5.0;


contract ERC20Detailed is IERC20 {

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
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
}


pragma solidity ^0.5.0;

library LowLevel {

  function staticCallContractAddr(address target, bytes memory payload) internal view
    returns (bool success_, address result_)
  {

    (bool success, bytes memory result) = address(target).staticcall(payload);
    if (success && result.length == 32) {
      return (true, abi.decode(result, (address)));
    }
    return (false, address(0));
  }

  function callContractAddr(address target, bytes memory payload) internal
    returns (bool success_, address result_)
  {

    (bool success, bytes memory result) = address(target).call(payload);
    if (success && result.length == 32) {
      return (true, abi.decode(result, (address)));
    }
    return (false, address(0));
  }

  function staticCallContractUint(address target, bytes memory payload) internal view
    returns (bool success_, uint result_)
  {

    (bool success, bytes memory result) = address(target).staticcall(payload);
    if (success && result.length == 32) {
      return (true, abi.decode(result, (uint)));
    }
    return (false, 0);
  }

  function callContractUint(address target, bytes memory payload) internal
    returns (bool success_, uint result_)
  {

    (bool success, bytes memory result) = address(target).call(payload);
    if (success && result.length == 32) {
      return (true, abi.decode(result, (uint)));
    }
    return (false, 0);
  }
}


pragma solidity ^0.5.0;





contract RateNormalization is Ownable {

  using SafeMath for uint;

  struct RateAdjustment {
    uint factor;
    bool multiply;
  }

  mapping (address => mapping(address => RateAdjustment)) public rateAdjustment;
  mapping (address => uint) public forcedDecimals;

  function _getAdjustment(address src, address dest) private view returns(RateAdjustment memory) {

    RateAdjustment memory adj = rateAdjustment[src][dest];
    if (adj.factor == 0) {
      uint srcDecimals = _getDecimals(src);
      uint destDecimals = _getDecimals(dest);
      if (srcDecimals != destDecimals) {
        if (srcDecimals > destDecimals) {
          adj.multiply = true;
          adj.factor = 10 ** (srcDecimals - destDecimals);
        } else {
          adj.multiply = false;
          adj.factor = 10 ** (destDecimals - srcDecimals);
        }
      }
    }
    return adj;
  }

  function normalizeRate(address src, address dest, uint256 rate) public view
    returns(uint)
  {

    RateAdjustment memory adj = _getAdjustment(src, dest);
    if (adj.factor > 1) {
      rate = adj.multiply
        ? rate.mul(adj.factor)
        : rate.div(adj.factor);
    }
    return rate;
  }

  function denormalizeRate(address src, address dest, uint256 rate) public view
    returns(uint)
  {

    RateAdjustment memory adj = _getAdjustment(src, dest);
    if (adj.factor > 1) {
      rate = adj.multiply  // invert multiply/divide for denormalization
        ? rate.div(adj.factor)
        : rate.mul(adj.factor);
    }
    return rate;
  }

  function denormalizeRate(address src, address dest, uint256 rate, uint256 slippage) public view
    returns(uint, uint)
  {

    RateAdjustment memory adj = _getAdjustment(src, dest);
    if (adj.factor > 1) {
      if (adj.multiply) {
        rate = rate.div(adj.factor);
        slippage = slippage.div(adj.factor);
      } else {
        rate = rate.mul(adj.factor);
        slippage = slippage.mul(adj.factor);
      }
    }
    return (rate, slippage);
  }

  function _getDecimals(address token) internal view returns(uint) {

    uint forced = forcedDecimals[token];
    if (forced > 0) return forced;
    bytes memory payload = abi.encodeWithSignature("decimals()");
    (bool success, uint decimals) = LowLevel.staticCallContractUint(token, payload);
    require(success, "the token doesn't expose the decimals number");
    return decimals;
  }

  function setRateAdjustmentFactor(address src, address dest, uint factor, bool multiply) public onlyOwner {

    rateAdjustment[src][dest] = RateAdjustment(factor, multiply);
    rateAdjustment[dest][src] = RateAdjustment(factor, !multiply);
  }

  function setForcedDecimals(address token, uint decimals) public onlyOwner {

    forcedDecimals[token] = decimals;
  }

}


pragma solidity >=0.5.0;

interface IWETH {

    function deposit() external payable;

    function transfer(address to, uint value) external returns (bool);

    function withdraw(uint) external;

}


pragma solidity ^0.5.0;









contract BalancerSwap2 is BMath, RateNormalization, NetworkBasedTokenSwap {

  using SafeMath for uint;
  using SafeStaticCallERC20 for IBadStaticCallERC20;
  uint constant MAX_PRICE = ~uint256(0); // type(uint256).max
  uint constant expScale = 1e18;

  IWETH public weth;
  mapping (address => mapping (address => BPool)) pairPool;

  constructor(address _weth, address payable _wallet, uint _spread)
    public NetworkBasedTokenSwap(_wallet, _spread)
  {
    setForcedDecimals(ETHER, 18);
    setWeth(_weth);
  }

  function setWeth(address _weth) public onlyOwner {

    require(_weth != address(0), "_weth == address(0)");
    weth = IWETH(_weth);
  }

  function _eventuallyTranslateEther(address token) private view returns(address) {

    return token == ETHER ? address(weth) : token;
  }

  function setPool(address token1, address token2, address _pool) public onlyOwner {

    if (token1 >= token2) {
      pairPool[token1][token2] = BPool(_pool);
    } else {
      pairPool[token2][token1] = BPool(_pool);
    }
  }

  function getPool(address token1, address token2) public view returns(BPool) {

    return token1 > token2
      ? pairPool[token1][token2]
      : pairPool[token2][token1];
  }

  function _getBalancerRate(BPool bpool, address src, address dest, uint srcAmount) internal view returns(uint rate, uint destAmount) {

    uint balanceIn = bpool.getBalance(src);
    uint balanceOut = bpool.getBalance(dest);
    uint weightIn = bpool.getNormalizedWeight(src);
    uint weightOut = bpool.getNormalizedWeight(dest);
    uint swapFee = bpool.getSwapFee();
    destAmount = calcOutGivenIn(
      balanceIn,
      weightIn,
      balanceOut,
      weightOut,
      srcAmount,
      swapFee
    );
    rate = _calcRate(srcAmount, destAmount);
  }

  function _calcRate(uint srcAmount, uint destAmount) internal pure returns(uint) {

    return destAmount.mul(expScale).div(srcAmount);
  }

  function getNetworkRate(address _src, address _dest, uint256 srcAmount) internal view
    returns(uint expectedRate, uint slippageRate)
  {

    address src = _eventuallyTranslateEther(_src);
    address dest = _eventuallyTranslateEther(_dest);
    (uint rate, ) = _getBalancerRate(getPool(src, dest), src, dest, srcAmount);
    uint normalizedRate = normalizeRate(src, dest, rate);
    return (normalizedRate, normalizedRate);
  }


  function _approveWithReset(address token, address spender, uint amount) internal {

    if (IBadStaticCallERC20(token).allowance(address(this), spender) > 0) {
      IBadStaticCallERC20(token).safeApprove(spender, 0);
    }
    IBadStaticCallERC20(token).safeApprove(spender, amount);
  }

  function doNetworkTrade(address src, uint srcAmount, address dest, uint maxDestAmount, uint minConversionRate)
    internal returns(uint256)
  {

    BPool pool = getPool(src, dest);
    address srcToTrade = _eventuallyTranslateEther(src);
    address destToTrade = _eventuallyTranslateEther(dest);
    (uint rate, uint destAmount) = _getBalancerRate(pool, srcToTrade, destToTrade, srcAmount);
    uint toTradeAmount = destAmount > maxDestAmount
      ? maxDestAmount.mul(expScale).div(rate)
      : srcAmount;

    if (src == ETHER) {
      weth.deposit.value(toTradeAmount)();
    }

    _approveWithReset(srcToTrade, address(pool), toTradeAmount);
    (uint finalDestAmount,) = pool.swapExactAmountIn(srcToTrade, toTradeAmount, destToTrade, 0, MAX_PRICE);

    require(normalizeRate(src, dest, _calcRate(toTradeAmount, finalDestAmount)) >= minConversionRate, "cannot satisfy minConversionRate");

    if (dest == ETHER) {
      weth.withdraw(finalDestAmount);
    }

    return finalDestAmount;
  }
}