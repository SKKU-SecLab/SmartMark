

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

contract Managerable is Ownable {


    address private _managerAddress;
    modifier onlyManager() {

        require(_managerAddress == msg.sender,"Managerable: caller is not the Manager");
        _;
    }
    function setManager(address managerAddress)
    public
    onlyOwner
    {

        _managerAddress = managerAddress;
    }
    function getManager()public view returns (address) {

        return _managerAddress;
    }
}


pragma solidity =0.5.16;

interface IFNXOracle {

    function getPrice(address asset) external view returns (uint256);

    function getUnderlyingPrice(uint256 cToken) external view returns (uint256);

}
contract ImportOracle is Ownable{

    IFNXOracle internal _oracle;
    function oraclePrice(address asset) internal view returns (uint256){

        uint256 price = _oracle.getPrice(asset);
        require(price >= 100 && price <= 1e30);
        return price;
    }
    function oracleUnderlyingPrice(uint256 cToken) internal view returns (uint256){

        uint256 price = _oracle.getUnderlyingPrice(cToken);
        require(price >= 100 && price <= 1e30);
        return price;
    }
    function getOracleAddress() public view returns(address){

        return address(_oracle);
    }
    function setOracleAddress(address oracle)public onlyOwner{

        _oracle = IFNXOracle(oracle);
    }
}


pragma solidity =0.5.16;
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


contract UnderlyingAssets is Ownable {

    using whiteListUint32 for uint32[];
    uint32[] internal underlyingAssets;
    function addUnderlyingAsset(uint32 underlying)public onlyOwner{

        underlyingAssets.addWhiteListUint32(underlying);
    }
    function removeUnderlyingAssets(uint32 removeUnderlying)public onlyOwner returns(bool) {

        return underlyingAssets.removeWhiteListUint32(removeUnderlying);
    }
    function getUnderlyingAssets()public view returns (uint32[] memory){

        return underlyingAssets;
    }
    function isEligibleUnderlyingAsset(uint32 underlying) public view returns (bool){

        return underlyingAssets.isEligibleUint32(underlying);
    }
    function _getEligibleUnderlyingIndex(uint32 underlying) internal view returns (uint256){

        return underlyingAssets._getEligibleIndexUint32(underlying);
    }
}


pragma solidity =0.5.16;

interface IVolatility {

    function calculateIv(uint32 underlying,uint8 optType,uint256 expiration,uint256 currentPrice,uint256 strikePrice)external view returns (uint256,uint256);

}
contract ImportVolatility is Ownable{

    IVolatility internal _volatility;
    function getVolatilityAddress() public view returns(address){

        return address(_volatility);
    }
    function setVolatilityAddress(address volatility)public onlyOwner{

        _volatility = IVolatility(volatility);
    }
}


pragma solidity =0.5.16;

interface IOptionsPrice {

    function getOptionsPrice(uint256 currentPrice, uint256 strikePrice, uint256 expiration,uint32 underlying,uint8 optType)external view returns (uint256);

    function getOptionsPrice_iv(uint256 currentPrice, uint256 strikePrice, uint256 expiration,
                uint256 ivNumerator,uint256 ivDenominator,uint8 optType)external view returns (uint256);

    function calOptionsPriceRatio(uint256 selfOccupied,uint256 totalOccupied,uint256 totalCollateral) external view returns (uint256,uint256);

}
contract ImportOptionsPrice is Ownable{

    IOptionsPrice internal _optionsPrice;
    function getOptionsPriceAddress() public view returns(address){

        return address(_optionsPrice);
    }
    function setOptionsPriceAddress(address optionsPrice)public onlyOwner{

        _optionsPrice = IOptionsPrice(optionsPrice);
    }
}


pragma solidity =0.5.16;


contract Operator is Ownable {

    using whiteListAddress for address[];
    address[] private _operatorList;
    modifier onlyOperator() {

        require(_operatorList.isEligibleAddress(msg.sender),"Managerable: caller is not the Operator");
        _;
    }
    modifier onlyOperatorIndex(uint256 index) {

        require(_operatorList.length>index && _operatorList[index] == msg.sender,"Operator: caller is not the eligible Operator");
        _;
    }
    function addOperator(address addAddress)public onlyOwner{

        _operatorList.addWhiteListAddress(addAddress);
    }
    function setOperator(uint256 index,address addAddress)public onlyOwner{

        _operatorList[index] = addAddress;
    }
    function removeOperator(address removeAddress)public onlyOwner returns (bool){

        return _operatorList.removeWhiteListAddress(removeAddress);
    }
    function getOperator()public view returns (address[] memory) {

        return _operatorList;
    }
    function setOperators(address[] memory operators)public onlyOwner {

        _operatorList = operators;
    }
}


pragma solidity =0.5.16;


contract ImputRange is Ownable {


    uint256 private maxAmount = 1e30;
    uint256 private minAmount = 1e2;

    modifier InRange(uint256 amount) {

        require(maxAmount>=amount && minAmount<=amount,"input amount is out of input amount range");
        _;
    }
    function isInputAmountInRange(uint256 Amount)public view returns (bool){

        return(maxAmount>=Amount && minAmount<=Amount);
    }
    modifier Smaller(uint256 amount) {

        require(maxAmount>=amount,"input amount is larger than maximium");
        _;
    }
    modifier Larger(uint256 amount) {

        require(minAmount<=amount,"input amount is smaller than maximium");
        _;
    }
    function getInputAmountRange() public view returns(uint256,uint256) {

        return (minAmount,maxAmount);
    }
    function setInputAmountRange(uint256 _minAmount,uint256 _maxAmount) public onlyOwner{

        minAmount = _minAmount;
        maxAmount = _maxAmount;
    }
}


pragma solidity =0.5.16;


contract timeLimitation is Ownable {


    mapping(uint256=>uint256) internal itemTimeMap;
    uint256 internal limitation = 1 hours;
    function setTimeLimitation(uint256 _limitation) public onlyOwner {

        limitation = _limitation;
    }
    function setItemTimeLimitation(uint256 item) internal{

        itemTimeMap[item] = now;
    }
    function getTimeLimitation() public view returns (uint256){

        return limitation;
    }
    function getItemTimeLimitation(uint256 item) public view returns (uint256){

        return itemTimeMap[item]+limitation;
    }
    modifier OutLimitation(uint256 item) {

        require(itemTimeMap[item]+limitation<now,"Time limitation is not expired!");
        _;
    }
}


pragma solidity =0.5.16;








contract OptionsData is UnderlyingAssets,timeLimitation,ImputRange,Managerable,ImportOracle,ImportVolatility,ImportOptionsPrice,Operator{

    struct OptionsInfo {
        uint64     optionID;    //an increasing nubmer id, begin from one.
        address     owner;      // option's owner
        uint8   	optType;    //0 for call, 1 for put
        uint32		underlying; // underlying ID, 1 for BTC,2 for ETH
        uint256		expiration; // Expiration timestamp
        uint256     strikePrice;    //strike price
        uint256     amount;         // mint amount
    }
    struct OptionsInfoEx{
        address      settlement;    //user's settlement paying for option.
        uint256      tokenTimePrice; //option's buying price based on settlement, used for options share calculation
        uint256      underlyingPrice;//underlying price when option is created.
        uint256      fullPrice;      //option's buying price.
        uint256      ivNumerator;   // option's iv numerator when option is created.
        uint256      ivDenominator;// option's iv denominator when option is created.
    }
    OptionsInfo[] internal allOptions;
    mapping(uint256=>OptionsInfoEx) internal optionExtraMap;
    uint256 constant internal calDecimals = 1e18;
    mapping(address=>uint256[]) internal optionsBalances;
    uint256[] internal expirationList;

    uint256 internal netWorthirstOption;
    mapping(address=>int256) internal optionsLatestNetWorth;

    uint256 internal occupiedFirstOption;
    uint256 internal callOccupied;
    uint256 internal putOccupied;
    int256 internal callLatestOccupied;
    int256 internal putLatestOccupied;

    event CreateOption(address indexed owner,uint256 indexed optionID,uint8 optType,uint32 underlying,uint256 expiration,uint256 strikePrice,uint256 amount);
    event BurnOption(address indexed owner,uint256 indexed optionID,uint amount);
}


pragma solidity =0.5.16;
library tuple64 {

    function getValue0(uint256 input) internal pure returns (uint256){

        return uint256(uint64(input));
    }
    function getValue1(uint256 input) internal pure returns (uint256){

        return uint256(uint64(input>>64));
    }
    function getValue2(uint256 input) internal pure returns (uint256){

        return uint256(uint64(input>>128));
    }
    function getValue3(uint256 input) internal pure returns (uint256){

        return uint256(uint64(input>>192));
    }
    function getTuple(uint256 input0,uint256 input1,uint256 input2,uint256 input3) internal pure returns (uint256){

        return input0+(input1<<64)+(input2<<128)+(input3<<192);
    }
    function getTuple3(uint256 input0,uint256 input1,uint256 input2) internal pure returns (uint256){

        return input0+(input1<<64)+(input2<<128);
    }
    function getTuple2(uint256 input0,uint256 input1) internal pure returns (uint256){

        return input0+(input1<<64);
    }
}


pragma solidity =0.5.16;


contract OptionsBase is OptionsData {

    using whiteListUint256 for uint256[];

    constructor () public{
        initialize();
    }
    function initialize() onlyOwner public {

        expirationList =  [1 days,2 days,3 days, 7 days, 10 days, 15 days,20 days, 30 days/*,90 days*/];
        underlyingAssets = [1,2];
    }
    function getUserOptionsID(address user)public view returns(uint256[] memory){

        return optionsBalances[user];
    }
    function getUserOptionsID(address user,uint256 from,uint256 size)public view returns(uint256[] memory){

        require(from <optionsBalances[user].length,"input from is overflow");
        require(size>0,"input size is zero");
        uint256[] memory userIdAry = new uint256[](size);
        if (from+size>optionsBalances[user].length){
            size = optionsBalances[user].length-from;
        }
        for (uint256 i= 0;i<size;i++){
            userIdAry[i] = optionsBalances[user][from+i];
        }
        return userIdAry;
    }
    function getOptionInfoLength()public view returns (uint256){

        return allOptions.length;
    }
    function getOptionInfoList(uint256 from,uint256 size)public view
                returns(address[] memory,uint256[] memory,uint256[] memory,uint256[] memory,uint256[] memory){

        require(from <allOptions.length,"input from is overflow");
        require(size>0,"input size is zero");
        if (from+size>allOptions.length){
            size = allOptions.length - from;
        }
        address[] memory ownerArr = new address[](size);
        uint256[] memory typeAndUnderArr = new uint256[](size);
        uint256[] memory expArr = new uint256[](size);
        uint256[] memory priceArr = new uint256[](size);
        uint256[] memory amountArr = new uint256[](size);
        for (uint i=0;i<size;i++){
            OptionsInfo storage info = allOptions[from+i];
            ownerArr[i] = info.owner;
            typeAndUnderArr[i] = (info.underlying << 16) + info.optType;
            expArr[i] = info.expiration;
            priceArr[i] = info.strikePrice;
            amountArr[i] = info.amount;
        }
        return (ownerArr,typeAndUnderArr,expArr,priceArr,amountArr);
    }
    function getOptionInfoListFromID(uint256[] memory ids)public view
                returns(address[] memory,uint256[] memory,uint256[] memory,uint256[] memory,uint256[] memory){

        uint256 size = ids.length;
        require(size > 0, "input ids array is empty");
        address[] memory ownerArr = new address[](size);
        uint256[] memory typeAndUnderArr = new uint256[](size);
        uint256[] memory expArr = new uint256[](size);
        uint256[] memory priceArr = new uint256[](size);
        uint256[] memory amountArr = new uint256[](size);
        for (uint i=0;i<size;i++){
            OptionsInfo storage info = _getOptionsById(ids[i]);
            ownerArr[i] = info.owner;
            typeAndUnderArr[i] = (info.underlying << 16) + info.optType;
            expArr[i] = info.expiration;
            priceArr[i] = info.strikePrice;
            amountArr[i] = info.amount;
        }
        return (ownerArr,typeAndUnderArr,expArr,priceArr,amountArr);
    }
    function getOptionsLimitTimeById(uint256 optionsId)public view returns(uint256){

        require(optionsId>0 && optionsId <= allOptions.length,"option id is not exist");
        return getItemTimeLimitation(optionsId);
    }
    function getOptionsById(uint256 optionsId)public view returns(uint256,address,uint8,uint32,uint256,uint256,uint256){

        OptionsInfo storage info = _getOptionsById(optionsId);
        return (info.optionID,info.owner,info.optType,info.underlying,info.expiration,info.strikePrice,info.amount);
    }
    function getOptionsExtraById(uint256 optionsId)public view returns(address,uint256,uint256,uint256,uint256,uint256){

        require(optionsId>0 && optionsId <= allOptions.length,"option id is not exist");
        OptionsInfoEx storage info = optionExtraMap[optionsId];
        return (info.settlement,info.tokenTimePrice,info.underlyingPrice,
                info.fullPrice,info.ivNumerator,info.ivDenominator);
    }
    function getUnderlyingPrices()internal view returns(uint256[] memory){

        uint256 underlyingLen = underlyingAssets.length;
        uint256[] memory prices = new uint256[](underlyingLen);
        for (uint256 i = 0;i<underlyingLen;i++){
            prices[i] = oracleUnderlyingPrice(underlyingAssets[i]);
        }
        return prices;
    }
    function _createOptions(address from,address settlement,uint256 type_ly_exp,uint256 strikePrice,uint256 optionPrice,
                uint256 amount) internal {

        uint256 optionID = allOptions.length;
        uint8 optType = uint8(tuple64.getValue0(type_ly_exp));
        uint32 underlying = uint32(tuple64.getValue1(type_ly_exp));
        allOptions.push(OptionsInfo(uint64(optionID+1),from,optType,underlying,tuple64.getValue2(type_ly_exp)+now,strikePrice,amount));
        optionsBalances[from].push(optionID+1);
        OptionsInfo memory info = allOptions[optionID];
        setOptionsExtra(info,settlement,optionPrice,strikePrice);
        setItemTimeLimitation(optionID+1);
        emit CreateOption(from,optionID+1,optType,underlying,tuple64.getValue2(type_ly_exp)+now,strikePrice,amount);
    }
    function setOptionsExtra(OptionsInfo memory info,address settlement,uint256 optionPrice,uint256 strikePrice) internal{

        uint256 underlyingPrice = oracleUnderlyingPrice(info.underlying);
        uint256 expiration = info.expiration - now;
        (uint256 ivNumerator,uint256 ivDenominator) = _volatility.calculateIv(info.underlying,info.optType,expiration,underlyingPrice,strikePrice);
        uint256 fullPrice = _optionsPrice.getOptionsPrice_iv(underlyingPrice,strikePrice,expiration,ivNumerator,
                ivDenominator,info.optType);
        uint256 tokenTimePrice = optionPrice*calDecimals/fullPrice/oraclePrice(settlement);
        optionExtraMap[info.optionID-1]= OptionsInfoEx(settlement,tokenTimePrice,underlyingPrice,fullPrice,ivNumerator,ivDenominator);
    }
    function _burnOptions(address from,uint256 id,uint256 amount)internal{

        OptionsInfo storage info = _getOptionsById(id);
        checkEligible(info);
        checkOwner(info,from);
        checkSufficient(info,amount);
        info.amount = info.amount-amount;
        emit BurnOption(from,id,amount);
    }
    function getExerciseWorth(uint256 optionsId,uint256 amount)public view returns(uint256){

        OptionsInfo memory info = _getOptionsById(optionsId);
        checkEligible(info);
        checkSufficient(info,amount);
        uint256 underlyingPrice = oracleUnderlyingPrice(info.underlying);
        uint256 tokenPayback = _getOptionsPayback(info.optType,info.strikePrice,underlyingPrice);
        if (tokenPayback == 0 ){
            return 0;
        }
        return tokenPayback*amount;
    }
    function _getOptionsPayback(uint8 optType,uint256 strikePrice,uint256 underlyingPrice)internal pure returns(uint256){

        if ((optType == 0) == (strikePrice>underlyingPrice)){ // call
            return 0;
        } else {
            return (optType == 0) ? underlyingPrice - strikePrice : strikePrice - underlyingPrice;
        }
    }
    function _getOptionsById(uint256 id)internal view returns(OptionsInfo storage){

        require(id>0 && id <= allOptions.length,"option id is not exist");
        return allOptions[id-1];
    }
    function checkEligible(OptionsInfo memory info)internal view{

        require(info.expiration>now,"option is expired");
    }
    function checkOwner(OptionsInfo memory info,address owner)internal pure{

        require(info.owner == owner,"caller is not the options owner");
    }
    function checkSufficient(OptionsInfo memory info,uint256 amount) internal pure{

        require(info.amount >= amount,"option amount is insufficient");
    }
    function buyOptionCheck(uint256 expiration,uint32 underlying)public view{

        require(isEligibleUnderlyingAsset(underlying) , "underlying is unsupported asset");
        checkExpiration(expiration);
    }
    function addExpiration(uint256 expiration)public onlyOwner{

        expirationList.addWhiteListUint256(expiration);
    }
    function removeExpirationList(uint256 removeExpiration)public onlyOwner returns(bool) {

        return expirationList.removeWhiteListUint256(removeExpiration);
    }
    function getExpirationList()public view returns (uint256[] memory){

        return expirationList;
    }
    function isEligibleExpiration(uint256 expiration) public view returns (bool){

        return expirationList.isEligibleUint256(expiration);
    }
    function checkExpiration(uint256 expiration) public view{

        return require(isEligibleExpiration(expiration),"expiration value is not supported");
    }
    function _getEligibleExpirationIndex(uint256 expiration) internal view returns (uint256){

        return expirationList._getEligibleIndexUint256(expiration);
    }
    function getFirstOption(uint256 begin,uint256 latestBegin,uint256 end) internal view returns(uint256,uint256){

        uint256 newFirstOption = latestBegin;
        if (begin > newFirstOption){
            return (begin,newFirstOption);
        }
        begin = newFirstOption;
        for (;begin<end;begin++){
            OptionsInfo storage info = allOptions[begin];
            if(info.expiration<now || info.amount == 0){
                continue;
            }
            break;
        }
        return (begin,begin);
    }
    function calOptionsCollateral(OptionsInfo memory option,uint256 underlyingPrice)internal view returns(uint256){

        if (option.expiration<=now || option.amount == 0){
            return 0;
        }
        uint256 totalOccupied = _getOptionsWorth(option.optType,option.strikePrice,underlyingPrice)*option.amount;
        require(totalOccupied<=1e40,"Option collateral occupied calculate error");
        return totalOccupied;
    }
    function _getOptionsWorth(uint8 optType,uint256 strikePrice,uint256 underlyingPrice)internal pure returns(uint256){

        if ((optType == 0) == (strikePrice>underlyingPrice)){ // call
            return strikePrice;
        } else {
            return underlyingPrice;
        }
    }
    function getBurnedFullPay(uint256 optionID,uint256 amount) Smaller(amount) public view returns(address,uint256){

        OptionsInfoEx storage optionEx = optionExtraMap[optionID-1];
        return (optionEx.settlement,optionEx.fullPrice*optionEx.tokenTimePrice*amount/calDecimals);
    }
}


pragma solidity =0.5.16;

contract OptionsOccupiedCal is OptionsBase {


    function getOccupiedCalInfo()public view returns(uint256,int256,int256){

        return (occupiedFirstOption,callLatestOccupied,putLatestOccupied);
    }
    function setOccupiedCollateral() public onlyOperatorIndex(1) {

        int256 latestCallOccupied = callLatestOccupied;
        int256 latestPutOccupied = putLatestOccupied;
        uint256 lastOption = allOptions.length;
        (uint256 totalCallOccupied,uint256 totalPutOccupied,uint256 beginOption,bool success) = calculatePhaseOccupiedCollateral(lastOption, occupiedFirstOption,lastOption);
        if (success){
            setCollateralPhase(totalCallOccupied,totalPutOccupied,beginOption,latestCallOccupied,latestPutOccupied);
        }
    }
    function calculatePhaseOccupiedCollateral(uint256 lastOption,uint256 beginOption,uint256 endOption) public view returns(uint256,uint256,uint256,bool){

        if (beginOption <  occupiedFirstOption){
            beginOption =  occupiedFirstOption;
        }
        if (beginOption>=lastOption){
            return (0,0,0,false);
        }
        if (endOption>lastOption) {
            endOption = lastOption;
        }else if(endOption <  occupiedFirstOption){
            return (0,0,0,false);
        }
        (uint256 totalCallOccupied,uint256 totalPutOccupied,uint256 newFirstOption) = _calculateOccupiedCollateral(beginOption,endOption);
        return (totalCallOccupied,totalPutOccupied,newFirstOption,true);
    }
    function _calculateOccupiedCollateral(uint256 begin,uint256 end)internal view returns(uint256,uint256,uint256){

        uint256 newFirstOption;
        (begin,newFirstOption) = getFirstOption(begin, occupiedFirstOption,end);
        uint256[] memory prices = getUnderlyingPrices();
        uint256 totalCallOccupied = 0;
        uint256 totalPutOccupied = 0;
        for (;begin<end;begin++){
            uint256 index = _getEligibleUnderlyingIndex(allOptions[begin].underlying);
            uint256 value = calOptionsCollateral(allOptions[begin],prices[index]);
            if (allOptions[begin].optType == 0){
                totalCallOccupied += value;
            }else{
                totalPutOccupied += value;
            }
        }
        return (totalCallOccupied,totalPutOccupied,newFirstOption);
    }
    function setCollateralPhase(uint256 totalCallOccupied,uint256 totalPutOccupied,uint256 beginOption,
            int256 latestCallOccpied,int256 latestPutOccpied) public onlyOperatorIndex(1){

        require(beginOption <= allOptions.length, "beginOption calculate Error");
        if (beginOption >  occupiedFirstOption){
             occupiedFirstOption = beginOption;
        }
        callOccupied = totalCallOccupied;
        putOccupied = totalPutOccupied;
        require(latestCallOccpied>=-1e40 && latestCallOccpied<=1e40,"options fall calculate error");
        require(latestPutOccpied>=-1e40 && latestPutOccpied<=1e40,"options fall calculate error");
        callLatestOccupied -= latestCallOccpied;
        putLatestOccupied -= latestPutOccpied;
    }
    function getCallTotalOccupiedCollateral() public view returns (uint256) {

        if (callLatestOccupied>=0){
            uint256 result = callOccupied+uint256(callLatestOccupied);
            require(result>=callOccupied,"TotalOccupiedCollateral calculate overflow");
            return result;
        }else{
            uint256 latestOccupied = uint256(-callLatestOccupied);
            if (callOccupied>latestOccupied){
                return callOccupied - latestOccupied;
            }else{
                return 0;
            }
        }
    }
    function getPutTotalOccupiedCollateral() public view returns (uint256) {

        if (putLatestOccupied>=0){
            uint256 result = putOccupied+uint256(putLatestOccupied);
            require(result>=putOccupied,"TotalOccupiedCollateral calculate overflow");
            return result;
        }else{
            uint256 latestOccupied = uint256(-putLatestOccupied);
            if (putOccupied>latestOccupied){
                return putOccupied - latestOccupied;
            }else{
                return 0;
            }
        }
    }
    function getTotalOccupiedCollateral() public view returns (uint256) {

        return getCallTotalOccupiedCollateral() + getPutTotalOccupiedCollateral();
    }
    function _addOptionsCollateral(OptionsInfo memory info) internal {

        OptionsInfoEx storage infoEx =  optionExtraMap[info.optionID-1];
        uint256 newOccupied = calOptionsCollateral(info,infoEx.underlyingPrice);
        if (info.optType == 0){
            callLatestOccupied += int256(newOccupied);
        }else{
            putLatestOccupied += int256(newOccupied);
        }
    }
    function _burnOptionsCollateral(OptionsInfo memory info,uint256 amount,uint256 underlyingPrice) internal {

        uint256 newOccupied = _getOptionsWorth(info.optType,info.strikePrice,underlyingPrice)*amount;
        require(newOccupied<=1e40,"Option collateral occupied calculate error");
        if (info.optType == 0){
            callLatestOccupied -= int256(newOccupied);
        }else{
            putLatestOccupied -= int256(newOccupied);
        }
    }

}


pragma solidity =0.5.16;

contract OptionsNetWorthCal is OptionsOccupiedCal {

    function getNetWrothCalInfo(address[] memory whiteList)public view returns(uint256,int256[] memory){

        uint256 len = whiteList.length;
        int256[] memory latestNetWorth = new int256[](len);
            for (uint256 i = 0;i<len;i++){
            latestNetWorth[i] = optionsLatestNetWorth[whiteList[i]];
        }
        return ( netWorthirstOption,latestNetWorth);
    }
    function getNetWrothLatestWorth(address settlement)public view returns(int256){

        return optionsLatestNetWorth[settlement];
    }
    function setSharedState(uint256 newFirstOption,int256[] memory latestNetWorth,address[] memory whiteList) public onlyOperatorIndex(0){

        require(newFirstOption <= allOptions.length, "newFirstOption calculate Error");
        if (newFirstOption >  netWorthirstOption){
             netWorthirstOption = newFirstOption;
        }
        uint256 len = whiteList.length;
        for (uint256 i = 0;i<len;i++){
            require(latestNetWorth[i]>=-1e40 && latestNetWorth[i]<=1e40,"latestNetWorth calculate error");
            optionsLatestNetWorth[whiteList[i]] += latestNetWorth[i];
        }
    }
    function calRangeSharedPayment(uint256 lastOption,uint256 begin,uint256 end,address[] memory whiteList)
            public view returns(int256[] memory,uint256[] memory,uint256){

        if (begin>=lastOption || end <  netWorthirstOption){
            return(new int256[](whiteList.length),new uint256[](whiteList.length),0);
        }
        if (end>lastOption) {
            end = lastOption;
        }
        (uint256[] memory sharedBalances,uint256 _firstOption) = _calculateSharedPayment(begin,end,whiteList);
        if (begin < _firstOption){
            int256[] memory newNetworth = calculateExpiredPayment(begin,_firstOption,whiteList);
            return (newNetworth,sharedBalances,_firstOption);
        }

        return (new int256[](whiteList.length),sharedBalances,_firstOption);
    }
    function _calculateSharedPayment(uint256 begin,uint256 end,address[] memory whiteList)
            internal view returns(uint256[] memory,uint256){

        uint256[] memory totalSharedPayment = new uint256[](whiteList.length);
        uint256 newFirstOption;
        (begin,newFirstOption) = getFirstOption(begin, netWorthirstOption,end);
        for (;begin<end;begin++){
            OptionsInfo storage info = allOptions[begin];
            OptionsInfoEx storage optionEx = optionExtraMap[begin];
            uint256 timeValue = _calculateCurrentPrice(optionEx.underlyingPrice,info.strikePrice,info.expiration,
                optionEx.ivNumerator,optionEx.ivDenominator,info.optType);
            if (timeValue<optionEx.fullPrice){
                timeValue = optionEx.fullPrice - timeValue;
                uint256 index = whiteListAddress._getEligibleIndexAddress(whiteList,optionEx.settlement);
                timeValue = optionEx.tokenTimePrice*timeValue*info.amount/calDecimals;
                require(timeValue<=1e40,"option time shared value calculate error");
                totalSharedPayment[index] = totalSharedPayment[index]+timeValue;
            }
        }
        return (totalSharedPayment,newFirstOption);
    }
    function calculateExpiredPayment(uint256 begin,uint256 end,address[] memory whiteList)internal view returns(int256[] memory){

        int256[] memory totalExpiredPayment = new int256[](whiteList.length);
        for (;begin<end;begin++){
            OptionsInfo storage info = allOptions[begin];
            if (info.amount>0){
                OptionsInfoEx storage optionEx = optionExtraMap[begin];
                uint256 index = whiteListAddress._getEligibleIndexAddress(whiteList,optionEx.settlement);
                uint256 timeValue = optionEx.fullPrice*optionEx.tokenTimePrice*info.amount/calDecimals;
                require(timeValue<=1e40,"option time shared value calculate error");
                totalExpiredPayment[index] = totalExpiredPayment[index]+int256(timeValue);
            }
        }
        return totalExpiredPayment;
    }
    function calculatePhaseOptionsFall(uint256 lastOption,uint256 begin,uint256 end,address[] memory whiteList) public view returns(int256[] memory){

        if (begin>=lastOption || end <  netWorthirstOption){
            return new int256[](whiteList.length);
        }
        if (end>lastOption) {
            end = lastOption;
        }
        if (begin <=  netWorthirstOption) {
            begin =  netWorthirstOption;
        }
        uint256[] memory prices = getUnderlyingPrices();
        int256[] memory OptionsFallBalances = _calRangeOptionsFall(begin,end,whiteList,prices);
        uint256 whiteListLen = whiteList.length;
        for (uint256 index = 0;index<whiteListLen;index++){
            OptionsFallBalances[index] = OptionsFallBalances[index]/(int256(oraclePrice(whiteList[index])));
        }
        return OptionsFallBalances;
    }
    function _calRangeOptionsFall(uint256 begin,uint256 lastOption,address[] memory whiteList,uint256[] memory prices)
                 internal view returns(int256[] memory){

        int256[] memory OptionsFallBalances = new int256[](whiteList.length);
        for (;begin<lastOption;begin++){
            OptionsInfo storage info = allOptions[begin];
            if(info.expiration<now || info.amount == 0){
                continue;
            }
            uint256 index = _getEligibleUnderlyingIndex(info.underlying);
            int256 curValue = _calCurtimeCallateralFall(info,info.amount,prices[index]);
            if (curValue != 0){
                OptionsInfoEx storage optionEx = optionExtraMap[begin];
                index = whiteListAddress._getEligibleIndexAddress(whiteList,optionEx.settlement);
                OptionsFallBalances[index] = OptionsFallBalances[index]-curValue;
            }
        }
        return OptionsFallBalances;
    }
    function _calCurtimeCallateralFall(OptionsInfo memory info,uint256 amount,uint256 curPrice) internal view returns(int256){

        if (info.expiration<=now || amount == 0){
            return 0;
        }
        uint256 newFall = _getOptionsPayback(info.optType,info.strikePrice,curPrice)*amount;
        OptionsInfoEx storage optionEx = optionExtraMap[info.optionID-1];
        uint256 OriginFall = _getOptionsPayback(info.optType,info.strikePrice,optionEx.underlyingPrice)*amount;
        int256 curValue = int256(newFall) - int256(OriginFall);
        require(curValue>=-1e40 && curValue<=1e40,"options fall calculate error");
        return curValue;
    }
    function _burnOptionsNetworth(OptionsInfo memory info,uint256 amount,uint256 underlyingPrice,uint256 currentPrice) internal {

        int256 curValue = _calCurtimeCallateralFall(info,amount,underlyingPrice);
        OptionsInfoEx storage optionEx = optionExtraMap[info.optionID-1];
        uint256 timeWorth = optionEx.fullPrice>currentPrice ? optionEx.fullPrice-currentPrice : 0;
        timeWorth = optionEx.tokenTimePrice*timeWorth*amount/calDecimals;
        curValue = curValue / int256(oraclePrice(optionEx.settlement));
        int256 value = curValue - int256(timeWorth);
        optionsLatestNetWorth[optionEx.settlement] = optionsLatestNetWorth[optionEx.settlement]+value;
    }
    function _calculateCurrentPrice(uint256 curprice,uint256 strikePrice,uint256 expiration,uint256 ivNumerator,uint256 ivDenominator,uint8 optType)internal view returns (uint256){

        if (expiration > now){
            return _optionsPrice.getOptionsPrice_iv(curprice,strikePrice,expiration-now,ivNumerator,
                ivDenominator,optType);
        }
        return 0;
    }
}


pragma solidity =0.5.16;

contract OptionsPool is OptionsNetWorthCal {

    constructor (address oracleAddr,address optionsPriceAddr,address ivAddress)public{
        _oracle = IFNXOracle(oracleAddr);
        _optionsPrice = IOptionsPrice(optionsPriceAddr);
        _volatility = IVolatility(ivAddress);
    }
    function update() onlyOwner public {


    }
    function getOptionCalRangeAll(address[] memory whiteList)public view returns(uint256,int256,int256,uint256,int256[] memory,uint256,uint256){

        (uint256 occupiedFirst,int256 callOccupiedlatest,int256 putOccupiedlatest) = getOccupiedCalInfo();
        (uint256 netFirst,int256[] memory netLatest) = getNetWrothCalInfo(whiteList);
        return (occupiedFirst,callOccupiedlatest,putOccupiedlatest,netFirst,netLatest,allOptions.length,block.number);
    }
    function createOptions(address from,address settlement,uint256 type_ly_exp,uint256 strikePrice,uint256 optionPrice,
                uint256 amount) onlyManager  Smaller(amount) public {

        _createOptions(from,settlement,type_ly_exp,strikePrice,optionPrice,amount);
        OptionsInfo memory info = _getOptionsById(allOptions.length);
        _addOptionsCollateral(info);
    }
    function burnOptions(address from,uint256 id,uint256 amount,uint256 optionPrice)public onlyManager Smaller(amount) OutLimitation(id){

        _burnOptions(from,id,amount);
        OptionsInfo memory info = _getOptionsById(id);
        uint256 currentPrice = oracleUnderlyingPrice(info.underlying);
        _burnOptionsCollateral(info,amount,currentPrice);
        _burnOptionsNetworth(info,amount,currentPrice,optionPrice);
    }
}