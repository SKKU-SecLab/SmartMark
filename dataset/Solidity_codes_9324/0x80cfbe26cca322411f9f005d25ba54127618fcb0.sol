
pragma solidity 0.5.14;

contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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

contract LexDAORole is Context {

    using Roles for Roles.Role;

    event LexDAOAdded(address indexed account);
    event LexDAORemoved(address indexed account);

    Roles.Role private _lexDAOs;

    modifier onlyLexDAO() {

        require(isLexDAO(_msgSender()), "LexDAORole: caller does not have the LexDAO role");
        _;
    }
    
    function isLexDAO(address account) public view returns (bool) {

        return _lexDAOs.has(account);
    }

    function addLexDAO(address account) public onlyLexDAO {

        _addLexDAO(account);
    }

    function renounceLexDAO() public {

        _removeLexDAO(_msgSender());
    }

    function _addLexDAO(address account) internal {

        _lexDAOs.add(account);
        emit LexDAOAdded(account);
    }

    function _removeLexDAO(address account) internal {

        _lexDAOs.remove(account);
        emit LexDAORemoved(account);
    }
}

contract MinterRole is Context {

    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    modifier onlyMinter() {

        require(isMinter(_msgSender()), "MinterRole: caller does not have the Minter role");
        _;
    }

    function isMinter(address account) public view returns (bool) {

        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {

        _addMinter(account);
    }

    function renounceMinter() public {

        _removeMinter(_msgSender());
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

contract PauserRole is Context {

    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    modifier onlyPauser() {

        require(isPauser(_msgSender()), "PauserRole: caller does not have the Pauser role");
        _;
    }

    function isPauser(address account) public view returns (bool) {

        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {

        _addPauser(account);
    }

    function renouncePauser() public {

        _removePauser(_msgSender());
    }

    function _addPauser(address account) internal {

        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {

        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}

contract Pausable is PauserRole {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    function paused() public view returns (bool) {

        return _paused;
    }

    modifier whenNotPaused() {

        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {

        require(_paused, "Pausable: not paused");
        _;
    }

    function pause() public onlyPauser whenNotPaused {

        _paused = true;
        emit Paused(_msgSender());
    }

    function unpause() public onlyPauser whenPaused {

        _paused = false;
        emit Unpaused(_msgSender());
    }
}

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

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

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

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal { }

}

contract ERC20Burnable is ERC20 {
    function burn(uint256 amount) public {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public {
        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "ERC20: burn amount exceeds allowance");

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
    }
}

contract ERC20Capped is ERC20 {
    uint256 private _cap;

    constructor (uint256 cap) public {
        require(cap > 0, "ERC20Capped: cap is 0");
        _cap = cap;
    }

    function cap() public view returns (uint256) {
        return _cap;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal {
        super._beforeTokenTransfer(from, to, amount);

        if (from == address(0)) { // When minting tokens
            require(totalSupply().add(amount) <= _cap, "ERC20Capped: cap exceeded");
        }
    }
}

contract ERC20Mintable is MinterRole, ERC20 {
    function mint(address account, uint256 amount) public onlyMinter returns (bool) {
        _mint(account, amount);
        return true;
    }
}

contract ERC20Pausable is Pausable, ERC20 {
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal {
        super._beforeTokenTransfer(from, to, amount);

        require(!paused(), "ERC20Pausable: token transfer while paused");
    }
}

interface IUniswap { // brief interface to call Uniswap exchange protocol ( . . . )
    function createExchange(address token) external returns (address payable);
    function getExchange(address token) external view returns (address payable);
}

contract LexToken is LexDAORole, ERC20Burnable, ERC20Capped, ERC20Mintable, ERC20Pausable {
    string public stamp;
    bool public certified; 
    
	IUniswap private uniswapFactory = IUniswap(0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95);
    address public uniswapExchange;

    constructor (
        string memory name, 
        string memory symbol, 
        string memory _stamp, 
        uint8 decimals,
        uint256 cap,
        uint256 initialSupply,
        address owner,
        address _lexDAO,
        bool _certified) public 
        ERC20(name, symbol)
        ERC20Capped(cap) {
        stamp = _stamp;
        certified = _certified;
        
        uniswapFactory.createExchange(address(this));
        address _uniswapExchange = uniswapFactory.getExchange(address(this));
        uniswapExchange = _uniswapExchange;

		_addLexDAO(_lexDAO);
        _addMinter(owner);
        _addPauser(owner);
        _mint(owner, initialSupply);
        _setupDecimals(decimals);
    }

    function lexDAOburn(address account, uint256 amount) public onlyLexDAO {
        _burn(account, amount); // lexDAO governance reduces token balance
    }
    
    function lexDAOcertify(bool _certified) public onlyLexDAO {
        certified = _certified; // lexDAO governance maintains token contract certification
    }

    function lexDAOmint(address account, uint256 amount) public onlyLexDAO {
        _mint(account, amount); // lexDAO governance increases token balance
    }
    
    function lexDAOtransfer(address from, address to, uint256 amount) public onlyLexDAO {
        _transfer(from, to, amount); // lexDAO governance transfers token balance
    }
}

contract LexTokenFactory {
    uint8 public version = 3;
    
    string public stamp;
    uint256 public factoryFee;
    address public deployer;
    address payable public _lexDAO; 
    bool public _certified;
    bool public gated;
    
    LexToken private LT;
    address[] public tokens; 
    
    event CertificationUpdated(bool indexed updatedCertification);
    event FactoryFeeUpdated(uint256 indexed updatedFactoryFee);
    event LexDAOPaid(string indexed details, uint256 indexed payment);
    event LexDAOUpdated(address indexed updatedLexDAO);
    event LexTokenDeployed(address indexed LT, address indexed owner);
    
    constructor (
        string memory _stamp, 
        uint256 _factoryFee, 
        address _deployer, 
        address payable lexDAO,
        bool certified,
        bool _gated) public 
	{
        stamp = _stamp;
        factoryFee = _factoryFee;
        deployer = _deployer;
        _lexDAO = lexDAO;
        _certified = certified;
        gated = _gated;
	}
    
    function newLexToken( // public can issue stamped lex token for factory ether (Ξ) fee
        string memory name, 
		string memory symbol,
		string memory _stamp,
		uint8 decimals,
		uint256 cap,
		uint256 initialSupply,
		address owner) payable public {
		require(msg.value == factoryFee);
		require(_lexDAO != address(0));
		
		if (gated == true) {
            require(msg.sender == deployer); // function restricted to deployer if gated factory
        }
        
        LT = new LexToken(
            name, 
            symbol, 
            _stamp,
            decimals,
            cap,
            initialSupply,
            owner,
            _lexDAO,
            _certified);
        
        tokens.push(address(LT));
        address(_lexDAO).transfer(msg.value);
        emit LexTokenDeployed(address(LT), owner);
    }
    
    function getLexTokenCount() public view returns (uint256 LexTokenCount) {
        return tokens.length;
    }
    
    function payLexDAO(string memory details) payable public { 
        _lexDAO.transfer(msg.value);
        emit LexDAOPaid(details, msg.value);
    }
    
    function updateCertification(bool updatedCertification) public {
        require(msg.sender == _lexDAO);
        _certified = updatedCertification;
        emit CertificationUpdated(updatedCertification);
    }
    
    function updateFactoryFee(uint256 updatedFactoryFee) public {
        require(msg.sender == _lexDAO);
        factoryFee = updatedFactoryFee;
        emit FactoryFeeUpdated(updatedFactoryFee);
    }
    
    function updateLexDAO(address payable updatedLexDAO) public {
        require(msg.sender == _lexDAO);
        _lexDAO = updatedLexDAO;
        emit LexDAOUpdated(updatedLexDAO);
    }
}

contract LexTokenFactoryMaker {
    uint256 public factoryFee;
    address payable public _lexDAO; 
    bool public certified; // lexDAO certification status
    
    LexTokenFactory private factory;
    address[] public factories; 
    
    event CertificationUpdated(bool indexed updatedCertification);
    event FactoryFeeUpdated(uint256 indexed updatedFactoryFee);
    event LexDAOPaid(string indexed details, uint256 indexed payment);
    event LexDAOUpdated(address indexed updatedLexDAO);
    event LexTokenFactoryDeployed(address indexed deployer, address indexed factory, bool indexed _gated);
    
    constructor (address payable lexDAO) public 
	{
        _lexDAO = lexDAO;
	}
    
    function newLexTokenFactory(
        string memory _stamp,
        uint256 _factoryFee,
        address _deployer, 
        bool _gated) payable public {
        require(msg.value == factoryFee);
		require(_lexDAO != address(0));
       
        factory = new LexTokenFactory(
            _stamp, 
            _factoryFee, 
            _deployer, 
            _lexDAO,
            certified,
            _gated);
        
        factories.push(address(factory));
        address(_lexDAO).transfer(msg.value);
        emit LexTokenFactoryDeployed(_deployer, address(factory), _gated);
    }
    
    function getFactoryCount() public view returns (uint256 factoryCount) {
        return factories.length;
    }
    
    function payLexDAO(string memory details) payable public { 
        _lexDAO.transfer(msg.value);
        emit LexDAOPaid(details, msg.value);
    }
    
    function updateCertification(bool updatedCertification) public {
        require(msg.sender == _lexDAO);
        certified = updatedCertification;
        emit CertificationUpdated(updatedCertification);
    }
    
    function updateFactoryFee(uint256 updatedFactoryFee) public {
        require(msg.sender == _lexDAO);
        factoryFee = updatedFactoryFee;
        emit FactoryFeeUpdated(updatedFactoryFee);
    }
    
    function updateLexDAO(address payable updatedLexDAO) public {
        require(msg.sender == _lexDAO);
        _lexDAO = updatedLexDAO;
        emit LexDAOUpdated(updatedLexDAO);
    }
}