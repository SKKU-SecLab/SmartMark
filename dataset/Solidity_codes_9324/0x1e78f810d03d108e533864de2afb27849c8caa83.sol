


pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {

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

        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {

        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {

        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {

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

pragma solidity >=0.4.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function decimals() external view returns (uint8);


    function symbol() external view returns (string memory);


    function name() external view returns (string memory);


    function getOwner() external view returns (address);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address _owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity ^0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {

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


pragma solidity ^0.8.0;




library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
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
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeERC20: decreased allowance below zero"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}


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

        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {

        return set._values;
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value)
        internal
        returns (bool)
    {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value)
        internal
        returns (bool)
    {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value)
        internal
        view
        returns (bool)
    {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index)
        internal
        view
        returns (bytes32)
    {

        return _at(set._inner, index);
    }

    function values(Bytes32Set storage set)
        internal
        view
        returns (bytes32[] memory)
    {

        return _values(set._inner);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value)
        internal
        returns (bool)
    {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value)
        internal
        returns (bool)
    {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value)
        internal
        view
        returns (bool)
    {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index)
        internal
        view
        returns (address)
    {

        return address(uint160(uint256(_at(set._inner, index))));
    }

    function values(AddressSet storage set)
        internal
        view
        returns (address[] memory)
    {

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

    function values(UintSet storage set)
        internal
        view
        returns (uint256[] memory)
    {

        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}




pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}



pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}




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


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

pragma solidity ^0.8.0;


abstract contract Pausable is Ownable {
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

    function pause() external onlyOwner whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() external onlyOwner whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}


pragma solidity ^0.8.0;

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

pragma solidity ^0.8.0;

library MerkleProof {

    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {

        return processProof(proof, leaf) == root;
    }

    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {

        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                computedHash = _efficientHash(computedHash, proofElement);
            } else {
                computedHash = _efficientHash(proofElement, computedHash);
            }
        }
        return computedHash;
    }

    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {

        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
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

pragma solidity ^0.8.0;


contract NftStaking is EIP712, ReentrancyGuard, Pausable, IERC721Receiver {

    string private constant SIGNING_DOMAIN = "WEB3CLUB";
    string private constant SIGNATURE_VERSION = "1";
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.UintSet;
    using SafeERC20 for IERC20;

    address public constant DEAD = 0x000000000000000000000000000000000000dEaD;


    enum Rarity {
        GENESIS,
        VALOROUS,
        EXTRATERRESTRIAL,
        ICONIC,
        ALMIGHTY
    }

    enum StakeType {
        UNLOCKED,
        LOCKED,
        PAIR_LOCKED
    }

    bytes32 public SEASON1_MERKLE_ROOT;
    bytes32 public SEASON2_MERKLE_ROOT;

    address public _season1Nft;
    address public _season2Nft;
    address public _rewardToken;

    uint256 public _lockPeriod = 60 days; // Lock period 60 days
    uint16 public _unstakeFee = 400; // Unstake fee 4%
    uint16 public _forcedUnstakeFee = 10000; // Force unstake fee 100%

    address private whitelistVerify = 0xbF3e689B25F460F695FC5a6715aA9c74de79e52F;

    struct NftStakeInfo {
        Rarity _rarity;
        bool _isLocked;
        uint256 _pairedTokenId;
        uint256 _stakedAt;
    }

    struct UserInfo {
        EnumerableSet.UintSet _season1Nfts;
        EnumerableSet.UintSet _season2Nfts;
        mapping(uint256 => NftStakeInfo) _season1StakeInfos;
        mapping(uint256 => NftStakeInfo) _season2StakeInfos;
        uint256 _pending; // Not claimed
        uint256 _totalClaimed; // Claimed so far
        uint256 _lastClaimedAt;
        uint256 _pairCount; // Paired count
    }

    mapping(Rarity => uint256) _season1BaseRpds; // RPD: reward per day
    mapping(Rarity => uint16) _season1LockedExtras;
    mapping(Rarity => mapping(StakeType => uint16)) _season2Extras;

    mapping(address => UserInfo) private _userInfo;

    event Staked(
        address indexed account,
        uint256 tokenId,
        bool isSeason1,
        bool isLocked
    );
    event Unstaked(address indexed account, uint256 tokenId, bool isSeason1);
    event Locked(address indexed account, uint256 tokenId, bool isSeason1);
    event Paired(
        address indexed account,
        uint256 season1TokenId,
        uint256 season2TokenId
    );
    event Harvested(address indexed account, uint256 amount);
    event InsufficientRewardToken(
        address indexed account,
        uint256 amountNeeded,
        uint256 balance
    );

    constructor(address __rewardToken, address __season1Nft) EIP712(SIGNING_DOMAIN, SIGNATURE_VERSION){
        IERC20(__rewardToken).balanceOf(address(this));
        IERC721(__season1Nft).balanceOf(address(this));

        _rewardToken = __rewardToken;
        _season1Nft = __season1Nft;

        _season1BaseRpds[Rarity.GENESIS] = 15 ether;
        _season1BaseRpds[Rarity.VALOROUS] = 30 ether;
        _season1BaseRpds[Rarity.EXTRATERRESTRIAL] = 30 ether;
        _season1BaseRpds[Rarity.ICONIC] = 45 ether;
        _season1BaseRpds[Rarity.ALMIGHTY] = 70 ether;

        _season1LockedExtras[Rarity.GENESIS] = 2500; // 25%
        _season1LockedExtras[Rarity.VALOROUS] = 2500; // 25%
        _season1LockedExtras[Rarity.EXTRATERRESTRIAL] = 2500; // 25%
        _season1LockedExtras[Rarity.ICONIC] = 2500; // 25%
        _season1LockedExtras[Rarity.ALMIGHTY] = 2500; // 25%
    }

    function setSeason2Nft(address __season2Nft) external onlyOwner {

        IERC721(__season2Nft).balanceOf(address(this));
        _season2Nft = __season2Nft;
    }

    function getRewardInNormal(
        uint256 __rpd,
        uint256 __stakedAt,
        uint256 __lastClaimedAt
    ) private view returns (uint256) {

        uint256 timePassed = __stakedAt > __lastClaimedAt
            ? block.timestamp.sub(__stakedAt)
            : block.timestamp.sub(__lastClaimedAt);
        return __rpd.mul(timePassed).div(1 days);
    }

    function getRewardInLocked(
        uint256 __rpd,
        uint256 __extraRate,
        uint256 __stakedAt,
        uint256 __lastClaimedAt
    ) private view returns (uint256 lockedAmount, uint256 unlockedAmount) {

        uint256 lockEndAt = __stakedAt.add(_lockPeriod);
        if (lockEndAt > block.timestamp) {
            lockedAmount = __rpd
                .mul(block.timestamp.sub(__stakedAt))
                .mul(uint256(10000).add(__extraRate))
                .div(10000)
                .div(1 days);
        } else {
            uint256 timePassed = __lastClaimedAt >= lockEndAt
                ? block.timestamp.sub(__lastClaimedAt)
                : block.timestamp.sub(__stakedAt);
            unlockedAmount = __rpd
                .mul(timePassed)
                .mul(uint256(10000).add(__extraRate))
                .div(10000)
                .div(1 days);
        }
    }

    function getSeason1Rewards(address __account, uint256 __nftId)
        private
        view
        returns (uint256 lockedAmount, uint256 unlockedAmount)
    {

        UserInfo storage user = _userInfo[__account];
        NftStakeInfo storage season1StakeInfo = user._season1StakeInfos[
            __nftId
        ];
        Rarity season1Rarity = season1StakeInfo._rarity;
        uint256 baseRpd = _season1BaseRpds[season1Rarity];

        if (season1StakeInfo._isLocked) {
            (lockedAmount, unlockedAmount) = getRewardInLocked(
                baseRpd,
                _season1LockedExtras[season1Rarity],
                season1StakeInfo._stakedAt,
                user._lastClaimedAt
            );
        } else {
            unlockedAmount = getRewardInNormal(
                baseRpd,
                season1StakeInfo._stakedAt,
                user._lastClaimedAt
            );
        }
    }

    function getPairedSeason2Rewards(address __account, uint256 __nftId)
        private
        view
        returns (uint256 lockedAmount, uint256 unlockedAmount)
    {

        UserInfo storage user = _userInfo[__account];
        NftStakeInfo storage season1StakeInfo = user._season1StakeInfos[
            __nftId
        ];
        NftStakeInfo storage season2StakeInfo = user._season2StakeInfos[
            season1StakeInfo._pairedTokenId
        ];
        Rarity season1Rarity = season1StakeInfo._rarity;
        Rarity season2Rarity = season2StakeInfo._rarity;
        uint256 baseRpd = _season1BaseRpds[season1Rarity];
        if (season1StakeInfo._pairedTokenId == 0) {
            lockedAmount = 0;
            unlockedAmount = 0;
        } else if (season2StakeInfo._isLocked) {
            uint256 rpdExtraRate = season1StakeInfo._isLocked
                ? _season2Extras[season2Rarity][StakeType.PAIR_LOCKED]
                : _season2Extras[season2Rarity][StakeType.LOCKED];
            (lockedAmount, unlockedAmount) = getRewardInLocked(
                baseRpd,
                rpdExtraRate,
                season2StakeInfo._stakedAt,
                user._lastClaimedAt
            );
        } else {
            baseRpd = baseRpd
                .mul(_season2Extras[season2Rarity][StakeType.UNLOCKED])
                .div(10000);
            unlockedAmount = getRewardInNormal(
                baseRpd,
                season2StakeInfo._stakedAt,
                user._lastClaimedAt
            );
        }
    }

    function viewProfit(address __account)
        public
        view
        returns (
            uint256 totalEarned,
            uint256 totalClaimed,
            uint256 lockedRewards,
            uint256 unlockedRewards
        )
    {

        UserInfo storage user = _userInfo[__account];
        totalClaimed = user._totalClaimed;
        unlockedRewards = user._pending;

        uint256 countSeason1Nfts = user._season1Nfts.length();
        uint256 index;
        for (index = 0; index < countSeason1Nfts; index++) {
            uint256 pendingLockedRewards = 0;
            uint256 pendingUnlockedRewards = 0;

            (pendingLockedRewards, pendingUnlockedRewards) = getSeason1Rewards(
                __account,
                user._season1Nfts.at(index)
            );

            if (pendingLockedRewards > 0) {
                lockedRewards = lockedRewards.add(pendingLockedRewards);
            }
            if (pendingUnlockedRewards > 0) {
                unlockedRewards = unlockedRewards.add(pendingUnlockedRewards);
            }

            (
                pendingLockedRewards,
                pendingUnlockedRewards
            ) = getPairedSeason2Rewards(__account, user._season1Nfts.at(index));

            if (pendingLockedRewards > 0) {
                lockedRewards = lockedRewards.add(pendingLockedRewards);
            }
            if (pendingUnlockedRewards > 0) {
                unlockedRewards = unlockedRewards.add(pendingUnlockedRewards);
            }
        }

        totalEarned = totalClaimed.add(lockedRewards).add(unlockedRewards);
    }

    function viewSeason1Nfts(address __account)
        external
        view
        returns (uint256[] memory season1Nfts, bool[] memory lockStats)
    {

        UserInfo storage user = _userInfo[__account];
        uint256 countSeason1Nfts = user._season1Nfts.length();

        season1Nfts = new uint256[](countSeason1Nfts);
        lockStats = new bool[](countSeason1Nfts);
        uint256 index;
        uint256 tokenId;
        for (index = 0; index < countSeason1Nfts; index++) {
            tokenId = user._season1Nfts.at(index);
            season1Nfts[index] = tokenId;
            lockStats[index] = user._season1StakeInfos[tokenId]._isLocked;
        }
    }

    function viewSeason2Nfts(address __account)
        external
        view
        returns (uint256[] memory season2Nfts, bool[] memory lockStats)
    {

        UserInfo storage user = _userInfo[__account];
        uint256 countSeason2Nfts = user._season2Nfts.length();

        season2Nfts = new uint256[](countSeason2Nfts);
        lockStats = new bool[](countSeason2Nfts);
        uint256 index;
        uint256 tokenId;
        for (index = 0; index < countSeason2Nfts; index++) {
            tokenId = user._season2Nfts.at(index);
            season2Nfts[index] = tokenId;
            lockStats[index] = user._season2StakeInfos[tokenId]._isLocked;
        }
    }

    function viewPairedNfts(address __account)
        external
        view
        returns (
            uint256[] memory pairedSeason1Nfts,
            uint256[] memory pairedSeason2Nfts
        )
    {

        UserInfo storage user = _userInfo[__account];
        uint256 pairCount = user._pairCount;
        pairedSeason1Nfts = new uint256[](pairCount);
        pairedSeason2Nfts = new uint256[](pairCount);
        uint256 index;
        uint256 tokenId;
        uint256 rindex = 0;
        uint256 season2NftCount = user._season2Nfts.length();
        for (index = 0; index < season2NftCount; index++) {
            tokenId = user._season2Nfts.at(index);
            if (user._season2StakeInfos[tokenId]._pairedTokenId == 0) {
                continue;
            }
            pairedSeason1Nfts[rindex] = user
                ._season2StakeInfos[tokenId]
                ._pairedTokenId;
            pairedSeason2Nfts[rindex] = tokenId;
            rindex = rindex.add(1);
        }
    }

    function isWhiteListedSeason1(bytes32 _leafNode, bytes32[] memory _proof)
        public
        view
        returns (bool)
    {

        return MerkleProof.verify(_proof, SEASON1_MERKLE_ROOT, _leafNode);
    }

    function isWhiteListedSeason2(bytes32 _leafNode, bytes32[] memory _proof)
        public
        view
        returns (bool)
    {

        return MerkleProof.verify(_proof, SEASON2_MERKLE_ROOT, _leafNode);
    }

    function toLeaf(
        uint256 tokenID,
        uint256 index,
        uint256 amount
    ) public pure returns (bytes32) {

        return keccak256(abi.encodePacked(index, tokenID, amount));
    }

    function setMerkleRoot(bytes32 _season1Root, bytes32 _season2Root)
        external
        onlyOwner
    {

        SEASON1_MERKLE_ROOT = _season1Root;
        SEASON2_MERKLE_ROOT = _season2Root;
    }

    function updateFeeValues(uint16 __unstakeFee, uint16 __forcedUnstakeFee)
        external
        onlyOwner
    {

        _unstakeFee = __unstakeFee;
        _forcedUnstakeFee = __forcedUnstakeFee;
    }
    function updateWhitelistVerify(address _temp) external onlyOwner{

        whitelistVerify = _temp;
    }
    function updateLockPeriod(uint256 __lockPeriod) external onlyOwner {

        require(__lockPeriod > 0, "Invalid lock period");
        _lockPeriod = __lockPeriod;
    }

    function updateSeason1BaseRpd(Rarity __rarity, uint256 __rpd)
        external
        onlyOwner
    {

        require(__rpd > 0, "Non zero values required");
        _season1BaseRpds[__rarity] = __rpd;
    }

    function updateSeason1LockedExtraPercent(
        Rarity __rarity,
        uint16 __lockedExtraPercent
    ) external onlyOwner {

        _season1LockedExtras[__rarity] = __lockedExtraPercent;
    }

    function updateSeason2ExtraPercent(
        Rarity __rarity,
        StakeType __stakeType,
        uint16 __extraPercent
    ) external onlyOwner {

        _season2Extras[__rarity][__stakeType] = __extraPercent;
    }

    function isStaked(address __account, uint256 __tokenId)
        external
        view
        returns (bool)
    {

        UserInfo storage user = _userInfo[__account];
        return
            user._season1Nfts.contains(__tokenId) ||
            user._season2Nfts.contains(__tokenId);
    }

    function claimRewards() external {

        UserInfo storage user = _userInfo[_msgSender()];
        (, , , uint256 unlockedRewards) = viewProfit(_msgSender());
        if (unlockedRewards > 0) {
            uint256 feeAmount = unlockedRewards.mul(_unstakeFee).div(10000);
            if (feeAmount > 0) {
                IERC20(_rewardToken).safeTransfer(DEAD, feeAmount);
                unlockedRewards = unlockedRewards.sub(feeAmount);
            }
            if (unlockedRewards > 0) {
                user._totalClaimed = user._totalClaimed.add(unlockedRewards);
                IERC20(_rewardToken).safeTransfer(_msgSender(), unlockedRewards);
            }
        }
        user._lastClaimedAt = block.timestamp;
    }

    function stakeSeason1(
        bool __lockedStaking,
        uint256[] calldata __tokenIDList,
        uint256[] calldata __rarityList,
        bytes[] memory signature,
        uint256[] calldata ids


    ) external nonReentrant whenNotPaused {

        require(
            IERC721(_season1Nft).isApprovedForAll(_msgSender(), address(this)),
            "Not approve nft to staker address"
        );

        UserInfo storage user = _userInfo[_msgSender()];
        for (uint256 i = 0; i < __tokenIDList.length; i++) {
            require(check(ids[i],__rarityList[i],signature[i]) == whitelistVerify, "Error, Try Again.");

            IERC721(_season1Nft).safeTransferFrom(
                _msgSender(),
                address(this),
                __tokenIDList[i]
            );

            user._season1Nfts.add(__tokenIDList[i]);
            user._season1StakeInfos[__tokenIDList[i]] = NftStakeInfo({
                _rarity: Rarity(__rarityList[i]),
                _isLocked: __lockedStaking,
                _stakedAt: block.timestamp,
                _pairedTokenId: 0
            });

            emit Staked(_msgSender(), __tokenIDList[i], true, __lockedStaking);
        }
    }
    function check(uint256 id, uint256 rarityId, bytes memory signature) public view returns(address){

        return _verify(id, rarityId,signature);
    }

    function _verify(uint256 id, uint256 rarityId, bytes memory signature) internal view returns(address){

        bytes32 digest = _hash(id,rarityId);
        return ECDSA.recover(digest, signature);
    }

    function _hash(uint256 id,uint256 rarityId) internal view returns(bytes32){

        return _hashTypedDataV4(keccak256(abi.encode(
            keccak256("EIP712Domain(uint256 id,uint256 rarityId)"),
            id,
            rarityId
        )));
    }
    function stakeSeason2(
        bool __lockedStaking,
        uint256[] calldata __tokenIDList,
        uint256[] calldata __indexList,
        uint256[] calldata __rarityList,
        bytes32[][] calldata __proofList
    ) external nonReentrant whenNotPaused {

        require(
            IERC721(_season2Nft).isApprovedForAll(_msgSender(), address(this)),
            "Not approve nft to staker address"
        );

        UserInfo storage user = _userInfo[_msgSender()];
        for (uint256 i = 0; i < __tokenIDList.length; i++) {
            require(
                isWhiteListedSeason2(
                    toLeaf(__tokenIDList[i], __indexList[i], __rarityList[i]),
                    __proofList[i]
                ),
                "Invalid params"
            );

            IERC721(_season2Nft).safeTransferFrom(
                _msgSender(),
                address(this),
                __tokenIDList[i]
            );

            user._season2Nfts.add(__tokenIDList[i]);
            user._season2StakeInfos[__tokenIDList[i]] = NftStakeInfo({
                _rarity: Rarity(__rarityList[i]),
                _isLocked: __lockedStaking,
                _stakedAt: block.timestamp,
                _pairedTokenId: 0
            });

            emit Staked(_msgSender(), __tokenIDList[i], false, __lockedStaking);
        }
    }

    function unstakeSeason1(uint256[] calldata __tokenIDList)
        external
        nonReentrant
    {

        UserInfo storage user = _userInfo[_msgSender()];
        for (uint256 i = 0; i < __tokenIDList.length; i++) {
            require(
                user._season1Nfts.contains(__tokenIDList[i]),
                "Not staked one of nfts"
            );

            IERC721(_season1Nft).safeTransferFrom(
                address(this),
                _msgSender(),
                __tokenIDList[i]
            );

            (, uint256 unlockedRewards) = getSeason1Rewards(
                _msgSender(),
                __tokenIDList[i]
            );
            user._pending = user._pending.add(unlockedRewards);

            user._season1Nfts.remove(__tokenIDList[i]);
            uint256 pairedTokenId = user
                ._season1StakeInfos[__tokenIDList[i]]
                ._pairedTokenId;
            if (pairedTokenId > 0) {
                user._season2StakeInfos[pairedTokenId]._pairedTokenId = 0;
                user._pairCount = user._pairCount.sub(1);
            }

            delete user._season1StakeInfos[__tokenIDList[i]];

            emit Unstaked(_msgSender(), __tokenIDList[i], true);
        }
    }

    function unstakeSeason2(uint256[] calldata __tokenIDList)
        external
        nonReentrant
    {

        UserInfo storage user = _userInfo[_msgSender()];
        for (uint256 i = 0; i < __tokenIDList.length; i++) {
            require(
                user._season2Nfts.contains(__tokenIDList[i]),
                "Not staked one of nfts"
            );

            IERC721(_season2Nft).safeTransferFrom(
                address(this),
                _msgSender(),
                __tokenIDList[i]
            );

            uint256 pairedTokenId = user
                ._season2StakeInfos[__tokenIDList[i]]
                ._pairedTokenId;

            if (pairedTokenId > 0) {
                (, uint256 unlockedRewards) = getPairedSeason2Rewards(
                    _msgSender(),
                    pairedTokenId
                );
                user._pending = user._pending.add(unlockedRewards);
            }

            user._season2Nfts.remove(__tokenIDList[i]);

            if (pairedTokenId > 0) {
                user._season1StakeInfos[pairedTokenId]._pairedTokenId = 0;
                user._pairCount = user._pairCount.sub(1);
            }
            delete user._season2StakeInfos[__tokenIDList[i]];

            emit Unstaked(_msgSender(), __tokenIDList[i], false);
        }
    }

    function lockSeason1Nfts(uint256[] calldata __tokenIDList)
        external
        onlyOwner
    {

        UserInfo storage user = _userInfo[_msgSender()];
        for (uint256 i = 0; i < __tokenIDList.length; i++) {
            require(
                user._season1Nfts.contains(__tokenIDList[i]),
                "One of nfts not staked yet"
            );
            require(
                !user._season1StakeInfos[__tokenIDList[i]]._isLocked,
                "Locked already"
            );
            (, uint256 unlockedRewards) = getSeason1Rewards(
                _msgSender(),
                __tokenIDList[i]
            );
            user._pending = user._pending.add(unlockedRewards);

            user._season1StakeInfos[__tokenIDList[i]]._isLocked = true;
            user._season1StakeInfos[__tokenIDList[i]]._stakedAt = block
                .timestamp;
            emit Locked(_msgSender(), __tokenIDList[i], true);
        }
    }

    function lockSeason2Nfts(uint256[] calldata __tokenIDList)
        external
        onlyOwner
    {

        UserInfo storage user = _userInfo[_msgSender()];
        for (uint256 i = 0; i < __tokenIDList.length; i++) {
            require(
                user._season2Nfts.contains(__tokenIDList[i]),
                "One of nfts not staked yet"
            );
            require(
                !user._season2StakeInfos[__tokenIDList[i]]._isLocked,
                "Locked already"
            );
            uint256 pairedTokenId = user
                ._season2StakeInfos[__tokenIDList[i]]
                ._pairedTokenId;

            if (pairedTokenId > 0) {
                (, uint256 unlockedRewards) = getPairedSeason2Rewards(
                    _msgSender(),
                    pairedTokenId
                );
                user._pending = user._pending.add(unlockedRewards);
            }
            user._season2StakeInfos[__tokenIDList[i]]._isLocked = true;
            user._season2StakeInfos[__tokenIDList[i]]._stakedAt = block
                .timestamp;

            emit Locked(_msgSender(), __tokenIDList[i], false);
        }
    }

    function pairNfts(uint256 __season1TokenID, uint256 __season2TokenID)
        external
        nonReentrant
        whenNotPaused
    {

        UserInfo storage user = _userInfo[_msgSender()];
        require(
            user._season1Nfts.contains(__season1TokenID) &&
                user._season2Nfts.contains(__season2TokenID),
            "One of nfts is not staked"
        );
        require(
            user._season1StakeInfos[__season1TokenID]._pairedTokenId == 0 &&
                user._season2StakeInfos[__season2TokenID]._pairedTokenId == 0,
            "Already paired"
        );
        user
            ._season1StakeInfos[__season1TokenID]
            ._pairedTokenId = __season2TokenID;
        user
            ._season2StakeInfos[__season2TokenID]
            ._pairedTokenId = __season1TokenID;
        user._season2StakeInfos[__season2TokenID]._stakedAt = block.timestamp;
        user._pairCount = user._pairCount.add(1);

        emit Paired(_msgSender(), __season1TokenID, __season2TokenID);
    }

    function safeRewardTransfer(address __to, uint256 __amount)
        internal
        returns (uint256)
    {

        uint256 balance = IERC20(_rewardToken).balanceOf(address(this));
        if (balance >= __amount) {
            IERC20(_rewardToken).safeTransfer(__to, __amount);
            return __amount;
        }

        if (balance > 0) {
            IERC20(_rewardToken).safeTransfer(__to, balance);
        }
        emit InsufficientRewardToken(__to, __amount, balance);
        return balance;
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
    }
}