

pragma solidity ^0.6.6;

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


pragma solidity ^0.6.5;

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

pragma solidity ^0.6.5;

contract EspressoToken is ERC20("Espresso.farm", "ESPR"), Ownable {

    using SafeMath for uint256;

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        return super.transfer(recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {      
        return super.transferFrom(sender, recipient, amount);
    }

    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
    }
    
    function burnFrom(address _from, uint256 _amount) public onlyOwner {
        _burn(_from, _amount);
    }

    function burn(uint256 _amount) public onlyOwner {
        _burn(_msgSender(), _amount);
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
        require(signatory != address(0), "ESPR::delegateBySig: invalid signature");
        require(nonce == nonces[signatory]++, "ESPR::delegateBySig: invalid nonce");
        require(now <= expiry, "ESPR::delegateBySig: signature expired");
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
        require(blockNumber < block.number, "ESPR::getPriorVotes: not yet determined");

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
        uint256 delegatorBalance = balanceOf(delegator); // balance of underlying ESPRs (not scaled);
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
        uint32 blockNumber = safe32(block.number, "ESPR::_writeCheckpoint: block number exceeds 32 bits");

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


pragma solidity ^0.6.5;

contract LatteToken is ERC20("Latte.farm", "LTTE"), Ownable {

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        return super.transfer(recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {      
        return super.transferFrom(sender, recipient, amount);
    }

    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
    }
    
    function burnFrom(address _from, uint256 _amount) public onlyOwner {
        _burn(_from, _amount);
    }

    function burn(uint256 _amount) public onlyOwner {
        _burn(_msgSender(), _amount);
    }
}


pragma solidity ^0.6.5;


interface IMigratorBarista {
    function migrate(IERC20 token) external returns (IERC20);
}



contract Barista is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount;     // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
    }

    struct PoolInfo {
        IERC20 lpToken;                 // Address of LP token contract.
        uint256 allocPoint;             // How many allocation points assigned to this pool. ESPRs to distribute per block.
        uint256 lastRewardBlock;        // Last block number that ESPRs distribution occurs.
        uint256 accEspressoPerShare;    // Accumulated ESPRs per share, times 1e12. See below.
        bool taxable;                   // Accumulated ESPRs per share, times 1e12. See below.
        bool isOpen;
    }

    struct MinorityInfo {
        uint256 amountMinorityVote;     // Number of minority vote
        uint256 endMinorityBlock;       // End of block for the vote
    }
    
    uint256 latteExchangeRate;
    uint256 latteInflationRate;
    uint256 initLatteExchangeRate;
    uint256 initLatteInflationRate;

    EspressoToken public espresso;
    LatteToken public latte;

    address private devaddr;

    uint256 public bonusEndBlock;
    uint256 public espressoPerBlock;
    uint256 public constant BONUS_MULTIPLIER = 1;
    IMigratorBarista public migrator;

    PoolInfo[] public poolInfo;

    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
    uint256 public totalAllocPoint = 0;
    uint256 public startBlock;

    mapping(uint256 => uint256) public poolTotalAmountVote;
    mapping(uint256 => uint256) public poolPreviousTotalAmountVote;
    uint256 public startRewardBlock;
    uint256 public endRewardBlock;
    uint256 private amountRewardBlock = 5760;
    uint256 public selectedPoolPid = 9;
    uint256 public nextSelectedPoolPid = 9;
    uint256 public initialStartRewardBlock = 1;

    mapping (uint256 => mapping (address => MinorityInfo)) public minorityInfo;
    mapping(uint256 => uint256) public minorityTotalAmountVote;
    mapping(uint256 => uint256) public minorityPreviousTotalAmountVote;
    uint256 public amountMinorityReward = 0;
    uint256 public amountMinorityRewardPool = 0;

    uint256 public amountMinorityBlock = 11520;
    uint256 public startMinorityBlock = 1; 
    uint256 public endMinorityBlock = 1;
    uint256 public prevPeriodMinorityVote = 0;
    uint256 public selectedMinorityGid = 9;
    uint256 public nextSelectedMinorityGid = 9;
    uint256 public initialStartMinorityBlock = 1;
    
    uint256 public lpAmount = 0;
    

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    constructor(
        EspressoToken _espresso,
        LatteToken _latte,
        uint256 _latteInflationRate,
        uint256 _latteExchangeRate,
        address _devaddr,
        uint256 _espressoPerBlock,
        uint256 _startBlock,
        uint256 _bonusEndBlock,
        uint256 _startRewardBlock,
        uint256 _amountRewardBlock,
        uint256 _startMinorityBlock,
        uint256 _amountMinorityBlock

    ) public {
        espresso = _espresso;
        latte = _latte;
        latteInflationRate = _latteInflationRate;
        latteExchangeRate = _latteExchangeRate;
        initLatteInflationRate = _latteInflationRate;
        initLatteExchangeRate = _latteExchangeRate;
        devaddr = _devaddr;
        espressoPerBlock = _espressoPerBlock;
        bonusEndBlock = _bonusEndBlock;
        startBlock = _startBlock;

        startRewardBlock = _startRewardBlock;
        amountRewardBlock = _amountRewardBlock;
        endRewardBlock = startRewardBlock.add(amountRewardBlock);
        initialStartRewardBlock = startRewardBlock;
        startMinorityBlock = _startMinorityBlock;
        amountMinorityBlock = _amountMinorityBlock;
        endMinorityBlock = startMinorityBlock.add(amountMinorityBlock);
        initialStartMinorityBlock = startMinorityBlock;
        
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    function add(uint256 _allocPoint, IERC20 _lpToken, bool _withUpdate, bool _taxable, uint256 _startBlock) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = _startBlock;
       
        poolInfo.push(PoolInfo({
            lpToken: _lpToken,
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            accEspressoPerShare: 0,
            taxable: _taxable,
            isOpen: false
        }));
    }

    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate, bool _taxable, uint256 _startBlock) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }

        if (poolInfo[_pid].isOpen) {
            totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        }
       
        poolInfo[_pid].allocPoint = _allocPoint;
        poolInfo[_pid].taxable = _taxable;
        poolInfo[_pid].lastRewardBlock = _startBlock;
    }

    function setBonusEndBlock(uint256 _bonusEndBlock) public onlyOwner {
        bonusEndBlock = _bonusEndBlock;
    }

    function setMigrator(IMigratorBarista _migrator) public onlyOwner {
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

    function pendingEspresso(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accEspressoPerShare = pool.accEspressoPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 espressoReward = multiplier.mul(espressoPerBlock).mul(pool.allocPoint).div(totalAllocPoint);

            if (block.number > endRewardBlock) {
                if (_pid.mod(3) == nextSelectedPoolPid) {
                    espressoReward = multiplier.mul(espressoPerBlock).mul(pool.allocPoint).mul(3).div(totalAllocPoint.add(2400));
                }
            }
            if (block.number >= startRewardBlock && block.number <= endRewardBlock) {
                if (_pid.mod(3) == selectedPoolPid) {
                    espressoReward = multiplier.mul(espressoPerBlock).mul(pool.allocPoint).mul(3).div(totalAllocPoint.add(2400));
                }
            }

            accEspressoPerShare = accEspressoPerShare.add(espressoReward.mul(1e12).div(lpSupply));
        }
        return user.amount.mul(accEspressoPerShare).div(1e12).sub(user.rewardDebt);
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

        if (block.number > pool.lastRewardBlock && pool.isOpen == false) {
            totalAllocPoint = totalAllocPoint.add(pool.allocPoint);
            pool.isOpen = true;
        }

        updatePoolWinner();
        updateMinorityWinner();
        
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }

        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 espressoReward = multiplier.mul(espressoPerBlock).mul(pool.allocPoint).div(totalAllocPoint);

        if (block.number >= startRewardBlock && block.number <= endRewardBlock) {
            if (_pid.mod(3) == selectedPoolPid) {
                espressoReward = multiplier.mul(espressoPerBlock).mul(pool.allocPoint).mul(3).div(totalAllocPoint.add(2400));
            }
        }

        amountMinorityRewardPool = amountMinorityRewardPool.add(espressoReward.div(10));
        espresso.mint(address(this), espressoReward);
        pool.accEspressoPerShare = pool.accEspressoPerShare.add(espressoReward.mul(1e12).div(lpSupply));
        pool.lastRewardBlock = block.number;
    }

    function deposit(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accEspressoPerShare).div(1e12).sub(user.rewardDebt);
            safeEspressoTransfer(msg.sender, pending);
        }
        pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
        user.amount = user.amount.add(_amount);
        user.rewardDebt = user.amount.mul(pool.accEspressoPerShare).div(1e12);
        
        lpAmount = lpAmount.add(_amount);
        emit Deposit(msg.sender, _pid, _amount);
    }

    function withdraw(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accEspressoPerShare).div(1e12).sub(user.rewardDebt);
        safeEspressoTransfer(msg.sender, pending);
        user.amount = user.amount.sub(_amount);
        user.rewardDebt = user.amount.mul(pool.accEspressoPerShare).div(1e12);
        if (pool.taxable) {
            pool.lpToken.safeTransfer(address(devaddr), _amount.mul(25).div(10000));
            emit Withdraw(devaddr, _pid,  _amount.mul(25).div(10000));   
            pool.lpToken.safeTransfer(address(msg.sender), _amount.sub(_amount.mul(25).div(10000)));
            emit Withdraw(msg.sender, _pid, _amount.sub(_amount.mul(25).div(10000)));
        } else {
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
            emit Withdraw(msg.sender, _pid, _amount);
        }
        lpAmount = lpAmount.sub(_amount);
    }

    function emergencyWithdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        pool.lpToken.safeTransfer(address(msg.sender), user.amount);
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
    }

    function safeEspressoTransfer(address _to, uint256 _amount) internal {
        uint256 espressoBal = espresso.balanceOf(address(this));
        if (_amount > espressoBal) {
            espresso.transfer(_to, espressoBal);
        } else {
            espresso.transfer(_to, _amount);
        }
    }

    function getStartVoteBlock() external view returns  (uint256) {
        return this.calculateStartRewardBlock();
    }
    
    function getEndVoteBlock() external view returns  (uint256) {
        return this.calculateStartRewardBlock().add(amountRewardBlock);
    }
    
    function getStartMinorityBlock() external view returns  (uint256) {
        return this.calculateStartMinorityBlock();
    }
    
    function getEndMinorityBlock() external view returns  (uint256) {
        return this.calculateStartMinorityBlock().add(amountMinorityBlock);
    }



    function setVoteBlock(uint256 _startRewardBlock, uint256 _endRewardBlock, uint256 _amountRewardBlock) public onlyOwner {
        startRewardBlock = _startRewardBlock;
        endRewardBlock = _endRewardBlock;
        amountRewardBlock = _amountRewardBlock;
    }

    function getPoolWinner() external view returns (uint256) {
        if ( endRewardBlock >= block.number) {
            return selectedPoolPid;
        }
        
        if (endMinorityBlock < block.number) {
            if (endMinorityBlock == this.calculateStartMinorityBlock().sub(1)) {
                return nextSelectedPoolPid;
            } else {
                return 9;
            }
        }
        
        return 9;
    }

    function getPoolVote(uint256 _pid) external view returns  (uint256) {
        if ( endRewardBlock >= block.number) {
            return poolTotalAmountVote[_pid];
        } 
        
        if (endMinorityBlock < block.number) {
            if (endMinorityBlock == this.calculateStartMinorityBlock().sub(1)) {
               if (_pid == nextSelectedPoolPid) {
                    return 0;
                }
                else {
                    return poolTotalAmountVote[_pid];
                }
            } else {
                return 0;
            }
        }
        
    }
    
     function getPrevPoolVote(uint256 _pid) external view returns  (uint256) {
        if ( endRewardBlock >= block.number) {
            return poolPreviousTotalAmountVote[_pid];
        }
        
        if (endMinorityBlock < block.number) {
            if (endMinorityBlock == this.calculateStartMinorityBlock().sub(1)) {
                return poolTotalAmountVote[_pid];
            } else {
                return 0;
            }
        }
        
        return 0;
    }

    function updatePoolWinner() public {
        
        if (block.number > endRewardBlock) {
            startRewardBlock = this.calculateStartRewardBlock();
            endRewardBlock = startRewardBlock.add(amountRewardBlock);
            
            if (nextSelectedPoolPid < 9) {
                
                poolPreviousTotalAmountVote[0] = poolTotalAmountVote[0];
                poolPreviousTotalAmountVote[1] = poolTotalAmountVote[1];
                poolPreviousTotalAmountVote[2] = poolTotalAmountVote[2];
                
                poolTotalAmountVote[nextSelectedPoolPid] = 0;
                
                selectedPoolPid = nextSelectedPoolPid;
                nextSelectedPoolPid = 9;
            }
        }
    }

    function checkPoolWinner() public {
        nextSelectedPoolPid = 9;
        
        if (poolTotalAmountVote[0] > poolTotalAmountVote[1] && poolTotalAmountVote[0] > poolTotalAmountVote[2]) {
            nextSelectedPoolPid = 0;
        } 
        
        if (poolTotalAmountVote[1] > poolTotalAmountVote[0] && poolTotalAmountVote[1] > poolTotalAmountVote[2]) {
            nextSelectedPoolPid = 1;
        } 
        
        if (poolTotalAmountVote[2] > poolTotalAmountVote[0] && poolTotalAmountVote[2] > poolTotalAmountVote[1]) {
            nextSelectedPoolPid = 2;
        } 
        
    }

    function votePool(uint256 _amount, uint256 _groupId) public {
        require(latte.balanceOf(address(msg.sender)) >= _amount, "Not enough token");
        latte.burnFrom(_msgSender(), _amount);
        
        updatePoolWinner();
        
        poolTotalAmountVote[_groupId] = poolTotalAmountVote[_groupId].add(_amount.div(1e18));

        checkPoolWinner();
        
    }

    function exchange(uint256 _amount) external {
        require(espresso.balanceOf(address(_msgSender())) >= _amount, "Not enough espresso");
        
        updateMinorityWinner();
        
        uint256 swapAmount = _amount.div(1e18).div(latteExchangeRate);
        
        espresso.burnFrom(address(_msgSender()), _amount);

        latte.mint(address(_msgSender()), swapAmount.mul(1e18));
        
        latteExchangeRate = latteExchangeRate.add(latteInflationRate.mul(swapAmount));
    }

    function getExchangeRateToken() external view returns (uint256) {
        return latteExchangeRate;
    }

    function setExchangeToken(uint256 _latteExchangeRate, uint256 _latteInflationRate) public onlyOwner {
        latteExchangeRate = _latteExchangeRate;
        latteInflationRate = _latteInflationRate;
    }


    function pendingMinorityEspresso(address _account) external view returns (uint256) {
        if (endMinorityBlock >= block.number) {
            if (selectedMinorityGid < 9) {
                if ((minorityInfo[selectedMinorityGid][_account].endMinorityBlock) == (endMinorityBlock - amountMinorityBlock - 1)) {
                    if (minorityInfo[selectedMinorityGid][_account].amountMinorityVote > 0) {
                        if (prevPeriodMinorityVote > 0) {
                            uint256 pending = minorityInfo[selectedMinorityGid][_account].amountMinorityVote.mul(amountMinorityReward).div(
                            prevPeriodMinorityVote);
                            return pending;
                        }
                    } 
                }
            }
        } 
        
        if (endMinorityBlock < block.number) {
            if (nextSelectedMinorityGid < 9) {
                if (minorityInfo[nextSelectedMinorityGid][_account].endMinorityBlock == this.calculateStartMinorityBlock().sub(1)) {
                    if (minorityInfo[nextSelectedMinorityGid][_account].endMinorityBlock < block.number) 
                    {
                        if (minorityInfo[nextSelectedMinorityGid][_account].amountMinorityVote > 0) {
                           
                            if (minorityTotalAmountVote[nextSelectedMinorityGid]  == 0) {
                                return 0;
                            }
                            uint256 amountMinorityRewardTemp = amountMinorityRewardPool.mul(25).div(100);
                            uint256 pending = minorityInfo[nextSelectedMinorityGid][_account].amountMinorityVote.mul(amountMinorityRewardTemp).div(
                                    minorityTotalAmountVote[nextSelectedMinorityGid]);
                            return pending;
                        } 
                    } 
                }
            }
        }
        
        
        return 0;
        
    }

    function setMinorityBlock(uint256 _startMinorityBlock, uint256 _endMinorityBlock) public onlyOwner {
        startMinorityBlock = _startMinorityBlock;
        endMinorityBlock = _endMinorityBlock;    
    }
    
    function calculateStartMinorityBlock() external view returns (uint256) {
        uint256 subtractor = (block.number.sub(initialStartMinorityBlock)).mod(amountMinorityBlock.add(1));
        return block.number.sub(subtractor);
    }
    
    function calculateStartRewardBlock() external view returns (uint256) {
        uint256 subtractor = (block.number.sub(initialStartRewardBlock)).mod(amountRewardBlock.add(1));
        return block.number.sub(subtractor);
    }

    function updateMinorityWinner() public {
        if (block.number > endMinorityBlock) {

            startMinorityBlock = this.calculateStartMinorityBlock();
            endMinorityBlock = startMinorityBlock.add(amountMinorityBlock);
            
            
            if (nextSelectedMinorityGid < 9) {    
                amountMinorityReward = amountMinorityRewardPool.mul(25).div(100);
                
                amountMinorityRewardPool = amountMinorityRewardPool.sub(amountMinorityReward);
                
                espresso.mint(address(this), amountMinorityReward);
                
                prevPeriodMinorityVote = minorityTotalAmountVote[nextSelectedMinorityGid];
            }   
                

            minorityPreviousTotalAmountVote[0] = minorityTotalAmountVote[0];
            minorityPreviousTotalAmountVote[1] = minorityTotalAmountVote[1];
            minorityPreviousTotalAmountVote[2] = minorityTotalAmountVote[2];
            minorityTotalAmountVote[0] = 0;
            minorityTotalAmountVote[1] = 0;
            minorityTotalAmountVote[2] = 0;
                
            selectedMinorityGid = nextSelectedMinorityGid;
                
            nextSelectedMinorityGid = 9;
          
            latteInflationRate = initLatteInflationRate;
            latteExchangeRate = initLatteExchangeRate;

        }
    }
    
    function getAmountMinorityRewardPool() external view returns (uint256) {
        if ( endMinorityBlock >= block.number) {
            return amountMinorityRewardPool;
        }
        
        return amountMinorityRewardPool.mul(3).div(4);
    }
    
    function getMinorityPrevTotalVote(uint256 _gid) external view returns  (uint256) {
        if ( endMinorityBlock >= block.number) {
            return minorityPreviousTotalAmountVote[_gid];
        }
        
        if (endMinorityBlock < block.number) {
            if (endMinorityBlock == this.calculateStartMinorityBlock().sub(1)) {
                return minorityTotalAmountVote[_gid];
            } else {
                return 0;
            }
        }
        return 0;
    }
    
    function getMinorityTotalVote(uint256 _gid) external view returns  (uint256) {
        if ( endMinorityBlock >= block.number) {
            return minorityTotalAmountVote[_gid];
        }
        
        return 0;
    }
    
    function getMinorityVote(uint256 _gid, address _account) external view returns  (uint256) {
        if ( minorityInfo[_gid][_account].endMinorityBlock > block.number) {
                return minorityInfo[_gid][_account].amountMinorityVote;
        }
        return 0;
    }
    
    function getMinorityWinner() external view returns  (uint256) {
        if ( endMinorityBlock >= block.number) {
            return selectedMinorityGid;
        }
        if (endMinorityBlock < block.number) {
            if (endMinorityBlock == this.calculateStartMinorityBlock().sub(1)) {
                return nextSelectedMinorityGid;
            } else {
                return 9;
            }
        }
        return 9;
    }

    function withdrawMinorityReward() public {
        updateMinorityWinner();
        if (selectedMinorityGid < 9) {
            if ((minorityInfo[selectedMinorityGid][msg.sender].endMinorityBlock) == this.calculateStartMinorityBlock().sub(1)) {
                if (minorityInfo[selectedMinorityGid][msg.sender].amountMinorityVote > 0) {
                    uint256 pending = minorityInfo[selectedMinorityGid][msg.sender].amountMinorityVote.mul(amountMinorityReward).div(prevPeriodMinorityVote);
                    safeEspressoTransfer(msg.sender, pending);                    
                }
            }
        }
        
        for (uint256 gid = 0; gid < 3; ++gid) {
            minorityInfo[gid][msg.sender].amountMinorityVote = 0;
            minorityInfo[gid][msg.sender].endMinorityBlock = endMinorityBlock;
        }
    }
    
    function checkMinorityWinner() public {
        nextSelectedMinorityGid = 9;
        
        if (minorityTotalAmountVote[0] < minorityTotalAmountVote[1] && minorityTotalAmountVote[0] < minorityTotalAmountVote[2]) {
            nextSelectedMinorityGid = 0;
        } 
        
        if (minorityTotalAmountVote[1] < minorityTotalAmountVote[0] && minorityTotalAmountVote[1] < minorityTotalAmountVote[2]) {
            nextSelectedMinorityGid = 1;
        } 
        
        if (minorityTotalAmountVote[2] < minorityTotalAmountVote[0] && minorityTotalAmountVote[2] < minorityTotalAmountVote[1]) {
            nextSelectedMinorityGid = 2;
        } 
        
    }

    function voteMinority(uint256 _amount, uint256 _groupId) public {
        require(latte.balanceOf(address(_msgSender())) >= _amount, "Not enough token");
        
        updateMinorityWinner();
        
        latte.burnFrom(_msgSender(), _amount);
        minorityTotalAmountVote[_groupId] = minorityTotalAmountVote[_groupId].add(_amount.div(1e18));
        
        if ( minorityInfo[_groupId][_msgSender()].endMinorityBlock < block.number) {
            withdrawMinorityReward();
        }
        
        minorityInfo[_groupId][_msgSender()].amountMinorityVote = minorityInfo[_groupId][_msgSender()].amountMinorityVote.add(_amount.div(1e18));
        minorityInfo[_groupId][_msgSender()].endMinorityBlock = endMinorityBlock;

        checkMinorityWinner();
    
    }
}