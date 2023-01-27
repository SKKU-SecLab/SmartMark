pragma solidity >=0.8.0;

abstract contract ERC20 {

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);


    string public name;

    string public symbol;

    uint8 public immutable decimals;


    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;


    uint256 internal immutable INITIAL_CHAIN_ID;

    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

    mapping(address => uint256) public nonces;


    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }


    function approve(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        balanceOf[msg.sender] -= amount;

        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;

        balanceOf[from] -= amount;

        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);

        return true;
    }


    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        unchecked {
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256(
                                    "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                                ),
                                owner,
                                spender,
                                value,
                                nonces[owner]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );

            require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");

            allowance[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                    keccak256(bytes(name)),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
    }


    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;

        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;

        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}// AGPL-3.0-only
pragma solidity >=0.8.0;


library SafeTransferLib {


    function safeTransferETH(address to, uint256 amount) internal {

        bool success;

        assembly {
            success := call(gas(), to, amount, 0, 0, 0, 0)
        }

        require(success, "ETH_TRANSFER_FAILED");
    }


    function safeTransferFrom(
        ERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {

        bool success;

        assembly {
            let freeMemoryPointer := mload(0x40)

            mstore(freeMemoryPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), from) // Append the "from" argument.
            mstore(add(freeMemoryPointer, 36), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 68), amount) // Append the "amount" argument.

            success := and(
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                call(gas(), token, 0, freeMemoryPointer, 100, 0, 32)
            )
        }

        require(success, "TRANSFER_FROM_FAILED");
    }

    function safeTransfer(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {

        bool success;

        assembly {
            let freeMemoryPointer := mload(0x40)

            mstore(freeMemoryPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument.

            success := and(
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        require(success, "TRANSFER_FAILED");
    }

    function safeApprove(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {

        bool success;

        assembly {
            let freeMemoryPointer := mload(0x40)

            mstore(freeMemoryPointer, 0x095ea7b300000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument.

            success := and(
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        require(success, "APPROVE_FAILED");
    }
}pragma solidity ^0.8.10;

struct AllocatorPerformance {
    uint128 gain;
    uint128 loss;
}

struct AllocatorLimits {
    uint128 allocated;
    uint128 loss;
}

struct AllocatorHoldings {
    uint256 allocated;
}

struct AllocatorData {
    AllocatorHoldings holdings;
    AllocatorLimits limits;
    AllocatorPerformance performance;
}

interface ITreasuryExtender {

    event NewDepositRegistered(address allocator, address token, uint256 id);

    event AllocatorFunded(uint256 id, uint256 amount, uint256 value);

    event AllocatorWithdrawal(uint256 id, uint256 amount, uint256 value);

    event AllocatorRewardsWithdrawal(address allocator, uint256 amount, uint256 value);

    event AllocatorReportedGain(uint256 id, uint128 gain);

    event AllocatorReportedLoss(uint256 id, uint128 loss);

    event AllocatorReportedMigration(uint256 id);

    event AllocatorLimitsChanged(uint256 id, uint128 allocationLimit, uint128 lossLimit);

    function registerDeposit(address newAllocator) external;


    function setAllocatorLimits(uint256 id, AllocatorLimits memory limits) external;


    function report(
        uint256 id,
        uint128 gain,
        uint128 loss
    ) external;


    function requestFundsFromTreasury(uint256 id, uint256 amount) external;


    function returnFundsToTreasury(uint256 id, uint256 amount) external;


    function returnRewardsToTreasury(
        uint256 id,
        address token,
        uint256 amount
    ) external;


    function getTotalAllocatorCount() external view returns (uint256);


    function getAllocatorByID(uint256 id) external view returns (address);


    function getAllocatorAllocated(uint256 id) external view returns (uint256);


    function getAllocatorLimits(uint256 id) external view returns (AllocatorLimits memory);


    function getAllocatorPerformance(uint256 id) external view returns (AllocatorPerformance memory);

}// AGPL-3.0
pragma solidity >=0.7.5;

interface IOlympusAuthority {


    event GovernorPushed(address indexed from, address indexed to, bool _effectiveImmediately);
    event GuardianPushed(address indexed from, address indexed to, bool _effectiveImmediately);
    event PolicyPushed(address indexed from, address indexed to, bool _effectiveImmediately);
    event VaultPushed(address indexed from, address indexed to, bool _effectiveImmediately);

    event GovernorPulled(address indexed from, address indexed to);
    event GuardianPulled(address indexed from, address indexed to);
    event PolicyPulled(address indexed from, address indexed to);
    event VaultPulled(address indexed from, address indexed to);


    function governor() external view returns (address);


    function guardian() external view returns (address);


    function policy() external view returns (address);


    function vault() external view returns (address);

}pragma solidity >=0.8.0;



enum AllocatorStatus {
    OFFLINE,
    ACTIVATED,
    MIGRATING
}

struct AllocatorInitData {
    IOlympusAuthority authority;
    ITreasuryExtender extender;
    ERC20[] tokens;
}

interface IAllocator {

    event AllocatorDeployed(address authority, address extender);

    event AllocatorActivated();

    event AllocatorDeactivated(bool panic);

    event LossLimitViolated(
        uint128 lastLoss,
        uint128 dloss,
        uint256 estimatedTotalAllocated
    );

    event MigrationExecuted(address allocator);

    event EtherReceived(uint256 amount);

    function update(uint256 id) external;


    function deallocate(uint256[] memory amounts) external;


    function prepareMigration() external;


    function migrate() external;


    function activate() external;


    function deactivate(bool panic) external;


    function addId(uint256 id) external;


    function name() external view returns (string memory);


    function ids() external view returns (uint256[] memory);


    function tokenIds(uint256 id) external view returns (uint256);


    function version() external view returns (string memory);


    function status() external view returns (AllocatorStatus);


    function tokens() external view returns (ERC20[] memory);


    function utilityTokens() external view returns (ERC20[] memory);


    function rewardTokens() external view returns (ERC20[] memory);


    function amountAllocated(uint256 id) external view returns (uint256);

}// AGPL-3.0
pragma solidity >=0.7.5;

interface ITreasury {

    function deposit(
        uint256 _amount,
        address _token,
        uint256 _profit
    ) external returns (uint256);


    function withdraw(uint256 _amount, address _token) external;


    function tokenValue(address _token, uint256 _amount) external view returns (uint256 value_);


    function mint(address _recipient, uint256 _amount) external;


    function manage(address _token, uint256 _amount) external;


    function incurDebt(uint256 amount_, address token_) external;


    function repayDebtWithReserve(uint256 amount_, address token_) external;


    function excessReserves() external view returns (uint256);


    function baseSupply() external view returns (uint256);

}pragma solidity ^0.8.10;


error UNAUTHORIZED();
error AUTHORITY_INITIALIZED();

abstract contract OlympusAccessControlledV2 {

    event AuthorityUpdated(IOlympusAuthority authority);


    IOlympusAuthority public authority;


    constructor(IOlympusAuthority _authority) {
        authority = _authority;
        emit AuthorityUpdated(_authority);
    }


    modifier onlyGovernor {
	_onlyGovernor();
	_;
    }

    modifier onlyGuardian {
	_onlyGuardian();
	_;
    }

    modifier onlyPolicy {
	_onlyPolicy();
	_;
    }

    modifier onlyVault {
	_onlyVault();
	_;
    }


    function initializeAuthority(IOlympusAuthority _newAuthority) internal {
        if (authority != IOlympusAuthority(address(0))) revert AUTHORITY_INITIALIZED();
        authority = _newAuthority;
        emit AuthorityUpdated(_newAuthority);
    }

    function setAuthority(IOlympusAuthority _newAuthority) external {
        _onlyGovernor();
        authority = _newAuthority;
        emit AuthorityUpdated(_newAuthority);
    }


    function _onlyGovernor() internal view {
        if (msg.sender != authority.governor()) revert UNAUTHORIZED();
    }

    function _onlyGuardian() internal view {
        if (msg.sender != authority.guardian()) revert UNAUTHORIZED();
    }

    function _onlyPolicy() internal view {
        if (msg.sender != authority.policy()) revert UNAUTHORIZED();
    }

    function _onlyVault() internal view {
        if (msg.sender != authority.vault()) revert UNAUTHORIZED();
    }
}pragma solidity ^0.8.10;




error BaseAllocator_AllocatorNotActivated();
error BaseAllocator_AllocatorNotOffline();
error BaseAllocator_Migrating();
error BaseAllocator_NotMigrating();
error BaseAllocator_OnlyExtender(address sender);

abstract contract BaseAllocator is OlympusAccessControlledV2, IAllocator {
    using SafeTransferLib for ERC20;

    uint256[] internal _ids;

    ERC20[] internal _tokens;

    mapping(uint256 => uint256) public tokenIds;

    AllocatorStatus public status;

    ITreasuryExtender public immutable extender;

    constructor(AllocatorInitData memory data)
        OlympusAccessControlledV2(data.authority)
    {
        _tokens = data.tokens;
        extender = data.extender;

        for (uint256 i; i < data.tokens.length; i++) {
            data.tokens[i].approve(address(data.extender), type(uint256).max);
        }

        emit AllocatorDeployed(address(data.authority), address(data.extender));
    }


    modifier onlyExtender() {
        _onlyExtender(msg.sender);
        _;
    }

    modifier onlyActivated() {
        _onlyActivated(status);
        _;
    }

    modifier onlyOffline() {
        _onlyOffline(status);
        _;
    }

    modifier notMigrating() {
        _notMigrating(status);
        _;
    }

    modifier isMigrating() {
        _isMigrating(status);
        _;
    }


    function _update(uint256 id)
        internal
        virtual
        returns (uint128 gain, uint128 loss);

    function deallocate(uint256[] memory amounts) public virtual;

    function _deactivate(bool panic) internal virtual;

    function _prepareMigration() internal virtual;

    function amountAllocated(uint256 id) public view virtual returns (uint256);

    function rewardTokens() public view virtual returns (ERC20[] memory);

    function utilityTokens() public view virtual returns (ERC20[] memory);

    function name() external view virtual returns (string memory);


    function _activate() internal virtual {}


    function update(uint256 id) external override onlyGuardian onlyActivated {
        (uint128 gain, uint128 loss) = _update(id);

        if (_lossLimitViolated(id, loss)) {
            deactivate(true);
            return;
        }

        if (gain + loss > 0) extender.report(id, gain, loss);
    }

    function prepareMigration() external override onlyGuardian notMigrating {
        _prepareMigration();

        status = AllocatorStatus.MIGRATING;
    }

    function migrate() external override onlyGuardian isMigrating {
        ERC20[] memory utilityTokensArray = utilityTokens();
        address newAllocator = extender.getAllocatorByID(
            extender.getTotalAllocatorCount() - 1
        );
        uint256 idLength = _ids.length;
        uint256 utilLength = utilityTokensArray.length;

        for (uint256 i; i < idLength; i++) {
            ERC20 token = _tokens[i];

            token.safeTransfer(newAllocator, token.balanceOf(address(this)));
            extender.report(_ids[i], type(uint128).max, type(uint128).max);
        }

        for (uint256 i; i < utilLength; i++) {
            ERC20 utilityToken = utilityTokensArray[i];
            utilityToken.safeTransfer(
                newAllocator,
                utilityToken.balanceOf(address(this))
            );
        }

        deactivate(false);

        emit MigrationExecuted(newAllocator);
    }

    function activate() external override onlyGuardian onlyOffline {
        _activate();
        status = AllocatorStatus.ACTIVATED;

        emit AllocatorActivated();
    }

    function addId(uint256 id) external override onlyExtender {
        _ids.push(id);
        tokenIds[id] = _ids.length - 1;
    }

    function ids() external view override returns (uint256[] memory) {
        return _ids;
    }

    function tokens() external view override returns (ERC20[] memory) {
        return _tokens;
    }

    function deactivate(bool panic) public override onlyGuardian {
        _deactivate(panic);
        status = AllocatorStatus.OFFLINE;

        emit AllocatorDeactivated(panic);
    }

    function version() public pure override returns (string memory) {
        return "v2.0.0";
    }

    function _lossLimitViolated(uint256 id, uint128 loss)
        internal
        returns (bool)
    {
        uint128 lastLoss = extender.getAllocatorPerformance(id).loss;

        if ((loss + lastLoss) >= extender.getAllocatorLimits(id).loss) {
            emit LossLimitViolated(
                lastLoss,
                loss,
                amountAllocated(tokenIds[id])
            );
            return true;
        }

        return false;
    }

    function _onlyExtender(address sender) internal view {
        if (sender != address(extender))
            revert BaseAllocator_OnlyExtender(sender);
    }

    function _onlyActivated(AllocatorStatus inputStatus) internal pure {
        if (inputStatus != AllocatorStatus.ACTIVATED)
            revert BaseAllocator_AllocatorNotActivated();
    }

    function _onlyOffline(AllocatorStatus inputStatus) internal pure {
        if (inputStatus != AllocatorStatus.OFFLINE)
            revert BaseAllocator_AllocatorNotOffline();
    }

    function _notMigrating(AllocatorStatus inputStatus) internal pure {
        if (inputStatus == AllocatorStatus.MIGRATING)
            revert BaseAllocator_Migrating();
    }

    function _isMigrating(AllocatorStatus inputStatus) internal pure {
        if (inputStatus != AllocatorStatus.MIGRATING)
            revert BaseAllocator_NotMigrating();
    }
}pragma solidity ^0.8.10;

struct UserVotePayload {
    address account;
    bytes32 voteSessionKey;
    uint256 nonce;
    uint256 chainId;
    uint256 totalVotes;
    UserVoteAllocationItem[] allocations;
}

struct UserVoteAllocationItem {
    bytes32 reactorKey; //asset-default, in actual deployment could be asset-exchange
    uint256 amount; //18 Decimals
}// MIT

pragma solidity ^0.8.10;

interface IManager {

    struct ControllerTransferData {
        bytes32 controllerId; // controller to target
        bytes data; // data the controller will pass
    }

    struct PoolTransferData {
        address pool; // pool to target
        uint256 amount; // amount to transfer
    }

    struct MaintenanceExecution {
        ControllerTransferData[] cycleSteps;
    }

    struct RolloverExecution {
        PoolTransferData[] poolData;
        ControllerTransferData[] cycleSteps;
        address[] poolsForWithdraw; //Pools to target for manager -> pool transfer
        bool complete; //Whether to mark the rollover complete
        string rewardsIpfsHash;
    }

    event ControllerRegistered(bytes32 id, address controller);
    event ControllerUnregistered(bytes32 id, address controller);
    event PoolRegistered(address pool);
    event PoolUnregistered(address pool);
    event CycleDurationSet(uint256 duration);
    event LiquidityMovedToManager(address pool, uint256 amount);
    event DeploymentStepExecuted(
        bytes32 controller,
        address adapaterAddress,
        bytes data
    );
    event LiquidityMovedToPool(address pool, uint256 amount);
    event CycleRolloverStarted(uint256 timestamp);
    event CycleRolloverComplete(uint256 timestamp);
    event NextCycleStartSet(uint256 nextCycleStartTime);
    event ManagerSwept(address[] addresses, uint256[] amounts);

    function registerController(bytes32 id, address controller) external;


    function registerPool(address pool) external;


    function unRegisterController(bytes32 id) external;


    function unRegisterPool(address pool) external;


    function getPools() external view returns (address[] memory);


    function getControllers() external view returns (bytes32[] memory);


    function setCycleDuration(uint256 duration) external;


    function startCycleRollover() external;


    function executeMaintenance(MaintenanceExecution calldata params) external;


    function executeRollover(RolloverExecution calldata params) external;


    function completeRollover(string calldata rewardsIpfsHash) external;


    function cycleRewardsHashes(uint256 index)
        external
        view
        returns (string memory);


    function getCurrentCycle() external view returns (uint256);


    function getCurrentCycleIndex() external view returns (uint256);


    function getCycleDuration() external view returns (uint256);


    function getRolloverStatus() external view returns (bool);


    function setNextCycleStartTime(uint256 nextCycleStartTime) external;


    function sweep(address[] calldata addresses) external;


    function setupRole(bytes32 role) external;

}// MIT

pragma solidity ^0.8.10;


interface ILiquidityPool {

    struct WithdrawalInfo {
        uint256 minCycle;
        uint256 amount;
    }

    event WithdrawalRequested(address requestor, uint256 amount);
    event DepositsPaused();
    event DepositsUnpaused();

    function deposit(uint256 amount) external;


    function depositFor(address account, uint256 amount) external;


    function requestWithdrawal(uint256 amount) external;


    function approveManager(uint256 amount) external;


    function withdraw(uint256 amount) external;


    function withheldLiquidity() external view returns (uint256);


    function requestedWithdrawals(address account)
        external
        view
        returns (uint256, uint256);


    function pause() external;


    function unpause() external;


    function pauseDeposit() external;


    function unpauseDeposit() external;

}// MIT

pragma solidity ^0.8.10;

interface IRewardHash {

    struct CycleHashTuple {
        string latestClaimable; // hash of last claimable cycle before/including this cycle
        string cycle; // cycleHash of this cycle
    }

    event CycleHashAdded(
        uint256 cycleIndex,
        string latestClaimableHash,
        string cycleHash
    );

    function setCycleHashes(
        uint256 index,
        string calldata latestClaimableIpfsHash,
        string calldata cycleIpfsHash
    ) external;


    function cycleHashes(uint256 index)
        external
        view
        returns (string memory latestClaimable, string memory cycle);

}// MIT

pragma solidity ^0.8.10;

interface IStaking {

    struct StakingSchedule {
        uint256 cliff; // Duration in seconds before staking starts
        uint256 duration; // Seconds it takes for entire amount to stake
        uint256 interval; // Seconds it takes for a chunk to stake
        bool setup; //Just so we know its there
        bool isActive; //Whether we can setup new stakes with the schedule
        uint256 hardStart; //Stakings will always start at this timestamp if set
        bool isPublic; //Schedule can be written to by any account
    }

    struct StakingScheduleInfo {
        StakingSchedule schedule;
        uint256 index;
    }

    struct StakingDetails {
        uint256 initial; //Initial amount of asset when stake was created, total amount to be staked before slashing
        uint256 withdrawn; //Amount that was staked and subsequently withdrawn
        uint256 slashed; //Amount that has been slashed
        uint256 started; //Timestamp at which the stake started
        uint256 scheduleIx;
    }

    struct WithdrawalInfo {
        uint256 minCycleIndex;
        uint256 amount;
    }

    struct QueuedTransfer {
        address from;
        uint256 scheduleIdxFrom;
        uint256 scheduleIdxTo;
        uint256 amount;
        address to;
    }

    event ScheduleAdded(
        uint256 scheduleIndex,
        uint256 cliff,
        uint256 duration,
        uint256 interval,
        bool setup,
        bool isActive,
        uint256 hardStart,
        address notional
    );
    event ScheduleRemoved(uint256 scheduleIndex);
    event WithdrawalRequested(
        address account,
        uint256 scheduleIdx,
        uint256 amount
    );
    event WithdrawCompleted(
        address account,
        uint256 scheduleIdx,
        uint256 amount
    );
    event Deposited(address account, uint256 amount, uint256 scheduleIx);
    event Slashed(address account, uint256 amount, uint256 scheduleIx);
    event PermissionedDepositorSet(address depositor, bool allowed);
    event UserSchedulesSet(address account, uint256[] userSchedulesIdxs);
    event NotionalAddressesSet(uint256[] scheduleIdxs, address[] addresses);
    event ScheduleStatusSet(uint256 scheduleId, bool isActive);
    event StakeTransferred(
        address from,
        uint256 scheduleFrom,
        uint256 scheduleTo,
        uint256 amount,
        address to
    );
    event ZeroSweep(address user, uint256 amount, uint256 scheduleFrom);
    event TransferApproverSet(address approverAddress);
    event TransferQueued(
        address from,
        uint256 scheduleFrom,
        uint256 scheduleTo,
        uint256 amount,
        address to
    );
    event QueuedTransferRemoved(
        address from,
        uint256 scheduleFrom,
        uint256 scheduleTo,
        uint256 amount,
        address to
    );
    event QueuedTransferRejected(
        address from,
        uint256 scheduleFrom,
        uint256 scheduleTo,
        uint256 amount,
        address to
    );

    function permissionedDepositors(address account) external returns (bool);


    function setUserSchedules(
        address account,
        uint256[] calldata userSchedulesIdxs
    ) external;


    function addSchedule(StakingSchedule memory schedule, address notional)
        external;


    function getSchedules()
        external
        view
        returns (StakingScheduleInfo[] memory retSchedules);


    function setPermissionedDepositor(address account, bool canDeposit)
        external;


    function withdrawalRequestsByIndex(address account, uint256 index)
        external
        view
        returns (uint256 minCycle, uint256 amount);


    function getStakes(address account)
        external
        view
        returns (StakingDetails[] memory stakes);


    function balanceOf(address account) external view returns (uint256 value);


    function availableForWithdrawal(address account, uint256 scheduleIndex)
        external
        view
        returns (uint256);


    function unvested(address account, uint256 scheduleIndex)
        external
        view
        returns (uint256 value);


    function vested(address account, uint256 scheduleIndex)
        external
        view
        returns (uint256 value);


    function deposit(uint256 amount, uint256 scheduleIndex) external;


    function deposit(uint256 amount) external;


    function depositFor(
        address account,
        uint256 amount,
        uint256 scheduleIndex
    ) external;


    function depositWithSchedule(
        address account,
        uint256 amount,
        StakingSchedule calldata schedule,
        address notional
    ) external;


    function requestWithdrawal(uint256 amount, uint256 scheduleIdx) external;


    function withdraw(uint256 amount, uint256 scheduleIdx) external;


    function setScheduleStatus(uint256 scheduleIndex, bool activeBoolean)
        external;


    function pause() external;


    function unpause() external;


    function slash(
        address[] calldata accounts,
        uint256[] calldata amounts,
        uint256 scheduleIndex
    ) external;


    function setNotionalAddresses(
        uint256[] calldata scheduleIdxArr,
        address[] calldata addresses
    ) external;


    function withdraw(uint256 amount) external;

}// MIT

pragma solidity ^0.8.10;

interface IRewards {

    struct EIP712Domain {
        string name;
        string version;
        uint256 chainId;
        address verifyingContract;
    }

    struct Recipient {
        uint256 chainId;
        uint256 cycle;
        address wallet;
        uint256 amount;
    }

    event SignerSet(address newSigner);
    event Claimed(uint256 cycle, address recipient, uint256 amount);

    function rewardsSigner() external view returns (address);


    function claimedAmounts(address account) external view returns (uint256);


    function getClaimableAmount(Recipient calldata recipient)
        external
        view
        returns (uint256);


    function setSigner(address newSigner) external;


    function claim(
        Recipient calldata recipient,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

}pragma solidity ^0.8.13;





interface ITokemakVoting {

    function vote(UserVotePayload memory userVotePayload) external;

}

uint256 constant nmax = type(uint256).max;

library TokemakAllocatorLib {

    function deposit(address reactor, uint256 amount) internal {

        ILiquidityPool(reactor).deposit(amount);
    }

    function requestWithdrawal(address reactor, uint256 amount) internal {

        ILiquidityPool(reactor).requestWithdrawal(amount);
    }

    function withdraw(address reactor, uint256 amount) internal {

        ILiquidityPool(reactor).withdraw(amount);
    }

    function requestedWithdrawals(address reactor)
        internal
        view
        returns (uint256 minCycle, uint256 amount)
    {

        (minCycle, amount) = ILiquidityPool(reactor).requestedWithdrawals(
            address(this)
        );
    }

    function balanceOf(address reactor, address owner)
        internal
        view
        returns (uint256)
    {

        return ERC20(reactor).balanceOf(owner);
    }

    function nmaxarr(uint256 l) internal pure returns (uint256[] memory arr) {

        arr = new uint256[](l);

        for (uint256 i; i < l; i++) {
            arr[i] = nmax;
        }
    }
}

struct TokemakData {
    address voting;
    address staking;
    address rewards;
    address manager;
}

struct PayloadData {
    uint128 amount;
    uint64 cycle;
    uint64 v;
    bytes32 r;
    bytes32 s;
}

error GeneralizedTokemak_ArbitraryCallFailed();
error GeneralizedTokemak_MustInitializeTotalWithdraw();
error GeneralizedTokemak_WithdrawalNotReady(uint256 tAssetIndex_);

contract GeneralizedTokemak is BaseAllocator {

    using SafeTransferLib for ERC20;
    using TokemakAllocatorLib for address;

    address immutable self;

    ITokemakVoting public voting;
    IStaking public staking;
    IRewards public rewards;
    IManager public manager;

    ERC20 public toke;

    address[] public reactors;

    PayloadData public nextPayloadData;

    bool public mayClaim;

    bool public totalWithdrawInitialized;

    constructor()
        BaseAllocator(
            AllocatorInitData(
                IOlympusAuthority(0x1c21F8EA7e39E2BA00BC12d2968D63F4acb38b7A),
                ITreasuryExtender(0xb32Ad041f23eAfd682F57fCe31d3eA4fd92D17af),
                new ERC20[](0)
            )
        )
    {
        self = address(this);

        toke = ERC20(0x2e9d63788249371f1DFC918a52f8d799F4a38C94);

        _setTokemakData(
            TokemakData(
                0x43094eD6D6d214e43C31C38dA91231D2296Ca511, // voting
                0x96F98Ed74639689C3A11daf38ef86E59F43417D3, // staking
                0x79dD22579112d8a5F7347c5ED7E609e60da713C5, // rewards
                0xA86e412109f77c45a3BC1c5870b880492Fb86A14 // manager
            )
        );
    }


    function executeArbitrary(address target, bytes memory data)
        external
        onlyGuardian
    {

        (bool success, ) = target.call(data);
        if (!success) revert GeneralizedTokemak_ArbitraryCallFailed();
    }


    function _update(uint256 id)
        internal
        override
        returns (uint128 gain, uint128 loss)
    {

        uint256 index = tokenIds[id];
        address reactor = reactors[index];
        ERC20 underl = _tokens[index];

        if (mayClaim) {
            PayloadData memory payData = nextPayloadData;

            rewards.claim(
                IRewards.Recipient(1, payData.cycle, self, payData.amount),
                uint8(payData.v),
                payData.r,
                payData.s
            );

            mayClaim = false;
        }

        uint256 bal = toke.balanceOf(self);

        if (0 < bal) {
            toke.approve(address(staking), bal);
            staking.deposit(bal);
        }

        bal = underl.balanceOf(self);

        if (0 < bal) {
            underl.approve(reactor, bal);
            reactor.deposit(bal);
        }

        uint128 current = uint128(reactor.balanceOf(self));
        uint128 last = extender.getAllocatorPerformance(id).gain +
            uint128(extender.getAllocatorAllocated(id));

        if (last <= current) gain = current - last;
        else loss = last - current;
    }

    function deallocate(uint256[] memory amounts) public override onlyGuardian {

        uint256 lt = _tokens.length;
        uint256 la = amounts.length;

        for (uint256 i; i <= lt; i++) {
            if (amounts[i] != 0) {
                address reactor;

                if (i < lt) reactor = reactors[i];

                if (lt + 1 < la) {
                    if (amounts[i] == nmax)
                        amounts[i] = i < lt
                            ? reactor.balanceOf(self)
                            : staking.balanceOf(self);

                    if (0 < amounts[i])
                        if (i < lt) reactor.requestWithdrawal(amounts[i]);
                        else staking.requestWithdrawal(amounts[i], 0);
                } else {
                    uint256 cycle = manager.getCurrentCycleIndex();

                    (uint256 minCycle, uint256 amount) = i < lt
                        ? reactor.requestedWithdrawals()
                        : staking.withdrawalRequestsByIndex(self, 0);

                    if (amounts[i] == nmax) amounts[i] = amount;

                    if (cycle < minCycle)
                        revert GeneralizedTokemak_WithdrawalNotReady(i);

                    if (0 < amounts[i])
                        if (i < lt) reactor.withdraw(amounts[i]);
                        else staking.withdraw(amounts[i]);
                }
            }
        }
    }

    function _prepareMigration() internal override {

        if (!totalWithdrawInitialized) {
            revert GeneralizedTokemak_MustInitializeTotalWithdraw();
        } else {
            deallocate(TokemakAllocatorLib.nmaxarr(reactors.length + 1));
        }
    }

    function _deactivate(bool panic) internal override {

        if (panic) {
            deallocate(TokemakAllocatorLib.nmaxarr(reactors.length + 2));
            totalWithdrawInitialized = true;
        }
    }

    function _activate() internal override {

        totalWithdrawInitialized = false;
    }


    function vote(UserVotePayload calldata payload) external onlyGuardian {

        voting.vote(payload);
    }

    function updateClaimPayload(PayloadData calldata data)
        external
        onlyGuardian
    {

        nextPayloadData = data;
        mayClaim = true;
    }

    function addToken(address token, address reactor) external onlyGuardian {

        ERC20(token).safeApprove(address(extender), type(uint256).max);
        ERC20(reactor).safeApprove(address(extender), type(uint256).max);
        _tokens.push(ERC20(token));
        reactors.push(reactor);
    }

    function setTokemakData(TokemakData memory tokeData) external onlyGuardian {

        _setTokemakData(tokeData);
    }


    function tokeAvailable(uint256 scheduleIndex)
        public
        view
        virtual
        returns (uint256)
    {

        return staking.availableForWithdrawal(self, scheduleIndex);
    }

    function tokeDeposited() public view virtual returns (uint256) {

        return staking.balanceOf(self);
    }


    function amountAllocated(uint256 id)
        public
        view
        override
        returns (uint256)
    {

        return reactors[tokenIds[id]].balanceOf(self);
    }

    function name() external pure override returns (string memory) {

        return "GeneralizedTokemak";
    }

    function utilityTokens() public view override returns (ERC20[] memory) {

        uint256 l = reactors.length + 1;
        ERC20[] memory utils = new ERC20[](l);

        for (uint256 i; i < l - 1; i++) {
            utils[i] = ERC20(reactors[i]);
        }

        utils[l - 1] = toke;
        return utils;
    }

    function rewardTokens() public view override returns (ERC20[] memory) {

        ERC20[] memory reward = new ERC20[](1);
        reward[0] = toke;
        return reward;
    }


    function _setTokemakData(TokemakData memory tokeData) internal {

        voting = ITokemakVoting(tokeData.voting);
        staking = IStaking(tokeData.staking);
        rewards = IRewards(tokeData.rewards);
        manager = IManager(tokeData.manager);
    }
}