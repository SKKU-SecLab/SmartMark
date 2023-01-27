
pragma experimental ABIEncoderV2;
pragma solidity 0.6.4;


library EthAddressLib {

    function ethAddress() internal pure returns (address) {

        return 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    }
}

interface IOracleProxy {

    function get(address token) external view returns (uint256, bool);

}

interface IPriceOracles {

    function get(address token) external view returns (uint256, bool);

}

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    function decimals() external view returns (uint8);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
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

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a <= b ? a : b;
    }

    function abs(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a < b) {
            return b - a;
        }
        return a - b;
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

        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
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

library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeERC20: decreased allowance below zero"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

library SignedSafeMath {

  int256 constant private _INT256_MIN = -2**255;

  function mul(int256 a, int256 b) internal pure returns (int256) {

    if (a == 0) {
      return 0;
    }

    require(!(a == -1 && b == _INT256_MIN), "SignedSafeMath: multiplication overflow");

    int256 c = a * b;
    require(c / a == b, "SignedSafeMath: multiplication overflow");

    return c;
  }

  function div(int256 a, int256 b) internal pure returns (int256) {

    require(b != 0, "SignedSafeMath: division by zero");
    require(!(b == -1 && a == _INT256_MIN), "SignedSafeMath: division overflow");

    int256 c = a / b;

    return c;
  }

  function sub(int256 a, int256 b) internal pure returns (int256) {

    int256 c = a - b;
    require((b >= 0 && c <= a) || (b < 0 && c > a), "SignedSafeMath: subtraction overflow");

    return c;
  }

  function add(int256 a, int256 b) internal pure returns (int256) {

    int256 c = a + b;
    require((b >= 0 && c >= a) || (b < 0 && c < a), "SignedSafeMath: addition overflow");

    return c;
  }

  function avg(int256 _a, int256 _b)
    internal
    pure
    returns (int256)
  {

    if ((_a < 0 && _b > 0) || (_a > 0 && _b < 0)) {
      return add(_a, _b) / 2;
    }
    int256 remainder = (_a % 2 + _b % 2) / 2;
    return add(add(_a / 2, _b / 2), remainder);
  }
}

library Median {

  using SignedSafeMath for int256;

  int256 constant INT_MAX = 2**255-1;

  function calculate(int256[] memory list)
    internal
    pure
    returns (int256)
  {

    return calculateInplace(copy(list));
  }

  function calculateInplace(int256[] memory list)
    internal
    pure
    returns (int256)
  {

    require(0 < list.length, "list must not be empty");
    uint256 len = list.length;
    uint256 middleIndex = len / 2;
    if (len % 2 == 0) {
      int256 median1;
      int256 median2;
      (median1, median2) = quickselectTwo(list, 0, len - 1, middleIndex - 1, middleIndex);
      return SignedSafeMath.avg(median1, median2);
    } else {
      return quickselect(list, 0, len - 1, middleIndex);
    }
  }

  uint256 constant SHORTSELECTTWO_MAX_LENGTH = 7;

  function shortSelectTwo(
    int256[] memory list,
    uint256 lo,
    uint256 hi,
    uint256 k1,
    uint256 k2
  )
    private
    pure
    returns (int256 k1th, int256 k2th)
  {


    uint256 len = hi + 1 - lo;
    int256 x0 = list[lo + 0];
    int256 x1 = 1 < len ? list[lo + 1] : INT_MAX;
    int256 x2 = 2 < len ? list[lo + 2] : INT_MAX;
    int256 x3 = 3 < len ? list[lo + 3] : INT_MAX;
    int256 x4 = 4 < len ? list[lo + 4] : INT_MAX;
    int256 x5 = 5 < len ? list[lo + 5] : INT_MAX;
    int256 x6 = 6 < len ? list[lo + 6] : INT_MAX;

    if (x0 > x1) {(x0, x1) = (x1, x0);}
    if (x2 > x3) {(x2, x3) = (x3, x2);}
    if (x4 > x5) {(x4, x5) = (x5, x4);}
    if (x0 > x2) {(x0, x2) = (x2, x0);}
    if (x1 > x3) {(x1, x3) = (x3, x1);}
    if (x4 > x6) {(x4, x6) = (x6, x4);}
    if (x1 > x2) {(x1, x2) = (x2, x1);}
    if (x5 > x6) {(x5, x6) = (x6, x5);}
    if (x0 > x4) {(x0, x4) = (x4, x0);}
    if (x1 > x5) {(x1, x5) = (x5, x1);}
    if (x2 > x6) {(x2, x6) = (x6, x2);}
    if (x1 > x4) {(x1, x4) = (x4, x1);}
    if (x3 > x6) {(x3, x6) = (x6, x3);}
    if (x2 > x4) {(x2, x4) = (x4, x2);}
    if (x3 > x5) {(x3, x5) = (x5, x3);}
    if (x3 > x4) {(x3, x4) = (x4, x3);}

    uint256 index1 = k1 - lo;
    if (index1 == 0) {k1th = x0;}
    else if (index1 == 1) {k1th = x1;}
    else if (index1 == 2) {k1th = x2;}
    else if (index1 == 3) {k1th = x3;}
    else if (index1 == 4) {k1th = x4;}
    else if (index1 == 5) {k1th = x5;}
    else if (index1 == 6) {k1th = x6;}
    else {revert("k1 out of bounds");}

    uint256 index2 = k2 - lo;
    if (k1 == k2) {return (k1th, k1th);}
    else if (index2 == 0) {return (k1th, x0);}
    else if (index2 == 1) {return (k1th, x1);}
    else if (index2 == 2) {return (k1th, x2);}
    else if (index2 == 3) {return (k1th, x3);}
    else if (index2 == 4) {return (k1th, x4);}
    else if (index2 == 5) {return (k1th, x5);}
    else if (index2 == 6) {return (k1th, x6);}
    else {revert("k2 out of bounds");}
  }

  function quickselect(int256[] memory list, uint256 lo, uint256 hi, uint256 k)
    private
    pure
    returns (int256 kth)
  {

    require(lo <= k);
    require(k <= hi);
    while (lo < hi) {
      if (hi - lo < SHORTSELECTTWO_MAX_LENGTH) {
        int256 ignore;
        (kth, ignore) = shortSelectTwo(list, lo, hi, k, k);
        return kth;
      }
      uint256 pivotIndex = partition(list, lo, hi);
      if (k <= pivotIndex) {
        hi = pivotIndex;
      } else {
        lo = pivotIndex + 1;
      }
    }
    return list[lo];
  }

  function quickselectTwo(
    int256[] memory list,
    uint256 lo,
    uint256 hi,
    uint256 k1,
    uint256 k2
  )
    internal // for testing
    pure
    returns (int256 k1th, int256 k2th)
  {

    require(k1 < k2);
    require(lo <= k1 && k1 <= hi);
    require(lo <= k2 && k2 <= hi);

    while (true) {
      if (hi - lo < SHORTSELECTTWO_MAX_LENGTH) {
        return shortSelectTwo(list, lo, hi, k1, k2);
      }
      uint256 pivotIdx = partition(list, lo, hi);
      if (k2 <= pivotIdx) {
        hi = pivotIdx;
      } else if (pivotIdx < k1) {
        lo = pivotIdx + 1;
      } else {
        assert(k1 <= pivotIdx && pivotIdx < k2);
        k1th = quickselect(list, lo, pivotIdx, k1);
        k2th = quickselect(list, pivotIdx + 1, hi, k2);
        return (k1th, k2th);
      }
    }
  }

  function partition(int256[] memory list, uint256 lo, uint256 hi)
    private
    pure
    returns (uint256)
  {

    int256 pivot = list[(lo + hi) / 2];
    lo -= 1; // this can underflow. that's intentional.
    hi += 1;
    while (true) {
      do {
        lo += 1;
      } while (list[lo] < pivot);
      do {
        hi -= 1;
      } while (list[hi] > pivot);
      if (lo < hi) {
        (list[lo], list[hi]) = (list[hi], list[lo]);
      } else {
        return hi;
      }
    }
  }

  function copy(int256[] memory list)
    private
    pure
    returns(int256[] memory)
  {

    int256[] memory list2 = new int256[](list.length);
    for (uint256 i = 0; i < list.length; i++) {
      list2[i] = list[i];
    }
    return list2;
  }
}

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

contract ForTubeOracle is Initializable, IPriceOracles {

    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;

    event Enable(address feeder);
    event Disable(address feeder);

    event Enables(address[] feeder);
    event Disables(address[] feeder);

    event EnableToken(address token);
    event DisableToken(address token);

    event EnableTokens(address[] ts);
    event DisableTokens(address[] ts);

    event Set(address who, address token, uint val, uint exp);
    event BatchSet(address[] tokens, uint[] vals, uint exp);

    address public multiSig;
    address public admin;

    EnumerableSet.AddressSet private _tokens;// 支持的币种列表

    struct Price {
        uint192 price;
        uint64 expiration;
    }
    mapping (address => Price) public finalPrices;//最终结果

    EnumerableSet.AddressSet private _feeders;// 支持的喂价者列表
    mapping (address => mapping (address => Price)) public _prices;

    function initialize(address _multiSig, address[] memory _initFeeders)
        public
        initializer
    {

        multiSig = _multiSig;
        admin = msg.sender;

        require(_initFeeders.length >= 1, "invalid length");
        for (uint256 i = 0; i < _initFeeders.length; i++) {
            _feeders.add(_initFeeders[i]);
        }
    }



    modifier auth {

        require(_feeders.contains(msg.sender), "unauthorized feeder");
        _;
    }

    modifier onlyMultiSig {

        require(msg.sender == multiSig, "require multiSig");
        _;
    }

    function setMultiSig(address _multiSig) external onlyMultiSig {

        multiSig = _multiSig;
    }

    modifier onlyAdmin {

        require(msg.sender == admin, "require admin");
        _;
    }

    function setAdmin(address _admin) external onlyMultiSig {

        admin = _admin;
    }

    function enable(address feeder) public onlyMultiSig {

        require(!_feeders.contains(feeder), "duplicated feeder");
        _feeders.add(feeder);
        emit Enable(feeder);
    }

    function disable(address feeder) public onlyMultiSig {

        require(_feeders.contains(feeder), "not exist");
        _feeders.remove(feeder);

        for (uint i = 0; i < _tokens.length(); i++) {
            delete _prices[feeder][_tokens.at(i)];
        }
        emit Disable(feeder);
    }

    function enables(address[] calldata feeders) external onlyMultiSig {

        for (uint256 i = 0; i < feeders.length; i++) {
            enable(feeders[i]);
        }
        emit Enables(feeders);
    }

    function disables(address[] calldata feeders) external onlyMultiSig {

        for (uint256 i = 0; i < feeders.length; i++) {
            disable(feeders[i]);
        }
        emit Disables(feeders);
    }

    function enableToken(address token) public onlyAdmin {

        require(_tokens.add(token), "Duplicate token");
        emit EnableToken(token);
    }

    function disableToken(address token) public onlyAdmin {

        require(_tokens.remove(token), "nonexist token");
        emit DisableToken(token);
    }

    function enableTokens(address[] calldata tokens) external onlyAdmin {

        for (uint256 i = 0; i < tokens.length; i++) {
            enableToken(tokens[i]);
        }
        emit EnableTokens(tokens);
    }

    function disableTokens(address[] calldata tokens) external onlyAdmin {

        for (uint256 i = 0; i < tokens.length; i++) {
            disableToken(tokens[i]);
        }
        emit DisableTokens(tokens);
    }

    function tokens() public view returns (address[] memory) {

        address[] memory values = new address[](_tokens.length());
        for (uint256 i = 0; i < _tokens.length(); ++i) {
            values[i] = _tokens.at(i);
        }
        return values;
    }

    function set(address token, uint val, uint exp) public auth {

        require(_feeders.contains(msg.sender), "unauth feeder");

        _prices[msg.sender][token].price = uint192(val);
        _prices[msg.sender][token].expiration = uint64(now + exp);

        int256[] memory priceList = new int256[](_feeders.length());
        uint256 j = 0;
        for (uint256 i = 0; i < _feeders.length(); i++) {
            address who = _feeders.at(i);
            if (_prices[who][token].price != 0 && now < _prices[who][token].expiration) {
                priceList[j++] = int256(_prices[who][token].price);
            }
        }

        int256[] memory priceFilter = new int256[](j);
        for (uint256 i = 0; i < j; i++) {
            priceFilter[i] = priceList[i];
        }

        finalPrices[token].price = uint192(Median.calculateInplace(priceFilter));
        finalPrices[token].expiration = uint64(now + exp);

        emit Set(msg.sender, token, val, exp);
    }

    function batchSet(address[] calldata tokens, uint[] calldata vals, uint exp) external auth {

        uint nToken = tokens.length;
        require(nToken == vals.length, "invalid array length");

        for (uint i = 0; i < nToken; ++i) {
            set(tokens[i], vals[i], now + exp);
        }

        emit BatchSet(tokens, vals, exp);
    }

    function getExpiration(address token) external view returns (uint) {

        return finalPrices[token].expiration;
    }

    function getPrice(address token) external view returns (uint) {

        return finalPrices[token].price;
    }

    function get(address token) external override view returns (uint, bool) {

        return (finalPrices[token].price, valid(token));
    }

    function valid(address token) public view returns (bool) {

        return now < finalPrices[token].expiration;
    }

    function getLastPriceByFeeder(address feeder, address token) public view returns (uint price, uint expiration) {

        return (_prices[feeder][token].price, _prices[feeder][token].expiration);
    }
}