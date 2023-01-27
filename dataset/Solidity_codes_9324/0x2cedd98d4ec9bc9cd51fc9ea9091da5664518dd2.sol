
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
                bytes32 lastValue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastValue;
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
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
}// MIT

pragma solidity 0.8.9;


abstract contract SignatureAccessControl {
    using ECDSA for bytes32;
    using EnumerableSet for EnumerableSet.Bytes32Set;

    event SigningAddressChanged(address indexed oldAddres, address indexed newAddress);

    address public signingAddress;

    constructor(address _signingAddress) {
        require(_signingAddress != address(0), 'Cannot set address(0) as signer');
        signingAddress = _signingAddress;
    }

    function _hasAccess(address caller, bytes calldata _signature) internal view returns (bool) {
        return
            signingAddress ==
            keccak256(
                abi.encodePacked(
                    '\x19Ethereum Signed Message:\n32',
                    bytes32(uint256(uint160(caller)))
                )
            ).recover(_signature);
    }
}// MIT

pragma solidity ^0.8.0;

interface IAccessControlUpgradeable {

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

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC1155Upgradeable is IERC165Upgradeable {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;


    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

}// MIT
pragma solidity 0.8.9;



interface IVault is IAccessControlUpgradeable, IERC1155Upgradeable {

    event BaseUriChanged(string indexed oldBaseUri, string indexed newBaseUri);

    function getBaseUri() external view returns (string memory _baseUri);


    function setBaseUri(string memory newUri) external;


    function uri(uint256 _id) external view returns (string memory);


    function mint(
        address to,
        bytes32 proof,
        uint256 amount,
        bytes memory data
    ) external;


    function mintBatch(
        address to,
        bytes32[] memory proofs,
        uint256[] memory amounts,
        bytes memory data
    ) external;


    function burn(
        bytes32 proof,
        uint256 amount,
        bytes calldata signature
    ) external;


    function burnBatch(
        bytes32[] memory proofs,
        uint256[] memory amounts,
        bytes calldata signature
    ) external;


    function pause() external;


    function unpause() external;

}// MIT
pragma solidity ^0.8.4;

abstract contract VRFConsumerBaseV2 {
  error OnlyCoordinatorCanFulfill(address have, address want);
  address private immutable vrfCoordinator;

  constructor(address _vrfCoordinator) {
    vrfCoordinator = _vrfCoordinator;
  }

  function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal virtual;

  function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external {
    if (msg.sender != vrfCoordinator) {
      revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);
    }
    fulfillRandomWords(requestId, randomWords);
  }
}// MIT
pragma solidity ^0.8.0;

interface VRFCoordinatorV2Interface {

  function getRequestConfig()
    external
    view
    returns (
      uint16,
      uint32,
      bytes32[] memory
    );


  function requestRandomWords(
    bytes32 keyHash,
    uint64 subId,
    uint16 minimumRequestConfirmations,
    uint32 callbackGasLimit,
    uint32 numWords
  ) external returns (uint256 requestId);


  function createSubscription() external returns (uint64 subId);


  function getSubscription(uint64 subId)
    external
    view
    returns (
      uint96 balance,
      uint64 reqCount,
      address owner,
      address[] memory consumers
    );


  function requestSubscriptionOwnerTransfer(uint64 subId, address newOwner) external;


  function acceptSubscriptionOwnerTransfer(uint64 subId) external;


  function addConsumer(uint64 subId, address consumer) external;


  function removeConsumer(uint64 subId, address consumer) external;


  function cancelSubscription(uint64 subId, address to) external;

}// MIT

pragma solidity ^0.8.1;

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
}// MIT

pragma solidity ^0.8.0;

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
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


library ERC165Checker {

    bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;

    function supportsERC165(address account) internal view returns (bool) {

        return
            _supportsERC165Interface(account, type(IERC165).interfaceId) &&
            !_supportsERC165Interface(account, _INTERFACE_ID_INVALID);
    }

    function supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {

        return supportsERC165(account) && _supportsERC165Interface(account, interfaceId);
    }

    function getSupportedInterfaces(address account, bytes4[] memory interfaceIds)
        internal
        view
        returns (bool[] memory)
    {

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

        bytes memory encodedParams = abi.encodeWithSelector(IERC165.supportsInterface.selector, interfaceId);
        (bool success, bytes memory result) = account.staticcall{gas: 30000}(encodedParams);
        if (result.length < 32) return false;
        return success && abi.decode(result, (bool));
    }
}// MIT

pragma solidity 0.8.9;


abstract contract TokenMintingPool is VRFConsumerBaseV2 {
    using EnumerableSet for EnumerableSet.Bytes32Set;



    VRFCoordinatorV2Interface internal COORDINATOR;

    bytes32 private _vrfKeyHash; // The key hash to run Chainlink VRF

    uint64 public vrfSubscriptionId; // Chainlink Subscription ID

    uint256 private s_requestId; // Request ID sent by the VRF

    IVault public immutable vault; // Reference to the vault where tokens will be minted.

    EnumerableSet.Bytes32Set private _availableTokenHashes;                     // The available token hashes that haven't been minted yet

    uint256[] private _randomSeeds; //  random seeds numbers provided by Chainlink VRF v2, ensuring that


    uint256 private _randomValue;    // (_randomValue != 0) serves as a check to verify that the

    uint256 private _seedCounter; // Allows to have a different seed for each mint

    uint256 public initialSupply; //Initial supply of the drop when locking the supply



    event TokensAdded(uint256 indexed addedNumber);
    event TokensRemoved(uint256 indexed removedNumber);



    modifier onlyValidVault(address vaultAddress) {
        require(
            ERC165Checker.supportsInterface(vaultAddress, type(IVault).interfaceId),
            'TokenMintingPool: Target token registry contract does not match the interface requirements.'
        );
        _;
    }

    constructor(
        address vaultAddress,
        address vrfCoordinator,
        bytes32 vrfKeyHash,
        uint64 _vrfSubscriptionId
    ) onlyValidVault(vaultAddress) VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        vault = IVault(vaultAddress);
        _vrfKeyHash = vrfKeyHash;
        vrfSubscriptionId = _vrfSubscriptionId;
    }


    function _addTokens(bytes32[] calldata tokenHashes) internal {
        require(!tokenSupplyLocked(), 'TokenMintingPool: Token supply is locked. Cannot add new tokens.');
        for (uint256 ii = 0; ii < tokenHashes.length; ii++) {
            _availableTokenHashes.add(tokenHashes[ii]);
        }
         emit TokensAdded(tokenHashes.length);
    }

    function _removeTokens(bytes32[] calldata tokenHashes) internal {
        require(!tokenSupplyLocked(), 'TokenMintingPool: Token supply is locked. Cannot remove tokens.');
        for (uint256 ii = 0; ii < tokenHashes.length; ii++) {
            _availableTokenHashes.remove(tokenHashes[ii]);
        }
        emit TokensRemoved(tokenHashes.length);
    }

    function _lockTokenSupply(uint32 callbackGasLimit, uint32 numberSeeds) internal {
        initialSupply = remainingSupplyCount();
        require(numberSeeds < 501);
        require(!tokenSupplyLocked(), 'TokenMintingPool: Token supply is already locked.');
        s_requestId = COORDINATOR.requestRandomWords(
            _vrfKeyHash,
            vrfSubscriptionId,
            3, // Default number of confirmations
            callbackGasLimit, // See https://docs.chain.link/docs/vrf-contracts/
            numberSeeds // This value should be lower than 500 (VRF v2 can only provide 500 seeds by call)
        );
    }

    function tokenSupplyLocked() public view returns (bool) {
        return _randomValue != 0;
    }

    function fulfillRandomWords(
        uint256, /* requestId */
        uint256[] memory randomWords
    ) internal override {
        if (!tokenSupplyLocked()) {
            _randomValue = randomWords[0];
            _randomSeeds = randomWords;
        }
    }

    function remainingSupplyCount() public view returns (uint256) {
        return _availableTokenHashes.length();
    }


    function _mintTokens(
        address to,
        uint256 numTokens
    ) internal {
        require(tokenSupplyLocked(), 'TokenMintingPool: Token supply needs to be locked.');
        require(remainingSupplyCount() + 1 > numTokens, 'TokenMintingPool: Not enough tokens left.');
        for (uint256 ii = 0; ii < numTokens; ii++) {
            uint256 index = _randomSeeds[_seedCounter % _randomSeeds.length] % remainingSupplyCount();
            bytes32 tokenHash = _availableTokenHashes.at(index);
            vault.mint(to, tokenHash, 1, '');
            _availableTokenHashes.remove(tokenHash);
            _seedCounter += 1;
        }
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
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
        _checkRole(role);
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    function _checkRole(bytes32 role, address account) internal view virtual {
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

    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
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
}// MIT

pragma solidity 0.8.9;


abstract contract PackDropBase is
    Context,
    ReentrancyGuard,
    AccessControl,
    SignatureAccessControl,
    TokenMintingPool
{

    string public name; // the name of this drop
    uint256 public maxPerTx; // maximum of tokens that can be minted per transaction
    uint256 public maxPerAddress; // maximum of tokens that can be minted by a specific address.
    uint256 public mintPrice; // mint price per token, in the selected ERC20.
    mapping(address => uint256) internal _mintsPerAddress; // keeps track of how many tokens were minted per address.

    bool private _presaleIsOpen = false; // flag used to control the presale opening
    bool private _publicSaleIsOpen = false; // flag used to control the public sale opening


    event PresaleOpened();
    event PublicSaleOpened();
    event MintPriceChanged(uint256 indexed oldPrice, uint256 indexed newPrice);
    event SubscriptionIdChanged(uint256 indexed oldId, uint256 indexed newId);


    constructor(
        string memory dropName,
        uint256 _maxPerTx,
        uint256 _maxPerAddress,
        uint256 mintPriceERC20,
        address signingAddress,
        address _altEscrowAdmin,
        address _altMintingAdmin,
        address vaultAddress,
        address vrfCoordinator,
        bytes32 vrfKeyHash,
        uint64 vrfSubscriptionId
    )
        SignatureAccessControl(signingAddress)
        TokenMintingPool(vaultAddress, vrfCoordinator, vrfKeyHash, vrfSubscriptionId)
    {
        name = dropName;
        maxPerTx = _maxPerTx;
        maxPerAddress = _maxPerAddress;
        mintPrice = mintPriceERC20;

        _grantRole(MINTING_ADMIN_ROLE(), _altMintingAdmin);
        _setRoleAdmin(MINTING_ADMIN_ROLE(), MINTING_ADMIN_ROLE());

        _grantRole(ESCROW_ROLE(), _altEscrowAdmin);
        _setRoleAdmin(ESCROW_ROLE(), ESCROW_ROLE());
    }

    function updateSubscriptionId(uint64 _newId) external onlyAdmin {
        emit SubscriptionIdChanged(vrfSubscriptionId, _newId);
        vrfSubscriptionId = _newId;
    }

    function updateMintPrice(uint256 _mintPrice) external onlyAdmin {
        require(
            !(_presaleIsOpen || _publicSaleIsOpen),
            'PackDropBase: The drop already started - cannot update the mint price.'
        );
        emit MintPriceChanged(mintPrice, _mintPrice);
        mintPrice = _mintPrice;
    }


    function addTokens(bytes32[] calldata tokenHashes)
        external
        onlyAdmin
    {
        _addTokens(tokenHashes);
    }

    function removeTokens(bytes32[] calldata tokenHashes)
        external
        onlyAdmin
    {
        _removeTokens(tokenHashes);
    }

    function lockTokenSupply(uint32 callbackGasLimit, uint32 numberSeeds) external onlyAdmin {
        _lockTokenSupply(callbackGasLimit, numberSeeds);
    }


    function changeSigningAddress(address newSigningAddress) external onlyAdmin {
        emit SigningAddressChanged(signingAddress, newSigningAddress);
        signingAddress = newSigningAddress;
    }


    modifier onlyPresale() {
        require(_presaleIsOpen, 'PackDropBase: The presale is closed.');
        _;
    }

    function openPresale() external onlyAdmin {
        require(tokenSupplyLocked(), 'PackDropBase: The token supply needs to be locked.');
        _presaleIsOpen = true;
        emit PresaleOpened();
    }

    function openPublicSale() external onlyAdmin onlyPresale {
        _publicSaleIsOpen = true;
        emit PublicSaleOpened();
    }

    function saleStatus() external view returns (string memory) {
        bool tokenSupplyIsEmpty = remainingSupplyCount() <= 0;
        return
            _presaleIsOpen
                ? (
                    _publicSaleIsOpen
                        ? (tokenSupplyIsEmpty ? 'SOLD_OUT' : 'PUBLIC_SALE')
                        : (tokenSupplyIsEmpty ? 'SOLD_OUT' : 'PRESALE')
                )
                : 'CLOSED';
    }

    function selfCheckTokensMinted() external view returns (uint256) {
        return _mintsPerAddress[_msgSender()];
    }

    function checkMintableAmountPerAddress(address _address) external view returns(uint256) {
        return maxPerAddress - _mintsPerAddress[_address];
    }



    function _processMintRequest(
        address minter,
        uint256 requestedAmount
    ) private {
        uint256 remainingSupply = remainingSupplyCount();
        require(requestedAmount > 0, 'PackDropBase: Invalid request for zero tokens.');
        require(remainingSupply > 0, 'PackDropBase: No more tokens left.');
        require(_mintsPerAddress[minter] + requestedAmount < maxPerAddress + 1, 'PackDropBase: Token limit per wallet reached.');
        require(requestedAmount < maxPerTx + 1, 'PackDropBase: Token limit per transaction exceeded.');
        require(requestedAmount < remainingSupply + 1, 'PackDropBase: Not enough tokens left.');
        require(msg.value == requestedAmount * mintPrice, 'PackDropBase: Incorrect amount sent.');
        _mintsPerAddress[minter] += requestedAmount;
        _mintTokens(minter, requestedAmount);
}

    function claimTokens(
        uint256 amount,
        bytes calldata _signature
    ) external payable nonReentrant {
        address caller = _msgSender();
        require(caller == tx.origin, 'PackDropBase: No DelegateCall authorized');
        require(_hasAccess(caller, _signature), 'PackDropBase: This address does not have access to the drop.');
        if (!_publicSaleIsOpen) {
                require(_presaleIsOpen, 'PackDropBase: The presale is not open yet.');
            }
        _processMintRequest(caller, amount);
    }


    function ESCROW_ROLE() internal pure returns (bytes32) {
        return keccak256('ESCROW_ROLE');
    }

    function MINTING_ADMIN_ROLE() internal pure returns (bytes32) {
        return keccak256('MINTING_ADMIN_ROLE');
    }

    modifier onlyAdmin() {
        _checkRole(MINTING_ADMIN_ROLE(), _msgSender());
        _;
    }

    modifier onlyEscrow() {
        _checkRole(ESCROW_ROLE(), _msgSender());
        _;
    }


    function withdraw(address payable receiver) external onlyEscrow {
        require(receiver != address(0),'PackDropBase: Cannot set the receiver address to the null address.');
        receiver.call{value:address(this).balance}("");
    }
}// MIT

pragma solidity 0.8.9;


contract AltMint is PackDropBase {

    constructor()
        PackDropBase(
            'ALT MINT I',
            6,                                                                  // Max 6 tokens per transaction
            6,                                                                  // Max 6 tokens per address
            1 * 10**18,                                                         // 1 ETH (subject to updates before the drop)
            0x8b9F2275E958E208099428a8fD16F6B44eC8B7ea,                         // Signer Address for the Allow List
            0xB143199c62d2D351f7d3F4527D9ed117870D27A4,                         // Alt Escrow Admin Multisig
            0x7bA31DdB4bc7C082cd3A55fC412934EFF9791496,                         // Alt Minting Admin Multisig
            0x2b97Af906d580De5e9A415EEc8025E35f4645f44,                         // Alt Vault Proxy deployed on Eth Mainnet
            0x271682DEB8C4E0901D1a1550aD2e64D568E69909,                         // VRFCoordinator on Eth Mainnet
            0x8af398995b04c28e9951adb9721ef74c74f93e6a478f39e7e0777be13527e7ef, // Chainlink keyHash on Eth Mainnet
            173                                                                 // Chainlink v2 Subscription ID 
        )
    {}
}