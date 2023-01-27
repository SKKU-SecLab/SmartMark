
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
███████╗ ██████╗ ██╗  ██╗     ██████╗  █████╗ ███╗   ███╗███████╗
██╔════╝██╔═══██╗╚██╗██╔╝    ██╔════╝ ██╔══██╗████╗ ████║██╔════╝
█████╗  ██║   ██║ ╚███╔╝     ██║  ███╗███████║██╔████╔██║█████╗  
██╔══╝  ██║   ██║ ██╔██╗     ██║   ██║██╔══██║██║╚██╔╝██║██╔══╝  
██║     ╚██████╔╝██╔╝ ██╗    ╚██████╔╝██║  ██║██║ ╚═╝ ██║███████╗
╚═╝      ╚═════╝ ╚═╝  ╚═╝     ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝
*/


pragma solidity ^0.8.10;

interface IFoxGame {

  function stakeTokens(address, uint16[] calldata) external;

  function randomFoxOwner(uint256) external view returns (address);

  function isValidMintSignature(address, uint8, uint32, uint256, bytes memory) external view returns (bool);

  function ownsBarrel(address) external view returns (bool);

  function getCorruptionEnabled() external view returns (bool);

}/*
███████╗ ██████╗ ██╗  ██╗     ██████╗  █████╗ ███╗   ███╗███████╗
██╔════╝██╔═══██╗╚██╗██╔╝    ██╔════╝ ██╔══██╗████╗ ████║██╔════╝
█████╗  ██║   ██║ ╚███╔╝     ██║  ███╗███████║██╔████╔██║█████╗  
██╔══╝  ██║   ██║ ██╔██╗     ██║   ██║██╔══██║██║╚██╔╝██║██╔══╝  
██║     ╚██████╔╝██╔╝ ██╗    ╚██████╔╝██║  ██║██║ ╚═╝ ██║███████╗
╚═╝      ╚═════╝ ╚═╝  ╚═╝     ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝
*/


pragma solidity ^0.8.10;

interface IFoxGameCarrot {

  function mint(address to, uint256 amount) external;

  function burn(address from, uint256 amount) external;

}/*
███████╗ ██████╗ ██╗  ██╗     ██████╗  █████╗ ███╗   ███╗███████╗
██╔════╝██╔═══██╗╚██╗██╔╝    ██╔════╝ ██╔══██╗████╗ ████║██╔════╝
█████╗  ██║   ██║ ╚███╔╝     ██║  ███╗███████║██╔████╔██║█████╗  
██╔══╝  ██║   ██║ ██╔██╗     ██║   ██║██╔══██║██║╚██╔╝██║██╔══╝  
██║     ╚██████╔╝██╔╝ ██╗    ╚██████╔╝██║  ██║██║ ╚═╝ ██║███████╗
╚═╝      ╚═════╝ ╚═╝  ╚═╝     ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝
*/


pragma solidity ^0.8.10;

interface IFoxGameCrown {

  function mint(address to, uint256 amount) external;

  function burn(address from, uint256 amount) external;

}/*
███████╗ ██████╗ ██╗  ██╗     ██████╗  █████╗ ███╗   ███╗███████╗
██╔════╝██╔═══██╗╚██╗██╔╝    ██╔════╝ ██╔══██╗████╗ ████║██╔════╝
█████╗  ██║   ██║ ╚███╔╝     ██║  ███╗███████║██╔████╔██║█████╗  
██╔══╝  ██║   ██║ ██╔██╗     ██║   ██║██╔══██║██║╚██╔╝██║██╔══╝  
██║     ╚██████╔╝██╔╝ ██╗    ╚██████╔╝██║  ██║██║ ╚═╝ ██║███████╗
╚═╝      ╚═════╝ ╚═╝  ╚═╝     ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝
*/


pragma solidity ^0.8.10;

interface IFoxGameNFT {

  enum Kind { RABBIT, FOX, HUNTER }
  enum Coin { CARROT, CROWN }
  struct Traits { Kind kind; uint8 advantage; uint8[7] traits; }
  function getMaxGEN0Players() external pure returns (uint16);

  function getTraits(uint16) external view returns (Traits memory);

  function ownerOf(uint256) external view returns (address owner);

  function transferFrom(address, address, uint256) external;

  function safeTransferFrom(address, address, uint256, bytes memory) external;

}/*
███████╗ ██████╗ ██╗  ██╗     ██████╗  █████╗ ███╗   ███╗███████╗
██╔════╝██╔═══██╗╚██╗██╔╝    ██╔════╝ ██╔══██╗████╗ ████║██╔════╝
█████╗  ██║   ██║ ╚███╔╝     ██║  ███╗███████║██╔████╔██║█████╗  
██╔══╝  ██║   ██║ ██╔██╗     ██║   ██║██╔══██║██║╚██╔╝██║██╔══╝  
██║     ╚██████╔╝██╔╝ ██╗    ╚██████╔╝██║  ██║██║ ╚═╝ ██║███████╗
╚═╝      ╚═════╝ ╚═╝  ╚═╝     ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝
*/


pragma solidity ^0.8.10;



contract FoxGames_v1_2 is IFoxGame, OwnableUpgradeable, IERC721ReceiverUpgradeable,
                    PausableUpgradeable, ReentrancyGuardUpgradeable {

  using ECDSAUpgradeable for bytes32; // signature verification helpers
  using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet; // iterable staked tokens


  uint8 public constant MAX_ADVANTAGE = 8;

  uint8 public constant RABBIT_CLAIM_TAX_PERCENTAGE = 20;

  uint8 private hunterStealFoxProbabilityMod;

  uint8 private hunterTaxCutPercentage;

  uint16 public totalMarksmanPointsStaked;

  uint16 public totalCunningPointsStaked;

  uint32 public totalRabbitsStaked;

  uint32 public totalFoxesStaked;

  uint32 public totalHuntersStaked;

  uint48 public lastClaimTimestamp;

  uint48 public constant RABBIT_MINIMUM_TO_EXIT = 2 days;

  uint128 public constant MAXIMUM_GLOBAL_CARROT = 2500000000 ether;

  uint128 public totalCarrotEarned;

  uint128 public unaccountedFoxRewards;

  uint128 public unaccountedHunterRewards;

  uint128 public carrotPerCunningPoint;

  uint128 public carrotPerMarksmanPoint;

  uint128 public constant RABBIT_EARNING_RATE = 115740740740740740; // 10000 ether / 1 days;

  uint128 public constant HUNTER_EARNING_RATE = 231481481481481470; // 20000 ether / 1 days;

  struct TimeStake { uint16 tokenId; uint48 time; address owner; }
  struct EarningStake { uint16 tokenId; uint128 earningRate; address owner; }

  event TokenStaked(string kind, uint16 tokenId, address owner);
  event TokenUnstaked(string kind, uint16 tokenId, address owner, uint128 earnings);
  event FoxStolen(uint16 foxTokenId, address thief, address victim);

  address private signVerifier;

  IFoxGameNFT private foxNFT;
  IFoxGameCarrot private foxCarrot;

  mapping(uint16 => TimeStake) public rabbitStakeByToken;

  mapping(uint8 => EarningStake[]) public foxStakeByCunning; // foxes grouped by cunning
  mapping(uint16 => uint16) public foxHierarchy; // fox location within cunning group

  mapping(uint16 => TimeStake) public hunterStakeByToken;
  mapping(uint8 => EarningStake[]) public hunterStakeByMarksman; // hunter grouped by markman
  mapping(uint16 => uint16) public hunterHierarchy; // hunter location within marksman group

  mapping(address => uint48) public membershipDate;
  mapping(address => uint32) public memberNumber;
  event MemberJoined(address member, uint32 memberCount);
  uint32 public membershipCount;

  IFoxGameNFT private foxNFTGen1;

  mapping(address => EnumerableSetUpgradeable.UintSet) private _stakedTokens;

  bool private _storeStaking;

  uint256 private _seed;

  IFoxGameCrown private foxCrown;

  uint128 public totalCrownEarned;

  uint128 public constant MAXIMUM_GLOBAL_CROWN = 2500000000 ether;

  mapping(address => mapping(uint8 => mapping(uint16 => uint32))) private _stakeClaimBlock;

  uint8 private constant UNSTAKE_AND_CLAIM_IDX = 0;
  uint8 private constant CLAIM_IDX = 1;

  uint256 public barrelPrice;

  mapping(address => uint48) private barrelPurchaseDate;

  event BarrelPurchase(address account, uint256 price, uint48 timestamp);

  uint48 public corruptionStartDate;

  uint48 public lastCrownClaimTimestamp;

  uint48 public divergenceTime;

  uint128 public constant CORRUPTION_BURN_PERCENT_RATE = 1157407407407; // 10% burned per day

  event ClaimCarrot(IFoxGameNFT.Kind, uint16 tokenId, address owner, uint128 reward, uint128 corruptedCarrot);
  event CrownClaimed(string kind, uint16 tokenId, address owner, bool unstake, uint128 reward, uint128 tax, bool elevatedRisk);

  mapping(uint16 => bool) private tokenCarrotClaimed;

  uint48 private ___;

  uint128 public crownPerCunningPoint;

  uint128 public crownPerMarksmanPoint;

  mapping(uint16 => bool) private hasRecentEarningPoint;

  function setDivergenceTime(uint48 timestamp) external onlyOwner {

    divergenceTime = timestamp;
  }

  function initialize() public initializer {

    __Ownable_init();
    __ReentrancyGuard_init();
    __Pausable_init();

    hunterStealFoxProbabilityMod = 20; // 100/5=20
    hunterTaxCutPercentage = 30; // whole number %

    _pause();
  }

  function getCorruptionEnabled() external view returns (bool) {

    return corruptionStartDate != 0 && corruptionStartDate < block.timestamp;
  }

  function setCorruptionStartTime(uint48 timestamp) external onlyOwner {

    corruptionStartDate = timestamp;
  }

  function getClaimSigningHash(address recipient, uint16[] calldata tokenIds, bool unstake, uint32[] calldata blocknums, uint256[] calldata seeds) public pure returns (bytes32) {

    return keccak256(abi.encodePacked(recipient, tokenIds, unstake, blocknums, seeds));
  }
  function getMintSigningHash(address recipient, uint8 token, uint32 blocknum, uint256 seed) public pure returns (bytes32) {

    return keccak256(abi.encodePacked(recipient, token, blocknum, seed));
  }
  function isValidMintSignature(address recipient, uint8 token, uint32 blocknum, uint256 seed, bytes memory sig) public view returns (bool) {

    bytes32 message = getMintSigningHash(recipient, token, blocknum, seed).toEthSignedMessageHash();
    return ECDSAUpgradeable.recover(message, sig) == signVerifier;
  }
  function isValidClaimSignature(address recipient, uint16[] calldata tokenIds, bool unstake, uint32[] calldata blocknums, uint256[] calldata seeds, bytes memory sig) public view returns (bool) {

    bytes32 message = getClaimSigningHash(recipient, tokenIds, unstake, blocknums, seeds).toEthSignedMessageHash();
    return ECDSAUpgradeable.recover(message, sig) == signVerifier;
  }

  function setBarrelPrice(uint256 price) external onlyOwner {

    barrelPrice = price;
  }

  function purchaseBarrel() external whenNotPaused nonReentrant {

    require(tx.origin == msg.sender, "eos");
    require(barrelPurchaseDate[msg.sender] == 0, "one barrel per account");

    barrelPurchaseDate[msg.sender] = uint48(block.timestamp);
    foxCarrot.burn(msg.sender, barrelPrice);
    emit BarrelPurchase(msg.sender, barrelPrice, uint48(block.timestamp));
  }

  function ownsBarrel(address account) external view returns (bool) {

    return barrelPurchaseDate[account] != 0;
  }

  function getTokenContract(uint16 tokenId) private view returns (IFoxGameNFT) {

    return tokenId <= 10000 ? foxNFT : foxNFTGen1;
  }

  function getEntropies(address recipient, uint16[] calldata tokenIds) external view returns (uint32[2][] memory entropies) {

    require(tx.origin == msg.sender, "eos");

    entropies = new uint32[2][](tokenIds.length);
    for (uint8 i; i < tokenIds.length; i++) {
      uint16 tokenId = tokenIds[i];
      entropies[i] = [
        _stakeClaimBlock[recipient][UNSTAKE_AND_CLAIM_IDX][tokenId],
        _stakeClaimBlock[recipient][CLAIM_IDX][tokenId]
      ];
    }
  }

  function stakeTokens(address account, uint16[] calldata tokenIds) external whenNotPaused nonReentrant _updateEarnings {

    require((account == msg.sender && tx.origin == msg.sender) || msg.sender == address(foxNFTGen1), "not approved");
    
    IFoxGameNFT nftContract;
    uint32 blocknum = uint32(block.number);
    mapping(uint16 => uint32) storage senderUnstakeBlock = _stakeClaimBlock[msg.sender][UNSTAKE_AND_CLAIM_IDX];
    for (uint16 i; i < tokenIds.length; i++) {
      uint16 tokenId = tokenIds[i];

      if (tokenId == 0) {
        continue;
      }

      senderUnstakeBlock[tokenId] = blocknum;

      nftContract = getTokenContract(tokenId);
      IFoxGameNFT.Kind kind = _getKind(nftContract, tokenId);
      if (kind == IFoxGameNFT.Kind.RABBIT) {
        _addRabbitToKeep(account, tokenId);
      } else if (kind == IFoxGameNFT.Kind.FOX) {
        _addFoxToDen(nftContract, account, tokenId);
      } else { // HUNTER
        _addHunterToCabin(nftContract, account, tokenId);
      }

      if (msg.sender != address(foxNFTGen1)) { // dont do this step if its a mint + stake
        require(nftContract.ownerOf(tokenId) == msg.sender, "not owner");
        nftContract.transferFrom(msg.sender, address(this), tokenId);
      }
    }
  }

  function _addRabbitToKeep(address account, uint16 tokenId) internal {

    rabbitStakeByToken[tokenId] = TimeStake({
      owner: account,
      tokenId: tokenId,
      time: uint48(block.timestamp)
    });
    totalRabbitsStaked += 1;
    emit TokenStaked("RABBIT", tokenId, account);
  }

  function _addFoxToDen(IFoxGameNFT nftContract, address account, uint16 tokenId) internal {

    uint8 cunning = _getAdvantagePoints(nftContract, tokenId);
    totalCunningPointsStaked += cunning;
    foxHierarchy[tokenId] = uint16(foxStakeByCunning[cunning].length);
    foxStakeByCunning[cunning].push(EarningStake({
      owner: account,
      tokenId: tokenId,
      earningRate: crownPerCunningPoint
    }));
    hasRecentEarningPoint[tokenId] = true;
    totalFoxesStaked += 1;
    emit TokenStaked("FOX", tokenId, account);
  }

  function _addHunterToCabin(IFoxGameNFT nftContract, address account, uint16 tokenId) internal {

    uint8 marksman = _getAdvantagePoints(nftContract, tokenId);
    totalMarksmanPointsStaked += marksman;
    hunterHierarchy[tokenId] = uint16(hunterStakeByMarksman[marksman].length);
    hunterStakeByMarksman[marksman].push(EarningStake({
      owner: account,
      tokenId: tokenId,
      earningRate: crownPerMarksmanPoint
    }));
    hunterStakeByToken[tokenId] = TimeStake({
      owner: account,
      tokenId: tokenId,
      time: uint48(block.timestamp)
    });
    hasRecentEarningPoint[tokenId] = true;
    totalHuntersStaked += 1;
    emit TokenStaked("HUNTER", tokenId, account);
  }

  struct Param {
    IFoxGameNFT nftContract;
    uint16 tokenId;
    bool unstake;
    uint256 seed;
  }

  function claimRewardsAndUnstake(bool unstake, uint16[] calldata tokenIds, uint32[] calldata blocknums, uint256[] calldata seeds,  bytes calldata sig) external whenNotPaused nonReentrant _updateEarnings {

    require(tx.origin == msg.sender, "eos");
    require(isValidClaimSignature(msg.sender, tokenIds, unstake, blocknums, seeds, sig), "invalid signature");
    require(tokenIds.length == blocknums.length && blocknums.length == seeds.length, "seed mismatch");

    bool elevatedRisk =
      (corruptionStartDate != 0 && corruptionStartDate < block.timestamp) && // corrupted
      (barrelPurchaseDate[msg.sender] == 0);                                 // does not have barrel

    uint128 reward;
    mapping(uint16 => uint32) storage senderBlocks = _stakeClaimBlock[msg.sender][unstake ? UNSTAKE_AND_CLAIM_IDX : CLAIM_IDX];
    Param memory params;
    for (uint8 i; i < tokenIds.length; i++) {
      uint16 tokenId = tokenIds[i];

      require(senderBlocks[tokenId] == blocknums[i], "seed not match");

      if (!unstake) {
        senderBlocks[tokenId] = uint32(block.number);
      }

      params.nftContract = getTokenContract(tokenId);
      params.tokenId = tokenId;
      params.unstake = unstake;
      params.seed = seeds[i];

      IFoxGameNFT.Kind kind = _getKind(params.nftContract, params.tokenId);
      if (kind == IFoxGameNFT.Kind.RABBIT) {
        reward += _claimRabbitsFromKeep(params.nftContract, params.tokenId, params.unstake, params.seed, elevatedRisk);
      } else if (kind == IFoxGameNFT.Kind.FOX) {
        reward += _claimFoxFromDen(params.nftContract, params.tokenId, params.unstake, params.seed, elevatedRisk);
      } else { // HUNTER
        reward += _claimHunterFromCabin(params.nftContract, params.tokenId, params.unstake);
      }
    }

    if (reward != 0) {
      foxCrown.mint(msg.sender, reward);
    }
  }

  function _claimRabbitsFromKeep(IFoxGameNFT nftContract, uint16 tokenId, bool unstake, uint256 seed, bool elevatedRisk) internal returns (uint128 reward) {

    TimeStake storage stake = rabbitStakeByToken[tokenId];
    require(stake.owner == msg.sender, "not owner");
    uint48 time = uint48(block.timestamp);
    uint48 stakeStart = stake.time < divergenceTime ? divergenceTime : stake.time; // phase 2 reset
    require(!(unstake && time - stakeStart < RABBIT_MINIMUM_TO_EXIT), "needs 2 days of crown");

    if (totalCrownEarned < MAXIMUM_GLOBAL_CROWN) {
      reward = (time - stakeStart) * RABBIT_EARNING_RATE;
    } else if (stakeStart <= lastCrownClaimTimestamp) {
      reward = (lastCrownClaimTimestamp - stakeStart) * RABBIT_EARNING_RATE;
    }

    uint128 tax;
    if (unstake) {
      if (((seed >> 245) % 10) < (elevatedRisk ? 6 : 5)) {
        _payTaxToPredators(reward, true);
        tax = reward;
        reward = 0;
      }
      delete rabbitStakeByToken[tokenId];
      totalRabbitsStaked -= 1;
      nftContract.safeTransferFrom(address(this), msg.sender, tokenId, "");
    } else {
      tax = reward * RABBIT_CLAIM_TAX_PERCENTAGE / 100;
      _payTaxToPredators(tax, false);
      reward = reward * (100 - RABBIT_CLAIM_TAX_PERCENTAGE) / 100;
      rabbitStakeByToken[tokenId] = TimeStake({
        owner: msg.sender,
        tokenId: tokenId,
        time: time
      });
    }

    emit CrownClaimed("RABBIT", tokenId, stake.owner, unstake, reward, tax, elevatedRisk);
  }

  function _claimFoxFromDen(IFoxGameNFT nftContract, uint16 tokenId, bool unstake, uint256 seed, bool elevatedRisk) internal returns (uint128 reward) {

    require(nftContract.ownerOf(tokenId) == address(this), "not staked");
    uint8 cunning = _getAdvantagePoints(nftContract, tokenId);
    EarningStake storage stake = foxStakeByCunning[cunning][foxHierarchy[tokenId]];
    require(stake.owner == msg.sender, "not owner");

    uint128 migratedEarningPoint = hasRecentEarningPoint[tokenId] ? stake.earningRate : 0; // phase 2 reset
    if (crownPerCunningPoint > migratedEarningPoint) {
      reward = (cunning) * (crownPerCunningPoint - migratedEarningPoint);
    }
    if (unstake) {
      totalCunningPointsStaked -= cunning; // Remove Alpha from total staked
      EarningStake storage lastStake = foxStakeByCunning[cunning][foxStakeByCunning[cunning].length - 1];
      foxStakeByCunning[cunning][foxHierarchy[tokenId]] = lastStake; // Shuffle last Fox to current position
      foxHierarchy[lastStake.tokenId] = foxHierarchy[tokenId];
      foxStakeByCunning[cunning].pop(); // Remove duplicate
      delete foxHierarchy[tokenId]; // Delete old mapping
      totalFoxesStaked -= 1;

      address recipient = msg.sender;
      if (((seed >> 245) % (elevatedRisk ? 5 : hunterStealFoxProbabilityMod)) == 0) {
        recipient = _randomHunterOwner(seed);
        if (recipient == address(0x0)) {
          recipient = msg.sender;
        } else if (recipient != msg.sender) {
          emit FoxStolen(tokenId, recipient, msg.sender);
        }
      }
      nftContract.safeTransferFrom(address(this), recipient, tokenId, "");
    } else {
      foxStakeByCunning[cunning][foxHierarchy[tokenId]] = EarningStake({
        owner: msg.sender,
        tokenId: tokenId,
        earningRate: crownPerCunningPoint
      });
      hasRecentEarningPoint[tokenId] = true;
    }

    emit CrownClaimed("FOX", tokenId, stake.owner, unstake, reward, 0, elevatedRisk);
  }

  function _claimHunterFromCabin(IFoxGameNFT nftContract, uint16 tokenId, bool unstake) internal returns (uint128 reward) {

    require(foxNFTGen1.ownerOf(tokenId) == address(this), "not staked");
    uint8 marksman = _getAdvantagePoints(nftContract, tokenId);
    EarningStake storage earningStake = hunterStakeByMarksman[marksman][hunterHierarchy[tokenId]];
    require(earningStake.owner == msg.sender, "not owner");
    uint48 time = uint48(block.timestamp);

    uint128 migratedEarningPoint = hasRecentEarningPoint[tokenId] ? earningStake.earningRate : 0; // phase 2 reset
    if (crownPerCunningPoint > migratedEarningPoint) {
      reward = (marksman) * (crownPerMarksmanPoint - migratedEarningPoint);
    }
    if (unstake) {
      totalMarksmanPointsStaked -= marksman; // Remove Alpha from total staked
      EarningStake storage lastStake = hunterStakeByMarksman[marksman][hunterStakeByMarksman[marksman].length - 1];
      hunterStakeByMarksman[marksman][hunterHierarchy[tokenId]] = lastStake; // Shuffle last Fox to current position
      hunterHierarchy[lastStake.tokenId] = hunterHierarchy[tokenId];
      hunterStakeByMarksman[marksman].pop(); // Remove duplicate
      delete hunterHierarchy[tokenId]; // Delete old mapping
    } else {
      hunterStakeByMarksman[marksman][hunterHierarchy[tokenId]] = EarningStake({
        owner: msg.sender,
        tokenId: tokenId,
        earningRate: crownPerMarksmanPoint
      });
      hasRecentEarningPoint[tokenId] = true;
    }

    TimeStake storage timeStake = hunterStakeByToken[tokenId];
    require(timeStake.owner == msg.sender, "not owner");
    uint48 stakeStart = timeStake.time < divergenceTime ? divergenceTime : timeStake.time; // phase 2 reset
    if (totalCrownEarned < MAXIMUM_GLOBAL_CROWN) {
      reward += (time - stakeStart) * HUNTER_EARNING_RATE;
    } else if (stakeStart <= lastCrownClaimTimestamp) {
      reward += (lastCrownClaimTimestamp - stakeStart) * HUNTER_EARNING_RATE;
    }
    if (unstake) {
      delete hunterStakeByToken[tokenId];
      totalHuntersStaked -= 1;
      foxNFTGen1.safeTransferFrom(address(this), msg.sender, tokenId, "");
    } else {
      hunterStakeByToken[tokenId] = TimeStake({
        owner: msg.sender,
        tokenId: tokenId,
        time: time
      });
    }

    emit CrownClaimed("HUNTER", tokenId, earningStake.owner, unstake, reward, 0, false);
  }

  struct TokenReward {
    address owner;
    IFoxGameNFT.Kind kind;
    uint128 reward;
    uint128 corruptedCarrot;
  }

  function getCarrotReward(uint16 tokenId, uint48 time) private view returns (TokenReward memory claim) {

    IFoxGameNFT nftContract = getTokenContract(tokenId);
    claim.kind = _getKind(nftContract, tokenId);
    if (claim.kind == IFoxGameNFT.Kind.RABBIT) {
      claim = _getCarrotForRabbit(tokenId, time);
    } else if (claim.kind == IFoxGameNFT.Kind.FOX) {
      claim = _getCarrotForFox(nftContract, tokenId, time);
    } else { // HUNTER
      claim = _getCarrotForHunter(nftContract, tokenId, time);
    }
  }

  function getCarrotRewards(uint16[] calldata tokenIds) external view returns (TokenReward[] memory claims) {

    uint48 time = uint48(block.timestamp);
    claims = new TokenReward[](tokenIds.length);
    for (uint8 i; i < tokenIds.length; i++) {
      if (!tokenCarrotClaimed[tokenIds[i]]) {
        claims[i] = getCarrotReward(tokenIds[i], time);
      }
    }
  }

  function claimCarrotRewards(uint16[] calldata tokenIds) external  {

    require(tx.origin == msg.sender, "eos");

    uint128 reward;
    TokenReward memory claim;
    uint48 time = uint48(block.timestamp);
    for (uint8 i; i < tokenIds.length; i++) {
      if (!tokenCarrotClaimed[tokenIds[i]]) {
        claim = getCarrotReward(tokenIds[i], time);
        require(claim.owner == msg.sender, "not owner");
        reward += claim.reward;
        emit ClaimCarrot(claim.kind, tokenIds[i], claim.owner, claim.reward, claim.corruptedCarrot);
        tokenCarrotClaimed[tokenIds[i]] = true;
      }
    }

    if (reward != 0) {
      foxCarrot.mint(msg.sender, reward);
    }
  }

  function calculateCorruptedCarrot(address account, uint128 reward, uint48 time) private view returns (uint128 corruptedCarrot) {

    if (reward > 0 && corruptionStartDate != 0 && time > corruptionStartDate) {
      uint48 barrelTime = barrelPurchaseDate[account];
      uint128 unsafeElapsed = (barrelTime == 0 ? time - corruptionStartDate     // never bought barrel
          : barrelTime > corruptionStartDate ? barrelTime - corruptionStartDate // bought after corruption
          : 0                                                                   // bought before corruption
      );
      if (unsafeElapsed > 0) {
        corruptedCarrot = (reward * unsafeElapsed * CORRUPTION_BURN_PERCENT_RATE) / 1000000000000000000 /* 1eth */;
      }
    }
  }

  function _getCarrotForRabbit(uint16 tokenId, uint48 time) private view returns (TokenReward memory claim) {

    uint128 reward;
    TimeStake storage stake = rabbitStakeByToken[tokenId];
    if (divergenceTime == 0 || time < divergenceTime) { // divergence has't yet started
      reward = (time - stake.time) * RABBIT_EARNING_RATE;
    } else if (stake.time < divergenceTime) { // last moment to accrue carrot
      reward = (divergenceTime - stake.time) * RABBIT_EARNING_RATE;
    }

    claim.corruptedCarrot = calculateCorruptedCarrot(msg.sender, reward, time);
    claim.reward = reward - claim.corruptedCarrot;
    claim.owner = stake.owner;
  }

  function _getCarrotForFox(IFoxGameNFT nftContract, uint16 tokenId, uint48 time) private view returns (TokenReward memory claim) {

    uint8 cunning = _getAdvantagePoints(nftContract, tokenId);
    EarningStake storage stake = foxStakeByCunning[cunning][foxHierarchy[tokenId]];

    uint128 reward;
    if (carrotPerCunningPoint > stake.earningRate) {
      reward = cunning * (carrotPerCunningPoint - stake.earningRate);
    }

    claim.corruptedCarrot = calculateCorruptedCarrot(msg.sender, reward, time);
    claim.reward = reward - claim.corruptedCarrot;
    claim.owner = stake.owner;
  }

  function _getCarrotForHunter(IFoxGameNFT nftContract, uint16 tokenId, uint48 time) private view returns (TokenReward memory claim) {

    require(foxNFTGen1.ownerOf(tokenId) == address(this), "not staked");
    uint8 marksman = _getAdvantagePoints(nftContract, tokenId);
    EarningStake storage earningStake = hunterStakeByMarksman[marksman][hunterHierarchy[tokenId]];
    require(earningStake.owner == msg.sender, "not owner");
 
    uint128 reward;
    if (carrotPerMarksmanPoint > earningStake.earningRate) {
      reward = marksman * (carrotPerMarksmanPoint - earningStake.earningRate);
    }

    TimeStake storage timeStake = hunterStakeByToken[tokenId];
    if (divergenceTime == 0 || time < divergenceTime) {
      reward += (time - timeStake.time) * HUNTER_EARNING_RATE;
    } else if (timeStake.time < divergenceTime) {
      reward += (divergenceTime - timeStake.time) * HUNTER_EARNING_RATE;
    }

    claim.corruptedCarrot = calculateCorruptedCarrot(msg.sender, reward, time);
    claim.reward = reward - claim.corruptedCarrot;
    claim.owner = earningStake.owner;
  }

  function _payTaxToPredators(uint128 amount, bool includeHunters) internal {

    uint128 amountDueFoxes = amount;

    if (includeHunters) {
      uint128 amountDueHunters = amount * hunterTaxCutPercentage / 100;
      amountDueFoxes -= amountDueHunters;

      if (totalMarksmanPointsStaked == 0) {
        unaccountedHunterRewards += amountDueHunters;
      } else {
        crownPerMarksmanPoint += (amountDueHunters + unaccountedHunterRewards) / totalMarksmanPointsStaked;
        unaccountedHunterRewards = 0;
      }
    }

    if (totalCunningPointsStaked == 0) {
      unaccountedFoxRewards += amountDueFoxes;
    } else {
      crownPerCunningPoint += (amountDueFoxes + unaccountedFoxRewards) / totalCunningPointsStaked;
      unaccountedFoxRewards = 0;
    }
  }

  modifier _updateEarnings() {

    uint48 time = uint48(block.timestamp);
    if (totalCrownEarned < MAXIMUM_GLOBAL_CROWN) {
      uint48 elapsed = time - lastCrownClaimTimestamp;
      totalCrownEarned +=
        (elapsed * totalRabbitsStaked * RABBIT_EARNING_RATE) +
        (elapsed * totalHuntersStaked * HUNTER_EARNING_RATE);
      lastCrownClaimTimestamp = time;
    }
    _;
  }

  function _getKind(IFoxGameNFT nftContract, uint16 tokenId) internal view returns (IFoxGameNFT.Kind) {

    return nftContract.getTraits(tokenId).kind;
  }

  function _getAdvantagePoints(IFoxGameNFT nftContract, uint16 tokenId) internal view returns (uint8) {

    return MAX_ADVANTAGE - nftContract.getTraits(tokenId).advantage; // alpha index is 0-3
  }

  function randomFoxOwner(uint256 seed) external view returns (address) {

    if (totalCunningPointsStaked == 0) {
      return address(0x0); // use 0x0 to return to msg.sender
    }
    uint256 bucket = (seed & 0xFFFFFFFF) % totalCunningPointsStaked;
    uint256 cumulative;
    seed >>= 32;
    for (uint8 i = MAX_ADVANTAGE - 3; i <= MAX_ADVANTAGE; i++) {
      cumulative += foxStakeByCunning[i].length * i;
      if (bucket >= cumulative) continue;
      return foxStakeByCunning[i][seed % foxStakeByCunning[i].length].owner;
    }
    return address(0x0);
  }

  function _randomHunterOwner(uint256 seed) internal view returns (address) {

    if (totalMarksmanPointsStaked == 0) {
      return address(0x0); // use 0x0 to return to msg.sender
    }
    uint256 bucket = (seed & 0xFFFFFFFF) % totalMarksmanPointsStaked;
    uint256 cumulative;
    seed >>= 32;
    for (uint8 i = MAX_ADVANTAGE - 3; i <= MAX_ADVANTAGE; i++) {
      cumulative += hunterStakeByMarksman[i].length * i;
      if (bucket >= cumulative) continue;
      return hunterStakeByMarksman[i][seed % hunterStakeByMarksman[i].length].owner;
    }
    return address(0x0);
  }

  function calculateRewards(uint16[] calldata tokenIds) external view returns (TokenReward[] memory tokenRewards) {

    require(tx.origin == msg.sender, "eos only");

    IFoxGameNFT.Kind kind;
    IFoxGameNFT nftContract;
    tokenRewards = new TokenReward[](tokenIds.length);
    uint48 time = uint48(block.timestamp);
    for (uint8 i = 0; i < tokenIds.length; i++) {
      nftContract = getTokenContract(tokenIds[i]);
      kind = _getKind(nftContract, tokenIds[i]);
      if (kind == IFoxGameNFT.Kind.RABBIT) {
        tokenRewards[i] = _calculateRabbitReward(tokenIds[i], time);
      } else if (kind == IFoxGameNFT.Kind.FOX) {
        tokenRewards[i] = _calculateFoxReward(nftContract, tokenIds[i]);
      } else { // HUNTER
        tokenRewards[i] = _calculateHunterReward(nftContract, tokenIds[i], time);
      }
    }
  }

  function _calculateRabbitReward(uint16 tokenId, uint48 time) internal view returns (TokenReward memory tokenReward) {

    TimeStake storage stake = rabbitStakeByToken[tokenId];
    uint48 stakeStart = stake.time < divergenceTime ? divergenceTime : stake.time; // phase 2 reset

    uint128 reward;
    if (totalCrownEarned < MAXIMUM_GLOBAL_CROWN) {
      reward = (time - stakeStart) * RABBIT_EARNING_RATE;
    } else if (stakeStart <= lastCrownClaimTimestamp) {
      reward = (lastCrownClaimTimestamp - stakeStart) * RABBIT_EARNING_RATE;
    }

    tokenReward.owner = stake.owner;
    tokenReward.reward = reward * (100 - RABBIT_CLAIM_TAX_PERCENTAGE) / 100;
  }

  function _calculateFoxReward(IFoxGameNFT nftContract, uint16 tokenId) internal view returns (TokenReward memory tokenReward) {

    uint8 cunning = _getAdvantagePoints(nftContract, tokenId);
    EarningStake storage stake = foxStakeByCunning[cunning][foxHierarchy[tokenId]];

    uint128 reward;
    uint128 migratedEarningPoint = hasRecentEarningPoint[tokenId] ? stake.earningRate : 0; // phase 2 reset
    if (crownPerCunningPoint > migratedEarningPoint) {
      reward = (cunning) * (crownPerCunningPoint - migratedEarningPoint);
    }

    tokenReward.owner = stake.owner;
    tokenReward.reward = reward;
  }

  function _calculateHunterReward(IFoxGameNFT nftContract, uint16 tokenId, uint48 time) internal view returns (TokenReward memory tokenReward) {

    uint8 marksman = _getAdvantagePoints(nftContract, tokenId);
    EarningStake storage earningStake = hunterStakeByMarksman[marksman][hunterHierarchy[tokenId]];

    uint128 reward;
    uint128 migratedEarningPoint = hasRecentEarningPoint[tokenId] ? earningStake.earningRate : 0; // phase 2 reset
    if (crownPerMarksmanPoint > migratedEarningPoint) {
      reward = (marksman) * (crownPerMarksmanPoint - migratedEarningPoint);
    }

    TimeStake storage timeStake = hunterStakeByToken[tokenId];
    uint48 stakeStart = timeStake.time < divergenceTime ? divergenceTime : timeStake.time; // phase 2 reset
    require(timeStake.owner == msg.sender, "not owner");
    if (totalCrownEarned < MAXIMUM_GLOBAL_CROWN) {
      reward += (time - stakeStart) * HUNTER_EARNING_RATE;
    } else if (stakeStart <= lastCrownClaimTimestamp) {
      reward += (lastCrownClaimTimestamp - stakeStart) * HUNTER_EARNING_RATE;
    }

    tokenReward.owner = earningStake.owner;
    tokenReward.reward = reward;
  }

  function togglePaused() external onlyOwner {

    if (paused()) {
      _unpause();
    } else {
      _pause();
    }
  }

  function setExternalAddresses(address[5] memory addresses) external onlyOwner {

    signVerifier = addresses[0];
    foxNFT = IFoxGameNFT(addresses[1]);
    foxNFTGen1 = IFoxGameNFT(addresses[2]);
    foxCarrot = IFoxGameCarrot(addresses[3]);
    foxCrown = IFoxGameCrown(addresses[4]);
  }

  function onERC721Received(address, address from, uint256, bytes calldata) external pure override returns (bytes4) {    

    require(from == address(0x0));
    return IERC721ReceiverUpgradeable.onERC721Received.selector;
  }
}