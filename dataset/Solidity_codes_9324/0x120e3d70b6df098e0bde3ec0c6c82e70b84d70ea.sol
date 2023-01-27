
pragma solidity ^0.8.9;


interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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
}

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}

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

    function transfer(address to, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {

        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
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

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
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

}

interface IERC20Permit {
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function nonces(address owner) external view returns (uint256);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

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
}

library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

abstract contract EIP712 {
    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;
    address private immutable _CACHED_THIS;

    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;
    bytes32 private immutable _TYPE_HASH;


    constructor(string memory name, string memory version) {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = block.chainid;
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
        _CACHED_THIS = address(this);
        _TYPE_HASH = typeHash;
    }

    function _domainSeparatorV4() internal view returns (bytes32) {
        if (address(this) == _CACHED_THIS && block.chainid == _CACHED_CHAIN_ID) {
            return _CACHED_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
        }
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
    }

    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
    }
}

library Counters {
    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

abstract contract ERC20Permit is ERC20, IERC20Permit, EIP712 {
    using Counters for Counters.Counter;

    mapping(address => Counters.Counter) private _nonces;

    bytes32 private immutable _PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    constructor(string memory name) EIP712(name, "1") {}

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual override {
        require(block.timestamp <= deadline, "ERC20Permit: expired deadline");

        bytes32 structHash = keccak256(abi.encode(_PERMIT_TYPEHASH, owner, spender, value, _useNonce(owner), deadline));

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, v, r, s);
        require(signer == owner, "ERC20Permit: invalid signature");

        _approve(owner, spender, value);
    }

    function nonces(address owner) public view virtual override returns (uint256) {
        return _nonces[owner].current();
    }

    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _domainSeparatorV4();
    }

    function _useNonce(address owner) internal virtual returns (uint256 current) {
        Counters.Counter storage nonce = _nonces[owner];
        current = nonce.current();
        nonce.increment();
    }
}

library Math {
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b + (a % b == 0 ? 0 : 1);
    }
}

library Arrays {
    function findUpperBound(uint256[] storage array, uint256 element) internal view returns (uint256) {
        if (array.length == 0) {
            return 0;
        }

        uint256 low = 0;
        uint256 high = array.length;

        while (low < high) {
            uint256 mid = Math.average(low, high);

            if (array[mid] > element) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        if (low > 0 && array[low - 1] == element) {
            return low - 1;
        } else {
            return low;
        }
    }
}

abstract contract ERC20Snapshot is ERC20 {

    using Arrays for uint256[];
    using Counters for Counters.Counter;

    struct Snapshots {
        uint256[] ids;
        uint256[] values;
    }

    mapping(address => Snapshots) private _accountBalanceSnapshots;
    Snapshots private _totalSupplySnapshots;

    Counters.Counter private _currentSnapshotId;

    event Snapshot(uint256 id);

    function _snapshot() internal virtual returns (uint256) {
        _currentSnapshotId.increment();

        uint256 currentId = _getCurrentSnapshotId();
        emit Snapshot(currentId);
        return currentId;
    }

    function _getCurrentSnapshotId() internal view virtual returns (uint256) {
        return _currentSnapshotId.current();
    }

    function balanceOfAt(address account, uint256 snapshotId) public view virtual returns (uint256) {
        (bool snapshotted, uint256 value) = _valueAt(snapshotId, _accountBalanceSnapshots[account]);

        return snapshotted ? value : balanceOf(account);
    }

    function totalSupplyAt(uint256 snapshotId) public view virtual returns (uint256) {
        (bool snapshotted, uint256 value) = _valueAt(snapshotId, _totalSupplySnapshots);

        return snapshotted ? value : totalSupply();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        if (from == address(0)) {
            _updateAccountSnapshot(to);
            _updateTotalSupplySnapshot();
        } else if (to == address(0)) {
            _updateAccountSnapshot(from);
            _updateTotalSupplySnapshot();
        } else {
            _updateAccountSnapshot(from);
            _updateAccountSnapshot(to);
        }
    }

    function _valueAt(uint256 snapshotId, Snapshots storage snapshots) private view returns (bool, uint256) {
        require(snapshotId > 0, "ERC20Snapshot: id is 0");
        require(snapshotId <= _getCurrentSnapshotId(), "ERC20Snapshot: nonexistent id");


        uint256 index = snapshots.ids.findUpperBound(snapshotId);

        if (index == snapshots.ids.length) {
            return (false, 0);
        } else {
            return (true, snapshots.values[index]);
        }
    }

    function _updateAccountSnapshot(address account) private {
        _updateSnapshot(_accountBalanceSnapshots[account], balanceOf(account));
    }

    function _updateTotalSupplySnapshot() private {
        _updateSnapshot(_totalSupplySnapshots, totalSupply());
    }

    function _updateSnapshot(Snapshots storage snapshots, uint256 currentValue) private {
        uint256 currentId = _getCurrentSnapshotId();
        if (_lastSnapshotId(snapshots.ids) < currentId) {
            snapshots.ids.push(currentId);
            snapshots.values.push(currentValue);
        }
    }

    function _lastSnapshotId(uint256[] storage ids) private view returns (uint256) {
        if (ids.length == 0) {
            return 0;
        } else {
            return ids[ids.length - 1];
        }
    }
}

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {

        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
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
}

library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

contract MuskGoldFarmV1 is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserDeposit {
        uint256 balance; // THE DEPOSITED NUMBER OF TOKENS BY THE USER
        uint256 unlockTime; // TIME WHEN THE USER CAN WITHDRAW FUNDS (BASED ON EPOCH)
        uint256 lastPayout; // BLOCK NUMBER OF THE LAST PAYOUT FOR THIS USER IN THIS POOL
        uint256 totalEarned; // TOTAL NUMBER OF TOKENS THIS USER HAS EARNED
    }

    struct RewardPool {
        IERC20 depositToken; // ADDRESS OF DEPOSITED TOKEN CONTRACT
        bool active; // DETERMINES WHETHER OR NOT THIS POOL IS USABLE
        bool hidden; // FLAG FOR WHETHER UI SHOULD RENDER THIS
        bool uniV2Lp; // SIGNIFIES A IUNISWAPV2PAIR
        bool selfStake; // SIGNIFIES IF THIS IS A 'SINGLE SIDED' SELF STAKE
        bytes32 lpOrigin; // ORIGIN OF LP TOKEN BEING DEPOSITED E.G. SUSHI, UNISWAP, PANCAKE - NULL IF NOT N LP TOKEN
        uint256 lockSeconds; // HOW LONG UNTIL AN LP DEPOSIT CAN BE REMOVED IN SECONDS
        bool lockEnforced; // DETERMINES WHETER TIME LOCKS ARE ENFORCED
        uint256 rewardPerBlock; // HOW MANY TOKENS TO REWARD PER BLOCK FOR THIS POOL
        bytes32 label; // TEXT LABEL STRICTLY FOR READABILITY AND RENDERING
        bytes32 order; // DISPLAY/PRESENTATION ORDER OF THE POOL
        uint256 depositSum; // SUM OF ALL DEPOSITED TOKENS IN THIS POOL
    }

    struct UserFarmState {
        RewardPool[] pools; // REWARD POOLS
        uint256[] balance; // DEPOSITS BY POOL
        uint256[] unlockTime; // UNLOCK TIME FOR EACH POOL DEPOSIT
        uint256[] pending; // PENDING REWARDS BY POOL
        uint256[] earnings; // EARNINGS BY POOL
        uint256[] depTknBal; // USER BALANCE OF DEPOSIT TOKEN
        uint256[] depTknSupply; // TOTAL SUPPLY OF DEPOSIT TOKEN
        uint256[] reserve0; // RESERVE0 AMOUNT FOR LP TKN0
        uint256[] reserve1; // RESERVE1 AMOUNT FOR LP TKN1
        address[] token0; // ADDRESS OF LP TOKEN 0
        address[] token1; // ADDRESS OF LP TOKEN 1
        uint256 rewardTknBal; // CURRENT USER HOLDINGS OF THE REWARD TOKEN
        uint256 pendingAllPools; // REWARDS PENDING FOR ALL POOLS
        uint256 earningsAllPools; // REWARDS EARNED FOR ALL POOLS
    }

    bytes32 public name; // POOL NAME, FOR DISPLAY ON BLOCK EXPLORER
    IERC20 public rewardToken; // ADDRESS OF THE ERC20 REWARD TOKEN
    address public rewardWallet; // WALLE THAT REWARD TOKENS ARE DRAWN FROM
    uint256 public earliestRewards; // EARLIEST BLOCK REWARDS CAN BE GENERATED FROM (FOR FAIR LAUNCH)
    uint256 public paidOut = 0; // TOTAL AMOUNT OF REWARDS THAT HAVE BEEN PAID OUT

    RewardPool[] public rewardPools; // INFO OF EACH POOL
    address[] public depositAddresses; // LIST OF ADDRESSES THAT CURRENTLY HAVE FUNDS DEPOSITED
    mapping(uint256 => mapping(address => UserDeposit)) public userDeposits; // INFO OF EACH USER THAT STAKES LP TOKENS

    event Deposit(
        address indexed from,
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event Reward(address indexed user, uint256 indexed pid, uint256 amount);
    event Restake(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );

    constructor(
        IERC20 _rewardToken,
        address _rewardWallet,
        uint256 _earliestRewards
    ) {
        name = "Musk Gold Farm";
        rewardToken = _rewardToken;
        rewardWallet = _rewardWallet;
        earliestRewards = _earliestRewards;
    }


    function setRewardWallet(address _source) external onlyOwner {
        rewardWallet = _source;
    }

    function fund(uint256 _amount) external {
        require(msg.sender != rewardWallet, "Sender is reward wallet");
        rewardToken.safeTransferFrom(
            address(msg.sender),
            rewardWallet,
            _amount
        );
    }


    function addPool(
        IERC20 _depositToken,
        bool _active,
        bool _hidden,
        bool _uniV2Lp,
        bytes32 _lpOrigin,
        uint256 _lockSeconds,
        bool _lockEnforced,
        uint256 _rewardPerBlock,
        bytes32 _label,
        bytes32 _order
    ) external onlyOwner {
        require(
            poolExists(_depositToken, _lockSeconds) == false,
            "Reward pool for token already exists"
        );

        bool selfStake = false;
        if (_depositToken == rewardToken) {
            selfStake = true;
            _uniV2Lp = false;
        }

        rewardPools.push(
            RewardPool({
                depositToken: _depositToken,
                active: _active,
                hidden: _hidden,
                uniV2Lp: _uniV2Lp,
                selfStake: selfStake, // MARKS IF A "SINGLED SIDED" STAKE OF THE REWARD TOKEN
                lpOrigin: _lpOrigin,
                lockSeconds: _lockSeconds,
                lockEnforced: _lockEnforced,
                rewardPerBlock: _rewardPerBlock,
                label: _label,
                order: _order,
                depositSum: 0
            })
        );
    }

    function setPool(
        uint256 _pid,
        bool _active,
        bool _hidden,
        bool _uniV2Lp,
        bytes32 _lpOrigin,
        uint256 _lockSeconds,
        bool _lockEnforced,
        uint256 _rewardPerBlock,
        bytes32 _label,
        bytes32 _order
    ) external onlyOwner {
        rewardPools[_pid].active = _active;
        rewardPools[_pid].hidden = _hidden;
        rewardPools[_pid].uniV2Lp = _uniV2Lp;
        rewardPools[_pid].lpOrigin = _lpOrigin;
        rewardPools[_pid].lockSeconds = _lockSeconds;
        rewardPools[_pid].lockEnforced = _lockEnforced;
        rewardPools[_pid].rewardPerBlock = _rewardPerBlock;
        rewardPools[_pid].label = _label;
        rewardPools[_pid].order = _order;
    }

    function setFarmActive(bool _value) public onlyOwner {
        for (uint256 pid = 0; pid < rewardPools.length; ++pid) {
            RewardPool storage pool = rewardPools[pid];
            pool.active = _value;
        }
    }

    function setEarliestRewards(uint256 _value) external onlyOwner {
        require(
            _value >= block.number,
            "Earliest reward block must be greater than the current block"
        );
        earliestRewards = _value;
    }


    function setLastPayout(UserDeposit storage _deposit) private {
        _deposit.lastPayout = block.number;
        if (_deposit.lastPayout < earliestRewards)
            _deposit.lastPayout = earliestRewards; // FAIR LAUNCH ACCOMODATION
    }

    function deposit(
        uint256 _pid,
        address _user,
        uint256 _amount
    ) public nonReentrant {
        RewardPool storage pool = rewardPools[_pid];
        require(_amount > 0, "Amount must be greater than zero");
        require(pool.active == true, "This reward pool is inactive");

        UserDeposit storage userDeposit = userDeposits[_pid][_user];

        if (userDeposit.lastPayout == 0) {
            userDeposit.lastPayout = block.number;
            if (userDeposit.lastPayout < earliestRewards)
                userDeposit.lastPayout = earliestRewards; // FAIR LAUNCH ACCOMODATION
        }

        if (userDeposit.balance > 0 && msg.sender == _user) {
            payReward(_pid, _user);
        }

        pool.depositToken.safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        ); // DO THE ACTUAL DEPOSIT
        userDeposit.balance = userDeposit.balance.add(_amount); // ADD THE TRANSFERRED AMOUNT TO THE DEPOSIT VALUE
        userDeposit.unlockTime = block.timestamp.add(pool.lockSeconds); // UPDATE THE UNLOCK TIME
        pool.depositSum = pool.depositSum.add(_amount); // KEEP TRACK OF TOTAL DEPOSITS IN THE POOL

        recordAddress(_user); // RECORD THE USER ADDRESS IN THE LIST
        emit Deposit(msg.sender, _user, _pid, _amount);
    }

    function payReward(uint256 _pid, address _user) private {
        UserDeposit storage userDeposit = userDeposits[_pid][_user]; // FETCH THE DEPOSIT
        uint256 rewardsDue = userPendingPool(_pid, _user); // GET PENDING REWARDS

        if (rewardsDue <= 0) return; // BAIL OUT IF NO REWARD IS DUE

        rewardToken.transferFrom(rewardWallet, _user, rewardsDue);
        emit Reward(_user, _pid, rewardsDue);

        userDeposit.totalEarned = userDeposit.totalEarned.add(rewardsDue); // ADD THE PAYOUT AMOUNT TO TOTAL EARNINGS
        paidOut = paidOut.add(rewardsDue); // ADD AMOUNT TO TOTAL PAIDOUT FOR THE WHOLE FARM

        setLastPayout(userDeposit); // UPDATE THE LAST PAYOUT
    }

    function collectReward(uint256 _pid) external nonReentrant {
        payReward(_pid, msg.sender);
    }

    function restake(uint256 _pid) external nonReentrant {
        RewardPool storage pool = rewardPools[_pid]; // GET THE POOL
        UserDeposit storage userDeposit = userDeposits[_pid][msg.sender]; // FETCH THE DEPOSIT

        require(
            pool.depositToken == rewardToken,
            "Restake is only available on single-sided staking"
        );

        uint256 rewardsDue = userPendingPool(_pid, msg.sender); // GET PENDING REWARD AMOUNT
        if (rewardsDue <= 0) return; // BAIL OUT IF NO REWARDS ARE TO BE PAID

        pool.depositToken.safeTransferFrom(
            rewardWallet,
            address(this),
            rewardsDue
        ); // MOVE FUNDS FROM THE REWARDS TO THIS CONTRACT
        pool.depositSum = pool.depositSum.add(rewardsDue);

        userDeposit.balance = userDeposit.balance.add(rewardsDue); // ADD THE FUNDS MOVED TO THE USER'S BALANCE
        userDeposit.totalEarned = userDeposit.totalEarned.add(rewardsDue); // ADD FUNDS MOVED TO USER'S TOTAL EARNINGS FOR POOL

        setLastPayout(userDeposit); // UPDATE THE LAST PAYOUT

        paidOut = paidOut.add(rewardsDue); // ADD TO THE TOTAL PAID OUT FOR THE FARM
        emit Restake(msg.sender, _pid, rewardsDue);
    }

    function withdraw(uint256 _pid, uint256 _amount) external nonReentrant {
        RewardPool storage pool = rewardPools[_pid];
        UserDeposit storage userDeposit = userDeposits[_pid][msg.sender];

        if (pool.lockEnforced)
            require(
                userDeposit.unlockTime <= block.timestamp,
                "withdraw: time lock has not passed"
            );
        require(
            userDeposit.balance >= _amount,
            "withdraw: can't withdraw more than deposit"
        );

        payReward(_pid, msg.sender); // PAY OUT ANY REWARDS ACCUMULATED UP TO THIS POINT
        setLastPayout(userDeposit); // UPDATE THE LAST PAYOUT

        userDeposit.unlockTime = block.timestamp.add(pool.lockSeconds); // RESET THE UNLOCK TIME
        userDeposit.balance = userDeposit.balance.sub(_amount); // SUBTRACT THE AMOUNT DEBITED FROM THE BALANCE
        pool.depositToken.safeTransfer(address(msg.sender), _amount); // TRANSFER THE WITHDRAWN AMOUNT BACK TO THE USER
        emit Withdraw(msg.sender, _pid, _amount);

        pool.depositSum = pool.depositSum.sub(_amount); // SUBTRACT THE WITHDRAWN AMOUNT FROM THE POOL DEPOSIT TOTAL
        cleanupAddress(msg.sender);
    }

    function recordAddress(address _address) private {
        for (uint256 i = 0; i < depositAddresses.length; i++) {
            address curAddress = depositAddresses[i];
            if (_address == curAddress) return;
        }
        depositAddresses.push(_address);
    }

    function cleanupAddress(address _address) private {
        uint256 deposits = 0;
        for (uint256 pid = 0; pid < rewardPools.length; pid++) {
            deposits = deposits.add(userDeposits[pid][_address].balance);
        }

        if (deposits > 0) return; // BAIL OUT IF USER STILL HAS DEPOSITS

        for (uint256 i = 0; i < depositAddresses.length; i++) {
            address curAddress = depositAddresses[i];
            if (_address == curAddress) delete depositAddresses[i]; // REMOVE ADDRESS FROM ARRAY
        }
    }


    function getPools() public view returns (RewardPool[] memory) {
        return rewardPools;
    }

    function rewardsRemaining() public view returns (uint256) {
        return rewardToken.balanceOf(rewardWallet);
    }

    function addressCount() external view returns (uint256) {
        return depositAddresses.length;
    }

    function poolExists(IERC20 _depositToken, uint256 _lockSeconds)
        private
        view
        returns (bool)
    {
        for (uint256 pid = 0; pid < rewardPools.length; ++pid) {
            RewardPool storage pool = rewardPools[pid];
            if (
                pool.depositToken == _depositToken &&
                pool.lockSeconds == _lockSeconds
            ) return true;
        }
        return false;
    }

    function poolLength() external view returns (uint256) {
        return rewardPools.length;
    }

    function poolDepositSum(uint256 _pid) external view returns (uint256) {
        return rewardPools[_pid].depositSum;
    }

    function userPendingPool(uint256 _pid, address _user)
        public
        view
        returns (uint256)
    {
        RewardPool storage pool = rewardPools[_pid];
        UserDeposit storage userDeposit = userDeposits[_pid][_user];

        if (userDeposit.balance == 0) return 0;
        if (earliestRewards > block.number) return 0;

        uint256 precision = 1e36;

        uint256 blocksElapsed = 0;
        if (block.number > userDeposit.lastPayout)
            blocksElapsed = block.number.sub(userDeposit.lastPayout);

        uint256 poolOwnership = userDeposit.balance.mul(precision).div(
            pool.depositSum
        );
        uint256 rewardsDue = blocksElapsed
            .mul(pool.rewardPerBlock)
            .mul(poolOwnership)
            .div(precision);
        return rewardsDue;
    }

    function userPendingAll(address _user) public view returns (uint256) {
        uint256 totalReward = 0;
        for (uint256 pid = 0; pid < rewardPools.length; ++pid) {
            uint256 pending = userPendingPool(pid, _user);
            totalReward = totalReward.add(pending);
        }
        return totalReward;
    }

    function userEarnedPool(uint256 _pid, address _user)
        public
        view
        returns (uint256)
    {
        return userDeposits[_pid][_user].totalEarned;
    }

    function userEarnedAll(address _user) public view returns (uint256) {
        uint256 totalEarned = 0;
        for (uint256 pid = 0; pid < rewardPools.length; ++pid) {
            totalEarned = totalEarned.add(userDeposits[pid][_user].totalEarned);
        }
        return totalEarned;
    }

    function farmTotalPending() external view returns (uint256) {
        uint256 pending = 0;

        for (uint256 i = 0; i < depositAddresses.length; ++i) {
            uint256 userPending = userPendingAll(depositAddresses[i]);
            pending = pending.add(userPending);
        }
        return pending;
    }

    function getUserState(address _user)
        external
        view
        returns (UserFarmState memory)
    {
        uint256[] memory balance = new uint256[](rewardPools.length);
        uint256[] memory pending = new uint256[](rewardPools.length);
        uint256[] memory earned = new uint256[](rewardPools.length);
        uint256[] memory depTknBal = new uint256[](rewardPools.length);
        uint256[] memory depTknSupply = new uint256[](rewardPools.length);
        uint256[] memory depTknReserve0 = new uint256[](rewardPools.length);
        uint256[] memory depTknReserve1 = new uint256[](rewardPools.length);
        address[] memory depTknResTkn0 = new address[](rewardPools.length);
        address[] memory depTknResTkn1 = new address[](rewardPools.length);
        uint256[] memory unlockTime = new uint256[](rewardPools.length);

        for (uint256 pid = 0; pid < rewardPools.length; ++pid) {
            balance[pid] = userDeposits[pid][_user].balance;
            pending[pid] = userPendingPool(pid, _user);
            earned[pid] = userEarnedPool(pid, _user);
            depTknBal[pid] = rewardPools[pid].depositToken.balanceOf(_user);
            depTknSupply[pid] = rewardPools[pid].depositToken.totalSupply();
            unlockTime[pid] = userDeposits[pid][_user].unlockTime;

            if (
                rewardPools[pid].uniV2Lp == true &&
                rewardPools[pid].selfStake == false
            ) {
                IUniswapV2Pair pair = IUniswapV2Pair(
                    address(rewardPools[pid].depositToken)
                );
                (uint256 res0, uint256 res1, uint256 timestamp) = pair
                    .getReserves();
                depTknReserve0[pid] = res0;
                depTknReserve1[pid] = res1;
                depTknResTkn0[pid] = pair.token0();
                depTknResTkn1[pid] = pair.token1();
            }
        }

        return
            UserFarmState(
                rewardPools, // POOLS
                balance, // DEPOSITS BY POOL
                unlockTime, // UNLOCK TIME FOR EACH DEPOSITED POOL
                pending, // PENDING REWARDS BY POOL
                earned, // EARNINGS BY POOL
                depTknBal, // USER BALANCE OF DEPOSIT TOKEN
                depTknSupply, // TOTAL SUPPLY OF DEPOSIT TOKEN
                depTknReserve0, // RESERVE0 AMOUNT FOR LP TKN0
                depTknReserve1, // RESERVE1 AMOUNT FOR LP TKN1
                depTknResTkn0, // ADDRESS OF LP TOKEN 0
                depTknResTkn1, // ADDRESS OF LP TOKEN 1
                rewardToken.balanceOf(_user), // CURRENT USER HOLDINGS OF THE REWARD TOKEN
                userPendingAll(_user), // REWARDS PENDING FOR ALL POOLS
                userEarnedAll(_user) // REWARDS EARNED FOR ALL POOLS
            );
    }


    function emergencyWithdraw(uint256 _pid) external nonReentrant {
        RewardPool storage pool = rewardPools[_pid]; // GET THE POOL
        UserDeposit storage userDeposit = userDeposits[_pid][msg.sender]; //GET THE DEPOSIT

        pool.depositToken.safeTransfer(
            address(msg.sender),
            userDeposit.balance
        ); // TRANSFER THE DEPOSIT BACK TO THE USER
        pool.depositSum = pool.depositSum.sub(userDeposit.balance); // DECREMENT THE POOL'S OVERALL DEPOSIT SUM
        userDeposit.unlockTime = block.timestamp.add(pool.lockSeconds); // RESET THE UNLOCK TIME
        userDeposit.balance = 0; // SET THE BALANCE TO ZERO AFTER WIRTHDRAWAL
        setLastPayout(userDeposit); // UPDATE THE LAST PAYOUT

        emit EmergencyWithdraw(msg.sender, _pid, userDeposit.balance);
    }
}