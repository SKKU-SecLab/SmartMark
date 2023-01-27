
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
}

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
}

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
}

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
}

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
}

pragma solidity ^0.8.0;

interface IERC20Upgradeable {

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
}

pragma solidity ^0.8.0;


library SafeERC20Upgradeable {

    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
pragma solidity 0.8.7;

interface IveSPA {

    function getLastUserSlope(address addr) external view returns (int128);


    function getUserPointHistoryTS(address addr, uint256 idx)
        external
        view
        returns (uint256);


    function userPointEpoch(address addr) external view returns (uint256);


    function checkpoint() external;


    function lockedEnd(address addr) external view returns (uint256);


    function depositFor(address addr, uint128 value) external;


    function createLock(
        uint128 value,
        uint256 unlockTime,
        bool autoCooldown
    ) external;


    function increaseAmount(uint128 value) external;


    function increaseUnlockTime(uint256 unlockTime) external;


    function initiateCooldown() external;


    function withdraw() external;


    function balanceOf(address addr, uint256 ts)
        external
        view
        returns (uint256);


    function balanceOf(address addr) external view returns (uint256);


    function balanceOfAt(address, uint256 blockNumber)
        external
        view
        returns (uint256);


    function totalSupply(uint256 ts) external view returns (uint256);


    function totalSupply() external view returns (uint256);


    function totalSupplyAt(uint256 blockNumber) external view returns (uint256);

}
pragma solidity 0.8.7;




contract veSPA_v1 is IveSPA, OwnableUpgradeable, ReentrancyGuardUpgradeable {

    using SafeERC20Upgradeable for IERC20Upgradeable;

    enum ActionType {
        DEPOSIT_FOR,
        CREATE_LOCK,
        INCREASE_AMOUNT,
        INCREASE_LOCK_TIME,
        INITIATE_COOLDOWN
    }

    event UserCheckpoint(
        ActionType indexed actionType,
        bool autoCooldown,
        address indexed provider,
        uint256 value,
        uint256 indexed locktime
    );
    event GlobalCheckpoint(address caller, uint256 epoch);
    event Withdraw(address indexed provider, uint256 value, uint256 ts);
    event Supply(uint256 prevSupply, uint256 supply);

    struct Point {
        int128 bias; // veSPA value at this point
        int128 slope; // slope at this point
        int128 residue; // residue calculated at this point
        uint256 ts; // timestamp of this point
        uint256 blk; // block number of this point
    }

    struct LockedBalance {
        bool autoCooldown; // if true, the user's deposit will have a default cooldown.
        bool cooldownInitiated; // Determines if the cooldown has been initiated.
        uint128 amount; // amount of SPA locked for a user.
        uint256 end; // the expiry time of the deposit.
    }

    string public version;
    string public constant name = "Vote-escrow SPA";
    string public constant symbol = "veSPA";
    uint8 public constant decimals = 18;
    uint256 public totalSPALocked;
    uint256 public constant WEEK = 1 weeks;
    uint256 public constant MAX_TIME = 4 * 365 days;
    uint256 public constant MIN_TIME = 1 * WEEK;
    uint256 public constant MULTIPLIER = 10**18;
    int128 public constant I_YEAR = int128(uint128(365 days));
    int128 public constant I_MIN_TIME = int128(uint128(WEEK));
    address public SPA;

    uint256 public epoch;
    mapping(uint256 => Point) public pointHistory; // epoch -> unsigned point
    mapping(uint256 => int128) public slopeChanges; // time -> signed slope change

    mapping(address => LockedBalance) public lockedBalances; // user Deposits
    mapping(address => mapping(uint256 => Point)) public userPointHistory; // user -> point[userEpoch]
    mapping(address => uint256) public override userPointEpoch;

    function initialize(address _SPA, string memory _version)
        public
        initializer
    {

        require(_SPA != address(0), "_SPA is zero address");
        OwnableUpgradeable.__Ownable_init();
        ReentrancyGuardUpgradeable.__ReentrancyGuard_init();
        SPA = _SPA;
        version = _version;
        pointHistory[0].blk = block.number;
        pointHistory[0].ts = block.timestamp;
    }

    function getLastUserSlope(address addr)
        external
        view
        override
        returns (int128)
    {

        uint256 uEpoch = userPointEpoch[addr];
        if (uEpoch == 0) {
            return 0;
        }
        return userPointHistory[addr][uEpoch].slope;
    }

    function getUserPointHistoryTS(address addr, uint256 idx)
        external
        view
        override
        returns (uint256)
    {

        return userPointHistory[addr][idx].ts;
    }

    function lockedEnd(address addr) external view override returns (uint256) {

        return lockedBalances[addr].end;
    }

    function _updateGlobalPoint() private returns (Point memory lastPoint) {

        uint256 _epoch = epoch;
        lastPoint = Point({
            bias: 0,
            slope: 0,
            residue: 0,
            ts: block.timestamp,
            blk: block.number //TODO: arbi-main-fork cannot test it
        });
        Point memory initialLastPoint = Point({
            bias: 0,
            slope: 0,
            residue: 0,
            ts: block.timestamp,
            blk: block.number
        });
        if (_epoch > 0) {
            lastPoint = pointHistory[_epoch];
            initialLastPoint = pointHistory[_epoch];
        }
        uint256 lastCheckpoint = lastPoint.ts;
        uint256 blockSlope = 0; // dblock/dt
        if (block.timestamp > lastPoint.ts) {
            blockSlope =
                (MULTIPLIER * (block.number - lastPoint.blk)) /
                (block.timestamp - lastPoint.ts);
        }
        {
            uint256 ti = (lastCheckpoint / WEEK) * WEEK;
            for (uint256 i = 0; i < 255; i++) {
                ti += WEEK;
                int128 dslope = 0;
                if (ti > block.timestamp) {
                    ti = block.timestamp;
                } else {
                    dslope = slopeChanges[ti];
                }
                lastPoint.bias -=
                    lastPoint.slope *
                    int128(int256(ti) - int256(lastCheckpoint));
                lastPoint.slope += dslope;
                if (lastPoint.bias < 0) {
                    lastPoint.bias = 0;
                }
                if (lastPoint.slope < 0) {
                    lastPoint.slope = 0;
                }

                lastCheckpoint = ti;
                lastPoint.ts = ti;
                lastPoint.blk =
                    initialLastPoint.blk +
                    (blockSlope * (ti - initialLastPoint.ts)) /
                    MULTIPLIER;
                _epoch += 1;
                if (ti == block.timestamp) {
                    lastPoint.blk = block.number;
                    pointHistory[_epoch] = lastPoint;
                    break;
                }
                pointHistory[_epoch] = lastPoint;
            }
        }

        epoch = _epoch;
        return lastPoint;
    }

    function _checkpoint(
        address addr,
        LockedBalance memory oldDeposit,
        LockedBalance memory newDeposit
    ) internal {

        Point memory uOld = Point(0, 0, 0, 0, 0);
        Point memory uNew = Point(0, 0, 0, 0, 0);
        int128 dSlopeOld = 0;
        int128 dSlopeNew = 0;

        if (oldDeposit.amount > 0) {
            int128 amt = int128(oldDeposit.amount);
            if (!oldDeposit.cooldownInitiated) {
                uOld.residue = (amt * I_MIN_TIME) / I_YEAR;
                oldDeposit.end -= WEEK;
            }
            if (oldDeposit.end > block.timestamp) {
                uOld.slope = amt / I_YEAR;

                uOld.bias =
                    uOld.slope *
                    int128(int256(oldDeposit.end) - int256(block.timestamp));
            }
        }
        if ((newDeposit.end > block.timestamp) && (newDeposit.amount > 0)) {
            int128 amt = int128(newDeposit.amount);
            if (!newDeposit.cooldownInitiated) {
                uNew.residue = (amt * I_MIN_TIME) / I_YEAR;
                newDeposit.end -= WEEK;
            }
            if (newDeposit.end > block.timestamp) {
                uNew.slope = amt / I_YEAR;
                uNew.bias =
                    uNew.slope *
                    int128(int256(newDeposit.end) - int256(block.timestamp));
            }
        }

        dSlopeOld = slopeChanges[oldDeposit.end];
        if (newDeposit.end != 0) {
            dSlopeNew = slopeChanges[newDeposit.end];
        }
        Point memory lastPoint = _updateGlobalPoint();
        lastPoint.slope += (uNew.slope - uOld.slope);
        lastPoint.bias += (uNew.bias - uOld.bias);
        lastPoint.residue += (uNew.residue - uOld.residue);
        if (lastPoint.slope < 0) {
            lastPoint.slope = 0;
        }
        if (lastPoint.bias < 0) {
            lastPoint.bias = 0;
        }
        pointHistory[epoch] = lastPoint;
        if (oldDeposit.end > block.timestamp) {
            dSlopeOld += uOld.slope;
            if (newDeposit.end == oldDeposit.end) {
                dSlopeOld -= uNew.slope;
            }
            slopeChanges[oldDeposit.end] = dSlopeOld;
        }

        if (newDeposit.end > block.timestamp) {
            if (newDeposit.end > oldDeposit.end) {
                dSlopeNew -= uNew.slope;
                slopeChanges[newDeposit.end] = dSlopeNew;
            }
        }
        uint256 userEpc = userPointEpoch[addr] + 1;
        userPointEpoch[addr] = userEpc;
        uNew.ts = block.timestamp;
        uNew.blk = block.number;
        userPointHistory[addr][userEpc] = uNew;
    }


    function _depositFor(
        address addr,
        bool autoCooldown,
        bool enableCooldown,
        uint128 value,
        uint256 unlockTime,
        LockedBalance memory oldDeposit,
        ActionType _type
    ) internal {

        LockedBalance memory newDeposit = lockedBalances[addr];
        uint256 prevSupply = totalSPALocked;

        totalSPALocked += value;
        newDeposit.amount += value;
        newDeposit.autoCooldown = autoCooldown;
        newDeposit.cooldownInitiated = enableCooldown;
        if (unlockTime != 0) {
            newDeposit.end = unlockTime;
        }
        lockedBalances[addr] = newDeposit;
        _checkpoint(addr, oldDeposit, newDeposit);

        if (value != 0) {
            IERC20Upgradeable(SPA).safeTransferFrom(
                _msgSender(),
                address(this),
                value
            );
        }

        emit UserCheckpoint(_type, autoCooldown, addr, value, newDeposit.end);
        emit Supply(prevSupply, totalSPALocked);
    }

    function checkpoint() external override {

        _updateGlobalPoint();
        emit GlobalCheckpoint(_msgSender(), epoch);
    }

    function depositFor(address addr, uint128 value)
        external
        override
        nonReentrant
    {

        LockedBalance memory existingDeposit = lockedBalances[addr];
        require(value > 0, "Cannot deposit 0 tokens");
        require(existingDeposit.amount > 0, "No existing lock");

        if (!existingDeposit.autoCooldown) {
            require(
                !existingDeposit.cooldownInitiated,
                "Cannot deposit during cooldown"
            );
        }
        require(
            existingDeposit.end > block.timestamp,
            "Lock expired. Withdraw"
        );
        _depositFor(
            addr,
            existingDeposit.autoCooldown,
            existingDeposit.cooldownInitiated,
            value,
            0,
            existingDeposit,
            ActionType.DEPOSIT_FOR
        );
    }

    function createLock(
        uint128 value,
        uint256 unlockTime,
        bool autoCooldown
    ) external override nonReentrant {

        address account = _msgSender();
        uint256 roundedUnlockTime = (unlockTime / WEEK) * WEEK;
        LockedBalance memory existingDeposit = lockedBalances[account];

        require(value > 0, "Cannot lock 0 tokens");
        require(existingDeposit.amount == 0, "Withdraw old tokens first");
        require(roundedUnlockTime > block.timestamp, "Cannot lock in the past");
        require(
            roundedUnlockTime <= block.timestamp + MAX_TIME,
            "Voting lock can be 4 years max"
        );
        _depositFor(
            account,
            autoCooldown,
            autoCooldown,
            value,
            roundedUnlockTime,
            existingDeposit,
            ActionType.CREATE_LOCK
        );
    }

    function increaseAmount(uint128 value) external override nonReentrant {

        address account = _msgSender();
        LockedBalance memory existingDeposit = lockedBalances[account];

        require(value > 0, "Cannot deposit 0 tokens");
        require(existingDeposit.amount > 0, "No existing lock found");

        if (!existingDeposit.autoCooldown) {
            require(
                !existingDeposit.cooldownInitiated,
                "Cannot deposit during cooldown"
            );
        }

        require(
            existingDeposit.end > block.timestamp,
            "Lock expired. Withdraw"
        );
        _depositFor(
            account,
            existingDeposit.autoCooldown,
            existingDeposit.cooldownInitiated,
            value,
            0,
            existingDeposit,
            ActionType.INCREASE_AMOUNT
        );
    }

    function increaseUnlockTime(uint256 unlockTime) external override {

        address account = _msgSender();
        LockedBalance memory existingDeposit = lockedBalances[account];
        uint256 roundedUnlockTime = (unlockTime / WEEK) * WEEK; // Locktime is rounded down to weeks

        require(existingDeposit.amount > 0, "No existing lock found");
        if (!existingDeposit.autoCooldown) {
            require(
                !existingDeposit.cooldownInitiated,
                "Deposit is in cooldown"
            );
        }
        require(
            existingDeposit.end > block.timestamp,
            "Lock expired. Withdraw"
        );
        require(
            roundedUnlockTime > existingDeposit.end,
            "Can only increase lock duration"
        );
        require(
            roundedUnlockTime <= block.timestamp + MAX_TIME,
            "Voting lock can be 4 years max"
        );

        _depositFor(
            account,
            existingDeposit.autoCooldown,
            existingDeposit.cooldownInitiated,
            0,
            roundedUnlockTime,
            existingDeposit,
            ActionType.INCREASE_LOCK_TIME
        );
    }

    function initiateCooldown() external override {

        address account = _msgSender();
        LockedBalance memory existingDeposit = lockedBalances[account];
        require(existingDeposit.amount > 0, "No existing lock found");
        require(
            !existingDeposit.cooldownInitiated,
            "Cooldown already initiated"
        );
        require(
            block.timestamp >= existingDeposit.end - MIN_TIME,
            "Can not initiate cool down"
        );

        uint256 roundedUnlockTime = ((block.timestamp + MIN_TIME) / WEEK) *
            WEEK;

        _depositFor(
            account,
            existingDeposit.autoCooldown,
            true,
            0,
            roundedUnlockTime,
            existingDeposit,
            ActionType.INITIATE_COOLDOWN
        );
    }

    function withdraw() external override nonReentrant {

        address account = _msgSender();
        LockedBalance memory existingDeposit = lockedBalances[account];
        require(existingDeposit.amount > 0, "No existing lock found");
        require(existingDeposit.cooldownInitiated, "No cooldown initiated");
        require(block.timestamp >= existingDeposit.end, "Lock not expired.");
        uint128 value = existingDeposit.amount;

        LockedBalance memory oldDeposit = lockedBalances[account];
        lockedBalances[account] = LockedBalance(false, false, 0, 0);
        uint256 prevSupply = totalSPALocked;
        totalSPALocked -= value;

        _checkpoint(account, oldDeposit, LockedBalance(false, false, 0, 0));

        IERC20Upgradeable(SPA).safeTransfer(account, value);
        emit Withdraw(account, value, block.timestamp);
        emit Supply(prevSupply, totalSPALocked);
    }


    function _findBlockEpoch(uint256 blockNumber, uint256 maxEpoch)
        internal
        view
        returns (uint256)
    {

        uint256 min = 0;
        uint256 max = maxEpoch;

        for (uint256 i = 0; i < 128; i++) {
            if (min >= max) {
                break;
            }
            uint256 mid = (min + max + 1) / 2;
            if (pointHistory[mid].blk <= blockNumber) {
                min = mid;
            } else {
                max = mid - 1;
            }
        }
        return min;
    }

    function _findUserTimestampEpoch(address addr, uint256 ts)
        internal
        view
        returns (uint256)
    {

        uint256 min = 0;
        uint256 max = userPointEpoch[addr];

        for (uint256 i = 0; i < 128; i++) {
            if (min >= max) {
                break;
            }
            uint256 mid = (min + max + 1) / 2;
            if (userPointHistory[addr][mid].ts <= ts) {
                min = mid;
            } else {
                max = mid - 1;
            }
        }
        return min;
    }

    function _findGlobalTimestampEpoch(uint256 ts)
        internal
        view
        returns (uint256)
    {

        uint256 min = 0;
        uint256 max = epoch;

        for (uint256 i = 0; i < 128; i++) {
            if (min >= max) {
                break;
            }
            uint256 mid = (min + max + 1) / 2;
            if (pointHistory[mid].ts <= ts) {
                min = mid;
            } else {
                max = mid - 1;
            }
        }
        return min;
    }

    function estimateDeposit(
        bool autoCooldown,
        uint128 value,
        uint256 expectedUnlockTime
    )
        public
        view
        returns (
            bool,
            int128 initialVespaBalance, // initial veSPA balance
            int128 slope, // slope of the user's graph
            int128 bias, // bias of the user's graph
            int128 residue, // residual balance
            uint256 actualUnlockTime, // actual rounded unlock time
            uint256 providedUnlockTime, // expected unlock time
            uint256 residuePeriodStart
        )
    {

        actualUnlockTime = (expectedUnlockTime / WEEK) * WEEK;

        require(actualUnlockTime > block.timestamp, "Cannot lock in the past");
        require(
            actualUnlockTime <= block.timestamp + MAX_TIME,
            "Voting lock can be 4 years max"
        );

        int128 amt = int128(value);
        slope = amt / I_YEAR;

        if (!autoCooldown) {
            residue = (amt * I_MIN_TIME) / I_YEAR;
            residuePeriodStart = actualUnlockTime - WEEK;
            bias =
                slope *
                int128(
                    int256(actualUnlockTime - WEEK) - int256(block.timestamp)
                );
        } else {
            bias =
                slope *
                int128(int256(actualUnlockTime) - int256(block.timestamp));
        }
        if (bias <= 0) {
            bias = 0;
        }
        initialVespaBalance = bias + residue;

        return (
            autoCooldown,
            initialVespaBalance,
            slope,
            bias,
            residue,
            actualUnlockTime,
            expectedUnlockTime,
            residuePeriodStart
        );
    }

    function balanceOf(address addr, uint256 ts)
        public
        view
        override
        returns (uint256)
    {

        uint256 _epoch = _findUserTimestampEpoch(addr, ts);
        if (_epoch == 0) {
            return 0;
        } else {
            Point memory lastPoint = userPointHistory[addr][_epoch];
            lastPoint.bias -=
                lastPoint.slope *
                int128(int256(ts) - int256(lastPoint.ts));
            if (lastPoint.bias < 0) {
                lastPoint.bias = 0;
            }
            lastPoint.bias += lastPoint.residue;
            return uint256(int256(lastPoint.bias));
        }
    }

    function balanceOf(address addr) public view override returns (uint256) {

        return balanceOf(addr, block.timestamp);
    }

    function balanceOfAt(address addr, uint256 blockNumber)
        public
        view
        override
        returns (uint256)
    {

        uint256 min = 0;
        uint256 max = userPointEpoch[addr];

        for (uint256 i = 0; i < 128; i++) {
            if (min >= max) {
                break;
            }
            uint256 mid = (min + max + 1) / 2;
            if (userPointHistory[addr][mid].blk <= blockNumber) {
                min = mid;
            } else {
                max = mid - 1;
            }
        }

        Point memory uPoint = userPointHistory[addr][min];
        uint256 maxEpoch = epoch;

        uint256 _epoch = _findBlockEpoch(blockNumber, maxEpoch);
        Point memory point0 = pointHistory[_epoch];
        uint256 dBlock = 0;
        uint256 dt = 0;

        if (_epoch < maxEpoch) {
            Point memory point1 = pointHistory[_epoch + 1];
            dBlock = point1.blk - point0.blk;
            dt = point1.ts - point0.ts;
        } else {
            dBlock = blockNumber - point0.blk;
            dt = block.timestamp - point0.ts;
        }

        uint256 blockTime = point0.ts;
        if (dBlock != 0) {
            blockTime += (dt * (blockNumber - point0.blk)) / dBlock;
        }

        uPoint.bias -=
            uPoint.slope *
            int128(int256(blockTime) - int256(uPoint.ts));
        if (uPoint.bias < 0) {
            uPoint.bias = 0;
        }
        uPoint.bias += uPoint.residue;
        return uint256(int256(uPoint.bias));
    }

    function supplyAt(Point memory point, uint256 ts)
        internal
        view
        returns (uint256)
    {

        Point memory lastPoint = point;
        uint256 ti = (lastPoint.ts / WEEK) * WEEK;

        for (uint256 i = 0; i < 255; i++) {
            ti += WEEK;
            int128 dSlope = 0;
            if (ti > ts) {
                ti = ts;
            } else {
                dSlope = slopeChanges[ti];
            }
            lastPoint.bias -=
                lastPoint.slope *
                int128(int256(ti) - int256(lastPoint.ts));
            if (ti == ts) {
                break;
            }
            lastPoint.slope += dSlope;
            lastPoint.ts = ti;
        }

        if (lastPoint.bias < 0) {
            lastPoint.bias = 0;
        }
        lastPoint.bias += lastPoint.residue;
        return uint256(int256(lastPoint.bias));
    }

    function totalSupply(uint256 ts) public view override returns (uint256) {

        uint256 _epoch = _findGlobalTimestampEpoch(ts);
        Point memory lastPoint = pointHistory[_epoch];
        return supplyAt(lastPoint, ts);
    }

    function totalSupply() public view override returns (uint256) {

        return totalSupply(block.timestamp);
    }

    function totalSupplyAt(uint256 blockNumber)
        external
        view
        override
        returns (uint256)
    {

        require(blockNumber <= block.number);
        uint256 _epoch = epoch;
        uint256 targetEpoch = _findBlockEpoch(blockNumber, _epoch);

        Point memory point0 = pointHistory[targetEpoch];
        uint256 dt = 0;

        if (targetEpoch < _epoch) {
            Point memory point1 = pointHistory[targetEpoch + 1];
            dt =
                ((blockNumber - point0.blk) * (point1.ts - point0.ts)) /
                (point1.blk - point0.blk);
        } else {
            if (point0.blk != block.number) {
                dt =
                    ((blockNumber - point0.blk) *
                        (block.timestamp - point0.ts)) /
                    (block.number - point0.blk);
            }
        }
        return supplyAt(point0, point0.ts + dt);
    }
}
