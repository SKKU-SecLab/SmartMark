



pragma solidity ^0.8.0;

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





pragma solidity ^0.8.0;

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

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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
}





pragma solidity ^0.8.0;


library SafeERC20 {

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

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}





pragma solidity ^0.8.0;

abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}





pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}




pragma solidity >=0.6.0 <0.8.5;

abstract contract Pausable is ContextUpgradeable {
  event Paused(address account);

  event Unpaused(address account);

  bool private _paused;

  constructor() {
    _paused = false;
  }

  function paused() public view virtual returns (bool) {
    return _paused;
  }

  modifier whenNotPaused() {
    require(!paused(), "Pausable: paused");
    _;
  }

  modifier whenPaused() {
    require(paused(), "Pausable: not paused");
    _;
  }

  function _pause() internal virtual whenNotPaused {
    _paused = true;
    emit Paused(_msgSender());
  }

  function _unpause() internal virtual whenPaused {
    _paused = false;
    emit Unpaused(_msgSender());
  }
}





pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}





pragma solidity ^0.8.0;

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}





pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}





pragma solidity ^0.8.0;



contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

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

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}




pragma solidity ^0.8.0;

contract CosmosERC20 is ERC20 {
	uint256 MAX_UINT = 2**256 - 1;
	uint8 immutable private _decimals;

	constructor(
		address peggyAddress_,
		string memory name_,
		string memory symbol_,
		uint8 decimals_
	) ERC20(name_, symbol_) {
		_decimals = decimals_;
		_mint(peggyAddress_, MAX_UINT);
	}

	function decimals() public view virtual override returns (uint8) {
		return _decimals;
	}
}





pragma solidity ^0.8.0;


abstract contract OwnableUpgradeableWithExpiry is Initializable, ContextUpgradeable {
    address private _owner;
    uint256 private _deployTimestamp;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        address msgSender = _msgSender();
        _owner = msgSender;
        _deployTimestamp = block.timestamp;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() external virtual onlyOwner {
        _renounceOwnership();
    }

    function getOwnershipExpiryTimestamp() public view returns (uint256) {
       return _deployTimestamp + 82 weeks;
    }

    function isOwnershipExpired() public view returns (bool) {
       return block.timestamp > getOwnershipExpiryTimestamp();
    }

    function renounceOwnershipAfterExpiry() external {
        require(isOwnershipExpired(), "Ownership not yet expired");
        _renounceOwnership();
    }

    function transferOwnership(address newOwner) external virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function _renounceOwnership() private {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    uint256[49] private __gap;
}




pragma solidity ^0.8.0;







struct ValsetArgs {
  address[] validators;
  uint256[] powers;
  uint256 valsetNonce;
  uint256 rewardAmount;
  address rewardToken;
}

contract Peggy is Initializable, OwnableUpgradeableWithExpiry, Pausable, ReentrancyGuard {
  using SafeERC20 for IERC20;

bytes32 public state_lastValsetCheckpoint;
mapping(address => uint256) public state_lastBatchNonces;
mapping(bytes32 => uint256) public state_invalidationMapping;
uint256 public state_lastValsetNonce = 0;
uint256 public state_lastEventNonce = 0;

bytes32 public state_peggyId;
uint256 public state_powerThreshold;

  event TransactionBatchExecutedEvent(
    uint256 indexed _batchNonce,
    address indexed _token,
    uint256 _eventNonce
  );
  event SendToCosmosEvent(
    address indexed _tokenContract,
    address indexed _sender,
    bytes32 indexed _destination,
    uint256 _amount,
    uint256 _eventNonce
  );
  event ERC20DeployedEvent(
    string _cosmosDenom,
    address indexed _tokenContract,
    string _name,
    string _symbol,
    uint8 _decimals,
    uint256 _eventNonce
  );
  event ValsetUpdatedEvent(
    uint256 indexed _newValsetNonce,
    uint256 _eventNonce,
    uint256 _rewardAmount,
    address _rewardToken,
    address[] _validators,
    uint256[] _powers
  );

  function initialize(
    bytes32 _peggyId,
    uint256 _powerThreshold,
    address[] calldata _validators,
    uint256[] memory _powers
  ) external initializer {
    __Context_init_unchained();
    __Ownable_init_unchained();

    require(
      _validators.length == _powers.length,
      "Malformed current validator set"
    );

    uint256 cumulativePower = 0;
    for (uint256 i = 0; i < _powers.length; i++) {
      cumulativePower = cumulativePower + _powers[i];
      if (cumulativePower > _powerThreshold) {
        break;
      }
    }

    require(
      cumulativePower > _powerThreshold,
      "Submitted validator set signatures do not have enough power."
    );

    ValsetArgs memory _valset;
    _valset = ValsetArgs(_validators, _powers, 0, 0, address(0));

    bytes32 newCheckpoint = makeCheckpoint(_valset, _peggyId);


    state_peggyId = _peggyId;
    state_powerThreshold = _powerThreshold;
    state_lastValsetCheckpoint = newCheckpoint;
    state_lastEventNonce = state_lastEventNonce + 1;

    emit ValsetUpdatedEvent(
      state_lastValsetNonce,
      state_lastEventNonce,
      0,
      address(0),
      _validators,
      _powers
    );
  }

  function lastBatchNonce(address _erc20Address) public view returns (uint256) {
    return state_lastBatchNonces[_erc20Address];
  }

  function verifySig(
    address _signer,
    bytes32 _theHash,
    uint8 _v,
    bytes32 _r,
    bytes32 _s
  ) private pure returns (bool) {
    bytes32 messageDigest =
      keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _theHash));
    return _signer == ecrecover(messageDigest, _v, _r, _s);
  }

  function makeCheckpoint(ValsetArgs memory _valsetArgs, bytes32 _peggyId)
    private
    pure
    returns (bytes32)
  {
    bytes32 methodName =
      0x636865636b706f696e7400000000000000000000000000000000000000000000;

    bytes32 checkpoint =
      keccak256(
        abi.encode(
          _peggyId,
          methodName,
          _valsetArgs.valsetNonce,
          _valsetArgs.validators,
          _valsetArgs.powers,
          _valsetArgs.rewardAmount,
          _valsetArgs.rewardToken
        )
      );
    return checkpoint;
  }

  function checkValidatorSignatures(
    address[] memory _currentValidators,
    uint256[] memory _currentPowers,
    uint8[] memory _v,
    bytes32[] memory _r,
    bytes32[] memory _s,
    bytes32 _theHash,
    uint256 _powerThreshold
  ) private pure {
    uint256 cumulativePower = 0;

    for (uint256 i = 0; i < _currentValidators.length; i++) {
      if (_v[i] != 0) {
        require(
          verifySig(_currentValidators[i], _theHash, _v[i], _r[i], _s[i]),
          "Validator signature does not match."
        );

        cumulativePower = cumulativePower + _currentPowers[i];

        if (cumulativePower > _powerThreshold) {
          break;
        }
      }
    }

    require(
      cumulativePower > _powerThreshold,
      "Submitted validator set signatures do not have enough power."
    );
  }

  function updateValset(
    ValsetArgs memory _newValset,
    ValsetArgs memory _currentValset,
    uint8[] memory _v,
    bytes32[] memory _r,
    bytes32[] memory _s
  ) external whenNotPaused {

    require(
      _newValset.valsetNonce > _currentValset.valsetNonce,
      "New valset nonce must be greater than the current nonce"
    );

    require(
      _newValset.validators.length == _newValset.powers.length,
      "Malformed new validator set"
    );

    require(
      _currentValset.validators.length == _currentValset.powers.length &&
        _currentValset.validators.length == _v.length &&
        _currentValset.validators.length == _r.length &&
        _currentValset.validators.length == _s.length,
      "Malformed current validator set"
    );

    require(
      makeCheckpoint(_currentValset, state_peggyId) ==
        state_lastValsetCheckpoint,
      "Supplied current validators and powers do not match checkpoint."
    );

    bytes32 newCheckpoint = makeCheckpoint(_newValset, state_peggyId);
    checkValidatorSignatures(
      _currentValset.validators,
      _currentValset.powers,
      _v,
      _r,
      _s,
      newCheckpoint,
      state_powerThreshold
    );


    state_lastValsetCheckpoint = newCheckpoint;

    state_lastValsetNonce = _newValset.valsetNonce;

    if (_newValset.rewardToken != address(0) && _newValset.rewardAmount != 0) {
      IERC20(_newValset.rewardToken).safeTransfer(
        msg.sender,
        _newValset.rewardAmount
      );
    }

    state_lastEventNonce = state_lastEventNonce + 1;
    emit ValsetUpdatedEvent(
      _newValset.valsetNonce,
      state_lastEventNonce,
      _newValset.rewardAmount,
      _newValset.rewardToken,
      _newValset.validators,
      _newValset.powers
    );
  }

  function submitBatch(
    ValsetArgs memory _currentValset,
    uint8[] memory _v,
    bytes32[] memory _r,
    bytes32[] memory _s,
    uint256[] memory _amounts,
    address[] memory _destinations,
    uint256[] memory _fees,
    uint256 _batchNonce,
    address _tokenContract,
    uint256 _batchTimeout
  ) external nonReentrant whenNotPaused {
    {
      require(
        state_lastBatchNonces[_tokenContract] < _batchNonce,
        "New batch nonce must be greater than the current nonce"
      );

      require(
        block.number < _batchTimeout,
        "Batch timeout must be greater than the current block height"
      );

      require(
        _currentValset.validators.length == _currentValset.powers.length &&
          _currentValset.validators.length == _v.length &&
          _currentValset.validators.length == _r.length &&
          _currentValset.validators.length == _s.length,
        "Malformed current validator set"
      );

      require(
        makeCheckpoint(_currentValset, state_peggyId) ==
          state_lastValsetCheckpoint,
        "Supplied current validators and powers do not match checkpoint."
      );

      require(
        _amounts.length == _destinations.length &&
          _amounts.length == _fees.length,
        "Malformed batch of transactions"
      );

      checkValidatorSignatures(
        _currentValset.validators,
        _currentValset.powers,
        _v,
        _r,
        _s,
        keccak256(
          abi.encode(
            state_peggyId,
            0x7472616e73616374696f6e426174636800000000000000000000000000000000,
            _amounts,
            _destinations,
            _fees,
            _batchNonce,
            _tokenContract,
            _batchTimeout
          )
        ),
        state_powerThreshold
      );


      state_lastBatchNonces[_tokenContract] = _batchNonce;

      {
        uint256 totalFee;
        for (uint256 i = 0; i < _amounts.length; i++) {
          IERC20(_tokenContract).safeTransfer(_destinations[i], _amounts[i]);
          totalFee = totalFee + _fees[i];
        }

        if (totalFee > 0) {
          IERC20(_tokenContract).safeTransfer(msg.sender, totalFee);
        }
      }
    }

    {
      state_lastEventNonce = state_lastEventNonce + 1;
      emit TransactionBatchExecutedEvent(
        _batchNonce,
        _tokenContract,
        state_lastEventNonce
      );
    }
  }

  function sendToCosmos(
    address _tokenContract,
    bytes32 _destination,
    uint256 _amount
  ) external whenNotPaused nonReentrant {
    IERC20(_tokenContract).safeTransferFrom(msg.sender, address(this), _amount);
    state_lastEventNonce = state_lastEventNonce + 1;
    emit SendToCosmosEvent(
      _tokenContract,
      msg.sender,
      _destination,
      _amount,
      state_lastEventNonce
    );
  }

  function deployERC20(
    string calldata _cosmosDenom,
    string calldata _name,
    string calldata _symbol,
    uint8 _decimals
  ) external {
    CosmosERC20 erc20 =
      new CosmosERC20(address(this), _name, _symbol, _decimals);

    state_lastEventNonce = state_lastEventNonce + 1;
    emit ERC20DeployedEvent(
      _cosmosDenom,
      address(erc20),
      _name,
      _symbol,
      _decimals,
      state_lastEventNonce
    );
  }

  function emergencyPause() external onlyOwner {
    _pause();
  }

  function emergencyUnpause() external onlyOwner {
    _unpause();
  }
}