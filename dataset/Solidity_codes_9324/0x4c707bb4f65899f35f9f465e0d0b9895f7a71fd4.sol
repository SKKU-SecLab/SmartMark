
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

library EnumerableSet {


    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(value)));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(value)));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(value)));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint256(_at(set._inner, index)));
    }



    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
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

contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public _whitelistedAddresses;

    uint256 private _totalSupply;
    uint256 private _burnedSupply;
    uint256 private _minSupply;
    uint256 private _burnRate;
    string private _name;
    string private _symbol;
    uint256 private _decimals;

    constructor (string memory name, string memory symbol, uint256 burnrate, uint256 initSupply, uint256 minSupply) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
        _burnRate = burnrate;
        _totalSupply = 0;
        _mint(msg.sender, initSupply*(10**_decimals));
        _burnedSupply = 0;
        _minSupply = minSupply*(10**_decimals);
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint256) {

        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function burnedSupply() public view returns (uint256) {

        return _burnedSupply;
    }
    
    function minSupply() public view returns (uint256) {

        return _minSupply;
    }

    function burnRate() public view returns (uint256) {

        return _burnRate;
    }

    function balanceOf(address account) public view override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function burn(uint256 amount) public virtual returns (bool) {

        _burn(_msgSender(), amount);
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

        if (_whitelistedAddresses[sender] == true || _whitelistedAddresses[recipient] == true) {
            _beforeTokenTransfer(sender, recipient, amount);
            _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
        } else {
            uint256 amount_burn = amount.mul(_burnRate).div(1000);
            uint256 amount_send = amount.sub(amount_burn);
            require(amount == amount_send + amount_burn, "Burn value invalid");
            if(_totalSupply.sub(amount_burn) >= _minSupply) {
                _burn(sender, amount_burn);
                amount = amount_send;
            } else {
                amount = amount_send + amount_burn;
            }
            _beforeTokenTransfer(sender, recipient, amount);
            _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
        }
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
        _burnedSupply = _burnedSupply.add(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupBurnrate(uint256 burnrate_) internal virtual {

        _burnRate = burnrate_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}

contract Mintable is Context {

    address private _minter;

    event MintershipTransferred(address indexed previousMinter, address indexed newMinter);

    constructor () internal {
        address msgSender = _msgSender();
        _minter = msgSender;
        emit MintershipTransferred(address(0), msgSender);
    }

    function minter() public view returns (address) {
        return _minter;
    }

    modifier onlyMinter() {
        require(_minter == _msgSender(), "Mintable: caller is not the minter");
        _;
    }

    function transferMintership(address newMinter) public virtual onlyMinter {
        require(newMinter != address(0), "Mintable: new minter is the zero address");
        emit MintershipTransferred(_minter, newMinter);
        _minter = newMinter;
    }
}

interface IMigrationMaster {
    function migrate(IERC20 token) external returns (IERC20);
}

contract CoinSWOP is ERC20("CoinSWOP", "cSWOP", 30, 100000, 10000), Ownable, Mintable {
    function mint(address _to, uint256 _amount) public onlyMinter {
        _mint(_to, _amount);
    }

    function setBurnrate(uint256 burnrate_) public onlyOwner {
        _setupBurnrate(burnrate_);
    }

    function addWhitelistedAddress(address _address) public onlyOwner {
        _whitelistedAddresses[_address] = true;
    }

    function removeWhitelistedAddress(address _address) public onlyOwner {
        _whitelistedAddresses[_address] = false;
    }
}

contract CoinSWOPGov is ERC20("CoinSWOPGov", "cGOV", 0, 0, 0), Ownable {
    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
    }
    
    function burn(address _from, uint256 _amount) public onlyOwner {
        _burn(_from, _amount);
    }
}

contract CoinSWOPMaster is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
        uint256 pendingRewards;
        uint256 lastHarvestBlock;
    }

    struct PoolInfo {
        IERC20 lpToken;
        uint256 allocPoint;
        uint256 lastRewardBlock;
        uint256 cSWOPPerShare;
        uint256 harvestVestingBlocks;
    }
    
    CoinSWOP public cSWOP;
    CoinSWOPGov public cGOV;
    uint256 public devFundDivRate = 100;
    address public devaddr;
    uint256 public cSWOPPerBlock;
    uint256 public maxcSWOPSupply;
    IMigrationMaster public migrator;

    PoolInfo[] public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    uint256 public totalAllocPoint = 0;
    uint256 public startBlock;

    event Recovered(address token, uint256 amount);
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event Claim(address indexed user, uint256 indexed pid, uint256 amount);
    event ClaimAndStake(address indexed user, uint256 indexed pid, uint256 amount);

    constructor(
        CoinSWOP _cSWOP,
        CoinSWOPGov _cGOV,
        address _devaddr,
        uint256 _cSWOPPerBlock,
        uint256 _startBlock,
        uint256 _maxcSWOPSupply
    ) public {
        cSWOP = _cSWOP;
        cGOV = _cGOV;
        devaddr = _devaddr;
        cSWOPPerBlock = _cSWOPPerBlock;
        startBlock = _startBlock;
        maxcSWOPSupply = _maxcSWOPSupply*(10**18);

        poolInfo.push(PoolInfo({
            lpToken: _cSWOP,
            allocPoint: 1000,
            lastRewardBlock: startBlock,
            cSWOPPerShare: 0,
            harvestVestingBlocks: 0
        }));

        totalAllocPoint = 1000;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }
    
    function getMultiplier(uint256 _from, uint256 _to)
        public
        pure
        returns (uint256)
    {
        return _to.sub(_from);
    }

    function add(
        uint256 _allocPoint,
        IERC20 _lpToken,
        bool _withUpdate,
        uint _harvestVestingBlocks
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
                cSWOPPerShare: 0,
                harvestVestingBlocks: _harvestVestingBlocks
            })
        );
        updateStakingPool();
    }

    function set(
        uint256 _pid,
        uint256 _allocPoint,
        uint256 _lastRewardBlock,
        uint _harvestVestingBlocks,
        bool _withUpdate
    ) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(
            _allocPoint
        );
        uint256 prevAllocPoint = poolInfo[_pid].allocPoint;
        poolInfo[_pid].lastRewardBlock = _lastRewardBlock;
        poolInfo[_pid].allocPoint = _allocPoint;
        if (prevAllocPoint != _allocPoint) {
            updateStakingPool();
        }
        poolInfo[_pid].harvestVestingBlocks = _harvestVestingBlocks;
    }

    function updateStakingPool() internal {
        uint256 length = poolInfo.length;
        uint256 points = 0;
        for (uint256 pid = 1; pid < length; ++pid) {
            points = points.add(poolInfo[pid].allocPoint);
        }
        if (points != 0) {
            points = points.div(3);
            totalAllocPoint = totalAllocPoint.sub(poolInfo[0].allocPoint).add(points);
            poolInfo[0].allocPoint = points;
        }
    }
    
    function migrate(uint256 _pid) public {
        require(address(migrator) != address(0), "migrate: no migrator");
        PoolInfo storage pool = poolInfo[_pid];
        IERC20 lpToken = pool.lpToken;
        uint256 bal = lpToken.balanceOf(address(this));
        lpToken.safeApprove(address(migrator), bal);
        IERC20 newLpToken = migrator.migrate(lpToken);
        require(bal == newLpToken.balanceOf(address(this)), "migrate: bad");
        pool.lpToken = newLpToken;
    }

    function pendingcSWOP(uint256 _pid, address _user)
        external
        view
        returns (uint256)
    {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 cSWOPPerShare = pool.cSWOPPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(
                pool.lastRewardBlock,
                block.number
            );
            uint256 cSWOPReward = multiplier
                .mul(cSWOPPerBlock)
                .mul(pool.allocPoint)
                .div(totalAllocPoint);
            cSWOPPerShare = cSWOPPerShare.add(
                cSWOPReward.mul(1e12).div(lpSupply)
            );
        }
        return
            user.amount.mul(cSWOPPerShare).div(1e12).sub(user.rewardDebt).add(user.pendingRewards);
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
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 cSWOPReward = multiplier
            .mul(cSWOPPerBlock)
            .mul(pool.allocPoint)
            .div(totalAllocPoint);
        uint256 currentSupply = cSWOP.totalSupply();
        if(currentSupply.add(cSWOPReward) <= maxcSWOPSupply) {
            cSWOP.mint(devaddr, cSWOPReward.div(devFundDivRate));
            cSWOP.mint(address(this), cSWOPReward);
        }
        pool.cSWOPPerShare = pool.cSWOPPerShare.add(
            cSWOPReward.mul(1e12).div(lpSupply)
        );
        pool.lastRewardBlock = block.number;
    }

    function deposit(uint256 _pid, uint256 _amount, bool _withdrawRewards) public {
        require (_pid != 0, 'please deposit cSWOP by staking');
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user
                .amount
                .mul(pool.cSWOPPerShare)
                .div(1e12)
                .sub(user.rewardDebt);
            
            if (pending > 0) {
                user.pendingRewards = user.pendingRewards.add(pending);

                if (_withdrawRewards) {
                    safecSWOPTransfer(msg.sender, user.pendingRewards);
                    emit Claim(msg.sender, _pid, user.pendingRewards);
                    user.pendingRewards = 0;
                }
            }
        }
        if (_amount > 0) {
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.cSWOPPerShare).div(1e12);
        user.lastHarvestBlock = block.number;
        emit Deposit(msg.sender, _pid, _amount);
    }

    function withdraw(uint256 _pid, uint256 _amount, bool _withdrawRewards) public {
        require (_pid != 0, 'please withdraw cSWOP by unstaking');
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        require (block.number >= user.lastHarvestBlock.add(pool.harvestVestingBlocks), 'withdraw: you cant harvest yet');
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.cSWOPPerShare).div(1e12).sub(user.rewardDebt);
        if (pending > 0) {
            user.pendingRewards = user.pendingRewards.add(pending);

            if (_withdrawRewards) {
                safecSWOPTransfer(msg.sender, user.pendingRewards);
                emit Claim(msg.sender, _pid, user.pendingRewards);
                user.pendingRewards = 0;
            }
        }
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
        }
        user.rewardDebt = user.amount.mul(pool.cSWOPPerShare).div(1e12);
        user.lastHarvestBlock = block.number;
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function claim(uint256 _pid) public {
        require (_pid != 0, 'please claim staking rewards on stake page');
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.cSWOPPerShare).div(1e12).sub(user.rewardDebt);
        if (pending > 0 || user.pendingRewards > 0) {
            user.pendingRewards = user.pendingRewards.add(pending);
            safecSWOPTransfer(msg.sender, user.pendingRewards);
            emit Claim(msg.sender, _pid, user.pendingRewards);
            user.pendingRewards = 0;
            user.lastHarvestBlock = block.number;
        }
        user.rewardDebt = user.amount.mul(pool.cSWOPPerShare).div(1e12);
        user.lastHarvestBlock = block.number;
    }

    function claimAndStake(uint256 _pid) public {
        require (_pid != 0, 'please claim and stake staking rewards on stake page');
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.cSWOPPerShare).div(1e12).sub(user.rewardDebt);
        if (pending > 0 || user.pendingRewards > 0) {
            user.pendingRewards = user.pendingRewards.add(pending);
            transferToStake(user.pendingRewards);
            emit ClaimAndStake(msg.sender, _pid, user.pendingRewards);
            user.pendingRewards = 0;
        }
        user.rewardDebt = user.amount.mul(pool.cSWOPPerShare).div(1e12);
        user.lastHarvestBlock = block.number;
    }

    function transferToStake(uint256 _amount) internal {
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[0][msg.sender];
        updatePool(0);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.cSWOPPerShare).div(1e12).sub(user.rewardDebt);
            if (pending > 0) {
                user.pendingRewards = user.pendingRewards.add(pending);
            }
        }
        if (_amount > 0) {
            user.amount = user.amount.add(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.cSWOPPerShare).div(1e12);

        cGOV.mint(msg.sender, _amount);
        emit Deposit(msg.sender, 0, _amount);
    }

    function enterStaking(uint256 _amount, bool _withdrawRewards) public {
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[0][msg.sender];
        updatePool(0);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.cSWOPPerShare).div(1e12).sub(user.rewardDebt);
            if (pending > 0) {
                user.pendingRewards = user.pendingRewards.add(pending);

                if (_withdrawRewards) {
                    safecSWOPTransfer(msg.sender, user.pendingRewards);
                    user.pendingRewards = 0;
                }
            }
        }
        if (_amount > 0) {
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.cSWOPPerShare).div(1e12);

        cGOV.mint(msg.sender, _amount);
        emit Deposit(msg.sender, 0, _amount);
    }

    function leaveStaking(uint256 _amount, bool _withdrawRewards) public {
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[0][msg.sender];
        require(user.amount >= _amount, "unstake: not good");
        require(cGOV.balanceOf(msg.sender) >= _amount, "unstake: not enough cGOV tokens");
        updatePool(0);
        uint256 pending = user.amount.mul(pool.cSWOPPerShare).div(1e12).sub(user.rewardDebt);
        if (pending > 0) {
                user.pendingRewards = user.pendingRewards.add(pending);

                if (_withdrawRewards) {
                    safecSWOPTransfer(msg.sender, user.pendingRewards);
                    user.pendingRewards = 0;
                }
            }
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
        }
        user.rewardDebt = user.amount.mul(pool.cSWOPPerShare).div(1e12);
        
        cGOV.burn(msg.sender, _amount);
        emit Withdraw(msg.sender, 0, _amount);
    }

    function claimStaking() public {
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[0][msg.sender];
        updatePool(0);
        uint256 pending = user.amount.mul(pool.cSWOPPerShare).div(1e12).sub(user.rewardDebt);
        if (pending > 0 || user.pendingRewards > 0) {
            user.pendingRewards = user.pendingRewards.add(pending);
            safecSWOPTransfer(msg.sender, user.pendingRewards);
            emit Claim(msg.sender, 0, user.pendingRewards);
            user.pendingRewards = 0;
        }
        user.rewardDebt = user.amount.mul(pool.cSWOPPerShare).div(1e12);
    }

    function stakeRewardsStaking() public {
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[0][msg.sender];
        uint256 rewardsToStake;
        updatePool(0);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.cSWOPPerShare).div(1e12).sub(user.rewardDebt);
            if (pending > 0) {
                user.pendingRewards = user.pendingRewards.add(pending);
            }
        }
        if (user.pendingRewards > 0) {
            rewardsToStake = user.pendingRewards;
            user.pendingRewards = 0;
            user.amount = user.amount.add(rewardsToStake);
        }
        user.rewardDebt = user.amount.mul(pool.cSWOPPerShare).div(1e12);

        cGOV.mint(msg.sender, rewardsToStake);
        emit Deposit(msg.sender, 0, rewardsToStake);
    }

    function safecSWOPTransfer(address _to, uint256 _amount) internal {
        uint256 bal = cSWOP.balanceOf(address(this));
        if (_amount > bal) {
            cSWOP.transfer(_to, bal);
        } else {
            cSWOP.transfer(_to, _amount);
        }
    }

    function setDevAddr(address _devaddr) public {
        require(msg.sender == devaddr, "nice try");
        devaddr = _devaddr;
    }

    function setcSWOPPerBlock(uint256 _cSWOPPerBlock) public onlyOwner {
        require(_cSWOPPerBlock > 0, "!cSWOPPerBlock-0");
        cSWOPPerBlock = _cSWOPPerBlock;
    }

    function setDevFundDivRate(uint256 _devFundDivRate) public onlyOwner {
        require(_devFundDivRate > 0, "!devFundDivRate-0");
        devFundDivRate = _devFundDivRate;
    }
    function setMigrator(IMigrationMaster _migrator) public onlyOwner {
        migrator = _migrator;
    }
    function setStartBlock(uint256 _startBlock) public onlyOwner{
        startBlock = _startBlock;
    }
}