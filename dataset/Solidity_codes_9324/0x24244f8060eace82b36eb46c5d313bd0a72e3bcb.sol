

pragma solidity 0.7.5;

abstract contract Context {
  function _msgSender() internal view virtual returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}



pragma solidity 0.7.5;

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



pragma solidity 0.7.5;

library SafeMath {

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    require(c >= a, 'SafeMath: addition overflow');

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    return sub(a, b, 'SafeMath: subtraction overflow');
  }

  function sub(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {

    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, 'SafeMath: multiplication overflow');

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    return div(a, b, 'SafeMath: division by zero');
  }

  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {

    require(b > 0, errorMessage);
    uint256 c = a / b;

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {

    return mod(a, b, 'SafeMath: modulo by zero');
  }

  function mod(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {

    require(b != 0, errorMessage);
    return a % b;
  }
}



pragma solidity 0.7.5;

library Address {

  function isContract(address account) internal view returns (bool) {

    bytes32 codehash;
    bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
    assembly {
      codehash := extcodehash(account)
    }
    return (codehash != accountHash && codehash != 0x0);
  }

  function sendValue(address payable recipient, uint256 amount) internal {

    require(address(this).balance >= amount, 'Address: insufficient balance');

    (bool success, ) = recipient.call{value: amount}('');
    require(success, 'Address: unable to send value, recipient may have reverted');
  }
}



pragma solidity ^0.7.5;




contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string internal _name;
    string internal _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    function name() virtual public view returns (string memory) {

        return _name;
    }

    function symbol() virtual public view returns (string memory) {

        return _symbol;
    }

    function decimals() virtual public view returns (uint8) {

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



pragma solidity 0.7.5;

contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor() {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  function owner() public view returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(_owner == _msgSender(), 'Ownable: caller is not the owner');
    _;
  }

  function renounceOwnership() public virtual onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  function transferOwnership(address newOwner) public virtual onlyOwner {
    require(newOwner != address(0), 'Ownable: new owner is the zero address');
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}



pragma solidity 0.7.5;

interface IGovernancePowerDelegationERC20 {

  enum DelegationType {
    VOTING_POWER,
    PROPOSITION_POWER
  }

  event DelegateChanged(
    address indexed delegator,
    address indexed delegatee,
    DelegationType delegationType
  );

  event DelegatedPowerChanged(address indexed user, uint256 amount, DelegationType delegationType);

  function delegateByType(address delegatee, DelegationType delegationType) external virtual;

  function delegate(address delegatee) external virtual;

  function getDelegateeByType(address delegator, DelegationType delegationType)
    external
    view
    virtual
    returns (address);

  function getPowerCurrent(address user, DelegationType delegationType)
    external
    view
    virtual
    returns (uint256);

  function getPowerAtBlock(
    address user,
    uint256 blockNumber,
    DelegationType delegationType
  )
    external
    view
    virtual
    returns (uint256);
}



pragma solidity 0.7.5;



abstract contract GovernancePowerDelegationERC20Mixin is
  ERC20,
  IGovernancePowerDelegationERC20
{
  using SafeMath for uint256;


  bytes32 public constant DELEGATE_BY_TYPE_TYPEHASH = keccak256(
    'DelegateByType(address delegatee,uint256 type,uint256 nonce,uint256 expiry)'
  );

  bytes32 public constant DELEGATE_TYPEHASH = keccak256(
    'Delegate(address delegatee,uint256 nonce,uint256 expiry)'
  );


  struct Snapshot {
    uint128 blockNumber;
    uint128 value;
  }


  function delegateByType(
    address delegatee,
    DelegationType delegationType
  )
    external
    override
  {
    _delegateByType(msg.sender, delegatee, delegationType);
  }

  function delegate(
    address delegatee
  )
    external
    override
  {
    _delegateByType(msg.sender, delegatee, DelegationType.VOTING_POWER);
    _delegateByType(msg.sender, delegatee, DelegationType.PROPOSITION_POWER);
  }

  function getDelegateeByType(
    address delegator,
    DelegationType delegationType
  )
    external
    override
    view
    returns (address)
  {
    (, , mapping(address => address) storage delegates) = _getDelegationDataByType(delegationType);

    return _getDelegatee(delegator, delegates);
  }

  function getPowerCurrent(
    address user,
    DelegationType delegationType
  )
    external
    override
    view
    returns (uint256)
  {
    (
      mapping(address => mapping(uint256 => Snapshot)) storage snapshots,
      mapping(address => uint256) storage snapshotsCounts,
    ) = _getDelegationDataByType(delegationType);

    return _searchByBlockNumber(snapshots, snapshotsCounts, user, block.number);
  }

  function getPowerAtBlock(
    address user,
    uint256 blockNumber,
    DelegationType delegationType
  )
    external
    override
    view
    returns (uint256)
  {
    (
      mapping(address => mapping(uint256 => Snapshot)) storage snapshots,
      mapping(address => uint256) storage snapshotsCounts,
    ) = _getDelegationDataByType(delegationType);

    return _searchByBlockNumber(snapshots, snapshotsCounts, user, blockNumber);
  }


  function _delegateByType(
    address delegator,
    address delegatee,
    DelegationType delegationType
  )
    internal
  {
    require(
      delegatee != address(0),
      'INVALID_DELEGATEE'
    );

    (, , mapping(address => address) storage delegates) = _getDelegationDataByType(delegationType);

    uint256 delegatorBalance = balanceOf(delegator);

    address previousDelegatee = _getDelegatee(delegator, delegates);

    delegates[delegator] = delegatee;

    _moveDelegatesByType(previousDelegatee, delegatee, delegatorBalance, delegationType);
    emit DelegateChanged(delegator, delegatee, delegationType);
  }

  function _moveDelegatesByType(
    address from,
    address to,
    uint256 amount,
    DelegationType delegationType
  )
    internal
  {
    if (from == to) {
      return;
    }

    (
      mapping(address => mapping(uint256 => Snapshot)) storage snapshots,
      mapping(address => uint256) storage snapshotsCounts,
    ) = _getDelegationDataByType(delegationType);

    if (from != address(0)) {
      uint256 previous = 0;
      uint256 fromSnapshotsCount = snapshotsCounts[from];

      if (fromSnapshotsCount != 0) {
        previous = snapshots[from][fromSnapshotsCount - 1].value;
      } else {
        previous = balanceOf(from);
      }

      uint256 newAmount = previous.sub(amount);
      _writeSnapshot(
        snapshots,
        snapshotsCounts,
        from,
        uint128(newAmount)
      );

      emit DelegatedPowerChanged(from, newAmount, delegationType);
    }

    if (to != address(0)) {
      uint256 previous = 0;
      uint256 toSnapshotsCount = snapshotsCounts[to];
      if (toSnapshotsCount != 0) {
        previous = snapshots[to][toSnapshotsCount - 1].value;
      } else {
        previous = balanceOf(to);
      }

      uint256 newAmount = previous.add(amount);
      _writeSnapshot(
        snapshots,
        snapshotsCounts,
        to,
        uint128(newAmount)
      );

      emit DelegatedPowerChanged(to, newAmount, delegationType);
    }
  }

  function _searchByBlockNumber(
    mapping(address => mapping(uint256 => Snapshot)) storage snapshots,
    mapping(address => uint256) storage snapshotsCounts,
    address user,
    uint256 blockNumber
  )
    internal
    view
    returns (uint256)
  {
    require(
      blockNumber <= block.number,
      'INVALID_BLOCK_NUMBER'
    );

    uint256 snapshotsCount = snapshotsCounts[user];

    if (snapshotsCount == 0) {
      return balanceOf(user);
    }

    if (snapshots[user][snapshotsCount - 1].blockNumber <= blockNumber) {
      return snapshots[user][snapshotsCount - 1].value;
    }

    if (snapshots[user][0].blockNumber > blockNumber) {
      return 0;
    }

    uint256 lower = 0;
    uint256 upper = snapshotsCount - 1;
    while (upper > lower) {
      uint256 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
      Snapshot memory snapshot = snapshots[user][center];
      if (snapshot.blockNumber == blockNumber) {
        return snapshot.value;
      } else if (snapshot.blockNumber < blockNumber) {
        lower = center;
      } else {
        upper = center - 1;
      }
    }
    return snapshots[user][lower].value;
  }

  function _getDelegationDataByType(
    DelegationType delegationType
  )
    internal
    virtual
    view
    returns (
      mapping(address => mapping(uint256 => Snapshot)) storage, // snapshots
      mapping(address => uint256) storage, // snapshotsCount
      mapping(address => address) storage // delegates
    );

  function _writeSnapshot(
    mapping(address => mapping(uint256 => Snapshot)) storage snapshots,
    mapping(address => uint256) storage snapshotsCounts,
    address owner,
    uint128 newValue
  )
    internal
  {
    uint128 currentBlock = uint128(block.number);

    uint256 ownerSnapshotsCount = snapshotsCounts[owner];
    mapping(uint256 => Snapshot) storage ownerSnapshots = snapshots[owner];

    if (
      ownerSnapshotsCount != 0 &&
      ownerSnapshots[ownerSnapshotsCount - 1].blockNumber == currentBlock
    ) {
      ownerSnapshots[ownerSnapshotsCount - 1].value = newValue;
    } else {
      ownerSnapshots[ownerSnapshotsCount] = Snapshot(currentBlock, newValue);
      snapshotsCounts[owner] = ownerSnapshotsCount + 1;
    }
  }

  function _getDelegatee(
    address delegator,
    mapping(address => address) storage delegates
  )
    internal
    view
    returns (address)
  {
    address previousDelegatee = delegates[delegator];

    if (previousDelegatee == address(0)) {
      return delegator;
    }

    return previousDelegatee;
  }
}



pragma solidity 0.7.5;




contract DydxToken is
  GovernancePowerDelegationERC20Mixin,
  Ownable
{
  using SafeMath for uint256;


  event TransferAllowlistUpdated(
    address account,
    bool isAllowed
  );

  event TransfersRestrictedBeforeUpdated(
    uint256 transfersRestrictedBefore
  );


  string internal constant NAME = 'dYdX';
  string internal constant SYMBOL = 'DYDX';

  uint256 public constant INITIAL_SUPPLY = 1_000_000_000 ether;

  bytes32 public immutable DOMAIN_SEPARATOR;
  bytes public constant EIP712_VERSION = '1';
  bytes32 public constant EIP712_DOMAIN = keccak256(
    'EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'
  );
  bytes32 public constant PERMIT_TYPEHASH = keccak256(
    'Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)'
  );

  uint256 public constant MINT_MIN_INTERVAL = 365 days;

  uint256 public immutable MINT_MAX_PERCENT;

  uint256 public immutable TRANSFER_RESTRICTION_LIFTED_NO_LATER_THAN;


  mapping(address => uint256) internal _nonces;

  mapping(address => mapping(uint256 => Snapshot)) public _votingSnapshots;
  mapping(address => uint256) public _votingSnapshotsCounts;
  mapping(address => address) public _votingDelegates;

  mapping(address => mapping(uint256 => Snapshot)) public _propositionPowerSnapshots;
  mapping(address => uint256) public _propositionPowerSnapshotsCounts;
  mapping(address => address) public _propositionPowerDelegates;

  mapping(uint256 => Snapshot) public _totalSupplySnapshots;

  uint256 public _totalSupplySnapshotsCount;

  mapping(address => bool) public _tokenTransferAllowlist;

  uint256 public _mintingRestrictedBefore;

  uint256 public _transfersRestrictedBefore;


  constructor(
    address distributor,
    uint256 transfersRestrictedBefore,
    uint256 transferRestrictionLiftedNoLaterThan,
    uint256 mintingRestrictedBefore,
    uint256 mintMaxPercent
  )
    ERC20(NAME, SYMBOL)
  {
    uint256 chainId;

    assembly {
      chainId := chainid()
    }

    DOMAIN_SEPARATOR = keccak256(
      abi.encode(
        EIP712_DOMAIN,
        keccak256(bytes(NAME)),
        keccak256(bytes(EIP712_VERSION)),
        chainId,
        address(this)
      )
    );

    require(
      transfersRestrictedBefore > block.timestamp,
      'TRANSFERS_RESTRICTED_BEFORE_TOO_EARLY'
    );
    require(
      transfersRestrictedBefore <= transferRestrictionLiftedNoLaterThan,
      'MAX_TRANSFER_RESTRICTION_TOO_EARLY'
    );
    require(
      mintingRestrictedBefore > block.timestamp,
      'MINTING_RESTRICTED_BEFORE_TOO_EARLY'
    );
    _transfersRestrictedBefore = transfersRestrictedBefore;
    TRANSFER_RESTRICTION_LIFTED_NO_LATER_THAN = transferRestrictionLiftedNoLaterThan;
    _mintingRestrictedBefore = mintingRestrictedBefore;
    MINT_MAX_PERCENT = mintMaxPercent;

    _mint(distributor, INITIAL_SUPPLY);

    emit TransfersRestrictedBeforeUpdated(transfersRestrictedBefore);
  }


  function addToTokenTransferAllowlist(
    address[] calldata addressesToAdd
  )
    external
    onlyOwner
  {
    for (uint256 i = 0; i < addressesToAdd.length; i++) {
      require(
        !_tokenTransferAllowlist[addressesToAdd[i]],
        'ADDRESS_EXISTS_IN_TRANSFER_ALLOWLIST'
      );
      _tokenTransferAllowlist[addressesToAdd[i]] = true;
      emit TransferAllowlistUpdated(addressesToAdd[i], true);
    }
  }

  function removeFromTokenTransferAllowlist(
    address[] calldata addressesToRemove
  )
    external
    onlyOwner
  {
    for (uint256 i = 0; i < addressesToRemove.length; i++) {
      require(
        _tokenTransferAllowlist[addressesToRemove[i]],
        'ADDRESS_DOES_NOT_EXIST_IN_TRANSFER_ALLOWLIST'
      );
      _tokenTransferAllowlist[addressesToRemove[i]] = false;
      emit TransferAllowlistUpdated(addressesToRemove[i], false);
    }
  }

  function updateTransfersRestrictedBefore(
    uint256 transfersRestrictedBefore
  )
    external
    onlyOwner
  {
    uint256 previousTransfersRestrictedBefore = _transfersRestrictedBefore;
    require(
      block.timestamp < previousTransfersRestrictedBefore,
      'TRANSFER_RESTRICTION_ENDED'
    );
    require(
      previousTransfersRestrictedBefore <= transfersRestrictedBefore,
      'NEW_TRANSFER_RESTRICTION_TOO_EARLY'
    );
    require(
      transfersRestrictedBefore <= TRANSFER_RESTRICTION_LIFTED_NO_LATER_THAN,
      'AFTER_MAX_TRANSFER_RESTRICTION'
    );

    _transfersRestrictedBefore = transfersRestrictedBefore;

    emit TransfersRestrictedBeforeUpdated(transfersRestrictedBefore);
  }

  function mint(
    address recipient,
    uint256 amount
  )
    external
    onlyOwner
  {
    require(
      block.timestamp >= _mintingRestrictedBefore,
      'MINT_TOO_EARLY'
    );
    require(
      amount <= totalSupply().mul(MINT_MAX_PERCENT).div(100),
      'MAX_MINT_EXCEEDED'
    );

    _mintingRestrictedBefore = block.timestamp.add(MINT_MIN_INTERVAL);

    _mint(recipient, amount);
  }

  function permit(
    address owner,
    address spender,
    uint256 value,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  )
    external
  {
    require(
      owner != address(0),
      'INVALID_OWNER'
    );
    require(
      block.timestamp <= deadline,
      'INVALID_EXPIRATION'
    );
    uint256 currentValidNonce = _nonces[owner];
    bytes32 digest = keccak256(
      abi.encodePacked(
        '\x19\x01',
        DOMAIN_SEPARATOR,
        keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, currentValidNonce, deadline))
      )
    );

    require(
      owner == ecrecover(digest, v, r, s),
      'INVALID_SIGNATURE'
    );
    _nonces[owner] = currentValidNonce.add(1);
    _approve(owner, spender, value);
  }

  function nonces(
    address owner
  )
    external
    view
    returns (uint256)
  {
    return _nonces[owner];
  }

  function transfer(
    address recipient,
    uint256 amount
  )
    public
    override
    returns (bool)
  {
    _requireTransferAllowed(_msgSender(), recipient);
    return super.transfer(recipient, amount);
  }

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  )
    public
    override
    returns (bool)
  {
    _requireTransferAllowed(sender, recipient);
    return super.transferFrom(sender, recipient, amount);
  }

  function _mint(
    address account,
    uint256 amount
  )
    internal
    override
  {
    super._mint(account, amount);

    uint256 snapshotsCount = _totalSupplySnapshotsCount;
    uint128 currentBlock = uint128(block.number);
    uint128 newValue = uint128(totalSupply());

    _totalSupplySnapshots[snapshotsCount] = Snapshot(currentBlock, newValue);
    _totalSupplySnapshotsCount = snapshotsCount.add(1);
  }

  function _requireTransferAllowed(
    address sender,
    address recipient
  )
    view
    internal
  {
    if (
      block.timestamp < TRANSFER_RESTRICTION_LIFTED_NO_LATER_THAN &&
      block.timestamp < _transfersRestrictedBefore
    ) {
      require(
        _tokenTransferAllowlist[sender] || _tokenTransferAllowlist[recipient],
        'NON_ALLOWLIST_TRANSFERS_DISABLED'
      );
    }
  }

  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 amount
  )
    internal
    override
  {
    address votingFromDelegatee = _getDelegatee(from, _votingDelegates);
    address votingToDelegatee = _getDelegatee(to, _votingDelegates);

    _moveDelegatesByType(
      votingFromDelegatee,
      votingToDelegatee,
      amount,
      DelegationType.VOTING_POWER
    );

    address propPowerFromDelegatee = _getDelegatee(from, _propositionPowerDelegates);
    address propPowerToDelegatee = _getDelegatee(to, _propositionPowerDelegates);

    _moveDelegatesByType(
      propPowerFromDelegatee,
      propPowerToDelegatee,
      amount,
      DelegationType.PROPOSITION_POWER
    );
  }

  function _getDelegationDataByType(
    DelegationType delegationType
  )
    internal
    override
    view
    returns (
      mapping(address => mapping(uint256 => Snapshot)) storage, // snapshots
      mapping(address => uint256) storage, // snapshots count
      mapping(address => address) storage // delegatees list
    )
  {
    if (delegationType == DelegationType.VOTING_POWER) {
      return (_votingSnapshots, _votingSnapshotsCounts, _votingDelegates);
    } else {
      return (
        _propositionPowerSnapshots,
        _propositionPowerSnapshotsCounts,
        _propositionPowerDelegates
      );
    }
  }

  function delegateByTypeBySig(
    address delegatee,
    DelegationType delegationType,
    uint256 nonce,
    uint256 expiry,
    uint8 v,
    bytes32 r,
    bytes32 s
  )
    public
  {
    bytes32 structHash = keccak256(
      abi.encode(DELEGATE_BY_TYPE_TYPEHASH, delegatee, uint256(delegationType), nonce, expiry)
    );
    bytes32 digest = keccak256(abi.encodePacked('\x19\x01', DOMAIN_SEPARATOR, structHash));
    address signer = ecrecover(digest, v, r, s);
    require(
      signer != address(0),
      'INVALID_SIGNATURE'
    );
    require(
      nonce == _nonces[signer]++,
      'INVALID_NONCE'
    );
    require(
      block.timestamp <= expiry,
      'INVALID_EXPIRATION'
    );
    _delegateByType(signer, delegatee, delegationType);
  }

  function delegateBySig(
    address delegatee,
    uint256 nonce,
    uint256 expiry,
    uint8 v,
    bytes32 r,
    bytes32 s
  )
    public
  {
    bytes32 structHash = keccak256(abi.encode(DELEGATE_TYPEHASH, delegatee, nonce, expiry));
    bytes32 digest = keccak256(abi.encodePacked('\x19\x01', DOMAIN_SEPARATOR, structHash));
    address signer = ecrecover(digest, v, r, s);
    require(
      signer != address(0),
      'INVALID_SIGNATURE'
    );
    require(
      nonce == _nonces[signer]++,
      'INVALID_NONCE'
    );
    require(
      block.timestamp <= expiry,
      'INVALID_EXPIRATION'
    );
    _delegateByType(signer, delegatee, DelegationType.VOTING_POWER);
    _delegateByType(signer, delegatee, DelegationType.PROPOSITION_POWER);
  }
}