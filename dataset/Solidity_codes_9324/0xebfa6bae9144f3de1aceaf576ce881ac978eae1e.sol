


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




contract ZEUSToken is ERC20("ZEUSV2Token", "ZEUSV2"), Ownable {
    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
        _moveDelegates(address(0), _delegates[_to], _amount);
    }

    function burn(address _from, uint256 _amount) public onlyOwner {
        _burn(_from, _amount);
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
        require(signatory != address(0), "ZEUSV2::delegateBySig: invalid signature");
        require(nonce == nonces[signatory]++, "ZEUSV2::delegateBySig: invalid nonce");
        require(now <= expiry, "ZEUSV2::delegateBySig: signature expired");
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
        require(blockNumber < block.number, "ZEUSV2::getPriorVotes: not yet determined");

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
        uint256 delegatorBalance = balanceOf(delegator); // balance of underlying ZEUSs (not scaled);
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
        uint32 blockNumber = safe32(block.number, "ZEUSV2::_writeCheckpoint: block number exceeds 32 bits");

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

contract ZEUSMain is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount;     // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
    }

    struct PoolInfo {
        IERC20 lpToken;           // Address of LP token contract.
        bool bChange;             // if true锛宎llocPoint changed by
        bool bLock;               // if true锛宼he pool be locked
        bool bDepositFee;         //
        uint256 depositMount;     // 
        uint256 changeMount;     //
        uint256 allocPoint;       // How many allocation points assigned to this pool. ZEUSs to distribute per block.
        uint256 lastRewardBlock;  // Last block number that ZEUSs distribution occurs.
        uint256 accZEUSPerShare; // Accumulated ZEUSs per share, times 1e12. See below.
    }

    struct AreaInfo {
        uint256 totalAllocPoint;
        uint256 rate;
    }

    ZEUSToken public zeus;
    ZEUSToken public zeusOld;

    address public devaddr;
    uint256 public minPerBlock;
    uint256 public zeusPerBlock;
    uint256 public halfPeriod;
    uint256 public lockPeriods; // lock periods

    IMigratorChef public migrator;

    mapping (uint256 => PoolInfo[]) public poolInfo;
    mapping (uint256 => mapping(uint256 => mapping (address => UserInfo))) public userInfo;
    AreaInfo[] public areaInfo;
    uint256 public totalRate = 0;

    uint256 public startBlock;

    uint256 public permitExpired;

    event Deposit(address indexed user, uint256 indexed aid, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed aid, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed aid, uint256 indexed pid, uint256 amount);

    constructor(
        ZEUSToken _zeus,
        ZEUSToken _zeusOld,
        address _devaddr,
        uint256 _zeusPerBlock,
        uint256 _startBlock,
        uint256 _minPerBlock,
        uint256 _halfPeriod,
        uint256 _lockPeriods,
        uint256 _permitExpired        
    ) public {
        zeus = _zeus;
        zeusOld = _zeusOld;
        devaddr = _devaddr;
        zeusPerBlock = _zeusPerBlock;
        minPerBlock = _minPerBlock;
        startBlock = _startBlock;
        halfPeriod = _halfPeriod;
        lockPeriods = _lockPeriods;
        permitExpired = _permitExpired;
    }

    function buyBackToken(address payable buybackaddr) public onlyOwner {
        require(buybackaddr != address(0), "buy back is addr 0");
        buybackaddr.transfer(address(this).balance);
    }

    function areaLength() external view returns (uint256) {
        return areaInfo.length;
    }

    function poolLength(uint256 _aid) external view returns (uint256) {
        return poolInfo[_aid].length;
    }

    function addArea(uint256 _rate, bool _withUpdate) public onlyOwner {

        if (_withUpdate) {
            massUpdateAreas();
        }

        totalRate = totalRate.add(_rate);
        areaInfo.push(AreaInfo({
        totalAllocPoint: 0,
        rate: _rate
        }));
    }

    function add(uint256 _aid, uint256 _allocPoint, IERC20 _lpToken, bool _withUpdate, bool _bChange, uint256 _changeMount, bool _bLock, bool _bDepositFee, uint256 _depositFee) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools(_aid);
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        areaInfo[_aid].totalAllocPoint = areaInfo[_aid].totalAllocPoint.add(_allocPoint);
        poolInfo[_aid].push(PoolInfo({
        lpToken: _lpToken,
        bChange: _bChange,
        bLock: _bLock,
        bDepositFee: _bDepositFee,
        depositMount: _depositFee,
        changeMount: _changeMount,
        allocPoint: _allocPoint,
        lastRewardBlock: lastRewardBlock,
        accZEUSPerShare: 0
        }));
    }

    function setArea(uint256 _aid, uint256 _rate, bool _withUpdate) public onlyOwner {

        if (_withUpdate) {
            massUpdateAreas();
        }

        totalRate = totalRate.sub(areaInfo[_aid].rate).add(_rate);
        areaInfo[_aid].rate = _rate;
    }

    function set(uint256 _aid, uint256 _pid, uint256 _allocPoint, bool _withUpdate, bool _bChange, uint256 _changeMount, bool _bLock, bool _bDepositFee, uint256 _depositFee) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools(_aid);
        }
        areaInfo[_aid].totalAllocPoint = areaInfo[_aid].totalAllocPoint.sub(poolInfo[_aid][_pid].allocPoint).add(_allocPoint);
        poolInfo[_aid][_pid].allocPoint = _allocPoint;
        poolInfo[_aid][_pid].bChange = _bChange;
        poolInfo[_aid][_pid].bLock = _bLock;
        poolInfo[_aid][_pid].changeMount = _changeMount;
        poolInfo[_aid][_pid].bDepositFee = _bDepositFee;
        poolInfo[_aid][_pid].depositMount = _depositFee;
    }

    function setMigrator(IMigratorChef _migrator) public onlyOwner {
        migrator = _migrator;
    }

    function migrate(uint256 _aid, uint256 _pid) public {
        require(address(migrator) != address(0), "migrate: no migrator");
        PoolInfo storage pool = poolInfo[_aid][_pid];
        IERC20 lpToken = pool.lpToken;
        uint256 bal = lpToken.balanceOf(address(this));
        lpToken.safeApprove(address(migrator), bal);
        IERC20 newLpToken = migrator.migrate(lpToken);
        require(bal == newLpToken.balanceOf(address(this)), "migrate: bad");
        pool.lpToken = newLpToken;
    }

    function getBlockReward(uint256 number) public view returns (uint256) {
        if (number < startBlock){
            return 0;
        }
        uint256 mintBlocks = number.sub(startBlock);

        uint256 exp = mintBlocks.div(halfPeriod);

        if (exp == 0) return 100000000000000000000;
        if (exp == 1) return 80000000000000000000;
        if (exp == 2) return 60000000000000000000;
        if (exp == 3) return 40000000000000000000;
        if (exp == 4) return 20000000000000000000;
        if (exp == 5) return 10000000000000000000;
        if (exp == 6) return 8000000000000000000;
        if (exp == 7) return 6000000000000000000;
        if (exp == 8) return 4000000000000000000;
        if (exp == 9) return 2000000000000000000;
        if (exp >= 10) return 1000000000000000000;


        return 0;
    }

    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {

        if(_from < startBlock){
            _from = startBlock;
        }
        if(_from >= _to){
            return 0;
        }

        uint256 blockReward1 = getBlockReward(_from);
        uint256 blockReward2 = getBlockReward(_to);
        uint256 blockGap = _to.sub(_from);
        if(blockReward1 != blockReward2){

            uint256 blocks2 = _to.mod(halfPeriod);
            if (blockGap < blocks2) {
              return 0;
            }
            uint256 blocks1 = blockGap > blocks2 ? blockGap.sub(blocks2): 0;
            return blocks1.mul(blockReward1).add(blocks2.mul(blockReward2));
        }
        return blockGap.mul(blockReward1);

    }

    function pendingZEUS(uint256 _aid, uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_aid][_pid];
        UserInfo storage user = userInfo[_aid][_pid][_user];
        uint256 accZEUSPerShare = pool.accZEUSPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 ZEUSReward = multiplier.mul(pool.allocPoint).div(areaInfo[_aid].totalAllocPoint);
            accZEUSPerShare = accZEUSPerShare.add((ZEUSReward.mul(1e12).div(lpSupply)).mul(areaInfo[_aid].rate).div(totalRate));
        }
        return user.amount.mul(accZEUSPerShare).div(1e12).sub(user.rewardDebt);
    }

    function massUpdateAreas() public {
        uint256 length = areaInfo.length;
        for (uint256 aid = 0; aid < length; ++aid) {
            massUpdatePools(aid);
        }
    }


    function massUpdatePools(uint256 _aid) public {
        uint256 length = poolInfo[_aid].length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(_aid, pid);
        }
    }

    function updatePool(uint256 _aid, uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_aid][_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }

        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        if (multiplier == 0) return;
        
        uint256 zeusReward = multiplier.mul(pool.allocPoint).div(areaInfo[_aid].totalAllocPoint).mul(areaInfo[_aid].rate).div(totalRate);
        zeus.mint(devaddr, zeusReward.div(20));
        zeus.mint(address(this), zeusReward);
        pool.accZEUSPerShare = pool.accZEUSPerShare.add((zeusReward.mul(1e12).div(lpSupply)));
        pool.lastRewardBlock = block.number;
    }

    function deposit(uint256 _aid, uint256 _pid, uint256 _amount) payable public {
        PoolInfo storage pool = poolInfo[_aid][_pid];
        UserInfo storage user = userInfo[_aid][_pid][msg.sender];

        if (_amount > 0){        
            require((pool.bDepositFee == false) || (pool.bDepositFee == true && msg.value == pool.depositMount), "deposit: not enough");
        }

        updatePool(_aid, _pid);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accZEUSPerShare).div(1e12).sub(user.rewardDebt);
            if(pending > 0) {
                safeZEUSTransfer(msg.sender, pending);
            }
        }
        else {
            if (pool.bChange == true)
            {
                pool.allocPoint += pool.changeMount;
                areaInfo[_aid].totalAllocPoint += pool.changeMount;
            }
        }
        if(_amount > 0) {
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accZEUSPerShare).div(1e12);
        emit Deposit(msg.sender, _aid, _pid, _amount);
    }

    function withdraw(uint256 _aid, uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_aid][_pid];
        UserInfo storage user = userInfo[_aid][_pid][msg.sender];
        require((pool.bLock == false) || (pool.bLock && (block.number >= (startBlock.add(lockPeriods)))), "withdraw: pool lock");
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_aid, _pid);
        uint256 pending = user.amount.mul(pool.accZEUSPerShare).div(1e12).sub(user.rewardDebt);
        if(pending > 0) {
            safeZEUSTransfer(msg.sender, pending);
        }
        if(_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
        }
        if (user.amount == 0)
        {
            if (pool.bChange == true)
            {
                uint256 changenum = pool.allocPoint > pool.changeMount ? pool.changeMount : 0;
                pool.allocPoint = pool.allocPoint.sub(changenum);
                areaInfo[_aid].totalAllocPoint = areaInfo[_aid].totalAllocPoint.sub(changenum);
            }
        }
        user.rewardDebt = user.amount.mul(pool.accZEUSPerShare).div(1e12);
        emit Withdraw(msg.sender, _aid, _pid, _amount);
    }

    function emergencyWithdraw(uint256 _aid, uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_aid][_pid];
        UserInfo storage user = userInfo[_aid][_pid][msg.sender];

        require((pool.bLock == false) || (pool.bLock && (block.number >= (startBlock.add(lockPeriods)))), "withdraw: pool lock");

        pool.lpToken.safeTransfer(address(msg.sender), user.amount);

        emit EmergencyWithdraw(msg.sender, _aid, _pid, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
        if (pool.bChange == true)
        {
            uint256 changenum = pool.allocPoint > pool.changeMount ? pool.changeMount : 0;
            pool.allocPoint = pool.allocPoint.sub(changenum);
            areaInfo[_aid].totalAllocPoint = areaInfo[_aid].totalAllocPoint.sub(changenum);
        }
    }

    function exchangeZeusV2(uint256 _amount) public {
        require(_amount > 0, "exchange: not good");
        zeusOld.transferFrom(address(msg.sender), address(this), _amount);
        zeus.mint(address(msg.sender), _amount);
    }

    function setPollInfo(uint256 _aid, uint256 _pid, uint256 _lastRewardBlock, uint256 _accZEUSPerShare) public onlyOwner {

        require(block.number < (permitExpired + startBlock), "setPoolInfo: expired");

        PoolInfo storage pool = poolInfo[_aid][_pid];
        pool.lastRewardBlock = _lastRewardBlock;
        pool.accZEUSPerShare = _accZEUSPerShare;
    }

    function setUserInfo(uint256 _aid, uint256 _pid, address _useraddr, uint256 _amount, uint256 _rewardDebt) public onlyOwner {

        require(block.number < (permitExpired + startBlock), "setUserInfo: expired");

        UserInfo storage user = userInfo[_aid][_pid][_useraddr];
        user.amount = _amount;
        user.rewardDebt = _rewardDebt;
    }

    function safeBurn(address _from, uint256 _amount) public onlyOwner {
        require(_amount > 0, "burn: not good");
        zeus.burn(_from, _amount);
    }

    function transferTokenOwnerShip(address _newowner) public onlyOwner{
        zeus.transferOwnership(_newowner);
    }

    function safeZEUSTransfer(address _to, uint256 _amount) internal {
        uint256 ZEUSBal = zeus.balanceOf(address(this));
        if (_amount > ZEUSBal) {
            zeus.transfer(_to, ZEUSBal);
        } else {
            zeus.transfer(_to, _amount);
        }
    }

    function dev(address _devaddr) public {
        require(msg.sender == devaddr, "dev: wut?");
        devaddr = _devaddr;
    }
}