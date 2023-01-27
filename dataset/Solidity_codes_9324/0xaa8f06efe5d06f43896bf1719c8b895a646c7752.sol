
pragma solidity ^0.5.11;

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



contract OpenZeppelinUpgradesOwnable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract UAXCoinOwnable is OpenZeppelinUpgradesOwnable {

    address private _newOwner;

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _newOwner = newOwner;
    }

    function newOwner() public view returns (address) {

        return _newOwner;
    }

    modifier onlyNewOwner() {

        require(msg.sender == _newOwner, "Ownable: caller is not a new owner");
        _;
    }

    function acceptOwnership() public onlyNewOwner {

        super._transferOwnership(_newOwner);
        _newOwner = address(0);
    }
}


contract UAXCoinController is IERC20, UAXCoinOwnable {

    using SafeMath for uint256;

    UAXCoinAccounts private _accounts;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    bool private _useWhiteList;

    bool private _hasFrozenAccounts;

    event AccountFreeze(address account);

    event AccountUnfreeze(address account);

    function initialize() public onlyOwner {

        _name = 'UAX';
        _symbol = 'UAX';
        _decimals = 2;
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

    function setName(string memory newName) public onlyOwner {

        _name = newName;
    }

    function setSymbol(string memory newSymbol) public onlyOwner {

        _symbol = newSymbol;
    }

    function setAccounts(UAXCoinAccounts accounts) public onlyOwner {

        _accounts = accounts;
        _hasFrozenAccounts = accounts.hasFrozen();
    }

    function totalSupply() public view returns (uint256) {

        return _accounts.totalSupply();
    }

    function balanceOf(address account) public view returns (uint256) {

        return _accounts.balanceOf(account);
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _accounts.allowance(owner, spender);
    }

    function isWhitelistedModeActive() public view returns (bool) {

        return _useWhiteList;
    }

    function allowWhitelistedAccountsOnly(bool value) public onlyOwner {

        _useWhiteList = value;
    }

    function freeze(address account) public onlyOwner {

        _accounts.freeze(account);
        _hasFrozenAccounts = true;
        emit AccountFreeze(account);
    }

    function unfreeze(address account) public onlyOwner {

        _accounts.unfreeze(account);
        _hasFrozenAccounts = _accounts.hasFrozen();
        emit AccountUnfreeze(account);
    }

    function addToWhitelist(address account) public onlyOwner {

        _accounts.addToWhitelist(account);
    }

    function removeFromWhiteList(address account) public onlyOwner {

        _accounts.removeFromWhiteList(account);
    }

    function setNonce(address _address, uint256 _nonce) private {

        _accounts.setNonce(_address, _nonce);
    }

    function transfer(address to, uint256 value) public returns(bool) {

        if (_useWhiteList) {
            require(_accounts.bothWhitelisted(msg.sender, to), "Unknown account");
        }
        if (_hasFrozenAccounts) {
            require(!_accounts.anyFrozen(msg.sender, to), "Frozen account");
        }
        
        _transfer(msg.sender, to, value);

        return true;
    }

    function approve(address spender, uint256 value) public returns(bool) {

        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns(bool) {

        if (_useWhiteList) {
            require(_accounts.bothWhitelisted(from, to), "Unknown account");
        }
        if (_hasFrozenAccounts) {
            require(!_accounts.anyFrozen(from, to), "Frozen account");
        }
        uint256 allowanceValue = _accounts.allowance(from, msg.sender);
        allowanceValue = allowanceValue.sub(value);
        _approve(from, msg.sender, allowanceValue);

        _transfer(from, to, value);

        return true;
    }

    function increaseAllowance(address spender, uint256 value) public returns (bool) {

        uint256 allowanceValue = _accounts.allowance(msg.sender, spender);
        allowanceValue = allowanceValue.add(value);
        _approve(msg.sender, spender, allowanceValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 value)  public returns (bool) {

        uint256 allowanceValue = _accounts.allowance(msg.sender, spender);
        allowanceValue = allowanceValue.sub(value);
        _approve(msg.sender, spender, allowanceValue);
        return true;
    }

    function issue(uint256 value) public onlyOwner {

        _accounts.addBalanceAndTotalSupply(msg.sender, value);
        emit Transfer(address(0x0), msg.sender, value);
    }

    function delegatedTransfer(
        address _to,
        uint256 _value,
        uint256 _fee,
        uint256 _nonce,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    )
        public
        returns (bool)
    {

        if (_useWhiteList) {
            require(_accounts.isWhitelisted(_to), "Unknown account");
        }
        if (_hasFrozenAccounts) {
            require(!_accounts.isFrozen(_to), "Frozen account");
        }

        address _from = ecrecover(
            keccak256(
                abi.encodePacked(
                    address(this), msg.sender, _to, _value, _fee, _nonce
                )
            ),
            _v, _r, _s
        );

        if (_useWhiteList) {
            require(_accounts.isWhitelisted(_from), "Unknown account");
        }
        if (_hasFrozenAccounts) {
            require(!_accounts.isFrozen(_from), "Frozen account");
        }
        require(_nonce == nonce(_from), "Invalid nonce");
        require(_fee.add(_value) <= balanceOf(_from), "Invalid balance");
        require(
            _to != address(0),
            "ERC20: delegated transfer to the zero address"
        );

        setNonce(_from, _nonce.add(1));

        _accounts.transferToTwo(_from, _to, msg.sender, _value, _fee);

        emit Transfer(_from, _to, _value);
        emit Transfer(_from, msg.sender, _fee);

        return true;

    }

    function delegatedMultiTransfer(
        address[] memory _to_arr,
        uint256[] memory _value_arr,
        uint256[] memory _fee_arr,
        uint256[] memory _nonce_arr,
        uint8[] memory _v_arr,
        bytes32[] memory _r_arr,
        bytes32[] memory _s_arr
    )
    public
    returns (bool)
    {

        require(
            _to_arr.length == _value_arr.length &&
            _to_arr.length == _fee_arr.length &&
            _to_arr.length == _nonce_arr.length &&
            _to_arr.length == _v_arr.length &&
            _to_arr.length == _r_arr.length &&
            _to_arr.length == _s_arr.length,
            'Incorrect input length'
        );

        for (uint i = 0; i < _to_arr.length; i++) {
            delegatedTransfer(
                _to_arr[i],
                _value_arr[i],
                _fee_arr[i],
                _nonce_arr[i],
                _v_arr[i],
                _r_arr[i],
                _s_arr[i]
            );
        }
    }

    function nonce(address _address) public view returns (uint256) {

        return _accounts.nonce(_address);
    }

    function burn(uint256 value) public onlyOwner {

        _accounts.subBalanceAndTotalSupply(msg.sender, value);
        emit Transfer(msg.sender, address(0x0), value);
    }

    function _transfer(address from, address to, uint256 value) internal {

        require(to != address(0), "ERC20: transfer to the zero address");
        _accounts.transfer(from, to, value);
        emit Transfer(from, to, value);
    }

    function _approve(address owner, address spender, uint256 value) internal {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _accounts.setAllowance(owner, spender, value);
        emit Approval(owner, spender, value);
    }
}


contract UAXCoinAccounts is UAXCoinOwnable {

    using SafeMath for uint256;

    mapping(address => uint256) private _nonces;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    UAXCoinController private _ctrl;

    mapping (address => bool) private _whitelist;
    mapping (address => bool) private _frozen;

    bool private _hasFrozenAccounts;

    uint16 private _frozenCount;

    constructor() public {
    }

    modifier onlyController {

        require(msg.sender == address(_ctrl), "Ownable: not a controller");
        _;
    }

    function transfer(address from, address to, uint256 value ) external onlyController {

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
    }

    function transferToTwo(address from, address to1, address to2, uint256 value1, uint256 value2) external onlyController {

        uint256 value = value1.add(value2);
        _balances[from] = _balances[from].sub(value);
        _balances[to1] = _balances[to1].add(value1);
        _balances[to2] = _balances[to2].add(value2);
    }

    function addBalanceAndTotalSupply(address owner, uint256 value) external onlyController {

        _balances[owner] = _balances[owner].add(value);
        _totalSupply = _totalSupply.add(value);
    }

    function subBalanceAndTotalSupply(address owner, uint256 value) external onlyController {

        _balances[owner] = _balances[owner].sub(value);
        _totalSupply = _totalSupply.sub(value);
    }

    function setAllowance(address owner, address spender, uint256 allowance) external onlyController {

        _allowances[owner][spender] = allowance;
    }

    function addToWhitelist(address account) external onlyController {

        _whitelist[account] = true;
    }

    function removeFromWhiteList(address account) external onlyController {

        _whitelist[account] = false;
    }

    function nonce(address account) external onlyController view returns (uint256) {

        return _nonces[account];
    }

    function setNonce(address account, uint256 _nonce) external onlyController {

        _nonces[account] = _nonce;
    }
    function isFrozen(address account) external view onlyController returns(bool) {

        return _frozen[account];
    }

    function anyFrozen(address account1, address account2) external view onlyController returns(bool) {

        return _frozen[account1] || _frozen[account2];
    }

    function setController(UAXCoinController ctrl) public onlyOwner {

        _ctrl = ctrl;
    }

    function totalSupply() public view onlyController returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view onlyController returns (uint256) {

        return _balances[account];
    }

    function allowance(address owner, address spender) public view onlyController returns (uint256) {

        return _allowances[owner][spender];
    }

    function isWhitelisted(address account) public view onlyController returns(bool) {

        return _whitelist[account];
    }

    function bothWhitelisted(address account1, address account2) public view onlyController returns(bool) {

        return _whitelist[account1] && _whitelist[account2];
    }

    function freeze(address account) public onlyController {

        if (!_frozen[account]) {
            _frozenCount++;
            _frozen[account] = true;
            _hasFrozenAccounts = true;
        }
    }

    function unfreeze(address account) public onlyController {

        if (_frozen[account]) {
            _frozenCount--;
            _frozen[account] = false;
            _hasFrozenAccounts = (_frozenCount > 0);
        }
    }

    function hasFrozen() public view returns(bool) {

        return _hasFrozenAccounts;
    }
}