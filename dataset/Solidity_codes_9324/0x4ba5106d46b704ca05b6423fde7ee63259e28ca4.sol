
pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

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


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC20Burnable is Context, ERC20 {
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        unchecked {
            _approve(account, _msgSender(), currentAllowance - amount);
        }
        _burn(account, amount);
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


interface IERC721Enumerable is IERC721 {
    function totalSupply() external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    function tokenByIndex(uint256 index) external view returns (uint256);
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

pragma solidity ^0.8.7;

interface RewardLike {
    function mintMany(address to, uint256 amount) external;
}

interface IDNAChip is RewardLike {
    function tokenIdToTraits(uint256 tokenId) external view returns (uint256);

    function isEvolutionPod(uint256 tokenId) external view returns (bool);

    function breedingIdToEvolutionPod(uint256 tokenId) external view returns (uint256);
}

interface IDescriptor {
    function tokenURI(uint256 _tokenId) external view returns (string memory);

    function tokenBreedingURI(uint256 _tokenId, uint256 _breedingId) external view returns (string memory);
}

interface IEvolutionTraits {
    function getDNAChipSVG(uint256 base) external view returns (string memory);

    function getEvolutionPodImageTag(uint256 base) external view returns (string memory);

    function getTraitsImageTags(uint8[8] memory traits) external view returns (string memory);

    function getMetadata(uint8[8] memory traits) external view returns (string memory);
}

interface IERC721Like {
    function transferFrom(
        address from,
        address to,
        uint256 id
    ) external;

    function transfer(address to, uint256 id) external;

    function ownerOf(uint256 id) external returns (address owner);

    function mint(address to, uint256 tokenid) external;
}// MIT

pragma solidity ^0.8.7;


contract Wormhole is Ownable {
    using EnumerableSet for EnumerableSet.UintSet;
    struct SalvageEvent {
        uint64 id;
        uint64 startBlock;
        uint64 endBlock;
        uint64 rngSeed;
        uint16 genesisCount;
        uint16 babiesCount;
    }

    address public genesisAddress;
    address public babiesAddress;
    address public cheethAddress;
    address public rewardAddress;
    uint16 public genesisSalvageEventReward;
    uint16 public babiesSalvageEventReward;

    mapping(uint64 => SalvageEvent) public salvageEvents;
    mapping(address => mapping(uint256 => uint256[])) public ownerBabiesByEvent;
    mapping(address => mapping(uint256 => uint256[])) public ownerGenesisByEvent;
    mapping(uint64 => EnumerableSet.UintSet) private _salvageEventBabies;
    mapping(uint64 => EnumerableSet.UintSet) private _salvageEventGenesis;
    mapping(address => EnumerableSet.UintSet) private _unclaimedEvents;

    function joinEvent(
        uint64 id,
        uint256[] calldata babiesIds,
        uint256[] calldata genesisIds
    ) external {
        SalvageEvent storage salvageEvent = salvageEvents[id];
        require(block.number < salvageEvent.startBlock, "already started");
        uint256 totalCheeth = (babiesIds.length + genesisIds.length) * 250;
        ERC20Burnable(cheethAddress).transferFrom(msg.sender, address(this), totalCheeth * 1 ether);

        salvageEvent.babiesCount += uint16(babiesIds.length);
        salvageEvent.genesisCount += uint16(genesisIds.length);
        _unclaimedEvents[msg.sender].add(id);

        for (uint256 index = 0; index < babiesIds.length; index++) {
            uint256 mouseId = babiesIds[index];
            require(_ownerOfToken(mouseId, babiesAddress) == msg.sender, "not allowed");
            require(!_salvageEventBabies[id].contains(mouseId), "already in event");
            _salvageEventBabies[id].add(mouseId);
            ownerBabiesByEvent[msg.sender][id].push(mouseId);
        }

        for (uint256 index = 0; index < genesisIds.length; index++) {
            uint256 mouseId = genesisIds[index];
            require(_ownerOfToken(mouseId, genesisAddress) == msg.sender, "not allowed");
            require(!_salvageEventGenesis[id].contains(mouseId), "already in event");
            _salvageEventGenesis[id].add(mouseId);
            ownerGenesisByEvent[msg.sender][id].push(mouseId);
        }
    }

    function _ownerOfToken(uint256 tokenId, address tokenAddress) internal view returns (address) {
        return IERC721Enumerable(tokenAddress).ownerOf(tokenId);
    }

    function claimEventReward(uint64 id) external {
        require(!_getIsEventClaimed(id, msg.sender), "already claimed");

        uint64 eventReward = _getEventReward(id, msg.sender);
        RewardLike(rewardAddress).mintMany(msg.sender, eventReward);
        _markClaimedEvent(id, msg.sender);
    }


    function setAddresses(
        address _babiesAddress,
        address _genesisAddress,
        address _cheethAddress,
        address _rewardAddress
    ) external onlyOwner {
        babiesAddress = _babiesAddress;
        genesisAddress = _genesisAddress;
        cheethAddress = _cheethAddress;
        rewardAddress = _rewardAddress;
    }

    function setGenesisSalvageEventReward(uint16 _genesisSalvageEventReward) external onlyOwner {
        genesisSalvageEventReward = _genesisSalvageEventReward;
    }

    function setBabiesSalvageEventReward(uint16 _babiesSalvageEventReward) external onlyOwner {
        babiesSalvageEventReward = _babiesSalvageEventReward;
    }

    function registerSalvageEvent(uint64 id, uint64 startBlock) external onlyOwner {
        require(id > 0, "invalid id");
        salvageEvents[id].id = id;
        salvageEvents[id].startBlock = startBlock;
    }

    function startSalvageEvent(
        uint64 id,
        uint64 endBlock,
        uint64 rngSeed
    ) external onlyOwner {
        require(id > 0, "invalid id");
        salvageEvents[id].id = id;
        salvageEvents[id].endBlock = endBlock;
        salvageEvents[id].rngSeed = rngSeed;
    }

    function withdraw(address to) external onlyOwner {
        ERC20Burnable(cheethAddress).transfer(to, ERC20Burnable(cheethAddress).balanceOf(address(this)));
    }


    function getClaimableEventRewards(uint64 id, address wallet) external view returns (uint64) {
        if (_getIsEventClaimed(id, wallet)) {
            return 0;
        }
        return _getEventReward(id, wallet);
    }

    function getEventReward(uint64 id, address wallet) external view returns (uint64) {
        return _getEventReward(id, wallet);
    }

    function getEventMice(uint64 id, address wallet)
        external
        view
        returns (uint256[] memory genesis, uint256[] memory babies)
    {
        genesis = ownerGenesisByEvent[wallet][id];
        babies = ownerBabiesByEvent[wallet][id];
    }


    function _getEventReward(uint64 id, address wallet) internal view returns (uint64) {
        SalvageEvent memory salvageEvent = salvageEvents[id];
        require(block.number > salvageEvent.startBlock, "not started");
        require(block.number > salvageEvent.endBlock, "not finished");

        uint256[] memory eventBabies = ownerBabiesByEvent[wallet][id];
        uint256[] memory eventGenesis = ownerGenesisByEvent[wallet][id];
        uint256 baseProbability;
        uint256 additionalProbability;
        (baseProbability, additionalProbability) = _eventRewardProbabilities(id, false);

        uint16 rewardCount;
        uint256 mouseId;
        for (uint256 index = 0; index < eventBabies.length; index++) {
            mouseId = eventBabies[index];
            if (_ownerOfToken(mouseId, babiesAddress) != wallet) {
                continue;
            }
            if (_rand(salvageEvent.rngSeed, 10000 + mouseId, id, 1, wallet) < baseProbability) {
                rewardCount++;
            }
            if (_rand(salvageEvent.rngSeed, 10000 + mouseId, id, 2, wallet) < additionalProbability) {
                rewardCount++;
            }
        }

        (baseProbability, additionalProbability) = _eventRewardProbabilities(id, true);
        for (uint256 index = 0; index < eventGenesis.length; index++) {
            mouseId = eventGenesis[index];
            if (_ownerOfToken(mouseId, genesisAddress) != wallet) continue;

            if (_rand(salvageEvent.rngSeed, mouseId, id, 1, wallet) < baseProbability) {
                rewardCount++;
            }
            if (_rand(salvageEvent.rngSeed, mouseId, id, 2, wallet) < additionalProbability) {
                rewardCount++;
            }
        }
        return rewardCount;
    }

    function _eventRewardProbabilities(uint64 id, bool isGenesis) internal view returns (uint256, uint256) {
        uint256 rewardsCount = isGenesis ? genesisSalvageEventReward : babiesSalvageEventReward;
        uint16 eventSize = isGenesis ? salvageEvents[id].genesisCount : salvageEvents[id].babiesCount;
        if (eventSize == 0) return (0, 0);

        uint256 base = (rewardsCount * 100) / eventSize;
        uint256 additional;
        if (rewardsCount > eventSize) {
            uint256 remainingRewards = rewardsCount - eventSize;
            additional = (remainingRewards * 100) / eventSize;
        }
        return (base, additional);
    }

    function _getIsEventClaimed(uint64 id, address player) internal view returns (bool) {
        return !_unclaimedEvents[player].contains(id);
    }

    function _markClaimedEvent(uint64 id, address player) internal {
        _unclaimedEvents[player].remove(id);
    }

    function _rand(
        uint64 randomness,
        uint256 mouseId,
        uint64 eventId,
        uint8 nonce,
        address wallet
    ) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(wallet, randomness, mouseId, eventId, nonce))) % 100;
    }
}