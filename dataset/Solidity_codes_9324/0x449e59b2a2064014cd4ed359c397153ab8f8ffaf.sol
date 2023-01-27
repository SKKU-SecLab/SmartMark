
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


interface IAccessControl {

    function hasRole(bytes32 role, address account) external view returns (bool);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function grantRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function renounceRole(bytes32 role, address account) external;

}

abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping (address => bool) members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override {
        require(hasRole(getRoleAdmin(role), _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override {
        require(hasRole(getRoleAdmin(role), _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}// AGPL-3.0
pragma solidity 0.8.3;

interface IOndo {

  enum InvestorType {CoinlistTranche1, CoinlistTranche2, SeedTranche}


  function updateTrancheBalance(
    address beneficiary,
    uint256 rawAmount,
    InvestorType tranche
  ) external;



  function getFreedBalance(address account) external view returns (uint96);


  function getVestedBalance(address account)
    external
    view
    returns (uint96, uint96);

}// AGPL-3.0
pragma solidity 0.8.3;


abstract contract LinearTimelock {
  struct InvestorParam {
    IOndo.InvestorType investorType;
    uint96 initialBalance;
  }

  uint256 public cliffTimestamp;
  uint256 public immutable tranche1VestingPeriod;
  uint256 public immutable tranche2VestingPeriod;
  uint256 public immutable seedVestingPeriod;
  mapping(address => InvestorParam) internal investorBalances;
  bytes32 public constant TIMELOCK_UPDATE_ROLE =
    keccak256("TIMELOCK_UPDATE_ROLE");

  constructor(
    uint256 _cliffTimestamp,
    uint256 _tranche1VestingPeriod,
    uint256 _tranche2VestingPeriod,
    uint256 _seedVestingPeriod
  ) {
    cliffTimestamp = _cliffTimestamp;
    tranche1VestingPeriod = _tranche1VestingPeriod;
    tranche2VestingPeriod = _tranche2VestingPeriod;
    seedVestingPeriod = _seedVestingPeriod;
  }

  function passedCliff() public view returns (bool) {
    return block.timestamp > cliffTimestamp;
  }

  function passedAllVestingPeriods() public view returns (bool) {
    return block.timestamp > cliffTimestamp + seedVestingPeriod;
  }

  function getVestedBalance(address account)
    external
    view
    returns (uint256, uint256)
  {
    if (investorBalances[account].initialBalance == 0) {
      return (0, 0);
    }
    InvestorParam memory investorParam = investorBalances[account];
    uint96 amountAvailable;
    if (passedAllVestingPeriods()) {
      amountAvailable = investorParam.initialBalance;
    } else if (passedCliff()) {
      (uint256 vestingPeriod, uint256 elapsed) =
        _getTrancheInfo(investorParam.investorType);
      amountAvailable = _proportionAvailable(
        elapsed,
        vestingPeriod,
        investorParam
      );
    } else {
      amountAvailable = 0;
    }
    return (investorParam.initialBalance, amountAvailable);
  }

  function _getTrancheInfo(IOndo.InvestorType investorType)
    internal
    view
    returns (uint256 vestingPeriod, uint256 elapsed)
  {
    elapsed = block.timestamp - cliffTimestamp;
    if (investorType == IOndo.InvestorType.CoinlistTranche1) {
      elapsed = elapsed > tranche1VestingPeriod
        ? tranche1VestingPeriod
        : elapsed;
      vestingPeriod = tranche1VestingPeriod;
    } else if (investorType == IOndo.InvestorType.CoinlistTranche2) {
      elapsed = elapsed > tranche2VestingPeriod
        ? tranche2VestingPeriod
        : elapsed;
      vestingPeriod = tranche2VestingPeriod;
    } else if (investorType == IOndo.InvestorType.SeedTranche) {
      elapsed = elapsed > seedVestingPeriod ? seedVestingPeriod : elapsed;
      vestingPeriod = seedVestingPeriod;
    }
  }

  function _proportionAvailable(
    uint256 elapsed,
    uint256 vestingPeriod,
    InvestorParam memory investorParam
  ) internal pure returns (uint96) {
    if (investorParam.investorType == IOndo.InvestorType.SeedTranche) {
      uint96 vestedAmount =
        safe96(
          (((investorParam.initialBalance * elapsed) / vestingPeriod) * 2) / 3,
          "Ondo::_proportionAvailable: amount exceeds 96 bits"
        );
      return
        add96(
          vestedAmount,
          investorParam.initialBalance / 3,
          "Ondo::_proportionAvailable: overflow"
        );
    } else {
      return
        safe96(
          (investorParam.initialBalance * elapsed) / vestingPeriod,
          "Ondo::_proportionAvailable: amount exceeds 96 bits"
        );
    }
  }

  function safe32(uint256 n, string memory errorMessage)
    internal
    pure
    returns (uint32)
  {
    require(n < 2**32, errorMessage);
    return uint32(n);
  }

  function safe96(uint256 n, string memory errorMessage)
    internal
    pure
    returns (uint96)
  {
    require(n < 2**96, errorMessage);
    return uint96(n);
  }

  function add96(
    uint96 a,
    uint96 b,
    string memory errorMessage
  ) internal pure returns (uint96) {
    uint96 c = a + b;
    require(c >= a, errorMessage);
    return c;
  }

  function sub96(
    uint96 a,
    uint96 b,
    string memory errorMessage
  ) internal pure returns (uint96) {
    require(b <= a, errorMessage);
    return a - b;
  }
}// AGPL-3.0
pragma solidity 0.8.3;


contract Ondo is AccessControl, LinearTimelock {

  string public constant name = "OndoTest";

  string public constant symbol = "ONDOTEST";

  uint8 public constant decimals = 18;

  bool public transferAllowed; // false by default

  uint256 public totalSupply = 10_000_000_000e18; // 10 billion Ondo

  mapping(address => mapping(address => uint96)) internal allowances;

  mapping(address => uint96) internal balances;

  mapping(address => address) public delegates;

  struct Checkpoint {
    uint32 fromBlock;
    uint96 votes;
  }

  mapping(address => mapping(uint32 => Checkpoint)) public checkpoints;

  mapping(address => uint32) public numCheckpoints;

  bytes32 public constant DOMAIN_TYPEHASH =
    keccak256(
      "EIP712Domain(string name,uint256 chainId,address verifyingContract)"
    );

  bytes32 public constant DELEGATION_TYPEHASH =
    keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

  bytes32 public constant TRANSFER_ROLE = keccak256("TRANSFER_ROLE");
  bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

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

  event Transfer(address indexed from, address indexed to, uint256 amount);

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 amount
  );

  event CliffTimestampUpdate(uint256 newTimestamp);

  event TransferEnabled(address account);

  modifier whenTransferAllowed() {

    require(
      transferAllowed || hasRole(TRANSFER_ROLE, msg.sender),
      "OndoToken: Transfers not allowed or not right privillege"
    );
    _;
  }

  constructor(
    address _governance,
    uint256 _cliffTimestamp,
    uint256 _tranche1VestingPeriod,
    uint256 _tranche2VestingPeriod,
    uint256 _seedVestingPeriod
  )
    LinearTimelock(
      _cliffTimestamp,
      _tranche1VestingPeriod,
      _tranche2VestingPeriod,
      _seedVestingPeriod
    )
  {
    balances[_governance] = uint96(totalSupply);
    _setupRole(DEFAULT_ADMIN_ROLE, _governance);
    _setupRole(TRANSFER_ROLE, _governance);
    _setupRole(MINTER_ROLE, _governance);
    emit Transfer(address(0), _governance, totalSupply);
  }

  function allowance(address account, address spender)
    external
    view
    returns (uint256)
  {

    return allowances[account][spender];
  }

  function approve(address spender, uint256 rawAmount) external returns (bool) {

    uint96 amount;
    if (rawAmount == type(uint256).max) {
      amount = type(uint96).max;
    } else {
      amount = safe96(rawAmount, "Ondo::approve: amount exceeds 96 bits");
    }

    allowances[msg.sender][spender] = amount;

    emit Approval(msg.sender, spender, amount);
    return true;
  }

  function balanceOf(address account) external view returns (uint256) {

    return balances[account];
  }

  function getFreedBalance(address account) external view returns (uint256) {

    if (investorBalances[account].initialBalance > 0) {
      return _getFreedBalance(account);
    } else {
      return balances[account];
    }
  }

  function transfer(address dst, uint256 rawAmount) external returns (bool) {

    uint96 amount = safe96(rawAmount, "Ondo::transfer: amount exceeds 96 bits");
    _transferTokens(msg.sender, dst, amount);
    return true;
  }

  function transferFrom(
    address src,
    address dst,
    uint256 rawAmount
  ) external returns (bool) {

    address spender = msg.sender;
    uint96 spenderAllowance = allowances[src][spender];
    uint96 amount = safe96(rawAmount, "Ondo::approve: amount exceeds 96 bits");

    if (spender != src && spenderAllowance != type(uint96).max) {
      uint96 newAllowance =
        sub96(
          spenderAllowance,
          amount,
          "Ondo::transferFrom: transfer amount exceeds spender allowance"
        );
      allowances[src][spender] = newAllowance;

      emit Approval(src, spender, newAllowance);
    }

    _transferTokens(src, dst, amount);
    return true;
  }

  function delegate(address delegatee) public {

    return _delegate(msg.sender, delegatee);
  }

  function delegateBySig(
    address delegatee,
    uint256 nonce,
    uint256 expiry,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) public {

    bytes32 domainSeparator =
      keccak256(
        abi.encode(
          DOMAIN_TYPEHASH,
          keccak256(bytes(name)),
          getChainId(),
          address(this)
        )
      );
    bytes32 structHash =
      keccak256(abi.encode(DELEGATION_TYPEHASH, delegatee, nonce, expiry));
    bytes32 digest =
      keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    address signatory = ecrecover(digest, v, r, s);
    require(signatory != address(0), "Ondo::delegateBySig: invalid signature");
    require(nonce == nonces[signatory]++, "Ondo::delegateBySig: invalid nonce");
    require(
      block.timestamp <= expiry,
      "Ondo::delegateBySig: signature expired"
    );
    return _delegate(signatory, delegatee);
  }

  function getCurrentVotes(address account) external view returns (uint96) {

    uint32 nCheckpoints = numCheckpoints[account];
    return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
  }

  function getPriorVotes(address account, uint256 blockNumber)
    public
    view
    returns (uint96)
  {

    require(
      blockNumber < block.number,
      "Ondo::getPriorVotes: not yet determined"
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

  function mint(address account, uint256 rawAmount) external {

    require(hasRole(MINTER_ROLE, msg.sender), "Ondo::mint: not authorized");
    require(account != address(0), "cannot mint to the zero address");

    uint96 amount = safe96(rawAmount, "Ondo::mint: amount exceeds 96 bits");
    uint96 supply =
      safe96(totalSupply, "Ondo::mint: totalSupply exceeds 96 bits");
    totalSupply = add96(supply, amount, "Ondo::mint: token supply overflow");
    balances[account] = add96(
      balances[account],
      amount,
      "Ondo::mint: balance overflow"
    );

    emit Transfer(address(0), account, amount);
  }

  function _delegate(address delegator, address delegatee) internal {

    address currentDelegate = delegates[delegator];
    uint96 delegatorBalance = balances[delegator];
    delegates[delegator] = delegatee;

    emit DelegateChanged(delegator, currentDelegate, delegatee);

    _moveDelegates(currentDelegate, delegatee, delegatorBalance);
  }

  function _transferTokens(
    address src,
    address dst,
    uint96 amount
  ) internal whenTransferAllowed {

    require(
      src != address(0),
      "Ondo::_transferTokens: cannot transfer from the zero address"
    );
    require(
      dst != address(0),
      "Ondo::_transferTokens: cannot transfer to the zero address"
    );
    if (investorBalances[src].initialBalance > 0) {
      require(
        amount <= _getFreedBalance(src),
        "Ondo::_transferTokens: not enough unlocked balance"
      );
    }

    balances[src] = sub96(
      balances[src],
      amount,
      "Ondo::_transferTokens: transfer amount exceeds balance"
    );
    balances[dst] = add96(
      balances[dst],
      amount,
      "Ondo::_transferTokens: transfer amount overflows"
    );
    emit Transfer(src, dst, amount);

    _moveDelegates(delegates[src], delegates[dst], amount);
  }

  function _moveDelegates(
    address srcRep,
    address dstRep,
    uint96 amount
  ) internal {

    if (srcRep != dstRep && amount > 0) {
      if (srcRep != address(0)) {
        uint32 srcRepNum = numCheckpoints[srcRep];
        uint96 srcRepOld =
          srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
        uint96 srcRepNew =
          sub96(srcRepOld, amount, "Ondo::_moveVotes: vote amount underflows");
        _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
      }

      if (dstRep != address(0)) {
        uint32 dstRepNum = numCheckpoints[dstRep];
        uint96 dstRepOld =
          dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
        uint96 dstRepNew =
          add96(dstRepOld, amount, "Ondo::_moveVotes: vote amount overflows");
        _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
      }
    }
  }

  function _writeCheckpoint(
    address delegatee,
    uint32 nCheckpoints,
    uint96 oldVotes,
    uint96 newVotes
  ) internal {

    uint32 blockNumber =
      safe32(
        block.number,
        "Ondo::_writeCheckpoint: block number exceeds 32 bits"
      );

    if (
      nCheckpoints > 0 &&
      checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber
    ) {
      checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
    } else {
      checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
      numCheckpoints[delegatee] = nCheckpoints + 1;
    }

    emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
  }

  function getChainId() internal view returns (uint256) {

    uint256 chainId;
    assembly {
      chainId := chainid()
    }
    return chainId;
  }

  function enableTransfer() external {

    require(
      hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
      "Ondo::enableTransfer: not authorized"
    );
    transferAllowed = true;
    emit TransferEnabled(msg.sender);
  }

  function updateTrancheBalance(
    address beneficiary,
    uint256 rawAmount,
    IOndo.InvestorType investorType
  ) external {

    require(hasRole(TIMELOCK_UPDATE_ROLE, msg.sender));
    require(rawAmount > 0, "Ondo::updateTrancheBalance: amount must be > 0");
    require(
      investorBalances[beneficiary].initialBalance == 0,
      "Ondo::updateTrancheBalance: already has timelocked Ondo"
    ); //Prevents users from being in more than 1 tranche

    uint96 amount =
      safe96(rawAmount, "Ondo::updateTrancheBalance: amount exceeds 96 bits");
    investorBalances[beneficiary] = InvestorParam(investorType, amount);
  }

  function _getFreedBalance(address account) internal view returns (uint96) {

    if (passedAllVestingPeriods()) {
      return balances[account];
    } else {
      InvestorParam memory investorParam = investorBalances[account];
      if (passedCliff()) {
        (uint256 vestingPeriod, uint256 elapsed) =
          _getTrancheInfo(investorParam.investorType);
        uint96 lockedBalance =
          sub96(
            investorParam.initialBalance,
            _proportionAvailable(elapsed, vestingPeriod, investorParam),
            "Ondo::getFreedBalance: locked balance underflow"
          );
        return
          sub96(
            balances[account],
            lockedBalance,
            "Ondo::getFreedBalance: total freed balance underflow"
          );
      } else {
        return
          sub96(
            balances[account],
            investorParam.initialBalance,
            "Ondo::getFreedBalance: balance underflow"
          );
      }
    }
  }

  function updateCliffTimestamp(uint256 newTimestamp) external {

    require(
      hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
      "Ondo::updateCliffTimestamp: not authorized"
    );
    cliffTimestamp = newTimestamp;
    emit CliffTimestampUpdate(newTimestamp);
  }
}