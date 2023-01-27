
pragma solidity ^0.8.0;

library AddressUpgradeable {

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
}// MIT

pragma solidity ^0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
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

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;


library SafeERC20Upgradeable {

    using AddressUpgradeable for address;

    function safeTransfer(IERC20Upgradeable token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20Upgradeable token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20Upgradeable token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// Apache-2.0
pragma solidity 0.8.7;

interface IIdleCDOStrategy {

  function strategyToken() external view returns(address);

  function token() external view returns(address);

  function tokenDecimals() external view returns(uint256);

  function oneToken() external view returns(uint256);

  function redeemRewards() external;

  function pullStkAAVE() external returns(uint256);

  function price() external view returns(uint256);

  function getRewardTokens() external view returns(address[] memory);

  function deposit(uint256 _amount) external returns(uint256);

  function redeem(uint256 _amount) external returns(uint256);

  function redeemUnderlying(uint256 _amount) external returns(uint256);

  function getApr() external view returns(uint256);

}// Apache-2.0
pragma solidity 0.8.7;


interface IERC20Detailed is IERC20Upgradeable {

  function name() external view returns(string memory);

  function symbol() external view returns(string memory);

  function decimals() external view returns(uint256);

}// Apache-2.0
pragma solidity 0.8.7;

interface IIdleCDOTrancheRewards {

  function stake(uint256 _amount) external;

  function stakeFor(address _user, uint256 _amount) external;

  function unstake(uint256 _amount) external;

  function depositReward(address _reward, uint256 _amount) external;

}// Apache-2.0
pragma solidity 0.8.7;

interface IIdleCDO {

  function redeemRewards() external;

}// Apache-2.0
pragma solidity 0.8.7;

contract IdleCDOTrancheRewardsStorage {

  uint256 public constant ONE_TRANCHE_TOKEN = 10**18;
  address public idleCDO;
  address public tranche;
  address public governanceRecoveryFund;
  address[] public rewards;
  mapping(address => uint256) public usersStakes;
  mapping(address => uint256) public rewardsIndexes;
  mapping(address => mapping(address => uint256)) public usersIndexes;
  mapping(address => uint256) public lockedRewards;
  mapping(address => uint256) public lockedRewardsLastBlock;
  uint256 public totalStaked;
  uint256 public coolingPeriod;
}// UNLICENSED
pragma solidity 0.8.7;




contract IdleCDOTrancheRewards is Initializable, PausableUpgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable, IIdleCDOTrancheRewards, IdleCDOTrancheRewardsStorage {

  using SafeERC20Upgradeable for IERC20Detailed;

  constructor() {
    tranche = address(1);
  }

  function initialize(
    address _trancheToken, address[] memory _rewards, address _owner,
    address _idleCDO, address _governanceRecoveryFund, uint256 _coolingPeriod
  ) public initializer {

    require(tranche == address(0), 'Initialized');
    require(_owner != address(0) && _trancheToken != address(0) && _idleCDO != address(0) && _governanceRecoveryFund != address(0), "IS_0");
    OwnableUpgradeable.__Ownable_init();
    ReentrancyGuardUpgradeable.__ReentrancyGuard_init();
    PausableUpgradeable.__Pausable_init();
    transferOwnership(_owner);
    idleCDO = _idleCDO;
    tranche = _trancheToken;
    rewards = _rewards;
    governanceRecoveryFund = _governanceRecoveryFund;
    coolingPeriod = _coolingPeriod;
  }

  function stake(uint256 _amount) external whenNotPaused override {

    _stake(msg.sender, msg.sender, _amount);
  }

  function stakeFor(address _user, uint256 _amount) external whenNotPaused override {

    require(msg.sender == idleCDO, "!AUTH");
    _stake(_user, msg.sender, _amount);
  }

  function _stake(address _user, address _payer, uint256 _amount) internal {

    if (_amount == 0) {
      return;
    }
    _updateUserIdx(_user, _amount);
    usersStakes[_user] += _amount;
    IERC20Detailed(tranche).safeTransferFrom(_payer, address(this), _amount);
    totalStaked += _amount;
  }

  function unstake(uint256 _amount) external nonReentrant override {

    if (_amount == 0) {
      return;
    }
    if (paused()) {
      address reward;
      for (uint256 i = 0; i < rewards.length; i++) {
        reward = rewards[i];
        usersIndexes[msg.sender][reward] = adjustedRewardIndex(reward);
      }
    } else {
      _claim();
    }
    usersStakes[msg.sender] -= _amount;
    IERC20Detailed(tranche).safeTransfer(msg.sender, _amount);
    totalStaked -= _amount;
  }

  function claim() whenNotPaused nonReentrant external {

    _claim();
  }

  function _claim() internal {

    address[] memory _rewards = rewards;
    for (uint256 i = 0; i < _rewards.length; i++) {
      address reward = _rewards[i];
      uint256 amount = expectedUserReward(msg.sender, reward);
      uint256 balance = IERC20Detailed(reward).balanceOf(address(this));
      if (amount > balance) {
        amount = balance;
      }
      usersIndexes[msg.sender][reward] = adjustedRewardIndex(reward);
      IERC20Detailed(reward).safeTransfer(msg.sender, amount);
    }
  }

  function expectedUserReward(address user, address reward) public view returns (uint256) {

    require(_includesAddress(rewards, reward), "!SUPPORTED");
    uint256 _globalIdx = adjustedRewardIndex(reward);
    uint256 _userIdx = usersIndexes[user][reward];
    if (_userIdx > _globalIdx) {
      return 0;
    }

    return ((_globalIdx - _userIdx) * usersStakes[user]) / ONE_TRANCHE_TOKEN;
  }

  function adjustedRewardIndex(address _reward) public view returns (uint256 _index) {

    uint256 _totalStaked = totalStaked;
    uint256 _lockedRewards = lockedRewards[_reward];
    _index = rewardsIndexes[_reward];

    if (_totalStaked > 0 && _lockedRewards > 0) {
      uint256 distance = block.number - lockedRewardsLastBlock[_reward];
      if (distance < coolingPeriod) {
        uint256 unlockedRewards = _lockedRewards * distance / coolingPeriod;
        uint256 lockedRewards = _lockedRewards - unlockedRewards;
        _index -= lockedRewards * ONE_TRANCHE_TOKEN / _totalStaked;
      }
    }
  }

  function depositReward(address _reward, uint256 _amount) external override {

    require(msg.sender == idleCDO, "!AUTH");
    require(_includesAddress(rewards, _reward), "!SUPPORTED");
    IERC20Detailed(_reward).safeTransferFrom(msg.sender, address(this), _amount);
    if (totalStaked > 0) {
      rewardsIndexes[_reward] += _amount * ONE_TRANCHE_TOKEN / totalStaked;
    }
    lockedRewards[_reward] = _amount;
    lockedRewardsLastBlock[_reward] = block.number;
  }

  function setCoolingPeriod(uint256 _newCoolingPeriod) external onlyOwner {

    coolingPeriod = _newCoolingPeriod;
  }

  function _updateUserIdx(address _user, uint256 _amountToStake) internal {

    address[] memory _rewards = rewards;
    uint256 userIndex;
    address reward;
    uint256 _currStake = usersStakes[_user];

    for (uint256 i = 0; i < _rewards.length; i++) {
      reward = _rewards[i];
      if (_currStake == 0) {
        usersIndexes[_user][reward] = rewardsIndexes[reward];
      } else {
        userIndex = usersIndexes[_user][reward];
        usersIndexes[_user][reward] = userIndex + (
          _amountToStake * (rewardsIndexes[reward] - userIndex) / (_currStake + _amountToStake)
        );
      }
    }
  }

  function _includesAddress(address[] memory _array, address _val) internal pure returns (bool) {

    for (uint256 i = 0; i < _array.length; i++) {
      if (_array[i] == _val) {
        return true;
      }
    }
    return false;
  }

  function transferToken(address token, uint256 value) external onlyOwner nonReentrant {

    require(token != address(0), 'Address is 0');
    IERC20Detailed(token).safeTransfer(governanceRecoveryFund, value);
  }

  function pause() external onlyOwner {

    _pause();
  }

  function unpause() external onlyOwner {

    _unpause();
  }
}