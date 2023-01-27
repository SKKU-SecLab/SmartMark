
pragma solidity ^0.7.4;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function totalSupply() external view returns (uint256);

}// None

pragma solidity ^0.7.4;

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
}// MIT

pragma solidity ^0.7.4;

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
}// MIT

pragma solidity ^0.7.4;


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
}// None

pragma solidity ^0.7.4;

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
}// MIT

pragma solidity ^0.7.0;

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
}// None

pragma solidity ^0.7.4;


interface ICOVER is IERC20 {

  function mint(address _account, uint256 _amount) external;

  function setBlacksmith(address _newBlacksmith) external returns (bool);

  function setMigrator(address _newMigrator) external returns (bool);

}// None

pragma solidity ^0.7.4;

interface IBlacksmith {

  struct Miner {
    uint256 amount;
    uint256 rewardWriteoff; // the amount of COVER tokens to write off when calculate rewards from last update
    uint256 bonusWriteoff; // the amount of bonus tokens to write off when calculate rewards from last update
  }

  struct Pool {
    uint256 weight; // the allocation weight for pool
    uint256 accRewardsPerToken; // accumulated COVER to the lastUpdated Time
    uint256 lastUpdatedAt; // last accumulated rewards update timestamp
  }

  struct BonusToken {
    address addr; // the external bonus token, like CRV
    uint256 startTime;
    uint256 endTime;
    uint256 totalBonus; // total amount to be distributed from start to end
    uint256 accBonusPerToken; // accumulated bonus to the lastUpdated Time
    uint256 lastUpdatedAt; // last accumulated bonus update timestamp
  }

  event Deposit(address indexed miner, address indexed lpToken, uint256 amount);
  event Withdraw(address indexed miner, address indexed lpToken, uint256 amount);

  function getPoolList() external view returns (address[] memory);

  function viewMined(address _lpToken, address _miner) external view returns (uint256 _minedCOVER, uint256 _minedBonus);


  function claimRewardsForPools(address[] calldata _lpTokens) external;

  function claimRewards(address _lpToken) external;

  function deposit(address _lpToken, uint256 _amount) external;

  function withdraw(address _lpToken, uint256 _amount) external;

  function emergencyWithdraw(address _lpToken) external;


  function addBonusToken(address _lpToken, address _bonusToken, uint256 _startTime, uint256 _endTime, uint256 _totalBonus) external;


  function updatePool(address _lpToken) external;

  function updatePools(uint256 _start, uint256 _end) external;

  function collectDust(address _token) external;

  function collectBonusDust(address _lpToken) external;


  function addPool(address _lpToken, uint256 _weight) external;

  function addPools(address[] calldata _lpTokens, uint256[] calldata _weights) external;

  function updateBonusTokenStatus(address _bonusToken, uint8 _status) external;


  function updatePoolWeights(address[] calldata _lpTokens, uint256[] calldata _weights) external;

  function updateWeeklyTotal(uint256 _weeklyTotal) external;

  function transferMintingRights(address _newAddress) external;

}// None
pragma solidity ^0.7.4;


contract Blacksmith is Ownable, IBlacksmith, ReentrancyGuard {

  using SafeERC20 for IERC20;
  using SafeMath for uint256;

  ICOVER public cover;
  address public governance;
  address public treasury;
  uint256 public weeklyTotal = 654e18;
  uint256 public totalWeight; // total weight for all pools
  uint256 public constant START_TIME = 1605830400; // 11/20/2020 12am UTC
  uint256 public constant WEEK = 7 days;
  uint256 private constant CAL_MULTIPLIER = 1e12; // help calculate rewards/bonus PerToken only. 1e12 will allow meaningful $1 deposit in a $1bn pool
  address[] public poolList;
  mapping(address => Pool) public pools; // lpToken => Pool
  mapping(address => BonusToken) public bonusTokens; // lpToken => BonusToken
  mapping(address => uint8) public allowBonusTokens;
  mapping(address => mapping(address => Miner)) public miners;

  modifier onlyGovernance() {

    require(msg.sender == governance, "Blacksmith: caller not governance");
    _;
  }

  constructor (address _coverAddress, address _governance, address _treasury) {
    cover = ICOVER(_coverAddress);
    governance = _governance;
    treasury = _treasury;
  }

  function getPoolList() external view override returns (address[] memory) {

    return poolList;
  }

  function viewMined(address _lpToken, address _miner)
   external view override returns (uint256 _minedCOVER, uint256 _minedBonus)
  {

    Pool memory pool = pools[_lpToken];
    Miner memory miner = miners[_lpToken][_miner];
    uint256 lpTotal = IERC20(_lpToken).balanceOf(address(this));
    if (miner.amount > 0 && lpTotal > 0) {
      uint256 coverRewards = _calculateCoverRewardsForPeriod(pool);
      uint256 accRewardsPerToken = pool.accRewardsPerToken.add(coverRewards.div(lpTotal));
      _minedCOVER = miner.amount.mul(accRewardsPerToken).div(CAL_MULTIPLIER).sub(miner.rewardWriteoff);

      BonusToken memory bonusToken = bonusTokens[_lpToken];
      if (bonusToken.startTime < block.timestamp && bonusToken.totalBonus > 0) {
        uint256 bonus = _calculateBonusForPeriod(bonusToken);
        uint256 accBonusPerToken = bonusToken.accBonusPerToken.add(bonus.div(lpTotal));
        _minedBonus = miner.amount.mul(accBonusPerToken).div(CAL_MULTIPLIER).sub(miner.bonusWriteoff);
      }
    }
    return (_minedCOVER, _minedBonus);
  }

  function updatePool(address _lpToken) public override {

    Pool storage pool = pools[_lpToken];
    if (block.timestamp <= pool.lastUpdatedAt) return;
    uint256 lpTotal = IERC20(_lpToken).balanceOf(address(this));
    if (lpTotal == 0) {
      pool.lastUpdatedAt = block.timestamp;
      return;
    }
    uint256 coverRewards = _calculateCoverRewardsForPeriod(pool);
    pool.accRewardsPerToken = pool.accRewardsPerToken.add(coverRewards.div(lpTotal));
    pool.lastUpdatedAt = block.timestamp;
    BonusToken storage bonusToken = bonusTokens[_lpToken];
    if (bonusToken.lastUpdatedAt < bonusToken.endTime && bonusToken.startTime < block.timestamp) {
      uint256 bonus = _calculateBonusForPeriod(bonusToken);
      bonusToken.accBonusPerToken = bonusToken.accBonusPerToken.add(bonus.div(lpTotal));
      bonusToken.lastUpdatedAt = block.timestamp <= bonusToken.endTime ? block.timestamp : bonusToken.endTime;
    }
  }

  function claimRewards(address _lpToken) public override {

    updatePool(_lpToken);

    Pool memory pool = pools[_lpToken];
    Miner storage miner = miners[_lpToken][msg.sender];
    BonusToken memory bonusToken = bonusTokens[_lpToken];

    _claimCoverRewards(pool, miner);
    _claimBonus(bonusToken, miner);
    miner.rewardWriteoff = miner.amount.mul(pool.accRewardsPerToken).div(CAL_MULTIPLIER);
    miner.bonusWriteoff = miner.amount.mul(bonusToken.accBonusPerToken).div(CAL_MULTIPLIER);
  }

  function claimRewardsForPools(address[] calldata _lpTokens) external override {

    for (uint256 i = 0; i < _lpTokens.length; i++) {
      claimRewards(_lpTokens[i]);
    }
  }

  function deposit(address _lpToken, uint256 _amount) external override {

    require(block.timestamp >= START_TIME , "Blacksmith: not started");
    require(_amount > 0, "Blacksmith: amount is 0");
    Pool memory pool = pools[_lpToken];
    require(pool.lastUpdatedAt > 0, "Blacksmith: pool does not exists");
    require(IERC20(_lpToken).balanceOf(msg.sender) >= _amount, "Blacksmith: insufficient balance");
    updatePool(_lpToken);

    Miner storage miner = miners[_lpToken][msg.sender];
    BonusToken memory bonusToken = bonusTokens[_lpToken];
    _claimCoverRewards(pool, miner);
    _claimBonus(bonusToken, miner);

    miner.amount = miner.amount.add(_amount);
    miner.rewardWriteoff = miner.amount.mul(pool.accRewardsPerToken).div(CAL_MULTIPLIER);
    miner.bonusWriteoff = miner.amount.mul(bonusToken.accBonusPerToken).div(CAL_MULTIPLIER);

    IERC20(_lpToken).safeTransferFrom(msg.sender, address(this), _amount);
    emit Deposit(msg.sender, _lpToken, _amount);
  }

  function withdraw(address _lpToken, uint256 _amount) external override {

    require(_amount > 0, "Blacksmith: amount is 0");
    Miner storage miner = miners[_lpToken][msg.sender];
    require(miner.amount >= _amount, "Blacksmith: insufficient balance");
    updatePool(_lpToken);

    Pool memory pool = pools[_lpToken];
    BonusToken memory bonusToken = bonusTokens[_lpToken];
    _claimCoverRewards(pool, miner);
    _claimBonus(bonusToken, miner);

    miner.amount = miner.amount.sub(_amount);
    miner.rewardWriteoff = miner.amount.mul(pool.accRewardsPerToken).div(CAL_MULTIPLIER);
    miner.bonusWriteoff = miner.amount.mul(bonusToken.accBonusPerToken).div(CAL_MULTIPLIER);

    _safeTransfer(_lpToken, _amount);
    emit Withdraw(msg.sender, _lpToken, _amount);
  }

  function emergencyWithdraw(address _lpToken) external override {

    Miner storage miner = miners[_lpToken][msg.sender];
    uint256 amount = miner.amount;
    require(miner.amount > 0, "Blacksmith: insufficient balance");
    miner.amount = 0;
    miner.rewardWriteoff = 0;
    _safeTransfer(_lpToken, amount);
    emit Withdraw(msg.sender, _lpToken, amount);
  }

  function updatePoolWeights(address[] calldata _lpTokens, uint256[] calldata _weights) public override onlyGovernance {

    for (uint256 i = 0; i < _lpTokens.length; i++) {
      Pool storage pool = pools[_lpTokens[i]];
      if (pool.lastUpdatedAt > 0) {
        totalWeight = totalWeight.add(_weights[i]).sub(pool.weight);
        pool.weight = _weights[i];
      }
    }
  }

  function addPool(address _lpToken, uint256 _weight) public override onlyOwner {

    Pool memory pool = pools[_lpToken];
    require(pool.lastUpdatedAt == 0, "Blacksmith: pool exists");
    pools[_lpToken] = Pool({
      weight: _weight,
      accRewardsPerToken: 0,
      lastUpdatedAt: block.timestamp
    });
    totalWeight = totalWeight.add(_weight);
    poolList.push(_lpToken);
  }

  function addPools(address[] calldata _lpTokens, uint256[] calldata _weights) external override onlyOwner {

    require(_lpTokens.length == _weights.length, "Blacksmith: size don't match");
    for (uint256 i = 0; i < _lpTokens.length; i++) {
     addPool(_lpTokens[i], _weights[i]);
    }
  }

  function updateBonusTokenStatus(address _bonusToken, uint8 _status) external override onlyOwner {

    require(_status != 0, "Blacksmith: status cannot be 0");
    require(pools[_bonusToken].lastUpdatedAt == 0, "Blacksmith: lpToken is not allowed");
    allowBonusTokens[_bonusToken] = _status;
  }

  function addBonusToken(
    address _lpToken,
    address _bonusToken,
    uint256 _startTime,
    uint256 _endTime,
    uint256 _totalBonus
  ) external override {

    IERC20 bonusToken = IERC20(_bonusToken);
    require(pools[_lpToken].lastUpdatedAt != 0, "Blacksmith: pool does NOT exist");
    require(allowBonusTokens[_bonusToken] == 1, "Blacksmith: bonusToken not allowed");

    BonusToken memory currentBonusToken = bonusTokens[_lpToken];
    if (currentBonusToken.totalBonus != 0) {
      require(currentBonusToken.endTime.add(WEEK) < block.timestamp, "Blacksmith: last bonus period hasn't ended");
      require(IERC20(currentBonusToken.addr).balanceOf(address(this)) == 0, "Blacksmith: last bonus not all claimed");
    }

    require(_startTime >= block.timestamp && _endTime > _startTime, "Blacksmith: messed up timeline");
    require(_totalBonus > 0 && bonusToken.balanceOf(msg.sender) >= _totalBonus, "Blacksmith: incorrect total rewards");

    uint256 balanceBefore = bonusToken.balanceOf(address(this));
    bonusToken.safeTransferFrom(msg.sender, address(this), _totalBonus);
    uint256 balanceAfter = bonusToken.balanceOf(address(this));
    require(balanceAfter > balanceBefore, "Blacksmith: incorrect total rewards");

    bonusTokens[_lpToken] = BonusToken({
      addr: _bonusToken,
      startTime: _startTime,
      endTime: _endTime,
      totalBonus: balanceAfter.sub(balanceBefore),
      accBonusPerToken: 0,
      lastUpdatedAt: _startTime
    });
  }

  function collectDust(address _token) external override {

    Pool memory pool = pools[_token];
    require(pool.lastUpdatedAt == 0, "Blacksmith: lpToken, not allowed");
    require(allowBonusTokens[_token] == 0, "Blacksmith: bonusToken, not allowed");

    IERC20 token = IERC20(_token);
    uint256 amount = token.balanceOf(address(this));
    require(amount > 0, "Blacksmith: 0 to collect");

    if (_token == address(0)) { // token address(0) == ETH
      payable(treasury).transfer(amount);
    } else {
      token.safeTransfer(treasury, amount);
    }
  }

  function collectBonusDust(address _lpToken) external override {

    BonusToken memory bonusToken = bonusTokens[_lpToken];
    require(bonusToken.endTime.add(WEEK) < block.timestamp, "Blacksmith: bonusToken, not ready");

    IERC20 token = IERC20(bonusToken.addr);
    uint256 amount = token.balanceOf(address(this));
    require(amount > 0, "Blacksmith: 0 to collect");
    token.safeTransfer(treasury, amount);
  }

  function updateWeeklyTotal(uint256 _weeklyTotal) external override onlyGovernance {

    weeklyTotal = _weeklyTotal;
  }

  function updatePools(uint256 _start, uint256 _end) external override {

    address[] memory poolListCopy = poolList;
    for (uint256 i = _start; i < _end; i++) {
      updatePool(poolListCopy[i]);
    }
  }

  function transferMintingRights(address _newAddress) external override onlyGovernance {

    cover.setBlacksmith(_newAddress);
  }

  function _calculateCoverRewardsForPeriod(Pool memory _pool) internal view returns (uint256) {

    uint256 timePassed = block.timestamp.sub(_pool.lastUpdatedAt);
    return weeklyTotal.mul(CAL_MULTIPLIER).mul(timePassed).mul(_pool.weight).div(totalWeight).div(WEEK);
  }

  function _calculateBonusForPeriod(BonusToken memory _bonusToken) internal view returns (uint256) {

    if (_bonusToken.endTime == _bonusToken.lastUpdatedAt) return 0;

    uint256 calTime = block.timestamp > _bonusToken.endTime ? _bonusToken.endTime : block.timestamp;
    uint256 timePassed = calTime.sub(_bonusToken.lastUpdatedAt);
    uint256 totalDuration = _bonusToken.endTime.sub(_bonusToken.startTime);
    return _bonusToken.totalBonus.mul(CAL_MULTIPLIER).mul(timePassed).div(totalDuration);
  }

  function _safeTransfer(address _token, uint256 _amount) private nonReentrant {

    IERC20 token = IERC20(_token);
    uint256 balance = token.balanceOf(address(this));
    if (balance > _amount) {
      token.safeTransfer(msg.sender, _amount);
    } else if (balance > 0) {
      token.safeTransfer(msg.sender, balance);
    }
  }

  function _claimCoverRewards(Pool memory pool, Miner memory miner) private nonReentrant {

    if (miner.amount > 0) {
      uint256 minedSinceLastUpdate = miner.amount.mul(pool.accRewardsPerToken).div(CAL_MULTIPLIER).sub(miner.rewardWriteoff);
      if (minedSinceLastUpdate > 0) {
        cover.mint(msg.sender, minedSinceLastUpdate); // mint COVER tokens to miner
      }
    }
  }

  function _claimBonus(BonusToken memory bonusToken, Miner memory miner) private {

    if (bonusToken.totalBonus > 0 && miner.amount > 0 && bonusToken.startTime < block.timestamp) {
      uint256 bonusSinceLastUpdate = miner.amount.mul(bonusToken.accBonusPerToken).div(CAL_MULTIPLIER).sub(miner.bonusWriteoff);
      if (bonusSinceLastUpdate > 0) {
        _safeTransfer(bonusToken.addr, bonusSinceLastUpdate); // transfer bonus tokens to miner
      }
    }
  }
}// MIT

pragma solidity ^0.7.4;

library MerkleProof {

    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {

        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash <= proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }

        return computedHash == root;
    }
}// None

pragma solidity ^0.7.4;

interface IMigrator {

  function isSafeClaimed(uint256 _index) external view returns (bool);

  function migrateSafe2() external;

  function claim(uint256 _index, uint256 _amount, bytes32[] calldata _merkleProof) external;


  function transferMintingRights(address _newAddress) external;

}// None

pragma solidity ^0.7.4;


contract Migrator is Ownable, IMigrator {

  using SafeERC20 for IERC20;
  using SafeMath for uint256;

  IERC20 public safe2;
  ICOVER public cover;
  address public governance;
  bytes32 public immutable merkleRoot;
  uint256 public safe2Migrated; // total: 52,689.18
  uint256 public safeClaimed; // total: 2160.76
  uint256 public constant migrationCap = 54850e18;
  uint256 public constant START_TIME = 1605830400; // 11/20/2020 12am UTC
  mapping(uint256 => uint256) private claimedBitMap;

  constructor (address _governance, address _coverAddress, address _safe2, bytes32 _merkleRoot) {
    governance = _governance;
    cover = ICOVER(_coverAddress);

    require(_safe2 == 0x250a3500f48666561386832f1F1f1019b89a2699, "Migrator: safe2 address not match");
    safe2 = IERC20(_safe2);

    merkleRoot = _merkleRoot;
  }

  function isSafeClaimed(uint256 _index) public view override returns (bool) {

    uint256 claimedWordIndex = _index / 256;	
    uint256 claimedBitIndex = _index % 256;	
    uint256 claimedWord = claimedBitMap[claimedWordIndex];	
    uint256 mask = (1 << claimedBitIndex);	
    return claimedWord & mask == mask;
  }

  function migrateSafe2() external override {

    require(block.timestamp >= START_TIME, "Migrator: not started");
    uint256 safe2Balance = safe2.balanceOf(msg.sender);

    require(safe2Balance > 0, "Migrator: no safe2 balance");
    safe2.transferFrom(msg.sender, 0x000000000000000000000000000000000000dEaD, safe2Balance);
    cover.mint(msg.sender, safe2Balance);
    safe2Migrated = safe2Migrated.add(safe2Balance);
  }

  function claim(uint256 _index, uint256 _amount, bytes32[] calldata _merkleProof) external override {

    require(block.timestamp >= START_TIME, "Migrator: not started");
    require(_amount > 0, "Migrator: amount is 0");
    require(!isSafeClaimed(_index), 'Migrator: already claimed');
    require(safe2Migrated.add(safeClaimed).add(_amount) <= migrationCap, "Migrator: cap exceeded"); // SAFE2 take priority first

    bytes32 node = keccak256(abi.encodePacked(_index, msg.sender, _amount));
    require(MerkleProof.verify(_merkleProof, merkleRoot, node), 'Migrator: invalid proof');

    _setClaimed(_index);
    safeClaimed = safeClaimed.add(_amount);
    cover.mint(msg.sender, _amount);
  }

  function transferMintingRights(address _newAddress) external override {

    require(msg.sender == governance, "Migrator: caller not governance");
    cover.setMigrator(_newAddress);
  }

  function _setClaimed(uint256 _index) private {	

    uint256 claimedWordIndex = _index / 256;	
    uint256 claimedBitIndex = _index % 256;	
    claimedBitMap[claimedWordIndex] = claimedBitMap[claimedWordIndex] | (1 << claimedBitIndex);	
  }
}// MIT
pragma solidity ^0.7.4;


contract Vesting {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 public constant START_TIME = 1605830400; // 11/20/2020 12 AM UTC
    uint256 public constant MIDDLE_TIME = 1621468800; // 5/20/2021 12 AM UTC
    uint256 public constant END_TIME = 1637366400; // 11/20/2021 12 AM UTC

    mapping (address => uint256) private _vested;
    mapping (address => uint256) private _total;

    constructor() {
        _total[address(0x406a0c87A6bb25748252cb112a7a837e21aAcD98)] = 2700 ether;
        _total[address(0x3e677718f8665A40AC0AB044D8c008b55f277c98)] = 2700 ether;
        _total[address(0x094AD38fB69f27F6Eb0c515ad4a5BD4b9F9B2996)] = 2700 ether;
        _total[address(0xD4C8127AF1dE3Ebf8AB7449aac0fd892b70f3b45)] = 1620 ether;
        _total[address(0x82BBd2F08a59f5be1B4e719ff701e4D234c4F8db)] = 720 ether;
        _total[address(0xF00Bf178E3372C4eF6E15A1676fd770DAD2aDdfB)] = 360 ether;
    }

    function vest(IERC20 token) external {

        require(block.timestamp >= START_TIME, "Vesting: !started");
        require(_total[msg.sender] > 0, "Vesting: not team");

        uint256 toBeReleased = releasableAmount(msg.sender);
        require(toBeReleased > 0, "Vesting: all vested");

        _vested[msg.sender] = _vested[msg.sender].add(toBeReleased);
        token.safeTransfer(msg.sender, toBeReleased);
    }

    function releasableAmount(address _addr) public view returns (uint256) {

        return unlockedAmount(_addr).sub(_vested[_addr]);
    }

    function unlockedAmount(address _addr) public view returns (uint256) {

        if (block.timestamp <= MIDDLE_TIME) {
            uint256 duration = MIDDLE_TIME.sub(START_TIME);
            uint256 firstHalf = _total[_addr].mul(2).div(3);
            uint256 timePassed = block.timestamp.sub(START_TIME);
            return firstHalf.mul(timePassed).div(duration);
        } else if (block.timestamp > MIDDLE_TIME && block.timestamp <= END_TIME) {
            uint256 duration = END_TIME.sub(MIDDLE_TIME);
            uint256 firstHalf = _total[_addr].mul(2).div(3);
            uint256 secondHalf = _total[_addr].div(3);
            uint256 timePassed = block.timestamp.sub(MIDDLE_TIME);
            return firstHalf.add(secondHalf.mul(timePassed).div(duration));
        } else {
            return _total[_addr];
        }
    }

}// None

pragma solidity ^0.7.4;


contract ERC20 is IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

  constructor (string memory name_, string memory symbol_) {
    _name = name_;
    _symbol = symbol_;
    _decimals = 18;
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

  function totalSupply() public view override returns (uint256) {

    return _totalSupply;
  }

  function balanceOf(address account) public view override returns (uint256) {

    return _balances[account];
  }

  function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

    _transfer(msg.sender, recipient, amount);
    return true;
  }

  function allowance(address owner, address spender) public view virtual override returns (uint256) {

    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) public virtual override returns (bool) {

    _approve(msg.sender, spender, amount);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

    _transfer(sender, recipient, amount);
    _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

    _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

    _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
    return true;
  }

  function _transfer(address sender, address recipient, uint256 amount) internal virtual {

    require(sender != address(0), "ERC20: transfer from the zero address");
    require(recipient != address(0), "ERC20: transfer to the zero address");


    _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }

  function _mint(address account, uint256 amount) internal virtual {

    require(account != address(0), "ERC20: mint to the zero address");

    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }

  function _approve(address owner, address spender, uint256 amount) internal virtual {

    require(owner != address(0), "ERC20: approve from the zero address");
    require(spender != address(0), "ERC20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }
}// None

pragma solidity ^0.7.4;


contract COVER is Ownable, ERC20 {

  using SafeMath for uint256;

  bool private isReleased;
  address public blacksmith; // mining contract
  address public migrator; // migration contract
  uint256 public constant START_TIME = 1605830400; // 11/20/2020 12am UTC

  constructor () ERC20("Cover Protocol", "COVER") {
    _mint(0x2f80E5163A7A774038753593010173322eA6f9fe, 1e18);
  }

  function mint(address _account, uint256 _amount) public {

    require(isReleased, "$COVER: not released");
    require(msg.sender == migrator || msg.sender == blacksmith, "$COVER: caller not migrator or Blacksmith");

    _mint(_account, _amount);
  }

  function setBlacksmith(address _newBlacksmith) external returns (bool) {

    require(msg.sender == blacksmith, "$COVER: caller not blacksmith");

    blacksmith = _newBlacksmith;
    return true;
  }

  function setMigrator(address _newMigrator) external returns (bool) {

    require(msg.sender == migrator, "$COVER: caller not migrator");

    migrator = _newMigrator;
    return true;
  }

  function release(address _treasury, address _vestor, address _blacksmith, address _migrator) external onlyOwner {

    require(block.timestamp >= START_TIME, "$COVER: not started");
    require(isReleased == false, "$COVER: already released");

    isReleased = true;

    blacksmith = _blacksmith;
    migrator = _migrator;
    _mint(_treasury, 950e18);
    _mint(_vestor, 10800e18);
  }
}