
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


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
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
}//MIT
pragma solidity ^0.8.0;

interface IEarlyBirdRegistry {

    function registerProject(
        bool open,
        uint256 endRegistration,
        uint256 maxRegistration
    ) external returns (uint256 projectId);


    function exists(uint256 projectId) external view returns (bool);


    function listRegistrations(
        uint256 projectId,
        uint256 offset,
        uint256 limit
    ) external view returns (address[] memory list);


    function registeredCount(uint256 projectId) external view returns (uint256);


    function isRegistered(address check, uint256 projectId)
        external
        view
        returns (bool);


    function registerBatchTo(uint256 projectId, address[] memory birds)
        external;

}//MIT
pragma solidity ^0.8.0;


interface IVariety is IERC721 {

    function plant(address to, bytes32[] memory seeds)
        external
        returns (uint256);


    function getTokenSeed(uint256 tokenId) external view returns (bytes32);


    function requestSeedChange(uint256 tokenId) external;


    function changeSeedAfterRequest(uint256 tokenId) external;

}//MIT
pragma solidity ^0.8.0;




contract Sower is Ownable, ReentrancyGuard {

    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;

    event Collected(
        address indexed operator,
        address indexed variety,
        uint256 indexed count,
        uint256 value
    );

    event EarlyBirdSessionAdded(uint256 sessionId, uint256 projectId);
    event EarlyBirdSessionRemoved(uint256 sessionId, uint256 projectId);

    event VarietyAdded(address variety);
    event VarietyChanged(address variety);
    event VarietyEmpty(address variety);

    event DonationRecipientAdded(address recipient);
    event DonationRecipientRemoved(address recipient);

    struct VarietyData {
        uint8 maxPerCollect; // how many can be collected at once. 0 == no limit
        bool active; // if Variety is active or not
        bool curated; // curated Varieties can only be minted by Variety creator
        address location; // address of the Variety contract
        address creator; // creator of the variety (in case the contract opens to more creators)
        uint256 price; // price of collecting
        uint256 available; // how many are available
        uint256 reserve; // how many are reserve for creator
        uint256 earlyBirdUntil; // earlyBird limit timestamp
        uint256 earlyBirdSessionId; // earlyBirdSessionId
    }

    address public mainDonation = 0x37133cda1941449cde7128f0C964C228F94844a8;

    mapping(address => VarietyData) public varieties;

    EnumerableSet.AddressSet internal knownVarieties;

    EnumerableSet.AddressSet internal donations;

    bytes32 public lastSeed;

    mapping(uint256 => mapping(address => bool)) internal _earlyBirdsConsumed;

    address public earlyBirdRegistry;

    mapping(uint256 => EnumerableSet.UintSet) internal earlyBirdSessions;

    constructor() {
        _addDonationRecipient(0xde21F729137C5Af1b01d73aF1dC21eFfa2B8a0d6);

        _addDonationRecipient(0xCCa88b952976DA313Fb928111f2D5c390eE0D723);

        _addDonationRecipient(0xF0D7a8198D75e10517f035CF11b928e9E2aB20f4);
    }

    function plant(uint256 count, address variety)
        external
        payable
        nonReentrant
    {

        require(count > 0, '!count');

        VarietyData storage varietyData = _getVariety(variety);

        require(varietyData.curated == false, "Can't plant this Variety.");

        require(varietyData.active == true, 'Variety paused or out of seeds.');

        if (varietyData.earlyBirdUntil >= block.timestamp) {
            require(
                isUserInEarlyBirdSession(
                    msg.sender,
                    varietyData.earlyBirdSessionId
                ),
                'Not registered for EarlyBirds'
            );

            require(
                _earlyBirdsConsumed[varietyData.earlyBirdSessionId][
                    msg.sender
                ] == false,
                'Already used your EarlyBird'
            );

            _earlyBirdsConsumed[varietyData.earlyBirdSessionId][
                msg.sender
            ] = true;

            require(count == 1, 'Early bird can only grab one');
        }

        require(
            (varietyData.available - varietyData.reserve) >= count &&
                (varietyData.maxPerCollect == 0 ||
                    uint256(varietyData.maxPerCollect) >= count),
            'Too many requested.'
        );

        address operator = msg.sender;

        require(msg.value == varietyData.price * count, 'Value error.');

        _plant(varietyData, count, operator);
    }

    function plantFromReserve(
        uint256 count,
        address variety,
        address recipient
    ) external {

        require(count > 0, '!count');

        VarietyData storage varietyData = _getVariety(variety);

        require(varietyData.curated == false, "Can't plant this Variety.");

        require(
            msg.sender == varietyData.creator ||
                (varietyData.creator == address(0) && msg.sender == owner()),
            'Not Variety creator.'
        );

        require(
            varietyData.reserve >= count && varietyData.available >= count,
            'Not enough reserve.'
        );

        varietyData.reserve -= count;

        if (recipient == address(0)) {
            recipient = msg.sender;
        }

        _plant(varietyData, count, recipient);
    }

    function plantFromCurated(
        address variety,
        address recipient,
        bytes32[] memory seeds
    ) external {

        require(seeds.length > 0, '!count');

        VarietyData storage varietyData = _getVariety(variety);

        require(varietyData.curated == true, 'Variety not curated.');

        require(
            msg.sender == varietyData.creator ||
                (varietyData.creator == address(0) && msg.sender == owner()),
            'Not Variety creator.'
        );

        if (recipient == address(0)) {
            recipient = msg.sender;
        }

        _plantSeeds(varietyData, recipient, seeds);
    }

    function listVarieties() external view returns (VarietyData[] memory list) {

        uint256 count = knownVarieties.length();
        list = new VarietyData[](count);
        for (uint256 i; i < count; i++) {
            list[i] = varieties[knownVarieties.at(i)];
        }
    }

    function addVariety(
        address newVariety,
        uint256 price,
        uint8 maxPerCollect,
        bool active,
        address creator,
        uint256 available,
        uint256 reserve,
        bool curated
    ) external onlyOwner {

        require(
            !knownVarieties.contains(newVariety),
            'Variety already exists.'
        );
        knownVarieties.add(newVariety);

        varieties[newVariety] = VarietyData({
            maxPerCollect: maxPerCollect,
            price: price,
            active: active,
            creator: creator,
            location: newVariety,
            available: available,
            reserve: reserve,
            curated: curated,
            earlyBirdUntil: 0,
            earlyBirdSessionId: 0
        });

        emit VarietyAdded(newVariety);
    }

    function setActive(address variety, bool isActive) public onlyOwner {

        VarietyData storage varietyData = _getVariety(variety);
        require(
            !isActive || varietyData.available > 0,
            "Can't activate empty variety."
        );
        varietyData.active = isActive;
        emit VarietyChanged(variety);
    }

    function setMaxPerCollect(address variety, uint8 maxPerCollect)
        external
        onlyOwner
    {

        VarietyData storage varietyData = _getVariety(variety);
        varietyData.maxPerCollect = maxPerCollect;
        emit VarietyChanged(variety);
    }

    function activateEarlyBird(
        address[] memory varieties_,
        uint256 earlyBirdDuration,
        uint256 earlyBirdSessionId,
        bool activateVariety
    ) external onlyOwner {

        require(
            earlyBirdSessions[earlyBirdSessionId].length() > 0,
            'Session id empty'
        );

        for (uint256 i; i < varieties_.length; i++) {
            VarietyData storage varietyData = _getVariety(varieties_[i]);
            varietyData.earlyBirdUntil = block.timestamp + earlyBirdDuration;
            varietyData.earlyBirdSessionId = earlyBirdSessionId;

            if (activateVariety) {
                setActive(varieties_[i], true);
            } else {
                emit VarietyChanged(varieties_[i]);
            }
        }
    }

    function setEarlyBirdRegistry(address earlyBirdRegistry_)
        external
        onlyOwner
    {

        require(earlyBirdRegistry_ != address(0), 'Wrong address.');
        earlyBirdRegistry = earlyBirdRegistry_;
    }

    function addEarlyBirdProjectToSession(
        uint256 sessionId,
        uint256[] memory projectIds
    ) external onlyOwner {

        require(sessionId > 0, "Session can't be 0");
        for (uint256 i; i < projectIds.length; i++) {
            require(
                IEarlyBirdRegistry(earlyBirdRegistry).exists(projectIds[i]),
                'Unknown early bird project'
            );
            earlyBirdSessions[sessionId].add(projectIds[i]);
            emit EarlyBirdSessionAdded(sessionId, projectIds[i]);
        }
    }

    function removeEarlyBirdProjectFromSession(
        uint256 sessionId,
        uint256[] memory projectIds
    ) external onlyOwner {

        require(sessionId > 0, "Session can't be 0");

        for (uint256 i; i < projectIds.length; i++) {
            earlyBirdSessions[sessionId].remove(projectIds[i]);
            emit EarlyBirdSessionRemoved(sessionId, projectIds[i]);
        }
    }

    function isUserInEarlyBirdSession(address user, uint256 sessionId)
        public
        view
        returns (bool)
    {

        EnumerableSet.UintSet storage session = earlyBirdSessions[sessionId];
        uint256 count = session.length();

        for (uint256 i; i < count; i++) {
            if (
                IEarlyBirdRegistry(earlyBirdRegistry).isRegistered(
                    user,
                    session.at(i)
                )
            ) {
                return true;
            }
        }

        return false;
    }

    function listDonations() external view returns (address[] memory list) {

        uint256 count = donations.length();
        list = new address[](count);
        for (uint256 i; i < count; i++) {
            list[i] = donations.at(i);
        }
    }

    function addDonationRecipient(address recipient) external onlyOwner {

        _addDonationRecipient(recipient);
    }

    function removeDonationRecipient(address recipient) external onlyOwner {

        _removeDonationRecipient(recipient);
    }

    function setNewMainDonation(address newMainDonation) external onlyOwner {

        mainDonation = newMainDonation;
    }

    function updateTokenSeed(address variety, uint256 tokenId)
        external
        onlyOwner
    {

        require(knownVarieties.contains(variety), 'Unknown variety.');
        IVariety(variety).changeSeedAfterRequest(tokenId);
    }

    function withdraw() external onlyOwner {

        require(address(this).balance > 0, "I don't think so.");

        uint256 count = donations.length();

        require(
            mainDonation != address(0) && count > 0,
            'You have to give in order to get.'
        );

        bool success;

        uint256 ten = address(this).balance / 10;

        (success, ) = mainDonation.call{value: ten}('');
        require(success, '!success');

        uint256 parts = ten / count;
        for (uint256 i; i < count; i++) {
            (success, ) = donations.at(i).call{value: parts}('');
            require(success, '!success');
        }

        (success, ) = msg.sender.call{value: address(this).balance}('');
        require(success, '!success');
    }

    receive() external payable {}

    function _plant(
        VarietyData storage varietyData,
        uint256 count,
        address operator
    ) internal {

        bytes32 seed = lastSeed;
        bytes32[] memory seeds = new bytes32[](count);
        bytes32 blockHash = blockhash(block.number - 1);
        uint256 timestamp = block.timestamp;

        for (uint256 i; i < count; i++) {
            seed = _nextSeed(seed, timestamp, operator, blockHash);
            seeds[i] = seed;
        }

        lastSeed = seed;

        _plantSeeds(varietyData, operator, seeds);
    }

    function _plantSeeds(
        VarietyData storage varietyData,
        address collector,
        bytes32[] memory seeds
    ) internal {

        IVariety(varietyData.location).plant(collector, seeds);
        uint256 count = seeds.length;

        varietyData.available -= count;
        if (varietyData.available == 0) {
            varietyData.active = false;
            emit VarietyEmpty(varietyData.location);
        }

        emit Collected(collector, varietyData.location, count, msg.value);

        if (
            varietyData.creator != address(0) &&
            msg.value > 0 &&
            varietyData.creator != owner()
        ) {
            (bool success, ) = varietyData.creator.call{value: msg.value}('');
            require(success, '!success');
        }
    }

    function _nextSeed(
        bytes32 currentSeed,
        uint256 timestamp,
        address operator,
        bytes32 blockHash
    ) internal view returns (bytes32) {

        return
            keccak256(
                abi.encodePacked(
                    currentSeed,
                    timestamp,
                    operator,
                    blockHash,
                    block.coinbase,
                    block.difficulty,
                    tx.gasprice
                )
            );
    }

    function _getVariety(address variety)
        internal
        view
        returns (VarietyData storage)
    {

        require(knownVarieties.contains(variety), 'Unknown variety.');
        return varieties[variety];
    }

    function _addDonationRecipient(address recipient) internal {

        donations.add(recipient);
        emit DonationRecipientAdded(recipient);
    }

    function _removeDonationRecipient(address recipient) internal {

        donations.remove(recipient);
        emit DonationRecipientRemoved(recipient);
    }
}