
pragma solidity ^0.8.0;


interface IBLXMRewardProvider {


    event Stake(address indexed sender, uint amount, address indexed to);
    event Withdraw(address indexed sender, uint amount, uint rewardAmount, address indexed to);

    event AddRewards(address indexed sender, uint32 startHour, uint32 endHour, uint amountPerHours);
    event ArrangeFailedRewards(address indexed sender, uint32 startHour, uint32 endHour, uint amountPerHours);
    event AllPosition(address indexed owner, uint amount, uint extraAmount, uint32 startHour, uint32 endLocking, uint indexed idx);
    event SyncStatistics(address indexed sender, uint amountIn, uint amountOut, uint aggregatedRewards, uint32 hour);


    function getRewardFactor(uint16 _days) external view returns (uint factor);

    function updateRewardFactor(uint16 lockedDays, uint factor) external returns (bool);


    function allPosition(address investor, uint idx) external view returns(uint amount, uint extraAmount, uint32 startHour, uint32 endLocking);

    function allPositionLength(address investor) external view returns (uint);

    function calcRewards(address investor, uint idx) external returns (uint rewardAmount, bool isLocked);

    
    function getTreasuryFields() external view returns (uint32 syncHour, uint totalAmount, uint pendingRewards, uint32 initialHour, uint16 lastSession);

    function getDailyStatistics(uint32 hourFromEpoch) external view returns (uint amountIn, uint amountOut, uint aggregatedRewards, uint32 next);

    function syncStatistics() external;

    function hoursToSession(uint32 hourFromEpoch) external view returns (uint16 session);

    function getPeriods(uint16 session) external view returns (uint amountPerHours, uint32 startHour, uint32 endHour);


    function decimals() external pure returns (uint8);

}// GPL-3.0 License

pragma solidity ^0.8.0;


interface IBLXMTreasuryManager {


    event UpdateTreasury(address indexed sender, address oldTreasury, address newTreasury);

    function updateTreasury(address treasury) external;

    function getTreasury() external returns (address treasury);


    function getReserves() external view returns (uint reserveBlxm, uint totalRewrads);

}// MIT

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
}// MIT

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
}// GPL-3.0 License

pragma solidity ^0.8.0;


library BLXMLibrary {


    function validateAddress(address _address) internal pure {

        require(_address != address(0), "ZERO_ADDRESS");
    }

    function currentHour() internal view returns(uint32) {

        return uint32(block.timestamp / 1 hours);
    }
}// GPL-3.0 License

pragma solidity ^0.8.0;



abstract contract BLXMMultiOwnable is Initializable {
    
    mapping(address => bool) public members;

    event OwnershipChanged(address indexed executeOwner, address indexed targetOwner, bool permission);

    modifier onlyOwner() {
        require(members[msg.sender], "NOT_OWNER");
        _;
    }

    function __BLXMMultiOwnable_init() internal onlyInitializing {
        _changeOwnership(msg.sender, true);
    }

    function addOwnership(address newOwner) public virtual onlyOwner {
        BLXMLibrary.validateAddress(newOwner);
        _changeOwnership(newOwner, true);
    }

    function removeOwnership(address owner) public virtual onlyOwner {
        BLXMLibrary.validateAddress(owner);
        _changeOwnership(owner, false);
    }

    function _changeOwnership(address owner, bool permission) internal virtual {
        members[owner] = permission;
        emit OwnershipChanged(msg.sender, owner, permission);
    }

    uint256[50] private __gap;
}// GPL-3.0 License

pragma solidity ^0.8.0;


interface IBLXMTreasury {


    event SendTokensToWhitelistedWallet(address indexed sender, uint amount, address indexed receiver);
    event Whitelist(address indexed sender, bool permission, address indexed wallet);


    function BLXM() external returns (address blxm);

    function SSC() external returns (address ssc);


    function addWhitelist(address wallet) external;

    function removeWhitelist(address wallet) external;

    function whitelist(address wallet) external returns (bool permission);


    function totalBlxm() external view returns (uint totalBlxm);

    function totalRewards() external view returns (uint totalRewards);

    function balanceOf(address investor) external view returns (uint balance);


    function addRewards(uint amount) external;


    function addBlxmTokens(uint amount, address to) external;

    function retrieveBlxmTokens(address from, uint amount, uint rewardAmount, address to) external;


    function sendTokensToWhitelistedWallet(uint amount, address to) external;

}// GPL-3.0 License

pragma solidity ^0.8.0;




contract BLXMTreasuryManager is BLXMMultiOwnable, IBLXMTreasuryManager {


    address internal treasury;


    function getTreasury() public override view returns (address _treasury) {

        require(treasury != address(0), 'TSC_NOT_FOUND');
        _treasury = treasury;
    }

    function updateTreasury(address _treasury) external override onlyOwner {

        require(IBLXMTreasury(_treasury).SSC() == address(this), 'INVALID_TSC');
        address oldTreasury = treasury;
        treasury = _treasury;
        emit UpdateTreasury(msg.sender, oldTreasury, _treasury);
    }

    function getReserves() public view override returns (uint reserveBlxm, uint totalRewrads) {

        reserveBlxm = IBLXMTreasury(getTreasury()).totalBlxm();
        totalRewrads = IBLXMTreasury(getTreasury()).totalRewards();
    }

    function _addRewards(uint amount) internal {

        IBLXMTreasury(getTreasury()).addRewards(amount);
    }

    function _withdraw(address from, uint amount, uint rewards, address to) internal {

        IBLXMTreasury(getTreasury()).retrieveBlxmTokens(from, amount, rewards, to);
    }

    function _notify(uint amount, address to) internal {

        IBLXMTreasury(getTreasury()).addBlxmTokens(amount, to);
    }

    uint256[50] private __gap;
}// MIT

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
}// GPL-3.0 License

pragma solidity ^0.8.0;


library SafeMath {


    function add(uint x, uint y) internal pure returns (uint z) {

        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {

        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {

        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }

    uint constant WAD = 10 ** 18;

    function wmul(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, y), WAD / 2) / WAD;
    }

    function wdiv(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, WAD), y / 2) / y;
    }
}// GPL-3.0 License

pragma solidity ^0.8.0;


library Math {

    function sqrt(uint y) internal pure returns (uint z) {

        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}// GPL-3.0 License

pragma solidity ^0.8.0;




contract BLXMRewardProvider is ReentrancyGuardUpgradeable, BLXMMultiOwnable, BLXMTreasuryManager, IBLXMRewardProvider {


    using SafeMath for uint;


    struct Field {
        uint32 syncHour; // at most sync once an hour
        uint totalAmount; // exclude extra amount
        uint pendingRewards;
        uint32 initialHour;
        uint16 lastSession;

        mapping(uint32 => uint16) daysToSession;

        mapping(uint16 => Period) periods;

        mapping(uint32 => Statistics) dailyStatistics;
    }

    struct Period {
        uint amountPerHours;
        uint32 startHour; // include, timestamp in hour from initial hour
        uint32 endHour; // exclude, timestamp in hour from initial hour
    }

    struct Statistics {
        uint amountIn; // include extra amount
        uint amountOut;
        uint aggregatedRewards; // rewards / (amountIn - amountOut)
        uint32 next;
    }

    struct Position {
        uint amount;
        uint extraAmount;
        uint32 startHour; // include, hour from epoch, time to start calculating rewards
        uint32 endLocking; // exclude, hour from epoch, locked until this hour
    }

    Field private treasuryFields;

    mapping(address => Position[]) public override allPosition;

    mapping(uint16 => uint) internal rewardFactor;


    modifier sync() {

        syncStatistics();
        _;
    }

    function updateRewardFactor(uint16 lockedDays, uint factor) public override onlyOwner returns (bool) {

        require(lockedDays != 0, 'ZERO_DAYS');
        require(factor == 0 || factor >= 10 ** decimals(), 'WRONG_FACTOR');
        rewardFactor[lockedDays] = factor;
        return true;
    }

    function getRewardFactor(uint16 lockedDays) external override view returns (uint factor) {

        factor = rewardFactor[lockedDays];
    }

    function allPositionLength(address investor) public override view returns (uint) {

        return allPosition[investor].length;
    }

    function calcRewards(address investor, uint idx) external override sync returns (uint rewardAmount, bool isLocked) {

        require(idx < allPositionLength(investor), 'NO_POSITION');
        Position memory position = allPosition[investor][idx];
        (rewardAmount, isLocked) = _calcRewards(position);
    }

    function decimals() public override pure returns (uint8) {

        return 18;
    }

    function getDailyStatistics(uint32 hourFromEpoch) external view override returns (uint amountIn, uint amountOut, uint aggregatedRewards, uint32 next) {

        Statistics memory statistics = treasuryFields.dailyStatistics[hourFromEpoch];
        amountIn = statistics.amountIn;
        amountOut = statistics.amountOut;
        aggregatedRewards = statistics.aggregatedRewards;
        next = statistics.next;
    }

    function hoursToSession(uint32 hourFromEpoch) external override view returns (uint16 session) {

        uint32 initialHour = treasuryFields.initialHour;
        if (hourFromEpoch >= initialHour) {
            uint32 hour = hourFromEpoch - initialHour;
            session = treasuryFields.daysToSession[hour / 24];
        }
    }

    function getPeriods(uint16 session) external override view returns (uint amountPerHours, uint32 startHour, uint32 endHour) {

        Period storage period = treasuryFields.periods[session];
        amountPerHours = period.amountPerHours;

        uint32 initialHour = treasuryFields.initialHour;
        startHour = period.startHour;
        endHour = period.endHour;
        
        if (startHour != 0 || endHour != 0) {
            startHour += initialHour;
            endHour += initialHour;
        }
    }

    function getTreasuryFields() external view override returns(uint32 syncHour, uint totalAmount, uint pendingRewards, uint32 initialHour, uint16 lastSession) {

        syncHour = treasuryFields.syncHour;
        totalAmount = treasuryFields.totalAmount;
        pendingRewards = treasuryFields.pendingRewards;
        initialHour = treasuryFields.initialHour;
        lastSession = treasuryFields.lastSession;
    }

    function syncStatistics() public override {

        uint32 currentHour = BLXMLibrary.currentHour();
        uint32 syncHour = treasuryFields.syncHour;

        if (syncHour < currentHour) {
            if (syncHour != 0) {
                _updateStatistics(syncHour, currentHour);
            }
            treasuryFields.syncHour = currentHour;
        }
    }

    function _addRewards(uint totalAmount, uint16 supplyDays) internal nonReentrant sync onlyOwner returns (uint amountPerHours) {

        require(totalAmount > 0 && supplyDays > 0, 'ZERO_REWARDS');

        uint16 lastSession = treasuryFields.lastSession;
        if (lastSession == 0) {
            treasuryFields.initialHour = BLXMLibrary.currentHour();
        }

        uint32 startHour = treasuryFields.periods[lastSession].endHour;
        uint32 endHour = startHour + (supplyDays * 24);

        lastSession += 1;
        treasuryFields.lastSession = lastSession;

        uint32 target = startHour / 24;
        uint32 i = endHour / 24;
        unchecked {
            while (i --> target) {
                treasuryFields.daysToSession[i] = lastSession;
            }
        }

        amountPerHours = totalAmount / (supplyDays * 24);
        treasuryFields.periods[lastSession] = Period(amountPerHours, startHour, endHour);

        if (treasuryFields.pendingRewards != 0) {
            uint pendingRewards = treasuryFields.pendingRewards;
            treasuryFields.pendingRewards = 0;
            _arrangeFailedRewards(pendingRewards);
        }

        uint32 initialHour = treasuryFields.initialHour;
        _addRewards(totalAmount);
        emit AddRewards(msg.sender, initialHour + startHour, initialHour + endHour, amountPerHours);
    }

    function _calcRewards(Position memory position) internal view returns (uint rewardAmount, bool isLocked) {


        uint32 currentHour = BLXMLibrary.currentHour();
        require(treasuryFields.syncHour == currentHour, 'NOT_SYNC');

        if (currentHour < position.startHour) {
            return (0, true);
        }

        if (currentHour < position.endLocking) {
            isLocked = true;
        }

        uint amount = position.amount;
        uint extraAmount = position.extraAmount;
        
        uint aggNow = treasuryFields.dailyStatistics[currentHour].aggregatedRewards;
        uint aggStart = treasuryFields.dailyStatistics[position.startHour].aggregatedRewards;
        if (isLocked) {
            rewardAmount = amount.add(extraAmount).wmul(aggNow.sub(aggStart));
        } else {
            uint aggEnd = treasuryFields.dailyStatistics[position.endLocking].aggregatedRewards;
            rewardAmount = extraAmount.wmul(aggEnd.sub(aggStart));
            rewardAmount = rewardAmount.add(amount.wmul(aggNow.sub(aggStart)));
        }
    }

    function _stake(address to, uint amount, uint16 lockedDays) internal nonReentrant sync {

        require(amount != 0, 'INSUFFICIENT_AMOUNT');
        uint256 _factor = rewardFactor[lockedDays];
        require(_factor != 0, 'NO_FACTOR');

        uint extraAmount = amount.wmul(_factor.sub(10 ** decimals()));

        uint32 startHour = BLXMLibrary.currentHour() + 1;
        uint32 endLocking = startHour + (lockedDays * 24);

        allPosition[to].push(Position(amount, extraAmount, startHour, endLocking));
        
        _updateAmount(startHour, amount.add(extraAmount), 0);
        if (extraAmount != 0) {
            _updateAmount(endLocking, 0, extraAmount);
        }

        treasuryFields.totalAmount = amount.add(treasuryFields.totalAmount);

        _notify(amount, to);
        emit Stake(msg.sender, amount, to);
        _emitAllPosition(to, allPositionLength(to) - 1);
    }

    function _withdraw(address to, uint amount, uint idx) internal nonReentrant sync returns (uint rewardAmount) {

        require(idx < allPositionLength(msg.sender), 'NO_POSITION');
        Position memory position = allPosition[msg.sender][idx];
        require(amount > 0 && amount <= position.amount, 'INSUFFICIENT_AMOUNT');

        uint32 hour = BLXMLibrary.currentHour();
        hour = hour >= position.startHour ? hour : position.startHour;
        _updateAmount(hour, 0, amount);

        uint extraAmount = position.extraAmount * amount / position.amount;

        bool isLocked;
        (rewardAmount, isLocked) = _calcRewards(position);
        rewardAmount = rewardAmount * amount / position.amount;
        if (isLocked) {
            _arrangeFailedRewards(rewardAmount);
            rewardAmount = 0;
            _updateAmount(hour, 0, extraAmount);
            _updateAmount(position.endLocking, extraAmount, 0);
        }

        allPosition[msg.sender][idx].amount = position.amount.sub(amount);
        allPosition[msg.sender][idx].extraAmount = position.extraAmount.sub(extraAmount);
        
        uint _totalAmount = treasuryFields.totalAmount;
        treasuryFields.totalAmount = _totalAmount.sub(amount);

        _withdraw(msg.sender, amount, rewardAmount, to);
        emit Withdraw(msg.sender, amount, rewardAmount, to);
        _emitAllPosition(msg.sender, idx);
    }

    function _arrangeFailedRewards(uint rewardAmount) internal {

        if (rewardAmount == 0) {
            return;
        }
        uint32 initialHour = treasuryFields.initialHour;
        uint32 startHour = BLXMLibrary.currentHour() - initialHour;
        uint16 session = treasuryFields.daysToSession[startHour / 24];
        if (session == 0) {
            treasuryFields.pendingRewards += rewardAmount; 
        }

        uint32 endHour = treasuryFields.periods[session].endHour;
        uint32 leftHour = endHour - startHour;
        uint amountPerHours = rewardAmount / leftHour;
        treasuryFields.periods[session].amountPerHours += amountPerHours;

        emit ArrangeFailedRewards(msg.sender, initialHour + startHour, initialHour + endHour, amountPerHours);
    }

    function _emitAllPosition(address owner, uint idx) internal {

        Position memory position = allPosition[owner][idx];
        emit AllPosition(owner, position.amount, position.extraAmount, position.startHour, position.endLocking, idx);
    }

    function _updateAmount(uint32 hour, uint amountIn, uint amountOut) internal {

        require(hour >= BLXMLibrary.currentHour(), 'DATA_FIXED');
        Statistics memory statistics = treasuryFields.dailyStatistics[hour];
        statistics.amountIn = statistics.amountIn.add(amountIn);
        statistics.amountOut = statistics.amountOut.add(amountOut);
        treasuryFields.dailyStatistics[hour] = statistics;
    }

    function _updateStatistics(uint32 fromHour, uint32 toHour) internal {

        Statistics storage statistics = treasuryFields.dailyStatistics[fromHour];
        uint amountIn = statistics.amountIn;
        uint amountOut = statistics.amountOut;
        uint aggregatedRewards = statistics.aggregatedRewards;
        uint32 prev = fromHour; // point to previous statistics
        while (fromHour < toHour) {
            uint amount = amountIn.sub(amountOut);
            uint rewards = treasuryFields.periods[treasuryFields.daysToSession[(fromHour - treasuryFields.initialHour) / 24]].amountPerHours;

            if (amount != 0) {
                aggregatedRewards = aggregatedRewards.add(rewards.wdiv(amount));
            }

            fromHour += 1;
            statistics = treasuryFields.dailyStatistics[fromHour];

            if (statistics.amountIn != 0 || statistics.amountOut != 0 || fromHour == toHour) {
                statistics.aggregatedRewards = aggregatedRewards;
                statistics.amountIn = amountIn = amountIn.add(statistics.amountIn);
                statistics.amountOut = amountOut = amountOut.add(statistics.amountOut);
                treasuryFields.dailyStatistics[prev].next = fromHour;
                prev = fromHour;

                emit SyncStatistics(msg.sender, amountIn, amountOut, aggregatedRewards, fromHour);
            }
        }
    }

    uint256[50] private __gap;
}// GPL-3.0 License

pragma solidity ^0.8.0;


interface IBLXMStaker {


    function BLXM() external view returns (address);


    function addRewards(uint totalBlxmAmount, uint16 supplyDays) external returns (uint amountPerHours);

    function stake(uint256 amount, address to, uint16 lockedDays) external;

    function withdraw(uint256 amount, address to, uint256 idx) external returns (uint256 rewardAmount);

}// GPL-3.0 License

pragma solidity ^0.8.0;


interface IWETH {

    function deposit() external payable;

    function transfer(address to, uint value) external returns (bool);

    function withdraw(uint) external;

}// GPL-3.0-or-later

pragma solidity ^0.8.0;

library TransferHelper {

    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferCurrency(address to, uint256 value) internal {

        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper: CURRENCY_TRANSFER_FAILED');
    }
}// GPL-3.0 License

pragma solidity ^0.8.0;





contract BLXMStaker is Initializable, BLXMRewardProvider, IBLXMStaker {

    using SafeMath for uint256;

    address public override BLXM;

    function initialize(address _BLXM) public initializer {

        __ReentrancyGuard_init();
        __BLXMMultiOwnable_init();

        updateRewardFactor(30, 1000000000000000000);
        updateRewardFactor(90, 1300000000000000000);
        updateRewardFactor(180, 1690000000000000000);
        updateRewardFactor(360, 2197000000000000000);

        BLXM = _BLXM;
    }

    function addRewards(uint256 totalBlxmAmount, uint16 supplyDays) external override returns (uint256 amountPerHours) {

        TransferHelper.safeTransferFrom(BLXM, msg.sender, getTreasury(), totalBlxmAmount);
        amountPerHours = _addRewards(totalBlxmAmount, supplyDays);
    }

    function stake(uint256 amount, address to, uint16 lockedDays) external override {

        require(amount > 0, "ZERO_AMOUNT");
        TransferHelper.safeTransferFrom(BLXM, msg.sender, getTreasury(), amount);
        _stake(to, amount, lockedDays);
    }

    function withdraw(uint256 amount, address to, uint256 idx) external override returns (uint256 rewardAmount) {

        require(amount > 0, "ZERO_AMOUNT");
        rewardAmount = _withdraw(to, amount, idx);
    }

    uint256[50] private __gap;
}