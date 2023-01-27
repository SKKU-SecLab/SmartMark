
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
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

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
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

    function grantRole(bytes32 role, address account) public virtual override(AccessControl, IAccessControl) {
        super.grantRole(role, account);
        _roleMembers[role].add(account);
    }

    function revokeRole(bytes32 role, address account) public virtual override(AccessControl, IAccessControl) {
        super.revokeRole(role, account);
        _roleMembers[role].remove(account);
    }

    function renounceRole(bytes32 role, address account) public virtual override(AccessControl, IAccessControl) {
        super.renounceRole(role, account);
        _roleMembers[role].remove(account);
    }

    function _setupRole(bytes32 role, address account) internal virtual override {
        super._setupRole(role, account);
        _roleMembers[role].add(account);
    }
}// MIT
pragma solidity ^0.8.2;


contract TimeYieldedCredit is AccessControlEnumerable {

    
    bytes32 public constant YIELD_MANAGER_ROLE = keccak256("YIELD_MANAGER_ROLE");

    mapping(uint256 => uint256) _usedCredit;

    uint256 public yieldStep;

    uint256 public yield;

    uint256 public epoch;

    uint256 public horizon = type(uint256).max;

    constructor(
        address yieldManager,
        uint256 yieldStep_,
        uint256 yield_,
        uint256 epoch_,
        uint256 horizon_)
        {
            require(yieldStep_ > 0, "TimeYieldedCredit: yieldStep must be positive");

            epoch = epoch_;
            yieldStep = yieldStep_;
            yield = yield_;
            _setHorizon(horizon_);
            _setupRole(YIELD_MANAGER_ROLE, yieldManager);

        }

    function setHorizon(uint256 newHorizon) public onlyRole(YIELD_MANAGER_ROLE) {

        _setHorizon(newHorizon);
    }

    function _setHorizon(uint256 newHorizon) internal {

        require(newHorizon > epoch, "TimeYieldedCredit: new horizon precedes epoch");
    
        horizon = newHorizon;
    }

    function getCurrentYield() public view returns(uint256) {

        uint256 effectiveTs = block.timestamp < horizon ? block.timestamp : horizon;
        if (effectiveTs < epoch) {
            return 0;
        }
        unchecked {
            return ((effectiveTs - epoch) / yieldStep) * yield;
        }
    }

    function _creditFor(uint256 yieldId) internal view returns (uint256) {

        uint256 currentYield = getCurrentYield();
        
        uint256 currentSpent = _usedCredit[yieldId];
        if (currentYield > currentSpent) {
            unchecked {
                return currentYield - currentSpent;
            }
        }
        return 0;
    }

    function _spendCredit(uint256 yieldId, uint256 amount) internal {

        uint256 credit = _creditFor(yieldId);
        require(amount <= credit, "TimeYieldedCredit: Insufficient credit");
        _usedCredit[yieldId] += amount;
    }

    function _spendAll(uint256 yieldId) internal returns (uint256) {

        uint256 credit = _creditFor(yieldId);
        require(credit > 0, "TimeYieldedCredit: Insufficient credit");
        _usedCredit[yieldId] += credit;

        return credit;
    }

    function _spendCreditBatch(
        uint256[] calldata yieldIds,
        uint256[] calldata amounts
    ) internal returns (uint256) {

        require(yieldIds.length == amounts.length, "TimeYieldedCredit: Incorrect arguments length");
        uint256 totalSpent = 0;

        uint256 currentYield = getCurrentYield();
        
        for (uint256 i = 0; i < yieldIds.length; i++) {
            
            uint256 yieldId = yieldIds[i];
            uint256 currentSpent = _usedCredit[yieldId];

            require(currentYield > currentSpent, "TimeYieldedCredit: No credit available");

            uint256 amount = amounts[i];
            uint256 credit;
            unchecked {
                credit = currentYield - currentSpent;
            }

            require(amount <= credit, "TimeYieldedCredit: Insufficient credit");

            _usedCredit[yieldId] += amount;
            totalSpent += amount;
        }

        return totalSpent;
    }
}// MIT

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
pragma solidity ^0.8.2;


contract UtilityToken is ERC20, Pausable, AccessControlEnumerable {
    
    event TokenSpent(address indexed spender, uint256 amount, uint256 indexed serviceId, bytes data);

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant EXTERNAL_SPENDER_ROLE = keccak256("EXTERNAL_SPENDER_ROLE");

    constructor(
        string memory name,
        string memory symbol,
        address admin,
        address pauser,
        address minter)
        ERC20(name, symbol) {
        _setupRole(DEFAULT_ADMIN_ROLE, admin);
        _setupRole(PAUSER_ROLE, pauser);
        _setupRole(MINTER_ROLE, minter);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, amount);
    }

    function burn(
        uint256 amount,
        uint256 serviceId,
        bytes calldata data
    ) public virtual {
        _burn(msg.sender, amount);
        emit TokenSpent(msg.sender, amount, serviceId, data);
    }

    function burnFrom(
        address account,
        uint256 amount,
        uint256 serviceId,
        bytes calldata data
    ) public virtual {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        unchecked {
            _approve(account, _msgSender(), currentAllowance - amount);
        }
        _burn(account, amount);
        emit TokenSpent(account, amount, serviceId, data);
    }

    function externalBurnFrom(
        address account,
        uint256 amount,
        uint256 serviceId,
        bytes calldata data
    ) external virtual onlyRole(EXTERNAL_SPENDER_ROLE) {
        _burn(account, amount);
        emit TokenSpent(account, amount, serviceId, data);
    }
}// MIT

pragma solidity ^0.8.0;


interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function approve(address to, uint256 tokenId) external;

    function getApproved(uint256 tokenId) external view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator) external view returns (bool);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}// MIT

pragma solidity ^0.8.0;


interface IERC721Enumerable is IERC721 {
    function totalSupply() external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    function tokenByIndex(uint256 index) external view returns (uint256);
}// MIT
pragma solidity ^0.8.2;


interface NFTContract is IERC721, IERC721Enumerable {}

contract NFTYieldedToken is UtilityToken, TimeYieldedCredit {
    
    NFTContract public nftContract;

    constructor(
        string memory name,
        string memory symbol,
        address admin,
        address pauser,
        address minter,
        address yieldManager,
        uint256 yieldStep_,
        uint256 yield_,
        uint256 epoch_,
        uint256 horizon_,
        address nftContractAddress)
        UtilityToken(name, symbol, admin, pauser, minter)
        TimeYieldedCredit(yieldManager, yieldStep_, yield_, epoch_, horizon_)
        {
            nftContract = NFTContract(nftContractAddress);
        }

        function getClaimableAmount(uint256 tokenId) external view returns (uint256) {
            require(tokenId < nftContract.totalSupply(), "NFTYieldedToken: Non-existent tokenId");
            return _creditFor(tokenId);
        }

        function getClaimableForAddress(address addr) external view returns (uint256[] memory, uint256[] memory) {
            uint256 balance = nftContract.balanceOf(addr);
            uint256[] memory balances = new uint256[](balance);
            uint256[] memory tokenIds = new uint256[](balance);

            for (uint256 i = 0; i < balance; i++) {
                uint256 tokenId = nftContract.tokenOfOwnerByIndex(addr, i);
                balances[i] = _creditFor(tokenId);
                tokenIds[i] = tokenId;
            }

            return (balances, tokenIds);
        }

        function spend(
            uint256 tokenId,
            uint256 amount,
            uint256 serviceId,
            bytes calldata data
        ) public {
            _spend(tokenId, amount);
            
            emit TokenSpent(msg.sender, amount, serviceId, data);
        }

        function claim(uint256 tokenId, uint256 amount) public {
            _spend(tokenId, amount);

            _mint(msg.sender, amount);
        }

        function _spend(uint256 tokenId, uint256 amount) internal {
            require(msg.sender == nftContract.ownerOf(tokenId), "NFTYieldedToken: Not owner of token");

            _spendCredit(tokenId, amount);
        }

        function spendFrom(
            address account,
            uint256 tokenId,
            uint256 amount,
            uint256 serviceId,
            bytes calldata data
        ) public {
            _spendFrom(account, tokenId, amount);

            emit TokenSpent(account, amount, serviceId, data);
        }

        function claimFrom(
            address account,
            uint256 tokenId,
            uint256 amount,
            address to
        ) public {
            _spendFrom(account, tokenId, amount);

            _mint(to, amount);
        }


        function _spendFrom(
            address account,
            uint256 tokenId,
            uint256 amount
        ) internal {
            require(account == nftContract.ownerOf(tokenId), "NFTYieldedToken: Not owner of token");
            uint256 currentAllowance = allowance(account, msg.sender);
            require(currentAllowance >= amount, "NFTYieldedToken: spend amount exceeds allowance");

            unchecked {
                _approve(account, msg.sender, currentAllowance - amount);
            }

            _spendCredit(tokenId, amount);
        }

        function spendMultiple(
            uint256[] calldata tokenIds,
            uint256[] calldata amounts,
            uint256 serviceId,
            bytes calldata data
        ) public {
            uint256 totalSpent = _spendMultiple(msg.sender, tokenIds, amounts);

            emit TokenSpent(msg.sender, totalSpent, serviceId, data);
        }

        function externalSpendMultiple(
            address account,
            uint256[] calldata tokenIds,
            uint256[] calldata amounts,
            uint256 serviceId,
            bytes calldata data
        ) external onlyRole(EXTERNAL_SPENDER_ROLE) {
            uint256 totalSpent = _spendMultiple(account, tokenIds, amounts);

            emit TokenSpent(account, totalSpent, serviceId, data);
        }

        function claimMultiple(
            uint256[] calldata tokenIds,
            uint256[] calldata amounts
        ) public {
            uint256 totalSpent = _spendMultiple(msg.sender, tokenIds, amounts);

            _mint(msg.sender, totalSpent);
        }

        function _spendMultiple(
            address account,
            uint256[] calldata tokenIds,
            uint256[] calldata amounts
        ) internal returns (uint256) {
            for (uint256 i = 0; i < tokenIds.length; i++) {
                require(account == nftContract.ownerOf(tokenIds[i]), "NFTYieldedToken: Not owner of token");
            }

            return _spendCreditBatch(tokenIds, amounts);
        }

        function claimAll(uint256 tokenId) public {
            require(msg.sender == nftContract.ownerOf(tokenId), "NFTYieldedToken: Not owner of token");
            uint256 amount = _spendAll(tokenId);

            _mint(msg.sender, amount);
        }
}// MIT
pragma solidity ^0.8.2;


contract CHILL is NFTYieldedToken {

    uint256 constant public PROJECT_ALLOCATION = 5000000 * 10**18;

    uint256 constant public YIELD_STEP = 86400;

    uint256 constant public YIELD = 10**19;
    constructor(
        address admin,
        address pauser,
        address minter,
        address yieldManager,
        uint256 epoch_,
        uint256 horizon_,
        address nftContractAddress
    )
    NFTYieldedToken(
        "CHILL",
        "CHILL",
        admin,
        pauser,
        minter,
        yieldManager,
        YIELD_STEP,
        YIELD,
        epoch_,
        horizon_,
        nftContractAddress
    )
    {
        _mint(0x7A105DFD75713c1FDd592E1F9f81232Fa3E74945, PROJECT_ALLOCATION);
    }
}