

pragma solidity 0.5.17;

contract Context {

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

    event LexDAOadded(address indexed account);
    event LexDAOremoved(address indexed account);

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
        emit LexDAOadded(account);
    }

    function _removeLexDAO(address account) internal {

        _lexDAOs.remove(account);
        emit LexDAOremoved(account);
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

contract LexToken is LexDAORole, ERC20Burnable, ERC20Capped, ERC20Mintable, ERC20Pausable {
    uint8 public forSale;
    uint8 public lexDAOcertified;  
    uint8 public lexDAOgoverned;
    uint256 public ethPurchaseRate;
    address private lexToken = address(this);
    address payable public owner;
    bytes32 public stamp;
    
    event LexDAOcertify(uint8 indexed _lexDAOcertified, bytes32 indexed details);
    event LexDAOslashStake(bytes32 indexed details);
    event LexDAOtransfer(bytes32 indexed details);
    event RedeemLexToken(uint256 indexed amount, address indexed sender, bytes32 indexed details);
    event UpdateLexTokenGovernance(uint8 indexed _lexDAOgoverned, bytes32 indexed details);
    event UpdateLexTokenOwner(address indexed _owner, bytes32 indexed details);
    event UpdateLexTokenPurchaseRate(uint256 indexed _ethPurchaseRate, bytes32 indexed details);
    event UpdateLexTokenSale(uint8 indexed _onSale, uint256 indexed saleAmount, bytes32 indexed details);
    event UpdateLexTokenStamp(bytes32 indexed _stamp);

    constructor (
        string memory name, 
        string memory symbol,  
        uint8 decimals,
        uint8 _forSale,
        uint8 _lexDAOgoverned,
        uint256 cap,
        uint256 _ethPurchaseRate, 
        uint256 initialOwnerAmount, 
        uint256 initialSaleAmount,
        address _lexDAO,
        address payable _owner,
	    bytes32 _stamp) public 
        ERC20(name, symbol)
        ERC20Capped(cap) {
        forSale = _forSale;
        lexDAOgoverned = _lexDAOgoverned;
        ethPurchaseRate = _ethPurchaseRate;
        owner = _owner;
	    stamp = _stamp;

	    _addLexDAO(_lexDAO);
        _addMinter(_owner);
        _addPauser(_owner);
        _mint(_owner, initialOwnerAmount);
        _mint(lexToken, initialSaleAmount);
        _setupDecimals(decimals);
    }
    
    function() external payable { 
        require(forSale == 1, "not for sale");  
        uint256 purchaseAmount = msg.value.mul(ethPurchaseRate);
        _transfer(lexToken, _msgSender(), purchaseAmount);
        (bool success, ) = owner.call.value(msg.value)(""); 
        require(success, "transfer failed");
    }

    function redeemLexToken(uint256 amount, bytes32 details) external { 
        require(amount > 0, "amount insufficient");
        burn(amount);
        emit RedeemLexToken(amount, _msgSender(), details);
    }

    modifier onlyOwner() {
        require(_msgSender() == owner, "not owner");
        _;
    }
    
    function stake() payable external onlyLexDAOgoverned onlyOwner {}
    
    function updateLexTokenGovernance(uint8 _lexDAOgoverned, bytes32 details) external onlyOwner {
        lexDAOgoverned = _lexDAOgoverned; // owner adjusts LexDAO governance 
        emit UpdateLexTokenGovernance(_lexDAOgoverned, details);
    }
    
    function updateLexTokenOwner(address payable _owner, bytes32 details) external onlyOwner {
        owner = _owner; // owner transfers controls
        emit UpdateLexTokenOwner(_owner, details);
    }
    
    function updateLexTokenPurchaseRate(uint256 _ethPurchaseRate, bytes32 details) external onlyOwner {
        ethPurchaseRate = _ethPurchaseRate; // owner adjusts purchase rate
        emit UpdateLexTokenPurchaseRate(_ethPurchaseRate, details);
    }
    
    function updateLexTokenSale(uint8 _forSale, uint256 saleAmount, bytes32 details) external onlyOwner {
        forSale = _forSale; // owner adjusts sale status
        _mint(lexToken, saleAmount);
        emit UpdateLexTokenSale(_forSale, saleAmount, details);
    }
    
    function updateLexTokenStamp(bytes32 _stamp) external onlyOwner {
        stamp = _stamp; // owner adjusts token stamp
        emit UpdateLexTokenStamp(_stamp);
    }

    modifier onlyLexDAOgoverned() {
        require(lexDAOgoverned == 1, "lexToken not under LexDAO governance");
        _;
    }

    function lexDAOcertify(uint8 _lexDAOcertified, bytes32 details) external onlyLexDAO {
        lexDAOcertified = _lexDAOcertified; // LexDAO governance adjusts token certification
        emit LexDAOcertify(_lexDAOcertified, details);
    }
    
    function lexDAOslashStake(address payable to, uint256 amount, bytes32 details) external onlyLexDAO onlyLexDAOgoverned {
        (bool success, ) = to.call.value(amount)(""); // LexDAO governance directs slashed stake
        require(success, "transfer failed");
        emit LexDAOslashStake(details);
    }

    function lexDAOstamp(bytes32 _stamp) external onlyLexDAO onlyLexDAOgoverned {
        stamp = _stamp; // LexDAO governance adjusts token stamp
        emit UpdateLexTokenStamp(_stamp);
    }
    
    function lexDAOtransfer(address from, address to, uint256 amount, bytes32 details) external onlyLexDAO onlyLexDAOgoverned {
        _transfer(from, to, amount); // LexDAO governance transfers token balance
        emit LexDAOtransfer(details);
    }
}

contract LexTokenFactory is Context {
    uint256 public factoryFee;
    address payable public _lexDAO; 
    bytes32 public stamp;
    
    LexToken private LT;
    address[] public tokens; 
    
    event NewLexToken(uint8 indexed _lexDAOgoverned, address indexed LT, address indexed owner);
    event PayLexDAO(uint256 indexed payment, address indexed sender, bytes32 indexed details);
    event UpdateFactoryFee(uint256 indexed _factoryFee);
    event UpdateFactoryStamp(bytes32 indexed _stamp);
    event UpdateLexDAO(address indexed lexDAO);
    
    constructor (
        uint256 _factoryFee, 
        address payable lexDAO,
	    bytes32 _stamp) public 
    {
        factoryFee = _factoryFee;
        _lexDAO = lexDAO;
	    stamp = _stamp;
    }
    
    function newLexToken( // public issues stamped lexToken for factory ether (Ξ) fee
        string memory name, 
	    string memory symbol,
	    uint8 decimals,
	    uint8 _forSale,
	    uint8 _lexDAOgoverned,
	    uint256 cap,
	    uint256 _ethPurchaseRate,
	    uint256 initialOwnerAmount,
	    uint256 initialSaleAmount,
	    address payable _owner,
	    bytes32 _stamp) payable public {
	    require(msg.value == factoryFee, "factory fee not attached");

        LT = new LexToken(
            name, 
            symbol, 
            decimals,
            _forSale,
            _lexDAOgoverned,
            cap,
            _ethPurchaseRate,
            initialOwnerAmount,
            initialSaleAmount,
            _lexDAO,
            _owner,
	        _stamp);
        
        tokens.push(address(LT));
        (bool success, ) = _lexDAO.call.value(msg.value)("");
        require(success, "transfer failed");
        emit NewLexToken(_lexDAOgoverned, address(LT), _owner);
    }
    
    function payLexDAO(bytes32 details) payable external { // public attaches ether (Ξ) with details to LexDAO
        (bool success, ) = _lexDAO.call.value(msg.value)("");
        require(success, "transfer failed");
        emit PayLexDAO(msg.value, _msgSender(), details);
    }
    
    function getLexTokenCount() external view returns (uint256 LexTokenCount) {
        return tokens.length;
    }
    
    modifier onlyLexDAO() {
        require(_msgSender() == _lexDAO, "caller not LexDAO");
        _;
    }

    function updateFactoryFee(uint256 _factoryFee) external onlyLexDAO {
        factoryFee = _factoryFee;
        emit UpdateFactoryFee(_factoryFee);
    }
    
    function updateFactoryStamp(bytes32 _stamp) external onlyLexDAO {
        stamp = _stamp;
        emit UpdateFactoryStamp(_stamp);
    }
    
    function updateLexDAO(address payable lexDAO) external onlyLexDAO {
        _lexDAO = lexDAO;
        emit UpdateLexDAO(lexDAO);
    }
}