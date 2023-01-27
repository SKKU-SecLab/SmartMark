
pragma solidity ^0.8.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b + (a % b == 0 ? 0 : 1);
    }
}// MIT

pragma solidity ^0.8.0;

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
}// MIT

pragma solidity ^0.8.0;

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

        (bool success, ) = recipient.call{value: amount}("");
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

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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
        return verifyCallResult(success, returndata, errorMessage);
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
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

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
}// MIT

pragma solidity ^0.8.0;


library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
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
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) {

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

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

        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {

        return set._values;
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

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {

        return _values(set._inner);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
    }

    function values(AddressSet storage set) internal view returns (address[] memory) {

        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
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

    function values(UintSet storage set) internal view returns (uint256[] memory) {

        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}// MIT
pragma solidity >=0.8.4 <0.9.0;

interface IGovernable {


  event GovernanceSet(address _governance);

  event GovernanceProposal(address _pendingGovernance);


  error OnlyGovernance();

  error OnlyPendingGovernance();

  error NoGovernanceZeroAddress();


  function governance() external view returns (address _governance);


  function pendingGovernance() external view returns (address _pendingGovernance);



  function setGovernance(address _governance) external;


  function acceptGovernance() external;

}// MIT
pragma solidity >=0.8.4 <0.9.0;


abstract contract Governable is IGovernable {
  address public override governance;

  address public override pendingGovernance;

  constructor(address _governance) {
    if (_governance == address(0)) revert NoGovernanceZeroAddress();
    governance = _governance;
  }

  function setGovernance(address _governance) external override onlyGovernance {
    pendingGovernance = _governance;
    emit GovernanceProposal(_governance);
  }

  function acceptGovernance() external override onlyPendingGovernance {
    governance = pendingGovernance;
    delete pendingGovernance;
    emit GovernanceSet(governance);
  }

  modifier onlyGovernance() {
    if (msg.sender != governance) revert OnlyGovernance();
    _;
  }

  modifier onlyPendingGovernance() {
    if (msg.sender != pendingGovernance) revert OnlyPendingGovernance();
    _;
  }
}// MIT

pragma solidity >=0.8.4 <0.9.0;

interface IBaseErrors {

  error ZeroAddress();
}// MIT

pragma solidity >=0.8.4 <0.9.0;


interface IDustCollector is IBaseErrors {

  event DustSent(address _token, uint256 _amount, address _to);

  function sendDust(address _token) external;

}// MIT
pragma solidity >=0.8.4 <0.9.0;


interface IVestingWallet is IDustCollector {


  error WrongLengthAmounts();


  event BenefitAdded(address indexed token, address indexed beneficiary, uint256 amount, uint256 startDate, uint256 releaseDate);

  event BenefitRemoved(address indexed token, address indexed beneficiary, uint256 removedAmount);

  event BenefitReleased(address indexed token, address indexed beneficiary, uint256 releasedAmount);


  struct Benefit {
    uint256 amount; // Amount of vested token for the inputted beneficiary
    uint256 startDate; // Timestamp at which the benefit starts to take effect
    uint256 duration; // Seconds to unlock the full benefit
    uint256 released; // The amount of vested tokens already released
  }


  function getBeneficiaries() external view returns (address[] memory _beneficiaries);


  function getTokens() external view returns (address[] memory _tokens);


  function getTokensOf(address _beneficiary) external view returns (address[] memory _tokens);


  function benefits(address _token, address _beneficiary)
    external
    view
    returns (
      uint256 amount,
      uint256 startDate,
      uint256 duration,
      uint256 released
    );


  function releaseDate(address _token, address _beneficiary) external view returns (uint256 _releaseDate);


  function releasableAmount(address _token, address _beneficiary) external view returns (uint256 _claimableAmount);


  function totalAmountPerToken(address _token) external view returns (uint256 _totalAmount);



  function addBenefit(
    address _beneficiary,
    uint256 _startDate,
    uint256 _duration,
    address _token,
    uint256 _amount
  ) external;


  function addBenefits(
    address _token,
    address[] memory _beneficiaries,
    uint256[] memory _amounts,
    uint256 _startDate,
    uint256 _duration
  ) external;


  function removeBenefit(address _token, address _beneficiary) external;


  function removeBeneficiary(address _beneficiary) external;


  function release(address _token) external;


  function release(address _token, address _beneficiary) external;


  function release(address[] memory _tokens) external;


  function release(address[] memory _tokens, address _beneficiary) external;


  function releaseAll() external;


  function releaseAll(address _beneficiary) external;

}// MIT


pragma solidity >=0.8.4 <0.9.0;


contract VestingWallet is IVestingWallet, Governable {

  using SafeERC20 for IERC20;
  using EnumerableSet for EnumerableSet.AddressSet;

  EnumerableSet.AddressSet internal _vestedTokens;
  EnumerableSet.AddressSet internal _beneficiaries;
  mapping(address => EnumerableSet.AddressSet) internal _tokensPerBeneficiary; // beneficiary => [tokens]
  mapping(address => uint256) public override totalAmountPerToken; // token => amount
  mapping(address => mapping(address => Benefit)) public override benefits; // token => beneficiary => benefit

  constructor(address _governance) Governable(_governance) {}


  function releaseDate(address _token, address _beneficiary) external view override returns (uint256) {

    Benefit memory _benefit = benefits[_token][_beneficiary];

    return _benefit.startDate + _benefit.duration;
  }

  function releasableAmount(address _token, address _beneficiary) external view override returns (uint256) {

    Benefit memory _benefit = benefits[_token][_beneficiary];

    return _releasableSchedule(_benefit) - _benefit.released;
  }

  function getBeneficiaries() external view override returns (address[] memory) {

    return _beneficiaries.values();
  }

  function getTokens() external view override returns (address[] memory) {

    return _vestedTokens.values();
  }

  function getTokensOf(address _beneficiary) external view override returns (address[] memory) {

    return _tokensPerBeneficiary[_beneficiary].values();
  }


  function addBenefit(
    address _beneficiary,
    uint256 _startDate,
    uint256 _duration,
    address _token,
    uint256 _amount
  ) external override onlyGovernance {

    _addBenefit(_beneficiary, _startDate, _duration, _token, _amount);
    totalAmountPerToken[_token] += _amount;

    IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);
  }

  function addBenefits(
    address _token,
    address[] calldata __beneficiaries,
    uint256[] calldata _amounts,
    uint256 _startDate,
    uint256 _duration
  ) external override onlyGovernance {

    uint256 _length = __beneficiaries.length;
    if (_length != _amounts.length) revert WrongLengthAmounts();

    uint256 _vestedAmount;

    for (uint256 _i; _i < _length; _i++) {
      _addBenefit(__beneficiaries[_i], _startDate, _duration, _token, _amounts[_i]);
      _vestedAmount += _amounts[_i];
    }

    totalAmountPerToken[_token] += _vestedAmount;

    IERC20(_token).safeTransferFrom(msg.sender, address(this), _vestedAmount);
  }

  function removeBenefit(address _token, address _beneficiary) external override onlyGovernance {

    _removeBenefit(_token, _beneficiary);
  }

  function removeBeneficiary(address _beneficiary) external override onlyGovernance {

    while (_tokensPerBeneficiary[_beneficiary].length() > 0) {
      _removeBenefit(_tokensPerBeneficiary[_beneficiary].at(0), _beneficiary);
    }
  }

  function release(address _token) external override {

    _release(_token, msg.sender);
  }

  function release(address _token, address _beneficiary) external override {

    _release(_token, _beneficiary);
  }

  function release(address[] calldata _tokens) external override {

    _release(_tokens, msg.sender);
  }

  function release(address[] calldata _tokens, address _beneficiary) external override {

    _release(_tokens, _beneficiary);
  }

  function releaseAll() external override {

    _releaseAll(msg.sender);
  }

  function releaseAll(address _beneficiary) external override {

    _releaseAll(_beneficiary);
  }

  function sendDust(address _token) external override onlyGovernance {

    uint256 _amount;

    _amount = IERC20(_token).balanceOf(address(this)) - totalAmountPerToken[_token];
    IERC20(_token).safeTransfer(governance, _amount);

    emit DustSent(_token, _amount, governance);
  }


  function _addBenefit(
    address _beneficiary,
    uint256 _startDate,
    uint256 _duration,
    address _token,
    uint256 _amount
  ) internal {

    if (_tokensPerBeneficiary[_beneficiary].contains(_token)) {
      _release(_token, _beneficiary);
    }

    _beneficiaries.add(_beneficiary);
    _vestedTokens.add(_token);
    _tokensPerBeneficiary[_beneficiary].add(_token);

    Benefit storage _benefit = benefits[_token][_beneficiary];
    _benefit.startDate = _startDate;
    _benefit.duration = _duration;

    uint256 pendingAmount = _benefit.amount - _benefit.released;
    _benefit.amount = _amount + pendingAmount;
    _benefit.released = 0;

    emit BenefitAdded(_token, _beneficiary, _benefit.amount, _startDate, _startDate + _duration);
  }

  function _release(address _token, address _beneficiary) internal {

    Benefit storage _benefit = benefits[_token][_beneficiary];

    uint256 _releasable = _releasableSchedule(_benefit) - _benefit.released;

    if (_releasable == 0) {
      return;
    }

    _benefit.released += _releasable;
    totalAmountPerToken[_token] -= _releasable;

    if (_benefit.released == _benefit.amount) {
      _deleteBenefit(_token, _beneficiary);
    }

    IERC20(_token).safeTransfer(_beneficiary, _releasable);

    emit BenefitReleased(_token, _beneficiary, _releasable);
  }

  function _release(address[] calldata _tokens, address _beneficiary) internal {

    uint256 _length = _tokens.length;
    for (uint256 _i; _i < _length; _i++) {
      _release(_tokens[_i], _beneficiary);
    }
  }

  function _releaseAll(address _beneficiary) internal {

    address[] memory _tokens = _tokensPerBeneficiary[_beneficiary].values();
    uint256 _length = _tokens.length;
    for (uint256 _i; _i < _length; _i++) {
      _release(_tokens[_i], _beneficiary);
    }
  }

  function _removeBenefit(address _token, address _beneficiary) internal {

    _release(_token, _beneficiary);

    Benefit storage _benefit = benefits[_token][_beneficiary];

    uint256 _transferToOwner = _benefit.amount - _benefit.released;

    totalAmountPerToken[_token] -= _transferToOwner;

    if (_transferToOwner != 0) {
      IERC20(_token).safeTransfer(msg.sender, _transferToOwner);
    }

    _deleteBenefit(_token, _beneficiary);

    emit BenefitRemoved(_token, _beneficiary, _transferToOwner);
  }

  function _releasableSchedule(Benefit memory _benefit) internal view returns (uint256) {

    uint256 _timestamp = block.timestamp;
    uint256 _start = _benefit.startDate;
    uint256 _duration = _benefit.duration;
    uint256 _totalAllocation = _benefit.amount;

    if (_timestamp <= _start) {
      return 0;
    } else {
      return Math.min(_totalAllocation, (_totalAllocation * (_timestamp - _start)) / _duration);
    }
  }

  function _deleteBenefit(address _token, address _beneficiary) internal {

    delete benefits[_token][_beneficiary];

    _tokensPerBeneficiary[_beneficiary].remove(_token);

    if (_tokensPerBeneficiary[_beneficiary].length() == 0) {
      _beneficiaries.remove(_beneficiary);
    }

    if (totalAmountPerToken[_token] == 0) {
      _vestedTokens.remove(_token);
    }
  }
}