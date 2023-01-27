
pragma solidity >=0.6.2 <0.8.0;

library AddressUpgradeable {

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

pragma solidity >=0.4.24 <0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract ContextUpgradeable is Initializable {
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
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
    uint256[49] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library ECDSAUpgradeable {

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

        return recover(hash, v, r, s);
    }

    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {

        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ECDSA: invalid signature 's' value");
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract EIP712Upgradeable is Initializable {
    bytes32 private _HASHED_NAME;
    bytes32 private _HASHED_VERSION;
    bytes32 private constant _TYPE_HASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    function __EIP712_init(string memory name, string memory version) internal initializer {
        __EIP712_init_unchained(name, version);
    }

    function __EIP712_init_unchained(string memory name, string memory version) internal initializer {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
    }

    function _domainSeparatorV4() internal view returns (bytes32) {
        return _buildDomainSeparator(_TYPE_HASH, _EIP712NameHash(), _EIP712VersionHash());
    }

    function _buildDomainSeparator(bytes32 typeHash, bytes32 name, bytes32 version) private view returns (bytes32) {
        return keccak256(
            abi.encode(
                typeHash,
                name,
                version,
                _getChainId(),
                address(this)
            )
        );
    }

    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", _domainSeparatorV4(), structHash));
    }

    function _getChainId() private view returns (uint256 chainId) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        assembly {
            chainId := chainid()
        }
    }

    function _EIP712NameHash() internal virtual view returns (bytes32) {
        return _HASHED_NAME;
    }

    function _EIP712VersionHash() internal virtual view returns (bytes32) {
        return _HASHED_VERSION;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC20Upgradeable {

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

library SafeMathUpgradeable {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable {

    using SafeMathUpgradeable for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    function __ERC20_init(string memory name_, string memory symbol_) internal initializer {

        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal initializer {

        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return _decimals;
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

    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

    uint256[44] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC20PermitUpgradeable {

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;


    function nonces(address owner) external view returns (uint256);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

}// MIT

pragma solidity >=0.6.0 <0.8.0;


library CountersUpgradeable {

    using SafeMathUpgradeable for uint256;

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {

        counter._value = counter._value.sub(1);
    }
}// MIT

pragma solidity >=0.6.5 <0.8.0;


abstract contract ERC20PermitUpgradeable is Initializable, ERC20Upgradeable, IERC20PermitUpgradeable, EIP712Upgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;

    mapping (address => CountersUpgradeable.Counter) private _nonces;

    bytes32 private _PERMIT_TYPEHASH;

    function __ERC20Permit_init(string memory name) internal initializer {
        __Context_init_unchained();
        __EIP712_init_unchained(name, "1");
        __ERC20Permit_init_unchained(name);
    }

    function __ERC20Permit_init_unchained(string memory name) internal initializer {
        _PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    }

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public virtual override {
        require(block.timestamp <= deadline, "ERC20Permit: expired deadline");

        bytes32 structHash = keccak256(
            abi.encode(
                _PERMIT_TYPEHASH,
                owner,
                spender,
                value,
                _nonces[owner].current(),
                deadline
            )
        );

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSAUpgradeable.recover(hash, v, r, s);
        require(signer == owner, "ERC20Permit: invalid signature");

        _nonces[owner].increment();
        _approve(owner, spender, value);
    }

    function nonces(address owner) public view override returns (uint256) {
        return _nonces[owner].current();
    }

    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _domainSeparatorV4();
    }
    uint256[49] private __gap;
}// MIT

pragma solidity >=0.6.2 <0.8.0;

library ERC165CheckerUpgradeable {

    bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;

    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    function supportsERC165(address account) internal view returns (bool) {

        return _supportsERC165Interface(account, _INTERFACE_ID_ERC165) &&
            !_supportsERC165Interface(account, _INTERFACE_ID_INVALID);
    }

    function supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {

        return supportsERC165(account) &&
            _supportsERC165Interface(account, interfaceId);
    }

    function getSupportedInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool[] memory) {

        bool[] memory interfaceIdsSupported = new bool[](interfaceIds.length);

        if (supportsERC165(account)) {
            for (uint256 i = 0; i < interfaceIds.length; i++) {
                interfaceIdsSupported[i] = _supportsERC165Interface(account, interfaceIds[i]);
            }
        }

        return interfaceIdsSupported;
    }

    function supportsAllInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool) {

        if (!supportsERC165(account)) {
            return false;
        }

        for (uint256 i = 0; i < interfaceIds.length; i++) {
            if (!_supportsERC165Interface(account, interfaceIds[i])) {
                return false;
            }
        }

        return true;
    }

    function _supportsERC165Interface(address account, bytes4 interfaceId) private view returns (bool) {

        (bool success, bool result) = _callERC165SupportsInterface(account, interfaceId);

        return (success && result);
    }

    function _callERC165SupportsInterface(address account, bytes4 interfaceId)
        private
        view
        returns (bool, bool)
    {

        bytes memory encodedParams = abi.encodeWithSelector(_INTERFACE_ID_ERC165, interfaceId);
        (bool success, bytes memory result) = account.staticcall{ gas: 30000 }(encodedParams);
        if (result.length < 32) return (false, false);
        return (success, abi.decode(result, (bool)));
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC1820RegistryUpgradeable {

    function setManager(address account, address newManager) external;


    function getManager(address account) external view returns (address);


    function setInterfaceImplementer(address account, bytes32 _interfaceHash, address implementer) external;


    function getInterfaceImplementer(address account, bytes32 _interfaceHash) external view returns (address);


    function interfaceHash(string calldata interfaceName) external pure returns (bytes32);


    function updateERC165Cache(address account, bytes4 interfaceId) external;


    function implementsERC165Interface(address account, bytes4 interfaceId) external view returns (bool);


    function implementsERC165InterfaceNoCache(address account, bytes4 interfaceId) external view returns (bool);


    event InterfaceImplementerSet(address indexed account, bytes32 indexed interfaceHash, address indexed implementer);

    event ManagerChanged(address indexed account, address indexed newManager);
}// MIT

pragma solidity >=0.6.0 <0.8.0;


library SafeERC20Upgradeable {

    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;

    function safeTransfer(IERC20Upgradeable token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20Upgradeable token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20Upgradeable token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC721ReceiverUpgradeable {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}// MIT

pragma solidity >=0.6.2 <0.8.0;


interface IERC721Upgradeable is IERC165Upgradeable {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;


library SafeCastUpgradeable {


    function toUint128(uint256 value) internal pure returns (uint128) {

        require(value < 2**128, "SafeCast: value doesn\'t fit in 128 bits");
        return uint128(value);
    }

    function toUint64(uint256 value) internal pure returns (uint64) {

        require(value < 2**64, "SafeCast: value doesn\'t fit in 64 bits");
        return uint64(value);
    }

    function toUint32(uint256 value) internal pure returns (uint32) {

        require(value < 2**32, "SafeCast: value doesn\'t fit in 32 bits");
        return uint32(value);
    }

    function toUint16(uint256 value) internal pure returns (uint16) {

        require(value < 2**16, "SafeCast: value doesn\'t fit in 16 bits");
        return uint16(value);
    }

    function toUint8(uint256 value) internal pure returns (uint8) {

        require(value < 2**8, "SafeCast: value doesn\'t fit in 8 bits");
        return uint8(value);
    }

    function toUint256(int256 value) internal pure returns (uint256) {

        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    function toInt128(int256 value) internal pure returns (int128) {

        require(value >= -2**127 && value < 2**127, "SafeCast: value doesn\'t fit in 128 bits");
        return int128(value);
    }

    function toInt64(int256 value) internal pure returns (int64) {

        require(value >= -2**63 && value < 2**63, "SafeCast: value doesn\'t fit in 64 bits");
        return int64(value);
    }

    function toInt32(int256 value) internal pure returns (int32) {

        require(value >= -2**31 && value < 2**31, "SafeCast: value doesn\'t fit in 32 bits");
        return int32(value);
    }

    function toInt16(int256 value) internal pure returns (int16) {

        require(value >= -2**15 && value < 2**15, "SafeCast: value doesn\'t fit in 16 bits");
        return int16(value);
    }

    function toInt8(int256 value) internal pure returns (int8) {

        require(value >= -2**7 && value < 2**7, "SafeCast: value doesn\'t fit in 8 bits");
        return int8(value);
    }

    function toInt256(uint256 value) internal pure returns (int256) {

        require(value < 2**255, "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}// MIT


pragma solidity >=0.6.0 <0.8.0;

library OpenZeppelinSafeMath_V3_3_0 {

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
}/**
Copyright 2020 PoolTogether Inc.

This file is part of PoolTogether.

PoolTogether is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation under version 3 of the License.

PoolTogether is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with PoolTogether.  If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity >=0.6.0 <0.8.0;


library FixedPoint {

    using OpenZeppelinSafeMath_V3_3_0 for uint256;

    uint256 internal constant SCALE = 1e18;

    function calculateMantissa(uint256 numerator, uint256 denominator) internal pure returns (uint256) {

        uint256 mantissa = numerator.mul(SCALE);
        mantissa = mantissa.div(denominator);
        return mantissa;
    }

    function multiplyUintByMantissa(uint256 b, uint256 mantissa) internal pure returns (uint256) {

        uint256 result = mantissa.mul(b);
        result = result.div(SCALE);
        return result;
    }

    function divideUintByMantissa(uint256 dividend, uint256 mantissa) internal pure returns (uint256) {

        uint256 result = SCALE.mul(dividend);
        result = result.div(mantissa);
        return result;
    }
}// GPL-3.0

pragma solidity >=0.6.0;

interface RNGInterface {


  event RandomNumberRequested(uint32 indexed requestId, address indexed sender);

  event RandomNumberCompleted(uint32 indexed requestId, uint256 randomNumber);

  function getLastRequestId() external view returns (uint32 requestId);


  function getRequestFee() external view returns (address feeToken, uint256 requestFee);


  function requestRandomNumber() external returns (uint32 requestId, uint32 lockBlock);


  function isRequestComplete(uint32 requestId) external view returns (bool isCompleted);


  function randomNumber(uint32 requestId) external returns (uint256 randomNum);

}/**
Copyright 2019 PoolTogether LLC

This file is part of PoolTogether.

PoolTogether is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation under version 3 of the License.

PoolTogether is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with PoolTogether.  If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity >=0.6.0 <0.8.0;

library UniformRandomNumber {

  function uniform(uint256 _entropy, uint256 _upperBound) internal pure returns (uint256) {

    require(_upperBound > 0, "UniformRand/min-bound");
    uint256 min = -_upperBound % _upperBound;
    uint256 random = _entropy;
    while (true) {
      if (random >= min) {
        break;
      }
      random = uint256(keccak256(abi.encodePacked(random)));
    }
    return random % _upperBound;
  }
}// GPL-3.0

pragma solidity 0.6.12;


library Constants {

  IERC1820RegistryUpgradeable public constant REGISTRY = IERC1820RegistryUpgradeable(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

  bytes32 public constant TOKENS_SENDER_INTERFACE_HASH =
  0x29ddb589b1fb5fc7cf394961c1adf5f8c6454761adf795e67fe149f658abe895;

  bytes32 public constant TOKENS_RECIPIENT_INTERFACE_HASH =
  0xb281fc8c12954d22544db45de3159a39272895b169a852b314f9cc762e44c53b;

  bytes32 public constant ACCEPT_MAGIC =
  0xa2ef4600d742022d532d4747cb3547474667d6f13804902513b2ec01c848f4b4;

  bytes4 public constant ERC165_INTERFACE_ID_ERC165 = 0x01ffc9a7;
  bytes4 public constant ERC165_INTERFACE_ID_ERC721 = 0x80ac58cd;
}// GPL-3.0

pragma solidity >=0.5.0 <0.7.0;

interface TokenControllerInterface {


  function beforeTokenTransfer(address from, address to, uint256 amount) external;

}// GPL-3.0

pragma solidity 0.6.12;



interface ControlledTokenInterface is IERC20Upgradeable {


  function controller() external view returns (TokenControllerInterface);


  function controllerMint(address _user, uint256 _amount) external;


  function controllerBurn(address _user, uint256 _amount) external;


  function controllerBurnFrom(address _operator, address _user, uint256 _amount) external;

}// GPL-3.0

pragma solidity 0.6.12;



contract ControlledToken is ERC20PermitUpgradeable, ControlledTokenInterface {


  event Initialized(
    string _name,
    string _symbol,
    uint8 _decimals,
    TokenControllerInterface _controller
  );

  TokenControllerInterface public override controller;

  function initialize(
    string memory _name,
    string memory _symbol,
    uint8 _decimals,
    TokenControllerInterface _controller
  )
    public
    virtual
    initializer
  {

    require(address(_controller) != address(0), "ControlledToken/controller-not-zero");
    __ERC20_init(_name, _symbol);
    __ERC20Permit_init("PoolTogether ControlledToken");
    controller = _controller;
    _setupDecimals(_decimals);

    emit Initialized(
      _name,
      _symbol,
      _decimals,
      _controller
    );
  }

  function controllerMint(address _user, uint256 _amount) external virtual override onlyController {

    _mint(_user, _amount);
  }

  function controllerBurn(address _user, uint256 _amount) external virtual override onlyController {

    _burn(_user, _amount);
  }

  function controllerBurnFrom(address _operator, address _user, uint256 _amount) external virtual override onlyController {

    if (_operator != _user) {
      uint256 decreasedAllowance = allowance(_user, _operator).sub(_amount, "ControlledToken/exceeds-allowance");
      _approve(_user, _operator, decreasedAllowance);
    }
    _burn(_user, _amount);
  }

  modifier onlyController {

    require(_msgSender() == address(controller), "ControlledToken/only-controller");
    _;
  }

  function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {

    controller.beforeTokenTransfer(from, to, amount);
  }
}pragma solidity 0.6.12;

contract ProxyFactory {


  event ProxyCreated(address proxy);

  function deployMinimal(address _logic, bytes memory _data) public returns (address proxy) {

    bytes20 targetBytes = bytes20(_logic);
    assembly {
      let clone := mload(0x40)
      mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
      mstore(add(clone, 0x14), targetBytes)
      mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
      proxy := create(0, clone, 0x37)
    }

    emit ProxyCreated(address(proxy));

    if(_data.length > 0) {
      (bool success,) = proxy.call(_data);
      require(success, "ProxyFactory/constructor-call-failed");
    }
  }
}// GPL-3.0

pragma solidity 0.6.12;


contract ControlledTokenProxyFactory is ProxyFactory {


  ControlledToken public instance;

  constructor () public {
    instance = new ControlledToken();
  }

  function create() external returns (ControlledToken) {

    return ControlledToken(deployMinimal(address(instance), ""));
  }
}/**
 *  @reviewers: [@clesaege, @unknownunknown1, @ferittuncer]
 *  @auditors: []
 *  @bounties: [<14 days 10 ETH max payout>]
 *  @deployments: []
 */

pragma solidity ^0.6.0;

library SortitionSumTreeFactory {


    struct SortitionSumTree {
        uint K; // The maximum number of childs per node.
        uint[] stack;
        uint[] nodes;
        mapping(bytes32 => uint) IDsToNodeIndexes;
        mapping(uint => bytes32) nodeIndexesToIDs;
    }


    struct SortitionSumTrees {
        mapping(bytes32 => SortitionSumTree) sortitionSumTrees;
    }


    function createTree(SortitionSumTrees storage self, bytes32 _key, uint _K) internal {

        SortitionSumTree storage tree = self.sortitionSumTrees[_key];
        require(tree.K == 0, "Tree already exists.");
        require(_K > 1, "K must be greater than one.");
        tree.K = _K;
        tree.stack = new uint[](0);
        tree.nodes = new uint[](0);
        tree.nodes.push(0);
    }

    function set(SortitionSumTrees storage self, bytes32 _key, uint _value, bytes32 _ID) internal {

        SortitionSumTree storage tree = self.sortitionSumTrees[_key];
        uint treeIndex = tree.IDsToNodeIndexes[_ID];

        if (treeIndex == 0) { // No existing node.
            if (_value != 0) { // Non zero value.
                if (tree.stack.length == 0) { // No vacant spots.
                    treeIndex = tree.nodes.length;
                    tree.nodes.push(_value);

                    if (treeIndex != 1 && (treeIndex - 1) % tree.K == 0) { // Is first child.
                        uint parentIndex = treeIndex / tree.K;
                        bytes32 parentID = tree.nodeIndexesToIDs[parentIndex];
                        uint newIndex = treeIndex + 1;
                        tree.nodes.push(tree.nodes[parentIndex]);
                        delete tree.nodeIndexesToIDs[parentIndex];
                        tree.IDsToNodeIndexes[parentID] = newIndex;
                        tree.nodeIndexesToIDs[newIndex] = parentID;
                    }
                } else { // Some vacant spot.
                    treeIndex = tree.stack[tree.stack.length - 1];
                    tree.stack.pop();
                    tree.nodes[treeIndex] = _value;
                }

                tree.IDsToNodeIndexes[_ID] = treeIndex;
                tree.nodeIndexesToIDs[treeIndex] = _ID;

                updateParents(self, _key, treeIndex, true, _value);
            }
        } else { // Existing node.
            if (_value == 0) { // Zero value.
                uint value = tree.nodes[treeIndex];
                tree.nodes[treeIndex] = 0;

                tree.stack.push(treeIndex);

                delete tree.IDsToNodeIndexes[_ID];
                delete tree.nodeIndexesToIDs[treeIndex];

                updateParents(self, _key, treeIndex, false, value);
            } else if (_value != tree.nodes[treeIndex]) { // New, non zero value.
                bool plusOrMinus = tree.nodes[treeIndex] <= _value;
                uint plusOrMinusValue = plusOrMinus ? _value - tree.nodes[treeIndex] : tree.nodes[treeIndex] - _value;
                tree.nodes[treeIndex] = _value;

                updateParents(self, _key, treeIndex, plusOrMinus, plusOrMinusValue);
            }
        }
    }


    function queryLeafs(
        SortitionSumTrees storage self,
        bytes32 _key,
        uint _cursor,
        uint _count
    ) internal view returns(uint startIndex, uint[] memory values, bool hasMore) {

        SortitionSumTree storage tree = self.sortitionSumTrees[_key];

        for (uint i = 0; i < tree.nodes.length; i++) {
            if ((tree.K * i) + 1 >= tree.nodes.length) {
                startIndex = i;
                break;
            }
        }

        uint loopStartIndex = startIndex + _cursor;
        values = new uint[](loopStartIndex + _count > tree.nodes.length ? tree.nodes.length - loopStartIndex : _count);
        uint valuesIndex = 0;
        for (uint j = loopStartIndex; j < tree.nodes.length; j++) {
            if (valuesIndex < _count) {
                values[valuesIndex] = tree.nodes[j];
                valuesIndex++;
            } else {
                hasMore = true;
                break;
            }
        }
    }

    function draw(SortitionSumTrees storage self, bytes32 _key, uint _drawnNumber) internal view returns(bytes32 ID) {

        SortitionSumTree storage tree = self.sortitionSumTrees[_key];
        uint treeIndex = 0;
        uint currentDrawnNumber = _drawnNumber % tree.nodes[0];

        while ((tree.K * treeIndex) + 1 < tree.nodes.length)  // While it still has children.
            for (uint i = 1; i <= tree.K; i++) { // Loop over children.
                uint nodeIndex = (tree.K * treeIndex) + i;
                uint nodeValue = tree.nodes[nodeIndex];

                if (currentDrawnNumber >= nodeValue) currentDrawnNumber -= nodeValue; // Go to the next child.
                else { // Pick this child.
                    treeIndex = nodeIndex;
                    break;
                }
            }
        
        ID = tree.nodeIndexesToIDs[treeIndex];
    }

    function stakeOf(SortitionSumTrees storage self, bytes32 _key, bytes32 _ID) internal view returns(uint value) {

        SortitionSumTree storage tree = self.sortitionSumTrees[_key];
        uint treeIndex = tree.IDsToNodeIndexes[_ID];

        if (treeIndex == 0) value = 0;
        else value = tree.nodes[treeIndex];
    }

    function total(SortitionSumTrees storage self, bytes32 _key) internal view returns (uint) {

        SortitionSumTree storage tree = self.sortitionSumTrees[_key];
        if (tree.nodes.length == 0) {
            return 0;
        } else {
            return tree.nodes[0];
        }
    }


    function updateParents(SortitionSumTrees storage self, bytes32 _key, uint _treeIndex, bool _plusOrMinus, uint _value) private {

        SortitionSumTree storage tree = self.sortitionSumTrees[_key];

        uint parentIndex = _treeIndex;
        while (parentIndex != 0) {
            parentIndex = (parentIndex - 1) / tree.K;
            tree.nodes[parentIndex] = _plusOrMinus ? tree.nodes[parentIndex] + _value : tree.nodes[parentIndex] - _value;
        }
    }
}// GPL-3.0

pragma solidity >=0.5.0 <0.7.0;

interface TicketInterface {

  function draw(uint256 randomNumber) external view returns (address);

}// GPL-3.0

pragma solidity 0.6.12;



contract Ticket is ControlledToken, TicketInterface {

  using SortitionSumTreeFactory for SortitionSumTreeFactory.SortitionSumTrees;

  bytes32 constant private TREE_KEY = keccak256("PoolTogether/Ticket");
  uint256 constant private MAX_TREE_LEAVES = 5;

  event Initialized(
    string _name,
    string _symbol,
    uint8 _decimals,
    TokenControllerInterface _controller
  );

  SortitionSumTreeFactory.SortitionSumTrees internal sortitionSumTrees;

  function initialize(
    string memory _name,
    string memory _symbol,
    uint8 _decimals,
    TokenControllerInterface _controller
  )
    public
    virtual
    override
    initializer
  {

    require(address(_controller) != address(0), "Ticket/controller-not-zero");
    ControlledToken.initialize(_name, _symbol, _decimals, _controller);
    sortitionSumTrees.createTree(TREE_KEY, MAX_TREE_LEAVES);
    emit Initialized(
      _name,
      _symbol,
      _decimals,
      _controller
    );
  }

  function chanceOf(address user) external view returns (uint256) {

    return sortitionSumTrees.stakeOf(TREE_KEY, bytes32(uint256(user)));
  }

  function draw(uint256 randomNumber) external view override returns (address) {

    uint256 bound = totalSupply();
    address selected;
    if (bound == 0) {
      selected = address(0);
    } else {
      uint256 token = UniformRandomNumber.uniform(randomNumber, bound);
      selected = address(uint256(sortitionSumTrees.draw(TREE_KEY, token)));
    }
    return selected;
  }

  function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {

    super._beforeTokenTransfer(from, to, amount);

    if (from == to) {
      return;
    }

    if (from != address(0)) {
      uint256 fromBalance = balanceOf(from).sub(amount);
      sortitionSumTrees.set(TREE_KEY, fromBalance, bytes32(uint256(from)));
    }

    if (to != address(0)) {
      uint256 toBalance = balanceOf(to).add(amount);
      sortitionSumTrees.set(TREE_KEY, toBalance, bytes32(uint256(to)));
    }
  }

}// GPL-3.0

pragma solidity 0.6.12;



contract TicketProxyFactory is ProxyFactory {


  Ticket public instance;

  constructor () public {
    instance = new Ticket();
  }

  function create() external returns (Ticket) {

    return Ticket(deployMinimal(address(instance), ""));
  }
}// GPL-3.0

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;


contract ControlledTokenBuilder {


  event CreatedControlledToken(address indexed token);
  event CreatedTicket(address indexed token);

  ControlledTokenProxyFactory public controlledTokenProxyFactory;
  TicketProxyFactory public ticketProxyFactory;

  struct ControlledTokenConfig {
    string name;
    string symbol;
    uint8 decimals;
    TokenControllerInterface controller;
  }

  constructor (
    ControlledTokenProxyFactory _controlledTokenProxyFactory,
    TicketProxyFactory _ticketProxyFactory
  ) public {
    require(address(_controlledTokenProxyFactory) != address(0), "ControlledTokenBuilder/controlledTokenProxyFactory-not-zero");
    require(address(_ticketProxyFactory) != address(0), "ControlledTokenBuilder/ticketProxyFactory-not-zero");
    controlledTokenProxyFactory = _controlledTokenProxyFactory;
    ticketProxyFactory = _ticketProxyFactory;
  }

  function createControlledToken(
    ControlledTokenConfig calldata config
  ) external returns (ControlledToken) {

    ControlledToken token = controlledTokenProxyFactory.create();

    token.initialize(
      config.name,
      config.symbol,
      config.decimals,
      config.controller
    );

    emit CreatedControlledToken(address(token));

    return token;
  }

  function createTicket(
    ControlledTokenConfig calldata config
  ) external returns (Ticket) {

    Ticket token = ticketProxyFactory.create();

    token.initialize(
      config.name,
      config.symbol,
      config.decimals,
      config.controller
    );

    emit CreatedTicket(address(token));

    return token;
  }
}// MIT
pragma solidity ^0.6.12;


abstract contract PrizeSplit is OwnableUpgradeable {
  using SafeMathUpgradeable for uint256;
  
  PrizeSplitConfig[] internal _prizeSplits;

  struct PrizeSplitConfig {
      address target;
      uint16 percentage;
      uint8 token;
  }

  event PrizeSplitSet(address indexed target, uint16 percentage, uint8 token, uint256 index);

  event PrizeSplitRemoved(uint256 indexed target);

  function _awardPrizeSplitAmount(address target, uint256 amount, uint8 tokenIndex) virtual internal;

  function prizeSplits() external view returns (PrizeSplitConfig[] memory) {
    return _prizeSplits;
  }

  function prizeSplit(uint256 prizeSplitIndex) external view returns (PrizeSplitConfig memory) {
    return _prizeSplits[prizeSplitIndex];
  }

  function setPrizeSplits(PrizeSplitConfig[] calldata newPrizeSplits) external onlyOwner {
    uint256 newPrizeSplitsLength = newPrizeSplits.length;

    for (uint256 index = 0; index < newPrizeSplitsLength; index++) {
      PrizeSplitConfig memory split = newPrizeSplits[index];
      require(split.token <= 1, "MultipleWinners/invalid-prizesplit-token");
      require(split.target != address(0), "MultipleWinners/invalid-prizesplit-target");
      
      if (_prizeSplits.length <= index) {
        _prizeSplits.push(split);
      } else {
        PrizeSplitConfig memory currentSplit = _prizeSplits[index];
        if (split.target != currentSplit.target || split.percentage != currentSplit.percentage || split.token != currentSplit.token) {
          _prizeSplits[index] = split;
        } else {
          continue;
        }
      }

      emit PrizeSplitSet(split.target, split.percentage, split.token, index);
    }

    while (_prizeSplits.length > newPrizeSplitsLength) {
      uint256 _index = _prizeSplits.length.sub(1);
      _prizeSplits.pop();
      emit PrizeSplitRemoved(_index);
    }

    uint256 totalPercentage = _totalPrizeSplitPercentageAmount();
    require(totalPercentage <= 1000, "MultipleWinners/invalid-prizesplit-percentage-total");
  }

  function setPrizeSplit(PrizeSplitConfig memory prizeStrategySplit, uint8 prizeSplitIndex) external onlyOwner {
    require(prizeSplitIndex < _prizeSplits.length, "MultipleWinners/nonexistent-prizesplit");
    require(prizeStrategySplit.token <= 1, "MultipleWinners/invalid-prizesplit-token");
    require(prizeStrategySplit.target != address(0), "MultipleWinners/invalid-prizesplit-target");
    
    _prizeSplits[prizeSplitIndex] = prizeStrategySplit;

    uint256 totalPercentage = _totalPrizeSplitPercentageAmount();
    require(totalPercentage <= 1000, "MultipleWinners/invalid-prizesplit-percentage-total");

    emit PrizeSplitSet(prizeStrategySplit.target, prizeStrategySplit.percentage, prizeStrategySplit.token, prizeSplitIndex);
  }

  function _getPrizeSplitAmount(uint256 amount, uint16 percentage) internal pure returns (uint256) {
    return (amount * percentage).div(1000);
  }

  function _totalPrizeSplitPercentageAmount() internal view returns (uint256) {
    uint256 _tempTotalPercentage;
    uint256 prizeSplitsLength = _prizeSplits.length;
    for (uint8 index = 0; index < prizeSplitsLength; index++) {
      PrizeSplitConfig memory split = _prizeSplits[index];
      _tempTotalPercentage = _tempTotalPercentage.add(split.percentage);
    }
    return _tempTotalPercentage;
  }

  function _distributePrizeSplits(uint256 prize) internal returns (uint256) {
    uint256 _prizeTemp = prize;
    uint256 prizeSplitsLength = _prizeSplits.length;
    for (uint256 index = 0; index < prizeSplitsLength; index++) {
      PrizeSplitConfig memory split = _prizeSplits[index];
      uint256 _splitAmount = _getPrizeSplitAmount(_prizeTemp, split.percentage);

      _awardPrizeSplitAmount(split.target, _splitAmount, split.token);

      prize = prize.sub(_splitAmount);
    }

    return prize;
  }

}// GPL-3.0

pragma solidity >=0.5.0 <0.7.0;


interface TokenListenerInterface is IERC165Upgradeable {

  function beforeTokenMint(address to, uint256 amount, address controlledToken, address referrer) external;


  function beforeTokenTransfer(address from, address to, uint256 amount, address controlledToken) external;

}pragma solidity 0.6.12;

library TokenListenerLibrary {

  bytes4 public constant ERC165_INTERFACE_ID_TOKEN_LISTENER = 0xff5e34e7;
}pragma solidity ^0.6.4;


abstract contract TokenListener is TokenListenerInterface {
  function supportsInterface(bytes4 interfaceId) external override view returns (bool) {
    return (
      interfaceId == Constants.ERC165_INTERFACE_ID_ERC165 || 
      interfaceId == TokenListenerLibrary.ERC165_INTERFACE_ID_TOKEN_LISTENER
    );
  }
}// GPL-3.0

pragma solidity 0.6.12;


interface ICompLike is IERC20Upgradeable {

  function getCurrentVotes(address account) external view returns (uint96);

  function delegate(address delegatee) external;

}// GPL-3.0

pragma solidity >=0.5.0 <0.7.0;

interface RegistryInterface {

  function lookup() external view returns (address);

}// GPL-3.0

pragma solidity >=0.5.0 <0.7.0;

interface ReserveInterface {

  function reserveRateMantissa(address prizePool) external view returns (uint256);

}// GPL-3.0

pragma solidity 0.6.12;

library MappedSinglyLinkedList {


  address public constant SENTINEL = address(0x1);

  struct Mapping {
    uint256 count;

    mapping(address => address) addressMap;
  }

  function initialize(Mapping storage self) internal {

    require(self.count == 0, "Already init");
    self.addressMap[SENTINEL] = SENTINEL;
  }

  function start(Mapping storage self) internal view returns (address) {

    return self.addressMap[SENTINEL];
  }

  function next(Mapping storage self, address current) internal view returns (address) {

    return self.addressMap[current];
  }

  function end(Mapping storage) internal pure returns (address) {

    return SENTINEL;
  }

  function addAddresses(Mapping storage self, address[] memory addresses) internal {

    for (uint256 i = 0; i < addresses.length; i++) {
      addAddress(self, addresses[i]);
    }
  }

  function addAddress(Mapping storage self, address newAddress) internal {

    require(newAddress != SENTINEL && newAddress != address(0), "Invalid address");
    require(self.addressMap[newAddress] == address(0), "Already added");
    self.addressMap[newAddress] = self.addressMap[SENTINEL];
    self.addressMap[SENTINEL] = newAddress;
    self.count = self.count + 1;
  }

  function removeAddress(Mapping storage self, address prevAddress, address addr) internal {

    require(addr != SENTINEL && addr != address(0), "Invalid address");
    require(self.addressMap[prevAddress] == addr, "Invalid prevAddress");
    self.addressMap[prevAddress] = self.addressMap[addr];
    delete self.addressMap[addr];
    self.count = self.count - 1;
  }

  function contains(Mapping storage self, address addr) internal view returns (bool) {

    return addr != SENTINEL && addr != address(0) && self.addressMap[addr] != address(0);
  }

  function addressArray(Mapping storage self) internal view returns (address[] memory) {

    address[] memory array = new address[](self.count);
    uint256 count;
    address currentAddress = self.addressMap[SENTINEL];
    while (currentAddress != address(0) && currentAddress != SENTINEL) {
      array[count] = currentAddress;
      currentAddress = self.addressMap[currentAddress];
      count++;
    }
    return array;
  }

  function clearAll(Mapping storage self) internal {

    address currentAddress = self.addressMap[SENTINEL];
    while (currentAddress != address(0) && currentAddress != SENTINEL) {
      address nextAddress = self.addressMap[currentAddress];
      delete self.addressMap[currentAddress];
      currentAddress = nextAddress;
    }
    self.addressMap[SENTINEL] = SENTINEL;
    self.count = 0;
  }
}// GPL-3.0

pragma solidity 0.6.12;


interface PrizePoolInterface {


  function depositTo(
    address to,
    uint256 amount,
    address controlledToken,
    address referrer
  )
    external;


  function withdrawInstantlyFrom(
    address from,
    uint256 amount,
    address controlledToken,
    uint256 maximumExitFee
  ) external returns (uint256);



  function withdrawReserve(address to) external returns (uint256);


  function awardBalance() external view returns (uint256);


  function captureAwardBalance() external returns (uint256);


  function award(
    address to,
    uint256 amount,
    address controlledToken
  )
    external;


  function transferExternalERC20(
    address to,
    address externalToken,
    uint256 amount
  )
    external;


  function awardExternalERC20(
    address to,
    address externalToken,
    uint256 amount
  )
    external;


  function awardExternalERC721(
    address to,
    address externalToken,
    uint256[] calldata tokenIds
  )
    external;


  function calculateEarlyExitFee(
    address from,
    address controlledToken,
    uint256 amount
  )
    external
    returns (
      uint256 exitFee,
      uint256 burnedCredit
    );


  function estimateCreditAccrualTime(
    address _controlledToken,
    uint256 _principal,
    uint256 _interest
  )
    external
    view
    returns (uint256 durationSeconds);


  function balanceOfCredit(address user, address controlledToken) external returns (uint256);


  function setCreditPlanOf(
    address _controlledToken,
    uint128 _creditRateMantissa,
    uint128 _creditLimitMantissa
  )
    external;


  function creditPlanOf(
    address controlledToken
  )
    external
    view
    returns (
      uint128 creditLimitMantissa,
      uint128 creditRateMantissa
    );


  function setLiquidityCap(uint256 _liquidityCap) external;


  function setPrizeStrategy(TokenListenerInterface _prizeStrategy) external;


  function token() external view returns (address);


  function tokens() external view returns (ControlledTokenInterface[] memory);


  function accountedBalance() external view returns (uint256);

}// GPL-3.0

pragma solidity 0.6.12;



abstract contract PrizePool is PrizePoolInterface, OwnableUpgradeable, ReentrancyGuardUpgradeable, TokenControllerInterface, IERC721ReceiverUpgradeable {
  using SafeMathUpgradeable for uint256;
  using SafeCastUpgradeable for uint256;
  using SafeERC20Upgradeable for IERC20Upgradeable;
  using SafeERC20Upgradeable for IERC721Upgradeable;
  using MappedSinglyLinkedList for MappedSinglyLinkedList.Mapping;
  using ERC165CheckerUpgradeable for address;

  event Initialized(
    address reserveRegistry,
    uint256 maxExitFeeMantissa
  );

  event ControlledTokenAdded(
    ControlledTokenInterface indexed token
  );

  event ReserveFeeCaptured(
    uint256 amount
  );

  event AwardCaptured(
    uint256 amount
  );

  event Deposited(
    address indexed operator,
    address indexed to,
    address indexed token,
    uint256 amount,
    address referrer
  );

  event Awarded(
    address indexed winner,
    address indexed token,
    uint256 amount
  );

  event AwardedExternalERC20(
    address indexed winner,
    address indexed token,
    uint256 amount
  );

  event TransferredExternalERC20(
    address indexed to,
    address indexed token,
    uint256 amount
  );

  event AwardedExternalERC721(
    address indexed winner,
    address indexed token,
    uint256[] tokenIds
  );

  event InstantWithdrawal(
    address indexed operator,
    address indexed from,
    address indexed token,
    uint256 amount,
    uint256 redeemed,
    uint256 exitFee
  );

  event ReserveWithdrawal(
    address indexed to,
    uint256 amount
  );

  event LiquidityCapSet(
    uint256 liquidityCap
  );

  event CreditPlanSet(
    address token,
    uint128 creditLimitMantissa,
    uint128 creditRateMantissa
  );

  event PrizeStrategySet(
    address indexed prizeStrategy
  );

  event CreditMinted(
    address indexed user,
    address indexed token,
    uint256 amount
  );

  event CreditBurned(
    address indexed user,
    address indexed token,
    uint256 amount
  );

  event ErrorAwardingExternalERC721(bytes error);


  struct CreditPlan {
    uint128 creditLimitMantissa;
    uint128 creditRateMantissa;
  }

  struct CreditBalance {
    uint192 balance;
    uint32 timestamp;
    bool initialized;
  }

  string constant public VERSION = "3.4.1";

  RegistryInterface public reserveRegistry;

  ControlledTokenInterface[] internal _tokens;

  TokenListenerInterface public prizeStrategy;

  uint256 public maxExitFeeMantissa;

  uint256 public reserveTotalSupply;

  uint256 public liquidityCap;

  uint256 internal _currentAwardBalance;

  mapping(address => CreditPlan) internal _tokenCreditPlans;

  mapping(address => mapping(address => CreditBalance)) internal _tokenCreditBalances;

  function initialize (
    RegistryInterface _reserveRegistry,
    ControlledTokenInterface[] memory _controlledTokens,
    uint256 _maxExitFeeMantissa
  )
    public
    initializer
  {
    require(address(_reserveRegistry) != address(0), "PrizePool/reserveRegistry-not-zero");
    uint256 controlledTokensLength = _controlledTokens.length;
    _tokens = new ControlledTokenInterface[](controlledTokensLength);

    for (uint256 i = 0; i < controlledTokensLength; i++) {
      ControlledTokenInterface controlledToken = _controlledTokens[i];
      _addControlledToken(controlledToken, i);
    }
    __Ownable_init();
    __ReentrancyGuard_init();
    _setLiquidityCap(uint256(-1));

    reserveRegistry = _reserveRegistry;
    maxExitFeeMantissa = _maxExitFeeMantissa;

    emit Initialized(
      address(_reserveRegistry),
      maxExitFeeMantissa
    );
  }

  function token() external override view returns (address) {
    return address(_token());
  }

  function balance() external returns (uint256) {
    return _balance();
  }

  function canAwardExternal(address _externalToken) external view returns (bool) {
    return _canAwardExternal(_externalToken);
  }

  function depositTo(
    address to,
    uint256 amount,
    address controlledToken,
    address referrer
  )
    external override
    nonReentrant
    onlyControlledToken(controlledToken)
    canAddLiquidity(amount)
  {
    address operator = _msgSender();

    _mint(to, amount, controlledToken, referrer);

    _token().safeTransferFrom(operator, address(this), amount);
    _supply(amount);

    emit Deposited(operator, to, controlledToken, amount, referrer);
  }

  function withdrawInstantlyFrom(
    address from,
    uint256 amount,
    address controlledToken,
    uint256 maximumExitFee
  )
    external override
    nonReentrant
    onlyControlledToken(controlledToken)
    returns (uint256)
  {
    (uint256 exitFee, uint256 burnedCredit) = _calculateEarlyExitFeeLessBurnedCredit(from, controlledToken, amount);
    require(exitFee <= maximumExitFee, "PrizePool/exit-fee-exceeds-user-maximum");

    _burnCredit(from, controlledToken, burnedCredit);

    ControlledToken(controlledToken).controllerBurnFrom(_msgSender(), from, amount);

    uint256 amountLessFee = amount.sub(exitFee);
    uint256 redeemed = _redeem(amountLessFee);

    _token().safeTransfer(from, redeemed);

    emit InstantWithdrawal(_msgSender(), from, controlledToken, amount, redeemed, exitFee);

    return exitFee;
  }

  function _limitExitFee(uint256 withdrawalAmount, uint256 exitFee) internal view returns (uint256) {
    uint256 maxFee = FixedPoint.multiplyUintByMantissa(withdrawalAmount, maxExitFeeMantissa);
    if (exitFee > maxFee) {
      exitFee = maxFee;
    }
    return exitFee;
  }

  function beforeTokenTransfer(address from, address to, uint256 amount) external override onlyControlledToken(msg.sender) {
    if (from != address(0)) {
      uint256 fromBeforeBalance = IERC20Upgradeable(msg.sender).balanceOf(from);
      uint256 newCreditBalance = _calculateCreditBalance(from, msg.sender, fromBeforeBalance, 0);

      if (from != to) {
        newCreditBalance = _applyCreditLimit(msg.sender, fromBeforeBalance.sub(amount), newCreditBalance);
      }

      _updateCreditBalance(from, msg.sender, newCreditBalance);
    }
    if (to != address(0) && to != from) {
      _accrueCredit(to, msg.sender, IERC20Upgradeable(msg.sender).balanceOf(to), 0);
    }
    if (from != address(0) && address(prizeStrategy) != address(0)) {
      prizeStrategy.beforeTokenTransfer(from, to, amount, msg.sender);
    }
  }

  function awardBalance() external override view returns (uint256) {
    return _currentAwardBalance;
  }

  function captureAwardBalance() external override nonReentrant returns (uint256) {
    uint256 tokenTotalSupply = _tokenTotalSupply();

    uint256 currentBalance = _balance();
    uint256 totalInterest = (currentBalance > tokenTotalSupply) ? currentBalance.sub(tokenTotalSupply) : 0;
    uint256 unaccountedPrizeBalance = (totalInterest > _currentAwardBalance) ? totalInterest.sub(_currentAwardBalance) : 0;

    if (unaccountedPrizeBalance > 0) {
      uint256 reserveFee = calculateReserveFee(unaccountedPrizeBalance);
      if (reserveFee > 0) {
        reserveTotalSupply = reserveTotalSupply.add(reserveFee);
        unaccountedPrizeBalance = unaccountedPrizeBalance.sub(reserveFee);
        emit ReserveFeeCaptured(reserveFee);
      }
      _currentAwardBalance = _currentAwardBalance.add(unaccountedPrizeBalance);

      emit AwardCaptured(unaccountedPrizeBalance);
    }

    return _currentAwardBalance;
  }

  function withdrawReserve(address to) external override onlyReserve returns (uint256) {

    uint256 amount = reserveTotalSupply;
    reserveTotalSupply = 0;
    uint256 redeemed = _redeem(amount);

    _token().safeTransfer(address(to), redeemed);

    emit ReserveWithdrawal(to, amount);

    return redeemed;
  }

  function award(
    address to,
    uint256 amount,
    address controlledToken
  )
    external override
    onlyPrizeStrategy
    onlyControlledToken(controlledToken)
  {
    if (amount == 0) {
      return;
    }

    require(amount <= _currentAwardBalance, "PrizePool/award-exceeds-avail");
    _currentAwardBalance = _currentAwardBalance.sub(amount);

    _mint(to, amount, controlledToken, address(0));

    uint256 extraCredit = _calculateEarlyExitFeeNoCredit(controlledToken, amount);
    _accrueCredit(to, controlledToken, IERC20Upgradeable(controlledToken).balanceOf(to), extraCredit);

    emit Awarded(to, controlledToken, amount);
  }

  function transferExternalERC20(
    address to,
    address externalToken,
    uint256 amount
  )
    external override
    onlyPrizeStrategy
  {
    if (_transferOut(to, externalToken, amount)) {
      emit TransferredExternalERC20(to, externalToken, amount);
    }
  }

  function awardExternalERC20(
    address to,
    address externalToken,
    uint256 amount
  )
    external override
    onlyPrizeStrategy
  {
    if (_transferOut(to, externalToken, amount)) {
      emit AwardedExternalERC20(to, externalToken, amount);
    }
  }

  function _transferOut(
    address to,
    address externalToken,
    uint256 amount
  )
    internal
    returns (bool)
  {
    require(_canAwardExternal(externalToken), "PrizePool/invalid-external-token");

    if (amount == 0) {
      return false;
    }

    IERC20Upgradeable(externalToken).safeTransfer(to, amount);

    return true;
  }

  function _mint(address to, uint256 amount, address controlledToken, address referrer) internal {
    if (address(prizeStrategy) != address(0)) {
      prizeStrategy.beforeTokenMint(to, amount, controlledToken, referrer);
    }
    ControlledToken(controlledToken).controllerMint(to, amount);
  }

  function awardExternalERC721(
    address to,
    address externalToken,
    uint256[] calldata tokenIds
  )
    external override
    onlyPrizeStrategy
  {
    require(_canAwardExternal(externalToken), "PrizePool/invalid-external-token");

    if (tokenIds.length == 0) {
      return;
    }

    for (uint256 i = 0; i < tokenIds.length; i++) {
      try IERC721Upgradeable(externalToken).safeTransferFrom(address(this), to, tokenIds[i]){

      }
      catch(bytes memory error){
        emit ErrorAwardingExternalERC721(error);
      }
      
    }

    emit AwardedExternalERC721(to, externalToken, tokenIds);
  }

  function calculateReserveFee(uint256 amount) public view returns (uint256) {
    ReserveInterface reserve = ReserveInterface(reserveRegistry.lookup());
    if (address(reserve) == address(0)) {
      return 0;
    }
    uint256 reserveRateMantissa = reserve.reserveRateMantissa(address(this));
    if (reserveRateMantissa == 0) {
      return 0;
    }
    return FixedPoint.multiplyUintByMantissa(amount, reserveRateMantissa);
  }

  function calculateEarlyExitFee(
    address from,
    address controlledToken,
    uint256 amount
  )
    external override
    returns (
      uint256 exitFee,
      uint256 burnedCredit
    )
  {
    (exitFee, burnedCredit) = _calculateEarlyExitFeeLessBurnedCredit(from, controlledToken, amount);
  }

  function _calculateEarlyExitFeeNoCredit(address controlledToken, uint256 amount) internal view returns (uint256) {
    return _limitExitFee(
      amount,
      FixedPoint.multiplyUintByMantissa(amount, _tokenCreditPlans[controlledToken].creditLimitMantissa)
    );
  }

  function estimateCreditAccrualTime(
    address _controlledToken,
    uint256 _principal,
    uint256 _interest
  )
    external override
    view
    returns (uint256 durationSeconds)
  {
    durationSeconds =_estimateCreditAccrualTime(
      _controlledToken,
      _principal,
      _interest
    );
  }

  function _estimateCreditAccrualTime(
    address _controlledToken,
    uint256 _principal,
    uint256 _interest
  )
    internal
    view
    returns (uint256 durationSeconds)
  {
    uint256 accruedPerSecond = FixedPoint.multiplyUintByMantissa(_principal, _tokenCreditPlans[_controlledToken].creditRateMantissa);
    if (accruedPerSecond == 0) {
      return 0;
    }
    return _interest.div(accruedPerSecond);
  }

  function _burnCredit(address user, address controlledToken, uint256 credit) internal {
    _tokenCreditBalances[controlledToken][user].balance = uint256(_tokenCreditBalances[controlledToken][user].balance).sub(credit).toUint128();

    emit CreditBurned(user, controlledToken, credit);
  }

  function _accrueCredit(address user, address controlledToken, uint256 controlledTokenBalance, uint256 extra) internal {
    _updateCreditBalance(
      user,
      controlledToken,
      _calculateCreditBalance(user, controlledToken, controlledTokenBalance, extra)
    );
  }

  function _calculateCreditBalance(address user, address controlledToken, uint256 controlledTokenBalance, uint256 extra) internal view returns (uint256) {
    uint256 newBalance;
    CreditBalance storage creditBalance = _tokenCreditBalances[controlledToken][user];
    if (!creditBalance.initialized) {
      newBalance = 0;
    } else {
      uint256 credit = _calculateAccruedCredit(user, controlledToken, controlledTokenBalance);
      newBalance = _applyCreditLimit(controlledToken, controlledTokenBalance, uint256(creditBalance.balance).add(credit).add(extra));
    }
    return newBalance;
  }

  function _updateCreditBalance(address user, address controlledToken, uint256 newBalance) internal {
    uint256 oldBalance = _tokenCreditBalances[controlledToken][user].balance;

    _tokenCreditBalances[controlledToken][user] = CreditBalance({
      balance: newBalance.toUint128(),
      timestamp: _currentTime().toUint32(),
      initialized: true
    });

    if (oldBalance < newBalance) {
      emit CreditMinted(user, controlledToken, newBalance.sub(oldBalance));
    } 
    else if (newBalance < oldBalance) {
      emit CreditBurned(user, controlledToken, oldBalance.sub(newBalance));
    }
  }

  function _applyCreditLimit(address controlledToken, uint256 controlledTokenBalance, uint256 creditBalance) internal view returns (uint256) {
    uint256 creditLimit = FixedPoint.multiplyUintByMantissa(
      controlledTokenBalance,
      _tokenCreditPlans[controlledToken].creditLimitMantissa
    );
    if (creditBalance > creditLimit) {
      creditBalance = creditLimit;
    }

    return creditBalance;
  }

  function _calculateAccruedCredit(address user, address controlledToken, uint256 controlledTokenBalance) internal view returns (uint256) {
    uint256 userTimestamp = _tokenCreditBalances[controlledToken][user].timestamp;

    if (!_tokenCreditBalances[controlledToken][user].initialized) {
      return 0;
    }

    uint256 deltaTime = _currentTime().sub(userTimestamp);
    uint256 deltaMantissa = deltaTime.mul(_tokenCreditPlans[controlledToken].creditRateMantissa);
    return FixedPoint.multiplyUintByMantissa(controlledTokenBalance, deltaMantissa);
  }

  function balanceOfCredit(address user, address controlledToken) external override onlyControlledToken(controlledToken) returns (uint256) {
    _accrueCredit(user, controlledToken, IERC20Upgradeable(controlledToken).balanceOf(user), 0);
    return _tokenCreditBalances[controlledToken][user].balance;
  }

  function setCreditPlanOf(
    address _controlledToken,
    uint128 _creditRateMantissa,
    uint128 _creditLimitMantissa
  )
    external override
    onlyControlledToken(_controlledToken)
    onlyOwner
  {
    _tokenCreditPlans[_controlledToken] = CreditPlan({
      creditLimitMantissa: _creditLimitMantissa,
      creditRateMantissa: _creditRateMantissa
    });

    emit CreditPlanSet(_controlledToken, _creditLimitMantissa, _creditRateMantissa);
  }

  function creditPlanOf(
    address controlledToken
  )
    external override
    view
    returns (
      uint128 creditLimitMantissa,
      uint128 creditRateMantissa
    )
  {
    creditLimitMantissa = _tokenCreditPlans[controlledToken].creditLimitMantissa;
    creditRateMantissa = _tokenCreditPlans[controlledToken].creditRateMantissa;
  }

  function _calculateEarlyExitFeeLessBurnedCredit(
    address from,
    address controlledToken,
    uint256 amount
  )
    internal
    returns (
      uint256 earlyExitFee,
      uint256 creditBurned
    )
  {
    uint256 controlledTokenBalance = IERC20Upgradeable(controlledToken).balanceOf(from);
    require(controlledTokenBalance >= amount, "PrizePool/insuff-funds");
    _accrueCredit(from, controlledToken, controlledTokenBalance, 0);

    uint256 remainingExitFee = _calculateEarlyExitFeeNoCredit(controlledToken, controlledTokenBalance.sub(amount));

    uint256 availableCredit;
    if (_tokenCreditBalances[controlledToken][from].balance >= remainingExitFee) {
      availableCredit = uint256(_tokenCreditBalances[controlledToken][from].balance).sub(remainingExitFee);
    }

    uint256 totalExitFee = _calculateEarlyExitFeeNoCredit(controlledToken, amount);
    creditBurned = (availableCredit > totalExitFee) ? totalExitFee : availableCredit;
    earlyExitFee = totalExitFee.sub(creditBurned);
  }

  function setLiquidityCap(uint256 _liquidityCap) external override onlyOwner {
    _setLiquidityCap(_liquidityCap);
  }

  function _setLiquidityCap(uint256 _liquidityCap) internal {
    liquidityCap = _liquidityCap;
    emit LiquidityCapSet(_liquidityCap);
  }

  function _addControlledToken(ControlledTokenInterface _controlledToken, uint256 index) internal {
    require(_controlledToken.controller() == this, "PrizePool/token-ctrlr-mismatch");
    
    _tokens[index] = _controlledToken;
    emit ControlledTokenAdded(_controlledToken);
  }

  function setPrizeStrategy(TokenListenerInterface _prizeStrategy) external override onlyOwner {
    _setPrizeStrategy(_prizeStrategy);
  }

  function _setPrizeStrategy(TokenListenerInterface _prizeStrategy) internal {
    require(address(_prizeStrategy) != address(0), "PrizePool/prizeStrategy-not-zero");
    require(address(_prizeStrategy).supportsInterface(TokenListenerLibrary.ERC165_INTERFACE_ID_TOKEN_LISTENER), "PrizePool/prizeStrategy-invalid");
    prizeStrategy = _prizeStrategy;

    emit PrizeStrategySet(address(_prizeStrategy));
  }

  function tokens() external override view returns (ControlledTokenInterface[] memory) {
    return _tokens;
  }

  function _currentTime() internal virtual view returns (uint256) {
    return block.timestamp;
  }

  function accountedBalance() external override view returns (uint256) {
    return _tokenTotalSupply();
  }

  function compLikeDelegate(ICompLike compLike, address to) external onlyOwner {
    if (compLike.balanceOf(address(this)) > 0) {
      compLike.delegate(to);
    }
  }
  
  function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external override returns (bytes4){
    return IERC721ReceiverUpgradeable.onERC721Received.selector;
  }

  function _tokenTotalSupply() internal view returns (uint256) {
    uint256 total = reserveTotalSupply;
    ControlledTokenInterface[] memory tokens = _tokens; // SLOAD  
    uint256 tokensLength = tokens.length;
    
    for(uint256 i = 0; i < tokensLength; i++){
      total = total.add(IERC20Upgradeable(tokens[i]).totalSupply());
    }

    return total;
  }

  function _canAddLiquidity(uint256 _amount) internal view returns (bool) {
    uint256 tokenTotalSupply = _tokenTotalSupply();
    return (tokenTotalSupply.add(_amount) <= liquidityCap);
  }

  function _isControlled(ControlledTokenInterface controlledToken) internal view returns (bool) {
    ControlledTokenInterface[] memory tokens = _tokens; // SLOAD
    uint256 tokensLength = tokens.length;

    for(uint256 i = 0; i < tokensLength; i++) {
      if(tokens[i] == controlledToken) return true;
    }
    return false;
  }
  
  function isControlled(ControlledTokenInterface controlledToken) external view returns (bool) {
    return _isControlled(controlledToken);
  }

  function _canAwardExternal(address _externalToken) internal virtual view returns (bool);

  function _token() internal virtual view returns (IERC20Upgradeable);

  function _balance() internal virtual returns (uint256);

  function _supply(uint256 mintAmount) internal virtual;

  function _redeem(uint256 redeemAmount) internal virtual returns (uint256);

  modifier onlyControlledToken(address controlledToken) {
    require(_isControlled(ControlledTokenInterface(controlledToken)), "PrizePool/unknown-token");
    _;
  }

  modifier onlyPrizeStrategy() {
    require(_msgSender() == address(prizeStrategy), "PrizePool/only-prizeStrategy");
    _;
  }

  modifier canAddLiquidity(uint256 _amount) {
    require(_canAddLiquidity(_amount), "PrizePool/exceeds-liquidity-cap");
    _;
  }

  modifier onlyReserve() {
    ReserveInterface reserve = ReserveInterface(reserveRegistry.lookup());
    require(address(reserve) == msg.sender, "PrizePool/only-reserve");
    _;
  }
}// GPL-3.0

pragma solidity 0.6.12;


interface PeriodicPrizeStrategyListenerInterface is IERC165Upgradeable {

  function afterPrizePoolAwarded(uint256 randomNumber, uint256 prizePeriodStartedAt) external;

}// GPL-3.0

pragma solidity 0.6.12;

library PeriodicPrizeStrategyListenerLibrary {

  bytes4 public constant ERC165_INTERFACE_ID_PERIODIC_PRIZE_STRATEGY_LISTENER = 0x575072c6;
}// GPL-3.0

pragma solidity 0.6.12;


interface BeforeAwardListenerInterface is IERC165Upgradeable {

  function beforePrizePoolAwarded(uint256 randomNumber, uint256 prizePeriodStartedAt) external;

}// GPL-3.0

pragma solidity 0.6.12;

library BeforeAwardListenerLibrary {

  bytes4 public constant ERC165_INTERFACE_ID_BEFORE_AWARD_LISTENER = 0x4cdf9c3e;
}// GPL-3.0

pragma solidity 0.6.12;


abstract contract BeforeAwardListener is BeforeAwardListenerInterface {
  function supportsInterface(bytes4 interfaceId) external override view returns (bool) {
    return (
      interfaceId == Constants.ERC165_INTERFACE_ID_ERC165 || 
      interfaceId == BeforeAwardListenerLibrary.ERC165_INTERFACE_ID_BEFORE_AWARD_LISTENER
    );
  }
}// GPL-3.0

pragma solidity 0.6.12;



abstract contract PeriodicPrizeStrategy is Initializable,
                                           OwnableUpgradeable,
                                           TokenListener {

  using SafeMathUpgradeable for uint256;
  using SafeMathUpgradeable for uint16;
  using SafeCastUpgradeable for uint256;
  using SafeERC20Upgradeable for IERC20Upgradeable;
  using MappedSinglyLinkedList for MappedSinglyLinkedList.Mapping;
  using AddressUpgradeable for address;
  using ERC165CheckerUpgradeable for address;

  uint256 internal constant ETHEREUM_BLOCK_TIME_ESTIMATE_MANTISSA = 13.4 ether;

  event PrizePoolOpened(
    address indexed operator,
    uint256 indexed prizePeriodStartedAt
  );

  event RngRequestFailed();

  event PrizePoolAwardStarted(
    address indexed operator,
    address indexed prizePool,
    uint32 indexed rngRequestId,
    uint32 rngLockBlock
  );

  event PrizePoolAwardCancelled(
    address indexed operator,
    address indexed prizePool,
    uint32 indexed rngRequestId,
    uint32 rngLockBlock
  );

  event PrizePoolAwarded(
    address indexed operator,
    uint256 randomNumber
  );

  event RngServiceUpdated(
    RNGInterface indexed rngService
  );

  event TokenListenerUpdated(
    TokenListenerInterface indexed tokenListener
  );

  event RngRequestTimeoutSet(
    uint32 rngRequestTimeout
  );

  event PrizePeriodSecondsUpdated(
    uint256 prizePeriodSeconds
  );

  event BeforeAwardListenerSet(
    BeforeAwardListenerInterface indexed beforeAwardListener
  );

  event PeriodicPrizeStrategyListenerSet(
    PeriodicPrizeStrategyListenerInterface indexed periodicPrizeStrategyListener
  );

  event ExternalErc721AwardAdded(
    IERC721Upgradeable indexed externalErc721,
    uint256[] tokenIds
  );

  event ExternalErc20AwardAdded(
    IERC20Upgradeable indexed externalErc20
  );

  event ExternalErc721AwardRemoved(
    IERC721Upgradeable indexed externalErc721Award
  );

  event ExternalErc20AwardRemoved(
    IERC20Upgradeable indexed externalErc20Award
  );

  event Initialized(
    uint256 prizePeriodStart,
    uint256 prizePeriodSeconds,
    PrizePool indexed prizePool,
    TicketInterface ticket,
    IERC20Upgradeable sponsorship,
    RNGInterface rng,
    IERC20Upgradeable[] externalErc20Awards
  );

  struct RngRequest {
    uint32 id;
    uint32 lockBlock;
    uint32 requestedAt;
  }

  string constant public VERSION = "3.4.1";

  TokenListenerInterface public tokenListener;

  PrizePool public prizePool;
  TicketInterface public ticket;
  IERC20Upgradeable public sponsorship;
  RNGInterface public rng;

  RngRequest internal rngRequest;

  uint32 public rngRequestTimeout;

  uint256 public prizePeriodSeconds;
  uint256 public prizePeriodStartedAt;

  MappedSinglyLinkedList.Mapping internal externalErc20s;
  MappedSinglyLinkedList.Mapping internal externalErc721s;

  mapping (IERC721Upgradeable => uint256[]) internal externalErc721TokenIds;

  BeforeAwardListenerInterface public beforeAwardListener;

  PeriodicPrizeStrategyListenerInterface public periodicPrizeStrategyListener;

  function initialize (
    uint256 _prizePeriodStart,
    uint256 _prizePeriodSeconds,
    PrizePool _prizePool,
    TicketInterface _ticket,
    IERC20Upgradeable _sponsorship,
    RNGInterface _rng,
    IERC20Upgradeable[] memory externalErc20Awards
  ) public initializer {
    require(address(_prizePool) != address(0), "PeriodicPrizeStrategy/prize-pool-not-zero");
    require(address(_ticket) != address(0), "PeriodicPrizeStrategy/ticket-not-zero");
    require(address(_sponsorship) != address(0), "PeriodicPrizeStrategy/sponsorship-not-zero");
    require(address(_rng) != address(0), "PeriodicPrizeStrategy/rng-not-zero");
    prizePool = _prizePool;
    ticket = _ticket;
    rng = _rng;
    sponsorship = _sponsorship;
    _setPrizePeriodSeconds(_prizePeriodSeconds);

    __Ownable_init();
    Constants.REGISTRY.setInterfaceImplementer(address(this), Constants.TOKENS_RECIPIENT_INTERFACE_HASH, address(this));

    externalErc20s.initialize();
    for (uint256 i = 0; i < externalErc20Awards.length; i++) {
      _addExternalErc20Award(externalErc20Awards[i]);
    }

    prizePeriodSeconds = _prizePeriodSeconds;
    prizePeriodStartedAt = _prizePeriodStart;

    externalErc721s.initialize();

    _setRngRequestTimeout(1800);

    emit Initialized(
      _prizePeriodStart,
      _prizePeriodSeconds,
      _prizePool,
      _ticket,
      _sponsorship,
      _rng,
      externalErc20Awards
    );
    emit PrizePoolOpened(_msgSender(), prizePeriodStartedAt);
  }

  function _distribute(uint256 randomNumber) internal virtual;

  function currentPrize() public view returns (uint256) {
    return prizePool.awardBalance();
  }

  function setTokenListener(TokenListenerInterface _tokenListener) external onlyOwner requireAwardNotInProgress {
    require(address(0) == address(_tokenListener) || address(_tokenListener).supportsInterface(TokenListenerLibrary.ERC165_INTERFACE_ID_TOKEN_LISTENER), "PeriodicPrizeStrategy/token-listener-invalid");

    tokenListener = _tokenListener;

    emit TokenListenerUpdated(tokenListener);
  }

  function estimateRemainingBlocksToPrize(uint256 secondsPerBlockMantissa) public view returns (uint256) {
    return FixedPoint.divideUintByMantissa(
      _prizePeriodRemainingSeconds(),
      secondsPerBlockMantissa
    );
  }

  function prizePeriodRemainingSeconds() external view returns (uint256) {
    return _prizePeriodRemainingSeconds();
  }

  function _prizePeriodRemainingSeconds() internal view returns (uint256) {
    uint256 endAt = _prizePeriodEndAt();
    uint256 time = _currentTime();
    if (time > endAt) {
      return 0;
    }
    return endAt.sub(time);
  }

  function isPrizePeriodOver() external view returns (bool) {
    return _isPrizePeriodOver();
  }

  function _isPrizePeriodOver() internal view returns (bool) {
    return _currentTime() >= _prizePeriodEndAt();
  }

  function _awardTickets(address user, uint256 amount) internal {
    prizePool.award(user, amount, address(ticket));
  }
  
  function _awardToken(address user, uint256 amount, uint8 tokenIndex) internal {
    ControlledTokenInterface[] memory _controlledTokens = prizePool.tokens();
    require(tokenIndex <= _controlledTokens.length, "PeriodicPrizeStrategy/award-invalid-token-index");
    ControlledTokenInterface _token = _controlledTokens[tokenIndex];
    prizePool.award(user, amount, address(_token));
  }

  function _awardAllExternalTokens(address winner) internal {
    _awardExternalErc20s(winner);
    _awardExternalErc721s(winner);
  }

  function _awardExternalErc20s(address winner) internal {
    address currentToken = externalErc20s.start();
    while (currentToken != address(0) && currentToken != externalErc20s.end()) {
      uint256 balance = IERC20Upgradeable(currentToken).balanceOf(address(prizePool));
      if (balance > 0) {
        prizePool.awardExternalERC20(winner, currentToken, balance);
      }
      currentToken = externalErc20s.next(currentToken);
    }
  }

  function _awardExternalErc721s(address winner) internal {
    address currentToken = externalErc721s.start();
    while (currentToken != address(0) && currentToken != externalErc721s.end()) {
      uint256 balance = IERC721Upgradeable(currentToken).balanceOf(address(prizePool));
      if (balance > 0) {
        prizePool.awardExternalERC721(winner, currentToken, externalErc721TokenIds[IERC721Upgradeable(currentToken)]);
        _removeExternalErc721AwardTokens(IERC721Upgradeable(currentToken));
      }
      currentToken = externalErc721s.next(currentToken);
    }
    externalErc721s.clearAll();
  }

  function prizePeriodEndAt() external view returns (uint256) {
    return _prizePeriodEndAt();
  }

  function _prizePeriodEndAt() internal view returns (uint256) {
    return prizePeriodStartedAt.add(prizePeriodSeconds);
  }

  function beforeTokenTransfer(address from, address to, uint256 amount, address controlledToken) external override onlyPrizePool {
    require(from != to, "PeriodicPrizeStrategy/transfer-to-self");

    if (controlledToken == address(ticket)) {
      _requireAwardNotInProgress();
    }

    if (address(tokenListener) != address(0)) {
      tokenListener.beforeTokenTransfer(from, to, amount, controlledToken);
    }
  }

  function beforeTokenMint(
    address to,
    uint256 amount,
    address controlledToken,
    address referrer
  )
    external
    override
    onlyPrizePool
  {
    if (controlledToken == address(ticket)) {
      _requireAwardNotInProgress();
    }
    if (address(tokenListener) != address(0)) {
      tokenListener.beforeTokenMint(to, amount, controlledToken, referrer);
    }
  }

  function _currentTime() internal virtual view returns (uint256) {
    return block.timestamp;
  }

  function _currentBlock() internal virtual view returns (uint256) {
    return block.number;
  }

  function startAward() external requireCanStartAward {
    (address feeToken, uint256 requestFee) = rng.getRequestFee();
    if (feeToken != address(0) && requestFee > 0) {
      IERC20Upgradeable(feeToken).safeApprove(address(rng), requestFee);
    }

    (uint32 requestId, uint32 lockBlock) = rng.requestRandomNumber();
    rngRequest.id = requestId;
    rngRequest.lockBlock = lockBlock;
    rngRequest.requestedAt = _currentTime().toUint32();

    emit PrizePoolAwardStarted(_msgSender(), address(prizePool), requestId, lockBlock);
  }

  function cancelAward() public {
    require(isRngTimedOut(), "PeriodicPrizeStrategy/rng-not-timedout");
    uint32 requestId = rngRequest.id;
    uint32 lockBlock = rngRequest.lockBlock;
    delete rngRequest;
    emit RngRequestFailed();
    emit PrizePoolAwardCancelled(msg.sender, address(prizePool), requestId, lockBlock);
  }

  function completeAward() external requireCanCompleteAward {
    uint256 randomNumber = rng.randomNumber(rngRequest.id);
    delete rngRequest;

    if (address(beforeAwardListener) != address(0)) {
      beforeAwardListener.beforePrizePoolAwarded(randomNumber, prizePeriodStartedAt);
    }
    _distribute(randomNumber);
    if (address(periodicPrizeStrategyListener) != address(0)) {
      periodicPrizeStrategyListener.afterPrizePoolAwarded(randomNumber, prizePeriodStartedAt);
    }

    prizePeriodStartedAt = _calculateNextPrizePeriodStartTime(_currentTime());

    emit PrizePoolAwarded(_msgSender(), randomNumber);
    emit PrizePoolOpened(_msgSender(), prizePeriodStartedAt);
  }

  function setBeforeAwardListener(BeforeAwardListenerInterface _beforeAwardListener) external onlyOwner requireAwardNotInProgress {
    require(
      address(0) == address(_beforeAwardListener) || address(_beforeAwardListener).supportsInterface(BeforeAwardListenerLibrary.ERC165_INTERFACE_ID_BEFORE_AWARD_LISTENER),
      "PeriodicPrizeStrategy/beforeAwardListener-invalid"
    );

    beforeAwardListener = _beforeAwardListener;

    emit BeforeAwardListenerSet(_beforeAwardListener);
  }

  function setPeriodicPrizeStrategyListener(PeriodicPrizeStrategyListenerInterface _periodicPrizeStrategyListener) external onlyOwner requireAwardNotInProgress {
    require(
      address(0) == address(_periodicPrizeStrategyListener) || address(_periodicPrizeStrategyListener).supportsInterface(PeriodicPrizeStrategyListenerLibrary.ERC165_INTERFACE_ID_PERIODIC_PRIZE_STRATEGY_LISTENER),
      "PeriodicPrizeStrategy/prizeStrategyListener-invalid"
    );

    periodicPrizeStrategyListener = _periodicPrizeStrategyListener;

    emit PeriodicPrizeStrategyListenerSet(_periodicPrizeStrategyListener);
  }

  function _calculateNextPrizePeriodStartTime(uint256 currentTime) internal view returns (uint256) {
    uint256 elapsedPeriods = currentTime.sub(prizePeriodStartedAt).div(prizePeriodSeconds);
    return prizePeriodStartedAt.add(elapsedPeriods.mul(prizePeriodSeconds));
  }

  function calculateNextPrizePeriodStartTime(uint256 currentTime) external view returns (uint256) {
    return _calculateNextPrizePeriodStartTime(currentTime);
  }

  function canStartAward() external view returns (bool) {
    return _isPrizePeriodOver() && !isRngRequested();
  }

  function canCompleteAward() external view returns (bool) {
    return isRngRequested() && isRngCompleted();
  }

  function isRngRequested() public view returns (bool) {
    return rngRequest.id != 0;
  }

  function isRngCompleted() public view returns (bool) {
    return rng.isRequestComplete(rngRequest.id);
  }

  function getLastRngLockBlock() external view returns (uint32) {
    return rngRequest.lockBlock;
  }

  function getLastRngRequestId() external view returns (uint32) {
    return rngRequest.id;
  }

  function setRngService(RNGInterface rngService) external onlyOwner requireAwardNotInProgress {
    require(!isRngRequested(), "PeriodicPrizeStrategy/rng-in-flight");

    rng = rngService;
    emit RngServiceUpdated(rngService);
  }

  function setRngRequestTimeout(uint32 _rngRequestTimeout) external onlyOwner requireAwardNotInProgress {
    _setRngRequestTimeout(_rngRequestTimeout);
  }

  function _setRngRequestTimeout(uint32 _rngRequestTimeout) internal {
    require(_rngRequestTimeout > 60, "PeriodicPrizeStrategy/rng-timeout-gt-60-secs");
    rngRequestTimeout = _rngRequestTimeout;
    emit RngRequestTimeoutSet(rngRequestTimeout);
  }

  function setPrizePeriodSeconds(uint256 _prizePeriodSeconds) external onlyOwner requireAwardNotInProgress {
    _setPrizePeriodSeconds(_prizePeriodSeconds);
  }

  function _setPrizePeriodSeconds(uint256 _prizePeriodSeconds) internal {
    require(_prizePeriodSeconds > 0, "PeriodicPrizeStrategy/prize-period-greater-than-zero");
    prizePeriodSeconds = _prizePeriodSeconds;

    emit PrizePeriodSecondsUpdated(prizePeriodSeconds);
  }

  function getExternalErc20Awards() external view returns (address[] memory) {
    return externalErc20s.addressArray();
  }

  function addExternalErc20Award(IERC20Upgradeable _externalErc20) external onlyOwnerOrListener requireAwardNotInProgress {
    _addExternalErc20Award(_externalErc20);
  }

  function _addExternalErc20Award(IERC20Upgradeable _externalErc20) internal {
    require(address(_externalErc20).isContract(), "PeriodicPrizeStrategy/erc20-null");
    require(prizePool.canAwardExternal(address(_externalErc20)), "PeriodicPrizeStrategy/cannot-award-external");
    (bool succeeded, bytes memory returnValue) = address(_externalErc20).staticcall(abi.encodeWithSignature("totalSupply()"));
    require(succeeded, "PeriodicPrizeStrategy/erc20-invalid");
    externalErc20s.addAddress(address(_externalErc20));
    emit ExternalErc20AwardAdded(_externalErc20);
  }

  function addExternalErc20Awards(IERC20Upgradeable[] calldata _externalErc20s) external onlyOwnerOrListener requireAwardNotInProgress {
    for (uint256 i = 0; i < _externalErc20s.length; i++) {
      _addExternalErc20Award(_externalErc20s[i]);
    }
  }

  function removeExternalErc20Award(IERC20Upgradeable _externalErc20, IERC20Upgradeable _prevExternalErc20) external onlyOwner requireAwardNotInProgress {
    externalErc20s.removeAddress(address(_prevExternalErc20), address(_externalErc20));
    emit ExternalErc20AwardRemoved(_externalErc20);
  }

  function getExternalErc721Awards() external view returns (address[] memory) {
    return externalErc721s.addressArray();
  }

  function getExternalErc721AwardTokenIds(IERC721Upgradeable _externalErc721) external view returns (uint256[] memory) {
    return externalErc721TokenIds[_externalErc721];
  }

  function addExternalErc721Award(IERC721Upgradeable _externalErc721, uint256[] calldata _tokenIds) external onlyOwnerOrListener requireAwardNotInProgress {
    require(prizePool.canAwardExternal(address(_externalErc721)), "PeriodicPrizeStrategy/cannot-award-external");
    require(address(_externalErc721).supportsInterface(Constants.ERC165_INTERFACE_ID_ERC721), "PeriodicPrizeStrategy/erc721-invalid");
    
    if (!externalErc721s.contains(address(_externalErc721))) {
      externalErc721s.addAddress(address(_externalErc721));
    }

    for (uint256 i = 0; i < _tokenIds.length; i++) {
      _addExternalErc721Award(_externalErc721, _tokenIds[i]);
    }

    emit ExternalErc721AwardAdded(_externalErc721, _tokenIds);
  }

  function _addExternalErc721Award(IERC721Upgradeable _externalErc721, uint256 _tokenId) internal {
    require(IERC721Upgradeable(_externalErc721).ownerOf(_tokenId) == address(prizePool), "PeriodicPrizeStrategy/unavailable-token");
    for (uint256 i = 0; i < externalErc721TokenIds[_externalErc721].length; i++) {
      if (externalErc721TokenIds[_externalErc721][i] == _tokenId) {
        revert("PeriodicPrizeStrategy/erc721-duplicate");
      }
    }
    externalErc721TokenIds[_externalErc721].push(_tokenId);
  }

  function removeExternalErc721Award(
    IERC721Upgradeable _externalErc721,
    IERC721Upgradeable _prevExternalErc721
  )
    external
    onlyOwner
    requireAwardNotInProgress
  {
    externalErc721s.removeAddress(address(_prevExternalErc721), address(_externalErc721));
    _removeExternalErc721AwardTokens(_externalErc721);
  }

  function _removeExternalErc721AwardTokens(
    IERC721Upgradeable _externalErc721
  )
    internal
  {
    delete externalErc721TokenIds[_externalErc721];
    emit ExternalErc721AwardRemoved(_externalErc721);
  }

  function _requireAwardNotInProgress() internal view {
    uint256 currentBlock = _currentBlock();
    require(rngRequest.lockBlock == 0 || currentBlock < rngRequest.lockBlock, "PeriodicPrizeStrategy/rng-in-flight");
  }

  function isRngTimedOut() public view returns (bool) {
    if (rngRequest.requestedAt == 0) {
      return false;
    } else {
      return _currentTime() > uint256(rngRequestTimeout).add(rngRequest.requestedAt);
    }
  }

  modifier onlyOwnerOrListener() {
    require(_msgSender() == owner() ||
            _msgSender() == address(periodicPrizeStrategyListener) ||
            _msgSender() == address(beforeAwardListener),
            "PeriodicPrizeStrategy/only-owner-or-listener");
    _;
  }

  modifier requireAwardNotInProgress() {
    _requireAwardNotInProgress();
    _;
  }

  modifier requireCanStartAward() {
    require(_isPrizePeriodOver(), "PeriodicPrizeStrategy/prize-period-not-over");
    require(!isRngRequested(), "PeriodicPrizeStrategy/rng-already-requested");
    _;
  }

  modifier requireCanCompleteAward() {
    require(isRngRequested(), "PeriodicPrizeStrategy/rng-not-requested");
    require(isRngCompleted(), "PeriodicPrizeStrategy/rng-not-complete");
    _;
  }

  modifier onlyPrizePool() {
    require(_msgSender() == address(prizePool), "PeriodicPrizeStrategy/only-prize-pool");
    _;
  }
}// MIT

pragma solidity 0.6.12;


contract MultipleWinners is PeriodicPrizeStrategy, PrizeSplit {


  uint256 internal __numberOfWinners;
  
  bool public splitExternalErc20Awards;

  mapping(address => bool) public isBlocklisted;

  bool public carryOverBlocklist;

  uint256 public blocklistRetryCount;

  event SplitExternalErc20AwardsSet(bool splitExternalErc20Awards);

  event NumberOfWinnersSet(uint256 numberOfWinners);

  event BlocklistCarrySet(bool carry);

  event BlocklistSet(address indexed user, bool isBlocked);

  event BlocklistRetryCountSet(uint256 count);

  event RetryMaxLimitReached(uint256 numberOfWinners);

  event NoWinners();

  function initializeMultipleWinners (
    uint256 _prizePeriodStart,
    uint256 _prizePeriodSeconds,
    PrizePool _prizePool,
    TicketInterface _ticket,
    IERC20Upgradeable _sponsorship,
    RNGInterface _rng,
    uint256 _numberOfWinners
  ) public initializer {
    IERC20Upgradeable[] memory _externalErc20Awards;

    PeriodicPrizeStrategy.initialize(
      _prizePeriodStart,
      _prizePeriodSeconds,
      _prizePool,
      _ticket,
      _sponsorship,
      _rng,
      _externalErc20Awards
    );

    _setNumberOfWinners(_numberOfWinners);
  }

  function setBlocklisted(address _user, bool _isBlocked) external onlyOwner requireAwardNotInProgress returns (bool) {

    isBlocklisted[_user] = _isBlocked;

    emit BlocklistSet(_user, _isBlocked);

    return true;
  }

  function setCarryBlocklist(bool _carry) external onlyOwner requireAwardNotInProgress returns (bool) {

    carryOverBlocklist = _carry;

    emit BlocklistCarrySet(_carry);

    return true;
  }

  function setBlocklistRetryCount(uint256 _count) external onlyOwner requireAwardNotInProgress returns (bool) {

    blocklistRetryCount = _count;

    emit BlocklistRetryCountSet(_count);

    return true;
  }
  
  function setSplitExternalErc20Awards(bool _splitExternalErc20Awards) external onlyOwner requireAwardNotInProgress {

    splitExternalErc20Awards = _splitExternalErc20Awards;

    emit SplitExternalErc20AwardsSet(splitExternalErc20Awards);
  }

  function setNumberOfWinners(uint256 count) external onlyOwner requireAwardNotInProgress {

    _setNumberOfWinners(count);
  }

  function _setNumberOfWinners(uint256 count) internal {

    require(count > 0, "MultipleWinners/winners-gte-one");

    __numberOfWinners = count;
    emit NumberOfWinnersSet(count);
  }

  function numberOfWinners() external view returns (uint256) {

    return __numberOfWinners;
  }

  function _awardPrizeSplitAmount(address target, uint256 amount, uint8 tokenIndex) override internal {

    _awardToken(target, amount, tokenIndex);
  }

  function _distribute(uint256 randomNumber) internal override {

    uint256 prize = prizePool.captureAwardBalance();
    
    prize = _distributePrizeSplits(prize);

    if (IERC20Upgradeable(address(ticket)).totalSupply() == 0) {
      emit NoWinners();
      return;
    }

    bool _carryOverBlocklistPrizes = carryOverBlocklist;

    uint256 numberOfWinners = __numberOfWinners;
    address[] memory winners = new address[](numberOfWinners);
    uint256 nextRandom = randomNumber;
    uint256 winnerCount = 0;
    uint256 retries = 0;
    uint256 _retryCount = blocklistRetryCount;
    while (winnerCount < numberOfWinners) {
      address winner = ticket.draw(nextRandom);

      if (!isBlocklisted[winner]) {
        winners[winnerCount++] = winner;
      } else if (++retries >= _retryCount) {
        emit RetryMaxLimitReached(winnerCount);
        if(winnerCount == 0) {
          emit NoWinners();
        }
        break;
      }

      bytes32 nextRandomHash = keccak256(abi.encodePacked(nextRandom + 499 + winnerCount*521));
      nextRandom = uint256(nextRandomHash);
    }

    _awardExternalErc721s(winners[0]);

    uint256 prizeShare = _carryOverBlocklistPrizes ? prize.div(numberOfWinners) : prize.div(winnerCount);
    if (prizeShare > 0) {
      for (uint i = 0; i < winnerCount; i++) {
        _awardTickets(winners[i], prizeShare);
      }
    }

    if (splitExternalErc20Awards) {
      address currentToken = externalErc20s.start();
      while (currentToken != address(0) && currentToken != externalErc20s.end()) {
        uint256 balance = IERC20Upgradeable(currentToken).balanceOf(address(prizePool));
        uint256 split = _carryOverBlocklistPrizes ? balance.div(numberOfWinners) : balance.div(winnerCount);
        if (split > 0) {
          for (uint256 i = 0; i < winnerCount; i++) {
            prizePool.awardExternalERC20(winners[i], currentToken, split);
          }
        }
        currentToken = externalErc20s.next(currentToken);
      }
    } else {
      _awardExternalErc20s(winners[0]);
    }
  }
}// GPL-3.0

pragma solidity 0.6.12;


contract MultipleWinnersProxyFactory is ProxyFactory {


  MultipleWinners public instance;

  constructor () public {
    instance = new MultipleWinners();
  }

  function create() external returns (MultipleWinners) {

    return MultipleWinners(deployMinimal(address(instance), ""));
  }

}// GPL-3.0

pragma solidity 0.6.12;


contract MultipleWinnersBuilder {


  event MultipleWinnersCreated(address indexed prizeStrategy);

  struct MultipleWinnersConfig {
    RNGInterface rngService;
    uint256 prizePeriodStart;
    uint256 prizePeriodSeconds;
    string ticketName;
    string ticketSymbol;
    string sponsorshipName;
    string sponsorshipSymbol;
    uint256 ticketCreditLimitMantissa;
    uint256 ticketCreditRateMantissa;
    uint256 numberOfWinners;
    MultipleWinners.PrizeSplitConfig[] prizeSplits;
    bool splitExternalErc20Awards;
  }

  MultipleWinnersProxyFactory public multipleWinnersProxyFactory;
  ControlledTokenBuilder public controlledTokenBuilder;

  constructor (
    MultipleWinnersProxyFactory _multipleWinnersProxyFactory,
    ControlledTokenBuilder _controlledTokenBuilder
  ) public {
    require(address(_multipleWinnersProxyFactory) != address(0), "MultipleWinnersBuilder/multipleWinnersProxyFactory-not-zero");
    require(address(_controlledTokenBuilder) != address(0), "MultipleWinnersBuilder/token-builder-not-zero");
    multipleWinnersProxyFactory = _multipleWinnersProxyFactory;
    controlledTokenBuilder = _controlledTokenBuilder;
  }

  function createMultipleWinners(
    PrizePool prizePool,
    MultipleWinnersConfig memory prizeStrategyConfig,
    uint8 decimals,
    address owner
  ) external returns (MultipleWinners) {

    MultipleWinners mw = multipleWinnersProxyFactory.create();

    Ticket ticket = _createTicket(
      prizeStrategyConfig.ticketName,
      prizeStrategyConfig.ticketSymbol,
      decimals,
      prizePool
    );

    ControlledToken sponsorship = _createSponsorship(
      prizeStrategyConfig.sponsorshipName,
      prizeStrategyConfig.sponsorshipSymbol,
      decimals,
      prizePool
    );

    mw.initializeMultipleWinners(
      prizeStrategyConfig.prizePeriodStart,
      prizeStrategyConfig.prizePeriodSeconds,
      prizePool,
      ticket,
      sponsorship,
      prizeStrategyConfig.rngService,
      prizeStrategyConfig.numberOfWinners
    );

    mw.setPrizeSplits(prizeStrategyConfig.prizeSplits);

    if (prizeStrategyConfig.splitExternalErc20Awards) {
      mw.setSplitExternalErc20Awards(true);
    }

    mw.transferOwnership(owner);

    emit MultipleWinnersCreated(address(mw));

    return mw;
  }

  function _createTicket(
    string memory name,
    string memory token,
    uint8 decimals,
    PrizePool prizePool
  ) internal returns (Ticket) {

    return controlledTokenBuilder.createTicket(
      ControlledTokenBuilder.ControlledTokenConfig(
        name,
        token,
        decimals,
        prizePool
      )
    );
  }

  function _createSponsorship(
    string memory name,
    string memory token,
    uint8 decimals,
    PrizePool prizePool
  ) internal returns (ControlledToken) {

    return controlledTokenBuilder.createControlledToken(
      ControlledTokenBuilder.ControlledTokenConfig(
        name,
        token,
        decimals,
        prizePool
      )
    );
  }
}