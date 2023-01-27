
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;


interface IDotTokenContract{

  function balanceOf(address account) external view returns (uint256);

  function totalSupply() external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  function allowance(address owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
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
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IDoTxLib{

    function queryChainLinkPrice(string calldata _fsym, string calldata _fsymId, int256 _multiplicator, bytes4 _selector) external;

    function fetchFirstDayPrices(string calldata firstHouseTicker, string calldata secondHouseTicker, string calldata firstHouseId, string calldata secondHouseId, int256 multiplicator, uint256 warIndex) external;

    function fetchLastDayPrices(string calldata firstHouseTicker, string calldata currentSecondHouseTicker, string calldata firstHouseId, string calldata secondHouseId, int256 multiplicator, uint256 warIndex) external;

    function setDoTxGame(address gameAddress) external;

    function calculateHousePerf(int256 open, int256 close, int256 precision) external pure returns(int256);

    function calculatePercentage(uint256 amount, uint256 percentage, uint256 selecteWinnerPrecision) external pure returns(uint256);

    function calculateReward(uint256 dotxUserBalance, uint256 totalDoTxWinningHouse, uint256 totalDoTxLosingHouse) external view returns(uint256);

    function getWarIndex() external view returns(uint256);

}

contract Context {

    constructor () internal { }

    function _msgSender() internal view virtual returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {

        this; 
        return msg.data;
    }
}

contract Ownable is Context {

    address private _owner;
    address private _owner2;
    address public dotxLibAddress;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }
    
    function owner2() public view returns (address) {

        return _owner2;
    }
    
    function setOwner2(address ownerAddress) public onlyOwner {

        _owner2 = ownerAddress;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender() || _owner2 == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    
    modifier onlyOwnerOrDoTxLib() {

        require(_owner == _msgSender() || dotxLibAddress == _msgSender() || _owner2 == _msgSender(), "Ownable: caller is not the owner or the lib");
        _;
    }
    
    modifier onlyDoTxLib() {

        require(dotxLibAddress == _msgSender(), "Ownable: caller is not the owner or the lib");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract DoTxGameContract is Ownable {

    using SafeMath for uint256;
    address constant public BURN_ADDRESS = 0x0000000000000000000000000000000000000001;

    struct War {
        uint256 startTime;
        uint256 duration;
        uint256 ticketPrice;
        uint256 purchasePeriod;
        bytes32 winningHouse;
        uint256 warFeesPercent;
        int256 multiplicator;
        uint256 burnPercentage;
        uint256 stakingPercentage;
        House firstHouse;
        House secondHouse;
        mapping(address => User) users;
    }
    struct House {
        bytes32 houseTicker;
        bytes32 houseId;
        uint256 openPrice;
        uint256 closePrice;
        uint256 ticketsBought;
    }
    struct User {
        bytes32 houseTicker;
        uint256 ticketsBought;
        bool rewardClaimed;
    }
    
    struct BurnStake {
        uint256 firstHouseBurnDoTx;
        uint256 firstHouseStakingDoTx;
        uint256 secondHouseBurnDoTx;
        uint256 secondHouseStakingDoTx;
    }
    
    struct WarHouses {
        uint256 index;
        bytes32 firstHouse;
        bytes32 secondHouse;
        uint256 startTime;
        uint256 duration;
    }
    
    IDotTokenContract private dotxToken;
    IDoTxLib private dotxLib;
    address stakingAddress = address(0x1c2206f3115CaC3750acCb899d18d50b774C2f21);
    
    mapping(uint256 => War) public wars;
    
    uint256 public totalFees;
    uint256 public selecteWinnerPrecision = 100000;
    
    uint256 public burnPercentage = 5;
    uint256 public stakingPercentage = 5;
    int256 public multiplicator = 10000;
    
    event WarStarted(uint256 warIndex);
    event TicketBought(uint256 warIndex, string house, uint256 valueInDoTx, address sender, string txType);
    event ClaimReward(uint256 warIndex, uint256 reward, uint256 balance, address sender, string txType);
    event SwitchHouse(uint256 warIndex, string from, string to, address sender, uint256 valueInDoTx);
    event openPriceFetched(uint256 warIndex);
    event closePriceFetched(uint256 warIndex);
    event StakeBurn(uint256 warIndex, uint256 burnValue, uint256 stakeValue);

    modifier onlyIfCurrentWarFinished(uint256 warIndex) {

        require(wars[warIndex].startTime.add(wars[warIndex].duration) <= now || warIndex == 0, "Current war not finished");
        _;
    }
    
    modifier onlyIfCurrentWarNotFinished(uint256 warIndex) {

        require(wars[warIndex].startTime.add(wars[warIndex].duration) > now, "Current war finished");
        _;
    }
    
    modifier onlyIfTicketsPurchasable(uint256 warIndex) {

        require(now.sub(wars[warIndex].startTime) < wars[warIndex].purchasePeriod,
        "Purchase tickets period ended");
        _;
    }
    
    modifier onlyIfPricesFetched(uint256 warIndex){

        require(wars[warIndex].firstHouse.openPrice != 0 && wars[warIndex].secondHouse.openPrice != 0, "Open prices not fetched");
        require(wars[warIndex].firstHouse.closePrice != 0 && wars[warIndex].secondHouse.closePrice != 0, "Close prices not fetched");
        _;
    }
    
    constructor(address dotxTokenAddress, address dotxLibAddr, bool setupAddressInLib) public {
        dotxToken = IDotTokenContract(dotxTokenAddress);
        
        setDoTxLib(dotxLibAddr, setupAddressInLib);
    }
    
    
    function startWar(string memory _firstHouseTicker, string memory _secondHouseTicker, string memory _firstHouseId, string memory _secondHouseId, 
    uint256 _duration, uint256 _ticketPrice, uint256 _purchasePeriod, uint256 _warFeesPercent, uint256 _warIndex) 
    public onlyOwner returns(bool) {

        require(_warIndex > dotxLib.getWarIndex(), "War index already exists");
        
        wars[_warIndex] = War(now, _duration, _ticketPrice, _purchasePeriod, 0, _warFeesPercent, multiplicator, burnPercentage, stakingPercentage, 
        House(stringToBytes32(_firstHouseTicker), stringToBytes32(_firstHouseId), 0, 0, 0),
        House(stringToBytes32(_secondHouseTicker), stringToBytes32(_secondHouseId), 0, 0, 0));
        
        emit WarStarted(_warIndex);
        
        fetchFirstDayPrices(_warIndex);
        
        return true;
    }
    
    function buyTickets(string memory _houseTicker, uint _numberOfTicket, uint256 warIndex) public onlyIfTicketsPurchasable(warIndex) {

        bytes32 houseTicker = stringToBytes32(_houseTicker);
        House storage userHouse = getHouseStg(houseTicker, warIndex);
        
        bytes32 userHouseTicker = wars[warIndex].users[msg.sender].houseTicker;
        require(userHouse.houseTicker == houseTicker && (userHouseTicker == houseTicker || userHouseTicker == 0), "You can not buy tickets for the other house");

        wars[warIndex].users[msg.sender].houseTicker = userHouse.houseTicker;

        wars[warIndex].users[msg.sender].ticketsBought = wars[warIndex].users[msg.sender].ticketsBought.add(_numberOfTicket);
        
        userHouse.ticketsBought = userHouse.ticketsBought.add(_numberOfTicket);
        
        uint256 valueInDoTx = wars[warIndex].ticketPrice.mul(_numberOfTicket);
        
        emit TicketBought(warIndex, _houseTicker, valueInDoTx, msg.sender, "BOUGHT");
        
        dotxToken.transferFrom(msg.sender, address(this), valueInDoTx);
    }
    
    function switchHouse(string memory _fromHouseTicker, string memory _toHouseTicker, uint256 warIndex) public onlyIfTicketsPurchasable(warIndex) {


        bytes32 fromHouseTicker = stringToBytes32(_fromHouseTicker);
        bytes32 toHouseTicker = stringToBytes32(_toHouseTicker);
        
        require(checkIfHouseInCompetition(toHouseTicker, warIndex) && fromHouseTicker != toHouseTicker, "House not in competition");
        require(wars[warIndex].users[msg.sender].houseTicker == fromHouseTicker, "User doesn't belong to fromHouse");
        
        House storage fromHouse = getHouseStg(fromHouseTicker, warIndex);
        House storage toHouse = getHouseStg(toHouseTicker, warIndex);
        
        wars[warIndex].users[msg.sender].houseTicker = toHouseTicker;
        
        uint256 ticketsBoughtByUser = wars[warIndex].users[msg.sender].ticketsBought;
        fromHouse.ticketsBought = fromHouse.ticketsBought.sub(ticketsBoughtByUser);
        
        toHouse.ticketsBought = toHouse.ticketsBought.add(ticketsBoughtByUser);
        
        uint256 feesToBePaid = getFeesForSwitchHouse(msg.sender, warIndex);
        totalFees = totalFees.add(feesToBePaid);
        
        emit SwitchHouse(warIndex, _fromHouseTicker, _toHouseTicker, msg.sender, feesToBePaid);
        
        dotxToken.transferFrom(msg.sender, address(this), feesToBePaid);
    }
    
    function claimRewardAndTickets(uint256 warIndex) public onlyIfCurrentWarFinished(warIndex) returns(bool) {

        require(wars[warIndex].users[msg.sender].rewardClaimed == false, "You already claimed your reward");
        
        require(wars[warIndex].users[msg.sender].ticketsBought > 0 && wars[warIndex].users[msg.sender].houseTicker == wars[warIndex].winningHouse, "User doesn't belong to winning house");
        
        wars[warIndex].users[msg.sender].rewardClaimed = true;
        
        uint256 reward = getCurrentReward(wars[warIndex].winningHouse, msg.sender, warIndex);
        uint256 balance = getUserDoTxInBalance(warIndex, msg.sender);
        
        dotxToken.transfer(msg.sender, reward.add(balance));
        
        emit ClaimReward(warIndex, reward, balance, msg.sender, "CLAIM");
    }

    
    
    function fetchFirstDayPrices(uint256 warIndex) public onlyOwner {

        require(wars[warIndex].firstHouse.openPrice == 0 && wars[warIndex].secondHouse.openPrice == 0, "Open prices already fetched");
        
        string memory firstHouse = bytes32ToString(wars[warIndex].firstHouse.houseTicker);
        string memory secondHouse = bytes32ToString(wars[warIndex].secondHouse.houseTicker);
        
        dotxLib.fetchFirstDayPrices(firstHouse, secondHouse, bytes32ToString(wars[warIndex].firstHouse.houseId), bytes32ToString(wars[warIndex].secondHouse.houseId), wars[warIndex].multiplicator, warIndex);
    }

    function fetchLastDayPrices(uint256 warIndex) public onlyOwner onlyIfCurrentWarFinished(warIndex) {

        require(wars[warIndex].firstHouse.closePrice == 0 && wars[warIndex].secondHouse.closePrice == 0, "Close prices already fetched");
        
        string memory firstHouse = bytes32ToString(wars[warIndex].firstHouse.houseTicker);
        string memory secondHouse = bytes32ToString(wars[warIndex].secondHouse.houseTicker);
        
        dotxLib.fetchLastDayPrices(firstHouse, secondHouse, bytes32ToString(wars[warIndex].firstHouse.houseId), bytes32ToString(wars[warIndex].secondHouse.houseId), wars[warIndex].multiplicator, warIndex);
    }
    
    function selectWinner(uint256 warIndex) public onlyOwner onlyIfCurrentWarFinished(warIndex) onlyIfPricesFetched(warIndex) {

        require(wars[warIndex].winningHouse == 0, "Winner already selected");
        
        int256 precision = int256(selecteWinnerPrecision);
        
        int256 firstHousePerf =  dotxLib.calculateHousePerf(int256(wars[warIndex].firstHouse.openPrice), int256(wars[warIndex].firstHouse.closePrice), precision);
        int256 secondHousePerf = dotxLib.calculateHousePerf(int256(wars[warIndex].secondHouse.openPrice), int256(wars[warIndex].secondHouse.closePrice), precision);
        
        wars[warIndex].winningHouse = (firstHousePerf > secondHousePerf ? wars[warIndex].firstHouse : wars[warIndex].secondHouse).houseTicker;
        House memory losingHouse = (firstHousePerf > secondHousePerf ? wars[warIndex].secondHouse : wars[warIndex].firstHouse);
        
        uint256 burnValue = calculateBurnStaking(losingHouse, true, warIndex);
        dotxToken.transfer(BURN_ADDRESS, burnValue);
        
        uint256 stakingValue = calculateBurnStaking(losingHouse, true, warIndex);
        dotxToken.transfer(stakingAddress, stakingValue);
        
        emit StakeBurn(warIndex, burnValue, stakingValue);
    }

    
    
    function firstHouseOpen(uint256 _price, uint256 warIndex) external onlyDoTxLib {

        wars[warIndex].firstHouse.openPrice = _price;
        openPriceEvent(warIndex);
    }
    function secondHouseOpen(uint256 _price, uint256 warIndex) external onlyDoTxLib {

        wars[warIndex].secondHouse.openPrice = _price;
        openPriceEvent(warIndex);
    }
    function firstHouseClose(uint256 _price, uint256 warIndex) external onlyDoTxLib {

        wars[warIndex].firstHouse.closePrice = _price;
        closePriceEvent(warIndex);
    }
    function secondHouseClose(uint256 _price, uint256 warIndex) external onlyDoTxLib {

        wars[warIndex].secondHouse.closePrice = _price;
        closePriceEvent(warIndex);
    }
    function openPriceEvent(uint256 warIndex) private {

        if(wars[warIndex].firstHouse.openPrice != 0 && wars[warIndex].secondHouse.openPrice != 0){
            emit openPriceFetched(warIndex);
        }
    }
    function closePriceEvent(uint256 warIndex) private {

        if(wars[warIndex].firstHouse.closePrice != 0 && wars[warIndex].secondHouse.closePrice != 0){
            emit closePriceFetched(warIndex);
        }
    }
    
    
    function getUserDoTxInBalance(uint256 _warIndex, address userAddress) public view returns(uint256){

        return wars[_warIndex].users[userAddress].ticketsBought.mul(wars[_warIndex].ticketPrice);
    }
    
    
    function getFeesForSwitchHouse(address userAddress, uint256 warIndex) public view returns(uint256){

        return (getUserDoTxInBalance(warIndex, userAddress).mul(wars[warIndex].warFeesPercent)).div(100);
    }
    
    function getUser(uint256 _warIndex, address userAddress) public view returns(User memory){

        return wars[_warIndex].users[userAddress];
    }
    
    function getHouse(uint256 _warIndex, string memory houseTicker) public view returns(House memory){

        bytes32 ticker = stringToBytes32(houseTicker);
        return wars[_warIndex].firstHouse.houseTicker == ticker ? wars[_warIndex].firstHouse : wars[_warIndex].secondHouse;
    }
    function getBurnStake(uint256 warIndex) public view returns(BurnStake memory){

        return BurnStake(calculateBurnStaking(wars[warIndex].firstHouse, true, warIndex), calculateBurnStaking(wars[warIndex].firstHouse, false, warIndex),
        calculateBurnStaking(wars[warIndex].secondHouse, true, warIndex), calculateBurnStaking(wars[warIndex].secondHouse, false, warIndex));
    }
    
    function getWarsHouses(uint256 min, uint256 max) public view returns (WarHouses[20] memory){

        WarHouses[20] memory houses;
        uint256 i = min;
        uint256 index = 0;
        while(index < 20 && i <= (max - min) + 1){
            houses[index] = (WarHouses(i, wars[i].firstHouse.houseTicker, wars[i].secondHouse.houseTicker, wars[i].startTime, wars[i].duration));
            i++;
            index++;
        }
        return houses;
    }
    
    function setSelectWinnerPrecision(uint256 _precision) public onlyOwner{

        selecteWinnerPrecision = _precision;
    }

    function setStakingBurnPercentageWar(uint256 _burnPercentage, uint256 _stakingPercentage, uint256 warIndex) public onlyOwner{

        wars[warIndex].burnPercentage = _burnPercentage;
        wars[warIndex].stakingPercentage = _stakingPercentage;
    }
    
    function setStakingBurnPercentage(uint256 _burnPercentage, uint256 _stakingPercentage) public onlyOwner{

        burnPercentage = _burnPercentage;
        stakingPercentage = _stakingPercentage;
    }
    
    function setMultiplicatorWar(int256 _multiplicator, uint256 warIndex) public onlyOwner{

        wars[warIndex].multiplicator = _multiplicator;
    }
    
    function setMultiplicator(int256 _multiplicator) public onlyOwner{

        multiplicator = _multiplicator;
    }
    
    function withdrawFees() public onlyOwner {

        dotxToken.transfer(owner(), totalFees);
        
        totalFees = 0;
    }
    
    function setDoTxLib(address dotxLibAddr, bool setupAddressInLib) public onlyOwner {

        dotxLibAddress = dotxLibAddr;
        dotxLib = IDoTxLib(dotxLibAddress);
        if(setupAddressInLib){
            dotxLib.setDoTxGame(address(this));
        }
    }
    
    function setStakingAddress(address stakingAdr) public onlyOwner {

        stakingAddress = stakingAdr;
    }

    
    function getHouseStg(bytes32 ticker, uint256 warIndex) private view returns(House storage){

        return wars[warIndex].firstHouse.houseTicker == ticker ? wars[warIndex].firstHouse : wars[warIndex].secondHouse;
    }
    
    function checkIfHouseInCompetition(bytes32 _houseTicker, uint256 warIndex) private view returns(bool){

        return wars[warIndex].firstHouse.houseTicker == _houseTicker || wars[warIndex].secondHouse.houseTicker == _houseTicker;
    }
    
    function getCurrentRewardString(string memory _winningHouse, address userAddress, uint256 warIndex) public view returns(uint256){

        bytes32 winningHouseTicker = stringToBytes32(_winningHouse);
        return getCurrentReward(winningHouseTicker, userAddress, warIndex);
    } 
    
    function getCurrentReward(bytes32 _winningHouse, address userAddress, uint256 warIndex) public view returns(uint256){

        House memory losingHouse = wars[warIndex].firstHouse.houseTicker == _winningHouse ? wars[warIndex].secondHouse : wars[warIndex].firstHouse;
        
        uint256 totalDoTxWinningHouse = getHouseStg(_winningHouse, warIndex).ticketsBought.mul(wars[warIndex].ticketPrice);
        uint256 totalDoTxLosingHouse = losingHouse.ticketsBought.mul(wars[warIndex].ticketPrice).sub(calculateBurnStaking(losingHouse, true, warIndex)).sub(calculateBurnStaking(losingHouse, false, warIndex));
        
        return dotxLib.calculateReward(getUserDoTxInBalance(warIndex, userAddress), totalDoTxWinningHouse, totalDoTxLosingHouse);
    }
    
    function calculateBurnStaking(House memory house, bool isBurn, uint256 warIndex) public view returns(uint256){

        uint256 ticketsBoughtValueDoTx = house.ticketsBought.mul(wars[warIndex].ticketPrice);
        uint256 percentage =  isBurn ? wars[warIndex].burnPercentage : wars[warIndex].stakingPercentage;
        return dotxLib.calculatePercentage(ticketsBoughtValueDoTx, percentage, selecteWinnerPrecision);
    }
    
    function stringToBytes32(string memory source) public pure returns (bytes32 result) {

        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }
    
        assembly {
            result := mload(add(source, 32))
        }
    }
    
    function bytes32ToString(bytes32 x) public pure returns (string memory) {

        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (uint256 j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }
}