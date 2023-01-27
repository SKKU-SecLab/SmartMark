

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


pragma solidity ^0.6.0;

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




pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.6.0;

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


pragma solidity ^0.6.0;

contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
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


pragma solidity 0.6.12;

contract LightToken is ERC20("LightToken", "LIGHT"), Ownable {
    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
        _moveDelegates(address(0), _delegates[_to], _amount);
    }


    mapping (address => address) internal _delegates;

    struct Checkpoint {
        uint32 fromBlock;
        uint256 votes;
    }

    mapping (address => mapping (uint32 => Checkpoint)) public checkpoints;

    mapping (address => uint32) public numCheckpoints;

    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    mapping (address => uint) public nonces;

    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);

    function delegates(address delegator)
        external
        view
        returns (address)
    {
        return _delegates[delegator];
    }

    function delegate(address delegatee) external {
        return _delegate(msg.sender, delegatee);
    }

    function delegateBySig(
        address delegatee,
        uint nonce,
        uint expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
    {
        bytes32 domainSeparator = keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                keccak256(bytes(name())),
                getChainId(),
                address(this)
            )
        );

        bytes32 structHash = keccak256(
            abi.encode(
                DELEGATION_TYPEHASH,
                delegatee,
                nonce,
                expiry
            )
        );

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                domainSeparator,
                structHash
            )
        );

        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "LIGHT::delegateBySig: invalid signature");
        require(nonce == nonces[signatory]++, "LIGHT::delegateBySig: invalid nonce");
        require(now <= expiry, "LIGHT::delegateBySig: signature expired");
        return _delegate(signatory, delegatee);
    }

    function getCurrentVotes(address account)
        external
        view
        returns (uint256)
    {
        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    function getPriorVotes(address account, uint blockNumber)
        external
        view
        returns (uint256)
    {
        require(blockNumber < block.number, "LIGHT::getPriorVotes: not yet determined");

        uint32 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }

    function _delegate(address delegator, address delegatee)
        internal
    {
        address currentDelegate = _delegates[delegator];
        uint256 delegatorBalance = balanceOf(delegator); // balance of underlying LIGHTs (not scaled);
        _delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _moveDelegates(address srcRep, address dstRep, uint256 amount) internal {
        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint256 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                uint256 srcRepNew = srcRepOld.sub(amount);
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint256 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint256 dstRepNew = dstRepOld.add(amount);
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(
        address delegatee,
        uint32 nCheckpoints,
        uint256 oldVotes,
        uint256 newVotes
    )
        internal
    {
        uint32 blockNumber = safe32(block.number, "LIGHT::_writeCheckpoint: block number exceeds 32 bits");

        if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }

        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    function safe32(uint n, string memory errorMessage) internal pure returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function getChainId() internal pure returns (uint) {
        uint256 chainId;
        assembly { chainId := chainid() }
        return chainId;
    }
}




interface IMigratorLight {
    enum Platform{
        uniswap,
        sushiswap
    }
    function migrate(IERC20 token, Platform platform) external returns (IERC20);
}

contract LightMain is Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 public constant MinMinters = 20;

    enum Region{
        master,
        slave
    }

    struct UserInfo {
        uint256 amount;     // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256 accReward;
    }

    struct PoolInfo {
        IERC20 lpToken;           // Address of LP token contract.
        uint256 allocPoint;       // How many allocation points assigned to this pool. LIGHTs to distribute per block.
        uint256 lastRewardBlock;  // Last block number that LIGHTs distribution occurs.
        uint256 accLightPerShare; // Accumulated LIGHTs per share, times 1e12. See below.
        bool lock;
    }

    LightToken public light;
    uint256 public lightPerBlock;
    IMigratorLight public migrator;
    address public buyBackContract;
    PoolInfo[] public poolInfo;
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
    uint256 public totalAllocPoint = 0;
    uint256 public startBlock;
    uint256 public halfPeriod;
    uint256 public maxBlocks;
    uint256 public maxSupply;
    uint256 public createAreaFee;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    constructor(
        LightToken _light,
        uint256 _createAreaFee,
        uint256 _lightPerBlock,
        uint256 _startBlock,
        uint256 _halfPeriod,
        uint256 _maxBlocks,
        uint256 _maxSupply
    ) public {
        light = _light;
        createAreaFee = _createAreaFee;
        lightPerBlock = _lightPerBlock;
        startBlock = _startBlock;
        halfPeriod = _halfPeriod;
        maxBlocks = _maxBlocks;
        maxSupply = _maxSupply;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    function add(uint256 _allocPoint, IERC20 _lpToken, bool _withUpdate, bool _lock) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools(Region.master);
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(PoolInfo({
            lpToken: _lpToken,
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            accLightPerShare: 0,
            lock: _lock
        }));
    }

    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools(Region.master);
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    function pendingLight(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accLightPerShare = pool.accLightPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 blockRewards = getBlockRewards(pool.lastRewardBlock, block.number, Region.master);
            uint256 lightReward = blockRewards.mul(pool.allocPoint).div(totalAllocPoint);
            accLightPerShare = accLightPerShare.add(lightReward.mul(1e12).div(lpSupply));
        }
        return user.amount.mul(accLightPerShare).div(1e12).sub(user.rewardDebt);
    }

    function massUpdatePools(Region region) public {
        if(region == Region.master){
            uint256 length = poolInfo.length;
            for (uint256 pid = 0; pid < length; ++pid) {
                updatePool(pid);
            }
        }else if(region == Region.master){
            uint256 length = slavePoolInfo.length;
            for (uint256 pid = 0; pid < length; ++pid) {
                updateSlavePool(pid);
            }
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
        uint256 blockRewards = getBlockRewards(pool.lastRewardBlock, block.number, Region.master);
        uint256 lightReward = blockRewards.mul(pool.allocPoint).div(totalAllocPoint);
        light.mint(address(this), lightReward);
        pool.accLightPerShare = pool.accLightPerShare.add(lightReward.mul(1e12).div(lpSupply));
        pool.lastRewardBlock = block.number;
    }

    function deposit(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accLightPerShare).div(1e12).sub(user.rewardDebt);
            if(pending > 0) {
                safeLightTransfer(msg.sender, pending);
                user.accReward = user.accReward.add(pending);
            }
        }
        if(_amount > 0) {
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accLightPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }

    function withdraw(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        require(pool.lock == false || pool.lock && block.number >= (startBlock + maxBlocks + 5760));
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accLightPerShare).div(1e12).sub(user.rewardDebt);
        if(pending > 0) {
            safeLightTransfer(msg.sender, pending);
            user.accReward = user.accReward.add(pending);
        }
        if(_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
        }
        user.rewardDebt = user.amount.mul(pool.accLightPerShare).div(1e12);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function emergencyWithdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        pool.lpToken.safeTransfer(address(msg.sender), user.amount);
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
    }

    function safeLightTransfer(address _to, uint256 _amount) internal {
        uint256 lightBal = light.balanceOf(address(this));
        if (_amount > lightBal) {
            light.transfer(_to, lightBal);
        } else {
            light.transfer(_to, _amount);
        }
    }

    function getBlockReward(uint256 number, Region region) public view returns (uint256) {
        if (number < startBlock){
            return 0;
        }
        uint256 mintBlocks = number.sub(startBlock);
        if (mintBlocks >= maxBlocks){
            return 0;
        }
        uint256 exp = mintBlocks.div(halfPeriod);
        uint256 blockReward = lightPerBlock.mul(5 ** exp).div(10 ** exp);
        if(blockReward > 0 && blockReward <= lightPerBlock){
            if(region == Region.master){
                return blockReward.mul(8).div(10);
            }
            if(region == Region.slave){
                return blockReward.mul(2).div(10);
            }
            return blockReward;
        }
        return 0;
    }

    function getBlockRewardNow() public view returns (uint256) {
        return getBlockReward(block.number, Region.master) + getBlockReward(block.number, Region.slave);
    }

    function getBlockRewards(uint256 from, uint256 to, Region region) public view returns (uint256) {
        if(light.totalSupply() >= maxSupply){
            return 0;
        }
        if(from < startBlock){
            from = startBlock;
        }
        if(to > startBlock.add(maxBlocks)){
            to = startBlock.add(maxBlocks).sub(1);
        }
        if(from >= to){
            return 0;
        }
        uint256 blockReward1 = getBlockReward(from, region);
        uint256 blockReward2 = getBlockReward(to, region);
        uint256 blockGap = to.sub(from);
        if(blockReward1 != blockReward2){
            uint256 blocks2 = to.mod(halfPeriod);
            if(blockGap < blocks2){
                return 0;
            }
            uint256 blocks1 = blockGap.sub(blocks2);
            return blocks1.mul(blockReward1).add(blocks2.mul(blockReward2));
        }
        return blockGap.mul(blockReward1);
    }


    event SlaveDeposit(address indexed user, uint256 indexed pid, uint256 amount);
    event SlaveWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event SlaveEmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    struct AreaInfo {
        address creator;
        uint256 creationBlock;
        uint256 members;
        uint256 amount;
        uint256 rewardDebt;
        string name;
    }

    mapping (uint256 => AreaInfo[]) public areaInfo;

    struct SlaveUserInfo {
        uint256 aid;
        uint256 amount;     // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256 accReward;
    }

    struct SlavePoolInfo {
        IERC20 lpToken;           // Address of LP token contract.
        uint256 allocPoint;       // How many allocation points assigned to this pool. LIGHTs to distribute per block.
        uint256 lastRewardBlock;  // Last block number that LIGHTs distribution occurs.
        uint256 minerAccLightPerShare; // Accumulated LIGHTs per share, times 1e12. See below.
        uint256 creatorAccLightPerShare; // Accumulated LIGHTs per share, times 1e12. See below.
        uint256 totalBadAreaBalance;
        uint256 ethForBuyBack;
    }

    SlavePoolInfo[] public slavePoolInfo;
    mapping (uint256 => mapping (address => SlaveUserInfo)) public slaveUserInfo;
    uint256 public slaveTotalAllocPoint = 0;

    function createArea(uint256 _pid, string memory _name) payable public  {
        require(msg.value == createAreaFee);
        areaInfo[_pid].push(AreaInfo({
            creator: msg.sender,
            creationBlock: block.number,
            members: 0,
            amount: 0,
            rewardDebt: 0,
            name: _name
        }));
        SlavePoolInfo storage pool = slavePoolInfo[_pid];
        if(buyBackContract != address(0)){
            bytes memory callData = abi.encodeWithSignature("buyBackLightForCreators(uint256)", _pid);
            (bool success, ) = buyBackContract.call{value: pool.ethForBuyBack.add(msg.value)}(callData);
            if(success){
                pool.ethForBuyBack = 0;
            }
        }else{
            pool.ethForBuyBack = pool.ethForBuyBack.add(createAreaFee);
        }
    }

    function slavePoolLength() external view returns (uint256) {
        return slavePoolInfo.length;
    }

    function areaLength(uint256 _pid) external view returns (uint256) {
        return areaInfo[_pid].length;
    }

    function addSlavePool(uint256 _allocPoint, IERC20 _lpToken, bool _withUpdate) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools(Region.slave);
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        slaveTotalAllocPoint = slaveTotalAllocPoint.add(_allocPoint);
        slavePoolInfo.push(SlavePoolInfo({
            lpToken: _lpToken,
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            minerAccLightPerShare: 0,
            creatorAccLightPerShare: 0,
            totalBadAreaBalance: 0,
            ethForBuyBack: 0
        }));
    }

    function setSlavePool(uint256 _pid, uint256 _allocPoint, bool _withUpdate) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools(Region.slave);
        }
        slaveTotalAllocPoint = slaveTotalAllocPoint.sub(slavePoolInfo[_pid].allocPoint).add(_allocPoint);
        slavePoolInfo[_pid].allocPoint = _allocPoint;
    }

    function slavePendingLightByAid(uint256 _pid, uint256 _aid, address _user) external view returns (uint256) {
        if(slaveUserInfo[_pid][_user].aid != _aid){
            return 0;
        }
        return slavePendingLight(_pid, _user);
    }

    function slavePendingLight(uint256 _pid, address _user) public view returns (uint256) {
        SlavePoolInfo storage pool = slavePoolInfo[_pid];
        SlaveUserInfo storage user = slaveUserInfo[_pid][_user];
        uint256 minerAccLightPerShare = pool.minerAccLightPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 blockRewards = getBlockRewards(pool.lastRewardBlock, block.number, Region.slave);
            uint256 lightReward = blockRewards.mul(pool.allocPoint).div(slaveTotalAllocPoint);
            uint256 lightRewardForMiner = lightReward.mul(95).div(100);
            minerAccLightPerShare = minerAccLightPerShare.add(lightRewardForMiner.mul(1e12).div(lpSupply));
        }
        return user.amount.mul(minerAccLightPerShare).div(1e12).sub(user.rewardDebt);
    }

    function slavePendingLightForCreatorByAid(uint256 _pid, uint256 _aid, address _user) external view returns (uint256) {
        if(slaveUserInfo[_pid][_user].aid != _aid){
            return 0;
        }
        return slavePendingLightForCreator(_pid, _user);
    }

    function slavePendingLightForCreator(uint256 _pid, address _user) public view returns (uint256) {
        SlaveUserInfo storage user = slaveUserInfo[_pid][_user];
        AreaInfo storage area = areaInfo[_pid][user.aid];
        if(area.creator != _user || area.members < MinMinters){
            return 0;
        }
        SlavePoolInfo storage pool = slavePoolInfo[_pid];
        uint256 creatorAccLightPerShare = pool.creatorAccLightPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 blockRewards = getBlockRewards(pool.lastRewardBlock, block.number, Region.slave);
            uint256 lightReward = blockRewards.mul(pool.allocPoint).div(slaveTotalAllocPoint);
            uint256 lightRewardForCreator = lightReward.mul(5).div(100);
            uint256 lpSupply2 = lpSupply.sub(pool.totalBadAreaBalance);
            if(lpSupply2 > 0){
                creatorAccLightPerShare = creatorAccLightPerShare.add(lightRewardForCreator.mul(1e12).div(lpSupply2));
            }
        }
        return area.amount.mul(creatorAccLightPerShare).div(1e12).sub(area.rewardDebt);
    }

    function updateSlavePool(uint256 _pid) public {
        SlavePoolInfo storage pool = slavePoolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 blockReward = getBlockRewards(pool.lastRewardBlock, block.number, Region.slave);
        uint256 lightReward = blockReward.mul(pool.allocPoint).div(slaveTotalAllocPoint);
        uint256 lightRewardForMiner = lightReward.mul(95).div(100);
        uint256 lightRewardForCreator = lightReward.sub(lightRewardForMiner);
        pool.minerAccLightPerShare = pool.minerAccLightPerShare.add(lightRewardForMiner.mul(1e12).div(lpSupply));
        uint256 lpSupply2 = lpSupply.sub(pool.totalBadAreaBalance);
        if(lpSupply2 > 0){
            pool.creatorAccLightPerShare = pool.creatorAccLightPerShare.add(lightRewardForCreator.mul(1e12).div(lpSupply2));
            light.mint(address(this), lightReward);
        }else{
            light.mint(address(this), lightRewardForMiner);
        }
        pool.lastRewardBlock = block.number;
    }

    function slaveDeposit(uint256 _pid, uint256 _aid, uint256 _amount) public {
        AreaInfo storage area = areaInfo[_pid][_aid];
        require(area.creator != address(0), "invalid area");
        SlavePoolInfo storage pool = slavePoolInfo[_pid];
        SlaveUserInfo storage user = slaveUserInfo[_pid][msg.sender];
        updateSlavePool(_pid);
        if (user.amount > 0) {
            require(user.aid == _aid, "deposit: invalid aid");
            uint256 minerPending = user.amount.mul(pool.minerAccLightPerShare).div(1e12).sub(user.rewardDebt);
            if(minerPending > 0) {
                safeLightTransfer(msg.sender, minerPending);
                user.accReward = user.accReward.add(minerPending);
            }
        }
        if(area.members >= MinMinters){
            uint256 creatorPending = area.amount.mul(pool.creatorAccLightPerShare).div(1e12).sub(area.rewardDebt);
            if(creatorPending > 0) {
                safeLightTransfer(area.creator, creatorPending);
                SlaveUserInfo storage creatorInfo = slaveUserInfo[_pid][area.creator];
                creatorInfo.accReward = creatorInfo.accReward.add(creatorPending);
            }
        }
        if(_amount > 0) {
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            if(user.amount == 0){
                user.aid = _aid;
                area.members = area.members.add(1);
                if(area.members == MinMinters){
                    pool.totalBadAreaBalance = pool.totalBadAreaBalance.sub(area.amount);
                }
            }
            if(area.members < MinMinters){
                pool.totalBadAreaBalance = pool.totalBadAreaBalance.add(_amount);
            }
            user.amount = user.amount.add(_amount);
            area.amount = area.amount.add(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.minerAccLightPerShare).div(1e12);
        area.rewardDebt = area.amount.mul(pool.creatorAccLightPerShare).div(1e12);
        emit SlaveDeposit(msg.sender, _pid, _amount);
    }

    function slaveWithdraw(uint256 _pid, uint256 _amount) public {
        SlavePoolInfo storage pool = slavePoolInfo[_pid];
        SlaveUserInfo storage user = slaveUserInfo[_pid][msg.sender];
        AreaInfo storage area = areaInfo[_pid][user.aid];
        require(user.amount >= _amount, "withdraw: not good");
        updateSlavePool(_pid);
        uint256 minerPending = user.amount.mul(pool.minerAccLightPerShare).div(1e12).sub(user.rewardDebt);
        if(minerPending > 0) {
            safeLightTransfer(msg.sender, minerPending);
            user.accReward = user.accReward.add(minerPending);
        }
        if(area.members >= MinMinters){
            uint256 creatorPending = area.amount.mul(pool.creatorAccLightPerShare).div(1e12).sub(area.rewardDebt);
            if(creatorPending > 0) {
                safeLightTransfer(area.creator, creatorPending);
                SlaveUserInfo storage creatorInfo = slaveUserInfo[_pid][area.creator];
                creatorInfo.accReward = creatorInfo.accReward.add(creatorPending);
            }
        }
        if(_amount > 0) {
            user.amount = user.amount.sub(_amount);
            if(user.amount == 0){
                if(area.members == MinMinters){
                    pool.totalBadAreaBalance = pool.totalBadAreaBalance.add(area.amount);
                }
                area.members = area.members.sub(1);
            }
            if(area.members < MinMinters){
                pool.totalBadAreaBalance = pool.totalBadAreaBalance.sub(_amount);
            }
            area.amount = area.amount.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
        }
        area.rewardDebt = area.amount.mul(pool.creatorAccLightPerShare).div(1e12);
        user.rewardDebt = user.amount.mul(pool.minerAccLightPerShare).div(1e12);
        emit SlaveWithdraw(msg.sender, _pid, _amount);
    }

    function slaveEmergencyWithdraw(uint256 _pid) public {
        SlavePoolInfo storage pool = slavePoolInfo[_pid];
        SlaveUserInfo storage user = slaveUserInfo[_pid][msg.sender];
        pool.lpToken.safeTransfer(address(msg.sender), user.amount);
        emit SlaveEmergencyWithdraw(msg.sender, _pid, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
    }

    function setBuyBackContract(address _buyBackContract) public onlyOwner {
        buyBackContract = _buyBackContract;
    }

    function shareLightForCreators(uint256 _pid, uint256 _amount) public {
        SlavePoolInfo storage pool = slavePoolInfo[_pid];
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        uint256 lpSupply2 = lpSupply.sub(pool.totalBadAreaBalance);
        if(lpSupply2 > 0){
            light.transferFrom(msg.sender, address(this), _amount);
            pool.creatorAccLightPerShare = pool.creatorAccLightPerShare.add(_amount.mul(1e12).div(lpSupply2));
        }
    }

    function manualBuyBack(uint256 _pid) public onlyOwner {
        SlavePoolInfo storage pool = slavePoolInfo[_pid];
        require(buyBackContract != address(0) && pool.ethForBuyBack > 0);
        bytes memory callData = abi.encodeWithSignature("buyBackLightForCreators(uint256)", _pid);
        (bool success, ) = buyBackContract.call{value: pool.ethForBuyBack}(callData);
        if(success){
            pool.ethForBuyBack = 0;
        }
    }


    function setMigrator(IMigratorLight _migrator) public onlyOwner {
        migrator = _migrator;
    }

    function migrate(uint256 _pid, Region region, IMigratorLight.Platform platform) public {
        require(address(migrator) != address(0), "migrate: no migrator");
        if(region == Region.master){
            PoolInfo storage pool = poolInfo[_pid];
            IERC20 lpToken = pool.lpToken;
            uint256 bal = lpToken.balanceOf(address(this));
            lpToken.safeApprove(address(migrator), bal);
            IERC20 newLpToken = migrator.migrate(lpToken, platform);
            require(bal == newLpToken.balanceOf(address(this)), "migrate: bad");
            pool.lpToken = newLpToken;
        }else if(region == Region.slave){
            SlavePoolInfo storage pool = slavePoolInfo[_pid];
            IERC20 lpToken = pool.lpToken;
            uint256 bal = lpToken.balanceOf(address(this));
            lpToken.safeApprove(address(migrator), bal);
            IERC20 newLpToken = migrator.migrate(lpToken, platform);
            require(bal == newLpToken.balanceOf(address(this)), "migrate: bad");
            pool.lpToken = newLpToken;
        }
    }

}