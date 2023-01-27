



pragma solidity ^0.8.0;

contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}



pragma solidity ^0.8.0;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function decimals() external view returns (uint8);

    function balanceOf(address account) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);

}



pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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



pragma solidity ^0.8.0;


library SafeERC20 {

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

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender) - value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}



pragma solidity ^0.8.0;

interface IBonusRewards {

  event Deposit(address indexed user, address indexed lpToken, uint256 amount);
  event Withdraw(address indexed user, address indexed lpToken, uint256 amount);

  struct Bonus {
    address bonusTokenAddr; // the external bonus token, like CRV
    uint48 startTime;
    uint48 endTime;
    uint256 weeklyRewards; // total amount to be distributed from start to end
    uint256 accRewardsPerToken; // accumulated bonus to the lastUpdated Time
    uint256 remBonus; // remaining bonus in contract
  }

  struct Pool {
    Bonus[] bonuses;
    uint256 lastUpdatedAt; // last accumulated bonus update timestamp
  }

  struct User {
    uint256 amount;
    uint256[] rewardsWriteoffs; // the amount of bonus tokens to write off when calculate rewards from last update
  }

  function getPoolList() external view returns (address[] memory);

  function getResponders() external view returns (address[] memory);

  function getPool(address _lpToken) external view returns (Pool memory);

  function getUser(address _lpToken, address _account) external view returns (User memory _user, uint256[] memory _rewards);

  function getAuthorizers(address _lpToken, address _bonusTokenAddr) external view returns (address[] memory);

  function viewRewards(address _lpToken, address _user) external view  returns (uint256[] memory);


  function claimRewardsForPools(address[] calldata _lpTokens) external;

  function deposit(address _lpToken, uint256 _amount) external;

  function withdraw(address _lpToken, uint256 _amount) external;

  function emergencyWithdraw(address[] calldata _lpTokens) external;

  function addBonus(
    address _lpToken,
    address _bonusTokenAddr,
    uint48 _startTime,
    uint256 _weeklyRewards,
    uint256 _transferAmount
  ) external;

  function extendBonus(
    address _lpToken,
    uint256 _poolBonusId,
    address _bonusTokenAddr,
    uint256 _transferAmount
  ) external;

  function updateBonus(
    address _lpToken,
    address _bonusTokenAddr,
    uint256 _weeklyRewards,
    uint48 _startTime
  ) external;


  function setResponders(address[] calldata _responders) external;

  function setPaused(bool _paused) external;

  function collectDust(address _token, address _lpToken, uint256 _poolBonusId) external;

  function addPoolsAndAllowBonus(
    address[] calldata _lpTokens,
    address[] calldata _bonusTokenAddrs,
    address[] calldata _authorizers
  ) external;

}



pragma solidity ^0.8.0;




contract BonusRewards is IBonusRewards, Ownable, ReentrancyGuard {

  using SafeERC20 for IERC20;

  bool public paused;
  uint256 private constant WEEK = 7 days;
  uint256 private constant CAL_MULTIPLIER = 1e30;
  address[] private responders;
  address[] private poolList;
  mapping(address => Pool) private pools;
  mapping(address => mapping(address => User)) private users;
  mapping(address => mapping(address => address[])) private allowedTokenAuthorizers;
  mapping(address => uint8) private bonusTokenAddrMap;

  modifier notPaused() {

    require(!paused, "BonusRewards: paused");
    _;
  }

  function claimRewardsForPools(address[] calldata _lpTokens) external override nonReentrant notPaused {

    for (uint256 i = 0; i < _lpTokens.length; i++) {
      address lpToken = _lpTokens[i];
      User memory user = users[lpToken][msg.sender];
      if (user.amount == 0) continue;
      _updatePool(lpToken);
      _claimRewards(lpToken, user);
      _updateUserWriteoffs(lpToken);
    }
  }

  function deposit(address _lpToken, uint256 _amount) external override nonReentrant notPaused {

    require(pools[_lpToken].lastUpdatedAt > 0, "Blacksmith: pool does not exists");
    require(IERC20(_lpToken).balanceOf(msg.sender) >= _amount, "Blacksmith: insufficient balance");

    _updatePool(_lpToken);
    User storage user = users[_lpToken][msg.sender];
    _claimRewards(_lpToken, user);

    IERC20 token = IERC20(_lpToken);
    uint256 balanceBefore = token.balanceOf(address(this));
    token.safeTransferFrom(msg.sender, address(this), _amount);
    uint256 received = token.balanceOf(address(this)) - balanceBefore;

    user.amount = user.amount + received;
    _updateUserWriteoffs(_lpToken);
    emit Deposit(msg.sender, _lpToken, received);
  }

  function withdraw(address _lpToken, uint256 _amount) external override nonReentrant notPaused {

    require(pools[_lpToken].lastUpdatedAt > 0, "Blacksmith: pool does not exists");
    _updatePool(_lpToken);

    User storage user = users[_lpToken][msg.sender];
    _claimRewards(_lpToken, user);
    uint256 amount = user.amount > _amount ? _amount : user.amount;
    user.amount = user.amount - amount;
    _updateUserWriteoffs(_lpToken);

    _safeTransfer(_lpToken, amount);
    emit Withdraw(msg.sender, _lpToken, amount);
  }

  function emergencyWithdraw(address[] calldata _lpTokens) external override nonReentrant {

    for (uint256 i = 0; i < _lpTokens.length; i++) {
      User storage user = users[_lpTokens[i]][msg.sender];
      uint256 amount = user.amount;
      user.amount = 0;
      _safeTransfer(_lpTokens[i], amount);
      emit Withdraw(msg.sender, _lpTokens[i], amount);
    }
  }

  function addBonus(
    address _lpToken,
    address _bonusTokenAddr,
    uint48 _startTime,
    uint256 _weeklyRewards,
    uint256 _transferAmount
  ) external override nonReentrant notPaused {

    require(_isAuthorized(allowedTokenAuthorizers[_lpToken][_bonusTokenAddr]), "BonusRewards: not authorized caller");
    require(_startTime >= block.timestamp, "BonusRewards: startTime in the past");

    Pool memory pool = pools[_lpToken];
    require(pool.lastUpdatedAt > 0, "BonusRewards: pool does not exist");
    Bonus[] memory bonuses = pool.bonuses;
    for (uint256 i = 0; i < bonuses.length; i++) {
      if (bonuses[i].bonusTokenAddr == _bonusTokenAddr) {
        require(bonuses[i].endTime + WEEK < block.timestamp, "BonusRewards: last bonus period hasn't ended");
        require(bonuses[i].remBonus == 0, "BonusRewards: last bonus not all claimed");
      }
    }

    IERC20 bonusTokenAddr = IERC20(_bonusTokenAddr);
    uint256 balanceBefore = bonusTokenAddr.balanceOf(address(this));
    bonusTokenAddr.safeTransferFrom(msg.sender, address(this), _transferAmount);
    uint256 received = bonusTokenAddr.balanceOf(address(this)) - balanceBefore;
    uint48 endTime = uint48(received * WEEK / _weeklyRewards + _startTime);

    pools[_lpToken].bonuses.push(Bonus({
      bonusTokenAddr: _bonusTokenAddr,
      startTime: _startTime,
      endTime: endTime,
      weeklyRewards: _weeklyRewards,
      accRewardsPerToken: 0,
      remBonus: received
    }));
  }

  function updateBonus(
    address _lpToken,
    address _bonusTokenAddr,
    uint256 _weeklyRewards,
    uint48 _startTime
  ) external override nonReentrant notPaused {

    require(_isAuthorized(allowedTokenAuthorizers[_lpToken][_bonusTokenAddr]), "BonusRewards: not authorized caller");
    require(_startTime == 0 || _startTime > block.timestamp, "BonusRewards: startTime in the past");

    Pool memory pool = pools[_lpToken];
    require(pool.lastUpdatedAt > 0, "BonusRewards: pool does not exist");
    Bonus[] memory bonuses = pool.bonuses;
    for (uint256 i = 0; i < bonuses.length; i++) {
      if (bonuses[i].bonusTokenAddr == _bonusTokenAddr && bonuses[i].endTime > block.timestamp) {
        Bonus storage bonus = pools[_lpToken].bonuses[i];
        _updatePool(_lpToken); // update pool with old weeklyReward to this block
        if (bonus.startTime >= block.timestamp) {
          if (_startTime >= block.timestamp) {
            bonus.startTime = _startTime;
          }
          bonus.endTime = uint48(bonus.remBonus * WEEK / _weeklyRewards + bonus.startTime);
        } else {
          uint256 remBonusToDistribute = (bonus.endTime - block.timestamp) * bonus.weeklyRewards / WEEK;
          bonus.endTime = uint48(remBonusToDistribute * WEEK / _weeklyRewards + block.timestamp);
        }
        bonus.weeklyRewards = _weeklyRewards;
      }
    }
  }

  function extendBonus(
    address _lpToken,
    uint256 _poolBonusId,
    address _bonusTokenAddr,
    uint256 _transferAmount
  ) external override nonReentrant notPaused {

    require(_isAuthorized(allowedTokenAuthorizers[_lpToken][_bonusTokenAddr]), "BonusRewards: not authorized caller");

    Bonus memory bonus = pools[_lpToken].bonuses[_poolBonusId];
    require(bonus.bonusTokenAddr == _bonusTokenAddr, "BonusRewards: bonus and id dont match");
    require(bonus.endTime > block.timestamp, "BonusRewards: bonus program ended, please start a new one");

    IERC20 bonusTokenAddr = IERC20(_bonusTokenAddr);
    uint256 balanceBefore = bonusTokenAddr.balanceOf(address(this));
    bonusTokenAddr.safeTransferFrom(msg.sender, address(this), _transferAmount);
    uint256 received = bonusTokenAddr.balanceOf(address(this)) - balanceBefore;
    uint48 endTime = uint48(received * WEEK / bonus.weeklyRewards + bonus.endTime);

    pools[_lpToken].bonuses[_poolBonusId].endTime = endTime;
    pools[_lpToken].bonuses[_poolBonusId].remBonus = bonus.remBonus + received;
  }

  function addPoolsAndAllowBonus(
    address[] calldata _lpTokens,
    address[] calldata _bonusTokenAddrs,
    address[] calldata _authorizers
  ) external override onlyOwner notPaused {

    uint256 currentTime = block.timestamp;
    for (uint256 i = 0; i < _lpTokens.length; i++) {
      address _lpToken = _lpTokens[i];
      require(IERC20(_lpToken).decimals() <= 18, "BonusRewards: lptoken decimals > 18");
      if (pools[_lpToken].lastUpdatedAt == 0) {
        pools[_lpToken].lastUpdatedAt = currentTime;
        poolList.push(_lpToken);
      }

      for (uint256 j = 0; j < _bonusTokenAddrs.length; j++) {
        address _bonusTokenAddr = _bonusTokenAddrs[j];
        require(pools[_bonusTokenAddr].lastUpdatedAt == 0, "BonusRewards: lpToken, not allowed");
        allowedTokenAuthorizers[_lpToken][_bonusTokenAddr] = _authorizers;
        bonusTokenAddrMap[_bonusTokenAddr] = 1;
      }
    }
  }

  function collectDust(address _token, address _lpToken, uint256 _poolBonusId) external override onlyOwner {

    require(pools[_token].lastUpdatedAt == 0, "BonusRewards: lpToken, not allowed");

    if (_token == address(0)) { // token address(0) = ETH
      payable(owner()).transfer(address(this).balance);
    } else {
      uint256 balance = IERC20(_token).balanceOf(address(this));
      if (bonusTokenAddrMap[_token] == 1) {
        Bonus memory bonus = pools[_lpToken].bonuses[_poolBonusId];
        require(bonus.bonusTokenAddr == _token, "BonusRewards: wrong pool");
        require(bonus.endTime + WEEK < block.timestamp, "BonusRewards: not ready");
        balance = bonus.remBonus;
        pools[_lpToken].bonuses[_poolBonusId].remBonus = 0;
      }

      IERC20(_token).transfer(owner(), balance);
    }
  }

  function setResponders(address[] calldata _responders) external override onlyOwner {

    responders = _responders;
  }

  function setPaused(bool _paused) external override {

    require(_isAuthorized(responders), "BonusRewards: caller not responder");
    paused = _paused;
  }

  function getPool(address _lpToken) external view override returns (Pool memory) {

    return pools[_lpToken];
  }

  function getUser(address _lpToken, address _account) external view override returns (User memory, uint256[] memory) {

    return (users[_lpToken][_account], viewRewards(_lpToken, _account));
  }

  function getAuthorizers(address _lpToken, address _bonusTokenAddr) external view override returns (address[] memory) {

    return allowedTokenAuthorizers[_lpToken][_bonusTokenAddr];
  }

  function getResponders() external view override returns (address[] memory) {

    return responders;
  }

  function viewRewards(address _lpToken, address _user) public view override returns (uint256[] memory) {

    Pool memory pool = pools[_lpToken];
    User memory user = users[_lpToken][_user];
    uint256[] memory rewards = new uint256[](pool.bonuses.length);
    if (user.amount <= 0) return rewards;

    uint256 rewardsWriteoffsLen = user.rewardsWriteoffs.length;
    for (uint256 i = 0; i < rewards.length; i ++) {
      Bonus memory bonus = pool.bonuses[i];
      if (bonus.startTime < block.timestamp && bonus.remBonus > 0) {
        uint256 lpTotal = IERC20(_lpToken).balanceOf(address(this));
        uint256 bonusForTime = _calRewardsForTime(bonus, pool.lastUpdatedAt);
        uint256 bonusPerToken = bonus.accRewardsPerToken + bonusForTime / lpTotal;
        uint256 rewardsWriteoff = rewardsWriteoffsLen <= i ? 0 : user.rewardsWriteoffs[i];
        uint256 reward = user.amount * bonusPerToken / CAL_MULTIPLIER - rewardsWriteoff;
        rewards[i] = reward < bonus.remBonus ? reward : bonus.remBonus;
      }
    }
    return rewards;
  }


  function getPoolList() external view override returns (address[] memory) {

    return poolList;
  }

  function _updatePool(address _lpToken) private {

    Pool storage pool = pools[_lpToken];
    uint256 poolLastUpdatedAt = pool.lastUpdatedAt;
    if (poolLastUpdatedAt == 0 || block.timestamp <= poolLastUpdatedAt) return;
    pool.lastUpdatedAt = block.timestamp;
    uint256 lpTotal = IERC20(_lpToken).balanceOf(address(this));
    if (lpTotal == 0) return;

    for (uint256 i = 0; i < pool.bonuses.length; i ++) {
      Bonus storage bonus = pool.bonuses[i];
      if (poolLastUpdatedAt < bonus.endTime && bonus.startTime < block.timestamp) {
        uint256 bonusForTime = _calRewardsForTime(bonus, poolLastUpdatedAt);
        bonus.accRewardsPerToken = bonus.accRewardsPerToken + bonusForTime / lpTotal;
      }
    }
  }

  function _updateUserWriteoffs(address _lpToken) private {

    Bonus[] memory bonuses = pools[_lpToken].bonuses;
    User storage user = users[_lpToken][msg.sender];
    for (uint256 i = 0; i < bonuses.length; i++) {
      if (user.rewardsWriteoffs.length == i) {
        user.rewardsWriteoffs.push(user.amount * bonuses[i].accRewardsPerToken / CAL_MULTIPLIER);
      } else {
        user.rewardsWriteoffs[i] = user.amount * bonuses[i].accRewardsPerToken / CAL_MULTIPLIER;
      }
    }
  }

  function _safeTransfer(address _token, uint256 _amount) private returns (uint256 _transferred) {

    IERC20 token = IERC20(_token);
    uint256 balance = token.balanceOf(address(this));
    if (balance > _amount) {
      token.safeTransfer(msg.sender, _amount);
      _transferred = _amount;
    } else if (balance > 0) {
      token.safeTransfer(msg.sender, balance);
      _transferred = balance;
    }
  }

  function _calRewardsForTime(Bonus memory _bonus, uint256 _lastUpdatedAt) internal view returns (uint256) {

    if (_bonus.endTime <= _lastUpdatedAt) return 0;

    uint256 calEndTime = block.timestamp > _bonus.endTime ? _bonus.endTime : block.timestamp;
    uint256 calStartTime = _lastUpdatedAt > _bonus.startTime ? _lastUpdatedAt : _bonus.startTime;
    uint256 timePassed = calEndTime - calStartTime;
    return _bonus.weeklyRewards * CAL_MULTIPLIER * timePassed / WEEK;
  }

  function _claimRewards(address _lpToken, User memory _user) private {

    if (_user.amount == 0) return;
    uint256 rewardsWriteoffsLen = _user.rewardsWriteoffs.length;
    Bonus[] memory bonuses = pools[_lpToken].bonuses;
    for (uint256 i = 0; i < bonuses.length; i++) {
      uint256 rewardsWriteoff = rewardsWriteoffsLen <= i ? 0 : _user.rewardsWriteoffs[i];
      uint256 bonusSinceLastUpdate = _user.amount * bonuses[i].accRewardsPerToken / CAL_MULTIPLIER - rewardsWriteoff;
      uint256 toTransfer = bonuses[i].remBonus < bonusSinceLastUpdate ? bonuses[i].remBonus : bonusSinceLastUpdate;
      if (toTransfer == 0) continue;
      uint256 transferred = _safeTransfer(bonuses[i].bonusTokenAddr, toTransfer);
      pools[_lpToken].bonuses[i].remBonus = bonuses[i].remBonus - transferred;
    }
  }

  function _isAuthorized(address[] memory checkList) private view returns (bool) {

    if (msg.sender == owner()) return true;

    for (uint256 i = 0; i < checkList.length; i++) {
      if (msg.sender == checkList[i]) {
        return true;
      }
    }
    return false;
  }
}