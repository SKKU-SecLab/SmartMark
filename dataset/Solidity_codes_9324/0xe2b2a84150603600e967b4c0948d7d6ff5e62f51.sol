
pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
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


pragma solidity >=0.6.0 <0.8.0;

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


pragma solidity >=0.6.0 <0.8.0;

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


pragma solidity >=0.6.2 <0.8.0;

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
}


pragma solidity >=0.6.0 <0.8.0;




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


pragma solidity >=0.6.0 <0.8.0;




contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) public {
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

pragma solidity ^0.7.0;



contract NovaToken2 is ERC20("NOVA", "NOVA"), Ownable {
    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
    }
}

pragma solidity ^0.7.0;





contract MasterUniverse2 is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256 lastStakedTime; // Useful for fees calculate
        uint256 buffRate; // Calculated per share of LP
        uint256 plasmaPower;
    }

    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. NOVAs to distribute per block.
        uint256 lastRewardBlock; // Last block number that NOVAs distribution occurs.
        uint256 accNovaPerShare; // Accumulated NOVAs per share, times 1e12. See below.
        uint256 totalPlasmaPower;
    }

    NovaToken2 public nova;
    address public devaddr;
    uint256 public bonusEndBlock;
    uint256 public novaPerBlock;
    uint256 public constant BONUS_MULTIPLIER = 2; //10 for test
    PoolInfo[] public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    uint256 public totalAllocPoint = 0;
    uint256 public startBlock;
    uint256 public startTimestamp;
    uint256[5] private halvings = [0,65000,195000,455000,975000];

    uint256 private constant TINY_LIMIT = 2 * 1 ether;
    uint256 private constant COMMON_LIMIT = 15 * 1 ether;
    uint256 private constant HUGE_LIMIT = 100 * 1 ether;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    constructor(
        NovaToken2 _nova,
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

    function add(uint256 _allocPoint, IERC20 _lpToken, bool _withUpdate) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(PoolInfo({
            lpToken: _lpToken,
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            accNovaPerShare: 0,
            totalPlasmaPower: 0
        }));
    }

    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {
        if (_to <= bonusEndBlock) {
            return _to.sub(_from).mul(BONUS_MULTIPLIER);
        } else if (_from >= bonusEndBlock) {
            return _to.sub(_from);
        } else {
            return bonusEndBlock.sub(_from).mul(BONUS_MULTIPLIER).add(
                _to.sub(bonusEndBlock)
            );
        }
    }

    function calculateBuffRate(uint _amount) private pure returns (uint256) {
        if (_amount <= TINY_LIMIT) {
            return 12;
        } else if (_amount > TINY_LIMIT && _amount <= COMMON_LIMIT) {
            return 10;
        } else if (_amount <= HUGE_LIMIT) {
            return 8;
        } else {
            return 6;
        }
    }

    function calculateNovaPerBlock(uint256 _from, uint256 _to) public view returns (uint256)
    {
        uint256 countFrom = _from - startBlock;
        uint256 countTo = _to - startBlock;
        uint256 fromHalvingCycle = getHalvingCycleByBlockCount(countFrom); 
        uint256 toHalvingCycle = getHalvingCycleByBlockCount(countTo); 
        uint256 novaPerBlockNow;

        if(fromHalvingCycle == toHalvingCycle){
            novaPerBlockNow = novaPerBlock.div(2**(toHalvingCycle-1));
        } else {
            uint256 blockWithPreviousHalving = halvings[toHalvingCycle-1] - countFrom; 
            uint256 blockWithCurrentHalving = countTo - halvings[toHalvingCycle-1]; 
            uint previousNovaPerBlock = novaPerBlock.div(2**(fromHalvingCycle-1)); 
            uint currentNovaPerBlock = novaPerBlock.div(2**(toHalvingCycle-1)); 
            novaPerBlockNow = (blockWithPreviousHalving.mul(previousNovaPerBlock) + blockWithCurrentHalving.mul(currentNovaPerBlock)).div(countTo.sub(countFrom)); 
        }
        return novaPerBlockNow;
    }

    function getHalvingCycleByBlockCount(uint256 _blockCount) private view returns (uint256)
    {
        uint256 halvingCycle;
        if(_blockCount >= halvings[4]){
            halvingCycle = 5;
        } else if(_blockCount >= halvings[3]){
            halvingCycle = 4;
        } else if(_blockCount >= halvings[2]){
            halvingCycle = 3;
        } else if(_blockCount >= halvings[1]){
            halvingCycle = 2;
        }  else {
            halvingCycle = 1;
        }
        return halvingCycle;
    }

    function pendingNova(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accNovaPerShare = pool.accNovaPerShare;
        if (block.number > pool.lastRewardBlock && pool.totalPlasmaPower != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 novaReward = multiplier.mul(calculateNovaPerBlock(pool.lastRewardBlock, block.number)).mul(pool.allocPoint).div(totalAllocPoint);
            accNovaPerShare = accNovaPerShare.add(novaReward.mul(1e12).div(pool.totalPlasmaPower));
        }

        return user.plasmaPower.mul(accNovaPerShare).div(1e12).sub(user.rewardDebt);
    }

    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    function calculateFeesPercentage(uint256 _pid, address _user) public view returns (uint256) {
        UserInfo storage user = userInfo[_pid][_user];
        uint currentTimestamp = block.timestamp; 
        uint daysSinceStartStaking = (currentTimestamp - user.lastStakedTime).div(60).div(60).div(24);
        uint feesPercentage = max(30 - daysSinceStartStaking.div(2), 1); 
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
        if (pool.totalPlasmaPower == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 novaReward = multiplier.mul(calculateNovaPerBlock(pool.lastRewardBlock, block.number)).mul(pool.allocPoint).div(totalAllocPoint);
        nova.mint(devaddr, novaReward.div(10));
        nova.mint(address(this), novaReward);
        pool.accNovaPerShare = pool.accNovaPerShare.add(novaReward.mul(1e12).div(pool.totalPlasmaPower));
        pool.lastRewardBlock = block.number;
    }

    function deposit(uint256 _pid, uint256 _amount) external {
        require(_pid < poolLength(), "bad pid");
        require(_amount > 0, "amount could'n be 0");
        require(_amount >= 0.1 ether, "amount could'n be lower than 0.1 LP token");

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        updatePool(_pid);

        if (user.amount == 0) {
            user.lastStakedTime = block.timestamp; 
        }

        if (user.amount > 0) {
            uint256 pending = user.plasmaPower.mul(pool.accNovaPerShare).div(1e12).sub(user.rewardDebt);
            if (pending > 0) {
                uint feesPercentage = calculateFeesPercentage(_pid, msg.sender);
                uint256 fees = pending.mul(feesPercentage).div(100);
                uint256 gain = pending.sub(fees);
                safeNovaTransfer(devaddr, fees);
                safeNovaTransfer(msg.sender, gain);
            }
        }

        if (_amount > 0) {
            pool.lpToken.safeTransferFrom(address(msg.sender),address(this),_amount);
            user.amount = user.amount.add(_amount);
            user.buffRate = calculateBuffRate(user.amount);
            uint prevPlasmaPower = user.plasmaPower;
            user.plasmaPower = user.amount.mul(user.buffRate);
            pool.totalPlasmaPower = pool.totalPlasmaPower.sub(prevPlasmaPower).add(user.plasmaPower);
        }

        user.rewardDebt = user.plasmaPower.mul(pool.accNovaPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }

    function withdraw(uint256 _pid, uint256 _amount) external {
        require(_pid < poolLength(), "bad pid");

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        require(user.amount >= _amount, "withdraw: not good");
        require(user.amount.sub(_amount) == 0 || user.amount.sub(_amount) >= 0.1 ether, "you can't keep less than 0.1 LP token");

        updatePool(_pid);

        uint256 pending = user.plasmaPower.mul(pool.accNovaPerShare).div(1e12).sub(user.rewardDebt);
        uint256 fees;
        if(pending > 0) {
            uint feesPercentage = calculateFeesPercentage(_pid, msg.sender);
            fees = pending.mul(feesPercentage).div(100);
            uint256 gain = pending.sub(fees);
            safeNovaTransfer(devaddr, fees);
            safeNovaTransfer(msg.sender, gain);
        }

        if (_amount > 0) {
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
            user.amount = user.amount.sub(_amount);
            user.buffRate = calculateBuffRate(user.amount);
            uint prevPlasmaPower = user.plasmaPower;
            user.plasmaPower = user.amount.mul(user.buffRate);
            pool.totalPlasmaPower = pool.totalPlasmaPower.sub(prevPlasmaPower).add(user.plasmaPower);
            user.lastStakedTime = block.timestamp;
        }

        user.rewardDebt = user.plasmaPower.mul(pool.accNovaPerShare).div(1e12);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function emergencyWithdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        pool.totalPlasmaPower = pool.totalPlasmaPower.sub(user.plasmaPower);
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