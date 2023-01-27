
pragma solidity ^0.5.0;

contract Ownable {

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

pragma solidity ^0.5.0;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0);
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);
        return a % b;
    }
}

 
pragma solidity ^0.5.4;


contract Utils {

    modifier onlyValidAddress(address _address) {

        require(_address != address(0), "invalid address");
        _;
    }
}

 
 pragma solidity ^0.5.4;


contract Manageable is Ownable, Utils {

    mapping(address => bool) public isManager;     // manager accounts

    event ChangedManager(address indexed manager, bool active);

    modifier onlyManager() {

        require(isManager[msg.sender], "is not manager");
        _;
    }

    constructor() public {
        setManager(msg.sender, true);
    }

    function setManager(address _manager, bool _active) public onlyOwner onlyValidAddress(_manager) {

        isManager[_manager] = _active;
        emit ChangedManager(_manager, _active);
    }
}


pragma solidity ^0.5.4;



contract GlobalWhitelist is Ownable, Manageable {

    using SafeMath for uint256;
    
    mapping(address => bool) public isWhitelisted; // addresses of who's whitelisted
    bool public isWhitelisting = true;             // whitelisting enabled by default

    event ChangedWhitelisting(address indexed registrant, bool whitelisted);
    event GlobalWhitelistDisabled(address indexed manager);
    event GlobalWhitelistEnabled(address indexed manager);

    function addAddressToWhitelist(address _address) public onlyManager onlyValidAddress(_address) {

        isWhitelisted[_address] = true;
        emit ChangedWhitelisting(_address, true);
    }

    function addAddressesToWhitelist(address[] memory _addresses) public {

        for (uint256 i = 0; i < _addresses.length; i++) {
            addAddressToWhitelist(_addresses[i]);
        }
    }

    function removeAddressFromWhitelist(address _address) public onlyManager onlyValidAddress(_address) {

        isWhitelisted[_address] = false;
        emit ChangedWhitelisting(_address, false);
    }

    function removeAddressesFromWhitelist(address[] memory _addresses) public {

        for (uint256 i = 0; i < _addresses.length; i++) {
            removeAddressFromWhitelist(_addresses[i]);
        }
    }

    function toggleWhitelist() public onlyOwner {

        isWhitelisting ? isWhitelisting = false : isWhitelisting = true;
        if (isWhitelisting) {
            emit GlobalWhitelistEnabled(msg.sender);
        } else {
            emit GlobalWhitelistDisabled(msg.sender);
        }
    }
}

pragma solidity ^0.5.0;

interface IERC20 {

    function transfer(address to, uint256 value) external returns (bool);


    function approve(address spender, uint256 value) external returns (bool);


    function transferFrom(address from, address to, uint256 value) external returns (bool);


    function totalSupply() external view returns (uint256);


    function balanceOf(address who) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

pragma solidity ^0.5.0;


contract ERC20 is IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address owner) public view returns (uint256) {

        return _balances[owner];
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowed[owner][spender];
    }

    function transfer(address to, uint256 value) public returns (bool) {

        _transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {

        require(spender != address(0));

        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {

        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        emit Approval(from, msg.sender, _allowed[from][msg.sender]);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {

        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    function _mint(address account, uint256 value) internal {

        require(account != address(0));

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    function _burn(address account, uint256 value) internal {

        require(account != address(0));

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    function _burnFrom(address account, uint256 value) internal {

        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);
        _burn(account, value);
        emit Approval(account, msg.sender, _allowed[account][msg.sender]);
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

pragma solidity ^0.5.0;


contract ERC20Burnable is ERC20 {

    function burn(uint256 value) public {

        _burn(msg.sender, value);
    }

    function burnFrom(address from, uint256 value) public {

        _burnFrom(from, value);
    }
}

pragma solidity ^0.5.0;

library Roles {

    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {

        require(account != address(0));
        return role.bearer[account];
    }
}

pragma solidity ^0.5.0;


contract PauserRole {

    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(msg.sender);
    }

    modifier onlyPauser() {

        require(isPauser(msg.sender));
        _;
    }

    function isPauser(address account) public view returns (bool) {

        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {

        _addPauser(account);
    }

    function renouncePauser() public {

        _removePauser(msg.sender);
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

pragma solidity ^0.5.0;


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

        require(!_paused);
        _;
    }

    modifier whenPaused() {

        require(_paused);
        _;
    }

    function pause() public onlyPauser whenNotPaused {

        _paused = true;
        emit Paused(msg.sender);
    }

    function unpause() public onlyPauser whenPaused {

        _paused = false;
        emit Unpaused(msg.sender);
    }
}

pragma solidity ^0.5.0;


contract ERC20Pausable is ERC20, Pausable {

    function transfer(address to, uint256 value) public whenNotPaused returns (bool) {

        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public whenNotPaused returns (bool) {

        return super.transferFrom(from, to, value);
    }

    function approve(address spender, uint256 value) public whenNotPaused returns (bool) {

        return super.approve(spender, value);
    }

    function increaseAllowance(address spender, uint addedValue) public whenNotPaused returns (bool success) {

        return super.increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(address spender, uint subtractedValue) public whenNotPaused returns (bool success) {

        return super.decreaseAllowance(spender, subtractedValue);
    }
}


pragma solidity ^0.5.4;  


contract IERC20Snapshot {   

    function balanceOfAt(address _owner, uint _blockNumber) public view returns (uint256) {}


    function totalSupplyAt(uint _blockNumber) public view returns(uint256) {}

}


pragma solidity ^0.5.4;  



contract ERC20Snapshot is IERC20Snapshot, ERC20 {   
    using SafeMath for uint256;

    struct Snapshot {
        uint128 fromBlock;  // `fromBlock` is the block number at which the value was generated from
        uint128 value;  // `value` is the amount of tokens at a specific block number
    }

    mapping (address => Snapshot[]) private _snapshotBalances;

    Snapshot[] private _snapshotTotalSupply;

    function transfer(address _to, uint256 _value) public returns (bool result) {
        result = super.transfer(_to, _value);
        createSnapshot(msg.sender, _to);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool result) {
        result = super.transferFrom(_from, _to, _value);
        createSnapshot(_from, _to);
    }

    function balanceOfAt(address _owner, uint _blockNumber) public view returns (uint256) {
        return getValueAt(_snapshotBalances[_owner], _blockNumber);
    }

    function totalSupplyAt(uint _blockNumber) public view returns(uint256) {
        return getValueAt(_snapshotTotalSupply, _blockNumber);
    }

    function createSnapshot(address _from, address _to) internal {
        updateValueAtNow(_snapshotBalances[_from], balanceOf(_from));
        updateValueAtNow(_snapshotBalances[_to], balanceOf(_to));
    }

    function getValueAt(Snapshot[] storage checkpoints, uint _block) internal view returns (uint) {
        if (checkpoints.length == 0) return 0;

        if (_block >= checkpoints[checkpoints.length.sub(1)].fromBlock) {
            return checkpoints[checkpoints.length.sub(1)].value;
        }

        if (_block < checkpoints[0].fromBlock) {
            return 0;
        } 

        uint min;
        uint max = checkpoints.length.sub(1);

        while (max > min) {
            uint mid = (max.add(min).add(1)).div(2);
            if (checkpoints[mid].fromBlock <= _block) {
                min = mid;
            } else {
                max = mid.sub(1);
            }
        }

        return checkpoints[min].value;
    }

    function updateValueAtNow(Snapshot[] storage checkpoints, uint _value) internal {
        if ((checkpoints.length == 0) || (checkpoints[checkpoints.length.sub(1)].fromBlock < block.number)) {
            checkpoints.push(Snapshot(uint128(block.number), uint128(_value)));
        } else {
            checkpoints[checkpoints.length.sub(1)].value = uint128(_value);
        }
    }
}


pragma solidity ^0.5.4;  



contract ERC20ForcedTransfer is Ownable, ERC20 {
    event ForcedTransfer(address indexed account, uint256 amount, address indexed receiver);

    function forceTransfer(address _confiscatee, address _receiver) public onlyOwner {
        uint256 balance = balanceOf(_confiscatee);
        _transfer(_confiscatee, _receiver, balance);
        emit ForcedTransfer(_confiscatee, balance, _receiver);
    }
}


pragma solidity ^0.5.4;  



contract ERC20Whitelist is Ownable, ERC20 {   
    GlobalWhitelist public whitelist;
    bool public isWhitelisting = true;  // default to true

    event ESTWhitelistingEnabled();
    event ESTWhitelistingDisabled();

    function toggleWhitelist() external onlyOwner {
        isWhitelisting ? isWhitelisting = false : isWhitelisting = true;
        if (isWhitelisting) {
            emit ESTWhitelistingEnabled();
        } else {
            emit ESTWhitelistingDisabled();
        }
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        if (checkWhitelistEnabled()) {
            checkIfWhitelisted(msg.sender);
            checkIfWhitelisted(_to);
        }
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        if (checkWhitelistEnabled()) {
            checkIfWhitelisted(_from);
            checkIfWhitelisted(_to);
        }
        return super.transferFrom(_from, _to, _value);
    }

    function checkWhitelistEnabled() public view returns (bool) {
        if (isWhitelisting) {
            if (whitelist.isWhitelisting()) {
                return true;
            }
        }

        return false;
    }

    function checkIfWhitelisted(address _account) internal view {
        require(whitelist.isWhitelisted(_account), "not whitelisted");
    }
}

 
 pragma solidity ^0.5.4;



contract ERC20DocumentRegistry is Ownable {
    using SafeMath for uint256;

    struct HashedDocument {
        uint256 timestamp;
        string documentUri;
    }

    HashedDocument[] private _documents;

    event LogDocumentedAdded(string documentUri, uint256 documentIndex);

    function addDocument(string memory documentUri) public onlyOwner {
        require(bytes(documentUri).length > 0, "invalid documentUri");

        HashedDocument memory document = HashedDocument({
            timestamp: block.timestamp,
            documentUri: documentUri
        });

        _documents.push(document);

        emit LogDocumentedAdded(documentUri, _documents.length.sub(1));
    }

    function currentDocument() public view 
        returns (uint256 timestamp, string memory documentUri, uint256 index) {
            require(_documents.length > 0, "no documents exist");
            uint256 last = _documents.length.sub(1);

            HashedDocument storage document = _documents[last];
            return (document.timestamp, document.documentUri, last);
        }

    function getDocument(uint256 documentIndex) public view
        returns (uint256 timestamp, string memory documentUri, uint256 index) {
            require(documentIndex < _documents.length, "invalid index");

            HashedDocument storage document = _documents[documentIndex];
            return (document.timestamp, document.documentUri, documentIndex);
        }

    function documentCount() public view returns (uint256) {
        return _documents.length;
    }
}


pragma solidity ^0.5.4;



contract SampleToken is Ownable, ERC20, ERC20Detailed {
    constructor(string memory _name, string memory _symbol, uint8 _decimal, uint256 _initialSupply, address _recipient)
        public 
        ERC20Detailed(_name, _symbol, _decimal) {
            _mint(_recipient, _initialSupply);
        }
}


pragma solidity ^0.5.4;



contract SampleTokenFactory is Ownable, Manageable {
    address public whitelist;

    event NewTokenDeployed(address indexed contractAddress, string name, string symbol, uint8 decimals);
   

    function newToken(string memory _name, string memory _symbol, uint8 _decimals, uint256 _initialSupply, address _recipient) 
        public 
        onlyManager 
        onlyValidAddress(_recipient)
        returns (address) {
            require(bytes(_name).length > 0, "name cannot be blank");
            require(bytes(_symbol).length > 0, "symbol cannot be blank");
            require(_initialSupply > 0, "supply cannot be 0");

            SampleToken token = new SampleToken(_name, _symbol, _decimals, _initialSupply, _recipient);

            emit NewTokenDeployed(address(token), _name, _symbol, _decimals);
            
            return address(token);
        }
}

