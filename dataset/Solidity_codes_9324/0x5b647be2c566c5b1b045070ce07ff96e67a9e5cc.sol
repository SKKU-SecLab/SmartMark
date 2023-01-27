


pragma solidity 0.5.12;

contract ERC20Detailed {

    string internal _name;
    string internal _symbol;
    uint8 internal _decimals;

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



pragma solidity 0.5.12;

interface IBaseOperators {

    function isOperator(address _account) external view returns (bool);


    function isAdmin(address _account) external view returns (bool);


    function isSystem(address _account) external view returns (bool);


    function isRelay(address _account) external view returns (bool);


    function isMultisig(address _contract) external view returns (bool);


    function confirmFor(address _address) external;


    function addOperator(address _account) external;


    function removeOperator(address _account) external;


    function addAdmin(address _account) external;


    function removeAdmin(address _account) external;


    function addSystem(address _account) external;


    function removeSystem(address _account) external;


    function addRelay(address _account) external;


    function removeRelay(address _account) external;


    function addOperatorAndAdmin(address _account) external;


    function removeOperatorAndAdmin(address _account) external;

}


pragma solidity 0.5.12;

contract Initializable {

    bool private initialized;

    bool private initializing;

    modifier initializer() {

        require(
            initializing || isConstructor() || !initialized,
            "Initializable: Contract instance has already been initialized"
        );

        bool isTopLevelCall = !initializing;
        if (isTopLevelCall) {
            initializing = true;
            initialized = true;
        }

        _;

        if (isTopLevelCall) {
            initializing = false;
        }
    }

    function isConstructor() private view returns (bool) {

        uint256 cs;
        assembly {
            cs := extcodesize(address)
        }
        return cs == 0;
    }

    function isInitialized() public view returns (bool) {

        return initialized;
    }

    uint256[50] private ______gap;
}



pragma solidity 0.5.12;



contract Operatorable is Initializable {

    IBaseOperators internal operatorsInst;
    address private operatorsPending;

    event OperatorsContractChanged(address indexed caller, address indexed operatorsAddress);
    event OperatorsContractPending(address indexed caller, address indexed operatorsAddress);

    modifier onlyOperator() {

        require(isOperator(msg.sender), "Operatorable: caller does not have the operator role");
        _;
    }

    modifier onlyAdmin() {

        require(isAdmin(msg.sender), "Operatorable: caller does not have the admin role");
        _;
    }

    modifier onlySystem() {

        require(isSystem(msg.sender), "Operatorable: caller does not have the system role");
        _;
    }

    modifier onlyMultisig() {

        require(isMultisig(msg.sender), "Operatorable: caller does not have multisig role");
        _;
    }

    modifier onlyAdminOrSystem() {

        require(isAdminOrSystem(msg.sender), "Operatorable: caller does not have the admin role nor system");
        _;
    }

    modifier onlyOperatorOrSystem() {

        require(isOperatorOrSystem(msg.sender), "Operatorable: caller does not have the operator role nor system");
        _;
    }

    modifier onlyRelay() {

        require(isRelay(msg.sender), "Operatorable: caller does not have relay role associated");
        _;
    }

    modifier onlyOperatorOrRelay() {

        require(
            isOperator(msg.sender) || isRelay(msg.sender),
            "Operatorable: caller does not have the operator role nor relay"
        );
        _;
    }

    modifier onlyAdminOrRelay() {

        require(
            isAdmin(msg.sender) || isRelay(msg.sender),
            "Operatorable: caller does not have the admin role nor relay"
        );
        _;
    }

    modifier onlyOperatorOrSystemOrRelay() {

        require(
            isOperator(msg.sender) || isSystem(msg.sender) || isRelay(msg.sender),
            "Operatorable: caller does not have the operator role nor system nor relay"
        );
        _;
    }

    function initialize(address _baseOperators) public initializer {

        _setOperatorsContract(_baseOperators);
    }

    function setOperatorsContract(address _baseOperators) public onlyAdmin {

        require(_baseOperators != address(0), "Operatorable: address of new operators contract can not be zero");
        operatorsPending = _baseOperators;
        emit OperatorsContractPending(msg.sender, _baseOperators);
    }

    function confirmOperatorsContract() public {

        require(operatorsPending != address(0), "Operatorable: address of new operators contract can not be zero");
        require(msg.sender == operatorsPending, "Operatorable: should be called from new operators contract");
        _setOperatorsContract(operatorsPending);
    }

    function getOperatorsContract() public view returns (address) {

        return address(operatorsInst);
    }

    function getOperatorsPending() public view returns (address) {

        return operatorsPending;
    }

    function isOperator(address _account) public view returns (bool) {

        return operatorsInst.isOperator(_account);
    }

    function isAdmin(address _account) public view returns (bool) {

        return operatorsInst.isAdmin(_account);
    }

    function isSystem(address _account) public view returns (bool) {

        return operatorsInst.isSystem(_account);
    }

    function isRelay(address _account) public view returns (bool) {

        return operatorsInst.isRelay(_account);
    }

    function isMultisig(address _contract) public view returns (bool) {

        return operatorsInst.isMultisig(_contract);
    }

    function isAdminOrSystem(address _account) public view returns (bool) {

        return (operatorsInst.isAdmin(_account) || operatorsInst.isSystem(_account));
    }

    function isOperatorOrSystem(address _account) public view returns (bool) {

        return (operatorsInst.isOperator(_account) || operatorsInst.isSystem(_account));
    }

    function _setOperatorsContract(address _baseOperators) internal {

        require(_baseOperators != address(0), "Operatorable: address of new operators contract cannot be zero");
        operatorsInst = IBaseOperators(_baseOperators);
        emit OperatorsContractChanged(msg.sender, _baseOperators);
    }
}



pragma solidity 0.5.12;



contract ERC20SygnumDetailed is ERC20Detailed, Operatorable {

    bytes4 private _category;
    string private _class;
    address private _issuer;

    event NameUpdated(address issuer, string name, address token);
    event SymbolUpdated(address issuer, string symbol, address token);
    event CategoryUpdated(address issuer, bytes4 category, address token);
    event ClassUpdated(address issuer, string class, address token);
    event IssuerUpdated(address issuer, address newIssuer, address token);

    function _setDetails(
        string memory name,
        string memory symbol,
        uint8 decimals,
        bytes4 category,
        string memory class,
        address issuer
    ) internal {

        _name = name;
        _symbol = symbol;
        _decimals = decimals;
        _category = category;
        _class = class;
        _issuer = issuer;
    }

    function category() public view returns (bytes4) {

        return _category;
    }

    function class() public view returns (string memory) {

        return _class;
    }

    function issuer() public view returns (address) {

        return _issuer;
    }

    function updateName(string memory name_) public onlyOperator {

        _name = name_;
        emit NameUpdated(msg.sender, _name, address(this));
    }

    function updateSymbol(string memory symbol_) public onlyOperator {

        _symbol = symbol_;
        emit SymbolUpdated(msg.sender, symbol_, address(this));
    }

    function updateCategory(bytes4 category_) public onlyOperator {

        _category = category_;
        emit CategoryUpdated(msg.sender, _category, address(this));
    }

    function updateClass(string memory class_) public onlyOperator {

        _class = class_;
        emit ClassUpdated(msg.sender, _class, address(this));
    }

    function updateIssuer(address issuer_) public onlyOperator {

        _issuer = issuer_;
        emit IssuerUpdated(msg.sender, _issuer, address(this));
    }
}


pragma solidity ^0.5.0;

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


pragma solidity 0.5.12;




contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping(address => uint256) internal _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance")
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero")
        );
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {

        _burn(account, amount);
        _approve(
            account,
            _msgSender(),
            _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance")
        );
    }
}


pragma solidity 0.5.12;

contract IWhitelist {

    function isWhitelisted(address _account) external view returns (bool);


    function toggleWhitelist(address _account, bool _toggled) external;

}



pragma solidity 0.5.12;




contract Whitelistable is Initializable, Operatorable {

    IWhitelist internal whitelistInst;
    address private whitelistPending;

    event WhitelistContractChanged(address indexed caller, address indexed whitelistAddress);
    event WhitelistContractPending(address indexed caller, address indexed whitelistAddress);

    modifier whenWhitelisted(address _account) {

        require(isWhitelisted(_account), "Whitelistable: account is not whitelisted");
        _;
    }

    function initialize(address _baseOperators, address _whitelist) public initializer {

        _setOperatorsContract(_baseOperators);
        _setWhitelistContract(_whitelist);
    }

    function setWhitelistContract(address _whitelist) public onlyAdmin {

        require(_whitelist != address(0), "Whitelistable: address of new whitelist contract can not be zero");
        whitelistPending = _whitelist;
        emit WhitelistContractPending(msg.sender, _whitelist);
    }

    function confirmWhitelistContract() public {

        require(whitelistPending != address(0), "Whitelistable: address of new whitelist contract can not be zero");
        require(msg.sender == whitelistPending, "Whitelistable: should be called from new whitelist contract");
        _setWhitelistContract(whitelistPending);
    }

    function getWhitelistContract() public view returns (address) {

        return address(whitelistInst);
    }

    function getWhitelistPending() public view returns (address) {

        return whitelistPending;
    }

    function isWhitelisted(address _account) public view returns (bool) {

        return whitelistInst.isWhitelisted(_account);
    }

    function _setWhitelistContract(address _whitelist) internal {

        require(_whitelist != address(0), "Whitelistable: address of new whitelist contract cannot be zero");
        whitelistInst = IWhitelist(_whitelist);
        emit WhitelistContractChanged(msg.sender, _whitelist);
    }
}



pragma solidity 0.5.12;



contract ERC20Whitelist is ERC20, Whitelistable {

    function transfer(address to, uint256 value) public whenWhitelisted(msg.sender) whenWhitelisted(to) returns (bool) {

        return super.transfer(to, value);
    }

    function approve(address spender, uint256 value)
        public
        whenWhitelisted(msg.sender)
        whenWhitelisted(spender)
        returns (bool)
    {

        return super.approve(spender, value);
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public whenWhitelisted(msg.sender) whenWhitelisted(from) whenWhitelisted(to) returns (bool) {

        return super.transferFrom(from, to, value);
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        whenWhitelisted(spender)
        whenWhitelisted(msg.sender)
        returns (bool)
    {

        return super.increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        whenWhitelisted(spender)
        whenWhitelisted(msg.sender)
        returns (bool)
    {

        return super.decreaseAllowance(spender, subtractedValue);
    }

    function _burn(address account, uint256 value) internal whenWhitelisted(account) {

        super._burn(account, value);
    }

    function _burnFrom(address account, uint256 amount) internal whenWhitelisted(msg.sender) whenWhitelisted(account) {

        super._burnFrom(account, amount);
    }

    function _mint(address account, uint256 amount) internal whenWhitelisted(account) {

        super._mint(account, amount);
    }
}



pragma solidity 0.5.12;

contract ITraderOperators {

    function isTrader(address _account) external view returns (bool);


    function addTrader(address _account) external;


    function removeTrader(address _account) external;

}



pragma solidity 0.5.12;




contract TraderOperatorable is Operatorable {

    ITraderOperators internal traderOperatorsInst;
    address private traderOperatorsPending;

    event TraderOperatorsContractChanged(address indexed caller, address indexed traderOperatorsAddress);
    event TraderOperatorsContractPending(address indexed caller, address indexed traderOperatorsAddress);

    modifier onlyTrader() {

        require(isTrader(msg.sender), "TraderOperatorable: caller is not trader");
        _;
    }

    modifier onlyOperatorOrTraderOrSystem() {

        require(
            isOperator(msg.sender) || isTrader(msg.sender) || isSystem(msg.sender),
            "TraderOperatorable: caller is not trader or operator or system"
        );
        _;
    }

    function initialize(address _baseOperators, address _traderOperators) public initializer {

        super.initialize(_baseOperators);
        _setTraderOperatorsContract(_traderOperators);
    }

    function setTraderOperatorsContract(address _traderOperators) public onlyAdmin {

        require(
            _traderOperators != address(0),
            "TraderOperatorable: address of new traderOperators contract can not be zero"
        );
        traderOperatorsPending = _traderOperators;
        emit TraderOperatorsContractPending(msg.sender, _traderOperators);
    }

    function confirmTraderOperatorsContract() public {

        require(
            traderOperatorsPending != address(0),
            "TraderOperatorable: address of pending traderOperators contract can not be zero"
        );
        require(
            msg.sender == traderOperatorsPending,
            "TraderOperatorable: should be called from new traderOperators contract"
        );
        _setTraderOperatorsContract(traderOperatorsPending);
    }

    function getTraderOperatorsContract() public view returns (address) {

        return address(traderOperatorsInst);
    }

    function getTraderOperatorsPending() public view returns (address) {

        return traderOperatorsPending;
    }

    function isTrader(address _account) public view returns (bool) {

        return traderOperatorsInst.isTrader(_account);
    }

    function _setTraderOperatorsContract(address _traderOperators) internal {

        require(
            _traderOperators != address(0),
            "TraderOperatorable: address of new traderOperators contract can not be zero"
        );
        traderOperatorsInst = ITraderOperators(_traderOperators);
        emit TraderOperatorsContractChanged(msg.sender, _traderOperators);
    }
}


pragma solidity 0.5.12;


contract Pausable is TraderOperatorable {

    event Paused(address indexed account);
    event Unpaused(address indexed account);

    bool internal _paused;

    constructor() internal {
        _paused = false;
    }

    modifier whenNotPaused() {

        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {

        require(_paused, "Pausable: not paused");
        _;
    }

    function pause() public onlyOperatorOrTraderOrSystem whenNotPaused {

        _paused = true;
        emit Paused(msg.sender);
    }

    function unpause() public onlyOperatorOrTraderOrSystem whenPaused {

        _paused = false;
        emit Unpaused(msg.sender);
    }

    function isPaused() public view returns (bool) {

        return _paused;
    }

    function isNotPaused() public view returns (bool) {

        return !_paused;
    }
}



pragma solidity 0.5.12;



contract ERC20Pausable is ERC20, Pausable {

    function transfer(address to, uint256 value) public whenNotPaused returns (bool) {

        return super.transfer(to, value);
    }

    function approve(address spender, uint256 value) public whenNotPaused returns (bool) {

        return super.approve(spender, value);
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public whenNotPaused returns (bool) {

        return super.transferFrom(from, to, value);
    }

    function increaseAllowance(address spender, uint256 addedValue) public whenNotPaused returns (bool) {

        return super.increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public whenNotPaused returns (bool) {

        return super.decreaseAllowance(spender, subtractedValue);
    }

    function _burn(address account, uint256 value) internal whenNotPaused {

        super._burn(account, value);
    }

    function _burnFrom(address account, uint256 amount) internal whenNotPaused {

        super._burnFrom(account, amount);
    }

    function _mint(address account, uint256 amount) internal whenNotPaused {

        super._mint(account, amount);
    }
}



pragma solidity 0.5.12;



contract ERC20Mintable is ERC20, Operatorable {

    function _mint(address account, uint256 amount) internal onlyOperatorOrSystem {

        require(amount > 0, "ERC20Mintable: amount has to be greater than 0");
        super._mint(account, amount);
    }
}


pragma solidity 0.5.12;



contract ERC20Snapshot is ERC20 {

    using SafeMath for uint256;

    struct Snapshot {
        uint256 fromBlock; // `fromBlock` is the block number at which the value was generated from
        uint256 value; // `value` is the amount of tokens at a specific block number
    }

    mapping(address => Snapshot[]) private _snapshotBalances;

    Snapshot[] private _snapshotTotalSupply;

    function balanceOfAt(address _owner, uint256 _blockNumber) public view returns (uint256) {

        return getValueAt(_snapshotBalances[_owner], _blockNumber);
    }

    function totalSupplyAt(uint256 _blockNumber) public view returns (uint256) {

        return getValueAt(_snapshotTotalSupply, _blockNumber);
    }

    function getValueAt(Snapshot[] storage checkpoints, uint256 _block) internal view returns (uint256) {

        if (checkpoints.length == 0) return 0;

        if (_block >= checkpoints[checkpoints.length.sub(1)].fromBlock) {
            return checkpoints[checkpoints.length.sub(1)].value;
        }

        if (_block < checkpoints[0].fromBlock) {
            return 0;
        }

        uint256 min;
        uint256 max = checkpoints.length.sub(1);

        while (max > min) {
            uint256 mid = (max.add(min).add(1)).div(2);
            if (checkpoints[mid].fromBlock <= _block) {
                min = mid;
            } else {
                max = mid.sub(1);
            }
        }

        return checkpoints[min].value;
    }

    function updateValueAtNow(Snapshot[] storage checkpoints, uint256 _value) internal {

        if ((checkpoints.length == 0) || (checkpoints[checkpoints.length.sub(1)].fromBlock < block.number)) {
            checkpoints.push(Snapshot(block.number, _value));
        } else {
            checkpoints[checkpoints.length.sub(1)].value = _value;
        }
    }

    function transfer(address to, uint256 value) public returns (bool result) {

        result = super.transfer(to, value);
        updateValueAtNow(_snapshotTotalSupply, totalSupply());
        updateValueAtNow(_snapshotBalances[msg.sender], balanceOf(msg.sender));
        updateValueAtNow(_snapshotBalances[to], balanceOf(to));
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public returns (bool result) {

        result = super.transferFrom(from, to, value);
        updateValueAtNow(_snapshotTotalSupply, totalSupply());
        updateValueAtNow(_snapshotBalances[from], balanceOf(from));
        updateValueAtNow(_snapshotBalances[to], balanceOf(to));
    }

    function _confiscate(
        address confiscatee,
        address receiver,
        uint256 amount
    ) internal {

        super._transfer(confiscatee, receiver, amount);
        updateValueAtNow(_snapshotTotalSupply, totalSupply());
        updateValueAtNow(_snapshotBalances[confiscatee], balanceOf(confiscatee));
        updateValueAtNow(_snapshotBalances[receiver], balanceOf(receiver));
    }

    function _mint(address account, uint256 amount) internal {

        super._mint(account, amount);
        updateValueAtNow(_snapshotTotalSupply, totalSupply());
        updateValueAtNow(_snapshotBalances[account], balanceOf(account));
    }

    function _burn(address account, uint256 amount) internal {

        super._burn(account, amount);
        updateValueAtNow(_snapshotTotalSupply, totalSupply());
        updateValueAtNow(_snapshotBalances[account], balanceOf(account));
    }

    function _burnFor(address account, uint256 amount) internal {

        super._burn(account, amount);
        updateValueAtNow(_snapshotTotalSupply, totalSupply());
        updateValueAtNow(_snapshotBalances[account], balanceOf(account));
    }

    function _burnFrom(address account, uint256 amount) internal {

        super._burnFrom(account, amount);
        updateValueAtNow(_snapshotTotalSupply, totalSupply());
        updateValueAtNow(_snapshotBalances[account], balanceOf(account));
    }
}



pragma solidity 0.5.12;



contract ERC20Burnable is ERC20Snapshot, Operatorable {


    function _burnFor(address account, uint256 amount) internal onlyOperator {

        super._burn(account, amount);
    }
}



pragma solidity 0.5.12;


contract Freezable is Operatorable {

    mapping(address => bool) public frozen;

    event FreezeToggled(address indexed account, bool frozen);

    modifier onlyValidAddress(address _address) {

        require(_address != address(0), "Freezable: Empty address");
        _;
    }

    modifier whenNotFrozen(address _account) {

        require(!frozen[_account], "Freezable: account is frozen");
        _;
    }

    modifier whenFrozen(address _account) {

        require(frozen[_account], "Freezable: account is not frozen");
        _;
    }

    function isFrozen(address _account) public view returns (bool) {

        return frozen[_account];
    }

    function toggleFreeze(address _account, bool _toggled) public onlyValidAddress(_account) onlyOperator {

        frozen[_account] = _toggled;
        emit FreezeToggled(_account, _toggled);
    }

    function batchToggleFreeze(address[] memory _addresses, bool _toggled) public {

        require(_addresses.length <= 256, "Freezable: batch count is greater than 256");
        for (uint256 i = 0; i < _addresses.length; i++) {
            toggleFreeze(_addresses[i], _toggled);
        }
    }
}



pragma solidity 0.5.12;



contract ERC20Freezable is ERC20, Freezable {

    function transfer(address to, uint256 value) public whenNotFrozen(msg.sender) whenNotFrozen(to) returns (bool) {

        return super.transfer(to, value);
    }

    function approve(address spender, uint256 value)
        public
        whenNotFrozen(msg.sender)
        whenNotFrozen(spender)
        returns (bool)
    {

        return super.approve(spender, value);
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public whenNotFrozen(msg.sender) whenNotFrozen(from) whenNotFrozen(to) returns (bool) {

        return super.transferFrom(from, to, value);
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        whenNotFrozen(msg.sender)
        whenNotFrozen(spender)
        returns (bool)
    {

        return super.increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        whenNotFrozen(msg.sender)
        whenNotFrozen(spender)
        returns (bool)
    {

        return super.decreaseAllowance(spender, subtractedValue);
    }

    function _burnFrom(address account, uint256 amount) internal whenNotFrozen(msg.sender) whenNotFrozen(account) {

        super._burnFrom(account, amount);
    }
}



pragma solidity 0.5.12;


contract ERC20Destroyable is Operatorable {

    event Destroyed(address indexed caller, address indexed account, address indexed contractAddress);

    function destroy(address payable to) public onlyOperator {

        emit Destroyed(msg.sender, to, address(this));
        selfdestruct(to);
    }
}



pragma solidity 0.5.12;



contract ERC20Tradeable is ERC20, TraderOperatorable {

    function approveOnBehalf(
        address _owner,
        address _spender,
        uint256 _value
    ) public onlyTrader {

        super._approve(_owner, _spender, _value);
    }
}



pragma solidity 0.5.12;

contract IBlockerOperators {

    function isBlocker(address _account) external view returns (bool);


    function addBlocker(address _account) external;


    function removeBlocker(address _account) external;

}



pragma solidity 0.5.12;




contract BlockerOperatorable is Operatorable {

    IBlockerOperators internal blockerOperatorsInst;
    address private blockerOperatorsPending;

    event BlockerOperatorsContractChanged(address indexed caller, address indexed blockerOperatorAddress);
    event BlockerOperatorsContractPending(address indexed caller, address indexed blockerOperatorAddress);

    modifier onlyBlocker() {

        require(isBlocker(msg.sender), "BlockerOperatorable: caller is not blocker role");
        _;
    }

    modifier onlyBlockerOrOperator() {

        require(
            isBlocker(msg.sender) || isOperator(msg.sender),
            "BlockerOperatorable: caller is not blocker or operator role"
        );
        _;
    }

    function initialize(address _baseOperators, address _blockerOperators) public initializer {

        super.initialize(_baseOperators);
        _setBlockerOperatorsContract(_blockerOperators);
    }

    function setBlockerOperatorsContract(address _blockerOperators) public onlyAdmin {

        require(
            _blockerOperators != address(0),
            "BlockerOperatorable: address of new blockerOperators contract can not be zero."
        );
        blockerOperatorsPending = _blockerOperators;
        emit BlockerOperatorsContractPending(msg.sender, _blockerOperators);
    }

    function confirmBlockerOperatorsContract() public {

        require(
            blockerOperatorsPending != address(0),
            "BlockerOperatorable: address of pending blockerOperators contract can not be zero"
        );
        require(
            msg.sender == blockerOperatorsPending,
            "BlockerOperatorable: should be called from new blockerOperators contract"
        );
        _setBlockerOperatorsContract(blockerOperatorsPending);
    }

    function getBlockerOperatorsContract() public view returns (address) {

        return address(blockerOperatorsInst);
    }

    function getBlockerOperatorsPending() public view returns (address) {

        return blockerOperatorsPending;
    }

    function isBlocker(address _account) public view returns (bool) {

        return blockerOperatorsInst.isBlocker(_account);
    }

    function _setBlockerOperatorsContract(address _blockerOperators) internal {

        require(
            _blockerOperators != address(0),
            "BlockerOperatorable: address of new blockerOperators contract can not be zero"
        );
        blockerOperatorsInst = IBlockerOperators(_blockerOperators);
        emit BlockerOperatorsContractChanged(msg.sender, _blockerOperators);
    }
}



pragma solidity 0.5.12;



contract ERC20Blockable is ERC20, BlockerOperatorable {

    uint256 public totalBlockedBalance;

    mapping(address => uint256) public _blockedBalances;

    event Blocked(address indexed blocker, address indexed account, uint256 value);
    event UnBlocked(address indexed blocker, address indexed account, uint256 value);

    function block(address _account, uint256 _amount) public onlyBlockerOrOperator {

        _balances[_account] = _balances[_account].sub(_amount);
        _blockedBalances[_account] = _blockedBalances[_account].add(_amount);

        totalBlockedBalance = totalBlockedBalance.add(_amount);
        emit Blocked(msg.sender, _account, _amount);
    }

    function unblock(address _account, uint256 _amount) public onlyBlockerOrOperator {

        _balances[_account] = _balances[_account].add(_amount);
        _blockedBalances[_account] = _blockedBalances[_account].sub(_amount);

        totalBlockedBalance = totalBlockedBalance.sub(_amount);
        emit UnBlocked(msg.sender, _account, _amount);
    }

    function blockedBalanceOf(address _account) public view returns (uint256) {

        return _blockedBalances[_account];
    }

    function getTotalBlockedBalance() public view returns (uint256) {

        return totalBlockedBalance;
    }
}



pragma solidity 0.5.12;











contract SygnumToken is
    ERC20Snapshot,
    ERC20SygnumDetailed,
    ERC20Pausable,
    ERC20Mintable,
    ERC20Whitelist,
    ERC20Tradeable,
    ERC20Blockable,
    ERC20Burnable,
    ERC20Freezable,
    ERC20Destroyable
{

    event Minted(address indexed minter, address indexed account, uint256 value);
    event Burned(address indexed burner, uint256 value);
    event BurnedFor(address indexed burner, address indexed account, uint256 value);
    event Confiscated(address indexed account, uint256 amount, address indexed receiver);

    uint16 internal constant BATCH_LIMIT = 256;

    function initializeContractsAndConstructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        bytes4 _category,
        string memory _class,
        address _issuer,
        address _baseOperators,
        address _whitelist,
        address _traderOperators,
        address _blockerOperators
    ) public initializer {

        super.initialize(_baseOperators);
        _setWhitelistContract(_whitelist);
        _setTraderOperatorsContract(_traderOperators);
        _setBlockerOperatorsContract(_blockerOperators);
        _setDetails(_name, _symbol, _decimals, _category, _class, _issuer);
    }

    function burn(uint256 _amount) public {

        require(!isFrozen(msg.sender), "SygnumToken: Account must not be frozen.");
        super._burn(msg.sender, _amount);
        emit Burned(msg.sender, _amount);
    }

    function burnFor(address _account, uint256 _amount) public {

        super._burnFor(_account, _amount);
        emit BurnedFor(msg.sender, _account, _amount);
    }

    function burnFrom(address _account, uint256 _amount) public {

        super._burnFrom(_account, _amount);
        emit Burned(_account, _amount);
    }

    function mint(address _account, uint256 _amount) public {

        if (isSystem(msg.sender)) {
            require(!isFrozen(_account), "SygnumToken: Account must not be frozen if system calling.");
        }
        super._mint(_account, _amount);
        emit Minted(msg.sender, _account, _amount);
    }

    function confiscate(
        address _confiscatee,
        address _receiver,
        uint256 _amount
    ) public onlyOperator whenNotPaused whenWhitelisted(_receiver) whenWhitelisted(_confiscatee) {

        super._confiscate(_confiscatee, _receiver, _amount);
        emit Confiscated(_confiscatee, _amount, _receiver);
    }

    function batchBurnFor(address[] memory _accounts, uint256[] memory _amounts) public {

        require(_accounts.length == _amounts.length, "SygnumToken: values and recipients are not equal.");
        require(_accounts.length <= BATCH_LIMIT, "SygnumToken: batch count is greater than BATCH_LIMIT.");
        for (uint256 i = 0; i < _accounts.length; i++) {
            burnFor(_accounts[i], _amounts[i]);
        }
    }

    function batchMint(address[] memory _accounts, uint256[] memory _amounts) public {

        require(_accounts.length == _amounts.length, "SygnumToken: values and recipients are not equal.");
        require(_accounts.length <= BATCH_LIMIT, "SygnumToken: batch count is greater than BATCH_LIMIT.");
        for (uint256 i = 0; i < _accounts.length; i++) {
            mint(_accounts[i], _amounts[i]);
        }
    }

    function batchConfiscate(
        address[] memory _confiscatees,
        address[] memory _receivers,
        uint256[] memory _values
    ) public returns (bool) {

        require(
            _confiscatees.length == _values.length && _receivers.length == _values.length,
            "SygnumToken: confiscatees, recipients and values are not equal."
        );
        require(_confiscatees.length <= BATCH_LIMIT, "SygnumToken: batch count is greater than BATCH_LIMIT.");
        for (uint256 i = 0; i < _confiscatees.length; i++) {
            confiscate(_confiscatees[i], _receivers[i], _values[i]);
        }
    }
}


pragma solidity 0.5.12;


contract SygnumTokenV1 is SygnumToken {

    string public tokenURI;
    bool public initializedV1;
    event TokenUriUpdated(string newToken);

    function initializeContractsAndConstructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        bytes4 _category,
        string memory _class,
        address _issuer,
        address _baseOperators,
        address _whitelist,
        address _traderOperators,
        address _blockerOperators,
        string memory _tokenURI
    ) public {

        require(!initializedV1, "SygnumTokenV1: already initialized");
        super.initializeContractsAndConstructor(
            _name,
            _symbol,
            _decimals,
            _category,
            _class,
            _issuer,
            _baseOperators,
            _whitelist,
            _traderOperators,
            _blockerOperators
        );
        initializeV1(_tokenURI);
    }

    function initializeV1(string memory _tokenURI) public {

        require(!initializedV1, "SygnumTokenV1: already initialized");
        tokenURI = _tokenURI;
        initializedV1 = true;
    }

    function updateTokenURI(string memory _newToken) public onlyOperator {

        tokenURI = _newToken;
        emit TokenUriUpdated(_newToken);
    }
}