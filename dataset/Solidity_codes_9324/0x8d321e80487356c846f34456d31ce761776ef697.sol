

pragma solidity >=0.8.0 <0.9.0 >=0.8.2 <0.9.0 >=0.8.7 <0.9.0;



abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}




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
}



interface IBeacon {

    function implementation() external view returns (address);

}



library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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
}



library StorageSlot {

    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {

        assembly {
            r.slot := slot
        }
    }
}




abstract contract ERC1967Upgrade {
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    event Upgraded(address indexed implementation);

    function _getImplementation() internal view returns (address) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    function _setImplementation(address newImplementation) private {
        require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(newImplementation, data);
        }
    }

    function _upgradeToAndCallSecure(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        address oldImplementation = _getImplementation();

        _setImplementation(newImplementation);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(newImplementation, data);
        }

        StorageSlot.BooleanSlot storage rollbackTesting = StorageSlot.getBooleanSlot(_ROLLBACK_SLOT);
        if (!rollbackTesting.value) {
            rollbackTesting.value = true;
            Address.functionDelegateCall(
                newImplementation,
                abi.encodeWithSignature("upgradeTo(address)", oldImplementation)
            );
            rollbackTesting.value = false;
            require(oldImplementation == _getImplementation(), "ERC1967Upgrade: upgrade breaks further upgrades");
            _upgradeTo(newImplementation);
        }
    }

    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    event AdminChanged(address previousAdmin, address newAdmin);

    function _getAdmin() internal view returns (address) {
        return StorageSlot.getAddressSlot(_ADMIN_SLOT).value;
    }

    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlot.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    event BeaconUpgraded(address indexed beacon);

    function _getBeacon() internal view returns (address) {
        return StorageSlot.getAddressSlot(_BEACON_SLOT).value;
    }

    function _setBeacon(address newBeacon) private {
        require(Address.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            Address.isContract(IBeacon(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlot.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(IBeacon(newBeacon).implementation(), data);
        }
    }
}



abstract contract Proxy {
    function _delegate(address implementation) internal virtual {
        assembly {
            calldatacopy(0, 0, calldatasize())

            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    function _implementation() internal view virtual returns (address);

    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    fallback() external payable virtual {
        _fallback();
    }

    receive() external payable virtual {
        _fallback();
    }

    function _beforeFallback() internal virtual {}
}




contract ERC1967Proxy is Proxy, ERC1967Upgrade {

    constructor(address _logic, bytes memory _data) payable {
        assert(_IMPLEMENTATION_SLOT == bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1));
        _upgradeToAndCall(_logic, _data, false);
    }

    function _implementation() internal view virtual override returns (address impl) {

        return ERC1967Upgrade._getImplementation();
    }
}




abstract contract UUPSUpgradeable is ERC1967Upgrade {
    address private immutable __self = address(this);

    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallSecure(newImplementation, new bytes(0), false);
    }

    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallSecure(newImplementation, data, true);
    }

    function _authorizeUpgrade(address newImplementation) internal virtual;
}



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
}



interface IDai is IERC20 {

    function permit(
        address holder,
        address spender,
        uint256 nonce,
        uint256 expiry,
        bool allowed,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

}



interface IERC20Reserve {

    function erc20() external view returns (IERC20);


    function withdraw(uint256 amt) external;


    function deposit(uint256 amt) external;

}

contract ERC20Reserve is IERC20Reserve, Ownable {

    IERC20 public immutable override erc20;
    address public user;
    uint256 public balance;

    event Withdrawn(address to, uint256 amt);
    event Deposited(address from, uint256 amt);
    event ForceWithdrawn(address to, uint256 amt);
    event UserSet(address oldUser, address newUser);

    constructor(
        IERC20 _erc20,
        address owner,
        address _user
    ) {
        erc20 = _erc20;
        setUser(_user);
        transferOwnership(owner);
    }

    modifier onlyUser() {

        require(_msgSender() == user, "Reserve: caller is not the user");
        _;
    }

    function withdraw(uint256 amt) public override onlyUser {

        require(balance >= amt, "Reserve: withdrawal over balance");
        balance -= amt;
        emit Withdrawn(_msgSender(), amt);
        require(erc20.transfer(_msgSender(), amt), "Reserve: transfer failed");
    }

    function deposit(uint256 amt) public override onlyUser {

        balance += amt;
        emit Deposited(_msgSender(), amt);
        require(erc20.transferFrom(_msgSender(), address(this), amt), "Reserve: transfer failed");
    }

    function forceWithdraw(uint256 amt) public onlyOwner {

        emit ForceWithdrawn(_msgSender(), amt);
        require(erc20.transfer(_msgSender(), amt), "Reserve: transfer failed");
    }

    function setUser(address newUser) public onlyOwner {

        emit UserSet(user, newUser);
        user = newUser;
    }
}



interface IDaiReserve is IERC20Reserve {

    function dai() external view returns (IDai);

}

contract DaiReserve is ERC20Reserve, IDaiReserve {

    IDai public immutable override dai;

    constructor(
        IDai _dai,
        address owner,
        address user
    ) ERC20Reserve(_dai, owner, user) {
        dai = _dai;
    }
}


struct DripsReceiver {
    address receiver;
    uint128 amtPerSec;
}

struct SplitsReceiver {
    address receiver;
    uint32 weight;
}



abstract contract DripsHub {
    uint64 public immutable cycleSecs;
    uint64 internal constant MAX_TIMESTAMP = type(uint64).max - 2;
    uint32 public constant MAX_DRIPS_RECEIVERS = 100;
    uint32 public constant MAX_SPLITS_RECEIVERS = 200;
    uint32 public constant TOTAL_SPLITS_WEIGHT = 1_000_000;
    bytes32 private constant SLOT_STORAGE =
        bytes32(uint256(keccak256("eip1967.dripsHub.storage")) - 1);

    event Dripping(
        address indexed user,
        address indexed receiver,
        uint128 amtPerSec,
        uint64 endTime
    );

    event Dripping(
        address indexed user,
        uint256 indexed account,
        address indexed receiver,
        uint128 amtPerSec,
        uint64 endTime
    );

    event DripsUpdated(address indexed user, uint128 balance, DripsReceiver[] receivers);

    event DripsUpdated(
        address indexed user,
        uint256 indexed account,
        uint128 balance,
        DripsReceiver[] receivers
    );

    event SplitsUpdated(address indexed user, SplitsReceiver[] receivers);

    event Collected(address indexed user, uint128 collected, uint128 split);

    event Split(address indexed user, address indexed receiver, uint128 amt);

    event Given(address indexed user, address indexed receiver, uint128 amt);

    event Given(
        address indexed user,
        uint256 indexed account,
        address indexed receiver,
        uint128 amt
    );

    struct ReceiverState {
        uint128 collectable;
        uint64 nextCollectedCycle;
        mapping(uint64 => AmtDelta) amtDeltas;
    }

    struct AmtDelta {
        int128 thisCycle;
        int128 nextCycle;
    }

    struct UserOrAccount {
        bool isAccount;
        address user;
        uint256 account;
    }

    struct DripsHubStorage {
        mapping(address => bytes32) splitsHash;
        mapping(address => bytes32) userDripsHashes;
        mapping(address => mapping(uint256 => bytes32)) accountDripsHashes;
        mapping(address => ReceiverState) receiverStates;
    }

    constructor(uint64 _cycleSecs) {
        cycleSecs = _cycleSecs;
    }

    function _storage() internal pure returns (DripsHubStorage storage dripsHubStorage) {
        bytes32 slot = SLOT_STORAGE;
        assembly {
            dripsHubStorage.slot := slot
        }
    }

    function collectable(address user, SplitsReceiver[] memory currReceivers)
        public
        view
        returns (uint128 collected, uint128 split)
    {
        ReceiverState storage receiver = _storage().receiverStates[user];
        _assertCurrSplits(user, currReceivers);

        collected = receiver.collectable;

        uint64 collectedCycle = receiver.nextCollectedCycle;
        uint64 currFinishedCycle = _currTimestamp() / cycleSecs;
        if (collectedCycle != 0 && collectedCycle <= currFinishedCycle) {
            int128 cycleAmt = 0;
            for (; collectedCycle <= currFinishedCycle; collectedCycle++) {
                cycleAmt += receiver.amtDeltas[collectedCycle].thisCycle;
                collected += uint128(cycleAmt);
                cycleAmt += receiver.amtDeltas[collectedCycle].nextCycle;
            }
        }

        if (collected > 0 && currReceivers.length > 0) {
            uint32 splitsWeight = 0;
            for (uint256 i = 0; i < currReceivers.length; i++) {
                splitsWeight += currReceivers[i].weight;
            }
            split = uint128((uint160(collected) * splitsWeight) / TOTAL_SPLITS_WEIGHT);
            collected -= split;
        }
    }

    function collect(address user, SplitsReceiver[] memory currReceivers)
        public
        virtual
        returns (uint128 collected, uint128 split)
    {
        (collected, split) = _collectInternal(user, currReceivers);
        _transfer(user, int128(collected));
    }

    function flushableCycles(address user) public view returns (uint64 flushable) {
        uint64 nextCollectedCycle = _storage().receiverStates[user].nextCollectedCycle;
        if (nextCollectedCycle == 0) return 0;
        uint64 currFinishedCycle = _currTimestamp() / cycleSecs;
        return currFinishedCycle + 1 - nextCollectedCycle;
    }

    function flushCycles(address user, uint64 maxCycles) public virtual returns (uint64 flushable) {
        flushable = flushableCycles(user);
        uint64 cycles = maxCycles < flushable ? maxCycles : flushable;
        flushable -= cycles;
        uint128 collected = _flushCyclesInternal(user, cycles);
        if (collected > 0) _storage().receiverStates[user].collectable += collected;
    }

    function _collectInternal(address user, SplitsReceiver[] memory currReceivers)
        internal
        returns (uint128 collected, uint128 split)
    {
        mapping(address => ReceiverState) storage receiverStates = _storage().receiverStates;
        ReceiverState storage receiver = receiverStates[user];
        _assertCurrSplits(user, currReceivers);

        collected = receiver.collectable;
        if (collected > 0) receiver.collectable = 0;

        uint64 cycles = flushableCycles(user);
        collected += _flushCyclesInternal(user, cycles);

        if (collected > 0 && currReceivers.length > 0) {
            uint32 splitsWeight = 0;
            for (uint256 i = 0; i < currReceivers.length; i++) {
                splitsWeight += currReceivers[i].weight;
                uint128 splitsAmt = uint128(
                    (uint160(collected) * splitsWeight) / TOTAL_SPLITS_WEIGHT - split
                );
                split += splitsAmt;
                address splitsReceiver = currReceivers[i].receiver;
                receiverStates[splitsReceiver].collectable += splitsAmt;
                emit Split(user, splitsReceiver, splitsAmt);
            }
            collected -= split;
        }
        emit Collected(user, collected, split);
    }

    function _flushCyclesInternal(address user, uint64 count)
        internal
        returns (uint128 collectedAmt)
    {
        if (count == 0) return 0;
        ReceiverState storage receiver = _storage().receiverStates[user];
        uint64 cycle = receiver.nextCollectedCycle;
        int128 cycleAmt = 0;
        for (uint256 i = 0; i < count; i++) {
            cycleAmt += receiver.amtDeltas[cycle].thisCycle;
            collectedAmt += uint128(cycleAmt);
            cycleAmt += receiver.amtDeltas[cycle].nextCycle;
            delete receiver.amtDeltas[cycle];
            cycle++;
        }
        if (cycleAmt != 0) receiver.amtDeltas[cycle].thisCycle += cycleAmt;
        receiver.nextCollectedCycle = cycle;
    }

    function _give(
        UserOrAccount memory userOrAccount,
        address receiver,
        uint128 amt
    ) internal {
        _storage().receiverStates[receiver].collectable += amt;
        if (userOrAccount.isAccount) {
            emit Given(userOrAccount.user, userOrAccount.account, receiver, amt);
        } else {
            emit Given(userOrAccount.user, receiver, amt);
        }
        _transfer(userOrAccount.user, -int128(amt));
    }

    function dripsHash(address user) public view returns (bytes32 currDripsHash) {
        return _storage().userDripsHashes[user];
    }

    function dripsHash(address user, uint256 account) public view returns (bytes32 currDripsHash) {
        return _storage().accountDripsHashes[user][account];
    }

    function _setDrips(
        UserOrAccount memory userOrAccount,
        uint64 lastUpdate,
        uint128 lastBalance,
        DripsReceiver[] memory currReceivers,
        int128 balanceDelta,
        DripsReceiver[] memory newReceivers
    ) internal returns (uint128 newBalance, int128 realBalanceDelta) {
        _assertCurrDrips(userOrAccount, lastUpdate, lastBalance, currReceivers);
        uint128 newAmtPerSec = _assertDripsReceiversValid(newReceivers);
        uint128 currAmtPerSec = _totalDripsAmtPerSec(currReceivers);
        uint64 currEndTime = _dripsEndTime(lastUpdate, lastBalance, currAmtPerSec);
        (newBalance, realBalanceDelta) = _updateDripsBalance(
            lastUpdate,
            lastBalance,
            currEndTime,
            currAmtPerSec,
            balanceDelta
        );
        uint64 newEndTime = _dripsEndTime(_currTimestamp(), newBalance, newAmtPerSec);
        _updateDripsReceiversStates(
            userOrAccount,
            currReceivers,
            currEndTime,
            newReceivers,
            newEndTime
        );
        _storeNewDrips(userOrAccount, newBalance, newReceivers);
        _emitDripsUpdated(userOrAccount, newBalance, newReceivers);
        _transfer(userOrAccount.user, -realBalanceDelta);
    }

    function _assertDripsReceiversValid(DripsReceiver[] memory receivers)
        internal
        pure
        returns (uint128 totalAmtPerSec)
    {
        require(receivers.length <= MAX_DRIPS_RECEIVERS, "Too many drips receivers");
        uint256 amtPerSec = 0;
        address prevReceiver;
        for (uint256 i = 0; i < receivers.length; i++) {
            uint128 amt = receivers[i].amtPerSec;
            require(amt != 0, "Drips receiver amtPerSec is zero");
            amtPerSec += amt;
            address receiver = receivers[i].receiver;
            if (i > 0) {
                require(prevReceiver != receiver, "Duplicate drips receivers");
                require(prevReceiver < receiver, "Drips receivers not sorted by address");
            }
            prevReceiver = receiver;
        }
        require(amtPerSec <= type(uint128).max, "Total drips receivers amtPerSec too high");
        return uint128(amtPerSec);
    }

    function _totalDripsAmtPerSec(DripsReceiver[] memory receivers)
        internal
        pure
        returns (uint128 totalAmtPerSec)
    {
        uint256 length = receivers.length;
        uint256 i = 0;
        while (i < length) {
            unchecked {
                totalAmtPerSec += receivers[i++].amtPerSec;
            }
        }
    }

    function _updateDripsBalance(
        uint64 lastUpdate,
        uint128 lastBalance,
        uint64 currEndTime,
        uint128 currAmtPerSec,
        int128 balanceDelta
    ) internal view returns (uint128 newBalance, int128 realBalanceDelta) {
        if (currEndTime > _currTimestamp()) currEndTime = _currTimestamp();
        uint128 dripped = (currEndTime - lastUpdate) * currAmtPerSec;
        int128 currBalance = int128(lastBalance - dripped);
        int136 balance = currBalance + int136(balanceDelta);
        if (balance < 0) balance = 0;
        return (uint128(uint136(balance)), int128(balance - currBalance));
    }

    function _emitDripsUpdated(
        UserOrAccount memory userOrAccount,
        uint128 balance,
        DripsReceiver[] memory receivers
    ) internal {
        if (userOrAccount.isAccount) {
            emit DripsUpdated(userOrAccount.user, userOrAccount.account, balance, receivers);
        } else {
            emit DripsUpdated(userOrAccount.user, balance, receivers);
        }
    }

    function _updateDripsReceiversStates(
        UserOrAccount memory userOrAccount,
        DripsReceiver[] memory currReceivers,
        uint64 currEndTime,
        DripsReceiver[] memory newReceivers,
        uint64 newEndTime
    ) internal {
        uint256 currIdx = currEndTime > _currTimestamp() ? 0 : currReceivers.length;
        uint256 newIdx = newEndTime > _currTimestamp() ? 0 : newReceivers.length;
        while (true) {
            bool pickCurr = currIdx < currReceivers.length;
            bool pickNew = newIdx < newReceivers.length;
            if (!pickCurr && !pickNew) break;
            if (pickCurr && pickNew) {
                address currReceiver = currReceivers[currIdx].receiver;
                address newReceiver = newReceivers[newIdx].receiver;
                pickCurr = currReceiver <= newReceiver;
                pickNew = newReceiver <= currReceiver;
            }
            address receiver;
            int128 currAmtPerSec = 0;
            int128 newAmtPerSec = 0;
            if (pickCurr) {
                receiver = currReceivers[currIdx].receiver;
                currAmtPerSec = int128(currReceivers[currIdx].amtPerSec);
                _setDelta(receiver, currEndTime, currAmtPerSec);
                currIdx++;
            }
            if (pickNew) {
                receiver = newReceivers[newIdx].receiver;
                newAmtPerSec = int128(newReceivers[newIdx].amtPerSec);
                _setDelta(receiver, newEndTime, -newAmtPerSec);
                newIdx++;
            }
            _setDelta(receiver, _currTimestamp(), newAmtPerSec - currAmtPerSec);
            _emitDripping(userOrAccount, receiver, uint128(newAmtPerSec), newEndTime);
            if (!pickCurr) {
                ReceiverState storage receiverState = _storage().receiverStates[receiver];
                if (receiverState.nextCollectedCycle == 0) {
                    receiverState.nextCollectedCycle = _currTimestamp() / cycleSecs + 1;
                }
            }
        }
    }

    function _emitDripping(
        UserOrAccount memory userOrAccount,
        address receiver,
        uint128 amtPerSec,
        uint64 endTime
    ) internal {
        if (amtPerSec == 0) endTime = _currTimestamp();
        if (userOrAccount.isAccount) {
            emit Dripping(userOrAccount.user, userOrAccount.account, receiver, amtPerSec, endTime);
        } else {
            emit Dripping(userOrAccount.user, receiver, amtPerSec, endTime);
        }
    }

    function _dripsEndTime(
        uint64 startTime,
        uint128 startBalance,
        uint128 totalAmtPerSec
    ) internal pure returns (uint64 dripsEndTime) {
        if (totalAmtPerSec == 0) return startTime;
        uint256 endTime = startTime + uint256(startBalance / totalAmtPerSec);
        return endTime > MAX_TIMESTAMP ? MAX_TIMESTAMP : uint64(endTime);
    }

    function _assertCurrDrips(
        UserOrAccount memory userOrAccount,
        uint64 lastUpdate,
        uint128 lastBalance,
        DripsReceiver[] memory currReceivers
    ) internal view {
        bytes32 expectedHash;
        if (userOrAccount.isAccount) {
            expectedHash = _storage().accountDripsHashes[userOrAccount.user][userOrAccount.account];
        } else {
            expectedHash = _storage().userDripsHashes[userOrAccount.user];
        }
        bytes32 actualHash = hashDrips(lastUpdate, lastBalance, currReceivers);
        require(actualHash == expectedHash, "Invalid current drips configuration");
    }

    function _storeNewDrips(
        UserOrAccount memory userOrAccount,
        uint128 newBalance,
        DripsReceiver[] memory newReceivers
    ) internal {
        bytes32 newDripsHash = hashDrips(_currTimestamp(), newBalance, newReceivers);
        if (userOrAccount.isAccount) {
            _storage().accountDripsHashes[userOrAccount.user][userOrAccount.account] = newDripsHash;
        } else {
            _storage().userDripsHashes[userOrAccount.user] = newDripsHash;
        }
    }

    function hashDrips(
        uint64 update,
        uint128 balance,
        DripsReceiver[] memory receivers
    ) public pure returns (bytes32 dripsConfigurationHash) {
        if (update == 0 && balance == 0 && receivers.length == 0) return bytes32(0);
        return keccak256(abi.encode(receivers, update, balance));
    }

    function _setSplits(
        address user,
        SplitsReceiver[] memory currReceivers,
        SplitsReceiver[] memory newReceivers
    ) internal returns (uint128 collected, uint128 split) {
        (collected, split) = _collectInternal(user, currReceivers);
        _assertSplitsValid(newReceivers);
        _storage().splitsHash[user] = hashSplits(newReceivers);
        emit SplitsUpdated(user, newReceivers);
        _transfer(user, int128(collected));
    }

    function _assertSplitsValid(SplitsReceiver[] memory receivers) internal pure {
        require(receivers.length <= MAX_SPLITS_RECEIVERS, "Too many splits receivers");
        uint64 totalWeight = 0;
        address prevReceiver;
        for (uint256 i = 0; i < receivers.length; i++) {
            uint32 weight = receivers[i].weight;
            require(weight != 0, "Splits receiver weight is zero");
            totalWeight += weight;
            address receiver = receivers[i].receiver;
            if (i > 0) {
                require(prevReceiver != receiver, "Duplicate splits receivers");
                require(prevReceiver < receiver, "Splits receivers not sorted by address");
            }
            prevReceiver = receiver;
        }
        require(totalWeight <= TOTAL_SPLITS_WEIGHT, "Splits weights sum too high");
    }

    function splitsHash(address user) public view returns (bytes32 currSplitsHash) {
        return _storage().splitsHash[user];
    }

    function _assertCurrSplits(address user, SplitsReceiver[] memory currReceivers) internal view {
        require(
            hashSplits(currReceivers) == _storage().splitsHash[user],
            "Invalid current splits receivers"
        );
    }

    function hashSplits(SplitsReceiver[] memory receivers)
        public
        pure
        returns (bytes32 receiversHash)
    {
        if (receivers.length == 0) return bytes32(0);
        return keccak256(abi.encode(receivers));
    }

    function _transfer(address user, int128 amt) internal virtual;

    function _setDelta(
        address user,
        uint64 timestamp,
        int128 amtPerSecDelta
    ) internal {
        if (amtPerSecDelta == 0) return;
        mapping(uint64 => AmtDelta) storage amtDeltas = _storage().receiverStates[user].amtDeltas;
        uint64 thisCycle = timestamp / cycleSecs + 1;
        uint64 nextCycleSecs = timestamp % cycleSecs;
        uint64 thisCycleSecs = cycleSecs - nextCycleSecs;
        amtDeltas[thisCycle].thisCycle += int128(uint128(thisCycleSecs)) * amtPerSecDelta;
        amtDeltas[thisCycle].nextCycle += int128(uint128(nextCycleSecs)) * amtPerSecDelta;
    }

    function _userOrAccount(address user) internal pure returns (UserOrAccount memory) {
        return UserOrAccount({isAccount: false, user: user, account: 0});
    }

    function _userOrAccount(address user, uint256 account)
        internal
        pure
        returns (UserOrAccount memory)
    {
        return UserOrAccount({isAccount: true, user: user, account: account});
    }

    function _currTimestamp() internal view returns (uint64) {
        return uint64(block.timestamp);
    }
}



abstract contract ManagedDripsHub is DripsHub, UUPSUpgradeable {
    bytes32 private constant SLOT_PAUSED =
        bytes32(uint256(keccak256("eip1967.managedDripsHub.paused")) - 1);

    event Paused(address account);

    event Unpaused(address account);

    constructor(uint64 cycleSecs) DripsHub(cycleSecs) {
        _pausedSlot().value = true;
    }

    function collect(address user, SplitsReceiver[] memory currReceivers)
        public
        override
        whenNotPaused
        returns (uint128 collected, uint128 split)
    {
        return super.collect(user, currReceivers);
    }

    function flushCycles(address user, uint64 maxCycles)
        public
        override
        whenNotPaused
        returns (uint64 flushable)
    {
        return super.flushCycles(user, maxCycles);
    }

    function _authorizeUpgrade(address newImplementation) internal view override onlyAdmin {
        newImplementation;
    }

    function admin() public view returns (address) {
        return _getAdmin();
    }

    function changeAdmin(address newAdmin) public onlyAdmin {
        _changeAdmin(newAdmin);
    }

    modifier onlyAdmin() {
        require(admin() == msg.sender, "Caller is not the admin");
        _;
    }

    function paused() public view returns (bool isPaused) {
        return _pausedSlot().value;
    }

    function pause() public whenNotPaused onlyAdmin {
        _pausedSlot().value = true;
        emit Paused(msg.sender);
    }

    function unpause() public whenPaused onlyAdmin {
        _pausedSlot().value = false;
        emit Unpaused(msg.sender);
    }

    modifier whenNotPaused() {
        require(!paused(), "Contract paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Contract not paused");
        _;
    }

    function _pausedSlot() private pure returns (StorageSlot.BooleanSlot storage) {
        return StorageSlot.getBooleanSlot(SLOT_PAUSED);
    }
}

contract ManagedDripsHubProxy is ERC1967Proxy {

    constructor(ManagedDripsHub hubLogic, address admin)
        ERC1967Proxy(address(hubLogic), new bytes(0))
    {
        _changeAdmin(admin);
    }
}



contract ERC20DripsHub is ManagedDripsHub {

    bytes32 private constant SLOT_RESERVE =
        bytes32(uint256(keccak256("eip1967.erc20DripsHub.reserve")) - 1);
    IERC20 public immutable erc20;

    event ReserveSet(IERC20Reserve oldReserve, IERC20Reserve newReserve);

    constructor(uint64 cycleSecs, IERC20 _erc20) ManagedDripsHub(cycleSecs) {
        erc20 = _erc20;
    }

    function setDrips(
        uint64 lastUpdate,
        uint128 lastBalance,
        DripsReceiver[] memory currReceivers,
        int128 balanceDelta,
        DripsReceiver[] memory newReceivers
    ) public whenNotPaused returns (uint128 newBalance, int128 realBalanceDelta) {

        return
            _setDrips(
                _userOrAccount(msg.sender),
                lastUpdate,
                lastBalance,
                currReceivers,
                balanceDelta,
                newReceivers
            );
    }

    function setDrips(
        uint256 account,
        uint64 lastUpdate,
        uint128 lastBalance,
        DripsReceiver[] memory currReceivers,
        int128 balanceDelta,
        DripsReceiver[] memory newReceivers
    ) public whenNotPaused returns (uint128 newBalance, int128 realBalanceDelta) {

        return
            _setDrips(
                _userOrAccount(msg.sender, account),
                lastUpdate,
                lastBalance,
                currReceivers,
                balanceDelta,
                newReceivers
            );
    }

    function give(address receiver, uint128 amt) public whenNotPaused {

        _give(_userOrAccount(msg.sender), receiver, amt);
    }

    function give(
        uint256 account,
        address receiver,
        uint128 amt
    ) public whenNotPaused {

        _give(_userOrAccount(msg.sender, account), receiver, amt);
    }

    function setSplits(SplitsReceiver[] memory currReceivers, SplitsReceiver[] memory newReceivers)
        public
        whenNotPaused
        returns (uint128 collected, uint128 split)
    {

        return _setSplits(msg.sender, currReceivers, newReceivers);
    }

    function reserve() public view returns (IERC20Reserve) {

        return IERC20Reserve(_reserveSlot().value);
    }

    function setReserve(IERC20Reserve newReserve) public onlyAdmin {

        require(newReserve.erc20() == erc20, "Invalid reserve ERC-20 address");
        IERC20Reserve oldReserve = reserve();
        if (address(oldReserve) != address(0)) erc20.approve(address(oldReserve), 0);
        _reserveSlot().value = address(newReserve);
        erc20.approve(address(newReserve), type(uint256).max);
        emit ReserveSet(oldReserve, newReserve);
    }

    function _reserveSlot() private pure returns (StorageSlot.AddressSlot storage) {

        return StorageSlot.getAddressSlot(SLOT_RESERVE);
    }

    function _transfer(address user, int128 amt) internal override {

        IERC20Reserve erc20Reserve = reserve();
        require(address(erc20Reserve) != address(0), "Reserve unset");
        if (amt > 0) {
            uint256 withdraw = uint128(amt);
            erc20Reserve.withdraw(withdraw);
            erc20.transfer(user, withdraw);
        } else if (amt < 0) {
            uint256 deposit = uint128(-amt);
            erc20.transferFrom(user, address(this), deposit);
            erc20Reserve.deposit(deposit);
        }
    }
}



struct PermitArgs {
    uint256 nonce;
    uint256 expiry;
    uint8 v;
    bytes32 r;
    bytes32 s;
}

contract DaiDripsHub is ERC20DripsHub {

    IDai public immutable dai;

    constructor(uint64 cycleSecs, IDai _dai) ERC20DripsHub(cycleSecs, _dai) {
        dai = _dai;
    }

    function setDripsAndPermit(
        uint64 lastUpdate,
        uint128 lastBalance,
        DripsReceiver[] memory currReceivers,
        int128 balanceDelta,
        DripsReceiver[] memory newReceivers,
        PermitArgs calldata permitArgs
    ) public whenNotPaused returns (uint128 newBalance, int128 realBalanceDelta) {

        _permit(permitArgs);
        return setDrips(lastUpdate, lastBalance, currReceivers, balanceDelta, newReceivers);
    }

    function setDripsAndPermit(
        uint256 account,
        uint64 lastUpdate,
        uint128 lastBalance,
        DripsReceiver[] memory currReceivers,
        int128 balanceDelta,
        DripsReceiver[] memory newReceivers,
        PermitArgs calldata permitArgs
    ) public whenNotPaused returns (uint128 newBalance, int128 realBalanceDelta) {

        _permit(permitArgs);
        return
            setDrips(account, lastUpdate, lastBalance, currReceivers, balanceDelta, newReceivers);
    }

    function giveAndPermit(
        address receiver,
        uint128 amt,
        PermitArgs calldata permitArgs
    ) public whenNotPaused {

        _permit(permitArgs);
        give(receiver, amt);
    }

    function giveAndPermit(
        uint256 account,
        address receiver,
        uint128 amt,
        PermitArgs calldata permitArgs
    ) public whenNotPaused {

        _permit(permitArgs);
        give(account, receiver, amt);
    }

    function _permit(PermitArgs calldata permitArgs) internal {

        dai.permit(
            msg.sender,
            address(this),
            permitArgs.nonce,
            permitArgs.expiry,
            true,
            permitArgs.v,
            permitArgs.r,
            permitArgs.s
        );
    }
}