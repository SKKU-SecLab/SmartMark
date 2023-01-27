
pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

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


abstract contract Pausable is Context {
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

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}// MIT

pragma solidity ^0.8.0;


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
}//Contract based on https://docs.openzeppelin.com/contracts/3.x/erc721
pragma solidity ^0.8.9;


interface ICryptoBees {

    struct Token {
        uint8 _type;
        uint8 color;
        uint8 eyes;
        uint8 mouth;
        uint8 nose;
        uint8 hair;
        uint8 accessory;
        uint8 feelers;
        uint8 strength;
        uint48 lastAttackTimestamp;
        uint48 cooldownTillTimestamp;
    }

    function getMinted() external view returns (uint256 m);


    function increaseTokensPot(address _owner, uint256 amount) external;


    function updateTokensLastAttack(
        uint256 tokenId,
        uint48 timestamp,
        uint48 till
    ) external;


    function mint(
        address addr,
        uint256 tokenId,
        bool stake
    ) external;


    function setPaused(bool _paused) external;


    function getTokenData(uint256 tokenId) external view returns (Token memory token);


    function getOwnerOf(uint256 tokenId) external view returns (address);


    function doesExist(uint256 tokenId) external view returns (bool exists);


    function performTransferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external;


    function performSafeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

}// MIT LICENSE

pragma solidity ^0.8.9;

interface IHoney {

    function mint(address to, uint256 amount) external;


    function mintGiveaway(address[] calldata addresses, uint256 amount) external;


    function burn(address from, uint256 amount) external;


    function disableGiveaway() external;


    function addController(address controller) external;


    function removeController(address controller) external;

}// MIT LICENSE

pragma solidity ^0.8.9;

interface IHive {

    struct Bee {
        address owner;
        uint32 tokenId;
        uint48 since;
        uint8 index;
    }

    struct BeeHive {
        uint32 startedTimestamp;
        uint32 lastCollectedHoneyTimestamp;
        uint32 hiveProtectionBears;
        uint32 lastStolenHoneyTimestamp;
        uint32 collectionAmount;
        uint32 collectionAmountPerBee;
        uint8 successfulAttacks;
        uint8 totalAttacks;
        mapping(uint256 => Bee) bees;
        uint16[] beesArray;
    }

    function addManyToHive(
        address account,
        uint16[] calldata tokenIds,
        uint16[] calldata hiveIds
    ) external;


    function claimManyFromHive(
        uint16[] calldata tokenIds,
        uint16[] calldata hiveIds,
        uint16[] calldata newHiveIds
    ) external;


    function addToWaitingRoom(address account, uint256 tokenId) external;


    function removeFromWaitingRoom(uint256 tokenId, uint256 hiveId) external;


    function setRescueEnabled(bool _enabled) external;


    function setPaused(bool _paused) external;


    function setBeeSince(
        uint256 hiveId,
        uint256 tokenId,
        uint48 since
    ) external;


    function calculateBeeOwed(uint256 hiveId, uint256 tokenId) external view returns (uint256 owed);


    function incSuccessfulAttacks(uint256 hiveId) external;


    function incTotalAttacks(uint256 hiveId) external;


    function setBearAttackData(
        uint256 hiveId,
        uint32 timestamp,
        uint32 protection
    ) external;


    function setKeeperAttackData(
        uint256 hiveId,
        uint32 timestamp,
        uint32 collected,
        uint32 collectedPerBee
    ) external;


    function getLastStolenHoneyTimestamp(uint256 hiveId) external view returns (uint256 lastStolenHoneyTimestamp);


    function getHiveProtectionBears(uint256 hiveId) external view returns (uint256 hiveProtectionBears);


    function isHiveProtectedFromKeepers(uint256 hiveId) external view returns (bool);


    function getHiveOccupancy(uint256 hiveId) external view returns (uint256 occupancy);


    function getBeeSinceTimestamp(uint256 hiveId, uint256 tokenId) external view returns (uint256 since);


    function getBeeTokenId(uint256 hiveId, uint256 index) external view returns (uint256 tokenId);


    function getHiveAge(uint256 hiveId) external view returns (uint32);


    function getHiveSuccessfulAttacks(uint256 hiveId) external view returns (uint8);


    function getWaitingRoomOwner(uint256 tokenId) external view returns (address);


    function resetHive(uint256 hiveId) external;

}// MIT LICENSE

pragma solidity ^0.8.9;

interface IAttack {

    struct Settings {
        uint8 bearChance;
        uint8 beekeeperMultiplier;
        uint24 hiveProtectionBear;
        uint24 hiveProtectionKeeper;
        uint24 bearCooldownBase;
        uint24 bearCooldownPerHiveDay;
        uint24 beekeeperCooldownBase;
        uint24 beekeeperCooldownPerHiveDay;
        uint8 attacksToRestart;
    }
    struct UnresolvedAttack {
        uint24 tokenId;
        uint48 nonce;
        uint64 block;
        uint32 howMuch;
    }
}// MIT LICENSE

pragma solidity ^0.8.9;


contract Hive is IHive, Ownable, IERC721Receiver, Pausable {

    using Strings for uint256;
    using Strings for uint48;
    using Strings for uint32;
    using Strings for uint16;
    using Strings for uint8;

    event AddedToHive(address indexed owner, uint256 indexed hiveId, uint256 tokenId, uint256 timestamp);
    event AddedToWaitingRoom(address indexed owner, uint256 indexed tokenId, uint256 timestamp);
    event RemovedFromWaitingRoom(address indexed owner, uint256 indexed tokenId, uint256 timestamp);
    event TokenClaimed(address indexed owner, uint256 indexed tokenId, uint256 earned);
    event HiveRestarted(uint256 indexed hiveId);
    event HiveFull(address indexed owner, uint256 hiveId, uint256 tokenId, uint256 timestamp);

    ICryptoBees beesContract;
    IAttack attackContract;

    mapping(uint256 => BeeHive) public hives;

    mapping(uint256 => Bee) public waitingRoom;

    uint256 public constant MINIMUM_TO_EXIT = 1 days;

    uint256 public totalBeesStaked;
    uint256 public availableHive;
    uint256 public extraHives = 2;
    bool public rescueEnabled = false;

    constructor() {}

    function setContracts(address _BEES, address _ATTACK) external onlyOwner {

        beesContract = ICryptoBees(_BEES);
        attackContract = IAttack(_ATTACK);
    }


    uint16[] accDaily = [400, 480, 576, 690, 830, 1000, 1200];
    uint16[] accCombined = [400, 880, 1456, 2146, 2976, 3976, 5176];

    function calculateAccumulation(uint256 start, uint256 end) internal view returns (uint256 owed) {

        uint256 d = (end - start) / 1 days;
        if (d > 6) d = 6;
        uint256 left = end - start;
        if (left > d * 1 days) left = left - (d * 1 days);
        else left = 0;
        if (d > 0) owed = accCombined[d - 1];
        owed += ((left * accDaily[d]) / 1 days);
    }

    function calculateBeeOwed(uint256 hiveId, uint256 tokenId) public view returns (uint256 owed) {

        uint256 since = hives[hiveId].bees[tokenId].since;
        owed = calculateAccumulation(hives[hiveId].startedTimestamp, block.timestamp);
        if (since > hives[hiveId].startedTimestamp) {
            owed -= calculateAccumulation(hives[hiveId].startedTimestamp, since);
        }
        if (since < hives[hiveId].lastCollectedHoneyTimestamp && hives[hiveId].startedTimestamp < hives[hiveId].lastCollectedHoneyTimestamp) {
            if (owed > hives[hiveId].collectionAmountPerBee) owed -= hives[hiveId].collectionAmountPerBee;
            else owed = 0;
        }
    }

    function addToWaitingRoom(address account, uint256 tokenId) external whenNotPaused {

        require(_msgSender() == address(beesContract), "HIVE:ADD TO WAITING ROOM:ONLY BEES CONTRACT");
        waitingRoom[tokenId] = Bee({owner: account, tokenId: uint16(tokenId), index: 0, since: uint48(block.timestamp)});
        emit AddedToWaitingRoom(account, tokenId, block.timestamp);
    }

    function removeFromWaitingRoom(uint256 tokenId, uint256 hiveId) external whenNotPaused {

        Bee memory token = waitingRoom[tokenId];
        if (token.tokenId > 0 && beesContract.getTokenData(token.tokenId)._type == 1) {
            if (availableHive != 0 && hiveId == 0 && hives[availableHive].beesArray.length < 100) hiveId = availableHive;
            if (hiveId == 0) {
                uint256 totalHives = ((beesContract.getMinted() / 100) + extraHives);
                for (uint256 i = 1; i <= totalHives; i++) {
                    if (hives[i].beesArray.length < 100) {
                        hiveId = i;
                        availableHive = i;
                        break;
                    }
                }
            }
            _addBeeToHive(token.owner, tokenId, hiveId);
            delete waitingRoom[tokenId];
        } else if (token.tokenId > 0 && beesContract.getTokenData(token.tokenId)._type > 1) {
            beesContract.performSafeTransferFrom(address(this), _msgSender(), tokenId); // send the bear/beekeeper back
            delete waitingRoom[tokenId];
            emit TokenClaimed(_msgSender(), tokenId, 0);
        } else if (token.tokenId > 0) {
            require(_msgSender() == owner() || token.owner == _msgSender(), "CANNOT REMOVE UNREVEALED TOKEN");
            beesContract.performSafeTransferFrom(address(this), _msgSender(), tokenId); // send the bear/beekeeper back
            delete waitingRoom[tokenId];
            emit TokenClaimed(_msgSender(), tokenId, 0);
        }
    }

    function addManyToHive(
        address account,
        uint16[] calldata tokenIds,
        uint16[] calldata hiveIds
    ) external whenNotPaused {

        require(account == _msgSender() || _msgSender() == address(beesContract), "DONT GIVE YOUR TOKENS AWAY");
        require(tokenIds.length == hiveIds.length, "THE ARGUMENTS LENGTHS DO NOT MATCH");
        uint256 totalHives = ((beesContract.getMinted() / 100) + extraHives);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(beesContract.getTokenData(tokenIds[i])._type == 1, "TOKEN MUST BE A BEE");

            require(totalHives >= hiveIds[i], "HIVE NOT AVAILABLE");

            if (_msgSender() != address(beesContract)) {
                require(beesContract.getOwnerOf(tokenIds[i]) == _msgSender(), "AINT YO TOKEN");
                beesContract.performTransferFrom(_msgSender(), address(this), tokenIds[i]);
            }
            _addBeeToHive(account, tokenIds[i], hiveIds[i]);
        }
    }

    function _addBeeToHive(
        address account,
        uint256 tokenId,
        uint256 hiveId
    ) internal {

        uint256 index = hives[hiveId].beesArray.length;
        require(index < 100, "HIVE IS FULL");
        require(hiveId > 0, "HIVE 0 NOT AVAILABLE");
        if (hives[hiveId].startedTimestamp == 0) hives[hiveId].startedTimestamp = uint32(block.timestamp);
        hives[hiveId].bees[tokenId] = Bee({owner: account, tokenId: uint16(tokenId), index: uint8(index), since: uint48(block.timestamp)});
        hives[hiveId].beesArray.push(uint16(tokenId));
        if (hives[hiveId].beesArray.length < 90 && availableHive != hiveId) {
            availableHive = hiveId;
        }
        totalBeesStaked += 1;
        emit AddedToHive(account, hiveId, tokenId, block.timestamp);
    }


    function claimManyFromHive(
        uint16[] calldata tokenIds,
        uint16[] calldata hiveIds,
        uint16[] calldata newHiveIds
    ) external whenNotPaused {

        require(tokenIds.length == hiveIds.length && tokenIds.length == newHiveIds.length, "THE ARGUMENTS LENGTHS DO NOT MATCH");
        for (uint256 i = 0; i < tokenIds.length; i++) {
            _claimBeeFromHive(tokenIds[i], hiveIds[i], newHiveIds[i]);
        }
    }

    function _claimBeeFromHive(
        uint256 tokenId,
        uint256 hiveId,
        uint256 newHiveId
    ) internal returns (uint256 owed) {

        Bee memory bee = hives[hiveId].bees[tokenId];
        require(bee.owner == _msgSender(), "YOU ARE NOT THE OWNER");
        if (!rescueEnabled) {
            require(block.timestamp - bee.since > MINIMUM_TO_EXIT, "YOU NEED MORE HONEY TO GET OUT OF THE HIVE");
        }
        owed = calculateBeeOwed(hiveId, tokenId);
        beesContract.increaseTokensPot(bee.owner, owed);
        if (newHiveId == 0) {
            beesContract.performSafeTransferFrom(address(this), _msgSender(), tokenId); // send the bee back
            uint256 index = hives[hiveId].bees[tokenId].index;

            if (index != hives[hiveId].beesArray.length - 1) {
                uint256 lastIndex = hives[hiveId].beesArray.length - 1;
                uint256 lastTokenIndex = hives[hiveId].beesArray[lastIndex];
                hives[hiveId].beesArray[index] = uint16(lastTokenIndex);
                hives[hiveId].bees[lastTokenIndex].index = uint8(index);
            }
            hives[hiveId].beesArray.pop();
            delete hives[hiveId].bees[tokenId];

            totalBeesStaked -= 1;
            emit TokenClaimed(_msgSender(), tokenId, owed);
        } else if (hives[newHiveId].beesArray.length < 100) {
            uint256 index = hives[hiveId].bees[tokenId].index;
            if (index != hives[hiveId].beesArray.length - 1) {
                uint256 lastIndex = hives[hiveId].beesArray.length - 1;
                uint256 lastTokenIndex = hives[hiveId].beesArray[lastIndex];
                hives[hiveId].beesArray[index] = uint16(lastTokenIndex);
                hives[hiveId].bees[lastTokenIndex].index = uint8(index);
            }
            hives[hiveId].beesArray.pop();
            delete hives[hiveId].bees[tokenId];

            uint256 newIndex = hives[newHiveId].beesArray.length;
            hives[newHiveId].bees[tokenId] = Bee({owner: _msgSender(), tokenId: uint16(tokenId), index: uint8(newIndex), since: uint48(block.timestamp)}); // reset stake
            if (hives[newHiveId].startedTimestamp == 0) hives[newHiveId].startedTimestamp = uint32(block.timestamp);
            hives[newHiveId].beesArray.push(uint16(tokenId));
            if (newIndex < 90 && availableHive != newHiveId) {
                availableHive = newHiveId;
            }
            emit AddedToHive(_msgSender(), newHiveId, tokenId, block.timestamp);
        } else {
            emit HiveFull(_msgSender(), newHiveId, tokenId, block.timestamp);
        }
    }

    function getLastStolenHoneyTimestamp(uint256 hiveId) external view returns (uint256 lastStolenHoneyTimestamp) {

        lastStolenHoneyTimestamp = hives[hiveId].lastStolenHoneyTimestamp;
    }

    function getHiveProtectionBears(uint256 hiveId) external view returns (uint256 hiveProtectionBears) {

        hiveProtectionBears = hives[hiveId].hiveProtectionBears;
    }

    function isHiveProtectedFromKeepers(uint256 hiveId) external view returns (bool) {

        return hives[hiveId].collectionAmount > 0 ? true : false;
    }

    function getHiveOccupancy(uint256 hiveId) external view returns (uint256 occupancy) {

        occupancy = hives[hiveId].beesArray.length;
    }

    function getBeeSinceTimestamp(uint256 hiveId, uint256 tokenId) external view returns (uint256 since) {

        since = hives[hiveId].bees[tokenId].since;
    }

    function getBeeTokenId(uint256 hiveId, uint256 index) external view returns (uint256 tokenId) {

        tokenId = hives[hiveId].beesArray[index];
    }

    function setBeeSince(
        uint256 hiveId,
        uint256 tokenId,
        uint48 since
    ) external {

        require(_msgSender() == address(attackContract), "ONLY ATTACK CONTRACT CAN CALL THIS");
        hives[hiveId].bees[tokenId].since = since;
    }

    function incSuccessfulAttacks(uint256 hiveId) external {

        require(_msgSender() == address(attackContract), "ONLY ATTACK CONTRACT CAN CALL THIS");
        hives[hiveId].successfulAttacks += 1;
    }

    function incTotalAttacks(uint256 hiveId) external {

        require(_msgSender() == address(attackContract), "ONLY ATTACK CONTRACT CAN CALL THIS");
        hives[hiveId].totalAttacks += 1;
    }

    function setBearAttackData(
        uint256 hiveId,
        uint32 timestamp,
        uint32 protection
    ) external {

        require(_msgSender() == address(attackContract), "ONLY ATTACK CONTRACT CAN CALL THIS");
        hives[hiveId].lastStolenHoneyTimestamp = timestamp;
        hives[hiveId].hiveProtectionBears = protection;
    }

    function setKeeperAttackData(
        uint256 hiveId,
        uint32 timestamp,
        uint32 collected,
        uint32 collectedPerBee
    ) external {

        require(_msgSender() == address(attackContract), "ONLY ATTACK CONTRACT CAN CALL THIS");
        hives[hiveId].lastCollectedHoneyTimestamp = timestamp;
        hives[hiveId].collectionAmount = collected;
        hives[hiveId].collectionAmountPerBee = collectedPerBee;
    }

    function resetHive(uint256 hiveId) external {

        require(_msgSender() == address(attackContract) || _msgSender() == owner(), "ONLY ATTACK CONTRACT CAN CALL THIS");
        hives[hiveId].startedTimestamp = uint32(block.timestamp);
        hives[hiveId].lastCollectedHoneyTimestamp = 0;
        hives[hiveId].hiveProtectionBears = 0;
        hives[hiveId].lastStolenHoneyTimestamp = 0;
        hives[hiveId].collectionAmount = 0;
        hives[hiveId].collectionAmountPerBee = 0;
        hives[hiveId].successfulAttacks = 0;
        hives[hiveId].totalAttacks = 0;
        emit HiveRestarted(hiveId);
    }


    function setRescueEnabled(bool _enabled) external onlyOwner {

        rescueEnabled = _enabled;
    }

    function setExtraHives(uint256 _extra) external onlyOwner {

        extraHives = _extra;
    }

    function setPaused(bool _paused) external onlyOwner {

        if (_paused) _pause();
        else _unpause();
    }

    function setAvailableHive(uint256 _hiveId) external onlyOwner {

        availableHive = _hiveId;
    }


    function getInfoOnBee(uint256 tokenId, uint256 hiveId) public view returns (Bee memory) {

        return hives[hiveId].bees[tokenId];
    }

    function getHiveAge(uint256 hiveId) external view returns (uint32) {

        return hives[hiveId].startedTimestamp;
    }

    function getHiveSuccessfulAttacks(uint256 hiveId) external view returns (uint8) {

        return hives[hiveId].successfulAttacks;
    }

    function getWaitingRoomOwner(uint256 tokenId) external view returns (address) {

        return waitingRoom[tokenId].owner;
    }

    function getInfoOnHive(uint256 hiveId) public view returns (string memory) {

        return
            string(
                abi.encodePacked(
                    uint32(hives[hiveId].startedTimestamp).toString(),
                    ",",
                    uint32(hives[hiveId].lastCollectedHoneyTimestamp).toString(),
                    ",",
                    uint32(hives[hiveId].lastStolenHoneyTimestamp).toString(),
                    ",",
                    uint32(hives[hiveId].hiveProtectionBears).toString(),
                    ",",
                    uint32(hives[hiveId].collectionAmount).toString(),
                    ",",
                    uint16(hives[hiveId].beesArray.length).toString(),
                    ",",
                    uint8(hives[hiveId].successfulAttacks).toString(),
                    ",",
                    uint8(hives[hiveId].totalAttacks).toString()
                )
            );
    }

    function getInfoOnHives(uint256 _start, uint256 _to) public view returns (string memory) {

        string memory result;
        uint256 minted = beesContract.getMinted();
        if (minted == 0) minted = 1;
        uint256 to = _to > 0 ? _to : ((minted / 100) + extraHives);
        uint256 start = _start > 0 ? _start : 1;
        for (uint256 i = start; i <= to; i++) {
            result = string(abi.encodePacked(result, uint16(i).toString(), ":", getInfoOnHive(i), ";"));
        }
        return result;
    }

    function onERC721Received(
        address,
        address from,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {

        require(from == address(0x0), "Cannot send tokens to Hive directly");
        return IERC721Receiver.onERC721Received.selector;
    }
}