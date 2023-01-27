

pragma solidity >=0.4.24;


interface ICash {

    function claimDividends(address account) external returns (uint256);


    function transfer(address to, uint256 value) external returns(bool);

    function transferFrom(address from, address to, uint256 value) external returns(bool);

    function balanceOf(address who) external view returns(uint256);

    function allowance(address owner_, address spender) external view returns(uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);

    function totalSupply() external view returns (uint256);

    function rebase(uint256 epoch, int256 supplyDelta) external returns (uint256);

    function redeemedShare(address account) external view returns (uint256);

}


pragma solidity ^0.4.24;


library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b != 0);
    return a % b;
  }
}


pragma solidity >=0.4.24 <0.6.0;


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

    uint256 cs;
    assembly { cs := extcodesize(address) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}


pragma solidity ^0.4.24;


contract Ownable is Initializable {

  address private _owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  function initialize(address sender) public initializer {

    _owner = sender;
  }

  function owner() public view returns(address) {

    return _owner;
  }

  modifier onlyOwner() {

    require(isOwner());
    _;
  }

  function isOwner() public view returns(bool) {

    return msg.sender == _owner;
  }

  function renounceOwnership() public onlyOwner {

    emit OwnershipRenounced(_owner);
    _owner = address(0);
  }

  function transferOwnership(address newOwner) public onlyOwner {

    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal {

    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }

  uint256[50] private ______gap;
}


pragma solidity ^0.4.24;


interface IERC20 {

  function totalSupply() external view returns (uint256);


  function balanceOf(address who) external view returns (uint256);


  function allowance(address owner, address spender)
    external view returns (uint256);


  function transfer(address to, uint256 value) external returns (bool);


  function approve(address spender, uint256 value)
    external returns (bool);


  function transferFrom(address from, address to, uint256 value)
    external returns (bool);


  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}


pragma solidity ^0.4.24;




contract ERC20Detailed is Initializable, IERC20 {

  string private _name;
  string private _symbol;
  uint8 private _decimals;

  function initialize(string name, string symbol, uint8 decimals) public initializer {

    _name = name;
    _symbol = symbol;
    _decimals = decimals;
  }

  function name() public view returns(string) {

    return _name;
  }

  function symbol() public view returns(string) {

    return _symbol;
  }

  function decimals() public view returns(uint8) {

    return _decimals;
  }

  uint256[50] private ______gap;
}



pragma solidity >=0.4.24;


library SafeMathInt {

    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b)
        internal
        pure
        returns (int256)
    {

        int256 c = a * b;

        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b)
        internal
        pure
        returns (int256)
    {

        require(b != -1 || a != MIN_INT256);

        return a / b;
    }

    function sub(int256 a, int256 b)
        internal
        pure
        returns (int256)
    {

        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b)
        internal
        pure
        returns (int256)
    {

        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a)
        internal
        pure
        returns (int256)
    {

        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
}


pragma solidity >=0.4.24;






interface IShareHelper {

    function getChainId() external pure returns (uint);

}


contract SeigniorageShares is ERC20Detailed, Ownable {

    address private _minter;

    modifier onlyMinter() {

        require(msg.sender == _minter, "DOES_NOT_HAVE_MINTER_ROLE");
        _;
    }

    using SafeMath for uint256;
    using SafeMathInt for int256;

    uint256 private constant DECIMALS = 9;
    uint256 private constant MAX_UINT256 = ~uint256(0);
    uint256 private constant INITIAL_SHARE_SUPPLY = 21 * 10**6 * 10**DECIMALS;

    uint256 private constant MAX_SUPPLY = ~uint128(0);

    uint256 private _totalSupply;

    struct Account {
        uint256 balance;
        uint256 lastDividendPoints;
    }

    bool private _initializedDollar;
    ICash Dollars;

    mapping(address=>Account) private _shareBalances;
    mapping (address => mapping (address => uint256)) private _allowedShares;

    bool reEntrancyMintMutex;
    address public deprecatedVariable;
    mapping (address => uint256) private deprecatedMapping;
    mapping (address => bool) public _debased;
    bool public debaseOn;


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

    mapping (address => address) internal _delegates2;
    mapping (address => mapping (uint32 => Checkpoint)) public checkpoints2;
    mapping (address => uint32) public numCheckpoints2;
    mapping (address => uint) public nonces2;

    mapping (address => uint256) public stakingStatus;
    mapping (address => uint256) public commitTimeStamp;
    uint256 public minimumCommitTime;
    address public timelock;

    event Staked(address user, uint256 balance);
    event CommittedWithdraw(address user, uint256 balance);
    event Unstaked(address user, uint256 balance);

    uint256 public totalStaked;
    uint256 public totalCommitted;

    mapping (address => mapping (address => uint256)) public synthAssetDividendPoints;
    mapping (address => bool) public acceptedSynthAsset;
    mapping (address => bool) public previouslySeenSynthAsset;
    address[] public syntheticAssets;

    event newSyntheticAsset(address asset);

    function setDividendPoints(address who, uint256 amount) external onlyMinter returns (bool) {

        _shareBalances[who].lastDividendPoints = amount;
        return true;
    }
    
    function setTimelock(address timelock_)
        external
        onlyOwner
    {

        timelock = timelock_;
    }

    function addSyntheticAsset(address newAsset) external {

        require(msg.sender == timelock || msg.sender == address(0x89a359A3D37C3A857E62cDE9715900441b47acEC), "unauthorized");
        require(acceptedSynthAsset[newAsset] == false && previouslySeenSynthAsset[newAsset] == false, 'must be a new asset');

        syntheticAssets.push(newAsset);
        acceptedSynthAsset[newAsset] = true;
        previouslySeenSynthAsset[newAsset] = true;

        emit newSyntheticAsset(newAsset);
    }

    function setSyntheticAsset(address asset, bool active) external {

        require(msg.sender == timelock || msg.sender == address(0x89a359A3D37C3A857E62cDE9715900441b47acEC), "unauthorized");
        require(previouslySeenSynthAsset[asset], 'must be a previously seen asset');

        acceptedSynthAsset[asset] = active;
    }

    function setSyntheticDividendPoints(address synth, address who, uint256 amount) external returns (bool) {

        require(acceptedSynthAsset[synth] && previouslySeenSynthAsset[synth], 'must be valid asset');
        require(msg.sender == synth, 'unauthorized');
        synthAssetDividendPoints[synth][who] = amount;
        return true;
    }

    function lastSyntheticDividendPoints(address synth, address who)
        external
        view
        returns (uint256)
    {

        require(previouslySeenSynthAsset[synth], 'must be valid asset');
        return synthAssetDividendPoints[synth][who];
    }

    function setMinimumCommitTime(uint256 _seconds) external {

        require(msg.sender == timelock || msg.sender == address(0x89a359A3D37C3A857E62cDE9715900441b47acEC), "unauthorized");
        minimumCommitTime = _seconds;
    }

    function externalTotalSupply()
        external
        view
        returns (uint256)
    {

        return _totalSupply;
    }

    function externalRawBalanceOf(address who)
        external
        view
        returns (uint256)
    {

        return _shareBalances[who].balance;
    }

    function lastDividendPoints(address who)
        external
        view
        returns (uint256)
    {

        return _shareBalances[who].lastDividendPoints;
    }

    function initialize(address owner_)
        public
        initializer
    {

        ERC20Detailed.initialize("Seigniorage Shares", "SHARE", uint8(DECIMALS));
        Ownable.initialize(owner_);

        _initializedDollar = false;

        _totalSupply = INITIAL_SHARE_SUPPLY;
        _shareBalances[owner_].balance = _totalSupply;

        emit Transfer(address(0x0), owner_, _totalSupply);
    }

    function initializeDollar(address dollarAddress) public onlyOwner {

        require(_initializedDollar == false, "ALREADY_INITIALIZED");
        Dollars = ICash(dollarAddress);
        _initializedDollar = true;
        _minter = dollarAddress;
    }

    function totalSupply()
        public
        view
        returns (uint256)
    {

        return _totalSupply;
    }

    function balanceOf(address who)
        public
        view
        returns (uint256)
    {

        return _shareBalances[who].balance;
    }

    function commitUnstake() updateAccount(msg.sender) external {

        require(stakingStatus[msg.sender] == 1, "can only commit to unstaking if currently staking");
        commitTimeStamp[msg.sender] = now;
        stakingStatus[msg.sender] = 2;

        totalStaked = totalStaked.sub(balanceOf(msg.sender));
        totalCommitted = totalCommitted.add(balanceOf(msg.sender));
        emit CommittedWithdraw(msg.sender, balanceOf(msg.sender));
    }

    function unstake() updateAccount(msg.sender) external {

        require(stakingStatus[msg.sender] == 2, "can only unstake if currently committed to unstake");
        require(commitTimeStamp[msg.sender] + minimumCommitTime < now, "minimum commit time not met yet");
        stakingStatus[msg.sender] = 0;

        totalCommitted = totalCommitted.sub(balanceOf(msg.sender));
        emit Unstaked(msg.sender, balanceOf(msg.sender));
    }

    function setTotalStaked(uint256 _amount) external onlyOwner {

        totalStaked = _amount;
    }

    function setTotalCommitted(uint256 _amount) external onlyOwner {

        totalCommitted = _amount;
    }

    function stake() updateAccount(msg.sender) external {

        require(stakingStatus[msg.sender] == 0, "can only stake if currently unstaked");
        stakingStatus[msg.sender] = 1;

        totalStaked = totalStaked.add(balanceOf(msg.sender));
        emit Staked(msg.sender, balanceOf(msg.sender));
    }

    function transfer(address to, uint256 value)
        public
        updateAccount(msg.sender)
        updateAccount(to)
        validRecipient(to)
        returns (bool)
    {

        require(!reEntrancyMintMutex, "RE-ENTRANCY GUARD MUST BE FALSE");
        require(stakingStatus[msg.sender] == 0, "cannot send SHARE while staking. Please unstake to send");

        _shareBalances[msg.sender].balance = _shareBalances[msg.sender].balance.sub(value);
        _shareBalances[to].balance = _shareBalances[to].balance.add(value);
        emit Transfer(msg.sender, to, value);

        _moveDelegates(_delegates2[msg.sender], _delegates2[to], value);

        if (stakingStatus[to] == 1) totalStaked += value;
        else if (stakingStatus[to] == 2) totalCommitted += value;

        return true;
    }

    function allowance(address owner_, address spender)
        public
        view
        returns (uint256)
    {

        return _allowedShares[owner_][spender];
    }

    function moveShare(address src, address dst) external onlyOwner {

        uint256 senderBalance = _shareBalances[src].balance;
        _shareBalances[src].balance = _shareBalances[src].balance.sub(senderBalance);
        _shareBalances[dst].balance = _shareBalances[dst].balance.add(senderBalance);

        emit Transfer(src, dst, senderBalance);
    }

    function transferFrom(address from, address to, uint256 value)
        public
        updateAccount(from)
        updateAccount(to)
        validRecipient(to)
        returns (bool)
    {

        require(!reEntrancyMintMutex, "RE-ENTRANCY GUARD MUST BE FALSE");
        require(stakingStatus[from] == 0, "cannot send SHARE while staking. Please unstake to send");

        _allowedShares[from][msg.sender] = _allowedShares[from][msg.sender].sub(value);

        _shareBalances[from].balance = _shareBalances[from].balance.sub(value);
        _shareBalances[to].balance = _shareBalances[to].balance.add(value);
        emit Transfer(from, to, value);

        _moveDelegates(_delegates2[from], _delegates2[to], value);

        if (stakingStatus[to] == 1) totalStaked += value;
        else if (stakingStatus[to] == 2) totalCommitted += value;

        return true;
    }

    function approve(address spender, uint256 value)
        public
        validRecipient(spender)
        returns (bool)
    {

        _allowedShares[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    modifier validRecipient(address to) {

        require(to != address(0x0));
        require(to != address(this));
        _;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {

        _allowedShares[msg.sender][spender] =
            _allowedShares[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowedShares[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public

        returns (bool)    {

        uint256 oldValue = _allowedShares[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowedShares[msg.sender][spender] = 0;
        } else {
            _allowedShares[msg.sender][spender] = oldValue.sub(subtractedValue);
        }
        emit Approval(msg.sender, spender, _allowedShares[msg.sender][spender]);
        return true;
    }

    modifier updateAccount(address account) {

        require(_initializedDollar == true, "DOLLAR_NEEDS_INITIALIZATION");

        Dollars.claimDividends(account);

        for (uint256 i = 0; i < syntheticAssets.length; i++) {
            if (acceptedSynthAsset[syntheticAssets[i]]) {
                ICash(syntheticAssets[i]).claimDividends(account);
            }
        }

        _;
    }


    function delegates(address delegator)
        external
        view
        returns (address)
    {

        return _delegates2[delegator];
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
        require(signatory != address(0), "SeigniorageShares::delegateBySig: invalid signature");
        require(nonce == nonces2[signatory]++, "SeigniorageShares::delegateBySig: invalid nonce");
        require(now <= expiry, "SeigniorageShares::delegateBySig: signature expired");
        return _delegate(signatory, delegatee);
    }

    function getCurrentVotes(address account)
        external
        view
        returns (uint256)
    {

        uint32 nCheckpoints = numCheckpoints2[account];
        return nCheckpoints > 0 ? checkpoints2[account][nCheckpoints - 1].votes : 0;
    }

    function getPriorVotes(address account, uint blockNumber)
        external
        view
        returns (uint256)
    {

        require(blockNumber < block.number, "SeigniorageShares::getPriorVotes: not yet determined");

        uint32 nCheckpoints = numCheckpoints2[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        if (checkpoints2[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints2[account][nCheckpoints - 1].votes;
        }

        if (checkpoints2[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints2[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints2[account][lower].votes;
    }

    function _delegate(address delegator, address delegatee)
        internal
    {

        address currentDelegate = _delegates2[delegator];
        uint256 delegatorBalance = balanceOf(delegator);
        _delegates2[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _moveDelegates(address srcRep, address dstRep, uint256 amount) internal {

        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                uint32 srcRepNum = numCheckpoints2[srcRep];
                uint256 srcRepOld = srcRepNum > 0 ? checkpoints2[srcRep][srcRepNum - 1].votes : 0;
                uint256 srcRepNew = srcRepOld.sub(amount);
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                uint32 dstRepNum = numCheckpoints2[dstRep];
                uint256 dstRepOld = dstRepNum > 0 ? checkpoints2[dstRep][dstRepNum - 1].votes : 0;
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

        uint32 blockNumber = safe32(block.number, "SeigniorageShares::_writeCheckpoint: block number exceeds 32 bits");

        if (nCheckpoints > 0 && checkpoints2[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
            checkpoints2[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints2[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
            numCheckpoints2[delegatee] = nCheckpoints + 1;
        }

        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    function safe32(uint n, string memory errorMessage) internal pure returns (uint32) {

        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function getChainId() public pure returns (uint) {

        return IShareHelper(address(0x1Cb015194edB31FD0e7Fa7a41AfC3a6A42e451F6)).getChainId();
    }
}