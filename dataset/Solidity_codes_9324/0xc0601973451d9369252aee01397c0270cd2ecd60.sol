
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
}// MIT

pragma solidity ^0.7.0;

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
}// MIT

pragma solidity ^0.7.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.7.0;

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
}// MIT

pragma solidity ^0.7.0;


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
}// MIT

pragma solidity ^0.7.0;


library SafeCast {


    function toUint128(uint256 value) internal pure returns (uint128) {

        require(value < 2**128, "SafeCast: value doesn\'t fit in 128 bits");
        return uint128(value);
    }

    function toUint64(uint256 value) internal pure returns (uint64) {

        require(value < 2**64, "SafeCast: value doesn\'t fit in 64 bits");
        return uint64(value);
    }

    function toUint32(uint256 value) internal pure returns (uint32) {

        require(value < 2**32, "SafeCast: value doesn\'t fit in 32 bits");
        return uint32(value);
    }

    function toUint16(uint256 value) internal pure returns (uint16) {

        require(value < 2**16, "SafeCast: value doesn\'t fit in 16 bits");
        return uint16(value);
    }

    function toUint8(uint256 value) internal pure returns (uint8) {

        require(value < 2**8, "SafeCast: value doesn\'t fit in 8 bits");
        return uint8(value);
    }

    function toUint256(int256 value) internal pure returns (uint256) {

        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    function toInt128(int256 value) internal pure returns (int128) {

        require(value >= -2**127 && value < 2**127, "SafeCast: value doesn\'t fit in 128 bits");
        return int128(value);
    }

    function toInt64(int256 value) internal pure returns (int64) {

        require(value >= -2**63 && value < 2**63, "SafeCast: value doesn\'t fit in 64 bits");
        return int64(value);
    }

    function toInt32(int256 value) internal pure returns (int32) {

        require(value >= -2**31 && value < 2**31, "SafeCast: value doesn\'t fit in 32 bits");
        return int32(value);
    }

    function toInt16(int256 value) internal pure returns (int16) {

        require(value >= -2**15 && value < 2**15, "SafeCast: value doesn\'t fit in 16 bits");
        return int16(value);
    }

    function toInt8(int256 value) internal pure returns (int8) {

        require(value >= -2**7 && value < 2**7, "SafeCast: value doesn\'t fit in 8 bits");
        return int8(value);
    }

    function toInt256(uint256 value) internal pure returns (int256) {

        require(value < 2**255, "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}// MIT
pragma solidity 0.7.6;



interface IERC20Ext is IERC20 {

    function decimals() external view returns (uint8 digits);

}// MIT
pragma solidity 0.7.6;


abstract contract PermissionAdmin {
    address public admin;
    address public pendingAdmin;

    event AdminClaimed(address newAdmin, address previousAdmin);

    event TransferAdminPending(address pendingAdmin);

    constructor(address _admin) {
        require(_admin != address(0), "admin 0");
        admin = _admin;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "only admin");
        _;
    }

    function transferAdmin(address newAdmin) public onlyAdmin {
        require(newAdmin != address(0), "new admin 0");
        emit TransferAdminPending(newAdmin);
        pendingAdmin = newAdmin;
    }

    function transferAdminQuickly(address newAdmin) public onlyAdmin {
        require(newAdmin != address(0), "admin 0");
        emit TransferAdminPending(newAdmin);
        emit AdminClaimed(newAdmin, admin);
        admin = newAdmin;
    }

    function claimAdmin() public {
        require(pendingAdmin == msg.sender, "not pending");
        emit AdminClaimed(pendingAdmin, admin);
        admin = pendingAdmin;
        pendingAdmin = address(0);
    }
}// agpl-3.0
pragma solidity 0.7.6;
pragma abicoder v2;

interface IKyberFairLaunchWithToken {

  function addPool(
    address _stakeToken,
    uint32 _startBlock,
    uint32 _endBlock,
    uint256[] calldata _rewardPerBlocks,
    string memory _tokenName,
    string memory _tokenSymbol
  ) external;


  function renewPool(
    uint256 _pid,
    uint32 _startBlock,
    uint32 _endBlock,
    uint256[] calldata _rewardPerBlocks
  ) external;


  function updatePool(
    uint256 _pid,
    uint32 _endBlock,
    uint256[] calldata _rewardPerBlocks
  ) external;


  function deposit(
    uint256 _pid,
    uint256 _amount,
    bool _shouldHarvest
  ) external;


  function withdraw(uint256 _pid, uint256 _amount) external;


  function withdrawAll(uint256 _pid) external;


  function emergencyWithdraw(uint256 _pid) external;


  function harvest(uint256 _pid) external;


  function harvestMultiplePools(uint256[] calldata _pids) external;


  function updatePoolRewards(uint256 _pid) external;


  function poolLength() external view returns (uint256);


  function getPoolInfo(uint256 _pid)
    external view
    returns(
      uint256 totalStake,
      address stakeToken,
      uint32 startBlock,
      uint32 endBlock,
      uint32 lastRewardBlock,
      uint256[] memory rewardPerBlocks,
      uint256[] memory accRewardPerShares);


  function getUserInfo(uint256 _pid, address _account)
    external view
    returns (
      uint256 amount,
      uint256[] memory unclaimedRewards,
      uint256[] memory lastRewardPerShares);


  function getRewardTokens() external view returns (address[] memory);

  function pendingRewards(
    uint256 _pid,
    address _user
   )
    external view
    returns (uint256[] memory rewards);

}// agpl-3.0
pragma solidity 0.7.6;


interface IKyberRewardLocker {

  struct VestingSchedule {
    uint64 startBlock;
    uint64 endBlock;
    uint128 quantity;
    uint128 vestedQuantity;
  }

  event VestingEntryCreated(
    IERC20Ext indexed token,
    address indexed beneficiary,
    uint256 startBlock,
    uint256 endBlock,
    uint256 quantity,
    uint256 index
  );

  event VestingEntryQueued(
    uint256 indexed index,
    IERC20Ext indexed token,
    address indexed beneficiary,
    uint256 quantity
  );

  event Vested(
    IERC20Ext indexed token,
    address indexed beneficiary,
    uint256 vestedQuantity,
    uint256 index
  );

  function lock(
    IERC20Ext token,
    address account,
    uint256 amount
  ) external payable;


  function lockWithStartBlock(
    IERC20Ext token,
    address account,
    uint256 quantity,
    uint256 startBlock
  ) external payable;


  function vestCompletedSchedulesForMultipleTokens(IERC20Ext[] calldata tokens)
    external
    returns (uint256[] memory vestedAmounts);


  function vestScheduleForMultipleTokensAtIndices(
    IERC20Ext[] calldata tokens,
    uint256[][] calldata indices
  )
    external
    returns (uint256[] memory vestedAmounts);


  function vestCompletedSchedules(IERC20Ext token) external returns (uint256);


  function vestScheduleAtIndices(IERC20Ext token, uint256[] calldata indexes)
    external
    returns (uint256);


  function vestSchedulesInRange(
    IERC20Ext token,
    uint256 startIndex,
    uint256 endIndex
  ) external returns (uint256);


  function numVestingSchedules(address account, IERC20Ext token) external view returns (uint256);


  function getVestingScheduleAtIndex(
    address account,
    IERC20Ext token,
    uint256 index
  ) external view returns (VestingSchedule memory);


  function getVestingSchedules(address account, IERC20Ext token)
    external
    view
    returns (VestingSchedule[] memory schedules);

}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.7.0;


contract ERC20 is Context, IERC20 {

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

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}// agpl-3.0
pragma solidity 0.7.6;



contract GeneratedToken is ERC20 {

  address internal deployer;

  modifier onlyDeployer() {
    require(msg.sender == deployer, 'unauthorized');
    _;
  }

  constructor (string memory name_, string memory symbol_) ERC20(name_, symbol_) {
    deployer = msg.sender;
  }

  function mint(address account, uint256 amount) external onlyDeployer {
    super._mint(account, amount);
  }

  function burn(address account, uint256 amount) external onlyDeployer {
    super._burn(account, amount);
  }
}// agpl-3.0
pragma solidity 0.7.6;


contract KyberFairLaunchWithToken is IKyberFairLaunchWithToken, PermissionAdmin, ReentrancyGuard {
  using SafeMath for uint256;
  using SafeCast for uint256;
  using SafeERC20 for IERC20Ext;

  uint256 internal constant PRECISION = 1e12;

  struct UserRewardData {
    uint256 unclaimedReward;
    uint256 lastRewardPerShare;
  }
  struct UserInfo {
    uint256 amount; // How many Staking tokens the user has provided.
    mapping (uint256 => UserRewardData) userRewardData;
  }

  struct PoolRewardData {
    uint256 rewardPerBlock;
    uint256 accRewardPerShare;
  }
  struct PoolInfo {
    uint256 totalStake;
    address stakeToken;
    uint32 startBlock;
    uint32 endBlock;
    uint32 lastRewardBlock;
    mapping (uint256 => PoolRewardData) poolRewardData;
  }

  mapping(address => bool) public poolExists;
  mapping(address => GeneratedToken) public poolToGeneratedToken;
  IKyberRewardLocker public immutable rewardLocker;
  address[] public rewardTokens;

  uint256 public override poolLength;
  mapping(uint256 => PoolInfo) internal poolInfo;
  mapping(uint256 => mapping(address => UserInfo)) internal userInfo;

  event AddNewPool(
    address indexed stakeToken,
    uint32 indexed startBlock,
    uint32 indexed endBlock,
    uint256[] rewardPerBlocks
  );
  event RenewPool(
    uint256 indexed pid,
    uint32 indexed startBlock,
    uint32 indexed endBlock,
    uint256[] rewardPerBlocks
  );
  event UpdatePool(
    uint256 indexed pid,
    uint32 indexed endBlock,
    uint256[] rewardPerBlocks
  );
  event Deposit(
    address indexed user,
    uint256 indexed pid,
    uint256 indexed blockNumber,
    uint256 amount
  );
  event Withdraw(
    address indexed user,
    uint256 indexed pid,
    uint256 indexed blockNumber,
    uint256 amount
  );
  event Harvest(
    address indexed user,
    uint256 indexed pid,
    address indexed rewardToken,
    uint256 lockedAmount,
    uint256 blockNumber
  );
  event EmergencyWithdraw(
    address indexed user,
    uint256 indexed pid,
    uint256 indexed blockNumber,
    uint256 amount
  );

  constructor(
    address _admin,
    address[] memory _rewardTokens,
    IKyberRewardLocker _rewardLocker
  ) PermissionAdmin(_admin) {
    rewardTokens = _rewardTokens;
    rewardLocker = _rewardLocker;

    for(uint256 i = 0; i < _rewardTokens.length; i++) {
      if (_rewardTokens[i] != address(0)) {
        IERC20Ext(_rewardTokens[i]).safeApprove(address(_rewardLocker), type(uint256).max);
      }
    }
  }

  receive() external payable {}

  function adminWithdraw(uint256 rewardTokenIndex, uint256 amount) external onlyAdmin {
    IERC20Ext rewardToken = IERC20Ext(rewardTokens[rewardTokenIndex]);
    if (rewardToken == IERC20Ext(0)) {
      (bool success, ) = msg.sender.call{ value: amount }('');
      require(success, 'transfer reward token failed');
    } else {
      rewardToken.safeTransfer(msg.sender, amount);
    }
  }

  function addPool(
    address _stakeToken,
    uint32 _startBlock,
    uint32 _endBlock,
    uint256[] calldata _rewardPerBlocks,
    string memory _tokenName,
    string memory _tokenSymbol
  ) external override onlyAdmin {
    require(!poolExists[_stakeToken], 'add: duplicated pool');
    require(_stakeToken != address(0), 'add: invalid stake token');
    require(rewardTokens.length == _rewardPerBlocks.length, 'add: invalid length');

    require(_startBlock > block.number && _endBlock > _startBlock, 'add: invalid blocks');

    poolInfo[poolLength].stakeToken = _stakeToken;
    poolInfo[poolLength].startBlock = _startBlock;
    poolInfo[poolLength].endBlock = _endBlock;
    poolInfo[poolLength].lastRewardBlock = _startBlock;

    GeneratedToken _generatedToken = new GeneratedToken(
      _tokenName, _tokenSymbol
    );
    poolToGeneratedToken[_stakeToken] = _generatedToken;

    for(uint256 i = 0; i < _rewardPerBlocks.length; i++) {
      poolInfo[poolLength].poolRewardData[i] = PoolRewardData({
        rewardPerBlock: _rewardPerBlocks[i],
        accRewardPerShare: 0
      });
    }

    poolLength++;

    poolExists[_stakeToken] = true;

    emit AddNewPool(_stakeToken, _startBlock, _endBlock, _rewardPerBlocks);
  }

  function renewPool(
    uint256 _pid,
    uint32 _startBlock,
    uint32 _endBlock,
    uint256[] calldata _rewardPerBlocks
  ) external override onlyAdmin {
    updatePoolRewards(_pid);

    PoolInfo storage pool = poolInfo[_pid];
    require(
      pool.startBlock > block.number || pool.endBlock < block.number,
      'renew: invalid pool state to renew'
    );
    require(rewardTokens.length == _rewardPerBlocks.length, 'renew: invalid length');
    require(_startBlock > block.number && _endBlock > _startBlock, 'renew: invalid blocks');

    pool.startBlock = _startBlock;
    pool.endBlock = _endBlock;
    pool.lastRewardBlock = _startBlock;

    for(uint256 i = 0; i < _rewardPerBlocks.length; i++) {
      pool.poolRewardData[i].rewardPerBlock = _rewardPerBlocks[i];
    }

    emit RenewPool(_pid, _startBlock, _endBlock, _rewardPerBlocks);
  }

  function updatePool(
    uint256 _pid,
    uint32 _endBlock,
    uint256[] calldata _rewardPerBlocks
  ) external override onlyAdmin {
    updatePoolRewards(_pid);

    PoolInfo storage pool = poolInfo[_pid];

    require(pool.endBlock > block.number, 'update: pool already ended');
    require(rewardTokens.length == _rewardPerBlocks.length, 'update: invalid length');
    require(_endBlock > block.number && _endBlock > pool.startBlock, 'update: invalid end block');

    pool.endBlock = _endBlock;
    for(uint256 i = 0; i < _rewardPerBlocks.length; i++) {
      pool.poolRewardData[i].rewardPerBlock = _rewardPerBlocks[i];
    }

    emit UpdatePool(_pid, _endBlock, _rewardPerBlocks);
  }

  function deposit(
    uint256 _pid,
    uint256 _amount,
    bool _shouldHarvest
  ) external override nonReentrant {
    updatePoolRewards(_pid);
    _updateUserReward(msg.sender, _pid, _shouldHarvest);

    PoolInfo storage pool = poolInfo[_pid];
    UserInfo storage user = userInfo[_pid][msg.sender];

    address stakeToken = pool.stakeToken;
    IERC20Ext(stakeToken).safeTransferFrom(msg.sender, address(this), _amount);
    poolToGeneratedToken[stakeToken].mint(msg.sender, _amount);

    user.amount = user.amount.add(_amount);
    pool.totalStake = pool.totalStake.add(_amount);

    emit Deposit(msg.sender, _pid, block.number, _amount);
  }

  function withdraw(uint256 _pid, uint256 _amount) external override nonReentrant {
    _withdraw(_pid, _amount);
  }

  function withdrawAll(uint256 _pid) external override nonReentrant {
    _withdraw(_pid, userInfo[_pid][msg.sender].amount);
  }

  function emergencyWithdraw(uint256 _pid) external override nonReentrant {
    PoolInfo storage pool = poolInfo[_pid];
    UserInfo storage user = userInfo[_pid][msg.sender];
    uint256 amount = user.amount;

    user.amount = 0;
    for(uint256 i = 0; i < rewardTokens.length; i++) {
      UserRewardData storage rewardData = user.userRewardData[i];
      rewardData.lastRewardPerShare = 0;
      rewardData.unclaimedReward = 0;
    }

    pool.totalStake = pool.totalStake.sub(amount);

    if (amount > 0) {
      address stakeToken = pool.stakeToken;
      poolToGeneratedToken[stakeToken].burn(msg.sender, amount);
      IERC20Ext(stakeToken).safeTransfer(msg.sender, amount);
    }

    emit EmergencyWithdraw(msg.sender, _pid, block.number, amount);
  }

  function harvestMultiplePools(uint256[] calldata _pids) external override {
    address[] memory rTokens = rewardTokens;
    uint256[] memory totalRewards = new uint256[](rTokens.length);
    address account = msg.sender;
    uint256 pid;

    for (uint256 i = 0; i < _pids.length; i++) {
      pid = _pids[i];
      updatePoolRewards(pid);
      _updateUserReward(account, pid, false);

      for(uint256 j = 0; j < rTokens.length; j++) {
        uint256 reward = userInfo[pid][account].userRewardData[j].unclaimedReward;
        if (reward > 0) {
          totalRewards[j] = totalRewards[j].add(reward);
          userInfo[pid][account].userRewardData[j].unclaimedReward = 0;
          emit Harvest(account, pid, rTokens[j], reward, block.number);
        }
      }
    }

    for(uint256 i = 0; i < totalRewards.length; i++) {
      if (totalRewards[i] > 0) {
        _lockReward(IERC20Ext(rTokens[i]), account, totalRewards[i]);
      }
    }
  }

  function pendingRewards(uint256 _pid, address _user)
    external
    override
    view
    returns (uint256[] memory rewards)
  {
    uint256 rTokensLength = rewardTokens.length;
    rewards = new uint256[](rTokensLength);
    PoolInfo storage pool = poolInfo[_pid];
    UserInfo storage user = userInfo[_pid][_user];
    uint256 _totalStake = pool.totalStake;
    uint256 _poolLastRewardBlock = pool.lastRewardBlock;
    uint32 lastAccountedBlock = _lastAccountedRewardBlock(_pid);
    for(uint256 i = 0; i < rTokensLength; i++) {
      uint256 _accRewardPerShare = pool.poolRewardData[i].accRewardPerShare;
      if (lastAccountedBlock > _poolLastRewardBlock && _totalStake != 0) {
        uint256 reward = (lastAccountedBlock - _poolLastRewardBlock)
          .mul(pool.poolRewardData[i].rewardPerBlock);
        _accRewardPerShare = _accRewardPerShare.add(reward.mul(PRECISION) / _totalStake);
      }

      rewards[i] = user.amount.mul(
        _accRewardPerShare.sub(user.userRewardData[i].lastRewardPerShare)
        ) / PRECISION;
      rewards[i] = rewards[i].add(user.userRewardData[i].unclaimedReward);
    }
  }

  function getRewardTokens() external override view returns (address[] memory) {
    return rewardTokens;
  }

  function getPoolInfo(uint256 _pid)
    external override view
    returns (
      uint256 totalStake,
      address stakeToken,
      uint32 startBlock,
      uint32 endBlock,
      uint32 lastRewardBlock,
      uint256[] memory rewardPerBlocks,
      uint256[] memory accRewardPerShares
    )
  {
    PoolInfo storage pool = poolInfo[_pid];
    (
      totalStake,
      stakeToken,
      startBlock,
      endBlock,
      lastRewardBlock
    ) = (
      pool.totalStake,
      pool.stakeToken,
      pool.startBlock,
      pool.endBlock,
      pool.lastRewardBlock
    );
    rewardPerBlocks = new uint256[](rewardTokens.length);
    accRewardPerShares = new uint256[](rewardTokens.length);
    for(uint256 i = 0; i < rewardTokens.length; i++) {
      rewardPerBlocks[i] = pool.poolRewardData[i].rewardPerBlock;
      accRewardPerShares[i] = pool.poolRewardData[i].accRewardPerShare;
    }
  }

  function getUserInfo(uint256 _pid, address _account)
    external override view
    returns (
      uint256 amount,
      uint256[] memory unclaimedRewards,
      uint256[] memory lastRewardPerShares
    )
  {
    UserInfo storage user = userInfo[_pid][_account];
    amount = user.amount;
    unclaimedRewards = new uint256[](rewardTokens.length);
    lastRewardPerShares = new uint256[](rewardTokens.length);
    for(uint256 i = 0; i < rewardTokens.length; i++) {
      unclaimedRewards[i] = user.userRewardData[i].unclaimedReward;
      lastRewardPerShares[i] = user.userRewardData[i].lastRewardPerShare;
    }
  }

  function harvest(uint256 _pid) public override {
    updatePoolRewards(_pid);
    _updateUserReward(msg.sender, _pid, true);
  }

  function updatePoolRewards(uint256 _pid) public override {
    require(_pid < poolLength, 'invalid pool id');
    PoolInfo storage pool = poolInfo[_pid];
    uint32 lastAccountedBlock = _lastAccountedRewardBlock(_pid);
    if (lastAccountedBlock <= pool.lastRewardBlock) return;
    uint256 _totalStake = pool.totalStake;
    if (_totalStake == 0) {
      pool.lastRewardBlock = lastAccountedBlock;
      return;
    }
    uint256 numberBlocks = lastAccountedBlock - pool.lastRewardBlock;
    for(uint256 i = 0; i < rewardTokens.length; i++) {
      PoolRewardData storage rewardData = pool.poolRewardData[i];
      uint256 reward = numberBlocks.mul(rewardData.rewardPerBlock);
      rewardData.accRewardPerShare = rewardData.accRewardPerShare.add(reward.mul(PRECISION) / _totalStake);
    }
    pool.lastRewardBlock = lastAccountedBlock;
  }

  function _withdraw(uint256 _pid, uint256 _amount) internal {
    PoolInfo storage pool = poolInfo[_pid];
    UserInfo storage user = userInfo[_pid][msg.sender];
    require(user.amount >= _amount, 'withdraw: insufficient amount');

    updatePoolRewards(_pid);
    _updateUserReward(msg.sender, _pid, true);

    user.amount = user.amount.sub(_amount);
    pool.totalStake = pool.totalStake.sub(_amount);

    address stakeToken = pool.stakeToken;
    GeneratedToken(poolToGeneratedToken[stakeToken]).burn(msg.sender, _amount);
    IERC20Ext(stakeToken).safeTransfer(msg.sender, _amount);

    emit Withdraw(msg.sender, _pid, block.number, _amount);
  }

  function _updateUserReward(
    address _to,
    uint256 _pid,
    bool shouldHarvest
  ) internal {
    uint256 userAmount = userInfo[_pid][_to].amount;
    uint256 rTokensLength = rewardTokens.length;

    if (userAmount == 0) {
      for(uint256 i = 0; i < rTokensLength; i++) {
        userInfo[_pid][_to].userRewardData[i].lastRewardPerShare =
          poolInfo[_pid].poolRewardData[i].accRewardPerShare;
      }
      return;
    }

    for(uint256 i = 0; i < rTokensLength; i++) {
      uint256 lastAccRewardPerShare = poolInfo[_pid].poolRewardData[i].accRewardPerShare;
      UserRewardData storage rewardData = userInfo[_pid][_to].userRewardData[i];
      uint256 _pending = userAmount.mul(lastAccRewardPerShare.sub(rewardData.lastRewardPerShare)) / PRECISION;
      _pending = _pending.add(rewardData.unclaimedReward);

      rewardData.unclaimedReward = shouldHarvest ? 0 : _pending;
      rewardData.lastRewardPerShare = lastAccRewardPerShare;

      if (shouldHarvest && _pending > 0) {
        _lockReward(IERC20Ext(rewardTokens[i]), _to, _pending);
        emit Harvest(_to, _pid, rewardTokens[i], _pending, block.number);
      }
    }
  }

  function _lastAccountedRewardBlock(uint256 _pid) internal view returns (uint32 _value) {
    _value = poolInfo[_pid].endBlock;
    if (_value > block.number) _value = block.number.toUint32();
  }

  function _lockReward(IERC20Ext token, address _account, uint256 _amount) internal {
    uint256 value = token == IERC20Ext(0) ? _amount : 0;
    rewardLocker.lock{ value: value }(token, _account, _amount);
  }
}