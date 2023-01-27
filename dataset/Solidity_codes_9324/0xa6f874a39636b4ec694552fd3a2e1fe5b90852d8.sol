



pragma solidity >=0.4.24 <0.7.0;


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
}


pragma solidity ^0.6.0;


contract ContextUpgradeSafe is Initializable {


    function __Context_init() internal initializer {

        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {



    }


    function _msgSender() internal view virtual returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    uint256[50] private __gap;
}


pragma solidity ^0.6.0;


contract OwnableUpgradeSafe is Initializable, ContextUpgradeSafe {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    function __Ownable_init() internal initializer {

        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {



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

    uint256[49] private __gap;
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


pragma solidity 0.6.12;

interface IPowerOracle {

  function assetPrices(address _token) external view returns (uint256);

}


pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

contract MCapWeightAbstract is BNum, OwnableUpgradeSafe {

  event SetExcludeTokenBalances(address indexed token, address[] excludeTokenBalances);
  event FetchTokenMCap(address indexed pool, address indexed token, uint256 mCap);
  event UpdatePoolWeights(
    address indexed pool,
    uint256 indexed timestamp,
    address[] tokens,
    uint256[3][] weightsChange,
    uint256[] newMCaps
  );

  struct TokenConfigItem {
    address token;
    address[] excludeTokenBalances;
  }

  IPowerOracle public oracle;
  mapping(address => address[]) public excludeTokenBalances;

  constructor(address _oracle) public OwnableUpgradeSafe() {
    if (_oracle != address(0)) {
      __Ownable_init();
      oracle = IPowerOracle(_oracle);
    }
  }

  function setExcludeTokenBalances(address _token, address[] calldata _excludeTokenBalances) external onlyOwner {

    excludeTokenBalances[_token] = _excludeTokenBalances;

    emit SetExcludeTokenBalances(_token, _excludeTokenBalances);
  }

  function setExcludeTokenBalancesList(TokenConfigItem[] calldata _tokenConfigItems) external onlyOwner {

    uint256 len = _tokenConfigItems.length;
    for (uint256 i = 0; i < len; i++) {
      excludeTokenBalances[_tokenConfigItems[i].token] = _tokenConfigItems[i].excludeTokenBalances;

      emit SetExcludeTokenBalances(_tokenConfigItems[i].token, _tokenConfigItems[i].excludeTokenBalances);
    }
  }

  function getTokenMarketCap(address _token) public view returns (uint256) {

    uint256 totalSupply = IERC20(_token).totalSupply();
    uint256 len = excludeTokenBalances[_token].length;
    for (uint256 i = 0; i < len; i++) {
      totalSupply = bsub(totalSupply, IERC20(_token).balanceOf(excludeTokenBalances[_token][i]));
    }
    return bdiv(bmul(totalSupply, oracle.assetPrices(_token)), 1 ether);
  }

  function getExcludeTokenBalancesLength(address _token) external view returns (uint256) {

    return excludeTokenBalances[_token].length;
  }

  function getExcludeTokenBalancesList(address _token) external view returns (address[] memory) {

    return excludeTokenBalances[_token];
  }

  function _computeWeightsChangeWithEvent(
    PowerIndexPoolInterface _pool,
    address[] memory _tokens,
    uint256 _minWPS,
    uint256 _maxWPS,
    uint256 fromTimestamp,
    uint256 toTimestamp
  ) internal returns (uint256[3][] memory weightsChange, uint256 lenToPush) {

    uint256[] memory newMCaps;
    (weightsChange, lenToPush, newMCaps) = computeWeightsChange(
      _pool,
      _tokens,
      _minWPS,
      _maxWPS,
      fromTimestamp,
      toTimestamp
    );
    emit UpdatePoolWeights(address(_pool), block.timestamp, _tokens, weightsChange, newMCaps);
  }

  function computeWeightsChange(
    PowerIndexPoolInterface _pool,
    address[] memory _tokens,
    uint256 _minWPS,
    uint256 _maxWPS,
    uint256 fromTimestamp,
    uint256 toTimestamp
  )
    public
    view
    returns (
      uint256[3][] memory weightsChange,
      uint256 lenToPush,
      uint256[] memory newMCaps
    )
  {

    uint256 len = _tokens.length;
    newMCaps = new uint256[](len);

    uint256 newMarketCapSum;
    for (uint256 i = 0; i < len; i++) {
      newMCaps[i] = getTokenMarketCap(_tokens[i]);
      newMarketCapSum = badd(newMarketCapSum, newMCaps[i]);
    }

    weightsChange = new uint256[3][](len);
    for (uint256 i = 0; i < len; i++) {
      (, , , uint256 oldWeight) = _pool.getDynamicWeightSettings(_tokens[i]);
      uint256 newWeight = bmul(bdiv(newMCaps[i], newMarketCapSum), 25 * BONE);
      weightsChange[i] = [i, oldWeight, newWeight];
    }

    for (uint256 i = 0; i < len; i++) {
      uint256 wps = getWeightPerSecond(weightsChange[i][1], weightsChange[i][2], fromTimestamp, toTimestamp);
      if (wps >= _minWPS) {
        lenToPush++;
      }
    }

    if (lenToPush > 1) {
      _sort(weightsChange);
    }
  }

  function getWeightPerSecond(
    uint256 fromDenorm,
    uint256 targetDenorm,
    uint256 fromTimestamp,
    uint256 targetTimestamp
  ) public pure returns (uint256) {

    uint256 delta = targetDenorm > fromDenorm ? bsub(targetDenorm, fromDenorm) : bsub(fromDenorm, targetDenorm);
    return div(delta, bsub(targetTimestamp, fromTimestamp));
  }

  function _quickSort(
    uint256[3][] memory wightsChange,
    int256 left,
    int256 right
  ) internal pure {

    int256 i = left;
    int256 j = right;
    if (i == j) return;
    uint256[3] memory pivot = wightsChange[uint256(left + (right - left) / 2)];
    int256 pDiff = int256(pivot[2]) - int256(pivot[1]);
    while (i <= j) {
      while (int256(wightsChange[uint256(i)][2]) - int256(wightsChange[uint256(i)][1]) < pDiff) i++;
      while (pDiff < int256(wightsChange[uint256(j)][2]) - int256(wightsChange[uint256(j)][1])) j--;
      if (i <= j) {
        (wightsChange[uint256(i)], wightsChange[uint256(j)]) = (wightsChange[uint256(j)], wightsChange[uint256(i)]);
        i++;
        j--;
      }
    }
    if (left < j) _quickSort(wightsChange, left, j);
    if (i < right) _quickSort(wightsChange, i, right);
  }

  function _sort(uint256[3][] memory weightsChange) internal pure {

    _quickSort(weightsChange, int256(0), int256(weightsChange.length - 1));
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }
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

interface IPoolRestrictions {

  function getMaxTotalSupply(address _pool) external view returns (uint256);


  function isVotingSignatureAllowed(address _votingAddress, bytes4 _signature) external view returns (bool);


  function isVotingSenderAllowed(address _votingAddress, address _sender) external view returns (bool);


  function isWithoutFee(address _addr) external view returns (bool);

}


pragma solidity 0.6.12;

contract PowerIndexAbstractController is Ownable {

  using SafeMath for uint256;

  bytes4 public constant CALL_VOTING_SIG = bytes4(keccak256(bytes("callVoting(address,bytes4,bytes,uint256)")));

  event CallPool(bool indexed success, bytes4 indexed inputSig, bytes inputData, bytes outputData);

  PowerIndexPoolInterface public immutable pool;

  constructor(address _pool) public {
    pool = PowerIndexPoolInterface(_pool);
  }

  function callPool(bytes4 signature, bytes calldata args) external onlyOwner {

    _checkSignature(signature);
    (bool success, bytes memory data) = address(pool).call(abi.encodePacked(signature, args));
    require(success, "NOT_SUCCESS");
    emit CallPool(success, signature, args, data);
  }

  function callVotingByPool(
    address voting,
    bytes4 signature,
    bytes calldata args,
    uint256 value
  ) external {

    require(_restrictions().isVotingSenderAllowed(voting, msg.sender), "SENDER_NOT_ALLOWED");
    pool.callVoting(voting, signature, args, value);
  }

  function migrateController(address newController, address[] calldata addressesToMigrate) external onlyOwner {

    uint256 len = addressesToMigrate.length;
    for (uint256 i = 0; i < len; i++) {
      PowerIndexPoolInterface(addressesToMigrate[i]).setController(newController);
    }
  }

  function _restrictions() internal view returns (IPoolRestrictions) {

    return IPoolRestrictions(pool.getRestrictions());
  }

  function _checkSignature(bytes4 signature) internal pure virtual {

    require(signature != CALL_VOTING_SIG, "SIGNATURE_NOT_ALLOWED");
  }
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

interface WrappedPiErc20Interface is IERC20 {

  function deposit(uint256 _amount) external payable returns (uint256);


  function withdraw(uint256 _amount) external payable returns (uint256);


  function changeRouter(address _newRouter) external;


  function setEthFee(uint256 _newEthFee) external;


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


interface WrappedPiErc20FactoryInterface {

  event NewWrappedPiErc20(address indexed token, address indexed wrappedToken, address indexed creator);

  function build(
    address _token,
    address _router,
    string calldata _name,
    string calldata _symbol
  ) external returns (WrappedPiErc20Interface);

}


pragma solidity 0.6.12;

interface IPiRouterFactory {

  function buildRouter(address _piToken, bytes calldata _args) external returns (address);

}


pragma solidity 0.6.12;

contract PowerIndexWrappedController is PowerIndexAbstractController {


  event ReplacePoolTokenWithPiToken(
    address indexed underlyingToken,
    address indexed piToken,
    uint256 balance,
    uint256 denormalizedWeight
  );

  event ReplacePoolTokenWithNewVersion(
    address indexed oldToken,
    address indexed newToken,
    address indexed migrator,
    uint256 balance,
    uint256 denormalizedWeight
  );

  event ReplacePoolTokenFinish();

  event SetPoolWrapper(address indexed poolWrapper);

  event SetPiTokenFactory(address indexed piTokenFactory);

  event CreatePiToken(address indexed underlyingToken, address indexed piToken, address indexed router);


  PowerIndexWrapperInterface public poolWrapper;

  WrappedPiErc20FactoryInterface public piTokenFactory;

  constructor(
    address _pool,
    address _poolWrapper,
    address _piTokenFactory
  ) public PowerIndexAbstractController(_pool) {
    poolWrapper = PowerIndexWrapperInterface(_poolWrapper);
    piTokenFactory = WrappedPiErc20FactoryInterface(_piTokenFactory);
  }

  function setPoolWrapper(address _poolWrapper) external onlyOwner {

    poolWrapper = PowerIndexWrapperInterface(_poolWrapper);
    emit SetPoolWrapper(_poolWrapper);
  }

  function setPiTokenFactory(address _piTokenFactory) external onlyOwner {

    piTokenFactory = WrappedPiErc20FactoryInterface(_piTokenFactory);
    emit SetPiTokenFactory(_piTokenFactory);
  }

  function createPiToken(
    address _underlyingToken,
    address _routerFactory,
    bytes memory _routerArgs,
    string calldata _name,
    string calldata _symbol
  ) external onlyOwner {

    _createPiToken(_underlyingToken, _routerFactory, _routerArgs, _name, _symbol);
  }

  function replacePoolTokenWithNewPiToken(
    address _underlyingToken,
    address _routerFactory,
    bytes calldata _routerArgs,
    string calldata _name,
    string calldata _symbol
  ) external payable onlyOwner {

    WrappedPiErc20Interface piToken = _createPiToken(_underlyingToken, _routerFactory, _routerArgs, _name, _symbol);
    _replacePoolTokenWithPiToken(_underlyingToken, piToken);
  }

  function replacePoolTokenWithExistingPiToken(address _underlyingToken, WrappedPiErc20Interface _piToken)
    external
    payable
    onlyOwner
  {

    _replacePoolTokenWithPiToken(_underlyingToken, _piToken);
  }

  function replacePoolTokenWithNewVersion(
    address _oldToken,
    address _newToken,
    address _migrator,
    bytes calldata _migratorData
  ) external onlyOwner {

    uint256 denormalizedWeight = pool.getDenormalizedWeight(_oldToken);
    uint256 balance = pool.getBalance(_oldToken);

    pool.unbind(_oldToken);

    IERC20(_oldToken).approve(_migrator, balance);
    (bool success, ) = _migrator.call(_migratorData);
    require(success, "NOT_SUCCESS");

    require(
      IERC20(_newToken).balanceOf(address(this)) >= balance,
      "PiBPoolController:newVersion: insufficient newToken balance"
    );

    IERC20(_newToken).approve(address(pool), balance);
    _bindNewToken(_newToken, balance, denormalizedWeight);

    emit ReplacePoolTokenWithNewVersion(_oldToken, _newToken, _migrator, balance, denormalizedWeight);
  }


  function _replacePoolTokenWithPiToken(address _underlyingToken, WrappedPiErc20Interface _piToken) internal {

    uint256 denormalizedWeight = pool.getDenormalizedWeight(_underlyingToken);
    uint256 balance = pool.getBalance(_underlyingToken);

    pool.unbind(_underlyingToken);

    IERC20(_underlyingToken).approve(address(_piToken), balance);
    _piToken.deposit{ value: msg.value }(balance);

    _piToken.approve(address(pool), balance);
    _bindNewToken(address(_piToken), balance, denormalizedWeight);

    if (address(poolWrapper) != address(0)) {
      poolWrapper.setPiTokenForUnderlying(_underlyingToken, address(_piToken));
    }

    emit ReplacePoolTokenWithPiToken(_underlyingToken, address(_piToken), balance, denormalizedWeight);
  }

  function _bindNewToken(
    address _piToken,
    uint256 _balance,
    uint256 _denormalizedWeight
  ) internal virtual {

    pool.bind(_piToken, _balance, _denormalizedWeight);
  }

  function _createPiToken(
    address _underlyingToken,
    address _routerFactory,
    bytes memory _routerArgs,
    string calldata _name,
    string calldata _symbol
  ) internal returns (WrappedPiErc20Interface) {

    WrappedPiErc20Interface piToken = piTokenFactory.build(_underlyingToken, address(this), _name, _symbol);
    address router = IPiRouterFactory(_routerFactory).buildRouter(address(piToken), _routerArgs);
    Ownable(router).transferOwnership(msg.sender);
    piToken.changeRouter(router);

    emit CreatePiToken(_underlyingToken, address(piToken), router);
    return piToken;
  }
}


pragma solidity 0.6.12;

contract PowerIndexPoolController is PowerIndexWrappedController {

  using SafeERC20 for IERC20;


  bytes4 public constant BIND_SIG = bytes4(keccak256(bytes("bind(address,uint256,uint256,uint256,uint256)")));

  bytes4 public constant UNBIND_SIG = bytes4(keccak256(bytes("unbind(address)")));

  struct DynamicWeightInput {
    address token;
    uint256 targetDenorm;
    uint256 fromTimestamp;
    uint256 targetTimestamp;
  }

  event SetWeightsStrategy(address indexed weightsStrategy);

  address public weightsStrategy;

  modifier onlyWeightsStrategy() {

    require(msg.sender == weightsStrategy, "ONLY_WEIGHTS_STRATEGY");
    _;
  }

  constructor(
    address _pool,
    address _poolWrapper,
    address _wrapperFactory,
    address _weightsStrategy
  ) public PowerIndexWrappedController(_pool, _poolWrapper, _wrapperFactory) {
    weightsStrategy = _weightsStrategy;
  }


  function bind(
    address token,
    uint256 balance,
    uint256 targetDenorm,
    uint256 fromTimestamp,
    uint256 targetTimestamp
  ) external onlyOwner {

    _validateNewTokenBind();

    IERC20(token).safeTransferFrom(msg.sender, address(this), balance);
    IERC20(token).approve(address(pool), balance);
    pool.bind(token, balance, targetDenorm, fromTimestamp, targetTimestamp);
  }

  function replaceTokenWithNew(
    address oldToken,
    address newToken,
    uint256 balance,
    uint256 fromTimestamp,
    uint256 targetTimestamp
  ) external onlyOwner {

    _replaceTokenWithNew(oldToken, newToken, balance, fromTimestamp, targetTimestamp);
  }

  function replaceTokenWithNewFromNow(
    address oldToken,
    address newToken,
    uint256 balance,
    uint256 durationFromNow
  ) external onlyOwner {

    uint256 now = block.timestamp.add(1);
    _replaceTokenWithNew(oldToken, newToken, balance, now, now.add(durationFromNow));
  }

  function setDynamicWeightList(DynamicWeightInput[] memory _dynamicWeights) external onlyOwner {

    uint256 len = _dynamicWeights.length;
    for (uint256 i = 0; i < len; i++) {
      pool.setDynamicWeight(
        _dynamicWeights[i].token,
        _dynamicWeights[i].targetDenorm,
        _dynamicWeights[i].fromTimestamp,
        _dynamicWeights[i].targetTimestamp
      );
    }
  }

  function setWeightsStrategy(address _weightsStrategy) external onlyOwner {

    weightsStrategy = _weightsStrategy;
    emit SetWeightsStrategy(_weightsStrategy);
  }

  function setDynamicWeightListByStrategy(DynamicWeightInput[] memory _dynamicWeights) external onlyWeightsStrategy {

    uint256 len = _dynamicWeights.length;
    for (uint256 i = 0; i < len; i++) {
      pool.setDynamicWeight(
        _dynamicWeights[i].token,
        _dynamicWeights[i].targetDenorm,
        _dynamicWeights[i].fromTimestamp,
        _dynamicWeights[i].targetTimestamp
      );
    }
  }

  function unbindNotActualToken(address _token) external {

    require(pool.getDenormalizedWeight(_token) == pool.getMinWeight(), "DENORM_MIN");
    (, uint256 targetTimestamp, , ) = pool.getDynamicWeightSettings(_token);
    require(block.timestamp > targetTimestamp, "TIMESTAMP_MORE_THEN_TARGET");

    uint256 tokenBalance = pool.getBalance(_token);

    pool.unbind(_token);
    (, , , address communityWallet) = pool.getCommunityFee();
    IERC20(_token).safeTransfer(communityWallet, tokenBalance);
  }

  function _checkSignature(bytes4 signature) internal pure override {

    require(signature != BIND_SIG && signature != UNBIND_SIG && signature != CALL_VOTING_SIG, "SIGNATURE_NOT_ALLOWED");
  }


  function _replaceTokenWithNew(
    address oldToken,
    address newToken,
    uint256 balance,
    uint256 fromTimestamp,
    uint256 targetTimestamp
  ) internal {

    uint256 minWeight = pool.getMinWeight();
    (, , , uint256 targetDenorm) = pool.getDynamicWeightSettings(oldToken);

    pool.setDynamicWeight(oldToken, minWeight, fromTimestamp, targetTimestamp);

    IERC20(newToken).safeTransferFrom(msg.sender, address(this), balance);
    IERC20(newToken).approve(address(pool), balance);
    pool.bind(newToken, balance, targetDenorm.sub(minWeight), fromTimestamp, targetTimestamp);
  }

  function _validateNewTokenBind() internal {

    address[] memory tokens = pool.getCurrentTokens();
    uint256 tokensLen = tokens.length;
    uint256 minWeight = pool.getMinWeight();

    if (tokensLen == pool.getMaxBoundTokens() - 1) {
      for (uint256 i = 0; i < tokensLen; i++) {
        (, , , uint256 targetDenorm) = pool.getDynamicWeightSettings(tokens[i]);
        if (targetDenorm == minWeight) {
          return;
        }
      }
      revert("NEW_TOKEN_NOT_ALLOWED"); // If there is no tokens with target MIN_WEIGHT
    }
  }
}


pragma solidity 0.6.12;

contract MCapWeightStrategyRebinder is MCapWeightAbstract {

  event SetOperationsContract(address indexed operationsContract);
  event ExecuteOperation(address indexed operationsContract, bool indexed success, bytes inData, bytes outData);

  struct RebindOperation {
    address token;
    uint256 newWeight;
    uint256 oldBalance;
    uint256 newBalance;
    uint256 opApproveAmount;
    address opToken;
    bytes opData;
    bool opAfter;
  }
  struct RebindConfig {
    address token;
    uint256 newWeight;
    uint256 oldBalance;
    uint256 newBalance;
  }

  address public operationsContract;

  constructor(address _oracle, address _operationsContract) public MCapWeightAbstract(_oracle) {
    operationsContract = _operationsContract;
  }

  function setOperationsContract(address _operationsContract) public onlyOwner {

    operationsContract = _operationsContract;

    emit SetOperationsContract(_operationsContract);
  }

  function setController(PowerIndexPoolInterface _pool, address _newController) public onlyOwner {

    _pool.setController(_newController);
  }

  function runRebind(
    PowerIndexPoolInterface _pool,
    address _newController,
    RebindOperation[] memory _ops
  ) public onlyOwner {

    address[] memory tokens = _pool.getCurrentTokens();
    uint256 len = _ops.length;

    for (uint256 i = 0; i < len; i++) {
      if (!_ops[i].opAfter) {
        _runOperation(_ops[i]);
      }

      if (_ops[i].token != address(0)) {
        if (_ops[i].newBalance > _ops[i].oldBalance) {
          _ops[i].oldBalance = _pool.getBalance(_ops[i].token);
          uint256 amountToAdd = IERC20(_ops[i].token).balanceOf(address(this));
          IERC20(_ops[i].token).approve(address(_pool), amountToAdd);
          _pool.rebind(_ops[i].token, _ops[i].oldBalance + amountToAdd, _ops[i].newWeight);
        } else {
          _pool.rebind(_ops[i].token, _ops[i].newBalance, _ops[i].newWeight);
        }
      }

      if (_ops[i].opAfter) {
        _runOperation(_ops[i]);
      }
    }
  }

  function _runOperation(RebindOperation memory _op) internal {

    if (_op.opToken != address(0)) {
      if (_op.opApproveAmount != 0) {
        IERC20(_op.opToken).approve(operationsContract, _op.opApproveAmount);
      }
      (bool success, bytes memory resData) = operationsContract.call(_op.opData);
      require(success, "NOT_SUCCESS");
      emit ExecuteOperation(operationsContract, success, _op.opData, resData);
    }
  }

  function getRebindConfigs(
    PowerIndexPoolInterface _pool,
    address[] memory _tokens,
    uint256 _oldWeightDiv
  ) external view returns (RebindConfig[] memory configs) {

    uint256 len = _tokens.length;
    uint256[] memory oldBalances = new uint256[](len);
    for (uint256 i = 0; i < len; i++) {
      oldBalances[i] = IERC20(_tokens[i]).balanceOf(address(_pool));
    }

    uint256 now = block.timestamp;
    (uint256[3][] memory weightsChange, , ) = computeWeightsChange(_pool, _tokens, 0, 100 ether, now, now + 1);

    configs = new RebindConfig[](len);
    for (uint256 i = 0; i < len; i++) {
      uint256[3] memory wc = weightsChange[i];
      uint256 ti = wc[0];
      uint256 oldWeight = wc[1] / _oldWeightDiv;
      uint256 newWeight = wc[2];
      configs[i] = RebindConfig(
        _tokens[ti],
        newWeight,
        oldBalances[ti],
        bmul(oldBalances[ti], bdiv(newWeight, oldWeight))
      );
    }
  }
}