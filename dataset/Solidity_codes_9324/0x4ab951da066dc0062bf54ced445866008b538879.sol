
pragma solidity 0.6.2;


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;


            bytes32 accountHash
         = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }
}

library EnumerableSet {


    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) {

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

    function _contains(Set storage set, bytes32 value)
        private
        view
        returns (bool)
    {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index)
        private
        view
        returns (bytes32)
    {

        require(
            set._values.length > index,
            "EnumerableSet: index out of bounds"
        );
        return set._values[index];
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value)
        internal
        returns (bool)
    {

        return _add(set._inner, bytes32(uint256(value)));
    }

    function remove(AddressSet storage set, address value)
        internal
        returns (bool)
    {

        return _remove(set._inner, bytes32(uint256(value)));
    }

    function contains(AddressSet storage set, address value)
        internal
        view
        returns (bool)
    {

        return _contains(set._inner, bytes32(uint256(value)));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index)
        internal
        view
        returns (address)
    {

        return address(uint256(_at(set._inner, index)));
    }


    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value)
        internal
        returns (bool)
    {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value)
        internal
        view
        returns (bool)
    {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index)
        internal
        view
        returns (uint256)
    {

        return uint256(_at(set._inner, index));
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface ITST {

    function setFeeAccount(address feeAccount) external returns (bool);


    function setMaxTransferFee(uint256 maxTransferFee) external returns (bool);


    function setMinTransferFee(uint256 minTransferFee) external returns (bool);


    function setTransferFeePercentage(uint256 transferFeePercentage)
        external
        returns (bool);


         
    function calculateTransferFee(address sender, uint256 weiAmount) external view returns(uint256) ;



    function feeAccount() external view returns (address);


    function maxTransferFee() external view returns (uint256);


    function minTransferFee() external view returns (uint256);



    function transferFeePercentage() external view returns (uint256);


    function transfer(
        address recipient,
        uint256 amount,
        string calldata message
    ) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount,
        string calldata message
    ) external returns (bool);


    event Created();

    event FeeAccountUpdated(
        address indexed previousFeeAccount,
        address indexed newFeeAccount
    );

    event MaxTransferFeeUpdated(
        uint256 previousMaxTransferFee,
        uint256 newMaxTransferFee
    );

    event MinTransferFeeUpdated(
        uint256 previousMinTransferFee,
        uint256 newMinTransferFee
    );

    event TransferFeePercentageUpdated(
        uint256 previousTransferFeePercentage,
        uint256 newTransferFeePercentage
    );

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value,
        uint256 fee,
        string description,
        uint256 timestamp
    );
}

contract Initializable {

    bool private initialized;

    bool private initializing;

    modifier initializer() {

        require(
            initializing || isConstructor() || !initialized,
            "Contract instance has already been initialized"
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

        address self = address(this);
        uint256 cs;
        assembly {
            cs := extcodesize(self)
        }
        return cs == 0;
    }

    uint256[50] private ______gap;
}

contract ContextUpgradeSafe is Initializable {


    function __Context_init() internal initializer {

        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {}


    function _msgSender() internal virtual view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal virtual view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    uint256[50] private __gap;
}

contract OwnableUpgradeSafe is Initializable, ContextUpgradeSafe {

    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );


    function __Ownable_init() internal initializer {

        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {

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

        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    uint256[49] private __gap;
}

contract PausableUpgradeSafe is Initializable, ContextUpgradeSafe {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;


    function __Pausable_init() internal initializer {

        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {

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

    uint256[49] private __gap;
}

abstract contract AccessControlUpgradeSafe is
    Initializable,
    ContextUpgradeSafe
{
    function __AccessControl_init() internal initializer {
        __Context_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {}

    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleGranted(
        bytes32 indexed role,
        address indexed account,
        address indexed sender
    );

    event RoleRevoked(
        bytes32 indexed role,
        address indexed account,
        address indexed sender
    );

    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }

    function getRoleMember(bytes32 role, uint256 index)
        public
        view
        returns (address)
    {
        return _roles[role].members.at(index);
    }

    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual {
        require(
            hasRole(_roles[role].adminRole, _msgSender()),
            "AccessControl: sender must be an admin to grant"
        );

        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual {
        require(
            hasRole(_roles[role].adminRole, _msgSender()),
            "AccessControl: sender must be an admin to revoke"
        );

        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual {
        require(
            account == _msgSender(),
            "AccessControl: can only renounce roles for self"
        );

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
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

    uint256[49] private __gap;
}

abstract contract IRelayRecipient {
    function isTrustedForwarder(address forwarder)
        public
        virtual
        view
        returns (bool);

    function _msgSender() internal virtual view returns (address payable);

    function _msgData() internal virtual view returns (bytes memory);

    function versionRecipient() external virtual view returns (string memory);
}

abstract contract BaseRelayRecipient is IRelayRecipient {
    address public trustedForwarder;

    function isTrustedForwarder(address forwarder)
        public
        override
        view
        returns (bool)
    {
        return forwarder == trustedForwarder;
    }

    function _msgSender()
        internal
        virtual
        override
        view
        returns (address payable ret)
    {
        if (msg.data.length >= 24 && isTrustedForwarder(msg.sender)) {
            assembly {
                ret := shr(96, calldataload(sub(calldatasize(), 20)))
            }
        } else {
            return msg.sender;
        }
    }

    function _msgData()
        internal
        virtual
        override
        view
        returns (bytes memory ret)
    {
        if (msg.data.length >= 24 && isTrustedForwarder(msg.sender)) {
            assembly {
                let ptr := mload(0x40)
                let size := sub(calldatasize(), 20)
                mstore(ptr, 0x20)
                mstore(add(ptr, 32), size)
                calldatacopy(add(ptr, 64), 0, size)
                return(ptr, add(size, 64))
            }
        } else {
            return msg.data;
        }
    }
}

contract ERC20UpgradeSafe is Initializable, ContextUpgradeSafe, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;


    function __ERC20_init(string memory name, string memory symbol)
        internal
        initializer
    {

        __Context_init_unchained();
        __ERC20_init_unchained(name, symbol);
    }

    function __ERC20_init_unchained(string memory name, string memory symbol)
        internal
        initializer
    {

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

    function totalSupply() public override view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public override view returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        virtual
        override
        view
        returns (uint256)
    {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {

        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {

        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
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

        _balances[account] = _balances[account].sub(
            amount,
            "ERC20: burn amount exceeds balance"
        );
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    uint256[44] private __gap;
}

abstract contract ERC20PausableUpgradeSafe is
    Initializable,
    ERC20UpgradeSafe,
    PausableUpgradeSafe
{
    function __ERC20Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
        __ERC20Pausable_init_unchained();
    }

    function __ERC20Pausable_init_unchained() internal initializer {}

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        require(!paused(), "ERC20Pausable: token transfer while paused");
    }

    uint256[50] private __gap;
}

abstract contract ERC20BurnableUpgradeSafe is
    Initializable,
    ContextUpgradeSafe,
    ERC20UpgradeSafe
{
    function __ERC20Burnable_init() internal initializer {
        __Context_init_unchained();
        __ERC20Burnable_init_unchained();
    }

    function __ERC20Burnable_init_unchained() internal initializer {}

    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(
            amount,
            "ERC20: burn amount exceeds allowance"
        );

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
    }

    uint256[50] private __gap;
}

abstract contract TransferFee is OwnableUpgradeSafe, ITST {
    address private _feeAccount;
    uint256 private _maxTransferFee;
    uint256 private _minTransferFee;
    uint256 private _transferFeePercentage;

    function __TransferFee_init_unchained(
        address feeAccount,
        uint256 maxTransferFee,
        uint256 minTransferFee,
        uint256 transferFeePercentage
    ) public {
        require(feeAccount != address(0x0), "TransferFee: feeAccount is 0");

        require(
            maxTransferFee >= minTransferFee,
            "TransferFee: maxTransferFee should be greater than minTransferFee"
        );

        __Ownable_init_unchained();

        _feeAccount = feeAccount;
        _maxTransferFee = maxTransferFee;
        _minTransferFee = minTransferFee;
        _transferFeePercentage = transferFeePercentage;
    }

    function setFeeAccount(address feeAccount)
        external
        override
        onlyOwner
        returns (bool)
    {
        require(feeAccount != address(0x0), "TransferFee: feeAccount is 0");

        emit FeeAccountUpdated(_feeAccount, feeAccount);
        _feeAccount = feeAccount;
        return true;
    }

    function setMaxTransferFee(uint256 maxTransferFee)
        external
        override
        onlyOwner
        returns (bool)
    {
        require(
            maxTransferFee >= _minTransferFee,
            "TransferFee: maxTransferFee should be greater or equal to minTransferFee"
        );

        emit MaxTransferFeeUpdated(_maxTransferFee, maxTransferFee);
        _maxTransferFee = maxTransferFee;
        return true;
    }

    function setMinTransferFee(uint256 minTransferFee)
        external
        override
        onlyOwner
        returns (bool)
    {
        require(
            minTransferFee <= _maxTransferFee,
            "TransferFee: minTransferFee should be less than maxTransferFee"
        );

        emit MaxTransferFeeUpdated(_minTransferFee, minTransferFee);
        _minTransferFee = minTransferFee;
        return true;
    }

    function setTransferFeePercentage(uint256 transferFeePercentage)
        external
        override
        onlyOwner
        returns (bool)
    {
        emit TransferFeePercentageUpdated(
            _transferFeePercentage,
            transferFeePercentage
        );
        _transferFeePercentage = transferFeePercentage;
        return true;
    }


    function feeAccount() public override view returns (address) {
        return _feeAccount;
    }

    function maxTransferFee() public override view returns (uint256) {
        return _maxTransferFee;
    }

    function minTransferFee() public override view returns (uint256) {
        return _minTransferFee;
    }


    function transferFeePercentage() public override view returns (uint256) {
        return _transferFeePercentage;
    }

    uint256[50] private __gap;
}

contract TST is
    Initializable,
    ContextUpgradeSafe,
    OwnableUpgradeSafe,
    AccessControlUpgradeSafe,
    ERC20BurnableUpgradeSafe,
    ERC20PausableUpgradeSafe,
    BaseRelayRecipient,
    TransferFee
{

    mapping(address => bool) public feeWaived;
    mapping(address => bool) public blacklisted;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    event AddedBlackList(address account);
    event AddedFeeWaived(address account);
    event RemovedBlackList(address account);
    event RemovedFeeWaived(address account);


    function initialize(
        address owner,
        string memory name,
        string memory symbol,
        address feeAccount,
        uint256 maxTransferFee,
        uint256 minTransferFee,
        uint256 transferFeePercentage
    ) public {

        __TST_init(
            owner,
            name,
            symbol,
            feeAccount,
            maxTransferFee,
            minTransferFee,
            transferFeePercentage
        );
    }

    function __TST_init(
        address owner,
        string memory name,
        string memory symbol,
        address feeAccount,
        uint256 maxTransferFee,
        uint256 minTransferFee,
        uint256 transferFeePercentage
    ) internal initializer {

        __Context_init_unchained();
        __Ownable_init_unchained();
        __AccessControl_init_unchained();
        __ERC20_init_unchained(name, symbol);
        __ERC20Burnable_init_unchained();
        __Pausable_init_unchained();
        __ERC20Pausable_init_unchained();
        __TST_init_unchained(owner);
        __TransferFee_init_unchained(
            feeAccount,
            maxTransferFee,
            minTransferFee,
            transferFeePercentage
        );
    }

    function __TST_init_unchained(address owner) internal initializer {

        _setupDecimals(2);
        _setupRole(DEFAULT_ADMIN_ROLE, owner);
        _setupRole(MINTER_ROLE, owner);
        _setupRole(PAUSER_ROLE, owner);
        _setupRole(BURNER_ROLE, owner);
        transferOwnership(owner);
        emit Created();
    }

    function mint(address to, uint256 amount) public virtual {

        require(
            hasRole(MINTER_ROLE, _msgSender()),
            "TST: must have minter role to mint"
        );
        require(
            to == owner(),
            "TST: tokens can be only minted on owner address"
        );
        _mint(to, amount);
    }

    function burn(address account, uint256 amount) public virtual {

        require(
            hasRole(BURNER_ROLE, _msgSender()),
            "TST: must have burner role to burn"
        );
        _burn(account, amount);
    }

    function pause() public {

        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "TST: must have pauser role to pause"
        );
        _pause();
    }

    function unpause() public {

        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "TST: must have pauser role to unpause"
        );
        _unpause();
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override(ERC20UpgradeSafe)
        returns (bool)
    {

        require(
            recipient != address(this),
            "ERC20: transfer to the this contract"
        );
        uint256 _fee = calculateTransferFee(_msgSender(), amount);

        super.transfer(recipient, amount);

        if (_fee > 0) super.transfer(feeAccount(), _fee); // transfering fee to fee account
        emit Transfer(_msgSender(), recipient, amount, _fee, "", now);
        return true;
    }

    function transfer(
        address recipient,
        uint256 amount,
        string memory message
    ) public virtual override(ITST) returns (bool) {

        require(
            recipient != address(this),
            "ERC20: transfer to the this contract"
        );
        uint256 _fee = calculateTransferFee(_msgSender(), amount);

        super.transfer(recipient, amount);

        if (_fee > 0) super.transfer(feeAccount(), _fee); // transfering fee to fee account
        emit Transfer(_msgSender(), recipient, amount, _fee, message, now);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override(ERC20UpgradeSafe) returns (bool) {

        require(
            recipient != address(this),
            "ERC20: transfer to the this contract"
        );
        uint256 _fee = calculateTransferFee(sender, amount);

        super.transferFrom(sender, recipient, amount);

        if (_fee > 0) super.transferFrom(sender, feeAccount(), _fee); // transfering fee to fee account
        emit Transfer(sender, recipient, amount, _fee, "", now);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount,
        string memory message
    ) public virtual override(ITST) returns (bool) {

        require(
            recipient != address(this),
            "ERC20: transfer to the this contract"
        );
        uint256 _fee = calculateTransferFee(sender, amount);

        super.transferFrom(sender, recipient, amount);

        if (_fee > 0) super.transferFrom(sender, feeAccount(), _fee); // transfering fee to fee account
        emit Transfer(sender, recipient, amount, _fee, message, now);
        return true;
    }

    function addBlackList(address account) external onlyOwner returns (bool) {

        blacklisted[account] = true;
        emit AddedBlackList(account);
        return true;
    }

    function removeBlackList(address account)
        external
        onlyOwner
        returns (bool)
    {

        blacklisted[account] = false;
        emit RemovedBlackList(account);
        return true;
    }

    function addFeeWaived(address account) external onlyOwner returns (bool) {

        feeWaived[account] = true;
        emit AddedFeeWaived(account);
        return true;
    }

    function removeFeeWaived(address account)
        external
        onlyOwner
        returns (bool)
    {

        feeWaived[account] = false;
        emit RemovedFeeWaived(account);
        return true;
    }

    function calculateTransferFee(address sender, uint256 weiAmount)
        public
        virtual
        override(ITST)
        view
        returns (uint256)
    {

        if (feeWaived[sender] == true) return 0;

        uint256 divisor = uint256(100).mul((10**uint256(decimals())));
        uint256 _fee = (transferFeePercentage().mul(weiAmount)).div(divisor);

        if (_fee < minTransferFee()) {
            _fee = minTransferFee();
        } else if (_fee > maxTransferFee()) {
            _fee = maxTransferFee();
        }

        return _fee;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20UpgradeSafe, ERC20PausableUpgradeSafe) {

        super._beforeTokenTransfer(from, to, amount);

        require(
            !blacklisted[from],
            "TST: token transfer from blacklisted account"
        );
        require(!blacklisted[to], "TST: token transfer to blacklisted account");
    }


    function setTrustedForwarder(address forwarder) external onlyOwner {

        trustedForwarder = forwarder;
    }

    function _msgSender()
        internal
        override(BaseRelayRecipient, ContextUpgradeSafe)
        view
        returns (address payable)
    {

        return BaseRelayRecipient._msgSender();
    }

    function _msgData()
        internal
        override(BaseRelayRecipient, ContextUpgradeSafe)
        view
        returns (bytes memory)
    {

        return BaseRelayRecipient._msgData();
    }

    function versionRecipient() external override view returns (string memory) {

        return "2.0.0";
    }


    function increaseSupply(address target, uint256 amount) external virtual {

        mint(target, amount);
    }

    function decreaseSupply(address target, uint256 amount) external virtual {

        burn(target, amount);
    }

    function getOwner() external view returns (address) {

        return owner();
    }

    function getName() external view returns (string memory) {

        return name();
    }

    function getFeeAccount() external view returns (address) {

        return feeAccount();
    }

    function getTotalSupply() external view returns (uint256) {

        return totalSupply();
    }

    function getMaxTransferFee() external view returns (uint256) {

        return maxTransferFee();
    }

    function getMinTransferFee() external view returns (uint256) {

        return minTransferFee();
    }

    function getTransferFeePercentage() external view returns (uint256) {

        return transferFeePercentage();
    }

    function getBalance(address balanceAddress)
        external
        virtual
        view
        returns (uint256)
    {

        return balanceOf(balanceAddress);
    }

    uint256[50] private __gap;
}