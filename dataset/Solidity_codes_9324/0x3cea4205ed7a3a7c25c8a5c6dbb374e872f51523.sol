

pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
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

        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


pragma solidity ^0.5.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}


pragma solidity ^0.5.0;




library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


pragma solidity ^0.5.0;

library Roles {

    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {

        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}


pragma solidity ^0.5.0;


contract MinterRole {

    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    constructor () internal {
        _addMinter(msg.sender);
    }

    modifier onlyMinter() {

        require(isMinter(msg.sender), "MinterRole: caller does not have the Minter role");
        _;
    }

    function isMinter(address account) public view returns (bool) {

        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {

        _addMinter(account);
    }

    function renounceMinter() public {

        _removeMinter(msg.sender);
    }

    function _addMinter(address account) internal {

        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {

        _minters.remove(account);
        emit MinterRemoved(account);
    }
}


pragma solidity 0.5.11;

interface IERC20Detailed {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint256);

}


pragma solidity 0.5.11;

interface IERC20MintableBurnable {

    function mint(address account, uint256 amount) external returns (bool);

    function burn(uint256 amount) external;

    function burnFrom(address account, uint256 amount) external;

}


pragma solidity 0.5.11;

interface IExchange {

    event Deposited(address payee, uint256 amount);
    event Withdrawn(address payee, uint256 amount);

    function deposit(uint256 _amount) external returns (bool);

    function depositFrom(address _source, address _destination, uint256 _amount)
        external
        returns (bool);

    function withdraw(uint256 _amount) external returns (bool);

    function withdrawFrom(address _source, address _destination, uint256 _amount)
        external
        returns (bool);

    function token() external view returns (address);

    function wrappedToken() external view returns (address);

    function supply() external view returns (uint256);

}


pragma solidity 0.5.11;


interface IFactory {

    event WrappedTokenCreated(address collateral, address wrappedToken);
    event ExchangeCreated(address collateral, address exchange);

    function create(IERC20 _token) external returns (bool);

    function wrappedTokens(address _token) external view returns (address);

    function exchanges(address _token) external view returns (address);

}


pragma solidity ^0.5.0;

contract ReentrancyGuard {

    uint256 private _guardCounter;

    constructor () internal {
        _guardCounter = 1;
    }

    modifier nonReentrant() {

        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }
}


pragma solidity 0.5.11;







contract WrappedERC20Exchange is IExchange, ReentrancyGuard {

    using SafeERC20 for IERC20;

    event Deposited(address payee, uint amount);
    event Withdrawn(address payee, uint amount);

    IERC20 public token;
    IERC20MintableBurnable public wrappedToken;

    constructor (IERC20 _token, IERC20MintableBurnable _wrappedToken) public {
        token = _token;
        wrappedToken = _wrappedToken;
    }

    function deposit(uint _amount) public nonReentrant returns (bool) {

        require(_amount != 0, "Amount cannot be zero.");
        emit Deposited(msg.sender, _amount);

        token.safeTransferFrom(msg.sender, address(this), _amount);

        wrappedToken.mint(msg.sender, _amount);

        return true;
    }

    function depositFrom(address _source, address _destination, uint _amount) public nonReentrant returns (bool) {

        require(_amount != 0, "Amount cannot be zero.");
        require(_source != address(0), "Source address cannot be a zero address.");
        require(_destination != address(0), "Destination address cannot be a zero address.");

        emit Deposited(_source, _amount);

        token.safeTransferFrom(_source, address(this), _amount);

        wrappedToken.mint(_destination, _amount);

        return true;
    }

    function withdraw(uint _amount) public nonReentrant returns (bool) {

        require(_amount != 0, "Amount cannot be zero.");
        emit Withdrawn(msg.sender, _amount);

        wrappedToken.burnFrom(msg.sender, _amount);

        token.safeTransfer(msg.sender, _amount);

        return true;
    }

    function withdrawFrom(address _source, address _destination, uint _amount) public nonReentrant returns (bool) {

        require(_amount != 0, "Amount cannot be zero.");
        require(_source != address(0), "Source address cannot be a zero address.");
        require(_destination != address(0), "Destination address cannot be a zero address.");

        emit Withdrawn(_source, _amount);

        wrappedToken.burnFrom(_source, _amount);

        token.safeTransfer(_destination, _amount);

        return true;
    }

    function supply() public view returns (uint) {

        return token.balanceOf(address(this));
    }
}


pragma solidity ^0.5.0;



contract ERC20 is IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {

        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public returns (bool) {

        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 value) internal {

        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    function _approve(address owner, address spender, uint256 value) internal {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _burnFrom(address account, uint256 amount) internal {

        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }
}


pragma solidity ^0.5.0;



contract ERC20Mintable is ERC20, MinterRole {

    function mint(address account, uint256 amount) public onlyMinter returns (bool) {

        _mint(account, amount);
        return true;
    }
}


pragma solidity ^0.5.0;


contract ERC20Burnable is ERC20 {

    function burn(uint256 amount) public {

        _burn(msg.sender, amount);
    }

    function burnFrom(address account, uint256 amount) public {

        _burnFrom(account, amount);
    }
}


pragma solidity ^0.5.0;


contract ERC20Detailed is IERC20 {

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
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
}


pragma solidity 0.5.11;







contract WrappedERC20 is IERC20MintableBurnable, ERC20, ERC20Mintable, ERC20Burnable, ERC20Detailed {

    constructor (string memory name, string memory symbol, uint8 decimals) public ERC20Detailed(name, symbol, decimals){}
}


pragma solidity 0.5.11;










contract WrappedERC20Factory is IFactory {

    using SafeERC20 for IERC20;

    event WrappedTokenCreated(address collateral, address wrappedToken);
    event ExchangeCreated(address collateral, address exchange);

    mapping(address => IERC20MintableBurnable) public wrappedTokens; // Mapping of token address -> wrapped token address
    mapping(address => IExchange) public exchanges; // Mapping of token address -> exchange address

    function create(IERC20 _token) public returns (bool) {

        IERC20MintableBurnable wrappedToken = createWrappedToken(_token);
        IExchange exchange = createExchange(_token, wrappedToken);

        MinterRole mintable = MinterRole(address(wrappedToken));
        mintable.addMinter(address(exchange));
        mintable.renounceMinter();

        return true;
    }

    function createWrappedToken(IERC20 _token) internal returns (IERC20MintableBurnable) {

        IERC20Detailed t = IERC20Detailed(address(_token));
        string memory wrappedName = string(abi.encodePacked("Wrapped", " ", t.name()));
        string memory wrappedSymbol = string(abi.encodePacked("W", t.symbol())); // e.g. wPAY
        uint8 wrappedDecimals = uint8(t.decimals()); // Conversion from old ERC20 uint256 decimals to new uint8

        IERC20MintableBurnable wrappedToken = new WrappedERC20(
          wrappedName,
          wrappedSymbol,
          wrappedDecimals
        );
        wrappedTokens[address(_token)] = wrappedToken;
        emit WrappedTokenCreated(address(_token), address(wrappedToken));

        return wrappedToken;
    }

    function createExchange(IERC20 _token, IERC20MintableBurnable _wrappedToken) internal returns (IExchange) {

        IExchange exchange = new WrappedERC20Exchange(
          _token,
          _wrappedToken
        );
        exchanges[address(_token)] = exchange;
        emit ExchangeCreated(address(_token), address(exchange));

        return exchange;
    }
}