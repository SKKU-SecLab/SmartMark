

pragma solidity ^0.6.0;

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


pragma solidity ^0.6.0;

contract Context {

    constructor () internal { }

    function _msgSender() internal view virtual returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.6.0;

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


pragma solidity ^0.6.2;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}


pragma solidity ^0.6.0;





contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
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


pragma solidity ^0.6.0;

interface IERC777Recipient {
    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external;
}


pragma solidity ^0.6.0;

interface IERC777 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function granularity() external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function send(address recipient, uint256 amount, bytes calldata data) external;

    function burn(uint256 amount, bytes calldata data) external;

    function isOperatorFor(address operator, address tokenHolder) external view returns (bool);

    function authorizeOperator(address operator) external;

    function revokeOperator(address operator) external;

    function defaultOperators() external view returns (address[] memory);

    function operatorSend(
        address sender,
        address recipient,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;

    function operatorBurn(
        address account,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;

    event Sent(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 amount,
        bytes data,
        bytes operatorData
    );

    event Minted(address indexed operator, address indexed to, uint256 amount, bytes data, bytes operatorData);

    event Burned(address indexed operator, address indexed from, uint256 amount, bytes data, bytes operatorData);

    event AuthorizedOperator(address indexed operator, address indexed tokenHolder);

    event RevokedOperator(address indexed operator, address indexed tokenHolder);
}


pragma solidity ^0.6.0;

interface IERC1820Registry {
    function setManager(address account, address newManager) external;

    function getManager(address account) external view returns (address);

    function setInterfaceImplementer(address account, bytes32 interfaceHash, address implementer) external;

    function getInterfaceImplementer(address account, bytes32 interfaceHash) external view returns (address);

    function interfaceHash(string calldata interfaceName) external pure returns (bytes32);

    function updateERC165Cache(address account, bytes4 interfaceId) external;

    function implementsERC165Interface(address account, bytes4 interfaceId) external view returns (bool);

    function implementsERC165InterfaceNoCache(address account, bytes4 interfaceId) external view returns (bool);

    event InterfaceImplementerSet(address indexed account, bytes32 indexed interfaceHash, address indexed implementer);

    event ManagerChanged(address indexed account, address indexed newManager);
}


pragma solidity >=0.6.2 <0.7.0;




abstract contract Receiver is IERC777Recipient {
  mapping(address => bool) internal canReceive;

  IERC1820Registry constant internal ERC1820_REGISTRY = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

  constructor() internal {
    ERC1820_REGISTRY.setInterfaceImplementer(address(this), keccak256("ERC777TokensRecipient"), address(this));
  }

  function _tokensReceived(IERC777 token, address from, uint256 amount, bytes memory data) internal virtual;

  function tokensReceived(
    address /*operator*/,
    address from,
    address /*to*/,
    uint256 amount,
    bytes calldata userData,
    bytes calldata /*operatorData*/
  ) external override {
    _tokensReceived(IERC777(msg.sender), from, amount, userData);
  }

  function recover(address token) external /*onlyOwner*/ {

    IERC777(token).send(msg.sender, IERC777(token).balanceOf(address(this)), "");
  }
}


pragma solidity ^0.6.0;

interface IERC777Sender {
    function tokensToSend(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external;
}


pragma solidity >=0.6.2 <0.7.0;

contract Granularity {
  uint256 internal _decimals;

  function setDecimals(uint decimals) internal {
    _decimals = decimals;
  }

  function getGranularity() internal view returns (uint256) {
    return 10 ** (18 - _decimals);
  }

  function from777to20(uint amount) internal view returns (uint256) {
    return amount / getGranularity();
  }

  function from20to777(uint amount) internal view returns (uint256) {
    return amount * getGranularity();
  }
}


pragma solidity ^0.6.0;











contract ERC777WithGranularity is Context, IERC777, IERC20, Granularity {
    using SafeMath for uint256;
    using Address for address;

    IERC1820Registry constant internal _ERC1820_REGISTRY = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

    mapping(address => uint256) private _balances;

    uint256 private _totalSupply;

    string internal _name;
    string internal _symbol;


    bytes32 constant private _TOKENS_SENDER_INTERFACE_HASH =
        0x29ddb589b1fb5fc7cf394961c1adf5f8c6454761adf795e67fe149f658abe895;

    bytes32 constant private _TOKENS_RECIPIENT_INTERFACE_HASH =
        0xb281fc8c12954d22544db45de3159a39272895b169a852b314f9cc762e44c53b;

    address[] private _defaultOperatorsArray;

    mapping(address => bool) private _defaultOperators;

    mapping(address => mapping(address => bool)) private _operators;
    mapping(address => mapping(address => bool)) private _revokedDefaultOperators;

    mapping (address => mapping (address => uint256)) private _allowances;

    constructor(
    ) public {


        _ERC1820_REGISTRY.setInterfaceImplementer(address(this), keccak256("ERC777Token"), address(this));
        _ERC1820_REGISTRY.setInterfaceImplementer(address(this), keccak256("ERC20Token"), address(this));
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function granularity() public view override returns (uint256) {
        return getGranularity();
    }

    function totalSupply() public view override(IERC20, IERC777) virtual returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address tokenHolder) public view override(IERC20, IERC777) virtual returns (uint256) {
        return _balances[tokenHolder];
    }

    function send(address recipient, uint256 amount, bytes memory data) public override  {
        _send(_msgSender(), recipient, amount, data, "", true);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(recipient != address(0), "ERC777: transfer to the zero address");

        address from = _msgSender();

        _callTokensToSend(from, from, recipient, amount, "", "");

        _move(from, from, recipient, amount, "", "");

        _callTokensReceived(from, from, recipient, amount, "", "", false);

        return true;
    }

    function burn(uint256 amount, bytes memory data) public override  {
        _burn(_msgSender(), amount, data, "");
    }

    function isOperatorFor(
        address operator,
        address tokenHolder
    ) public view override returns (bool) {
        return operator == tokenHolder ||
            (_defaultOperators[operator] && !_revokedDefaultOperators[tokenHolder][operator]) ||
            _operators[tokenHolder][operator];
    }

    function authorizeOperator(address operator) public override  {
        require(_msgSender() != operator, "ERC777: authorizing self as operator");

        if (_defaultOperators[operator]) {
            delete _revokedDefaultOperators[_msgSender()][operator];
        } else {
            _operators[_msgSender()][operator] = true;
        }

        emit AuthorizedOperator(operator, _msgSender());
    }

    function revokeOperator(address operator) public override  {
        require(operator != _msgSender(), "ERC777: revoking self as operator");

        if (_defaultOperators[operator]) {
            _revokedDefaultOperators[_msgSender()][operator] = true;
        } else {
            delete _operators[_msgSender()][operator];
        }

        emit RevokedOperator(operator, _msgSender());
    }

    function defaultOperators() public view override returns (address[] memory) {
        return _defaultOperatorsArray;
    }

    function operatorSend(
        address sender,
        address recipient,
        uint256 amount,
        bytes memory data,
        bytes memory operatorData
    )
    public override
    {
        require(isOperatorFor(_msgSender(), sender), "ERC777: caller is not an operator for holder");
        _send(sender, recipient, amount, data, operatorData, true);
    }

    function operatorBurn(address account, uint256 amount, bytes memory data, bytes memory operatorData) public override {
        require(isOperatorFor(_msgSender(), account), "ERC777: caller is not an operator for holder");
        _burn(account, amount, data, operatorData);
    }

    function allowance(address holder, address spender) public view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function approve(address spender, uint256 value) public override returns (bool) {
        address holder = _msgSender();
        _approve(holder, spender, value);
        return true;
    }

    function transferFrom(address holder, address recipient, uint256 amount) public override returns (bool) {
        require(recipient != address(0), "ERC777: transfer to the zero address");
        require(holder != address(0), "ERC777: transfer from the zero address");

        address spender = _msgSender();

        _callTokensToSend(spender, holder, recipient, amount, "", "");

        _move(spender, holder, recipient, amount, "", "");
        _approve(holder, spender, _allowances[holder][spender].sub(amount, "ERC777: transfer amount exceeds allowance"));

        _callTokensReceived(spender, holder, recipient, amount, "", "", false);

        return true;
    }

    function _mint(
        address account,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    )
    internal virtual
    {
        require(account != address(0), "ERC777: mint to the zero address");
        require(amount % getGranularity() == 0, "ERC777: Invalid granularity");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);

        _callTokensReceived(operator, address(0), account, amount, userData, operatorData, true);

        emit Minted(operator, account, amount, userData, operatorData);
        emit Transfer(address(0), account, amount);
    }

    function _send(
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData,
        bool requireReceptionAck
    )
        internal
    {
        require(from != address(0), "ERC777: send from the zero address");
        require(to != address(0), "ERC777: send to the zero address");

        address operator = _msgSender();

        _callTokensToSend(operator, from, to, amount, userData, operatorData);

        _move(operator, from, to, amount, userData, operatorData);

        _callTokensReceived(operator, from, to, amount, userData, operatorData, requireReceptionAck);
    }

    function _burn(
        address from,
        uint256 amount,
        bytes memory data,
        bytes memory operatorData
    )
        internal virtual
    {
        require(from != address(0), "ERC777: burn from the zero address");
        require(amount % getGranularity() == 0, "ERC777: Invalid granularity");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), amount);

        _callTokensToSend(operator, from, address(0), amount, data, operatorData);

        _balances[from] = _balances[from].sub(amount, "ERC777: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);

        emit Burned(operator, from, amount, data, operatorData);
        emit Transfer(from, address(0), amount);
    }

    function _move(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    )
        private
    {
        require(amount % getGranularity() == 0, "ERC777: Invalid granularity");
        _beforeTokenTransfer(operator, from, to, amount);

        _balances[from] = _balances[from].sub(amount, "ERC777: transfer amount exceeds balance");
        _balances[to] = _balances[to].add(amount);

        emit Sent(operator, from, to, amount, userData, operatorData);
        emit Transfer(from, to, amount);
    }

    function _approve(address holder, address spender, uint256 value) internal {
        require(spender != address(0), "ERC777: approve to the zero address");

        _allowances[holder][spender] = value;
        emit Approval(holder, spender, value);
    }

    function _callTokensToSend(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    )
        private
    {
        address implementer = _ERC1820_REGISTRY.getInterfaceImplementer(from, _TOKENS_SENDER_INTERFACE_HASH);
        if (implementer != address(0)) {
            IERC777Sender(implementer).tokensToSend(operator, from, to, amount, userData, operatorData);
        }
    }

    function _callTokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData,
        bool requireReceptionAck
    )
        private
    {
        address implementer = _ERC1820_REGISTRY.getInterfaceImplementer(to, _TOKENS_RECIPIENT_INTERFACE_HASH);
        if (implementer != address(0)) {
            IERC777Recipient(implementer).tokensReceived(operator, from, to, amount, userData, operatorData);
        } else if (requireReceptionAck) {
            require(!to.isContract(), "ERC777: token recipient contract has no implementer for ERC777TokensRecipient");
        }
    }

    function _beforeTokenTransfer(address operator, address from, address to, uint256 tokenId) internal virtual { }
}


pragma solidity >=0.6.2 <0.7.0;



interface IWrapped777 is IERC777 {
  function factory() external view returns (address);

  function token() external view returns (ERC20);

  function wrap(uint256 amount) external returns (uint256);
}


pragma solidity >=0.6.2 <0.7.0;







contract Wrapped777 is ERC777WithGranularity, Receiver, IWrapped777 {
  using SafeMath for uint256;

  ERC20 public override token;
  address public override factory;

  event FlashLoan(address indexed target, uint256 amount);

  mapping(address => uint256) private borrows;

  bytes32 public DOMAIN_SEPARATOR;
  bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
  mapping(address => uint) public nonces;

  constructor(ERC20 _token, string memory name, string memory symbol)
    public
    ERC777WithGranularity()
  {
    token = _token;
    factory = msg.sender;
    canReceive[address(this)] = true;

    if (bytes(name).length == 0) {
      _name = string(abi.encodePacked(token.name(), "-777"));
    } else {
      _name = name;
    }

    if (bytes(symbol).length == 0) {
      _symbol = string(abi.encodePacked(token.symbol(), "777"));
    } else {
      _symbol = symbol;
    }

    setDecimals(_token.decimals());

    DOMAIN_SEPARATOR = keccak256(
      abi.encode(
        keccak256('EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'),
        keccak256(bytes(_name)),
        keccak256(bytes('1')),
        chainId(),
        address(this)
      )
    );
  }

  function totalSupply() public view override(ERC777WithGranularity, IERC777) returns (uint256) {
    return ERC777WithGranularity.totalSupply();
  }

  function balanceOf(address tokenHolder) public view override(ERC777WithGranularity, IERC777) returns (uint256) {
    return ERC777WithGranularity.balanceOf(tokenHolder);
  }

  function wrap(uint256 amount) external override returns (uint256) {
    address sender = _msgSender();
    token.transferFrom(sender, address(this), amount);

    uint256 adjustedAmount = from20to777(amount);
    _mint(sender, adjustedAmount, "", "");
    return adjustedAmount;
  }

  function _tokensReceived(IERC777 /*_token*/, address from, uint256 amount, bytes memory data) internal override {
    _burn(address(this), amount, "", "");
    if (keccak256(data) == keccak256(bytes('flreturn'))) {
      borrows[from] = borrows[from].sub(amount);
      return;
    }

    uint256 adjustedAmount = from777to20(amount);
    token.transfer(from, adjustedAmount);
  }



  function flashLoan(address target, uint256 amount, bytes calldata data) external {
    borrows[target] = borrows[target].add(amount);
    _mint(target, amount, data, '');

    require(borrows[target] == 0, 'Flash loan was not returned');

    emit FlashLoan(target, amount);
  }

  function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external {
    require(deadline >= block.timestamp, 'Permit: EXPIRED');
    bytes32 digest = keccak256(
      abi.encodePacked(
        '\x19\x01',
        DOMAIN_SEPARATOR,
        keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline))
      )
    );
    address recoveredAddress = ecrecover(digest, v, r, s);
    require(recoveredAddress != address(0) && recoveredAddress == owner, 'Permit: INVALID_SIGNATURE');
    _approve(owner, spender, value);
  }

  function chainId() private pure returns (uint _chainId) {
    assembly {
      _chainId := chainid()
    }
  }
}


pragma solidity >=0.6.2;


interface IUniswapV2Router01 /*is IUniswapV2Library*/ {
    function WETH() external pure returns (address);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
}


pragma solidity >=0.6.2 <0.7.0;




contract UniswapWrapper is Receiver {
  Wrapped777 public wrapper;
  IUniswapV2Router01 public router;

  bool private wrapping = false;

  constructor(Wrapped777 _wrapper, address _router) public {
    wrapper = _wrapper;
    router = IUniswapV2Router01(_router);
  }

  receive() external payable {
    address[] memory path = new address[](2);
    path[0] = router.WETH();
    path[1] = address(wrapper.token());

    router.swapExactETHForTokens{value: msg.value}(0, path, address(this), now);

    wrapAndReturn(msg.sender);
  }

  function _tokensReceived(IERC777 _token, address from, uint256 amount, bytes memory /*data*/) internal override {
    if (address(_token) == address(wrapper) && wrapping) {
      return;
    }

    Wrapped777 _wrapper = Wrapped777(address(_token));
    _token.send(address(_token), amount, "");
    uint unwrappedBalance = _wrapper.token().balanceOf(address(this));
    _wrapper.token().approve(address(router), unwrappedBalance);

    if (address(_token) == address(wrapper)) {
      address[] memory path = new address[](2);
      path[0] = address(_wrapper.token());
      path[1] = router.WETH();

      router.swapExactTokensForETH(unwrappedBalance, 0, path, from, now);
    } else {
      address[] memory path = new address[](3);
      path[0] = address(_wrapper.token());
      path[1] = router.WETH();
      path[2] = address(wrapper.token());

      router.swapExactTokensForTokens(unwrappedBalance, 0 /*amountOutMin*/, path, address(this), now);

      wrapAndReturn(from);
    }
  }

  function wrapAndReturn(address recipient) private {
    wrapping = true;
    wrapper.token().approve(address(wrapper), wrapper.token().balanceOf(address(this)));
    wrapper.wrap(wrapper.token().balanceOf(address(this)));
    wrapper.transfer(recipient, wrapper.balanceOf(address(this)));
    wrapping = false;
  }
}


pragma solidity >=0.6.2 <0.7.0;




contract UniswapWrapperFactory is Receiver {
  address public uniswapRouter;
  mapping(address => UniswapWrapper) private wrappers;

  constructor(address _uniswapRouter) public {
    uniswapRouter = _uniswapRouter;
  }

  function getWrapper(address token) external view returns (UniswapWrapper) {
    return wrappers[token];
  }

  function createExchange(Wrapped777 token) public {
    UniswapWrapper wrapper = new UniswapWrapper{salt: bytes32(0)}(token, uniswapRouter);
    wrappers[address(token)] = wrapper;
  }

  function _tokensReceived(IERC777, address, uint256, bytes memory) internal override {
    revert('Receiving tokens not allowed');
  }
}