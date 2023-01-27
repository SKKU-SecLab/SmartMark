
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


library LibReignStorage {


    bytes32 constant STORAGE_POSITION = keccak256("org.sovreign.reign.storage");

    struct Checkpoint {
        uint256 timestamp;
        uint256 amount;
    }

    struct EpochBalance {
        uint128 epochId;
        uint128 multiplier;
        uint256 startBalance;
        uint256 newDeposits;
    }

    struct Stake {
        uint256 timestamp;
        uint256 amount;
        uint256 expiryTimestamp;
        address delegatedTo;
        uint256 stakingBoost;
    }

    struct Storage {
        bool initialized;
        mapping(address => Stake[]) userStakeHistory;
        mapping(address => EpochBalance[]) userBalanceHistory;
        mapping(address => uint128) lastWithdrawEpochId;
        Checkpoint[] reignStakedHistory;
        mapping(address => Checkpoint[]) delegatedPowerHistory;
        IERC20 reign; // the reign Token
        uint256 epoch1Start;
        uint256 epochDuration;
    }

    function reignStorage() internal pure returns (Storage storage ds) {

        bytes32 position = STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}// Apache-2.0
pragma solidity 0.7.6;


interface IReign {

    function BASE_MULTIPLIER() external view returns (uint256);


    function deposit(uint256 amount) external;


    function withdraw(uint256 amount) external;


    function lock(uint256 timestamp) external;


    function delegate(address to) external;


    function stopDelegate() external;


    function lockCreatorBalance(address user, uint256 timestamp) external;


    function balanceOf(address user) external view returns (uint256);


    function balanceAtTs(address user, uint256 timestamp)
        external
        view
        returns (uint256);


    function stakeAtTs(address user, uint256 timestamp)
        external
        view
        returns (LibReignStorage.Stake memory);


    function votingPower(address user) external view returns (uint256);


    function votingPowerAtTs(address user, uint256 timestamp)
        external
        view
        returns (uint256);


    function reignStaked() external view returns (uint256);


    function reignStakedAtTs(uint256 timestamp) external view returns (uint256);


    function delegatedPower(address user) external view returns (uint256);


    function delegatedPowerAtTs(address user, uint256 timestamp)
        external
        view
        returns (uint256);


    function stakingBoost(address user) external view returns (uint256);


    function stackingBoostAtTs(address user, uint256 timestamp)
        external
        view
        returns (uint256);


    function userLockedUntil(address user) external view returns (uint256);


    function userDelegatedTo(address user) external view returns (address);


    function userLastAction(address user) external view returns (uint256);


    function reignCirculatingSupply() external view returns (uint256);


    function getEpochDuration() external view returns (uint256);


    function getEpoch1Start() external view returns (uint256);


    function getCurrentEpoch() external view returns (uint128);


    function stakingBoostAtEpoch(address, uint128)
        external
        view
        returns (uint256);


    function getEpochUserBalance(address, uint128)
        external
        view
        returns (uint256);

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


contract ReignFacet {

    using SafeMath for uint256;

    uint256 public constant MAX_LOCK = 365 days * 2; //two years
    uint256 public constant BASE_STAKE_MULTIPLIER = 1 * 10**18;
    uint128 public constant BASE_BALANCE_MULTIPLIER = uint128(1 * 10**18);

    mapping(uint128 => bool) private _isInitialized;
    mapping(uint128 => uint256) private _initialisedAt;
    mapping(address => uint256) private _balances;

    event Deposit(address indexed user, uint256 amount, uint256 newBalance);
    event Withdraw(
        address indexed user,
        uint256 amountWithdrew,
        uint256 amountLeft
    );
    event Lock(address indexed user, uint256 timestamp);
    event Delegate(address indexed from, address indexed to);
    event DelegatedPowerIncreased(
        address indexed from,
        address indexed to,
        uint256 amount,
        uint256 to_newDelegatedPower
    );
    event DelegatedPowerDecreased(
        address indexed from,
        address indexed to,
        uint256 amount,
        uint256 to_newDelegatedPower
    );
    event InitEpoch(address indexed caller, uint128 indexed epochId);

    function initReign(
        address _reignToken,
        uint256 _epoch1Start,
        uint256 _epochDuration
    ) public {

        require(
            _reignToken != address(0),
            "Reign Token address must not be 0x0"
        );

        LibReignStorage.Storage storage ds = LibReignStorage.reignStorage();

        require(!ds.initialized, "Reign: already initialized");
        LibOwnership.enforceIsContractOwner();

        ds.initialized = true;

        ds.reign = IERC20(_reignToken);
        ds.epoch1Start = _epoch1Start;
        ds.epochDuration = _epochDuration;
    }

    function deposit(uint256 amount) public {

        require(amount > 0, "Amount must be greater than 0");

        LibReignStorage.Storage storage ds = LibReignStorage.reignStorage();
        uint256 allowance = ds.reign.allowance(msg.sender, address(this));
        require(allowance >= amount, "Token allowance too small");

        _balances[msg.sender] = _balances[msg.sender].add(amount);

        _updateStake(ds.userStakeHistory[msg.sender], _balances[msg.sender]);
        _increaseEpochBalance(ds.userBalanceHistory[msg.sender], amount);
        _updateLockedReign(reignStaked().add(amount));

        address delegatedTo = userDelegatedTo(msg.sender);
        if (delegatedTo != address(0)) {
            uint256 newDelegatedPower = delegatedPower(delegatedTo).add(amount);
            _updateDelegatedPower(
                ds.delegatedPowerHistory[delegatedTo],
                newDelegatedPower
            );

            emit DelegatedPowerIncreased(
                msg.sender,
                delegatedTo,
                amount,
                newDelegatedPower
            );
        }

        ds.reign.transferFrom(msg.sender, address(this), amount);

        emit Deposit(msg.sender, amount, _balances[msg.sender]);
    }

    function withdraw(uint256 amount) public {

        require(amount > 0, "Amount must be greater than 0");
        require(
            userLockedUntil(msg.sender) <= block.timestamp,
            "User balance is locked"
        );

        uint256 balance = balanceOf(msg.sender);
        require(balance >= amount, "Insufficient balance");

        _balances[msg.sender] = balance.sub(amount);

        LibReignStorage.Storage storage ds = LibReignStorage.reignStorage();

        _updateStake(ds.userStakeHistory[msg.sender], _balances[msg.sender]);
        _decreaseEpochBalance(ds.userBalanceHistory[msg.sender], amount);
        _updateLockedReign(reignStaked().sub(amount));

        address delegatedTo = userDelegatedTo(msg.sender);
        if (delegatedTo != address(0)) {
            uint256 newDelegatedPower = delegatedPower(delegatedTo).sub(amount);
            _updateDelegatedPower(
                ds.delegatedPowerHistory[delegatedTo],
                newDelegatedPower
            );

            emit DelegatedPowerDecreased(
                msg.sender,
                delegatedTo,
                amount,
                newDelegatedPower
            );
        }

        ds.reign.transfer(msg.sender, amount);

        emit Withdraw(msg.sender, amount, balance.sub(amount));
    }

    function lock(uint256 timestamp) public {

        require(timestamp > block.timestamp, "Timestamp must be in the future");
        require(timestamp <= block.timestamp + MAX_LOCK, "Timestamp too big");
        require(balanceOf(msg.sender) > 0, "Sender has no balance");

        LibReignStorage.Storage storage ds = LibReignStorage.reignStorage();
        LibReignStorage.Stake[] storage checkpoints = ds.userStakeHistory[
            msg.sender
        ];
        LibReignStorage.Stake storage currentStake = checkpoints[
            checkpoints.length - 1
        ];
        if (!epochIsInitialized(getEpoch())) {
            _initEpoch(getEpoch());
        }

        require(
            timestamp > currentStake.expiryTimestamp,
            "New timestamp lower than current lock timestamp"
        );

        _updateUserLock(checkpoints, timestamp);

        emit Lock(msg.sender, timestamp);
    }

    function depositAndLock(uint256 amount, uint256 timestamp) public {

        deposit(amount);
        lock(timestamp);
    }

    function delegate(address to) public {

        require(msg.sender != to, "Can't delegate to self");

        uint256 senderBalance = balanceOf(msg.sender);
        require(senderBalance > 0, "No balance to delegate");

        LibReignStorage.Storage storage ds = LibReignStorage.reignStorage();

        emit Delegate(msg.sender, to);

        address delegatedTo = userDelegatedTo(msg.sender);
        if (delegatedTo != address(0)) {
            uint256 newDelegatedPower = delegatedPower(delegatedTo).sub(
                senderBalance
            );
            _updateDelegatedPower(
                ds.delegatedPowerHistory[delegatedTo],
                newDelegatedPower
            );

            emit DelegatedPowerDecreased(
                msg.sender,
                delegatedTo,
                senderBalance,
                newDelegatedPower
            );
        }

        if (to != address(0)) {
            uint256 newDelegatedPower = delegatedPower(to).add(senderBalance);
            _updateDelegatedPower(
                ds.delegatedPowerHistory[to],
                newDelegatedPower
            );

            emit DelegatedPowerIncreased(
                msg.sender,
                to,
                senderBalance,
                newDelegatedPower
            );
        }

        _updateUserDelegatedTo(ds.userStakeHistory[msg.sender], to);
    }

    function stopDelegate() public {

        return delegate(address(0));
    }


    function balanceOf(address user) public view returns (uint256) {

        return _balances[user];
    }

    function balanceAtTs(address user, uint256 timestamp)
        public
        view
        returns (uint256)
    {

        LibReignStorage.Stake memory stake = stakeAtTs(user, timestamp);

        return stake.amount;
    }

    function getEpochUserBalance(address user, uint128 epochId)
        public
        view
        returns (uint256)
    {

        LibReignStorage.EpochBalance memory epochBalance = balanceCheckAtEpoch(
            user,
            epochId
        );

        return getEpochEffectiveBalance(epochBalance);
    }

    function getEpochEffectiveBalance(LibReignStorage.EpochBalance memory c)
        internal
        pure
        returns (uint256)
    {

        return
            _getEpochBalance(c).mul(c.multiplier).div(BASE_BALANCE_MULTIPLIER);
    }

    function balanceCheckAtEpoch(address user, uint128 epochId)
        public
        view
        returns (LibReignStorage.EpochBalance memory)
    {

        LibReignStorage.Storage storage ds = LibReignStorage.reignStorage();
        LibReignStorage.EpochBalance[] storage balanceHistory = ds
            .userBalanceHistory[user];

        if (balanceHistory.length == 0 || epochId < balanceHistory[0].epochId) {
            return
                LibReignStorage.EpochBalance(
                    epochId,
                    BASE_BALANCE_MULTIPLIER,
                    0,
                    0
                );
        }

        uint256 min = 0;
        uint256 max = balanceHistory.length - 1;

        if (epochId >= balanceHistory[max].epochId) {
            return balanceHistory[max];
        }

        while (max > min) {
            uint256 mid = (max + min + 1) / 2;
            if (balanceHistory[mid].epochId <= epochId) {
                min = mid;
            } else {
                max = mid - 1;
            }
        }

        return balanceHistory[min];
    }

    function stakeAtTs(address user, uint256 timestamp)
        public
        view
        returns (LibReignStorage.Stake memory)
    {

        LibReignStorage.Storage storage ds = LibReignStorage.reignStorage();
        LibReignStorage.Stake[] storage stakeHistory = ds.userStakeHistory[
            user
        ];

        if (stakeHistory.length == 0 || timestamp < stakeHistory[0].timestamp) {
            return
                LibReignStorage.Stake(
                    block.timestamp,
                    0,
                    block.timestamp,
                    address(0),
                    BASE_STAKE_MULTIPLIER
                );
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

    function votingPowerAtTs(address user, uint256 timestamp)
        public
        view
        returns (uint256)
    {

        LibReignStorage.Stake memory stake = stakeAtTs(user, timestamp);

        uint256 ownVotingPower;

        if (stake.delegatedTo != address(0)) {
            ownVotingPower = 0;
        } else {
            ownVotingPower = stake.amount;
        }

        uint256 delegatedVotingPower = delegatedPowerAtTs(user, timestamp);
        return ownVotingPower.add(delegatedVotingPower);
    }

    function reignStaked() public view returns (uint256) {

        return reignStakedAtTs(block.timestamp);
    }

    function reignStakedAtTs(uint256 timestamp) public view returns (uint256) {

        return
            _checkpointSearch(
                LibReignStorage.reignStorage().reignStakedHistory,
                timestamp
            );
    }

    function delegatedPower(address user) public view returns (uint256) {

        return delegatedPowerAtTs(user, block.timestamp);
    }

    function delegatedPowerAtTs(address user, uint256 timestamp)
        public
        view
        returns (uint256)
    {

        return
            _checkpointSearch(
                LibReignStorage.reignStorage().delegatedPowerHistory[user],
                timestamp
            );
    }

    function stakingBoost(address user) public view returns (uint256) {

        return stakingBoostAtEpoch(user, getEpoch());
    }

    function stakingBoostAtEpoch(address user, uint128 epochId)
        public
        view
        returns (uint256)
    {

        uint256 epochTime;
        if (epochId == getEpoch() || _initialisedAt[epochId] == 0) {
            epochTime = block.timestamp;
        } else {
            epochTime = _initialisedAt[epochId];
        }
        LibReignStorage.Stake memory stake = stakeAtTs(user, epochTime);
        if (block.timestamp > stake.expiryTimestamp) {
            return BASE_STAKE_MULTIPLIER;
        }

        return stake.stakingBoost;
    }

    function userLockedUntil(address user) public view returns (uint256) {

        LibReignStorage.Stake memory stake = stakeAtTs(user, block.timestamp);

        return stake.expiryTimestamp;
    }

    function userDelegatedTo(address user) public view returns (address) {

        LibReignStorage.Stake memory stake = stakeAtTs(user, block.timestamp);

        return stake.delegatedTo;
    }

    function userLastAction(address user) public view returns (uint256) {

        LibReignStorage.Stake memory stake = stakeAtTs(user, block.timestamp);

        return stake.timestamp;
    }

    function getEpoch() public view returns (uint128) {

        LibReignStorage.Storage storage ds = LibReignStorage.reignStorage();

        if (block.timestamp < ds.epoch1Start) {
            return 0;
        }

        return
            uint128((block.timestamp - ds.epoch1Start) / ds.epochDuration + 1);
    }

    function currentEpochMultiplier() public view returns (uint128) {

        LibReignStorage.Storage storage ds = LibReignStorage.reignStorage();
        uint128 currentEpoch = getEpoch();
        uint256 currentEpochEnd = ds.epoch1Start +
            currentEpoch *
            ds.epochDuration;
        uint256 timeLeft = currentEpochEnd - block.timestamp;
        uint128 multiplier = uint128(
            (timeLeft * BASE_BALANCE_MULTIPLIER) / ds.epochDuration
        );

        return multiplier;
    }

    function computeNewMultiplier(
        uint256 prevBalance,
        uint128 prevMultiplier,
        uint256 amount,
        uint128 currentMultiplier
    ) public pure returns (uint128) {

        uint256 prevAmount = prevBalance.mul(prevMultiplier).div(
            BASE_BALANCE_MULTIPLIER
        );
        uint256 addAmount = amount.mul(currentMultiplier).div(
            BASE_BALANCE_MULTIPLIER
        );
        uint128 newMultiplier = uint128(
            prevAmount.add(addAmount).mul(BASE_BALANCE_MULTIPLIER).div(
                prevBalance.add(amount)
            )
        );

        return newMultiplier;
    }

    function epochIsInitialized(uint128 epochId) public view returns (bool) {

        return _isInitialized[epochId];
    }


    function _updateStake(
        LibReignStorage.Stake[] storage checkpoints,
        uint256 amount
    ) internal {

        if (checkpoints.length == 0) {
            checkpoints.push(
                LibReignStorage.Stake(
                    block.timestamp,
                    amount,
                    block.timestamp,
                    address(0),
                    BASE_STAKE_MULTIPLIER
                )
            );
        } else {
            LibReignStorage.Stake storage old = checkpoints[
                checkpoints.length - 1
            ];

            if (old.timestamp == block.timestamp) {
                old.amount = amount;
            } else {
                checkpoints.push(
                    LibReignStorage.Stake(
                        block.timestamp,
                        amount,
                        old.expiryTimestamp,
                        old.delegatedTo,
                        old.stakingBoost
                    )
                );
            }
        }
    }

    function _increaseEpochBalance(
        LibReignStorage.EpochBalance[] storage epochBalances,
        uint256 amount
    ) internal {

        uint128 currentEpoch = getEpoch();
        uint128 currentMultiplier = currentEpochMultiplier();
        if (!epochIsInitialized(currentEpoch)) {
            _initEpoch(currentEpoch);
        }

        if (epochBalances.length == 0) {
            epochBalances.push(
                LibReignStorage.EpochBalance(
                    currentEpoch,
                    currentMultiplier,
                    0,
                    amount
                )
            );

            epochBalances.push(
                LibReignStorage.EpochBalance(
                    currentEpoch + 1, //for next epoch
                    BASE_BALANCE_MULTIPLIER,
                    amount, //start balance is amount
                    0 // new deposit of amount is made
                )
            );
        } else {
            LibReignStorage.EpochBalance storage old = epochBalances[
                epochBalances.length - 1
            ];
            uint256 lastIndex = epochBalances.length - 1;

            if (old.epochId < currentEpoch) {
                uint128 multiplier = computeNewMultiplier(
                    _getEpochBalance(old),
                    BASE_BALANCE_MULTIPLIER,
                    amount,
                    currentMultiplier
                );
                epochBalances.push(
                    LibReignStorage.EpochBalance(
                        currentEpoch,
                        multiplier,
                        _getEpochBalance(old),
                        amount
                    )
                );

                epochBalances.push(
                    LibReignStorage.EpochBalance(
                        currentEpoch + 1,
                        BASE_BALANCE_MULTIPLIER,
                        _balances[msg.sender],
                        0
                    )
                );
            }
            else if (old.epochId == currentEpoch) {
                old.multiplier = computeNewMultiplier(
                    _getEpochBalance(old),
                    old.multiplier,
                    amount,
                    currentMultiplier
                );
                old.newDeposits = old.newDeposits.add(amount);

                epochBalances.push(
                    LibReignStorage.EpochBalance(
                        currentEpoch + 1,
                        BASE_BALANCE_MULTIPLIER,
                        _balances[msg.sender],
                        0
                    )
                );
            }
            else {
                if (
                    lastIndex >= 1 &&
                    epochBalances[lastIndex - 1].epochId == currentEpoch
                ) {
                    epochBalances[lastIndex - 1]
                        .multiplier = computeNewMultiplier(
                        _getEpochBalance(epochBalances[lastIndex - 1]),
                        epochBalances[lastIndex - 1].multiplier,
                        amount,
                        currentMultiplier
                    );
                    epochBalances[lastIndex - 1].newDeposits = epochBalances[
                        lastIndex - 1
                    ].newDeposits.add(amount);
                }

                epochBalances[lastIndex].startBalance = _balances[msg.sender];
            }
        }
    }

    function _decreaseEpochBalance(
        LibReignStorage.EpochBalance[] storage epochBalances,
        uint256 amount
    ) internal {

        uint128 currentEpoch = getEpoch();

        if (!epochIsInitialized(currentEpoch)) {
            _initEpoch(currentEpoch);
        }


        LibReignStorage.EpochBalance storage old = epochBalances[
            epochBalances.length - 1
        ];
        uint256 lastIndex = epochBalances.length - 1;

        if (old.epochId < currentEpoch) {
            epochBalances.push(
                LibReignStorage.EpochBalance(
                    currentEpoch,
                    BASE_BALANCE_MULTIPLIER,
                    _balances[msg.sender],
                    0
                )
            );
        }
        else if (old.epochId == currentEpoch) {
            old.multiplier = BASE_BALANCE_MULTIPLIER;
            old.startBalance = _balances[msg.sender];
            old.newDeposits = 0;
        }
        else {
            LibReignStorage.EpochBalance
                storage currentEpochCheckpoint = epochBalances[lastIndex - 1];

            uint256 balanceBefore = getEpochEffectiveBalance(
                currentEpochCheckpoint
            );
            if (amount < currentEpochCheckpoint.newDeposits) {
                uint128 avgDepositMultiplier = uint128(
                    balanceBefore
                        .sub(currentEpochCheckpoint.startBalance)
                        .mul(BASE_BALANCE_MULTIPLIER)
                        .div(currentEpochCheckpoint.newDeposits)
                );

                currentEpochCheckpoint.newDeposits = currentEpochCheckpoint
                    .newDeposits
                    .sub(amount);

                currentEpochCheckpoint.multiplier = computeNewMultiplier(
                    currentEpochCheckpoint.startBalance,
                    BASE_BALANCE_MULTIPLIER,
                    currentEpochCheckpoint.newDeposits,
                    avgDepositMultiplier
                );
            } else {
                currentEpochCheckpoint.startBalance = currentEpochCheckpoint
                    .startBalance
                    .sub(amount.sub(currentEpochCheckpoint.newDeposits));
                currentEpochCheckpoint.newDeposits = 0;
                currentEpochCheckpoint.multiplier = BASE_BALANCE_MULTIPLIER;
            }

            epochBalances[lastIndex].startBalance = _balances[msg.sender];
        }
    }

    function _updateUserLock(
        LibReignStorage.Stake[] storage checkpoints,
        uint256 expiryTimestamp
    ) internal {

        LibReignStorage.Stake storage old = checkpoints[checkpoints.length - 1];

        if (old.timestamp < block.timestamp) {
            checkpoints.push(
                LibReignStorage.Stake(
                    block.timestamp,
                    old.amount,
                    expiryTimestamp,
                    old.delegatedTo,
                    _lockingBoost(block.timestamp, expiryTimestamp)
                )
            );
        } else {
            old.expiryTimestamp = expiryTimestamp;
            old.stakingBoost = _lockingBoost(block.timestamp, expiryTimestamp);
        }
    }

    function _updateUserDelegatedTo(
        LibReignStorage.Stake[] storage checkpoints,
        address to
    ) internal {

        LibReignStorage.Stake storage old = checkpoints[checkpoints.length - 1];

        if (old.timestamp < block.timestamp) {
            checkpoints.push(
                LibReignStorage.Stake(
                    block.timestamp,
                    old.amount,
                    old.expiryTimestamp,
                    to,
                    old.stakingBoost
                )
            );
        } else {
            old.delegatedTo = to;
        }
    }

    function _updateDelegatedPower(
        LibReignStorage.Checkpoint[] storage checkpoints,
        uint256 amount
    ) internal {

        if (
            checkpoints.length == 0 ||
            checkpoints[checkpoints.length - 1].timestamp < block.timestamp
        ) {
            checkpoints.push(
                LibReignStorage.Checkpoint(block.timestamp, amount)
            );
        } else {
            LibReignStorage.Checkpoint storage old = checkpoints[
                checkpoints.length - 1
            ];
            old.amount = amount;
        }
    }

    function _updateLockedReign(uint256 amount) internal {

        LibReignStorage.Storage storage ds = LibReignStorage.reignStorage();

        if (
            ds.reignStakedHistory.length == 0 ||
            ds.reignStakedHistory[ds.reignStakedHistory.length - 1].timestamp <
            block.timestamp
        ) {
            ds.reignStakedHistory.push(
                LibReignStorage.Checkpoint(block.timestamp, amount)
            );
        } else {
            LibReignStorage.Checkpoint storage old = ds.reignStakedHistory[
                ds.reignStakedHistory.length - 1
            ];
            old.amount = amount;
        }
    }


    function _lockingBoost(uint256 from, uint256 to)
        internal
        pure
        returns (uint256)
    {

        uint256 diff = to.sub(from); // underflow is checked for in lock()

        return (
            BASE_STAKE_MULTIPLIER.add(
                (diff.mul(BASE_STAKE_MULTIPLIER).div(MAX_LOCK)).div(2)
            )
        );
    }

    function _initEpoch(uint128 epochId) internal {

        _isInitialized[epochId] = true;
        _initialisedAt[epochId] = block.timestamp;

        emit InitEpoch(msg.sender, epochId);
    }

    function _getEpochBalance(LibReignStorage.EpochBalance memory c)
        internal
        pure
        returns (uint256)
    {

        return c.startBalance.add(c.newDeposits);
    }

    function _checkpointSearch(
        LibReignStorage.Checkpoint[] storage checkpoints,
        uint256 timestamp
    ) internal view returns (uint256) {

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
}