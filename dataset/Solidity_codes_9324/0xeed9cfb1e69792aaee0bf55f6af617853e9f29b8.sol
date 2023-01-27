

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;




interface IAlphaStakingTier {

  function tiers(uint index) external view returns (uint);


  function tierCount() external view returns (uint);


  function getAlphaTier(address user) external view returns (uint index);


  function setAlphaTiers(uint[] calldata upperLimits) external;


  function updateAlphaTier(uint index, uint upperLimit) external;

}


interface IBaseOracle {

  function getETHPx(address token) external view returns (uint);

}


interface IERC20Wrapper {

  function getUnderlyingToken(uint id) external view returns (address);


  function getUnderlyingRate(uint id) external view returns (uint);

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
        return !Address.isContract(address(this));
    }
}


contract Governable is Initializable {

  event SetGovernor(address governor);
  event SetPendingGovernor(address pendingGovernor);
  event AcceptGovernor(address governor);

  address public governor; // The current governor.
  address public pendingGovernor; // The address pending to become the governor once accepted.

  bytes32[64] _gap; // reserve space for upgrade

  modifier onlyGov() {

    require(msg.sender == governor, 'not the governor');
    _;
  }

  function __Governable__init() internal initializer {

    governor = msg.sender;
    pendingGovernor = address(0);
    emit SetGovernor(msg.sender);
  }

  function setPendingGovernor(address _pendingGovernor) external onlyGov {

    pendingGovernor = _pendingGovernor;
    emit SetPendingGovernor(_pendingGovernor);
  }

  function acceptGovernor() external {

    require(msg.sender == pendingGovernor, 'not the pending governor');
    pendingGovernor = address(0);
    governor = msg.sender;
    emit AcceptGovernor(msg.sender);
  }
}


contract TierProxyOracle is Governable {

  using SafeMath for uint;

  event SetTierTokenFactor(address indexed token, uint indexed tier, TokenFactor factor);
  event UnsetTierTokenInfo(address indexed token);
  event SetWhitelist(address indexed token, bool ok);
  event SetLiqIncentive(address indexed token, uint liqIncentive);

  struct TokenFactor {
    uint16 borrowFactor; // The borrow factor for this token, multiplied by 1e4.
    uint16 collateralFactor; // The collateral factor for this token, multiplied by 1e4.
  }

  IBaseOracle public immutable source; // Main oracle source
  IAlphaStakingTier public immutable alphaTier; // alpha tier contract address
  uint public immutable tierCount; // number of tiers
  mapping(address => TokenFactor[]) public tierTokenFactors; // Mapping from token to list of token factor by tier.
  mapping(address => uint) public liqIncentives; // Mapping from token to liquidation incentive, multiplied by 1e4.
  mapping(address => bool) public whitelistERC1155; // Mapping from token address to whitelist status

  constructor(IBaseOracle _source, IAlphaStakingTier _alphaTier) public {
    __Governable__init();
    source = _source;
    alphaTier = _alphaTier;
    tierCount = _alphaTier.tierCount();
  }

  function setTierTokenFactors(
    address[] calldata _tokens,
    TokenFactor[][] memory _tokenFactors,
    uint[] calldata _liqIncentives
  ) external onlyGov {

    require(_tokenFactors.length == _tokens.length, 'token factors & tokens length mismatched');
    require(_liqIncentives.length == _tokens.length, 'liq incentive & tokens length mismatched');
    for (uint idx = 0; idx < _tokens.length; idx++) {
      require(
        _tokenFactors[idx].length == tierCount,
        'token factor of token & tier count length mismatched'
      );
      delete tierTokenFactors[_tokens[idx]];
      for (uint i = 0; i < _tokenFactors[idx].length; i++) {
        if (i > 0) {
          require(
            _tokenFactors[idx][i - 1].borrowFactor >= _tokenFactors[idx][i].borrowFactor,
            'borrow factors should be non-increasing'
          );
          require(
            _tokenFactors[idx][i - 1].collateralFactor <= _tokenFactors[idx][i].collateralFactor,
            'collateral factors should be non-decreasing'
          );
        }
        tierTokenFactors[_tokens[idx]].push(_tokenFactors[idx][i]);
        emit SetTierTokenFactor(_tokens[idx], i, _tokenFactors[idx][i]);
      }
      require(
        _tokenFactors[idx][_tokenFactors[idx].length - 1].borrowFactor >= 1e4,
        'borrow factor must be at least 10000'
      );
      require(
        _tokenFactors[idx][_tokenFactors[idx].length - 1].collateralFactor <= 1e4,
        'collateral factor must be no more than 10000'
      );
      require(_liqIncentives[idx] != 0, 'liq incentive should != 0');
      liqIncentives[_tokens[idx]] = _liqIncentives[idx];
      emit SetLiqIncentive(_tokens[idx], _liqIncentives[idx]);
    }
  }

  function unsetTierTokenInfos(address[] calldata _tokens) external onlyGov {

    for (uint idx = 0; idx < _tokens.length; idx++) {
      delete liqIncentives[_tokens[idx]];
      delete tierTokenFactors[_tokens[idx]];
      emit UnsetTierTokenInfo(_tokens[idx]);
    }
  }

  function setWhitelistERC1155(address[] calldata tokens, bool ok) external onlyGov {

    for (uint idx = 0; idx < tokens.length; idx++) {
      whitelistERC1155[tokens[idx]] = ok;
      emit SetWhitelist(tokens[idx], ok);
    }
  }

  function supportWrappedToken(address token, uint id) external view returns (bool) {

    if (!whitelistERC1155[token]) return false;
    address tokenUnderlying = IERC20Wrapper(token).getUnderlyingToken(id);
    return liqIncentives[tokenUnderlying] != 0;
  }

  function convertForLiquidation(
    address tokenIn,
    address tokenOut,
    uint tokenOutId,
    uint amountIn
  ) external view returns (uint) {

    require(whitelistERC1155[tokenOut], 'bad token');
    address tokenOutUnderlying = IERC20Wrapper(tokenOut).getUnderlyingToken(tokenOutId);
    uint rateUnderlying = IERC20Wrapper(tokenOut).getUnderlyingRate(tokenOutId);
    uint liqIncentiveIn = liqIncentives[tokenIn];
    uint liqIncentiveOut = liqIncentives[tokenOutUnderlying];
    require(liqIncentiveIn != 0, 'bad underlying in');
    require(liqIncentiveOut != 0, 'bad underlying out');
    uint pxIn = source.getETHPx(tokenIn);
    uint pxOut = source.getETHPx(tokenOutUnderlying);
    uint amountOut = amountIn.mul(pxIn).div(pxOut);
    amountOut = amountOut.mul(2**112).div(rateUnderlying);
    return amountOut.mul(liqIncentiveIn).mul(liqIncentiveOut).div(10000 * 10000);
  }

  function asETHCollateral(
    address token,
    uint id,
    uint amount,
    address owner
  ) external view returns (uint) {

    require(whitelistERC1155[token], 'bad token');
    address tokenUnderlying = IERC20Wrapper(token).getUnderlyingToken(id);
    uint rateUnderlying = IERC20Wrapper(token).getUnderlyingRate(id);
    uint amountUnderlying = amount.mul(rateUnderlying).div(2**112);
    uint tier = alphaTier.getAlphaTier(owner);
    uint collFactor = tierTokenFactors[tokenUnderlying][tier].collateralFactor;
    require(liqIncentives[tokenUnderlying] != 0, 'bad underlying collateral');
    require(collFactor != 0, 'bad coll factor');
    uint ethValue = source.getETHPx(tokenUnderlying).mul(amountUnderlying).div(2**112);
    return ethValue.mul(collFactor).div(10000);
  }

  function asETHBorrow(
    address token,
    uint amount,
    address owner
  ) external view returns (uint) {

    uint tier = alphaTier.getAlphaTier(owner);
    uint borrFactor = tierTokenFactors[token][tier].borrowFactor;
    require(liqIncentives[token] != 0, 'bad underlying borrow');
    require(borrFactor < 50000, 'bad borr factor');
    uint ethValue = source.getETHPx(token).mul(amount).div(2**112);
    return ethValue.mul(borrFactor).div(10000);
  }

  function support(address token) external view returns (bool) {

    try source.getETHPx(token) returns (uint px) {
      return px != 0 && liqIncentives[token] != 0;
    } catch {
      return false;
    }
  }
}