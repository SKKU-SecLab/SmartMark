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
}pragma solidity ^0.5.0;


contract Context is Initializable {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}pragma solidity ^0.5.0;



contract Ownable is Initializable, Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function initialize(address sender) public initializer {

        _owner = sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    uint256[50] private ______gap;
}pragma solidity ^0.5.0;



contract IRewardDistributionRecipient is Ownable {

    address public rewardDistribution;

    function notifyRewardAmount(uint256 reward) external;


    modifier onlyRewardDistribution() {

        require(_msgSender() == rewardDistribution, "Caller is not reward distribution");
        _;
    }

    function setRewardDistribution(address _rewardDistribution)
        external
        onlyOwner
    {

        rewardDistribution = _rewardDistribution;
    }
}pragma solidity ^0.5.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}pragma solidity ^0.5.0;

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
}pragma solidity ^0.5.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}pragma solidity ^0.5.5;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}pragma solidity ^0.5.0;


library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}pragma solidity 0.5.12;



interface ISharesTimeLock {

    function depositByMonths(uint256 amount, uint256 months, address receiver) external;

}


interface IDoughEscrow {

    function balanceOf(address account) external view returns (uint);

    function appendVestingEntry(address account, uint quantity) external;

}



contract RewardEscrow is Ownable {

    using SafeMath for uint;
    using SafeERC20 for IERC20;

    IERC20 public dough;

    mapping(address => bool) public isRewardContract;

    mapping(address => uint[2][]) public vestingSchedules;

    mapping(address => uint) public totalEscrowedAccountBalance;

    mapping(address => uint) public totalVestedAccountBalance;

    uint public totalEscrowedBalance;

    uint constant TIME_INDEX = 0;
    uint constant QUANTITY_INDEX = 1;

    uint constant public MAX_VESTING_ENTRIES = 52*5;

    uint8 public constant decimals = 18;
    string public name;
    string public symbol;

    uint256 public constant STAKE_DURATION = 36;
    ISharesTimeLock public sharesTimeLock;



    function initialize (address _dough, string memory _name, string memory _symbol) public initializer
    {
        dough = IERC20(_dough);
        name = _name;
        symbol = _symbol;
        Ownable.initialize(msg.sender);
    }



    function setDough(address _dough)
    external
    onlyOwner
    {

        dough = IERC20(_dough);
        emit DoughUpdated(address(_dough));
    }

    function setTimelock(address _timelock)
    external
    onlyOwner
    {

        sharesTimeLock = ISharesTimeLock(_timelock);
        emit TimelockUpdated(address(_timelock));
    }

    function addRewardsContract(address _rewardContract) external onlyOwner {

        isRewardContract[_rewardContract] = true;
        emit RewardContractAdded(_rewardContract);
    }

    function removeRewardsContract(address _rewardContract) external onlyOwner {

        isRewardContract[_rewardContract] = false;
        emit RewardContractRemoved(_rewardContract);
    }


    function balanceOf(address account)
    public
    view
    returns (uint)
    {

        return totalEscrowedAccountBalance[account];
    }

    function totalSupply() external view returns (uint256) {

        return totalEscrowedBalance;
    }

    function numVestingEntries(address account)
    public
    view
    returns (uint)
    {

        return vestingSchedules[account].length;
    }

    function getVestingScheduleEntry(address account, uint index)
    public
    view
    returns (uint[2] memory)
    {

        return vestingSchedules[account][index];
    }

    function getVestingTime(address account, uint index)
    public
    view
    returns (uint)
    {

        return getVestingScheduleEntry(account,index)[TIME_INDEX];
    }

    function getVestingQuantity(address account, uint index)
    public
    view
    returns (uint)
    {

        return getVestingScheduleEntry(account,index)[QUANTITY_INDEX];
    }

    function getNextVestingIndex(address account)
    public
    view
    returns (uint)
    {

        uint len = numVestingEntries(account);
        for (uint i = 0; i < len; i++) {
            if (getVestingTime(account, i) != 0) {
                return i;
            }
        }
        return len;
    }

    function getNextVestingEntry(address account)
    public
    view
    returns (uint[2] memory)
    {

        uint index = getNextVestingIndex(account);
        if (index == numVestingEntries(account)) {
            return [uint(0), 0];
        }
        return getVestingScheduleEntry(account, index);
    }

    function getNextVestingTime(address account)
    external
    view
    returns (uint)
    {

        return getNextVestingEntry(account)[TIME_INDEX];
    }

    function getNextVestingQuantity(address account)
    external
    view
    returns (uint)
    {

        return getNextVestingEntry(account)[QUANTITY_INDEX];
    }

    function checkAccountSchedule(address account)
        public
        view
        returns (uint[520] memory)
    {

        uint[520] memory _result;
        uint schedules = numVestingEntries(account);
        for (uint i = 0; i < schedules; i++) {
            uint[2] memory pair = getVestingScheduleEntry(account, i);
            _result[i*2] = pair[0];
            _result[i*2 + 1] = pair[1];
        }
        return _result;
    }



    function appendVestingEntry(address account, uint quantity)
    public
    onlyRewardsContract
    {

        require(quantity != 0, "Quantity cannot be zero");

        totalEscrowedBalance = totalEscrowedBalance.add(quantity);
        require(totalEscrowedBalance <= dough.balanceOf(address(this)), "Must be enough balance in the contract to provide for the vesting entry");

        uint scheduleLength = vestingSchedules[account].length;
        require(scheduleLength <= MAX_VESTING_ENTRIES, "Vesting schedule is too long");

        uint time = now + 52 weeks;

        if (scheduleLength == 0) {
            totalEscrowedAccountBalance[account] = quantity;
        } else {
            require(getVestingTime(account, numVestingEntries(account) - 1) < time, "Cannot add new vested entries earlier than the last one");
            totalEscrowedAccountBalance[account] = totalEscrowedAccountBalance[account].add(quantity);
        }

        if(
            vestingSchedules[account].length != 0 && 
            vestingSchedules[account][vestingSchedules[account].length - 1][0] > time - 1 weeks
        ) {
            vestingSchedules[account][vestingSchedules[account].length - 1][1] = vestingSchedules[account][vestingSchedules[account].length - 1][1].add(quantity);
        } else {
            vestingSchedules[account].push([time, quantity]);
        }
        
        emit Transfer(address(0), account, quantity);
        emit VestingEntryCreated(account, now, quantity);
    }

    function vest()
    external
    {

        uint numEntries = numVestingEntries(msg.sender);
        uint total;
        for (uint i = 0; i < numEntries; i++) {
            uint time = getVestingTime(msg.sender, i);
            if (time > now) {
                break;
            }
            uint qty = getVestingQuantity(msg.sender, i);
            if (qty == 0) {
                continue;
            }

            vestingSchedules[msg.sender][i] = [0, 0];
            total = total.add(qty);
        }

        if (total != 0) {
            totalEscrowedBalance = totalEscrowedBalance.sub(total);
            totalEscrowedAccountBalance[msg.sender] = totalEscrowedAccountBalance[msg.sender].sub(total);
            totalVestedAccountBalance[msg.sender] = totalVestedAccountBalance[msg.sender].add(total);
            dough.safeTransfer(msg.sender, total);
            emit Vested(msg.sender, now, total);
            emit Transfer(msg.sender, address(0), total);
        }
    }

    function migrateToVeDOUGH()
    external
    {

        require(address(sharesTimeLock) != address(0), "SharesTimeLock not set");
        uint numEntries = numVestingEntries(msg.sender); // get the number of entries for msg.sender
        
        uint total;
        for (uint i = 0; i < numEntries; i++) {
            uint[2] memory entry = getVestingScheduleEntry(msg.sender, i);        
            (uint quantity, uint vestingTime) = (entry[QUANTITY_INDEX], entry[TIME_INDEX]);
            
            if(quantity > 0 && vestingTime > 0) {
                uint activationTime = entry[TIME_INDEX].sub(26 weeks); // point in time when the bridge becomes possible (52 weeks - 26 weeks = 26 weeks (6 months))

                if(block.timestamp >= activationTime) {
                    vestingSchedules[msg.sender][i] = [0, 0];
                    total = total.add(quantity);
                }
            }
        }

        require(total > 0, 'No vesting entries to bridge');

        totalEscrowedBalance = totalEscrowedBalance.sub(total);
        totalEscrowedAccountBalance[msg.sender] = totalEscrowedAccountBalance[msg.sender].sub(total);
        totalVestedAccountBalance[msg.sender] = totalVestedAccountBalance[msg.sender].add(total);

        dough.safeApprove(address(sharesTimeLock), 0);
        dough.safeApprove(address(sharesTimeLock), total);

        sharesTimeLock.depositByMonths(total, STAKE_DURATION, msg.sender);

        emit MigratedToVeDOUGH(msg.sender, now, total);
        emit Transfer(msg.sender, address(0), total);
    }


    modifier onlyRewardsContract() {

        require(isRewardContract[msg.sender], "Only reward contract can perform this action");
        _;
    }



    event DoughUpdated(address newDough);

    event TimelockUpdated(address newTimelock);

    event Vested(address indexed beneficiary, uint time, uint value);

    event MigratedToVeDOUGH(address indexed beneficiary, uint time, uint value);

    event VestingEntryCreated(address indexed beneficiary, uint time, uint value);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event RewardContractAdded(address indexed rewardContract);

    event RewardContractRemoved(address indexed rewardContract);

}pragma solidity 0.5.12;


contract LPTokenWrapper {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public uni;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function stake(uint256 amount) public {

        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        uni.safeTransferFrom(msg.sender, address(this), amount);
    }

    function stakeFor(uint256 amount, address beneficiary) public {

        _totalSupply = _totalSupply.add(amount);
        _balances[beneficiary] = _balances[beneficiary].add(amount);
        uni.safeTransferFrom(msg.sender, address(this), amount);
    }

    function withdraw(uint256 amount) public {

        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        uni.safeTransfer(msg.sender, amount);
    }
}

contract ReferralRewards is LPTokenWrapper, IRewardDistributionRecipient {

    IERC20 public dough;
    uint256 public constant DURATION = 7 days;

    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    RewardEscrow public rewardEscrow;
    uint256 public escrowPercentage;

    mapping(address => address) public referralOf;
    uint256 referralPercentage = 1 * 10 ** 16;

    uint8 public constant decimals = 18;
    string public name = "PieDAO staking contract DOUGH/ETH";
    string public symbol = "PieDAO DOUGH/ETH Staking";

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event ReferralSet(address indexed user, address indexed referral);
    event ReferralReward(address indexed user, address indexed referral, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 value);

    modifier updateReward(address account) {

        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    function initialize(
        address _dough,
        address _uni,
        address _rewardEscrow,
        string memory _name, 
        string memory _symbol
    ) public initializer {

        Ownable.initialize(msg.sender);
        dough = IERC20(_dough);
        uni = IERC20 (_uni);
        rewardEscrow = RewardEscrow(_rewardEscrow);
        name = _name;
        symbol = _symbol;
    }

    function lastTimeRewardApplicable() public view returns (uint256) {

        return Math.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view returns (uint256) {

        if (totalSupply() == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored.add(
                lastTimeRewardApplicable()
                    .sub(lastUpdateTime)
                    .mul(rewardRate)
                    .mul(1e18)
                    .div(totalSupply())
            );
    }

    function earned(address account) public view returns (uint256) {

        return
            balanceOf(account)
                .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
                .div(1e18)
                .add(rewards[account]);
    }

    function stake(uint256 amount) public updateReward(msg.sender) {

        require(amount > 0, "Cannot stake 0");
        super.stake(amount);
        emit Transfer(address(0), msg.sender, amount);
        emit Staked(msg.sender, amount);
    }

    function stakeFor(uint256 amount, address beneficiary) public updateReward(beneficiary) {

        require(amount > 0, "Cannot stake 0");
        super.stakeFor(amount, beneficiary);
        emit Transfer(address(0), msg.sender, amount);
        emit Staked(beneficiary, amount);
    }

    function stake(uint256 amount, address referral) public {

        stake(amount);
        
        if(referralOf[msg.sender] == address(0) && referral != msg.sender && referral != address(0)) {
            referralOf[msg.sender] = referral;
            emit ReferralSet(msg.sender, referral);
        }
    }

    function withdraw(uint256 amount) public updateReward(msg.sender) {

        require(amount > 0, "Cannot withdraw 0");
        super.withdraw(amount);
        emit Withdrawn(msg.sender, amount);
        emit Transfer(msg.sender, address(0), amount);
    }

    function exit() external {

        withdraw(balanceOf(msg.sender));
        getReward();
    }

    function getReward() public updateReward(msg.sender) {

        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            rewards[msg.sender] = 0;
            uint256 escrowedReward = reward.mul(escrowPercentage).div(10**18);
            if(escrowedReward != 0) {
                dough.safeTransfer(address(rewardEscrow), escrowedReward);
                rewardEscrow.appendVestingEntry(msg.sender, escrowedReward);
            }

            uint256 nonEscrowedReward = reward.sub(escrowedReward);

            if(nonEscrowedReward != 0) {
                dough.safeTransfer(msg.sender, reward.sub(escrowedReward));
            }
            emit RewardPaid(msg.sender, reward);
        }

        if(referralOf[msg.sender] != address(0)) {
            address referral = referralOf[msg.sender];
            uint256 referralReward = reward.mul(referralPercentage).div(10**18);
            rewards[referral] = rewards[referral].add(referralReward);
            emit ReferralReward(msg.sender, referral, referralReward);
        }
    }

    function notifyRewardAmount(uint256 reward)
        external
        onlyRewardDistribution
        updateReward(address(0))
    {

        if (block.timestamp >= periodFinish) {
            rewardRate = reward.div(DURATION);
        } else {
            uint256 remaining = periodFinish.sub(block.timestamp);
            uint256 leftover = remaining.mul(rewardRate);
            rewardRate = reward.add(leftover).div(DURATION);
        }
        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp.add(DURATION);
        emit RewardAdded(reward);
    }

    function setEscrowPercentage(uint256 _percentage) external onlyRewardDistribution {

        require(_percentage <= 10**18, "100% escrow is the max");
        escrowPercentage = _percentage;
    }

    function saveToken(address _token) external {

        require(_token != address(dough) && _token != address(uni), "INVALID_TOKEN");

        IERC20 token = IERC20(_token);

        token.transfer(address(0x4efD8CEad66bb0fA64C8d53eBE65f31663199C6d), token.balanceOf(address(this)));
    }
}pragma solidity 0.5.12;


contract VestingPusher is Ownable {


    RewardEscrow public rewardEscrow;

    constructor(address _rewardEscrow) public {
        Ownable.initialize(msg.sender);
        rewardEscrow = RewardEscrow(_rewardEscrow);
    }

    function addVesting(address[] calldata _receivers, uint256[] calldata _amounts) external onlyOwner {

        require(_receivers.length == _amounts.length, "ARRAY_LENGTH_MISMATCH");
        
        for(uint256 i = 0; i < _receivers.length; i ++) {
            rewardEscrow.appendVestingEntry(_receivers[i], _amounts[i]);
        }
    }
}pragma solidity ^0.5.0;

library Roles {

    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {

        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}pragma solidity ^0.5.0;



contract MinterRole is Initializable, Context {

    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    function initialize(address sender) public initializer {

        if (!isMinter(sender)) {
            _addMinter(sender);
        }
    }

    modifier onlyMinter() {

        require(isMinter(_msgSender()), "MinterRole: caller does not have the Minter role");
        _;
    }

    function isMinter(address account) public view returns (bool) {

        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {

        _addMinter(account);
    }

    function renounceMinter() public {

        _removeMinter(_msgSender());
    }

    function _addMinter(address account) internal {

        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {

        _minters.remove(account);
        emit MinterRemoved(account);
    }

    uint256[50] private ______gap;
}pragma solidity ^0.5.0;



contract ERC20 is Initializable, Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {

        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }

    uint256[50] private ______gap;
}pragma solidity ^0.5.0;


contract ERC20Mintable is Initializable, ERC20, MinterRole {

    function initialize(address sender) public initializer {

        MinterRole.initialize(sender);
    }

    function mint(address account, uint256 amount) public onlyMinter returns (bool) {

        _mint(account, amount);
        return true;
    }

    uint256[50] private ______gap;
}pragma solidity ^0.5.0;



contract UniMock is ERC20Mintable {

    constructor() public {
        ERC20Mintable.initialize(msg.sender);
    }
}pragma solidity ^0.5.0;



contract DoughMock is ERC20Mintable {

    constructor() public {
        ERC20Mintable.initialize(msg.sender);
    }
}