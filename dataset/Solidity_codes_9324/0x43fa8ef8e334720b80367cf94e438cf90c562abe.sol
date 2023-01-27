



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





pragma solidity 0.6.12;

contract BConst {

    uint public constant BONE              = 10**18;
    uint public constant MIN_BOUND_TOKENS  = 2;
    uint public constant MAX_BOUND_TOKENS  = 9;
    uint public constant MIN_FEE           = BONE / 10**6;
    uint public constant MAX_FEE           = BONE / 10;
    uint public constant MIN_WEIGHT        = 1000000000;
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





pragma solidity 0.6.12;


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

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

      require(b > 0, "ERR_DIV_ZERO");
      return a / b;
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



contract BMath is BConst, BNum, BMathInterface {

    function calcSpotPrice(
        uint tokenBalanceIn,
        uint tokenWeightIn,
        uint tokenBalanceOut,
        uint tokenWeightOut,
        uint swapFee
    )
        public pure virtual
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
        public pure virtual
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
        public pure virtual override
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
        public pure virtual
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
        public pure virtual override
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
        public pure virtual
        returns (uint tokenAmountOut)
    {

        uint normalizedWeight = bdiv(tokenWeightOut, totalWeight);
        uint newPoolSupply = bsub(poolSupply, poolAmountIn);
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
        public pure virtual
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
        uint poolAmountIn = bsub(poolSupply, newPoolSupply);
        return poolAmountIn;
    }
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
pragma experimental ABIEncoderV2;


interface WrappedPiErc20Interface is IERC20 {

  function deposit(uint256 _amount) external payable returns (uint256);


  function withdraw(uint256 _amount) external payable returns (uint256);


  function changeRouter(address _newRouter) external;


  function setEthFee(uint256 _newEthFee) external;


  function withdrawEthFee(address payable receiver) external;


  function approveUnderlying(address _to, uint256 _amount) external;


  function callExternal(
    address voting,
    bytes4 signature,
    bytes calldata args,
    uint256 value
  ) external;


  struct ExternalCallData {
    address destination;
    bytes4 signature;
    bytes args;
    uint256 value;
  }

  function callExternalMultiple(ExternalCallData[] calldata calls) external;


  function getUnderlyingBalance() external view returns (uint256);

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


pragma solidity ^0.6.0;

contract ControllerOwnable {

    address private _controller;

    event SetController(address indexed previousController, address indexed newController);

    constructor () internal {
        _controller = msg.sender;
        emit SetController(address(0), _controller);
    }

    function getController() public view returns (address) {

        return _controller;
    }

    modifier onlyController() {

        require(_controller == msg.sender, "NOT_CONTROLLER");
        _;
    }

    function setController(address newController) public virtual onlyController {

        require(newController != address(0), "ControllerOwnable: new controller is the zero address");
        emit SetController(_controller, newController);
        _controller = newController;
    }
}


pragma solidity 0.6.12;

contract PowerIndexWrapper is ControllerOwnable, BMath, PowerIndexWrapperInterface {

  using SafeMath for uint256;

  event SetPiTokenForUnderlying(address indexed underlyingToken, address indexed piToken);
  event UpdatePiTokenEthFee(address indexed piToken, uint256 ethFee);

  BPoolInterface public immutable bpool;

  mapping(address => address) public piTokenByUnderlying;
  mapping(address => address) public underlyingByPiToken;
  mapping(address => uint256) public ethFeeByPiToken;

  constructor(address _bpool) public ControllerOwnable() {
    bpool = BPoolInterface(_bpool);
    BPoolInterface(_bpool).approve(_bpool, uint256(-1));

    address[] memory tokens = BPoolInterface(_bpool).getCurrentTokens();
    uint256 len = tokens.length;
    for (uint256 i = 0; i < len; i++) {
      IERC20(tokens[i]).approve(_bpool, uint256(-1));
    }
  }

  function withdrawOddEthFee(address payable _recipient) external override onlyController {

    _recipient.transfer(address(this).balance);
  }

  function setPiTokenForUnderlyingsMultiple(address[] calldata _underlyingTokens, address[] calldata _piTokens)
    external
    override
    onlyController
  {

    uint256 len = _underlyingTokens.length;
    require(len == _piTokens.length, "LENGTH_DONT_MATCH");

    for (uint256 i = 0; i < len; i++) {
      _setPiTokenForUnderlying(_underlyingTokens[i], _piTokens[i]);
    }
  }

  function setPiTokenForUnderlying(address _underlyingToken, address _piToken) external override onlyController {

    _setPiTokenForUnderlying(_underlyingToken, _piToken);
  }

  function updatePiTokenEthFees(address[] calldata _underlyingTokens) external override {

    uint256 len = _underlyingTokens.length;

    for (uint256 i = 0; i < len; i++) {
      _updatePiTokenEthFee(piTokenByUnderlying[_underlyingTokens[i]]);
    }
  }

  function swapExactAmountOut(
    address tokenIn,
    uint256 maxAmountIn,
    address tokenOut,
    uint256 tokenAmountOut,
    uint256 maxPrice
  ) external payable override returns (uint256 tokenAmountIn, uint256 spotPriceAfter) {

    (address actualTokenIn, uint256 actualMaxAmountIn) = _getActualTokenAndAmount(tokenIn, maxAmountIn);
    (address actualTokenOut, uint256 actualTokenAmountOut) = _getActualTokenAndAmount(tokenOut, tokenAmountOut);
    uint256 actualMaxPrice =
      getActualMaxPrice(maxAmountIn, actualMaxAmountIn, tokenAmountOut, actualTokenAmountOut, maxPrice);
    uint256 amountInRate = actualMaxAmountIn.mul(uint256(1 ether)).div(maxAmountIn);

    uint256 prevMaxAmount = actualMaxAmountIn;
    actualMaxAmountIn = calcInGivenOut(
      bpool.getBalance(actualTokenIn),
      bpool.getDenormalizedWeight(actualTokenIn),
      bpool.getBalance(actualTokenOut),
      bpool.getDenormalizedWeight(actualTokenOut),
      actualTokenAmountOut,
      bpool.getSwapFee()
    );
    if (prevMaxAmount > actualMaxAmountIn) {
      maxAmountIn = actualMaxAmountIn.mul(uint256(1 ether)).div(amountInRate);
    } else {
      actualMaxAmountIn = prevMaxAmount;
    }

    _processUnderlyingTokenIn(tokenIn, maxAmountIn);

    (tokenAmountIn, spotPriceAfter) = bpool.swapExactAmountOut(
      actualTokenIn,
      actualMaxAmountIn,
      actualTokenOut,
      actualTokenAmountOut,
      actualMaxPrice
    );

    _processUnderlyingOrPiTokenOutBalance(tokenOut);

    return (tokenAmountIn, spotPriceAfter);
  }

  function swapExactAmountIn(
    address tokenIn,
    uint256 tokenAmountIn,
    address tokenOut,
    uint256 minAmountOut,
    uint256 maxPrice
  ) external payable override returns (uint256 tokenAmountOut, uint256 spotPriceAfter) {

    (address actualTokenIn, uint256 actualAmountIn) = _processUnderlyingTokenIn(tokenIn, tokenAmountIn);
    (address actualTokenOut, uint256 actualMinAmountOut) = _getActualTokenAndAmount(tokenOut, minAmountOut);
    uint256 actualMaxPrice =
      getActualMaxPrice(tokenAmountIn, actualAmountIn, minAmountOut, actualMinAmountOut, maxPrice);

    (tokenAmountOut, spotPriceAfter) = bpool.swapExactAmountIn(
      actualTokenIn,
      actualAmountIn,
      actualTokenOut,
      actualMinAmountOut,
      actualMaxPrice
    );

    _processUnderlyingOrPiTokenOutBalance(tokenOut);

    return (tokenAmountOut, spotPriceAfter);
  }

  function joinPool(uint256 poolAmountOut, uint256[] memory maxAmountsIn) external payable override {

    address[] memory tokens = getCurrentTokens();
    uint256 len = tokens.length;
    require(maxAmountsIn.length == len, "ERR_LENGTH_MISMATCH");

    uint256 ratio = poolAmountOut.mul(1 ether).div(bpool.totalSupply()).add(100);

    for (uint256 i = 0; i < len; i++) {
      (address actualToken, uint256 actualMaxAmountIn) = _getActualTokenAndAmount(tokens[i], maxAmountsIn[i]);
      uint256 amountInRate = actualMaxAmountIn.mul(uint256(1 ether)).div(maxAmountsIn[i]);

      uint256 prevMaxAmount = actualMaxAmountIn;
      actualMaxAmountIn = ratio.mul(bpool.getBalance(actualToken)).div(1 ether);
      if (prevMaxAmount > actualMaxAmountIn) {
        maxAmountsIn[i] = actualMaxAmountIn.mul(uint256(1 ether)).div(amountInRate);
      } else {
        actualMaxAmountIn = prevMaxAmount;
      }

      _processUnderlyingTokenIn(tokens[i], maxAmountsIn[i]);
      maxAmountsIn[i] = actualMaxAmountIn;
    }
    bpool.joinPool(poolAmountOut, maxAmountsIn);
    require(bpool.transfer(msg.sender, bpool.balanceOf(address(this))), "ERR_TRANSFER_FAILED");
  }

  function exitPool(uint256 poolAmountIn, uint256[] memory minAmountsOut) external payable override {

    address[] memory tokens = getCurrentTokens();
    uint256 len = tokens.length;
    require(minAmountsOut.length == len, "ERR_LENGTH_MISMATCH");

    bpool.transferFrom(msg.sender, address(this), poolAmountIn);

    for (uint256 i = 0; i < len; i++) {
      (, minAmountsOut[i]) = _getActualTokenAndAmount(tokens[i], minAmountsOut[i]);
    }

    bpool.exitPool(poolAmountIn, minAmountsOut);

    for (uint256 i = 0; i < len; i++) {
      _processUnderlyingOrPiTokenOutBalance(tokens[i]);
    }
  }

  function joinswapExternAmountIn(
    address tokenIn,
    uint256 tokenAmountIn,
    uint256 minPoolAmountOut
  ) external payable override returns (uint256 poolAmountOut) {

    (address actualTokenIn, uint256 actualAmountIn) = _processUnderlyingTokenIn(tokenIn, tokenAmountIn);
    poolAmountOut = bpool.joinswapExternAmountIn(actualTokenIn, actualAmountIn, minPoolAmountOut);
    require(bpool.transfer(msg.sender, bpool.balanceOf(address(this))), "ERR_TRANSFER_FAILED");
    return poolAmountOut;
  }

  function joinswapPoolAmountOut(
    address tokenIn,
    uint256 poolAmountOut,
    uint256 maxAmountIn
  ) external payable override returns (uint256 tokenAmountIn) {

    (address actualTokenIn, uint256 actualMaxAmountIn) = _getActualTokenAndAmount(tokenIn, maxAmountIn);
    uint256 amountInRate = actualMaxAmountIn.mul(uint256(1 ether)).div(maxAmountIn);

    uint256 prevMaxAmount = maxAmountIn;
    maxAmountIn = calcSingleInGivenPoolOut(
      getBalance(tokenIn),
      bpool.getDenormalizedWeight(actualTokenIn),
      bpool.totalSupply(),
      bpool.getTotalDenormalizedWeight(),
      poolAmountOut,
      bpool.getSwapFee()
    );
    if (prevMaxAmount > maxAmountIn) {
      maxAmountIn = maxAmountIn;
      actualMaxAmountIn = maxAmountIn.mul(amountInRate).div(uint256(1 ether));
    } else {
      maxAmountIn = prevMaxAmount;
    }

    _processUnderlyingTokenIn(tokenIn, maxAmountIn);
    tokenAmountIn = bpool.joinswapPoolAmountOut(actualTokenIn, poolAmountOut, actualMaxAmountIn);
    require(bpool.transfer(msg.sender, bpool.balanceOf(address(this))), "ERR_TRANSFER_FAILED");
    return tokenAmountIn;
  }

  function exitswapPoolAmountIn(
    address tokenOut,
    uint256 poolAmountIn,
    uint256 minAmountOut
  ) external payable override returns (uint256 tokenAmountOut) {

    require(bpool.transferFrom(msg.sender, address(this), poolAmountIn), "ERR_TRANSFER_FAILED");

    (address actualTokenOut, uint256 actualMinAmountOut) = _getActualTokenAndAmount(tokenOut, minAmountOut);
    tokenAmountOut = bpool.exitswapPoolAmountIn(actualTokenOut, poolAmountIn, actualMinAmountOut);
    _processUnderlyingOrPiTokenOutBalance(tokenOut);
    return tokenAmountOut;
  }

  function exitswapExternAmountOut(
    address tokenOut,
    uint256 tokenAmountOut,
    uint256 maxPoolAmountIn
  ) external payable override returns (uint256 poolAmountIn) {

    require(bpool.transferFrom(msg.sender, address(this), maxPoolAmountIn), "ERR_TRANSFER_FAILED");

    (address actualTokenOut, uint256 actualTokenAmountOut) = _getActualTokenAndAmount(tokenOut, tokenAmountOut);
    poolAmountIn = bpool.exitswapExternAmountOut(actualTokenOut, actualTokenAmountOut, maxPoolAmountIn);
    _processUnderlyingOrPiTokenOutBalance(tokenOut);
    require(bpool.transfer(msg.sender, maxPoolAmountIn.sub(poolAmountIn)), "ERR_TRANSFER_FAILED");
    return poolAmountIn;
  }

  function calcInGivenOut(
    uint256 tokenBalanceIn,
    uint256 tokenWeightIn,
    uint256 tokenBalanceOut,
    uint256 tokenWeightOut,
    uint256 tokenAmountOut,
    uint256 swapFee
  ) public pure override returns (uint256) {

    return
      super.calcInGivenOut(tokenBalanceIn, tokenWeightIn, tokenBalanceOut, tokenWeightOut, tokenAmountOut, swapFee).add(
        1
      );
  }

  function calcSingleInGivenPoolOut(
    uint256 tokenBalanceIn,
    uint256 tokenWeightIn,
    uint256 poolSupply,
    uint256 totalWeight,
    uint256 poolAmountOut,
    uint256 swapFee
  ) public pure override returns (uint256) {

    return
      super
        .calcSingleInGivenPoolOut(tokenBalanceIn, tokenWeightIn, poolSupply, totalWeight, poolAmountOut, swapFee)
        .add(1);
  }

  function calcPoolInGivenSingleOut(
    uint256 tokenBalanceOut,
    uint256 tokenWeightOut,
    uint256 poolSupply,
    uint256 totalWeight,
    uint256 tokenAmountOut,
    uint256 swapFee
  ) public pure override returns (uint256) {

    return
      super
        .calcPoolInGivenSingleOut(tokenBalanceOut, tokenWeightOut, poolSupply, totalWeight, tokenAmountOut, swapFee)
        .add(1);
  }

  function calcSpotPrice(
    uint256 tokenBalanceIn,
    uint256 tokenWeightIn,
    uint256 tokenBalanceOut,
    uint256 tokenWeightOut,
    uint256 swapFee
  ) public pure override returns (uint256) {

    return super.calcSpotPrice(tokenBalanceIn, tokenWeightIn, tokenBalanceOut, tokenWeightOut, swapFee).add(1);
  }

  function calcOutGivenIn(
    uint256 tokenBalanceIn,
    uint256 tokenWeightIn,
    uint256 tokenBalanceOut,
    uint256 tokenWeightOut,
    uint256 tokenAmountIn,
    uint256 swapFee
  ) public pure override returns (uint256) {

    return
      super.calcOutGivenIn(tokenBalanceIn, tokenWeightIn, tokenBalanceOut, tokenWeightOut, tokenAmountIn, swapFee).sub(
        10
      );
  }

  function calcPoolOutGivenSingleIn(
    uint256 tokenBalanceIn,
    uint256 tokenWeightIn,
    uint256 poolSupply,
    uint256 totalWeight,
    uint256 tokenAmountIn,
    uint256 swapFee
  ) public pure override returns (uint256) {

    return
      super
        .calcPoolOutGivenSingleIn(tokenBalanceIn, tokenWeightIn, poolSupply, totalWeight, tokenAmountIn, swapFee)
        .sub(10);
  }

  function calcSingleOutGivenPoolIn(
    uint256 tokenBalanceOut,
    uint256 tokenWeightOut,
    uint256 poolSupply,
    uint256 totalWeight,
    uint256 poolAmountIn,
    uint256 swapFee
  ) public pure override returns (uint256) {

    return
      super
        .calcSingleOutGivenPoolIn(tokenBalanceOut, tokenWeightOut, poolSupply, totalWeight, poolAmountIn, swapFee)
        .sub(10);
  }

  function getDenormalizedWeight(address token) external view returns (uint256) {

    return bpool.getDenormalizedWeight(_getActualToken(token));
  }

  function getSwapFee() external view returns (uint256) {

    return bpool.getSwapFee();
  }

  function calcEthFeeForTokens(address[] memory tokens) external view override returns (uint256 feeSum) {

    uint256 len = tokens.length;
    for (uint256 i = 0; i < len; i++) {
      address piToken = address(0);
      if (underlyingByPiToken[tokens[i]] != address(0)) {
        piToken = tokens[i];
      } else if (piTokenByUnderlying[tokens[i]] != address(0)) {
        piToken = piTokenByUnderlying[tokens[i]];
      }
      if (piToken != address(0)) {
        feeSum = feeSum.add(WrappedPiErc20EthFeeInterface(piToken).ethFee());
      }
    }
  }

  function getCurrentTokens() public view override returns (address[] memory tokens) {

    tokens = bpool.getCurrentTokens();

    uint256 len = tokens.length;
    for (uint256 i = 0; i < len; i++) {
      if (underlyingByPiToken[tokens[i]] != address(0)) {
        tokens[i] = underlyingByPiToken[tokens[i]];
      }
    }
  }

  function getFinalTokens() public view override returns (address[] memory tokens) {

    return getCurrentTokens();
  }

  function getBalance(address _token) public view override returns (uint256) {

    address piTokenAddress = piTokenByUnderlying[_token];
    if (piTokenAddress == address(0)) {
      return bpool.getBalance(_token);
    }
    return WrappedPiErc20EthFeeInterface(piTokenAddress).getUnderlyingEquivalentForPi(bpool.getBalance(piTokenAddress));
  }

  function getActualMaxPrice(
    uint256 amountIn,
    uint256 actualAmountIn,
    uint256 amountOut,
    uint256 actualAmountOut,
    uint256 maxPrice
  ) public returns (uint256 actualMaxPrice) {

    uint256 amountInRate = amountIn.mul(uint256(1 ether)).div(actualAmountIn);
    uint256 amountOutRate = actualAmountOut.mul(uint256(1 ether)).div(amountOut);
    return
      amountInRate > amountOutRate
        ? maxPrice.mul(amountInRate).div(amountOutRate)
        : maxPrice.mul(amountOutRate).div(amountInRate);
  }

  function _processUnderlyingTokenIn(address _underlyingToken, uint256 _amount)
    internal
    returns (address actualToken, uint256 actualAmount)
  {

    if (_amount == 0) {
      return (_underlyingToken, _amount);
    }
    require(IERC20(_underlyingToken).transferFrom(msg.sender, address(this), _amount), "ERR_TRANSFER_FAILED");

    actualToken = piTokenByUnderlying[_underlyingToken];
    if (actualToken == address(0)) {
      return (_underlyingToken, _amount);
    }
    actualAmount = WrappedPiErc20Interface(actualToken).deposit{ value: ethFeeByPiToken[actualToken] }(_amount);
  }

  function _processPiTokenOutBalance(address _piToken) internal {

    uint256 balance = WrappedPiErc20EthFeeInterface(_piToken).balanceOfUnderlying(address(this));

    WrappedPiErc20Interface(_piToken).withdraw{ value: ethFeeByPiToken[_piToken] }(balance);

    require(IERC20(underlyingByPiToken[_piToken]).transfer(msg.sender, balance), "ERR_TRANSFER_FAILED");
  }

  function _processUnderlyingTokenOutBalance(address _underlyingToken) internal returns (uint256 balance) {

    balance = IERC20(_underlyingToken).balanceOf(address(this));
    require(IERC20(_underlyingToken).transfer(msg.sender, balance), "ERR_TRANSFER_FAILED");
  }

  function _processUnderlyingOrPiTokenOutBalance(address _underlyingOrPiToken) internal {

    address piToken = piTokenByUnderlying[_underlyingOrPiToken];
    if (piToken == address(0)) {
      _processUnderlyingTokenOutBalance(_underlyingOrPiToken);
    } else {
      _processPiTokenOutBalance(piToken);
    }
  }

  function _getActualToken(address token) internal view returns (address) {

    address piToken = piTokenByUnderlying[token];
    return piToken == address(0) ? token : piToken;
  }

  function _getActualTokenAndAmount(address token, uint256 amount)
    internal
    view
    returns (address actualToken, uint256 actualAmount)
  {

    address piToken = piTokenByUnderlying[token];
    if (piToken == address(0)) {
      return (token, amount);
    }
    return (piToken, WrappedPiErc20EthFeeInterface(piToken).getPiEquivalentForUnderlying(amount));
  }

  function _setPiTokenForUnderlying(address underlyingToken, address piToken) internal {

    piTokenByUnderlying[underlyingToken] = piToken;
    if (piToken == address(0)) {
      IERC20(underlyingToken).approve(address(bpool), uint256(-1));
    } else {
      underlyingByPiToken[piToken] = underlyingToken;
      IERC20(piToken).approve(address(bpool), uint256(-1));
      IERC20(underlyingToken).approve(piToken, uint256(-1));
      _updatePiTokenEthFee(piToken);
    }
    emit SetPiTokenForUnderlying(underlyingToken, piToken);
  }

  function _updatePiTokenEthFee(address piToken) internal {

    if (piToken == address(0)) {
      return;
    }
    uint256 ethFee = WrappedPiErc20EthFeeInterface(piToken).ethFee();
    if (ethFeeByPiToken[piToken] == ethFee) {
      return;
    }
    ethFeeByPiToken[piToken] = ethFee;
    emit UpdatePiTokenEthFee(piToken, ethFee);
  }
}

interface WrappedPiErc20EthFeeInterface {

  function ethFee() external view returns (uint256);


  function router() external view returns (address);


  function getPiEquivalentForUnderlying(uint256 _underlyingAmount) external view returns (uint256);


  function getUnderlyingEquivalentForPi(uint256 _piAmount) external view returns (uint256);


  function balanceOfUnderlying(address _account) external view returns (uint256);

}