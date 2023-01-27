
pragma solidity =0.7.6;

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


        if (a == 0 || b == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        
        if(b == 0){
            return 0;
        }
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);
        return a % b;
    }
}

pragma solidity =0.7.6;

interface IUniswapRouterV2 {


    function swapETHForExactTokens(
        uint amountOut,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (
        uint[] memory amounts
    );

}

interface IGriseToken {


    function currentGriseDay()
        external view
        returns (uint64);


    function balanceOfStaker(
        address account
    ) external view returns (uint256);


    function approve(
        address _spender,
        uint256 _value
    ) external returns (bool success);


    function totalSupply() 
        external view 
        returns (uint256);


    function mintSupply(
        address _investorAddress,
        uint256 _amount
    ) external;


    function burnSupply(
        address _investorAddress,
        uint256 _amount
    ) external;


    function setStaker(
        address _staker
    ) external;


    function resetStaker(
        address _staker
    ) external;


    function updateStakedToken(
        uint256 _stakedToken
    ) external;


    function updateMedTermShares(
        uint256 _shares
    ) external;


    function getTransFeeReward(
        uint256 _fromDay,
        uint256 _toDay
    )external view returns (uint256 rewardAmount);

    
    function getReservoirReward(
        uint256 _fromDay,
        uint256 _toDay
    )external view returns (uint256 rewardAmount);


    function getTokenHolderReward(
        uint256 _fromDay,
        uint256 _toDay
    )external view returns (uint256 rewardAmount);

}// --GRISE--

pragma solidity =0.7.6;

contract Events {

    
    event StakeStart(
        bytes16 indexed stakeID,
        address indexed stakerAddress,
        uint256 stakeType,
        uint256 stakedAmount,
        uint256 stakesShares,
        uint256 startDay,
        uint256 lockDays
    );

    event StakeEnd(
        bytes16 indexed stakeID,
        address indexed stakerAddress,
        uint256 stakeType,
        uint256 stakedAmount,
        uint256 stakesShares,
        uint256 rewardAmount,
        uint256 closeDay,
        uint256 penaltyAmount
    );

    event InterestScraped(
        bytes16 indexed stakeID,
        address indexed stakerAddress,
        uint256 scrapeAmount,
        uint256 scrapeDay,
        uint256 currentGriseDay
    );

    event NewGlobals(
        uint256 indexed currentGriseDay,
        uint256 totalShares,
        uint256 totalStaked,
        uint256 shortTermshare,
        uint256 MediumTermshare,
        uint256 shareRate
    );
}// --GRISE--

pragma solidity =0.7.6;


abstract contract Global is Events {

    using SafeMath for uint256;

    struct Globals {
        uint256 totalStaked;
        uint256 totalShares;
        uint256 STShares; // Short Term shares counter
        uint256 MLTShares; // Medium Term and Large Term Shares counter
        uint256 sharePrice;
        uint256 currentGriseDay;
    }

    Globals public globals;

    constructor() {
        globals.sharePrice = 100E15;
    }

    function _increaseGlobals(
        uint8 _stakeType, 
        uint256 _staked,
        uint256 _shares
    )
        internal
    {
        globals.totalStaked =
        globals.totalStaked.add(_staked);

        globals.totalShares =
        globals.totalShares.add(_shares);

        if (_stakeType > 0) {
            globals.MLTShares = 
                globals.MLTShares.add(_shares);
        }else {
            globals.STShares = 
                globals.STShares.add(_shares);
        }

        _logGlobals();
    }

    function _decreaseGlobals(
        uint8 _stakeType,
        uint256 _staked,
        uint256 _shares
    )
        internal
    {
        globals.totalStaked =
        globals.totalStaked > _staked ?
        globals.totalStaked - _staked : 0;

        globals.totalShares =
        globals.totalShares > _shares ?
        globals.totalShares - _shares : 0;

        if (_stakeType > 0) {
            globals.MLTShares = 
                globals.MLTShares > _shares ?
                globals.MLTShares - _shares : 0;
        }else {            
            globals.STShares = 
                globals.STShares > _shares ?
                globals.STShares - _shares : 0;

        }
        
        _logGlobals();
    }

    function _logGlobals()
        private
    {
        emit NewGlobals(
            globals.currentGriseDay,
            globals.totalShares,
            globals.totalStaked,
            globals.STShares,
            globals.MLTShares,
            globals.sharePrice
        );
    }
}// --GRISE--

pragma solidity =0.7.6;


abstract contract Declaration is Global {

    uint256 constant _decimals = 18;
    uint256 constant REI_PER_GRISE = 10 ** _decimals; // 1 GRISE = 1E18 REI
    
    uint64 constant PRECISION_RATE = 1E18;
    uint32 constant REWARD_PRECISION_RATE = 1E4;

    uint16 constant GRISE_WEEK = 7;
    uint16 constant GRISE_MONTH = GRISE_WEEK * 4;
    uint16 constant GRISE_YEAR = GRISE_MONTH * 12;

    uint32 constant INFLATION_RATE = 57658685; // per day Inflation Amount
    uint16 constant MED_TERM_INFLATION_REWARD = 3000; // 30% of Inflation Amount with 1E4 Precision
    uint16 constant LONG_TERM_INFLATION_REWARD = 7000; // 70% of Inflation Amount with 1E4 Precision

    uint16 constant ST_STAKER_COMPENSATION = 200; // 2.00% multiple 1E4 Precision
    uint16 constant MLT_STAKER_COMPENSATION = 347; // 3.47% multiple 1E4 Precision

    uint16 constant PENALTY_RATE = 1700; // pre-mature end-stake penalty
    uint16 constant RESERVOIR_PENALTY_REWARD = 3427;
    uint16 constant SHORT_STAKER_PENALTY_REWARD = 1311;
    uint16 constant MED_LONG_STAKER_PENALTY_REWARD = 2562;
    uint16 constant TEAM_PENALTY_REWARD = 1350;
    uint16 constant DEVELOPER_PENALTY_REWARD = 150;
    uint16 constant BURN_PENALTY_REWARD = 1200;

    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // mainnet

    address constant TEAM_ADDRESS = 0xa377433831E83C7a4Fa10fB75C33217cD7CABec2;
    address constant DEVELOPER_ADDRESS = 0xcD8DcbA8e4791B19719934886A8bA77EA3fad447;

    IUniswapRouterV2 public constant UNISWAP_ROUTER = IUniswapRouterV2(
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D // mainnet
    );

    IGriseToken public GRISE_CONTRACT;
    address public contractDeployer;

    constructor(address _immutableAddress) 
    {
        contractDeployer = msg.sender;

        GRISE_CONTRACT = IGriseToken(_immutableAddress);

        stakeDayLimit[StakeType.SHORT_TERM].minStakeDay = 1 * GRISE_WEEK;   // Min 1 Week
        stakeDayLimit[StakeType.SHORT_TERM].maxStakeDay = 12 * GRISE_WEEK;  // Max 12 Week
        stakeDayLimit[StakeType.MEDIUM_TERM].minStakeDay = 3 * GRISE_MONTH; // Min 3 Month
        stakeDayLimit[StakeType.MEDIUM_TERM].maxStakeDay = 9 * GRISE_MONTH; // Max 9 Month
        stakeDayLimit[StakeType.LONG_TERM].minStakeDay =  1 * GRISE_YEAR;  // Min 1 Year
        stakeDayLimit[StakeType.LONG_TERM].maxStakeDay = 10 * GRISE_YEAR;  // Max 10 Year

        stakeCaps[StakeType.SHORT_TERM][0].minStakingAmount = 50 * REI_PER_GRISE;   // 50 GRISE TOKEN
        stakeCaps[StakeType.MEDIUM_TERM][0].minStakingAmount = 225 * REI_PER_GRISE; // 225 GIRSE TOKEN
        stakeCaps[StakeType.MEDIUM_TERM][1].minStakingAmount = 100 * REI_PER_GRISE; // 100 GIRSE TOKEN
        stakeCaps[StakeType.MEDIUM_TERM][2].minStakingAmount = 150 * REI_PER_GRISE; // 150 GIRSE TOKEN
        stakeCaps[StakeType.LONG_TERM][0].minStakingAmount = 100 * REI_PER_GRISE;  // 100 GIRSE TOKEN

        stakeCaps[StakeType.SHORT_TERM][0].maxStakingSlot = 1250;   // Max 1250 Slot Available
        stakeCaps[StakeType.MEDIUM_TERM][0].maxStakingSlot = 250;   // Max 250 Slot Available
        stakeCaps[StakeType.MEDIUM_TERM][1].maxStakingSlot = 500;   // Max 500 Slot Available
        stakeCaps[StakeType.MEDIUM_TERM][2].maxStakingSlot = 300;   // Max 300 Slot Available
        stakeCaps[StakeType.LONG_TERM][0].maxStakingSlot = 300;    // Max 300 Slot Available
    }

    struct Stake {
        uint256 stakesShares;
        uint256 stakedAmount;
        uint256 rewardAmount;
        StakeType stakeType;
        uint256 totalOccupiedSlot;
        uint256 startDay;
        uint256 lockDays;
        uint256 finalDay;
        uint256 closeDay;
        uint256 scrapeDay;
        bool isActive;
    }

    enum StakeType {
        SHORT_TERM,
        MEDIUM_TERM,
        LONG_TERM
    }

    struct StakeCapping {
        uint256 minStakingAmount;
        uint256 stakingSlotCount;
        uint256 maxStakingSlot;
        uint256 totalStakeCount;
    }

    struct StakeMinMaxDay{
        uint256 minStakeDay;
        uint256 maxStakeDay;
    }

    mapping(address => uint256) public stakeCount;
    mapping(address => mapping(bytes16 => uint256)) public scrapes;
    mapping(address => mapping(bytes16 => Stake)) public stakes;

    mapping(uint256 => uint256) public scheduledToEnd;
    mapping(uint256 => uint256) public totalPenalties;
    mapping(uint256 => uint256) public MLTPenaltiesRewardPerShares; // Medium/Long Term Penatly Reward
    mapping(uint256 => uint256) public STPenaltiesRewardPerShares;  // Short Term Penatly Reward
    mapping(uint256 => uint256) public ReservoirPenaltiesRewardPerShares;  // Short Term Penatly Reward

    mapping(StakeType => StakeMinMaxDay) public stakeDayLimit;
    mapping(StakeType => mapping(uint8 => StakeCapping)) public stakeCaps;
}

pragma solidity =0.7.6;


abstract contract Helper is Declaration {

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

    function currentGriseDay() internal view returns (uint256) {
        return GRISE_CONTRACT.currentGriseDay();
    }

    function latestStakeID(address _staker) external view returns (bytes16) {
        return stakeCount[_staker] == 0 ? bytes16(0) : generateID(_staker, stakeCount[_staker].sub(1), 0x01);
    }

    function _increaseStakeCount(address _staker) internal {
        stakeCount[_staker] = stakeCount[_staker] + 1;
    }

    function _isMatureStake(Stake memory _stake) internal view returns (bool) {
        return _stake.closeDay > 0
            ? _stake.finalDay <= _stake.closeDay
            : _stake.finalDay <= currentGriseDay();
    }

    function _stakeNotStarted(Stake memory _stake) internal view returns (bool) {
        return _stake.closeDay > 0
            ? _stake.startDay > _stake.closeDay
            : _stake.startDay > currentGriseDay();
    }

    function _stakeEligibleForWeeklyReward(Stake memory _stake) internal view returns (bool) {
        uint256 curGriseDay = currentGriseDay();
        
        return ( _stake.isActive && 
                !_stakeNotStarted(_stake) &&
                (_startingDay(_stake) < curGriseDay.sub(curGriseDay.mod(GRISE_WEEK)) ||
                   curGriseDay >= _stake.finalDay));
    }

    function _stakeEligibleForMonthlyReward(Stake memory _stake) internal view returns (bool) {
        uint256 curGriseDay = currentGriseDay();

        return ( _stake.isActive && 
                !_stakeNotStarted(_stake) &&
                (_startingDay(_stake) < curGriseDay.sub(curGriseDay.mod(GRISE_MONTH)) ||
                   curGriseDay >= _stake.finalDay));
    }

    function _stakeEnded(Stake memory _stake) internal view returns (bool) {
        return _stake.isActive == false || _isMatureStake(_stake);
    }

    function _daysLeft(Stake memory _stake) internal view returns (uint256) {
        return _stake.isActive == false
            ? _daysDiff(_stake.closeDay, _stake.finalDay)
            : _daysDiff(currentGriseDay(), _stake.finalDay);
    }

    function _daysDiff(uint256 _startDate, uint256 _endDate) internal pure returns (uint256) {
        return _startDate > _endDate ? 0 : _endDate.sub(_startDate);
    }

    function _calculationDay(Stake memory _stake) internal view returns (uint256) {
        return _stake.finalDay > globals.currentGriseDay ? globals.currentGriseDay : _stake.finalDay;
    }

    function _startingDay(Stake memory _stake) internal pure returns (uint256) {
        return _stake.scrapeDay == 0 ? _stake.startDay : _stake.scrapeDay;
    }

    function _notFuture(uint256 _day) internal view returns (bool) {
        return _day <= currentGriseDay();
    }

    function _notPast(uint256 _day) internal view returns (bool) {
        return _day >= currentGriseDay();
    }

    function _nonZeroAddress(address _address) internal pure returns (bool) {
        return _address != address(0x0);
    }

    function _getLockDays(Stake memory _stake) internal pure returns (uint256) {
        return
            _stake.lockDays > 1 ?
            _stake.lockDays - 1 : 1;
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
    
}// --GRISE--

pragma solidity =0.7.6;


abstract contract Snapshot is Helper {

    using SafeMath for uint;

    struct SnapShot {
        uint256 totalShares;
        uint256 inflationAmount;
        uint256 scheduledToEnd;
    }

    mapping(uint256 => SnapShot) public snapshots;
    
    modifier snapshotTrigger() {
        _dailySnapshotPoint(currentGriseDay());
        _;
    }

    
    function manualDailySnapshot()
        external
    {
        _dailySnapshotPoint(currentGriseDay());
    }

    function manualDailySnapshotPoint(
        uint256 _updateDay
    )
        external
    {
        require(
            _updateDay > 0 &&
            _updateDay < currentGriseDay(),
            'GRISE: snapshot day does not exist yet'
        );

        require(
            _updateDay > globals.currentGriseDay,
            'GRISE: snapshot already taken for that day'
        );

        _dailySnapshotPoint(_updateDay);
    }

    function _dailySnapshotPoint(
        uint256 _updateDay
    )
        private
    {
    
        uint256 scheduledToEndToday;
        uint256 totalStakedToday = globals.totalStaked;

        for (uint256 _day = globals.currentGriseDay; _day < _updateDay; _day++) {


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
                        GRISE_CONTRACT.totalSupply(),
                        INFLATION_RATE
                    )
                );

            snapshots[_day] = snapshot;
            globals.currentGriseDay++;
        }
    }

    function _inflationAmount(uint256 _totalStaked, uint256 _totalSupply, uint256 _INFLATION_RATE) private pure returns (uint256) {
        return (_totalStaked + _totalSupply) * 10000 / _INFLATION_RATE;
    }
}// --GRISE--

pragma solidity =0.7.6;


contract StakingToken is Snapshot {


    using SafeMath for uint256;
    receive() payable external {}

    constructor(address _immutableAddress) Declaration(_immutableAddress) {}

    function createStakeWithETH(
        uint256 _stakedAmount,
        StakeType _stakeType,
        uint64 _lockDays
    )
        external
        payable
        returns (bytes16, uint256)
    {

        address[] memory path = new address[](2);
            path[0] = WETH;
            path[1] = address(GRISE_CONTRACT);

        uint256[] memory amounts =
        UNISWAP_ROUTER.swapETHForExactTokens{value: msg.value}(
            _stakedAmount.add(_stakedAmount.mul(400).div(10000)),
            path,
            msg.sender,
            block.timestamp + 2 hours
        );

        if (msg.value > amounts[0])
        {
            (bool success, ) = msg.sender.call{value: msg.value.sub(amounts[0])}("Pending Ether");
            require(success, 'Grise: Pending ETH transfer failed');
        }

        return createStake(
            _stakedAmount,
            _stakeType,
            _lockDays
        );
    }
    
    function createStake(
        uint256 _stakedAmount,
        StakeType _stakeType,
        uint64 _lockDays
    )
        snapshotTrigger
        public
        returns (bytes16, uint256)
    {

        uint8 stakingSlot; 

        if (_stakeType == StakeType.MEDIUM_TERM){
            if (_lockDays == 168){ // 6 Month
                stakingSlot = 1;
            } else if (_lockDays == 252){ // 9 Month
                stakingSlot = 2;
            }
        }

        require(
            _lockDays % GRISE_WEEK == 0 &&
            _lockDays >= stakeDayLimit[_stakeType].minStakeDay &&
            _lockDays <= stakeDayLimit[_stakeType].maxStakeDay,
            'GRISE: stake is not in range'
        );

        require(
            _stakedAmount >= stakeCaps[_stakeType][stakingSlot].minStakingAmount && 
            _stakedAmount.mod(stakeCaps[_stakeType][stakingSlot].minStakingAmount) == 0,
            'GRISE: stake is not large enough or StakingAmount is not Valid'
        );

        require(
            stakeCaps[_stakeType][stakingSlot].stakingSlotCount <= 
                    stakeCaps[_stakeType][stakingSlot].maxStakingSlot ,
            'GRISE: All staking slot is occupied not extra slot is available'
        );

        uint256 newOccupiedSlotCount = _stakedAmount
                                      .mod(stakeCaps[_stakeType][stakingSlot].minStakingAmount) != 0?
                                      _stakedAmount
                                      .div(stakeCaps[_stakeType][stakingSlot].minStakingAmount) + 1 :
                                      _stakedAmount
                                      .div(stakeCaps[_stakeType][stakingSlot].minStakingAmount);

        require(
            (stakeCaps[_stakeType][stakingSlot].stakingSlotCount + newOccupiedSlotCount <= 
                    stakeCaps[_stakeType][stakingSlot].maxStakingSlot),
            'GRISE: All staking slot is occupied not extra slot is available'
        );

        stakeCaps[_stakeType][stakingSlot].stakingSlotCount = 
        stakeCaps[_stakeType][stakingSlot].stakingSlotCount.add(newOccupiedSlotCount);

        (
            Stake memory newStake,
            bytes16 stakeID,
            uint256 _startDay
        ) =

        _createStake(msg.sender, _stakedAmount, _lockDays, _stakeType, newOccupiedSlotCount);

        stakes[msg.sender][stakeID] = newStake;

        _increaseStakeCount(
            msg.sender
        );

        _increaseGlobals(
            uint8(newStake.stakeType),
            newStake.stakedAmount,
            newStake.stakesShares
        );
        
        _addScheduledShares(
            newStake.finalDay,
            newStake.stakesShares
        );

        GRISE_CONTRACT.setStaker(msg.sender);
        GRISE_CONTRACT.updateStakedToken(globals.totalStaked);

        if (newStake.stakeType != StakeType.SHORT_TERM) {
            GRISE_CONTRACT.updateMedTermShares(globals.MLTShares);
        }

        stakeCaps[_stakeType][stakingSlot].totalStakeCount++;

        emit StakeStart(
            stakeID,
            msg.sender,
            uint256(newStake.stakeType),
            newStake.stakedAmount,
            newStake.stakesShares,
            newStake.startDay,
            newStake.lockDays
        );

        return (stakeID, _startDay);
    }

    function _createStake(
        address _staker,
        uint256 _stakedAmount,
        uint64 _lockDays,
        StakeType  _stakeType,
        uint256 _totalOccupiedSlot
    )
        private
        returns (
            Stake memory _newStake,
            bytes16 _stakeID,
            uint256 _startDay
        )
    {

        require(
            GRISE_CONTRACT.balanceOfStaker(_staker) >= _stakedAmount,
            "GRISE: Staker doesn't have enough balance"
        );

        GRISE_CONTRACT.burnSupply(
            _staker,
            _stakedAmount
        );

        _startDay = currentGriseDay() + 1;
        _stakeID = generateStakeID(_staker);

        _newStake.stakeType = _stakeType;
        _newStake.totalOccupiedSlot = _totalOccupiedSlot;
        _newStake.lockDays = _lockDays;
        _newStake.startDay = _startDay;
        _newStake.finalDay = _startDay + _lockDays;
        _newStake.isActive = true;

        _newStake.stakedAmount = _stakedAmount;
        _newStake.stakesShares = _stakesShares(
            _stakedAmount,
            globals.sharePrice
        );
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
            uint8(endedStake.stakeType),
            endedStake.stakedAmount,
            endedStake.stakesShares
        );

        _removeScheduledShares(
            endedStake.finalDay,
            endedStake.stakesShares
        );

        _storePenalty(
            endedStake.closeDay,
            penaltyAmount
        );

        uint8 stakingSlot; 
        if (endedStake.stakeType == StakeType.MEDIUM_TERM){
            if (endedStake.lockDays == 168) { // 6 Month
                stakingSlot = 1;
            } else if (endedStake.lockDays == 252) { // 9 Month
                stakingSlot = 2;
            }
        }

        stakeCaps[endedStake.stakeType][stakingSlot].stakingSlotCount = 
        stakeCaps[endedStake.stakeType][stakingSlot].stakingSlotCount.sub(endedStake.totalOccupiedSlot);
        
        GRISE_CONTRACT.resetStaker(msg.sender);
        GRISE_CONTRACT.updateStakedToken(globals.totalStaked);

        if (endedStake.stakeType != StakeType.SHORT_TERM) {
            GRISE_CONTRACT.updateMedTermShares(globals.MLTShares);
        }
        
        stakeCaps[endedStake.stakeType][stakingSlot].totalStakeCount--;

        emit StakeEnd(
            _stakeID,
            msg.sender,
            uint256(endedStake.stakeType),
            endedStake.stakedAmount,
            endedStake.stakesShares,
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
            stakes[_staker][_stakeID].isActive,
            'GRISE: Not an active stake'
        );

        uint256 transFeeCompensation;
        _stake = stakes[_staker][_stakeID];
        _stake.closeDay = currentGriseDay();
        _stake.rewardAmount = _calculateRewardAmount(_stake);
        _penalty = _calculatePenaltyAmount(_stake);

        if (_stake.stakeType == StakeType.SHORT_TERM)
        {
            transFeeCompensation = (_stake.stakedAmount
                                    .add(_stake.rewardAmount)
                                    .sub(_penalty))
                                    .mul(ST_STAKER_COMPENSATION)
                                    .div(REWARD_PRECISION_RATE);
        }
        else
        {
            transFeeCompensation = (_stake.stakedAmount
                                    .add(_stake.rewardAmount)
                                    .sub(_penalty))
                                    .mul(MLT_STAKER_COMPENSATION)
                                    .div(REWARD_PRECISION_RATE);
        }
        _stake.isActive = false;

        GRISE_CONTRACT.mintSupply(
            _staker,
            _stake.stakedAmount > _penalty ?
            _stake.stakedAmount - _penalty : 0
        );

        GRISE_CONTRACT.mintSupply(
            _staker,
            _stake.rewardAmount
        );

        GRISE_CONTRACT.mintSupply(
            _staker,
            transFeeCompensation
        );
    }

    function scrapeReward(
        bytes16 _stakeID
    )
        external
        snapshotTrigger
        returns (
            uint256 scrapeDay,
            uint256 scrapeAmount
        )
    {

        require(
            stakes[msg.sender][_stakeID].isActive,
            'GRISE: Not an active stake'
        );

        Stake memory stake = stakes[msg.sender][_stakeID];

        require(
            globals.currentGriseDay >= stake.finalDay || 
                _startingDay(stake) < currentGriseDay().sub(currentGriseDay().mod(GRISE_WEEK)),
            'GRISE: Stake is not yet mature to claim Reward'
        );

        scrapeDay = _calculationDay(stake);

        scrapeDay = scrapeDay < stake.finalDay
            ? scrapeDay.sub(scrapeDay.mod(GRISE_WEEK))
            : scrapeDay;

        scrapeAmount = getTranscRewardAmount(msg.sender, _stakeID);

        scrapeAmount += getPenaltyRewardAmount(msg.sender, _stakeID);

        scrapeAmount += getReservoirRewardAmount(msg.sender, _stakeID);

        scrapes[msg.sender][_stakeID] =
        scrapes[msg.sender][_stakeID].add(scrapeAmount);
        
        stake.scrapeDay = scrapeDay;
        stakes[msg.sender][_stakeID] = stake;

        GRISE_CONTRACT.mintSupply(
            msg.sender,
            scrapeAmount
        );

        emit InterestScraped(
            _stakeID,
            msg.sender,
            scrapeAmount,
            scrapeDay,
            currentGriseDay()
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

            uint256 _day = currentGriseDay() - 1;
            snapshots[_day].scheduledToEnd =
            snapshots[_day].scheduledToEnd > _shares ?
            snapshots[_day].scheduledToEnd - _shares : 0;
        }
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
        returns 
    (
        uint256 startDay,
        uint256 lockDays,
        uint256 finalDay,
        uint256 closeDay,
        uint256 scrapeDay,
        StakeType stakeType,
        uint256 slotOccupied,
        uint256 stakedAmount,
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
        stakeType = stake.stakeType;
        slotOccupied = stake.totalOccupiedSlot;
        stakedAmount = stake.stakedAmount;
        penaltyAmount = _calculatePenaltyAmount(stake);
        isActive = stake.isActive;
        isMature = _isMatureStake(stake);
    }

    function checkStakeRewards(
        address _staker,
        bytes16 _stakeID
    )
        external
        view
        returns 
    (
        uint256 transcRewardAmount,
        uint256 penaltyRewardAmount,
        uint256 reservoirRewardAmount,
        uint256 inflationRewardAmount
    )
    {

        transcRewardAmount = getTranscRewardAmount(_staker, _stakeID);
        penaltyRewardAmount = getPenaltyRewardAmount(_staker, _stakeID);
        reservoirRewardAmount = getReservoirRewardAmount(_staker, _stakeID);
        inflationRewardAmount = getInflationRewardAmount(_staker, _stakeID);
    }

    function updateStakingSlotLimit(
        uint256 STSlotLimit,
        uint256 MT3MonthSlotLimit,
        uint256 MT6MonthSlotLimit,
        uint256 MT9MonthSlotLimit,
        uint256 LTSlotLimit
    )
    external
    {

        require(
            msg.sender == contractDeployer,
            'Operation Denied'
        );

        stakeCaps[StakeType.SHORT_TERM][0].maxStakingSlot = STSlotLimit;
        stakeCaps[StakeType.MEDIUM_TERM][0].maxStakingSlot = MT3MonthSlotLimit;
        stakeCaps[StakeType.MEDIUM_TERM][1].maxStakingSlot = MT6MonthSlotLimit;
        stakeCaps[StakeType.MEDIUM_TERM][2].maxStakingSlot = MT9MonthSlotLimit;
        stakeCaps[StakeType.LONG_TERM][0].maxStakingSlot = LTSlotLimit;
    }

    function getTranscRewardAmount(
        address _staker,
        bytes16 _stakeID
    ) 
        private
        view
        returns (uint256 rewardAmount)
    {

        Stake memory _stake = stakes[_staker][_stakeID];

        if ( _stakeEligibleForWeeklyReward(_stake))
        {
            uint256 _endDay = currentGriseDay() >= _stake.finalDay ? 
                                _stake.finalDay : 
                                currentGriseDay().sub(currentGriseDay().mod(GRISE_WEEK));

            rewardAmount = _loopTranscRewardAmount(
                _stake.stakesShares,
                _startingDay(_stake),
                _endDay,
                _stake.stakeType);
        }
    }

    function getPenaltyRewardAmount(
        address _staker,
        bytes16 _stakeID
    ) 
        private 
        view 
        returns (uint256 rewardAmount) 
    {

        Stake memory _stake = stakes[_staker][_stakeID];

        if ( _stakeEligibleForWeeklyReward(_stake))
        {
            uint256 _endDay = currentGriseDay() >= _stake.finalDay ? 
                                _stake.finalDay : 
                                currentGriseDay().sub(currentGriseDay().mod(GRISE_WEEK));

            rewardAmount = _loopPenaltyRewardAmount(
                _stake.stakesShares,
                _startingDay(_stake),
                _endDay,
                _stake.stakeType);
        }
    }

    function getReservoirRewardAmount(
        address _staker,
        bytes16 _stakeID
    ) 
        private 
        view 
        returns (uint256 rewardAmount) 
    {

        Stake memory _stake = stakes[_staker][_stakeID];

        if ( _stakeEligibleForMonthlyReward(_stake))
        {
            uint256 _endDay = currentGriseDay() >= _stake.finalDay ? 
                                _stake.finalDay : 
                                currentGriseDay().sub(currentGriseDay().mod(GRISE_MONTH));

            rewardAmount = _loopReservoirRewardAmount(
                _stake.stakesShares,
                _startingDay(_stake),
                _endDay,
                _stake.stakeType
            );
        }
    }

    function getInflationRewardAmount(
        address _staker,
        bytes16 _stakeID
    ) 
        private 
        view 
        returns (uint256 rewardAmount) 
    {    

        Stake memory _stake = stakes[_staker][_stakeID];

        if ( _stake.isActive && !_stakeNotStarted(_stake))
        {
            rewardAmount = _loopInflationRewardAmount(
            _stake.stakesShares,
            _stake.startDay,
            _calculationDay(_stake),
            _stake.stakeType);
        }
    }

    function _stakesShares(
        uint256 _stakedAmount,
        uint256 _sharePrice
    )
        private
        pure
        returns (uint256)
    {

        return _stakedAmount
                .div(_sharePrice);
    }

    function _storePenalty(
        uint256 _storeDay,
        uint256 _penalty
    )
        private
    {

        if (_penalty > 0) {
            totalPenalties[_storeDay] =
            totalPenalties[_storeDay].add(_penalty);

            MLTPenaltiesRewardPerShares[_storeDay] += 
                _penalty.mul(MED_LONG_STAKER_PENALTY_REWARD)
                        .div(REWARD_PRECISION_RATE)
                        .div(globals.MLTShares);

            STPenaltiesRewardPerShares[_storeDay] +=
                _penalty.mul(SHORT_STAKER_PENALTY_REWARD)
                        .div(REWARD_PRECISION_RATE)
                        .div(globals.STShares);

            ReservoirPenaltiesRewardPerShares[_storeDay] +=
                _penalty.mul(RESERVOIR_PENALTY_REWARD)
                        .div(REWARD_PRECISION_RATE)
                        .div(globals.MLTShares);

            GRISE_CONTRACT.mintSupply(
                TEAM_ADDRESS,
                _penalty.mul(TEAM_PENALTY_REWARD)
                        .div(REWARD_PRECISION_RATE)
            );

            GRISE_CONTRACT.mintSupply(
                DEVELOPER_ADDRESS,
                _penalty.mul(DEVELOPER_PENALTY_REWARD)
                        .div(REWARD_PRECISION_RATE)
            );
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

    function _getPenalties(
        Stake memory _stake
    )
        private
        view
        returns (uint256)
    {

        return _stake.stakedAmount * ((PENALTY_RATE * (_daysLeft(_stake) - 1) / (_getLockDays(_stake)))) / 10000;
    }

    function _calculateRewardAmount(
        Stake memory _stake
    )
        private
        view
        returns (uint256 _rewardAmount)
    {

        _rewardAmount = _loopPenaltyRewardAmount(
            _stake.stakesShares,
            _startingDay(_stake),
            _calculationDay(_stake),
            _stake.stakeType
        );

        _rewardAmount += _loopTranscRewardAmount(
            _stake.stakesShares,
            _startingDay(_stake),
            _calculationDay(_stake),
            _stake.stakeType
        );

        _rewardAmount += _loopReservoirRewardAmount(
            _stake.stakesShares,
            _startingDay(_stake),
            _calculationDay(_stake),
             _stake.stakeType
        );
        
        _rewardAmount += _loopInflationRewardAmount(
            _stake.stakesShares,
            _stake.startDay,
            _calculationDay(_stake),
            _stake.stakeType
        );
    }

    function _loopInflationRewardAmount(
        uint256 _stakeShares,
        uint256 _startDay,
        uint256 _finalDay,
        StakeType _stakeType
    )
        private
        view
        returns (uint256 _rewardAmount)
    {

        uint256 inflationAmount;
        if (_stakeType == StakeType.SHORT_TERM)
        {
            return 0;
        }

        for (uint256 _day = _startDay; _day < _finalDay; _day++) {

            inflationAmount = (_stakeType == StakeType.MEDIUM_TERM) ? 
                                snapshots[_day].inflationAmount
                                .mul(MED_TERM_INFLATION_REWARD)
                                .div(REWARD_PRECISION_RATE) :
                                snapshots[_day].inflationAmount
                                .mul(LONG_TERM_INFLATION_REWARD)
                                .div(REWARD_PRECISION_RATE);

            _rewardAmount = _rewardAmount
                            .add(_stakeShares
                                    .mul(PRECISION_RATE)
                                    .div(inflationAmount));
        }
    }

    function _loopPenaltyRewardAmount(
        uint256 _stakeShares,
        uint256 _startDay,
        uint256 _finalDay,
        StakeType _stakeType
    )
        private
        view
        returns (uint256 _rewardAmount)
    {

        for (uint256 day = _startDay; day < _finalDay; day++) 
        {
            if (_stakeType == StakeType.SHORT_TERM)
            {
                _rewardAmount += STPenaltiesRewardPerShares[day]
                                    .mul(_stakeShares);
            } else {
                _rewardAmount += MLTPenaltiesRewardPerShares[day]
                                    .mul(_stakeShares);
            }
        }
    }

    function _loopReservoirRewardAmount(
        uint256 _stakeShares,
        uint256 _startDay,
        uint256 _finalDay,
        StakeType _stakeType
    )
        private
        view
        returns (uint256 _rewardAmount)
    {

        if (_stakeType == StakeType.SHORT_TERM)
        {
            return 0;
        }

        for (uint256 day = _startDay; day < _finalDay; day++) 
        {
            _rewardAmount = 
            _rewardAmount.add(ReservoirPenaltiesRewardPerShares[day]);
        }

        _rewardAmount = 
        _rewardAmount.add(GRISE_CONTRACT.getReservoirReward(_startDay, _finalDay));

        _rewardAmount = 
        _rewardAmount.mul(_stakeShares);
    }

    function _loopTranscRewardAmount(
        uint256 _stakeShares,
        uint256 _startDay,
        uint256 _finalDay,
        StakeType _stakeType
    )
        private
        view
        returns (uint256 _rewardAmount)
    {

        uint256 stakedAmount = _stakeShares.mul(globals.sharePrice);
        
        if (_stakeType != StakeType.SHORT_TERM)
        {
            _rewardAmount =
            _rewardAmount.add(GRISE_CONTRACT.getTransFeeReward(_startDay, _finalDay)
                                .mul(_stakeShares)); 
        }

        _rewardAmount =
        _rewardAmount.add(GRISE_CONTRACT.getTokenHolderReward(_startDay, _finalDay)
                            .mul(stakedAmount)
                            .div(PRECISION_RATE));
    }

    function getSlotLeft() 
        external 
        view 
        returns 
    (
        uint256 STSlotLeft, 
        uint256 MT3MonthSlotLeft,
        uint256 MT6MonthSlotLeft, 
        uint256 MT9MonthSlotLeft, 
        uint256 LTSlotLeft
    ) 
    {


        STSlotLeft = stakeCaps[StakeType.SHORT_TERM][0].maxStakingSlot
                            .sub(stakeCaps[StakeType.SHORT_TERM][0].stakingSlotCount);

        MT3MonthSlotLeft = stakeCaps[StakeType.MEDIUM_TERM][0].maxStakingSlot
                            .sub(stakeCaps[StakeType.MEDIUM_TERM][0].stakingSlotCount);
                            
        MT6MonthSlotLeft = stakeCaps[StakeType.MEDIUM_TERM][1].maxStakingSlot
                            .sub(stakeCaps[StakeType.MEDIUM_TERM][1].stakingSlotCount);

        MT9MonthSlotLeft = stakeCaps[StakeType.MEDIUM_TERM][2].maxStakingSlot
                            .sub(stakeCaps[StakeType.MEDIUM_TERM][2].stakingSlotCount);
        
        LTSlotLeft = stakeCaps[StakeType.LONG_TERM][0].maxStakingSlot
                            .sub(stakeCaps[StakeType.LONG_TERM][0].stakingSlotCount);
    }

    function getStakeCount() 
        external 
        view 
        returns 
    (
        uint256 STStakeCount, 
        uint256 MT3MonthStakeCount,
        uint256 MT6MonthStakeCount,
        uint256 MT9MonthStakeCount,
        uint256 LTStakeCount
    )
    {

        STStakeCount = stakeCaps[StakeType.SHORT_TERM][0].totalStakeCount;
        MT3MonthStakeCount = stakeCaps[StakeType.MEDIUM_TERM][0].totalStakeCount;
        MT6MonthStakeCount = stakeCaps[StakeType.MEDIUM_TERM][1].totalStakeCount;
        MT9MonthStakeCount = stakeCaps[StakeType.MEDIUM_TERM][2].totalStakeCount;
        LTStakeCount = stakeCaps[StakeType.LONG_TERM][0].totalStakeCount;
    }

    function getTotalStakedToken()
        external
        view 
        returns (uint256) 
    {

        return globals.totalStaked;
    }
}// --GRISE--

pragma solidity ^0.7.6;

contract Migrations {

    address public owner;
    uint public last_completed_migration;

    constructor() {
        owner = msg.sender;
    }

    modifier restricted() {

        if (msg.sender == owner)
        _;
    }

    function setCompleted(uint completed) public restricted {

        last_completed_migration = completed;
    }

    function upgrade(address new_address) public restricted {

        Migrations upgraded = Migrations(new_address);
        upgraded.setCompleted(last_completed_migration);
    }
}
