

pragma solidity 0.6.12;




interface IAlphaStaking {

  function getStakeValue(address) external view returns (uint);


  function stake(uint) external;


  function unbond(uint) external;


  function withdraw() external;


  function reward(uint amount) external;


  function skim(uint amount) external;


  function extract(uint amount) external;

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

  address public governor; // The current governor.
  address public pendingGovernor; // The address pending to become the governor once accepted.

  modifier onlyGov() {

    require(msg.sender == governor, 'not the governor');
    _;
  }

  function __Governable__init() internal initializer {

    governor = msg.sender;
    pendingGovernor = address(0);
  }

  function setPendingGovernor(address _pendingGovernor) external onlyGov {

    pendingGovernor = _pendingGovernor;
  }

  function acceptGovernor() external {

    require(msg.sender == pendingGovernor, 'not the pending governor');
    pendingGovernor = address(0);
    governor = msg.sender;
  }
}


contract AlphaStakingTier is Initializable, Governable {

  using SafeMath for uint;

  event SetAlphaTier(uint index, uint upperLimit);
  event DeleteAlphaTier(uint index);

  IAlphaStaking public staking;
  mapping(uint => uint) public tiers;
  uint public tierCount;

  function initialize(address _staking) external initializer {

    __Governable__init();
    staking = IAlphaStaking(_staking);
  }

  function getAlphaTier(address user) external view returns (uint index) {

    uint stakeAmount = staking.getStakeValue(user);
    uint _tierCount = tierCount;
    for (uint i = 0; i < _tierCount; i++) {
      if (stakeAmount < tiers[i]) {
        return i;
      }
    }
    return _tierCount.sub(1);
  }

  function setAlphaTiers(uint[] calldata upperLimits) external onlyGov {

    for (uint lIndex = 0; lIndex < upperLimits.length; lIndex++) {
      if (lIndex > 0) {
        require(
          upperLimits[lIndex] > upperLimits[lIndex - 1],
          'setAlphaTiers: upperLimits should be strictly increasing'
        );
      } else {
        require(upperLimits[lIndex] > 0, 'setAlphaTiers: first tier upper limit should be > 0');
      }
      tiers[lIndex] = upperLimits[lIndex];
      emit SetAlphaTier(lIndex, upperLimits[lIndex]);
    }

    uint _tierCount = tierCount; // gas opt
    for (uint eIndex = upperLimits.length; eIndex < _tierCount; eIndex++) {
      delete tiers[eIndex];
      emit DeleteAlphaTier(eIndex);
    }

    tierCount = upperLimits.length;
  }

  function updateAlphaTier(uint index, uint upperLimit) external onlyGov {

    require(index < tierCount, 'updateAlphaTier: index out of range');
    require(upperLimit != 0, 'updateAlphaTier: upper limit cannot be 0');
    if (0 < index) {
      require(
        tiers[index - 1] < upperLimit,
        'updateAlphaTier: new upper limit must be more than the previous tier'
      );
    }
    if (index < tierCount.sub(1)) {
      require(
        upperLimit < tiers[index + 1],
        'updateAlphaTier: new upper limit must be less than the next tier'
      );
    }
    tiers[index] = upperLimit;
    emit SetAlphaTier(index, upperLimit);
  }
}