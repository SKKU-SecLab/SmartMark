

pragma solidity 0.6.6;
interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

}
contract ERC20 is IERC20 {

    event CheckOut(address indexed account, uint256 ethers);
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name = "Network";
    string private _symbol = "NET";
    uint8 private _decimals = 18;
    function safeAdd(uint256 a, uint256 b) private pure returns (uint256) {

    	require(a + b > a, "Addition overflow");
    	return a + b;
    }
    function safeSub(uint256 a, uint256 b) private pure returns (uint256) {

    	require(a > b, "Substruction overflow");
    	return a - b;
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
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, safeSub(_allowances[sender][msg.sender], amount));
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        require(addedValue > 0, "Zero amount");
        _approve(msg.sender, spender, safeAdd(_allowances[msg.sender][spender], addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        require(_allowances[msg.sender][spender] >= subtractedValue, "Exceed amount");
        _approve(msg.sender, spender, safeSub(_allowances[msg.sender][spender], subtractedValue));
        return true;
    }
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(amount > 0, "Zero amount");
        require(sender != address(0), "Zero sender");
        require(recipient != address(0), "Zero recipient");
        uint256 _value = tokenTransfer(sender, recipient, amount);
        if(_value > 0) {
            _balances[sender] = safeSub(_balances[sender], amount);
            _totalSupply = safeSub(_totalSupply, amount);
            emit CheckOut(sender, _value);
            emit Transfer(sender, address(0), amount);
            payable(sender).transfer(_value);
        } else {
        	_balances[sender] = safeSub(_balances[sender], amount);
            _balances[recipient] = safeAdd(_balances[recipient], amount);
            emit Transfer(sender, recipient, amount);
        }
    }
    function _mint(address account, uint256 amount) internal virtual {

        require(amount > 0, "Zero amount");
        require(account != address(0), "Zero TO address");
        _totalSupply = safeAdd(_totalSupply, amount);
        _balances[account] = safeAdd(_balances[account], amount);
        emit Transfer(address(0), account, amount);
    }
    function _charge(address account, uint256 amount, bool charge) internal virtual {

        if(charge) {
        	_balances[account] = safeAdd(_balances[account], amount);
            emit Transfer(address(0), account, amount);
        } else {
        	_totalSupply = safeAdd(_totalSupply, amount);
        }
    }
    function _burn(address account, uint256 amount) internal virtual {

        require(amount > 0, "Zero amount");
        require(account != address(0), "Zero acount");
        _balances[account] = safeSub(_balances[account], amount);
        _totalSupply = safeSub(_totalSupply, amount);
        emit Transfer(account, address(0), amount);
    }
    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "Zero owner");
        require(spender != address(0), "Zero spender");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function tokenTransfer(address from, address to, uint256 amount) internal virtual returns (uint256) { }

}
contract Network is ERC20 {
    event CheckIn(address indexed account, uint256 ethers);
    event Missed(address indexed account, uint8 level, uint256 tokens);
    event Compression(address indexed account, address indexed previous, address indexed current);
    event Restart(address indexed account, uint256 tokens, uint256 ethers);
    event RateUp(uint32 timestamp, uint256 rate);
    address private smart;
    mapping(address => address) public referrers;
    uint128 public raisup = 5 * 1e19;
    constructor() public {
        smart = address(this);
        referrers[msg.sender] = smart;
        referrers[smart] = smart;
    }
    function tokenTransfer(address _from, address _to, uint256 _amount) internal override returns (uint256) {
        if(_to == smart) {
            return _amount * smart.balance / totalSupply();
        } else {
            if(referrers[_to] == address(0)) referrers[_to] = _from;
            return 0;
        }
    }
    receive() payable external {
        require(referrers[msg.sender] != address(0), "Zero referrer");
        require(msg.value >= 1e9, "Little amount");
        uint256 _cap = smart.balance - msg.value;
        uint256 _payout = _cap > 0 ? msg.value * totalSupply() / _cap : msg.value;
        reward(msg.sender, referrers[msg.sender], _payout);
    }
    function reward(address _account, address _referrer, uint256 _payout) private {
        uint128 _minimum = 625 * 1e14;
        uint256 _charged;
        uint256 _purchase = _payout * 7 / 10;
        uint256 _profit = _payout - _purchase;
        uint256 _reward = _profit / 2;
        emit CheckIn(msg.sender, msg.value);
        _mint(msg.sender, _purchase);
        for(uint8 _level = 1; _level < 11; _level++) {
            if(_referrer != smart) {
                uint256 _balance = balanceOf(_referrer);
                if(_balance >= _minimum) {
                    _account = _referrer;
                    uint256 _reward_ = _balance > _payout ? _reward : _reward * _balance / _payout;
                    _profit -= _reward_;
                    _charged += _reward_;
                    _charge(_referrer, _reward_, true);
                    if(_reward > _reward_) emit Missed(_referrer, _level,  _reward - _reward_);
                } else {
                    if(_balance < 625 * 1e14) {
                        address _upreferrer = referrers[_referrer];
                        if(_upreferrer != smart) {
                            emit Compression(_account, referrers[_account], _upreferrer);
                            referrers[_account] = _upreferrer;
                        }
                    } else {
                        _account = _referrer;
                        emit Missed(_referrer, _level, _reward);
                    }
                }
            } else {
                _level = 11;
            }
            _referrer = referrers[_referrer];
            _reward /= 2;
            _minimum *= 2;
        }
        if(_charged > 0) _charge(address(0), _charged, false);
        if(raisup > 0) {
            if(_profit > 0) _mint(smart, _profit);
            if(totalSupply() >= raisup) {
                raisup = 0;
                _burn(smart, balanceOf(smart));
            }
        } else {
            emit RateUp(uint32(block.timestamp), this.rate());
        }
    }
    function restart() external {
        require(balanceOf(msg.sender) + balanceOf(smart) == totalSupply(), "Not alone");
        if(balanceOf(msg.sender) > 0) _burn(msg.sender, balanceOf(msg.sender));
        if(balanceOf(smart) > 0) _burn(smart, balanceOf(smart));
        raisup = 5 * 1e19;
        emit Restart(msg.sender, balanceOf(msg.sender) + balanceOf(smart), smart.balance);
        payable(msg.sender).transfer(smart.balance);
    }
    function burn(uint256 _value) external {
        _burn(msg.sender, _value);
    }
    function rate() external view returns (uint256) {
        return totalSupply() > 0 && smart.balance > 0 ? smart.balance * 1e6 / totalSupply() : 1e6; 
    }
    function cap() external view returns (uint256) {
        return smart.balance > 0 ? smart.balance : 0;
    }
}