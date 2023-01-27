

pragma solidity >=0.4.24 <0.7.0;


contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

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
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}


pragma solidity ^0.6.0;


contract ContextUpgradeSafe is Initializable {


    function __Context_init() internal initializer {

        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {



    }


    function _msgSender() internal view virtual returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    uint256[50] private __gap;
}


pragma solidity ^0.6.0;

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
}


pragma solidity ^0.6.2;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}


pragma solidity ^0.6.0;





abstract contract AccessControlUpgradeSafe is Initializable, ContextUpgradeSafe {
    function __AccessControl_init() internal initializer {
        __Context_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {


    }

    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

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


pragma solidity ^0.6.0;

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


pragma solidity ^0.6.0;

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


pragma solidity ^0.6.0;






contract ERC20UpgradeSafe is Initializable, ContextUpgradeSafe, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;


    function __ERC20_init(string memory name, string memory symbol) internal initializer {

        __Context_init_unchained();
        __ERC20_init_unchained(name, symbol);
    }

    function __ERC20_init_unchained(string memory name, string memory symbol) internal initializer {



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


    uint256[44] private __gap;
}


pragma solidity ^0.6.0;

library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        if (signature.length != 65) {
            revert("ECDSA: invalid signature length");
        }

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            revert("ECDSA: invalid signature 's' value");
        }

        if (v != 27 && v != 28) {
            revert("ECDSA: invalid signature 'v' value");
        }

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}


pragma solidity ^0.6.2;



library Validate {

    using Address for address;
    using ECDSA for bytes32;

    function validateSignature(bytes32 hash, address sender, bytes memory sig) internal pure {

        bytes32 messageHash = hash.toEthSignedMessageHash();

        address signer = messageHash.recover(sig);
        require(signer == sender, "Validate: invalid signature");
    }
}


pragma solidity ^0.6.2;





abstract contract ERC20ETHless is Initializable, AccessControlUpgradeSafe, ERC20UpgradeSafe {
    using Address for address;

    mapping (address => mapping (uint256 => bool)) private _usedNonces;

    bytes32 public constant RELAYER_ROLE = keccak256("RELAYER_ROLE");

    function __ERC20ETHless_init(string memory name, string memory symbol) internal
    initializer {
        __ERC20_init_unchained(name, symbol);
        __ERC20ETHless_init_unchained();
    }

    function __ERC20ETHless_init_unchained() internal initializer {
        _setupRole(RELAYER_ROLE, _msgSender());
    }

    function transfer(address sender, address recipient, uint256 amount, uint256 fee, uint256 nonce, bytes calldata  sig)
        external returns (bool success)
    {
        uint256 senderBalance = balanceOf(sender);
        require(senderBalance >= amount.add(fee), "ERC20ETHless: the balance is not sufficient");

        _useNonce(sender, nonce);

        bytes32 hash = keccak256(abi.encodePacked(address(this), sender, recipient, amount, fee, nonce));
        Validate.validateSignature(hash, sender, sig);

        _collect(sender, fee);
        _transfer(sender, recipient, amount);

        return true;
    }

    function _useNonce(address signer, uint256 nonce) private {
        require(!_usedNonces[signer][nonce], "ERC20ETHless: the nonce has already been used for this address");
        _usedNonces[signer][nonce] = true;
    }

    function _collect(address sender, uint256 amount) internal {
        address relayer = getRoleMember(RELAYER_ROLE, 0);

        _transfer(sender, relayer, amount);
    }

    uint256[50] private __gap;
}


pragma solidity ^0.6.2;





abstract contract ERC20Reservable is Initializable, ERC20UpgradeSafe {
    using SafeMath for uint256;
    using Address for address;

    enum ReservationStatus {
        Active,
        Reclaimed,
        Completed
    }

    struct Reservation {
        uint256 _amount;
        uint256 _fee;
        address _recipient;
        address _executor;
        uint256 _expiryBlockNum;
        ReservationStatus _status;
    }

    mapping (address => mapping(uint256 => Reservation)) private _reserved;

    mapping (address => uint256) private _totalReserved;

    function __ERC20Reservable_init(string memory name, string memory symbol) internal
    initializer {
        __ERC20_init_unchained(name, symbol);
        __ERC20Reservable_init_unchained();
    }

    function __ERC20Reservable_init_unchained() internal initializer {
    }

    function getReservation(address sender, uint256 nonce) external view
        returns (
            uint256 amount,
            uint256 fee,
            address recipient,
            address executor,
            uint256 expiryBlockNum
        )
    {
        Reservation memory reservation = _reserved[sender][nonce];

        amount = reservation._amount;
        fee = reservation._fee;
        recipient = reservation._recipient;
        executor = reservation._executor;
        expiryBlockNum = reservation._expiryBlockNum;
    }

    function reservedBalanceOf(address account) external view returns (uint256 amount) {
        return balanceOf(account).sub(_unreservedBalance(account));
    }

    function unreservedBalanceOf(address account) external view returns (uint256 amount) {
        return _unreservedBalance(account);
    }

    function reserve(
        address sender,
        address recipient,
        address executor,
        uint256 amount,
        uint256 fee,
        uint256 nonce,
        uint256 expiryBlockNum,
        bytes calldata sig
    )
        external returns (bool success)
    {
        require(_reserved[sender][nonce]._expiryBlockNum == 0, "ERC20Reservable: the sender used the nonce already");

        require(expiryBlockNum > block.number, "ERC20Reservable: invalid block expiry number");
        require(executor != address(0), "ERC20Reservable: cannot execute from zero address");

        uint256 total = amount.add(fee);
        require(_unreservedBalance(sender) >= total, "ERC20Reservable: insufficient unreserved balance");

        bytes32 hash = keccak256(abi.encodePacked(address(this), sender, recipient, amount, fee, nonce));
        Validate.validateSignature(hash, sender, sig);

        _reserved[sender][nonce] = Reservation(amount, fee, recipient, executor, expiryBlockNum,
            ReservationStatus.Active);
        _totalReserved[sender] = _totalReserved[sender].add(total);

        return true;
    }

    function execute(address sender, uint256 nonce) external returns (bool success) {
        Reservation storage reservation = _reserved[sender][nonce];

        require(reservation._expiryBlockNum != 0, "ERC20Reservable: reservation does not exist");
        require(_msgSender() == sender || _msgSender() == reservation._executor,
            "ERC20Reservable: this address is not authorized to execute this reservation");
        require(reservation._expiryBlockNum > block.number,
            "ERC20Reservable: reservation has expired and cannot be executed");
        require(reservation._status == ReservationStatus.Active,
            "ERC20Reservable: invalid reservation status to execute");

        address executor = reservation._executor;
        address recipient = reservation._recipient;
        uint256 fee = reservation._fee;
        uint256 amount = reservation._amount;
        uint256 total = amount.add(fee);

        _reserved[sender][nonce]._status = ReservationStatus.Completed;
        _totalReserved[sender] = _totalReserved[sender].sub(total);

        _transfer(sender, executor, fee);
        _transfer(sender, recipient, amount);

        return true;
    }

    function reclaim(address sender, uint256 nonce) external returns (bool success) {
        Reservation storage reservation = _reserved[sender][nonce];

        require(reservation._expiryBlockNum != 0, "ERC20Reservable: reservation does not exist");
        require(_msgSender() == sender || _msgSender() == reservation._executor,
            "ERC20Reservable: only the sender or the executor can reclaim the reservation back to the sender");
        require(reservation._expiryBlockNum <= block.number || _msgSender() == reservation._executor,
            "ERC20Reservable: reservation has not expired or you are not the executor and cannot be reclaimed");
        require(reservation._status == ReservationStatus.Active,
            "ERC20Reservable: invalid reservation status to reclaim");

        _reserved[sender][nonce]._status = ReservationStatus.Reclaimed;
        _totalReserved[sender] = _totalReserved[sender].sub(reservation._amount).sub(reservation._fee);

        return true;
    }

    function _unreservedBalance(address sender) internal view returns (uint256 amount) {
        return balanceOf(sender).sub(_totalReserved[sender]);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override (ERC20UpgradeSafe) {
        if (from != address(0)) {
            require(_unreservedBalance(from) >= amount, "ERC20Reservable: transfer amount exceeds unreserved balance");
        }

        super._beforeTokenTransfer(from, to, amount);
    }

    uint256[44] private __gap;
}


pragma solidity ^0.6.2;







abstract contract ERC20Wrapper is Initializable, AccessControlUpgradeSafe, ERC20UpgradeSafe {
    using SafeMath for uint256;
    using Address for address;
    IERC20 private _token;

    mapping (address => mapping (uint256 => bool)) private _usedNonces;

    bytes32 public constant WRAPPER_ROLE = keccak256("WRAPPER_ROLE");

    event Mint(address indexed _mintTo, uint256 _value);
    event Burnt(address indexed _burnFrom, uint256 _value);

    function __ERC20Wrapper_init(string memory name, string memory symbol, uint8 decimals, IERC20 token) internal
    initializer {
        __Context_init_unchained();
        __ERC20_init_unchained(name, symbol);
        __ERC20Wrapper_init_unchained(decimals, token);
    }

    function __ERC20Wrapper_init_unchained(uint8 decimals, IERC20 token) internal virtual initializer {
        _setupDecimals(decimals);
        _setupToken(token);
        _setupRole(WRAPPER_ROLE, _msgSender());
    }

    function token() external view returns (IERC20) {
        return _token;
    }

    function mint(uint256 amount) external {
        __mint(_msgSender(), amount);
    }

    function mint(address minter,  uint256 amount, uint256 fee, uint256 nonce, bytes calldata sig) external
    {
        _useWrapperNonce(minter, nonce);

        bytes32 hash = keccak256(abi.encodePacked(address(this), minter, amount, fee, nonce));
        Validate.validateSignature(hash, minter, sig);

        __mint(minter, amount);

        address wrapper = getRoleMember(WRAPPER_ROLE, 0);
        _transfer(minter, wrapper, fee);
    }

    function burn(uint256 amount) external {
        __burn(_msgSender(), amount);
    }

    function burn(address burner, uint256 amount, uint256 fee, uint256 nonce,  bytes memory sig)  public
    {
        uint256 burnerBalance = balanceOf(burner);
        require(burnerBalance >= amount, "ERC20Wrapper: burn amount exceed balance");

        _useWrapperNonce(burner, nonce);

        bytes32 hash = keccak256(abi.encodePacked(address(this), burner, amount, fee, nonce));
        Validate.validateSignature(hash, burner, sig);

        address wrapper = getRoleMember(WRAPPER_ROLE, 0);
        _transfer(burner, wrapper, fee);

        __burn(burner, amount.sub(fee));
    }

    function __mint(address account, uint256 amount) internal {
        require(_token.transferFrom(account, address(this), amount), "ERC20Wrapper: could not deposit base tokens");

        emit Mint(account, amount);

        _mint(account, amount);
    }

    function __burn(address account, uint256 amount) internal {
        require(_token.transfer(account, amount), "ERC20Wrapper: could not withdraw base tokens");

        emit Burnt(account, amount);

        _burn(account, amount);
    }

    function _setupToken(IERC20 token_) internal {
        _token = token_;
    }

    function _useWrapperNonce(address signer, uint256 nonce) private {
        require(!_usedNonces[signer][nonce], "ERC20Wrapper: the nonce has already been used for this address");
        _usedNonces[signer][nonce] = true;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override (ERC20UpgradeSafe) {
        super._beforeTokenTransfer(from, to, amount);
    }

    uint256[44] private __gap;
}


pragma solidity ^0.6.2;






contract ERC20WrapperGluwacoin is Initializable, ContextUpgradeSafe, ERC20Wrapper, ERC20ETHless, ERC20Reservable   {

    function initialize(string memory name, string memory symbol, uint8 decimals, IERC20 token) public virtual {

        __ERC20WrapperGluwacoin_init(name, symbol, decimals, token);
    }

    function __ERC20WrapperGluwacoin_init(string memory name, string memory symbol, uint8 decimals, IERC20 token)
    internal initializer {

        __Context_init_unchained();
        __ERC20_init_unchained(name, symbol);
        __ERC20ETHless_init_unchained();
        __ERC20Reservable_init_unchained();
        __ERC20Wrapper_init_unchained(decimals, token);
        __ERC20WrapperGluwacoin_init_unchained();
    }

    function __ERC20WrapperGluwacoin_init_unchained() internal initializer {

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override (ERC20UpgradeSafe, ERC20Wrapper, ERC20Reservable) {

        ERC20Wrapper._beforeTokenTransfer(from, to, amount);
    } 


    uint256[44] private __gap;
}