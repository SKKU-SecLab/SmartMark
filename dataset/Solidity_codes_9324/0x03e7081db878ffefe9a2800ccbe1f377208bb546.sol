
pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// Apache-2.0
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

interface IRewards {

    function registerUserAction(address user) external;


    function setNewAPR(uint256 _apr) external;

}// Apache-2.0
pragma solidity 0.7.6;


library LibBarnStorage {

    bytes32 constant STORAGE_POSITION = keccak256("com.barnbridge.barn.storage");

    struct Checkpoint {
        uint256 timestamp;
        uint256 amount;
    }

    struct Stake {
        uint256 timestamp;
        uint256 amount;
        uint256 expiryTimestamp;
        address delegatedTo;
    }

    struct NodeInfo {
        bytes32 p2pkey;
        uint8   dataType;
    }

    struct Storage {
        bool initialized;

        mapping(address => Stake[]) userStakeHistory;

        Checkpoint[] bondStakedHistory;

        mapping(address => Checkpoint[]) delegatedPowerHistory;

        mapping(address => NodeInfo) nodeInfo;

        IERC20 bond;
        IRewards rewards;
    }

    function barnStorage() internal pure returns (Storage storage ds) {

        bytes32 position = STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}// Apache-2.0
pragma solidity 0.7.6;


interface IBarn {

    function deposit(uint256 amount) external;


    function withdraw(uint256 amount) external;


    function lock(uint256 timestamp) external;


    function delegate(address to) external;


    function stopDelegate() external;


    function lockCreatorBalance(address user, uint256 timestamp) external;


    function balanceOf(address user) external view returns (uint256);


    function balanceAtTs(address user, uint256 timestamp) external view returns (uint256);


    function stakeAtTs(address user, uint256 timestamp) external view returns (LibBarnStorage.Stake memory);


    function votingPower(address user) external view returns (uint256);


    function votingPowerAtTs(address user, uint256 timestamp) external view returns (uint256);


    function bondStaked() external view returns (uint256);


    function bondStakedAtTs(uint256 timestamp) external view returns (uint256);


    function delegatedPower(address user) external view returns (uint256);


    function delegatedPowerAtTs(address user, uint256 timestamp) external view returns (uint256);


    function multiplierAtTs(address user, uint256 timestamp) external view returns (uint256);


    function userLockedUntil(address user) external view returns (uint256);


    function userDelegatedTo(address user) external view returns (address);


    function bondCirculatingSupply() external view returns (uint256);

}// Apache-2.0
pragma solidity 0.7.6;

library LibDiamondStorage {

    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage");

    struct Facet {
        address facetAddress;
        uint16 selectorPosition;
    }

    struct DiamondStorage {
        mapping(bytes4 => Facet) facets;
        bytes4[] selectors;

        mapping(bytes4 => bool) supportedInterfaces;

        address contractOwner;
    }

    function diamondStorage() internal pure returns (DiamondStorage storage ds) {

        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}// Apache-2.0
pragma solidity 0.7.6;


library LibOwnership {

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function setContractOwner(address _newOwner) internal {

        LibDiamondStorage.DiamondStorage storage ds = LibDiamondStorage.diamondStorage();

        address previousOwner = ds.contractOwner;
        require(previousOwner != _newOwner, "Previous owner and new owner must be different");

        ds.contractOwner = _newOwner;

        emit OwnershipTransferred(previousOwner, _newOwner);
    }

    function contractOwner() internal view returns (address contractOwner_) {

        contractOwner_ = LibDiamondStorage.diamondStorage().contractOwner;
    }

    function enforceIsContractOwner() view internal {

        require(msg.sender == LibDiamondStorage.diamondStorage().contractOwner, "Must be contract owner");
    }

    modifier onlyOwner {

        require(msg.sender == LibDiamondStorage.diamondStorage().contractOwner, "Must be contract owner");
        _;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// Apache-2.0
pragma solidity 0.7.6;


contract BarnFacet {

    using SafeMath for uint256;

    uint256 constant public MAX_LOCK = 365 days;
    uint256 constant BASE_MULTIPLIER = 1e18;

    event Deposit(address indexed user, uint256 amount, uint256 newBalance);
    event Withdraw(address indexed user, uint256 amountWithdrew, uint256 amountLeft);
    event Lock(address indexed user, uint256 timestamp);
    event Timelock(address indexed user, uint256 timestamp, uint8 dataType, bytes32 data);
    event UnlockTimelock(address indexed user, uint8 dataType);
    event Delegate(address indexed from, address indexed to);
    event DelegatedPowerIncreased(address indexed from, address indexed to, uint256 amount, uint256 to_newDelegatedPower);
    event DelegatedPowerDecreased(address indexed from, address indexed to, uint256 amount, uint256 to_newDelegatedPower);

    function initBarn(address _bond, address _rewards) public {

        require(_bond != address(0), "BOND address must not be 0x0");

        LibBarnStorage.Storage storage ds = LibBarnStorage.barnStorage();

        require(!ds.initialized, "Barn: already initialized");
        LibOwnership.enforceIsContractOwner();

        ds.initialized = true;

        ds.bond = IERC20(_bond);
        ds.rewards = IRewards(_rewards);
    }

    function deposit(uint256 amount) public {

        require(amount > 0, "Amount must be greater than 0");

        LibBarnStorage.Storage storage ds = LibBarnStorage.barnStorage();
        uint256 allowance = ds.bond.allowance(msg.sender, address(this));
        require(allowance >= amount, "Token allowance too small");

        if (address(ds.rewards) != address(0)) {
            ds.rewards.registerUserAction(msg.sender);
        }

        uint256 newBalance = balanceOf(msg.sender).add(amount);
        _updateUserBalance(ds.userStakeHistory[msg.sender], newBalance);
        _updateLockedBond(bondStakedAtTs(block.timestamp).add(amount));

        address delegatedTo = userDelegatedTo(msg.sender);
        if (delegatedTo != address(0)) {
            uint256 newDelegatedPower = delegatedPower(delegatedTo).add(amount);
            _updateDelegatedPower(ds.delegatedPowerHistory[delegatedTo], newDelegatedPower);

            emit DelegatedPowerIncreased(msg.sender, delegatedTo, amount, newDelegatedPower);
        }

        ds.bond.transferFrom(msg.sender, address(this), amount);

        emit Deposit(msg.sender, amount, newBalance);
    }

    function withdraw(uint256 amount) public {

        require(amount > 0, "Amount must be greater than 0");
        require(userLockedUntil(msg.sender) <= block.timestamp, "User balance is locked");

        uint256 balance = balanceOf(msg.sender);
        require(balance >= amount, "Insufficient balance");

        LibBarnStorage.Storage storage ds = LibBarnStorage.barnStorage();

        if (address(ds.rewards) != address(0)) {
            ds.rewards.registerUserAction(msg.sender);
        }

        _updateUserBalance(ds.userStakeHistory[msg.sender], balance.sub(amount));
        _updateLockedBond(bondStakedAtTs(block.timestamp).sub(amount));

        address delegatedTo = userDelegatedTo(msg.sender);
        if (delegatedTo != address(0)) {
            uint256 newDelegatedPower = delegatedPower(delegatedTo).sub(amount);
            _updateDelegatedPower(ds.delegatedPowerHistory[delegatedTo], newDelegatedPower);

            emit DelegatedPowerDecreased(msg.sender, delegatedTo, amount, newDelegatedPower);
        }

        _deleteUserP2pKey(msg.sender);

        ds.bond.transfer(msg.sender, amount);

        emit Withdraw(msg.sender, amount, balance.sub(amount));
    }

    function lock(uint256 timestamp) public {

        require(timestamp > block.timestamp, "Timestamp must be in the future");
        require(timestamp <= block.timestamp + MAX_LOCK, "Timestamp too big");
        require(balanceOf(msg.sender) > 0, "Sender has no balance");

        LibBarnStorage.Storage storage ds = LibBarnStorage.barnStorage();
        LibBarnStorage.Stake[] storage checkpoints = ds.userStakeHistory[msg.sender];
        LibBarnStorage.Stake storage currentStake = checkpoints[checkpoints.length - 1];

        require(timestamp > currentStake.expiryTimestamp, "New timestamp lower than current lock timestamp");

        _updateUserLock(checkpoints, timestamp);
        emit Lock(msg.sender, timestamp);
    }

    function depositAndLock(uint256 amount, uint256 timestamp) public {

        deposit(amount);
        lock(timestamp);
    }

    function addOrAdjusttimelock(uint256 _amount, uint256 _timestamp, uint8 _type, bytes32 _data) public {

        deposit(_amount);
        lock(_timestamp);
        _updateUserP2pKey(msg.sender, _type, _data);
        emit Timelock(msg.sender, _timestamp, _type, _data);
    }

    function delegate(address to) public {

        require(msg.sender != to, "Can't delegate to self");

        uint256 senderBalance = balanceOf(msg.sender);
        require(senderBalance > 0, "No balance to delegate");

        LibBarnStorage.Storage storage ds = LibBarnStorage.barnStorage();

        emit Delegate(msg.sender, to);

        address delegatedTo = userDelegatedTo(msg.sender);
        if (delegatedTo != address(0)) {
            uint256 newDelegatedPower = delegatedPower(delegatedTo).sub(senderBalance);
            _updateDelegatedPower(ds.delegatedPowerHistory[delegatedTo], newDelegatedPower);

            emit DelegatedPowerDecreased(msg.sender, delegatedTo, senderBalance, newDelegatedPower);
        }

        if (to != address(0)) {
            uint256 newDelegatedPower = delegatedPower(to).add(senderBalance);
            _updateDelegatedPower(ds.delegatedPowerHistory[to], newDelegatedPower);

            emit DelegatedPowerIncreased(msg.sender, to, senderBalance, newDelegatedPower);
        }

        _updateUserDelegatedTo(ds.userStakeHistory[msg.sender], to);
    }

    function stopDelegate() public {

        return delegate(address(0));
    }

    function balanceOf(address user) public view returns (uint256) {

        return balanceAtTs(user, block.timestamp);
    }

    function balanceAtTs(address user, uint256 timestamp) public view returns (uint256) {

        LibBarnStorage.Stake memory stake = stakeAtTs(user, timestamp);

        return stake.amount;
    }

    function stakeAtTs(address user, uint256 timestamp) public view returns (LibBarnStorage.Stake memory) {

        LibBarnStorage.Storage storage ds = LibBarnStorage.barnStorage();
        LibBarnStorage.Stake[] storage stakeHistory = ds.userStakeHistory[user];

        if (stakeHistory.length == 0 || timestamp < stakeHistory[0].timestamp) {
            return LibBarnStorage.Stake(block.timestamp, 0, block.timestamp, address(0));
        }

        uint256 min = 0;
        uint256 max = stakeHistory.length - 1;

        if (timestamp >= stakeHistory[max].timestamp) {
            return stakeHistory[max];
        }

        while (max > min) {
            uint256 mid = (max + min + 1) / 2;
            if (stakeHistory[mid].timestamp <= timestamp) {
                min = mid;
            } else {
                max = mid - 1;
            }
        }

        return stakeHistory[min];
    }

    function votingPower(address user) public view returns (uint256) {

        return votingPowerAtTs(user, block.timestamp);
    }

    function votingPowerAtTs(address user, uint256 timestamp) public view returns (uint256) {

        LibBarnStorage.Stake memory stake = stakeAtTs(user, timestamp);

        uint256 ownVotingPower;

        if (stake.delegatedTo != address(0)) {
            ownVotingPower = 0;
        } else {
            uint256 balance = stake.amount;
            uint256 multiplier = _stakeMultiplier(stake, timestamp);
            ownVotingPower = balance.mul(multiplier).div(BASE_MULTIPLIER);
        }

        uint256 delegatedVotingPower = delegatedPowerAtTs(user, timestamp);

        return ownVotingPower.add(delegatedVotingPower);
    }

    function bondStaked() public view returns (uint256) {

        return bondStakedAtTs(block.timestamp);
    }

    function bondStakedAtTs(uint256 timestamp) public view returns (uint256) {

        return _checkpointsBinarySearch(LibBarnStorage.barnStorage().bondStakedHistory, timestamp);
    }

    function delegatedPower(address user) public view returns (uint256) {

        return delegatedPowerAtTs(user, block.timestamp);
    }

    function delegatedPowerAtTs(address user, uint256 timestamp) public view returns (uint256) {

        return _checkpointsBinarySearch(LibBarnStorage.barnStorage().delegatedPowerHistory[user], timestamp);
    }

    function multiplierOf(address user) public view returns (uint256) {

        return multiplierAtTs(user, block.timestamp);
    }

    function multiplierAtTs(address user, uint256 timestamp) public view returns (uint256) {

        LibBarnStorage.Stake memory stake = stakeAtTs(user, timestamp);

        return _stakeMultiplier(stake, timestamp);
    }

    function userLockedUntil(address user) public view returns (uint256) {

        LibBarnStorage.Stake memory c = stakeAtTs(user, block.timestamp);

        return c.expiryTimestamp;
    }

    function checkTimeLock(address _user, uint8 _type) public view returns (uint256 amount, uint256 expiry, bytes32 data) {

        LibBarnStorage.NodeInfo memory nInfo = LibBarnStorage.barnStorage().nodeInfo[_user];
        if (nInfo.dataType == _type) {
            amount = balanceOf(_user);
            expiry = userLockedUntil(_user);
            data = nInfo.p2pkey;
        }
    }

    function userDelegatedTo(address user) public view returns (address) {

        LibBarnStorage.Stake memory c = stakeAtTs(user, block.timestamp);

        return c.delegatedTo;
    }

    function _checkpointsBinarySearch(LibBarnStorage.Checkpoint[] storage checkpoints, uint256 timestamp) internal view returns (uint256) {

        if (checkpoints.length == 0 || timestamp < checkpoints[0].timestamp) {
            return 0;
        }

        uint256 min = 0;
        uint256 max = checkpoints.length - 1;

        if (timestamp >= checkpoints[max].timestamp) {
            return checkpoints[max].amount;
        }

        while (max > min) {
            uint256 mid = (max + min + 1) / 2;
            if (checkpoints[mid].timestamp <= timestamp) {
                min = mid;
            } else {
                max = mid - 1;
            }
        }

        return checkpoints[min].amount;
    }

    function _stakeMultiplier(LibBarnStorage.Stake memory stake, uint256 timestamp) internal view returns (uint256) {

        if (timestamp >= stake.expiryTimestamp) {
            return BASE_MULTIPLIER;
        }

        uint256 diff = stake.expiryTimestamp - timestamp;
        if (diff >= MAX_LOCK) {
            return BASE_MULTIPLIER.mul(2);
        }

        return BASE_MULTIPLIER.add(diff.mul(BASE_MULTIPLIER).div(MAX_LOCK));
    }

    function _updateUserBalance(LibBarnStorage.Stake[] storage checkpoints, uint256 amount) internal {

        if (checkpoints.length == 0) {
            checkpoints.push(LibBarnStorage.Stake(block.timestamp, amount, block.timestamp, address(0)));
        } else {
            LibBarnStorage.Stake storage old = checkpoints[checkpoints.length - 1];

            if (old.timestamp == block.timestamp) {
                old.amount = amount;
            } else {
                checkpoints.push(LibBarnStorage.Stake(block.timestamp, amount, old.expiryTimestamp, old.delegatedTo));
            }
        }
    }

    function _updateUserLock(LibBarnStorage.Stake[] storage checkpoints, uint256 expiryTimestamp) internal {

        LibBarnStorage.Stake storage old = checkpoints[checkpoints.length - 1];

        if (old.timestamp < block.timestamp) {
            checkpoints.push(LibBarnStorage.Stake(block.timestamp, old.amount, expiryTimestamp, old.delegatedTo));
        } else {
            old.expiryTimestamp = expiryTimestamp;
        }
    }

    function _updateUserDelegatedTo(LibBarnStorage.Stake[] storage checkpoints, address to) internal {

        LibBarnStorage.Stake storage old = checkpoints[checkpoints.length - 1];

        if (old.timestamp < block.timestamp) {
            checkpoints.push(LibBarnStorage.Stake(block.timestamp, old.amount, old.expiryTimestamp, to));
        } else {
            old.delegatedTo = to;
        }
    }

    function _updateDelegatedPower(LibBarnStorage.Checkpoint[] storage checkpoints, uint256 amount) internal {

        if (checkpoints.length == 0 || checkpoints[checkpoints.length - 1].timestamp < block.timestamp) {
            checkpoints.push(LibBarnStorage.Checkpoint(block.timestamp, amount));
        } else {
            LibBarnStorage.Checkpoint storage old = checkpoints[checkpoints.length - 1];
            old.amount = amount;
        }
    }

    function _updateLockedBond(uint256 amount) internal {

        LibBarnStorage.Storage storage ds = LibBarnStorage.barnStorage();

        if (ds.bondStakedHistory.length == 0 || ds.bondStakedHistory[ds.bondStakedHistory.length - 1].timestamp < block.timestamp) {
            ds.bondStakedHistory.push(LibBarnStorage.Checkpoint(block.timestamp, amount));
        } else {
            LibBarnStorage.Checkpoint storage old = ds.bondStakedHistory[ds.bondStakedHistory.length - 1];
            old.amount = amount;
        }
    }

    function _updateUserP2pKey(address _user, uint8 _type, bytes32 _data) internal {

        LibBarnStorage.Storage storage ds = LibBarnStorage.barnStorage();
        LibBarnStorage.NodeInfo storage nInfo = ds.nodeInfo[_user];
        nInfo.p2pkey = _data;
        nInfo.dataType = _type;
    }

    function _deleteUserP2pKey(address _user) internal {

        LibBarnStorage.Storage storage ds = LibBarnStorage.barnStorage();
        delete ds.nodeInfo[_user];
    }
}