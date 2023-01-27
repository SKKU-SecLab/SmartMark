

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

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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


pragma solidity ^0.5.0;




contract ERC20 is Context, IERC20 {

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

    function _approve(address owner, address spender, uint256 amount) internal {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {

        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}


pragma solidity ^0.5.0;



contract ERC20Burnable is Context, ERC20 {

    function burn(uint256 amount) public {

        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public {

        _burnFrom(account, amount);
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



contract MinterRole is Context {

    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    constructor () internal {
        _addMinter(_msgSender());
    }

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


pragma solidity ^0.5.0;



contract ERC20Mintable is ERC20, MinterRole {

    function mint(address account, uint256 amount) public onlyMinter returns (bool) {

        _mint(account, amount);
        return true;
    }
}


pragma solidity 0.5.17;




contract BridgedToken is ERC20Burnable, ERC20Detailed, ERC20Mintable {

    address public ethTokenAddr;
    constructor(
        address _ethTokenAddr,
        string memory name,
        string memory symbol,
        uint8 decimals
    ) public ERC20Detailed(name, symbol, decimals) {
        ethTokenAddr = _ethTokenAddr;
    }
}


pragma solidity 0.5.17;




contract TokenManager is Ownable {

    mapping(address => address) public mappedTokens;

    event TokenMapAck(address indexed tokenReq, address indexed tokenAck);

    mapping(address => uint256) public wards;

    function rely(address guy) external onlyOwner {

        wards[guy] = 1;
    }

    function deny(address guy) external onlyOwner {

        require(guy != owner(), "TokenManager/cannot deny the owner");
        wards[guy] = 0;
    }

    modifier auth {

        require(wards[msg.sender] == 1, "TokenManager/not-authorized");
        _;
    }

    function addToken(
        address ethTokenAddr,
        string memory name,
        string memory symbol,
        uint8 decimals
    ) public auth returns (address) {

        require(
            ethTokenAddr != address(0),
            "TokenManager/ethToken is a zero address"
        );
        require(
            mappedTokens[ethTokenAddr] == address(0),
            "TokenManager/ethToken already mapped"
        );

        BridgedToken bridgedToken = new BridgedToken(
            ethTokenAddr,
            name,
            symbol,
            decimals
        );
        address bridgedTokenAddr = address(bridgedToken);

        mappedTokens[ethTokenAddr] = bridgedTokenAddr;

        bridgedToken.addMinter(msg.sender);

        emit TokenMapAck(ethTokenAddr, bridgedTokenAddr);
        return bridgedTokenAddr;
    }

    function registerToken(address ethTokenAddr, address oneTokenAddr)
        public
        auth
        returns (bool)
    {

        require(
            ethTokenAddr != address(0),
            "TokenManager/ethTokenAddr is a zero address"
        );
        require(
            mappedTokens[ethTokenAddr] == address(0),
            "TokenManager/ethTokenAddr already mapped"
        );

        mappedTokens[ethTokenAddr] = oneTokenAddr;
    }

    function removeToken(address ethTokenAddr, uint256 supply) public auth {

        require(
            mappedTokens[ethTokenAddr] != address(0),
            "TokenManager/ethToken mapping does not exists"
        );
        IERC20 oneToken = IERC20(mappedTokens[ethTokenAddr]);
        require(
            oneToken.totalSupply() == supply,
            "TokenManager/remove has non-zero supply"
        );
        delete mappedTokens[ethTokenAddr];
    }
}


pragma solidity 0.5.17;



interface MintableToken {

    function mint(address beneficiary, uint256 amount) external returns (bool);

}

interface BurnableToken {

    function burnFrom(address account, uint256 amount) external;

}

contract HRC20EthManager {

    mapping(bytes32 => bool) public usedEvents_;
    mapping(address => address) public mappings;

    event Burned(
        address indexed token,
        address indexed sender,
        uint256 amount,
        address recipient
    );

    event Minted(
        address ethToken,
        uint256 amount,
        address recipient,
        bytes32 receiptId
    );

    address public wallet;
    modifier onlyWallet {

        require(msg.sender == wallet, "EthManager/not-authorized");
        _;
    }

    constructor(address _wallet) public {
        wallet = _wallet;
    }

    function addToken(
        address tokenManager,
        address hmyTokenAddr,
        string memory name,
        string memory symbol,
        uint8 decimals
    ) public {

        address ethTokenAddr = TokenManager(tokenManager).addToken(
            hmyTokenAddr,
            name,
            symbol,
            decimals
        );
        mappings[hmyTokenAddr] = ethTokenAddr;
    }

    function removeToken(address tokenManager, address hmyTokenAddr) public {

        TokenManager(tokenManager).removeToken(hmyTokenAddr, 0);
    }

    function burnToken(
        address ethToken,
        uint256 amount,
        address recipient
    ) public {

        BurnableToken(ethToken).burnFrom(msg.sender, amount);
        emit Burned(ethToken, msg.sender, amount, recipient);
    }

    function mintToken(
        address ethToken,
        uint256 amount,
        address recipient,
        bytes32 receiptId
    ) public onlyWallet {

        require(
            !usedEvents_[receiptId],
            "EthManager/The lock event cannot be reused"
        );
        usedEvents_[receiptId] = true;
        MintableToken(ethToken).mint(recipient, amount);
        emit Minted(ethToken, amount, recipient, receiptId);
    }
}