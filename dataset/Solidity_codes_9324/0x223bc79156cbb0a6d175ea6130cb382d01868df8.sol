
pragma solidity 0.6.12;


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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
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
}

interface IMigratorToChadSwap {

    function migrate(IERC20 token) external returns (IERC20);

}

interface IStacyVaultRewardsLock {

    function lock(address _holder, uint256 _amount) external; 

    function lockToBlock() external returns (uint256);

}

contract StacyVault is Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount; // How many  tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256 lastDepositBlock;
    }

    struct PoolInfo {
        IERC20 token; // Address of  token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. STACYs to distribute per block.
        uint256 accStacyPerShare; // Accumulated STACYs per share, times 1e12. See below.
        bool withdrawable; // Is this pool withdrawable?
        mapping(address => mapping(address => uint256)) allowance;
    }

    IERC20 public stacy;
    address public devaddr;

    IStacyVaultRewardsLock public rewardsLock;

    PoolInfo[] public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    uint256 public totalAllocPoint;

    uint256 public pendingRewards;

    uint256 public contractStartBlock;
    uint256 public epochCalculationStartBlock;
    uint256 public cumulativeRewardsSinceStart;
    uint256 public rewardsInThisEpoch;
    uint public epoch;

    uint256 public constant PERCENT_LOCK_BONUS_REWARD = 75; // lock 75% of bonus reward

    function averageFeesPerBlockSinceStart() external view returns (uint averagePerBlock) {

        averagePerBlock = cumulativeRewardsSinceStart.add(rewardsInThisEpoch).div(block.number.sub(contractStartBlock));
    }        

    function averageFeesPerBlockEpoch() external view returns (uint256 averagePerBlock) {

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

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );
    event Approval(address indexed owner, address indexed spender, uint256 _pid, uint256 value);

    constructor(
        IERC20 _stacy,
        IStacyVaultRewardsLock _rewardsLock,
        address _devaddr, 
        address superAdmin
    )
    public
    Ownable() 
    {
        DEV_FEE = 500; // 5% (of the burn %)
        stacy = _stacy;
        rewardsLock = _rewardsLock;
        devaddr = _devaddr;
        contractStartBlock = block.number;
        _superAdmin = superAdmin;
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
            require(poolInfo[pid].token != _token,"Error pool already added");
        }

        totalAllocPoint = totalAllocPoint.add(_allocPoint);

        poolInfo.push(
            PoolInfo({
                token: _token,
                allocPoint: _allocPoint,
                accStacyPerShare: 0,
                withdrawable : _withdrawable
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

    function setRewardsLock(IStacyVaultRewardsLock _rewardsLock) public onlyOwner {

        rewardsLock = _rewardsLock;
    }

    uint16 DEV_FEE;
    function setDevFee(uint16 _DEV_FEE) public onlyOwner {

        require(_DEV_FEE <= 1000, 'Dev fee clamped at 10%');
        DEV_FEE = _DEV_FEE;
    }
    uint256 pending_DEV_rewards;


    function pendingStacy(uint256 _pid, address _user)
        public
        view
        returns (uint256)
    {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accStacyPerShare = pool.accStacyPerShare;

        return user.amount.mul(accStacyPerShare).div(1e12).sub(user.rewardDebt);
    }

    function massUpdatePools() public {

        uint256 length = poolInfo.length;
        uint allRewards;
        for (uint256 pid = 0; pid < length; ++pid) {
            allRewards = allRewards.add(updatePool(pid));
        }

        pendingRewards = pendingRewards.sub(allRewards);
    }

    uint256 private stacyBalance;
    function addPendingRewards(uint256 _) public {

        uint256 newRewards = stacy.balanceOf(address(this)).sub(stacyBalance);
        
        if (newRewards > 0) {
            stacyBalance = stacy.balanceOf(address(this)); // If there is no change the balance didn't change
            pendingRewards = pendingRewards.add(newRewards);
            rewardsInThisEpoch = rewardsInThisEpoch.add(newRewards);
        }
    }

    function updatePool(uint256 _pid) internal returns (uint256 stacyRewardWhole) {

        PoolInfo storage pool = poolInfo[_pid];

        uint256 tokenSupply = pool.token.balanceOf(address(this));
        if (tokenSupply == 0) { // avoids division by 0 errors
            return 0;
        }
        stacyRewardWhole = pendingRewards // Multiplies pending rewards by allocation point of this pool and then total allocation
            .mul(pool.allocPoint)        // getting the percent of total pending rewards this pool should get
            .div(totalAllocPoint);       // we can do this because pools are only mass updated
        uint256 stacyRewardFee = stacyRewardWhole.mul(DEV_FEE).div(10000);
        uint256 stacyRewardToDistribute = stacyRewardWhole.sub(stacyRewardFee);

        pending_DEV_rewards = pending_DEV_rewards.add(stacyRewardFee);

        pool.accStacyPerShare = pool.accStacyPerShare.add(
            stacyRewardToDistribute.mul(1e12).div(tokenSupply)
        );
    }

    function deposit(uint256 _pid, uint256 _amount) public {


        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        massUpdatePools();
        
        updateAndPayOutPending(_pid, msg.sender);

        if (_amount > 0) {
            pool.token.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);
        }


        user.rewardDebt = user.amount.mul(pool.accStacyPerShare).div(1e12);
        user.lastDepositBlock = block.number;
        emit Deposit(msg.sender, _pid, _amount);
    }

    function depositFor(address depositForAddress, uint256 _pid, uint256 _amount) public {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][depositForAddress];

        massUpdatePools();
        
        updateAndPayOutPending(_pid, depositForAddress); // Update the balances of person that amount is being deposited for

        if(_amount > 0) {
            pool.token.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount); // This is depositedFor address
        }

        user.rewardDebt = user.amount.mul(pool.accStacyPerShare).div(1e12); /// This is deposited for address
        emit Deposit(depositForAddress, _pid, _amount);

    }

    function setAllowanceForPoolToken(address spender, uint256 _pid, uint256 value) public {

        PoolInfo storage pool = poolInfo[_pid];
        pool.allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, _pid, value);
    }

    function withdrawFrom(address owner, uint256 _pid, uint256 _amount) public{

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
        require(block.number > user.lastDepositBlock, "withdraw: same block as deposit");

        massUpdatePools();
        updateAndPayOutPending(_pid, from); // Update balances of from this is not withdrawal but claiming STACY farmed

        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.token.safeTransfer(address(to), _amount);
        }
        user.rewardDebt = user.amount.mul(pool.accStacyPerShare).div(1e12);

        emit Withdraw(to, _pid, _amount);
    }

    function emergencyWithdraw(uint256 _pid) public {

        PoolInfo storage pool = poolInfo[_pid];
        require(pool.withdrawable, "Withdrawing from this pool is disabled");
        UserInfo storage user = userInfo[_pid][msg.sender];
        pool.token.safeTransfer(address(msg.sender), user.amount);
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
    }    

    function updateAndPayOutPending(uint256 _pid, address _addr) internal {

        uint256 pending = pendingStacy(_pid, _addr);

        if (pending > 0) {
            uint256 stacyBal = stacy.balanceOf(address(this));
            uint256 availableAmountToTransfer = pending > stacyBal ? stacyBal : pending;


            uint256 lockAmount = availableAmountToTransfer.mul(PERCENT_LOCK_BONUS_REWARD).div(100);

            stacy.transfer(_addr, availableAmountToTransfer.sub(lockAmount));

            stacy.safeApprove(address(rewardsLock), lockAmount);
            rewardsLock.lock(_addr, lockAmount);
            stacy.safeApprove(address(rewardsLock), 0);

            stacyBalance = stacy.balanceOf(address(this));

            transferDevFee();
        }
    }

    function setStrategyContractOrDistributionContractAllowance(address tokenAddress, uint256 _amount, address contractAddress) public onlySuperAdmin {

        require(isContract(contractAddress), "Recipent is not a smart contract, BAD");
        require(block.number > contractStartBlock.add(95_000), "Governance setup grace period not over"); // about 2weeks
        IERC20(tokenAddress).approve(contractAddress, _amount);
    }

    function isContract(address addr) public returns (bool) {

        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function safeStacyTransfer(address _to, uint256 _amount) internal returns (uint256 amountToTransfer) {

        uint256 stacyBal = stacy.balanceOf(address(this));

        amountToTransfer = _amount > stacyBal ? stacyBal : _amount;
        stacy.transfer(_to, amountToTransfer);
        stacyBalance = stacy.balanceOf(address(this));

        transferDevFee();

        return amountToTransfer;
    }

    function transferDevFee() public {

        if (pending_DEV_rewards == 0) {
            return;
        }

        uint256 stacyBal = stacy.balanceOf(address(this));
        if (pending_DEV_rewards > stacyBal) {
            stacy.transfer(devaddr, stacyBal);
            stacyBalance = stacy.balanceOf(address(this));
        } else {
            stacy.transfer(devaddr, pending_DEV_rewards);
            stacyBalance = stacy.balanceOf(address(this));
        }

        pending_DEV_rewards = 0;
    }

    function setDevFeeReciever(address _devaddr) public onlyOwner {

        devaddr = _devaddr;
    }

    address private _superAdmin;

    event SuperAdminTransfered(address indexed previousOwner, address indexed newOwner);

    function superAdmin() public view returns (address) {

        return _superAdmin;
    }

    modifier onlySuperAdmin() {

        require(_superAdmin == _msgSender(), "Super admin : caller is not super admin.");
        _;
    }

    function burnSuperAdmin() public virtual onlySuperAdmin {

        emit SuperAdminTransfered(_superAdmin, address(0));
        _superAdmin = address(0);
    }

    function newSuperAdmin(address newOwner) public virtual onlySuperAdmin {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit SuperAdminTransfered(_superAdmin, newOwner);
        _superAdmin = newOwner;
    }


    IMigratorToChadSwap public migrator;

    function setMigrator(IMigratorToChadSwap _migrator) public onlyOwner {

        migrator = _migrator;
    }

    function migrate(uint256 _pid) public {

        require(address(migrator) != address(0), "migrate: no migrator");
        PoolInfo storage pool = poolInfo[_pid];
        IERC20 lpToken = pool.token;
        uint256 bal = lpToken.balanceOf(address(this));
        lpToken.safeApprove(address(migrator), bal);
        IERC20 newLpToken = migrator.migrate(lpToken);
        require(bal == newLpToken.balanceOf(address(this)), "migrate: bad");
        pool.token = newLpToken;
    }
}