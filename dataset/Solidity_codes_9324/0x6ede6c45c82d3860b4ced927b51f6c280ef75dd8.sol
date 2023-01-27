
pragma solidity ^0.8.0;

abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
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
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

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

pragma solidity ^0.8.0;

interface IERC721ReceiverUpgradeable {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;

library ECDSAUpgradeable {

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

        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
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

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}// MIT

pragma solidity ^0.8.0;

library EnumerableSetUpgradeable {


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
}/*
 ██████╗██████╗  ██████╗  ██████╗ ██████╗ ██████╗ ██╗██╗     ███████╗     ██████╗  █████╗ ███╗   ███╗███████╗
██╔════╝██╔══██╗██╔═══██╗██╔════╝██╔═══██╗██╔══██╗██║██║     ██╔════╝    ██╔════╝ ██╔══██╗████╗ ████║██╔════╝
██║     ██████╔╝██║   ██║██║     ██║   ██║██║  ██║██║██║     █████╗      ██║  ███╗███████║██╔████╔██║█████╗  
██║     ██╔══██╗██║   ██║██║     ██║   ██║██║  ██║██║██║     ██╔══╝      ██║   ██║██╔══██║██║╚██╔╝██║██╔══╝  
╚██████╗██║  ██║╚██████╔╝╚██████╗╚██████╔╝██████╔╝██║███████╗███████╗    ╚██████╔╝██║  ██║██║ ╚═╝ ██║███████╗
 ╚═════╝╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚═════╝ ╚═════╝ ╚═╝╚══════╝╚══════╝     ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝
*/


pragma solidity ^0.8.10;

interface ICrocodileGame {

  function stakeTokens(address, uint16[] calldata, uint8[] calldata) external;

  function randomKarmaOwner(uint256) external view returns (address);

}/*
 ██████╗██████╗  ██████╗  ██████╗ ██████╗ ██████╗ ██╗██╗     ███████╗     ██████╗  █████╗ ███╗   ███╗███████╗
██╔════╝██╔══██╗██╔═══██╗██╔════╝██╔═══██╗██╔══██╗██║██║     ██╔════╝    ██╔════╝ ██╔══██╗████╗ ████║██╔════╝
██║     ██████╔╝██║   ██║██║     ██║   ██║██║  ██║██║██║     █████╗      ██║  ███╗███████║██╔████╔██║█████╗  
██║     ██╔══██╗██║   ██║██║     ██║   ██║██║  ██║██║██║     ██╔══╝      ██║   ██║██╔══██║██║╚██╔╝██║██╔══╝  
╚██████╗██║  ██║╚██████╔╝╚██████╗╚██████╔╝██████╔╝██║███████╗███████╗    ╚██████╔╝██║  ██║██║ ╚═╝ ██║███████╗
 ╚═════╝╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚═════╝ ╚═════╝ ╚═╝╚══════╝╚══════╝     ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝
*/


pragma solidity ^0.8.10;

interface ICrocodileGamePiranha {

  function mint(address to, uint256 amount) external;

  function burn(address from, uint256 amount) external;

}/*
 ██████╗██████╗  ██████╗  ██████╗ ██████╗ ██████╗ ██╗██╗     ███████╗     ██████╗  █████╗ ███╗   ███╗███████╗
██╔════╝██╔══██╗██╔═══██╗██╔════╝██╔═══██╗██╔══██╗██║██║     ██╔════╝    ██╔════╝ ██╔══██╗████╗ ████║██╔════╝
██║     ██████╔╝██║   ██║██║     ██║   ██║██║  ██║██║██║     █████╗      ██║  ███╗███████║██╔████╔██║█████╗  
██║     ██╔══██╗██║   ██║██║     ██║   ██║██║  ██║██║██║     ██╔══╝      ██║   ██║██╔══██║██║╚██╔╝██║██╔══╝  
╚██████╗██║  ██║╚██████╔╝╚██████╗╚██████╔╝██████╔╝██║███████╗███████╗    ╚██████╔╝██║  ██║██║ ╚═╝ ██║███████╗
 ╚═════╝╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚═════╝ ╚═════╝ ╚═╝╚══════╝╚══════╝     ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝
*/


pragma solidity ^0.8.10;

interface ICrocodileGameNFT {

  struct Traits {uint8 kind; uint8 dilemma; uint8 karmaP; uint8 karmaM; string traits;}
  function getMaxGEN0Players() external pure returns (uint16);

  function getTraits(uint16) external view returns (Traits memory);

  function setDilemma(uint16, uint8) external;

  function setKarmaP(uint16, uint8) external;

  function setKarmaM(uint16, uint8) external;

  function ownerOf(uint256) external view returns (address owner);

  function transferFrom(address, address, uint256) external;

  function safeTransferFrom(address, address, uint256, bytes memory) external;

  function burn(uint16) external;

}/*
 ██████╗██████╗  ██████╗  ██████╗ ██████╗ ██████╗ ██╗██╗     ███████╗     ██████╗  █████╗ ███╗   ███╗███████╗
██╔════╝██╔══██╗██╔═══██╗██╔════╝██╔═══██╗██╔══██╗██║██║     ██╔════╝    ██╔════╝ ██╔══██╗████╗ ████║██╔════╝
██║     ██████╔╝██║   ██║██║     ██║   ██║██║  ██║██║██║     █████╗      ██║  ███╗███████║██╔████╔██║█████╗  
██║     ██╔══██╗██║   ██║██║     ██║   ██║██║  ██║██║██║     ██╔══╝      ██║   ██║██╔══██║██║╚██╔╝██║██╔══╝  
╚██████╗██║  ██║╚██████╔╝╚██████╗╚██████╔╝██████╔╝██║███████╗███████╗    ╚██████╔╝██║  ██║██║ ╚═╝ ██║███████╗
 ╚═════╝╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚═════╝ ╚═════╝ ╚═╝╚══════╝╚══════╝     ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝
*/


pragma solidity ^0.8.10;

interface ICrocodileGameWARDER {

  struct Traits {uint8 kind; uint8 dilemma; uint8 karmaP; uint8 karmaM; string traits;}
  function getMaxGEN0Players() external pure returns (uint16);

  function getTraits(uint16) external view returns (Traits memory);

  function setDilemma(uint16, uint8) external;

  function setKarmaP(uint16, uint8) external;

  function setKarmaM(uint16, uint8) external;

  function ownerOf(uint256) external view returns (address owner);

  function isOwner(address) external view returns (bool isOwner);

  function transferFrom(address, address, uint256) external;

  function safeTransferFrom(address, address, uint256, bytes memory) external;

  function burn(uint16) external;

}/*
 ██████╗██████╗  ██████╗  ██████╗ ██████╗ ██████╗ ██╗██╗     ███████╗     ██████╗  █████╗ ███╗   ███╗███████╗
██╔════╝██╔══██╗██╔═══██╗██╔════╝██╔═══██╗██╔══██╗██║██║     ██╔════╝    ██╔════╝ ██╔══██╗████╗ ████║██╔════╝
██║     ██████╔╝██║   ██║██║     ██║   ██║██║  ██║██║██║     █████╗      ██║  ███╗███████║██╔████╔██║█████╗  
██║     ██╔══██╗██║   ██║██║     ██║   ██║██║  ██║██║██║     ██╔══╝      ██║   ██║██╔══██║██║╚██╔╝██║██╔══╝  
╚██████╗██║  ██║╚██████╔╝╚██████╗╚██████╔╝██████╔╝██║███████╗███████╗    ╚██████╔╝██║  ██║██║ ╚═╝ ██║███████╗
 ╚═════╝╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚═════╝ ╚═════╝ ╚═╝╚══════╝╚══════╝     ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝
*/


pragma solidity ^0.8.10;



contract CrocodileGame is ICrocodileGame, OwnableUpgradeable, IERC721ReceiverUpgradeable,
                    PausableUpgradeable, ReentrancyGuardUpgradeable {

  using ECDSAUpgradeable for bytes32;
  using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;


  uint32 public totalCrocodilesStaked;

  uint32 public totalCrocodilebirdsStaked;

  uint16 public totalStakedCooperate;
  uint16 public totalStakedBetray;

  uint48 public lastClaimTimestamp;

  uint48 public constant MINIMUM_TO_EXIT = 1 days;

  uint128 public constant MAXIMUM_GLOBAL_PIRANHA = 900000000 ether;

  uint128 public totalPiranhaEarned;

  uint128 public constant CROCODILE_EARNING_RATE = 115740740740740740; // 10000 ether / 1 days;
  uint128 public constant CROCODILEBIRD_EARNING_RATE = 115740740740740740; // 10000 ether / 1 days;

  struct TimeStake { uint16 tokenId; uint48 time; address owner; }
  struct KarmaStake { uint16 tokenId; address owner; uint8 karmaP; uint8 karmaM; }

  event TokenStaked(string kind, uint16 tokenId, address owner);
  event TokenUnstaked(string kind, uint16 tokenId, address owner, uint128 earnings);

  ICrocodileGameNFT private crocodileNFT;
  ICrocodileGamePiranha private crocodilePiranha;
  ICrocodileGameWARDER private crocodileWARDER;
  bool isWARDER = false;

  KarmaStake[] public karmaStake;
  mapping(uint16 => uint16[]) public karmaHierarchy;
  uint8 karmaStakeLength;

  TimeStake[] public crocodileStakeByToken; // crocodile storage
  mapping(uint16 => uint16) public crocodileHierarchy; // crocodile location within group

  TimeStake[] public crocodilebirdStakeByToken; // crocodile bird storage
  mapping(uint16 => uint16) public crocodilebirdHierarchy; // bird location within group

  mapping(address => EnumerableSetUpgradeable.UintSet) private _stakedTokens;


  function initialize() public initializer {

    __Ownable_init();
    __ReentrancyGuard_init();
    __Pausable_init();
  }


  function stakeTokens(address account, uint16[] calldata tokenIds, uint8[] calldata dilemmas) external whenNotPaused nonReentrant _updateEarnings {

    require((account == msg.sender && tx.origin == msg.sender) || msg.sender == address(crocodileNFT), "not approved");
    
    for (uint16 i = 0; i < tokenIds.length; i++) {
      if (msg.sender != address(crocodileNFT)) { 
        require(crocodileNFT.ownerOf(tokenIds[i]) == msg.sender, "only token owners can stake");
      }
      require((crocodileNFT.getTraits(tokenIds[i]).kind == 0) || (crocodileNFT.getTraits(tokenIds[i]).kind == 1), "traits overlaps");
      
      if (crocodileNFT.getTraits(tokenIds[i]).kind==0)
      { // CROCODILE
        _addCrocodileToSwamp(account, tokenIds[i], dilemmas[i]);
      } 
      else { // CROCODILEBIRD
        _addCrocodilebirdToNest(account, tokenIds[i], dilemmas[i]);
      }

      if (msg.sender != address(crocodileNFT)) {
        require(crocodileNFT.ownerOf(tokenIds[i]) == msg.sender, "only token owners can stake");
        crocodileNFT.transferFrom(msg.sender, address(this), tokenIds[i]);
      }
    }
  }


  function _addCrocodileToSwamp(address account, uint16 tokenId, uint8 dilemma) internal {


    if(dilemma==1){ // for COOPERATE
      if (crocodileNFT.getTraits(tokenId).karmaM>0){
        crocodileNFT.setKarmaM(tokenId, crocodileNFT.getTraits(tokenId).karmaM-1);
      }
      else{
        karmaHierarchy[tokenId].push(karmaStakeLength);
        karmaStakeLength++;
        karmaStake.push(KarmaStake({
          tokenId: tokenId,
          owner: account,
          karmaP: crocodileNFT.getTraits(tokenId).karmaP,
          karmaM: 0
        }));

        crocodileNFT.setKarmaP(tokenId, crocodileNFT.getTraits(tokenId).karmaP+1);
      }
    } 
    else{ // for BETRAY
      if(crocodileNFT.getTraits(tokenId).karmaP>0){
        KarmaStake memory KlastStake = karmaStake[karmaStakeLength-1];
        karmaStake[karmaHierarchy[tokenId][crocodileNFT.getTraits(tokenId).karmaP-1]] = KlastStake;
        karmaHierarchy[KlastStake.tokenId][KlastStake.karmaP] = karmaHierarchy[tokenId][crocodileNFT.getTraits(tokenId).karmaP-1];
        karmaStake.pop();
        karmaStakeLength--;
        karmaHierarchy[tokenId].pop();
        crocodileNFT.setKarmaP(tokenId, crocodileNFT.getTraits(tokenId).karmaP-1);
      }
      else{
        crocodileNFT.setKarmaM(tokenId, crocodileNFT.getTraits(tokenId).karmaM+1);
      }
    }
    crocodileHierarchy[tokenId] = uint16(crocodileStakeByToken.length);
    crocodileStakeByToken.push(TimeStake({
        owner: account,
        tokenId: tokenId,
        time: uint48(block.timestamp)
    }));
    
    totalCrocodilesStaked += 1;
    _stakedTokens[account].add(tokenId); 

    if (dilemma==1)
    {totalStakedCooperate += 1;}
    else if (dilemma==2)
    {totalStakedBetray += 1;}

    emit TokenStaked("CROCODILE", tokenId, account);
  }


  function _addCrocodilebirdToNest(address account, uint16 tokenId, uint8 dilemma) internal {


    if(dilemma==1){ // for Cooperating
      if(crocodileNFT.getTraits(tokenId).karmaM>0){
        crocodileNFT.setKarmaM(tokenId, crocodileNFT.getTraits(tokenId).karmaM-1);
      }
      else{
        karmaHierarchy[tokenId].push(karmaStakeLength);
        karmaStakeLength++;
        karmaStake.push(KarmaStake({
          tokenId: tokenId,
          owner: account,
          karmaP: crocodileNFT.getTraits(tokenId).karmaP,
          karmaM: 0
        }));
        crocodileNFT.setKarmaP(tokenId, crocodileNFT.getTraits(tokenId).karmaP+1);
      }
    }
    else{ // for Betraying
      if(crocodileNFT.getTraits(tokenId).karmaP>0){
        KarmaStake memory KlastStake = karmaStake[karmaStakeLength-1];
        karmaStake[karmaHierarchy[tokenId][crocodileNFT.getTraits(tokenId).karmaP-1]] = KlastStake;
        karmaHierarchy[KlastStake.tokenId][KlastStake.karmaP] = karmaHierarchy[tokenId][crocodileNFT.getTraits(tokenId).karmaP-1];
        karmaStake.pop();
        karmaStakeLength--;
        karmaHierarchy[tokenId].pop();
        crocodileNFT.setKarmaP(tokenId, crocodileNFT.getTraits(tokenId).karmaP-1);
      }
      else{
        crocodileNFT.setKarmaM(tokenId, crocodileNFT.getTraits(tokenId).karmaM+1);
      }
    }

    crocodilebirdHierarchy[tokenId] = uint16(crocodilebirdStakeByToken.length);
    crocodilebirdStakeByToken.push(TimeStake({
        owner: account,
        tokenId: tokenId,
        time: uint48(block.timestamp)
    }));

    totalCrocodilebirdsStaked += 1;
    _stakedTokens[account].add(tokenId);

    if (dilemma==1)
    {totalStakedCooperate += 1;}
    else if (dilemma==2)
    {totalStakedBetray += 1;}

    emit TokenStaked("CROCODILEBIRD", tokenId, account);
  }
  
  function claimRewardsAndUnstake(uint16[] calldata tokenIds, bool unstake, uint256 seed) external whenNotPaused nonReentrant _updateEarnings {

    require(tx.origin == msg.sender, "eos only");

    uint128 reward;
    uint48 time = uint48(block.timestamp);
    for (uint8 i = 0; i < tokenIds.length; i++) {
      if (crocodileNFT.getTraits(tokenIds[i]).kind==0) {
        reward += _claimCrocodilesFromSwamp(tokenIds[i], unstake, time, seed);
      } else { 
        reward += _claimCrocodilebirdsFromNest(tokenIds[i], unstake, time, seed);
      }
    }
    if (reward != 0) {
      if(!isWARDER){
        crocodilePiranha.mint(msg.sender, reward);
      }else{
        if(crocodileWARDER.isOwner(msg.sender)){
          crocodilePiranha.mint(msg.sender, reward*2);
        }else{
          crocodilePiranha.mint(msg.sender, reward);
        }
      }
    }
  }


  function _claimCrocodilesFromSwamp(uint16 tokenId, bool unstake, uint48 time, uint256 seed) internal returns (uint128 reward) {

    TimeStake memory stake = crocodileStakeByToken[crocodileHierarchy[tokenId]];
    require(stake.owner == msg.sender, "only token owners can unstake");
    require(!(unstake && block.timestamp - stake.time < MINIMUM_TO_EXIT), "crocodiles need 1 days of piranha");

    if (totalPiranhaEarned < MAXIMUM_GLOBAL_PIRANHA) {
      reward = (time - stake.time) * CROCODILE_EARNING_RATE;
    } 
    else if (stake.time <= lastClaimTimestamp) {
      reward = (lastClaimTimestamp - stake.time) * CROCODILE_EARNING_RATE;
    }
    bool burn = false;
    if (unstake) {
      
      uint8 dilemma = crocodileNFT.getTraits(tokenId).dilemma;
      uint16 randToken = _randomCrocodilebirdToken(seed);
      if(dilemma==1){ // for Cooperate
        totalStakedCooperate -= 1;
        crocodileNFT.setDilemma(tokenId, 0);
        if(randToken>0){
          if(crocodileNFT.getTraits(randToken).dilemma==2){
            reward = 0;
          }
        }
        
      }
      else if(dilemma==2){ // for Betray
        totalStakedBetray -= 1;
        crocodileNFT.setDilemma(tokenId, 0);
        if(randToken>0){
          if(crocodileNFT.getTraits(randToken).dilemma==1){
            reward *= 2;
          }
          else if(crocodileNFT.getTraits(randToken).dilemma==2){
            reward = 0;

            if(crocodileNFT.getTraits(tokenId).karmaM == 2){
              seed >>= 64;
              if( seed%1001 < 309){
                burn=true;
              } 
            }else if(crocodileNFT.getTraits(tokenId).karmaM == 3){
              seed >>= 64;
              if( seed%1001 < 500){
                burn=true;
              } 
            }else if(crocodileNFT.getTraits(tokenId).karmaM == 4){
              seed >>= 64;
              if( seed%1001 < 691){
                burn=true;
              } 
            }else if(crocodileNFT.getTraits(tokenId).karmaM == 5){
              seed >>= 64;
              if( seed%1001 < 841){
                burn=true;
              } 
            }else if(crocodileNFT.getTraits(tokenId).karmaM == 6){
              seed >>= 64;
              if( seed%1001 < 933){
                burn=true;
              } 
            }else if(crocodileNFT.getTraits(tokenId).karmaM == 7){
              seed >>= 64;
              if( seed%1001 < 977){
                burn=true;
              } 
            }else if(crocodileNFT.getTraits(tokenId).karmaM == 8){
              seed >>= 64;
              if( seed%1001 < 993){
                burn=true;
              } 
            }else if(crocodileNFT.getTraits(tokenId).karmaM == 9){
              seed >>= 64;
              if( seed%1001 < 997){
                burn=true;
              } 
            }else if(crocodileNFT.getTraits(tokenId).karmaM >= 10){ 
              burn = true;
            }
          }
          if(burn) {crocodileNFT.burn(tokenId);}
        }
      }
      TimeStake memory lastStake = crocodileStakeByToken[crocodileStakeByToken.length - 1];
      crocodileStakeByToken[crocodileHierarchy[tokenId]] = lastStake; 
      crocodileHierarchy[lastStake.tokenId] = crocodileHierarchy[tokenId];
      crocodileStakeByToken.pop(); 
      delete crocodileHierarchy[tokenId]; 

      totalCrocodilesStaked -= 1;
      _stakedTokens[stake.owner].remove(tokenId); 


      if(!burn) crocodileNFT.safeTransferFrom(address(this), msg.sender, tokenId, "");
    } 
    else {
      reward = reward / 2;      
      crocodileStakeByToken[crocodileHierarchy[tokenId]] = TimeStake({
        owner: msg.sender,
        tokenId: tokenId,
        time: time
      });
    }
    emit TokenUnstaked("CROCODILE", tokenId, stake.owner, reward);
  }


  function _claimCrocodilebirdsFromNest(uint16 tokenId, bool unstake, uint48 time, uint256 seed) internal returns (uint128 reward) {


    TimeStake memory stake = crocodilebirdStakeByToken[crocodileHierarchy[tokenId]];
    require(stake.owner == msg.sender, "only token owners can unstake");
    require(!(unstake && block.timestamp - stake.time < MINIMUM_TO_EXIT), "crocodile birds need 1 days of piranha");

    if (totalPiranhaEarned < MAXIMUM_GLOBAL_PIRANHA) {
      reward = (time - stake.time) * CROCODILEBIRD_EARNING_RATE;
    } 
    else if (stake.time <= lastClaimTimestamp) {
      reward = (lastClaimTimestamp - stake.time) * CROCODILEBIRD_EARNING_RATE;
    }
    bool burn = false;
    if (unstake) {
      uint8 dilemma = crocodileNFT.getTraits(tokenId).dilemma;
      uint16 randToken = _randomCrocodileToken(seed);
      if(dilemma==1){ // for COOPERATE
        totalStakedCooperate -= 1;
        crocodileNFT.setDilemma(tokenId, 0);
        if(randToken>0){
          if(crocodileNFT.getTraits(randToken).dilemma==2){
            reward = 0;
          }
        }
        
      }
      else if(dilemma==2){ // for BETRAY
        totalStakedBetray -= 1;
        crocodileNFT.setDilemma(tokenId, 0);
        if(randToken>0){
          if(crocodileNFT.getTraits(randToken).dilemma==1){
            reward *= 2;
          }
          else if(crocodileNFT.getTraits(randToken).dilemma==2){
            reward = 0;

            if(crocodileNFT.getTraits(tokenId).karmaM == 2){
              seed >>= 64;
              if( seed%1001 < 309){
                burn=true;
              } 
            }else if(crocodileNFT.getTraits(tokenId).karmaM == 3){
              seed >>= 64;
              if( seed%1001 < 500){
                burn=true;
              } 
            }else if(crocodileNFT.getTraits(tokenId).karmaM == 4){
              seed >>= 64;
              if( seed%1001 < 691){
                burn=true;
              } 
            }else if(crocodileNFT.getTraits(tokenId).karmaM == 5){
              seed >>= 64;
              if( seed%1001 < 841){
                burn=true;
              } 
            }else if(crocodileNFT.getTraits(tokenId).karmaM == 6){
              seed >>= 64;
              if( seed%1001 < 933){
                burn=true;
              } 
            }else if(crocodileNFT.getTraits(tokenId).karmaM == 7){
              seed >>= 64;
              if( seed%1001 < 977){
                burn=true;
              } 
            }else if(crocodileNFT.getTraits(tokenId).karmaM == 8){
              seed >>= 64;
              if( seed%1001 < 993){
                burn=true;
              } 
            }else if(crocodileNFT.getTraits(tokenId).karmaM == 9){
              seed >>= 64;
              if( seed%1001 < 997){
                burn=true;
              } 
            }else if(crocodileNFT.getTraits(tokenId).karmaM >= 10){ 
              burn = true;
            }
          }
          if(burn) {crocodileNFT.burn(tokenId);}
        }
      }
      TimeStake memory lastStake = crocodilebirdStakeByToken[crocodilebirdStakeByToken.length - 1];
      crocodilebirdStakeByToken[crocodilebirdHierarchy[tokenId]] = lastStake; 
      crocodilebirdHierarchy[lastStake.tokenId] = crocodilebirdHierarchy[tokenId];
      crocodilebirdStakeByToken.pop();
      delete crocodilebirdHierarchy[tokenId]; 

      totalCrocodilebirdsStaked -= 1;
      _stakedTokens[stake.owner].remove(tokenId);


      if(!burn) crocodileNFT.safeTransferFrom(address(this), msg.sender, tokenId, "");
    } else {
      reward = reward / 2;
      crocodilebirdStakeByToken[crocodilebirdHierarchy[tokenId]] = TimeStake({
        owner: msg.sender,
        tokenId: tokenId,
        time: time
      });
    }

    emit TokenUnstaked("CROCODILEBIRD", tokenId, stake.owner, reward);
  }


  modifier _updateEarnings() {

    if (totalPiranhaEarned < MAXIMUM_GLOBAL_PIRANHA) {
      uint48 time = uint48(block.timestamp);
      uint48 elapsed = time - lastClaimTimestamp;
      totalPiranhaEarned +=
        (elapsed * totalCrocodilesStaked * CROCODILE_EARNING_RATE) +
        (elapsed * totalCrocodilebirdsStaked * CROCODILEBIRD_EARNING_RATE);
      lastClaimTimestamp = time;
    }
    _;
  }

  function randomKarmaOwner(uint256 seed) external view returns (address) {

    if (karmaStakeLength == 0) {
      return address(0x0); // use 0x0 to return to msg.sender
    }
    seed >>= 32;
    return karmaStake[seed % karmaStakeLength].owner;
  }

  function _randomCrocodileToken(uint256 seed) internal view returns (uint16) {

    if (totalCrocodilesStaked == 0) {
      return 0; 
    }
    seed >>= 32;
    return crocodileStakeByToken[seed % crocodileStakeByToken.length].tokenId;
  }

  function _randomCrocodilebirdToken(uint256 seed) internal view returns (uint16) {

    if (totalCrocodilebirdsStaked == 0) {
      return 0; 
    }
    seed >>= 32;
    return crocodilebirdStakeByToken[seed % crocodilebirdStakeByToken.length].tokenId;
  }

  function depositsOf(address account) external view returns (uint16[] memory) {

    EnumerableSetUpgradeable.UintSet storage depositSet = _stakedTokens[account];
    uint16[] memory tokenIds = new uint16[] (depositSet.length());

    for (uint16 i; i < depositSet.length(); i++) {
      tokenIds[i] = uint16(depositSet.at(i));
    }

    return tokenIds;
  }

  function togglePaused() external onlyOwner {

    if (paused()) {
      _unpause();
    } else {
      _pause();
    }
  }

  function setNFTContract(address _address) external onlyOwner {

    crocodileNFT = ICrocodileGameNFT(_address);
  }


  function setPiranhaContract(address _address) external onlyOwner {

    crocodilePiranha = ICrocodileGamePiranha(_address);
  }

  function setWARDERContract(address _address) external onlyOwner {

    crocodileWARDER = ICrocodileGameWARDER(_address);
    isWARDER = true;
  }

  function onERC721Received(address, address from, uint256, bytes calldata) external pure override returns (bytes4) {    

    require(from == address(0x0), "only allow directly from mint");
    return IERC721ReceiverUpgradeable.onERC721Received.selector;
  }
}