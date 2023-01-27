
pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

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

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
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

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC20Burnable is Context, ERC20 {
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        unchecked {
            _approve(account, _msgSender(), currentAllowance - amount);
        }
        _burn(account, amount);
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
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

pragma solidity ^0.8.0;


abstract contract ERC20Pausable is ERC20, Pausable {
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        require(!paused(), "ERC20Pausable: token transfer while paused");
    }
}// MIT

pragma solidity ^0.8.0;

interface IAccessControl {
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) external view returns (bool);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function grantRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function renounceRole(bytes32 role, address account) external;
}// MIT

pragma solidity ^0.8.0;


interface IAccessControlEnumerable is IAccessControl {
    function getRoleMember(bytes32 role, uint256 index) external view returns (address);

    function getRoleMemberCount(bytes32 role) external view returns (uint256);
}// MIT

pragma solidity ^0.8.0;

library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}// MIT

pragma solidity ^0.8.0;

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

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

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
        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
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

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
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

    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract AccessControlEnumerable is IAccessControlEnumerable, AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(bytes32 => EnumerableSet.AddressSet) private _roleMembers;

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    function getRoleMember(bytes32 role, uint256 index) public view override returns (address) {
        return _roleMembers[role].at(index);
    }

    function getRoleMemberCount(bytes32 role) public view override returns (uint256) {
        return _roleMembers[role].length();
    }

    function _grantRole(bytes32 role, address account) internal virtual override {
        super._grantRole(role, account);
        _roleMembers[role].add(account);
    }

    function _revokeRole(bytes32 role, address account) internal virtual override {
        super._revokeRole(role, account);
        _roleMembers[role].remove(account);
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC20PresetMinterPauser is Context, AccessControlEnumerable, ERC20Burnable, ERC20Pausable {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
    }

    function mint(address to, uint256 amount) public virtual {
        require(hasRole(MINTER_ROLE, _msgSender()), "ERC20PresetMinterPauser: must have minter role to mint");
        _mint(to, amount);
    }

    function pause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "ERC20PresetMinterPauser: must have pauser role to pause");
        _pause();
    }

    function unpause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "ERC20PresetMinterPauser: must have pauser role to unpause");
        _unpause();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override(ERC20, ERC20Pausable) {
        super._beforeTokenTransfer(from, to, amount);
    }
}// MIT

pragma solidity ^0.8.0;

library Create2 {
    function deploy(
        uint256 amount,
        bytes32 salt,
        bytes memory bytecode
    ) internal returns (address) {
        address addr;
        require(address(this).balance >= amount, "Create2: insufficient balance");
        require(bytecode.length != 0, "Create2: bytecode length is zero");
        assembly {
            addr := create2(amount, add(bytecode, 0x20), mload(bytecode), salt)
        }
        require(addr != address(0), "Create2: Failed on deploy");
        return addr;
    }

    function computeAddress(bytes32 salt, bytes32 bytecodeHash) internal view returns (address) {
        return computeAddress(salt, bytecodeHash, address(this));
    }

    function computeAddress(
        bytes32 salt,
        bytes32 bytecodeHash,
        address deployer
    ) internal pure returns (address) {
        bytes32 _data = keccak256(abi.encodePacked(bytes1(0xff), deployer, salt, bytecodeHash));
        return address(uint160(uint256(_data)));
    }
}// MIT

pragma solidity ^0.8.0;

library Clones {
    function clone(address implementation) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {
        return predictDeterministicAddress(implementation, salt, address(this));
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}//MIT
pragma solidity ^0.8.0;


contract AllowList is Ownable {
    event SetAllowed(address addr, bool allowed);
    event SetBypassCheck(bool bypassCheck);

    mapping(address => bool) public allowedMap;
    bool public bypassCheck;

    constructor(address[] memory allowed) {
        for (uint256 i = 0; i < allowed.length; i++) {
            address addr = allowed[i];
            allowedMap[addr] = true;
            emit SetAllowed(addr, true);
        }
    }

    function setAllowance(address addr, bool allowed) public onlyOwner {
        require(!bypassCheck);
        allowedMap[addr] = allowed;
        emit SetAllowed(addr, allowed);
    }

    function setBypassCheck(bool _bypassCheck) public onlyOwner {
        bypassCheck = _bypassCheck;
        emit SetBypassCheck(_bypassCheck);
    }

    function getIsAllowed(address addr) public view returns (bool) {
        return bypassCheck || allowedMap[addr];
    }
}//MIT
pragma solidity ^0.8.0;


contract TokenSale {
    event SaleInitialized(
        address creator,
        uint256 price,
        uint256 saleStart,
        uint256 saleEnd,
        uint256 numTokens
    );
    event Sale(address buyer, uint256 amount, uint256 paid);
    event SaleSwept(uint256 saleProceeds, uint256 amountUnsold);

    address public creator;
    IERC20 public token;
    uint256 public tokensPerWei;
    uint256 public saleStart;
    uint256 public saleEnd;

    uint256 public saleProceeds;
    uint256 public amountUnsold;
    bool public swept;

    modifier saleOver(bool want) {
        bool isOver = block.timestamp >= saleEnd;
        require(want == isOver, "Sale state is invalid for this method");
        _;
    }

    struct Params {
        uint256 price;
        uint256 saleStart;
        uint256 saleEnd;
        uint256 numTokens;
    }

    constructor(
        address _creator,
        address _token,
        Params memory params
    ) {
        initialize(_creator, _token, params);
    }

    function initialize(
        address _creator,
        address _token,
        Params memory params
    ) public {
        require(saleEnd == 0);
        require(params.saleStart < params.saleEnd);
        creator = _creator;
        token = IERC20(_token);
        tokensPerWei = params.price;
        saleStart = params.saleStart;
        saleEnd = params.saleEnd;
        amountUnsold = params.numTokens;
        emit SaleInitialized(
            creator,
            params.price,
            params.saleStart,
            params.saleEnd,
            params.numTokens
        );
    }

    function buyTokens() public payable saleOver(false) {
        require(block.timestamp >= saleStart, "Sale has not started yet");
        uint256 amount = msg.value * tokensPerWei;
        require(
            amountUnsold >= amount,
            "Attempted to purchase too many tokens!"
        );
        amountUnsold -= amount;
        token.transfer(msg.sender, amount);
        saleProceeds += msg.value;
        emit Sale(msg.sender, amount, msg.value);
    }

    function sweepProceeds() public saleOver(true) {
        require(!swept, "Already swept");
        swept = true;
        payable(creator).transfer(saleProceeds);
        token.transfer(creator, amountUnsold);
        emit SaleSwept(saleProceeds, amountUnsold);
    }

    function getTokenSaleData()
        public
        view
        returns (
            address _creator,
            IERC20 _token,
            uint256 _tokensPerWei,
            uint256 _saleStart,
            uint256 _saleEnd,
            uint256 _saleProceeds,
            uint256 _amountUnsold,
            bool _swept
        )
    {
        return (
            creator,
            token,
            tokensPerWei,
            saleStart,
            saleEnd,
            saleProceeds,
            amountUnsold,
            swept
        );
    }
}// MIT

pragma solidity >=0.8.4;


interface IENS {
    function setRecord(
        bytes32 node,
        address _owner,
        address resolver,
        uint64 ttl
    ) external;

    function setSubnodeRecord(
        bytes32 node,
        bytes32 label,
        address _owner,
        address resolver,
        uint64 ttl
    ) external;

    function setSubnodeOwner(
        bytes32 node,
        bytes32 label,
        address _owner
    ) external returns (bytes32);

    function setResolver(bytes32 node, address resolver) external;

    function setOwner(bytes32 node, address _owner) external;

    function owner(bytes32 node) external view returns (address);
}// MIT

pragma solidity >=0.8.4;


interface IENSResolver {
    function multicall(bytes[] calldata data)
        external
        returns (bytes[] memory results);
}// MIT

pragma solidity ^0.8.0;


interface IERC721 {
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
}// MIT
pragma solidity ^0.8.0;

interface IFactorySafeHelper {
    function createAndSetupSafe(bytes32 salt)
        external
        returns (address safeAddress, address);
}//MIT
pragma solidity ^0.8.0;



contract AlbumFactory {
    event AlbumCreated(
        string name,
        address sale,
        address safe,
        address realityModule,
        address token
    );

    error NotAllowedError();
    error MinimumTotalTokensNotMetError(uint256 minimum);
    error NotEnoughTokensLeftForRakeError();
    error ENSSubNameUnavailableError();
    error InvalidDistributeParameters();

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    uint256 public constant SZNS_DAO_RAKE_DIVISOR = 100;

    AllowList public immutable ALLOW_LIST;
    IFactorySafeHelper public immutable FACTORY_SAFE_HELPER;
    IENS public immutable ENS;
    address public immutable ENS_PUBLIC_RESOLVER_ADDRESS;
    bytes32 public immutable BASE_ENS_NODE;
    address public immutable SZNS_DAO;
    address public immutable TOKEN_SALE_MASTER_COPY;

    struct TokenParams {
        string symbol;
        uint256 totalTokens;
    }

    struct ERC721Grouping {
        IERC721 erc721;
        uint256[] ids;
    }

    constructor(
        address allowListAddress,
        address factorySafeHelperAddress,
        address ensAddress,
        address ensPublicResolverAddress,
        bytes32 baseEnsNode,
        address sznsDao
    ) {
        ALLOW_LIST = AllowList(allowListAddress);
        FACTORY_SAFE_HELPER = IFactorySafeHelper(factorySafeHelperAddress);
        ENS = IENS(ensAddress);
        BASE_ENS_NODE = baseEnsNode;
        ENS_PUBLIC_RESOLVER_ADDRESS = ensPublicResolverAddress;
        SZNS_DAO = sznsDao;
        TOKEN_SALE_MASTER_COPY = address(
            new TokenSale(address(1), address(1), TokenSale.Params(0, 0, 1, 0))
        );
    }

    function createAlbum(
        string memory name,
        TokenParams memory tokenParams,
        TokenSale.Params memory tokenSaleParams,
        ERC721Grouping[] calldata erc721Groupings,
        bytes[] calldata ensResolverData
    ) external {
        if (!ALLOW_LIST.getIsAllowed(msg.sender)) {
            revert NotAllowedError();
        }
        if (tokenParams.totalTokens < 100 ether) {
            revert MinimumTotalTokensNotMetError(100);
        }
        if (
            tokenParams.totalTokens - tokenSaleParams.numTokens <
            tokenParams.totalTokens / SZNS_DAO_RAKE_DIVISOR
        ) {
            revert NotEnoughTokensLeftForRakeError();
        }
        address safe;
        address realityModule;
        bytes32 ensSubNode;
        {
            bytes32 nameHash = keccak256(abi.encodePacked(name));
            ensSubNode = keccak256(abi.encodePacked(BASE_ENS_NODE, nameHash));
            if (ENS.owner(ensSubNode) != address(0)) {
                revert ENSSubNameUnavailableError();
            }
            (safe, realityModule) = FACTORY_SAFE_HELPER.createAndSetupSafe(
                ensSubNode
            );
            ENS.setSubnodeOwner(BASE_ENS_NODE, nameHash, address(this));
            ENS.setResolver(ensSubNode, ENS_PUBLIC_RESOLVER_ADDRESS);
            IENSResolver(ENS_PUBLIC_RESOLVER_ADDRESS).multicall(
                ensResolverData
            );
            ENS.setOwner(ensSubNode, safe);
        }
        for (uint256 i = 0; i < erc721Groupings.length; i++) {
            for (uint256 j = 0; j < erc721Groupings[i].ids.length; ++j) {
                erc721Groupings[i].erc721.safeTransferFrom(
                    msg.sender,
                    safe,
                    erc721Groupings[i].ids[j]
                );
            }
        }
        address token = createAndSetupToken(name, tokenParams.symbol, safe);
        address sale;
        if (tokenSaleParams.numTokens > 0) {
            sale = createAndSetupTokenSale(token, tokenSaleParams, ensSubNode);
        } else {
            sale = address(0);
        }
        distributeAlbumTokens(
            token,
            tokenParams.totalTokens,
            tokenSaleParams.numTokens,
            sale
        );
        emit AlbumCreated(name, sale, safe, realityModule, token);
    }

    function createAndSetupToken(
        string memory name,
        string memory symbol,
        address safeAddress
    ) internal returns (address) {
        ERC20PresetMinterPauser token = new ERC20PresetMinterPauser{salt: ""}(
            name,
            symbol
        );
        token.grantRole(DEFAULT_ADMIN_ROLE, safeAddress);
        token.grantRole(MINTER_ROLE, safeAddress);
        token.grantRole(PAUSER_ROLE, safeAddress);
        return address(token);
    }

    function createAndSetupTokenSale(
        address tokenAddress,
        TokenSale.Params memory tokenSaleParams,
        bytes32 salt
    ) internal returns (address created) {
        created = Clones.cloneDeterministic(TOKEN_SALE_MASTER_COPY, salt);
        TokenSale(created).initialize(
            msg.sender,
            tokenAddress,
            tokenSaleParams
        );
    }

    function distributeAlbumTokens(
        address _token,
        uint256 totalTokens,
        uint256 amountSold,
        address sale
    ) internal {
        if (totalTokens < amountSold || totalTokens == 0) {
            revert InvalidDistributeParameters();
        }
        ERC20PresetMinterPauser token = ERC20PresetMinterPauser(_token);
        if (sale != address(0)) {
            token.mint(sale, amountSold);
        }
        uint256 sznsDaoRake = totalTokens / SZNS_DAO_RAKE_DIVISOR;
        token.mint(SZNS_DAO, sznsDaoRake);
        token.mint(msg.sender, (totalTokens - amountSold) - sznsDaoRake);
    }
}