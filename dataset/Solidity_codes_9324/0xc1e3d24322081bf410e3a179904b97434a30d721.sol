

pragma solidity =0.5.16;
library SafeInt256 {

    function add(int256 x, int256 y) internal pure returns (int256 z) {

        require(((z = x + y) >= x) == (y >= 0), 'SafeInt256: addition overflow');
    }

    function sub(int256 x, int256 y) internal pure returns (int256 z) {

        require(((z = x - y) <= x) == (y >= 0), 'SafeInt256: substraction underflow');
    }

    function mul(int256 x, int256 y) internal pure returns (int256 z) {

        require(y == 0 || (z = x * y) / y == x, 'SafeInt256: multiplication overflow');
    }
}


pragma solidity =0.5.16;


library SafeMath {

    function add(uint x, uint y) internal pure returns (uint z) {

        require((z = x + y) >= x, 'SafeMath: addition overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {

        require((z = x - y) <= x, 'SafeMath: substraction underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {

        require(y == 0 || (z = x * y) / y == x, 'SafeMath: multiplication overflow');
    }
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


contract AddressWhiteList is Halt {


    using whiteListAddress for address[];
    uint256 constant internal allPermission = 0xffffffff;
    uint256 constant internal allowBuyOptions = 1;
    uint256 constant internal allowSellOptions = 1<<1;
    uint256 constant internal allowExerciseOptions = 1<<2;
    uint256 constant internal allowAddCollateral = 1<<3;
    uint256 constant internal allowRedeemCollateral = 1<<4;
    address[] internal whiteList;
    mapping(address => uint256) internal addressPermission;
    function addWhiteList(address addAddress)public onlyOwner{

        whiteList.addWhiteListAddress(addAddress);
        addressPermission[addAddress] = allPermission;
    }
    function modifyPermission(address addAddress,uint256 permission)public onlyOwner{

        addressPermission[addAddress] = permission;
    }
    function removeWhiteList(address removeAddress)public onlyOwner returns (bool){

        addressPermission[removeAddress] = 0;
        return whiteList.removeWhiteListAddress(removeAddress);
    }
    function getWhiteList()public view returns (address[] memory){

        return whiteList;
    }
    function isEligibleAddress(address tmpAddress) public view returns (bool){

        return whiteList.isEligibleAddress(tmpAddress);
    }
    function checkAddressPermission(address tmpAddress,uint256 state) public view returns (bool){

        return  (addressPermission[tmpAddress]&state) == state;
    }
    modifier addressPermissionAllowed(address tmpAddress,uint256 state){

        require(checkAddressPermission(tmpAddress,state) , "Input address is not allowed");
        _;
    }
}


pragma solidity =0.5.16;

interface IOptionsPool {


    function getExpirationList()external view returns (uint32[] memory);

    function createOptions(address from,address settlement,uint256 type_ly_expiration,
        uint128 strikePrice,uint128 underlyingPrice,uint128 amount,uint128 settlePrice) external returns(uint256);

    function setSharedState(uint256 newFirstOption,int256[] calldata latestNetWorth,address[] calldata whiteList) external;

    function getAllTotalOccupiedCollateral() external view returns (uint256,uint256);

    function getCallTotalOccupiedCollateral() external view returns (uint256);

    function getPutTotalOccupiedCollateral() external view returns (uint256);

    function getTotalOccupiedCollateral() external view returns (uint256);

    function burnOptions(address from,uint256 id,uint256 amount,uint256 optionPrice)external;

    function getOptionsById(uint256 optionsId)external view returns(uint256,address,uint8,uint32,uint256,uint256,uint256);

    function getExerciseWorth(uint256 optionsId,uint256 amount)external view returns(uint256);

    function calculatePhaseOptionsFall(uint256 lastOption,uint256 begin,uint256 end,address[] calldata whiteList) external view returns(int256[] memory);

    function getOptionInfoLength()external view returns (uint256);

    function getNetWrothCalInfo(address[] calldata whiteList)external view returns(uint256,int256[] memory);

    function calRangeSharedPayment(uint256 lastOption,uint256 begin,uint256 end,address[] calldata whiteList)external view returns(int256[] memory,uint256[] memory,uint256);

    function getNetWrothLatestWorth(address settlement)external view returns(int256);

    function getBurnedFullPay(uint256 optionID,uint256 amount) external view returns(address,uint256);


}
contract ImportOptionsPool is Ownable{

    IOptionsPool internal _optionsPool;
    function getOptionsPoolAddress() public view returns(address){

        return address(_optionsPool);
    }
    function setOptionsPoolAddress(address optionsPool)public onlyOwner{

        _optionsPool = IOptionsPool(optionsPool);
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




contract CollateralData is AddressWhiteList,Managerable,Operator,ImportOptionsPool{

    mapping (address => uint256) 	internal feeBalances;
    uint32[] internal FeeRates;
    uint256 constant internal buyFee = 0;
    uint256 constant internal sellFee = 1;
    uint256 constant internal exerciseFee = 2;
    uint256 constant internal addColFee = 3;
    uint256 constant internal redeemColFee = 4;
    event RedeemFee(address indexed recieptor,address indexed settlement,uint256 payback);
    event AddFee(address indexed settlement,uint256 payback);
    event TransferPayback(address indexed recieptor,address indexed settlement,uint256 payback);

    mapping (address => int256) internal netWorthBalances;
    mapping (address => uint256) internal collateralBalances;
    mapping (address => uint256) internal userCollateralPaying;
    mapping (address => mapping (address => uint256)) internal userInputCollateral;
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




contract TransactionFee is CollateralData {

    using SafeMath for uint256;
    constructor() internal{
        initialize();
    }
    function initialize() onlyOwner public{

        FeeRates.push(50);
        FeeRates.push(0);
        FeeRates.push(50);
        FeeRates.push(0);
        FeeRates.push(0);
    }
    function getFeeRateAll()public view returns (uint32[] memory){

        return FeeRates;
    }
    function getFeeRate(uint256 feeType)public view returns (uint32){

        return FeeRates[feeType];
    }
    function setTransactionFee(uint256 feeType,uint32 thousandth)public onlyOwner{

        FeeRates[feeType] = thousandth;
    }

    function getFeeBalance(address settlement)public view returns(uint256){

        return feeBalances[settlement];
    }
    function getAllFeeBalances()public view returns(address[] memory,uint256[] memory){

        uint256[] memory balances = new uint256[](whiteList.length);
        for (uint256 i=0;i<whiteList.length;i++){
            balances[i] = feeBalances[whiteList[i]];
        }
        return (whiteList,balances);
    }
    function redeem(address currency)public onlyOwner{

        uint256 fee = feeBalances[currency];
        require (fee > 0, "It's empty balance");
        feeBalances[currency] = 0;
         if (currency == address(0)){
            msg.sender.transfer(fee);
        }else{
            IERC20 currencyToken = IERC20(currency);
            uint256 preBalance = currencyToken.balanceOf(address(this));
            SafeERC20.safeTransfer(currencyToken,msg.sender,fee);
            uint256 afterBalance = currencyToken.balanceOf(address(this));
            require(preBalance - afterBalance == fee,"settlement token transfer error!");
        }
        emit RedeemFee(msg.sender,currency,fee);
    }
    function redeemAll()public onlyOwner{

        for (uint256 i=0;i<whiteList.length;i++){
            redeem(whiteList[i]);
        }
    }
    function _addTransactionFee(address settlement,uint256 amount) internal {

        if (amount > 0){
            feeBalances[settlement] = feeBalances[settlement]+amount;
            emit AddFee(settlement,amount);
        }
    }
    function calculateFee(uint256 feeType,uint256 amount)public view returns (uint256){

        return FeeRates[feeType]*amount/1000;
    }
    function _transferPaybackAndFee(address payable recieptor,address settlement,uint256 payback,uint256 feeType)internal{

        if (payback == 0){
            return;
        }
        uint256 fee = FeeRates[feeType]*payback/1000;
        _transferPayback(recieptor,settlement,payback-fee);
        _addTransactionFee(settlement,fee);
    }
    function _transferPayback(address payable recieptor,address settlement,uint256 payback)internal{

        if (payback == 0){
            return;
        }
        if (settlement == address(0)){
            recieptor.transfer(payback);
        }else{
            IERC20 collateralToken = IERC20(settlement);
            uint256 preBalance = collateralToken.balanceOf(address(this));
            SafeERC20.safeTransfer(collateralToken,recieptor,payback);
            uint256 afterBalance = collateralToken.balanceOf(address(this));
            require(preBalance - afterBalance == payback,"settlement token transfer error!");
        }
        emit TransferPayback(recieptor,settlement,payback);
    }
}


pragma solidity =0.5.16;


contract CollateralPool is TransactionFee{

    using SafeMath for uint256;
    using SafeInt256 for int256;
    constructor(address optionsPool)public{
        _optionsPool = IOptionsPool(optionsPool);
    }
    function () external payable onlyManager{

    }
    function initialize() onlyOwner public {

        TransactionFee.initialize();
    }
    function update() onlyOwner public{

    }
    function addTransactionFee(address collateral,uint256 amount,uint256 feeType)public onlyManager returns (uint256) {

        uint256 fee = FeeRates[feeType]*amount/1000;
        _addTransactionFee(collateral,fee);
        return fee;
    }
    function getUserPayingUsd(address user)public view returns (uint256){

        return userCollateralPaying[user];
    }
    function getUserInputCollateral(address user,address collateral)public view returns (uint256){

        return userInputCollateral[user][collateral];
    }

    function getCollateralBalance(address collateral)public view returns (uint256){

        return collateralBalances[collateral];
    }
    function addUserPayingUsd(address user,uint256 amount)public onlyManager{

        userCollateralPaying[user] = userCollateralPaying[user].add(amount);
    }
    function addUserInputCollateral(address user,address collateral,uint256 amount)public onlyManager{

        userInputCollateral[user][collateral] = userInputCollateral[user][collateral].add(amount);
        collateralBalances[collateral] = collateralBalances[collateral].add(amount);
        netWorthBalances[collateral] = netWorthBalances[collateral].add(int256(amount));
    }
    function addNetWorthBalances(address[] memory whiteList,int256[] memory newNetworth)internal{

        for (uint i=0;i<newNetworth.length;i++){
            netWorthBalances[whiteList[i]] = netWorthBalances[whiteList[i]].add(newNetworth[i]);
        }
    }
    function addNetWorthBalance(address collateral,int256 amount)public onlyManager{

        netWorthBalances[collateral] = netWorthBalances[collateral].add(amount);
    }
    function addCollateralBalance(address collateral,uint256 amount)public onlyManager{

        collateralBalances[collateral] = collateralBalances[collateral].add(amount);
    }
    function subUserPayingUsd(address user,uint256 amount)public onlyManager{

        userCollateralPaying[user] = userCollateralPaying[user].sub(amount);
    }
    function subUserInputCollateral(address user,address collateral,uint256 amount)public onlyManager{

        userInputCollateral[user][collateral] = userInputCollateral[user][collateral].sub(amount);
    }
    function subNetWorthBalance(address collateral,int256 amount)public onlyManager{

        netWorthBalances[collateral] = netWorthBalances[collateral].sub(amount);
    }
    function subCollateralBalance(address collateral,uint256 amount)public onlyManager{

        collateralBalances[collateral] = collateralBalances[collateral].sub(amount);
    }
    function setUserPayingUsd(address user,uint256 amount)public onlyManager{

        userCollateralPaying[user] = amount;
    }
    function setUserInputCollateral(address user,address collateral,uint256 amount)public onlyManager{

        userInputCollateral[user][collateral] = amount;
    }
    function setNetWorthBalance(address collateral,int256 amount)public onlyManager{

        netWorthBalances[collateral] = amount;
    }
    function setCollateralBalance(address collateral,uint256 amount)public onlyManager{

        collateralBalances[collateral] = amount;
    }
    function transferPaybackAndFee(address payable recieptor,address settlement,uint256 payback,
            uint256 feeType)public onlyManager{

        _transferPaybackAndFee(recieptor,settlement,payback,feeType);
        netWorthBalances[settlement] = netWorthBalances[settlement].sub(int256(payback));
    }
    function buyOptionsPayfor(address payable recieptor,address settlement,uint256 settlementAmount,uint256 allPay)public onlyManager{

        uint256 fee = addTransactionFee(settlement,allPay,0);
        require(settlementAmount>=allPay+fee,"settlement asset is insufficient!");
        settlementAmount = settlementAmount-(allPay+fee);
        if (settlementAmount > 0){
            _transferPayback(recieptor,settlement,settlementAmount);
        }
    }
    function transferPayback(address payable recieptor,address settlement,uint256 payback)public onlyManager{

        _transferPayback(recieptor,settlement,payback);
    }
    function transferPaybackBalances(address payable account,uint256 redeemWorth,address[] memory tmpWhiteList,uint256[] memory colBalances,
        uint256[] memory PremiumBalances,uint256[] memory prices)public onlyManager {

        uint256 ln = tmpWhiteList.length;
        uint256[] memory PaybackBalances = new uint256[](ln);
        uint256 i=0;
        uint256 amount;
        for(; i<ln && redeemWorth>0;i++){
            if (colBalances[i] > 0){
                amount = redeemWorth/prices[i];
                if (amount < colBalances[i]){
                    redeemWorth = 0;
                }else{
                    amount = colBalances[i];
                    redeemWorth = redeemWorth - colBalances[i]*prices[i];
                }
                PaybackBalances[i] = amount;
                amount = amount * userInputCollateral[account][tmpWhiteList[i]]/colBalances[i];
                userInputCollateral[account][tmpWhiteList[i]] =userInputCollateral[account][tmpWhiteList[i]].sub(amount);
                collateralBalances[tmpWhiteList[i]] = collateralBalances[tmpWhiteList[i]].sub(amount);

            }
        }
        if (redeemWorth>0) {
           amount = 0;
            for (i=0; i<ln;i++){
                amount = amount.add(PremiumBalances[i]*prices[i]);
            }
            if (amount<redeemWorth){
                amount = redeemWorth;
            }
            for (i=0; i<ln;i++){
                PaybackBalances[i] = PaybackBalances[i].add(PremiumBalances[i].mul(redeemWorth)/amount);
            }
        }
        for (i=0;i<ln;i++){ 
            transferPaybackAndFee(account,tmpWhiteList[i],PaybackBalances[i],redeemColFee);
        } 
    }
    function getCollateralAndPremiumBalances(address account,uint256 userTotalWorth,address[] memory tmpWhiteList,
        uint256[] memory _RealBalances,uint256[] memory prices) public view returns(uint256[] memory,uint256[] memory){

        uint256[] memory colBalances = new uint256[](tmpWhiteList.length);
        uint256[] memory PremiumBalances = new uint256[](tmpWhiteList.length);
        uint256 totalWorth = 0;
        uint256 PremiumWorth = 0;
        uint256 i=0;
        for(; i<tmpWhiteList.length;i++){
            (colBalances[i],PremiumBalances[i]) = calUserNetWorthBalanceRate(tmpWhiteList[i],account,_RealBalances[i]);
            totalWorth = totalWorth.add(prices[i]*colBalances[i]);
            PremiumWorth = PremiumWorth.add(prices[i]*PremiumBalances[i]);
        }
        if (totalWorth >= userTotalWorth){
            for (i=0; i<tmpWhiteList.length;i++){
                colBalances[i] = colBalances[i].mul(userTotalWorth)/totalWorth;
            }
        }else if (PremiumWorth>0){
            userTotalWorth = userTotalWorth - totalWorth;
            for (i=0; i<tmpWhiteList.length;i++){
                PremiumBalances[i] = PremiumBalances[i].mul(userTotalWorth)/PremiumWorth;
            }
        }
        return (colBalances,PremiumBalances);
    } 
    function calUserNetWorthBalanceRate(address settlement,address user,uint256 netWorthBalance)internal view returns(uint256,uint256){

        uint256 collateralBalance = collateralBalances[settlement];
        uint256 amount = userInputCollateral[user][settlement];
        if (collateralBalance > 0){
            uint256 curAmount = netWorthBalance.mul(amount)/collateralBalance;
            return (curAmount,netWorthBalance.sub(curAmount));
        }else{
            return (0,netWorthBalance);
        }
    }
    function getAllRealBalance(address[] memory whiteList)public view returns(int256[] memory){

        uint256 len = whiteList.length;
        int256[] memory realBalances = new int256[](len); 
        for (uint i = 0;i<len;i++){
            int256 latestWorth = _optionsPool.getNetWrothLatestWorth(whiteList[i]);
            realBalances[i] = netWorthBalances[whiteList[i]].add(latestWorth);
        }
        return realBalances;
    }
    function getRealBalance(address settlement)public view returns(int256){

        int256 latestWorth = _optionsPool.getNetWrothLatestWorth(settlement);
        return netWorthBalances[settlement].add(latestWorth);
    }
    function getNetWorthBalance(address settlement)public view returns(uint256){

        int256 latestWorth = _optionsPool.getNetWrothLatestWorth(settlement);
        int256 netWorth = netWorthBalances[settlement].add(latestWorth);
        if (netWorth>0){
            return uint256(netWorth);
        }
        return 0;
    }
    function addNetBalance(address settlement,uint256 amount) public payable {

        amount = getPayableAmount(settlement,amount);
        netWorthBalances[settlement] = netWorthBalances[settlement].add(int256(amount));
    }
    function getPayableAmount(address settlement,uint256 settlementAmount) internal returns (uint256) {

        if (settlement == address(0)){
            settlementAmount = msg.value;
        }else if (settlementAmount > 0){
            IERC20 oToken = IERC20(settlement);
            uint256 preBalance = oToken.balanceOf(address(this));
            oToken.transferFrom(msg.sender, address(this), settlementAmount);
            uint256 afterBalance = oToken.balanceOf(address(this));
            require(afterBalance-preBalance==settlementAmount,"settlement token transfer error!");
        }
        return settlementAmount;
    }
    function calSharedPayment(address[] memory _whiteList) public onlyOperatorIndex(0) {

        (uint256 firstOption,int256[] memory latestShared) = _optionsPool.getNetWrothCalInfo(_whiteList);
        uint256 lastOption = _optionsPool.getOptionInfoLength();
        (int256[] memory newNetworth,uint256[] memory sharedBalance,uint256 newFirst) =
                     _optionsPool.calRangeSharedPayment(lastOption,firstOption,lastOption,_whiteList);
        int256[] memory fallBalance = _optionsPool.calculatePhaseOptionsFall(lastOption,newFirst,lastOption,_whiteList);
        for (uint256 i= 0;i<fallBalance.length;i++){
            fallBalance[i] = int256(sharedBalance[i]).sub(latestShared[i]).add(fallBalance[i]);
        }
        setSharedPayment(_whiteList,newNetworth,fallBalance,newFirst);
    }
    function setSharedPayment(address[] memory _whiteList,int256[] memory newNetworth,int256[] memory sharedBalances,uint256 firstOption) public onlyOperatorIndex(0){

        _optionsPool.setSharedState(firstOption,sharedBalances,_whiteList);
        addNetWorthBalances(_whiteList,newNetworth);
    }
}