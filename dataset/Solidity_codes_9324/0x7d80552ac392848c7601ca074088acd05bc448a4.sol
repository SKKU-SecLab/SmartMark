


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


pragma solidity 0.6.12;

abstract contract IStakingV2 {
    event Staked(address indexed user, uint256 amount, uint256 total, address referrer);
    event Unstaked(address indexed user, uint256 amount, uint256 total, bytes data);

    function stake(uint256 amount, address referrer) external virtual;
    function stakeFor(address user, uint256 amount, address referrer) external virtual;
    function unstake(uint256 amount) external virtual;
    function totalStakedFor(address addr) public virtual view returns (uint256);
    function totalStaked() public virtual view returns (uint256);
    function token() external virtual view returns (address);

    function supportsHistory() external pure returns (bool) {
        return false;
    }
}


pragma solidity 0.6.12;



contract TokenPool is Ownable {

    IERC20 public token;

    constructor(IERC20 _token) public {
        token = _token;
    }

    function balance() public view returns (uint256) {

        return token.balanceOf(address(this));
    }

    function transfer(address to, uint256 value) external onlyOwner returns (bool) {

        return token.transfer(to, value);
    }

    function rescueFunds(address tokenToRescue, address to, uint256 amount) external onlyOwner returns (bool) {

        require(address(token) != tokenToRescue, 'TokenPool: Cannot claim token held by the contract');

        return IERC20(tokenToRescue).transfer(to, amount);
    }
}


pragma solidity 0.6.12;

interface IReferrerBook {

    function affirmReferrer(address user, address referrer) external returns (bool);

    function getUserReferrer(address user) external view returns (address);

    function getUserTopNode(address user) external view returns (address);

    function getUserNormalNode(address user) external view returns (address);

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



pragma solidity >=0.6.0 <0.8.0;



abstract contract ERC20Burnable is Context, ERC20 {
    using SafeMath for uint256;

    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "ERC20: burn amount exceeds allowance");

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
    }
}


pragma solidity 0.6.12;


abstract contract DelegateERC20 is ERC20Burnable {
    mapping(address => address) internal _delegates;

    struct Checkpoint {
        uint32 fromBlock;
        uint256 votes;
    }

    mapping(address => mapping(uint32 => Checkpoint)) public checkpoints;

    mapping(address => uint32) public numCheckpoints;

    bytes32 public constant DOMAIN_TYPEHASH =
        keccak256('EIP712Domain(string name,uint256 chainId,address verifyingContract)');

    bytes32 public constant DELEGATION_TYPEHASH =
        keccak256('Delegation(address delegatee,uint256 nonce,uint256 expiry)');

    mapping(address => uint256) public nonces;

    function _mint(address account, uint256 amount) internal virtual override {
        super._mint(account, amount);

        _moveDelegates(address(0), _delegates[account], amount);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override {
        super._transfer(sender, recipient, amount);
        _moveDelegates(_delegates[sender], _delegates[recipient], amount);
    }

    function burn(uint256 amount) public virtual override {
        super.burn(amount);

        _moveDelegates(_delegates[_msgSender()], address(0), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual override {
        super.burnFrom(account, amount);

        _moveDelegates(_delegates[account], address(0), amount);
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
        bytes32 domainSeparator =
            keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name())), getChainId(), address(this)));

        bytes32 structHash = keccak256(abi.encode(DELEGATION_TYPEHASH, delegatee, nonce, expiry));

        bytes32 digest = keccak256(abi.encodePacked('\x19\x01', domainSeparator, structHash));

        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), 'Governance::delegateBySig: invalid signature');
        require(nonce == nonces[signatory]++, 'Governance::delegateBySig: invalid nonce');
        require(now <= expiry, 'Governance::delegateBySig: signature expired');
        return _delegate(signatory, delegatee);
    }

    function getCurrentVotes(address account) external view returns (uint256) {
        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    function getPriorVotes(address account, uint256 blockNumber) external view returns (uint256) {
        require(blockNumber < block.number, 'Governance::getPriorVotes: not yet determined');

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
            uint32 center = upper - (upper - lower) / 2;
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
        uint256 delegatorBalance = balanceOf(delegator);
        _delegates[delegator] = delegatee;

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);

        emit DelegateChanged(delegator, currentDelegate, delegatee);
    }

    function _moveDelegates(
        address srcRep,
        address dstRep,
        uint256 amount
    ) internal {
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
    ) internal {
        uint32 blockNumber = safe32(block.number, 'Governance::_writeCheckpoint: block number exceeds 32 bits');

        if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }

        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    function safe32(uint256 n, string memory errorMessage) internal pure returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function getChainId() internal pure returns (uint256) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }

        return chainId;
    }

    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    event DelegateVotesChanged(address indexed delegate, uint256 previousBalance, uint256 newBalance);
}


pragma solidity 0.6.12;



contract DSAGovToken is DelegateERC20, Ownable {
    constructor() public ERC20("DSBTC", "DSBTC") {}

    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
    }
}


pragma solidity 0.6.12;




interface IOracle {
    function getData() external returns (uint256, bool);
}

contract GovTokenPool is Ownable {
    using SafeMath for uint256;

    struct PoolInfo {
        uint256 allocPoint;
        uint256 lastRewardBlock;
        uint256 accTokenPerShare;
    }

    mapping(address => PoolInfo) public poolInfo;
    mapping(address => mapping(address => uint256)) public userDebt;

    DSAGovToken public token;
    IOracle public cpiOracle;
    IOracle public marketOracle;
    uint256 public totalAllocPoint;
    uint256 public startBlock;

    address public governance;

    uint256 public priceRate;

    uint256 constant BASE_CPI = 100 * 10**18;
    uint256 public constant BASE_REWARD_PER_BLOCK = 111 * 10**16;

    uint256 constant MAX_GAP_BLOCKS = 6500;
    uint256 constant BLOCKS_4YEARS = 2372500 * 4;

    uint256 constant ONE = 10**18;
    uint256 constant ZERO_PT_ONE = 10**17;

    uint256 constant PERFECT_RATE = 1 * ONE; //100%
    uint256 constant HIGH_RATE_D = 3 * ZERO_PT_ONE;
    uint256 constant HIGH_RATE = PERFECT_RATE + HIGH_RATE_D; //130%
    uint256 constant LOW_RATE_D = 9 * ZERO_PT_ONE;
    uint256 constant LOW_RATE = PERFECT_RATE - LOW_RATE_D; //10%

    constructor(
        DSAGovToken _token,
        IOracle _cpiOracle,
        IOracle _marketOracle,
        uint256 _startBlock
    ) public {
        token = _token;
        cpiOracle = _cpiOracle;
        marketOracle = _marketOracle;
        startBlock = _startBlock;

        governance = _msgSender();
    }

    modifier onlyGovernance() {
        require(governance == _msgSender(), "Only governance");
        _;
    }

    function balance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function syncRate() external {
        uint256 cpi;
        bool cpiValid;
        (cpi, cpiValid) = cpiOracle.getData();
        if (!cpiValid) {
            priceRate = 0;
            return;
        }

        uint256 rate;
        bool exRateValid;
        (rate, exRateValid) = marketOracle.getData();
        if (!exRateValid) {
            priceRate = 0;
            return;
        }
        uint256 targetRate = cpi.mul(10**18).div(BASE_CPI);

        priceRate = rate.mul(ONE).div(targetRate);
    }

    function addPool(address _addr, uint256 _allocPoint)
        external
        onlyGovernance()
    {
        uint256 lastRewardBlock =
            block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);

        require(poolInfo[_addr].lastRewardBlock == 0, "pool exists");

        poolInfo[_addr] = PoolInfo({
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            accTokenPerShare: 0
        });
    }

    function removePool(address _addr) external onlyGovernance() {
        delete poolInfo[_addr];
    }

    function setPool(address _addr, uint256 _allocPoint)
        external
        onlyGovernance()
    {
        require(poolInfo[_addr].lastRewardBlock != 0, "pool not exists");

        totalAllocPoint = totalAllocPoint.sub(poolInfo[_addr].allocPoint).add(
            _allocPoint
        );
        poolInfo[_addr].allocPoint = _allocPoint;
    }

    function transferGovernance(address _newAddr) external onlyGovernance() {
        require(_newAddr != address(0), "zero address");

        governance = _newAddr;
    }

    function calcRatedReward(
        uint256 _initReward,
        uint256 r
    ) internal pure returns (uint256) {

        uint256 f;

        if(r == PERFECT_RATE) {
            return _initReward;
        }
        
        if(r > PERFECT_RATE && r < HIGH_RATE) {
            f = HIGH_RATE.sub(r).mul(ONE).div(HIGH_RATE_D);
        } else if(r < PERFECT_RATE && r > LOW_RATE) {
            f = r.sub(LOW_RATE).mul(ONE).div(LOW_RATE_D);
        }

        return f.mul(f).div(ONE).mul(_initReward).div(ONE);
    }

    function _updatePool(PoolInfo storage pool, uint256 _lpSupply) private {
        if (block.number <= pool.lastRewardBlock) {
            return;
        }

        if (_lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }

        if (priceRate == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }

        if (priceRate >= HIGH_RATE || priceRate <= LOW_RATE) {
            pool.lastRewardBlock = block.number;
            return;
        }

        uint256 blocks = block.number.sub(pool.lastRewardBlock);

        if (blocks > MAX_GAP_BLOCKS) {
            blocks = MAX_GAP_BLOCKS;
        }

        uint256 halveTimes = block.number.sub(startBlock).div(BLOCKS_4YEARS);

        uint256 perfectReward =
            blocks
                .mul(BASE_REWARD_PER_BLOCK)
                .mul(pool.allocPoint)
                .div(totalAllocPoint)
                .div(2**halveTimes);

        uint256 reward =
            calcRatedReward(perfectReward, priceRate);

        if (reward > 0) {
            token.mint(address(this), reward);
            pool.accTokenPerShare = pool.accTokenPerShare.add(
                reward.mul(1e12).div(_lpSupply)
            );
        }

        pool.lastRewardBlock = block.number;
    }

    function updatePool(uint256 _lpSupply) external {
        address poolAddr = _msgSender();
        PoolInfo storage pool = poolInfo[poolAddr];
        require(pool.lastRewardBlock != 0, 'Pool not exists');

        _updatePool(pool, _lpSupply);
    }

    function updateAndClaim(
        address _userAddr,
        uint256 _userAmount,
        uint256 _lpSupply
    ) external {
        address poolAddr = _msgSender();
        PoolInfo storage pool = poolInfo[poolAddr];
        require(pool.lastRewardBlock != 0, 'Pool not exists');

        _updatePool(pool, _lpSupply);

        uint256 toClaim =
            _userAmount.mul(pool.accTokenPerShare).div(1e12).sub(
                userDebt[poolAddr][_userAddr]
            );

        if(toClaim > 0) {
            require(token.transfer(_userAddr, toClaim), 'transfer dbtc error');
        } 
    }

    function updateDebt(address _userAddr, uint256 _userAmount) external {
        address poolAddr = _msgSender();
        PoolInfo memory pool = poolInfo[poolAddr];
        require(pool.lastRewardBlock != 0, 'Pool not exists');
        userDebt[poolAddr][_userAddr] = _userAmount.mul(pool.accTokenPerShare).div(1e12);
    }

    function pendingReward(
        address _poolAddr,
        uint256 _userAmount,
        address _userAddr
    ) external view returns (uint256) {
        PoolInfo memory pool = poolInfo[_poolAddr];
        return
            _userAmount.mul(pool.accTokenPerShare).div(1e12).sub(
                userDebt[_poolAddr][_userAddr]
            );
    }
}


pragma solidity 0.6.12;








contract TokenGeyserV2 is IStakingV2, Ownable {
    using SafeMath for uint256;

    event Staked(
        address indexed user,
        uint256 amount,
        uint256 total,
        address referrer
    );
    event Unstaked(
        address indexed user,
        uint256 amount,
        uint256 total
    );
    event TokensClaimed(address indexed user, uint256 amount);
    event TokensLocked(uint256 amount, uint256 durationSec, uint256 total);
    event TokensUnlocked(uint256 amount, uint256 total);

    TokenPool private _stakingPool;
    TokenPool private _unlockedPool;
    TokenPool private _lockedPool;
    GovTokenPool public govTokenPool;

    uint256 public constant BONUS_DECIMALS = 2;
    uint256 public startBonus = 0;
    uint256 public bonusPeriodSec = 0;

    uint256 public totalLockedShares = 0;
    uint256 public totalStakingShares = 0;
    uint256 private _totalStakingShareSeconds = 0;
    uint256 private _lastAccountingTimestampSec = now;
    uint256 private _maxUnlockSchedules = 0;
    uint256 private _initialSharesPerToken = 0;

    address public referrerBook;

    uint256 public constant USER_SHARE_PCT = 8000;
    uint256 public constant REF_SHARE_PCT = 1500;
    uint256 public constant NODE_SHARE_PCT = 500;

    struct Stake {
        uint256 stakingShares;
        uint256 timestampSec;
    }

    struct UserTotals {
        uint256 stakingShares;
        uint256 stakingShareSeconds;
        uint256 lastAccountingTimestampSec;
    }

    mapping(address => UserTotals) private _userTotals;

    mapping(address => Stake[]) private _userStakes;

    struct UnlockSchedule {
        uint256 initialLockedShares;
        uint256 unlockedShares;
        uint256 lastUnlockTimestampSec;
        uint256 endAtSec;
        uint256 durationSec;
    }

    UnlockSchedule[] public unlockSchedules;

    constructor(
        IERC20 stakingToken,
        IERC20 distributionToken,
        GovTokenPool _govTokenPool,
        uint256 maxUnlockSchedules,
        uint256 startBonus_,
        uint256 bonusPeriodSec_,
        uint256 initialSharesPerToken,
        address referrerBook_
    ) public {
        require(
            startBonus_ <= 10**BONUS_DECIMALS,
            "TokenGeyser: start bonus too high"
        );
        require(bonusPeriodSec_ != 0, "TokenGeyser: bonus period is zero");
        require(
            initialSharesPerToken > 0,
            "TokenGeyser: initialSharesPerToken is zero"
        );
        require(
            referrerBook_ != address(0),
            "TokenGeyser: referrer book is zero"
        );

        require(
            address(_govTokenPool) != address(0),
            "TokenGeyser: govTokenPool is zero"
        );

        _stakingPool = new TokenPool(stakingToken);
        _unlockedPool = new TokenPool(distributionToken);
        _lockedPool = new TokenPool(distributionToken);
        govTokenPool = _govTokenPool;
        startBonus = startBonus_;
        bonusPeriodSec = bonusPeriodSec_;
        _maxUnlockSchedules = maxUnlockSchedules;
        _initialSharesPerToken = initialSharesPerToken;

        referrerBook = referrerBook_;
    }

    function getStakingToken() public view returns (IERC20) {
        return _stakingPool.token();
    }

    function getDistributionToken() public view returns (IERC20) {
        assert(_unlockedPool.token() == _lockedPool.token());
        return _unlockedPool.token();
    }

    function stake(uint256 amount, address referrer) external override {
        _stakeFor(msg.sender, msg.sender, amount, referrer);
    }

    function stakeFor(
        address user,
        uint256 amount,
        address referrer
    ) external override onlyOwner {
        _stakeFor(msg.sender, user, amount, referrer);
    }

    function _stakeFor(
        address staker,
        address beneficiary,
        uint256 amount,
        address referrer
    ) private {
        require(amount > 0, "TokenGeyser: stake amount is zero");
        require(
            beneficiary != address(0),
            "TokenGeyser: beneficiary is zero address"
        );
        require(
            totalStakingShares == 0 || totalStaked() > 0,
            "TokenGeyser: Invalid state. Staking shares exist, but no staking tokens do"
        );

        uint256 mintedStakingShares = (totalStakingShares > 0)
            ? totalStakingShares.mul(amount).div(totalStaked())
            : amount.mul(_initialSharesPerToken);
        require(
            mintedStakingShares > 0,
            "TokenGeyser: Stake amount is too small"
        );

        updateAccounting();

        govTokenPool.updateAndClaim(beneficiary, totalStakedFor(beneficiary), totalStaked());

        UserTotals storage totals = _userTotals[beneficiary];
        totals.stakingShares = totals.stakingShares.add(mintedStakingShares);
        totals.lastAccountingTimestampSec = now;

        Stake memory newStake = Stake(mintedStakingShares, now);
        _userStakes[beneficiary].push(newStake);

        totalStakingShares = totalStakingShares.add(mintedStakingShares);

        
        require(
            _stakingPool.token().transferFrom(
                staker,
                address(_stakingPool),
                amount
            ),
            "TokenGeyser: transfer into staking pool failed"
        );

        govTokenPool.updateDebt(beneficiary, totalStakedFor(beneficiary));

        if (referrer != address(0) && referrer != staker) {
            IReferrerBook(referrerBook).affirmReferrer(staker, referrer);
        }

        emit Staked(beneficiary, amount, totalStakedFor(beneficiary), referrer);
    }

    function unstake(uint256 amount) external override{
        _unstake(amount);
    }

    function unstakeQuery(uint256 amount) public returns (uint256) {
        return _unstake(amount);
    }

    function _unstake(uint256 amount) private returns (uint256) {
        updateAccounting();

        require(amount > 0, "TokenGeyser: unstake amount is zero");
        require(
            totalStakedFor(msg.sender) >= amount,
            "TokenGeyser: unstake amount is greater than total user stakes"
        );
        uint256 stakingSharesToBurn = totalStakingShares.mul(amount).div(
            totalStaked()
        );
        require(
            stakingSharesToBurn > 0,
            "TokenGeyser: Unable to unstake amount this small"
        );

        govTokenPool.updateAndClaim(msg.sender, totalStakedFor(msg.sender), totalStaked());

        UserTotals storage totals = _userTotals[msg.sender];
        Stake[] storage accountStakes = _userStakes[msg.sender];

        uint256 stakingShareSecondsToBurn = 0;
        uint256 sharesLeftToBurn = stakingSharesToBurn;
        uint256 rewardAmount = 0;
        while (sharesLeftToBurn > 0) {
            Stake storage lastStake = accountStakes[accountStakes.length - 1];
            uint256 stakeTimeSec = now.sub(lastStake.timestampSec);
            uint256 newStakingShareSecondsToBurn = 0;
            if (lastStake.stakingShares <= sharesLeftToBurn) {
                newStakingShareSecondsToBurn = lastStake.stakingShares.mul(
                    stakeTimeSec
                );
                rewardAmount = computeNewReward(
                    rewardAmount,
                    newStakingShareSecondsToBurn,
                    stakeTimeSec
                );
                stakingShareSecondsToBurn = stakingShareSecondsToBurn.add(
                    newStakingShareSecondsToBurn
                );
                sharesLeftToBurn = sharesLeftToBurn.sub(
                    lastStake.stakingShares
                );
                accountStakes.pop();
            } else {
                newStakingShareSecondsToBurn = sharesLeftToBurn.mul(
                    stakeTimeSec
                );
                rewardAmount = computeNewReward(
                    rewardAmount,
                    newStakingShareSecondsToBurn,
                    stakeTimeSec
                );
                stakingShareSecondsToBurn = stakingShareSecondsToBurn.add(
                    newStakingShareSecondsToBurn
                );
                lastStake.stakingShares = lastStake.stakingShares.sub(
                    sharesLeftToBurn
                );
                sharesLeftToBurn = 0;
            }
        }
        totals.stakingShareSeconds = totals.stakingShareSeconds.sub(
            stakingShareSecondsToBurn
        );
        totals.stakingShares = totals.stakingShares.sub(stakingSharesToBurn);

        _totalStakingShareSeconds = _totalStakingShareSeconds.sub(
            stakingShareSecondsToBurn
        );
        totalStakingShares = totalStakingShares.sub(stakingSharesToBurn);
        require(
            _stakingPool.transfer(msg.sender, amount),
            "TokenGeyser: transfer out of staking pool failed"
        );

        govTokenPool.updateDebt(msg.sender, totalStakedFor(msg.sender));

        uint256 userRewardAmount = _rewardUserAndReferrers(
            msg.sender,
            rewardAmount
        );

        emit Unstaked(msg.sender, amount, totalStakedFor(msg.sender));
        emit TokensClaimed(msg.sender, rewardAmount);

        require(
            totalStakingShares == 0 || totalStaked() > 0,
            "TokenGeyser: Error unstaking. Staking shares exist, but no staking tokens do"
        );
        return userRewardAmount;
    }

    function _rewardUserAndReferrers(address user, uint256 rewardAmount)
        private
        returns (uint256)
    {
        uint256 userAmount = rewardAmount.mul(USER_SHARE_PCT).div(10000);
        require(
            _unlockedPool.transfer(user, userAmount),
            "TokenGeyser: transfer out of unlocked pool failed(user)"
        );

        IReferrerBook refBook = IReferrerBook(referrerBook);

        uint256 amount = rewardAmount.mul(REF_SHARE_PCT).div(10000);
        address referrer = refBook.getUserReferrer(user);
        if (amount > 0 && referrer != address(0)) {
            _unlockedPool.transfer(referrer, amount);
        }

        amount = rewardAmount.mul(NODE_SHARE_PCT).div(10000);
        address topNode = refBook.getUserTopNode(user);
        if (amount > 0 && topNode != address(0)) {
            _unlockedPool.transfer(topNode, amount);
        }

        return userAmount;
    }

    function computeNewReward(
        uint256 currentRewardTokens,
        uint256 stakingShareSeconds,
        uint256 stakeTimeSec
    ) private view returns (uint256) {
        uint256 newRewardTokens = totalUnlocked().mul(stakingShareSeconds).div(
            _totalStakingShareSeconds
        );

        if (stakeTimeSec >= bonusPeriodSec) {
            return currentRewardTokens.add(newRewardTokens);
        }

        uint256 oneHundredPct = 10**BONUS_DECIMALS;
        uint256 bonusedReward = startBonus
            .add(
            oneHundredPct.sub(startBonus).mul(stakeTimeSec).div(bonusPeriodSec)
        )
            .mul(newRewardTokens)
            .div(oneHundredPct);
        return currentRewardTokens.add(bonusedReward);
    }

    function totalStakedFor(address addr) public override view returns (uint256) {
        return
            totalStakingShares > 0
                ? totalStaked().mul(_userTotals[addr].stakingShares).div(
                    totalStakingShares
                )
                : 0;
    }

    function totalStaked() public override view returns (uint256) {
        return _stakingPool.balance();
    }

    function token() external override view returns (address) {
        return address(getStakingToken());
    }

    function updateAccounting()
        public
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        unlockTokens();

        uint256 newStakingShareSeconds = now
            .sub(_lastAccountingTimestampSec)
            .mul(totalStakingShares);
        _totalStakingShareSeconds = _totalStakingShareSeconds.add(
            newStakingShareSeconds
        );
        _lastAccountingTimestampSec = now;

        UserTotals storage totals = _userTotals[msg.sender];
        uint256 newUserStakingShareSeconds = now
            .sub(totals.lastAccountingTimestampSec)
            .mul(totals.stakingShares);
        totals.stakingShareSeconds = totals.stakingShareSeconds.add(
            newUserStakingShareSeconds
        );
        totals.lastAccountingTimestampSec = now;

        uint256 totalUserRewards = (_totalStakingShareSeconds > 0)
            ? totalUnlocked().mul(totals.stakingShareSeconds).div(
                _totalStakingShareSeconds
            )
            : 0;

        return (
            totalLocked(),
            totalUnlocked(),
            totals.stakingShareSeconds,
            _totalStakingShareSeconds,
            totalUserRewards,
            now
        );
    }

    function totalLocked() public view returns (uint256) {
        return _lockedPool.balance();
    }

    function totalUnlocked() public view returns (uint256) {
        return _unlockedPool.balance();
    }

    function unlockScheduleCount() public view returns (uint256) {
        return unlockSchedules.length;
    }

    function lockTokens(uint256 amount, uint256 durationSec)
        external
        onlyOwner
    {
        require(
            unlockSchedules.length < _maxUnlockSchedules,
            "TokenGeyser: reached maximum unlock schedules"
        );

        updateAccounting();

        uint256 lockedTokens = totalLocked();
        uint256 mintedLockedShares = (lockedTokens > 0)
            ? totalLockedShares.mul(amount).div(lockedTokens)
            : amount.mul(_initialSharesPerToken);

        UnlockSchedule memory schedule;
        schedule.initialLockedShares = mintedLockedShares;
        schedule.lastUnlockTimestampSec = now;
        schedule.endAtSec = now.add(durationSec);
        schedule.durationSec = durationSec;
        unlockSchedules.push(schedule);

        totalLockedShares = totalLockedShares.add(mintedLockedShares);

        require(
            _lockedPool.token().transferFrom(
                msg.sender,
                address(_lockedPool),
                amount
            ),
            "TokenGeyser: transfer into locked pool failed"
        );
        emit TokensLocked(amount, durationSec, totalLocked());
    }

    function unlockTokens() public returns (uint256) {
        uint256 unlockedTokens = 0;
        uint256 lockedTokens = totalLocked();

        if (totalLockedShares == 0) {
            unlockedTokens = lockedTokens;
        } else {
            uint256 unlockedShares = 0;
            for (uint256 s = 0; s < unlockSchedules.length; s++) {
                unlockedShares = unlockedShares.add(unlockScheduleShares(s));
            }
            unlockedTokens = unlockedShares.mul(lockedTokens).div(
                totalLockedShares
            );
            totalLockedShares = totalLockedShares.sub(unlockedShares);
        }

        if (unlockedTokens > 0) {
            require(
                _lockedPool.transfer(address(_unlockedPool), unlockedTokens),
                "TokenGeyser: transfer out of locked pool failed"
            );
            emit TokensUnlocked(unlockedTokens, totalLocked());
        }

        return unlockedTokens;
    }

    function unlockScheduleShares(uint256 s) private returns (uint256) {
        UnlockSchedule storage schedule = unlockSchedules[s];

        if (schedule.unlockedShares >= schedule.initialLockedShares) {
            return 0;
        }

        uint256 sharesToUnlock = 0;
        if (now >= schedule.endAtSec) {
            sharesToUnlock = (
                schedule.initialLockedShares.sub(schedule.unlockedShares)
            );
            schedule.lastUnlockTimestampSec = schedule.endAtSec;
        } else {
            sharesToUnlock = now
                .sub(schedule.lastUnlockTimestampSec)
                .mul(schedule.initialLockedShares)
                .div(schedule.durationSec);
            schedule.lastUnlockTimestampSec = now;
        }

        schedule.unlockedShares = schedule.unlockedShares.add(sharesToUnlock);
        return sharesToUnlock;
    }

    function rescueFundsFromStakingPool(
        address tokenToRescue,
        address to,
        uint256 amount
    ) public onlyOwner returns (bool) {
        return _stakingPool.rescueFunds(tokenToRescue, to, amount);
    }

    function setReferrerBook(address referrerBook_) external onlyOwner {
        require(referrerBook_ != address(0), "referrerBook == 0");
        referrerBook = referrerBook_;
    }

    function claimGovToken() external {
        address beneficiary = msg.sender;
        govTokenPool.updateAndClaim(beneficiary,  totalStakedFor(beneficiary), totalStaked());
        govTokenPool.updateDebt(beneficiary,  totalStakedFor(beneficiary));
    }

    function pendingGovToken(address _user) external view returns(uint256) {
        return govTokenPool.pendingReward(address(this), totalStakedFor(_user), _user);
    }

    function updateGovTokenPool() external {
        govTokenPool.updatePool(totalStaked());
    }
}