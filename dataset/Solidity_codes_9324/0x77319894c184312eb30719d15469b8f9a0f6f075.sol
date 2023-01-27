
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

pragma solidity ^0.6.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
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

        (bool success, bytes memory returndata) = target.call.value(weiValue)(data);
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


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
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
}// MIT
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
}// MIT
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
}// MIT

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;


contract VaultAdu is OwnableUpgradeSafe {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount; // How many  tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.

    }

    struct PoolInfo {
        IERC20 token; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. ADUs to distribute per block.
        uint256 accRewardPerShare; // Accumulated token underlying units per share, times 1e12. See below.
        uint256 lastRewardBlock;
    }

    IERC20 public rewardToken;

    PoolInfo[] public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    uint256 public totalAllocPoint;

    uint256 public contractStartBlock;
    uint256 public epochCalculationStartBlock;
    uint256 public cumulativeRewardsSinceStart;
    uint256 public rewardsInThisEpoch;
    uint public epoch;

    uint256 public rewardPerBlock;

    function averageRewardPerBlockSinceStart() external view returns (uint averagePerBlock) {

        averagePerBlock = cumulativeRewardsSinceStart.add(rewardsInThisEpoch).div(block.number.sub(contractStartBlock));
    }        

    function averageRewardPerBlockEpoch() external view returns (uint256 averagePerBlock) {

        averagePerBlock = rewardsInThisEpoch.div(block.number.sub(epochCalculationStartBlock));
    }

    mapping(uint => uint256) public epochRewards;

    function startNewEpoch() public {

        require(epochCalculationStartBlock + 50000 < block.number, "New epoch not ready yet"); // About a week
        epochRewards[epoch] = rewardsInThisEpoch;
        cumulativeRewardsSinceStart = cumulativeRewardsSinceStart.add(rewardsInThisEpoch);
        rewardsInThisEpoch = 0;
        epochCalculationStartBlock = block.number;
        ++epoch;
    }

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount, address indexed to);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount, address indexed to);
    event LogUpdatePool(uint256 indexed pid, uint256 lastRewardBlock, uint256 lpSupply, uint256 accRewardPerShare);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount, address indexed to);
    event MigrationWithdraw(address indexed user, address indexed newVault, uint256 amount);
    event Harvest(address indexed user, uint256 indexed pid, uint256 amount);

    function initialize(
        IERC20 _rewardToken,
        uint256 _rewardPerBlock
    ) public initializer {

        OwnableUpgradeSafe.__Ownable_init();
        rewardToken = _rewardToken;
        contractStartBlock = block.number;
        epochCalculationStartBlock = block.number;
        rewardPerBlock = _rewardPerBlock;
    }

    function poolLength() external view returns (uint256) {

        return poolInfo.length;
    }

    function add(uint256 _allocPoint, IERC20 _token) public onlyOwner {

        uint256 length = poolInfo.length;
        uint256 lastRewardBlock = block.number;
        for (uint256 pid = 0; pid < length; ++pid) {
            require(poolInfo[pid].token != _token,"Error pool already added");
        }
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(
            PoolInfo({
                token: _token,
                allocPoint: _allocPoint,
                accRewardPerShare: 0,
                lastRewardBlock : lastRewardBlock
            })
        );
    }

    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate) public onlyOwner {

        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    function pendingToken(uint256 _pid, address _user) public view returns (uint256 pending) {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accRewardPerShare = pool.accRewardPerShare;
        pending = user.amount.mul(accRewardPerShare).div(1e12).sub(user.rewardDebt); // return calculated pending reward
    }

    function pendingTokenActual(uint256 _pid, address _user) public view returns (uint256) {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accRewardPerShare = pool.accRewardPerShare;
        if (block.number > pool.lastRewardBlock) {
            uint256 lpSupply = pool.token.balanceOf(address(this));
            if (lpSupply > 0) { // avoids division by 0 errors
                uint256 blocks = block.number.sub(pool.lastRewardBlock);
                uint256 aduReward = blocks.mul(rewardPerBlock).mul(pool.allocPoint).div(totalAllocPoint); // eg. 4blocks * 1e20 * 100allocPoint / 100totalAllocPoint
                accRewardPerShare = pool.accRewardPerShare.add((aduReward.mul(1e12).div(lpSupply)));
            }
        }

        return user.amount.mul(accRewardPerShare).div(1e12).sub(user.rewardDebt); // return calculated pending reward
    }

    function massUpdatePools() public {

        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    function updatePool(uint256 _pid) public returns (PoolInfo memory pool) {

        pool = poolInfo[_pid];

        if (block.number > pool.lastRewardBlock) {
            uint256 lpSupply = pool.token.balanceOf(address(this));
            if (lpSupply > 0) { // avoids division by 0 errors
                uint256 blocks = block.number.sub(pool.lastRewardBlock);
                uint256 aduReward = blocks.mul(rewardPerBlock).mul(pool.allocPoint).div(totalAllocPoint); // eg. 4blocks * 1e20 * 100allocPoint / 100totalAllocPoint
                pool.accRewardPerShare = pool.accRewardPerShare.add((aduReward.mul(1e12).div(lpSupply)));
            }
            pool.lastRewardBlock = block.number;
            poolInfo[_pid] = pool;
            emit LogUpdatePool(_pid, pool.lastRewardBlock, lpSupply, pool.accRewardPerShare);
        }
    }

    function deposit(uint256 _pid, uint256 _amount) public {

        depositFor(_pid, _amount, msg.sender);
    }

    function depositFor(uint256 _pid, uint256 _amount, address _to) public {

        PoolInfo memory pool = updatePool(_pid);
        UserInfo storage user = userInfo[_pid][_to];

        massUpdatePools();
        updateAndPayOutPending(_pid, _to);

        if (_amount > 0) {
            pool.token.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accRewardPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount, _to);
    }

    function withdraw(uint256 _pid, uint256 _amount) public {

        withdrawTo(_pid, _amount, msg.sender);
    }

    function withdrawTo(uint256 _pid, uint256 _amount, address _to) public {

        PoolInfo memory pool = updatePool(_pid);
        UserInfo storage user = userInfo[_pid][msg.sender];

        massUpdatePools();
        updateAndPayOutPending(_pid, msg.sender);

        if (_amount > 0) {
            pool.token.safeTransfer(_to, _amount);
            user.amount = user.amount.sub(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accRewardPerShare).div(1e12);
        emit Withdraw(msg.sender, _pid, _amount, _to);
    }

    function updateAndPayOutPending(uint256 _pid, address _to) internal {

        uint256 pending = pendingToken(_pid, _to);
        if (pending > 0) {
            safeRewardTokenTransfer(_to, pending);
        }
    }

    function harvest(uint256 _pid) public returns (bool success) {

        return harvestTo(_pid, msg.sender);
    }

    function harvestTo(uint256 _pid, address _to) public returns (bool success) {

        uint256 _pendingToken = pendingToken(_pid, _to);
        withdrawTo(_pid, 0, _to);
        emit Harvest(msg.sender, _pid, _pendingToken);
        return true;
    }

    function safeRewardTokenTransfer(address _to, uint256 _amount) internal {

        uint256 aduBalance = rewardToken.balanceOf(address(this));
        if (aduBalance > 0){
            if (_amount > aduBalance) {
                rewardToken.transfer(_to, aduBalance);
            } else {
                rewardToken.transfer(_to, _amount);
            }
        }
    }

    function migrateTokensToNewVault(address _newVault) public virtual onlyOwner {

        require(_newVault != address(0), "Vault: new vault is the zero address");
        uint256 rewardTokenBalErc = rewardToken.balanceOf(address(this));
        safeRewardTokenTransfer(_newVault, rewardTokenBalErc);
        emit MigrationWithdraw(msg.sender, _newVault, rewardTokenBalErc);
    }

    function emergencyWithdraw(uint256 _pid, address _to) public {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 amount = user.amount;
        if (amount > 0) {
            pool.token.safeTransfer(_to, amount);
            user.amount = 0;
            user.rewardDebt = 0;
        }
        emit EmergencyWithdraw(msg.sender, _pid, amount, _to);
    }

    function setStrategyContractOrDistributionContractAllowance(address tokenAddress, uint256 _amount, address contractAddress) public onlyOwner {

        require(isContract(contractAddress), "Recipent is not a smart contract");
        require(tokenAddress != address(rewardToken), "Vault token allowance not allowed");
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; pid++) {
            require(tokenAddress != address(poolInfo[pid].token), "Vault pool token allowance not allowed");
        }

        IERC20(tokenAddress).approve(contractAddress, _amount);
    }

    function isContract(address addr) internal view returns (bool) {

        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

}