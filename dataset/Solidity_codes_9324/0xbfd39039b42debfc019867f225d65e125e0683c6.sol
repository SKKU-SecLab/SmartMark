
pragma solidity >=0.6.0 <0.8.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(value)));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(value)));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(value)));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint256(_at(set._inner, index)));
    }



    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity >=0.6.0 <0.8.0;

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
}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
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

}// MIT

pragma solidity >=0.6.0 <0.8.0;


abstract contract Pausable is Context {
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

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}// MIT

pragma solidity >=0.6.2 <0.8.0;

library Address {
    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;


abstract contract AccessControl is Context {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }

    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }

    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, _roles[role].adminRole, adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// UNLICENSED
pragma solidity ^0.7.0;


abstract contract Roles is Ownable, AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    EnumerableSet.AddressSet _admins;

    constructor(address[3] memory accounts) {
        _setRoleAdmin(ADMIN_ROLE, DEFAULT_ADMIN_ROLE);

        for (uint256 i = 0; i < accounts.length; ++i) {
            if (accounts[i] != address(0)) {
                _setupRole(DEFAULT_ADMIN_ROLE, accounts[i]);
                _setupRole(ADMIN_ROLE, accounts[i]);
                _admins.add(accounts[i]);
            }
        }
    }

    modifier onlySuperAdmin() {
        require(isSuperAdmin(_msgSender()), "Restricted to super admins.");
        _;
    }

    modifier onlyAdmin() {
        require(isAdmin(_msgSender()), "Restricted to admins.");
        _;
    }

    modifier onlySuperAdminOrAdmin() {
        require(
            isSuperAdmin(_msgSender()) || isAdmin(_msgSender()),
            "Restricted to super admins or admins."
        );
        _;
    }

    function addSuperAdmin(address account)
        public
        onlySuperAdmin
    {
        grantRole(DEFAULT_ADMIN_ROLE, account);
        _admins.add(account);
    }

    function renounceSuperAdmin()
        public
        onlySuperAdmin
    {
        renounceRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _admins.remove(_msgSender());
    }

    function addAdmin(address account)
        public
        onlySuperAdmin
    {
        grantRole(ADMIN_ROLE, account);
        _admins.add(account);
    }

    function removeAdmin(address account)
        public
        onlySuperAdmin
    {
        revokeRole(ADMIN_ROLE, account);
        _admins.remove(account);
    }

    function renounceAdmin()
        public
        onlyAdmin
    {
        renounceRole(ADMIN_ROLE, _msgSender());
        _admins.remove(_msgSender());
    }

    function isSuperAdmin(address account)
        public
        view
        returns (bool)
    {
        return hasRole(DEFAULT_ADMIN_ROLE, account);
    }

    function isAdmin(address account)
        public
        view
        returns (bool)
    {
        return hasRole(ADMIN_ROLE, account);
    }
}// UNLICENSED
pragma solidity ^0.7.0;



abstract contract Pause is Pausable, Roles {
    function pause()
        public
        virtual
        onlySuperAdminOrAdmin
    {
        if (!paused()) {
            _pause();
        }
    }

    function unpause()
        public
        virtual
        onlySuperAdminOrAdmin
    {
        if (paused()) {
            _unpause();
        }
    }
}// UNLICENSED
pragma solidity ^0.7.0;



contract ZionodesToken is ERC20, Pause {
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeMath for uint256;

    uint256 public _fee;
    uint256 public _feeDecimals;

    address public _factory;
    address public _collector;
    address public _balancerPool;

    EnumerableSet.AddressSet _transferWhitelist;

    constructor
    (
        string memory name,
        string memory symbol,
        uint8 decimals,
        uint256 totalSupply,
        address factoryAdmin
    )
        ERC20(name, symbol)
        Roles([factoryAdmin, _msgSender(), address(this)])
    {
        _setupDecimals(decimals);

        _transferWhitelist.add(_msgSender());
        _transferWhitelist.add(address(0));

        _factory = _msgSender();
        _feeDecimals = 18;
        _fee = 0.01 * (10 ** 18);
        _collector = factoryAdmin;

        _mint(_factory, totalSupply);
    }

    function setFee(uint256 fee)
        external
        onlySuperAdminOrAdmin
    {
        _fee = fee;
    }

    function setBalancerPoolAddress(address balancerPool)
        external
        onlySuperAdminOrAdmin
    {
        require(balancerPool != address(0), "Can not be zero address");
        require(balancerPool != _msgSender(), "Can not be the same like caller");
        require(balancerPool != _balancerPool, "Can not be the same like old one");

        _balancerPool = balancerPool;
        _transferWhitelist.add(_balancerPool);
    }

    function addToTransferWhitelist(address account)
        external
        onlySuperAdminOrAdmin
    {
        _transferWhitelist.add(account);
    }

    function removeFromTransferWhitelist(address account)
        external
        onlySuperAdminOrAdmin
    {
        _transferWhitelist.remove(account);
    }

    function setCollector(address newCollector)
        external
        onlySuperAdminOrAdmin
    {
        require(newCollector != address(0), "Can not be zero address");
        require(
            newCollector != _collector,
            "Can not be the same as the current collector address"
        );

        _collector = newCollector;
    }

    function mint(address account, uint256 amount)
        external
        onlySuperAdminOrAdmin
    {
        _mint(account, amount);
    }

    function burn(uint256 amount)
        external
    {
        _burn(_msgSender(), amount);
    }

    function getFeeForAmount(uint256 amount)
        public
        view
        returns (uint256)
    {
        return _fee.mul(amount).div(100).div(10 ** _feeDecimals);
    }

    function getTotalSupplyExceptAdmins()
        external
        view
        returns (uint256)
    {
        uint256 adminBalances = 0;

        for (uint256 i = 0; i < _admins.length(); ++i) {
            adminBalances = adminBalances.add(balanceOf(_admins.at(i)));
        }

        return totalSupply().sub(adminBalances).add(balanceOf(_factory));
    }

    function isInTransferWhitelist(address account)
        external
        view
        returns (bool)
    {
        return _transferWhitelist.contains(account);
    }

    function _transfer(address sender, address recipient, uint256 amount)
        internal
        override
    {
        if (_transferWhitelist.contains(sender) || recipient == _balancerPool) {
            super._transfer(sender, recipient, amount);
        } else {
            uint256 fee = getFeeForAmount(amount);

            super._transfer(sender, recipient, amount.sub(fee));
            super._transfer(sender, _collector, fee);
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        override
    {
        require(!paused(), "ERC20: token transfer while paused");
    }
}// UNLICENSED
pragma solidity ^0.7.0;


interface IZToken is IERC20 {
    function pause() external;

    function unpause() external;

    function addSuperAdmin(address account) external;

    function renounceSuperAdmin() external;

    function addAdmin(address account) external;

    function removeAdmin(address account) external;

    function renounceAdmin() external;

    function isSuperAdmin(address account) external view returns (bool);

    function isAdmin(address account) external view returns (bool);
}// UNLICENSED
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;





contract ZionodesTokenFactory is Pause {
    using SafeMath for uint256;

    struct ZToken {
        ZionodesToken token;
        uint256 weiPrice;
        bool initialized;
        mapping(address => uint256) prices;
    }

    struct Price {
        uint256 price;
        address addr;
    }

    struct ZTokenInfo {
        address zAddress;
        string zName;
        string zSymbol;
        uint256 decimals;
    }

    address public paymentAddress;

    ZTokenInfo[] public _zTokensInfo;

    mapping(address => ZToken) public _zTokens;
    mapping(string => address) public _zTokenAdressess;

    event ZTokenSold(
        address indexed zAddress,
        address indexed buyer,
        uint256 amount
    );

    modifier zTokenExistsAndNotPaused(address zAddress) {
        require(_zTokens[zAddress].initialized, "Token isn't deployed");
        require(!_zTokens[zAddress].token.paused(), "Token is paused");
        _;
    }

    modifier onlyCorrectAddress(address destination) {
        require(destination != address(0), "Zero address");
        require(destination != address(this), "Identical addresses");
        _;
    }

    constructor ()
        Roles([_msgSender(), address(this), address(0)])
    {
        paymentAddress = address(this);
    }

    function deployZToken
    (
        string memory zName,
        string memory zSymbol,
        uint8 decimals,
        uint256 totalSupply
    )
        external
        onlySuperAdminOrAdmin
        returns (address)
    {
        require(
            _zTokenAdressess[zSymbol] == address(0) ||
            _zTokens[_zTokenAdressess[zSymbol]].token.paused(),
            "Token exists and not paused"
        );

        ZionodesToken tok = new ZionodesToken(
            zName,
            zSymbol,
            decimals,
            totalSupply,
            owner()
        );

        ZToken storage zToken = _zTokens[address(tok)];
        zToken.token = tok;
        zToken.weiPrice = 0;
        zToken.initialized = true;

        _zTokenAdressess[zSymbol] = address(tok);
        _zTokensInfo.push(ZTokenInfo(address(tok), zName, zSymbol, decimals));

        return address(tok);
    }

    function mintZTokens(address zAddress, address account, uint256 amount)
        external
        onlySuperAdminOrAdmin
        zTokenExistsAndNotPaused(zAddress)
    {
        _zTokens[zAddress].token.mint(account, amount);
    }

    function setupWeiPriceForZToken(address zAddress, uint256 weiPrice)
        external
        onlySuperAdminOrAdmin
        zTokenExistsAndNotPaused(zAddress)
    {
        _zTokens[zAddress].weiPrice = weiPrice;
    }

    function setupERC20PricesForZToken
    (
        address zAddress,
        Price[] memory prices
    )
        external
        onlySuperAdminOrAdmin
        zTokenExistsAndNotPaused(zAddress)
    {
        for (uint256 i = 0; i < prices.length; ++i) {
            _zTokens[zAddress].prices[prices[i].addr] = prices[i].price;
        }
    }

    function setPaymentAddress(address paymentAddr)
        external
        onlySuperAdminOrAdmin
    {
        require(paymentAddr != address(0), "Zero address");
        require(paymentAddr != paymentAddress, "Identical addresses");

        paymentAddress = paymentAddr;
    }

    function buyZTokenUsingWei(address zAddress, uint256 amount)
        external
        payable
        zTokenExistsAndNotPaused(zAddress)
        returns (bool)
    {
        require(_zTokens[zAddress].weiPrice > 0, "Price not set");

        uint256 tokenDecimals = _zTokens[zAddress].token.decimals();

        require(msg.value == _zTokens[zAddress].weiPrice.mul(amount), "Not enough wei");

        _zTokens[zAddress].token.transfer(_msgSender(), amount.mul(10 ** tokenDecimals));

        if (paymentAddress != address(this)) {
            address(uint160(paymentAddress)).transfer(msg.value);
        }

        emit ZTokenSold(zAddress, _msgSender(), amount.mul(10 ** tokenDecimals));

        return true;
    }

    function buyZTokenUsingERC20Token
    (
        address zAddress,
        address addr,
        uint256 amount
    )
        external
        zTokenExistsAndNotPaused(zAddress)
        returns (bool)
    {
        require(_zTokens[zAddress].prices[addr] > 0, "Price not set");

        IZToken token = IZToken(addr);
        uint256 tokenDecimals = _zTokens[zAddress].token.decimals();

        token.transferFrom(
            _msgSender(),
            paymentAddress,
            _zTokens[zAddress].prices[addr].mul(amount)
        );
        _zTokens[zAddress].token.transfer(_msgSender(), amount.mul(10 ** tokenDecimals));

        emit ZTokenSold(zAddress, _msgSender(), amount.mul(10 ** tokenDecimals));

        return true;
    }

    function withdrawWei(address destination)
        external
        onlySuperAdminOrAdmin
        onlyCorrectAddress(destination)
        returns (bool)
    {
        address(uint160(destination)).transfer(address(this).balance);

        return true;
    }

    function withdrawERC20Token(address addr, address destination)
        external
        onlySuperAdminOrAdmin
        onlyCorrectAddress(destination)
        returns (bool)
    {
        IZToken token = IZToken(addr);

        return token.transfer(destination, token.balanceOf(address(this)));
    }

    function getZTokenPriceByERC20Token
    (
        address zAddress,
        address addr
    )
        external
        view
        returns (uint256)
    {
        return _zTokens[zAddress].prices[addr];
    }

    function getZTokensInfo()
        external
        view
        returns (ZTokenInfo[] memory)
    {
        return _zTokensInfo;
    }
}