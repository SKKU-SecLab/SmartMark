

pragma solidity 0.8.6;




interface IBetaBank {

  function bTokens(address _underlying) external view returns (address);


  function underlyings(address _bToken) external view returns (address);


  function oracle() external view returns (address);


  function config() external view returns (address);


  function interestModel() external view returns (address);


  function getPositionTokens(address _owner, uint _pid)
    external
    view
    returns (address _collateral, address _bToken);


  function fetchPositionDebt(address _owner, uint _pid) external returns (uint);


  function fetchPositionLTV(address _owner, uint _pid) external returns (uint);


  function open(
    address _owner,
    address _underlying,
    address _collateral
  ) external returns (uint pid);


  function borrow(
    address _owner,
    uint _pid,
    uint _amount
  ) external;


  function repay(
    address _owner,
    uint _pid,
    uint _amount
  ) external;


  function put(
    address _owner,
    uint _pid,
    uint _amount
  ) external;


  function take(
    address _owner,
    uint _pid,
    uint _amount
  ) external;


  function liquidate(
    address _owner,
    uint _pid,
    uint _amount
  ) external;

}


interface IBetaConfig {

  function getRiskLevel(address token) external view returns (uint);


  function reserveRate() external view returns (uint);


  function reserveBeneficiary() external view returns (address);


  function getCollFactor(address token) external view returns (uint);


  function getCollMaxAmount(address token) external view returns (uint);


  function getSafetyLTV(address token) external view returns (uint);


  function getLiquidationLTV(address token) external view returns (uint);


  function getKillBountyRate(address token) external view returns (uint);

}


interface IBetaInterestModel {

  function initialRate() external view returns (uint);


  function getNextInterestRate(
    uint prevRate,
    uint totalAvailable,
    uint totalLoan,
    uint timePast
  ) external view returns (uint);

}


interface IBetaOracle {

  function getAssetETHPrice(address token) external returns (uint);


  function getAssetETHValue(address token, uint amount) external returns (uint);


  function convert(
    address from,
    address to,
    uint amount
  ) external returns (uint);

}


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
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


library Counters {

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {

        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {

        counter._value = 0;
    }
}


library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return recover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return recover(hash, r, vs);
        } else {
            revert("ECDSA: invalid signature length");
        }
    }

    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {

        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return recover(hash, v, r, s);
    }

    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {

        require(
            uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0,
            "ECDSA: invalid signature 's' value"
        );
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}


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
}


interface IERC20Permit {

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    function nonces(address owner) external view returns (uint256);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

}


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


library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + (((a % 2) + (b % 2)) / 2);
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b + (a % b == 0 ? 0 : 1);
    }
}


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
}


abstract contract EIP712 {
    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;

    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;
    bytes32 private immutable _TYPE_HASH;


    constructor(string memory name, string memory version) {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = block.chainid;
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
        _TYPE_HASH = typeHash;
    }

    function _domainSeparatorV4() internal view returns (bytes32) {
        if (block.chainid == _CACHED_CHAIN_ID) {
            return _CACHED_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
        }
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
    }

    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
    }
}


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}


abstract contract Pausable is Context {
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

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

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

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
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

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}


abstract contract ERC20Permit is ERC20, IERC20Permit, EIP712 {
    using Counters for Counters.Counter;

    mapping(address => Counters.Counter) private _nonces;

    bytes32 private immutable _PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    constructor(string memory name) EIP712(name, "1") {}

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual override {
        require(block.timestamp <= deadline, "ERC20Permit: expired deadline");

        bytes32 structHash = keccak256(abi.encode(_PERMIT_TYPEHASH, owner, spender, value, _useNonce(owner), deadline));

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, v, r, s);
        require(signer == owner, "ERC20Permit: invalid signature");

        _approve(owner, spender, value);
    }

    function nonces(address owner) public view virtual override returns (uint256) {
        return _nonces[owner].current();
    }

    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _domainSeparatorV4();
    }

    function _useNonce(address owner) internal virtual returns (uint256 current) {
        Counters.Counter storage nonce = _nonces[owner];
        current = nonce.current();
        nonce.increment();
    }
}


contract BToken is ERC20Permit, ReentrancyGuard {
  using SafeERC20 for IERC20;

  event Accrue(uint interest);
  event Mint(address indexed caller, address indexed to, uint amount, uint credit);
  event Burn(address indexed caller, address indexed to, uint amount, uint credit);

  uint public constant MINIMUM_LIQUIDITY = 10**6; // minimum liquidity to be locked in the pool when first mint occurs

  address public immutable betaBank; // BetaBank address
  address public immutable underlying; // the underlying token

  uint public interestRate; // current interest rate
  uint public lastAccrueTime; // last interest accrual timestamp
  uint public totalLoanable; // total asset amount available to be borrowed
  uint public totalLoan; // total amount of loan
  uint public totalDebtShare; // total amount of debt share

  constructor(address _betaBank, address _underlying)
    ERC20Permit('B Token')
    ERC20('B Token', 'bTOKEN')
  {
    require(_betaBank != address(0), 'constructor/betabank-zero-address');
    require(_underlying != address(0), 'constructor/underlying-zero-address');
    betaBank = _betaBank;
    underlying = _underlying;
    interestRate = IBetaInterestModel(IBetaBank(_betaBank).interestModel()).initialRate();
    lastAccrueTime = block.timestamp;
  }

  function name() public view override returns (string memory) {
    try IERC20Metadata(underlying).name() returns (string memory data) {
      return string(abi.encodePacked('B ', data));
    } catch (bytes memory) {
      return ERC20.name();
    }
  }

  function symbol() public view override returns (string memory) {
    try IERC20Metadata(underlying).symbol() returns (string memory data) {
      return string(abi.encodePacked('b', data));
    } catch (bytes memory) {
      return ERC20.symbol();
    }
  }

  function decimals() public view override returns (uint8) {
    try IERC20Metadata(underlying).decimals() returns (uint8 data) {
      return data;
    } catch (bytes memory) {
      return ERC20.decimals();
    }
  }

  function accrue() public {
    uint timePassed = block.timestamp - lastAccrueTime;
    if (timePassed == 0) return;
    lastAccrueTime = block.timestamp;
    require(!Pausable(betaBank).paused(), 'BetaBank/paused');
    (uint totalLoan_, uint totalLoanable_, uint interestRate_) = (
      totalLoan,
      totalLoanable,
      interestRate
    ); // gas saving by avoiding multiple SLOADs
    IBetaConfig config = IBetaConfig(IBetaBank(betaBank).config());
    IBetaInterestModel model = IBetaInterestModel(IBetaBank(betaBank).interestModel());
    uint interest = (interestRate_ * totalLoan_ * timePassed) / (365 days) / 1e18;
    totalLoan_ += interest;
    totalLoan = totalLoan_;
    interestRate = model.getNextInterestRate(interestRate_, totalLoanable_, totalLoan_, timePassed);
    if (interest > 0) {
      uint reserveRate = config.reserveRate();
      if (reserveRate > 0) {
        uint toReserve = (interest * reserveRate) / 1e18;
        _mint(
          config.reserveBeneficiary(),
          (toReserve * totalSupply()) / (totalLoan_ + totalLoanable_ - toReserve)
        );
      }
      emit Accrue(interest);
    }
  }

  function fetchDebtShareValue(uint _debtShare) external returns (uint) {
    accrue();
    if (_debtShare == 0) {
      return 0;
    }
    return Math.ceilDiv(_debtShare * totalLoan, totalDebtShare); // round up
  }

  function mint(address _to, uint _amount) external nonReentrant returns (uint credit) {
    accrue();
    uint amount;
    {
      uint balBefore = IERC20(underlying).balanceOf(address(this));
      IERC20(underlying).safeTransferFrom(msg.sender, address(this), _amount);
      uint balAfter = IERC20(underlying).balanceOf(address(this));
      amount = balAfter - balBefore;
    }
    uint supply = totalSupply();
    if (supply == 0) {
      credit = amount - MINIMUM_LIQUIDITY;
      totalLoanable += credit;
      totalLoan += MINIMUM_LIQUIDITY;
      totalDebtShare += MINIMUM_LIQUIDITY;
      _mint(address(1), MINIMUM_LIQUIDITY); // OpenZeppelin ERC20 does not allow minting to 0
    } else {
      credit = (amount * supply) / (totalLoanable + totalLoan);
      totalLoanable += amount;
    }
    require(credit > 0, 'mint/no-credit-minted');
    _mint(_to, credit);
    emit Mint(msg.sender, _to, _amount, credit);
  }

  function burn(address _to, uint _credit) external nonReentrant returns (uint amount) {
    accrue();
    uint supply = totalSupply();
    amount = (_credit * (totalLoanable + totalLoan)) / supply;
    require(amount > 0, 'burn/no-amount-returned');
    totalLoanable -= amount;
    _burn(msg.sender, _credit);
    IERC20(underlying).safeTransfer(_to, amount);
    emit Burn(msg.sender, _to, amount, _credit);
  }

  function borrow(address _to, uint _amount) external nonReentrant returns (uint debtShare) {
    require(msg.sender == betaBank, 'borrow/not-BetaBank');
    accrue();
    IERC20(underlying).safeTransfer(_to, _amount);
    debtShare = Math.ceilDiv(_amount * totalDebtShare, totalLoan); // round up
    totalLoanable -= _amount;
    totalLoan += _amount;
    totalDebtShare += debtShare;
  }

  function repay(address _from, uint _amount) external nonReentrant returns (uint debtShare) {
    require(msg.sender == betaBank, 'repay/not-BetaBank');
    accrue();
    uint amount;
    {
      uint balBefore = IERC20(underlying).balanceOf(address(this));
      IERC20(underlying).safeTransferFrom(_from, address(this), _amount);
      uint balAfter = IERC20(underlying).balanceOf(address(this));
      amount = balAfter - balBefore;
    }
    require(amount <= totalLoan, 'repay/amount-too-high');
    debtShare = (amount * totalDebtShare) / totalLoan; // round down
    totalLoanable += amount;
    totalLoan -= amount;
    totalDebtShare -= debtShare;
    require(totalDebtShare >= MINIMUM_LIQUIDITY, 'repay/too-low-sum-debt-share');
  }

  function recover(
    address _token,
    address _to,
    uint _amount
  ) external nonReentrant {
    require(msg.sender == betaBank, 'recover/not-BetaBank');
    if (_amount == type(uint).max) {
      _amount = IERC20(_token).balanceOf(address(this));
    }
    IERC20(_token).safeTransfer(_to, _amount);
  }
}


contract BTokenDeployer {
  function deploy(address _underlying) external returns (address) {
    bytes32 salt = keccak256(abi.encode(msg.sender, _underlying));
    return address(new BToken{salt: salt}(msg.sender, _underlying));
  }

  function bTokenFor(address _betaBank, address _underlying) external view returns (address) {
    bytes memory args = abi.encode(_betaBank, _underlying);
    bytes32 code = keccak256(abi.encodePacked(type(BToken).creationCode, args));
    bytes32 salt = keccak256(args);
    return address(uint160(uint(keccak256(abi.encodePacked(hex'ff', address(this), salt, code)))));
  }
}


contract BetaBank is IBetaBank, Initializable, Pausable {
  using Address for address;
  using SafeERC20 for IERC20;

  event Create(address indexed underlying, address bToken);
  event Open(address indexed owner, uint indexed pid, address bToken, address collateral);
  event Borrow(address indexed owner, uint indexed pid, uint amount, uint share, address borrower);
  event Repay(address indexed owner, uint indexed pid, uint amount, uint share, address payer);
  event Put(address indexed owner, uint indexed pid, uint amount, address payer);
  event Take(address indexed owner, uint indexed pid, uint amount, address to);
  event Liquidate(
    address indexed owner,
    uint indexed pid,
    uint amount,
    uint share,
    uint reward,
    address caller
  );
  event SelflessLiquidate(
    address indexed owner,
    uint indexed pid,
    uint amount,
    uint share,
    address caller
  );
  event SetGovernor(address governor);
  event SetPendingGovernor(address pendingGovernor);
  event SetOracle(address oracle);
  event SetConfig(address config);
  event SetInterestModel(address interestModel);
  event SetRunnerWhitelist(address indexed runner, bool ok);
  event SetOwnerWhitelist(address indexed owner, bool ok);
  event SetAllowPublicCreate(bool ok);

  struct Position {
    uint32 blockBorrowPut; // safety check
    uint32 blockRepayTake; // safety check
    address bToken;
    address collateral;
    uint collateralSize;
    uint debtShare;
  }

  uint private unlocked; // reentrancy variable
  address public deployer; // deployer address
  address public override oracle; // oracle address
  address public override config; // config address
  address public override interestModel; // interest rate model address
  address public governor; // current governor
  address public pendingGovernor; // pending governor
  bool public allowPublicCreate; // allow public to create pool status

  mapping(address => address) public override bTokens; // mapping from underlying to bToken
  mapping(address => address) public override underlyings; // mapping from bToken to underlying token
  mapping(address => bool) public runnerWhitelists; // whitelist of authorized routers
  mapping(address => bool) public ownerWhitelists; // whitelist of authorized owners

  mapping(address => mapping(uint => Position)) public positions; // mapping from user to the user's position id to Position info
  mapping(address => uint) public nextPositionIds; // mapping from user to next position id (position count)
  mapping(address => uint) public totalCollaterals; // mapping from token address to amount of collateral

  modifier lock() {
    require(unlocked == 1, 'BetaBank/locked');
    unlocked = 2;
    _;
    unlocked = 1;
  }

  modifier onlyGov() {
    require(msg.sender == governor, 'BetaBank/onlyGov');
    _;
  }

  modifier isPermittedByOwner(address _owner) {
    require(isPermittedCaller(_owner, msg.sender), 'BetaBank/isPermittedByOwner');
    _;
  }

  modifier checkPID(address _owner, uint _pid) {
    require(_pid < nextPositionIds[_owner], 'BetaBank/checkPID');
    _;
  }

  function initialize(
    address _governor,
    address _deployer,
    address _oracle,
    address _config,
    address _interestModel
  ) external initializer {
    require(_governor != address(0), 'initialize/governor-zero-address');
    require(_deployer != address(0), 'initialize/deployer-zero-address');
    require(_oracle != address(0), 'initialize/oracle-zero-address');
    require(_config != address(0), 'initialize/config-zero-address');
    require(_interestModel != address(0), 'initialize/interest-model-zero-address');
    governor = _governor;
    deployer = _deployer;
    oracle = _oracle;
    config = _config;
    interestModel = _interestModel;
    unlocked = 1;
    emit SetGovernor(_governor);
    emit SetOracle(_oracle);
    emit SetConfig(_config);
    emit SetInterestModel(_interestModel);
  }

  function setPendingGovernor(address _pendingGovernor) external onlyGov {
    pendingGovernor = _pendingGovernor;
    emit SetPendingGovernor(_pendingGovernor);
  }

  function acceptGovernor() external {
    require(msg.sender == pendingGovernor, 'acceptGovernor/not-pending-governor');
    pendingGovernor = address(0);
    governor = msg.sender;
    emit SetGovernor(msg.sender);
  }

  function setOracle(address _oracle) external onlyGov {
    require(_oracle != address(0), 'setOracle/zero-address');
    oracle = _oracle;
    emit SetOracle(_oracle);
  }

  function setConfig(address _config) external onlyGov {
    require(_config != address(0), 'setConfig/zero-address');
    config = _config;
    emit SetConfig(_config);
  }

  function setInterestModel(address _interestModel) external onlyGov {
    require(_interestModel != address(0), 'setInterestModel/zero-address');
    interestModel = _interestModel;
    emit SetInterestModel(_interestModel);
  }

  function setRunnerWhitelists(address[] calldata _runners, bool ok) external onlyGov {
    for (uint idx = 0; idx < _runners.length; idx++) {
      runnerWhitelists[_runners[idx]] = ok;
      emit SetRunnerWhitelist(_runners[idx], ok);
    }
  }

  function setOwnerWhitelists(address[] calldata _owners, bool ok) external onlyGov {
    for (uint idx = 0; idx < _owners.length; idx++) {
      ownerWhitelists[_owners[idx]] = ok;
      emit SetOwnerWhitelist(_owners[idx], ok);
    }
  }

  function pause() external whenNotPaused onlyGov {
    _pause();
  }

  function unpause() external whenPaused onlyGov {
    _unpause();
  }

  function setAllowPublicCreate(bool _ok) external onlyGov {
    allowPublicCreate = _ok;
    emit SetAllowPublicCreate(_ok);
  }

  function create(address _underlying) external lock whenNotPaused returns (address bToken) {
    require(allowPublicCreate || msg.sender == governor, 'create/unauthorized');
    require(_underlying != address(this), 'create/not-like-this');
    require(_underlying.isContract(), 'create/underlying-not-contract');
    require(bTokens[_underlying] == address(0), 'create/underlying-already-exists');
    require(IBetaOracle(oracle).getAssetETHPrice(_underlying) > 0, 'create/no-price');
    bToken = BTokenDeployer(deployer).deploy(_underlying);
    bTokens[_underlying] = bToken;
    underlyings[bToken] = _underlying;
    emit Create(_underlying, bToken);
  }

  function isPermittedCaller(address _owner, address _sender) public view returns (bool) {
    return ((_owner == _sender && ownerWhitelists[_owner]) ||
      (_owner == tx.origin && runnerWhitelists[_sender]));
  }

  function getPositionTokens(address _owner, uint _pid)
    external
    view
    override
    checkPID(_owner, _pid)
    returns (address _collateral, address _bToken)
  {
    Position storage pos = positions[_owner][_pid];
    _collateral = pos.collateral;
    _bToken = pos.bToken;
  }

  function fetchPositionDebt(address _owner, uint _pid)
    external
    override
    checkPID(_owner, _pid)
    returns (uint)
  {
    Position storage pos = positions[_owner][_pid];
    return BToken(pos.bToken).fetchDebtShareValue(pos.debtShare);
  }

  function fetchPositionLTV(address _owner, uint _pid)
    external
    override
    checkPID(_owner, _pid)
    returns (uint)
  {
    return _fetchPositionLTV(positions[_owner][_pid]);
  }

  function open(
    address _owner,
    address _underlying,
    address _collateral
  ) external override whenNotPaused isPermittedByOwner(_owner) returns (uint pid) {
    address bToken = bTokens[_underlying];
    require(bToken != address(0), 'open/bad-underlying');
    require(_underlying != _collateral, 'open/self-collateral');
    require(IBetaConfig(config).getCollFactor(_collateral) > 0, 'open/bad-collateral');
    require(IBetaOracle(oracle).getAssetETHPrice(_collateral) > 0, 'open/no-price');
    pid = nextPositionIds[_owner]++;
    Position storage pos = positions[_owner][pid];
    pos.bToken = bToken;
    pos.collateral = _collateral;
    emit Open(_owner, pid, bToken, _collateral);
  }

  function borrow(
    address _owner,
    uint _pid,
    uint _amount
  ) external override lock whenNotPaused isPermittedByOwner(_owner) checkPID(_owner, _pid) {
    Position memory pos = positions[_owner][_pid];
    require(pos.blockRepayTake != uint32(block.number), 'borrow/bad-block');
    uint share = BToken(pos.bToken).borrow(msg.sender, _amount);
    pos.debtShare += share;
    positions[_owner][_pid].debtShare = pos.debtShare;
    positions[_owner][_pid].blockBorrowPut = uint32(block.number);
    uint ltv = _fetchPositionLTV(pos);
    require(ltv <= IBetaConfig(config).getSafetyLTV(underlyings[pos.bToken]), 'borrow/not-safe');
    emit Borrow(_owner, _pid, _amount, share, msg.sender);
  }

  function repay(
    address _owner,
    uint _pid,
    uint _amount
  ) external override lock whenNotPaused isPermittedByOwner(_owner) checkPID(_owner, _pid) {
    Position memory pos = positions[_owner][_pid];
    require(pos.blockBorrowPut != uint32(block.number), 'repay/bad-block');
    uint share = BToken(pos.bToken).repay(msg.sender, _amount);
    pos.debtShare -= share;
    positions[_owner][_pid].debtShare = pos.debtShare;
    positions[_owner][_pid].blockRepayTake = uint32(block.number);
    emit Repay(_owner, _pid, _amount, share, msg.sender);
  }

  function put(
    address _owner,
    uint _pid,
    uint _amount
  ) external override lock whenNotPaused isPermittedByOwner(_owner) checkPID(_owner, _pid) {
    Position memory pos = positions[_owner][_pid];
    require(pos.blockRepayTake != uint32(block.number), 'put/bad-block');
    uint amount;
    {
      uint balBefore = IERC20(pos.collateral).balanceOf(address(this));
      IERC20(pos.collateral).safeTransferFrom(msg.sender, address(this), _amount);
      uint balAfter = IERC20(pos.collateral).balanceOf(address(this));
      amount = balAfter - balBefore;
    }
    pos.collateralSize += amount;
    totalCollaterals[pos.collateral] += amount;
    require(
      totalCollaterals[pos.collateral] <= IBetaConfig(config).getCollMaxAmount(pos.collateral),
      'put/too-much-collateral'
    );
    positions[_owner][_pid].collateralSize = pos.collateralSize;
    positions[_owner][_pid].blockBorrowPut = uint32(block.number);
    emit Put(_owner, _pid, _amount, msg.sender);
  }

  function take(
    address _owner,
    uint _pid,
    uint _amount
  ) external override lock whenNotPaused isPermittedByOwner(_owner) checkPID(_owner, _pid) {
    Position memory pos = positions[_owner][_pid];
    require(pos.blockBorrowPut != uint32(block.number), 'take/bad-block');
    pos.collateralSize -= _amount;
    totalCollaterals[pos.collateral] -= _amount;
    positions[_owner][_pid].collateralSize = pos.collateralSize;
    positions[_owner][_pid].blockRepayTake = uint32(block.number);
    uint ltv = _fetchPositionLTV(pos);
    require(ltv <= IBetaConfig(config).getSafetyLTV(underlyings[pos.bToken]), 'take/not-safe');
    IERC20(pos.collateral).safeTransfer(msg.sender, _amount);
    emit Take(_owner, _pid, _amount, msg.sender);
  }

  function liquidate(
    address _owner,
    uint _pid,
    uint _amount
  ) external override lock whenNotPaused checkPID(_owner, _pid) {
    Position memory pos = positions[_owner][_pid];
    address underlying = underlyings[pos.bToken];
    uint ltv = _fetchPositionLTV(pos);
    require(ltv >= IBetaConfig(config).getLiquidationLTV(underlying), 'liquidate/not-liquidatable');
    uint debtShare = BToken(pos.bToken).repay(msg.sender, _amount);
    require(debtShare <= (pos.debtShare + 1) / 2, 'liquidate/too-much-liquidation');
    uint debtValue = BToken(pos.bToken).fetchDebtShareValue(debtShare);
    uint collValue = IBetaOracle(oracle).convert(underlying, pos.collateral, debtValue);
    uint payout = Math.min(
      collValue + (collValue * IBetaConfig(config).getKillBountyRate(underlying)) / 1e18,
      pos.collateralSize
    );
    pos.debtShare -= debtShare;
    positions[_owner][_pid].debtShare = pos.debtShare;
    pos.collateralSize -= payout;
    positions[_owner][_pid].collateralSize = pos.collateralSize;
    totalCollaterals[pos.collateral] -= payout;
    IERC20(pos.collateral).safeTransfer(msg.sender, payout);
    emit Liquidate(_owner, _pid, _amount, debtShare, payout, msg.sender);
  }

  function selflessLiquidate(
    address _owner,
    uint _pid,
    uint _amount
  ) external onlyGov lock checkPID(_owner, _pid) {
    Position memory pos = positions[_owner][_pid];
    require(pos.collateralSize == 0, 'selflessLiquidate/positive-collateral');
    uint debtValue = BToken(pos.bToken).fetchDebtShareValue(pos.debtShare);
    _amount = Math.min(_amount, debtValue);
    uint debtShare = BToken(pos.bToken).repay(msg.sender, _amount);
    pos.debtShare -= debtShare;
    positions[_owner][_pid].debtShare = pos.debtShare;
    emit SelflessLiquidate(_owner, _pid, _amount, debtShare, msg.sender);
  }

  function recover(
    address _bToken,
    address _token,
    uint _amount
  ) external onlyGov lock {
    require(underlyings[_bToken] != address(0), 'recover/not-bToken');
    BToken(_bToken).recover(_token, msg.sender, _amount);
  }

  function _fetchPositionLTV(Position memory pos) internal returns (uint) {
    if (pos.debtShare == 0) {
      return 0; // no debt means zero LTV
    }

    address oracle_ = oracle; // gas saving
    uint collFactor = IBetaConfig(config).getCollFactor(pos.collateral);
    require(collFactor > 0, 'fetch/bad-collateral');
    uint debtSize = BToken(pos.bToken).fetchDebtShareValue(pos.debtShare);
    uint debtValue = IBetaOracle(oracle_).getAssetETHValue(underlyings[pos.bToken], debtSize);
    uint collCred = (pos.collateralSize * collFactor) / 1e18;
    uint collValue = IBetaOracle(oracle_).getAssetETHValue(pos.collateral, collCred);

    if (debtValue >= collValue) {
      return 1e18; // 100% LTV is very very bad and must always be liquidatable and unsafe
    }
    return (debtValue * 1e18) / collValue;
  }
}