pragma solidity 0.8.1;

interface ILinkedToSYN {

  function synr() external view returns (address);

}// MIT
pragma solidity 0.8.1;


interface IPool is ILinkedToSYN {

  struct Deposit {
    uint256 tokenAmount;
    uint256 weight;
    uint64 lockedFrom;
    uint64 lockedUntil;
    bool isYield;
  }

  struct User {
    uint256 tokenAmount;
    uint256 totalWeight;
    uint256 subYieldRewards;
    uint256 subVaultRewards;
    Deposit[] deposits;
  }


  function ssynr() external view returns (address);


  function poolToken() external view returns (address);


  function isFlashPool() external view returns (bool);


  function weight() external view returns (uint32);


  function lastYieldDistribution() external view returns (uint64);


  function yieldRewardsPerWeight() external view returns (uint256);


  function usersLockingWeight() external view returns (uint256);


  function pendingYieldRewards(address _user) external view returns (uint256);


  function balanceOf(address _user) external view returns (uint256);


  function getDeposit(address _user, uint256 _depositId) external view returns (Deposit memory);


  function getDepositsLength(address _user) external view returns (uint256);


  function stake(
    uint256 _amount,
    uint64 _lockedUntil,
    bool useSSYN
  ) external;


  function unstake(
    uint256 _depositId,
    uint256 _amount,
    bool useSSYN
  ) external;


  function sync() external;


  function processRewards(bool useSSYN) external;


  function setWeight(uint32 _weight) external;

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

  constructor(address _superAdmin) {
    userRoles[_superAdmin] = FULL_PRIVILEGES_MASK;
    userRoles[msg.sender] = FULL_PRIVILEGES_MASK;
  }

  function features() public view returns (uint256) {

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

  function evaluateBy(
    address operator,
    uint256 target,
    uint256 desired
  ) public view returns (uint256) {

    uint256 p = userRoles[operator];

    target |= p & desired;
    target &= FULL_PRIVILEGES_MASK ^ (p & (FULL_PRIVILEGES_MASK ^ desired));

    return target;
  }

  function isFeatureEnabled(uint256 required) public view returns (bool) {

    return __hasRole(features(), required);
  }

  function isSenderInRole(uint256 required) public view returns (bool) {

    return isOperatorInRole(msg.sender, required);
  }

  function isOperatorInRole(address operator, uint256 required) public view returns (bool) {

    return __hasRole(userRoles[operator], required);
  }

  function __hasRole(uint256 actual, uint256 required) internal pure returns (bool) {

    return actual & required == required;
  }
}// MIT
pragma solidity 0.8.1;

interface ERC20Receiver {

  function onERC20Received(
    address _operator,
    address _from,
    uint256 _value,
    bytes calldata _data
  ) external returns (bytes4);

}// MIT
pragma solidity 0.8.1;


contract SyndicateERC20 is AccessControl {

  uint256 public constant TOKEN_UID = 0x83ecb176af7c4f35a45ff0018282e3a05a1018065da866182df12285866f5a2c;

  string public constant name = "Syndicate Token";

  string public symbol = "SYNR";

  event SymbolUpdated(string _symbol);

  uint8 public constant decimals = 18;

  uint256 public maxTotalSupply; // is set up in the constructor

  uint256 public totalSupply; // is set to 700 million * 10^18 in the constructor

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

  uint32 public constant ROLE_WHITE_LISTED_SPENDER = 0x0010_0000;

  uint32 public constant ROLE_TREASURY = 0x0020_0000;

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

  constructor(
    address _initialHolder,
    uint256 _maxTotalSupply,
    address _superAdmin
  ) AccessControl(_superAdmin) {
    require(_initialHolder != address(0), "_initialHolder not set (zero address)");
    require(_maxTotalSupply >= 10e9, "_maxTotalSupply less than minimum accepted amount");

    maxTotalSupply = _maxTotalSupply * 10**18;
    mint(_initialHolder, (maxTotalSupply * 9) / 10);
  }


  function balanceOf(address _owner) public view returns (uint256 balance) {

    return tokenBalances[_owner];
  }

  function transfer(address _to, uint256 _value) public returns (bool success) {

    return transferFrom(msg.sender, _to, _value);
  }

  function updateSymbol(string memory _symbol) external {

    require(isSenderInRole(ROLE_ACCESS_MANAGER), "insufficient privileges (ROLE_ACCESS_MANAGER required)");
    symbol = _symbol;
    emit SymbolUpdated(_symbol);
  }

  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  ) public returns (bool success) {

    if (
      isFeatureEnabled(FEATURE_UNSAFE_TRANSFERS) ||
      isOperatorInRole(_to, ROLE_ERC20_RECEIVER) ||
      isSenderInRole(ROLE_ERC20_SENDER)
    ) {
      unsafeTransferFrom(_from, _to, _value);
    }
    else {
      safeTransferFrom(_from, _to, _value, "");
    }

    return true;
  }

  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _value,
    bytes memory _data
  ) public {

    unsafeTransferFrom(_from, _to, _value);

    if (AddressUtils.isContract(_to)) {
      bytes4 response = ERC20Receiver(_to).onERC20Received(msg.sender, _from, _value, _data);

      require(response == ERC20_RECEIVED, "invalid onERC20Received response");
    }
  }

  function unsafeTransferFrom(
    address _from,
    address _to,
    uint256 _value
  ) public {

    require(
      (_from == msg.sender && isFeatureEnabled(FEATURE_TRANSFERS)) ||
        (_from != msg.sender && (isFeatureEnabled(FEATURE_TRANSFERS_ON_BEHALF) || isSenderInRole(ROLE_WHITE_LISTED_SPENDER))),
      _from == msg.sender ? "transfers are disabled" : "transfers on behalf are disabled"
    );
    require(_from != address(0), "SYNR: transfer from the zero address"); // Zeppelin msg

    require(_to != address(0), "SYNR: transfer to the zero address"); // Zeppelin msg

    require(_from != _to, "sender and recipient are the same (_from = _to)");

    require(_to != address(this), "invalid recipient (transfer to the token smart contract itself)");

    if (_value == 0) {
      emit Transfer(_from, _to, _value);

      return;
    }


    if (_from != msg.sender) {
      uint256 _allowance = transferAllowances[_from][msg.sender];

      require(_allowance >= _value, "SYNR: transfer amount exceeds allowance"); // Zeppelin msg

      _allowance -= _value;

      transferAllowances[_from][msg.sender] = _allowance;

      emit Approved(_from, msg.sender, _allowance + _value, _allowance);

      emit Approval(_from, msg.sender, _allowance);
    }

    require(tokenBalances[_from] >= _value, "SYNR: transfer amount exceeds balance"); // Zeppelin msg

    tokenBalances[_from] -= _value;

    tokenBalances[_to] += _value;

    __moveVotingPower(votingDelegates[_from], votingDelegates[_to], _value);

    emit Transferred(msg.sender, _from, _to, _value);

    emit Transfer(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public returns (bool success) {

    require(_spender != address(0), "SYNR: approve to the zero address"); // Zeppelin msg

    require(
      isFeatureEnabled(FEATURE_TRANSFERS_ON_BEHALF) || isOperatorInRole(_spender, ROLE_WHITE_LISTED_SPENDER),
      "SYNR: spender not allowed"
    );

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

    require(currentVal >= _value, "SYNR: decreased allowance below zero");

    return approve(_spender, currentVal - _value);
  }



  function mint(address _to, uint256 _value) public {

    require(isSenderInRole(ROLE_TOKEN_CREATOR), "insufficient privileges (ROLE_TOKEN_CREATOR required)");

    require(_to != address(0), "SYNR: mint to the zero address"); // Zeppelin msg

    require(totalSupply + _value > totalSupply, "zero value mint or arithmetic overflow");

    require(totalSupply + _value <= type(uint192).max, "total supply overflow (uint192)");

    require(totalSupply + _value <= maxTotalSupply, "reached total max supply");

    totalSupply += _value;

    tokenBalances[_to] += _value;

    __moveVotingPower(address(0), votingDelegates[_to], _value);

    emit Minted(msg.sender, _to, _value);

    emit Transferred(msg.sender, address(0), _to, _value);

    emit Transfer(address(0), _to, _value);
  }

  function burn(address _from, uint256 _value) public {

    if (!isSenderInRole(ROLE_TOKEN_DESTROYER)) {
      require(
        (_from == msg.sender && isFeatureEnabled(FEATURE_OWN_BURNS)) ||
          (_from != msg.sender && isFeatureEnabled(FEATURE_BURNS_ON_BEHALF)),
        _from == msg.sender ? "burns are disabled" : "burns on behalf are disabled"
      );

      if (_from != msg.sender) {
        uint256 _allowance = transferAllowances[_from][msg.sender];

        require(_allowance >= _value, "SYNR: burn amount exceeds allowance"); // Zeppelin msg

        _allowance -= _value;

        transferAllowances[_from][msg.sender] = _allowance;

        emit Approved(msg.sender, _from, _allowance + _value, _allowance);

        emit Approval(_from, msg.sender, _allowance);
      }
    }


    require(_value != 0, "zero value burn");

    require(_from != address(0), "SYNR: burn from the zero address"); // Zeppelin msg

    require(tokenBalances[_from] >= _value, "SYNR: burn amount exceeds balance"); // Zeppelin msg

    tokenBalances[_from] -= _value;

    totalSupply -= _value;

    __moveVotingPower(votingDelegates[_from], address(0), _value);

    emit Burnt(msg.sender, _from, _value);

    emit Transferred(msg.sender, _from, address(0), _value);

    emit Transfer(_from, address(0), _value);
  }



  function getVotingPower(address _of) public view returns (uint256) {

    VotingPowerRecord[] storage history = votingPowerHistory[_of];

    return history.length == 0 ? 0 : history[history.length - 1].votingPower;
  }

  function getVotingPowerAt(address _of, uint256 _blockNum) public view returns (uint256) {

    require(_blockNum < block.number, "not yet determined"); // Compound msg

    VotingPowerRecord[] storage history = votingPowerHistory[_of];

    if (history.length == 0) {
      return 0;
    }

    if (history[history.length - 1].blockNumber <= _blockNum) {
      return getVotingPower(_of);
    }

    if (history[0].blockNumber > _blockNum) {
      return 0;
    }

    return history[__binaryLookup(_of, _blockNum)].votingPower;
  }

  function getVotingPowerHistory(address _of) public view returns (VotingPowerRecord[] memory) {

    return votingPowerHistory[_of];
  }

  function getVotingPowerHistoryLength(address _of) public view returns (uint256) {

    return votingPowerHistory[_of].length;
  }

  function delegate(address _to) public {

    require(isFeatureEnabled(FEATURE_DELEGATIONS), "delegations are disabled");
    __delegate(msg.sender, _to);
  }

  function delegateWithSig(
    address _to,
    uint256 _nonce,
    uint256 _exp,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) public {

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

  function __moveVotingPower(
    address _from,
    address _to,
    uint256 _value
  ) private {

    if (_from == _to || _value == 0) {
      return;
    }

    if (_from != address(0)) {
      uint256 _fromVal = getVotingPower(_from);

      uint256 _toVal = _fromVal - _value;

      __updateVotingPower(_from, _fromVal, _toVal);
    }

    if (_to != address(0)) {
      uint256 _fromVal = getVotingPower(_to);

      uint256 _toVal = _fromVal + _value;

      __updateVotingPower(_to, _fromVal, _toVal);
    }
  }

  function __updateVotingPower(
    address _of,
    uint256 _fromVal,
    uint256 _toVal
  ) private {

    VotingPowerRecord[] storage history = votingPowerHistory[_of];

    if (history.length != 0 && history[history.length - 1].blockNumber == block.number) {
      history[history.length - 1].votingPower = uint192(_toVal);
    }
    else {
      history.push(VotingPowerRecord(uint64(block.number), uint192(_toVal)));
    }

    emit VotingPowerChanged(_of, _fromVal, _toVal);
  }

  function __binaryLookup(address _to, uint256 n) private view returns (uint256) {

    VotingPowerRecord[] storage history = votingPowerHistory[_to];

    uint256 i = 0;

    uint256 j = history.length - 1;

    while (j > i) {
      uint256 k = j - (j - i) / 2;

      VotingPowerRecord memory cp = history[k];

      if (cp.blockNumber == n) {
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


abstract contract SyndicateAware is ILinkedToSYN {
  address public immutable override synr;

  constructor(address _synr) {
    require(_synr != address(0), "SYNR address not set");
    require(
      SyndicateERC20(_synr).TOKEN_UID() == 0x83ecb176af7c4f35a45ff0018282e3a05a1018065da866182df12285866f5a2c,
      "unexpected TOKEN_UID"
    );

    synr = _synr;
  }

  function _transferSyn(address _to, uint256 _value) internal {
    _transferSynFrom(address(this), _to, _value);
  }

  function _transferSynFrom(
    address _from,
    address _to,
    uint256 _value
  ) internal {
    SyndicateERC20(synr).transferFrom(_from, _to, _value);
  }

  function _mintSyn(address _to, uint256 _value) internal {
    SyndicateERC20(synr).mint(_to, _value);
  }
}// MIT

pragma solidity 0.8.1;


interface ICorePool is IPool {

  function vaultRewardsPerToken() external view returns (uint256);


  function poolTokenReserve() external view returns (uint256);


  function stakeAsPool(address _staker, uint256 _amount) external;


  function receiveVaultRewards(uint256 _amount) external;

}// https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/master/contracts/security/ReentrancyGuard.sol


pragma solidity 0.8.1;

abstract contract ReentrancyGuard {

  uint256 private constant _NOT_ENTERED = 1;
  uint256 private constant _ENTERED = 2;

  uint256 private _status;

  constructor() {
    _status = _NOT_ENTERED;
  }

  modifier nonReentrant() {
    require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

    _status = _ENTERED;

    _;

    _status = _NOT_ENTERED;
  }
}// MIT
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

library Address {

  function isContract(address account) internal view returns (bool) {


    uint256 size;
    assembly {
      size := extcodesize(account)
    }
    return size > 0;
  }

  function sendValue(address payable recipient, uint256 amount) internal {

    require(address(this).balance >= amount, "Address: insufficient balance");

    (bool success, ) = recipient.call{value: amount}("");
    require(success, "Address: unable to send value, recipient may have reverted");
  }

  function functionCall(address target, bytes memory data) internal returns (bytes memory) {

    return functionCall(target, data, "Address: low-level call failed");
  }

  function functionCall(
    address target,
    bytes memory data,
    string memory errorMessage
  ) internal returns (bytes memory) {

    return functionCallWithValue(target, data, 0, errorMessage);
  }

  function functionCallWithValue(
    address target,
    bytes memory data,
    uint256 value
  ) internal returns (bytes memory) {

    return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
  }

  function functionCallWithValue(
    address target,
    bytes memory data,
    uint256 value,
    string memory errorMessage
  ) internal returns (bytes memory) {

    require(address(this).balance >= value, "Address: insufficient balance for call");
    require(isContract(target), "Address: call to non-contract");

    (bool success, bytes memory returndata) = target.call{value: value}(data);
    return _verifyCallResult(success, returndata, errorMessage);
  }

  function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

    return functionStaticCall(target, data, "Address: low-level static call failed");
  }

  function functionStaticCall(
    address target,
    bytes memory data,
    string memory errorMessage
  ) internal view returns (bytes memory) {

    require(isContract(target), "Address: static call to non-contract");

    (bool success, bytes memory returndata) = target.staticcall(data);
    return _verifyCallResult(success, returndata, errorMessage);
  }

  function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

    return functionDelegateCall(target, data, "Address: low-level delegate call failed");
  }

  function functionDelegateCall(
    address target,
    bytes memory data,
    string memory errorMessage
  ) internal returns (bytes memory) {

    require(isContract(target), "Address: delegate call to non-contract");

    (bool success, bytes memory returndata) = target.delegatecall(data);
    return _verifyCallResult(success, returndata, errorMessage);
  }

  function _verifyCallResult(
    bool success,
    bytes memory returndata,
    string memory errorMessage
  ) private pure returns (bytes memory) {

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
pragma solidity 0.8.1;


library SafeERC20 {

  using Address for address;

  function safeTransfer(
    IERC20 token,
    address to,
    uint256 value
  ) internal {

    _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
  }

  function safeTransferFrom(
    IERC20 token,
    address from,
    address to,
    uint256 value
  ) internal {

    _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
  }

  function safeApprove(
    IERC20 token,
    address spender,
    uint256 value
  ) internal {

    require(
      (value == 0) || (token.allowance(address(this), spender) == 0),
      "SafeERC20: approve from non-zero to non-zero allowance"
    );
    _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
  }

  function safeIncreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  ) internal {

    uint256 newAllowance = token.allowance(address(this), spender) + value;
    _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
  }

  function safeDecreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  ) internal {

    uint256 newAllowance = token.allowance(address(this), spender) - value;
    _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
  }

  function _callOptionalReturn(IERC20 token, bytes memory data) private {

    bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
    if (returndata.length > 0) {
      require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
    }
  }
}// MIT
pragma solidity 0.8.1;




contract ERC20 is IERC20 {

  mapping(address => uint256) private _balances;

  mapping(address => mapping(address => uint256)) private _allowances;

  uint256 private _totalSupply;

  string private _name;
  string private _symbol;
  uint8 private _decimals;

  uint32 public constant ROLE_TOKEN_CREATOR = 0x0001_0000;

  constructor(string memory name_, string memory symbol_) {
    _name = name_;
    _symbol = symbol_;
    _decimals = 18;
  }

  function name() public view virtual returns (string memory) {

    return _name;
  }

  function symbol() public view virtual returns (string memory) {

    return _symbol;
  }

  function decimals() public view virtual returns (uint8) {

    return _decimals;
  }

  function totalSupply() public view virtual override returns (uint256) {

    return _totalSupply;
  }

  function balanceOf(address account) public view virtual override returns (uint256) {

    return _balances[account];
  }

  function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

    _transfer(msg.sender, recipient, amount);
    return true;
  }

  function allowance(address owner, address spender) public view virtual override returns (uint256) {

    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) public virtual override returns (bool) {

    _approve(msg.sender, spender, amount);
    return true;
  }

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) public virtual override returns (bool) {

    _transfer(sender, recipient, amount);
    _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

    _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

    _approve(msg.sender, spender, _allowances[msg.sender][spender] - subtractedValue);
    return true;
  }

  function _transfer(
    address sender,
    address recipient,
    uint256 amount
  ) internal virtual {

    require(sender != address(0), "ERC20: transfer from the zero address");
    require(recipient != address(0), "ERC20: transfer to the zero address");

    _beforeTokenTransfer(sender, recipient, amount);

    _balances[sender] = _balances[sender] - amount;
    _balances[recipient] = _balances[recipient] + amount;
    emit Transfer(sender, recipient, amount);
  }

  function _mint(address account, uint256 amount) internal virtual {

    require(account != address(0), "ERC20: mint to the zero address");

    _beforeTokenTransfer(address(0), account, amount);

    _totalSupply = _totalSupply + amount;
    _balances[account] = _balances[account] + amount;
    emit Transfer(address(0), account, amount);
  }

  function _burn(address account, uint256 amount) internal virtual {

    require(account != address(0), "ERC20: burn from the zero address");

    _beforeTokenTransfer(account, address(0), amount);

    _balances[account] = _balances[account] - amount;
    _totalSupply = _totalSupply - amount;
    emit Transfer(account, address(0), amount);
  }

  function _approve(
    address owner,
    address spender,
    uint256 amount
  ) internal virtual {

    require(owner != address(0), "ERC20: approve from the zero address");
    require(spender != address(0), "ERC20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function _setupDecimals(uint8 decimals_) internal virtual {

    _decimals = decimals_;
  }

  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 amount
  ) internal virtual {}

}// MIT
pragma solidity 0.8.1;


contract SyntheticSyndicateERC20 is ERC20("Synthetic Syndicate Token", "sSYNR"), AccessControl {
  uint256 public constant TOKEN_UID = 0xac3051b8d4f50966afb632468a4f61483ae6a953b74e387a01ef94316d6b7d62;

  uint32 public constant ROLE_TOKEN_DESTROYER = 0x0002_0000;

  uint32 public constant ROLE_WHITE_LISTED_RECEIVER = 0x0004_0000;

  constructor(address _superAdmin) AccessControl(_superAdmin) {}

  function mint(address recipient, uint256 amount) external {
    require(isSenderInRole(ROLE_TOKEN_CREATOR), "sSYNR: insufficient privileges (ROLE_TOKEN_CREATOR required)");
    _mint(recipient, amount);
  }

  function burn(uint256 amount) external {
    _burn(msg.sender, amount);
  }

  function burn(address recipient, uint256 amount) external {
    require(isSenderInRole(ROLE_TOKEN_DESTROYER), "sSYNR: insufficient privileges (ROLE_TOKEN_DESTROYER required)");
    require(isOperatorInRole(recipient, ROLE_WHITE_LISTED_RECEIVER), "sSYNR: Non Allowed Receiver");
    _burn(recipient, amount);
  }

  function _transfer(
    address sender,
    address recipient,
    uint256 amount
  ) internal virtual override {
    require(isOperatorInRole(recipient, ROLE_WHITE_LISTED_RECEIVER), "sSYNR: Non Allowed Receiver");
    super._transfer(sender, recipient, amount);
  }
}// MIT
pragma solidity ^0.8.1;

interface IMigrator {
  function receiveDeposits(address _staker, IPool.User memory _user) external;
}// MIT
pragma solidity 0.8.1;


abstract contract SyndicatePoolBase is IPool, SyndicateAware, ReentrancyGuard {
  uint256 public minLockTime = 16 weeks;

  IMigrator public migrator;

  mapping(address => User) public users;

  address public immutable override ssynr;

  SyndicatePoolFactory public immutable factory;

  address public immutable override poolToken;

  uint32 public override weight;

  uint64 public override lastYieldDistribution;

  uint256 public override yieldRewardsPerWeight;

  uint256 public override usersLockingWeight;

  uint256 public totalYieldReward;

  uint256 internal constant WEIGHT_MULTIPLIER = 1e6;

  uint256 internal constant YEAR_STAKE_WEIGHT_MULTIPLIER = 2 * WEIGHT_MULTIPLIER;

  uint256 internal constant REWARD_PER_WEIGHT_MULTIPLIER = 1e20;

  event Staked(address indexed _by, address indexed _from, uint256 amount);

  event StakeLockUpdated(address indexed _by, uint256 depositId, uint64 lockedFrom, uint64 lockedUntil);

  event Unstaked(address indexed _by, address indexed _to, uint256 amount);

  event Synchronized(address indexed _by, uint256 yieldRewardsPerWeight, uint64 lastYieldDistribution);

  event YieldClaimed(address indexed _by, address indexed _to, bool sSyn, uint256 amount);

  event PoolWeightUpdated(address indexed _by, uint32 _fromVal, uint32 _toVal);

  modifier onlyFactoryOwner() {
    require(factory.owner() == msg.sender, "access denied");
    _;
  }

  modifier poolAlive() {
    require(weight > 0, "pool disabled");
    _;
  }

  constructor(
    address _synr,
    address _ssynr,
    SyndicatePoolFactory _factory,
    address _poolToken,
    uint64 _initBlock,
    uint32 _weight
  ) SyndicateAware(_synr) {
    require(_ssynr != address(0), "sSYNR address not set");
    require(address(_factory) != address(0), "SYNR Pool fct address not set");
    require(_poolToken != address(0), "pool token address not set");
    require(_initBlock > 0, "init block not set");
    require(_weight > 0, "pool weight not set");

    require(
      SyntheticSyndicateERC20(_ssynr).TOKEN_UID() == 0xac3051b8d4f50966afb632468a4f61483ae6a953b74e387a01ef94316d6b7d62,
      "unexpected sSYNR TOKEN_UID"
    );
    require(
      _factory.FACTORY_UID() == 0xc5cfd88c6e4d7e5c8a03c0f0f03af23c0918d8e82cac196f57466af3fd4a5ec7,
      "unexpected FACTORY_UID"
    );

    ssynr = _ssynr;
    factory = _factory;
    poolToken = _poolToken;
    weight = _weight;

    lastYieldDistribution = _initBlock;
  }

  function setMigrator(IMigrator _migrator) external onlyFactoryOwner {
    require(address(_migrator) != address(0), "migrator cannot be 0x0");
    migrator = _migrator;
  }

  function migrate() external {
    require(weight == 0, "disable pool first");
    require(address(migrator) != address(0), "migrator not set");
    User storage user = users[msg.sender];
    require(user.tokenAmount != 0, "no tokens to migrate");
    migrator.receiveDeposits(msg.sender, user);
    uint256 tokenToMigrate;
    for (uint256 i = user.deposits.length; i > 0; i--) {
      if (!user.deposits[i - 1].isYield) {
        tokenToMigrate += user.deposits[i - 1].tokenAmount;
      }
      user.deposits.pop();
    }
    SyndicateERC20(synr).transfer(address(migrator), tokenToMigrate);
    delete users[msg.sender];
  }

  function pendingYieldRewards(address _staker) external view override returns (uint256) {
    uint256 newYieldRewardsPerWeight;

    if (blockNumber() > lastYieldDistribution && usersLockingWeight != 0) {
      uint256 endBlock = factory.endBlock();
      uint256 multiplier = blockNumber() > endBlock ? endBlock - lastYieldDistribution : blockNumber() - lastYieldDistribution;
      uint256 synRewards = (multiplier * weight * factory.synrPerBlock()) / factory.totalWeight();

      newYieldRewardsPerWeight = rewardToWeight(synRewards, usersLockingWeight) + yieldRewardsPerWeight;
    } else {
      newYieldRewardsPerWeight = yieldRewardsPerWeight;
    }

    User storage user = users[_staker];
    uint256 pending = weightToReward(user.totalWeight, newYieldRewardsPerWeight) - user.subYieldRewards;
    return pending;
  }

  function balanceOf(address _user) external view override returns (uint256) {
    return users[_user].tokenAmount;
  }

  function getDeposit(address _user, uint256 _depositId) external view override returns (Deposit memory) {
    return users[_user].deposits[_depositId];
  }

  function getDepositsLength(address _user) external view override returns (uint256) {
    return users[_user].deposits.length;
  }

  function stake(
    uint256 _amount,
    uint64 _lockUntil,
    bool _useSSYN
  ) external override poolAlive {
    _stake(msg.sender, _amount, _lockUntil, _useSSYN, false);
  }

  function unstake(
    uint256 _depositId,
    uint256 _amount,
    bool _useSSYN
  ) external override poolAlive {
    _unstake(msg.sender, _depositId, _amount, _useSSYN);
  }

  function updateStakeLock(
    uint256 depositId,
    uint64 lockedUntil,
    bool useSSYN
  ) external poolAlive {
    _updateStakeLock(msg.sender, depositId, lockedUntil, useSSYN);
  }

  function sync() external override poolAlive {
    _sync();
  }

  function processRewards(bool _useSSYN) external virtual override poolAlive {
    _processRewards(msg.sender, _useSSYN, true);
  }

  function setWeight(uint32 _weight) external override {
    require(msg.sender == address(factory), "access denied");

    emit PoolWeightUpdated(msg.sender, weight, _weight);

    weight = _weight;
  }

  function _pendingYieldRewards(address _staker) internal view returns (uint256 pending) {
    User storage user = users[_staker];

    return weightToReward(user.totalWeight, yieldRewardsPerWeight) - user.subYieldRewards;
  }

  function setMinLockTime(uint256 _minLockTime) external {
    require(_minLockTime < 365 days, "invalid minLockTime");
    minLockTime = _minLockTime;
  }

  function _stake(
    address _staker,
    uint256 _amount,
    uint64 _lockUntil,
    bool _useSSYN,
    bool _isYield
  ) internal virtual {
    require(_amount > 0, "SyndicatePoolBase: zero amount");
    require(
      _lockUntil >= now256() + minLockTime && _lockUntil - now256() <= 365 days,
      "SyndicatePoolBase: invalid lock interval"
    );
    _sync();

    User storage user = users[_staker];
    if (user.tokenAmount > 0) {
      _processRewards(_staker, _useSSYN, false);
    }

    uint256 previousBalance = IERC20(poolToken).balanceOf(address(this));
    transferPoolTokenFrom(address(msg.sender), address(this), _amount);
    uint256 newBalance = IERC20(poolToken).balanceOf(address(this));
    uint256 addedAmount = newBalance - previousBalance;

    uint64 lockFrom = _lockUntil > 0 ? uint64(now256()) : 0;
    uint64 lockUntil = _lockUntil;

    uint256 stakeWeight = getStakeWeight(lockUntil - lockFrom, addedAmount);

    assert(stakeWeight > 0);

    Deposit memory deposit = Deposit({
      tokenAmount: addedAmount,
      weight: stakeWeight,
      lockedFrom: lockFrom,
      lockedUntil: lockUntil,
      isYield: _isYield
    });
    user.deposits.push(deposit);

    user.tokenAmount += addedAmount;
    user.totalWeight += stakeWeight;
    user.subYieldRewards = weightToReward(user.totalWeight, yieldRewardsPerWeight);

    usersLockingWeight += stakeWeight;

    emit Staked(msg.sender, _staker, _amount);
  }

  function getStakeWeight(uint256 lockedTime, uint256 addedAmount) public pure returns (uint256) {
    return ((lockedTime * WEIGHT_MULTIPLIER) / 365 days + WEIGHT_MULTIPLIER) * addedAmount;
  }

  function _unstake(
    address _staker,
    uint256 _depositId,
    uint256 _amount,
    bool _useSSYN
  ) internal virtual {
    require(_amount > 0, "zero amount");

    User storage user = users[_staker];
    Deposit storage stakeDeposit = user.deposits[_depositId];
    bool isYield = stakeDeposit.isYield;

    require(stakeDeposit.tokenAmount >= _amount, "amount exceeds stake");

    _sync();
    _processRewards(_staker, _useSSYN, false);

    uint256 previousWeight = stakeDeposit.weight;
    uint256 newWeight = (((stakeDeposit.lockedUntil - stakeDeposit.lockedFrom) * WEIGHT_MULTIPLIER) /
      365 days +
      WEIGHT_MULTIPLIER) * (stakeDeposit.tokenAmount - _amount);

    if (stakeDeposit.tokenAmount - _amount == 0) {
      delete user.deposits[_depositId];
    } else {
      stakeDeposit.tokenAmount -= _amount;
      stakeDeposit.weight = newWeight;
    }

    user.tokenAmount -= _amount;
    user.totalWeight = user.totalWeight - previousWeight + newWeight;
    user.subYieldRewards = weightToReward(user.totalWeight, yieldRewardsPerWeight);

    usersLockingWeight = usersLockingWeight - previousWeight + newWeight;

    if (isYield) {
      factory.mintYieldTo(msg.sender, _amount);
    } else {
      transferPoolToken(msg.sender, _amount);
    }

    emit Unstaked(msg.sender, _staker, _amount);
  }

  function _sync() internal virtual {
    if (factory.shouldUpdateRatio()) {
      factory.updateSYNPerBlock();
    }
    uint256 endBlock = factory.endBlock();
    if (lastYieldDistribution >= endBlock) {
      return;
    }
    if (blockNumber() <= lastYieldDistribution) {
      return;
    }
    if (usersLockingWeight == 0) {
      lastYieldDistribution = uint64(blockNumber());
      return;
    }
    uint256 currentBlock = blockNumber() > endBlock ? endBlock : blockNumber();
    uint256 blocksPassed = currentBlock - lastYieldDistribution;
    uint256 synrPerBlock = factory.synrPerBlock();

    uint256 synReward = (blocksPassed * synrPerBlock * weight) / factory.totalWeight();

    totalYieldReward += synReward;

    yieldRewardsPerWeight += rewardToWeight(synReward, usersLockingWeight);
    lastYieldDistribution = uint64(currentBlock);

    emit Synchronized(msg.sender, yieldRewardsPerWeight, lastYieldDistribution);
  }

  function _processRewards(
    address _staker,
    bool _useSSYN,
    bool _withUpdate
  ) internal virtual returns (uint256 pendingYield) {
    if (_withUpdate) {
      _sync();
    }

    pendingYield = _pendingYieldRewards(_staker);

    if (pendingYield == 0) return 0;

    User storage user = users[_staker];

    if (_useSSYN) {
      mintSSyn(_staker, pendingYield);
    } else if (poolToken == synr) {
      uint256 depositWeight = pendingYield * YEAR_STAKE_WEIGHT_MULTIPLIER;

      Deposit memory newDeposit = Deposit({
        tokenAmount: pendingYield,
        lockedFrom: uint64(now256()),
        lockedUntil: uint64(now256() + 365 days), // staking yield for 1 year
        weight: depositWeight,
        isYield: true
      });
      user.deposits.push(newDeposit);

      user.tokenAmount += pendingYield;
      user.totalWeight += depositWeight;

      usersLockingWeight += depositWeight;
    } else {
      address synPool = factory.getPoolAddress(synr);
      ICorePool(synPool).stakeAsPool(_staker, pendingYield);
    }

    if (_withUpdate) {
      user.subYieldRewards = weightToReward(user.totalWeight, yieldRewardsPerWeight);
    }

    emit YieldClaimed(msg.sender, _staker, _useSSYN, pendingYield);
  }

  function _updateStakeLock(
    address _staker,
    uint256 _depositId,
    uint64 _lockedUntil,
    bool _useSSYN
  ) internal virtual {
    _sync();
    require(_lockedUntil > now256(), "lock should be in the future");
    User storage user = users[_staker];
    if (user.tokenAmount > 0) {
      _processRewards(_staker, _useSSYN, false);
    }
    Deposit storage stakeDeposit = user.deposits[_depositId];

    require(_lockedUntil > stakeDeposit.lockedUntil, "invalid new lock");

    if (stakeDeposit.lockedFrom == 0) {
      require(_lockedUntil - now256() <= 365 days, "max lock period is 365 days");
      stakeDeposit.lockedFrom = uint64(now256());
    } else {
      require(_lockedUntil - stakeDeposit.lockedFrom <= 365 days, "max lock period is 365 days");
    }

    stakeDeposit.lockedUntil = _lockedUntil;
    uint256 newWeight = (((stakeDeposit.lockedUntil - stakeDeposit.lockedFrom) * WEIGHT_MULTIPLIER) /
      365 days +
      WEIGHT_MULTIPLIER) * stakeDeposit.tokenAmount;

    uint256 previousWeight = stakeDeposit.weight;
    stakeDeposit.weight = newWeight;

    user.totalWeight = user.totalWeight - previousWeight + newWeight;
    user.subYieldRewards = weightToReward(user.totalWeight, yieldRewardsPerWeight);
    usersLockingWeight = usersLockingWeight - previousWeight + newWeight;

    emit StakeLockUpdated(_staker, _depositId, stakeDeposit.lockedFrom, _lockedUntil);
  }

  function weightToReward(uint256 _weight, uint256 rewardPerWeight) public pure returns (uint256) {
    return (_weight * rewardPerWeight) / REWARD_PER_WEIGHT_MULTIPLIER;
  }

  function rewardToWeight(uint256 reward, uint256 rewardPerWeight) public pure returns (uint256) {
    return (reward * REWARD_PER_WEIGHT_MULTIPLIER) / rewardPerWeight;
  }

  function blockNumber() public view virtual returns (uint256) {
    return block.number;
  }

  function now256() public view virtual returns (uint256) {
    return block.timestamp;
  }

  function mintSSyn(address _to, uint256 _value) internal {
    SyntheticSyndicateERC20(ssynr).mint(_to, _value);
  }

  function transferPoolToken(address _to, uint256 _value) internal nonReentrant {
    SafeERC20.safeTransfer(IERC20(poolToken), _to, _value);
  }

  function transferPoolTokenFrom(
    address _from,
    address _to,
    uint256 _value
  ) internal nonReentrant {
    SafeERC20.safeTransferFrom(IERC20(poolToken), _from, _to, _value);
  }
}// MIT

pragma solidity 0.8.1;


contract SyndicateCorePool is SyndicatePoolBase {
  bool public constant override isFlashPool = false;

  uint256 public quickRewardRate;

  uint256 public totalQuickReward;

  uint256 public maxQuickReward;

  address public vault;

  uint256 public vaultRewardsPerWeight;

  uint256 public poolTokenReserve;

  event VaultRewardsReceived(address indexed _by, uint256 amount);

  event VaultRewardsClaimed(address indexed _by, address indexed _to, uint256 amount);

  event VaultUpdated(address indexed _by, address _fromVal, address _toVal);

  constructor(
    address _synr,
    address _ssynr,
    SyndicatePoolFactory _factory,
    address _poolToken,
    uint64 _initBlock,
    uint32 _weight
  ) SyndicatePoolBase(_synr, _ssynr, _factory, _poolToken, _initBlock, _weight) {}

  function pendingVaultRewards(address _staker) public view returns (uint256 pending) {
    User storage user = users[_staker];

    return weightToReward(user.totalWeight, vaultRewardsPerWeight) - user.subVaultRewards;
  }

  function setQuickRewardRate(uint256 _quickRewardRate) external onlyFactoryOwner {
    require(_quickRewardRate < 100000, "parameter out of range");
    quickRewardRate = _quickRewardRate;
  }

  function setMaxQuickReward(uint256 _maxQuickReward) external onlyFactoryOwner {
    maxQuickReward = _maxQuickReward;
  }

  function setVault(address _vault) external {
    require(factory.owner() == msg.sender, "access denied");

    require(_vault != address(0), "zero input");

    emit VaultUpdated(msg.sender, vault, _vault);

    vault = _vault;
  }

  function receiveVaultRewards(uint256 _rewardsAmount) external {
    require(msg.sender == vault, "access denied");
    if (_rewardsAmount == 0) {
      return;
    }
    require(usersLockingWeight > 0, "zero locking weight");

    _transferSynFrom(msg.sender, address(this), _rewardsAmount);

    vaultRewardsPerWeight += rewardToWeight(_rewardsAmount, usersLockingWeight);

    if (poolToken == synr) {
      poolTokenReserve += _rewardsAmount;
    }

    emit VaultRewardsReceived(msg.sender, _rewardsAmount);
  }

  function processRewards(bool _useSSYN) external override poolAlive {
    _processRewards(msg.sender, _useSSYN, true);
  }

  function stakeAsPool(address _staker, uint256 _amount) external {
    require(factory.poolExists(msg.sender), "access denied");
    _sync();
    User storage user = users[_staker];
    if (user.tokenAmount > 0) {
      _processRewards(_staker, false, false);
    }
    uint256 depositWeight = _amount * YEAR_STAKE_WEIGHT_MULTIPLIER;
    Deposit memory newDeposit = Deposit({
      tokenAmount: _amount,
      lockedFrom: uint64(now256()),
      lockedUntil: uint64(now256() + 365 days),
      weight: depositWeight,
      isYield: true
    });
    user.tokenAmount += _amount;
    user.totalWeight += depositWeight;
    user.deposits.push(newDeposit);

    usersLockingWeight += depositWeight;

    user.subYieldRewards = weightToReward(user.totalWeight, yieldRewardsPerWeight);
    user.subVaultRewards = weightToReward(user.totalWeight, vaultRewardsPerWeight);

    poolTokenReserve += _amount;
  }

  function _updateStakeLock(
    address _staker,
    uint256 _depositId,
    uint64 _lockedUntil,
    bool _useSSYN
  ) internal override poolAlive {
    super._updateStakeLock(_staker, _depositId, _lockedUntil, _useSSYN);
    User storage user = users[_staker];
    user.subVaultRewards = weightToReward(user.totalWeight, vaultRewardsPerWeight);
  }

  function _stake(
    address _staker,
    uint256 _amount,
    uint64 _lockedUntil,
    bool _useSSYN,
    bool _isYield
  ) internal override {
    super._stake(_staker, _amount, _lockedUntil, _useSSYN, _isYield);
    User storage user = users[_staker];
    user.subVaultRewards = weightToReward(user.totalWeight, vaultRewardsPerWeight);

    poolTokenReserve += _amount;

    if (quickRewardRate > 0 && _lockedUntil > 0) {
      uint256 reward = ((_lockedUntil - now256()) * _amount * quickRewardRate) / (10000 * 365 days);
      if (totalQuickReward < maxQuickReward) {
        if (totalQuickReward + reward > maxQuickReward) {
          reward = maxQuickReward - totalQuickReward;
        }
        mintSSyn(_staker, reward);
        totalQuickReward += reward;
      }
    }
  }

  function _unstake(
    address _staker,
    uint256 _depositId,
    uint256 _amount,
    bool _useSSYN
  ) internal override {
    User storage user = users[_staker];
    Deposit memory stakeDeposit = user.deposits[_depositId];
    require(stakeDeposit.lockedFrom == 0 || now256() > stakeDeposit.lockedUntil, "deposit not yet unlocked");
    poolTokenReserve -= _amount;
    super._unstake(_staker, _depositId, _amount, _useSSYN);
    user.subVaultRewards = weightToReward(user.totalWeight, vaultRewardsPerWeight);
  }

  function _processRewards(
    address _staker,
    bool _useSSYN,
    bool _withUpdate
  ) internal override returns (uint256 pendingYield) {
    _processVaultRewards(_staker, _withUpdate);
    pendingYield = super._processRewards(_staker, _useSSYN, _withUpdate);

    if (poolToken == synr && !_useSSYN) {
      poolTokenReserve += pendingYield;
    }
  }

  function _processVaultRewards(address _staker, bool _withUpdate) private {
    User storage user = users[_staker];
    uint256 pendingVaultClaim = pendingVaultRewards(_staker);
    if (pendingVaultClaim == 0) return;
    uint256 synBalance = IERC20(synr).balanceOf(address(this));
    require(synBalance >= pendingVaultClaim, "contract SYNR balance too low");

    if (poolToken == synr) {
      poolTokenReserve -= pendingVaultClaim > poolTokenReserve ? poolTokenReserve : pendingVaultClaim;
    }

    if (_withUpdate) {
      user.subVaultRewards = weightToReward(user.totalWeight, vaultRewardsPerWeight);
    }

    _transferSyn(_staker, pendingVaultClaim);

    emit VaultRewardsClaimed(msg.sender, _staker, pendingVaultClaim);
  }

  function delegate(address receiver) external onlyFactoryOwner {
    require(poolToken == synr, "CorePool: only synr pool can delegate");
    SyndicateERC20(synr).delegate(receiver);
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
pragma solidity >= 0.4.22 <0.9.0;

library console {
	address constant CONSOLE_ADDRESS = address(0x000000000000000000636F6e736F6c652e6c6f67);

	function _sendLogPayload(bytes memory payload) private view {
		uint256 payloadLength = payload.length;
		address consoleAddress = CONSOLE_ADDRESS;
		assembly {
			let payloadStart := add(payload, 32)
			let r := staticcall(gas(), consoleAddress, payloadStart, payloadLength, 0, 0)
		}
	}

	function log() internal view {
		_sendLogPayload(abi.encodeWithSignature("log()"));
	}

	function logInt(int p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(int)", p0));
	}

	function logUint(uint p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint)", p0));
	}

	function logString(string memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function logBool(bool p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function logAddress(address p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function logBytes(bytes memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes)", p0));
	}

	function logBytes1(bytes1 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes1)", p0));
	}

	function logBytes2(bytes2 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes2)", p0));
	}

	function logBytes3(bytes3 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes3)", p0));
	}

	function logBytes4(bytes4 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes4)", p0));
	}

	function logBytes5(bytes5 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes5)", p0));
	}

	function logBytes6(bytes6 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes6)", p0));
	}

	function logBytes7(bytes7 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes7)", p0));
	}

	function logBytes8(bytes8 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes8)", p0));
	}

	function logBytes9(bytes9 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes9)", p0));
	}

	function logBytes10(bytes10 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes10)", p0));
	}

	function logBytes11(bytes11 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes11)", p0));
	}

	function logBytes12(bytes12 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes12)", p0));
	}

	function logBytes13(bytes13 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes13)", p0));
	}

	function logBytes14(bytes14 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes14)", p0));
	}

	function logBytes15(bytes15 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes15)", p0));
	}

	function logBytes16(bytes16 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes16)", p0));
	}

	function logBytes17(bytes17 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes17)", p0));
	}

	function logBytes18(bytes18 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes18)", p0));
	}

	function logBytes19(bytes19 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes19)", p0));
	}

	function logBytes20(bytes20 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes20)", p0));
	}

	function logBytes21(bytes21 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes21)", p0));
	}

	function logBytes22(bytes22 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes22)", p0));
	}

	function logBytes23(bytes23 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes23)", p0));
	}

	function logBytes24(bytes24 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes24)", p0));
	}

	function logBytes25(bytes25 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes25)", p0));
	}

	function logBytes26(bytes26 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes26)", p0));
	}

	function logBytes27(bytes27 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes27)", p0));
	}

	function logBytes28(bytes28 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes28)", p0));
	}

	function logBytes29(bytes29 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes29)", p0));
	}

	function logBytes30(bytes30 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes30)", p0));
	}

	function logBytes31(bytes31 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes31)", p0));
	}

	function logBytes32(bytes32 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes32)", p0));
	}

	function log(uint p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint)", p0));
	}

	function log(string memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function log(bool p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function log(address p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function log(uint p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint)", p0, p1));
	}

	function log(uint p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string)", p0, p1));
	}

	function log(uint p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool)", p0, p1));
	}

	function log(uint p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address)", p0, p1));
	}

	function log(string memory p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint)", p0, p1));
	}

	function log(string memory p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string)", p0, p1));
	}

	function log(string memory p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool)", p0, p1));
	}

	function log(string memory p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address)", p0, p1));
	}

	function log(bool p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint)", p0, p1));
	}

	function log(bool p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string)", p0, p1));
	}

	function log(bool p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool)", p0, p1));
	}

	function log(bool p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address)", p0, p1));
	}

	function log(address p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint)", p0, p1));
	}

	function log(address p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string)", p0, p1));
	}

	function log(address p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool)", p0, p1));
	}

	function log(address p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address)", p0, p1));
	}

	function log(uint p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint)", p0, p1, p2));
	}

	function log(uint p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string)", p0, p1, p2));
	}

	function log(uint p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool)", p0, p1, p2));
	}

	function log(uint p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address)", p0, p1, p2));
	}

	function log(uint p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint)", p0, p1, p2));
	}

	function log(uint p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string)", p0, p1, p2));
	}

	function log(uint p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool)", p0, p1, p2));
	}

	function log(uint p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address)", p0, p1, p2));
	}

	function log(uint p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint)", p0, p1, p2));
	}

	function log(uint p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string)", p0, p1, p2));
	}

	function log(uint p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool)", p0, p1, p2));
	}

	function log(uint p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address)", p0, p1, p2));
	}

	function log(string memory p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint)", p0, p1, p2));
	}

	function log(string memory p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string)", p0, p1, p2));
	}

	function log(string memory p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool)", p0, p1, p2));
	}

	function log(string memory p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address)", p0, p1, p2));
	}

	function log(bool p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint)", p0, p1, p2));
	}

	function log(bool p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string)", p0, p1, p2));
	}

	function log(bool p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool)", p0, p1, p2));
	}

	function log(bool p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address)", p0, p1, p2));
	}

	function log(bool p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint)", p0, p1, p2));
	}

	function log(bool p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string)", p0, p1, p2));
	}

	function log(bool p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool)", p0, p1, p2));
	}

	function log(bool p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address)", p0, p1, p2));
	}

	function log(bool p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint)", p0, p1, p2));
	}

	function log(bool p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string)", p0, p1, p2));
	}

	function log(bool p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool)", p0, p1, p2));
	}

	function log(bool p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address)", p0, p1, p2));
	}

	function log(address p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint)", p0, p1, p2));
	}

	function log(address p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string)", p0, p1, p2));
	}

	function log(address p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool)", p0, p1, p2));
	}

	function log(address p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address)", p0, p1, p2));
	}

	function log(address p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint)", p0, p1, p2));
	}

	function log(address p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string)", p0, p1, p2));
	}

	function log(address p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool)", p0, p1, p2));
	}

	function log(address p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address)", p0, p1, p2));
	}

	function log(address p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint)", p0, p1, p2));
	}

	function log(address p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string)", p0, p1, p2));
	}

	function log(address p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool)", p0, p1, p2));
	}

	function log(address p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address)", p0, p1, p2));
	}

	function log(address p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint)", p0, p1, p2));
	}

	function log(address p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string)", p0, p1, p2));
	}

	function log(address p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool)", p0, p1, p2));
	}

	function log(address p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address)", p0, p1, p2));
	}

	function log(uint p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,address)", p0, p1, p2, p3));
	}

}// MIT
pragma solidity 0.8.1;



contract SyndicatePoolFactory is Ownable, SyndicateAware {
  uint256 public constant FACTORY_UID = 0xc5cfd88c6e4d7e5c8a03c0f0f03af23c0918d8e82cac196f57466af3fd4a5ec7;

  bool public isFinal = false;

  struct PoolData {
    address poolToken;
    address poolAddress;
    uint32 weight;
    bool isFlashPool;
  }

  uint192 public synrPerBlock;

  uint32 public totalWeight;

  uint32 public blocksPerUpdate;

  uint32 public endBlock;

  uint32 public decayFactor = 97;

  uint32 public lastRatioUpdate;

  address public immutable ssynr;

  mapping(address => address) public pools;

  mapping(address => bool) public poolExists;

  modifier notFinal() {
    require(! isFinal, "pool is final");
    _;
  }

  event PoolRegistered(
    address indexed _by,
    address indexed poolToken,
    address indexed poolAddress,
    uint32 weight,
    bool isFlashPool
  );

  event WeightUpdated(address indexed _by, address indexed poolAddress, uint32 weight);

  event SynRatioUpdated(address indexed _by, uint256 newSynPerBlock);

  constructor(
    address _synr,
    address _ssynr,
    uint192 _synrPerBlock,
    uint32 _blocksPerUpdate,
    uint32 _initBlock,
    uint32 _endBlock
  ) SyndicateAware(_synr) {
    require(_ssynr != address(0), "sSYNR address not set");
    require(_synrPerBlock > 0, "SYNR/block not set");
    require(_blocksPerUpdate > 0, "blocks/update not set");
    require(_initBlock > 0, "init block not set");
    require(_endBlock > _initBlock, "invalid end block: must be greater than init block");

    require(
      SyntheticSyndicateERC20(_ssynr).TOKEN_UID() == 0xac3051b8d4f50966afb632468a4f61483ae6a953b74e387a01ef94316d6b7d62,
      "unexpected sSYNR TOKEN_UID"
    );

    ssynr = _ssynr;
    synrPerBlock = _synrPerBlock;
    blocksPerUpdate = _blocksPerUpdate;
    lastRatioUpdate = _initBlock;
    endBlock = _endBlock;
  }

  function getPoolAddress(address poolToken) external view returns (address) {
    return pools[poolToken];
  }

  function getPoolData(address _poolToken) public view returns (PoolData memory) {
    address poolAddr = pools[_poolToken];

    require(poolAddr != address(0), "pool not found");

    address poolToken = IPool(poolAddr).poolToken();
    bool isFlashPool = IPool(poolAddr).isFlashPool();
    uint32 weight = IPool(poolAddr).weight();

    return PoolData({poolToken: poolToken, poolAddress: poolAddr, weight: weight, isFlashPool: isFlashPool});
  }

  function shouldUpdateRatio() public view returns (bool) {
    if (blockNumber() > endBlock) {
      return false;
    }

    return blockNumber() >= lastRatioUpdate + blocksPerUpdate;
  }

  function createPool(
    address poolToken,
    uint64 initBlock,
    uint32 weight
  ) external virtual onlyOwner {
    IPool pool = new SyndicateCorePool(synr, ssynr, this, poolToken, initBlock, weight);

    registerPool(address(pool));
  }

  function registerPool(address poolAddr) public onlyOwner {
    address poolToken = IPool(poolAddr).poolToken();
    bool isFlashPool = IPool(poolAddr).isFlashPool();
    uint32 weight = IPool(poolAddr).weight();

    require(pools[poolToken] == address(0), "this pool is already registered");

    pools[poolToken] = poolAddr;
    poolExists[poolAddr] = true;
    totalWeight += weight;

    emit PoolRegistered(msg.sender, poolToken, poolAddr, weight, isFlashPool);
  }

  function updateSYNPerBlock() external {
    require(shouldUpdateRatio(), "too frequent");

    synrPerBlock = (synrPerBlock * decayFactor) / 100;

    lastRatioUpdate = uint32(blockNumber());

    emit SynRatioUpdated(msg.sender, synrPerBlock);
  }

  function overrideSYNPerBlock(uint192 _synrPerBlock) external onlyOwner notFinal {
    synrPerBlock = _synrPerBlock;
    emit SynRatioUpdated(msg.sender, synrPerBlock);
  }

  function overrideBlockesPerUpdate(uint32 _blocksPerUpdate) external onlyOwner notFinal {
    blocksPerUpdate = _blocksPerUpdate;
  }

  function overrideEndblock(uint32 _endBlock) external onlyOwner notFinal {
    endBlock = _endBlock;
  }

  function overrideDecayFactor(uint32 _decayFactor) external onlyOwner notFinal {
    decayFactor = _decayFactor;
  }

  function finalizePool() external onlyOwner {
    isFinal = true;
  }

  function mintYieldTo(address _to, uint256 _amount) external {
    require(poolExists[msg.sender], "access denied");

    _mintSyn(_to, _amount);
  }

  function changePoolWeight(address poolAddr, uint32 weight) external {
    require(msg.sender == owner() || poolExists[msg.sender], "access denied");

    totalWeight = totalWeight + weight - IPool(poolAddr).weight();

    IPool(poolAddr).setWeight(weight);

    emit WeightUpdated(msg.sender, poolAddr, weight);
  }

  function blockNumber() public view virtual returns (uint256) {
    return block.number;
  }
}