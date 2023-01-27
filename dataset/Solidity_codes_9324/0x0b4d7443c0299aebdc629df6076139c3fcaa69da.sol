



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


pragma solidity ^0.6.0;

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


pragma solidity ^0.6.0;

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


pragma solidity ^0.6.2;

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
}


pragma solidity ^0.6.0;




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


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


pragma solidity ^0.6.0;


contract ReentrancyGuardUpgradeSafe is Initializable {

    bool private _notEntered;


    function __ReentrancyGuard_init() internal initializer {

        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {



        _notEntered = true;

    }


    modifier nonReentrant() {

        require(_notEntered, "ReentrancyGuard: reentrant call");

        _notEntered = false;

        _;

        _notEntered = true;
    }

    uint256[49] private __gap;
}


pragma solidity 0.6.12;



interface ILpTokenMigrator {

  function migrate(IERC20 token, uint8 poolType) external returns (IERC20);

}


pragma solidity 0.6.12;

interface IVestedLPMining {

  function initialize(
    IERC20 _cvp,
    address _reservoir,
    uint256 _cvpPerBlock,
    uint256 _startBlock,
    uint256 _cvpVestingPeriodInBlocks
  ) external;


  function poolLength() external view returns (uint256);


  function add(
    uint256 _allocPoint,
    IERC20 _lpToken,
    uint8 _poolType,
    bool _votesEnabled,
    uint256 _lpBoostRate,
    uint256 _cvpBoostRate,
    uint256 _lpBoostMinRatio,
    uint256 _lpBoostMaxRatio
  ) external;


  function set(
    uint256 _pid,
    uint256 _allocPoint,
    uint8 _poolType,
    bool _votesEnabled,
    uint256 _lpBoostRate,
    uint256 _cvpBoostRate,
    uint256 _lpBoostMinRatio,
    uint256 _lpBoostMaxRatio
  ) external;


  function setMigrator(ILpTokenMigrator _migrator) external;


  function setCvpPerBlock(uint256 _cvpPerBlock) external;


  function setCvpVestingPeriodInBlocks(uint256 _cvpVestingPeriodInBlocks) external;


  function setCvpPoolByMetaPool(address _metaPool, address _cvpPool) external;


  function migrate(uint256 _pid) external;


  function pendingCvp(uint256 _pid, address _user) external view returns (uint256);


  function vestableCvp(uint256 _pid, address user) external view returns (uint256);


  function isLpTokenAdded(IERC20 _lpToken) external view returns (bool);


  function massUpdatePools() external;


  function updatePool(uint256 _pid) external;


  function deposit(
    uint256 _pid,
    uint256 _amount,
    uint256 _boostAmount
  ) external;


  function withdraw(
    uint256 _pid,
    uint256 _amount,
    uint256 _boostAmount
  ) external;


  function emergencyWithdraw(uint256 _pid) external;


  function checkpointVotes(address _user) external;


  function getCheckpoint(address account, uint32 checkpointId)
    external
    view
    returns (
      uint32 fromBlock,
      uint96 cvpAmount,
      uint96 pooledCvpShare
    );


  event AddLpToken(address indexed lpToken, uint256 indexed pid, uint256 allocPoint);
  event SetLpToken(address indexed lpToken, uint256 indexed pid, uint256 allocPoint);
  event SetMigrator(address indexed migrator);
  event SetCvpPerBlock(uint256 cvpPerBlock);
  event SetCvpVestingPeriodInBlocks(uint256 cvpVestingPeriodInBlocks);
  event SetCvpPoolByMetaPool(address indexed metaPool, address indexed cvpPool);
  event MigrateLpToken(address indexed oldLpToken, address indexed newLpToken, uint256 indexed pid);

  event Deposit(address indexed user, uint256 indexed pid, uint256 amount, uint256 boostAmount);
  event Withdraw(address indexed user, uint256 indexed pid, uint256 amount, uint256 boostAmount);
  event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount, uint256 boostAmount);

  event CheckpointTotalLpVotes(uint256 lpVotes);
  event CheckpointUserLpVotes(address indexed user, uint256 indexed pid, uint256 lpVotes);
  event CheckpointUserVotes(address indexed user, uint256 pendedVotes, uint256 lpVotesShare);
}


pragma solidity 0.6.12;

contract ReservedSlots {

    uint256[100] private __gap;
}


pragma solidity 0.6.12;

library SafeMath96 {


    function add(uint96 a, uint96 b, string memory errorMessage) internal pure returns (uint96) {

        uint96 c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function add(uint96 a, uint96 b) internal pure returns (uint96) {

        return add(a, b, "SafeMath96: addition overflow");
    }

    function sub(uint96 a, uint96 b, string memory errorMessage) internal pure returns (uint96) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function sub(uint96 a, uint96 b) internal pure returns (uint96) {

        return sub(a, b, "SafeMath96: subtraction overflow");
    }

    function average(uint96 a, uint96 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }

    function fromUint(uint n, string memory errorMessage) internal pure returns (uint96) {

        require(n < 2**96, errorMessage);
        return uint96(n);
    }

    function fromUint(uint n) internal pure returns (uint96) {

        return fromUint(n, "SafeMath96: exceeds 96 bits");
    }
}


pragma solidity 0.6.12;

library SafeMath32 {


    function add(uint32 a, uint32 b, string memory errorMessage) internal pure returns (uint32) {

        uint32 c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function add(uint32 a, uint32 b) internal pure returns (uint32) {

        return add(a, b, "SafeMath32: addition overflow");
    }

    function sub(uint32 a, uint32 b, string memory errorMessage) internal pure returns (uint32) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function sub(uint32 a, uint32 b) internal pure returns (uint32) {

        return sub(a, b, "SafeMath32: subtraction overflow");
    }

    function fromUint(uint n, string memory errorMessage) internal pure returns (uint32) {

        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function fromUint(uint n) internal pure returns (uint32) {

        return fromUint(n, "SafeMath32: exceeds 32 bits");
    }
}


pragma solidity 0.6.12;


library DelegatableCheckpoints {


    struct Checkpoint {
        uint32 fromBlock;
        uint192 data;
    }

    struct Record {
        uint32 numCheckpoints;
        uint32 lastCheckpointBlock;
        address delegatee;

        mapping (uint32 => Checkpoint) checkpoints;
    }

    function getCheckpoint(Record storage record, uint checkpointId)
    internal view returns (uint32 fromBlock, uint192 data)
    {

        return checkpointId == 0 || checkpointId > record.numCheckpoints
            ? (0, 0)
            : _getCheckpoint(record, uint32(checkpointId));
    }

    function _getCheckpoint(Record storage record, uint32 checkpointId)
    internal view returns (uint32 fromBlock, uint192 data)
    {

        return (record.checkpoints[checkpointId].fromBlock, record.checkpoints[checkpointId].data);
    }

    function getLatestData(Record storage record)
    internal view returns (uint192, uint32)
    {

        Record memory _record = record;
        return _record.numCheckpoints == 0
        ? (0, 0)
        : (record.checkpoints[_record.numCheckpoints].data, record.checkpoints[_record.numCheckpoints].fromBlock);
    }

    function getPriorData(Record storage record, uint blockNumber, uint checkpointId)
    internal view returns (uint192, uint32)
    {

        uint32 blockNum = _safeMinedBlockNum(blockNumber);
        Record memory _record = record;
        Checkpoint memory cp;

        if (checkpointId != 0) {
            require(checkpointId <= _record.numCheckpoints, "ChPoints: invalid checkpoint id");
            uint32 cpId = uint32(checkpointId);

            cp = record.checkpoints[cpId];
            if (cp.fromBlock == blockNum) {
                return (cp.data, cp.fromBlock);
            } else if (cp.fromBlock < cp.fromBlock) {
                if (cpId == _record.numCheckpoints) {
                    return (cp.data, cp.fromBlock);
                }
                uint32 nextFromBlock = record.checkpoints[cpId + 1].fromBlock;
                if (nextFromBlock > blockNum) {
                    return (cp.data, cp.fromBlock);
                }
            }
        }

        (uint32 checkpointId, uint192 data) = _findCheckpoint(record, _record.numCheckpoints, blockNum);
        return (data, record.checkpoints[checkpointId].fromBlock);
    }

    function findCheckpoint(Record storage record, uint blockNumber)
    internal view returns (uint32 id, uint192 data)
    {

        uint32 blockNum = _safeMinedBlockNum(blockNumber);
        uint32 numCheckpoints = record.numCheckpoints;

        (id, data) = _findCheckpoint(record, numCheckpoints, blockNum);
    }

    function writeCheckpoint(Record storage record, uint192 data)
    internal returns (uint32 id)
    {

        uint32 blockNum = _safeBlockNum(block.number);
        Record memory _record = record;

        uint192 oldData = _record.numCheckpoints > 0 ? record.checkpoints[_record.numCheckpoints].data : 0;
        bool isChanged = data != oldData;

        if (_record.lastCheckpointBlock != blockNum) {
            _record.numCheckpoints = _record.numCheckpoints + 1; // overflow chance ignored
            record.numCheckpoints = _record.numCheckpoints;
            record.lastCheckpointBlock = blockNum;
            isChanged = true;
        }
        if (isChanged) {
            record.checkpoints[_record.numCheckpoints] = Checkpoint(blockNum, data);
        }
        id = _record.numCheckpoints;
    }

    function getProperties(Record storage record) internal view returns (uint32, uint32, address) {

        return (record.numCheckpoints, record.lastCheckpointBlock, record.delegatee);
    }

    function writeDelegatee(Record storage record, address delegatee) internal {

        record.delegatee = delegatee;
    }

    function _safeBlockNum(uint256 blockNumber) private pure returns (uint32) {

        require(blockNumber < 2**32, "ChPoints: blockNum >= 2**32");
        return uint32(blockNumber);
    }

    function _safeMinedBlockNum(uint256 blockNumber) private view returns (uint32) {

        require(blockNumber < block.number, "ChPoints: block not yet mined");
        return _safeBlockNum(blockNumber);
    }

    function _findCheckpoint(Record storage record, uint32 numCheckpoints, uint32 blockNum)
    private view returns (uint32, uint192)
    {

        Checkpoint memory cp;

        if (numCheckpoints == 0) {
            return (0, 0);
        }
        cp = record.checkpoints[numCheckpoints];
        if (cp.fromBlock <= blockNum) {
            return (numCheckpoints, cp.data);
        }
        if (record.checkpoints[1].fromBlock > blockNum) {
            return (0, 0);
        }

        uint32 lower = 1;
        uint32 upper = numCheckpoints;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            cp = record.checkpoints[center];
            if (cp.fromBlock == blockNum) {
                return (center, cp.data);
            } else if (cp.fromBlock < blockNum) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return (lower, record.checkpoints[lower].data);
    }
}


pragma solidity 0.6.12;

abstract contract DelegatableVotes {
  using SafeMath96 for uint96;
  using DelegatableCheckpoints for DelegatableCheckpoints.Record;

  mapping(address => DelegatableCheckpoints.Record) public book;

  mapping(address => uint192) internal delegatables;

  event CheckpointBalanceChanged(address indexed delegate, uint256 previousBalance, uint256 newBalance);

  event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

  function delegatee() public view returns (address) {
    return book[msg.sender].delegatee;
  }

  function delegate(address delegatee_) public {
    require(delegatee_ != address(this), "delegate: can't delegate to the contract address");
    return _delegate(msg.sender, delegatee_);
  }

  function _getCurrentVotes(address account) internal view returns (uint96) {
    (uint192 userData, uint32 userDataBlockNumber) = book[account].getLatestData();
    if (userData == 0) return 0;

    (uint192 sharedData, ) = book[address(this)].getLatestData();
    (uint192 sharedDataAtUserSave, ) = book[address(this)].getPriorData(userDataBlockNumber, 0);
    return _computeUserVotes(userData, sharedData, sharedDataAtUserSave);
  }

  function _getPriorVotes(address account, uint256 blockNumber) internal view returns (uint96) {
    return _getPriorVotes(account, blockNumber, 0, 0);
  }

  function _getPriorVotes(
    address account,
    uint256 blockNumber,
    uint32 userCheckpointId,
    uint32 sharedCheckpointId
  ) internal view returns (uint96) {
    (uint192 userData, uint32 userDataBlockNumber) = book[account].getPriorData(blockNumber, userCheckpointId);
    if (userData == 0) return 0;

    (uint192 sharedData, ) = book[address(this)].getPriorData(blockNumber, sharedCheckpointId);
    (uint192 sharedDataAtUserSave, ) = book[address(this)].getPriorData(userDataBlockNumber, 0);
    return _computeUserVotes(userData, sharedData, sharedDataAtUserSave);
  }

  function findCheckpoints(address account, uint256 blockNumber)
    external
    view
    returns (uint32 userCheckpointId, uint32 sharedCheckpointId)
  {
    require(account != address(0), "findCheckpoints: zero account");
    (userCheckpointId, ) = book[account].findCheckpoint(blockNumber);
    (sharedCheckpointId, ) = book[address(this)].findCheckpoint(blockNumber);
  }

  function _getCheckpoint(address account, uint32 checkpointId) internal view returns (uint32 fromBlock, uint192 data) {
    (fromBlock, data) = book[account].getCheckpoint(checkpointId);
  }

  function _writeSharedData(uint192 data) internal {
    book[address(this)].writeCheckpoint(data);
  }

  function _writeUserData(address account, uint192 data) internal {
    DelegatableCheckpoints.Record storage src = book[account];
    address _delegatee = src.delegatee;
    DelegatableCheckpoints.Record storage dst = _delegatee == address(0) ? src : book[_delegatee];

    (uint192 latestData, ) = dst.getLatestData();
    dst.writeCheckpoint(
      _computeUserData(latestData, data, delegatables[account])
    );
    delegatables[account] = data;
  }

  function _moveUserData(
    address account,
    address from,
    address to
  ) internal {
    DelegatableCheckpoints.Record storage src;
    DelegatableCheckpoints.Record storage dst;

    if (from == address(0)) {
      src = book[account];
      dst = book[to];
    } else if (to == address(0)) {
      src = book[from];
      dst = book[account];
    } else {
      src = book[from];
      dst = book[to];
    }
    uint192 delegatable = delegatables[account];

    (uint192 srcPrevData, ) = src.getLatestData();
    uint192 srcData = _computeUserData(srcPrevData, 0, delegatable);
    if (srcPrevData != srcData) src.writeCheckpoint(srcData);

    (uint192 dstPrevData, ) = dst.getLatestData();
    uint192 dstData = _computeUserData(dstPrevData, delegatable, 0);
    if (dstPrevData != dstData) dst.writeCheckpoint(dstData);
  }

  function _delegate(address delegator, address delegatee_) internal {
    address currentDelegate = book[delegator].delegatee;
    book[delegator].delegatee = delegatee_;

    emit DelegateChanged(delegator, currentDelegate, delegatee_);

    _moveUserData(delegator, currentDelegate, delegatee_);
  }

  function _computeUserVotes(
    uint192 userData,
    uint192 sharedData,
    uint192 sharedDataAtUserSave
  ) internal pure virtual returns (uint96 votes);

  function _computeUserData(
    uint192 prevData,
    uint192 newDelegated,
    uint192 prevDelegated
  ) internal pure virtual returns (uint192 userData) {
    (uint96 prevA, uint96 prevB) = _unpackData(prevData);
    (uint96 newDelegatedA, uint96 newDelegatedB) = _unpackData(newDelegated);
    (uint96 prevDelegatedA, uint96 prevDelegatedB) = _unpackData(prevDelegated);
    userData = _packData(
      _getNewValue(prevA, newDelegatedA, prevDelegatedA),
      _getNewValue(prevB, newDelegatedB, prevDelegatedB)
    );
  }

  function _unpackData(uint192 data) internal pure virtual returns (uint96 valA, uint96 valB) {
    return (uint96(data >> 96), uint96((data << 96) >> 96));
  }

  function _packData(uint96 valA, uint96 valB) internal pure virtual returns (uint192 data) {
    return ((uint192(valA) << 96) | uint192(valB));
  }

  function _getNewValue(
    uint96 val,
    uint96 more,
    uint96 less
  ) internal pure virtual returns (uint96 newVal) {
    if (more == less) {
      newVal = val;
    } else if (more > less) {
      newVal = val.add(more.sub(less));
    } else {
      uint96 decrease = less.sub(more);
      newVal = val > decrease ? val.sub(decrease) : 0;
    }
  }

  uint256[50] private _gap; // reserved
}


pragma solidity 0.6.12;

contract VestedLPMining is
  OwnableUpgradeSafe,
  ReentrancyGuardUpgradeSafe,
  ReservedSlots,
  DelegatableVotes,
  IVestedLPMining
{

  using SafeMath for uint256;
  using SafeMath96 for uint96;
  using SafeMath32 for uint32;

  using SafeERC20 for IERC20;


  struct User {
    uint32 lastUpdateBlock; // block when the params (below) were updated
    uint32 vestingBlock; // block by when all entitled CVP tokens to be vested
    uint96 pendedCvp; // amount of CVPs tokens entitled but not yet vested to the user
    uint96 cvpAdjust; // adjustments for pended CVP tokens amount computation
    uint256 lptAmount; // amount of LP tokens the user has provided to a pool
  }

  struct Pool {
    IERC20 lpToken; // address of the LP token contract
    bool votesEnabled; // if the pool is enabled to write votes
    uint8 poolType; // pool type (1 - Uniswap, 2 - Balancer)
    uint32 allocPoint; // points assigned to the pool, which affect CVPs distribution between pools
    uint32 lastUpdateBlock; // latest block when the pool params which follow was updated
    uint256 accCvpPerLpt; // accumulated distributed CVPs per one deposited LP token, times 1e12
  }

  uint256 internal constant SCALE = 1e12;

  IERC20 public cvp;
  uint96 public cvpVestingPool;

  address public reservoir;
  uint32 public cvpVestingPeriodInBlocks;
  uint32 public startBlock;
  uint96 public cvpPerBlock;

  ILpTokenMigrator public migrator;

  Pool[] public pools;
  mapping(address => uint256) public poolPidByAddress;
  mapping(uint256 => mapping(address => User)) public users;
  uint256 public totalAllocPoint = 0;

  mapping(address => address) public cvpPoolByMetaPool;

  mapping(address => uint256) public lastSwapBlock;

  struct PoolBoost {
    uint256 lpBoostRate;
    uint256 cvpBoostRate;
    uint32 lastUpdateBlock;
    uint256 accCvpPerLpBoost;
    uint256 accCvpPerCvpBoost;
  }

  struct UserPoolBoost {
    uint256 balance;
    uint32 lastUpdateBlock;
  }

  mapping(uint256 => PoolBoost) public poolBoostByLp;
  mapping(uint256 => mapping(address => UserPoolBoost)) public usersPoolBoost;

  mapping(address => uint256) public lpBoostRatioByToken;
  mapping(address => uint256) public lpBoostMaxRatioByToken;

  mapping(address => bool) public votingEnabled;

  function initialize(
    IERC20 _cvp,
    address _reservoir,
    uint256 _cvpPerBlock,
    uint256 _startBlock,
    uint256 _cvpVestingPeriodInBlocks
  ) external override initializer {

    __Ownable_init();
    __ReentrancyGuard_init_unchained();

    cvp = _cvp;
    reservoir = _reservoir;
    startBlock = SafeMath32.fromUint(_startBlock, "VLPMining: too big startBlock");
    cvpVestingPeriodInBlocks = SafeMath32.fromUint(_cvpVestingPeriodInBlocks, "VLPMining: too big vest period");
    setCvpPerBlock(_cvpPerBlock);
  }

  function poolLength() external view override returns (uint256) {

    return pools.length;
  }

  function add(
    uint256 _allocPoint,
    IERC20 _lpToken,
    uint8 _poolType,
    bool _votesEnabled,
    uint256 _lpBoostRate,
    uint256 _cvpBoostRate,
    uint256 _lpBoostMinRatio,
    uint256 _lpBoostMaxRatio
  ) public override onlyOwner {

    require(!isLpTokenAdded(_lpToken), "VLPMining: token already added");

    massUpdatePools();
    uint32 blockNum = _currBlock();
    uint32 lastUpdateBlock = blockNum > startBlock ? blockNum : startBlock;
    totalAllocPoint = totalAllocPoint.add(_allocPoint);

    uint256 pid = pools.length;
    pools.push(
      Pool({
        lpToken: _lpToken,
        votesEnabled: _votesEnabled,
        poolType: _poolType,
        allocPoint: SafeMath32.fromUint(_allocPoint, "VLPMining: too big allocation"),
        lastUpdateBlock: lastUpdateBlock,
        accCvpPerLpt: 0
      })
    );
    poolPidByAddress[address(_lpToken)] = pid;

    poolBoostByLp[pid].lpBoostRate = _lpBoostRate;
    poolBoostByLp[pid].cvpBoostRate = _cvpBoostRate;

    poolBoostByLp[pid].lastUpdateBlock = lastUpdateBlock;
    lpBoostRatioByToken[address(_lpToken)] = _lpBoostMinRatio;
    lpBoostMaxRatioByToken[address(_lpToken)] = _lpBoostMaxRatio;

    emit AddLpToken(address(_lpToken), pid, _allocPoint);
  }

  function set(
    uint256 _pid,
    uint256 _allocPoint,
    uint8 _poolType,
    bool _votesEnabled,
    uint256 _lpBoostRate,
    uint256 _cvpBoostRate,
    uint256 _lpBoostMinRatio,
    uint256 _lpBoostMaxRatio
  ) public override onlyOwner {

    massUpdatePools();
    totalAllocPoint = totalAllocPoint.sub(uint256(pools[_pid].allocPoint)).add(_allocPoint);
    pools[_pid].allocPoint = SafeMath32.fromUint(_allocPoint, "VLPMining: too big allocation");
    pools[_pid].votesEnabled = _votesEnabled;
    pools[_pid].poolType = _poolType;

    poolBoostByLp[_pid].lpBoostRate = _lpBoostRate;
    poolBoostByLp[_pid].cvpBoostRate = _cvpBoostRate;

    lpBoostRatioByToken[address(pools[_pid].lpToken)] = _lpBoostMinRatio;
    lpBoostMaxRatioByToken[address(pools[_pid].lpToken)] = _lpBoostMaxRatio;

    emit SetLpToken(address(pools[_pid].lpToken), _pid, _allocPoint);
  }

  function setMigrator(ILpTokenMigrator _migrator) public override onlyOwner {

    migrator = _migrator;

    emit SetMigrator(address(_migrator));
  }

  function setCvpPerBlock(uint256 _cvpPerBlock) public override onlyOwner {

    cvpPerBlock = SafeMath96.fromUint(_cvpPerBlock, "VLPMining: too big cvpPerBlock");

    emit SetCvpPerBlock(_cvpPerBlock);
  }

  function setCvpVestingPeriodInBlocks(uint256 _cvpVestingPeriodInBlocks) public override onlyOwner {

    cvpVestingPeriodInBlocks = SafeMath32.fromUint(
      _cvpVestingPeriodInBlocks,
      "VLPMining: too big cvpVestingPeriodInBlocks"
    );

    emit SetCvpVestingPeriodInBlocks(_cvpVestingPeriodInBlocks);
  }

  function setCvpPoolByMetaPool(address _metaPool, address _cvpPool) public override onlyOwner {

    cvpPoolByMetaPool[_metaPool] = _cvpPool;

    emit SetCvpPoolByMetaPool(_metaPool, _cvpPool);
  }

  function updateCvpAdjust(
    uint256 _pid,
    address[] calldata _users,
    uint96[] calldata _cvpAdjust
  ) external onlyOwner {

    uint256 len = _users.length;
    require(len == _cvpAdjust.length, "Lengths not match");
    for (uint256 i = 0; i < len; i++) {
      users[_pid][_users[i]].cvpAdjust = _cvpAdjust[i];
    }
  }

  function migrate(uint256 _pid) public override nonReentrant {

    require(address(migrator) != address(0), "VLPMining: no migrator");
    Pool storage pool = pools[_pid];
    IERC20 lpToken = pool.lpToken;
    uint256 bal = lpToken.balanceOf(address(this));
    lpToken.safeApprove(address(migrator), bal);
    IERC20 newLpToken = migrator.migrate(lpToken, pool.poolType);
    require(bal == newLpToken.balanceOf(address(this)), "VLPMining: invalid migration");
    pool.lpToken = newLpToken;

    delete poolPidByAddress[address(lpToken)];
    poolPidByAddress[address(newLpToken)] = _pid;

    emit MigrateLpToken(address(lpToken), address(newLpToken), _pid);
  }

  function pendingCvp(uint256 _pid, address _user) external view override returns (uint256) {

    if (_pid >= pools.length) return 0;

    Pool memory _pool = pools[_pid];
    PoolBoost memory _poolBoost = poolBoostByLp[_pid];
    User memory user = users[_pid][_user];
    UserPoolBoost memory userPB = usersPoolBoost[_pid][_user];

    _computePoolReward(_pool);
    _computePoolBoostReward(_poolBoost);

    _pool.lastUpdateBlock = pools[_pid].lastUpdateBlock;
    _computePoolRewardByBoost(_pool, _poolBoost);
    uint96 newlyEntitled = _computeCvpToEntitle(user, _pool, userPB, _poolBoost);

    return uint256(newlyEntitled.add(user.pendedCvp));
  }

  function vestableCvp(uint256 _pid, address user) external view override returns (uint256) {

    Pool memory _pool = pools[_pid];
    PoolBoost memory _poolBoost = poolBoostByLp[_pid];
    User memory _user = users[_pid][user];
    UserPoolBoost memory _userPB = usersPoolBoost[_pid][user];

    _computePoolReward(_pool);
    _computePoolBoostReward(_poolBoost);

    _pool.lastUpdateBlock = pools[_pid].lastUpdateBlock;
    _computePoolRewardByBoost(_pool, _poolBoost);
    (, uint256 newlyVested) = _computeCvpVesting(_user, _pool, _userPB, _poolBoost);

    return newlyVested;
  }

  function isLpTokenAdded(IERC20 _lpToken) public view override returns (bool) {

    uint256 pid = poolPidByAddress[address(_lpToken)];
    return pools.length > pid && address(pools[pid].lpToken) == address(_lpToken);
  }

  function massUpdatePools() public override {

    uint256 length = pools.length;
    for (uint256 pid = 0; pid < length; ++pid) {
      updatePool(pid);
    }
  }

  function updatePool(uint256 _pid) public override nonReentrant {

    _doPoolUpdate(pools[_pid], poolBoostByLp[_pid]);
  }

  function deposit(
    uint256 _pid,
    uint256 _amount,
    uint256 _boostAmount
  ) public override nonReentrant {

    _validatePoolId(_pid);
    _preventSameTxOriginAndMsgSender();

    Pool storage pool = pools[_pid];
    PoolBoost storage poolBoost = poolBoostByLp[_pid];
    User storage user = users[_pid][msg.sender];
    UserPoolBoost storage userPB = usersPoolBoost[_pid][msg.sender];

    _doPoolUpdate(pool, poolBoost);
    _vestUserCvp(user, pool, userPB, poolBoost);

    if (_amount != 0) {
      pool.lpToken.safeTransferFrom(msg.sender, address(this), _amount);
      user.lptAmount = user.lptAmount.add(_amount);
    }
    if (_boostAmount != 0) {
      cvp.safeTransferFrom(msg.sender, address(this), _boostAmount);
      userPB.balance = userPB.balance.add(_boostAmount);
    }
    if (userPB.balance != 0) {
      require(!cvpAmountNotInBoundsToBoost(userPB.balance, user.lptAmount, address(pool.lpToken)), "BOOST_BOUNDS");
    }
    user.cvpAdjust = _computeCvpAdjustmentWithBoost(user.lptAmount, pool, userPB, poolBoost);
    emit Deposit(msg.sender, _pid, _amount, _boostAmount);

    if (votingEnabled[msg.sender]) {
      _doCheckpointVotes(msg.sender);
    }
  }

  function withdraw(
    uint256 _pid,
    uint256 _amount,
    uint256 _boostAmount
  ) public override nonReentrant {

    _validatePoolId(_pid);
    _preventSameTxOriginAndMsgSender();

    Pool storage pool = pools[_pid];
    PoolBoost storage poolBoost = poolBoostByLp[_pid];
    User storage user = users[_pid][msg.sender];
    UserPoolBoost storage userPB = usersPoolBoost[_pid][msg.sender];
    require(user.lptAmount >= _amount, "VLPMining: amount exceeds balance");

    _doPoolUpdate(pool, poolBoost);
    _vestUserCvp(user, pool, userPB, poolBoost);

    if (_amount != 0) {
      user.lptAmount = user.lptAmount.sub(_amount);
      pool.lpToken.safeTransfer(msg.sender, _amount);
    }
    if (_boostAmount != 0) {
      userPB.balance = userPB.balance.sub(_boostAmount);
      cvp.safeTransfer(msg.sender, _boostAmount);
    }
    if (userPB.balance != 0) {
      require(!cvpAmountNotInBoundsToBoost(userPB.balance, user.lptAmount, address(pool.lpToken)), "BOOST_BOUNDS");
    }
    user.cvpAdjust = _computeCvpAdjustmentWithBoost(user.lptAmount, pool, userPB, poolBoost);
    emit Withdraw(msg.sender, _pid, _amount, _boostAmount);

    if (votingEnabled[msg.sender]) {
      _doCheckpointVotes(msg.sender);
    }
  }

  function emergencyWithdraw(uint256 _pid) public override nonReentrant {

    _validatePoolId(_pid);
    _preventSameTxOriginAndMsgSender();

    Pool storage pool = pools[_pid];
    User storage user = users[_pid][msg.sender];
    UserPoolBoost storage userPB = usersPoolBoost[_pid][msg.sender];

    pool.lpToken.safeTransfer(msg.sender, user.lptAmount);
    if (userPB.balance != 0) {
      cvp.safeTransfer(msg.sender, userPB.balance);
    }
    emit EmergencyWithdraw(msg.sender, _pid, user.lptAmount, userPB.balance);

    if (user.pendedCvp > 0) {
      cvpVestingPool = user.pendedCvp > cvpVestingPool ? 0 : cvpVestingPool.sub(user.pendedCvp);
    }

    user.lptAmount = 0;
    user.cvpAdjust = 0;
    user.pendedCvp = 0;
    user.vestingBlock = 0;
    userPB.balance = 0;

    if (votingEnabled[msg.sender]) {
      _doCheckpointVotes(msg.sender);
    }
  }

  function setVotingEnabled(bool _isEnabled) public nonReentrant {

    votingEnabled[msg.sender] = _isEnabled;
    if (_isEnabled) {
      _doCheckpointVotes(msg.sender);
    }
  }

  function checkpointVotes(address _user) public override nonReentrant {

    _doCheckpointVotes(_user);
  }

  function getCurrentVotes(address account) external view returns (uint96) {

    if (!votingEnabled[account]) {
      return 0;
    }
    return _getCurrentVotes(account);
  }

  function getPriorVotes(address account, uint256 blockNumber) external view returns (uint96) {

    if (!votingEnabled[account]) {
      return 0;
    }
    return _getPriorVotes(account, blockNumber);
  }

  function getPriorVotes(
    address account,
    uint256 blockNumber,
    uint32 userCheckpointId,
    uint32 sharedCheckpointId
  ) external view returns (uint96) {

    if (!votingEnabled[account]) {
      return 0;
    }
    return _getPriorVotes(account, blockNumber, userCheckpointId, sharedCheckpointId);
  }

  function getCheckpoint(address account, uint32 checkpointId)
    external
    view
    override
    returns (
      uint32 fromBlock,
      uint96 cvpAmount,
      uint96 pooledCvpShare
    )
  {

    uint192 data;
    (fromBlock, data) = _getCheckpoint(account, checkpointId);
    (cvpAmount, pooledCvpShare) = _unpackData(data);
  }

  function _doCheckpointVotes(address _user) internal {

    uint256 length = pools.length;
    uint96 userPendedCvp = 0;
    uint256 userTotalLpCvp = 0;
    uint96 totalLpCvp = 0;
    for (uint256 pid = 0; pid < length; ++pid) {
      userPendedCvp = userPendedCvp.add(users[pid][_user].pendedCvp);

      Pool storage pool = pools[pid];
      uint96 lpCvp;
      address lpToken = address(pool.lpToken);
      address cvpPoolByMeta = cvpPoolByMetaPool[lpToken];
      if (cvpPoolByMeta == address(0)) {
        lpCvp = SafeMath96.fromUint(cvp.balanceOf(lpToken), "VLPMining::_doCheckpointVotes:1");
        totalLpCvp = totalLpCvp.add(lpCvp);
      } else {
        uint256 poolTotalSupply = IERC20(cvpPoolByMeta).totalSupply();
        uint256 poolBalance = IERC20(cvpPoolByMeta).balanceOf(lpToken);
        uint256 lpShare = uint256(poolBalance).mul(SCALE).div(poolTotalSupply);
        uint256 metaPoolCvp = cvp.balanceOf(cvpPoolByMeta);
        lpCvp = SafeMath96.fromUint(metaPoolCvp.mul(lpShare).div(SCALE), "VLPMining::_doCheckpointVotes:1");
      }

      if (!pool.votesEnabled) {
        continue;
      }

      uint256 lptTotalSupply = pool.lpToken.totalSupply();
      uint256 lptAmount = users[pid][_user].lptAmount;
      if (lptAmount != 0 && lptTotalSupply != 0) {
        uint256 cvpPerLpt = uint256(lpCvp).mul(SCALE).div(lptTotalSupply);
        uint256 userLpCvp = lptAmount.mul(cvpPerLpt).div(SCALE);
        userTotalLpCvp = userTotalLpCvp.add(userLpCvp);

        emit CheckpointUserLpVotes(_user, pid, userLpCvp);
      }
    }

    uint96 lpCvpUserShare =
      (userTotalLpCvp == 0 || totalLpCvp == 0)
        ? 0
        : SafeMath96.fromUint(userTotalLpCvp.mul(SCALE).div(totalLpCvp), "VLPMining::_doCheckpointVotes:2");

    emit CheckpointTotalLpVotes(totalLpCvp);
    emit CheckpointUserVotes(_user, uint256(userPendedCvp), lpCvpUserShare);

    _writeUserData(_user, _packData(userPendedCvp, lpCvpUserShare));
    _writeSharedData(_packData(totalLpCvp, 0));
  }

  function _transferCvp(address _to, uint256 _amount) internal {

    SafeERC20.safeTransferFrom(cvp, reservoir, _to, _amount);
  }

  function _doPoolUpdate(Pool storage pool, PoolBoost storage poolBoost) internal {

    Pool memory _pool = pool;
    uint32 prevBlock = _pool.lastUpdateBlock;
    uint256 prevAcc = _pool.accCvpPerLpt;

    uint256 cvpReward = _computePoolReward(_pool);

    if (poolBoost.lpBoostRate != 0) {
      PoolBoost memory _poolBoost = poolBoost;
      uint32 prevBoostBlock = poolBoost.lastUpdateBlock;
      uint256 prevCvpBoostAcc = poolBoost.accCvpPerCvpBoost;
      uint256 prevLpBoostAcc = poolBoost.accCvpPerLpBoost;

      cvpReward = cvpReward.add(_computePoolBoostReward(_poolBoost));
      _pool.lastUpdateBlock = prevBlock;
      cvpReward = cvpReward.add(_computePoolRewardByBoost(_pool, _poolBoost));

      if (_poolBoost.accCvpPerCvpBoost > prevCvpBoostAcc) {
        poolBoost.accCvpPerCvpBoost = _poolBoost.accCvpPerCvpBoost;
      }
      if (_poolBoost.accCvpPerLpBoost > prevLpBoostAcc) {
        poolBoost.accCvpPerLpBoost = _poolBoost.accCvpPerLpBoost;
      }
      if (_poolBoost.lastUpdateBlock > prevBoostBlock) {
        poolBoost.lastUpdateBlock = _poolBoost.lastUpdateBlock;
      }
    }

    if (_pool.accCvpPerLpt > prevAcc) {
      pool.accCvpPerLpt = _pool.accCvpPerLpt;
    }
    if (_pool.lastUpdateBlock > prevBlock) {
      pool.lastUpdateBlock = _pool.lastUpdateBlock;
    }

    if (cvpReward != 0) {
      cvpVestingPool = cvpVestingPool.add(
        SafeMath96.fromUint(cvpReward, "VLPMining::_doPoolUpdate:1"),
        "VLPMining::_doPoolUpdate:2"
      );
    }
  }

  function _vestUserCvp(
    User storage user,
    Pool storage pool,
    UserPoolBoost storage userPB,
    PoolBoost storage poolBoost
  ) internal {

    User memory _user = user;
    UserPoolBoost memory _userPB = userPB;
    uint32 prevVestingBlock = _user.vestingBlock;
    uint32 prevUpdateBlock = _user.lastUpdateBlock;
    (uint256 newlyEntitled, uint256 newlyVested) = _computeCvpVesting(_user, pool, _userPB, poolBoost);

    if (newlyEntitled != 0 || newlyVested != 0) {
      user.pendedCvp = _user.pendedCvp;
    }
    if (newlyVested != 0) {
      if (newlyVested > cvpVestingPool) newlyVested = uint256(cvpVestingPool);
      cvpVestingPool = cvpVestingPool.sub(
        SafeMath96.fromUint(newlyVested, "VLPMining::_vestUserCvp:1"),
        "VLPMining::_vestUserCvp:2"
      );
      _transferCvp(msg.sender, newlyVested);
    }
    if (_user.vestingBlock > prevVestingBlock) {
      user.vestingBlock = _user.vestingBlock;
    }
    if (_user.lastUpdateBlock > prevUpdateBlock) {
      user.lastUpdateBlock = _user.lastUpdateBlock;
    }
  }

  function _computeCvpVesting(
    User memory _user,
    Pool memory pool,
    UserPoolBoost memory _userPB,
    PoolBoost memory _poolBoost
  ) internal view returns (uint256 newlyEntitled, uint256 newlyVested) {

    uint32 prevBlock = _user.lastUpdateBlock;
    _user.lastUpdateBlock = _currBlock();
    if (prevBlock >= _user.lastUpdateBlock) {
      return (0, 0);
    }

    uint32 age = _user.lastUpdateBlock - prevBlock;

    newlyEntitled = uint256(_computeCvpToEntitle(_user, pool, _userPB, _poolBoost));
    uint256 newToVest =
      newlyEntitled == 0 ? 0 : (newlyEntitled.mul(uint256(age)).div(uint256(age + cvpVestingPeriodInBlocks)));

    uint256 pended = uint256(_user.pendedCvp);
    age = _user.lastUpdateBlock >= _user.vestingBlock ? cvpVestingPeriodInBlocks : _user.lastUpdateBlock - prevBlock;
    uint256 pendedToVest =
      pended == 0
        ? 0
        : (
          age >= cvpVestingPeriodInBlocks
            ? pended
            : pended.mul(uint256(age)).div(uint256(_user.vestingBlock - prevBlock))
        );

    newlyVested = pendedToVest.add(newToVest);
    _user.pendedCvp = SafeMath96.fromUint(
      uint256(_user.pendedCvp).add(newlyEntitled).sub(newlyVested),
      "VLPMining::computeCvpVest:1"
    );

    uint256 remainingPended = pended == 0 ? 0 : pended.sub(pendedToVest);
    uint256 unreleasedNewly = newlyEntitled == 0 ? 0 : newlyEntitled.sub(newToVest);
    uint256 pending = remainingPended.add(unreleasedNewly);

    uint256 period = 0;
    if (remainingPended == 0 || pending == 0) {
      period = cvpVestingPeriodInBlocks;
    } else {
      age = _user.vestingBlock - _user.lastUpdateBlock;
      period = ((remainingPended.mul(age)).add(unreleasedNewly.mul(cvpVestingPeriodInBlocks))).div(pending);
    }
    _user.vestingBlock =
      _user.lastUpdateBlock +
      (cvpVestingPeriodInBlocks > uint32(period) ? uint32(period) : cvpVestingPeriodInBlocks);

    return (newlyEntitled, newlyVested);
  }

  function _computePoolReward(Pool memory _pool) internal view returns (uint256 poolCvpReward) {

    (poolCvpReward, _pool.accCvpPerLpt, _pool.lastUpdateBlock) = _computeReward(
      _pool.lastUpdateBlock,
      _pool.accCvpPerLpt,
      _pool.lpToken,
      SCALE.mul(uint256(cvpPerBlock)).mul(uint256(_pool.allocPoint)).div(totalAllocPoint)
    );
  }

  function _computePoolRewardByBoost(Pool memory _pool, PoolBoost memory _poolBoost)
    internal
    view
    returns (uint256 poolCvpReward)
  {

    (poolCvpReward, _poolBoost.accCvpPerLpBoost, _pool.lastUpdateBlock) = _computeReward(
      _pool.lastUpdateBlock,
      _poolBoost.accCvpPerLpBoost,
      _pool.lpToken,
      _poolBoost.lpBoostRate
    );
  }

  function _computePoolBoostReward(PoolBoost memory _poolBoost) internal view returns (uint256 poolCvpReward) {

    (poolCvpReward, _poolBoost.accCvpPerCvpBoost, _poolBoost.lastUpdateBlock) = _computeReward(
      _poolBoost.lastUpdateBlock,
      _poolBoost.accCvpPerCvpBoost,
      cvp,
      _poolBoost.cvpBoostRate
    );
  }

  function _computeReward(
    uint256 _lastUpdateBlock,
    uint256 _accumulated,
    IERC20 _token,
    uint256 _cvpPoolRate
  )
    internal
    view
    returns (
      uint256 poolCvpReward,
      uint256 newAccumulated,
      uint32 newLastUpdateBlock
    )
  {

    newAccumulated = _accumulated;

    newLastUpdateBlock = _currBlock();
    if (newLastUpdateBlock > _lastUpdateBlock) {
      uint256 multiplier = uint256(newLastUpdateBlock - _lastUpdateBlock); // can't overflow

      uint256 lptBalance = _token.balanceOf(address(this));
      if (lptBalance != 0) {
        poolCvpReward = multiplier.mul(_cvpPoolRate).div(SCALE);

        newAccumulated = newAccumulated.add(poolCvpReward.mul(SCALE).div(lptBalance));
      }
    }
  }

  function _computeUserVotes(
    uint192 userData,
    uint192 sharedData,
    uint192 sharedDataAtUserSave
  ) internal pure override returns (uint96 votes) {

    (uint96 ownCvp, uint96 pooledCvpShare) = _unpackData(userData);
    (uint96 currentTotalPooledCvp, ) = _unpackData(sharedData);
    (uint96 totalPooledCvpAtUserSave, ) = _unpackData(sharedDataAtUserSave);

    if (pooledCvpShare == 0) {
      votes = ownCvp;
    } else {
      uint256 pooledCvp = uint256(pooledCvpShare).mul(currentTotalPooledCvp).div(SCALE);
      if (currentTotalPooledCvp != totalPooledCvpAtUserSave) {
        uint256 totalCvpDiffRatio = uint256(currentTotalPooledCvp).mul(SCALE).div(uint256(totalPooledCvpAtUserSave));
        if (totalCvpDiffRatio > SCALE) {
          pooledCvp = pooledCvp.mul(SCALE).div(totalCvpDiffRatio);
        }
      }
      votes = ownCvp.add(SafeMath96.fromUint(pooledCvp, "VLPMining::_computeVotes"));
    }
  }

  function _computeCvpToEntitle(
    User memory user,
    Pool memory pool,
    UserPoolBoost memory userPB,
    PoolBoost memory poolBoost
  ) private view returns (uint96 cvpResult) {

    if (user.lptAmount == 0) {
      return 0;
    }
    return
      _computeCvpAdjustmentWithBoost(user.lptAmount, pool, userPB, poolBoost).sub(
        user.cvpAdjust,
        "VLPMining::computeCvp:2"
      );
  }

  function _computeCvpAdjustmentWithBoost(
    uint256 lptAmount,
    Pool memory pool,
    UserPoolBoost memory userPB,
    PoolBoost memory poolBoost
  ) private view returns (uint96 cvpResult) {

    cvpResult = _computeCvpAdjustment(lptAmount, pool.accCvpPerLpt);
    if (poolBoost.cvpBoostRate == 0 || poolBoost.lpBoostRate == 0 || userPB.balance == 0) {
      return cvpResult;
    }
    return
      cvpResult.add(_computeCvpAdjustment(userPB.balance, poolBoost.accCvpPerCvpBoost)).add(
        _computeCvpAdjustment(lptAmount, poolBoost.accCvpPerLpBoost)
      );
  }

  function _computeCvpAdjustment(uint256 lptAmount, uint256 accCvpPerLpt) private pure returns (uint96) {

    return SafeMath96.fromUint(lptAmount.mul(accCvpPerLpt).div(SCALE), "VLPMining::_computeCvpAdj");
  }

  function cvpAmountNotInBoundsToBoost(
    uint256 _cvpAmount,
    uint256 _lpAmount,
    address _lpToken
  ) public view returns (bool) {

    return
      _cvpAmount < cvpBalanceToBoost(_lpAmount, _lpToken, true) ||
      _cvpAmount > cvpBalanceToBoost(_lpAmount, _lpToken, false);
  }

  function cvpBalanceToBoost(
    uint256 _lpAmount,
    address _lpToken,
    bool _min
  ) public view returns (uint256) {

    return _lpAmount.mul(_min ? lpBoostRatioByToken[_lpToken] : lpBoostMaxRatioByToken[_lpToken]).div(SCALE);
  }

  function _validatePoolId(uint256 pid) private view {

    require(pid < pools.length, "VLPMining: invalid pool id");
  }

  function _currBlock() private view returns (uint32) {

    return SafeMath32.fromUint(block.number, "VLPMining::_currBlock:overflow");
  }

  function _preventSameTxOriginAndMsgSender() internal {

    require(block.number > lastSwapBlock[tx.origin], "SAME_TX_ORIGIN");
    lastSwapBlock[tx.origin] = block.number;

    if (msg.sender != tx.origin) {
      require(block.number > lastSwapBlock[msg.sender], "SAME_MSG_SENDER");
      lastSwapBlock[msg.sender] = block.number;
    }
  }
}