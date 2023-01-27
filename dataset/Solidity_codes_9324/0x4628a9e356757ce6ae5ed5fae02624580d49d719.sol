

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


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


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
}


pragma solidity ^0.6.0;


contract ContextUpgradeSafe is Initializable {


    function __Context_init() internal initializer {

        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {



    }


    function _msgSender() internal view virtual returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    uint256[50] private __gap;
}


pragma solidity ^0.6.0;


contract OwnableUpgradeSafe is Initializable, ContextUpgradeSafe {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    function __Ownable_init() internal initializer {

        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {



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

    uint256[49] private __gap;
}



pragma solidity 0.6.12;


interface IMigratorChef {

    function migrate(IERC20 token) external returns (IERC20);

}


pragma solidity ^0.6.0;






contract ERC20UpgradeSafe is Initializable, ContextUpgradeSafe, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;


    function __ERC20_init(string memory name, string memory symbol) internal initializer {

        __Context_init_unchained();
        __ERC20_init_unchained(name, symbol);
    }

    function __ERC20_init_unchained(string memory name, string memory symbol) internal initializer {



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


    uint256[44] private __gap;
}


pragma solidity ^0.6.0;



abstract contract ERC20CappedUpgradeSafe is Initializable, ERC20UpgradeSafe {
    uint256 private _cap;


    function __ERC20Capped_init(uint256 cap) internal initializer {
        __Context_init_unchained();
        __ERC20Capped_init_unchained(cap);
    }

    function __ERC20Capped_init_unchained(uint256 cap) internal initializer {


        require(cap > 0, "ERC20Capped: cap is 0");
        _cap = cap;

    }


    function cap() public view returns (uint256) {
        return _cap;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        if (from == address(0)) { // When minting tokens
            require(totalSupply().add(amount) <= _cap, "ERC20Capped: cap exceeded");
        }
    }

    uint256[49] private __gap;
}



pragma solidity 0.6.12;

interface IERC20VoteableUpgradeSafe {

    function getPriorVotes(address account, uint256 blockNumber)
        external
        view
        returns (uint256);

}



pragma solidity 0.6.12;




abstract contract ERC20VoteableUpgradeSafe is
    ERC20UpgradeSafe,
    IERC20VoteableUpgradeSafe
{
    struct Checkpoint {
        uint256 fromBlock;
        uint256 votes;
    }
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
    bytes32 public constant DOMAIN_TYPEHASH = keccak256(
        "EIP712Domain(string name,uint256 chainId,address verifyingContract)"
    );
    bytes32 public constant DELEGATION_TYPEHASH = keccak256(
        "Delegation(address delegatee,uint256 nonce,uint256 expiry)"
    );
    bytes32 public constant PERMIT_TYPEHASH = keccak256(
        "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
    );
    mapping(address => address) _delegates;
    mapping(address => mapping(uint256 => Checkpoint)) public _checkpoints;
    mapping(address => uint256) public _numCheckpoints;
    mapping(address => uint256) public _nonces;

    function permit(
        address owner,
        address spender,
        uint256 rawAmount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        uint256 amount;
        bytes32 domainSeparator = keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                keccak256(bytes(name())),
                _getChainId(),
                address(this)
            )
        );
        bytes32 structHash = keccak256(
            abi.encode(
                PERMIT_TYPEHASH,
                owner,
                spender,
                rawAmount,
                _nonces[owner]++,
                deadline
            )
        );
        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", domainSeparator, structHash)
        );
        address signatory = ecrecover(digest, v, r, s);
        require(
            signatory != address(0),
            "ERC20VoteableUpgradeSafe: permit: invalid signature"
        );
        require(
            signatory == owner,
            "ERC20VoteableUpgradeSafe: permit: unauthorized"
        );
        require(
            now <= deadline,
            "ERC20VoteableUpgradeSafe: permit: signature expired"
        );

        _approve(owner, spender, amount);
        emit Approval(owner, spender, amount);
    }

    function delegate(address delegatee) public {
        return _delegate(_msgSender(), delegatee);
    }

    function delegateBySig(
        address delegatee,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        bytes32 domainSeparator = keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                keccak256(bytes(name())),
                _getChainId(),
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
            "ERC20VoteableUpgradeSafe: delegateBySig: invalid signature"
        );
        require(
            nonce == _nonces[signatory]++,
            "ERC20VoteableUpgradeSafe: delegateBySig: invalid nonce"
        );
        require(
            now <= expiry,
            "ERC20VoteableUpgradeSafe: delegateBySig: signature expired"
        );
        return _delegate(signatory, delegatee);
    }

    function getCurrentVotes(address account) external view returns (uint256) {
        uint256 nCheckpoints = _numCheckpoints[account];
        return
            nCheckpoints > 0
                ? _checkpoints[account][nCheckpoints - 1].votes
                : 0;
    }

    function getPriorVotes(address account, uint256 blockNumber)
        public
        override
        view
        returns (uint256)
    {
        require(
            blockNumber < block.number,
            "ERC20VoteableUpgradeSafe: getPriorVotes: not yet determined"
        );

        uint256 nCheckpoints = _numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        if (_checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return _checkpoints[account][nCheckpoints - 1].votes;
        }

        if (_checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint256 lower = 0;
        uint256 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint256 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = _checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return _checkpoints[account][lower].votes;
    }

    function _delegate(address delegator, address delegatee) internal {
        address currentDelegate = _delegates[delegator];
        uint256 delegatorBalance = balanceOf(delegator);
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
                uint256 srcRepNum = _numCheckpoints[srcRep];
                uint256 srcRepOld = srcRepNum > 0
                    ? _checkpoints[srcRep][srcRepNum - 1].votes
                    : 0;
                uint256 srcRepNew = srcRepOld.sub(amount);
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                uint256 dstRepNum = _numCheckpoints[dstRep];
                uint256 dstRepOld = dstRepNum > 0
                    ? _checkpoints[dstRep][dstRepNum - 1].votes
                    : 0;
                uint256 dstRepNew = dstRepOld.add(amount);
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(
        address delegatee,
        uint256 nCheckpoints,
        uint256 oldVotes,
        uint256 newVotes
    ) internal {
        if (
            nCheckpoints > 0 &&
            _checkpoints[delegatee][nCheckpoints - 1].fromBlock == block.number
        ) {
            _checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            _checkpoints[delegatee][nCheckpoints] = Checkpoint(
                block.number,
                newVotes
            );
            _numCheckpoints[delegatee] = nCheckpoints + 1;
        }

        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    function _getChainId() internal pure returns (uint256) {
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
        super._beforeTokenTransfer(from, to, amount);
        _moveDelegates(_delegates[from], _delegates[to], amount);
    }
}



pragma solidity 0.6.12;





contract CF is
    ERC20UpgradeSafe,
    ERC20VoteableUpgradeSafe,
    ERC20CappedUpgradeSafe,
    OwnableUpgradeSafe
{

    event AuthorizeMinter(address minter, address operator);
    event RevokeMinter(address minter, address operator);

    address[] public minters;
    mapping(address => bool) public isMinter;

    function initialize() public initializer {

        __ERC20_init("Consensus Finance", "CF");
        __ERC20Capped_init(1000_000e18);
        __Ownable_init();
    }

    function mint(address to, uint256 amount) public {

        require(isMinter[_msgSender()], "CF: caller is not an operator for CF");
        _mint(to, amount);
    }

    function authorizeMinter(address minter) public onlyOwner {

        for (uint256 i = 0; i < minters.length; i++) {
            if (minters[i] == minter) revert("CF: minter exists");
        }
        minters.push(minter);
        isMinter[minter] = true;
        emit AuthorizeMinter(minter, _msgSender());
    }

    function revokeMinter(address minter) public onlyOwner {

        bool has;
        uint256 minterIndex;
        for (uint256 i = 0; i < minters.length; i++) {
            if (minters[i] == minter) {
                has = true;
                minterIndex = i;
                break;
            }
        }
        require(has, "CF: minter not found");
        address lastMinter = minters[minters.length - 1];
        if (lastMinter != minter) minters[minterIndex] = lastMinter;
        minters.pop();
        delete isMinter[minter];
        emit RevokeMinter(minter, _msgSender());
    }

    function mintersLength() public view returns (uint256) {

        return minters.length;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    )
        internal
        override(
            ERC20UpgradeSafe,
            ERC20VoteableUpgradeSafe,
            ERC20CappedUpgradeSafe
        )
    {

        super._beforeTokenTransfer(from, to, amount);
    }
}



pragma solidity 0.6.12;







contract CFStake is OwnableUpgradeSafe {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );

    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
    }

    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. CFs to distribute per block.
        uint256 lastRewardBlock; // Last block number that CFs distribution occurs.
        uint256 accCFPerShare; // Accumulated CFs per share, times 1e12. See below.
    }

    CF public cf;
    address public devaddr;
    IMigratorChef public migrator;

    PoolInfo[] public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    uint256 public totalAllocPoint;
    uint256 public startBlock;

    uint256 public constant maxTokenMint = 390000e18; // 39% of token.totalSupply()
    uint256 public tokenMinted;

    function initialize(
        CF _cf,
        address _devaddr,
        uint256 _startBlock
    ) public initializer {

        __Ownable_init();
        cf = _cf;
        devaddr = _devaddr;
        startBlock = _startBlock;
    }

    function poolLength() external view returns (uint256) {

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
                accCFPerShare: 0
            })
        );
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

    function getReward(uint256 _from, uint256 _to)
        public
        view
        returns (uint256)
    {

        require(_from <= _to, "_from must <= _to");
        uint256 res = 0;
        (uint256 rangeStart, uint256 rangeEnd) = nextRewardRange(_from, _to);
        while (true) {
            res = res.add(
                rangeEnd.sub(rangeStart).mul(getRewardPerBlock(rangeStart))
            );
            if (rangeEnd == _to) {
                return res;
            }
            require(rangeEnd < _to, "getReward: bad");
            (rangeStart, rangeEnd) = nextRewardRange(rangeEnd, _to);
        }
    }

    function nextRewardRange(uint256 _from, uint256 _to)
        internal
        view
        returns (uint256, uint256)
    {

        uint256 threshold1 = 50_000;
        uint256 threshold2 = 250_000;
        uint256 threshold3 = 550_000;
        uint256 threshold4 = 1_000_000;

        if (_from < startBlock.add(threshold1)) {
            return
                (_to > startBlock.add(threshold1))
                    ? (_from, startBlock.add(threshold1))
                    : (_from, _to);
        } else if (_from < startBlock.add(threshold2)) {
            return
                (_to > startBlock.add(threshold2))
                    ? (_from, startBlock.add(threshold2))
                    : (_from, _to);
        } else if (_from < startBlock.add(threshold3)) {
            return
                (_to > startBlock.add(threshold3))
                    ? (_from, startBlock.add(threshold3))
                    : (_from, _to);
        } else if (_from < startBlock.add(threshold4)) {
            return
                (_to > startBlock.add(threshold4))
                    ? (_from, startBlock.add(threshold4))
                    : (_from, _to);
        } else {
            return (_from, _to);
        }
    }

    function getRewardPerBlock(uint256 blockNumber)
        public
        view
        returns (uint256)
    {

        if (blockNumber == 0) {
            blockNumber = block.number;
        }
        uint256 threshold1 = 50_000;
        uint256 threshold2 = 250_000;
        uint256 threshold3 = 550_000;
        uint256 threshold4 = 1_000_000;
        if (blockNumber < startBlock.add(threshold1)) {
            return 75e16;
        } else if (blockNumber < startBlock.add(threshold2)) {
            return 15e16;
        } else if (blockNumber < startBlock.add(threshold3)) {
            return 75e15;
        } else if (blockNumber < startBlock.add(threshold4)) {
            return 6e16;
        } else {
            return 5e16;
        }
    }

    function pendingReward(uint256 _pid, address _user)
        external
        view
        returns (uint256)
    {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accCFPerShare = pool.accCFPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 reward = getReward(pool.lastRewardBlock, block.number);
            uint256 cfReward = reward.mul(pool.allocPoint).div(totalAllocPoint);

            if (tokenMinted.add(cfReward) >= maxTokenMint) {
                cfReward = maxTokenMint.sub(tokenMinted);
            }

            uint256 cfRewardForUsers = cfReward.sub(cfReward.div(20));
            accCFPerShare = accCFPerShare.add(
                cfRewardForUsers.mul(1e12).div(lpSupply)
            );
        }
        return user.amount.mul(accCFPerShare).div(1e12).sub(user.rewardDebt);
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
        uint256 reward = getReward(pool.lastRewardBlock, block.number);
        uint256 cfReward = reward.mul(pool.allocPoint).div(totalAllocPoint);

        if (tokenMinted.add(cfReward) >= maxTokenMint) {
            cfReward = maxTokenMint.sub(tokenMinted);
        }
        tokenMinted = tokenMinted.add(cfReward);

        cf.mint(address(devaddr), cfReward.div(20));
        uint256 cfRewardForUsers = cfReward.sub(cfReward.div(20));
        cf.mint(address(this), cfRewardForUsers);
        pool.accCFPerShare = pool.accCFPerShare.add(
            cfRewardForUsers.mul(1e12).div(lpSupply)
        );
        pool.lastRewardBlock = block.number;
    }

    function deposit(uint256 _pid, uint256 _amount) public {

        require(_amount > 0, "deposit: _amount must > 0");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_msgSender()];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accCFPerShare).div(1e12).sub(
                user.rewardDebt
            );
            safeCFTransfer(_msgSender(), pending);
        }
        pool.lpToken.safeTransferFrom(
            address(_msgSender()),
            address(this),
            _amount
        );
        user.amount = user.amount.add(_amount);
        user.rewardDebt = user.amount.mul(pool.accCFPerShare).div(1e12);
        emit Deposit(_msgSender(), _pid, _amount);
    }

    function withdraw(uint256 _pid, uint256 _amount) public {

        require(_amount > 0, "withdraw: _amount must > 0");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_msgSender()];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accCFPerShare).div(1e12).sub(
            user.rewardDebt
        );
        safeCFTransfer(_msgSender(), pending);
        user.amount = user.amount.sub(_amount);
        user.rewardDebt = user.amount.mul(pool.accCFPerShare).div(1e12);
        pool.lpToken.safeTransfer(address(_msgSender()), _amount);
        emit Withdraw(_msgSender(), _pid, _amount);
    }

    function claim(uint256 _pid) public {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_msgSender()];
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accCFPerShare).div(1e12).sub(
            user.rewardDebt
        );
        if (pending > 0) {
            safeCFTransfer(_msgSender(), pending);
        }
        user.rewardDebt = user.amount.mul(pool.accCFPerShare).div(1e12);
    }

    function emergencyWithdraw(uint256 _pid) public {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_msgSender()];
        pool.lpToken.safeTransfer(address(_msgSender()), user.amount);
        emit EmergencyWithdraw(_msgSender(), _pid, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
    }

    function safeCFTransfer(address _to, uint256 _amount) internal {

        uint256 cfBal = cf.balanceOf(address(this));
        if (_amount > cfBal) {
            cf.transfer(_to, cfBal);
        } else {
            cf.transfer(_to, _amount);
        }
    }

    function dev(address _devaddr) public {

        require(_msgSender() == devaddr, "dev: wut?");
        devaddr = _devaddr;
    }
}