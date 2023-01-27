pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

interface ITokenDelegator {

  function _setImplementation(address implementation_) external;


  function _setOwner(address owner_) external;


  fallback() external payable;

  receive() external payable;
}

interface ITokenDelegate {

  function initialize(address account_, uint256 initialSupply_) external;


  function changeName(string calldata name_) external;


  function changeSymbol(string calldata symbol_) external;


  function allowance(address account, address spender) external view returns (uint256);


  function approve(address spender, uint256 rawAmount) external returns (bool);


  function balanceOf(address account) external view returns (uint256);


  function transfer(address dst, uint256 rawAmount) external returns (bool);


  function transferFrom(
    address src,
    address dst,
    uint256 rawAmount
  ) external returns (bool);


  function mint(address dst, uint256 rawAmount) external;


  function permit(
    address owner,
    address spender,
    uint256 rawAmount,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;


  function delegate(address delegatee) external;


  function delegateBySig(
    address delegatee,
    uint256 nonce,
    uint256 expiry,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;


  function getCurrentVotes(address account) external view returns (uint96);


  function getPriorVotes(address account, uint256 blockNumber) external view returns (uint96);

}

interface TokenEvents {

  event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

  event DelegateVotesChanged(address indexed delegate, uint256 previousBalance, uint256 newBalance);

  event MinterChanged(address indexed oldMinter, address indexed newMinter);

  event Transfer(address indexed from, address indexed to, uint256 amount);

  event Approval(address indexed owner, address indexed spender, uint256 amount);

  event NewImplementation(address oldImplementation, address newImplementation);

  event ChangedSymbol(string oldSybmol, string newSybmol);

  event ChangedName(string oldName, string newName);
}// MIT
pragma solidity 0.8.9;

abstract contract Context {
  function _msgSender() internal view virtual returns (address) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes calldata) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}// MIT
pragma solidity 0.8.9;


contract TokenDelegatorStorage is Context {

  address public implementation;

  string public name = "Interest Protocol";

  string public symbol = "IPT";

  uint256 public totalSupply;

  uint8 public constant decimals = 18;

  address public owner;
  modifier onlyOwner() {

    require(owner == _msgSender(), "onlyOwner: sender not owner");
    _;
  }
}

contract TokenDelegateStorageV1 is TokenDelegatorStorage {

  mapping(address => mapping(address => uint96)) internal allowances;

  mapping(address => uint96) internal balances;

  mapping(address => address) public delegates;

  struct Checkpoint {
    uint32 fromBlock;
    uint96 votes;
  }
  mapping(address => mapping(uint32 => Checkpoint)) public checkpoints;

  mapping(address => uint32) public numCheckpoints;

  mapping(address => uint256) public nonces;
}// MIT
pragma solidity 0.8.9;


contract InterestProtocolTokenDelegate is TokenDelegateStorageV1, TokenEvents, ITokenDelegate {

  bytes32 public constant DOMAIN_TYPEHASH =
    keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

  bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

  bytes32 public constant PERMIT_TYPEHASH =
    keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

  uint96 public constant UINT96_MAX = 2**96 - 1;

  uint256 public constant UINT256_MAX = 2**256 - 1;

  function initialize(address account_, uint256 initialSupply_) public override {

    require(totalSupply == 0, "initialize: can only do once");
    require(account_ != address(0), "initialize: invalid address");
    require(initialSupply_ > 0, "invalid initial supply");

    totalSupply = initialSupply_;

    balances[account_] = uint96(totalSupply);
    emit Transfer(address(0), account_, totalSupply);
  }

  function changeName(string calldata name_) external override onlyOwner {

    require(bytes(name_).length > 0, "changeName: length invaild");

    emit ChangedName(name, name_);

    name = name_;
  }

  function changeSymbol(string calldata symbol_) external override onlyOwner {

    require(bytes(symbol_).length > 0, "changeSymbol: length invaild");

    emit ChangedSymbol(symbol, symbol_);

    symbol = symbol_;
  }

  function allowance(address account, address spender) external view override returns (uint256) {

    return allowances[account][spender];
  }

  function approve(address spender, uint256 rawAmount) external override returns (bool) {

    uint96 amount;
    if (rawAmount == UINT256_MAX) {
      amount = UINT96_MAX;
    } else {
      amount = safe96(rawAmount, "approve: amount exceeds 96 bits");
    }

    allowances[msg.sender][spender] = amount;

    emit Approval(msg.sender, spender, amount);
    return true;
  }

  function permit(
    address owner,
    address spender,
    uint256 rawAmount,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external override {

    uint96 amount;
    if (rawAmount == UINT256_MAX) {
      amount = UINT96_MAX;
    } else {
      amount = safe96(rawAmount, "permit: amount exceeds 96 bits");
    }

    bytes32 domainSeparator = keccak256(
      abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name)), getChainid(), address(this))
    );
    bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, rawAmount, nonces[owner]++, deadline));
    bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    address signatory = ecrecover(digest, v, r, s);
    require(signatory != address(0), "permit: invalid signature");
    require(signatory == owner, "permit: unauthorized");
    require(block.timestamp <= deadline, "permit: signature expired");

    allowances[owner][spender] = amount;

    emit Approval(owner, spender, amount);
  }

  function balanceOf(address account) external view override returns (uint256) {

    return balances[account];
  }

  function transfer(address dst, uint256 rawAmount) external override returns (bool) {

    uint96 amount = safe96(rawAmount, "transfer: amount exceeds 96 bits");
    _transferTokens(msg.sender, dst, amount);
    return true;
  }

  function transferFrom(
    address src,
    address dst,
    uint256 rawAmount
  ) external override returns (bool) {

    address spender = msg.sender;
    uint96 spenderAllowance = allowances[src][spender];
    uint96 amount = safe96(rawAmount, "approve: amount exceeds 96 bits");

    if (spender != src && spenderAllowance != UINT96_MAX) {
      uint96 newAllowance = sub96(spenderAllowance, amount, "transferFrom: transfer amount exceeds spender allowance");
      allowances[src][spender] = newAllowance;

      emit Approval(src, spender, newAllowance);
    }

    _transferTokens(src, dst, amount);
    return true;
  }

  function mint(address dst, uint256 rawAmount) external override onlyOwner {

    require(dst != address(0), "mint: cant transfer to 0 address");
    uint96 amount = safe96(rawAmount, "mint: amount exceeds 96 bits");
    totalSupply = safe96(totalSupply + amount, "mint: totalSupply exceeds 96 bits");

    balances[dst] = add96(balances[dst], amount, "mint: transfer amount overflows");
    emit Transfer(address(0), dst, amount);

    _moveDelegates(address(0), delegates[dst], amount);
  }

  function delegate(address delegatee) public override {

    return _delegate(msg.sender, delegatee);
  }

  function delegateBySig(
    address delegatee,
    uint256 nonce,
    uint256 expiry,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) public override {

    bytes32 domainSeparator = keccak256(
      abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name)), getChainid(), address(this))
    );
    bytes32 structHash = keccak256(abi.encode(DELEGATION_TYPEHASH, delegatee, nonce, expiry));
    bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    address signatory = ecrecover(digest, v, r, s);
    require(signatory != address(0), "delegateBySig: invalid signature");
    require(nonce == nonces[signatory]++, "delegateBySig: invalid nonce");
    require(block.timestamp <= expiry, "delegateBySig: signature expired");
    return _delegate(signatory, delegatee);
  }

  function getCurrentVotes(address account) external view override returns (uint96) {

    uint32 nCheckpoints = numCheckpoints[account];
    return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
  }

  function getPriorVotes(address account, uint256 blockNumber) public view override returns (uint96) {

    require(blockNumber < block.number, "getPriorVotes: not determined");
    bool ok = false;
    uint96 votes = 0;
    (ok, votes) = _naivePriorVotes(account, blockNumber);
    if (ok == true) {
      return votes;
    }
    uint32 lower = 0;
    uint32 upper = numCheckpoints[account] - 1;
    while (upper > lower) {
      uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
      Checkpoint memory cp = checkpoints[account][center];
      (ok, lower, upper) = _binarySearch(cp.fromBlock, blockNumber, lower, upper);
      if (ok == true) {
        return cp.votes;
      }
    }
    return checkpoints[account][lower].votes;
  }

  function _naivePriorVotes(address account, uint256 blockNumber) internal view returns (bool ok, uint96 ans) {

    uint32 nCheckpoints = numCheckpoints[account];
    if (nCheckpoints == 0) {
      return (true, 0);
    }
    if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
      return (true, checkpoints[account][nCheckpoints - 1].votes);
    }
    if (checkpoints[account][0].fromBlock > blockNumber) {
      return (true, 0);
    }
    return (false, 0);
  }

  function _binarySearch(
    uint32 from,
    uint256 blk,
    uint32 lower,
    uint32 upper
  )
    internal
    pure
    returns (
      bool ok,
      uint32 newLower,
      uint32 newUpper
    )
  {

    uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
    if (from == blk) {
      return (true, 0, 0);
    }
    if (from < blk) {
      return (false, center, upper);
    }
    return (false, lower, center - 1);
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
  ) internal {

    require(src != address(0), "_transferTokens: cant 0addr");
    require(dst != address(0), "_transferTokens: cant 0addr");

    balances[src] = sub96(balances[src], amount, "_transferTokens: transfer amount exceeds balance");
    balances[dst] = add96(balances[dst], amount, "_transferTokens: transfer amount overflows");
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
        uint96 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
        uint96 srcRepNew = sub96(srcRepOld, amount, "_moveVotes: vote amt underflows");
        _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
      }

      if (dstRep != address(0)) {
        uint32 dstRepNum = numCheckpoints[dstRep];
        uint96 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
        uint96 dstRepNew = add96(dstRepOld, amount, "_moveVotes: vote amt overflows");
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

    uint32 blockNumber = safe32(block.number, "_writeCheckpoint: blocknum exceeds 32 bits");

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

  function safe96(uint256 n, string memory errorMessage) internal pure returns (uint96) {

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

  function getChainid() internal view returns (uint256) {

    uint256 chainId;
    assembly {
      chainId := chainid()
    }
    return chainId;
  }
}