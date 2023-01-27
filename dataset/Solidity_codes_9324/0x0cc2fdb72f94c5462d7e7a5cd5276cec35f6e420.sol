
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

pragma solidity ^0.6.0;

interface IXAUToken {


    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);


    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns(uint256);

    function transfer(address to, uint256 value) external returns(bool);

    function transferFrom(address from, address to, uint256 value) external returns(bool);

    function allowance(address owner_, address spender) external view returns(uint256);

    function approve(address spender, uint256 value) external returns (bool);


    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);


    event Rebase(uint256 epoch, uint256 oldScalingFactor, uint256 newScalingFactor);
    event NewRebaser(address oldRebaser, address newRebaser);
    function maxScalingFactor() external view returns (uint256);

    function scalingFactor() external view returns (uint256);

    function rebase(uint256 epoch, uint256 indexDelta, bool positive) external returns (uint256);  // onlyRebaser

    function fromUnderlying(uint256 underlying) external view returns (uint256);

    function toUnderlying(uint256 value) external view returns (uint256);

    function balanceOfUnderlying(address who) external view returns(uint256);

    function rebaser() external view returns (address);

    function setRebaser(address _rebaser) external;  // onlyOwner


    event NewTransferHandler(address oldTransferHandler, address newTransferHandler);
    event NewFeeDistributor(address oldFeeDistributor, address newFeeDistributor);
    function transferHandler() external view returns (address);

    function setTransferHandler(address _transferHandler) external;  // onlyOwner

    function feeDistributor() external view returns (address);

    function setFeeDistributor(address _feeDistributor) external;  // onlyOwner


    function recoverERC20(address token, address to, uint256 amount) external returns (bool);  // onlyOwner

}

pragma solidity ^0.6.0;


contract Vault is OwnableUpgradeSafe {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount; // How many  tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below. // elastic, in token underlying units

    }

    struct PoolInfo {
        IERC20 token; // Address of  token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. Reward tokens to distribute per block.
        uint256 accRewardPerShare; // Accumulated token underlying units per share, times 1e12. See below.
        bool withdrawable; // Is this pool withdrawable?
        mapping(address => mapping(address => uint256)) allowance;

    }

    IXAUToken public rewardToken;

    PoolInfo[] public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    uint256 public totalAllocPoint;

    uint256 public pendingRewards;  // elastic, in token underlying units

    uint256 public contractStartBlock;
    uint256 public epochCalculationStartBlock;
    uint256 public cumulativeRewardsSinceStart;  // elastic, in token underlying units
    uint256 public rewardsInThisEpoch;           // elastic, in token underlying units
    uint public epoch;

    address public devFeeReceiver;
    uint16 public devFeePercentX100;
    uint256 public pendingDevRewards;  // elastic, in token underlying units

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

    event NewDevFeeReceiver(address oldDevFeeReceiver, address newDevFeeReceiver);
    event NewDevFeePercentX100(uint256 oldDevFeePercentX100, uint256 newDevFeePercentX100);
    
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount, address indexed to);
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );
    event MigrationWithdraw(
        address indexed user,
        address indexed newVault,
        uint256 amount
    );
    event Approval(address indexed owner, address indexed spender, uint256 _pid, uint256 value);

    function initialize(
        IXAUToken _rewardToken,
        address _devFeeReceiver, 
        uint16 _devFeePercentX100
    ) public initializer {

        OwnableUpgradeSafe.__Ownable_init();
        devFeePercentX100 = _devFeePercentX100;
        rewardToken = _rewardToken;
        devFeeReceiver = _devFeeReceiver;
        contractStartBlock = block.number;
        epochCalculationStartBlock = block.number;
    }

    function poolLength() external view returns (uint256) {

        return poolInfo.length;
    }

    function add(
        uint256 _allocPoint,
        IERC20 _token,
        bool _withUpdate,
        bool _withdrawable
    ) public onlyOwner {

        if (_withUpdate) {
            massUpdatePools();
        }

        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            require(poolInfo[pid].token != _token, "Error pool already added");
        }

        totalAllocPoint = totalAllocPoint.add(_allocPoint);

        poolInfo.push(
            PoolInfo({
                token: _token,
                allocPoint: _allocPoint,
                accRewardPerShare: 0,
                withdrawable: _withdrawable
            })
        );
    }

    function set(
        uint256 _pid,
        uint256 _allocPoint,
        bool _withUpdate
    ) public onlyOwner {

        if (_withUpdate) {
            massUpdatePools();
        }
        
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(
            _allocPoint
        );
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    function setPoolWithdrawable(
        uint256 _pid,
        bool _withdrawable
    ) public onlyOwner {

        poolInfo[_pid].withdrawable = _withdrawable;
    }

    function setDevFeePercentX100(uint16 _devFeePercentX100) public onlyOwner {

        require(_devFeePercentX100 <= 1000, 'Dev fee clamped at 10%');
        uint256 oldDevFeePercentX100 = devFeePercentX100;
        devFeePercentX100 = _devFeePercentX100;
        emit NewDevFeePercentX100(oldDevFeePercentX100, _devFeePercentX100);
    }

    function setDevFeeReceiver(address _devFeeReceiver) public onlyOwner {

        address oldDevFeeReceiver = devFeeReceiver;
        devFeeReceiver = _devFeeReceiver;
        emit NewDevFeeReceiver(oldDevFeeReceiver, _devFeeReceiver);
    }

    function pendingToken(uint256 _pid, address _user)
        public
        view
        returns (uint256)
    {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accRewardPerShare = pool.accRewardPerShare;
        
        return rewardToken.fromUnderlying(user.amount.mul(accRewardPerShare).div(1e12).sub(user.rewardDebt));
    }

    function pendingTokenActual(uint256 _pid, address _user) public view returns (uint256) {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 tokenSupply = pool.token.balanceOf(address(this));
        if (tokenSupply == 0) { // avoids division by 0 errors
            return 0;
        }
        uint256 rewardWhole = pendingRewards // Multiplies pending rewards by allocation point of this pool and then total allocation
            .mul(pool.allocPoint)        // getting the percent of total pending rewards this pool should get
            .div(totalAllocPoint);       // we can do this because pools are only mass updated
        uint256 rewardFee = rewardWhole.mul(devFeePercentX100).div(10000);
        uint256 rewardToDistribute = rewardWhole.sub(rewardFee);
        uint256 accRewardPerShare = pool.accRewardPerShare.add(rewardToDistribute.mul(1e12).div(tokenSupply));

        return rewardToken.fromUnderlying(user.amount.mul(accRewardPerShare).div(1e12).sub(user.rewardDebt));
    }

    function massUpdatePools() public {

        uint256 length = poolInfo.length;
        uint allRewards;
        for (uint256 pid = 0; pid < length; ++pid) {
            allRewards = allRewards.add(updatePool(pid));
        }

        pendingRewards = pendingRewards.sub(allRewards);
    }

    uint256 private rewardTokenBalance;
    function addPendingRewards(uint256 /* _ */) public {

        uint256 newRewards = rewardToken.balanceOfUnderlying(address(this)).sub(rewardTokenBalance);  // elastic
        
        if (newRewards > 0) {
            rewardTokenBalance = rewardToken.balanceOfUnderlying(address(this)); // If there is no change the balance didn't change  // elastic
            pendingRewards = pendingRewards.add(newRewards);
            rewardsInThisEpoch = rewardsInThisEpoch.add(newRewards);
        }
    }

    function updatePool(uint256 _pid) internal returns (uint256 rewardWhole) {

        PoolInfo storage pool = poolInfo[_pid];

        uint256 tokenSupply = pool.token.balanceOf(address(this));
        if (tokenSupply == 0) { // avoids division by 0 errors
            return 0;
        }
        rewardWhole = pendingRewards // Multiplies pending rewards by allocation point of this pool and then total allocation
            .mul(pool.allocPoint)        // getting the percent of total pending rewards this pool should get
            .div(totalAllocPoint);       // we can do this because pools are only mass updated
        uint256 rewardFee = rewardWhole.mul(devFeePercentX100).div(10000);
        uint256 rewardToDistribute = rewardWhole.sub(rewardFee);

        pendingDevRewards = pendingDevRewards.add(rewardFee);

        pool.accRewardPerShare = pool.accRewardPerShare.add(
            rewardToDistribute.mul(1e12).div(tokenSupply)
        );
    }

    function deposit(uint256 _pid, uint256 _amount) public {


        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        massUpdatePools();
        
        updateAndPayOutPending(_pid, msg.sender); // https://kovan.etherscan.io/tx/0xbd6a42d7ca389be178a2e825b7a242d60189abcfbea3e4276598c0bb28c143c9 // TODO: INVESTIGATE



        if (_amount > 0) {
            pool.token.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);
        }

        user.rewardDebt = user.amount.mul(pool.accRewardPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }

    function depositFor(address _depositFor, uint256 _pid, uint256 _amount) public {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_depositFor];

        massUpdatePools();
        
        updateAndPayOutPending(_pid, _depositFor);  // Update the balances of person that amount is being deposited for

        if (_amount > 0) {
            pool.token.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);  // This is depositedFor address
        }

        user.rewardDebt = user.amount.mul(pool.accRewardPerShare).div(1e12);  /// This is deposited for address
        emit Deposit(_depositFor, _pid, _amount);
    }

    function setAllowanceForPoolToken(address spender, uint256 _pid, uint256 value) public {

        PoolInfo storage pool = poolInfo[_pid];
        pool.allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, _pid, value);
    }

    function withdrawFrom(address owner, uint256 _pid, uint256 _amount) public {

        
        PoolInfo storage pool = poolInfo[_pid];
        require(pool.allowance[owner][msg.sender] >= _amount, "withdraw: insufficient allowance");
        pool.allowance[owner][msg.sender] = pool.allowance[owner][msg.sender].sub(_amount);
        _withdraw(_pid, _amount, owner, msg.sender);

    }
    
    function withdraw(uint256 _pid, uint256 _amount) public {


        _withdraw(_pid, _amount, msg.sender, msg.sender);

    }
    
    function _withdraw(uint256 _pid, uint256 _amount, address from, address to) internal {

        PoolInfo storage pool = poolInfo[_pid];
        require(pool.withdrawable, "Withdrawing from this pool is disabled");
        UserInfo storage user = userInfo[_pid][from];
        require(user.amount >= _amount, "withdraw: not good");

        massUpdatePools();
        updateAndPayOutPending(_pid, from); // Update balances of from this is not withdrawal but claiming rewards farmed

        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.token.safeTransfer(address(to), _amount);
        }
        user.rewardDebt = user.amount.mul(pool.accRewardPerShare).div(1e12);

        emit Withdraw(to, _pid, _amount);
    }

    function updateAndPayOutPending(uint256 _pid, address from) internal {


        uint256 pending = pendingToken(_pid, from);

        if (pending > 0) {
            safeRewardTokenTransfer(from, pending);
        }
    }

    function setStrategyContractOrDistributionContractAllowance(address tokenAddress, uint256 _amount, address contractAddress) public onlyOwner {

        require(isContract(contractAddress), "Recipent is not a smart contract");
        require(tokenAddress != address(rewardToken), "Reward token allowance not allowed");
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; pid++) {
            require(tokenAddress != address(poolInfo[pid].token), "Pool token allowance not allowed");
        }

        IERC20(tokenAddress).approve(contractAddress, _amount);
    }

    function isContract(address addr) internal view returns (bool) {

        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function migrateTokensToNewVault(address _newVault) public virtual onlyOwner {

        require(_newVault != address(0), "Vault: new vault is the zero address");
        uint256 rewardTokenBalErc = rewardToken.balanceOf(address(this));  // elastic
        safeRewardTokenTransfer(_newVault, rewardTokenBalErc);
        emit MigrationWithdraw(msg.sender, _newVault, rewardTokenBalErc);
        rewardTokenBalance = rewardToken.balanceOfUnderlying(address(this));
    }

    function emergencyWithdraw(uint256 _pid, address _to) public {

        PoolInfo storage pool = poolInfo[_pid];
        require(pool.withdrawable, "Withdrawing from this pool is disabled");
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 amount = user.amount;
        if (amount > 0) {
            pool.token.safeTransfer(_to, amount);
            user.amount = 0;
            user.rewardDebt = 0;
        }
        emit EmergencyWithdraw(msg.sender, _pid, amount, _to);
    }

    function safeRewardTokenTransfer(address _to, uint256 _amount) internal {


        uint256 rewardTokenBalErc = rewardToken.balanceOf(address(this));  // elastic
        
        if (_amount > rewardTokenBalErc) {
            rewardToken.transfer(_to, rewardTokenBalErc);  // elastic
            rewardTokenBalance = rewardToken.balanceOfUnderlying(address(this));  // elastic

        } else {
            rewardToken.transfer(_to, _amount);  // elastic
            rewardTokenBalance = rewardToken.balanceOfUnderlying(address(this));  // elastic

        }
        transferDevFee();

    }

    function transferDevFee() public {

        if (pendingDevRewards == 0) return;

        uint256 pendingDevRewardsErc = rewardToken.fromUnderlying(pendingDevRewards);
        uint256 rewardTokenBalErc = rewardToken.balanceOf(address(this));  // elastic
        
        if (pendingDevRewardsErc > rewardTokenBalErc) {

            rewardToken.transfer(devFeeReceiver, rewardTokenBalErc);  // elastic
            rewardTokenBalance = rewardToken.balanceOfUnderlying(address(this));  // elastic

        } else {

            rewardToken.transfer(devFeeReceiver, pendingDevRewardsErc);  // elastic
            rewardTokenBalance = rewardToken.balanceOfUnderlying(address(this));  // elastic

        }

        pendingDevRewards = 0;
    }

}
