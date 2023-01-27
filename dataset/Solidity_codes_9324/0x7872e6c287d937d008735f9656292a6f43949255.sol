
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
}// MIT

pragma solidity ^0.8.0;

library Strings {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (bytes memory) {


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
        return buffer;
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
}pragma solidity ^0.8.10;


interface IChubbyKaijuDAOStakingV2 {

  function stakeTokens(address, uint16[] calldata, bytes[] memory) external;

}pragma solidity ^0.8.10;


interface IChubbyKaijuDAOCrunch {

  function mint(address to, uint256 amount) external;

  function burn(address from, uint256 amount) external;

  function balanceOf(address owner) external view returns(uint256);

  function transferFrom(address, address, uint256) external;

  function allowance(address owner, address spender) external view returns(uint256);

  function approve(address spender, uint256 amount) external returns(bool);

}pragma solidity ^0.8.10;


interface IChubbyKaijuDAOGEN2 {

  function ownerOf(uint256) external view returns (address owner);

  function transferFrom(address, address, uint256) external;

  function safeTransferFrom(address, address, uint256, bytes memory) external;

  function burn(uint16) external;

  function traits(uint256) external returns (uint16);

}pragma solidity ^0.8.10;




contract ChubbyKaijuDAOStakingV2 is IChubbyKaijuDAOStakingV2, OwnableUpgradeable, IERC721ReceiverUpgradeable, PausableUpgradeable, ReentrancyGuardUpgradeable {

  using ECDSAUpgradeable for bytes32;
  using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;

  using Strings for uint128;

  uint32 public totalZombieStaked; // trait 0
  uint32 public totalAlienStaked; // trait 1
  uint32 public totalUndeadStaked; // trait 2



  uint48 public lastClaimTimestamp;

  uint48 public constant MINIMUM_TO_EXIT = 1 days;

  uint128 public constant MAXIMUM_CRUNCH = 18000000 ether; 
  uint128 public remaining_crunch = 17999872 ether;  // for 10 halvings
  uint128 public halving_phase = 0;

  uint128 public totalCrunchEarned;

  uint128 public CRUNCH_EARNING_RATE = 1024; //40; //74074074; // 1 crunch per day; H
  mapping(uint16=>uint128) public species_rate; 
  uint128 public constant TIME_BASE_RATE = 100000000;

  struct TimeStake { uint16 tokenId; uint48 time; address owner; uint16 trait; uint16 reward_type;}

  event TokenStaked(string kind, uint16 tokenId, address owner);
  event TokenUnstaked(string kind, uint16 tokenId, address owner, uint128 earnings);

  IChubbyKaijuDAOGEN2 private chubbykaijuGen2;
  IChubbyKaijuDAOCrunch private chubbykaijuDAOCrunch;


  TimeStake[] public gen2StakeByToken; 
  mapping(uint16 => uint16) public gen2Hierarchy; 
  mapping(address => EnumerableSetUpgradeable.UintSet) private _gen2StakedTokens;


  address private common_address;
  address private uncommon_address;
  address private rare_address;
  address private epic_address;
  address private legendary_address;
  address private one_address;

  

  struct rewardTypeStaked{
    uint32  common_gen2; // reward_type: 0 -> 1*1*(1+Time weight)
    uint32  uncommon_gen2; // reward_type: 1 -> 1*1*(1+Time weight)
    uint32  rare_gen2; // reward_type: 2 -> 2*1*(1+Time weight)
    uint32  epic_gen2; // reward_type: 3 -> -> 3*1*(1+Time weight)
    uint32  legendary_gen2; // reward_type: 4 -> 5*1*(1+Time weight)
    uint32  one_gen2; // reward_type: 5 -> 15*1*(1+Time weight)

  }

  rewardTypeStaked private rewardtypeStaked;

  function initialize() public initializer {

    __Ownable_init();
    __ReentrancyGuard_init();
    __Pausable_init();
    _pause();
  }

  function setSigners(address[] calldata signers) public onlyOwner{

    common_address = signers[0];
    uncommon_address = signers[1];
    rare_address = signers[2];
    epic_address = signers[3];
    legendary_address = signers[4];
    one_address = signers[5];
  }

  function setSpeciesRate() public onlyOwner{

    species_rate[0] = 125;
    species_rate[1] = 150;
    species_rate[2] = 200;
  }


  function stakeTokens(address account, uint16[] calldata tokenIds, bytes[] memory signatures) external whenNotPaused nonReentrant _updateEarnings {

    require((account == msg.sender), "only owners approved");
    
    for (uint16 i = 0; i < tokenIds.length; i++) {
      require(chubbykaijuGen2.ownerOf(tokenIds[i]) == msg.sender, "only owners approved");
      uint16 trait = chubbykaijuGen2.traits(tokenIds[i]); 
      _stakeGEN2(account, tokenIds[i], trait, signatures[i]);
      chubbykaijuGen2.transferFrom(msg.sender, address(this), tokenIds[i]);
    }
  
  }


  function _stakeGEN2(address account, uint16 tokenId, uint16 trait, bytes memory signature) internal {

    if(trait == 0){
      totalZombieStaked += 1;
    }else if(trait == 1){
      totalAlienStaked += 1;
    }else if(trait == 2){
      totalUndeadStaked += 1;
    }
    address rarity = rarityCheck(tokenId, signature);
    uint16 reward_type = 0;

    if(rarity == common_address){
      reward_type = 0;
      rewardtypeStaked.common_gen2 +=1;
    }else if(rarity == uncommon_address){
      reward_type = 1;
      rewardtypeStaked.uncommon_gen2 +=1;
    }else if(rarity == rare_address){
      reward_type = 2;
      rewardtypeStaked.rare_gen2 +=1;
    }else if (rarity == epic_address){
      reward_type = 3;
      rewardtypeStaked.epic_gen2 +=1;
    }else if(rarity == legendary_address){
      reward_type = 4;
      rewardtypeStaked.legendary_gen2 +=1;
    }else if(rarity == one_address){
      reward_type = 5;
      rewardtypeStaked.one_gen2 +=1;
    }

    gen2Hierarchy[tokenId] = uint16(gen2StakeByToken.length);
    gen2StakeByToken.push(TimeStake({
        owner: account,
        tokenId: tokenId,
        time: uint48(block.timestamp),
        trait: trait,
        reward_type: reward_type
    }));
    _gen2StakedTokens[account].add(tokenId); 
    

    emit TokenStaked("CHUBBYKAIJUGen2", tokenId, account);
  }



  function claimRewardsAndUnstake(uint16[] calldata tokenIds, bool unstake) external whenNotPaused nonReentrant _updateEarnings {

    require(tx.origin == msg.sender, "eos only");

    uint128 reward;
    uint48 time = uint48(block.timestamp);
    for (uint8 i = 0; i < tokenIds.length; i++) {
      reward += _claimGen2(tokenIds[i], unstake, time);
    }
    if (reward != 0) {
      chubbykaijuDAOCrunch.mint(msg.sender, reward);
    }
  }


  function _claimGen2(uint16 tokenId, bool unstake, uint48 time) internal returns (uint128 reward) {

    TimeStake memory stake = gen2StakeByToken[gen2Hierarchy[tokenId]];
    uint16 trait = stake.trait;
    uint16 reward_type = stake.reward_type;
    require(stake.owner == msg.sender, "only owners can unstake");
    require(!(unstake && block.timestamp - stake.time < MINIMUM_TO_EXIT), "need 1 day to unstake");

    reward = _calculateGEN2Rewards(tokenId);

    if (unstake) {
      TimeStake memory lastStake = gen2StakeByToken[gen2StakeByToken.length - 1];
      gen2StakeByToken[gen2Hierarchy[tokenId]] = lastStake; 
      gen2Hierarchy[lastStake.tokenId] = gen2Hierarchy[tokenId];
      gen2StakeByToken.pop(); 
      delete gen2Hierarchy[tokenId]; 

      if(trait == 0){
        totalZombieStaked -= 1;
      }else if(trait == 1){
        totalAlienStaked -= 1;
      }else if(trait == 2){
        totalUndeadStaked -= 1;
      }
      if(reward_type == 0){
        rewardtypeStaked.common_gen2 -=1;
      }else if(reward_type == 1){
        rewardtypeStaked.uncommon_gen2 -= 1;
      }else if(reward_type == 2){
        rewardtypeStaked.rare_gen2 -= 1;
      }else if(reward_type == 3){
        rewardtypeStaked.epic_gen2 -= 1;
      }else if(reward_type == 4){
        rewardtypeStaked.legendary_gen2 -= 1;
      }else if(reward_type == 5){
        rewardtypeStaked.one_gen2 -= 1;
      }
      _gen2StakedTokens[stake.owner].remove(tokenId); 
      chubbykaijuGen2.transferFrom(address(this), msg.sender, tokenId);

      emit TokenUnstaked("CHUBBYKAIJUGen2", tokenId, stake.owner, reward);
    } 
    else {
      gen2StakeByToken[gen2Hierarchy[tokenId]] = TimeStake({
        owner: msg.sender,
        tokenId: tokenId,
        time: time,
        trait: trait,
        reward_type: reward_type
      });
    }
    
  }


  function _calculateGEN2Rewards(uint16  tokenId) internal view returns (uint128 reward) {

    require(tx.origin == msg.sender, "eos only");
    TimeStake memory stake = gen2StakeByToken[gen2Hierarchy[tokenId]];

    uint48 time = uint48(block.timestamp);
    uint16 reward_type = stake.reward_type;
    if (totalCrunchEarned < MAXIMUM_CRUNCH) {
      uint128 time_weight = time-stake.time > 3600*24*120? 2*TIME_BASE_RATE: 20*(time-stake.time);
      if(reward_type == 0){
        reward = 1*1*(time-stake.time)*CRUNCH_EARNING_RATE;
        reward *= (TIME_BASE_RATE+time_weight);
      }else if(reward_type == 1){
        reward = 1*1*(time-stake.time)*CRUNCH_EARNING_RATE;
        reward *= (TIME_BASE_RATE+time_weight);
      }else if(reward_type == 2){
        reward = 2*1*(time-stake.time)*CRUNCH_EARNING_RATE;
        reward *= (TIME_BASE_RATE+time_weight);
      }else if(reward_type == 3){
        reward = 3*1*(time-stake.time)*CRUNCH_EARNING_RATE;
        reward *= (TIME_BASE_RATE+time_weight);
      }else if(reward_type == 4){
        reward = 5*1*(time-stake.time)*CRUNCH_EARNING_RATE;
        reward *= (TIME_BASE_RATE+time_weight);
      }else if(reward_type == 5){
        reward = 15*1*(time-stake.time)*CRUNCH_EARNING_RATE;
        reward *= (TIME_BASE_RATE+time_weight);
      }
    } 
    else if (stake.time <= lastClaimTimestamp) {
      uint128 time_weight = lastClaimTimestamp-stake.time > 3600*24*120? 2*TIME_BASE_RATE: 20*(lastClaimTimestamp-stake.time);
      if(reward_type == 0){
        reward = 1*1*(lastClaimTimestamp-stake.time)*CRUNCH_EARNING_RATE;
        reward *= (TIME_BASE_RATE+time_weight);
      }else if(reward_type == 1){
        reward = 1*1*(lastClaimTimestamp-stake.time)*CRUNCH_EARNING_RATE;
        reward *= (TIME_BASE_RATE+time_weight);
      }else if(reward_type == 2){
        reward = 2*1*(lastClaimTimestamp-stake.time)*CRUNCH_EARNING_RATE;
        reward *= (TIME_BASE_RATE+time_weight);
      }else if(reward_type == 3){
        reward = 3*1*(lastClaimTimestamp-stake.time)*CRUNCH_EARNING_RATE;
        reward *= (TIME_BASE_RATE+time_weight);
      }else if(reward_type == 4){
        reward = 5*1*(lastClaimTimestamp-stake.time)*CRUNCH_EARNING_RATE;
        reward *= (TIME_BASE_RATE+time_weight);
      }else if(reward_type == 5){
        reward = 15*1*(lastClaimTimestamp-stake.time)*CRUNCH_EARNING_RATE;
        reward *= (TIME_BASE_RATE+time_weight);
      }
    }
    reward *= species_rate[stake.trait];
  }
  function calculateGEN2Rewards(uint16  tokenId) external view returns (uint128) {

    return _calculateGEN2Rewards(tokenId);
  }

  modifier _updateEarnings() {

    if (totalCrunchEarned < MAXIMUM_CRUNCH) {
      uint48 time = uint48(block.timestamp);
      uint128 temp = (1*1*(time - lastClaimTimestamp)*CRUNCH_EARNING_RATE*rewardtypeStaked.common_gen2);
      uint128 temp2 = (100000000+20*(time - lastClaimTimestamp))*150;
      temp *= temp2;
      totalCrunchEarned += temp;

      temp = (1*1*(time - lastClaimTimestamp)*(CRUNCH_EARNING_RATE)*rewardtypeStaked.uncommon_gen2);
      temp *= temp2;
      totalCrunchEarned += temp;

      temp = (2*1*(time - lastClaimTimestamp)*(CRUNCH_EARNING_RATE)*rewardtypeStaked.rare_gen2);
      temp *= temp2;
      totalCrunchEarned += temp;

      temp = (3*1*(time - lastClaimTimestamp)*(CRUNCH_EARNING_RATE)*rewardtypeStaked.epic_gen2);
      temp *= temp2;
      totalCrunchEarned += temp;

      temp = (5*1*(time - lastClaimTimestamp)*(CRUNCH_EARNING_RATE)*rewardtypeStaked.legendary_gen2);
      temp *= temp2;
      totalCrunchEarned += temp;

      temp = (15*1*(time - lastClaimTimestamp)*(CRUNCH_EARNING_RATE)*rewardtypeStaked.one_gen2);
      temp *= temp2;
      totalCrunchEarned += temp;
      
      lastClaimTimestamp = time;
    }
    if(MAXIMUM_CRUNCH-totalCrunchEarned < remaining_crunch/2 && halving_phase < 10){
      CRUNCH_EARNING_RATE /= 2;
      remaining_crunch /= 2;
      halving_phase += 1;
    }
    _;
  }

  function GEN2depositsOf(address account) external view returns (uint16[] memory) {

    EnumerableSetUpgradeable.UintSet storage depositSet = _gen2StakedTokens[account];
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

  function setGen2Contract(address _address) external onlyOwner {

    chubbykaijuGen2 = IChubbyKaijuDAOGEN2(_address);
  }

  function setCrunchContract(address _address) external onlyOwner {

    chubbykaijuDAOCrunch = IChubbyKaijuDAOCrunch(_address);
  }

  function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32) {

        return
        keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash)
        );
  }

  function rarityCheck(uint16 tokenId, bytes memory signature) public view returns (address) {

      bytes32 messageHash = keccak256(Strings.toString(tokenId));
      bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

      return recoverSigner(ethSignedMessageHash, signature);
  }

  function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature) private pure returns (address) {

      (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);
      return ecrecover(_ethSignedMessageHash, v, r, s);
  }

  function splitSignature(bytes memory sig) private pure returns (bytes32 r, bytes32 s, uint8 v) {

      require(sig.length == 65, "sig invalid");

      assembly {

          r := mload(add(sig, 32))
          s := mload(add(sig, 64))
          v := byte(0, mload(add(sig, 96)))
      }

  }

  

  function onERC721Received(address, address from, uint256, bytes calldata) external pure override returns (bytes4) {    

    require(from == address(0x0), "only allow directly from mint");
    return IERC721ReceiverUpgradeable.onERC721Received.selector;
  }
}