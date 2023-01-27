
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

  function isValidSignature(address, bool, uint48, uint256, bytes memory) external view returns (bool);

  function getSeed(uint16) external returns (uint256);

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

interface IFoxGameNFT {

  enum Kind { RABBIT, FOX, HUNTER }
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



contract FoxGames_v1_1 is IFoxGame, OwnableUpgradeable, IERC721ReceiverUpgradeable,
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

  function _getSeed(uint16 offset, uint256 offset2) internal view returns (uint256) {

    return uint256(keccak256(abi.encodePacked(
      _seed,
      offset,
      offset2
    )));
  }

  function getSeed(uint16 offset) external view returns (uint256) {

    require(msg.sender == address(foxNFTGen1), "not approved");
    return _getSeed(offset, 0);
  }

  function setSeed(uint256 seed) external onlyOwner {

    _seed = seed;
  }

  function initialize() public initializer {

    __Ownable_init();
    __ReentrancyGuard_init();
    __Pausable_init();

    hunterStealFoxProbabilityMod = 20; // 100/5=20
    hunterTaxCutPercentage = 30; // whole number %

    _pause();
  }

  function joinFoxGames() external {

    require(tx.origin == msg.sender, "eos only");
    require(membershipDate[msg.sender] == 0, "already joined");
    membershipDate[msg.sender] = uint48(block.timestamp);
    memberNumber[msg.sender] = membershipCount;
    emit MemberJoined(msg.sender, membershipCount);
    membershipCount += 1;
  }

  function getSigningHash(address recipient, bool membership, uint48 expiration, uint256 seed) public pure returns (bytes32) {

    return keccak256(abi.encodePacked(recipient, membership, expiration, seed));
  }

  function isValidSignature(address recipient, bool membership, uint48 expiration, uint256 seed, bytes memory sig) public view returns (bool) {

    bytes32 message = getSigningHash(recipient, membership, expiration, seed).toEthSignedMessageHash();
    return ECDSAUpgradeable.recover(message, sig) == signVerifier;
  }

  function getTokenContract(uint16 tokenId) private view returns (IFoxGameNFT) {

    return tokenId <= 10000 ? foxNFT : foxNFTGen1;
  }

  function stakeTokens(address account, uint16[] calldata tokenIds) external whenNotPaused nonReentrant _updateEarnings {

    require((account == msg.sender && tx.origin == msg.sender) || msg.sender == address(foxNFTGen1), "not approved");
    
    IFoxGameNFT nftContract;
    for (uint16 i = 0; i < tokenIds.length; i++) {

      if (tokenIds[i] == 0) {
        continue;
      }

      nftContract = getTokenContract(tokenIds[i]);
      IFoxGameNFT.Kind kind = _getKind(nftContract, tokenIds[i]);
      if (kind == IFoxGameNFT.Kind.RABBIT) {
        _addRabbitToKeep(account, tokenIds[i]);
      } else if (kind == IFoxGameNFT.Kind.FOX) {
        _addFoxToDen(nftContract, account, tokenIds[i]);
      } else { // HUNTER
        _addHunterToCabin(nftContract, account, tokenIds[i]);
      }

      if (msg.sender != address(foxNFTGen1)) { // dont do this step if its a mint + stake
        require(nftContract.ownerOf(tokenIds[i]) == msg.sender, "only token owners can stake");
        nftContract.transferFrom(msg.sender, address(this), tokenIds[i]);
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
    if (_storeStaking) _stakedTokens[account].add(tokenId); // add staked ref
    emit TokenStaked("RABBIT", tokenId, account);
  }

  function _addFoxToDen(IFoxGameNFT nftContract, address account, uint16 tokenId) internal {

    uint8 cunning = _getAdvantagePoints(nftContract, tokenId);
    totalCunningPointsStaked += cunning;
    foxHierarchy[tokenId] = uint16(foxStakeByCunning[cunning].length);
    foxStakeByCunning[cunning].push(EarningStake({
      owner: account,
      tokenId: tokenId,
      earningRate: carrotPerCunningPoint
    }));
    totalFoxesStaked += 1;
    if (_storeStaking) _stakedTokens[account].add(tokenId); // add staked ref
    emit TokenStaked("FOX", tokenId, account);
  }

  function _addHunterToCabin(IFoxGameNFT nftContract, address account, uint16 tokenId) internal {

    uint8 marksman = _getAdvantagePoints(nftContract, tokenId);
    totalMarksmanPointsStaked += marksman;
    hunterHierarchy[tokenId] = uint16(hunterStakeByMarksman[marksman].length);
    hunterStakeByMarksman[marksman].push(EarningStake({
      owner: account,
      tokenId: tokenId,
      earningRate: carrotPerMarksmanPoint
    }));
    hunterStakeByToken[tokenId] = TimeStake({
      owner: account,
      tokenId: tokenId,
      time: uint48(block.timestamp)
    });
    totalHuntersStaked += 1;
    if (_storeStaking) _stakedTokens[account].add(tokenId); // add staked ref
    emit TokenStaked("HUNTER", tokenId, account);
  }

  function claimRewardsAndUnstake(uint16[] calldata tokenIds, bool unstake, bool membership, uint48 expiration, uint256 originSeed, bytes memory sig) external whenNotPaused nonReentrant _updateEarnings {

    require(tx.origin == msg.sender, "eos only");
    require(isValidSignature(msg.sender, membership, expiration, originSeed, sig), "invalid signature");

    uint256 seed;
    uint128 reward;
    IFoxGameNFT.Kind kind;
    IFoxGameNFT nftContract;
    uint48 time = uint48(block.timestamp);
    for (uint8 i = 0; i < tokenIds.length; i++) {
      nftContract = getTokenContract(tokenIds[i]);
      kind = _getKind(nftContract, tokenIds[i]);
      seed = _getSeed(tokenIds[i], originSeed);
      if (kind == IFoxGameNFT.Kind.RABBIT) {
        reward += _claimRabbitsFromKeep(nftContract, tokenIds[i], unstake, time, seed);
      } else if (kind == IFoxGameNFT.Kind.FOX) {
        reward += _claimFoxFromDen(nftContract, tokenIds[i], unstake, seed);
      } else { // HUNTER
        reward += _claimHunterFromCabin(nftContract, tokenIds[i], unstake, time);
      }
    }
    if (reward != 0) {
      foxCarrot.mint(msg.sender, reward);
    }
  }

  function _claimRabbitsFromKeep(IFoxGameNFT nftContract, uint16 tokenId, bool unstake, uint48 time, uint256 seed) internal returns (uint128 reward) {

    TimeStake memory stake = rabbitStakeByToken[tokenId];
    require(stake.owner == msg.sender, "only token owners can unstake");
    require(!(unstake && block.timestamp - stake.time < RABBIT_MINIMUM_TO_EXIT), "rabbits need 2 days of carrot");

    if (totalCarrotEarned < MAXIMUM_GLOBAL_CARROT) {
      reward = (time - stake.time) * RABBIT_EARNING_RATE;
    } else if (stake.time <= lastClaimTimestamp) {
      reward = (lastClaimTimestamp - stake.time) * RABBIT_EARNING_RATE;
    }

    if (unstake) {
      if (((seed >> 245) % 2) == 0) {
        _payTaxToPredators(reward, true);
        reward = 0;
      }
      delete rabbitStakeByToken[tokenId];
      totalRabbitsStaked -= 1;
      if (_storeStaking) _stakedTokens[stake.owner].remove(tokenId); // delete staked ref
      nftContract.safeTransferFrom(address(this), msg.sender, tokenId, "");
    } else {
      _payTaxToPredators(reward * RABBIT_CLAIM_TAX_PERCENTAGE / 100, false);
      reward = reward * (100 - RABBIT_CLAIM_TAX_PERCENTAGE) / 100;
      rabbitStakeByToken[tokenId] = TimeStake({
        owner: msg.sender,
        tokenId: tokenId,
        time: time
      });
    }

    emit TokenUnstaked("RABBIT", tokenId, stake.owner, reward);
  }

  function _claimFoxFromDen(IFoxGameNFT nftContract, uint16 tokenId, bool unstake, uint256 seed) internal returns (uint128 reward) {

    require(nftContract.ownerOf(tokenId) == address(this), "must be staked to claim rewards");
    uint8 cunning = _getAdvantagePoints(nftContract, tokenId);
    EarningStake memory stake = foxStakeByCunning[cunning][foxHierarchy[tokenId]];
    require(stake.owner == msg.sender, "only token owners can unstake");

    reward = (cunning) * (carrotPerCunningPoint - stake.earningRate);
    if (unstake) {
      totalCunningPointsStaked -= cunning; // Remove Alpha from total staked
      EarningStake memory lastStake = foxStakeByCunning[cunning][foxStakeByCunning[cunning].length - 1];
      foxStakeByCunning[cunning][foxHierarchy[tokenId]] = lastStake; // Shuffle last Fox to current position
      foxHierarchy[lastStake.tokenId] = foxHierarchy[tokenId];
      foxStakeByCunning[cunning].pop(); // Remove duplicate
      delete foxHierarchy[tokenId]; // Delete old mapping
      totalFoxesStaked -= 1;
      if (_storeStaking) _stakedTokens[stake.owner].remove(tokenId); // delete staked ref

      address recipient = msg.sender;
      if (((seed >> 245) % hunterStealFoxProbabilityMod) == 0) {
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
        earningRate: carrotPerCunningPoint
      });
    }

    emit TokenUnstaked("FOX", tokenId, stake.owner, reward);
  }

  function _claimHunterFromCabin(IFoxGameNFT nftContract, uint16 tokenId, bool unstake, uint48 time) internal returns (uint128 reward) {

    require(foxNFTGen1.ownerOf(tokenId) == address(this), "must be staked to claim rewards");
    uint8 marksman = _getAdvantagePoints(nftContract, tokenId);
    EarningStake memory earningStake = hunterStakeByMarksman[marksman][hunterHierarchy[tokenId]];
    require(earningStake.owner == msg.sender, "only token owners can unstake");

    reward = (marksman) * (carrotPerMarksmanPoint - earningStake.earningRate);
    if (unstake) {
      totalMarksmanPointsStaked -= marksman; // Remove Alpha from total staked
      EarningStake memory lastStake = hunterStakeByMarksman[marksman][hunterStakeByMarksman[marksman].length - 1];
      hunterStakeByMarksman[marksman][hunterHierarchy[tokenId]] = lastStake; // Shuffle last Fox to current position
      hunterHierarchy[lastStake.tokenId] = hunterHierarchy[tokenId];
      hunterStakeByMarksman[marksman].pop(); // Remove duplicate
      delete hunterHierarchy[tokenId]; // Delete old mapping
      if (_storeStaking) _stakedTokens[earningStake.owner].remove(tokenId); // delete staked ref
    } else {
      hunterStakeByMarksman[marksman][hunterHierarchy[tokenId]] = EarningStake({
        owner: msg.sender,
        tokenId: tokenId,
        earningRate: carrotPerMarksmanPoint
      });
    }

    TimeStake memory timeStake = hunterStakeByToken[tokenId];
    require(timeStake.owner == msg.sender, "only token owners can unstake");
    if (totalCarrotEarned < MAXIMUM_GLOBAL_CARROT) {
      reward += (time - timeStake.time) * HUNTER_EARNING_RATE;
    } else if (timeStake.time <= lastClaimTimestamp) {
      reward += (lastClaimTimestamp - timeStake.time) * HUNTER_EARNING_RATE;
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

    emit TokenUnstaked("HUNTER", tokenId, earningStake.owner, reward);
  }

  function _payTaxToPredators(uint128 amount, bool includeHunters) internal {

    uint128 amountDueFoxes = amount;

    if (includeHunters) {
      uint128 amountDueHunters = amount * hunterTaxCutPercentage / 100;
      amountDueFoxes -= amountDueHunters;

      if (totalMarksmanPointsStaked == 0) {
        unaccountedHunterRewards += amountDueHunters;
      } else {
        carrotPerMarksmanPoint += (amountDueHunters + unaccountedHunterRewards) / totalMarksmanPointsStaked;
        unaccountedHunterRewards = 0;
      }
    }

    if (totalCunningPointsStaked == 0) {
      unaccountedFoxRewards += amountDueFoxes;
    } else {
      carrotPerCunningPoint += (amountDueFoxes + unaccountedFoxRewards) / totalCunningPointsStaked;
      unaccountedFoxRewards = 0;
    }
  }

  modifier _updateEarnings() {

    if (totalCarrotEarned < MAXIMUM_GLOBAL_CARROT) {
      uint48 time = uint48(block.timestamp);
      uint48 elapsed = time - lastClaimTimestamp;
      totalCarrotEarned +=
        (elapsed * totalRabbitsStaked * RABBIT_EARNING_RATE) +
        (elapsed * totalHuntersStaked * HUNTER_EARNING_RATE);
      lastClaimTimestamp = time;
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

  function storeStakedUsers() external onlyOwner {

    TimeStake memory timeStake;
    for (uint16 tokenId = 0; tokenId < 10000; tokenId++) {
      timeStake = rabbitStakeByToken[tokenId];
      if (timeStake.tokenId != 0) {
        _stakedTokens[timeStake.owner].add(tokenId);
      }
    }

    uint256 earningLength;
    uint8 earningIdx;
    EarningStake memory earningStake;
    for (uint8 advantage = 5; advantage < 9; advantage++) {
      earningLength = foxStakeByCunning[advantage].length;
      for (earningIdx = 5; earningIdx < earningLength; earningIdx++) {
        earningStake = foxStakeByCunning[advantage][earningIdx];
        _stakedTokens[earningStake.owner].add(earningStake.tokenId);
      }

      earningLength = hunterStakeByMarksman[advantage].length;
      for (earningIdx = 5; earningIdx < earningLength; earningIdx++) {
        earningStake = hunterStakeByMarksman[advantage][earningIdx];
        _stakedTokens[earningStake.owner].add(earningStake.tokenId);
      }
    }

    _storeStaking = true;
  }

  function calculateRewards(uint16[] calldata tokenIds) external view returns (uint256[] memory) {

    require(tx.origin == msg.sender, "eos only");

    IFoxGameNFT.Kind kind;
    IFoxGameNFT nftContract;
    uint256[] memory rewards = new uint256[](tokenIds.length);
    uint48 time = uint48(block.timestamp);
    for (uint8 i = 0; i < tokenIds.length; i++) {
      nftContract = getTokenContract(tokenIds[i]);
      kind = _getKind(nftContract, tokenIds[i]);
      if (kind == IFoxGameNFT.Kind.RABBIT) {
        rewards[i] = _calculateRabbitReward(tokenIds[i], time);
      } else if (kind == IFoxGameNFT.Kind.FOX) {
        rewards[i] = _calculateFoxReward(nftContract, tokenIds[i]);
      } else { // HUNTER
        rewards[i] = _calculateHunterReward(nftContract, tokenIds[i], time);
      }
    }

    return rewards;
  }

  function _calculateRabbitReward(uint16 tokenId, uint48 time) internal view returns (uint256) {

    TimeStake memory stake = rabbitStakeByToken[tokenId];
    require(stake.owner == msg.sender, "only token owners can unstake");

    uint256 reward = 0;
    if (totalCarrotEarned < MAXIMUM_GLOBAL_CARROT) {
      reward = (time - stake.time) * RABBIT_EARNING_RATE;
    } else if (stake.time <= lastClaimTimestamp) {
      reward = (lastClaimTimestamp - stake.time) * RABBIT_EARNING_RATE;
    }

    return reward * (100 - RABBIT_CLAIM_TAX_PERCENTAGE) / 100;
  }

  function _calculateFoxReward(IFoxGameNFT nftContract, uint16 tokenId) internal view returns (uint256) {

    uint8 cunning = _getAdvantagePoints(nftContract, tokenId);
    EarningStake memory stake = foxStakeByCunning[cunning][foxHierarchy[tokenId]];
    require(stake.owner == msg.sender, "only token owners can unstake");

    return (cunning) * (carrotPerCunningPoint - stake.earningRate);
  }

  function _calculateHunterReward(IFoxGameNFT nftContract, uint16 tokenId, uint48 time) internal view returns (uint256) {

    uint8 marksman = _getAdvantagePoints(nftContract, tokenId);
    EarningStake memory earningStake = hunterStakeByMarksman[marksman][hunterHierarchy[tokenId]];
    require(earningStake.owner == msg.sender, "only token owners can unstake");

    uint256 reward = 0;
    reward = (marksman) * (carrotPerMarksmanPoint - earningStake.earningRate);

    TimeStake memory timeStake = hunterStakeByToken[tokenId];
    require(timeStake.owner == msg.sender, "only token owners can unstake");
    if (totalCarrotEarned < MAXIMUM_GLOBAL_CARROT) {
      reward += (time - timeStake.time) * HUNTER_EARNING_RATE;
    } else if (timeStake.time <= lastClaimTimestamp) {
      reward += (lastClaimTimestamp - timeStake.time) * HUNTER_EARNING_RATE;
    }

    return reward;
  }

  function togglePaused() external onlyOwner {

    if (paused()) {
      _unpause();
    } else {
      _pause();
    }
  }

  function setSignVerifier(address verifier) external onlyOwner {

    signVerifier = verifier;
  }

  function setNFTContract(address _address) external onlyOwner {

    foxNFT = IFoxGameNFT(_address);
  }

  function setNFTGen1Contract(address _address) external onlyOwner {

    foxNFTGen1 = IFoxGameNFT(_address);
  }

  function setCarrotContract(address _address) external onlyOwner {

    foxCarrot = IFoxGameCarrot(_address);
  }

  function setHunterTaxCutPercentage(uint8 percentCut) external onlyOwner {

    hunterTaxCutPercentage = percentCut;
  }

  function setHunterStealFoxPropabilityMod(uint8 mod) external onlyOwner {

    hunterStealFoxProbabilityMod = mod;
  }

  function depositsOf(address account) external view returns (uint16[] memory) {

    EnumerableSetUpgradeable.UintSet storage depositSet = _stakedTokens[account];
    uint16[] memory tokenIds = new uint16[] (depositSet.length());

    for (uint16 i; i < depositSet.length(); i++) {
      tokenIds[i] = uint16(depositSet.at(i));
    }

    return tokenIds;
  }

  function setStoredStaking(bool value) external onlyOwner {

    _storeStaking = value;
  }

  function onERC721Received(address, address from, uint256, bytes calldata) external pure override returns (bytes4) {    

    require(from == address(0x0), "only allow directly from mint");
    return IERC721ReceiverUpgradeable.onERC721Received.selector;
  }
}