pragma solidity =0.7.5;


library SafeMath {

    function add(
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (uint256)
    {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (uint256)
    {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    )
        internal
        pure
        returns (uint256)
    {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (uint256)
    {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (uint256)
    {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    )
        internal
        pure
        returns (uint256)
    {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (uint256)
    {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    )
        internal
        pure
        returns (uint256)
    {

        require(b != 0, errorMessage);
        return a % b;
    }
}// MIT
pragma solidity =0.7.5;


interface IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
}
pragma solidity =0.7.5;


interface IVesting {

    function vestingOf(address account) external view returns (uint256);

}
pragma solidity =0.7.5;


library Roles {

    struct Role
    {
        mapping (address => bool) bearer;
    }

    function add(
        Role storage role,
        address account
    )
        internal
    {

        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(
        Role storage role,
        address account
    )
        internal
    {

        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(
        Role storage role,
        address account
    )
        internal
        view
        returns (bool)
    {

        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}
pragma solidity =0.7.5;



contract BaseAuth {

    using Roles for Roles.Role;

    Roles.Role private _agents;

    event AgentAdded(address indexed account);
    event AgentRemoved(address indexed account);

    constructor ()
    {
        _agents.add(msg.sender);
        emit AgentAdded(msg.sender);
    }

    modifier onlyAgent() {

        require(isAgent(msg.sender), "AgentRole: caller does not have the Agent role");
        _;
    }

    function rescueToken(
        address tokenAddr,
        address recipient,
        uint256 amount
    )
        external
        onlyAgent
    {

        IERC20 _token = IERC20(tokenAddr);
        require(recipient != address(0), "Rescue: recipient is the zero address");
        uint256 balance = _token.balanceOf(address(this));

        require(balance >= amount, "Rescue: amount exceeds balance");
        _token.transfer(recipient, amount);
    }

    function withdrawEther(
        address payable recipient,
        uint256 amount
    )
        external
        onlyAgent
    {

        require(recipient != address(0), "Withdraw: recipient is the zero address");
        uint256 balance = address(this).balance;
        require(balance >= amount, "Withdraw: amount exceeds balance");
        recipient.transfer(amount);
    }

    function isAgent(address account)
        public
        view
        returns (bool)
    {

        return _agents.has(account);
    }

    function addAgent(address account)
        public
        onlyAgent
    {

        _agents.add(account);
        emit AgentAdded(account);
    }

    function removeAgent(address account)
        public
        onlyAgent
    {

        _agents.remove(account);
        emit AgentRemoved(account);
    }
}

pragma solidity =0.7.5;



contract AuthPause is BaseAuth {

    using Roles for Roles.Role;

    bool private _paused = false;

    event PausedON();
    event PausedOFF();


    modifier onlyNotPaused() {

        require(!_paused, "Paused");
        _;
    }

    function isPaused()
        public
        view
        returns (bool)
    {

        return _paused;
    }

    function setPaused(bool value)
        external
        onlyAgent
    {

        _paused = value;

        if (_paused) {
            emit PausedON();
        } else {
            emit PausedOFF();
        }
    }
}
pragma solidity =0.7.5;



contract AuthProxy is BaseAuth {

    using Roles for Roles.Role;

    Roles.Role private _proxies;
    
    event ProxyAdded(address indexed account);
    event ProxyRemoved(address indexed account);


    modifier onlyProxy() {

        require(isProxy(msg.sender), "ProxyRole: caller does not have the Proxy role");
        _;
    }

    function isProxy(address account)
        public
        view
        returns (bool)
    {

        return _proxies.has(account);
    }

    function addProxy(address account)
        public
        onlyAgent
    {

        _proxies.add(account);
        emit ProxyAdded(account);
    }

    function removeProxy(address account)
        public
        onlyAgent
    {

        _proxies.remove(account);
        emit ProxyRemoved(account);
    }
}
pragma solidity =0.7.5;



contract AuthVoken is BaseAuth, AuthPause, AuthProxy {

    using Roles for Roles.Role;

    Roles.Role private _banks;
    Roles.Role private _minters;

    event BankAdded(address indexed account);
    event BankRemoved(address indexed account);
    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);


    modifier onlyMinter()
    {

        require(isMinter(msg.sender), "MinterRole: caller does not have the Minter role");
        _;
    }

    function isBank(address account)
        public
        view
        returns (bool)
    {

        return _banks.has(account);
    }

    function addBank(address account)
        public
        onlyAgent
    {

        _banks.add(account);
        emit BankAdded(account);
    }

    function removeBank(address account)
        public
        onlyAgent
    {

        _banks.remove(account);
        emit BankRemoved(account);
    }

    function isMinter(address account)
        public
        view
        returns (bool)
    {

        return _minters.has(account);
    }

    function addMinter(address account)
        public
        onlyAgent
    {

        _minters.add(account);
        emit MinterAdded(account);
    }

    function removeMinter(address account)
        public
        onlyAgent
    {

        _minters.remove(account);
        emit MinterRemoved(account);
    }
}// MIT
pragma solidity =0.7.5;




contract Burning is BaseAuth {

    using SafeMath for uint256;

    uint16 private _burningPermilleMin;
    uint16 private _burningPermilleMax;
    uint16 private _burningPermilleMod;

    constructor () {
        _burningPermilleMin = 10;
        _burningPermilleMax = 30;
        _burningPermilleMod = 21;
    }

    function setBurningBorder(
        uint16 min,
        uint16 max
    )
        external
        onlyAgent
    {

        require(min <= 1000, "Set burning border: min exceeds 100.0%");
        require(max <= 1000, "Set burning border: max exceeds 100.0%");
        require(min <= max, 'Set burning border: min exceeds max');

        _burningPermilleMin = min;
        _burningPermilleMax = max;
        _burningPermilleMod = _burningPermilleMax - _burningPermilleMin + 1;
    }

    function burningPermilleBorder()
        public
        view
        returns (uint16 min, uint16 max)
    {

        min = _burningPermilleMin;
        max = _burningPermilleMax;
    }

    function burningPermille()
        public
        view
        returns (uint16)
    {

        if (_burningPermilleMax == 0)
            return 0;

        if (_burningPermilleMin == _burningPermilleMax)
            return _burningPermilleMin;

        return uint16(uint256(keccak256(abi.encode(blockhash(block.number - 1)))).mod(_burningPermilleMod).add(_burningPermilleMin));
    }
}
pragma solidity =0.7.5;





contract VokenTB is IERC20, IVesting, AuthVoken, Burning {

    using SafeMath for uint256;

    struct Account {
        uint256 balance;

        uint160 voken;
        address payable referrer;

        IVesting[] vestingContracts;
        mapping (address => bool) hasVesting;

        mapping (address => uint256) allowances;
    }

    string private _name = "Voken TeraByte";
    string private _symbol = "VokenTB";
    uint8 private constant _decimals = 9;
    uint256 private constant _cap = 210_000_000e9;
    uint256 private _totalSupply;
    uint256 private _vokenCounter;
    bool private _changeVokenAddressAllowed;

    mapping (address => Account) private _accounts;
    mapping (uint160 => address payable) private _voken2address;

    event Mint(address indexed account, uint256 amount);
    event Burn(address indexed account, uint256 amount);
    event Donate(address indexed account, uint256 amount);
    event VokenAddressSet(address indexed account, uint160 voken);
    event ReferrerSet(address indexed account, address indexed referrerAccount);


    receive()
        external
        payable
    {
        if (msg.value > 0) {
            emit Donate(msg.sender, msg.value);
        }
    }

    function setName(
        string calldata value
    )
        external
        onlyAgent
    {

        _name = value;
    }

    function setSymbol(
        string calldata value
    )
        external
        onlyAgent
    {

        _symbol = value;
    }

    function setChangeVokenAddressAllowed(bool value)
        external
        onlyAgent
    {

        _changeVokenAddressAllowed = value;
    }

    function setVokenAddress(uint160 voken)
        external
        returns (bool)
    {

        require(balanceOf(msg.sender) > 0, "Set Voken Address: balance is zero");
        require(voken > 0, "Set Voken Address: is zero address");

        if (_accounts[msg.sender].voken > 0) {
            require(_changeVokenAddressAllowed, "Change Voken Address: is not allowed");
            delete _voken2address[voken];
        }

        else {
            _vokenCounter = _vokenCounter.add(1);
        }

        _voken2address[voken] = msg.sender;
        _accounts[msg.sender].voken = voken;

        emit VokenAddressSet(msg.sender, voken);
        return true;
    }

    function setReferrer(
        uint160 referrerVoken
    )
        external
        returns (bool)
    {

        address payable referrer_ = _voken2address[referrerVoken];

        require(referrer_ != address(0), "Set referrer: does not exist");
        require(_accounts[msg.sender].referrer == address(0), "Set referrer: was already exist");

        _accounts[msg.sender].referrer = referrer_;
        emit ReferrerSet(msg.sender, referrer_);
        return true;
    }

    function name()
        public
        view
        override
        returns (string memory)
    {

        return _name;
    }

    function symbol()
        public
        view
        override
        returns (string memory)
    {

        return _symbol;
    }

    function decimals()
        public
        pure
        override
        returns (uint8)
    {

        return _decimals;
    }

    function cap()
        public
        pure
        returns (uint256)
    {

        return _cap;
    }

    function totalSupply()
        public
        view
        override
        returns (uint256)
    {

        return _totalSupply;
    }

    function balanceOf(
        address account
    )
        public
        view
        override
        returns (uint256)
    {

        return _accounts[account].balance;
    }

    function vestingContracts(
        address account
    )
        public
        view
        returns (IVesting[] memory contracts)
    {

        contracts = _accounts[account].vestingContracts;
    }

    function isChangeVokenAddressAllowed()
        public
        view
        returns (bool)
    {

        return _changeVokenAddressAllowed;
    }

    function address2voken(
        address account
    )
        public
        view
        returns (uint160)
    {

        return _accounts[account].voken;
    }

    function voken2address(
        uint160 voken
    )
        public
        view
        returns (address payable)
    {

        return _voken2address[voken];
    }

    function vokenCounter()
        public
        view
        returns (uint256)
    {

        return _vokenCounter;
    }

    function referrer(
        address account
    )
        public
        view
        returns (address payable)
    {

        return _accounts[account].referrer;
    }

    function approve(address spender, uint256 value)
        public
        override
        onlyNotPaused
        returns (bool)
    {

        _approve(msg.sender, spender, value);
        return true;
    }

    function allowance(
        address owner,
        address spender
    )
        public
        override
        view
        returns (uint256)
    {

        return _accounts[owner].allowances[spender];
    }

    function vestingOf(
        address account
    )
        public
        override
        view
        returns (uint256 reserved)
    {

        for (uint256 i = 0; i < _accounts[account].vestingContracts.length; i++) {
            if (
                _accounts[account].vestingContracts[i] != IVesting(0)
                &&
                isContract(address(_accounts[account].vestingContracts[i]))
            ) {
                try _accounts[account].vestingContracts[i].vestingOf(account) returns (uint256 value) {
                    reserved = reserved.add(value);
                }
    
                catch {
                }
            }
        }
    }

    function availableOf(
        address account
    )
        public
        view
        returns (uint256)
    {

        return balanceOf(account).sub(vestingOf(account));
    }

    function burn(
        uint256 amount
    )
        public
        returns (bool)
    {

        require(amount > 0, "Burn: amount is zero");

        uint256 balance = balanceOf(msg.sender);
        require(balance > 0, "Burn: balance is zero");

        if (balance >= amount) {
            _burn(msg.sender, amount);
        }
        
        else {
            _burn(msg.sender, balance);
        }

        return true;
    }

    function mint(
        address account,
        uint256 amount
    )
        public
        onlyNotPaused
        onlyMinter
        returns (bool)
    {

        require(amount > 0, "Mint: amount is zero");

        _mint(account, amount);
        return true;
    }

    function mintWithVesting(
        address account,
        uint256 amount,
        address vestingContract
    )
        public
        onlyNotPaused
        onlyMinter
        returns (bool)
    {

        require(amount > 0, "Mint: amount is zero");
        require(vestingContract != address(this), "Mint, vesting address is the token address");

        _mintWithVesting(account, amount, vestingContract);
        return true;
    }

    function transfer(
        address recipient,
        uint256 amount
    )
        public
        override
        onlyNotPaused
        returns (bool)
    {

        require(amount > 0, "Transfer: amount is zero");

        if (recipient == address(0)) {
            uint256 balance = balanceOf(msg.sender);
            require(balance > 0, "Transfer: balance is zero");

            if (amount <= balance) {
                _burn(msg.sender, amount);
            }

            else {
                _burn(msg.sender, balance);
            }
        }

        else {
            uint256 available = availableOf(msg.sender);
            require(available > 0, "Transfer: available balance is zero");
            require(amount <= available, "Transfer: insufficient available balance");
            
            _transfer(msg.sender, recipient, amount);
        }

        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    )
        public
        override
        onlyNotPaused
        returns (bool)
    {

        require(amount > 0, "TransferFrom: amount is zero");

        if (recipient == address(0)) {
            uint256 balance = balanceOf(sender);
            require(balance > 0, "Transfer: balance is zero");

            if (amount <= balance) {
                _burn(sender, amount);
            }

            else {
                _burn(sender, balance);
            }
        }

        else {
            uint256 available = availableOf(sender);
            require(available > 0, "TransferFrom: available balance is zero");
            require(amount <= available, "TransferFrom: insufficient available balance");
            
            _transfer(sender, recipient, amount);
            _approve(sender, msg.sender, _accounts[sender].allowances[msg.sender].sub(amount, "TransferFrom: amount exceeds allowance"));
        }

        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 value
    )
        private
    {

        require(owner != address(0), "Approve: from the zero address");
        require(spender != address(0), "Approve: to the zero address");

        _accounts[owner].allowances[spender] = value;
        emit Approval(owner, spender, value);
    }

    function _burn(
        address account,
        uint256 amount
    )
        private
    {

        _accounts[account].balance = _accounts[account].balance.sub(amount, "Burn: insufficient balance");
        _totalSupply = _totalSupply.sub(amount, "Burn: amount exceeds total supply");
        emit Burn(account, amount);
        emit Transfer(account, address(0), amount);
    }

    function _mint(
        address account,
        uint256 amount
    )
        private
    {

        uint256 total = _totalSupply.add(amount);

        require(total <= _cap, "Mint: total supply cap exceeded");
        require(account != address(0), "Mint: to the zero address");

        _totalSupply = total;
        _accounts[account].balance = _accounts[account].balance.add(amount);
        emit Mint(account, amount);
        emit Transfer(address(0), account, amount);
    }

    function _mintWithVesting(
        address account,
        uint256 amount,
        address vestingContract
    )
        private
    {

        uint256 total = _totalSupply.add(amount);

        require(total <= _cap, "Mint: total supply cap exceeded");
        require(account != address(0), "Mint: to the zero address");

        _totalSupply = total;
        _accounts[account].balance = _accounts[account].balance.add(amount);

        if (!_accounts[account].hasVesting[vestingContract]) {
            _accounts[account].vestingContracts.push(IVesting(vestingContract));
            _accounts[account].hasVesting[vestingContract] = true;
        }

        emit Mint(account, amount);
        emit Transfer(address(0), account, amount);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    )
        private
    {

        if (!isBank(sender) && !isBank(recipient)) {
            uint16 permille = burningPermille();

            if (permille > 0) {
                uint256 amountBurn = amount.mul(permille).div(1_000);
                uint256 amountTransfer = amount.sub(amountBurn);
    
                _accounts[sender].balance = _accounts[sender].balance.sub(amountTransfer, "Transfer: insufficient balance");
                _accounts[recipient].balance = _accounts[recipient].balance.add(amountTransfer);
                emit Transfer(sender, recipient, amountTransfer);
    
                _burn(sender, amountBurn);
                
                return;
            }
        }

        _accounts[sender].balance = _accounts[sender].balance.sub(amount, "Transfer: insufficient balance");
        _accounts[recipient].balance = _accounts[recipient].balance.add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function isContract(address account)
        private
        view
        returns (bool)
    {

        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}
