pragma solidity 0.8.1;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT
pragma solidity 0.8.1;

interface ILinkedToILV {

  function ilv() external view returns (address);

}// MIT
pragma solidity 0.8.1;


interface ILockedPool is ILinkedToILV {

    function vault() external view returns (address);


    function tokenLocking() external view returns (address);


    function vaultRewardsPerToken() external view returns (uint256);


    function poolTokenReserve() external view returns (uint256);


    function balanceOf(address _staker) external view returns (uint256);


    function pendingVaultRewards(address _staker) external view returns (uint256);


    function stakeLockedTokens(address _staker, uint256 _amount) external;


    function unstakeLockedTokens(address _staker, uint256 _amount) external;


    function changeLockedHolder(address _from, address _to) external;


    function receiveVaultRewards(uint256 _amount) external;

}// MIT
pragma solidity 0.8.1;

library AddressUtils {


  function isContract(address addr) internal view returns (bool) {

    uint256 size = 0;

    assembly {
      size := extcodesize(addr)
    }

    return size > 0;
  }

}// MIT
pragma solidity 0.8.1;

contract AccessControl {

  uint256 public constant ROLE_ACCESS_MANAGER = 0x8000000000000000000000000000000000000000000000000000000000000000;

  uint256 private constant FULL_PRIVILEGES_MASK = type(uint256).max; // before 0.8.0: uint256(-1) overflows to 0xFFFF...

  mapping(address => uint256) public userRoles;

  event RoleUpdated(address indexed _by, address indexed _to, uint256 _requested, uint256 _actual);

  constructor() {
    userRoles[msg.sender] = FULL_PRIVILEGES_MASK;
  }

  function features() public view returns(uint256) {

    return userRoles[address(0)];
  }

  function updateFeatures(uint256 _mask) public {

    updateRole(address(0), _mask);
  }

  function updateRole(address operator, uint256 role) public {

    require(isSenderInRole(ROLE_ACCESS_MANAGER), "insufficient privileges (ROLE_ACCESS_MANAGER required)");

    userRoles[operator] = evaluateBy(msg.sender, userRoles[operator], role);

    emit RoleUpdated(msg.sender, operator, role, userRoles[operator]);
  }

  function evaluateBy(address operator, uint256 target, uint256 desired) public view returns(uint256) {

    uint256 p = userRoles[operator];

    target |= p & desired;
    target &= FULL_PRIVILEGES_MASK ^ (p & (FULL_PRIVILEGES_MASK ^ desired));

    return target;
  }

  function isFeatureEnabled(uint256 required) public view returns(bool) {

    return __hasRole(features(), required);
  }

  function isSenderInRole(uint256 required) public view returns(bool) {

    return isOperatorInRole(msg.sender, required);
  }

  function isOperatorInRole(address operator, uint256 required) public view returns(bool) {

    return __hasRole(userRoles[operator], required);
  }

  function __hasRole(uint256 actual, uint256 required) internal pure returns(bool) {

    return actual & required == required;
  }
}// MIT
pragma solidity 0.8.1;

interface ERC20Receiver {

  function onERC20Received(address _operator, address _from, uint256 _value, bytes calldata _data) external returns(bytes4);

}// MIT
pragma solidity 0.8.1;


contract IlluviumERC20 is AccessControl {

  uint256 public constant TOKEN_UID = 0x83ecb176af7c4f35a45ff0018282e3a05a1018065da866182df12285866f5a2c;

  string public constant name = "Illuvium";

  string public constant symbol = "ILV";

  uint8 public constant decimals = 18;

  uint256 public totalSupply; // is set to 7 million * 10^18 in the constructor

  mapping(address => uint256) public tokenBalances;

  mapping(address => address) public votingDelegates;

  struct VotingPowerRecord {
    uint64 blockNumber;

    uint192 votingPower;
  }

  mapping(address => VotingPowerRecord[]) public votingPowerHistory;

  mapping(address => uint256) public nonces;

  mapping(address => mapping(address => uint256)) public transferAllowances;

  uint32 public constant FEATURE_TRANSFERS = 0x0000_0001;

  uint32 public constant FEATURE_TRANSFERS_ON_BEHALF = 0x0000_0002;

  uint32 public constant FEATURE_UNSAFE_TRANSFERS = 0x0000_0004;

  uint32 public constant FEATURE_OWN_BURNS = 0x0000_0008;

  uint32 public constant FEATURE_BURNS_ON_BEHALF = 0x0000_0010;

  uint32 public constant FEATURE_DELEGATIONS = 0x0000_0020;

  uint32 public constant FEATURE_DELEGATIONS_ON_BEHALF = 0x0000_0040;

  uint32 public constant ROLE_TOKEN_CREATOR = 0x0001_0000;

  uint32 public constant ROLE_TOKEN_DESTROYER = 0x0002_0000;

  uint32 public constant ROLE_ERC20_RECEIVER = 0x0004_0000;

  uint32 public constant ROLE_ERC20_SENDER = 0x0008_0000;

  bytes4 private constant ERC20_RECEIVED = 0x4fc35859;

  bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

  bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegate,uint256 nonce,uint256 expiry)");

  event Transfer(address indexed _from, address indexed _to, uint256 _value);

  event Approval(address indexed _owner, address indexed _spender, uint256 _value);

  event Minted(address indexed _by, address indexed _to, uint256 _value);

  event Burnt(address indexed _by, address indexed _from, uint256 _value);

  event Transferred(address indexed _by, address indexed _from, address indexed _to, uint256 _value);

  event Approved(address indexed _owner, address indexed _spender, uint256 _oldValue, uint256 _value);

  event DelegateChanged(address indexed _of, address indexed _from, address indexed _to);

  event VotingPowerChanged(address indexed _of, uint256 _fromVal, uint256 _toVal);

  constructor(address _initialHolder) {
    require(_initialHolder != address(0), "_initialHolder not set (zero address)");

    mint(_initialHolder, 7_000_000e18);
  }


  function balanceOf(address _owner) public view returns (uint256 balance) {

    return tokenBalances[_owner];
  }

  function transfer(address _to, uint256 _value) public returns (bool success) {

    return transferFrom(msg.sender, _to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

    if(isFeatureEnabled(FEATURE_UNSAFE_TRANSFERS)
      || isOperatorInRole(_to, ROLE_ERC20_RECEIVER)
      || isSenderInRole(ROLE_ERC20_SENDER)) {
      unsafeTransferFrom(_from, _to, _value);
    }
    else {
      safeTransferFrom(_from, _to, _value, "");
    }

    return true;
  }

  function safeTransferFrom(address _from, address _to, uint256 _value, bytes memory _data) public {

    unsafeTransferFrom(_from, _to, _value);

    if(AddressUtils.isContract(_to)) {
      bytes4 response = ERC20Receiver(_to).onERC20Received(msg.sender, _from, _value, _data);

      require(response == ERC20_RECEIVED, "invalid onERC20Received response");
    }
  }

  function unsafeTransferFrom(address _from, address _to, uint256 _value) public {

    require(_from == msg.sender && isFeatureEnabled(FEATURE_TRANSFERS)
         || _from != msg.sender && isFeatureEnabled(FEATURE_TRANSFERS_ON_BEHALF),
            _from == msg.sender? "transfers are disabled": "transfers on behalf are disabled");

    require(_from != address(0), "ERC20: transfer from the zero address"); // Zeppelin msg

    require(_to != address(0), "ERC20: transfer to the zero address"); // Zeppelin msg

    require(_from != _to, "sender and recipient are the same (_from = _to)");

    require(_to != address(this), "invalid recipient (transfer to the token smart contract itself)");

    if(_value == 0) {
      emit Transfer(_from, _to, _value);

      return;
    }


    if(_from != msg.sender) {
      uint256 _allowance = transferAllowances[_from][msg.sender];

      require(_allowance >= _value, "ERC20: transfer amount exceeds allowance"); // Zeppelin msg

      _allowance -= _value;

      transferAllowances[_from][msg.sender] = _allowance;

      emit Approved(_from, msg.sender, _allowance + _value, _allowance);

      emit Approval(_from, msg.sender, _allowance);
    }

    require(tokenBalances[_from] >= _value, "ERC20: transfer amount exceeds balance"); // Zeppelin msg

    tokenBalances[_from] -= _value;

    tokenBalances[_to] += _value;

    __moveVotingPower(votingDelegates[_from], votingDelegates[_to], _value);

    emit Transferred(msg.sender, _from, _to, _value);

    emit Transfer(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public returns (bool success) {

    require(_spender != address(0), "ERC20: approve to the zero address"); // Zeppelin msg

    uint256 _oldValue = transferAllowances[msg.sender][_spender];

    transferAllowances[msg.sender][_spender] = _value;

    emit Approved(msg.sender, _spender, _oldValue, _value);

    emit Approval(msg.sender, _spender, _value);

    return true;
  }

  function allowance(address _owner, address _spender) public view returns (uint256 remaining) {

    return transferAllowances[_owner][_spender];
  }



  function increaseAllowance(address _spender, uint256 _value) public virtual returns (bool) {

    uint256 currentVal = transferAllowances[msg.sender][_spender];

    require(currentVal + _value > currentVal, "zero value approval increase or arithmetic overflow");

    return approve(_spender, currentVal + _value);
  }

  function decreaseAllowance(address _spender, uint256 _value) public virtual returns (bool) {

    uint256 currentVal = transferAllowances[msg.sender][_spender];

    require(_value > 0, "zero value approval decrease");

    require(currentVal >= _value, "ERC20: decreased allowance below zero");

    return approve(_spender, currentVal - _value);
  }



  function mint(address _to, uint256 _value) public {

    require(isSenderInRole(ROLE_TOKEN_CREATOR), "insufficient privileges (ROLE_TOKEN_CREATOR required)");

    require(_to != address(0), "ERC20: mint to the zero address"); // Zeppelin msg

    require(totalSupply + _value > totalSupply, "zero value mint or arithmetic overflow");

    require(totalSupply + _value <= type(uint192).max, "total supply overflow (uint192)");

    totalSupply += _value;

    tokenBalances[_to] += _value;

    __moveVotingPower(address(0), votingDelegates[_to], _value);

    emit Minted(msg.sender, _to, _value);

    emit Transferred(msg.sender, address(0), _to, _value);

    emit Transfer(address(0), _to, _value);
  }

  function burn(address _from, uint256 _value) public {

    if(!isSenderInRole(ROLE_TOKEN_DESTROYER)) {
      require(_from == msg.sender && isFeatureEnabled(FEATURE_OWN_BURNS)
           || _from != msg.sender && isFeatureEnabled(FEATURE_BURNS_ON_BEHALF),
              _from == msg.sender? "burns are disabled": "burns on behalf are disabled");

      if(_from != msg.sender) {
        uint256 _allowance = transferAllowances[_from][msg.sender];

        require(_allowance >= _value, "ERC20: burn amount exceeds allowance"); // Zeppelin msg

        _allowance -= _value;

        transferAllowances[_from][msg.sender] = _allowance;

        emit Approved(msg.sender, _from, _allowance + _value, _allowance);

        emit Approval(_from, msg.sender, _allowance);
      }
    }


    require(_value != 0, "zero value burn");

    require(_from != address(0), "ERC20: burn from the zero address"); // Zeppelin msg

    require(tokenBalances[_from] >= _value, "ERC20: burn amount exceeds balance"); // Zeppelin msg

    tokenBalances[_from] -= _value;

    totalSupply -= _value;

    __moveVotingPower(votingDelegates[_from], address(0), _value);

    emit Burnt(msg.sender, _from, _value);

    emit Transferred(msg.sender, _from, address(0), _value);

    emit Transfer(_from, address(0), _value);
  }



  function getVotingPower(address _of) public view returns (uint256) {

    VotingPowerRecord[] storage history = votingPowerHistory[_of];

    return history.length == 0? 0: history[history.length - 1].votingPower;
  }

  function getVotingPowerAt(address _of, uint256 _blockNum) public view returns (uint256) {

    require(_blockNum < block.number, "not yet determined"); // Compound msg

    VotingPowerRecord[] storage history = votingPowerHistory[_of];

    if(history.length == 0) {
      return 0;
    }

    if(history[history.length - 1].blockNumber <= _blockNum) {
      return getVotingPower(_of);
    }

    if(history[0].blockNumber > _blockNum) {
      return 0;
    }

    return history[__binaryLookup(_of, _blockNum)].votingPower;
  }

  function getVotingPowerHistory(address _of) public view returns(VotingPowerRecord[] memory) {

    return votingPowerHistory[_of];
  }

  function getVotingPowerHistoryLength(address _of) public view returns(uint256) {

    return votingPowerHistory[_of].length;
  }

  function delegate(address _to) public {

    require(isFeatureEnabled(FEATURE_DELEGATIONS), "delegations are disabled");
    __delegate(msg.sender, _to);
  }

  function delegateWithSig(address _to, uint256 _nonce, uint256 _exp, uint8 v, bytes32 r, bytes32 s) public {

    require(isFeatureEnabled(FEATURE_DELEGATIONS_ON_BEHALF), "delegations on behalf are disabled");

    bytes32 domainSeparator = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name)), block.chainid, address(this)));

    bytes32 hashStruct = keccak256(abi.encode(DELEGATION_TYPEHASH, _to, _nonce, _exp));

    bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, hashStruct));

    address signer = ecrecover(digest, v, r, s);

    require(signer != address(0), "invalid signature"); // Compound msg
    require(_nonce == nonces[signer], "invalid nonce"); // Compound msg
    require(block.timestamp < _exp, "signature expired"); // Compound msg

    nonces[signer]++;

    __delegate(signer, _to);
  }

  function __delegate(address _from, address _to) private {

    address _fromDelegate = votingDelegates[_from];

    uint256 _value = tokenBalances[_from];

    votingDelegates[_from] = _to;

    __moveVotingPower(_fromDelegate, _to, _value);

    emit DelegateChanged(_from, _fromDelegate, _to);
  }

  function __moveVotingPower(address _from, address _to, uint256 _value) private {

    if(_from == _to || _value == 0) {
      return;
    }

    if(_from != address(0)) {
      uint256 _fromVal = getVotingPower(_from);

      uint256 _toVal = _fromVal - _value;

      __updateVotingPower(_from, _fromVal, _toVal);
    }

    if(_to != address(0)) {
      uint256 _fromVal = getVotingPower(_to);

      uint256 _toVal = _fromVal + _value;

      __updateVotingPower(_to, _fromVal, _toVal);
    }
  }

  function __updateVotingPower(address _of, uint256 _fromVal, uint256 _toVal) private {

    VotingPowerRecord[] storage history = votingPowerHistory[_of];

    if(history.length != 0 && history[history.length - 1].blockNumber == block.number) {
      history[history.length - 1].votingPower = uint192(_toVal);
    }
    else {
      history.push(VotingPowerRecord(uint64(block.number), uint192(_toVal)));
    }

    emit VotingPowerChanged(_of, _fromVal, _toVal);
  }

  function __binaryLookup(address _to, uint256 n) private view returns(uint256) {

    VotingPowerRecord[] storage history = votingPowerHistory[_to];

    uint256 i = 0;

    uint256 j = history.length - 1;

    while(j > i) {
      uint256 k = j - (j - i) / 2;

      VotingPowerRecord memory cp = history[k];

      if(cp.blockNumber == n) {
        return k;
      }
      else if (cp.blockNumber < n) {
        i = k;
      }
      else {
        j = k - 1;
      }
    }

    return i;
  }
}

pragma solidity 0.8.1;


abstract contract IlluviumAware is ILinkedToILV {
  address public immutable override ilv;

  constructor(address _ilv) {
    require(_ilv != address(0), "ILV address not set");
    require(IlluviumERC20(_ilv).TOKEN_UID() == 0x83ecb176af7c4f35a45ff0018282e3a05a1018065da866182df12285866f5a2c, "unexpected TOKEN_UID");

    ilv = _ilv;
  }

  function transferIlv(address _to, uint256 _value) internal {
    transferIlvFrom(address(this), _to, _value);
  }

  function transferIlvFrom(address _from, address _to, uint256 _value) internal {
    IlluviumERC20(ilv).transferFrom(_from, _to, _value);
  }

  function mintIlv(address _to, uint256 _value) internal {
    IlluviumERC20(ilv).mint(_to, _value);
  }

}// MIT
pragma solidity 0.8.1;

abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
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
}// MIT
pragma solidity 0.8.1;


contract TokenLocking is Ownable, IlluviumAware {

    uint256 public constant LOCKING_UID = 0x76ff776d518e4c1b71ef4a1af2227a94e9868d7c9ecfa08e9255d2360e18f347;

    struct UserRecord {
        uint96 ilvBalance;
        uint96 ilvReleased;
        bool hasStaked;
    }

    mapping(address => UserRecord) public userRecords;

    address[] public lockedHolders;

    uint64 public immutable cliff;
    uint32 public immutable duration;

    IlluviumLockedPool public pool;

    mapping(address => uint256) public migrationNonces;

    bytes32 public constant DOMAIN_TYPEHASH =
        keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    bytes32 public immutable DOMAIN_SEPARATOR;

    bytes32 public constant MIGRATION_TYPEHASH =
        keccak256("Migration(address from,address to,uint256 nonce,uint256 expiry)");

    event TokensReleased(address indexed holder, uint96 amountIlv);
    event TokensStaked(address indexed _by, address indexed pool, uint96 amount);
    event TokensUnstaked(address indexed _by, address indexed pool, uint96 amount);
    event PoolUpdated(address indexed _by, address indexed poolAddr);
    event LockedBalancesSet(address indexed _by, uint32 recordsNum, uint96 totalAmount);
    event TokensMigrated(address indexed _from, address indexed _to);

    constructor(
        uint64 _cliff,
        uint32 _duration,
        address _ilv
    ) IlluviumAware(_ilv) {
        require(_cliff > 0, "cliff is not set (zero)");
        require(_duration > 0, "duration is not set (zero)");

        cliff = _cliff;
        duration = _duration;

        DOMAIN_SEPARATOR = keccak256(
            abi.encode(DOMAIN_TYPEHASH, keccak256(bytes("TokenLocking")), block.chainid, address(this))
        );
    }

    function setPool(IlluviumLockedPool _pool) external onlyOwner {

        require(address(_pool) != address(0), "Pool address is not specified (zero)");
        require(address(pool) == address(0), "Pool is already set");

        require(
            _pool.POOL_UID() == 0x620bbda48b8ff3098da2f0033cbf499115c61efdd5dcd2db05346782df6218e7,
            "unexpected POOL_UID"
        );

        pool = _pool;

        emit PoolUpdated(msg.sender, address(_pool));
    }

    function setBalances(
        address[] memory holders,
        uint96[] memory amounts,
        uint96 expectedTotal
    ) external onlyOwner {

        require(holders.length == amounts.length, "input arr lengths mismatch");

        require(address(pool) == address(0), "too late: pool is already set");

        require(now256() < cliff, "too late: unlocking already begun");

        for (uint256 i = 0; i < lockedHolders.length; i++) {
            delete userRecords[lockedHolders[i]];
        }

        lockedHolders = holders;

        uint96 totalAmount = 0;

        for (uint256 i = 0; i < holders.length; i++) {
            require(holders[i] != address(0), "zero holder address found");
            require(amounts[i] != 0, "zero amount found");

            require(userRecords[holders[i]].ilvBalance == 0, "duplicate addresses found");

            userRecords[holders[i]].ilvBalance = amounts[i];

            totalAmount += amounts[i];
        }

        require(totalAmount == expectedTotal, "unexpected total");

        emit LockedBalancesSet(msg.sender, uint32(holders.length), totalAmount);
    }

    function balanceOf(address holder) external view returns (uint96) {

        return userRecords[holder].ilvBalance;
    }

    function hasStaked(address holder) external view returns (bool) {

        return userRecords[holder].hasStaked;
    }

    function release() external {

        UserRecord storage userRecord = userRecords[msg.sender];
        uint96 unreleasedIlv = releasableAmount(msg.sender);

        require(unreleasedIlv > 0, "no tokens are due");

        userRecord.ilvBalance -= unreleasedIlv;
        userRecord.ilvReleased += unreleasedIlv;

        if (userRecord.hasStaked) {
            _unstakeIlv(unreleasedIlv);
        }
        transferIlv(msg.sender, unreleasedIlv);

        emit TokensReleased(msg.sender, unreleasedIlv);
    }

    function stake() external {

        require(address(pool) != address(0), "pool is not set");

        UserRecord storage userRecord = userRecords[msg.sender];

        require(!userRecord.hasStaked, "tokens already staked");

        uint96 amount = userRecord.ilvBalance;

        require(amount > 0, "nothing to stake");

        userRecord.hasStaked = true;

        pool.stakeLockedTokens(msg.sender, amount);

        emit TokensStaked(msg.sender, address(pool), amount);
    }

    function _unstakeIlv(uint96 amount) private {

        pool.unstakeLockedTokens(msg.sender, amount);
        emit TokensUnstaked(msg.sender, address(pool), amount);
    }

    function migrateWithSig(
        address _from,
        address _to,
        uint256 _nonce,
        uint256 _exp,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {

        bytes32 hashStruct = keccak256(abi.encode(MIGRATION_TYPEHASH, _from, _to, _nonce, _exp));

        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, hashStruct));

        address signer = ecrecover(digest, v, r, s);

        require(signer != address(0), "invalid signature");
        require(_nonce == migrationNonces[signer], "invalid nonce");
        require(now256() < _exp, "signature expired");

        require(
            (signer == _from && msg.sender == owner()) || (signer == owner() && msg.sender == _from),
            "access denied"
        );

        migrationNonces[signer]++;

        __migrateTokens(_from, _to);
    }

    function __migrateTokens(address _from, address _to) private {

        require(_to != address(0), "receiver is not set");

        require(userRecords[_from].ilvBalance != 0 || userRecords[_from].ilvReleased != 0, "sender doesn't exist");
        require(userRecords[_to].ilvBalance == 0 && userRecords[_to].ilvReleased == 0, "recipient already exists");

        userRecords[_to] = userRecords[_from];
        delete userRecords[_from];

        if (address(pool) != address(0)) {
            pool.changeLockedHolder(_from, _to);
        }

        lockedHolders.push(_to);

        emit TokensMigrated(_from, _to);
    }

    function releasableAmount(address holder) public view returns (uint96 ilvAmt) {

        return vestedAmount(holder) - userRecords[holder].ilvReleased;
    }

    function vestedAmount(address holder) public view returns (uint96 ilvAmt) {

        if (now256() < cliff) {
            return 0;
        }

        UserRecord memory userRecord = userRecords[holder];

        ilvAmt = linearUnlockAmt(userRecord.ilvBalance + userRecord.ilvReleased);

        return ilvAmt;
    }

    function linearUnlockAmt(uint96 balance) public view returns (uint96) {

        uint256 _now256 = now256();

        if (_now256 < cliff) {
            _now256 = cliff;
        } else if (_now256 - cliff > duration) {
            _now256 = cliff + duration;
        }

        return uint96((balance * (_now256 - cliff)) / duration);
    }

    function now256() public view virtual returns (uint256) {

        return block.timestamp;
    }
}// MIT
pragma solidity 0.8.1;


contract IlluviumLockedPool is ILockedPool, IlluviumAware {

    uint256 public constant POOL_UID = 0x620bbda48b8ff3098da2f0033cbf499115c61efdd5dcd2db05346782df6218e7;

    struct User {
        uint256 tokenAmount;
        uint256 subVaultRewards;
    }

    address public override vault;

    address public override tokenLocking;

    uint256 public override vaultRewardsPerToken;

    uint256 public override poolTokenReserve;

    mapping(address => User) public users;

    uint256 private constant REWARD_PER_TOKEN_MULTIPLIER = 1e12;

    event Staked(address indexed _from, uint256 amount);

    event Unstaked(address indexed _to, uint256 amount);

    event VaultRewardsClaimed(address indexed _by, address indexed _to, uint256 amount);

    event VaultRewardsReceived(address indexed _by, uint256 amount);

    event VaultUpdated(address indexed _by, address _fromVal, address _toVal);

    modifier onlyTokenLocking() {

        require(msg.sender == tokenLocking, "access denied");
        _;
    }

    constructor(address _ilv, address _tokenLocking) IlluviumAware(_ilv) {
        require(_tokenLocking != address(0), "TokenLocking address is not set");

        require(
            TokenLocking(_tokenLocking).LOCKING_UID() ==
                0x76ff776d518e4c1b71ef4a1af2227a94e9868d7c9ecfa08e9255d2360e18f347,
            "unexpected LOCKING_UID"
        );

        tokenLocking = _tokenLocking;
    }

    function tokensToReward(uint256 _tokens, uint256 _rewardPerToken) public pure returns (uint256 _reward) {

        return (_tokens * _rewardPerToken) / REWARD_PER_TOKEN_MULTIPLIER;
    }

    function rewardPerToken(uint256 _reward, uint256 _tokens) public pure returns (uint256 _rewardPerToken) {

        return (_reward * REWARD_PER_TOKEN_MULTIPLIER) / _tokens;
    }

    function pendingVaultRewards(address _staker) public view override returns (uint256 pending) {

        User memory user = users[_staker];

        return tokensToReward(user.tokenAmount, vaultRewardsPerToken) - user.subVaultRewards;
    }

    function balanceOf(address _staker) external view override returns (uint256 balance) {

        balance = users[_staker].tokenAmount;
    }

    function setVault(address _vault) external {

        require(Ownable(tokenLocking).owner() == msg.sender, "access denied");

        require(_vault != address(0), "zero input");

        emit VaultUpdated(msg.sender, vault, _vault);

        vault = _vault;
    }

    function stakeLockedTokens(address _staker, uint256 _amount) external override onlyTokenLocking {

        _stake(_staker, _amount);
    }

    function unstakeLockedTokens(address _staker, uint256 _amount) external override onlyTokenLocking {

        _unstake(_staker, _amount);
    }

    function processVaultRewards() external {

        _processVaultRewards(msg.sender);
    }

    function receiveVaultRewards(uint256 _rewardsAmount) external override {

        require(msg.sender == vault, "access denied");
        if (_rewardsAmount == 0) {
            return;
        }
        require(poolTokenReserve > 0, "zero reserve");

        transferIlvFrom(msg.sender, address(this), _rewardsAmount);

        vaultRewardsPerToken += rewardPerToken(_rewardsAmount, poolTokenReserve);
        poolTokenReserve += _rewardsAmount;

        emit VaultRewardsReceived(msg.sender, _rewardsAmount);
    }

    function changeLockedHolder(address _from, address _to) external override onlyTokenLocking {

        users[_to] = users[_from];
        delete users[_from];
    }

    function _stake(address _staker, uint256 _amount) private {

        require(_amount > 0, "zero amount");
        _processVaultRewards(_staker);

        User storage user = users[_staker];
        user.tokenAmount += _amount;
        poolTokenReserve += _amount;
        user.subVaultRewards = tokensToReward(user.tokenAmount, vaultRewardsPerToken);

        emit Staked(_staker, _amount);
    }

    function _unstake(address _staker, uint256 _amount) private {

        require(_amount > 0, "zero amount");
        User storage user = users[_staker];
        require(user.tokenAmount >= _amount, "not enough balance");
        _processVaultRewards(_staker);
        user.tokenAmount -= _amount;
        poolTokenReserve -= _amount;
        user.subVaultRewards = tokensToReward(user.tokenAmount, vaultRewardsPerToken);

        emit Unstaked(_staker, _amount);
    }

    function _processVaultRewards(address _staker) private {

        User storage user = users[_staker];
        uint256 pendingVaultClaim = pendingVaultRewards(_staker);
        if (pendingVaultClaim == 0) return;
        uint256 ilvBalance = IERC20(ilv).balanceOf(address(this));
        require(ilvBalance >= pendingVaultClaim, "contract ILV balance too low");
        poolTokenReserve -= pendingVaultClaim > poolTokenReserve ? poolTokenReserve : pendingVaultClaim;

        user.subVaultRewards = tokensToReward(user.tokenAmount, vaultRewardsPerToken);

        transferIlv(_staker, pendingVaultClaim);

        emit VaultRewardsClaimed(msg.sender, _staker, pendingVaultClaim);
    }
}