



pragma solidity ^0.8.0;

interface IERC1271 {

  function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4 magicValue);

}




pragma solidity ^0.8.0;


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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}




pragma solidity ^0.8.0;

interface IERC20Permit {

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;


    function nonces(address owner) external view returns (uint256);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

}




pragma solidity ^0.8.0;

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




pragma solidity ^0.8.0;

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}




pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}




pragma solidity ^0.8.0;


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor (string memory name_, string memory symbol_) {
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

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}




pragma solidity ^0.8.0;

library ECDSA {
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;

        if (signature.length == 65) {
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
        } else if (signature.length == 64) {
            assembly {
                let vs := mload(add(signature, 0x40))
                r := mload(add(signature, 0x20))
                s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
                v := add(shr(255, vs), 27)
            }
        } else {
            revert("ECDSA: invalid signature length");
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

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}




pragma solidity ^0.8.0;

abstract contract EIP712 {
    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;

    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;
    bytes32 private immutable _TYPE_HASH;

    constructor(string memory name, string memory version) {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = block.chainid;
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
        _TYPE_HASH = typeHash;
    }

    function _domainSeparatorV4() internal view returns (bytes32) {
        if (block.chainid == _CACHED_CHAIN_ID) {
            return _CACHED_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
        }
    }

    function _buildDomainSeparator(bytes32 typeHash, bytes32 name, bytes32 version) private view returns (bytes32) {
        return keccak256(
            abi.encode(
                typeHash,
                name,
                version,
                block.chainid,
                address(this)
            )
        );
    }

    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
    }
}




pragma solidity ^0.8.0;

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
}




pragma solidity ^0.8.0;


abstract contract ERC20Permit is ERC20, IERC20Permit, EIP712 {
    using Counters for Counters.Counter;

    mapping (address => Counters.Counter) private _nonces;

    bytes32 private immutable _PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    constructor(string memory name) EIP712(name, "1") {
    }

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public virtual override {
        require(block.timestamp <= deadline, "ERC20Permit: expired deadline");

        bytes32 structHash = keccak256(
            abi.encode(
                _PERMIT_TYPEHASH,
                owner,
                spender,
                value,
                _useNonce(owner),
                deadline
            )
        );

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




pragma solidity ^0.8.0;


library UncheckedAddress {
    function uncheckedFunctionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return uncheckedFunctionCallWithValue(target, data, 0, errorMessage);
    }

    function uncheckedFunctionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "UA: insufficient balance");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function uncheckedFunctionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    revert(add(32, returndata), mload(returndata))
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}




pragma solidity ^0.8.0;

contract AmountCalculator {
    using UncheckedAddress for address;

    function getMakerAmount(uint256 orderMakerAmount, uint256 orderTakerAmount, uint256 swapTakerAmount) external pure returns(uint256) {
        return swapTakerAmount * orderMakerAmount / orderTakerAmount;
    }

    function getTakerAmount(uint256 orderMakerAmount, uint256 orderTakerAmount, uint256 swapMakerAmount) external pure returns(uint256) {
        return (swapMakerAmount * orderTakerAmount + orderMakerAmount - 1) / orderMakerAmount;
    }

    function arbitraryStaticCall(address target, bytes memory data) external view returns(uint256) {
        (bytes memory result) = target.uncheckedFunctionStaticCall(data, "AC: arbitraryStaticCall");
        return abi.decode(result, (uint256));
    }
}




pragma solidity ^0.8.0;

interface AggregatorV3Interface {
    function latestAnswer() external view returns (int256);
    function latestTimestamp() external view returns (uint256);
}




pragma solidity ^0.8.0;

contract ChainlinkCalculator {
    uint256 private constant _SPREAD_DENOMINATOR = 1e9;
    uint256 private constant _ORACLE_EXPIRATION_TIME = 30 minutes;
    uint256 private constant _INVERSE_MASK = 1 << 255;

    function singlePrice(AggregatorV3Interface oracle, uint256 inverseAndSpread, uint256 amount) external view returns(uint256) {
        require(oracle.latestTimestamp() + _ORACLE_EXPIRATION_TIME > block.timestamp, "CC: stale data");
        bool inverse = inverseAndSpread & _INVERSE_MASK > 0;
        uint256 spread = inverseAndSpread & (~_INVERSE_MASK);
        if (inverse) {
            return amount * spread * 1e18 / uint256(oracle.latestAnswer()) / _SPREAD_DENOMINATOR;
        } else {
            return amount * spread * uint256(oracle.latestAnswer()) / 1e18 / _SPREAD_DENOMINATOR;
        }
    }

    function doublePrice(AggregatorV3Interface oracle1, AggregatorV3Interface oracle2, uint256 spread, uint256 amount) external view returns(uint256) {
        require(oracle1.latestTimestamp() + _ORACLE_EXPIRATION_TIME > block.timestamp, "CC: stale data O1");
        require(oracle2.latestTimestamp() + _ORACLE_EXPIRATION_TIME > block.timestamp, "CC: stale data O2");

        return amount * spread * uint256(oracle1.latestAnswer()) / uint256(oracle2.latestAnswer()) / _SPREAD_DENOMINATOR;
    }
}




pragma solidity ^0.8.0;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}




pragma solidity ^0.8.0;

interface IERC1155 is IERC165 {
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);

    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);

    function setApprovalForAll(address operator, bool approved) external;

    function isApprovedForAll(address account, address operator) external view returns (bool);

    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;

    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;
}




pragma solidity ^0.8.0;

contract ImmutableOwner {
    address public immutable immutableOwner;

    modifier onlyImmutableOwner {
        require(msg.sender == immutableOwner, "IO: Access denied");
        _;
    }

    constructor(address _immutableOwner) {
        immutableOwner = _immutableOwner;
    }
}




pragma solidity ^0.8.0;



abstract contract ERC1155Proxy is ImmutableOwner {
    constructor() {
        require(ERC1155Proxy.func_733NCGU.selector == bytes4(uint32(IERC20.transferFrom.selector) + 4), "ERC1155Proxy: bad selector");
    }

    function func_733NCGU(address from, address to, uint256 amount, IERC1155 token, uint256 tokenId, bytes calldata data) external onlyImmutableOwner {
        token.safeTransferFrom(from, to, tokenId, amount, data);
    }
}





pragma solidity ^0.8.0;

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

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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
}




pragma solidity ^0.8.0;


library SafeERC20 {
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}




pragma solidity ^0.8.0;


abstract contract ERC20Proxy is ImmutableOwner {
    using SafeERC20 for IERC20;

    constructor() {
        require(ERC20Proxy.func_50BkM4K.selector == bytes4(uint32(IERC20.transferFrom.selector) + 1), "ERC20Proxy: bad selector");
    }

    function func_50BkM4K(address from, address to, uint256 amount, IERC20 token) external onlyImmutableOwner {
        token.safeTransferFrom(from, to, amount);
    }
}





pragma solidity ^0.8.0;

interface IERC721 is IERC165 {
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
}




pragma solidity ^0.8.0;



abstract contract ERC721Proxy is ImmutableOwner {
    constructor() {
        require(ERC721Proxy.func_40aVqeY.selector == bytes4(uint32(IERC20.transferFrom.selector) + 2), "ERC20Proxy: bad selector");
        require(ERC721Proxy.func_20xtkDI.selector == bytes4(uint32(IERC20.transferFrom.selector) + 3), "ERC20Proxy: bad selector");
    }

    function func_40aVqeY(address from, address to, uint256 tokenId, IERC721 token) external onlyImmutableOwner {
        token.transferFrom(from, to, tokenId);
    }

    function func_20xtkDI(address from, address to, uint256 tokenId, IERC721 token) external onlyImmutableOwner {
        token.safeTransferFrom(from, to, tokenId);
    }
}





pragma solidity ^0.8.0;

contract NonceManager {
    event NonceIncreased(address indexed maker, uint256 newNonce);

    mapping(address => uint256) public nonce;

    function increaseNonce() external {
        advanceNonce(1);
    }

    function advanceNonce(uint8 amount) public {
        emit NonceIncreased(msg.sender, nonce[msg.sender] += amount);
    }

    function nonceEquals(address makerAddress, uint256 makerNonce) external view returns(bool) {
        return nonce[makerAddress] == makerNonce;
    }
}




pragma solidity ^0.8.0;

contract PredicateHelper {
    using UncheckedAddress for address;

    function or(address[] calldata targets, bytes[] calldata data) external view returns(bool) {
        require(targets.length == data.length, "PH: input array size mismatch");
        for (uint i = 0; i < targets.length; i++) {
            bytes memory result = targets[i].uncheckedFunctionStaticCall(data[i], "PH: 'or' subcall failed");
            require(result.length == 32, "PH: invalid call result");
            if (abi.decode(result, (bool))) {
                return true;
            }
        }
        return false;
    }

    function and(address[] calldata targets, bytes[] calldata data) external view returns(bool) {
        require(targets.length == data.length, "PH: input array size mismatch");
        for (uint i = 0; i < targets.length; i++) {
            bytes memory result = targets[i].uncheckedFunctionStaticCall(data[i], "PH: 'and' subcall failed");
            require(result.length == 32, "PH: invalid call result");
            if (!abi.decode(result, (bool))) {
                return false;
            }
        }
        return true;
    }

    function eq(uint256 value, address target, bytes memory data) external view returns(bool) {
        bytes memory result = target.uncheckedFunctionStaticCall(data, "PH: eq");
        require(result.length == 32, "PH: invalid call result");
        return abi.decode(result, (uint256)) == value;
    }

    function lt(uint256 value, address target, bytes memory data) external view returns(bool) {
        bytes memory result = target.uncheckedFunctionStaticCall(data, "PH: lt");
        require(result.length == 32, "PH: invalid call result");
        return abi.decode(result, (uint256)) < value;
    }

    function gt(uint256 value, address target, bytes memory data) external view returns(bool) {
        bytes memory result = target.uncheckedFunctionStaticCall(data, "PH: gt");
        require(result.length == 32, "PH: invalid call result");
        return abi.decode(result, (uint256)) > value;
    }

    function timestampBelow(uint256 time) external view returns(bool) {
        return block.timestamp < time;  // solhint-disable-line not-rely-on-time
    }
}




pragma solidity ^0.8.0;


interface InteractiveMaker {
    function notifyFillOrder(
        address makerAsset,
        address takerAsset,
        uint256 makingAmount,
        uint256 takingAmount,
        bytes memory interactiveData
    ) external;
}




pragma solidity ^0.8.0;


library ArgumentsDecoder {
    function decodeSelector(bytes memory data) internal pure returns(bytes4 selector) {
        assembly { // solhint-disable-line no-inline-assembly
            selector := mload(add(data, 0x20))
        }
    }

    function decodeAddress(bytes memory data, uint256 argumentIndex) internal pure returns(address account) {
        assembly { // solhint-disable-line no-inline-assembly
            account := mload(add(add(data, 0x24), mul(argumentIndex, 0x20)))
        }
    }

    function decodeUint256(bytes memory data, uint256 argumentIndex) internal pure returns(uint256 value) {
        assembly { // solhint-disable-line no-inline-assembly
            value := mload(add(add(data, 0x24), mul(argumentIndex, 0x20)))
        }
    }

    function patchAddress(bytes memory data, uint256 argumentIndex, address account) internal pure {
        assembly { // solhint-disable-line no-inline-assembly
            mstore(add(add(data, 0x24), mul(argumentIndex, 0x20)), account)
        }
    }

    function patchUint256(bytes memory data, uint256 argumentIndex, uint256 value) internal pure {
        assembly { // solhint-disable-line no-inline-assembly
            mstore(add(add(data, 0x24), mul(argumentIndex, 0x20)), value)
        }
    }
}




pragma solidity ^0.8.0;

library SilentECDSA {
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;

        if (signature.length == 65) {
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
        } else if (signature.length == 64) {
            assembly {
                let vs := mload(add(signature, 0x40))
                r := mload(add(signature, 0x20))
                s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
                v := add(shr(255, vs), 27)
            }
        } else {
            return address(0);
        }

        return recover(hash, v, r, s);
    }

    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return address(0);
        }
        if (v != 27 && v != 28) {
            return address(0);
        }

        address signer = ecrecover(hash, v, r, s);

        return signer;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}




pragma solidity ^0.8.0;


contract LimitOrderProtocol is
    ImmutableOwner(address(this)),
    EIP712("1inch Limit Order Protocol", "1"),
    AmountCalculator,
    ChainlinkCalculator,
    ERC1155Proxy,
    ERC20Proxy,
    ERC721Proxy,
    NonceManager,
    PredicateHelper
{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using UncheckedAddress for address;
    using ArgumentsDecoder for bytes;


    event OrderFilled(
        address indexed maker,
        bytes32 orderHash,
        uint256 remaining
    );

    event OrderFilledRFQ(
        bytes32 orderHash,
        uint256 makingAmount
    );

    struct OrderRFQ {
        uint256 info;
        address makerAsset;
        address takerAsset;
        bytes makerAssetData; // (transferFrom.selector, signer, ______, makerAmount, ...)
        bytes takerAssetData; // (transferFrom.selector, sender, signer, takerAmount, ...)
    }

    struct Order {
        uint256 salt;
        address makerAsset;
        address takerAsset;
        bytes makerAssetData; // (transferFrom.selector, signer, ______, makerAmount, ...)
        bytes takerAssetData; // (transferFrom.selector, sender, signer, takerAmount, ...)
        bytes getMakerAmount; // this.staticcall(abi.encodePacked(bytes, swapTakerAmount)) => (swapMakerAmount)
        bytes getTakerAmount; // this.staticcall(abi.encodePacked(bytes, swapMakerAmount)) => (swapTakerAmount)
        bytes predicate;      // this.staticcall(bytes) => (bool)
        bytes permit;         // On first fill: permit.1.call(abi.encodePacked(permit.selector, permit.2))
        bytes interaction;
    }

    bytes32 constant public LIMIT_ORDER_TYPEHASH = keccak256(
        "Order(uint256 salt,address makerAsset,address takerAsset,bytes makerAssetData,bytes takerAssetData,bytes getMakerAmount,bytes getTakerAmount,bytes predicate,bytes permit,bytes interaction)"
    );

    bytes32 constant public LIMIT_ORDER_RFQ_TYPEHASH = keccak256(
        "OrderRFQ(uint256 info,address makerAsset,address takerAsset,bytes makerAssetData,bytes takerAssetData)"
    );

    bytes4 immutable private _MAX_SELECTOR = bytes4(uint32(IERC20.transferFrom.selector) + 10);

    uint256 constant private _FROM_INDEX = 0;
    uint256 constant private _TO_INDEX = 1;
    uint256 constant private _AMOUNT_INDEX = 2;

    mapping(bytes32 => uint256) private _remaining;
    mapping(address => mapping(uint256 => uint256)) private _invalidator;

    function DOMAIN_SEPARATOR() external view returns(bytes32) {
        return _domainSeparatorV4();
    }

    function remaining(bytes32 orderHash) external view returns(uint256) {
        return _remaining[orderHash].sub(1, "LOP: Unknown order");
    }

    function remainingRaw(bytes32 orderHash) external view returns(uint256) {
        return _remaining[orderHash];
    }

    function remainingsRaw(bytes32[] memory orderHashes) external view returns(uint256[] memory results) {
        results = new uint256[](orderHashes.length);
        for (uint i = 0; i < orderHashes.length; i++) {
            results[i] = _remaining[orderHashes[i]];
        }
    }

    function invalidatorForOrderRFQ(address maker, uint256 slot) external view returns(uint256) {
        return _invalidator[maker][slot];
    }

    function checkPredicate(Order memory order) public view returns(bool) {
        bytes memory result = address(this).uncheckedFunctionStaticCall(order.predicate, "LOP: predicate call failed");
        require(result.length == 32, "LOP: invalid predicate return");
        return abi.decode(result, (bool));
    }

    function simulateCalls(address[] calldata targets, bytes[] calldata data) external {
        require(targets.length == data.length, "LOP: array size mismatch");
        bytes memory reason = new bytes(targets.length);
        for (uint i = 0; i < targets.length; i++) {
            (bool success, bytes memory result) = targets[i].call(data[i]);
            if (success && result.length > 0) {
                success = abi.decode(result, (bool));
            }
            reason[i] = success ? bytes1("1") : bytes1("0");
        }

        revert(string(abi.encodePacked("CALL_RESULTS_", reason)));
    }

    function cancelOrder(Order memory order) external {
        require(order.makerAssetData.decodeAddress(_FROM_INDEX) == msg.sender, "LOP: Access denied");

        bytes32 orderHash = _hash(order);
        _remaining[orderHash] = 1;
        emit OrderFilled(msg.sender, orderHash, 0);
    }

    function cancelOrderRFQ(uint256 orderInfo) external {
        _invalidator[msg.sender][uint64(orderInfo) >> 8] |= (1 << (orderInfo & 0xff));
    }

    function fillOrderRFQ(OrderRFQ memory order, bytes memory signature, uint256 makingAmount, uint256 takingAmount) external {
        uint256 expiration = uint128(order.info) >> 64;
        require(expiration == 0 || block.timestamp <= expiration, "LOP: order expired");  // solhint-disable-line not-rely-on-time

        address maker = order.makerAssetData.decodeAddress(_FROM_INDEX);
        uint256 invalidatorSlot = uint64(order.info) >> 8;
        uint256 invalidatorBit = 1 << uint8(order.info);
        uint256 invalidator = _invalidator[maker][invalidatorSlot];
        require(invalidator & invalidatorBit == 0, "LOP: already filled");
        _invalidator[maker][invalidatorSlot] = invalidator | invalidatorBit;

        uint256 orderMakerAmount = order.makerAssetData.decodeUint256(_AMOUNT_INDEX);
        uint256 orderTakerAmount = order.takerAssetData.decodeUint256(_AMOUNT_INDEX);
        if (takingAmount == 0 && makingAmount == 0) {
            makingAmount = orderMakerAmount;
            takingAmount = orderTakerAmount;
        }
        else if (takingAmount == 0) {
            takingAmount = (makingAmount * orderTakerAmount + orderMakerAmount - 1) / orderMakerAmount;
        }
        else if (makingAmount == 0) {
            makingAmount = takingAmount * orderMakerAmount / orderTakerAmount;
        }
        else {
            revert("LOP: one of amounts should be 0");
        }

        require(makingAmount > 0 && takingAmount > 0, "LOP: can't swap 0 amount");
        require(makingAmount <= orderMakerAmount, "LOP: making amount exceeded");
        require(takingAmount <= orderTakerAmount, "LOP: taking amount exceeded");

        bytes32 orderHash = _hash(order);
        _validate(order.makerAssetData, order.takerAssetData, signature, orderHash);

        _callMakerAssetTransferFrom(order.makerAsset, order.makerAssetData, msg.sender, makingAmount);
        _callTakerAssetTransferFrom(order.takerAsset, order.takerAssetData, msg.sender, takingAmount);

        emit OrderFilledRFQ(orderHash, makingAmount);
    }

    function fillOrder(Order memory order, bytes calldata signature, uint256 makingAmount, uint256 takingAmount, uint256 thresholdAmount) external returns(uint256, uint256) {
        bytes32 orderHash = _hash(order);

        uint256 remainingMakerAmount;
        { // Stack too deep
            bool orderExists;
            (orderExists, remainingMakerAmount) = _remaining[orderHash].trySub(1);
            if (!orderExists) {
                _validate(order.makerAssetData, order.takerAssetData, signature, orderHash);
                remainingMakerAmount = order.makerAssetData.decodeUint256(_AMOUNT_INDEX);
                if (order.permit.length > 0) {
                    (address token, bytes memory permit) = abi.decode(order.permit, (address, bytes));
                    token.uncheckedFunctionCall(abi.encodePacked(IERC20Permit.permit.selector, permit), "LOP: permit failed");
                    require(_remaining[orderHash] == 0, "LOP: reentrancy detected");
                }
            }
        }

        if (order.predicate.length > 0) {
            require(checkPredicate(order), "LOP: predicate returned false");
        }

        if ((takingAmount == 0) == (makingAmount == 0)) {
            revert("LOP: only one amount should be 0");
        }
        else if (takingAmount == 0) {
            takingAmount = _callGetTakerAmount(order, makingAmount);
            require(takingAmount <= thresholdAmount, "LOP: taking amount too high");
        }
        else {
            makingAmount = _callGetMakerAmount(order, takingAmount);
            require(makingAmount >= thresholdAmount, "LOP: making amount too low");
        }

        require(makingAmount > 0 && takingAmount > 0, "LOP: can't swap 0 amount");

        remainingMakerAmount = remainingMakerAmount.sub(makingAmount, "LOP: taking > remaining");
        _remaining[orderHash] = remainingMakerAmount + 1;
        emit OrderFilled(msg.sender, orderHash, remainingMakerAmount);

        _callTakerAssetTransferFrom(order.takerAsset, order.takerAssetData, msg.sender, takingAmount);

        if (order.interaction.length > 0) {
            InteractiveMaker(order.makerAssetData.decodeAddress(_FROM_INDEX))
                .notifyFillOrder(order.makerAsset, order.takerAsset, makingAmount, takingAmount, order.interaction);
        }

        _callMakerAssetTransferFrom(order.makerAsset, order.makerAssetData, msg.sender, makingAmount);

        return (makingAmount, takingAmount);
    }

    function _hash(Order memory order) internal view returns(bytes32) {
        return _hashTypedDataV4(
            keccak256(
                abi.encode(
                    LIMIT_ORDER_TYPEHASH,
                    order.salt,
                    order.makerAsset,
                    order.takerAsset,
                    keccak256(order.makerAssetData),
                    keccak256(order.takerAssetData),
                    keccak256(order.getMakerAmount),
                    keccak256(order.getTakerAmount),
                    keccak256(order.predicate),
                    keccak256(order.permit),
                    keccak256(order.interaction)
                )
            )
        );
    }

    function _hash(OrderRFQ memory order) internal view returns(bytes32) {
        return _hashTypedDataV4(
            keccak256(
                abi.encode(
                    LIMIT_ORDER_RFQ_TYPEHASH,
                    order.info,
                    order.makerAsset,
                    order.takerAsset,
                    keccak256(order.makerAssetData),
                    keccak256(order.takerAssetData)
                )
            )
        );
    }

    function _validate(bytes memory makerAssetData, bytes memory takerAssetData, bytes memory signature, bytes32 orderHash) internal view {
        require(makerAssetData.length >= 100, "LOP: bad makerAssetData.length");
        require(takerAssetData.length >= 100, "LOP: bad takerAssetData.length");
        bytes4 makerSelector = makerAssetData.decodeSelector();
        bytes4 takerSelector = takerAssetData.decodeSelector();
        require(makerSelector >= IERC20.transferFrom.selector && makerSelector <= _MAX_SELECTOR, "LOP: bad makerAssetData.selector");
        require(takerSelector >= IERC20.transferFrom.selector && takerSelector <= _MAX_SELECTOR, "LOP: bad takerAssetData.selector");

        address maker = address(makerAssetData.decodeAddress(_FROM_INDEX));
        if ((signature.length != 65 && signature.length != 64) || SilentECDSA.recover(orderHash, signature) != maker) {
            bytes memory result = maker.uncheckedFunctionStaticCall(abi.encodeWithSelector(IERC1271.isValidSignature.selector, orderHash, signature), "LOP: isValidSignature failed");
            require(result.length == 32 && abi.decode(result, (bytes4)) == IERC1271.isValidSignature.selector, "LOP: bad signature");
        }
    }

    function _callMakerAssetTransferFrom(address makerAsset, bytes memory makerAssetData, address taker, uint256 makingAmount) internal {
        address orderTakerAddress = makerAssetData.decodeAddress(_TO_INDEX);
        if (orderTakerAddress == address(0)) {
            makerAssetData.patchAddress(_TO_INDEX, taker);
        } else {
            require(orderTakerAddress == taker, "LOP: private order");
        }

        makerAssetData.patchUint256(_AMOUNT_INDEX, makingAmount);

        bytes memory result = makerAsset.uncheckedFunctionCall(makerAssetData, "LOP: makerAsset.call failed");
        if (result.length > 0) {
            require(abi.decode(result, (bool)), "LOP: makerAsset.call bad result");
        }
    }

    function _callTakerAssetTransferFrom(address takerAsset, bytes memory takerAssetData, address taker, uint256 takingAmount) internal {
        takerAssetData.patchAddress(_FROM_INDEX, taker);

        takerAssetData.patchUint256(_AMOUNT_INDEX, takingAmount);

        bytes memory result = takerAsset.uncheckedFunctionCall(takerAssetData, "LOP: takerAsset.call failed");
        if (result.length > 0) {
            require(abi.decode(result, (bool)), "LOP: takerAsset.call bad result");
        }
    }

    function _callGetMakerAmount(Order memory order, uint256 takerAmount) internal view returns(uint256 makerAmount) {
        if (order.getMakerAmount.length == 0 && takerAmount == order.takerAssetData.decodeUint256(_AMOUNT_INDEX)) {
            return order.makerAssetData.decodeUint256(_AMOUNT_INDEX);
        }
        bytes memory result = address(this).uncheckedFunctionStaticCall(abi.encodePacked(order.getMakerAmount, takerAmount), "LOP: getMakerAmount call failed");
        require(result.length == 32, "LOP: invalid getMakerAmount ret");
        return abi.decode(result, (uint256));
    }

    function _callGetTakerAmount(Order memory order, uint256 makerAmount) internal view returns(uint256 takerAmount) {
        if (order.getTakerAmount.length == 0 && makerAmount == order.makerAssetData.decodeUint256(_AMOUNT_INDEX)) {
            return order.takerAssetData.decodeUint256(_AMOUNT_INDEX);
        }
        bytes memory result = address(this).uncheckedFunctionStaticCall(abi.encodePacked(order.getTakerAmount, makerAmount), "LOP: getTakerAmount call failed");
        require(result.length == 32, "LOP: invalid getTakerAmount ret");
        return abi.decode(result, (uint256));
    }
}