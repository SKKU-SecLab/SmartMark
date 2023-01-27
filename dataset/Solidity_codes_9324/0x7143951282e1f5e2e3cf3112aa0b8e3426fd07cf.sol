




pragma solidity ^0.8.0;

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




pragma solidity ^0.8.0;


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




pragma solidity ^0.8.2;

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









pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}




pragma solidity ^0.8.0;

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




pragma solidity ^0.8.0;





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


pragma solidity 0.8.4;




contract PeachesToken is ERC20("Peaches.Finance", "PCHS"), Ownable {
    
    
    
    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
        
    }
    
    function burn(address _from, uint256 _amount) public onlyOwner {
        _burn(_from, _amount);
        
    }
    
}

pragma solidity 0.8.4;

pragma experimental ABIEncoderV2;





contract MasterGarden is Ownable {
    
    using SafeERC20 for IERC20;
    using SafeERC20 for PeachesToken;
    
    struct UserInfo {
        uint256 amount;     // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
    }

    struct PoolInfo {
        IERC20 lpToken;  // Address of LP token contract.
        uint256 multiplier;
        uint256 allocPoint;       // How many allocation points assigned to this pool. Peachess to distribute per block.
        uint256 lastRewardBlock;  // Last block number that Peachess distribution occurs.
        uint256 accPeachesPerShare; // Accumulated Peachess per share, times 1e12. See below.
    }
    
    struct LockBox {
        uint id;
        address beneficiary;
        uint boxBalance;
        uint releaseTime;
    }
    
    PeachesToken public Peaches;
    
    address public collector;
    uint256 public bonusEndBlock;
    uint256 public PeachesPerBlock;
    uint256 public constant BONUS_MULTIPLIER = 2;
    uint256 public constant PEACHES_CAP = 46000000000000000000000000;
    uint256 public peachesMinted;
    uint public totalBoxes = 0;

    PoolInfo[] public poolInfo;
    mapping(address => LockBox[]) public lockBoxes;
    
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
    uint256 public totalAllocPoint = 0;
    uint256 public startBlock;
    uint256 public startTime;
    
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event BoxLocked(address indexed sender, address indexed receiver, uint amount, uint releaseTime);   
    event BoxUnlocked(address indexed receiver, uint amount);
    
    constructor(
        PeachesToken _Peaches,
        uint256 _PeachesPerBlock,
        uint256 _bonusEndBlock
    ) {
        Peaches = _Peaches;
        collector = msg.sender;
        PeachesPerBlock = _PeachesPerBlock;
        bonusEndBlock = _bonusEndBlock;
        startBlock = block.number;
        startTime = block.timestamp;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    function addPool(uint256 _allocPoint, uint256 _multiplier, IERC20 _lpToken, bool _withUpdate) external onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        
        totalAllocPoint = totalAllocPoint + _allocPoint;
        poolInfo.push(PoolInfo({
            lpToken: _lpToken,
            multiplier: _multiplier,
            allocPoint: _allocPoint,
            lastRewardBlock: block.number,
            accPeachesPerShare: 0
        }));
    }

    function setPool(uint256 _pid, uint256 _allocPoint, bool _withUpdate) external onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint - poolInfo[_pid].allocPoint + _allocPoint;
        poolInfo[_pid].allocPoint = _allocPoint;
    }


    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {
        if (_to <= bonusEndBlock) {
            return (_to - _from) * BONUS_MULTIPLIER;
        } else if (_from >= bonusEndBlock) {
            return _to - _from;
        } else {
            return (bonusEndBlock - _from) * BONUS_MULTIPLIER + (_to - bonusEndBlock);
        }
    }

    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
      
        uint256 PeachesReward = getMultiplier(pool.lastRewardBlock, block.number) * PeachesPerBlock * pool.allocPoint / totalAllocPoint;
        
        pool.accPeachesPerShare = pool.accPeachesPerShare + (PeachesReward * 1e12 / lpSupply);
        pool.lastRewardBlock = block.number;
        
        if (peachesMinted <= PEACHES_CAP) {
        peachesMinted = peachesMinted + PeachesReward;
        Peaches.mint(address(this), PeachesReward);
        }
    }

    function deposit(uint256 _pid, uint256 _amount) external {
        
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        
        require(_amount <= pool.lpToken.allowance(msg.sender, address(this)), "Allowance not high enough");
        pool.lpToken.safeTransferFrom(msg.sender, address(this), _amount);
        
        if ( pool.multiplier < 1000000000000000000) {
            _amount = _amount * pool.multiplier;
        }
        
        updatePool(_pid);
        
        uint256 pending = user.amount * pool.accPeachesPerShare / 1e12 - user.rewardDebt;
        user.amount = user.amount + _amount;
        
        if (block.timestamp > (startTime + 40 days) && pending > 0 ) {
            
            user.rewardDebt = user.amount * pool.accPeachesPerShare / 1e12;
            Peaches.safeTransfer(msg.sender, pending);
           
        } else {
            
            user.rewardDebt = user.amount * pool.accPeachesPerShare / 1e12 - pending;
        }
        
        if ( pool.multiplier < 1000000000000000000) {
            _amount = _amount / pool.multiplier;
        }
        
        emit Deposit(msg.sender, _pid, _amount);
    }

    function withdraw(uint256 _pid, uint256 _amount) external {
        
        require(block.timestamp > (startTime + 40 days), 'Too early');
        
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        
        if ( pool.multiplier < 1000000000000000000) {
            _amount = _amount * pool.multiplier;
        }
        
        require(user.amount >= _amount, "withdraw: not good");
        
        updatePool(_pid);
        
        uint256 pending = user.amount * pool.accPeachesPerShare / 1e12 - user.rewardDebt;
        
        user.amount = user.amount - _amount;
        user.rewardDebt = user.amount * pool.accPeachesPerShare / 1e12;
        
        Peaches.safeTransfer(msg.sender, pending);
        
        if ( pool.multiplier < 1000000000000000000) {
            _amount = _amount / pool.multiplier;
        }
        
        pool.lpToken.safeTransfer(msg.sender, _amount);
        
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function emergencyWithdraw(uint256 _pid) external {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        
        uint amount = user.amount;
        uint reward = user.rewardDebt;
        
        user.amount = 0;
        user.rewardDebt = 0;
        
         if ( pool.multiplier < 1000000000000000000) {
            amount = amount / pool.multiplier;
        }
        
        pool.lpToken.safeTransfer(msg.sender, amount);
        emit EmergencyWithdraw(msg.sender, _pid, reward);
        
    }

    
    function burn(uint256 _amount) external {
        require(msg.sender == collector, "Collector only");
        Peaches.burn(collector, _amount);
        
    }
    
    function lock(address _beneficiary, uint256 _amount, uint256 _releaseTime) external returns(bool success) {
        
        require(_amount > 0, "0 not valid");
        require(_releaseTime > block.timestamp, "Not valid");
        require(_amount <= Peaches.allowance(msg.sender, address(this)), "Allowance not high enough");
        Peaches.safeTransferFrom(msg.sender, address(this), _amount);
        
        totalBoxes = totalBoxes + 1;
        
        lockBoxes[_beneficiary].push(LockBox({
            id: totalBoxes,
            beneficiary: _beneficiary,
            boxBalance: _amount,
            releaseTime: _releaseTime
        }));

        emit BoxLocked(msg.sender, _beneficiary, _amount, _releaseTime);
        return true;
    }
    
    function unlock(uint256 id) external returns(bool success) {
        
        LockBox memory lockBox = getLockBox(msg.sender, id);
        
        require(lockBox.boxBalance > 0);
        require(lockBox.beneficiary == msg.sender);
        require(lockBox.releaseTime <= block.timestamp);
        
        uint256 amount = lockBox.boxBalance;
        lockBox.boxBalance = 0;
        updateLockBox(lockBox);
        
        Peaches.safeTransfer(msg.sender, amount);
        
        emit BoxUnlocked(msg.sender, amount);
        return true;
    }
    
   function getLockBox(address account, uint256 LockBoxID) public view returns (LockBox memory) {
        LockBox[] memory accountLockBoxes = lockBoxes[account];
        LockBox memory LockBox_;
        for (uint i = 0; i < accountLockBoxes.length; i++) {
            if (accountLockBoxes[i].id == LockBoxID) {
                LockBox_ = accountLockBoxes[i];
            }
        }
        return LockBox_;
    }
    
    function updateLockBox(LockBox memory lockBox) internal {
        LockBox[] storage accountLockBoxes = lockBoxes[lockBox.beneficiary];
        for (uint i = 0; i < accountLockBoxes.length; i++) {
            if (accountLockBoxes[i].id == lockBox.id) {
                lockBoxes[lockBox.beneficiary][i] = lockBox;
            }
        }
    }
    
    function getNumLockBoxes(address account) public view returns (uint numSafes) {
        return lockBoxes[account].length;
    }
    
    function setCollector(address _collector) external onlyOwner {
        collector = _collector;
    }
}