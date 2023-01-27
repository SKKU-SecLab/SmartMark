
pragma solidity =0.7.5;

library SafeMath {


    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a);
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {


        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0);
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);
        return a % b;
    }
}

pragma solidity =0.7.5;

contract Context {


    function _msgSender() internal view virtual returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {

        this;
        return msg.data;
    }
}

contract ERC20 is Context {


    using SafeMath for uint256;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 private _totalSupply = 0.404 ether;

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    constructor (string memory tokenName, string memory tokenSymbol) {
        _name = tokenName;
        _symbol = tokenSymbol;
        _decimals = 18;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function transfer(
        address recipient,
        uint256 amount
    )
        public
        returns (bool)
    {

        _transfer(
            _msgSender(),
            recipient,
            amount
        );

        return true;
    }

    function allowance(
        address owner,
        address spender
    )
        public
        view
        returns (uint256)
    {

        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    )
        public
        returns (bool)
    {

        _approve(
            _msgSender(),
            spender,
            amount
        );

        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    )
        public
        returns (bool)
    {

        _transfer(
            sender,
            recipient,
            amount
        );
        _approve(sender,
            _msgSender(), _allowances[sender][_msgSender()].sub(
                amount
            )
        );
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    )
        internal
        virtual
    {

        require(
            sender != address(0x0),
            'ERC20: transfer from the zero address'
        );

        require(
            recipient != address(0x0),
            'ERC20: transfer to the zero address'
        );

        _balances[sender] =
        _balances[sender].sub(amount);

        _balances[recipient] =
        _balances[recipient].add(amount);

        emit Transfer(
            sender,
            recipient,
            amount
        );
    }

    function _mint(
        address account,
        uint256 amount
    )
        internal
        virtual
    {

        require(
            account != address(0x0),
            'ERC20: mint to the zero address'
        );

        _totalSupply =
        _totalSupply.add(amount);

        _balances[account] =
        _balances[account].add(amount);

        emit Transfer(
            address(0x0),
            account,
            amount
        );
    }

    function _burn(
        address account,
        uint256 amount
    )
        internal
        virtual
    {

        require(
            account != address(0x0),
            'ERC20: burn from the zero address'
        );

        _balances[account] =
        _balances[account].sub(amount);

        _totalSupply =
        _totalSupply.sub(amount);

        emit Transfer(
            account,
            address(0x0),
            amount
        );
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    )
        internal
        virtual
    {

        require(
            owner != address(0x0)
        );

        require(
            spender != address(0x0)
        );

        _allowances[owner][spender] = amount;

        emit Approval(
            owner,
            spender,
            amount
        );
    }
}


pragma solidity =0.7.5;

contract Events {


    event StakeStart(
        bytes16 indexed stakeID,
        address indexed stakerAddress,
        address indexed referralAddress,
        uint256 stakedAmount,
        uint256 stakesShares,
        uint256 referralShares,
        uint256 startDay,
        uint256 lockDays,
        uint256 daiEquivalent
    );

    event StakeEnd(
        bytes16 indexed stakeID,
        address indexed stakerAddress,
        address indexed referralAddress,
        uint256 stakedAmount,
        uint256 stakesShares,
        uint256 referralShares,
        uint256 rewardAmount,
        uint256 closeDay,
        uint256 penaltyAmount
    );

    event InterestScraped(
        bytes16 indexed stakeID,
        address indexed stakerAddress,
        uint256 scrapeAmount,
        uint256 scrapeDay,
        uint256 stakersPenalty,
        uint256 referrerPenalty,
        uint256 currentWiseDay
    );

    event ReferralCollected(
        address indexed staker,
        bytes16 indexed stakeID,
        address indexed referrer,
        bytes16 referrerID,
        uint256 rewardAmount
    );

    event NewGlobals(
        uint256 totalShares,
        uint256 totalStaked,
        uint256 shareRate,
        uint256 referrerShares,
        uint256 indexed currentWiseDay
    );

    event NewSharePrice(
        uint256 newSharePrice,
        bytes32 stakeID
    );

    event UniswapReserves(
        uint112 reserveA,
        uint112 reserveB,
        uint32 blockTimestampLast
    );

    event LiquidityGuardStatus(
        bool isActive
    );
}// --🦉--

pragma solidity =0.7.5;


abstract contract Global is ERC20, Events {

    using SafeMath for uint256;

    struct Globals {
        uint256 totalStaked;
        uint256 totalShares;
        uint256 sharePrice;
        uint256 currentWiseDay;
        uint256 referralShares;
    }

    Globals public globals;

    constructor() {
        globals.sharePrice = 100E15;
    }

    function _increaseGlobals(
        uint256 _staked,
        uint256 _shares,
        uint256 _rshares
    )
        internal
    {
        globals.totalStaked =
        globals.totalStaked.add(_staked);

        globals.totalShares =
        globals.totalShares.add(_shares);

        if (_rshares > 0) {

            globals.referralShares =
            globals.referralShares.add(_rshares);
        }

        _logGlobals();
    }

    function _decreaseGlobals(
        uint256 _staked,
        uint256 _shares,
        uint256 _rshares
    )
        internal
    {
        globals.totalStaked =
        globals.totalStaked > _staked ?
        globals.totalStaked - _staked : 0;

        globals.totalShares =
        globals.totalShares > _shares ?
        globals.totalShares - _shares : 0;

        if (_rshares > 0) {

            globals.referralShares =
            globals.referralShares > _rshares ?
            globals.referralShares - _rshares : 0;

        }

        _logGlobals();
    }

    function _logGlobals()
        private
    {
        emit NewGlobals(
            globals.totalShares,
            globals.totalStaked,
            globals.sharePrice,
            globals.referralShares,
            globals.currentWiseDay
        );
    }
}// --🦉--

pragma solidity =0.7.5;


interface IUniswapV2Factory {


    function createPair(
        address tokenA,
        address tokenB
    ) external returns (
        address pair
    );

}

interface IUniswapRouterV2 {


    function getAmountsOut(
        uint amountIn,
        address[] calldata path
    ) external view returns (
        uint[] memory amounts
    );


    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (
        uint[] memory amounts
    );


    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (
        uint[] memory amounts
    );

}

interface IUniswapV2Pair {


    function getReserves() external view returns (
        uint112 reserve0,
        uint112 reserve1,
        uint32 blockTimestampLast
    );


    function transfer(
        address to,
        uint256 value
    ) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);


    function balanceOf(
        address owner
    ) external view returns (uint256);


    function token1() external view returns (address);

    function totalSupply() external view returns (uint256);

}

interface ILiquidityGuard {

    function getInflation(uint32 _amount) external view returns (uint256);

}

interface ERC20TokenI {


    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )  external returns (
        bool success
    );


    function approve(
        address _spender,
        uint256 _value
    )  external returns (
        bool success
    );

}

abstract contract Declaration is Global {

    uint256 constant _decimals = 18;
    uint256 constant YODAS_PER_WISE = 10 ** _decimals;

    uint32 constant SECONDS_IN_DAY = 86400 seconds;
    uint16 constant MIN_LOCK_DAYS = 1;
    uint16 constant FORMULA_DAY = 65;
    uint16 constant MAX_LOCK_DAYS = 15330; // 42 years
    uint16 constant MAX_BONUS_DAYS_A = 1825; // 5 years
    uint16 constant MAX_BONUS_DAYS_B = 13505; // 37 years
    uint16 constant MIN_REFERRAL_DAYS = 365;

    uint32 constant MIN_STAKE_AMOUNT = 1000000;
    uint32 constant REFERRALS_RATE = 366816973; // 1.000% (direct value, can be used right away)
    uint32 constant INFLATION_RATE_MAX = 103000; // 3.000% (indirect -> checks throgh LiquidityGuard)

    uint32 public INFLATION_RATE = 103000; // 3.000% (indirect -> checks throgh LiquidityGuard)
    uint32 public LIQUIDITY_RATE = 100006; // 0.006% (indirect -> checks throgh LiquidityGuard)

    uint64 constant PRECISION_RATE = 1E18;

    uint96 constant THRESHOLD_LIMIT = 10000E18; // $10,000 DAI Mainnet
    uint96 constant DAILY_BONUS_A = 13698630136986302; // 25%:1825 = 0.01369863013 per day;
    uint96 constant DAILY_BONUS_B = 370233246945576;   // 5%:13505 = 0.00037023324 per day;

    uint256 immutable LAUNCH_TIME;

    address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    IUniswapRouterV2 public constant UNISWAP_ROUTER = IUniswapRouterV2(
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
    );

    IUniswapV2Factory public constant UNISWAP_FACTORY = IUniswapV2Factory(
        0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f
    );

    ILiquidityGuard public constant LIQUIDITY_GUARD = ILiquidityGuard(
        0x9C306CaD86550EC80D77668c0A8bEE6eB34684B6
    );

    IUniswapV2Pair public UNISWAP_PAIR;
    bool public isLiquidityGuardActive;

    uint256 public latestDaiEquivalent;
    address[] internal _path = [address(this), WETH, DAI];

    constructor() {
        LAUNCH_TIME = 1604966400; // (10th November 2020 @00:00 GMT == day 0)
    }

    function createPair() external {
        UNISWAP_PAIR = IUniswapV2Pair(
            UNISWAP_FACTORY.createPair(
                WETH, address(this)
            )
        );
    }

    struct Stake {
        uint256 stakesShares;
        uint256 stakedAmount;
        uint256 rewardAmount;
        uint64 startDay;
        uint64 lockDays;
        uint64 finalDay;
        uint64 closeDay;
        uint256 scrapeDay;
        uint256 daiEquivalent;
        uint256 referrerShares;
        address referrer;
        bool isActive;
    }

    struct ReferrerLink {
        address staker;
        bytes16 stakeID;
        uint256 rewardAmount;
        uint256 processedDays;
        bool isActive;
    }

    struct LiquidityStake {
        uint256 stakedAmount;
        uint256 rewardAmount;
        uint64 startDay;
        uint64 closeDay;
        bool isActive;
    }

    struct CriticalMass {
        uint256 totalAmount;
        uint256 activationDay;
    }

    mapping(address => uint256) public stakeCount;
    mapping(address => uint256) public referralCount;
    mapping(address => uint256) public liquidityStakeCount;

    mapping(address => CriticalMass) public criticalMass;
    mapping(address => mapping(bytes16 => Stake)) public stakes;
    mapping(address => mapping(bytes16 => ReferrerLink)) public referrerLinks;
    mapping(address => mapping(bytes16 => LiquidityStake)) public liquidityStakes;

    mapping(uint256 => uint256) public scheduledToEnd;
    mapping(uint256 => uint256) public referralSharesToEnd;
    mapping(uint256 => uint256) public totalPenalties;
}

pragma solidity =0.7.5;


abstract contract Timing is Declaration {

    function currentWiseDay() public view returns (uint64) {
        return _getNow() >= LAUNCH_TIME ? _currentWiseDay() : 0;
    }

    function _currentWiseDay() internal view returns (uint64) {
        return _wiseDayFromStamp(_getNow());
    }

    function _nextWiseDay() internal view returns (uint64) {
        return _currentWiseDay() + 1;
    }

    function _previousWiseDay() internal view returns (uint64) {
        return _currentWiseDay() - 1;
    }

    function _wiseDayFromStamp(uint256 _timestamp) internal view returns (uint64) {
        return uint64((_timestamp - LAUNCH_TIME) / SECONDS_IN_DAY);
    }

    function _getNow() internal view returns (uint256) {
        return block.timestamp;
    }
}// --🦉--

pragma solidity =0.7.5;


abstract contract Helper is Timing {

    using SafeMath for uint256;

    function notContract(address _addr) internal view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size == 0);
    }

    function toBytes16(uint256 x) internal pure returns (bytes16 b) {
       return bytes16(bytes32(x));
    }

    function generateID(address x, uint256 y, bytes1 z) public pure returns (bytes16 b) {
        b = toBytes16(
            uint256(
                keccak256(
                    abi.encodePacked(x, y, z)
                )
            )
        );
    }

    function generateStakeID(address _staker) internal view returns (bytes16 stakeID) {
        return generateID(_staker, stakeCount[_staker], 0x01);
    }

    function generateReferralID(address _referrer) internal view returns (bytes16 referralID) {
        return generateID(_referrer, referralCount[_referrer], 0x02);
    }

    function generateLiquidityStakeID(address _staker) internal view returns (bytes16 liquidityStakeID) {
        return generateID(_staker, liquidityStakeCount[_staker], 0x03);
    }

    function activeStakesCount(
        address _staker
    )
        external
        view
        returns (
            uint256 activeCount
        )
    {
        for (uint256 _stakeIndex = 0; _stakeIndex <= stakeCount[_staker]; _stakeIndex++) {
            bytes16 _stakeID = generateID(_staker, _stakeIndex - 1, 0x01);
            if (stakes[_staker][_stakeID].isActive) {
                activeCount++;
            }
        }
    }

    function activeReferralCount(
        address _referrer
    )
        external
        view
        returns (
            uint256 activeCount
        )
    {
        for (uint256 _rIndex = 0; _rIndex <= referralCount[_referrer]; _rIndex++) {
            bytes16 _rID = generateID(_referrer, _rIndex - 1, 0x02);
            if (referrerLinks[_referrer][_rID].isActive) {
                activeCount++;
            }
        }
    }

    function stakesPagination(
        address _staker,
        uint256 _offset,
        uint256 _length
    )
        external
        view
        returns (bytes16[] memory _stakes)
    {
        uint256 start = _offset > 0 &&
            stakeCount[_staker] > _offset ?
            stakeCount[_staker] - _offset : stakeCount[_staker];

        uint256 finish = _length > 0 &&
            start > _length ?
            start - _length : 0;

        uint256 i;

        _stakes = new bytes16[](start - finish);

        for (uint256 _stakeIndex = start; _stakeIndex > finish; _stakeIndex--) {
            bytes16 _stakeID = generateID(_staker, _stakeIndex - 1, 0x01);
            if (stakes[_staker][_stakeID].stakedAmount > 0) {
                _stakes[i] = _stakeID; i++;
            }
        }
    }

    function referralsPagination(
        address _referrer,
        uint256 _offset,
        uint256 _length
    )
        external
        view
        returns (bytes16[] memory _referrals)
    {
        uint256 start = _offset > 0 &&
            referralCount[_referrer] > _offset ?
            referralCount[_referrer] - _offset : referralCount[_referrer];

        uint256 finish = _length > 0 &&
            start > _length ?
            start - _length : 0;

        uint256 i;

        _referrals = new bytes16[](start - finish);

        for (uint256 _rIndex = start; _rIndex > finish; _rIndex--) {
            bytes16 _rID = generateID(_referrer, _rIndex - 1, 0x02);
            if (_nonZeroAddress(referrerLinks[_referrer][_rID].staker)) {
                _referrals[i] = _rID; i++;
            }
        }
    }

    function latestStakeID(address _staker) external view returns (bytes16) {
        return stakeCount[_staker] == 0 ? bytes16(0) : generateID(_staker, stakeCount[_staker].sub(1), 0x01);
    }

    function latestReferralID(address _referrer) external view returns (bytes16) {
        return referralCount[_referrer] == 0 ? bytes16(0) : generateID(_referrer, referralCount[_referrer].sub(1), 0x02);
    }

    function latestLiquidityStakeID(address _staker) external view returns (bytes16) {
        return liquidityStakeCount[_staker] == 0 ? bytes16(0) : generateID(_staker, liquidityStakeCount[_staker].sub(1), 0x03);
    }

    function _increaseStakeCount(address _staker) internal {
        stakeCount[_staker] = stakeCount[_staker] + 1;
    }

    function _increaseReferralCount(address _referrer) internal {
        referralCount[_referrer] = referralCount[_referrer] + 1;
    }

    function _increaseLiquidityStakeCount(address _staker) internal {
        liquidityStakeCount[_staker] = liquidityStakeCount[_staker] + 1;
    }

    function _isMatureStake(Stake memory _stake) internal view returns (bool) {
        return _stake.closeDay > 0
            ? _stake.finalDay <= _stake.closeDay
            : _stake.finalDay <= _currentWiseDay();
    }

    function _notCriticalMassReferrer(address _referrer) internal view returns (bool) {
        return criticalMass[_referrer].activationDay == 0;
    }

    function _stakeNotStarted(Stake memory _stake) internal view returns (bool) {
        return _stake.closeDay > 0
            ? _stake.startDay > _stake.closeDay
            : _stake.startDay > _currentWiseDay();
    }

    function _stakeEnded(Stake memory _stake) internal view returns (bool) {
        return _stake.isActive == false || _isMatureStake(_stake);
    }

    function _daysLeft(Stake memory _stake) internal view returns (uint256) {
        return _stake.isActive == false
            ? _daysDiff(_stake.closeDay, _stake.finalDay)
            : _daysDiff(_currentWiseDay(), _stake.finalDay);
    }

    function _daysDiff(uint256 _startDate, uint256 _endDate) internal pure returns (uint256) {
        return _startDate > _endDate ? 0 : _endDate.sub(_startDate);
    }

    function _calculationDay(Stake memory _stake) internal view returns (uint256) {
        return _stake.finalDay > globals.currentWiseDay ? globals.currentWiseDay : _stake.finalDay;
    }

    function _startingDay(Stake memory _stake) internal pure returns (uint256) {
        return _stake.scrapeDay == 0 ? _stake.startDay : _stake.scrapeDay;
    }

    function _notFuture(uint256 _day) internal view returns (bool) {
        return _day <= _currentWiseDay();
    }

    function _notPast(uint256 _day) internal view returns (bool) {
        return _day >= _currentWiseDay();
    }

    function _nonZeroAddress(address _address) internal pure returns (bool) {
        return _address != address(0x0);
    }

    function _getLockDays(Stake memory _stake) internal pure returns (uint256) {
        return
            _stake.lockDays > 1 ?
            _stake.lockDays - 1 : 1;
    }

    function _preparePath(
        address _tokenAddress,
        address _wiseAddress
    )
        internal
        pure
        returns (address[] memory _path)
    {
        _path = new address[](3);
        _path[0] = _tokenAddress;
        _path[1] = WETH;
        _path[2] = _wiseAddress;
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    )
        internal
    {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(
                0xa9059cbb,
                to,
                value
            )
        );

        require(
            success && (data.length == 0 || abi.decode(data, (bool)))
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint value
    )
        internal
    {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(
                0x23b872dd,
                from,
                to,
                value
            )
        );

        require(
            success && (data.length == 0 || abi.decode(data, (bool)))
        );
    }
}// --🦉--

pragma solidity =0.7.5;


abstract contract Snapshot is Helper {

    using SafeMath for uint;

    struct SnapShot {
        uint256 totalShares;
        uint256 inflationAmount;
        uint256 scheduledToEnd;
    }

    struct rSnapShot {
        uint256 totalShares;
        uint256 inflationAmount;
        uint256 scheduledToEnd;
    }

    struct lSnapShot {
        uint256 totalShares;
        uint256 inflationAmount;
    }

    mapping(uint256 => SnapShot) public snapshots;
    mapping(uint256 => rSnapShot) public rsnapshots;
    mapping(uint256 => lSnapShot) public lsnapshots;

    modifier snapshotTrigger() {
        _dailySnapshotPoint(_currentWiseDay());
        _;
    }

    function liquidityGuardTrigger() public {

        (
            uint112 reserveA,
            uint112 reserveB,
            uint32 blockTimestampLast
        ) = UNISWAP_PAIR.getReserves();

        emit UniswapReserves(
            reserveA,
            reserveB,
            blockTimestampLast
        );

        uint256 onUniswap = UNISWAP_PAIR.token1() == WETH
            ? reserveA
            : reserveB;

        uint256 ratio = totalSupply() == 0
            ? 0
            : onUniswap
                .mul(200)
                .div(totalSupply());

        if (ratio < 40 && isLiquidityGuardActive == false) enableLiquidityGuard();
        if (ratio > 60 && isLiquidityGuardActive == true) disableLiquidityGuard();

        emit LiquidityGuardStatus(
            isLiquidityGuardActive
        );
    }

    function enableLiquidityGuard() private {
        isLiquidityGuardActive = true;
    }

    function disableLiquidityGuard() private {
        isLiquidityGuardActive = false;
    }

    function manualDailySnapshot()
        external
    {
        _dailySnapshotPoint(_currentWiseDay());
    }

    function manualDailySnapshotPoint(
        uint64 _updateDay
    )
        external
    {
        require(
            _updateDay > 0 &&
            _updateDay < _currentWiseDay()
        );

        require(
            _updateDay > globals.currentWiseDay
        );

        _dailySnapshotPoint(_updateDay);
    }

    function _dailySnapshotPoint(
        uint64 _updateDay
    )
        private
    {
        liquidityGuardTrigger();

        uint256 scheduledToEndToday;
        uint256 totalStakedToday = globals.totalStaked;

        for (uint256 _day = globals.currentWiseDay; _day < _updateDay; _day++) {


            scheduledToEndToday = scheduledToEnd[_day] + snapshots[_day - 1].scheduledToEnd;

            SnapShot memory snapshot = snapshots[_day];
            snapshot.scheduledToEnd = scheduledToEndToday;

            snapshot.totalShares =
                globals.totalShares > scheduledToEndToday ?
                globals.totalShares - scheduledToEndToday : 0;

            snapshot.inflationAmount =  snapshot.totalShares
                .mul(PRECISION_RATE)
                .div(
                    _inflationAmount(
                        totalStakedToday,
                        totalSupply(),
                        totalPenalties[_day],
                        LIQUIDITY_GUARD.getInflation(
                            INFLATION_RATE
                        )
                    )
                );

            snapshots[_day] = snapshot;



            scheduledToEndToday = referralSharesToEnd[_day] + rsnapshots[_day - 1].scheduledToEnd;

            rSnapShot memory rsnapshot = rsnapshots[_day];
            rsnapshot.scheduledToEnd = scheduledToEndToday;

            rsnapshot.totalShares =
                globals.referralShares > scheduledToEndToday ?
                globals.referralShares - scheduledToEndToday : 0;

            rsnapshot.inflationAmount = rsnapshot.totalShares
                .mul(PRECISION_RATE)
                .div(
                    _referralInflation(
                        totalStakedToday,
                        totalSupply()
                    )
                );

            rsnapshots[_day] = rsnapshot;



            lSnapShot memory lsnapshot = lsnapshots[_day];

            lsnapshot.totalShares = UNISWAP_PAIR.balanceOf(
                address(this)
            );

            lsnapshot.inflationAmount = lsnapshot.totalShares
                .mul(PRECISION_RATE).div(
                    _liquidityInflation(
                        totalStakedToday,
                        totalSupply(),
                        LIQUIDITY_GUARD.getInflation(
                            LIQUIDITY_RATE
                        )
                    )
                );

            lsnapshots[_day] = lsnapshot;

            adjustLiquidityRates();
            globals.currentWiseDay++;
        }
    }

    function adjustLiquidityRates() private {
        if (
            isLiquidityGuardActive ==  true &&
            LIQUIDITY_RATE < INFLATION_RATE_MAX
            )
        {
            LIQUIDITY_RATE = LIQUIDITY_RATE + 6;
            INFLATION_RATE = INFLATION_RATE - 6;
            return;
        }
        if (
            isLiquidityGuardActive == false &&
            INFLATION_RATE < INFLATION_RATE_MAX
            )
        {
            INFLATION_RATE = INFLATION_RATE + 6;
            LIQUIDITY_RATE = LIQUIDITY_RATE - 6;
            return;
        }
    }

    function _inflationAmount(uint256 _totalStaked, uint256 _totalSupply, uint256 _totalPenalties, uint256 _INFLATION_RATE) private pure returns (uint256) {
        return (_totalStaked + _totalSupply) * 10000 / _INFLATION_RATE + _totalPenalties;
    }

    function _referralInflation(uint256 _totalStaked, uint256 _totalSupply) private pure returns (uint256) {
        return (_totalStaked + _totalSupply) * 10000 / REFERRALS_RATE;
    }

    function _liquidityInflation(uint256 _totalStaked, uint256 _totalSupply, uint256 _LIQUIDITY_RATE) private pure returns (uint256) {
        return (_totalStaked + _totalSupply) * 10000 / _LIQUIDITY_RATE;
    }
}// --🦉--

pragma solidity =0.7.5;


abstract contract ReferralToken is Snapshot {

    using SafeMath for uint256;

    function _addReferrerSharesToEnd(
        uint256 _finalDay,
        uint256 _shares
    )
        internal
    {
        referralSharesToEnd[_finalDay] =
        referralSharesToEnd[_finalDay].add(_shares);
    }

    function _removeReferrerSharesToEnd(
        uint256 _finalDay,
        uint256 _shares
    )
        internal
    {
        if (_notPast(_finalDay)) {

            referralSharesToEnd[_finalDay] =
            referralSharesToEnd[_finalDay] > _shares ?
            referralSharesToEnd[_finalDay] - _shares : 0;

        } else {

            uint256 _day = _previousWiseDay();
            rsnapshots[_day].scheduledToEnd =
            rsnapshots[_day].scheduledToEnd > _shares ?
            rsnapshots[_day].scheduledToEnd - _shares : 0;
        }
    }

    function _belowThresholdLevel(
        address _referrer
    )
        private
        view
        returns (bool)
    {
        return criticalMass[_referrer].totalAmount < THRESHOLD_LIMIT;
    }

    function _addCriticalMass(
        address _referrer,
        uint256 _daiEquivalent
    )
        internal
    {
        criticalMass[_referrer].totalAmount =
        criticalMass[_referrer].totalAmount.add(_daiEquivalent);
        criticalMass[_referrer].activationDay = _determineActivationDay(_referrer);
    }

    function _removeCriticalMass(
        address _referrer,
        uint256 _daiEquivalent,
        uint256 _startDay
    )
        internal
    {
        if (
            _notFuture(_startDay) == false &&
            _nonZeroAddress(_referrer)
        ) {
            criticalMass[_referrer].totalAmount =
            criticalMass[_referrer].totalAmount > _daiEquivalent ?
            criticalMass[_referrer].totalAmount - _daiEquivalent : 0;
            criticalMass[_referrer].activationDay = _determineActivationDay(_referrer);
        }
    }

    function _determineActivationDay(
        address _referrer
    )
        private
        view
        returns (uint256)
    {
        return _belowThresholdLevel(_referrer) ? 0 : _activationDay(_referrer);
    }

    function _activationDay(
        address _referrer
    )
        private
        view
        returns (uint256)
    {
        return
            criticalMass[_referrer].activationDay > 0 ?
            criticalMass[_referrer].activationDay : _currentWiseDay();
    }

    function _updateDaiEquivalent()
        internal
        returns (uint256)
    {
        try UNISWAP_ROUTER.getAmountsOut(
            YODAS_PER_WISE, _path
        ) returns (uint256[] memory results) {
            latestDaiEquivalent = results[2];
            return latestDaiEquivalent;
        } catch Error(string memory) {
            return latestDaiEquivalent;
        } catch (bytes memory) {
            return latestDaiEquivalent;
        }
    }

    function referrerInterest(
        bytes16 _referralID,
        uint256 _scrapeDays
    )
        external
        snapshotTrigger
    {
        _referrerInterest(
            msg.sender,
            _referralID,
            _scrapeDays
        );
    }

    function referrerInterestBulk(
        bytes16[] memory _referralIDs,
        uint256[] memory _scrapeDays
    )
        external
        snapshotTrigger
    {
        for(uint256 i = 0; i < _referralIDs.length; i++) {
            _referrerInterest(
                msg.sender,
                _referralIDs[i],
                _scrapeDays[i]
            );
        }
    }

    function _referrerInterest(
        address _referrer,
        bytes16 _referralID,
        uint256 _processDays
    )
        internal
    {
        ReferrerLink memory link =
        referrerLinks[_referrer][_referralID];

        require(
            link.isActive == true
        );

        address staker = link.staker;
        bytes16 stakeID = link.stakeID;

        Stake memory stake = stakes[staker][stakeID];

        uint256 startDay = _determineStartDay(stake, link);
        uint256 finalDay = _determineFinalDay(stake);

        if (_stakeEnded(stake)) {

            if (
                _processDays > 0 &&
                _processDays < _daysDiff(startDay, finalDay)
                )
            {

                link.processedDays =
                link.processedDays.add(_processDays);

                finalDay =
                startDay.add(_processDays);

            } else {

                link.isActive = false;
            }

        } else {

            _processDays = _daysDiff(startDay, _currentWiseDay());

            link.processedDays =
            link.processedDays.add(_processDays);

            finalDay =
            startDay.add(_processDays);
        }

        uint256 referralInterest = _checkReferralInterest(
            stake,
            startDay,
            finalDay
        );

        link.rewardAmount =
        link.rewardAmount.add(referralInterest);

        referrerLinks[_referrer][_referralID] = link;

        _mint(
            _referrer,
            referralInterest
        );

        emit ReferralCollected(
            staker,
            stakeID,
            _referrer,
            _referralID,
            referralInterest
        );
    }

    function checkReferralsByID(
        address _referrer,
        bytes16 _referralID
    )
        external
        view
        returns (
            address staker,
            bytes16 stakeID,
            uint256 referrerShares,
            uint256 referralInterest,
            bool isActiveReferral,
            bool isActiveStake,
            bool isMatureStake,
            bool isEndedStake
        )
    {
        ReferrerLink memory link = referrerLinks[_referrer][_referralID];

        staker = link.staker;
        stakeID = link.stakeID;
        isActiveReferral = link.isActive;

        Stake memory stake = stakes[staker][stakeID];
        referrerShares = stake.referrerShares;

        referralInterest = _checkReferralInterest(
            stake,
            _determineStartDay(stake, link),
            _determineFinalDay(stake)
        );

        isActiveStake = stake.isActive;
        isEndedStake = _stakeEnded(stake);
        isMatureStake = _isMatureStake(stake);
    }

    function _checkReferralInterest(Stake memory _stake, uint256 _startDay, uint256 _finalDay) internal view returns (uint256 _referralInterest) {
        return _notCriticalMassReferrer(_stake.referrer) ? 0 : _getReferralInterest(_stake, _startDay, _finalDay);
    }

    function _getReferralInterest(Stake memory _stake, uint256 _startDay, uint256 _finalDay) private view returns (uint256 _referralInterest) {
        for (uint256 _day = _startDay; _day < _finalDay; _day++) {
            _referralInterest += _stake.stakesShares * PRECISION_RATE / rsnapshots[_day].inflationAmount;
        }
    }

    function _determineStartDay(Stake memory _stake, ReferrerLink memory _link) internal view returns (uint256) {
        return (
            criticalMass[_stake.referrer].activationDay > _stake.startDay ?
            criticalMass[_stake.referrer].activationDay : _stake.startDay
        ).add(_link.processedDays);
    }

    function _determineFinalDay(
        Stake memory _stake
    )
        internal
        view
        returns (uint256)
    {
        return
            _stake.closeDay > 0 ?
            _stake.closeDay : _calculationDay(_stake);
    }
}// --🦉--

pragma solidity =0.7.5;


abstract contract StakingToken is ReferralToken {

    using SafeMath for uint256;

    function createStake(
        uint256 _stakedAmount,
        uint64 _lockDays,
        address _referrer
    )
        snapshotTrigger
        public
        returns (bytes16, uint256, bytes16 referralID)
    {
        require(
            msg.sender != _referrer &&
            notContract(_referrer)
        );

        require(
            _lockDays >= MIN_LOCK_DAYS &&
            _lockDays <= MAX_LOCK_DAYS
        );

        require(
            _stakedAmount >= MIN_STAKE_AMOUNT
        );

        (
            Stake memory newStake,
            bytes16 stakeID,
            uint256 _startDay
        ) =

        _createStake(msg.sender, _stakedAmount, _lockDays, _referrer);

        if (newStake.referrerShares > 0) {

            ReferrerLink memory referrerLink;

            referrerLink.staker = msg.sender;
            referrerLink.stakeID = stakeID;
            referrerLink.isActive = true;

            referralID = generateReferralID(_referrer);
            referrerLinks[_referrer][referralID] = referrerLink;

            _increaseReferralCount(
                _referrer
            );

            _addReferrerSharesToEnd(
                newStake.finalDay,
                newStake.referrerShares
            );
        }

        stakes[msg.sender][stakeID] = newStake;

        _increaseStakeCount(
            msg.sender
        );

        _increaseGlobals(
            newStake.stakedAmount,
            newStake.stakesShares,
            newStake.referrerShares
        );

        _addScheduledShares(
            newStake.finalDay,
            newStake.stakesShares
        );

        emit StakeStart(
            stakeID,
            msg.sender,
            _referrer,
            newStake.stakedAmount,
            newStake.stakesShares,
            newStake.referrerShares,
            newStake.startDay,
            newStake.lockDays,
            newStake.daiEquivalent
        );

        return (stakeID, _startDay, referralID);
    }

    function _createStake(
        address _staker,
        uint256 _stakedAmount,
        uint64 _lockDays,
        address _referrer
    )
        private
        returns (
            Stake memory _newStake,
            bytes16 _stakeID,
            uint64 _startDay
        )
    {
        _burn(
            _staker,
            _stakedAmount
        );

        _startDay = _nextWiseDay();
        _stakeID = generateStakeID(_staker);

        _newStake.lockDays = _lockDays;
        _newStake.startDay = _startDay;
        _newStake.finalDay = _startDay + _lockDays;
        _newStake.isActive = true;

        _newStake.stakedAmount = _stakedAmount;
        _newStake.stakesShares = _stakesShares(
            _stakedAmount,
            _lockDays,
            _referrer,
            globals.sharePrice
        );

        _updateDaiEquivalent();

        _newStake.daiEquivalent = latestDaiEquivalent
            .mul(_newStake.stakedAmount)
            .div(YODAS_PER_WISE);

        if (_nonZeroAddress(_referrer)) {

            _newStake.referrer = _referrer;

            _addCriticalMass(
                _newStake.referrer,
                _newStake.daiEquivalent
            );

            _newStake.referrerShares = _referrerShares(
                _stakedAmount,
                _lockDays,
                _referrer
            );
        }
    }

    function endStake(
        bytes16 _stakeID
    )
        snapshotTrigger
        external
        returns (uint256)
    {
        (
            Stake memory endedStake,
            uint256 penaltyAmount
        ) =

        _endStake(
            msg.sender,
            _stakeID
        );

        _decreaseGlobals(
            endedStake.stakedAmount,
            endedStake.stakesShares,
            endedStake.referrerShares
        );

        _removeScheduledShares(
            endedStake.finalDay,
            endedStake.stakesShares
        );

        _removeReferrerSharesToEnd(
            endedStake.finalDay,
            endedStake.referrerShares
        );

        _removeCriticalMass(
            endedStake.referrer,
            endedStake.daiEquivalent,
            endedStake.startDay
        );

        _storePenalty(
            endedStake.closeDay,
            penaltyAmount
        );

        _sharePriceUpdate(
            endedStake.stakedAmount > penaltyAmount ?
            endedStake.stakedAmount - penaltyAmount : 0,
            endedStake.rewardAmount,
            endedStake.referrer,
            endedStake.lockDays,
            endedStake.stakesShares
        );

        emit StakeEnd(
            _stakeID,
            msg.sender,
            endedStake.referrer,
            endedStake.stakedAmount,
            endedStake.stakesShares,
            endedStake.referrerShares,
            endedStake.rewardAmount,
            endedStake.closeDay,
            penaltyAmount
        );

        return endedStake.rewardAmount;
    }

    function _endStake(
        address _staker,
        bytes16 _stakeID
    )
        private
        returns (
            Stake storage _stake,
            uint256 _penalty
        )
    {
        require(
            stakes[_staker][_stakeID].isActive
        );

        _stake = stakes[_staker][_stakeID];
        _stake.closeDay = _currentWiseDay();
        _stake.rewardAmount = _calculateRewardAmount(_stake);
        _penalty = _calculatePenaltyAmount(_stake);

        _stake.isActive = false;

        _mint(
            _staker,
            _stake.stakedAmount > _penalty ?
            _stake.stakedAmount - _penalty : 0
        );

        _mint(
            _staker,
            _stake.rewardAmount
        );
    }

    function scrapeInterest(
        bytes16 _stakeID,
        uint64 _scrapeDays
    )
        external
        snapshotTrigger
        returns (
            uint256 scrapeDay,
            uint256 scrapeAmount,
            uint256 remainingDays,
            uint256 stakersPenalty,
            uint256 referrerPenalty
        )
    {
        require(
            stakes[msg.sender][_stakeID].isActive
        );

        Stake memory stake = stakes[msg.sender][_stakeID];

        scrapeDay = _scrapeDays > 0
            ? _startingDay(stake).add(_scrapeDays)
            : _calculationDay(stake);

        scrapeDay = scrapeDay > stake.finalDay
            ? _calculationDay(stake)
            : scrapeDay;

        scrapeAmount = _loopRewardAmount(
            stake.stakesShares,
            _startingDay(stake),
            scrapeDay
        );

        if (_isMatureStake(stake) == false) {

            remainingDays = _daysLeft(stake);

            stakersPenalty = _stakesShares(
                scrapeAmount,
                remainingDays,
                msg.sender,
                globals.sharePrice
            );

            stake.stakesShares =
            stake.stakesShares.sub(stakersPenalty);

            _removeScheduledShares(
                stake.finalDay,
                stakersPenalty
            );

            if (stake.referrerShares > 0) {

                referrerPenalty = _stakesShares(
                    scrapeAmount,
                    remainingDays,
                    address(0x0),
                    globals.sharePrice
                );

                stake.referrerShares =
                stake.referrerShares.sub(referrerPenalty);

                _removeReferrerSharesToEnd(
                    stake.finalDay,
                    referrerPenalty
                );
            }

            _decreaseGlobals(
                0,
                stakersPenalty,
                referrerPenalty
            );
        }

        _sharePriceUpdate(
            stake.stakedAmount,
            scrapeAmount,
            stake.referrer,
            stake.lockDays,
            stake.stakesShares
        );

        stake.scrapeDay = scrapeDay;
        stakes[msg.sender][_stakeID] = stake;

        _mint(
            msg.sender,
            scrapeAmount
        );

        emit InterestScraped(
            _stakeID,
            msg.sender,
            scrapeAmount,
            scrapeDay,
            stakersPenalty,
            referrerPenalty,
            _currentWiseDay()
        );
    }

    function _addScheduledShares(
        uint256 _finalDay,
        uint256 _shares
    )
        internal
    {
        scheduledToEnd[_finalDay] =
        scheduledToEnd[_finalDay].add(_shares);
    }

    function _removeScheduledShares(
        uint256 _finalDay,
        uint256 _shares
    )
        internal
    {
        if (_notPast(_finalDay)) {

            scheduledToEnd[_finalDay] =
            scheduledToEnd[_finalDay] > _shares ?
            scheduledToEnd[_finalDay] - _shares : 0;

        } else {

            uint256 _day = _previousWiseDay();
            snapshots[_day].scheduledToEnd =
            snapshots[_day].scheduledToEnd > _shares ?
            snapshots[_day].scheduledToEnd - _shares : 0;
        }
    }

    function _sharePriceUpdate(
        uint256 _stakedAmount,
        uint256 _rewardAmount,
        address _referrer,
        uint256 _lockDays,
        uint256 _stakeShares
    )
        private
    {
        if (_stakeShares > 0 && _currentWiseDay() > FORMULA_DAY) {

            uint256 newSharePrice = _getNewSharePrice(
                _stakedAmount,
                _rewardAmount,
                _stakeShares,
                _lockDays,
                _referrer
            );

            if (newSharePrice > globals.sharePrice) {
                globals.sharePrice =
                    newSharePrice < globals.sharePrice.mul(110).div(100) ?
                    newSharePrice : globals.sharePrice.mul(110).div(100);
            }

            return;
        }

        if (_currentWiseDay() == FORMULA_DAY) {
            globals.sharePrice = 110E15;
        }
    }

    function _getNewSharePrice(
        uint256 _stakedAmount,
        uint256 _rewardAmount,
        uint256 _stakeShares,
        uint256 _lockDays,
        address _referrer
    )
        private
        pure
        returns (uint256)
    {

        uint256 _bonusAmount = _getBonus(
            _lockDays, _nonZeroAddress(_referrer) ? 11E9 : 10E9
        );

        return
            _stakedAmount
                .add(_rewardAmount)
                .mul(_bonusAmount)
                .mul(1E8)
                .div(_stakeShares);
    }

    function checkMatureStake(
        address _staker,
        bytes16 _stakeID
    )
        external
        view
        returns (bool isMature)
    {
        Stake memory stake = stakes[_staker][_stakeID];
        isMature = _isMatureStake(stake);
    }

    function checkStakeByID(
        address _staker,
        bytes16 _stakeID
    )
        external
        view
        returns (
            uint256 startDay,
            uint256 lockDays,
            uint256 finalDay,
            uint256 closeDay,
            uint256 scrapeDay,
            uint256 stakedAmount,
            uint256 stakesShares,
            uint256 rewardAmount,
            uint256 penaltyAmount,
            bool isActive,
            bool isMature
        )
    {
        Stake memory stake = stakes[_staker][_stakeID];
        startDay = stake.startDay;
        lockDays = stake.lockDays;
        finalDay = stake.finalDay;
        closeDay = stake.closeDay;
        scrapeDay = stake.scrapeDay;
        stakedAmount = stake.stakedAmount;
        stakesShares = stake.stakesShares;
        rewardAmount = _checkRewardAmount(stake);
        penaltyAmount = _calculatePenaltyAmount(stake);
        isActive = stake.isActive;
        isMature = _isMatureStake(stake);
    }

    function _stakesShares(
        uint256 _stakedAmount,
        uint256 _lockDays,
        address _referrer,
        uint256 _sharePrice
    )
        private
        pure
        returns (uint256)
    {
        return _nonZeroAddress(_referrer)
            ? _sharesAmount(_stakedAmount, _lockDays, _sharePrice, 11E9)
            : _sharesAmount(_stakedAmount, _lockDays, _sharePrice, 10E9);
    }

    function _sharesAmount(
        uint256 _stakedAmount,
        uint256 _lockDays,
        uint256 _sharePrice,
        uint256 _extraBonus
    )
        private
        pure
        returns (uint256)
    {
        return _baseAmount(_stakedAmount, _sharePrice)
            .mul(_getBonus(_lockDays, _extraBonus))
            .div(10E9);
    }

    function _getBonus(
        uint256 _lockDays,
        uint256 _extraBonus
    )
        private
        pure
        returns (uint256)
    {
        return
            _regularBonus(_lockDays, DAILY_BONUS_A, MAX_BONUS_DAYS_A) +
            _regularBonus(
                _lockDays > MAX_BONUS_DAYS_A ?
                _lockDays - MAX_BONUS_DAYS_A : 0, DAILY_BONUS_B, MAX_BONUS_DAYS_B
            ) + _extraBonus;
    }

    function _regularBonus(
        uint256 _lockDays,
        uint256 _daily,
        uint256 _maxDays
    )
        private
        pure
        returns (uint256)
    {
        return (
            _lockDays > _maxDays
                ? _maxDays.mul(_daily)
                : _lockDays.mul(_daily)
            ).div(10E9);
    }

    function _baseAmount(
        uint256 _stakedAmount,
        uint256 _sharePrice
    )
        private
        pure
        returns (uint256)
    {
        return
            _stakedAmount
                .mul(PRECISION_RATE)
                .div(_sharePrice);
    }

    function _referrerShares(
        uint256 _stakedAmount,
        uint256 _lockDays,
        address _referrer
    )
        private
        view
        returns (uint256)
    {
        return
            _notCriticalMassReferrer(_referrer) ||
            _lockDays < MIN_REFERRAL_DAYS
                ? 0
                : _sharesAmount(
                    _stakedAmount,
                    _lockDays,
                    globals.sharePrice,
                    10E9
                );
    }

    function _checkRewardAmount(Stake memory _stake) private view returns (uint256) {
        return _stake.isActive ? _detectReward(_stake) : _stake.rewardAmount;
    }

    function _detectReward(Stake memory _stake) private view returns (uint256) {
        return _stakeNotStarted(_stake) ? 0 : _calculateRewardAmount(_stake);
    }

    function _storePenalty(
        uint64 _storeDay,
        uint256 _penalty
    )
        private
    {
        if (_penalty > 0) {
            totalPenalties[_storeDay] =
            totalPenalties[_storeDay].add(_penalty);
        }
    }

    function _calculatePenaltyAmount(
        Stake memory _stake
    )
        private
        view
        returns (uint256)
    {
        return _stakeNotStarted(_stake) || _isMatureStake(_stake) ? 0 : _getPenalties(_stake);
    }

    function _getPenalties(Stake memory _stake)
        private
        view
        returns (uint256)
    {
        return _stake.stakedAmount * (100 + (800 * (_daysLeft(_stake) - 1) / (_getLockDays(_stake)))) / 1000;
    }

    function _calculateRewardAmount(
        Stake memory _stake
    )
        private
        view
        returns (uint256)
    {
        return _loopRewardAmount(
            _stake.stakesShares,
            _startingDay(_stake), 
            _calculationDay(_stake)
        );
    }

    function _loopRewardAmount(
        uint256 _stakeShares,
        uint256 _startDay,
        uint256 _finalDay
    )
        private
        view
        returns (uint256 _rewardAmount)
    {
        for (uint256 _day = _startDay; _day < _finalDay; _day++) {
            _rewardAmount += _stakeShares * PRECISION_RATE / snapshots[_day].inflationAmount;
        }
    }
}// --🦉--

pragma solidity =0.7.5;


abstract contract LiquidityToken is StakingToken {

    function createLiquidityStake(
        uint256 _liquidityTokens
    )
        snapshotTrigger
        external
        returns (bytes16 liquidityStakeID)
    {
        safeTransferFrom(
            address(UNISWAP_PAIR),
            msg.sender,
            address(this),
            _liquidityTokens
        );

        LiquidityStake memory newLiquidityStake;

        liquidityStakeID = generateLiquidityStakeID(
            msg.sender
        );

        newLiquidityStake.startDay = _nextWiseDay();
        newLiquidityStake.stakedAmount = _liquidityTokens;
        newLiquidityStake.isActive = true;

        liquidityStakes[msg.sender][liquidityStakeID] = newLiquidityStake;

        _increaseLiquidityStakeCount(
            msg.sender
        );
    }

    function endLiquidityStake(
        bytes16 _liquidityStakeID
    )
        snapshotTrigger
        external
        returns (uint256)
    {
        LiquidityStake memory liquidityStake =
        liquidityStakes[msg.sender][_liquidityStakeID];

        require(
            liquidityStake.isActive
        );

        liquidityStake.isActive = false;
        liquidityStake.closeDay = _currentWiseDay();

        liquidityStake.rewardAmount = _calculateRewardAmount(
            liquidityStake
        );

        _mint(
            msg.sender,
            liquidityStake.rewardAmount
        );

        safeTransfer(
            address(UNISWAP_PAIR),
            msg.sender,
            liquidityStake.stakedAmount
        );

        liquidityStakes[msg.sender][_liquidityStakeID] = liquidityStake;

        return liquidityStake.rewardAmount;
    }

    function checkLiquidityStakeByID(
        address _staker,
        bytes16 _liquidityStakeID
    )
        external
        view
        returns (
            uint256 startDay,
            uint256 stakedAmount,
            uint256 rewardAmount,
            uint256 closeDay,
            bool isActive
        )
    {
        LiquidityStake memory stake = liquidityStakes[_staker][_liquidityStakeID];
        startDay = stake.startDay;
        stakedAmount = stake.stakedAmount;
        rewardAmount = _calculateRewardAmount(stake);
        closeDay = stake.closeDay;
        isActive = stake.isActive;
    }

    function _calculateRewardAmount(
        LiquidityStake memory _liquidityStake
    )
        private
        view
        returns (uint256 _rewardAmount)
    {
        uint256 maxCalculationDay = _liquidityStake.startDay + MAX_BONUS_DAYS_A;

        uint256 calculationDay =
            globals.currentWiseDay < maxCalculationDay ?
            globals.currentWiseDay : maxCalculationDay;

        for (uint256 _day = _liquidityStake.startDay; _day < calculationDay; _day++) {
            _rewardAmount += _liquidityStake.stakedAmount * PRECISION_RATE / lsnapshots[_day].inflationAmount;
        }
    }
}// --🦉--

pragma solidity =0.7.5;


contract WiseToken is LiquidityToken {


    address public LIQUIDITY_TRANSFORMER;
    address public transformerGateKeeper;
    address payable public savingAddress;

    constructor() ERC20("Wise Token", "WISE") {
        transformerGateKeeper = msg.sender;
        savingAddress = msg.sender;
    }

    receive() external payable {
        savingAddress.transfer(msg.value);
    }

    function setLiquidityTransfomer(
        address _immutableTransformer
    )
        external
    {

        require(
            transformerGateKeeper == msg.sender
        );
        LIQUIDITY_TRANSFORMER = _immutableTransformer;
        transformerGateKeeper = address(0x0);
    }

    function mintSupply(
        address _investorAddress,
        uint256 _amount
    )
        external
    {

        require(
            msg.sender == LIQUIDITY_TRANSFORMER
        );

        _mint(
            _investorAddress,
            _amount
        );
    }

    function giveStatus(
        address _referrer
    )
        external
    {

        require(
            msg.sender == LIQUIDITY_TRANSFORMER
        );
        criticalMass[_referrer].totalAmount = THRESHOLD_LIMIT;
        criticalMass[_referrer].activationDay = _nextWiseDay();
    }

    function createStakeWithETH(
        uint64 _lockDays,
        address _referrer
    )
        external
        payable
        returns (bytes16, uint256, bytes16 referralID)
    {

        address[] memory path = new address[](2);
            path[0] = WETH;
            path[1] = address(this);

        uint256[] memory amounts =
        UNISWAP_ROUTER.swapExactETHForTokens{value: msg.value}(
            1,
            path,
            msg.sender,
            block.timestamp + 2 hours
        );

        return createStake(
            amounts[1],
            _lockDays,
            _referrer
        );
    }

    function createStakeWithToken(
        address _tokenAddress,
        uint256 _tokenAmount,
        uint64 _lockDays,
        address _referrer
    )
        external
        returns (bytes16, uint256, bytes16 referralID)
    {

        ERC20TokenI token = ERC20TokenI(
            _tokenAddress
        );

        token.transferFrom(
            msg.sender,
            address(this),
            _tokenAmount
        );

        token.approve(
            address(UNISWAP_ROUTER),
            _tokenAmount
        );

        address[] memory path = _preparePath(
            _tokenAddress,
            address(this)
        );

        uint256[] memory amounts =
        UNISWAP_ROUTER.swapExactTokensForTokens(
            _tokenAmount,
            1,
            path,
            msg.sender,
            block.timestamp + 2 hours
        );

        return createStake(
            amounts[2],
            _lockDays,
            _referrer
        );
    }

    function saveTokens(
        address _tokenAddress,
        uint256 _tokenAmount
    )
        external
    {

        safeTransfer(
            _tokenAddress,
            savingAddress,
            _tokenAmount
        );
    }
}