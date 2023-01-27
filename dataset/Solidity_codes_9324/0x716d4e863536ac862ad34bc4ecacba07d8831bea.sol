
pragma solidity ^0.8.3;

interface IERC20 {

    function symbol() external view returns (string memory);


    function balanceOf(address account) external view returns (uint256);


    function decimals() external view returns (uint8);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}
library Storage {




    struct Address {
        address data;
    }

    function addressPtr(string memory name)
        internal
        pure
        returns (Address storage data)
    {

        bytes32 typehash = keccak256("address");
        bytes32 offset = keccak256(abi.encodePacked(typehash, name));
        assembly {
            data.slot := offset
        }
    }

    function load(Address storage input) internal view returns (address) {

        return input.data;
    }

    function set(Address storage input, address to) internal {

        input.data = to;
    }

    struct Uint256 {
        uint256 data;
    }

    function uint256Ptr(string memory name)
        internal
        pure
        returns (Uint256 storage data)
    {

        bytes32 typehash = keccak256("uint256");
        bytes32 offset = keccak256(abi.encodePacked(typehash, name));
        assembly {
            data.slot := offset
        }
    }

    function load(Uint256 storage input) internal view returns (uint256) {

        return input.data;
    }

    function set(Uint256 storage input, uint256 to) internal {

        input.data = to;
    }

    function mappingAddressToUnit256Ptr(string memory name)
        internal
        pure
        returns (mapping(address => uint256) storage data)
    {

        bytes32 typehash = keccak256("mapping(address => uint256)");
        bytes32 offset = keccak256(abi.encodePacked(typehash, name));
        assembly {
            data.slot := offset
        }
    }

    function mappingAddressToUnit256ArrayPtr(string memory name)
        internal
        pure
        returns (mapping(address => uint256[]) storage data)
    {

        bytes32 typehash = keccak256("mapping(address => uint256[])");
        bytes32 offset = keccak256(abi.encodePacked(typehash, name));
        assembly {
            data.slot := offset
        }
    }

    function getPtr(string memory typeString, string memory name)
        external
        pure
        returns (uint256)
    {

        bytes32 typehash = keccak256(abi.encodePacked(typeString));
        bytes32 offset = keccak256(abi.encodePacked(typehash, name));
        return (uint256)(offset);
    }

    struct AddressUint {
        address who;
        uint96 amount;
    }

    function mappingAddressToPackedAddressUint(string memory name)
        internal
        pure
        returns (mapping(address => AddressUint) storage data)
    {

        bytes32 typehash = keccak256("mapping(address => AddressUint)");
        bytes32 offset = keccak256(abi.encodePacked(typehash, name));
        assembly {
            data.slot := offset
        }
    }
}
library History {


    struct HistoricalBalances {
        string name;
        bytes32 cachedPointer;
    }

    function load(string memory name)
        internal
        pure
        returns (HistoricalBalances memory)
    {

        mapping(address => uint256[]) storage storageData =
            Storage.mappingAddressToUnit256ArrayPtr(name);
        bytes32 pointer;
        assembly {
            pointer := storageData.slot
        }
        return HistoricalBalances(name, pointer);
    }

    function _getMapping(bytes32 pointer)
        private
        pure
        returns (mapping(address => uint256[]) storage storageData)
    {

        assembly {
            storageData.slot := pointer
        }
    }

    function push(
        HistoricalBalances memory wrapper,
        address who,
        uint256 data
    ) internal {

        require(data <= type(uint192).max, "OoB");
        mapping(address => uint256[]) storage storageMapping =
            _getMapping(wrapper.cachedPointer);
        uint256[] storage storageData = storageMapping[who];
        uint256 blockNumber = block.number << 192;
        uint256 packedData = blockNumber | data;
        (uint256 minIndex, uint256 length) = _loadBounds(storageData);
        uint256 loadedBlockNumber = 0;
        if (length != 0) {
            (loadedBlockNumber, ) = _loadAndUnpack(storageData, length - 1);
        }
        uint256 index = length;
        if (loadedBlockNumber == block.number) {
            index = length - 1;
        }
        assembly {
            sstore(
                add(
                    add(storageData.slot, 1),
                    index
                ),
                packedData
            )
        }
        if (loadedBlockNumber != block.number) {
            _setBounds(storageData, minIndex, length + 1);
        }
    }

    function loadTop(HistoricalBalances memory wrapper, address who)
        internal
        view
        returns (uint256)
    {

        uint256[] storage userData = _getMapping(wrapper.cachedPointer)[who];
        (, uint256 length) = _loadBounds(userData);
        if (length == 0) {
            return 0;
        }
        (, uint256 storedData) = _loadAndUnpack(userData, length - 1);
        return (storedData);
    }

    function find(
        HistoricalBalances memory wrapper,
        address who,
        uint256 blocknumber
    ) internal view returns (uint256) {

        mapping(address => uint256[]) storage storageMapping =
            _getMapping(wrapper.cachedPointer);
        uint256[] storage storageData = storageMapping[who];
        (uint256 minIndex, uint256 length) = _loadBounds(storageData);
        (, uint256 loadedData) =
            _find(storageData, blocknumber, 0, minIndex, length);
        return (loadedData);
    }

    function findAndClear(
        HistoricalBalances memory wrapper,
        address who,
        uint256 blocknumber,
        uint256 staleBlock
    ) internal returns (uint256) {

        mapping(address => uint256[]) storage storageMapping =
            _getMapping(wrapper.cachedPointer);
        uint256[] storage storageData = storageMapping[who];
        (uint256 minIndex, uint256 length) = _loadBounds(storageData);
        (uint256 staleIndex, uint256 loadedData) =
            _find(storageData, blocknumber, staleBlock, minIndex, length);
        if (staleIndex > minIndex) {
            _clear(minIndex, staleIndex, storageData);
            _setBounds(storageData, staleIndex, length);
        }
        return (loadedData);
    }

    function _find(
        uint256[] storage data,
        uint256 blocknumber,
        uint256 staleBlock,
        uint256 startingMinIndex,
        uint256 length
    ) private view returns (uint256, uint256) {

        require(length != 0, "uninitialized");
        require(staleBlock <= blocknumber);
        require(startingMinIndex < length);
        uint256 maxIndex = length - 1;
        uint256 minIndex = startingMinIndex;
        uint256 staleIndex = 0;

        while (minIndex != maxIndex) {
            uint256 mid = (minIndex + maxIndex + 1) / 2;
            (uint256 pastBlock, uint256 loadedData) = _loadAndUnpack(data, mid);

            if (pastBlock == blocknumber) {
                return (staleIndex, loadedData);

            } else if (pastBlock < blocknumber) {
                if (pastBlock < staleBlock) {
                    staleIndex = mid;
                }
                minIndex = mid;

            } else {
                maxIndex = mid - 1;
            }
        }

        (uint256 _pastBlock, uint256 _loadedData) =
            _loadAndUnpack(data, minIndex);
        require(_pastBlock <= blocknumber, "Search Failure");
        return (staleIndex, _loadedData);
    }

    function _clear(
        uint256 oldMin,
        uint256 newMin,
        uint256[] storage data
    ) private {

        require(oldMin <= newMin);
        assembly {
            let dataLocation := add(data.slot, 1)
            for {
                let i := oldMin
            } lt(i, newMin) {
                i := add(i, 1)
            } {
                sstore(add(dataLocation, i), 0)
            }
        }
    }

    function _loadAndUnpack(uint256[] storage data, uint256 i)
        private
        view
        returns (uint256, uint256)
    {

        uint256 loaded;
        assembly {
            loaded := sload(add(add(data.slot, 1), i))
        }
        return (
            loaded >> 192,
            loaded &
                0x0000000000000000ffffffffffffffffffffffffffffffffffffffffffffffff
        );
    }

    function _setBounds(
        uint256[] storage data,
        uint256 minIndex,
        uint256 length
    ) private {

        require(minIndex < length);

        assembly {
            let clearedLength := and(
                length,
                0x00000000000000000000000000000000ffffffffffffffffffffffffffffffff
            )
            let minInd := shl(128, minIndex)
            let packed := or(minInd, clearedLength)
            sstore(data.slot, packed)
        }
    }

    function _loadBounds(uint256[] storage data)
        private
        view
        returns (uint256 minInd, uint256 length)
    {

        uint256 packedData;
        assembly {
            packedData := sload(data.slot)
        }
        minInd = packedData >> 128;
        length =
            packedData &
            0x00000000000000000000000000000000ffffffffffffffffffffffffffffffff;
    }
}
library VestingVaultStorage {




    struct Grant {
        uint128 allocation;
        uint128 withdrawn;
        uint128 created;
        uint128 expiration;
        uint128 cliff;
        uint128 latestVotingPower;
        address delegatee;
        uint256[2] range;
    }

    function mappingAddressToGrantPtr(string memory name)
        internal
        pure
        returns (mapping(address => Grant) storage data)
    {

        bytes32 typehash = keccak256("mapping(address => Grant)");
        bytes32 offset = keccak256(abi.encodePacked(typehash, name));
        assembly {
            data.slot := offset
        }
    }
}
interface IVotingVault {

    function queryVotePower(
        address user,
        uint256 blockNumber,
        bytes calldata extraData
    ) external returns (uint256);

}
abstract contract AbstractVestingVault is IVotingVault {
    using History for *;
    using VestingVaultStorage for *;
    using Storage for *;



    IERC20 public immutable token;

    uint256 public immutable staleBlockLag;

    event VoteChange(address indexed to, address indexed from, int256 amount);

    constructor(IERC20 _token, uint256 _stale) {
        token = _token;
        staleBlockLag = _stale;
    }

    function initialize(address manager_, address timelock_) public {
        require(Storage.uint256Ptr("initialized").data == 0, "initialized");
        Storage.set(Storage.uint256Ptr("initialized"), 1);
        Storage.set(Storage.addressPtr("manager"), manager_);
        Storage.set(Storage.addressPtr("timelock"), timelock_);
        Storage.set(Storage.uint256Ptr("unvestedMultiplier"), 100);
    }

    function _grants()
        internal
        pure
        returns (mapping(address => VestingVaultStorage.Grant) storage)
    {
        return (VestingVaultStorage.mappingAddressToGrantPtr("grants"));
    }

    function _loadBound() internal pure returns (Storage.Uint256 memory) {
        return Storage.uint256Ptr("bound");
    }

    function _unassigned() internal pure returns (Storage.Uint256 storage) {
        return Storage.uint256Ptr("unassigned");
    }

    function _manager() internal pure returns (Storage.Address memory) {
        return Storage.addressPtr("manager");
    }

    function _timelock() internal pure returns (Storage.Address memory) {
        return Storage.addressPtr("timelock");
    }

    function _unvestedMultiplier()
        internal
        pure
        returns (Storage.Uint256 memory)
    {
        return Storage.uint256Ptr("unvestedMultiplier");
    }

    modifier onlyManager() {
        require(msg.sender == _manager().data, "!manager");
        _;
    }

    modifier onlyTimelock() {
        require(msg.sender == _timelock().data, "!timelock");
        _;
    }

    function getGrant(address _who)
        external
        view
        returns (VestingVaultStorage.Grant memory)
    {
        return _grants()[_who];
    }

    function acceptGrant() public {
        VestingVaultStorage.Grant storage grant = _grants()[msg.sender];
        uint256 availableTokens = grant.allocation - grant.withdrawn;

        require(availableTokens > 0, "no grant available");

        token.transfer(msg.sender, availableTokens);
        token.transferFrom(msg.sender, address(this), availableTokens);

        uint256 bound = _loadBound().data;
        grant.range = [bound, bound + availableTokens];
        Storage.set(Storage.uint256Ptr("bound"), bound + availableTokens);
    }

    function addGrantAndDelegate(
        address _who,
        uint128 _amount,
        uint128 _startTime,
        uint128 _expiration,
        uint128 _cliff,
        address _delegatee
    ) public onlyManager {
        require(
            _cliff <= _expiration && _startTime <= _expiration,
            "Invalid configuration"
        );
        if (_startTime == 0) {
            _startTime = uint128(block.number);
        }

        Storage.Uint256 storage unassigned = _unassigned();
        Storage.Uint256 memory unvestedMultiplier = _unvestedMultiplier();

        require(unassigned.data >= _amount, "Insufficient balance");
        VestingVaultStorage.Grant storage grant = _grants()[_who];

        require(grant.allocation == 0, "Has Grant");

        _delegatee = _delegatee == address(0) ? _who : _delegatee;

        uint128 newVotingPower =
            (_amount * uint128(unvestedMultiplier.data)) / 100;

        _grants()[_who] = VestingVaultStorage.Grant(
            _amount,
            0,
            _startTime,
            _expiration,
            _cliff,
            newVotingPower,
            _delegatee,
            [uint256(0), uint256(0)]
        );

        unassigned.data -= _amount;

        History.HistoricalBalances memory votingPower = _votingPower();
        uint256 delegateeVotes = votingPower.loadTop(grant.delegatee);
        votingPower.push(grant.delegatee, delegateeVotes + newVotingPower);

        emit VoteChange(grant.delegatee, _who, int256(uint256(newVotingPower)));
    }

    function removeGrant(address _who) public virtual onlyManager {
        VestingVaultStorage.Grant storage grant = _grants()[_who];
        uint256 withdrawable = _getWithdrawableAmount(grant);
        token.transfer(_who, withdrawable);

        Storage.Uint256 storage unassigned = _unassigned();
        uint256 locked = grant.allocation - (grant.withdrawn + withdrawable);

        unassigned.data += locked;

        History.HistoricalBalances memory votingPower = _votingPower();
        uint256 delegateeVotes = votingPower.loadTop(grant.delegatee);
        votingPower.push(
            grant.delegatee,
            delegateeVotes - grant.latestVotingPower
        );

        emit VoteChange(
            grant.delegatee,
            _who,
            -1 * int256(uint256(grant.latestVotingPower))
        );

        delete _grants()[_who];
    }

    function claim() public virtual {
        VestingVaultStorage.Grant storage grant = _grants()[msg.sender];
        uint256 withdrawable = _getWithdrawableAmount(grant);

        token.transfer(msg.sender, withdrawable);
        grant.withdrawn += uint128(withdrawable);

        if (grant.range[1] > 0) {
            grant.range[1] -= withdrawable;
        }

        _syncVotingPower(msg.sender, grant);
    }

    function delegate(address _to) public {
        VestingVaultStorage.Grant storage grant = _grants()[msg.sender];
        require(_to != grant.delegatee, "Already delegated");
        History.HistoricalBalances memory votingPower = _votingPower();

        uint256 oldDelegateeVotes = votingPower.loadTop(grant.delegatee);
        uint256 newVotingPower = _currentVotingPower(grant);

        votingPower.push(
            grant.delegatee,
            oldDelegateeVotes - grant.latestVotingPower
        );
        emit VoteChange(
            grant.delegatee,
            msg.sender,
            -1 * int256(uint256(grant.latestVotingPower))
        );

        uint256 newDelegateeVotes = votingPower.loadTop(_to);

        emit VoteChange(_to, msg.sender, int256(newVotingPower));
        votingPower.push(_to, newDelegateeVotes + newVotingPower);

        grant.latestVotingPower = uint128(newVotingPower);
        grant.delegatee = _to;
    }

    function deposit(uint256 _amount) public onlyManager {
        Storage.Uint256 storage unassigned = _unassigned();
        unassigned.data += _amount;
        token.transferFrom(msg.sender, address(this), _amount);
    }

    function withdraw(uint256 _amount, address _recipient)
        public
        virtual
        onlyManager
    {
        Storage.Uint256 storage unassigned = _unassigned();
        require(unassigned.data >= _amount, "Insufficient balance");
        unassigned.data -= _amount;
        token.transfer(_recipient, _amount);
    }

    function updateVotingPower(address _who) public {
        VestingVaultStorage.Grant storage grant = _grants()[_who];
        _syncVotingPower(_who, grant);
    }

    function _syncVotingPower(
        address _who,
        VestingVaultStorage.Grant storage _grant
    ) internal {
        History.HistoricalBalances memory votingPower = _votingPower();

        uint256 delegateeVotes = votingPower.loadTop(_grant.delegatee);

        uint256 newVotingPower = _currentVotingPower(_grant);
        int256 change =
            int256(newVotingPower) - int256(uint256(_grant.latestVotingPower));
        if (change == 0) return;
        if (change > 0) {
            votingPower.push(
                _grant.delegatee,
                delegateeVotes + uint256(change)
            );
        } else {
            votingPower.push(
                _grant.delegatee,
                delegateeVotes - uint256(change * -1)
            );
        }
        emit VoteChange(_grant.delegatee, _who, change);
        _grant.latestVotingPower = uint128(newVotingPower);
    }

    function queryVotePower(
        address user,
        uint256 blockNumber,
        bytes calldata
    ) external override returns (uint256) {
        History.HistoricalBalances memory votingPower = _votingPower();
        return
            votingPower.findAndClear(
                user,
                blockNumber,
                block.number - staleBlockLag
            );
    }

    function queryVotePowerView(address user, uint256 blockNumber)
        external
        view
        returns (uint256)
    {
        History.HistoricalBalances memory votingPower = _votingPower();
        return votingPower.find(user, blockNumber);
    }

    function _getWithdrawableAmount(VestingVaultStorage.Grant memory _grant)
        internal
        view
        returns (uint256)
    {
        if (block.number < _grant.cliff || block.number < _grant.created) {
            return 0;
        }
        if (block.number >= _grant.expiration) {
            return (_grant.allocation - _grant.withdrawn);
        }
        uint256 unlocked =
            (_grant.allocation * (block.number - _grant.created)) /
                (_grant.expiration - _grant.created);
        return (unlocked - _grant.withdrawn);
    }

    function _votingPower()
        internal
        pure
        returns (History.HistoricalBalances memory)
    {
        return (History.load("votingPower"));
    }

    function _currentVotingPower(VestingVaultStorage.Grant memory _grant)
        internal
        view
        returns (uint256)
    {
        uint256 withdrawable = _getWithdrawableAmount(_grant);
        uint256 locked = _grant.allocation - (withdrawable + _grant.withdrawn);
        return (withdrawable + (locked * _unvestedMultiplier().data) / 100);
    }

    function changeUnvestedMultiplier(uint256 _multiplier) public onlyTimelock {
        require(_multiplier <= 100, "Above 100%");
        Storage.set(Storage.uint256Ptr("unvestedMultiplier"), _multiplier);
    }

    function setTimelock(address timelock_) public onlyTimelock {
        Storage.set(Storage.addressPtr("timelock"), timelock_);
    }

    function setManager(address manager_) public onlyTimelock {
        Storage.set(Storage.addressPtr("manager"), manager_);
    }

    function timelock() public pure returns (address) {
        return _timelock().data;
    }

    function unvestedMultiplier() external pure returns (uint256) {
        return _unvestedMultiplier().data;
    }

    function manager() public pure returns (address) {
        return _manager().data;
    }
}

contract VestingVault is AbstractVestingVault {

    constructor(IERC20 _token, uint256 _stale)
        AbstractVestingVault(_token, _stale)
    {}
}
contract FrozenVestingVault is AbstractVestingVault {

    constructor(IERC20 _token, uint256 _stale)
        AbstractVestingVault(_token, _stale)
    {}


    function removeGrant(address) public pure override {

        revert("Frozen");
    }

    function claim() public pure override {

        revert("Frozen");
    }

    function withdraw(uint256, address) public pure override {

        revert("Frozen");
    }
}