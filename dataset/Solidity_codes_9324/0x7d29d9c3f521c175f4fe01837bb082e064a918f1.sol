
pragma solidity ^0.7.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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

contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

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

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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

contract NovaToken is ERC20("NOVA", "NOVA"), Ownable {
    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
    }
}

contract MasterUniverse is Ownable {
    using SafeMath for uint256;
    using SafeMath for uint8;
    using SafeERC20 for IERC20;

    address private constant GUARD = address(0);

    struct UserInfo {
        uint256 lastStakedTime;
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        address next;
    }

    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. NOVAs to distribute per block.
        uint256 lastRewardBlock; // Last block number that NOVAs distribution occurs.
        uint256 accNovaPerShare; // Accumulated NOVAs per share, times 1e12. See below.
        uint256 totalLpStaked; // Total Amount of LP Tokens Staked.
        uint256 startTimestamp; // Timestamp of the pool start
        uint256 totalPlasma; // cached totalPlasma calcul - too much gas consumption
    }

    NovaToken public nova;
    address public devaddr;
    uint256 public bonusEndBlock;
    uint256 public novaPerBlock;
    uint256 public constant BONUS_MULTIPLIER = 2;
    PoolInfo[] public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    uint256 public totalAllocPoint = 0;
    uint256 public startBlock;
    uint256 public startTimestamp;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );

    constructor(
        NovaToken _nova,
        address _devaddr,
        uint256 _novaPerBlock,
        uint256 _startBlock,
        uint256 _bonusEndBlock
    ) {
        nova = _nova;
        devaddr = _devaddr;
        novaPerBlock = _novaPerBlock;
        bonusEndBlock = _bonusEndBlock;
        startBlock = _startBlock;
        startTimestamp = block.timestamp;
    }

    function poolLength() public view returns (uint256) {
        return poolInfo.length;
    }

    function add(
        uint256 _allocPoint,
        IERC20 _lpToken,
        bool _withUpdate
    ) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock
            ? block.number
            : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                allocPoint: _allocPoint,
                lastRewardBlock: lastRewardBlock,
                accNovaPerShare: 0,
                totalLpStaked: 0,
                startTimestamp: block.timestamp,
                totalPlasma: 0
            })
        );
    }

    enum Range {Unknown, Tiny, Common}

    uint256 private constant tinyLimit = 10;
    uint256 private constant commonLimit = 100;
    uint256 private constant scaleUp = 10000;

    function maxBuffRate(uint256 _pid,address _user)
        public
        view
        returns (uint16)
    {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        require(pool.totalLpStaked > 0, "0 div");
        uint256 percentage = user.amount.mul(scaleUp).div(
            pool.totalLpStaked
        );

        if (percentage <= tinyLimit) {
            return 90;
        } else if (percentage > tinyLimit && percentage < commonLimit) {
            return 150;
        } else if (percentage >= commonLimit) {
            return 40;
        }

        revert("bad");
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

    function getMultiplier(uint256 _from, uint256 _to)
        public
        view
        returns (uint256)
    {
        if (_to <= bonusEndBlock) {
            return _to.sub(_from).mul(BONUS_MULTIPLIER);
        } else if (_from >= bonusEndBlock) {
            return _to.sub(_from);
        } else {
            return
                bonusEndBlock.sub(_from).mul(BONUS_MULTIPLIER).add(
                    _to.sub(bonusEndBlock)
                );
        }
    }

    function calculateBuffRate(
        uint256 _pid,
        address _user,
        uint256 _now_
    ) public
      view
      returns (uint16) {
        UserInfo storage user = userInfo[_pid][_user];
        uint16 buffRate = 10;
        for (
            uint256 d = user.lastStakedTime;
            d + 1 days <= _now_;
            d += 1 days
        ) {
            buffRate += (buffRate * 50) / 100;
        }

        uint16 max = maxBuffRate(_pid, _user);
        if(buffRate > max){
            buffRate = max;
        }
        return buffRate;
    }

    function calculateNovaPerBlock() public view returns (uint256)
    {
        uint currentTimestamp = block.timestamp; 
        uint daysSinceStartStaking = (currentTimestamp - startTimestamp).mul(100).div(60).div(60).div(24);
        uint8 halvingDiv = 0;

        if(daysSinceStartStaking >= 15000){
            return 0;
        }

        if(daysSinceStartStaking >= 7000){
            halvingDiv = 8;
        } else if(daysSinceStartStaking >= 3000){
            halvingDiv = 4;
        } else if(daysSinceStartStaking >= 1000){
            halvingDiv = 2;
        } 

        uint256 novaPerBlockNow = novaPerBlock;
        if (halvingDiv > 0){
            novaPerBlockNow = novaPerBlockNow.div(halvingDiv);
        }

        return novaPerBlockNow;
    }

    function plasmaPower(
        uint256 _pid,
        address _user,
        uint256 _now_
    ) private
      view
      returns (uint256) {
        UserInfo storage user = userInfo[_pid][_user];
        uint16 buffRate = calculateBuffRate(_pid, _user, _now_);
        return user.amount.mul(buffRate);
    }

    function totalPlasmaPower(uint256 _pid)
        public
        view
        returns (uint256)
    {
        uint256 total;
        uint256 _now_ = block.timestamp;

        for (
            address iter = userInfo[_pid][GUARD].next;
            iter != GUARD;
            iter = userInfo[_pid][iter].next
        ) {
            if(userInfo[_pid][iter].amount == 0) continue;
            total += plasmaPower(_pid, iter, _now_);
        }

        return total;
    }

    function pendingNova(uint256 _pid, address _user)
        public
        view
        returns (uint256)
    {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accNovaPerShare = pool.accNovaPerShare;
        uint256 plasma = plasmaPower(_pid, _user, block.timestamp);

        if (block.number > pool.lastRewardBlock && pool.totalPlasma > 0) {
            uint256 multiplier = getMultiplier(
                pool.lastRewardBlock,
                block.number
            );
            uint256 novaReward = multiplier
                .mul(calculateNovaPerBlock())
                .mul(pool.allocPoint)
                .div(totalAllocPoint);

            accNovaPerShare = accNovaPerShare.add(
                novaReward.mul(1e12).div(pool.totalPlasma)
            );
        }

        return plasma.mul(accNovaPerShare).div(1e12).sub(user.rewardDebt);
    }

    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    function calculateFeesPercentage(uint256 _pid, address _user)
        public
        view
        returns (uint256)
    {
        UserInfo storage user = userInfo[_pid][_user];
        uint currentTimestamp = block.timestamp; 
        uint daysSinceStartStaking = (currentTimestamp - user.lastStakedTime).div(60).div(60).div(24);
        uint feesPercentage = max(30 - daysSinceStartStaking.div(2), 1); // -0.5% by day - start to 30, and min to 1
        return feesPercentage;
    }

    function max(uint a, uint b) private pure returns (uint) {
        return a > b ? a : b;
    }

    function updatePool(uint256 _pid) private {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 novaReward = multiplier
            .mul(calculateNovaPerBlock())
            .mul(pool.allocPoint)
            .div(totalAllocPoint);
        nova.mint(devaddr, novaReward.div(10));
        nova.mint(address(this), novaReward);
        uint256 totalPlasma = totalPlasmaPower(_pid);
        pool.totalPlasma = totalPlasma;
        pool.accNovaPerShare = pool.accNovaPerShare.add(
            novaReward.mul(1e12).div(totalPlasma)
        );
        pool.lastRewardBlock = block.number;
    }

    function deposit(uint256 _pid, uint256 _amount) external {
        require(_pid < poolLength(), "bad pid");
        require(_amount > 0, "amount could'n be 0");

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        updatePool(_pid);

        if (user.amount == 0) {
            user.lastStakedTime = block.timestamp; 
            user.next = userInfo[_pid][GUARD].next;
            userInfo[_pid][GUARD].next = msg.sender;
        }

        if (user.amount > 0 && block.number > bonusEndBlock) {
            uint256 pending = pendingNova(_pid, msg.sender);
            if (pending > 0) {
                uint feesPercentage = calculateFeesPercentage(_pid, msg.sender);
                uint256 fees = pending.mul(feesPercentage).div(100);
                uint256 gain = pending.sub(fees);
                safeNovaTransfer(devaddr, fees);
                safeNovaTransfer(msg.sender, gain);
            }
        }

        if (_amount > 0) {
            user.amount = user.amount.add(_amount);
            pool.lpToken.safeTransferFrom(
                address(msg.sender),
                address(this),
                _amount
            );
        }

        pool.totalLpStaked = pool.totalLpStaked.add(_amount);
        uint256 plasma = plasmaPower(_pid, msg.sender, block.timestamp);
        user.rewardDebt = plasma.mul(pool.accNovaPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }

    function withdraw(uint256 _pid, uint256 _amount) external {
        require(_pid < poolLength(), "bad pid");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(block.number > bonusEndBlock, "withdraw: Withdrawals are not available yet, it's lock during 24h after the launch.");
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 pending = pendingNova(_pid, msg.sender);
        if (pending > 0) {
            uint feesPercentage = calculateFeesPercentage(_pid, msg.sender);
            uint256 fees = pending.mul(feesPercentage).div(100);
            uint256 gain = pending.sub(fees);
            safeNovaTransfer(devaddr, fees);
            safeNovaTransfer(msg.sender, gain);
        }
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.totalLpStaked = pool.totalLpStaked.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
        }

        uint256 plasma = 0;
        if(pool.totalLpStaked > 0){
            plasma = plasmaPower(_pid, msg.sender, block.timestamp);
        }
        user.rewardDebt = plasma.mul(pool.accNovaPerShare).div(1e12);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function emergencyWithdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        pool.lpToken.safeTransfer(address(msg.sender), amount);
        emit EmergencyWithdraw(msg.sender, _pid, amount);
    }

    function safeNovaTransfer(address _to, uint256 _amount) private {
        uint256 novaBal = nova.balanceOf(address(this));
        nova.transfer(_to, _amount > novaBal ? novaBal : _amount);
    }

    function dev(address _devaddr) public {
        require(msg.sender == devaddr, "dev: wut?");
        devaddr = _devaddr;
    }
}