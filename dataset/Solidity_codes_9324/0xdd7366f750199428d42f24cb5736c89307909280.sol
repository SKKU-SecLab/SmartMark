



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



contract BTokenBase is BNum {


    mapping(address => uint)                   internal _balance;
    mapping(address => mapping(address=>uint)) internal _allowance;
    uint internal _totalSupply;

    event Approval(address indexed src, address indexed dst, uint amt);
    event Transfer(address indexed src, address indexed dst, uint amt);

    function _mint(uint amt) internal {

        _balance[address(this)] = badd(_balance[address(this)], amt);
        _totalSupply = badd(_totalSupply, amt);
        emit Transfer(address(0), address(this), amt);
    }

    function _burn(uint amt) internal {

        require(_balance[address(this)] >= amt, "ERR_INSUFFICIENT_BAL");
        _balance[address(this)] = bsub(_balance[address(this)], amt);
        _totalSupply = bsub(_totalSupply, amt);
        emit Transfer(address(this), address(0), amt);
    }

    function _move(address src, address dst, uint amt) internal {

        require(_balance[src] >= amt, "ERR_INSUFFICIENT_BAL");
        _validateAddress(src);
        _validateAddress(dst);
        _balance[src] = bsub(_balance[src], amt);
        _balance[dst] = badd(_balance[dst], amt);
        emit Transfer(src, dst, amt);
    }

    function _push(address to, uint amt) internal {

        _move(address(this), to, amt);
    }

    function _pull(address from, uint amt) internal {

        _move(from, address(this), amt);
    }

    function _validateAddress(address addr) internal {

        require(addr != address(0), "ERR_NULL_ADDRESS");
    }
}

contract BToken is BTokenBase, IERC20 {


    string  internal _name;
    string  internal _symbol;
    uint8   private _decimals = 18;

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns(uint8) {

        return _decimals;
    }

    function allowance(address src, address dst) external override view returns (uint) {

        return _allowance[src][dst];
    }

    function balanceOf(address whom) external override view returns (uint) {

        return _balance[whom];
    }

    function totalSupply() public override view returns (uint) {

        return _totalSupply;
    }

    function approve(address dst, uint amt) external override returns (bool) {

        _validateAddress(dst);
        _allowance[msg.sender][dst] = amt;
        emit Approval(msg.sender, dst, amt);
        return true;
    }

    function increaseApproval(address dst, uint amt) external returns (bool) {

        _validateAddress(dst);
        _allowance[msg.sender][dst] = badd(_allowance[msg.sender][dst], amt);
        emit Approval(msg.sender, dst, _allowance[msg.sender][dst]);
        return true;
    }

    function decreaseApproval(address dst, uint amt) external returns (bool) {

        _validateAddress(dst);
        uint oldValue = _allowance[msg.sender][dst];
        if (amt > oldValue) {
            _allowance[msg.sender][dst] = 0;
        } else {
            _allowance[msg.sender][dst] = bsub(oldValue, amt);
        }
        emit Approval(msg.sender, dst, _allowance[msg.sender][dst]);
        return true;
    }

    function transfer(address dst, uint amt) external override returns (bool) {

        _move(msg.sender, dst, amt);
        return true;
    }

    function transferFrom(address src, address dst, uint amt) external override returns (bool) {

        require(msg.sender == src || amt <= _allowance[src][msg.sender], "ERR_BTOKEN_BAD_CALLER");
        _move(src, dst, amt);
        if (msg.sender != src && _allowance[src][msg.sender] != uint256(-1)) {
            _allowance[src][msg.sender] = bsub(_allowance[src][msg.sender], amt);
            emit Approval(src, msg.sender, _allowance[src][msg.sender]);
        }
        return true;
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

interface IPoolRestrictions {

  function getMaxTotalSupply(address _pool) external view returns (uint256);


  function isVotingSignatureAllowed(address _votingAddress, bytes4 _signature) external view returns (bool);


  function isVotingSenderAllowed(address _votingAddress, address _sender) external view returns (bool);


  function isWithoutFee(address _addr) external view returns (bool);

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





pragma solidity 0.6.12;






contract BPool is BToken, BMath, BPoolInterface {

    using SafeERC20 for IERC20;

    struct Record {
        bool bound;   // is token bound to pool
        uint index;   // private
        uint denorm;  // denormalized weight
        uint balance;
    }


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

    event LOG_CALL_VOTING(
        address indexed voting,
        bool    indexed success,
        bytes4  indexed inputSig,
        bytes           inputData,
        bytes           outputData
    );

    event LOG_COMMUNITY_FEE(
        address indexed caller,
        address indexed receiver,
        address indexed token,
        uint256         tokenAmount
    );


    modifier _logs_() {

        emit LOG_CALL(msg.sig, msg.sender, msg.data);
        _;
    }

    modifier _lock_() {

        _preventReentrancy();
        _mutex = true;
        _;
        _mutex = false;
    }

    modifier _viewlock_() {

        _preventReentrancy();
        _;
    }


    bool private _mutex;

    address internal _controller;

    bool private _publicSwap;

    address private _wrapper;
    bool private _wrapperMode;

    IPoolRestrictions private _restrictions;

    uint private _swapFee;
    uint private _communitySwapFee;
    uint private _communityJoinFee;
    uint private _communityExitFee;
    address private _communityFeeReceiver;
    bool private _finalized;

    address[] internal _tokens;
    mapping(address => Record) internal _records;
    uint internal _totalWeight;

    mapping(address => uint256) internal _lastSwapBlock;

    constructor(string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _controller = msg.sender;
        _swapFee = MIN_FEE;
        _communitySwapFee = 0;
        _communityJoinFee = 0;
        _communityExitFee = 0;
        _publicSwap = false;
        _finalized = false;
    }


    function isBound(address t)
        external view override
        returns (bool)
    {

        return _records[t].bound;
    }

    function getNumTokens()
        external view
        returns (uint)
    {

        return _tokens.length;
    }

    function getCurrentTokens()
        external view override
        _viewlock_
        returns (address[] memory tokens)
    {

        return _tokens;
    }

    function getFinalTokens()
        external view override
        _viewlock_
        returns (address[] memory tokens)
    {

        _requireContractIsFinalized();
        return _tokens;
    }

    function getDenormalizedWeight(address token)
        external view override
        _viewlock_
        returns (uint)
    {


        _requireTokenIsBound(token);
        return _getDenormWeight(token);
    }

    function getTotalDenormalizedWeight()
        external view override
        _viewlock_
        returns (uint)
    {

        return _getTotalWeight();
    }

    function getNormalizedWeight(address token)
        external view
        _viewlock_
        returns (uint)
    {


        _requireTokenIsBound(token);
        return bdiv(_getDenormWeight(token), _getTotalWeight());
    }

    function getBalance(address token)
        external view override
        _viewlock_
        returns (uint)
    {


        _requireTokenIsBound(token);
        return _records[token].balance;
    }


    function isPublicSwap()
        external view override
        returns (bool)
    {

        return _publicSwap;
    }

    function isFinalized()
        external view override
        returns (bool)
    {

        return _finalized;
    }

    function getSwapFee()
        external view override
        _viewlock_
        returns (uint)
    {

        return _swapFee;
    }

    function getCommunityFee()
        external view override
        _viewlock_
        returns (uint communitySwapFee, uint communityJoinFee, uint communityExitFee, address communityFeeReceiver)
    {

        return (_communitySwapFee, _communityJoinFee, _communityExitFee, _communityFeeReceiver);
    }

    function getController()
        external view
        _viewlock_
        returns (address)
    {

        return _controller;
    }

    function getWrapper()
        external view
        _viewlock_
        returns (address)
    {

        return _wrapper;
    }

    function getWrapperMode()
        external view
        _viewlock_
        returns (bool)
    {

        return _wrapperMode;
    }

    function getRestrictions()
        external view override
        _viewlock_
        returns (address)
    {

        return address(_restrictions);
    }


    function setSwapFee(uint swapFee)
        external override
        _logs_
        _lock_
    {

        _onlyController();
        _requireFeeInBounds(swapFee);
        _swapFee = swapFee;
    }

    function setCommunityFeeAndReceiver(
        uint communitySwapFee,
        uint communityJoinFee,
        uint communityExitFee,
        address communityFeeReceiver
    )
        external override
        _logs_
        _lock_
    {

        _onlyController();
        _requireFeeInBounds(communitySwapFee);
        _requireFeeInBounds(communityJoinFee);
        _requireFeeInBounds(communityExitFee);
        _communitySwapFee = communitySwapFee;
        _communityJoinFee = communityJoinFee;
        _communityExitFee = communityExitFee;
        _communityFeeReceiver = communityFeeReceiver;
    }

    function setRestrictions(IPoolRestrictions restrictions)
        external
        _logs_
        _lock_
    {

        _onlyController();
        _restrictions = restrictions;
    }

    function setController(address manager)
        external override
        _logs_
        _lock_
    {

        _onlyController();
        _controller = manager;
    }

    function setPublicSwap(bool public_)
        external override
        _logs_
        _lock_
    {

        _requireContractIsNotFinalized();
        _onlyController();
        _publicSwap = public_;
    }

    function setWrapper(address wrapper, bool wrapperMode)
        external
        _logs_
        _lock_
    {

        _onlyController();
        _wrapper = wrapper;
        _wrapperMode = wrapperMode;
    }

    function finalize()
        external override
        _logs_
        _lock_
    {

        _onlyController();
        _requireContractIsNotFinalized();
        require(_tokens.length >= MIN_BOUND_TOKENS, "MIN_TOKENS");

        _finalized = true;
        _publicSwap = true;

        _mintPoolShare(INIT_POOL_SUPPLY);
        _pushPoolShare(msg.sender, INIT_POOL_SUPPLY);
    }




    function callVoting(address voting, bytes4 signature, bytes calldata args, uint256 value)
        external override
        _logs_
        _lock_
    {

        require(_restrictions.isVotingSignatureAllowed(voting, signature), "NOT_ALLOWED_SIG");
        _onlyController();

        (bool success, bytes memory data) = voting.call{ value: value }(abi.encodePacked(signature, args));
        require(success, "NOT_SUCCESS");
        emit LOG_CALL_VOTING(voting, success, signature, args, data);
    }


    function bind(address token, uint balance, uint denorm)
        public override
        virtual
        _logs_
    {

        _onlyController();
        require(!_records[token].bound, "IS_BOUND");

        require(_tokens.length < MAX_BOUND_TOKENS, "MAX_TOKENS");

        _records[token] = Record({
            bound: true,
            index: _tokens.length,
            denorm: 0,    // balance and denorm will be validated
            balance: 0   // and set by `rebind`
        });
        _tokens.push(token);
        rebind(token, balance, denorm);
    }

    function rebind(address token, uint balance, uint denorm)
        public override
        virtual
        _logs_
        _lock_
    {

        _onlyController();
        _requireTokenIsBound(token);

        require(denorm >= MIN_WEIGHT && denorm <= MAX_WEIGHT, "WEIGHT_BOUNDS");
        require(balance >= MIN_BALANCE, "MIN_BALANCE");

        uint oldWeight = _records[token].denorm;
        if (denorm > oldWeight) {
            _addTotalWeight(bsub(denorm, oldWeight));
        } else if (denorm < oldWeight) {
            _subTotalWeight(bsub(oldWeight, denorm));
        }
        _records[token].denorm = denorm;

        uint oldBalance = _records[token].balance;
        _records[token].balance = balance;
        if (balance > oldBalance) {
            _pullUnderlying(token, msg.sender, bsub(balance, oldBalance));
        } else if (balance < oldBalance) {
            uint tokenBalanceWithdrawn = bsub(oldBalance, balance);
            _pushUnderlying(token, msg.sender, tokenBalanceWithdrawn);
        }
    }

    function unbind(address token)
        public override
        virtual
        _logs_
        _lock_
    {

        _onlyController();
        _requireTokenIsBound(token);

        uint tokenBalance = _records[token].balance;

        _subTotalWeight(_records[token].denorm);

        uint index = _records[token].index;
        uint last = _tokens.length - 1;
        _tokens[index] = _tokens[last];
        _records[_tokens[index]].index = index;
        _tokens.pop();
        _records[token] = Record({
            bound: false,
            index: 0,
            denorm: 0,
            balance: 0
        });

        _pushUnderlying(token, msg.sender, tokenBalance);
    }

    function gulp(address token)
        external override
        _logs_
        _lock_
    {

        _onlyWrapperOrNotWrapperMode();
        if (_records[token].bound) {
          _records[token].balance = IERC20(token).balanceOf(address(this));
        } else {
          IERC20(token).safeTransfer(_communityFeeReceiver, IERC20(token).balanceOf(address(this)));
        }
    }



    function getSpotPrice(address tokenIn, address tokenOut)
        external view
        _viewlock_
        returns (uint spotPrice)
    {

        require(_records[tokenIn].bound && _records[tokenOut].bound, "NOT_BOUND");
        Record storage inRecord = _records[tokenIn];
        Record storage outRecord = _records[tokenOut];
        return calcSpotPrice(inRecord.balance, _getDenormWeight(tokenIn), outRecord.balance, _getDenormWeight(tokenOut), _swapFee);
    }

    function getSpotPriceSansFee(address tokenIn, address tokenOut)
        external view
        _viewlock_
        returns (uint spotPrice)
    {

        _requireTokenIsBound(tokenIn);
        _requireTokenIsBound(tokenOut);
        Record storage inRecord = _records[tokenIn];
        Record storage outRecord = _records[tokenOut];
        return calcSpotPrice(inRecord.balance, _getDenormWeight(tokenIn), outRecord.balance, _getDenormWeight(tokenOut), 0);
    }


    function joinPool(uint poolAmountOut, uint[] calldata maxAmountsIn)
        external override
        _logs_
        _lock_
    {

        _preventSameTxOrigin();
        _onlyWrapperOrNotWrapperMode();
        _requireContractIsFinalized();

        uint poolTotal = totalSupply();
        uint ratio = bdiv(poolAmountOut, poolTotal);
        _requireMathApprox(ratio);

        for (uint i = 0; i < _tokens.length; i++) {
            address t = _tokens[i];
            uint bal = _records[t].balance;
            uint tokenAmountIn = bmul(ratio, bal);
            _requireMathApprox(tokenAmountIn);
            require(tokenAmountIn <= maxAmountsIn[i], "LIMIT_IN");
            _records[t].balance = badd(_records[t].balance, tokenAmountIn);
            emit LOG_JOIN(msg.sender, t, tokenAmountIn);
            _pullUnderlying(t, msg.sender, tokenAmountIn);
        }

        (uint poolAmountOutAfterFee, uint poolAmountOutFee) = calcAmountWithCommunityFee(
            poolAmountOut,
            _communityJoinFee,
            msg.sender
        );

        _mintPoolShare(poolAmountOut);
        _pushPoolShare(msg.sender, poolAmountOutAfterFee);
        _pushPoolShare(_communityFeeReceiver, poolAmountOutFee);

        emit LOG_COMMUNITY_FEE(msg.sender, _communityFeeReceiver, address(this), poolAmountOutFee);
    }

    function exitPool(uint poolAmountIn, uint[] calldata minAmountsOut)
        external override
        _logs_
        _lock_
    {

        _preventSameTxOrigin();
        _onlyWrapperOrNotWrapperMode();
        _requireContractIsFinalized();

        (uint poolAmountInAfterFee, uint poolAmountInFee) = calcAmountWithCommunityFee(
            poolAmountIn,
            _communityExitFee,
            msg.sender
        );

        uint poolTotal = totalSupply();
        uint ratio = bdiv(poolAmountInAfterFee, poolTotal);
        _requireMathApprox(ratio);

        _pullPoolShare(msg.sender, poolAmountIn);
        _pushPoolShare(_communityFeeReceiver, poolAmountInFee);
        _burnPoolShare(poolAmountInAfterFee);

        for (uint i = 0; i < _tokens.length; i++) {
            address t = _tokens[i];
            uint bal = _records[t].balance;
            uint tokenAmountOut = bmul(ratio, bal);
            _requireMathApprox(tokenAmountOut);
            require(tokenAmountOut >= minAmountsOut[i], "LIMIT_OUT");
            _records[t].balance = bsub(_records[t].balance, tokenAmountOut);
            emit LOG_EXIT(msg.sender, t, tokenAmountOut);
            _pushUnderlying(t, msg.sender, tokenAmountOut);
        }

        emit LOG_COMMUNITY_FEE(msg.sender, _communityFeeReceiver, address(this), poolAmountInFee);
    }

    function swapExactAmountIn(
        address tokenIn,
        uint tokenAmountIn,
        address tokenOut,
        uint minAmountOut,
        uint maxPrice
    )
        external override
        _logs_
        _lock_
        returns (uint tokenAmountOut, uint spotPriceAfter)
    {

        _preventSameTxOrigin();
        _onlyWrapperOrNotWrapperMode();
        _requireTokenIsBound(tokenIn);
        _requireTokenIsBound(tokenOut);
        require(_publicSwap, "NOT_PUBLIC");

        Record storage inRecord = _records[address(tokenIn)];
        Record storage outRecord = _records[address(tokenOut)];

        uint spotPriceBefore = calcSpotPrice(
                                    inRecord.balance,
                                    _getDenormWeight(tokenIn),
                                    outRecord.balance,
                                    _getDenormWeight(tokenOut),
                                    _swapFee
                                );
        require(spotPriceBefore <= maxPrice, "LIMIT_PRICE");

        (uint tokenAmountInAfterFee, uint tokenAmountInFee) = calcAmountWithCommunityFee(
                                                                tokenAmountIn,
                                                                _communitySwapFee,
                                                                msg.sender
                                                            );

        require(tokenAmountInAfterFee <= bmul(inRecord.balance, MAX_IN_RATIO), "MAX_IN_RATIO");

        tokenAmountOut = calcOutGivenIn(
                            inRecord.balance,
                            _getDenormWeight(tokenIn),
                            outRecord.balance,
                            _getDenormWeight(tokenOut),
                            tokenAmountInAfterFee,
                            _swapFee
                        );
        require(tokenAmountOut >= minAmountOut, "LIMIT_OUT");

        inRecord.balance = badd(inRecord.balance, tokenAmountInAfterFee);
        outRecord.balance = bsub(outRecord.balance, tokenAmountOut);

        spotPriceAfter = calcSpotPrice(
                                inRecord.balance,
                                _getDenormWeight(tokenIn),
                                outRecord.balance,
                                _getDenormWeight(tokenOut),
                                _swapFee
                            );
        require(
            spotPriceAfter >= spotPriceBefore &&
            spotPriceBefore <= bdiv(tokenAmountInAfterFee, tokenAmountOut),
            "MATH_APPROX"
        );
        require(spotPriceAfter <= maxPrice, "LIMIT_PRICE");

        emit LOG_SWAP(msg.sender, tokenIn, tokenOut, tokenAmountInAfterFee, tokenAmountOut);

        _pullCommunityFeeUnderlying(tokenIn, msg.sender, tokenAmountInFee);
        _pullUnderlying(tokenIn, msg.sender, tokenAmountInAfterFee);
        _pushUnderlying(tokenOut, msg.sender, tokenAmountOut);

        emit LOG_COMMUNITY_FEE(msg.sender, _communityFeeReceiver, tokenIn, tokenAmountInFee);

        return (tokenAmountOut, spotPriceAfter);
    }
    function swapExactAmountOut(
        address tokenIn,
        uint maxAmountIn,
        address tokenOut,
        uint tokenAmountOut,
        uint maxPrice
    )
        external override
        _logs_
        _lock_
        returns (uint tokenAmountIn, uint spotPriceAfter)
    {

        _preventSameTxOrigin();
        _onlyWrapperOrNotWrapperMode();
        _requireTokenIsBound(tokenIn);
        _requireTokenIsBound(tokenOut);
        require(_publicSwap, "NOT_PUBLIC");

        Record storage inRecord = _records[address(tokenIn)];
        Record storage outRecord = _records[address(tokenOut)];

        require(tokenAmountOut <= bmul(outRecord.balance, MAX_OUT_RATIO), "OUT_RATIO");

        uint spotPriceBefore = calcSpotPrice(
                                    inRecord.balance,
                                    _getDenormWeight(tokenIn),
                                    outRecord.balance,
                                    _getDenormWeight(tokenOut),
                                    _swapFee
                                );
        require(spotPriceBefore <= maxPrice, "LIMIT_PRICE");

        (uint tokenAmountOutAfterFee, uint tokenAmountOutFee) = calcAmountWithCommunityFee(
            tokenAmountOut,
            _communitySwapFee,
            msg.sender
        );

        tokenAmountIn = calcInGivenOut(
                            inRecord.balance,
                            _getDenormWeight(tokenIn),
                            outRecord.balance,
                            _getDenormWeight(tokenOut),
                            tokenAmountOut,
                            _swapFee
                        );
        require(tokenAmountIn <= maxAmountIn, "LIMIT_IN");

        inRecord.balance = badd(inRecord.balance, tokenAmountIn);
        outRecord.balance = bsub(outRecord.balance, tokenAmountOut);

        spotPriceAfter = calcSpotPrice(
                                inRecord.balance,
                                _getDenormWeight(tokenIn),
                                outRecord.balance,
                                _getDenormWeight(tokenOut),
                                _swapFee
                            );
        require(
            spotPriceAfter >= spotPriceBefore &&
            spotPriceBefore <= bdiv(tokenAmountIn, tokenAmountOutAfterFee),
            "MATH_APPROX"
        );
        require(spotPriceAfter <= maxPrice, "LIMIT_PRICE");

        emit LOG_SWAP(msg.sender, tokenIn, tokenOut, tokenAmountIn, tokenAmountOutAfterFee);

        _pullUnderlying(tokenIn, msg.sender, tokenAmountIn);
        _pushUnderlying(tokenOut, msg.sender, tokenAmountOutAfterFee);
        _pushUnderlying(tokenOut, _communityFeeReceiver, tokenAmountOutFee);

        emit LOG_COMMUNITY_FEE(msg.sender, _communityFeeReceiver, tokenOut, tokenAmountOutFee);

        return (tokenAmountIn, spotPriceAfter);
    }

    function joinswapExternAmountIn(address tokenIn, uint tokenAmountIn, uint minPoolAmountOut)
        external override
        _logs_
        _lock_
        returns (uint poolAmountOut)

    {

        _preventSameTxOrigin();
        _requireContractIsFinalized();
        _onlyWrapperOrNotWrapperMode();
        _requireTokenIsBound(tokenIn);
        require(tokenAmountIn <= bmul(_records[tokenIn].balance, MAX_IN_RATIO), "MAX_IN_RATIO");

        (uint tokenAmountInAfterFee, uint tokenAmountInFee) = calcAmountWithCommunityFee(
            tokenAmountIn,
            _communityJoinFee,
            msg.sender
        );

        Record storage inRecord = _records[tokenIn];

        poolAmountOut = calcPoolOutGivenSingleIn(
                            inRecord.balance,
                            _getDenormWeight(tokenIn),
                            _totalSupply,
                            _getTotalWeight(),
                            tokenAmountInAfterFee,
                            _swapFee
                        );

        require(poolAmountOut >= minPoolAmountOut, "LIMIT_OUT");

        inRecord.balance = badd(inRecord.balance, tokenAmountInAfterFee);

        emit LOG_JOIN(msg.sender, tokenIn, tokenAmountInAfterFee);

        _mintPoolShare(poolAmountOut);
        _pushPoolShare(msg.sender, poolAmountOut);
        _pullCommunityFeeUnderlying(tokenIn, msg.sender, tokenAmountInFee);
        _pullUnderlying(tokenIn, msg.sender, tokenAmountInAfterFee);

        emit LOG_COMMUNITY_FEE(msg.sender, _communityFeeReceiver, tokenIn, tokenAmountInFee);

        return poolAmountOut;
    }

    function joinswapPoolAmountOut(address tokenIn, uint poolAmountOut, uint maxAmountIn)
        external override
        _logs_
        _lock_
        returns (uint tokenAmountIn)
    {

        _preventSameTxOrigin();
        _requireContractIsFinalized();
        _onlyWrapperOrNotWrapperMode();
        _requireTokenIsBound(tokenIn);

        Record storage inRecord = _records[tokenIn];

        (uint poolAmountOutAfterFee, uint poolAmountOutFee) = calcAmountWithCommunityFee(
            poolAmountOut,
            _communityJoinFee,
            msg.sender
        );

        tokenAmountIn = calcSingleInGivenPoolOut(
                            inRecord.balance,
                            _getDenormWeight(tokenIn),
                            _totalSupply,
                            _getTotalWeight(),
                            poolAmountOut,
                            _swapFee
                        );

        _requireMathApprox(tokenAmountIn);
        require(tokenAmountIn <= maxAmountIn, "LIMIT_IN");

        require(tokenAmountIn <= bmul(_records[tokenIn].balance, MAX_IN_RATIO), "MAX_IN_RATIO");

        inRecord.balance = badd(inRecord.balance, tokenAmountIn);

        emit LOG_JOIN(msg.sender, tokenIn, tokenAmountIn);

        _mintPoolShare(poolAmountOut);
        _pushPoolShare(msg.sender, poolAmountOutAfterFee);
        _pushPoolShare(_communityFeeReceiver, poolAmountOutFee);
        _pullUnderlying(tokenIn, msg.sender, tokenAmountIn);

        emit LOG_COMMUNITY_FEE(msg.sender, _communityFeeReceiver, address(this), poolAmountOutFee);

        return tokenAmountIn;
    }

    function exitswapPoolAmountIn(address tokenOut, uint poolAmountIn, uint minAmountOut)
        external override
        _logs_
        _lock_
        returns (uint tokenAmountOut)
    {

        _preventSameTxOrigin();
        _requireContractIsFinalized();
        _onlyWrapperOrNotWrapperMode();
        _requireTokenIsBound(tokenOut);

        Record storage outRecord = _records[tokenOut];

        tokenAmountOut = calcSingleOutGivenPoolIn(
                            outRecord.balance,
                            _getDenormWeight(tokenOut),
                            _totalSupply,
                            _getTotalWeight(),
                            poolAmountIn,
                            _swapFee
                        );

        require(tokenAmountOut >= minAmountOut, "LIMIT_OUT");

        require(tokenAmountOut <= bmul(_records[tokenOut].balance, MAX_OUT_RATIO), "OUT_RATIO");

        outRecord.balance = bsub(outRecord.balance, tokenAmountOut);

        (uint tokenAmountOutAfterFee, uint tokenAmountOutFee) = calcAmountWithCommunityFee(
            tokenAmountOut,
            _communityExitFee,
            msg.sender
        );

        emit LOG_EXIT(msg.sender, tokenOut, tokenAmountOutAfterFee);

        _pullPoolShare(msg.sender, poolAmountIn);
        _burnPoolShare(poolAmountIn);
        _pushUnderlying(tokenOut, msg.sender, tokenAmountOutAfterFee);
        _pushUnderlying(tokenOut, _communityFeeReceiver, tokenAmountOutFee);

        emit LOG_COMMUNITY_FEE(msg.sender, _communityFeeReceiver, tokenOut, tokenAmountOutFee);

        return tokenAmountOutAfterFee;
    }

    function exitswapExternAmountOut(address tokenOut, uint tokenAmountOut, uint maxPoolAmountIn)
        external override
        _logs_
        _lock_
        returns (uint poolAmountIn)
    {

        _preventSameTxOrigin();
        _requireContractIsFinalized();
        _onlyWrapperOrNotWrapperMode();
        _requireTokenIsBound(tokenOut);
        require(tokenAmountOut <= bmul(_records[tokenOut].balance, MAX_OUT_RATIO), "OUT_RATIO");

        Record storage outRecord = _records[tokenOut];

        (uint tokenAmountOutAfterFee, uint tokenAmountOutFee) = calcAmountWithCommunityFee(
            tokenAmountOut,
            _communityExitFee,
            msg.sender
        );

        poolAmountIn = calcPoolInGivenSingleOut(
                            outRecord.balance,
                            _getDenormWeight(tokenOut),
                            _totalSupply,
                            _getTotalWeight(),
                            tokenAmountOut,
                            _swapFee
                        );

        _requireMathApprox(poolAmountIn);
        require(poolAmountIn <= maxPoolAmountIn, "LIMIT_IN");

        outRecord.balance = bsub(outRecord.balance, tokenAmountOut);

        emit LOG_EXIT(msg.sender, tokenOut, tokenAmountOutAfterFee);

        _pullPoolShare(msg.sender, poolAmountIn);
        _burnPoolShare(poolAmountIn);
        _pushUnderlying(tokenOut, msg.sender, tokenAmountOutAfterFee);
        _pushUnderlying(tokenOut, _communityFeeReceiver, tokenAmountOutFee);

        emit LOG_COMMUNITY_FEE(msg.sender, _communityFeeReceiver, tokenOut, tokenAmountOutFee);

        return poolAmountIn;
    }



    function _pullUnderlying(address erc20, address from, uint amount)
        internal
    {

        bool xfer = IERC20(erc20).transferFrom(from, address(this), amount);
        require(xfer, "ERC20_FALSE");
    }

    function _pushUnderlying(address erc20, address to, uint amount)
        internal
    {

        bool xfer = IERC20(erc20).transfer(to, amount);
        require(xfer, "ERC20_FALSE");
    }

    function _pullCommunityFeeUnderlying(address erc20, address from, uint amount)
        internal
    {

        bool xfer = IERC20(erc20).transferFrom(from, _communityFeeReceiver, amount);
        require(xfer, "ERC20_FALSE");
    }

    function _pullPoolShare(address from, uint amount)
        internal
    {

        _pull(from, amount);
    }

    function _pushPoolShare(address to, uint amount)
        internal
    {

        _push(to, amount);
    }

    function _mintPoolShare(uint amount)
        internal
    {

        if(address(_restrictions) != address(0)) {
            uint maxTotalSupply = _restrictions.getMaxTotalSupply(address(this));
            require(badd(_totalSupply, amount) <= maxTotalSupply, "MAX_SUPPLY");
        }
        _mint(amount);
    }

    function _burnPoolShare(uint amount)
        internal
    {

        _burn(amount);
    }


    function _requireTokenIsBound(address token)
        internal view
    {

        require(_records[token].bound, "NOT_BOUND");
    }

    function _onlyController()
        internal view
    {

        require(msg.sender == _controller, "NOT_CONTROLLER");
    }

    function _requireContractIsNotFinalized()
        internal view
    {

        require(!_finalized, "IS_FINALIZED");
    }

    function _requireContractIsFinalized()
        internal view
    {

        require(_finalized, "NOT_FINALIZED");
    }

    function _requireFeeInBounds(uint256 _fee)
        internal pure
    {

        require(_fee >= MIN_FEE && _fee <= MAX_FEE, "FEE_BOUNDS");
    }

    function _requireMathApprox(uint256 _value)
        internal pure
    {

        require(_value != 0, "MATH_APPROX");
    }

    function _preventReentrancy()
        internal view
    {

        require(!_mutex, "REENTRY");
    }

    function _onlyWrapperOrNotWrapperMode()
        internal view
    {

        require(!_wrapperMode || msg.sender == _wrapper, "ONLY_WRAPPER");
    }

    function _preventSameTxOrigin()
      internal
    {

      require(block.number > _lastSwapBlock[tx.origin], "SAME_TX_ORIGIN");
      _lastSwapBlock[tx.origin] = block.number;
    }


    function _getDenormWeight(address token)
        internal view virtual
        returns (uint)
    {

        return _records[token].denorm;
    }

    function _getTotalWeight()
        internal view virtual
        returns (uint)
    {

        return _totalWeight;
    }

    function _addTotalWeight(uint _amount) internal virtual {

        _totalWeight = badd(_totalWeight, _amount);
        require(_totalWeight <= MAX_TOTAL_WEIGHT, "MAX_TOTAL_WEIGHT");
    }

    function _subTotalWeight(uint _amount) internal virtual {

        _totalWeight = bsub(_totalWeight, _amount);
    }

    function calcAmountWithCommunityFee(
        uint tokenAmountIn,
        uint communityFee,
        address operator
    )
        public view override
        returns (uint tokenAmountInAfterFee, uint tokenAmountFee)
    {

        if (address(_restrictions) != address(0) && _restrictions.isWithoutFee(operator)) {
            return (tokenAmountIn, 0);
        }
        uint adjustedIn = bsub(BONE, communityFee);
        tokenAmountInAfterFee = bmul(tokenAmountIn, adjustedIn);
        tokenAmountFee = bsub(tokenAmountIn, tokenAmountInAfterFee);
        return (tokenAmountInAfterFee, tokenAmountFee);
    }

    function getMinWeight()
        external view override
        returns (uint)
    {

        return MIN_WEIGHT;
    }

    function getMaxBoundTokens()
        external view override
        returns (uint)
    {

      return MAX_BOUND_TOKENS;
    }
}


pragma solidity 0.6.12;


interface PowerIndexPoolInterface is BPoolInterface {

  function initialize(
    string calldata name,
    string calldata symbol,
    uint256 minWeightPerSecond,
    uint256 maxWeightPerSecond
  ) external;


  function bind(
    address,
    uint256,
    uint256,
    uint256,
    uint256
  ) external;


  function setDynamicWeight(
    address token,
    uint256 targetDenorm,
    uint256 fromTimestamp,
    uint256 targetTimestamp
  ) external;


  function getDynamicWeightSettings(address token)
    external
    view
    returns (
      uint256 fromTimestamp,
      uint256 targetTimestamp,
      uint256 fromDenorm,
      uint256 targetDenorm
    );


  function getMinWeight() external view override returns (uint256);


  function getWeightPerSecondBounds() external view returns (uint256, uint256);


  function setWeightPerSecondBounds(uint256, uint256) external;


  function setWrapper(address, bool) external;


  function getWrapperMode() external view returns (bool);

}


pragma solidity >=0.4.24 <0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    function _isConstructor() private view returns (bool) {
        address self = address(this);
        uint256 cs;
        assembly { cs := extcodesize(self) }
        return cs == 0;
    }
}



pragma solidity 0.6.12;




contract PowerIndexPool is BPool, Initializable {

  event SetDynamicWeight(
    address indexed token,
    uint256 fromDenorm,
    uint256 targetDenorm,
    uint256 fromTimestamp,
    uint256 targetTimestamp
  );

  event SetWeightPerSecondBounds(uint256 minWeightPerSecond, uint256 maxWeightPerSecond);

  struct DynamicWeight {
    uint256 fromTimestamp;
    uint256 targetTimestamp;
    uint256 targetDenorm;
  }

  mapping(address => DynamicWeight) private _dynamicWeights;

  uint256 private _minWeightPerSecond;
  uint256 private _maxWeightPerSecond;

  constructor() public BPool("", "") {}

  function initialize(
    string calldata name,
    string calldata symbol,
    address controller,
    uint256 minWeightPerSecond,
    uint256 maxWeightPerSecond
  ) external initializer {

    _name = name;
    _symbol = symbol;
    _controller = controller;
    _minWeightPerSecond = minWeightPerSecond;
    _maxWeightPerSecond = maxWeightPerSecond;
  }


  function setWeightPerSecondBounds(uint256 minWeightPerSecond, uint256 maxWeightPerSecond) public _logs_ _lock_ {

    _onlyController();
    _minWeightPerSecond = minWeightPerSecond;
    _maxWeightPerSecond = maxWeightPerSecond;

    emit SetWeightPerSecondBounds(minWeightPerSecond, maxWeightPerSecond);
  }

  function setDynamicWeight(
    address token,
    uint256 targetDenorm,
    uint256 fromTimestamp,
    uint256 targetTimestamp
  ) public _logs_ _lock_ {

    _onlyController();
    _requireTokenIsBound(token);

    require(fromTimestamp > block.timestamp, "CANT_SET_PAST_TIMESTAMP");
    require(targetTimestamp > fromTimestamp, "TIMESTAMP_INCORRECT_DELTA");
    require(targetDenorm >= MIN_WEIGHT && targetDenorm <= MAX_WEIGHT, "TARGET_WEIGHT_BOUNDS");

    uint256 fromDenorm = _getDenormWeight(token);
    uint256 weightPerSecond = _getWeightPerSecond(fromDenorm, targetDenorm, fromTimestamp, targetTimestamp);
    require(weightPerSecond <= _maxWeightPerSecond, "MAX_WEIGHT_PER_SECOND");
    require(weightPerSecond >= _minWeightPerSecond, "MIN_WEIGHT_PER_SECOND");

    _records[token].denorm = fromDenorm;

    _dynamicWeights[token] = DynamicWeight({
      fromTimestamp: fromTimestamp,
      targetTimestamp: targetTimestamp,
      targetDenorm: targetDenorm
    });

    uint256 denormSum = 0;
    uint256 len = _tokens.length;
    for (uint256 i = 0; i < len; i++) {
      denormSum = badd(denormSum, _dynamicWeights[_tokens[i]].targetDenorm);
    }

    require(denormSum <= MAX_TOTAL_WEIGHT, "MAX_TARGET_TOTAL_WEIGHT");

    emit SetDynamicWeight(token, fromDenorm, targetDenorm, fromTimestamp, targetTimestamp);
  }

  function bind(
    address token,
    uint256 balance,
    uint256 targetDenorm,
    uint256 fromTimestamp,
    uint256 targetTimestamp
  )
    external
    _logs_ // _lock_  Bind does not lock because it jumps to `rebind` and `setDynamicWeight`, which does
  {

    super.bind(token, balance, MIN_WEIGHT);

    setDynamicWeight(token, targetDenorm, fromTimestamp, targetTimestamp);
  }

  function unbind(address token) public override {

    super.unbind(token);

    _dynamicWeights[token] = DynamicWeight(0, 0, 0);
  }

  function bind(
    address token,
    uint256 balance,
    uint256 denorm
  ) public override {

    super.bind(token, balance, denorm);
  }

  function rebind(
    address token,
    uint256 balance,
    uint256 denorm
  ) public override {

    require(denorm == MIN_WEIGHT && _dynamicWeights[token].fromTimestamp == 0, "ONLY_NEW_TOKENS_ALLOWED");
    super.rebind(token, balance, denorm);
  }


  function getDynamicWeightSettings(address token)
    external
    view
    returns (
      uint256 fromTimestamp,
      uint256 targetTimestamp,
      uint256 fromDenorm,
      uint256 targetDenorm
    )
  {

    DynamicWeight storage dw = _dynamicWeights[token];
    return (dw.fromTimestamp, dw.targetTimestamp, _records[token].denorm, dw.targetDenorm);
  }

  function getWeightPerSecondBounds() external view returns (uint256 minWeightPerSecond, uint256 maxWeightPerSecond) {

    return (_minWeightPerSecond, _maxWeightPerSecond);
  }


  function _getDenormWeight(address token) internal view override returns (uint256) {

    DynamicWeight memory dw = _dynamicWeights[token];
    uint256 fromDenorm = _records[token].denorm;

    if (dw.fromTimestamp == 0 || dw.targetDenorm == fromDenorm || block.timestamp <= dw.fromTimestamp) {
      return fromDenorm;
    }
    if (block.timestamp >= dw.targetTimestamp) {
      return dw.targetDenorm;
    }

    uint256 weightPerSecond = _getWeightPerSecond(fromDenorm, dw.targetDenorm, dw.fromTimestamp, dw.targetTimestamp);
    uint256 deltaCurrentTime = bsub(block.timestamp, dw.fromTimestamp);
    if (dw.targetDenorm > fromDenorm) {
      return badd(fromDenorm, deltaCurrentTime * weightPerSecond);
    } else {
      return bsub(fromDenorm, deltaCurrentTime * weightPerSecond);
    }
  }

  function _getWeightPerSecond(
    uint256 fromDenorm,
    uint256 targetDenorm,
    uint256 fromTimestamp,
    uint256 targetTimestamp
  ) internal pure returns (uint256) {

    uint256 delta = targetDenorm > fromDenorm ? bsub(targetDenorm, fromDenorm) : bsub(fromDenorm, targetDenorm);
    return div(delta, bsub(targetTimestamp, fromTimestamp));
  }

  function _getTotalWeight() internal view override returns (uint256) {

    uint256 sum = 0;
    uint256 len = _tokens.length;
    for (uint256 i = 0; i < len; i++) {
      sum = badd(sum, _getDenormWeight(_tokens[i]));
    }
    return sum;
  }

  function _addTotalWeight(uint256 _amount) internal virtual override {

  }

  function _subTotalWeight(uint256 _amount) internal virtual override {

  }
}