



pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;

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

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
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

    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}


pragma solidity >=0.6.2 <0.8.0;

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


pragma solidity >=0.6.0 <0.8.0;

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

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


pragma solidity >=0.6.0 <0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}


pragma solidity 0.6.12;

interface PowerIndexNaiveRouterInterface {
  function migrateToNewRouter(
    address _piToken,
    address payable _newRouter,
    address[] memory _tokens
  ) external;

  function enableRouterCallback(address _piToken, bool _enable) external;

  function piTokenCallback(address sender, uint256 _withdrawAmount) external payable;
}


pragma solidity 0.6.12;

interface PowerIndexRouterInterface {
  enum StakeStatus {
    EQUILIBRIUM,
    EXCESS,
    SHORTAGE
  }


  function setReserveConfig(
    uint256 _reserveRatio,
    uint256 _reserveRatioLowerBound,
    uint256 _reserveRatioUpperBound,
    uint256 _claimRewardsInterval
  ) external;

  function getPiEquivalentForUnderlying(uint256 _underlyingAmount, uint256 _piTotalSupply)
    external
    view
    returns (uint256);

  function getPiEquivalentForUnderlyingPure(
    uint256 _underlyingAmount,
    uint256 _totalUnderlyingWrapped,
    uint256 _piTotalSupply
  ) external pure returns (uint256);

  function getUnderlyingEquivalentForPi(uint256 _piAmount, uint256 _piTotalSupply) external view returns (uint256);

  function getUnderlyingEquivalentForPiPure(
    uint256 _piAmount,
    uint256 _totalUnderlyingWrapped,
    uint256 _piTotalSupply
  ) external pure returns (uint256);
}


pragma solidity >=0.6.0 <0.8.0;

interface IERC20Permit is IERC20 {
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


pragma solidity 0.6.12;

interface WrappedPiErc20Interface is IERC20Permit {
  function deposit(uint256 _amount) external payable returns (uint256);

  function withdraw(uint256 _amount) external payable returns (uint256);

  function withdrawShares(uint256 _burnAmount) external payable returns (uint256);

  function changeRouter(address _newRouter) external;

  function enableRouterCallback(bool _enable) external;

  function setNoFee(address _for, bool _noFee) external;

  function setEthFee(uint256 _newEthFee) external;

  function withdrawEthFee(address payable receiver) external;

  function approveUnderlying(address _to, uint256 _amount) external;

  function getPiEquivalentForUnderlying(uint256 _underlyingAmount) external view returns (uint256);

  function getUnderlyingEquivalentForPi(uint256 _piAmount) external view returns (uint256);

  function balanceOfUnderlying(address account) external view returns (uint256);

  function callExternal(
    address voting,
    bytes4 signature,
    bytes calldata args,
    uint256 value
  ) external payable returns (bytes memory);

  struct ExternalCallData {
    address destination;
    bytes4 signature;
    bytes args;
    uint256 value;
  }

  function callExternalMultiple(ExternalCallData[] calldata calls) external payable returns (bytes[] memory);

  function getUnderlyingBalance() external view returns (uint256);
}



pragma solidity 0.6.12;

contract WrappedPiErc20 is ERC20, ReentrancyGuard, WrappedPiErc20Interface {
  using SafeMath for uint256;
  using SafeERC20 for IERC20Permit;

  bytes32 public constant PERMIT_TYPEHASH =
    keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
  bytes public constant EIP712_REVISION = bytes("1");
  bytes32 internal constant EIP712_DOMAIN =
    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

  IERC20Permit public immutable underlying;
  bytes32 public immutable override DOMAIN_SEPARATOR;
  address public router;
  bool public routerCallbackEnabled;
  uint256 public ethFee;
  mapping(address => bool) public noFeeWhitelist;
  mapping(address => uint256) public override nonces;

  event Deposit(address indexed account, uint256 undelyingDeposited, uint256 piMinted);
  event Withdraw(address indexed account, uint256 underlyingWithdrawn, uint256 piBurned);
  event Approve(address indexed to, uint256 amount);
  event ChangeRouter(address indexed newRouter);
  event EnableRouterCallback(bool indexed enabled);
  event SetEthFee(uint256 newEthFee);
  event SetNoFee(address indexed addr, bool noFee);
  event WithdrawEthFee(uint256 value);
  event CallExternal(address indexed destination, bytes4 indexed inputSig, bytes inputData, bytes outputData);

  modifier onlyRouter() {
    require(router == msg.sender, "ONLY_ROUTER");
    _;
  }

  constructor(
    address _token,
    address _router,
    string memory _name,
    string memory _symbol
  ) public ERC20(_name, _symbol) {
    underlying = IERC20Permit(_token);
    router = _router;

    uint256 chainId;

    assembly {
      chainId := chainid()
    }

    DOMAIN_SEPARATOR = keccak256(
      abi.encode(EIP712_DOMAIN, keccak256(bytes(_name)), keccak256(EIP712_REVISION), chainId, address(this))
    );
  }

  function depositWithPermit(
    uint256 _amount,
    uint256 _deadline,
    uint8 _v,
    bytes32 _r,
    bytes32 _s
  ) public virtual {
    underlying.permit(msg.sender, address(this), _amount, _deadline, _v, _r, _s);
    deposit(_amount);
  }

  function deposit(uint256 _depositAmount) public payable override nonReentrant returns (uint256) {
    if (noFeeWhitelist[msg.sender]) {
      require(msg.value == 0, "NO_FEE_FOR_WL");
    } else {
      require(msg.value >= ethFee, "FEE");
    }

    require(_depositAmount > 0, "ZERO_DEPOSIT");

    uint256 mintAmount = getPiEquivalentForUnderlying(_depositAmount);
    require(mintAmount > 0, "ZERO_PI_FOR_MINT");

    underlying.safeTransferFrom(msg.sender, address(this), _depositAmount);
    _mint(msg.sender, mintAmount);

    emit Deposit(msg.sender, _depositAmount, mintAmount);

    if (routerCallbackEnabled) {
      PowerIndexNaiveRouterInterface(router).piTokenCallback{ value: msg.value }(msg.sender, 0);
    }

    return mintAmount;
  }

  function withdraw(uint256 _withdrawAmount) external payable override nonReentrant returns (uint256) {
    if (noFeeWhitelist[msg.sender]) {
      require(msg.value == 0, "NO_FEE_FOR_WL");
    } else {
      require(msg.value >= ethFee, "FEE");
    }

    require(_withdrawAmount > 0, "ZERO_WITHDRAWAL");

    if (routerCallbackEnabled) {
      PowerIndexNaiveRouterInterface(router).piTokenCallback{ value: msg.value }(msg.sender, _withdrawAmount);
    }

    uint256 burnAmount = getPiEquivalentForUnderlying(_withdrawAmount);
    require(burnAmount > 0, "ZERO_PI_FOR_BURN");

    _burn(msg.sender, burnAmount);
    underlying.safeTransfer(msg.sender, _withdrawAmount);

    emit Withdraw(msg.sender, _withdrawAmount, burnAmount);

    return burnAmount;
  }

  function withdrawShares(uint256 _burnAmount) external payable override nonReentrant returns (uint256) {
    if (noFeeWhitelist[msg.sender]) {
      require(msg.value == 0, "NO_FEE_FOR_WL");
    } else {
      require(msg.value >= ethFee, "FEE");
    }

    require(_burnAmount > 0, "ZERO_WITHDRAWAL");

    uint256 withdrawAmount = getUnderlyingEquivalentForPi(_burnAmount);
    require(withdrawAmount > 0, "ZERO_UNDERLYING_TO_WITHDRAW");

    if (routerCallbackEnabled) {
      PowerIndexNaiveRouterInterface(router).piTokenCallback{ value: msg.value }(msg.sender, withdrawAmount);
    }

    _burn(msg.sender, _burnAmount);
    underlying.safeTransfer(msg.sender, withdrawAmount);

    emit Withdraw(msg.sender, withdrawAmount, _burnAmount);

    return withdrawAmount;
  }

  function getPiEquivalentForUnderlying(uint256 _underlyingAmount) public view override returns (uint256) {
    return PowerIndexRouterInterface(router).getPiEquivalentForUnderlying(_underlyingAmount, totalSupply());
  }

  function getUnderlyingEquivalentForPi(uint256 _piAmount) public view override returns (uint256) {
    return PowerIndexRouterInterface(router).getUnderlyingEquivalentForPi(_piAmount, totalSupply());
  }

  function balanceOfUnderlying(address account) external view override returns (uint256) {
    return getUnderlyingEquivalentForPi(balanceOf(account));
  }

  function totalSupplyUnderlying() external view returns (uint256) {
    return getUnderlyingEquivalentForPi(totalSupply());
  }

  function changeRouter(address _newRouter) external override onlyRouter {
    router = _newRouter;
    emit ChangeRouter(router);
  }

  function enableRouterCallback(bool _enable) external override onlyRouter {
    routerCallbackEnabled = _enable;
    emit EnableRouterCallback(_enable);
  }

  function setNoFee(address _for, bool _noFee) external override onlyRouter {
    noFeeWhitelist[_for] = _noFee;
    emit SetNoFee(_for, _noFee);
  }

  function setEthFee(uint256 _ethFee) external override onlyRouter {
    ethFee = _ethFee;
    emit SetEthFee(_ethFee);
  }

  function withdrawEthFee(address payable _receiver) external override onlyRouter {
    emit WithdrawEthFee(address(this).balance);
    _receiver.transfer(address(this).balance);
  }

  function approveUnderlying(address _to, uint256 _amount) external override onlyRouter {
    underlying.approve(_to, _amount);
    emit Approve(_to, _amount);
  }

  function callExternal(
    address _destination,
    bytes4 _signature,
    bytes calldata _args,
    uint256 _value
  ) external payable override onlyRouter returns (bytes memory) {
    return _callExternal(_destination, _signature, _args, _value);
  }

  function callExternalMultiple(ExternalCallData[] calldata _calls)
    external
    payable
    override
    onlyRouter
    returns (bytes[] memory results)
  {
    uint256 len = _calls.length;
    results = new bytes[](len);
    for (uint256 i = 0; i < len; i++) {
      results[i] = _callExternal(_calls[i].destination, _calls[i].signature, _calls[i].args, _calls[i].value);
    }
  }

  function getUnderlyingBalance() external view override returns (uint256) {
    return underlying.balanceOf(address(this));
  }

  function permit(
    address owner,
    address spender,
    uint256 value,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external override {
    require(owner != address(0), "INVALID_OWNER");
    require(block.timestamp <= deadline, "INVALID_EXPIRATION");
    uint256 currentValidNonce = nonces[owner];
    bytes32 digest = keccak256(
      abi.encodePacked(
        "\x19\x01",
        DOMAIN_SEPARATOR,
        keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, currentValidNonce, deadline))
      )
    );

    require(owner == ecrecover(digest, v, r, s), "INVALID_SIGNATURE");
    nonces[owner] = currentValidNonce.add(1);
    _approve(owner, spender, value);
  }

  function _callExternal(
    address _destination,
    bytes4 _signature,
    bytes calldata _args,
    uint256 _value
  ) internal returns (bytes memory) {
    (bool success, bytes memory data) = _destination.call{ value: _value }(abi.encodePacked(_signature, _args));

    if (!success) {
      assembly {
        let output := mload(0x40)
        let size := returndatasize()
        switch size
        case 0 {
          mstore(output, 0x08c379a000000000000000000000000000000000000000000000000000000000) // error identifier
          mstore(add(output, 0x04), 0x0000000000000000000000000000000000000000000000000000000000000020) // offset
          mstore(add(output, 0x24), 0x000000000000000000000000000000000000000000000000000000000000001e) // length
          mstore(add(output, 0x44), 0x52455645525445445f574954485f4e4f5f524541534f4e5f535452494e470000) // reason
          revert(output, 100) // 100 = 4 + 3 * 32 (error identifier + 3 words for the ABI encoded error)
        }
        default {
          revert(add(data, 32), size)
        }
      }
    }

    emit CallExternal(_destination, _signature, _args, data);

    return data;
  }
}