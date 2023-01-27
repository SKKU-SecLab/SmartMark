
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

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

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
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
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
pragma solidity ^0.8.11;



error StakingPaused();
error CollectionNotSupported();
error StakingInvalidSignature();
error StakingInvalidTokenOwner();
error StakingNotStaked();
error InsufficientSoulz();
error TransferPaused();
error TransferToZeroAddress();

contract DeathPlanet is AccessControl {

  using EnumerableSet for EnumerableSet.UintSet;

  bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
  bytes32 public constant SIGNER_ROLE = keccak256("SIGNER_ROLE");
  bytes32 public constant TREASURY_ROLE = keccak256("TREASURY_ROLE");

  uint256 public constant YIELD_INTERVAL = 24 hours;

  struct TokenOwnership {
    address addr;
    uint64 yieldRate;
  }

  struct EarthlingData {
    uint64 accumulatedSoulz;
    uint64 lastAccumulatedTimestamp;
    uint64 spentSoulz;
    uint64 yieldRate;
  }

  bool public stakingActive;
  bool public transferActive;

  mapping(address => uint256) internal _collections;
  mapping(address => mapping(uint256 => TokenOwnership)) internal _ownerships;
  mapping(address => EarthlingData) internal _earthlingData;

  event Staked(address indexed account, address indexed contractAddress, uint256 indexed tokenId);
  event Unstaked(address indexed account, address indexed contractAddress, uint256 indexed tokenId);
  event SoulzSpent(address indexed account, uint256 amount);
  event SoulzTransfered(address indexed from, address indexed to, uint256 amount);
  event SoulzMinted(address indexed to, uint256 amount);

  constructor() {
    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
  }

  function ownerOf(address contractAddress, uint256 tokenId) public view returns (address) {

    return _ownerships[contractAddress][tokenId].addr;
  }

  function soulzBalanceOf(address owner) public view returns (uint256) {

    EarthlingData memory earthling = _earthlingData[owner];
    return
      uint256(earthling.accumulatedSoulz) +
      _unaccumulatedSoulz(earthling.lastAccumulatedTimestamp, earthling.yieldRate) -
      earthling.spentSoulz;
  }

  function soulzYieldOf(address owner) public view returns (uint256) {

    return _earthlingData[owner].yieldRate;
  }

  function soulzSpentOf(address owner) public view returns (uint256) {

    return _earthlingData[owner].spentSoulz;
  }

  function earthlingDataOf(address owner) public view returns (EarthlingData memory) {

    return _earthlingData[owner];
  }

  function tokenSoulzYieldOf(address contractAddress, uint256 tokenId) public view returns (uint256) {

    uint256 tokenYield = _ownerships[contractAddress][tokenId].yieldRate;
    if (tokenYield == 0) {
      tokenYield = _collections[contractAddress];
    }
    return tokenYield;
  }

  function stake(
    address contractAddress,
    uint256[] calldata tokenIds,
    uint256[] calldata tokenYields,
    bytes calldata signature
  ) external {

    if (!stakingActive) revert StakingPaused();

    uint64 collectionRate = uint64(_collections[contractAddress]);
    if (collectionRate == 0) revert CollectionNotSupported();

    if (tokenYields.length > 0) {
      if (!_validateSignature(signature, contractAddress, tokenIds, tokenYields)) revert StakingInvalidSignature();
    }

    mapping(uint256 => TokenOwnership) storage ownership = _ownerships[contractAddress];
    EarthlingData storage earthling = _earthlingData[_msgSender()];

    uint64 newYield = earthling.yieldRate;

    for (uint256 i; i < tokenIds.length; i++) {
      if (IERC721(contractAddress).ownerOf(tokenIds[i]) != _msgSender()) revert StakingInvalidTokenOwner();
      IERC721(contractAddress).safeTransferFrom(_msgSender(), address(this), tokenIds[i]);

      ownership[tokenIds[i]].addr = _msgSender();
      if (tokenYields.length > i) {
        ownership[tokenIds[i]].yieldRate = uint32(tokenYields[i]);
        newYield += uint64(tokenYields[i]);
      } else {
        ownership[tokenIds[i]].yieldRate = collectionRate;
        newYield += collectionRate;
      }

      emit Staked(_msgSender(), contractAddress, tokenIds[i]);
    }

    earthling.accumulatedSoulz += uint64(_unaccumulatedSoulz(earthling.lastAccumulatedTimestamp, earthling.yieldRate));
    earthling.lastAccumulatedTimestamp = uint64(block.timestamp);
    earthling.yieldRate = newYield;
  }

  function unstake(address contractAddress, uint256[] calldata tokenIds) external {

    EarthlingData storage earthling = _earthlingData[_msgSender()];
    uint64 newYield = earthling.yieldRate;

    for (uint256 i; i < tokenIds.length; i++) {
      if (IERC721(contractAddress).ownerOf(tokenIds[i]) != address(this)) revert StakingNotStaked();
      if (_ownerships[contractAddress][tokenIds[i]].addr != _msgSender()) revert StakingInvalidTokenOwner();

      IERC721(contractAddress).safeTransferFrom(address(this), _msgSender(), tokenIds[i]);

      _ownerships[contractAddress][tokenIds[i]].addr = address(0);
      newYield -= _ownerships[contractAddress][tokenIds[i]].yieldRate;

      emit Unstaked(_msgSender(), contractAddress, tokenIds[i]);
    }

    earthling.accumulatedSoulz += uint64(_unaccumulatedSoulz(earthling.lastAccumulatedTimestamp, earthling.yieldRate));
    earthling.lastAccumulatedTimestamp = uint64(block.timestamp);
    earthling.yieldRate = newYield;
  }

  function transferSoulz(address to, uint256 amount) external {

    if (!transferActive) revert TransferPaused();
    if (to == address(0)) revert TransferToZeroAddress();

    uint256 accountBalance = soulzBalanceOf(_msgSender());
    if (accountBalance < amount) revert InsufficientSoulz();

    _earthlingData[_msgSender()].accumulatedSoulz -= uint64(amount);
    _earthlingData[to].accumulatedSoulz += uint64(amount);

    emit SoulzTransfered(_msgSender(), to, amount);
  }

  function mintSoulz(address account, uint256 amount) external onlyRole(MINTER_ROLE) {

    _earthlingData[account].accumulatedSoulz += uint64(amount);

    emit SoulzMinted(account, amount);
  }

  function spendSoulz(address account, uint256 amount) external onlyRole(TREASURY_ROLE) {

    uint256 accountBalance = soulzBalanceOf(account);
    if (accountBalance < amount) revert InsufficientSoulz();
    _earthlingData[account].spentSoulz += uint64(amount);

    emit SoulzSpent(account, amount);
  }

  function setStakingActive(bool active) external onlyRole(DEFAULT_ADMIN_ROLE) {

    stakingActive = active;
  }

  function setTransferActive(bool active) external onlyRole(DEFAULT_ADMIN_ROLE) {

    transferActive = active;
  }

  function setSupportedCollection(address contractAddress, uint256 yield) external onlyRole(DEFAULT_ADMIN_ROLE) {

    _collections[contractAddress] = uint256(yield);
  }

  function onERC721Received(
    address operator,
    address from,
    uint256 tId,
    bytes calldata data
  ) external pure returns (bytes4) {

    return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
  }

  function _validateSignature(
    bytes calldata signature,
    address contractAddress,
    uint256[] memory tokenIds,
    uint256[] memory tokenYields
  ) internal view returns (bool) {

    bytes32 dataHash = keccak256(abi.encodePacked(contractAddress, tokenIds, tokenYields));
    bytes32 message = ECDSA.toEthSignedMessageHash(dataHash);

    address signer = ECDSA.recover(message, signature);
    return hasRole(SIGNER_ROLE, signer);
  }

  function _unaccumulatedSoulz(uint256 lastAccumulatedTimestamp, uint256 yieldRate) internal view returns (uint256) {

    if (lastAccumulatedTimestamp == 0) {
      return 0;
    }
    return ((block.timestamp - lastAccumulatedTimestamp) * yieldRate) / YIELD_INTERVAL;
  }
}