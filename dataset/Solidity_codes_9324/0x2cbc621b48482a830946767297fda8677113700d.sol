
pragma solidity ^0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.1;

library AddressUpgradeable {

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


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

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

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }

    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
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

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
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

    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

library StringsUpgradeable {

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

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", StringsUpgradeable.toString(s.length), s));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
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
}// MIT

pragma solidity ^0.8.0;

library SafeCastUpgradeable {

    function toUint224(uint256 value) internal pure returns (uint224) {

        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    function toUint128(uint256 value) internal pure returns (uint128) {

        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    function toUint96(uint256 value) internal pure returns (uint96) {

        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    function toUint64(uint256 value) internal pure returns (uint64) {

        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    function toUint32(uint256 value) internal pure returns (uint32) {

        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    function toUint16(uint256 value) internal pure returns (uint16) {

        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    function toUint8(uint256 value) internal pure returns (uint8) {

        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    function toUint256(int256 value) internal pure returns (uint256) {

        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    function toInt128(int256 value) internal pure returns (int128) {

        require(value >= type(int128).min && value <= type(int128).max, "SafeCast: value doesn't fit in 128 bits");
        return int128(value);
    }

    function toInt64(int256 value) internal pure returns (int64) {

        require(value >= type(int64).min && value <= type(int64).max, "SafeCast: value doesn't fit in 64 bits");
        return int64(value);
    }

    function toInt32(int256 value) internal pure returns (int32) {

        require(value >= type(int32).min && value <= type(int32).max, "SafeCast: value doesn't fit in 32 bits");
        return int32(value);
    }

    function toInt16(int256 value) internal pure returns (int16) {

        require(value >= type(int16).min && value <= type(int16).max, "SafeCast: value doesn't fit in 16 bits");
        return int16(value);
    }

    function toInt8(int256 value) internal pure returns (int8) {

        require(value >= type(int8).min && value <= type(int8).max, "SafeCast: value doesn't fit in 8 bits");
        return int8(value);
    }

    function toInt256(uint256 value) internal pure returns (int256) {

        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
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
pragma solidity ^0.8.2;


contract HeroEscrow is ERC165Upgradeable, IERC721ReceiverUpgradeable, ReentrancyGuardUpgradeable, OwnableUpgradeable {

    struct HeroInfo {
        uint16 level;
        address owner;          // staked to, otherwise owner == 0
        uint16 deposit;         // Needed for rental functions in the future
        uint16 rentalPerDay;    // Needed for rental functions in the future
        uint16 minRentDays;     // Needed for rental functions in the future
        uint32 rentableUntil;   // Needed for rental functions in the future
    }

    struct RewardsPerlevel {
        uint32 totalLevel;
        uint96 accumulated;
        uint32 lastUpdated;
        uint96 rate;
    }

    struct UserRewards {
        uint32 stakedLevel;
        uint96 accumulated;
        uint96 checkpoint;
    }

    using SafeCastUpgradeable for uint;
    using ECDSAUpgradeable for bytes32;

    IERC20 WRLD_ERC20_ADDR;
    IERC721 HERO_ERC721;
    HeroInfo[5555] private heroInfo;
    RewardsPerlevel public rewardsPerlevel;     
    mapping (address => UserRewards) public rewards;
    mapping (address => uint[]) public stakedHeroes;
    address private signer;

    constructor() initializer {}

    function initialize(address wrld, address herogalaxy) initializer public {

        __ERC165_init();
        __ReentrancyGuard_init();
        __Ownable_init();
        require(wrld != address(0), "E0"); // E0: addr err
        require(herogalaxy != address(0), "E0");
        WRLD_ERC20_ADDR = IERC20(wrld);
        HERO_ERC721 = IERC721(herogalaxy);
    }

    function setRewards(uint96 rate) external virtual onlyOwner {

        require(rate < 10 ether, "E1"); // E1: Rate incorrect

        rewardsPerlevel.lastUpdated = block.timestamp.toUint32();
        rewardsPerlevel.rate = rate;
    }

    function setSigner(address _signer) external onlyOwner {

        signer = _signer;
    }

    function stake(uint[] calldata tokenIds, uint[] calldata levels, address stakeTo, uint32 _maxTimestamp, bytes calldata _signature) 
        external virtual nonReentrant {

        require(tokenIds.length == levels.length, "E2"); // E2: Input length mismatch
        require(block.timestamp <= _maxTimestamp, "E3"); // E3: Signature expired
        require(_verifySignerSignature(keccak256(
            abi.encode(tokenIds, levels, msg.sender, _maxTimestamp, address(this))), _signature), "E7"); // E7: Invalid signature
        _ensureEOAorERC721Receiver(stakeTo);
        require(stakeTo != address(this), "E4"); // E4: Cannot stake to escrow

        uint totalLevels = 0;
        for (uint i = 0; i < tokenIds.length; i++) {
            {
                uint tokenId = tokenIds[i];
                require(HERO_ERC721.ownerOf(tokenId) == msg.sender, "E5"); // E5: Not your hero
                HERO_ERC721.safeTransferFrom(msg.sender, address(this), tokenId);  
            }
            heroInfo[tokenIds[i]] = HeroInfo(levels[i].toUint16(), stakeTo, 0, 0, 0, 0);
            totalLevels += levels[i];
        }
        _updateRewardsPerlevel(totalLevels.toUint32(), true);
        _updateUserRewards(stakeTo, totalLevels.toUint32(), true);
    }

    function unstake(uint[] calldata tokenIds, address unstakeTo) external virtual nonReentrant {

        _ensureEOAorERC721Receiver(unstakeTo);
        require(unstakeTo != address(this), "ES"); // E4: Cannot unstake to escrow

        uint totalLevels = 0;
        for (uint i = 0; i < tokenIds.length; i++) {
            uint tokenId = tokenIds[i];
            require(heroInfo[tokenId].owner == msg.sender, "E5"); // E9: Not your hero
            HERO_ERC721.safeTransferFrom(address(this), unstakeTo, tokenId);
            uint16 _level = heroInfo[tokenId].level;
            totalLevels += _level;
            heroInfo[tokenId] = HeroInfo(0,address(0), 0, 0, 0, 0);
        }
        _updateRewardsPerlevel(totalLevels.toUint32(), false);
        _updateUserRewards(msg.sender, totalLevels.toUint32(), false);
    }

    function claim(address to) external virtual {

        _updateRewardsPerlevel(0, false);
        uint rewardAmount = _updateUserRewards(msg.sender, 0, false);
        rewards[msg.sender].accumulated = 0;
        WRLD_ERC20_ADDR.transfer(to, rewardAmount);
    }

    function updateRent(uint[] calldata tokenIds, 
        uint16 _deposit, uint16 _rentalPerDay, uint16 _minRentDays, uint32 _rentableUntil) 
        external virtual {

    }

    function extendRentalPeriod(uint tokenId, uint32 _rentableUntil) external virtual {

    }


    function getHeroInfo(uint tokenId) external view returns(HeroInfo memory) {

        return heroInfo[tokenId];
    }

    function getAllHeroesInfo() external view returns(HeroInfo[5555] memory) {

        return heroInfo;
    }

    function checkUserRewards(address user) external virtual view returns(uint) {

        RewardsPerlevel memory rewardsPerLevel_ = rewardsPerlevel;
        UserRewards memory userRewards_ = rewards[user];

        uint32 end = block.timestamp.toUint32();
        uint256 unaccountedTime = end - rewardsPerLevel_.lastUpdated; // Cast to uint256 to avoid overflows later on
        if (unaccountedTime != 0) {

            if (rewardsPerLevel_.totalLevel != 0) {
                rewardsPerLevel_.accumulated = (rewardsPerLevel_.accumulated + unaccountedTime * rewardsPerLevel_.rate / rewardsPerLevel_.totalLevel).toUint96();
            }
        }
        return userRewards_.accumulated + userRewards_.stakedLevel * (rewardsPerLevel_.accumulated - userRewards_.checkpoint);
    }


    function _verifySignerSignature(bytes32 hash, bytes calldata signature) internal view returns(bool) {

        return hash.toEthSignedMessageHash().recover(signature) == signer;
    }


    function _updateRewardsPerlevel(uint32 level, bool increase) internal virtual {

        RewardsPerlevel memory rewardsPerLevel_ = rewardsPerlevel;
        uint32 end = block.timestamp.toUint32();
        uint256 unaccountedTime = end - rewardsPerLevel_.lastUpdated; // Cast to uint256 to avoid overflows later on
        if (unaccountedTime != 0) {

            if (rewardsPerLevel_.totalLevel != 0) {
                rewardsPerLevel_.accumulated = (rewardsPerLevel_.accumulated + unaccountedTime * rewardsPerLevel_.rate / rewardsPerLevel_.totalLevel).toUint96();
            }
            rewardsPerLevel_.lastUpdated = end;
        }
        
        if (increase) {
            rewardsPerLevel_.totalLevel += level;
        }
        else {
            rewardsPerLevel_.totalLevel -= level;
        }
        rewardsPerlevel = rewardsPerLevel_;
    }

    function _updateUserRewards(address user, uint32 level, bool increase) internal virtual returns (uint96) {

        UserRewards memory userRewards_ = rewards[user];
        RewardsPerlevel memory rewardsPerLevel_ = rewardsPerlevel;
        
        userRewards_.accumulated = userRewards_.accumulated + userRewards_.stakedLevel * (rewardsPerLevel_.accumulated - userRewards_.checkpoint);
        userRewards_.checkpoint = rewardsPerLevel_.accumulated;    
        
        if (level != 0) {
            if (increase) {
                userRewards_.stakedLevel += level;
            }
            else {
                userRewards_.stakedLevel -= level;
            }
        }
        rewards[user] = userRewards_;

        return userRewards_.accumulated;
    }

    function _ensureEOAorERC721Receiver(address to) internal virtual {

        uint32 size;
        assembly {
            size := extcodesize(to)
        }
        if (size > 0) {
            try IERC721ReceiverUpgradeable(to).onERC721Received(address(this), address(this), 1, "") returns (bytes4 retval) {
                require(retval == IERC721ReceiverUpgradeable.onERC721Received.selector, "ET"); // ET: neither EOA nor ERC721Receiver
            } catch (bytes memory) {
                revert("ET"); // ET: neither EOA nor ERC721Receiver
            }
        }
    }


    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external view override returns (bytes4) {

        from; tokenId; data; // supress solidity warnings
        if (operator == address(this)) {
            return this.onERC721Received.selector;
        }
        else {
            return 0x00000000;
        }
    }
}