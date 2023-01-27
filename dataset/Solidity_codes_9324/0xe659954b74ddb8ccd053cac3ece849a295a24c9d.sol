


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


pragma solidity 0.6.12;




contract VENIToken is ERC20("VENIX", "VENIX"), Ownable {
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
        bytes32 s,
        address singaddress
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
        require(signatory != address(0), "VENI::delegateBySig: invalid signature");
        require(signatory == singaddress, "VENI::delegateBySig: invalid signature address");
        require(nonce == nonces[signatory]++, "VENI::delegateBySig: invalid nonce");
        require(now <= expiry, "VENI::delegateBySig: signature expired");
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
        require(blockNumber < block.number, "VENI::getPriorVotes: not yet determined");

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
        uint256 delegatorBalance = balanceOf(delegator); // balance of underlying VENIs (not scaled);
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
        uint32 blockNumber = safe32(block.number, "VENI::_writeCheckpoint: block number exceeds 32 bits");

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


pragma solidity 0.6.12;








interface IMigratorChef {
    function migrate(IERC20 token) external returns (IERC20);
}

contract VENIAdmin is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount;     // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
    }

    struct PoolInfo {
        IERC20 lpToken;           // Address of LP token contract.
        uint256 allocPoint;       // How many allocation points assigned to this pool. VENIs to distribute per block.
        uint256 lastRewardBlock;  // Last block number that VENIs distribution occurs.
        uint256 accVENIPerShare; // Accumulated VENIs per share, times 1e12. See below.
    }

    VENIToken public veni;
    uint256 public devFundDivRate = 10;
    address public devaddr;
    uint256 public bonusEndBlock;
    uint256 public veniPerBlock;
    uint256 public constant BONUS_MULTIPLIER = 2;
    IMigratorChef public migrator;

    PoolInfo[] public poolInfo;
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
    uint256 public totalAllocPoint = 0;
    uint256 public startBlock;

    bool public deposit_Paused = false;
    bool public deposit_PausedSingle = false;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Harvest(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    struct SinglePoolInfo {
        IERC20 sToken;           // Address of single token contract.
        uint256 singlePerBlock; // VENI tokens created per block single token.
        uint256 singleTokenStartBlock; // The block number when VENI mining starts single token.
        uint256 singleTokenEndBlock; // The block number when VENI mining end single token.
        uint256 bonusEndBlock; // Block number when bonus VENI period ends.
        uint256 BONUS_MULTIPLIER; // Bonus muliplier for early VENI makers.
        bool setEndBlock; // End block setting Yes or No!
        bool setActive; // single pool active Yes or No!
        uint256 lastRewardBlock;  // Last block number that VENI distribution occurs.
        uint256 accVENIPerShare; // Accumulated VENI per share, times 1e12. See below.
    }

    SinglePoolInfo[] public poolInfo_single;
    mapping (uint256 => mapping (address => UserInfo)) public userInfo_single;

    event Deposit_single(address indexed user, uint256 indexed pid, uint256 amount);
    event Harvest_single(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw_single(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw_single(address indexed user, uint256 indexed pid, uint256 amount);

    constructor(
        VENIToken _veni,
        address _devaddr,
        uint256 _veniPerBlock,
        uint256 _startBlock,
        uint256 _bonusEndBlock
    ) public {
        veni = _veni;
        devaddr = _devaddr;
        veniPerBlock = _veniPerBlock;
        startBlock = _startBlock;
        bonusEndBlock = _bonusEndBlock;
    }

    function poolLength() external view returns (uint256) {
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
            accVENIPerShare: 0
            }));
    }

    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    function setMigrator(IMigratorChef _migrator) public onlyOwner {
        migrator = _migrator;
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

    function pendingVENI(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accVENIPerShare = pool.accVENIPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 veniReward = multiplier.mul(veniPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accVENIPerShare = accVENIPerShare.add(veniReward.mul(1e12).div(lpSupply));
        }
        return user.amount.mul(accVENIPerShare).div(1e12).sub(user.rewardDebt);
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
        uint256 veniReward = multiplier.mul(veniPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
        veni.mint(devaddr, veniReward.div(devFundDivRate));
        veni.mint(address(this), veniReward);
        pool.accVENIPerShare = pool.accVENIPerShare.add(veniReward.mul(1e12).div(lpSupply));
        pool.lastRewardBlock = block.number;
    }

    function deposit(uint256 _pid, uint256 _amount) public {
        require(!deposit_Paused , "Deposit is currently not possible.");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accVENIPerShare).div(1e12).sub(user.rewardDebt);
            if(pending > 0) {
                safeVENITransfer(msg.sender, pending);
            }
        }
        if(_amount > 0) {
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accVENIPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }

    function harvest(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        updatePool(_pid);

        uint256 pending = 0;
        if (user.amount > 0) {
            pending = user.amount.mul(pool.accVENIPerShare).div(1e12).sub(user.rewardDebt);
            if(pending > 0) {
                safeVENITransfer(msg.sender, pending);
            }
        }

        user.rewardDebt = user.amount.mul(pool.accVENIPerShare).div(1e12);
        emit Harvest(msg.sender, _pid, pending);
    }

    function withdraw(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accVENIPerShare).div(1e12).sub(user.rewardDebt);
        if(pending > 0) {
            safeVENITransfer(msg.sender, pending);
        }
        if(_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
        }
        user.rewardDebt = user.amount.mul(pool.accVENIPerShare).div(1e12);
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

    function safeVENITransfer(address _to, uint256 _amount) internal {
        uint256 veniBal = veni.balanceOf(address(this));
        if (_amount > veniBal) {
            veni.transfer(_to, veniBal);
        } else {
            veni.transfer(_to, _amount);
        }
    }

    function dev(address _devaddr) public {
        require(msg.sender == devaddr, "dev: wut?");
        devaddr = _devaddr;
    }

    function SetDepositPause(bool _paused) public onlyOwner {
        deposit_Paused = _paused;
    }

    function SetDepositPauseSingle(bool _paused) public onlyOwner {
        deposit_PausedSingle = _paused;
    }

    function GetTotalStakeAmount() external view returns (uint256) {
        uint256 TotalMount = 0;

        for (uint256 i = 0; i < poolInfo.length; i++)
        {
            PoolInfo storage pool = poolInfo[i];

            if(pool.allocPoint > 0)
            {
                uint256 multiplier = getMultiplier(startBlock, block.number);
                TotalMount = TotalMount.add(multiplier.mul(veniPerBlock).mul(pool.allocPoint).div(totalAllocPoint)) ;
            }
        }

        return TotalMount;
    }


    function GetTotalStakeAmount_single(uint256 _pid) external view returns (uint256) {
        uint256 TotalMount = 0;

        SinglePoolInfo storage pool = poolInfo_single[_pid];

        uint256 currentBlock = block.number;
        if(pool.setEndBlock && currentBlock > pool.singleTokenEndBlock) {
            currentBlock = pool.singleTokenEndBlock;
        }

        uint256 multiplier = getMultiplier_single(_pid, pool.singleTokenStartBlock, currentBlock);
        TotalMount = multiplier.mul(pool.singlePerBlock);

        return TotalMount;
    }

    function poolLength_single() external view returns (uint256) {
        return poolInfo_single.length;
    }

    function isActive_single(uint256 _pid) external view returns (bool) {
        return poolInfo_single[_pid].setActive;
    }

    function isStake_single(uint256 _pid) external view returns (bool) {

        SinglePoolInfo storage pool = poolInfo_single[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return false;
        }

        if (pool.setEndBlock && block.number > pool.singleTokenEndBlock) {
            return false;
        }

        return true;
    }

    function AddSingleTokenInfo(IERC20 _sToken, uint256 _singlePerBlock, uint256 _singleTokenStartBlock, uint256 _singleTokenEndBlock, uint256 _bonusEndBlock, uint256 _BONUS_MULTIPLIER,  bool _setEndBlock) public onlyOwner {

        uint256 lastRewardBlock = block.number > _singleTokenStartBlock ? block.number : _singleTokenStartBlock;

        poolInfo_single.push(SinglePoolInfo({
            sToken: _sToken,
            singlePerBlock: _singlePerBlock,
            singleTokenStartBlock: _singleTokenStartBlock,
            singleTokenEndBlock: _singleTokenEndBlock,
            bonusEndBlock: _bonusEndBlock,
            BONUS_MULTIPLIER: _BONUS_MULTIPLIER,
            setEndBlock: _setEndBlock,
            lastRewardBlock: lastRewardBlock,
            setActive : true,
            accVENIPerShare: 0
            }));
    }

    function setSingleTokenInfo(uint256 _pid, IERC20 _sToken, uint256 _singlePerBlock, uint256 _singleTokenStartBlock, uint256 _singleTokenEndBlock, uint256 _bonusEndBlock, uint256 _BONUS_MULTIPLIER,  bool _setEndBlock, bool _withUpdate) public onlyOwner {
        require(poolInfo_single.length > _pid, "set single token: not active!");

        if (_withUpdate) {
            updatePool_single(_pid);
        }

        uint256 lastRewardBlock = block.number > _singleTokenStartBlock ? block.number : _singleTokenStartBlock;
        poolInfo_single[_pid].sToken = _sToken;
        poolInfo_single[_pid].singlePerBlock = _singlePerBlock;
        poolInfo_single[_pid].singleTokenStartBlock = _singleTokenStartBlock;
        poolInfo_single[_pid].singleTokenEndBlock = _singleTokenEndBlock;
        poolInfo_single[_pid].bonusEndBlock = _bonusEndBlock;
        poolInfo_single[_pid].BONUS_MULTIPLIER = _BONUS_MULTIPLIER;
        poolInfo_single[_pid].setEndBlock = _setEndBlock;
        poolInfo_single[_pid].lastRewardBlock = lastRewardBlock;
        poolInfo_single[_pid].setActive = true;
        poolInfo_single[_pid].accVENIPerShare = 0;
    }

    function updatePool_single(uint256 _pid) public {
        SinglePoolInfo storage pool = poolInfo_single[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }

        uint256 sSupply = pool.sToken.balanceOf(address(this));
        if (sSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }

        uint256 currentRewardBlock = block.number;
        if (pool.setEndBlock && currentRewardBlock > pool.singleTokenEndBlock) {
            currentRewardBlock = pool.singleTokenEndBlock;
        }

        uint256 multiplier = getMultiplier_single(_pid, pool.lastRewardBlock, currentRewardBlock);
        if(multiplier > 0) {
            uint256 veniReward = multiplier.mul(pool.singlePerBlock);
            veni.mint(devaddr, veniReward.div(devFundDivRate));
            veni.mint(address(this), veniReward);
            pool.accVENIPerShare = pool.accVENIPerShare.add(veniReward.mul(1e12).div(sSupply));
            pool.lastRewardBlock = currentRewardBlock;
        }

    }

    function getMultiplier_single(uint256 _pid, uint256 _from, uint256 _to) public view returns (uint256) {
        SinglePoolInfo storage pool = poolInfo_single[_pid];
        if (_to <= pool.bonusEndBlock) {
            return _to.sub(_from).mul(pool.BONUS_MULTIPLIER);
        } else if (_from >= pool.bonusEndBlock) {
            return _to.sub(_from);
        } else {
            return pool.bonusEndBlock.sub(_from).mul(pool.BONUS_MULTIPLIER).add(
                _to.sub(pool.bonusEndBlock)
            );
        }
    }

    function pendingVENI_single(uint256 _pid, address _user) external view returns (uint256) {
        SinglePoolInfo storage pool = poolInfo_single[_pid];
        UserInfo storage user = userInfo_single[_pid][_user];
        uint256 accVENIPerShare = pool.accVENIPerShare;
        uint256 sSupply = pool.sToken.balanceOf(address(this));

        uint256 currentRewardBlock = block.number;
        if (pool.setEndBlock && currentRewardBlock > pool.singleTokenEndBlock) {
            currentRewardBlock = pool.singleTokenEndBlock;
        }

        if (block.number > pool.lastRewardBlock && sSupply != 0) {
            uint256 multiplier = getMultiplier_single(_pid, pool.lastRewardBlock, currentRewardBlock);
            uint256 VENIReward = multiplier.mul(pool.singlePerBlock);
            accVENIPerShare = accVENIPerShare.add(VENIReward.mul(1e12).div(sSupply));
        }
        return user.amount.mul(accVENIPerShare).div(1e12).sub(user.rewardDebt);
    }

    function deposit_single(uint256 _pid, uint256 _amount) public {
        require(!deposit_PausedSingle , "Deposit is currently not possible.");

        SinglePoolInfo storage pool = poolInfo_single[_pid];

        if(pool.setEndBlock && _amount > 0) {
            require(block.number <= pool.singleTokenEndBlock, "deposit_single: stake end!");
        }

        UserInfo storage user = userInfo_single[_pid][msg.sender];

        updatePool_single(_pid);

        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accVENIPerShare).div(1e12).sub(user.rewardDebt);
            if(pending > 0) {
                safeVENITransfer(msg.sender, pending);
            }
        }

        if(_amount > 0) {
            pool.sToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);
        }

        user.rewardDebt = user.amount.mul(pool.accVENIPerShare).div(1e12);
        emit Deposit_single(msg.sender, _pid, _amount);
    }

    function harvest_single(uint256 _pid) public {
        SinglePoolInfo storage pool = poolInfo_single[_pid];

        UserInfo storage user = userInfo_single[_pid][msg.sender];

        updatePool_single(_pid);

        uint256 pending = 0;
        if (user.amount > 0) {
            pending = user.amount.mul(pool.accVENIPerShare).div(1e12).sub(user.rewardDebt);
            if(pending > 0) {
                safeVENITransfer(msg.sender, pending);
            }
        }

        user.rewardDebt = user.amount.mul(pool.accVENIPerShare).div(1e12);
        emit Harvest_single(msg.sender, _pid, pending);
    }

    function withdraw_single(uint256 _pid, uint256 _amount) public {
        SinglePoolInfo storage pool = poolInfo_single[_pid];
        UserInfo storage user = userInfo_single[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw_single: not good");
        updatePool_single(_pid);
        uint256 pending = user.amount.mul(pool.accVENIPerShare).div(1e12).sub(user.rewardDebt);
        if(pending > 0) {
            safeVENITransfer(msg.sender, pending);
        }
        if(_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.sToken.safeTransfer(address(msg.sender), _amount);
        }
        user.rewardDebt = user.amount.mul(pool.accVENIPerShare).div(1e12);
        emit Withdraw_single(msg.sender, _pid, _amount);
    }

    function emergencyWithdraw_single(uint256 _pid) public {
        SinglePoolInfo storage pool = poolInfo_single[_pid];
        UserInfo storage user = userInfo_single[_pid][msg.sender];
        pool.sToken.safeTransfer(address(msg.sender), user.amount);
        emit EmergencyWithdraw_single(msg.sender, _pid, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
    }

    function setDevFundDivRate(uint256 _devFundDivRate) public onlyOwner {
        require(_devFundDivRate > 0, "!devFundDivRate-0");
        devFundDivRate = _devFundDivRate;
    }

}