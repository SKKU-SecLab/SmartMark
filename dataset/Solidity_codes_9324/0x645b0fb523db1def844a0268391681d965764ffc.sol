

pragma solidity ^0.5.0;

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


pragma solidity =0.5.16;

contract Ownable {

    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


pragma solidity =0.5.16;


contract Halt is Ownable {

    
    bool private halted = false; 
    
    modifier notHalted() {

        require(!halted,"This contract is halted");
        _;
    }

    modifier isHalted() {

        require(halted,"This contract is not halted");
        _;
    }
    
    function setHalt(bool halt) 
        public 
        onlyOwner
    {

        halted = halt;
    }
}


pragma solidity >=0.5.16;
library whiteListUint32 {


    function addWhiteListUint32(uint32[] storage whiteList,uint32 temp) internal{

        if (!isEligibleUint32(whiteList,temp)){
            whiteList.push(temp);
        }
    }
    function removeWhiteListUint32(uint32[] storage whiteList,uint32 temp)internal returns (bool) {

        uint256 len = whiteList.length;
        uint256 i=0;
        for (;i<len;i++){
            if (whiteList[i] == temp)
                break;
        }
        if (i<len){
            if (i!=len-1) {
                whiteList[i] = whiteList[len-1];
            }
            whiteList.length--;
            return true;
        }
        return false;
    }
    function isEligibleUint32(uint32[] memory whiteList,uint32 temp) internal pure returns (bool){

        uint256 len = whiteList.length;
        for (uint256 i=0;i<len;i++){
            if (whiteList[i] == temp)
                return true;
        }
        return false;
    }
    function _getEligibleIndexUint32(uint32[] memory whiteList,uint32 temp) internal pure returns (uint256){

        uint256 len = whiteList.length;
        uint256 i=0;
        for (;i<len;i++){
            if (whiteList[i] == temp)
                break;
        }
        return i;
    }
}
library whiteListUint256 {

    function addWhiteListUint256(uint256[] storage whiteList,uint256 temp) internal{

        if (!isEligibleUint256(whiteList,temp)){
            whiteList.push(temp);
        }
    }
    function removeWhiteListUint256(uint256[] storage whiteList,uint256 temp)internal returns (bool) {

        uint256 len = whiteList.length;
        uint256 i=0;
        for (;i<len;i++){
            if (whiteList[i] == temp)
                break;
        }
        if (i<len){
            if (i!=len-1) {
                whiteList[i] = whiteList[len-1];
            }
            whiteList.length--;
            return true;
        }
        return false;
    }
    function isEligibleUint256(uint256[] memory whiteList,uint256 temp) internal pure returns (bool){

        uint256 len = whiteList.length;
        for (uint256 i=0;i<len;i++){
            if (whiteList[i] == temp)
                return true;
        }
        return false;
    }
    function _getEligibleIndexUint256(uint256[] memory whiteList,uint256 temp) internal pure returns (uint256){

        uint256 len = whiteList.length;
        uint256 i=0;
        for (;i<len;i++){
            if (whiteList[i] == temp)
                break;
        }
        return i;
    }
}
library whiteListAddress {

    function addWhiteListAddress(address[] storage whiteList,address temp) internal{

        if (!isEligibleAddress(whiteList,temp)){
            whiteList.push(temp);
        }
    }
    function removeWhiteListAddress(address[] storage whiteList,address temp)internal returns (bool) {

        uint256 len = whiteList.length;
        uint256 i=0;
        for (;i<len;i++){
            if (whiteList[i] == temp)
                break;
        }
        if (i<len){
            if (i!=len-1) {
                whiteList[i] = whiteList[len-1];
            }
            whiteList.length--;
            return true;
        }
        return false;
    }
    function isEligibleAddress(address[] memory whiteList,address temp) internal pure returns (bool){

        uint256 len = whiteList.length;
        for (uint256 i=0;i<len;i++){
            if (whiteList[i] == temp)
                return true;
        }
        return false;
    }
    function _getEligibleIndexAddress(address[] memory whiteList,address temp) internal pure returns (uint256){

        uint256 len = whiteList.length;
        uint256 i=0;
        for (;i<len;i++){
            if (whiteList[i] == temp)
                break;
        }
        return i;
    }
}


pragma solidity =0.5.16;


contract Operator is Ownable {

    mapping(uint256=>address) private _operators;
    modifier onlyOperator(uint256 index) {

        require(_operators[index] == msg.sender,"Operator: caller is not the eligible Operator");
        _;
    }
    function setOperator(uint256 index,address addAddress)public onlyOwner{

        _operators[index] = addAddress;
    }
    function getOperator(uint256 index)public view returns (address) {

        return _operators[index];
    }
}


pragma solidity >=0.5.16;


contract AddressWhiteList is Halt {


    using whiteListAddress for address[];
    address[] internal whiteList;
    function addWhiteList(address addAddress)public onlyOwner{

        whiteList.addWhiteListAddress(addAddress);
    }
    function removeWhiteList(address removeAddress)public onlyOwner returns (bool){

        return whiteList.removeWhiteListAddress(removeAddress);
    }
    function getWhiteList()public view returns (address[] memory){

        return whiteList;
    }
    function isEligibleAddress(address tmpAddress) public view returns (bool){

        return whiteList.isEligibleAddress(tmpAddress);
    }
}


pragma solidity =0.5.16;
contract ReentrancyGuard {


  bool private reentrancyLock = false;
  modifier nonReentrant() {

    require(!reentrancyLock);
    reentrancyLock = true;
    _;
    reentrancyLock = false;
  }

}


pragma solidity =0.5.16;
contract initializable {


    bool private initialized;

    bool private initializing;

    modifier initializer() {

        require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

        bool wasInitializing = initializing;
        initializing = true;
        initialized = true;

        _;

        initializing = wasInitializing;
    }

    function isConstructor() private view returns (bool) {

        uint256 cs;
        assembly { cs := extcodesize(address) }
        return cs == 0;
    }
}


pragma solidity =0.5.16;





contract fixedMinePoolData is initializable,Operator,Halt,AddressWhiteList,ReentrancyGuard {

    uint256 constant calDecimals = 1e18;

    uint256 internal _startTime;
    uint256 internal constant _period = 30 days;
    uint256 internal _flexibleExpired;

    uint256 constant internal _maxPeriod = 3;
    uint256 constant internal _maxLoop = 120;
    uint256 constant internal _FPTARatio = 1000;
    uint256 constant internal _FPTBRatio = 1000;
    uint256 constant internal _RepeatRatio = 20000;
    uint256 constant internal periodWeight = 1000;
    uint256 constant internal baseWeight = 5000;

    address internal _FPTA;
    address internal _FPTB;

    struct userInfo {
        uint256 _FPTABalance;
        uint256 _FPTBBalance;
        uint256 maxPeriodID;
        uint256 lockedExpired;
        uint256 distribution;
        mapping(address=>uint256) minerBalances;
        mapping(address=>uint256) minerOrigins;
        mapping(address=>uint256) settlePeriod;
    }
    struct tokenMineInfo {
        uint256 mineAmount;
        uint256 mineInterval;
        uint256 startPeriod;
        uint256 latestSettleTime;
        uint256 totalMinedCoin;
        uint256 minedNetWorth;
        mapping(uint256=>uint256) periodMinedNetWorth;
    }

    mapping(address=>userInfo) internal userInfoMap;
    mapping(address=>tokenMineInfo) internal mineInfoMap;
    mapping(uint256=>uint256) internal weightDistributionMap;
    uint256 internal totalDistribution;

    struct premiumDistribution {
        uint256 totalPremiumDistribution;
        mapping(address=>uint256) userPremiumDistribution;

    }
    mapping(uint256=>premiumDistribution) internal premiumDistributionMap;
    struct premiumInfo {
        mapping(address=>uint256) lastPremiumIndex;
        mapping(address=>uint256) premiumBalance;
        uint64[] distributedPeriod;
        uint256 totalPremium;
        mapping(uint256=>uint256) periodPremium;
    }
    mapping(address=>premiumInfo) internal premiumMap;
    address[] internal premiumCoinList;

    event StakeFPTA(address indexed account,uint256 amount);
    event LockAirDrop(address indexed from,address indexed recieptor,uint256 amount);
    event StakeFPTB(address indexed account,uint256 amount,uint256 lockedPeriod);
    event UnstakeFPTA(address indexed account,uint256 amount);
    event UnstakeFPTB(address indexed account,uint256 amount);
    event ChangeLockedPeriod(address indexed account,uint256 lockedPeriod);
    event DistributePremium(address indexed account,address indexed premiumCoin,uint256 indexed periodID,uint256 amount);
    event RedeemPremium(address indexed account,address indexed premiumCoin,uint256 amount);

    event RedeemMineCoin(address indexed account, address indexed mineCoin, uint256 value);

}


pragma solidity =0.5.16;
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


pragma solidity =0.5.16;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call.value(value )(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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


pragma solidity =0.5.16;




library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


pragma solidity =0.5.16;




contract fixedMinePool is fixedMinePoolData {

    using SafeMath for uint256;
    constructor(address FPTA,address FPTB,uint256 startTime)public{
        _FPTA = FPTA;
        _FPTB = FPTB;
        _startTime = startTime;
        initialize();
    }
    function()external payable{

    }
    function update()public onlyOwner{

    }
    function initialize() initializer public {

        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
        _flexibleExpired = 7 days;
    }
    function setAddresses(address FPTA,address FPTB,uint256 startTime) public onlyOwner {

        _FPTA = FPTA;
        _FPTB = FPTB;
        _startTime = startTime;
    }
    function getFPTAAddress()public view returns (address) {

        return _FPTA;
    }
    function getFPTBAddress()public view returns (address) {

        return _FPTB;
    }
    function getStartTime()public view returns (uint256) {

        return _startTime;
    }
    function getCurrentPeriodID()public view returns (uint256) {

        return getPeriodIndex(currentTime());
    }
    function getUserFPTABalance(address account)public view returns (uint256) {

        return userInfoMap[account]._FPTABalance;
    }
    function getUserFPTBBalance(address account)public view returns (uint256) {

        return userInfoMap[account]._FPTBBalance;
    }
    function getUserMaxPeriodId(address account)public view returns (uint256) {

        return userInfoMap[account].maxPeriodID;
    }
    function getUserExpired(address account)public view returns (uint256) {

        return userInfoMap[account].lockedExpired;
    }
    function getMineWeightRatio()public view returns (uint256) {

        if(totalDistribution > 0) {
            return getweightDistribution(getPeriodIndex(currentTime()))*1000/totalDistribution;
        }else{
            return 1000;
        }
    }
    function getTotalDistribution() public view returns (uint256){

        return totalDistribution;
    }
    function redeemOut(address mineCoin,uint256 amount)public onlyOwner{

        _redeem(msg.sender,mineCoin,amount);
    }
    function _redeem(address payable recieptor,address mineCoin,uint256 amount) internal{

        if (mineCoin == address(0)){
            recieptor.transfer(amount);
        }else{
            IERC20 token = IERC20(mineCoin);
            uint256 preBalance = token.balanceOf(address(this));
            SafeERC20.safeTransfer(token,recieptor,amount);
            uint256 afterBalance = token.balanceOf(address(this));
            require(preBalance - afterBalance == amount,"settlement token transfer error!");
        }
    }
    function getTotalMined(address mineCoin)public view returns(uint256){

        return mineInfoMap[mineCoin].totalMinedCoin.add(_getLatestMined(mineCoin));
    }
    function getMineInfo(address mineCoin)public view returns(uint256,uint256){

        return (mineInfoMap[mineCoin].mineAmount,mineInfoMap[mineCoin].mineInterval);
    }
    function getMinerBalance(address account,address mineCoin)public view returns(uint256){

        return userInfoMap[account].minerBalances[mineCoin].add(_getUserLatestMined(mineCoin,account));
    }
    function setMineCoinInfo(address mineCoin,uint256 _mineAmount,uint256 _mineInterval)public onlyOwner {

        require(_mineAmount<1e30,"input mine amount is too large");
        require(_mineInterval>0,"input mine Interval must larger than zero");
        _mineSettlement(mineCoin);
        mineInfoMap[mineCoin].mineAmount = _mineAmount;
        mineInfoMap[mineCoin].mineInterval = _mineInterval;
        if (mineInfoMap[mineCoin].startPeriod == 0){
            mineInfoMap[mineCoin].startPeriod = getPeriodIndex(currentTime());
        }
        addWhiteList(mineCoin);
    }

    function redeemMinerCoin(address mineCoin,uint256 amount)public nonReentrant notHalted {

        _mineSettlement(mineCoin);
        _settleUserMine(mineCoin,msg.sender);
        _redeemMineCoin(mineCoin,msg.sender,amount);
    }
    function _redeemMineCoin(address mineCoin,address payable recieptor,uint256 amount) internal {

        require (amount > 0,"input amount must more than zero!");
        userInfoMap[recieptor].minerBalances[mineCoin] = 
            userInfoMap[recieptor].minerBalances[mineCoin].sub(amount);
        _redeem(recieptor,mineCoin,amount);
        emit RedeemMineCoin(recieptor,mineCoin,amount);
    }

    function _mineSettlementAll()internal{

        uint256 addrLen = whiteList.length;
        for(uint256 i=0;i<addrLen;i++){
            _mineSettlement(whiteList[i]);
        }
    }
    function getPeriodIndex(uint256 _time) public view returns (uint256) {

        if (_time<_startTime){
            return 0;
        }
        return _time.sub(_startTime).div(_period)+1;
    }
    function getPeriodFinishTime(uint256 periodID)public view returns (uint256) {

        return periodID.mul(_period).add(_startTime);
    }
    function getCurrentTotalAPY(address mineCoin)public view returns (uint256) {

        if (totalDistribution == 0 || mineInfoMap[mineCoin].mineInterval == 0){
            return 0;
        }
        uint256 baseMine = mineInfoMap[mineCoin].mineAmount.mul(365 days)/mineInfoMap[mineCoin].mineInterval;
        return baseMine.mul(getweightDistribution(getPeriodIndex(currentTime())))/totalDistribution;
    }
    function getUserCurrentAPY(address account,address mineCoin)public view returns (uint256) {

        if (totalDistribution == 0 || mineInfoMap[mineCoin].mineInterval == 0){
            return 0;
        }
        uint256 baseMine = mineInfoMap[mineCoin].mineAmount.mul(365 days).mul(
                userInfoMap[account].distribution)/totalDistribution/mineInfoMap[mineCoin].mineInterval;
        return baseMine.mul(getPeriodWeight(getPeriodIndex(currentTime()),userInfoMap[account].maxPeriodID))/1000;
    }
    function getAverageLockedTime()public view returns (uint256) {

        if (totalDistribution == 0){
            return 0;
        }
        uint256 i = _maxPeriod-1;
        uint256 nowIndex = getPeriodIndex(currentTime());
        uint256[] memory periodLocked = new uint256[](_maxPeriod);
        for (;;i--){
            periodLocked[i] = weightDistributionMap[nowIndex+i];
            for(uint256 j=i+1;j<_maxPeriod;j++){
                if (periodLocked[j]>0){
                    periodLocked[i] = periodLocked[i].sub(periodLocked[j].mul(getPeriodWeight(i,j)-1000)/1000);
                }
            }
            periodLocked[i] = periodLocked[i]*1000/(getPeriodWeight(nowIndex,nowIndex)-1000);
            if (i == 0){
                break;
            }
        }
        uint256 allLockedPeriod = 0;
        for(i=0;i<_maxPeriod;i++){
            allLockedPeriod = allLockedPeriod.add(periodLocked[i].mul(getPeriodFinishTime(nowIndex+i).sub(currentTime())));
        }
        return allLockedPeriod.div(totalDistribution);
    }

    function _mineSettlement(address mineCoin)internal{

        uint256 latestTime = mineInfoMap[mineCoin].latestSettleTime;
        uint256 curIndex = getPeriodIndex(latestTime);
        if (curIndex == 0){
            latestTime = _startTime;
        }
        uint256 nowIndex = getPeriodIndex(currentTime());
        if (nowIndex == 0){
            return;
        }
        for (uint256 i=0;i<_maxLoop;i++){
            uint256 finishTime = getPeriodFinishTime(curIndex);
            if (finishTime < currentTime()){
                _mineSettlementPeriod(mineCoin,curIndex,finishTime.sub(latestTime));
                latestTime = finishTime;
            }else{
                _mineSettlementPeriod(mineCoin,curIndex,currentTime().sub(latestTime));
                latestTime = currentTime();
                break;
            }
            curIndex++;
            if (curIndex > nowIndex){
                break;
            }
        }
        mineInfoMap[mineCoin].periodMinedNetWorth[nowIndex] = mineInfoMap[mineCoin].minedNetWorth;
        uint256 _mineInterval = mineInfoMap[mineCoin].mineInterval;
        if (_mineInterval>0){
            mineInfoMap[mineCoin].latestSettleTime = currentTime()/_mineInterval*_mineInterval;
        }else{
            mineInfoMap[mineCoin].latestSettleTime = currentTime();
        }
    }
    function _mineSettlementPeriod(address mineCoin,uint256 periodID,uint256 mineTime)internal{

        uint256 totalDistri = totalDistribution;
        if (totalDistri > 0){
            uint256 latestMined = _getPeriodMined(mineCoin,mineTime);
            if (latestMined>0){
                mineInfoMap[mineCoin].minedNetWorth = mineInfoMap[mineCoin].minedNetWorth.add(latestMined.mul(calDecimals)/totalDistri);
                mineInfoMap[mineCoin].totalMinedCoin = mineInfoMap[mineCoin].totalMinedCoin.add(latestMined.mul(
                    getweightDistribution(periodID))/totalDistri);
            }
        }
        mineInfoMap[mineCoin].periodMinedNetWorth[periodID] = mineInfoMap[mineCoin].minedNetWorth;
    }
    function _settleUserMine(address mineCoin,address account) internal {

        uint256 nowIndex = getPeriodIndex(currentTime());
        if (nowIndex == 0){
            return;
        }
        if(userInfoMap[account].distribution>0){
            uint256 userPeriod = userInfoMap[account].settlePeriod[mineCoin];
            if(userPeriod == 0){
                userPeriod = 1;
            }
            if (userPeriod < mineInfoMap[mineCoin].startPeriod){
                userPeriod = mineInfoMap[mineCoin].startPeriod;
            }
            for (uint256 i = 0;i<_maxLoop;i++){
                _settlementPeriod(mineCoin,account,userPeriod);
                if (userPeriod >= nowIndex){
                    break;
                }
                userPeriod++;
            }
        }
        userInfoMap[account].minerOrigins[mineCoin] = _getTokenNetWorth(mineCoin,nowIndex);
        userInfoMap[account].settlePeriod[mineCoin] = nowIndex;
    }
    function _settlementPeriod(address mineCoin,address account,uint256 periodID) internal {

        uint256 tokenNetWorth = _getTokenNetWorth(mineCoin,periodID);
        if (totalDistribution > 0){
            userInfoMap[account].minerBalances[mineCoin] = userInfoMap[account].minerBalances[mineCoin].add(
                _settlement(mineCoin,account,periodID,tokenNetWorth));
        }
        userInfoMap[account].minerOrigins[mineCoin] = tokenNetWorth;
    }
    function _getTokenNetWorth(address mineCoin,uint256 periodID)internal view returns(uint256){

        return mineInfoMap[mineCoin].periodMinedNetWorth[periodID];
    }

    function _getUserLatestMined(address mineCoin,address account)internal view returns(uint256){

        uint256 userDistri = userInfoMap[account].distribution;
        if (userDistri == 0){
            return 0;
        }
        uint256 userperiod = userInfoMap[account].settlePeriod[mineCoin];
        if (userperiod < mineInfoMap[mineCoin].startPeriod){
            userperiod = mineInfoMap[mineCoin].startPeriod;
        }
        uint256 origin = userInfoMap[account].minerOrigins[mineCoin];
        uint256 latestMined = 0;
        uint256 nowIndex = getPeriodIndex(currentTime());
        uint256 userMaxPeriod = userInfoMap[account].maxPeriodID;
        uint256 netWorth = _getTokenNetWorth(mineCoin,userperiod);

        for (uint256 i=0;i<_maxLoop;i++){
            if(userperiod > nowIndex){
                break;
            }
            if (totalDistribution == 0){
                break;
            }
            netWorth = getPeriodNetWorth(mineCoin,userperiod,netWorth);
            latestMined = latestMined.add(userDistri.mul(netWorth.sub(origin)).mul(getPeriodWeight(userperiod,userMaxPeriod))/1000/calDecimals);
            origin = netWorth;
            userperiod++;
        }
        return latestMined;
    }
    function getPeriodNetWorth(address mineCoin,uint256 periodID,uint256 preNetWorth) internal view returns(uint256) {

        uint256 latestTime = mineInfoMap[mineCoin].latestSettleTime;
        uint256 curPeriod = getPeriodIndex(latestTime);
        if(periodID < curPeriod){
            return mineInfoMap[mineCoin].periodMinedNetWorth[periodID];
        }else{
            if (preNetWorth<mineInfoMap[mineCoin].periodMinedNetWorth[periodID]){
                preNetWorth = mineInfoMap[mineCoin].periodMinedNetWorth[periodID];
            }
            uint256 finishTime = getPeriodFinishTime(periodID);
            if (finishTime >= currentTime()){
                finishTime = currentTime();
            }
            if(periodID > curPeriod){
                latestTime = getPeriodFinishTime(periodID-1);
            }
            if (totalDistribution == 0){
                return preNetWorth;
            }
            uint256 periodMind = _getPeriodMined(mineCoin,finishTime.sub(latestTime));
            return preNetWorth.add(periodMind.mul(calDecimals)/totalDistribution);
        }
    }
    function _getLatestMined(address mineCoin)internal view returns(uint256){

        uint256 latestTime = mineInfoMap[mineCoin].latestSettleTime;
        uint256 curIndex = getPeriodIndex(latestTime);
        uint256 latestMined = 0;
        for (uint256 i=0;i<_maxLoop;i++){
            if (totalDistribution == 0){
                break;
            }
            uint256 finishTime = getPeriodFinishTime(curIndex);
            if (finishTime < currentTime()){
                latestMined = latestMined.add(_getPeriodWeightMined(mineCoin,curIndex,finishTime.sub(latestTime)));
            }else{
                latestMined = latestMined.add(_getPeriodWeightMined(mineCoin,curIndex,currentTime().sub(latestTime)));
                break;
            }
            curIndex++;
            latestTime = finishTime;
        }
        return latestMined;
    }
    function _getPeriodMined(address mineCoin,uint256 mintTime)internal view returns(uint256){

        uint256 _mineInterval = mineInfoMap[mineCoin].mineInterval;
        if (totalDistribution > 0 && _mineInterval>0){
            uint256 _mineAmount = mineInfoMap[mineCoin].mineAmount;
            mintTime = mintTime/_mineInterval;
            uint256 latestMined = _mineAmount.mul(mintTime);
            return latestMined;
        }
        return 0;
    }
    function _getPeriodWeightMined(address mineCoin,uint256 periodID,uint256 mintTime)internal view returns(uint256){

        if (totalDistribution > 0){
            return _getPeriodMined(mineCoin,mintTime).mul(getweightDistribution(periodID))/totalDistribution;
        }
        return 0;
    }
    function _settlement(address mineCoin,address account,uint256 periodID,uint256 tokenNetWorth)internal view returns (uint256) {

        uint256 origin = userInfoMap[account].minerOrigins[mineCoin];
        uint256 userMaxPeriod = userInfoMap[account].maxPeriodID;
        require(tokenNetWorth>=origin,"error: tokenNetWorth logic error!");
        return userInfoMap[account].distribution.mul(tokenNetWorth-origin).mul(getPeriodWeight(periodID,userMaxPeriod))/1000/calDecimals;
    }
    function stakeFPTA(uint256 amount)public minePoolStarted nonReentrant notHalted{

        amount = getPayableAmount(_FPTA,amount);
        require(amount > 0, 'stake amount is zero');
        removeDistribution(msg.sender);
        userInfoMap[msg.sender]._FPTABalance = userInfoMap[msg.sender]._FPTABalance.add(amount);
        addDistribution(msg.sender);
        emit StakeFPTA(msg.sender,amount);
    }
    function lockAirDrop(address user,uint256 ftp_b_amount) minePoolStarted notHalted external{

        if (msg.sender == getOperator(1)){
            lockAirDrop_base(user,ftp_b_amount);
        }else if (msg.sender == getOperator(2)){
            lockAirDrop_stake(user,ftp_b_amount);
        }else{
            require(false ,"Operator: caller is not the eligible Operator");
        }
    }
    function lockAirDrop_base(address user,uint256 ftp_b_amount) internal{

        uint256 curPeriod = getPeriodIndex(currentTime());
        uint256 maxId = userInfoMap[user].maxPeriodID;
        uint256 lockedPeriod = curPeriod > maxId ? curPeriod : maxId;
        ftp_b_amount = getPayableAmount(_FPTB,ftp_b_amount);
        require(ftp_b_amount > 0, 'stake amount is zero');
        removeDistribution(user);
        userInfoMap[user]._FPTBBalance = userInfoMap[user]._FPTBBalance.add(ftp_b_amount);
        userInfoMap[user].maxPeriodID = lockedPeriod;
        userInfoMap[user].lockedExpired = getPeriodFinishTime(lockedPeriod);
        addDistribution(user);
        emit LockAirDrop(msg.sender,user,ftp_b_amount);
    } 
    function lockAirDrop_stake(address user,uint256 lockedPeriod) internal validPeriod(lockedPeriod) {

        uint256 curPeriod = getPeriodIndex(currentTime());
        uint256 userMaxPeriod = curPeriod+lockedPeriod-1;

        require(userMaxPeriod>=userInfoMap[user].maxPeriodID, "lockedPeriod cannot be smaller than current locked period");
        if(userInfoMap[user].maxPeriodID<curPeriod && lockedPeriod == 1){
            require(getPeriodFinishTime(getCurrentPeriodID()+lockedPeriod)>currentTime() + _flexibleExpired, 'locked time must greater than flexible expiration');
        }
        uint256 ftp_a_amount = IERC20(_FPTA).balanceOf(msg.sender);
        ftp_a_amount = getPayableAmount(_FPTA,ftp_a_amount);
        uint256 ftp_b_amount = IERC20(_FPTB).balanceOf(msg.sender);
        ftp_b_amount = getPayableAmount(_FPTB,ftp_b_amount);
        require(ftp_a_amount > 0 || ftp_b_amount > 0, 'stake amount is zero');
        removeDistribution(user);
        userInfoMap[user]._FPTABalance = userInfoMap[user]._FPTABalance.add(ftp_a_amount);
        userInfoMap[user]._FPTBBalance = userInfoMap[user]._FPTBBalance.add(ftp_b_amount);
        if (userInfoMap[user]._FPTBBalance > 0)
        {
            if (lockedPeriod == 0){
                userInfoMap[user].maxPeriodID = 0;
                if (ftp_b_amount>0){
                    userInfoMap[user].lockedExpired = currentTime().add(_flexibleExpired);
                }
            }else{
                userInfoMap[user].maxPeriodID = userMaxPeriod;
                userInfoMap[user].lockedExpired = getPeriodFinishTime(userMaxPeriod);
            }
        }
        addDistribution(user);
        emit StakeFPTA(user,ftp_a_amount);
        emit StakeFPTB(user,ftp_b_amount,lockedPeriod);
    } 
    function stakeFPTB(uint256 amount,uint256 lockedPeriod)public validPeriod(lockedPeriod) minePoolStarted nonReentrant notHalted{

        uint256 curPeriod = getPeriodIndex(currentTime());
        uint256 userMaxPeriod = curPeriod+lockedPeriod-1;
        require(userMaxPeriod>=userInfoMap[msg.sender].maxPeriodID, "lockedPeriod cannot be smaller than current locked period");
        if(userInfoMap[msg.sender].maxPeriodID<curPeriod && lockedPeriod == 1){
            require(getPeriodFinishTime(getCurrentPeriodID()+lockedPeriod)>currentTime() + _flexibleExpired, 'locked time must greater than 15 days');
        }
        amount = getPayableAmount(_FPTB,amount);
        require(amount > 0, 'stake amount is zero');
        removeDistribution(msg.sender);
        userInfoMap[msg.sender]._FPTBBalance = userInfoMap[msg.sender]._FPTBBalance.add(amount);
        if (lockedPeriod == 0){
            userInfoMap[msg.sender].maxPeriodID = 0;
            userInfoMap[msg.sender].lockedExpired = currentTime().add(_flexibleExpired);
        }else{
            userInfoMap[msg.sender].maxPeriodID = userMaxPeriod;
            userInfoMap[msg.sender].lockedExpired = getPeriodFinishTime(userMaxPeriod);
        }
        addDistribution(msg.sender);
        emit StakeFPTB(msg.sender,amount,lockedPeriod);
    }
    function unstakeFPTA(uint256 amount)public nonReentrant notHalted{

        require(amount > 0, 'unstake amount is zero');
        require(userInfoMap[msg.sender]._FPTABalance >= amount,
            'unstake amount is greater than total user stakes');
        removeDistribution(msg.sender);
        userInfoMap[msg.sender]._FPTABalance = userInfoMap[msg.sender]._FPTABalance - amount;
        addDistribution(msg.sender);
        _redeem(msg.sender,_FPTA,amount);
        emit UnstakeFPTA(msg.sender,amount);
    }
    function unstakeFPTB(uint256 amount)public nonReentrant notHalted minePoolStarted periodExpired(msg.sender){

        require(amount > 0, 'unstake amount is zero');
        require(userInfoMap[msg.sender]._FPTBBalance >= amount,
            'unstake amount is greater than total user stakes');
        removeDistribution(msg.sender);
        userInfoMap[msg.sender]._FPTBBalance = userInfoMap[msg.sender]._FPTBBalance - amount;
        addDistribution(msg.sender);
        _redeem(msg.sender,_FPTB,amount);
        emit UnstakeFPTB(msg.sender,amount);
    }
    function changeFPTBLockedPeriod(uint256 lockedPeriod)public validPeriod(lockedPeriod) minePoolStarted notHalted{

        require(userInfoMap[msg.sender]._FPTBBalance > 0, "stake FPTB balance is zero");
        uint256 curPeriod = getPeriodIndex(currentTime());
        require(curPeriod+lockedPeriod-1>=userInfoMap[msg.sender].maxPeriodID, "lockedPeriod cannot be smaller than current locked period");
        removeDistribution(msg.sender); 
        if (lockedPeriod == 0){
            userInfoMap[msg.sender].maxPeriodID = 0;
            userInfoMap[msg.sender].lockedExpired = currentTime().add(_flexibleExpired);
        }else{
            userInfoMap[msg.sender].maxPeriodID = curPeriod+lockedPeriod-1;
            userInfoMap[msg.sender].lockedExpired = getPeriodFinishTime(curPeriod+lockedPeriod-1);
        }
        addDistribution(msg.sender);
        emit ChangeLockedPeriod(msg.sender,lockedPeriod);
    }
    function getPayableAmount(address settlement,uint256 settlementAmount) internal returns (uint256) {

        if (settlement == address(0)){
            settlementAmount = msg.value;
        }else if (settlementAmount > 0){
            IERC20 oToken = IERC20(settlement);
            uint256 preBalance = oToken.balanceOf(address(this));
            SafeERC20.safeTransferFrom(oToken,msg.sender, address(this), settlementAmount);
            uint256 afterBalance = oToken.balanceOf(address(this));
            require(afterBalance-preBalance==settlementAmount,"settlement token transfer error!");
        }
        return settlementAmount;
    }
    function removeDistribution(address account) internal {

        uint256 addrLen = whiteList.length;
        for(uint256 i=0;i<addrLen;i++){
            _mineSettlement(whiteList[i]);
            _settleUserMine(whiteList[i],account);
        }
        uint256 distri = calculateDistribution(account);
        totalDistribution = totalDistribution.sub(distri);
        uint256 nowId = getPeriodIndex(currentTime());
        uint256 endId = userInfoMap[account].maxPeriodID;
        for(;nowId<=endId;nowId++){
            weightDistributionMap[nowId] = weightDistributionMap[nowId].sub(distri.mul(getPeriodWeight(nowId,endId)-1000)/1000);
        }
        userInfoMap[account].distribution =  0;
        removePremiumDistribution(account);
    }
    function addDistribution(address account) internal {

        uint256 distri = calculateDistribution(account);
        uint256 nowId = getPeriodIndex(currentTime());
        uint256 endId = userInfoMap[account].maxPeriodID;
        for(;nowId<=endId;nowId++){
            weightDistributionMap[nowId] = weightDistributionMap[nowId].add(distri.mul(getPeriodWeight(nowId,endId)-1000)/1000);
        }
        userInfoMap[account].distribution =  distri;
        totalDistribution = totalDistribution.add(distri);
        addPremiumDistribution(account);
    }
    function calculateDistribution(address account) internal view returns (uint256){

        uint256 fptAAmount = userInfoMap[account]._FPTABalance;
        uint256 fptBAmount = userInfoMap[account]._FPTBBalance;
        uint256 repeat = (fptAAmount>fptBAmount*10) ? fptBAmount*10 : fptAAmount;
        return _FPTARatio.mul(fptAAmount).add(_FPTBRatio.mul(fptBAmount)).add(
            _RepeatRatio.mul(repeat));
    }
    function getweightDistribution(uint256 periodID)internal view returns (uint256) {

        return weightDistributionMap[periodID].add(totalDistribution);
    }
    function getPeriodWeight(uint256 currentID,uint256 maxPeriod) public pure returns (uint256) {

        if (maxPeriod == 0 || currentID > maxPeriod){
            return 1000;
        }
        uint256 curLocked = maxPeriod-currentID;
        if(curLocked == 0){
            return 1600;
        }else if(curLocked == 1){
            return 3200;
        }else{
            return 5000;
        }
    }

    function getTotalPremium(address premiumCoin)public view returns(uint256){

        return premiumMap[premiumCoin].totalPremium;
    }

    function redeemPremium()public nonReentrant notHalted {

        for (uint256 i=0;i<premiumCoinList.length;i++){
            address premiumCoin = premiumCoinList[i];
            settlePremium(msg.sender,premiumCoin);
            uint256 amount = premiumMap[premiumCoin].premiumBalance[msg.sender];
            if (amount > 0){
                premiumMap[premiumCoin].premiumBalance[msg.sender] = 0;
                _redeem(msg.sender,premiumCoin,amount);
                emit RedeemPremium(msg.sender,premiumCoin,amount);
            }
        }
    }
    function redeemPremiumCoin(address premiumCoin,uint256 amount)public nonReentrant notHalted {

        require(amount > 0,"redeem amount must be greater than zero");
        settlePremium(msg.sender,premiumCoin);
        premiumMap[premiumCoin].premiumBalance[msg.sender] = premiumMap[premiumCoin].premiumBalance[msg.sender].sub(amount);
        _redeem(msg.sender,premiumCoin,amount);
        emit RedeemPremium(msg.sender,premiumCoin,amount);
    }

    function getUserLatestPremium(address account,address premiumCoin)public view returns(uint256){

        return premiumMap[premiumCoin].premiumBalance[account].add(_getUserPremium(account,premiumCoin));
    }
    function _getUserPremium(address account,address premiumCoin)internal view returns(uint256){

        uint256 FPTBBalance = userInfoMap[account]._FPTBBalance;
        if (FPTBBalance > 0){
            uint256 lastIndex = premiumMap[premiumCoin].lastPremiumIndex[account];
            uint256 nowIndex = getPeriodIndex(currentTime());
            uint256 endIndex = lastIndex+_maxLoop < premiumMap[premiumCoin].distributedPeriod.length ? lastIndex+_maxLoop : premiumMap[premiumCoin].distributedPeriod.length;
            uint256 LatestPremium = 0;
            for (; lastIndex< endIndex;lastIndex++){
                uint256 periodID = premiumMap[premiumCoin].distributedPeriod[lastIndex];
                if (periodID == nowIndex || premiumDistributionMap[periodID].totalPremiumDistribution == 0 ||
                    premiumDistributionMap[periodID].userPremiumDistribution[account] == 0){
                    continue;
                }
                LatestPremium = LatestPremium.add(premiumMap[premiumCoin].periodPremium[periodID].mul(premiumDistributionMap[periodID].userPremiumDistribution[account]).div(
                    premiumDistributionMap[periodID].totalPremiumDistribution));
            }        
            return LatestPremium;
        }
        return 0;
    }
    function distributePremium(address premiumCoin, uint256 periodID,uint256 amount)public onlyOperator(0) {

        amount = getPayableAmount(premiumCoin,amount);
        require(amount > 0, 'Distribution amount is zero');
        require(premiumMap[premiumCoin].periodPremium[periodID] == 0 , "This period is already distributed!");
        uint256 nowIndex = getPeriodIndex(currentTime());
        require(nowIndex > periodID, 'This period is not finished');
        whiteListAddress.addWhiteListAddress(premiumCoinList,premiumCoin);
        premiumMap[premiumCoin].periodPremium[periodID] = amount;
        premiumMap[premiumCoin].totalPremium = premiumMap[premiumCoin].totalPremium.add(amount);
        premiumMap[premiumCoin].distributedPeriod.push(uint64(periodID));
        emit DistributePremium(msg.sender,premiumCoin,periodID,amount);
    }
    function removePremiumDistribution(address account) internal {

        for (uint256 i=0;i<premiumCoinList.length;i++){
            settlePremium(account,premiumCoinList[i]);
        }
        uint256 beginTime = currentTime(); 
        uint256 nowId = getPeriodIndex(beginTime);
        uint256 endId = userInfoMap[account].maxPeriodID;
        uint256 FPTBBalance = userInfoMap[account]._FPTBBalance;
        if (FPTBBalance> 0 && nowId<endId){
            for(;nowId<endId;nowId++){
                uint256 finishTime = getPeriodFinishTime(nowId);
                uint256 periodDistribution = finishTime.sub(beginTime).mul(FPTBBalance);
                premiumDistributionMap[nowId].totalPremiumDistribution = premiumDistributionMap[nowId].totalPremiumDistribution.sub(periodDistribution);
                premiumDistributionMap[nowId].userPremiumDistribution[account] = premiumDistributionMap[nowId].userPremiumDistribution[account].sub(periodDistribution);
                beginTime = finishTime;
            }
        }
    }
    function settlePremium(address account,address premiumCoin)internal{

        premiumMap[premiumCoin].premiumBalance[account] = premiumMap[premiumCoin].premiumBalance[account].add(getUserLatestPremium(account,premiumCoin));
        premiumMap[premiumCoin].lastPremiumIndex[account] = premiumMap[premiumCoin].distributedPeriod.length;
    }
    function addPremiumDistribution(address account) internal {

        uint256 beginTime = currentTime(); 
        uint256 nowId = getPeriodIndex(beginTime);
        uint256 endId = userInfoMap[account].maxPeriodID;
        uint256 FPTBBalance = userInfoMap[account]._FPTBBalance;
        for(;nowId<endId;nowId++){
            uint256 finishTime = getPeriodFinishTime(nowId);
            uint256 periodDistribution = finishTime.sub(beginTime).mul(FPTBBalance);
            premiumDistributionMap[nowId].totalPremiumDistribution = premiumDistributionMap[nowId].totalPremiumDistribution.add(periodDistribution);
            premiumDistributionMap[nowId].userPremiumDistribution[account] = premiumDistributionMap[nowId].userPremiumDistribution[account].add(periodDistribution);
            beginTime = finishTime;
        }

    }
    modifier periodExpired(address account){

        require(userInfoMap[account].lockedExpired < currentTime(),'locked period is not expired');

        _;
    }
    modifier validPeriod(uint256 period){

        require(period >= 0 && period <= _maxPeriod, 'locked period must be in valid range');
        _;
    }
    modifier minePoolStarted(){

        require(currentTime()>=_startTime, 'mine pool is not start');
        _;
    }
    function currentTime() internal view returns (uint256){

        return now;
    }
}