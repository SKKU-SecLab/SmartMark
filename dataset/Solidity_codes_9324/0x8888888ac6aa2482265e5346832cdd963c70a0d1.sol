



pragma solidity ^0.8.10;

struct DailySnapshot {
    uint inflationAmount;
    uint totalShares;
    uint sharePrice;
}
struct Stake {
    address owner;
    uint stakedAmount;
    uint startDay;
    uint lockedForXDays;
    uint endDay;
    uint maxSharesCountOnStartStake;
}


interface ICerbyStakingSystem {

    function getDailySnapshotsLength()
        external
        view
        returns(uint);


    function getStakesLength()
        external
        view
        returns(uint);


    function getCachedInterestPerShareLength()
        external
        view
        returns(uint);        


    function dailySnapshots(uint pos)
        external
        returns (DailySnapshot memory);        


    function stakes(uint pos)
        external
        returns (Stake memory);        


    function cachedInterestPerShare(uint pos)
        external
        returns (uint);

}



pragma solidity ^0.8.10;

interface ICerbyCronJobs {

    
    function executeCronJobs()
        external;

}



pragma solidity ^0.8.10;

struct TransactionInfo {
    bool isBuy;
    bool isSell;
}

interface ICerbyBotDetection {

        
    function checkTransactionInfo(address tokenAddr, address sender, address recipient, uint recipientBalance, uint transferAmount)
        external
        returns (TransactionInfo memory output);

    
    function isBotAddress(address addr)
        external
        view
        returns (bool);


    function executeCronJobs()
        external;

}



pragma solidity ^0.8.10;

interface ICerbyTokenMinterBurner {

    
    function balanceOf(
        address account
    )
        external
        view
        returns (uint);

    
    function totalSupply()
        external
        view
        returns (uint);

        
    function mintHumanAddress(address to, uint desiredAmountToMint) external;


    function burnHumanAddress(address from, uint desiredAmountToBurn) external;

    
    function transferCustom(address sender, address recipient, uint256 amount) external;

    
    function getUtilsContractAtPos(uint pos)
        external
        view
        returns (address);

}



pragma solidity ^0.8.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) { // Equivalent to contains(set, value)

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
}




pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}




pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}




pragma solidity ^0.8.0;

library Strings {

    bytes16 private constant alphabet = "0123456789abcdef";

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
            buffer[i] = alphabet[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

}




pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}




pragma solidity ^0.8.0;





struct RoleAccess {
    bytes32 role;
    address addr;
}

interface IAccessControl {

    function hasRole(bytes32 role, address account) external view returns (bool);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function grantRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function renounceRole(bytes32 role, address account) external;

}

abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping (address => bool) members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant ROLE_ADMIN = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if(!hasRole(role, account)) {
            revert(string(abi.encodePacked(
                "AccessControl: account ",
                Strings.toHexString(uint160(account), 20),
                " is missing role ",
                Strings.toHexString(uint256(role), 32)
            )));
        }
    }

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override onlyRole(ROLE_ADMIN) {
        _grantRole(role, account);
    }
    
    function grantRolesBulk(RoleAccess[] calldata roles)
        external
        onlyRole(ROLE_ADMIN)
    {
        for(uint i = 0; i<roles.length; i++)
        {
            _setupRole(roles[i].role, roles[i].addr);
        }
    }

    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}




pragma solidity ^0.8.0;



interface IAccessControlEnumerable {

    function getRoleMember(bytes32 role, uint256 index) external view returns (address);

    function getRoleMemberCount(bytes32 role) external view returns (uint256);

}

abstract contract AccessControlEnumerable is IAccessControlEnumerable, AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping (bytes32 => EnumerableSet.AddressSet) private _roleMembers;

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerable).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function getRoleMember(bytes32 role, uint256 index) public view override returns (address) {
        return _roleMembers[role].at(index);
    }

    function getRoleMemberCount(bytes32 role) public view override returns (uint256) {
        return _roleMembers[role].length();
    }

    function grantRole(bytes32 role, address account) public virtual override {
        super.grantRole(role, account);
        _roleMembers[role].add(account);
    }

    function revokeRole(bytes32 role, address account) public virtual override {
        super.revokeRole(role, account);
        _roleMembers[role].remove(account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        super.renounceRole(role, account);
        _roleMembers[role].remove(account);
    }

    function _setupRole(bytes32 role, address account) internal virtual override {
        super._setupRole(role, account);
        _roleMembers[role].add(account);
    }
}




pragma solidity ^0.8.10;







struct StartStake {
    uint stakedAmount;
    uint lockedForXDays;
}

struct Settings {
    uint MINIMUM_DAYS_FOR_HIGH_PENALTY;
    uint CONTROLLED_APY;
    uint SMALLER_PAYS_BETTER_BONUS;
    uint LONGER_PAYS_BETTER_BONUS;
    uint END_STAKE_FROM;
    uint END_STAKE_TO;
    uint MINIMUM_STAKE_DAYS;
    uint MAXIMUM_STAKE_DAYS;
}

contract CerbyStakingSystem is AccessControlEnumerable {

    DailySnapshot[] public dailySnapshots;
    uint[] public cachedInterestPerShare;
    
    Stake[] public stakes;
    Settings public settings;
    
    uint constant CERBY_BOT_DETECTION_CONTRACT_ID = 3;
    uint constant MINIMUM_SMALLER_PAYS_BETTER = 1000 * 1e18; // 1k CERBY
    uint constant MAXIMUM_SMALLER_PAYS_BETTER = 1000000 * 1e18; // 1M CERBY
    uint constant CACHED_DAYS_INTEREST = 100;
    uint constant DAYS_IN_ONE_YEAR = 365;
    uint constant SHARE_PRICE_DENORM = 1e18;
    uint constant INTEREST_PER_SHARE_DENORM = 1e18;
    uint constant APY_DENORM = 1e6;
    uint constant SECONDS_IN_ONE_DAY = 86400;
    
    ICerbyTokenMinterBurner cerbyToken = ICerbyTokenMinterBurner(
        0xdef1fac7Bf08f173D286BbBDcBeeADe695129840
    );

    address constant BURN_WALLET = address(0x0);
    
    uint public launchTimestamp;
    
    event StakeStarted(
        uint stakeId, 
        address owner, 
        uint stakedAmount, 
        uint startDay, 
        uint lockedForXDays, 
        uint sharesCount
    );
    event StakeEnded(
        uint stakeId, 
        uint endDay, 
        uint interest, 
        uint penalty
    );
    event StakeOwnerChanged(
        uint stakeId, 
        address newOwner
    );
    event StakeUpdated(
        uint stakeId, 
        uint lockedForXDays,
        uint sharesCount
    );
    
    event DailySnapshotSealed(
        uint sealedDay, 
        uint inflationAmount,
        uint totalShares,
        uint sharePrice,
        uint totalStaked,
        uint totalSupply
    );
    event CachedInterestPerShareSealed(
        uint sealedDay,
        uint sealedCachedDay, 
        uint cachedInterestPerShare
    );
    
    event SettingsUpdated(
        Settings Settings
    );
    
    event NewMaxSharePriceReached(
        uint newSharePrice
    );
   
    event BurnedAndAddedToStakersInflation(
        address fromAddr, 
        uint amountToBurn, 
        uint currentDay
    );
    
    constructor() 
    {
        settings.MINIMUM_DAYS_FOR_HIGH_PENALTY = 0;
        settings.CONTROLLED_APY = 4e5; // 40%
        settings.END_STAKE_FROM = 30;
        settings.END_STAKE_TO = 2*DAYS_IN_ONE_YEAR; // 5% per month penalty
        settings.MINIMUM_STAKE_DAYS = 1;
        settings.MAXIMUM_STAKE_DAYS = 100*DAYS_IN_ONE_YEAR;
        settings.LONGER_PAYS_BETTER_BONUS = 3e6; // 3e6/1e6 = 300% shares bonus max
        settings.SMALLER_PAYS_BETTER_BONUS = 25e4; // 25e4/1e6 = 25% shares bonus max        
        
        launchTimestamp = 1635604537; // 30 October 2021
        
        dailySnapshots.push(DailySnapshot(
            0,
            0,
            SHARE_PRICE_DENORM
        ));
        emit DailySnapshotSealed(
            0,
            0,
            0,
            SHARE_PRICE_DENORM,
            0,
            0
        );
        dailySnapshots.push(DailySnapshot(
            0,
            0,
            SHARE_PRICE_DENORM
        ));
        cachedInterestPerShare.push(0);
        emit NewMaxSharePriceReached(SHARE_PRICE_DENORM);        
        
        _setupRole(ROLE_ADMIN, msg.sender);
    }

    modifier executeCronJobs()
    {

        ICerbyBotDetection iCerbyBotDetection = ICerbyBotDetection(
            ICerbyTokenMinterBurner(cerbyToken).getUtilsContractAtPos(CERBY_BOT_DETECTION_CONTRACT_ID)
        );
        iCerbyBotDetection.executeCronJobs();
        _;
    }
    
    modifier onlyRealUsers
    {

        ICerbyBotDetection iCerbyBotDetection = ICerbyBotDetection(
            ICerbyTokenMinterBurner(cerbyToken).getUtilsContractAtPos(CERBY_BOT_DETECTION_CONTRACT_ID)
        );
        require(
            !iCerbyBotDetection.isBotAddress(msg.sender),
            "SS: Only real users allowed!"
        );
        _;
    }
    
    modifier onlyStakeOwners(uint stakeId)
    {

        require(
            msg.sender == stakes[stakeId].owner,
            "SS: Stake owner does not match"
        );
        _;
    }
    
    modifier onlyExistingStake(uint stakeId)
    {

        require(
            stakeId < stakes.length,
            "SS: Stake does not exist"
        );
        _;
    }
    
    modifier onlyActiveStake(uint stakeId)
    {

        require(
            stakes[stakeId].endDay == 0,
            "SS: Stake was already ended"
        );
        _;
    }
    
    function adminUpdateSettings(Settings calldata _settings)
        public
        onlyRole(ROLE_ADMIN)
    {

        settings = _settings;
        
        emit SettingsUpdated(_settings);
    }

    function adminBulkTransferOwnership(uint[] calldata stakeIds, address oldOwner, address newOwner)
        public
        executeCronJobs
        onlyRole(ROLE_ADMIN)
    {

        for(uint i = 0; i<stakeIds.length; i++)
        {
            require(
                stakes[stakeIds[i]].owner != newOwner,
                "SS: New owner must be different from old owner"
            );
            require(
                stakes[stakeIds[i]].owner == oldOwner,
                "SS: Stake owner does not match"
            );            

            _transferOwnership(stakeIds[i], newOwner);
        } 
    }

    function adminBulkDestroyStakes(uint[] calldata stakeIds, address stakeOwner)
        public
        executeCronJobs
        onlyRole(ROLE_ADMIN)
    {

        uint today = getCurrentDaySinceLaunch();
        for(uint i = 0; i<stakeIds.length; i++)
        {
            require(
                stakes[stakeIds[i]].owner == stakeOwner,
                "SS: Stake owner does not match"
            );
        
            dailySnapshots[today].totalShares -= stakes[stakeIds[i]].maxSharesCountOnStartStake;
            stakes[stakeIds[i]].endDay = today;
            stakes[stakeIds[i]].owner = BURN_WALLET;

            cerbyToken.burnHumanAddress(address(this), stakes[stakeIds[i]].stakedAmount);

            emit StakeOwnerChanged(stakeIds[i], BURN_WALLET);
            emit StakeEnded(stakeIds[i], today, 0, 0);
        }
    }

    function adminMigrateInitialSnapshots(address fromStakingContract, uint fromIndex, uint toIndex)
        public
        onlyRole(ROLE_ADMIN)
    {

        uint totalStaked = getTotalTokensStaked();
        uint totalSupply = cerbyToken.totalSupply();
        ICerbyStakingSystem iStaking = ICerbyStakingSystem(fromStakingContract);
        toIndex = minOfTwoUints(toIndex, iStaking.getDailySnapshotsLength());
        for(uint i = fromIndex; i<toIndex; i++)
        {
            DailySnapshot memory snapshot = iStaking.dailySnapshots(i);
            if (dailySnapshots.length == i)
            {
                dailySnapshots.push(snapshot);
            } else if (dailySnapshots.length > i)
            {
                dailySnapshots[i] = snapshot;
            }
            emit DailySnapshotSealed(
                i,
                snapshot.inflationAmount,
                snapshot.totalShares,
                snapshot.sharePrice,
                totalStaked,
                totalSupply
            );
            emit NewMaxSharePriceReached(snapshot.sharePrice);
        }
    }

    function adminMigrateInitialStakes(address fromStakingContract, uint fromIndex, uint toIndex)
        public
        onlyRole(ROLE_ADMIN)
    {

        ICerbyStakingSystem iStaking = ICerbyStakingSystem(fromStakingContract);
        toIndex = minOfTwoUints(toIndex, iStaking.getStakesLength());
        for(uint i = fromIndex; i<toIndex; i++)
        {
            Stake memory stake = iStaking.stakes(i);
            if (stakes.length == i)
            {
                stakes.push(stake);
            } else if (stakes.length > i)
            {
                stakes[i] = stake;
            }

            emit StakeStarted(
                i,
                stake.owner,
                stake.stakedAmount, 
                stake.startDay,
                stake.lockedForXDays,
                stake.maxSharesCountOnStartStake
            );

            if (stake.endDay > 0)
            {
                uint endDay = stake.endDay;
                uint interest = getInterestByStake(stake, endDay);
                uint penalty = getPenaltyByStake(stake, endDay, interest);
                
                emit StakeEnded(i, endDay, interest, penalty);
            }
        }
    }

    function adminMigrateInitialInterestPerShare(address fromStakingContract, uint fromIndex, uint toIndex)
        public
        onlyRole(ROLE_ADMIN)
    {

        ICerbyStakingSystem iStaking = ICerbyStakingSystem(fromStakingContract);
        toIndex = minOfTwoUints(toIndex, iStaking.getCachedInterestPerShareLength());
        for(uint i = fromIndex; i<toIndex; i++)
        {
            uint cachedInterestPerShareValue = iStaking.cachedInterestPerShare(i);
            if (cachedInterestPerShare.length == i)
            {
                cachedInterestPerShare.push(cachedInterestPerShareValue);
            } else if (stakes.length > i)
            {
                cachedInterestPerShare[i] = cachedInterestPerShareValue;
            }

            uint sealedDay = i * CACHED_DAYS_INTEREST;
            emit CachedInterestPerShareSealed(
                sealedDay,
                i,
                cachedInterestPerShareValue
            );
        }
    }

    
    function adminBurnAndAddToStakersInflation(address fromAddr, uint amountToBurn)
        public
        executeCronJobs
        onlyRole(ROLE_ADMIN)
    {

        cerbyToken.burnHumanAddress(fromAddr, amountToBurn);
        
        uint today = getCurrentDaySinceLaunch();
        dailySnapshots[today].inflationAmount += amountToBurn;
        
        emit BurnedAndAddedToStakersInflation(fromAddr, amountToBurn, today);
    }
    
    function bulkTransferOwnership(uint[] calldata stakeIds, address newOwner)
        public
        onlyRealUsers
        executeCronJobs
    {

        for(uint i = 0; i<stakeIds.length; i++)
        {
            transferOwnership(stakeIds[i], newOwner);
        }
    }
    
    function transferOwnership(uint stakeId, address newOwner)
        private
        onlyStakeOwners(stakeId)
        onlyExistingStake(stakeId)
        onlyActiveStake(stakeId)
    {

        require(
            stakes[stakeId].owner != newOwner,
            "SS: New owner must be different from old owner"
        );

        _transferOwnership(stakeId, newOwner);        
    }

    function _transferOwnership(uint stakeId, address newOwner)
        private
    {

        stakes[stakeId].owner = newOwner;
        emit StakeOwnerChanged(stakeId, newOwner);
    }
    
    function updateAllSnapshots()
        public
    {

        updateSnapshots(getCurrentDaySinceLaunch());
    }
    
    function updateSnapshots(uint givenDay)
        public
    {

        require(
            givenDay <= getCurrentDaySinceLaunch(),
            "SS: Exceeded current day"
        );
        
        uint startDay = dailySnapshots.length-1; // last sealed day
        if (startDay == givenDay) return;
        
        for (uint i = startDay; i<givenDay; i++)
        {
            uint currentSnapshotIndex = dailySnapshots.length > i? i: dailySnapshots.length-1;
            uint sharesCount =
                ((settings.LONGER_PAYS_BETTER_BONUS + APY_DENORM) * SHARE_PRICE_DENORM) / 
                    (APY_DENORM * dailySnapshots[currentSnapshotIndex].sharePrice);
            uint inflationAmount = 
                (settings.CONTROLLED_APY * (dailySnapshots[currentSnapshotIndex].totalShares + sharesCount)) / 
                    (sharesCount * DAYS_IN_ONE_YEAR * APY_DENORM);
            
            if (dailySnapshots.length > i)
            {
                dailySnapshots[currentSnapshotIndex].inflationAmount += inflationAmount;
            } else
            {
                dailySnapshots.push(DailySnapshot(
                    inflationAmount,
                    dailySnapshots[currentSnapshotIndex].totalShares,
                    dailySnapshots[currentSnapshotIndex].sharePrice
                ));
            }
            emit DailySnapshotSealed(
                i,
                dailySnapshots[currentSnapshotIndex].inflationAmount,
                dailySnapshots[currentSnapshotIndex].totalShares,
                dailySnapshots[currentSnapshotIndex].sharePrice,
                getTotalTokensStaked(),
                cerbyToken.totalSupply()
            );
        }
        
        if (dailySnapshots.length == givenDay)
        {
            dailySnapshots.push(DailySnapshot(
                0,
                dailySnapshots[givenDay-1].totalShares,
                dailySnapshots[givenDay-1].sharePrice
            ));
        }
        
        uint startCachedDay = cachedInterestPerShare.length-1;
        uint endCachedDay = givenDay / CACHED_DAYS_INTEREST;
        for(uint i = startCachedDay; i<endCachedDay; i++)
        {
            uint interestPerShare;
            for(uint j = i*CACHED_DAYS_INTEREST; j<(i+1)*CACHED_DAYS_INTEREST; j++)
            {
                if (dailySnapshots[j].totalShares == 0) continue;
                
                interestPerShare += 
                    (dailySnapshots[j].inflationAmount * INTEREST_PER_SHARE_DENORM) / dailySnapshots[j].totalShares;
            }
            
            if (cachedInterestPerShare.length > i)
            {
                cachedInterestPerShare[i] = interestPerShare;
            } else {
                cachedInterestPerShare.push(interestPerShare);
            }
            emit CachedInterestPerShareSealed(
                i, // sealedDay
                cachedInterestPerShare.length - 1, // sealedCachedDay
                interestPerShare
            );
        }
        if (cachedInterestPerShare.length == endCachedDay)
        {
            cachedInterestPerShare.push(0);
        }
    }
    
    function bulkStartStake(StartStake[] calldata startStakes)
        public
        onlyRealUsers
        executeCronJobs
    {

        for(uint i; i<startStakes.length; i++)
        {
            startStake(startStakes[i]);
        }
    }
    
    function startStake(StartStake memory _startStake)
        private
        returns(uint stakeId)
    {

        require(
            _startStake.stakedAmount > 0,
            "SS: StakedAmount has to be larger than zero"
        );
        require(
            _startStake.stakedAmount <= cerbyToken.balanceOf(msg.sender),
            "SS: StakedAmount exceeds balance"
        );
        require(
            _startStake.lockedForXDays >= settings.MINIMUM_STAKE_DAYS,
            "SS: Stake must be locked for more than min days"
        );
        require(
            _startStake.lockedForXDays <= settings.MAXIMUM_STAKE_DAYS,
            "SS: Stake must be locked for less than max years"
        );
        
        cerbyToken.transferCustom(msg.sender, address(this), _startStake.stakedAmount);
        
        uint today = getCurrentDaySinceLaunch();
        Stake memory stake = Stake(
            msg.sender,
            _startStake.stakedAmount,
            today,
            _startStake.lockedForXDays,
            0,
            0
        );
        stake.maxSharesCountOnStartStake = getSharesCountByStake(stake, 0);
        
        stakes.push(
            stake
        );
        stakeId = stakes.length - 1;
        
        dailySnapshots[today].totalShares += stake.maxSharesCountOnStartStake;
        
        emit StakeStarted(
            stakeId,
            stake.owner,
            stake.stakedAmount, 
            stake.startDay,
            stake.lockedForXDays,
            stake.maxSharesCountOnStartStake
        );
        
        return stakeId;
    }
    
    function bulkEndStake(uint[] calldata stakeIds)
        public
        onlyRealUsers
        executeCronJobs
    {

        for(uint i; i<stakeIds.length; i++)
        {
            endStake(stakeIds[i]);
        }
    }
    
    function endStake(
        uint stakeId
    )
        private
        onlyStakeOwners(stakeId)
        onlyExistingStake(stakeId)
        onlyActiveStake(stakeId)
    {

        uint today = getCurrentDaySinceLaunch();
        stakes[stakeId].endDay = today;
        
        cerbyToken.transferCustom(address(this), msg.sender, stakes[stakeId].stakedAmount);
        
        uint interest;
        if (
                today < stakes[stakeId].startDay + stakes[stakeId].lockedForXDays
        ) { // Early end stake: Calculating interest similar to scrapeStake one
            Stake memory modifiedStakeToGetInterest = stakes[stakeId];
            modifiedStakeToGetInterest.lockedForXDays = today - stakes[stakeId].startDay;
            
            interest = getInterestByStake(modifiedStakeToGetInterest, today);
        } else { // Late or correct end stake
            interest = getInterestByStake(stakes[stakeId], today);
        }
        
        if (interest > 0)
        {
            cerbyToken.mintHumanAddress(msg.sender, interest);
        }
        
        uint penalty = getPenaltyByStake(stakes[stakeId], today, interest);
        if (penalty > 0) 
        {
            cerbyToken.burnHumanAddress(msg.sender, penalty);
            dailySnapshots[today].inflationAmount += penalty;
        }
        
        uint payout = stakes[stakeId].stakedAmount + interest - penalty;
        uint ROI = (payout * SHARE_PRICE_DENORM) / stakes[stakeId].stakedAmount;
        if (ROI > dailySnapshots[today].sharePrice) 
        {
           dailySnapshots[today].sharePrice = ROI;
           emit NewMaxSharePriceReached(ROI);
        }
        
        dailySnapshots[today].totalShares -= stakes[stakeId].maxSharesCountOnStartStake;
        
        emit StakeEnded(stakeId, today, interest, penalty);
    }
    
    function bulkScrapeStake(uint[] calldata stakeIds)
        public
        onlyRealUsers
        executeCronJobs
    {

        for(uint i; i<stakeIds.length; i++)
        {
            scrapeStake(stakeIds[i]);
        }
    }
    
    function scrapeStake(
        uint stakeId
    )
        private
        onlyStakeOwners(stakeId)
        onlyExistingStake(stakeId)
        onlyActiveStake(stakeId)
    {

        uint today = getCurrentDaySinceLaunch();
        require(
            today > stakes[stakeId].startDay,
            "SS: Scraping is available once in 1 day"
        );
        require(
            today < stakes[stakeId].startDay + stakes[stakeId].lockedForXDays,
            "SS: Scraping is available once while stake is In Progress status"
        );
        
        uint oldLockedForXDays = stakes[stakeId].lockedForXDays;
        uint oldSharesCount = stakes[stakeId].maxSharesCountOnStartStake;
        
        stakes[stakeId].lockedForXDays = today - stakes[stakeId].startDay;
        uint newSharesCount = getSharesCountByStake(stakes[stakeId], 0);
        
        dailySnapshots[today].totalShares = dailySnapshots[today].totalShares - oldSharesCount + newSharesCount;
        stakes[stakeId].maxSharesCountOnStartStake = newSharesCount;
        
        emit StakeUpdated(
            stakeId, 
            stakes[stakeId].lockedForXDays,
            newSharesCount
        );
        
        endStake(stakeId);
        
        uint newLockedForXDays = oldLockedForXDays - stakes[stakeId].lockedForXDays;
        startStake(StartStake(stakes[stakeId].stakedAmount, newLockedForXDays));
    }
    
    function getTotalTokensStaked()
        public
        view
        returns(uint)
    {

        return ICerbyTokenMinterBurner(cerbyToken).balanceOf(address(this));
    }
    
    function getDailySnapshotsLength()
        public
        view
        returns(uint)
    {

        return dailySnapshots.length;
    }
    
    function getCachedInterestPerShareLength()
        public
        view
        returns(uint)
    {

        return cachedInterestPerShare.length;
    }
    
    function getStakesLength()
        public
        view
        returns(uint)
    {

        return stakes.length;
    }
    
    function getInterestById(uint stakeId, uint givenDay)
        public
        view
        returns (uint)
    {

        return getInterestByStake(stakes[stakeId], givenDay);
    }
    
    function getInterestByStake(Stake memory stake, uint givenDay)
        public
        view
        returns (uint)
    {

        if (givenDay <= stake.startDay) return 0;
        
        uint interest;
        
        uint endDay = minOfTwoUints(givenDay, stake.startDay + stake.lockedForXDays);
        endDay = minOfTwoUints(endDay, dailySnapshots.length);
        
        uint sharesCount = getSharesCountByStake(stake, givenDay);
        uint startCachedDay = stake.startDay/CACHED_DAYS_INTEREST + 1;
        uint endBeforeFirstCachedDay = minOfTwoUints(endDay, startCachedDay*CACHED_DAYS_INTEREST); 
        for(uint i = stake.startDay; i<endBeforeFirstCachedDay; i++)
        {
            if (dailySnapshots[i].totalShares == 0) continue;
            
            interest += (dailySnapshots[i].inflationAmount * sharesCount) / dailySnapshots[i].totalShares;
        }
        
        uint endCachedDay = endDay/CACHED_DAYS_INTEREST; 
        for(uint i = startCachedDay; i<endCachedDay; i++)
        {
            interest += (cachedInterestPerShare[i] * sharesCount) / INTEREST_PER_SHARE_DENORM;
        }
        
        uint startAfterLastCachedDay = endDay - endDay % CACHED_DAYS_INTEREST;
        if (startAfterLastCachedDay > stake.startDay) // do not double iterate if numberOfDaysServed < CACHED_DAYS_INTEREST 
        {
            for(uint i = startAfterLastCachedDay; i<endDay; i++)
            {
                if (dailySnapshots[i].totalShares == 0) continue;
                
                interest += (dailySnapshots[i].inflationAmount * sharesCount) / dailySnapshots[i].totalShares;
            }
        }
        
        return interest;
    }
    
    function getPenaltyById(uint stakeId, uint givenDay, uint interest)
        public
        view
        returns (uint)
    {

        return getPenaltyByStake(stakes[stakeId], givenDay, interest);
    }
    
    function getPenaltyByStake(Stake memory stake, uint givenDay, uint interest)
        public
        view
        returns (uint)
    {

        uint penalty;
        uint howManyDaysServed = givenDay > stake.startDay? givenDay - stake.startDay: 0;
        uint riskAmount = stake.stakedAmount + interest;
        
        if (howManyDaysServed <= settings.MINIMUM_DAYS_FOR_HIGH_PENALTY) // Stake just started or less than 7 days passed)
        {
            penalty = riskAmount; // 100%
        } else if (howManyDaysServed <= stake.lockedForXDays) 
        {
            penalty = 
                (riskAmount * (stake.lockedForXDays - howManyDaysServed)) / (stake.lockedForXDays - settings.MINIMUM_DAYS_FOR_HIGH_PENALTY);
        } else if (howManyDaysServed <= stake.lockedForXDays + settings.END_STAKE_FROM)
        {
            penalty = 0;
        } else if (howManyDaysServed <= stake.lockedForXDays + settings.END_STAKE_FROM + settings.END_STAKE_TO) {
            penalty = 
                (riskAmount * 9 * (howManyDaysServed - stake.lockedForXDays - settings.END_STAKE_FROM)) / (10 * settings.END_STAKE_TO);
        } else // if (howManyDaysServed > stake.lockedForXDays + settings.END_STAKE_FROM + settings.END_STAKE_TO)
        {
            penalty = (riskAmount * 9) / 10;
        } 
        
        return penalty;
    }
    
    function getSharesCountById(uint stakeId, uint givenDay)
        public
        view
        returns(uint)
    {

        return getSharesCountByStake(stakes[stakeId], givenDay);
    }
    
    function getSharesCountByStake(Stake memory stake, uint givenDay)
        public
        view
        returns (uint)
    {

        uint numberOfDaysServed;
        if (givenDay == 0)
        {
            numberOfDaysServed = stake.lockedForXDays;
        } else if (givenDay > stake.startDay)
        {
            numberOfDaysServed = givenDay - stake.startDay;
        } else // givenDay > 0 && givenDay < stake.startDay
        {
            return 0;
        }
        numberOfDaysServed = minOfTwoUints(numberOfDaysServed, 10*DAYS_IN_ONE_YEAR);
        
        uint initialSharesCount = 
            (stake.stakedAmount * SHARE_PRICE_DENORM) / dailySnapshots[stake.startDay].sharePrice;
        uint longerPaysBetterSharesCount =
            (settings.LONGER_PAYS_BETTER_BONUS * numberOfDaysServed * stake.stakedAmount * SHARE_PRICE_DENORM) / 
                (APY_DENORM * 10 * DAYS_IN_ONE_YEAR * dailySnapshots[stake.startDay].sharePrice);
        uint smallerPaysBetterSharesCountMultiplier;
        if (stake.stakedAmount <= MINIMUM_SMALLER_PAYS_BETTER)
        {
            smallerPaysBetterSharesCountMultiplier = APY_DENORM + settings.SMALLER_PAYS_BETTER_BONUS;
        } else if (
            MINIMUM_SMALLER_PAYS_BETTER < stake.stakedAmount &&
            stake.stakedAmount < MAXIMUM_SMALLER_PAYS_BETTER
        ) {
            smallerPaysBetterSharesCountMultiplier = 
                APY_DENORM + 
                    (settings.SMALLER_PAYS_BETTER_BONUS * (MAXIMUM_SMALLER_PAYS_BETTER - stake.stakedAmount)) /
                        (MAXIMUM_SMALLER_PAYS_BETTER - MINIMUM_SMALLER_PAYS_BETTER);
        } else // MAXIMUM_SMALLER_PAYS_BETTER >= stake.stakedAmount
        {
            smallerPaysBetterSharesCountMultiplier = APY_DENORM;
        }
        uint sharesCount = 
            ((initialSharesCount + longerPaysBetterSharesCount) * smallerPaysBetterSharesCountMultiplier) / 
                APY_DENORM;
                
        return sharesCount;
    }
    
    function getCurrentDaySinceLaunch()
        public
        view
        returns (uint)
    {

        return 1 + block.timestamp / SECONDS_IN_ONE_DAY - launchTimestamp / SECONDS_IN_ONE_DAY;
    }
    
    function getCurrentCachedPerShareDay()
        public
        view
        returns (uint)
    {

        return getCurrentDaySinceLaunch() / CACHED_DAYS_INTEREST;
    }
    
    function minOfTwoUints(uint uint1, uint uint2)
        private
        pure
        returns(uint)
    {

        if (uint1 < uint2) return uint1;
        return uint2;
    }
}