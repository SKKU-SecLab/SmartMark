
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
}// MIT

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
}// MIT

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
}// MIT

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
}// MIT

pragma solidity >=0.6.0 <0.8.0;

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


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
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
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

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

}// MIT

pragma solidity ^0.7.0;


contract Ownable is Context {
    address private _owner;
    address private proposedOwner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
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
        proposedOwner = address(0);
    }

    function proposeOwner(address _proposedOwner) public onlyOwner {
        require(msg.sender != _proposedOwner, "ERROR_CALLER_ALREADY_OWNER");
        proposedOwner = _proposedOwner;
    }

    function claimOwnership() public {
        require(msg.sender == proposedOwner, "ERROR_NOT_PROPOSED_OWNER");
        emit OwnershipTransferred(_owner, proposedOwner);
        _owner = proposedOwner;
        proposedOwner = address(0);
    }
}// MIT

pragma solidity ^0.7.0;


contract BambooToken is ERC20("BambooDeFi", "BAMBOO"), Ownable {
    using SafeMath for uint256;

    mapping(address => address) internal _delegates;

    struct Checkpoint {
        uint256 fromBlock;
        uint256 votes;
    }

    mapping(address => mapping(uint32 => Checkpoint)) public checkpoints;

    mapping(address => uint32) public numCheckpoints;

    bytes32 public constant DOMAIN_TYPEHASH = keccak256(
        "EIP712Domain(string name,uint256 chainId,address verifyingContract)"
    );

    bytes32 public constant DELEGATION_TYPEHASH = keccak256(
        "Delegation(address delegatee,uint256 nonce,uint256 expiry)"
    );

    mapping(address => uint256) public nonces;

    event DelegateChanged(
        address indexed delegator,
        address indexed fromDelegate,
        address indexed toDelegate
    );

    event DelegateVotesChanged(
        address indexed delegate,
        uint256 previousBalance,
        uint256 newBalance
    );

    event Minted(
        address indexed minter,
        address indexed receiver,
        uint256 mintAmount
    );
    event Burned(address indexed burner, uint256 burnAmount);

    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
        emit Minted(owner(), _to, _amount);
    }

    function burn(uint256 _amount) public {
        _burn(msg.sender, _amount);
        emit Burned(msg.sender, _amount);
    }

    function delegate(address delegatee) external {
        return _delegate(msg.sender, delegatee);
    }

    function delegateBySig(
        address delegatee,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        bytes32 domainSeparator = keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                keccak256(bytes(name())),
                getChainId(),
                address(this)
            )
        );

        bytes32 structHash = keccak256(
            abi.encode(DELEGATION_TYPEHASH, delegatee, nonce, expiry)
        );

        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", domainSeparator, structHash)
        );

        address signatory = ecrecover(digest, v, r, s);
        require(
            signatory != address(0),
            "BAMBOO::delegateBySig: invalid signature"
        );
        require(
            nonce == nonces[signatory]++,
            "BAMBOO::delegateBySig: invalid nonce"
        );
        require(block.timestamp <= expiry, "BAMBOO::delegateBySig: signature expired");
        return _delegate(signatory, delegatee);
    }

    function delegates(address delegator) external view returns (address) {
        return _delegates[delegator];
    }

    function getCurrentVotes(address account) external view returns (uint256) {
        uint32 nCheckpoints = numCheckpoints[account];
        return
            nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    function getPriorVotes(address account, uint256 blockNumber)
        external
        view
        returns (uint256)
    {
        require(
            blockNumber < block.number,
            "BAMBOO::getPriorVotes: not yet determined"
        );

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

    function _delegate(address delegator, address delegatee) internal {
        address currentDelegate = _delegates[delegator];
        uint256 delegatorBalance = balanceOf(delegator); // balance of underlying BAMBOOs (not scaled);
        _delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _moveDelegates(
        address srcRep,
        address dstRep,
        uint256 amount
    ) internal {
        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint256 srcRepOld = srcRepNum > 0
                    ? checkpoints[srcRep][srcRepNum - 1].votes
                    : 0;
                uint256 srcRepNew = srcRepOld.sub(amount);
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint256 dstRepOld = dstRepNum > 0
                    ? checkpoints[dstRep][dstRepNum - 1].votes
                    : 0;
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
    ) internal {
        uint256 blockNumber = block.number;

        if (
            nCheckpoints > 0 &&
            checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber
        ) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(
                blockNumber,
                newVotes
            );
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }

        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    function getChainId() internal pure returns (uint256) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return chainId;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        _moveDelegates(_delegates[from], _delegates[to], amount);
    }
}// MIT

pragma solidity ^0.7.0;



interface IMigratorKeeper {
    function migrate(IERC20 token) external returns (IERC20);
}

contract ZooKeeper is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 public constant TIME_REWARDS_LENGTH = 12;

    uint256[TIME_REWARDS_LENGTH] public timeRewards = [1 days, 7 days, 15 days, 30 days, 60 days, 90 days, 180 days, 365 days, 730 days, 1095 days, 1460 days, 1825 days];
    mapping(uint256 => bool) public validTimeRewards;

    struct  LpUserInfo {
        uint256 amount;         // How many LP tokens the user has provided.
        uint256 rewardDebt;     // Reward debt. See explanation below.
        uint256 lastLpDeposit;   // Last time user made a deposit
    }

    struct  BambooDeposit {
        uint256 amount;             // How many BAMBOO tokens the user has deposited.
        uint256 lockTime;           // Time in seconds that need to pass before this deposit can be withdrawn.
        bool active;                // Flag for checking if this entry is actively staking.
        uint256 totalReward;        // The total reward that will be collected from this deposit.
        uint256 dailyReward;        // The amount of bamboo that could be claimed daily.
        uint256 lastTime;           // Last timestamp when the daily rewards where collected.
    }

    struct BambooUserInfo {
        mapping(uint256 => BambooDeposit) deposits;    // Deposits from the user.
        uint256[] ids;                                  // Active deposits from the user.
        uint256 totalAmount;                            // Total amount of active deposits from the user.
        uint256 lastDeposit;                            // Timestamp of last deposit from user
    }

    struct StakeMultiplierInfo {
        uint256[TIME_REWARDS_LENGTH] multiplierBonus;       // Array of the different multipliers.
        bool registered;                                    // If this amount has been registered
    }

    struct YieldMultiplierInfo {
        uint256 multiplier;                                 // Multiplier value.
        bool registered;                                    // If this amount has been registered
    }

    struct PoolInfo {
        IERC20 lpToken;           // Address of LP token contract.
        uint256 allocPoint;       // How many allocation points assigned to this pool. BAMBOOs to distribute per block.
        uint256 lastRewardBlock;  // Last block number that BAMBOOs distribution occurs.
        uint256 accBambooPerShare; // Accumulated BAMBOOs per share, times 1e12. See below.
    }

    BambooToken public bamboo;
    uint256 public bambooPerBlock;
    IMigratorKeeper public migrator;
    BambooField public bambooField;
    bool public isField;
    PoolInfo[] public poolInfo;
    mapping(uint256 => mapping (address => LpUserInfo)) public userInfo;
    mapping(uint256 => StakeMultiplierInfo) public stakeMultipliers;
    mapping(uint256 => YieldMultiplierInfo) public yieldMultipliers;
    uint256[] public yieldAmounts;
    mapping(address => BambooUserInfo) public bambooUserInfo;
    uint256 public totalAllocPoint = 0;
    uint256 public startBlock;
    uint256 public minYieldTime = 7 days;
    uint256 public minStakeTime = 1 days;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event BAMBOODeposit(address indexed user, uint256 amount, uint256 lockTime, uint256 id);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event BAMBOOWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event BAMBOOBonusWithdraw(address indexed user, uint256 indexed pid, uint256 amount, uint256 ndays);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    modifier onlyEOA() {
        require(msg.sender == tx.origin, "ZooKeeper: must use EOA");
        _;
    }

    constructor(BambooToken _bamboo, uint256 _bambooPerBlock, uint256 _startBlock) {
        require(_bambooPerBlock > 0, "invalid bamboo per block");
        bamboo = _bamboo;
        bambooPerBlock = _bambooPerBlock;
        startBlock = _startBlock;
        for(uint i=0; i<TIME_REWARDS_LENGTH; i++) {
            validTimeRewards[timeRewards[i]] = true;
        }
    }


    function add(uint256 _allocPoint, IERC20 _lpToken) public onlyOwner {
        massUpdatePools();
        checkPoolDuplicate(_lpToken);
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(PoolInfo({
            lpToken: _lpToken,
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            accBambooPerShare: 0
        }));
    }

    function set(uint256 _pid, uint256 _allocPoint) public onlyOwner {
        massUpdatePools();
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    function setMigrator(IMigratorKeeper _migrator) public onlyOwner {
        migrator = _migrator;
    }

    function migrate(uint256 _pid) public onlyOwner {
        require(address(migrator) != address(0), "migrate: no migrator");
        PoolInfo storage pool = poolInfo[_pid];
        IERC20 lpToken = pool.lpToken;
        uint256 bal = lpToken.balanceOf(address(this));
        lpToken.safeApprove(address(migrator), bal);
        IERC20 newLpToken = migrator.migrate(lpToken);
        require(bal == newLpToken.balanceOf(address(this)), "migrate: bad");
        pool.lpToken = newLpToken;
    }


    function addStakeMultiplier(uint256 _amount, uint256[TIME_REWARDS_LENGTH] memory _multiplierBonuses) public onlyOwner {
        require(_amount > 0, "addStakeMultiplier: invalid amount");
        for(uint i=0; i<TIME_REWARDS_LENGTH; i++){
            require(_multiplierBonuses[i] >= 10000, "addStakeMultiplier: invalid multiplier array");
        }
        uint mLength = _multiplierBonuses.length;
        require(mLength== TIME_REWARDS_LENGTH, "addStakeMultiplier: invalid array length");
        StakeMultiplierInfo memory mInfo = StakeMultiplierInfo({multiplierBonus: _multiplierBonuses, registered:true});
        stakeMultipliers[_amount] = mInfo;
    }


    function addYieldMultiplier(uint256 _amount, uint256 _multiplierBonus ) public onlyOwner {
        require(_amount > 0, "addYieldMultiplier: invalid amount");
        require(_multiplierBonus >= 10000, "addYieldMultiplier: invalid multiplier");
        if(!yieldMultipliers[_amount].registered){
            yieldAmounts.push(_amount);
        }
        YieldMultiplierInfo memory mInfo = YieldMultiplierInfo({multiplier: _multiplierBonus, registered:true});
        yieldMultipliers[_amount] = mInfo;
    }

    function removeStakeMultiplier(uint256 _amount) public onlyOwner {
        require(stakeMultipliers[_amount].registered, "removeStakeMultiplier: nothing to remove");
        delete(stakeMultipliers[_amount]);
    }

    function removeYieldMultiplier(uint256 _amount) public onlyOwner {
        require(yieldMultipliers[_amount].registered, "removeYieldMultiplier: nothing to remove");
        for(uint i=0; i<yieldAmounts.length; i++) {
            if(yieldAmounts[i] == _amount){
                yieldAmounts[i] = yieldAmounts[yieldAmounts.length -1];
                yieldAmounts.pop();
                break;
            }
        }
        delete(yieldMultipliers[_amount]);
    }

    function getStakingMultiplier(uint256 _time, uint256 _amount) public view returns (uint256) {
        uint256 index = getTimeEarned(_time);
        StakeMultiplierInfo storage multiInfo = stakeMultipliers[_amount];
        require(multiInfo.registered, "getStakingMultiplier: invalid amount");
        uint256 res = multiInfo.multiplierBonus[index];
        return res;
    }

    function getYieldMultiplier(uint256 _amount) public view returns (uint256) {
        uint256 key=0;
        for(uint i=0; i<yieldAmounts.length; i++) {
            if (_amount >= yieldAmounts[i] ) {
                key = yieldAmounts[i];
            }
        }
        if(key == 0) {
            return 10000;
        }
        else {
            return yieldMultipliers[key].multiplier;
        }
    }

    function getDeposits(address _user) public view returns (uint256[] memory) {
        return bambooUserInfo[_user].ids;
    }

    function getDepositInfo(address _user, uint256 _id) public view returns (uint256, uint256) {
        BambooDeposit storage _deposit = bambooUserInfo[_user].deposits[_id];
        require(_deposit.active, "deposit does not exist");
        return (_deposit.amount, _id.add(_deposit.lockTime));
    }

    function getClaimableBamboo(uint256 _id, address _addr ) public view returns(uint256, uint256) {
        BambooUserInfo storage user = bambooUserInfo[_addr];
        if(block.timestamp >= _id.add(user.deposits[_id].lockTime) ){
            uint pastdays = user.deposits[_id].lastTime.sub(_id).div(1 days);
            uint256 leftToClaim = user.deposits[_id].totalReward.sub(pastdays.mul(user.deposits[_id].dailyReward));
            return (leftToClaim, (user.deposits[_id].lockTime.div(1 days)).sub(pastdays));
        }
        else{
            uint256 ndays = (block.timestamp.sub(user.deposits[_id].lastTime)).div(1 days);
            return (ndays.mul(user.deposits[_id].dailyReward), ndays);
        }
    }


    function pendingBamboo(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        LpUserInfo storage user = userInfo[_pid][_user];
        uint256 bambooUserAmount = bambooUserInfo[_user].totalAmount;
        uint256 accBambooPerShare = pool.accBambooPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        uint256 yMultiplier = 10000;
        if (block.timestamp - user.lastLpDeposit > minYieldTime && block.timestamp - bambooUserInfo[_user].lastDeposit > minStakeTime) {
            yMultiplier = getYieldMultiplier(bambooUserAmount);
        }
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = block.number.sub(pool.lastRewardBlock);
            uint256 bambooReward = multiplier.mul(bambooPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accBambooPerShare = accBambooPerShare.add(bambooReward.mul(1e12).div(lpSupply));
        }
        uint256 pending = user.amount.mul(accBambooPerShare).div(1e12).sub(user.rewardDebt);
        return yMultiplier.mul(pending).div(10000);
    }

    function pendingStakeBamboo(uint256 _id, address _addr) external view returns (uint256, uint256) {
        BambooUserInfo storage user = bambooUserInfo[_addr];
        require(user.deposits[_id].active, "pendingStakeBamboo: invalid id");
        uint256 claimable;
        uint256 ndays;
        (claimable, ndays) = getClaimableBamboo(_id, _addr);
        if (block.timestamp.sub(user.deposits[_id].lastTime) >= user.deposits[_id].lockTime){
            return (claimable, claimable);
        }
        else{
            uint pastdays = user.deposits[_id].lastTime.sub(_id).div(1 days);
            uint256 leftToClaim = user.deposits[_id].totalReward.sub(pastdays.mul(user.deposits[_id].dailyReward));
            return (leftToClaim, claimable);
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
        uint256 multiplier = block.number.sub(pool.lastRewardBlock);
        uint256 bambooReward = multiplier.mul(bambooPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
        bamboo.mint(address(this), bambooReward);
        pool.accBambooPerShare = pool.accBambooPerShare.add(bambooReward.mul(1e12).div(lpSupply));
        pool.lastRewardBlock = block.number;
    }

    function deposit(uint256 _pid, uint256 _amount) public onlyEOA {
        require ( _pid < poolInfo.length , "deposit: pool exists?");
        PoolInfo storage pool = poolInfo[_pid];
        LpUserInfo storage user = userInfo[_pid][msg.sender];
        uint256 bambooUserAmount = bambooUserInfo[msg.sender].totalAmount;
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accBambooPerShare).div(1e12).sub(user.rewardDebt);
            if (pending > 0) {
                uint256 bonus = mintBonusBamboo(pending, user.lastLpDeposit, bambooUserInfo[msg.sender].lastDeposit, bambooUserAmount);
                safeBambooTransfer(msg.sender, pending.add(bonus));
            }
        }
        if(_amount > 0) {
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);
            user.lastLpDeposit = block.timestamp;
        }
        user.rewardDebt = user.amount.mul(pool.accBambooPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }

    function depositBamboo(uint256 _amount, uint256 _lockTime) public onlyEOA {
        require(stakeMultipliers[_amount].registered, "depositBamboo: invalid amount");
        require(validTimeRewards[_lockTime] , "depositBamboo: invalid lockTime");
        BambooUserInfo storage user = bambooUserInfo[msg.sender];
        require(!user.deposits[block.timestamp].active, "depositBamboo: only 1 deposit per block!");
        if(_amount > 0) {
            IERC20(bamboo).safeTransferFrom(address(msg.sender), address(this), _amount);
            uint256 multiplier = getStakingMultiplier(_lockTime, _amount);
            uint256 pending = (multiplier.mul(_amount).div(10000)).sub(_amount);
            uint totaldays = _lockTime / 1 days;
            BambooDeposit memory depositData = BambooDeposit({
                amount: _amount,
                lockTime: _lockTime,
                active: true,
                totalReward:pending,
                dailyReward:pending.div(totaldays),
                lastTime: block.timestamp
            });
            user.ids.push(block.timestamp);
            user.deposits[block.timestamp] = depositData;
            user.totalAmount = user.totalAmount.add(_amount);
            user.lastDeposit = block.timestamp;
        }
        emit BAMBOODeposit(msg.sender, _amount, _lockTime, block.timestamp);
    }


    function withdraw(uint256 _pid, uint256 _amount) public onlyEOA {
        PoolInfo storage pool = poolInfo[_pid];
        LpUserInfo storage user = userInfo[_pid][msg.sender];
        uint256 bambooUserAmount = bambooUserInfo[msg.sender].totalAmount;
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accBambooPerShare).div(1e12).sub(user.rewardDebt);
        if(pending > 0) {
            uint256 bonus = mintBonusBamboo(pending, user.lastLpDeposit, bambooUserInfo[msg.sender].lastDeposit, bambooUserAmount);
            safeBambooTransfer(msg.sender, pending.add(bonus));
        }
        if(_amount > 0){
            user.amount = user.amount.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
            if(user.amount == 0 && isField){
                if(bambooField.isActive(msg.sender, _pid)){
                    bambooField.updatePool(msg.sender);
                }
            }
        }
        user.rewardDebt = user.amount.mul(pool.accBambooPerShare).div(1e12);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function withdrawBamboo(uint256 _depositId) public onlyEOA {
        BambooUserInfo storage user = bambooUserInfo[msg.sender];
        require(user.deposits[_depositId].active, "withdrawBamboo: invalid id");
        uint256 depositEnd = _depositId.add(user.deposits[_depositId].lockTime) ;
        uint depositIndex = 0;
        for (uint i=0; i<user.ids.length; i++){
            if (user.ids[i] == _depositId){
                depositIndex = i;
                break;
            }
        }
        require(user.ids[depositIndex] == _depositId, "withdrawBamboo: invalid id");
        require(block.timestamp >= depositEnd, "withdrawBamboo: cannot withdraw yet!");
        uint256 amount = user.deposits[_depositId].amount;
        withdrawDailyBamboo(_depositId);
        user.ids[depositIndex] = user.ids[user.ids.length -1];
        user.ids.pop();
        user.totalAmount = user.totalAmount.sub(user.deposits[_depositId].amount);
        delete user.deposits[_depositId];
        safeBambooTransfer(msg.sender, amount);
        emit BAMBOOWithdraw(msg.sender, _depositId, amount);
    }

    function withdrawDailyBamboo(uint256 _depositId) public onlyEOA {
        BambooUserInfo storage user = bambooUserInfo[msg.sender];
        require(user.deposits[_depositId].active, "withdrawDailyBamboo: invalid id");
        uint256 depositEnd = _depositId.add(user.deposits[_depositId].lockTime);
        uint256 amount;
        uint256 ndays;
        (amount, ndays) = getClaimableBamboo(_depositId, msg.sender);
        uint256 newLastTime =  user.deposits[_depositId].lastTime.add(ndays.mul(1 days));
        assert(newLastTime <= depositEnd);
        user.deposits[_depositId].lastTime =  newLastTime;
        bamboo.mint(msg.sender, amount);
        emit BAMBOOBonusWithdraw(msg.sender, _depositId, amount, ndays);
    }

    function mintBonusBamboo(uint256 pending, uint256 lastLp, uint256 lastStake, uint256 bambooUserAmount) internal returns (uint256) {
        if (block.timestamp - lastLp > minYieldTime && block.timestamp - lastStake > minStakeTime && bambooUserAmount > 0) {
            uint256 multiplier = getYieldMultiplier(bambooUserAmount);
            uint256 pmul = multiplier.mul(pending).div(10000);
            uint256 bonus = pmul.sub(pending);
            bamboo.mint(address(this), bonus);
            return bonus;
        }
        return 0;
    }

    function emergencyWithdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        LpUserInfo storage user = userInfo[_pid][msg.sender];
        uint256 _amount=user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        pool.lpToken.safeTransfer(address(msg.sender), _amount);
        emit EmergencyWithdraw(msg.sender, _pid, _amount);
    }

    function getTimeEarned(uint256 _time) internal view returns (uint256) {
        require(_time >= timeRewards[0], "getTimeEarned: invalid time");
        uint256 index=0;
        for(uint i=1; i<TIME_REWARDS_LENGTH; i++) {
            if (_time >= timeRewards[i] ) {
                index = i;
            }
            else{
                break;
            }
        }
        return index;
    }

    function safeBambooTransfer(address _to, uint256 _amount) internal {
        uint256 bambooBal = bamboo.balanceOf(address(this));
        if (_amount > bambooBal) {
            IERC20(bamboo).safeTransfer(_to, bambooBal);
        } else {
            IERC20(bamboo).safeTransfer(_to, _amount);
        }
    }

    function checkPoolDuplicate (IERC20 _lpToken) public view {
         uint256 length = poolInfo.length;
         for(uint256 pid = 0; pid < length ; ++pid) {
            require (poolInfo[pid].lpToken != _lpToken , "add: existing pool?");
        }
    }

    function getPoolLength() public view returns(uint count) {
        return poolInfo.length;
    }

    function getLpAmount(uint _pid, address _user) public view returns(uint256) {
        return userInfo[_pid][_user].amount;
    }

    function switchBamboField(BambooField _bf) public onlyOwner {
        if(isField){
            isField = false;
        }
        else{
            isField = true;
            bambooField = _bf;
        }
    }

    function claimToken() public onlyOwner {
        bamboo.claimOwnership();
    }

    function minYield(uint256 _yTime, uint256 _sTime) public onlyOwner {
        minYieldTime = _yTime;
        minStakeTime = _sTime;
    }

    function changeBambooPerBlock(uint256 _bamboo) public onlyOwner {
        require(_bamboo > 0, "changeBambooPerBlock: invalid amount");
        bambooPerBlock = _bamboo;
    }
}// MIT

pragma solidity ^0.7.0;


contract BambooField is ERC20("Seed", "SEED"), Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    mapping (address => FarmUserInfo) public userInfo;
    BambooToken public bamboo;
    ZooKeeper public zooKeeper;
    uint256 public registerAmount;
    uint256 public depositPool;
    uint256 public minStakeTime;

    struct FarmUserInfo {
        uint256 amount;             // Deposited Amount
        uint poolId;                // Pool ID of active staking LP
        uint256 startTime;          // Timestamp of registration
        bool active;                // Flag for checking if this entry is active.
        uint256 endTime;            // Last timestamp the user can buy seeds. Only used if this is not active
    }

    event RegisterAmountChanged(uint256 amount);
    event StakeTimeChanged(uint256 time);

    constructor(BambooToken _bamboo, ZooKeeper _zoo, uint256 _registerprice, uint256 _minstaketime) {
        bamboo= _bamboo;
        zooKeeper = _zoo;
        registerAmount = _registerprice;
        minStakeTime = _minstaketime;
    }

    function register(uint _pid, uint256 _amount) public {
        require( _pid < zooKeeper.getPoolLength() , "register: invalid pool");
        require(_amount > registerAmount, "register: amount should be bigger than registerAmount");
        require(userInfo[msg.sender].amount == 0, "register: already registered");
        uint256 amount = zooKeeper.getLpAmount(_pid, msg.sender);
        require(amount > 0, 'register: no LP on pool');
        uint256 seedAmount = _amount.sub(registerAmount);
        IERC20(bamboo).safeTransferFrom(address(msg.sender), address(this), registerAmount);
        depositPool = depositPool.add(registerAmount);
        userInfo[msg.sender] = FarmUserInfo(registerAmount, _pid, block.timestamp, true, 0);
        buy(seedAmount);
    }

    function buy(uint256 _amount) public {
        if(!userInfo[msg.sender].active) {
            require(userInfo[msg.sender].endTime >= block.timestamp, "buy: invalid user");
        }
        uint256 totalBamboo = bamboo.balanceOf(address(this)).sub(depositPool);
        uint256 totalShares = totalSupply();
        if (totalShares == 0 || totalBamboo == 0) {
            _mint(msg.sender, _amount);
        }
        else {
            uint256 what = _amount.mul(totalShares).div(totalBamboo);
            _mint(msg.sender, what);
        }
        IERC20(bamboo).safeTransferFrom(address(msg.sender), address(this), _amount);
    }

    function harvest(uint256 _share) public {
        require(block.timestamp.sub(userInfo[msg.sender].startTime) >= minStakeTime, "buy: cannot harvest seeds at this time");
        uint256 totalShares = totalSupply();
        uint256 totalBamboo = bamboo.balanceOf(address(this)).sub(depositPool);
        uint256 what = _share.mul(totalBamboo).div(totalShares);
        _burn(msg.sender, _share);
        IERC20(bamboo).safeTransfer(msg.sender, what);
    }

    function withdraw() public {
        require(block.timestamp.sub(userInfo[msg.sender].startTime) >= minStakeTime, "withdraw: cannot withdraw yet!");
        uint256 seeds = balanceOf(msg.sender);
        if (seeds>0){
            harvest (seeds);
        }
        uint256 deposit = userInfo[msg.sender].amount;
        delete(userInfo[msg.sender]);
        IERC20(bamboo).safeTransfer(msg.sender, deposit);
        depositPool = depositPool.sub(deposit);
    }

    function updatePool(address _user) external {
        require(ZooKeeper(msg.sender) == zooKeeper, "updatePool: contract was not ZooKeeper");
        userInfo[_user].active = false;
        if(block.timestamp - userInfo[_user].startTime >= 60 days){
            userInfo[_user].endTime = block.timestamp + 60 days;
        }
    }

    function setRegisterAmount(uint256 _amount) external onlyOwner {
        registerAmount = _amount;
        emit RegisterAmountChanged(registerAmount);
    }

    function setStakeTime(uint256 _mintime) external onlyOwner {
        minStakeTime = _mintime;
        emit StakeTimeChanged(minStakeTime);
    }

    function isActive(address _user, uint _pid) public view returns(bool) {
        return userInfo[_user].active && userInfo[_user].poolId == _pid;
    }

}