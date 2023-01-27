pragma solidity >= 0.5.3 < 0.6.0;


library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) { return 0; }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0);
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);
        uint256 c = a - b;
        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a);
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);
        return a % b;
    }
}
pragma solidity >=0.5.3 < 0.6.0;


library TimestampMonthConv {

    uint constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint constant SECONDS_PER_HOUR = 60 * 60;
    uint constant SECONDS_PER_MINUTE = 60;
    int constant OFFSET19700101 = 2440588;
    
    function _daysFromDate(uint year, uint month, uint day) internal pure returns (uint _days) {

        require(year >= 1970);
        int _year = int(year);
        int _month = int(month);
        int _day = int(day);

        int __days = _day
          - 32075
          + 1461 * (_year + 4800 + (_month - 14) / 12) / 4
          + 367 * (_month - 2 - (_month - 14) / 12 * 12) / 12
          - 3 * ((_year + 4900 + (_month - 14) / 12) / 100) / 4
          - OFFSET19700101;

        _days = uint(__days);
    }
    
    function _daysToDate(uint _days) internal pure returns (uint year, uint month, uint day) {

        int __days = int(_days);
        
        int L = __days + 68569 + OFFSET19700101;
        int N = 4 * L / 146097;
        L = L - (146097 * N + 3) / 4;
        int _year = 4000 * (L + 1) / 1461001;
        L = L - 1461 * _year / 4 + 31;
        int _month = 80 * L / 2447;
        int _day = L - 2447 * _month / 80;
        L = _month / 11;
        _month = _month + 2 - 12 * L;
        _year = 100 * (N - 49) + _year + L;

        year = uint(_year);
        month = uint(_month);
        day = uint(_day);
    }
    
    function _getDaysInMonth(uint year, uint month) internal pure returns (uint daysInMonth) {

        if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
            daysInMonth = 31;
        } else if (month != 2) {
            daysInMonth = 30;
        } else {
            daysInMonth = _isLeapYear(year) ? 29 : 28;
        }
    }
    
    function _isLeapYear(uint year) internal pure returns (bool leapYear) {

        leapYear = ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0);
    }
    
    function addMonths(uint timestamp, uint _months) internal pure returns (uint newTimestamp) {

        uint year;
        uint month;
        uint day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        month += _months;
        year += (month - 1) / 12;
        month = (month - 1) % 12 + 1;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp >= timestamp);
    }
    
    function diffMonths(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _months) {

        require(fromTimestamp <= toTimestamp);
        uint fromYear;
        uint fromMonth;
        uint fromDay;
        uint toYear;
        uint toMonth;
        uint toDay;
        (fromYear, fromMonth, fromDay) = _daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (toYear, toMonth, toDay) = _daysToDate(toTimestamp / SECONDS_PER_DAY);
        _months = toYear * 12 + toMonth - fromYear * 12 - fromMonth;
    }
}
pragma solidity >= 0.5.3 < 0.6.0;

interface ERC20Interface {

    function balanceOf(address _who) external view returns (uint256);

    function transfer(address _to, uint256 _value) external returns (bool);

    function allowance(address _owner, address _spender) external view returns (uint256);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);

    function approve(address _spender, uint256 _value) external returns (bool);

    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}pragma solidity >= 0.5.3 < 0.6.0;



contract Ownership {

    address private _owner;
    
    event OwnerOwnershipTransferred(address indexed prevOwner, address indexed newOwner);
    
    function owner() public view returns (address){

        return _owner;
    }
    
    function isOwner() public view returns (bool){

        return (msg.sender == _owner);
    }
    
    modifier onlyOwner() {

        require(isOwner(), "Ownership: the caller is not the owner address");
        _;
    }
    
    function transferOwnerOwnership(address newOwner) public onlyOwner {

        _transferOwnerOwnership(newOwner);
    }
    

    function _transferOwnerOwnership(address newOwner) internal {

        require (newOwner != address(0), "Ownable: new owner is zero address");
        emit OwnerOwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    
    function _setupOwnership(address own) internal {

        require (own != address(0), "Ownable: owner is zero address");
        _owner = own;
        
        emit OwnerOwnershipTransferred(address(0), own);
    }
}

contract LockupCampaign is Ownership {

    using SafeMath for uint256;
    using TimestampMonthConv for uint;
    
    enum LockStatus {NULL, LOCKED, UNLOCKED, RELEASED}
    
    struct WowbitInfo {
        uint256 totalLocked;
        uint256 totalExtraGiven;
        uint256 currentLocked;
        uint256 incentive3;
        uint256 incentive6;
        uint256 incentive9;
    }
    
    struct ParticipatingUsers {
        uint256 amountWWB;
        uint256 month;
        uint256 lockEnd;
        bool incCalculated;
        LockStatus status;
    }
    
    struct UsersExtraTokens {
        address[] exTokenAddress;
        uint8[] exTokenDecimals;
        uint256[] exTokenAmount;
    }
    
    WowbitInfo public wwbInfo;
    address public wwbAddress;
    address[] public tokenAddresses;
    uint8[] public tokenDecimals;
    bool public firstSet = false;
    mapping (address => ParticipatingUsers) internal userList;
    mapping (address => UsersExtraTokens) internal extraList;
    
    event PreRegister(address indexed _userAddress);
    event ConfirmRegister(address indexed _userAddress, uint256 startLock, uint256 endLock);
    event TokenLocked(address indexed _userAddress, uint256 amount);
    event TokenUnlocked(address indexed _userAddress, uint256 timestamp);
    event TokenReleased(address indexed _userAddress, uint256 amount);
    event RegisterEtcToken(address indexed _token);
    event RemoveEtcToken(address indexed _token);
    event EtcTokenRequested(address indexed _userAddress, address indexed _tokenAddress);
    event EtcTokenReleased(address indexed _userAddress, address indexed _tokenAddress, uint256 _amountIncentives);
    
    constructor(address owner, address WwbTokenAddress) public{
        _setupOwnership(owner);
        wwbAddress = WwbTokenAddress;
    }
    
    
    function tokenFallback(address _from, uint _value, bytes memory _data) public {

        string memory str = string(_data);
        if(_from == owner()){
            require((keccak256(abi.encodePacked((str))) == keccak256(abi.encodePacked(("supply")))),
                    "LockupCampaign: bytes command not authorized");
        } else if(_from != owner()){
            require(userList[_from].lockEnd == 0, "LockupCampaign: user not registered");
            _confirmRegister(_from, _value);
            emit TokenLocked(_from, _value);
        } else {
            revert("LockupCampaign: not authorized");
        }
    }
    
    
    function depositApprovedERC20(address erc20TokenAddress, uint256 amountToken) public onlyOwner {

        ERC20Interface(erc20TokenAddress).transferFrom(msg.sender, address(this), amountToken);
    }
    
    
    function setWwbRate(uint256 rate_3month, uint256 rate_6month, uint256 rate_9month) public onlyOwner {

        _setWwbRate(rate_3month, rate_6month, rate_9month);
    }
    
    function wwbTokenBalance() public view returns (uint256){

        return ERC20Interface(wwbAddress).balanceOf(address(this));
    }
    
    function returnAllWWBTokens() public onlyOwner {

        ERC20Interface(wwbAddress).transfer(owner(), ERC20Interface(wwbAddress).balanceOf(address(this)));
    }

    function getWwbInfo() public view onlyOwner returns (uint256, uint256, uint256, uint256, uint256, uint256){

        return (wwbInfo.totalLocked, wwbInfo.totalExtraGiven, wwbInfo.currentLocked, wwbInfo.incentive3, wwbInfo.incentive6, wwbInfo.incentive9);
    }
    
    
    function isParticipatingTokens(address tokenAddress) public view returns(bool){

        for(uint i = 0; i < tokenAddresses.length; i++){
            if(tokenAddresses[i] == tokenAddress) {
                return true;
            }
        }
    }

    function participatingTokenBalance(address tokenAddress) public view returns (uint256){

        return ERC20Interface(tokenAddress).balanceOf(address(this));
    }
    
    function addParticipatingToken(address tokenAddress, uint8 decimals) public onlyOwner {

        require(!isParticipatingTokens(tokenAddress), "LockupCampaign: token data exists");
        require(tokenAddress != address(0), "LockupCampaign: token contract address is zero");
        require(decimals != 0, "LockupCampaign: token contract decimals is zero");
        require(decimals <= 18, "LockupCampaign: token contract decimals invalid");
        tokenAddresses.push(tokenAddress);
        tokenDecimals.push(decimals);

        emit RegisterEtcToken(tokenAddress);
    }
    
    function removeParticipatingToken(address tokenAddress) public onlyOwner {

        for (uint i = 0; i < tokenAddresses.length; i++){
            if(tokenAddresses[i] == tokenAddress){
                tokenAddresses[i] = tokenAddresses[i+1];
                tokenDecimals[i] = tokenDecimals[i+1];
            }
        }
        tokenAddresses.length--;
        tokenDecimals.length--;
        emit RemoveEtcToken(tokenAddress);
    }
    
    function returnAllOtherTokens(address tokenAddress) public onlyOwner {

        ERC20Interface(tokenAddress).transfer(owner(), ERC20Interface(tokenAddress).balanceOf(address(this)));
    }
    

    function isPreParticipant(address userAddress) public view returns (bool) {

        return (userList[userAddress].month != 0);
    }

    function isRegisteredParticipant(address userAddress) public view returns (bool){

        return (userList[userAddress].lockEnd != 0);
    }

    function getParticipantLockAmount(address userAddress) public view returns (uint256){

        return userList[userAddress].amountWWB;
    }

    function getParticipantInfo(address userAddress) public view returns (uint256, uint256, uint256, bool, bool){

        return(userList[userAddress].amountWWB, userList[userAddress].month,
               userList[userAddress].lockEnd, userList[userAddress].incCalculated,
               _getLockStatus(userList[userAddress].status)
        );
    }

    function isParticipantExtraTokens(address user) public view returns (bool){

        return (extraList[user].exTokenAddress.length != 0);
    }

    function getParticipantExtraTokens(address user) public view returns (address[] memory, uint256[] memory){

        return (extraList[user].exTokenAddress, extraList[user].exTokenAmount);
    }
    
    function updateParticipantInfo(address userAddress) public {

        _incentiveTimeCheck(userAddress);
    }
    
    function preRegisterParticipant(address userAddr, uint256 months) public returns (bool) {

        require(firstSet == true, "LockupCampaign: rates data for WWB token not yet set for first time");
        require(userAddr != address(0), "LockupCampaign: user address is zero");
        require(months > 0, "LockupCampaign: months to lock is zero");
        
        _registParticipant(userAddr, months);
        return true;
    }
    
    function requestExtraToken(address user, address token) public {

        require(isRegisteredParticipant(user), "LockupCampaign: User not registered.");
        require(tokenAddresses.length > 0, "LockupCampaign: no participating token data is entered yet");
        require(userList[user].month >= 6, "LockupCampaign: user must lock more than 6 months to request extra token");
        
        _requestExtraTokens(user, token);
    }
    
    function releaseParticipantTokens(address userAddr) public returns (bool){

        require(isRegisteredParticipant(userAddr), "LockupCampaign: User not registered.");
        require(_incentiveTimeCheck(userAddr));
        require(userList[userAddr].status != LockStatus.LOCKED, "LockupCampaign: Token lock period still ongoing.");
        require(userList[userAddr].status != LockStatus.RELEASED, "LockupCampaign: Token already released.");
        
        _releaseWwbTokens(userAddr);
        
        if(extraList[userAddr].exTokenAddress.length != 0){
            _releaseOtherTokens(userAddr);
        }
        
        return true;
    }
    
    
    function convertStrToBytes(string memory str) public pure returns (bytes memory){

        return bytes(str);
    }
    
    
    function _setWwbRate(uint256 i3, uint256 i6, uint256 i9) internal {

        wwbInfo.incentive3 = i3;
        wwbInfo.incentive6 = i6;
        wwbInfo.incentive9 = i9;
        firstSet = true;
    }
    
    function _registParticipant(address addr, uint256 month) internal {

        ParticipatingUsers memory user = ParticipatingUsers(0, month, 0, false, LockStatus.NULL);
        userList[addr] = user;
        
        emit PreRegister(addr);
    }
    
    function _confirmRegister(address addr, uint256 val) internal {

        uint256 finalDate = now.addMonths(userList[addr].month);
        userList[addr].amountWWB = val;
        userList[addr].lockEnd = finalDate;
        userList[addr].status = LockStatus.LOCKED;
        
        wwbInfo.totalLocked = wwbInfo.totalLocked.add(val);
        wwbInfo.currentLocked = wwbInfo.currentLocked.add(val);
        
        emit ConfirmRegister(addr, now, finalDate);
    }
    
    function _getLockStatus(LockStatus stat) internal pure returns (bool) {

        if (stat == LockStatus.LOCKED || stat == LockStatus.NULL){
            return false;
        } else {
            return true;
        }
    }
    
    function _incentiveTimeCheck(address user) internal returns (bool) {

        if (now >= userList[user].lockEnd){
            if (userList[user].status == LockStatus.LOCKED && userList[user].incCalculated != true) {
                uint256 val = _calcIncentives(user);
                if (extraList[user].exTokenAddress.length != 0) { _calcExtra(user, val); }
                userList[user].status = LockStatus.UNLOCKED;
                userList[user].incCalculated = true;
                
                emit TokenUnlocked(user, now);
            }
        }
        return true;
    }
    
    function _calcIncentives(address user) internal returns (uint256){

        uint256 m = userList[user].month;
        uint256 added;
        if (m >= 3 && m < 6){
            added = _calcAdd(userList[user].amountWWB, wwbInfo.incentive3);
        } else if (m >= 6 && m < 12){
            added = _calcAdd(userList[user].amountWWB, wwbInfo.incentive6);
        } else if (m >= 12) {
            added = _calcAdd(userList[user].amountWWB, wwbInfo.incentive9);
        }
        userList[user].amountWWB = userList[user].amountWWB.add(added);
        wwbInfo.totalExtraGiven = wwbInfo.totalExtraGiven.add(added);
        wwbInfo.currentLocked = wwbInfo.currentLocked.add(added);
        
        return added;
    }
    
    function _calcExtra(address user, uint256 added) internal {

        for (uint i = 0; i < extraList[user].exTokenAddress.length; i++){
            uint8 dec = extraList[user].exTokenDecimals[i];
            uint256 total;
                
            if (dec > 6) { total = added.mul((10 ** uint256(dec - 6))); }
            else if (dec < 6) { total = added.div((10 ** uint256(6 - dec))); }
                
            extraList[user].exTokenAmount.push(total);
        }
    }

    function _calcAdd(uint256 total, uint256 rate) internal pure returns (uint256){

        uint256 r = total.mul(rate);
        r = r.div(10000);
        return r;
    }
    
    function _requestExtraTokens(address user, address token) internal {

        require(isParticipatingTokens(token), "LockupCampaign: token address is not participating token");
        
        for (uint i = 0; i < tokenAddresses.length; i++){
            if(token == tokenAddresses[i]){
                extraList[user].exTokenAddress.push(token);
                extraList[user].exTokenDecimals.push(tokenDecimals[i]);
                break;
            }
        }

        emit EtcTokenRequested(user, token);
    }
    
    function _releaseWwbTokens(address user) internal {

        uint256 amt = userList[user].amountWWB;
        ERC20Interface(wwbAddress).transfer(user, amt);
        wwbInfo.currentLocked = wwbInfo.currentLocked.sub(amt);
        userList[user].status = LockStatus.RELEASED;

        emit TokenReleased(user, amt);
    }
    
    function _releaseOtherTokens(address user) internal {

        for (uint i = 0; i < extraList[user].exTokenAddress.length; i++){
            address addr =  extraList[user].exTokenAddress[i];
            uint amt = extraList[user].exTokenAmount[i];
            
            ERC20Interface(addr).transfer(user, amt);
            
            emit EtcTokenReleased(user, addr, amt);
        }
    }
}