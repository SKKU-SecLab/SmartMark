
pragma solidity ^0.8.0;


interface IBLXMRewardProvider {


    event Mint(address indexed sender, uint amountBlxm, uint amountToken);
    event Burn(address indexed sender, uint amountBlxm, uint amountToken, uint rewardAmount, address indexed to);
    event AddRewards(address indexed sender, uint32 startHour, uint32 endHour, uint amountPerHours);
    event ArrangeFailedRewards(address indexed sender, uint32 startHour, uint32 endHour, uint amountPerHours);
    event AllPosition(address indexed owner, address indexed token, uint liquidity, uint extraLiquidity, uint32 startHour, uint32 endLocking, uint indexed idx);
    event SyncStatistics(address indexed sender, address indexed token, uint liquidityIn, uint liquidityOut, uint aggregatedRewards, uint32 hour);

    function getRewardFactor(uint16 _days) external view returns (uint factor);

    function updateRewardFactor(uint16 lockedDays, uint factor) external returns (bool);


    function allPosition(address investor, uint idx) external view returns(address token, uint liquidity, uint extraLiquidity, uint32 startHour, uint32 endLocking);

    function allPositionLength(address investor) external view returns (uint);

    function calcRewards(address investor, uint idx) external returns (uint amount, bool isLocked);

    
    function getTreasuryFields(address token) external view returns (uint32 syncHour, uint totalLiquidity, uint pendingRewards, uint32 initialHour, uint16 lastSession);

    function getDailyStatistics(address token, uint32 hourFromEpoch) external view returns (uint liquidityIn, uint liquidityOut, uint aggregatedRewards, uint32 next);

    function syncStatistics(address token) external;

    function hoursToSession(address token, uint32 hourFromEpoch) external view returns (uint16 session);

    function getPeriods(address token, uint16 session) external view returns (uint amountPerHours, uint32 startHour, uint32 endHour);


    function decimals() external pure returns (uint8);

}// GPL-3.0 License

pragma solidity ^0.8.0;


interface IBLXMTreasuryManager {


    event TreasuryPut(address indexed sender, address oldTreasury, address newTreasury, address indexed token);

    function putTreasury(address token, address treasury) external;

    function getTreasury(address token) external view returns (address treasury);

    function getReserves(address token) external view returns (uint reserveBlxm, uint reserveToken);


    function updateRatioAdmin(address _ratioAdmin) external;

    function getRatio(address token) external view returns (uint ratio);

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


interface ITreasury {

    function get_total_amounts() external view returns (uint amount0, uint amount1, uint[] memory totalAmounts0, uint[] memory totalAmounts1, uint[] memory currentAmounts0, uint[] memory currentAmounts1);

    function get_tokens(uint reward, uint requestedAmount0, uint requestedAmount1, address to) external returns (uint sentToken, uint sentBlxm);

    function add_liquidity(uint amountBlxm, uint amountToken, address to) external;

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




library BLXMLibrary {

    using SafeMath for uint;

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


interface IRatioAdmin {


    event UpdateRatio(address indexed sender, address indexed token, uint ratio);

    function getRatio(address token) external view returns (uint ratio);

    function updateRatio(address token, uint ratio) external;

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




contract BLXMTreasuryManager is BLXMMultiOwnable, IBLXMTreasuryManager {


    using SafeMath for uint;

    mapping(address => address) internal treasuries;
    mapping(address => bool) internal exclude;
    address public ratioAdmin;


    function putTreasury(address token, address treasury) external override onlyOwner {

        _validateToken(token);
        BLXMLibrary.validateAddress(treasury);

        address oldTreasury = treasuries[token];
        treasuries[token] = treasury;
        emit TreasuryPut(msg.sender, oldTreasury, treasury, token);
    }

    function getTreasury(address token) public view override returns (address treasury) {

        _validateToken(token);
        BLXMLibrary.validateAddress(treasury = treasuries[token]);
    }

    function getReserves(address token) public view override returns (uint reserveBlxm, uint reserveToken) {

        (reserveBlxm, reserveToken,,,,) = ITreasury(getTreasury(token)).get_total_amounts();
    }

    function updateRatioAdmin(address _ratioAdmin) external override onlyOwner {

        BLXMLibrary.validateAddress(_ratioAdmin);
        ratioAdmin = _ratioAdmin;
    }

    function getRatio(address token) public view override returns (uint ratio) {

        getTreasury(token);
        ratio = IRatioAdmin(ratioAdmin).getRatio(token);
        assert(ratio != 0);
    }

    function _withdraw(address token, uint rewards, uint liquidity, address to) internal returns (uint amountBlxm, uint amountToken) {

        uint _ratio = getRatio(token);

        amountToken = liquidity.mul(10 ** 9) / Math.sqrt(_ratio);
        amountBlxm = amountToken.wmul(_ratio);

        ITreasury(getTreasury(token)).get_tokens(rewards, amountBlxm, amountToken, to);
    }

    function _notify(address token, uint amountBlxm, uint amountToken, address to) internal {

        ITreasury(getTreasury(token)).add_liquidity(amountBlxm, amountToken, to);
    }

    function _validateToken(address token) internal view {

        require(!exclude[token], 'INVALID_TOKEN');
        BLXMLibrary.validateAddress(token);
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




contract BLXMRewardProvider is ReentrancyGuardUpgradeable, BLXMMultiOwnable, BLXMTreasuryManager, IBLXMRewardProvider {


    using SafeMath for uint;

    struct Field {
        uint32 syncHour; // at most sync once an hour
        uint totalLiquidity; // exclude extra liquidity
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
        uint liquidityIn; // include extra liquidity
        uint liquidityOut;
        uint aggregatedRewards; // rewards / (liquidityIn - liquidityOut)
        uint32 next;
    }

    struct Position {
        address token; // (another pair from blxm)
        uint liquidity;
        uint extraLiquidity;
        uint32 startHour; // include, hour from epoch, time to start calculating rewards
        uint32 endLocking; // exclude, hour from epoch, locked until this hour
    }

    mapping(address => Field) private treasuryFields;

    mapping(address => Position[]) public override allPosition;

    mapping(uint16 => uint) internal rewardFactor;


    function updateRewardFactor(uint16 lockedDays, uint factor) public override onlyOwner returns (bool) {

        require(lockedDays != 0, 'ZERO_DAYS');
        rewardFactor[lockedDays] = factor.sub(10 ** 18);
        return true;
    }

    function getRewardFactor(uint16 lockedDays) external override view returns (uint factor) {

        factor = rewardFactor[lockedDays];
        factor = factor.add(10 ** 18);
    }

    function allPositionLength(address investor) public override view returns (uint) {

        return allPosition[investor].length;
    }

    function _addRewards(address token, uint totalAmount, uint16 supplyDays) internal nonReentrant onlyOwner returns (uint amountPerHours) {

        require(totalAmount > 0 && supplyDays > 0, 'ZERO_REWARDS');
        _syncStatistics(token);

        Field storage field = treasuryFields[token];

        uint16 lastSession = field.lastSession;
        if (lastSession == 0) {
            field.initialHour = BLXMLibrary.currentHour();
        }

        uint32 startHour = field.periods[lastSession].endHour;
        uint32 endHour = startHour + (supplyDays * 24);

        lastSession += 1;
        field.lastSession = lastSession;

        uint32 target = startHour / 24;
        uint32 i = endHour / 24;
        unchecked {
            while (i --> target) {
                field.daysToSession[i] = lastSession;
            }
        }

        amountPerHours = totalAmount / (supplyDays * 24);
        field.periods[lastSession] = Period(amountPerHours, startHour, endHour);

        if (field.pendingRewards != 0) {
            uint pendingRewards = field.pendingRewards;
            field.pendingRewards = 0;
            _arrangeFailedRewards(token, pendingRewards);
        }

        uint32 initialHour = field.initialHour;
        emit AddRewards(msg.sender, initialHour + startHour, initialHour + endHour, amountPerHours);
    }

    function calcRewards(address investor, uint idx) external override returns (uint amount, bool isLocked) {

        require(idx < allPositionLength(investor), 'NO_POSITION');
        Position memory position = allPosition[investor][idx];
        _syncStatistics(position.token);
        (amount, isLocked) = _calcRewards(position);
    }

    function syncStatistics(address token) public override {

        getTreasury(token);
        _syncStatistics(token);
    }

    function decimals() public override pure returns (uint8) {

        return 18;
    }

    function getDailyStatistics(address token, uint32 hourFromEpoch) external view override returns (uint liquidityIn, uint liquidityOut, uint aggregatedRewards, uint32 next) {

        Statistics memory statistics = treasuryFields[token].dailyStatistics[hourFromEpoch];
        liquidityIn = statistics.liquidityIn;
        liquidityOut = statistics.liquidityOut;
        aggregatedRewards = statistics.aggregatedRewards;
        next = statistics.next;
    }

    function hoursToSession(address token, uint32 hourFromEpoch) external override view returns (uint16 session) {

        Field storage field = treasuryFields[token];
        uint32 initialHour = field.initialHour;
        if (hourFromEpoch >= initialHour) {
            uint32 hour = hourFromEpoch - initialHour;
            session = field.daysToSession[hour / 24];
        }
    }

    function getPeriods(address token, uint16 session) external override view returns (uint amountPerHours, uint32 startHour, uint32 endHour) {

        Field storage field = treasuryFields[token];

        Period storage period = field.periods[session];
        amountPerHours = period.amountPerHours;

        uint32 initialHour = field.initialHour;
        startHour = period.startHour;
        endHour = period.endHour;
        
        if (startHour != 0 || endHour != 0) {
            startHour += initialHour;
            endHour += initialHour;
        }
    }

    function getTreasuryFields(address token) external view override returns(uint32 syncHour, uint totalLiquidity, uint pendingRewards, uint32 initialHour, uint16 lastSession) {

        Field storage fields = treasuryFields[token];
        syncHour = fields.syncHour;
        totalLiquidity = fields.totalLiquidity;
        pendingRewards = fields.pendingRewards;
        initialHour = fields.initialHour;
        lastSession = fields.lastSession;
    }

    function _calcRewards(Position memory position) internal view returns (uint amount, bool isLocked) {


        uint32 currentHour = BLXMLibrary.currentHour();
        require(treasuryFields[position.token].syncHour == currentHour, 'NOT_SYNC');

        if (currentHour < position.startHour) {
            return (0, true);
        }

        if (currentHour < position.endLocking) {
            isLocked = true;
        }

        uint liquidity = position.liquidity;
        uint extraLiquidity = position.extraLiquidity;
        
        Field storage field = treasuryFields[position.token];
        uint aggNow = field.dailyStatistics[currentHour].aggregatedRewards;
        uint aggStart = field.dailyStatistics[position.startHour].aggregatedRewards;
        if (isLocked) {
            amount = liquidity.add(extraLiquidity).wmul(aggNow.sub(aggStart));
        } else {
            uint aggEnd = field.dailyStatistics[position.endLocking].aggregatedRewards;
            amount = extraLiquidity.wmul(aggEnd.sub(aggStart));
            amount = amount.add(liquidity.wmul(aggNow.sub(aggStart)));
        }
    }

    function _mint(address to, address token, uint amountBlxm, uint amountToken, uint16 lockedDays) internal nonReentrant returns (uint liquidity) {

        liquidity = Math.sqrt(amountBlxm.mul(amountToken));
        require(liquidity != 0, 'INSUFFICIENT_LIQUIDITY');
        _syncStatistics(token);

        uint factor = rewardFactor[lockedDays];
        uint extraLiquidity = liquidity.wmul(factor);

        uint32 startHour = BLXMLibrary.currentHour() + 1;
        uint32 endLocking = factor != 0 ? startHour + (lockedDays * 24) : startHour;

        allPosition[to].push(Position(token, liquidity, extraLiquidity, startHour, endLocking));
        
        _updateLiquidity(token, startHour, liquidity.add(extraLiquidity), 0);
        if (extraLiquidity != 0) {
            _updateLiquidity(token, endLocking, 0, extraLiquidity);
        }

        treasuryFields[token].totalLiquidity = liquidity.add(treasuryFields[token].totalLiquidity);

        _notify(token, amountBlxm, amountToken, to);
        emit Mint(msg.sender, amountBlxm, amountToken);
        _emitAllPosition(to, allPositionLength(to) - 1);
    }

    function _burn(address to, uint liquidity, uint idx) internal nonReentrant returns (uint amountBlxm, uint amountToken, uint rewardAmount) {

        require(idx < allPositionLength(msg.sender), 'NO_POSITION');
        Position memory position = allPosition[msg.sender][idx];
        require(liquidity > 0 && liquidity <= position.liquidity, 'INSUFFICIENT_LIQUIDITY');
        _syncStatistics(position.token);

        uint32 hour = BLXMLibrary.currentHour();
        hour = hour >= position.startHour ? hour : position.startHour;
        _updateLiquidity(position.token, hour, 0, liquidity);

        uint extraLiquidity = position.extraLiquidity * liquidity / position.liquidity;

        bool isLocked;
        (rewardAmount, isLocked) = _calcRewards(position);
        rewardAmount = rewardAmount * liquidity / position.liquidity;
        if (isLocked) {
            _arrangeFailedRewards(position.token, rewardAmount);
            rewardAmount = 0;
            _updateLiquidity(position.token, hour, 0, extraLiquidity);
            _updateLiquidity(position.token, position.endLocking, extraLiquidity, 0);
        }

        allPosition[msg.sender][idx].liquidity = position.liquidity.sub(liquidity);
        allPosition[msg.sender][idx].extraLiquidity = position.extraLiquidity.sub(extraLiquidity);
        
        uint _totalLiquidity = treasuryFields[position.token].totalLiquidity;
        treasuryFields[position.token].totalLiquidity = _totalLiquidity.sub(liquidity);

        (amountBlxm, amountToken) = _withdraw(position.token, rewardAmount, liquidity, to);
        emit Burn(msg.sender, amountBlxm, amountToken, rewardAmount, to);
        _emitAllPosition(msg.sender, idx);
    }

    function _emitAllPosition(address owner, uint idx) internal {

        Position memory position = allPosition[owner][idx];
        emit AllPosition(owner, position.token, position.liquidity, position.extraLiquidity, position.startHour, position.endLocking, idx);
    }

    function _arrangeFailedRewards(address token, uint rewardAmount) internal {

        if (rewardAmount == 0) {
            return;
        }
        Field storage field = treasuryFields[token];
        uint32 initialHour = field.initialHour;
        uint32 startHour = BLXMLibrary.currentHour() - initialHour;
        uint16 session = field.daysToSession[startHour / 24];
        if (session == 0) {
            field.pendingRewards += rewardAmount; 
            return;
        }

        uint32 endHour = field.periods[session].endHour;
        uint32 leftHour = endHour - startHour;
        uint amountPerHours = rewardAmount / leftHour;
        field.periods[session].amountPerHours += amountPerHours;

        emit ArrangeFailedRewards(msg.sender, initialHour + startHour, initialHour + endHour, amountPerHours);
    }

    function _updateLiquidity(address token, uint32 hour, uint liquidityIn, uint liquidityOut) internal {

        require(hour >= BLXMLibrary.currentHour(), 'DATA_FIXED');
        Field storage field = treasuryFields[token];
        Statistics memory statistics = field.dailyStatistics[hour];
        statistics.liquidityIn = statistics.liquidityIn.add(liquidityIn);
        statistics.liquidityOut = statistics.liquidityOut.add(liquidityOut);
        field.dailyStatistics[hour] = statistics;
    }

    function _syncStatistics(address token) internal {

        uint32 currentHour = BLXMLibrary.currentHour();
        uint32 syncHour = treasuryFields[token].syncHour;

        if (syncHour < currentHour) {
            if (syncHour != 0) {
                _updateStatistics(token, syncHour, currentHour);
            }
            treasuryFields[token].syncHour = currentHour;
        }
    }

    function _updateStatistics(address token, uint32 fromHour, uint32 toHour) internal {

        Field storage field = treasuryFields[token];
        Statistics storage statistics = field.dailyStatistics[fromHour];
        uint liquidityIn = statistics.liquidityIn;
        uint liquidityOut = statistics.liquidityOut;
        uint aggregatedRewards = statistics.aggregatedRewards;
        uint32 prev = fromHour; // point to previous statistics
        while (fromHour < toHour) {
            uint liquidity = liquidityIn.sub(liquidityOut);
            uint rewards = field.periods[field.daysToSession[(fromHour - field.initialHour) / 24]].amountPerHours;

            if (liquidity != 0) {
                aggregatedRewards = aggregatedRewards.add(rewards.wdiv(liquidity));
            }

            fromHour += 1;
            statistics = field.dailyStatistics[fromHour];

            if (statistics.liquidityIn != 0 || statistics.liquidityOut != 0 || fromHour == toHour) {
                statistics.aggregatedRewards = aggregatedRewards;
                statistics.liquidityIn = liquidityIn = liquidityIn.add(statistics.liquidityIn);
                statistics.liquidityOut = liquidityOut = liquidityOut.add(statistics.liquidityOut);
                field.dailyStatistics[prev].next = fromHour;
                prev = fromHour;

                emit SyncStatistics(msg.sender, token, liquidityIn, liquidityOut, aggregatedRewards, fromHour);
            }
        }
    }

    uint256[50] private __gap;
}// GPL-3.0 License

pragma solidity ^0.8.0;


interface IBLXMRouter {


    function BLXM() external view returns (address);

    
    function addRewards(address token, uint totalBlxmAmount, uint16 supplyDays) external returns (uint amountPerHours);


    function addLiquidity(
        address token,
        uint amountBlxmDesired,
        uint amountTokenDesired,
        uint amountBlxmMin,
        uint amountTokenMin,
        address to,
        uint deadline,
        uint16 lockedDays
    ) external returns (uint amountBlxm, uint amountToken, uint liquidity);


    function removeLiquidity(
        uint liquidity,
        uint amountBlxmMin,
        uint amountTokenMin,
        address to,
        uint deadline,
        uint idx
    ) external returns (uint amountBlxm, uint amountToken, uint rewards);

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




contract BLXMRouter is Initializable, BLXMRewardProvider, IBLXMRouter {


    using SafeMath for uint;

    address public override BLXM;


    modifier ensure(uint deadline) {

        require(deadline >= block.timestamp, 'EXPIRED');
        _;
    }

    function initialize(address _BLXM) public initializer {

        __ReentrancyGuard_init();
        __BLXMMultiOwnable_init();
        
        updateRewardFactor(30, 1100000000000000000); // 1.1
        updateRewardFactor(60, 1210000000000000000); // 1.21
        updateRewardFactor(90, 1331000000000000000); // 1.331
        
        exclude[_BLXM] = true;
        BLXM = _BLXM;
    }

    function addRewards(address token, uint totalBlxmAmount, uint16 supplyDays) external override returns (uint amountPerHours) {

        TransferHelper.safeTransferFrom(BLXM, msg.sender, getTreasury(token), totalBlxmAmount);
        amountPerHours = _addRewards(token, totalBlxmAmount, supplyDays);
    }

    function _addLiquidity(
        address token,
        uint amountBlxmDesired,
        uint amountTokenDesired,
        uint amountBlxmMin,
        uint amountTokenMin
    ) private view returns (uint amountBlxm, uint amountToken) {

        _validateToken(token);

        uint ratio = getRatio(token);
        uint amountTokenOptimal = amountBlxmDesired.wdiv(ratio);
        if (amountTokenOptimal <= amountTokenDesired) {
            require(amountTokenOptimal >= amountTokenMin, 'INSUFFICIENT_BLXM_AMOUNT');
            (amountBlxm, amountToken) = (amountBlxmDesired, amountTokenOptimal);
        } else {
            uint amountBlxmOptimal = amountTokenDesired.wmul(ratio);
            assert(amountBlxmOptimal <= amountBlxmDesired);
            require(amountBlxmOptimal >= amountBlxmMin, 'INSUFFICIENT_TOKEN_AMOUNT');
            (amountBlxm, amountToken) = (amountBlxmOptimal, amountTokenDesired);
        }
    }

    function addLiquidity(
        address token,
        uint amountBlxmDesired,
        uint amountTokenDesired,
        uint amountBlxmMin,
        uint amountTokenMin,
        address to,
        uint deadline,
        uint16 lockedDays
    ) external override ensure(deadline) returns (uint amountBlxm, uint amountToken, uint liquidity) {

        (amountBlxm, amountToken) = _addLiquidity(token, amountBlxmDesired, amountTokenDesired, amountBlxmMin, amountTokenMin);
        address treasury = getTreasury(token);
        TransferHelper.safeTransferFrom(BLXM, msg.sender, treasury, amountBlxm);
        TransferHelper.safeTransferFrom(token, msg.sender, treasury, amountToken);
        liquidity = _mint(to, token, amountBlxm, amountToken, lockedDays);
    }

    function removeLiquidity(
        uint liquidity,
        uint amountBlxmMin,
        uint amountTokenMin,
        address to,
        uint deadline,
        uint idx
    ) public override ensure(deadline) returns (uint amountBlxm, uint amountToken, uint rewards) {

        require(msg.sender == to, 'WRONG_ADDRESS');
        (amountBlxm, amountToken, rewards) = _burn(to, liquidity, idx);
        require(amountBlxm >= amountBlxmMin, 'INSUFFICIENT_BLXM_AMOUNT');
        require(amountToken >= amountTokenMin, 'INSUFFICIENT_TOKEN_AMOUNT');
    }

    uint256[50] private __gap;
}