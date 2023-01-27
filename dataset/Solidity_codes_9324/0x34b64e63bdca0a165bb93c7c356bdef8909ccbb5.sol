

pragma solidity ^0.6.8;



interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {


    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SM: ADD OVF");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SM: SUB OVF");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SM: MUL OVF");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SM: DIV/0");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SM: MOD 0");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}


interface IHEX {


    struct DailyDataStore {
        uint72 dayPayoutTotal;
        uint72 dayStakeSharesTotal;
        uint56 dayUnclaimedSatoshisTotal;
    }

    function currentDay() external view returns (uint256);


    function globalInfo() external view returns (uint256[13] memory);


    function dailyData(uint256 lobbyDay) external view returns
        (uint72 dayPayoutTotal, uint72 dayStakeSharesTotal, uint56 dayUnclaimedSatoshisTotal);


    struct XfLobbyEntryStore {
        uint96 rawAmount;
        address referrerAddr;
    }

    struct XfLobbyQueueStore {
        uint40 headIndex;
        uint40 tailIndex;
        mapping(uint256 => XfLobbyEntryStore) entries;
    }

    function xfLobby(uint256 lobbyDay) external view returns (uint256 rawAmount);


    function xfLobbyMembers(uint256 i, address _XfLobbyQueueStore) external view returns
        (uint40 headIndex, uint40 tailIndex, uint96 rawAmount, address referrerAddr);


    function xfLobbyEnter(address referrerAddr) external payable;


    function xfLobbyExit(uint256 enterDay, uint256 count) external;


    function dailyDataUpdate(uint256 beforeDay) external;


    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract HEXme {



    using SafeMath for uint256;
    using SafeMath for uint40;


    uint256 private constant HEARTS_PER_HEX = 10 ** uint256(8);
    uint256 private constant HEARTS_PER_SATOSHI = HEARTS_PER_HEX / 1e8 * 1e4;
    uint256 private constant WAAS_LOBBY_SEED_HEARTS = 1e9 * HEARTS_PER_HEX;

    uint256 private constant CLAIM_PHASE_START_DAY = 1;
    uint256 private constant CLAIM_PHASE_DAYS = 50 * 7;
    uint256 private constant CLAIM_PHASE_END_DAY = CLAIM_PHASE_START_DAY + CLAIM_PHASE_DAYS;
    uint256 private constant BIG_PAY_DAY = CLAIM_PHASE_END_DAY + 1;


    IHEX public constant HEX = IHEX(0x2b591e99afE9f32eAA6214f7B7629768c40Eeb39);

    address public constant ORIGIN_ADDR = 0x63Cbc7d47dfFE12C2B57AD37b8458944ad4121Ee;


    uint256 constant private totalShares = 1320;
    uint256 constant public basicShares = 1000;
    uint256 public userShares = 1200;
    uint256 public marginShares = 60;


    struct GlobalsStore {
        uint256 initDay;
        uint256 exitLobbyPointer;
        uint256 minimumEntryAmount;
        uint256 totalContractsExitedHEX;
        uint256 totalUsersExitedHEX;
    }

    GlobalsStore public globals;

    struct HEXmeLobbyEntryQueueStore {
        uint40 headIndex;
        uint40 tailIndex;
    }


    mapping(uint256 => uint256) public HEXmeLobbyETHperDay;
    mapping(uint256 => uint256) public HEXmeLobbyHEXperDay;
    mapping(uint256 => uint256[]) public HEXmeLobbyETHperDayEntries;
    mapping(address => mapping(uint256 => uint256)) public HEXmeUsersLobbyETHperDay;
    mapping(uint256 => HEXmeLobbyEntryQueueStore) public HEXmeLobbyEntryQueue;

    mapping(address => address) private referredForever;
    mapping(address => uint256) private referredSince;


    event EnteredLobby(uint256 lobbyDay, address indexed user, address indexed referrer, uint256 enteredETH);
    event ExitedLobby(uint256 lobbyDay, address indexed user, address indexed referrer, uint256 usersHEX, uint256 referrersHEX, uint256 exitedETH);
    event ExitedOnBehalf(uint256 lobbyDay, address indexed user, address indexed sender);
    event NewReferral(address indexed referrer, address referee, uint256 currentDay);

    event ContractFullyExitedLobbyDay(uint256 lobbyDay, uint256 currentDay);
    event MovedExitLobbyPointer(uint256 from, uint256 to, uint256 currentDay);
    event ChangedMinimumEntryAmount(uint256 from, uint256 to, uint256 currentDay);
    event RaisedUserShares(uint256 userShares, uint256 marginShares, uint256 currentDay);
    event FlushedExceedingHEX(uint256 exceedingHEX, uint256 currentDay);


    modifier onlyOrigin {

        require(msg.sender == ORIGIN_ADDR, "HEXme: only ORIGIN_ADDR");
        _;
    }

    constructor() public payable {
        uint256 initBufferEntryAmount = 1000000000000000;
        require(msg.value == initBufferEntryAmount);

        globals.minimumEntryAmount = initBufferEntryAmount;
        globals.initDay = HEX.currentDay();
        globals.exitLobbyPointer = globals.initDay;

        _enterLobby(address(0));

        globals.minimumEntryAmount = 25000000000000000;
    }

    receive() external payable {
        _enterLobby(ORIGIN_ADDR);
    }

    function enterLobby() external payable {

        _enterLobby(address(0));
    }

    function enterLobbyWithReferrer(address referrer) external payable {

        _enterLobby(referrer);
    }

    function _enterLobby(address referrer) private {

        require(msg.value >= globals.minimumEntryAmount, "HEXme: below minimumEntryAmount");

        HEX.xfLobbyEnter{value : msg.value}(address(this));

        uint256 currentDay = HEX.currentDay();

        _updateReferrer(referrer, currentDay);

        HEXmeLobbyETHperDay[currentDay] += msg.value;
        HEXmeUsersLobbyETHperDay[msg.sender][currentDay] += msg.value;
        HEXmeLobbyETHperDayEntries[currentDay].push(msg.value);
        HEXmeLobbyEntryQueue[currentDay].tailIndex++;

        emit EnteredLobby(currentDay, msg.sender, referredForever[msg.sender], msg.value);
    }

    function _updateReferrer(address referrer, uint256 currentDay) private {

        if (referrer != address(0) && referrer != msg.sender && !_isReferred(msg.sender)) {
            referredForever[msg.sender] = referrer;
            referredSince[msg.sender] = currentDay;
            emit NewReferral(referrer, msg.sender, currentDay);
        }
    }

    function _isReferred(address userAddress) private view returns (bool){

        return (referredForever[userAddress] != address(0));
    }

    function exitLobby(uint256 lobbyDay) external {

        uint256 currentDay = HEX.currentDay();
        _exitLobby(msg.sender, lobbyDay, currentDay);
    }

    function exitLobbyOnBehalf(address userAddress, uint256 lobbyDay) external {

        uint256 currentDay = HEX.currentDay();
        require(
            msg.sender == userAddress ||
            (
                (currentDay > CLAIM_PHASE_END_DAY.sub(7)) &&
                (
                    msg.sender == ORIGIN_ADDR ||
                    (msg.sender == referredForever[userAddress] && lobbyDay >= referredSince[userAddress])
                )
            ),
            "HEXme: Only for incentivized users, from day 345 on"
        );
        _exitLobby(userAddress, lobbyDay, currentDay);
    }

    function _exitLobby(address userAddress, uint256 lobbyDay, uint256 currentDay) private {

        uint256 ETHtoExit = HEXmeUsersLobbyETHperDay[userAddress][lobbyDay];

        require(lobbyDay < currentDay, "HEXme: Day not complete");
        require(ETHtoExit > 0, "HEXme: No entry from this user, this day");

        uint256 HEXtoExit = _getUsersHEXtoExit(userAddress, lobbyDay);
        delete HEXmeUsersLobbyETHperDay[userAddress][lobbyDay];
        globals.totalUsersExitedHEX += HEXtoExit;

        _exitTillLiquidity(HEXtoExit, currentDay);
        _payoutHEX(userAddress, HEXtoExit, ETHtoExit, lobbyDay);
    }

    function _getUsersHEXtoExit(address userAddress, uint256 lobbyDay) private returns (uint256 HEXtoExit){

        _updateHEXmeLobbyHEXperDay(lobbyDay);
        return ((HEXmeUsersLobbyETHperDay[userAddress][lobbyDay]
            .mul(HEXmeLobbyHEXperDay[lobbyDay])).div(HEXmeLobbyETHperDay[lobbyDay]));
    }

    function _updateHEXmeLobbyHEXperDay(uint256 lobbyDay) private {

        if (HEXmeLobbyHEXperDay[lobbyDay] == 0) {
            uint256 HEXinLobby = _getHEXinLobby(lobbyDay);
            if (HEXinLobby == 0) {
                HEX.dailyDataUpdate(lobbyDay + 1);
                HEXinLobby = _getHEXinLobby(lobbyDay);
            }
            uint256 basicHEXperDay =
                (HEXinLobby.mul(HEXmeLobbyETHperDay[lobbyDay])).div(HEX.xfLobby(lobbyDay));
                HEXmeLobbyHEXperDay[lobbyDay] = (basicHEXperDay.mul(totalShares)).div(basicShares);
        }
    }

    function _getHEXinLobby(uint256 lobbyDay) private view returns (uint256 HEXinLobby){

        if (lobbyDay >= 1) {
            (,,uint256 dayUnclaimedSatoshisTotal) = HEX.dailyData(lobbyDay);
            if (lobbyDay == HEX.currentDay()) {
                dayUnclaimedSatoshisTotal = HEX.globalInfo()[7];
            }
            return dayUnclaimedSatoshisTotal * HEARTS_PER_SATOSHI / CLAIM_PHASE_DAYS;
        } else {
            return WAAS_LOBBY_SEED_HEARTS;
        }
    }

    function _exitTillLiquidity(uint256 liquidity, uint256 currentDay) private {

        uint256 cachedExitLobbyPointer = globals.exitLobbyPointer;
        uint40 cachedHeadIndex = HEXmeLobbyEntryQueue[cachedExitLobbyPointer].headIndex;

        uint256 startIndex = HEXmeLobbyEntryQueue[cachedExitLobbyPointer].headIndex;
        uint256 startLiquidity = HEX.balanceOf(address(this));
        uint256 currentLiquidity = startLiquidity;

        while (currentLiquidity < liquidity) {
            if (cachedHeadIndex < HEXmeLobbyEntryQueue[cachedExitLobbyPointer].tailIndex) {
                uint256 addedLiquidity =
                    (HEXmeLobbyETHperDayEntries[cachedExitLobbyPointer][cachedHeadIndex]
                    .mul(HEXmeLobbyHEXperDay[cachedExitLobbyPointer])).div(HEXmeLobbyETHperDay[cachedExitLobbyPointer]);

                currentLiquidity = currentLiquidity.add(addedLiquidity);
                cachedHeadIndex++;
            } else {
                if (cachedHeadIndex.sub(startIndex) > 0) {
                    HEX.xfLobbyExit(cachedExitLobbyPointer, cachedHeadIndex.sub(startIndex));

                    if (cachedHeadIndex == HEXmeLobbyEntryQueue[cachedExitLobbyPointer].tailIndex)
                        emit ContractFullyExitedLobbyDay(cachedExitLobbyPointer, currentDay);
                }

                if(cachedHeadIndex != HEXmeLobbyEntryQueue[cachedExitLobbyPointer].headIndex)
                    HEXmeLobbyEntryQueue[cachedExitLobbyPointer].headIndex = cachedHeadIndex;

                cachedExitLobbyPointer++;

                if (cachedExitLobbyPointer >= currentDay || cachedExitLobbyPointer >= CLAIM_PHASE_END_DAY)
                    cachedExitLobbyPointer = globals.initDay;

                cachedHeadIndex = HEXmeLobbyEntryQueue[cachedExitLobbyPointer].headIndex;
                startIndex = cachedHeadIndex;
            }
        }

        if (cachedHeadIndex.sub(startIndex) > 0) {
            HEX.xfLobbyExit(cachedExitLobbyPointer, cachedHeadIndex.sub(startIndex));

            if (cachedHeadIndex == HEXmeLobbyEntryQueue[cachedExitLobbyPointer].tailIndex)
                emit ContractFullyExitedLobbyDay(cachedExitLobbyPointer, currentDay);
        }

        globals.totalContractsExitedHEX = globals.totalContractsExitedHEX.add(
            HEX.balanceOf(address(this)).sub(startLiquidity));

        if (HEXmeLobbyEntryQueue[cachedExitLobbyPointer].headIndex != cachedHeadIndex)
            HEXmeLobbyEntryQueue[cachedExitLobbyPointer].headIndex = cachedHeadIndex;

        if (globals.exitLobbyPointer != cachedExitLobbyPointer)
            globals.exitLobbyPointer = cachedExitLobbyPointer;
    }

    function _payoutHEX(address userAddress, uint256 HEXtoExit, uint256 exitedETH, uint256 lobbyDay) private {

        uint256 usersHEX = (HEXtoExit.mul(userShares)).div(totalShares);
        uint256 marginHEX = HEXtoExit.sub(usersHEX);
        uint256 referrersHEX = (_isReferred(userAddress) && lobbyDay >= referredSince[userAddress]) ?
            (marginHEX.mul(marginShares)).div(totalShares.sub(userShares)) : 0;
        uint256 originsHEX = marginHEX.sub(referrersHEX);

        if (originsHEX > 0)
            HEX.transfer(address(ORIGIN_ADDR), originsHEX);

        if (referrersHEX > 0)
            HEX.transfer(address(referredForever[userAddress]), referrersHEX);

        if (usersHEX > 0)
            HEX.transfer(userAddress, usersHEX);

        emit ExitedLobby(lobbyDay, userAddress, referredForever[userAddress], usersHEX, referrersHEX, exitedETH);

        if (msg.sender != userAddress)
            emit ExitedOnBehalf(lobbyDay, userAddress, msg.sender);
    }

    function exitContractLobbyDay(uint256 lobbyDay, uint40 count) external {

        uint256 startLiquidity = HEX.balanceOf(address(this));

        HEX.xfLobbyExit(lobbyDay, count);

        globals.totalContractsExitedHEX = globals.totalContractsExitedHEX.add(
            HEX.balanceOf(address(this)).sub(startLiquidity));

        if (count > 0)
            HEXmeLobbyEntryQueue[lobbyDay].headIndex += count;
        else
            HEXmeLobbyEntryQueue[lobbyDay].headIndex = HEXmeLobbyEntryQueue[lobbyDay].tailIndex;

        if (HEXmeLobbyEntryQueue[lobbyDay].headIndex == HEXmeLobbyEntryQueue[lobbyDay].tailIndex)
            emit ContractFullyExitedLobbyDay(lobbyDay, HEX.currentDay());
    }

    function changeMinimumEntryAmount(uint256 newMinimumEntryAmount) external onlyOrigin {

        require(10000000000000000 <= newMinimumEntryAmount && newMinimumEntryAmount <= 50000000000000000, "HEXme: INV VAL");

        emit ChangedMinimumEntryAmount(globals.minimumEntryAmount, newMinimumEntryAmount, HEX.currentDay());

        globals.minimumEntryAmount = newMinimumEntryAmount;
    }

    function raiseUserShares(uint256 newUserSharesInPerMill) external onlyOrigin {

        require(newUserSharesInPerMill.add(20) <= totalShares, "HEXme: 1300 CAP");
        require(newUserSharesInPerMill > userShares, "HEXme: INCREASE");

        marginShares = (totalShares.sub(newUserSharesInPerMill)).div(2);
        userShares = totalShares.sub(marginShares.mul(2));

        emit RaisedUserShares(userShares, marginShares, HEX.currentDay());
    }

    function moveExitLobbyPointer(uint256 newLobbyPointerDay) external onlyOrigin {

        require(newLobbyPointerDay >= globals.initDay && newLobbyPointerDay < HEX.currentDay(), "HEXme: INV VAL");

        emit MovedExitLobbyPointer(globals.exitLobbyPointer, newLobbyPointerDay, HEX.currentDay());

        globals.exitLobbyPointer = newLobbyPointerDay;
    }

    function flushExceedingHEX() external onlyOrigin {

        uint256 currentLiquidity = HEX.balanceOf(address(this));
        uint256 reservedLiquidity = globals.totalContractsExitedHEX.sub(globals.totalUsersExitedHEX);
        uint256 exceedingLiquidity = (currentLiquidity.sub(reservedLiquidity)).sub(HEARTS_PER_HEX);

        require(exceedingLiquidity > 0, "HEXme: 0 Exceeding");

        HEX.transfer(ORIGIN_ADDR, exceedingLiquidity);
        emit FlushedExceedingHEX(exceedingLiquidity, HEX.currentDay());
    }

    function flushERC20(IERC20 _token) external onlyOrigin {

        require(_token.balanceOf(address(this)) > 0, "HEXme: 0 BAL");
        require(address(_token) != address(HEX), "HEXme: !HEX");
        _token.transfer(ORIGIN_ADDR, _token.balanceOf(address(this)));
    }


    function getCurrentDay() external view returns (uint256) {

        return HEX.currentDay();
    }

    function getHEXinLobby(uint256 lobbyDay) external view returns (uint256){

        return _getHEXinLobby(lobbyDay);
    }

    function getHistoricLobby(bool getHEXInsteadETH) external view returns (uint256[] memory){

        uint256 tillDay = HEX.currentDay();
        tillDay = (tillDay <= CLAIM_PHASE_END_DAY) ? tillDay : CLAIM_PHASE_END_DAY;
        uint256[] memory historicLobby = new uint256[](tillDay + 1);
        for (uint256 i = 0; i <= tillDay; i++) {
            if (getHEXInsteadETH)
                historicLobby[i] = _getHEXinLobby(i);
            else
                historicLobby[i] = HEX.xfLobby(i);
        }
        return historicLobby;
    }
}