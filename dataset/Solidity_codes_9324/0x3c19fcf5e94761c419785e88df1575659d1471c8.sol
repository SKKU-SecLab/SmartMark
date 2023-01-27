


pragma solidity ^0.5.0;

library SafeMath {

    int256 constant private INT256_MIN = -2**255;

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function mul(int256 a, int256 b) internal pure returns (int256) {

        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == INT256_MIN)); // This is the only case of overflow not detected by the check below

        int256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0);
        uint256 c = a / b;

        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {

        require(b != 0); // Solidity only automatically asserts when dividing by 0
        require(!(b == -1 && a == INT256_MIN)); // This is the only case of overflow

        int256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);
        return a % b;
    }
}

contract Ownable {

    address payable public owner;
    address payable public developer;


    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );


    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {

        require(msg.sender == owner, "Only Owner Can Do This");
        _;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipRenounced(owner);
        owner = address(0);
    }

    function transferOwnership(address payable _newOwner) public onlyOwner {

        _transferOwnership(_newOwner);
    }

    function _transferOwnership(address payable _newOwner) internal {

        require(_newOwner != address(0), "New Owner's Address is Required");
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}

contract Pausable is Ownable {


    event Pause();
    event Unpause();

    bool public paused = false;


    modifier whenNotPaused() {

        require(!paused);
        _;
    }

    modifier whenPaused() {

        require(paused);
        _;
    }

    function pause() public onlyOwner whenNotPaused {

        paused = true;
        emit Pause();
    }

    function unpause() public onlyOwner whenPaused {

        paused = false;
        emit Unpause();
    }
}



contract Ranch is Ownable, Pausable{


    using SafeMath for uint;

    uint[9] _ranchSize = [0,2000,3000,4000,7000,9000,10000,14000,17000];
    uint[9] _ranchGradeByNum = [0,1,5,10,30,50,100,150,200];

    address private cryptoRanchAddress;

    event OnSetCryptoRanchAddress(address cryptoRanchAddress,  uint timestamp);

    constructor(address cryptoRanchAddr) public {
        cryptoRanchAddress = cryptoRanchAddr;
    }

    modifier onlyForCryptoRanch() {

        require(cryptoRanchAddress == msg.sender, "Only for cryptoRanch contract!");
        _;
    }

    function setCryptoRanchAddress(address cryptoRanchAddr) public onlyOwner {

        cryptoRanchAddress = cryptoRanchAddr;
        emit OnSetCryptoRanchAddress(cryptoRanchAddress, now);
    }

    function getCryptoRanchAddress() public view returns (address) {

        return cryptoRanchAddress;
    }

    function ranch(uint totalSheepPrice, uint sheepNum) public view onlyForCryptoRanch returns(uint, uint, uint, uint) {

        uint ranchGrade = getRanchGrade(sheepNum);
        uint ranchSize = getRanchSize(ranchGrade);
        uint admissionPrice = getAdmissionPrice(totalSheepPrice);
        uint maxProfitability = getMaxProfitability(ranchGrade, admissionPrice);

        return (
        ranchGrade,
        ranchSize,
        admissionPrice,
        maxProfitability
        );
    }

    function getRanchGrade(uint sheepNum) public view onlyForCryptoRanch returns (uint) {

        for (uint i = 0; i < 9; i++) {
            if (sheepNum == _ranchGradeByNum[i]) {
                return i;
            }
        }
        return 0;
    }

    function getRanchSize(uint ranchGrade) public view onlyForCryptoRanch returns(uint) {

        return _ranchSize[ranchGrade];
    }

    function getMaxProfitability(uint ranchGrade, uint admissionPrice) public view onlyForCryptoRanch returns(uint) {

        return admissionPrice.mul(getRanchSize(ranchGrade));
    }

    function getAdmissionPrice(uint totalSheepPrice) public view onlyForCryptoRanch returns(uint) {

        return totalSheepPrice.mul(2);
    }

    function multipleBuy(uint totalSheepPrice, uint oldAdmissionPrice, uint oldMaxProfitability)
    public view onlyForCryptoRanch returns(uint, uint){

        uint admissionPrice = getAdmissionPrice(totalSheepPrice);
        uint newAdmissionPrice = admissionPrice.add(oldAdmissionPrice);
        uint newMaxProfitability = getMaxProfitability(8, admissionPrice).add(oldMaxProfitability);
        return (newAdmissionPrice, newMaxProfitability);
    }
}



contract Commission is Ownable, Pausable{

    using SafeMath for uint;

    uint[9] gradeToCommission = [100,400,400,500,500,600,600,700,700];
    uint[9] ranchGrow = [0,0,0,0,0,0,0,0,1000];

    address private cryptoRanchAddress;

    struct Generation {
        uint[] ancestorList; //up-line
        uint[] inviteesList; //down-line
    }

    mapping (uint => Generation) generations;

    event OnSetCryptoRanchAddress(address cryptoRanchAddress, uint timestamp);

    constructor (address cryptoRanchAddr) public {
        cryptoRanchAddress = cryptoRanchAddr;
    }

    modifier onlyForCryptoRanch() {

        require(cryptoRanchAddress == msg.sender, "Only for cryptoRanch contract!");
        _;
    }

    function setCryptoRanchAddress(address cryptoRanchAddr) public onlyOwner{

        cryptoRanchAddress = cryptoRanchAddr;
        emit OnSetCryptoRanchAddress(cryptoRanchAddress, now);
    }

    function joinGame(uint pID, uint inviterID) public onlyForCryptoRanch{


        uint len = generations[inviterID].ancestorList.length;
        if (len == 0) {
            generations[pID].ancestorList.push(inviterID);
        } else if (len < 10) {
            generations[pID].ancestorList.push(inviterID);
            for(uint i = 0; i < len; i++) {
                generations[pID].ancestorList.push(generations[inviterID].ancestorList[i]);
            }
        } else if (len >= 10) {
            generations[pID].ancestorList.push(inviterID);
            for(uint i = 0; i < 9; i++) {
                generations[pID].ancestorList.push(generations[inviterID].ancestorList[i]);
            }
        }
    }

    function inviteNewUser(uint inviterID, uint inviterRanchSize, bool inviterIsAlive, uint invitee, uint inviteeRanchGrade)
    public onlyForCryptoRanch returns(uint){

        generations[inviterID].inviteesList.push(invitee);
        if (inviterIsAlive) {
            uint newRanchSize = inviterRanchSize.add(ranchGrow[inviteeRanchGrade]);
            return newRanchSize;
        } else {
            return inviterRanchSize;
        }
    }

    function getMotherGeneration(uint pID) external view onlyForCryptoRanch returns(uint) {

        require(generations[pID].ancestorList.length != 0, "You are the first generation!");
        return generations[pID].ancestorList[0];
    }

    function getAncestorList(uint pID) external view onlyForCryptoRanch returns(uint[] memory){

        require(generations[pID].ancestorList.length != 0, "You are the first generation!");

        uint[] memory ancestorList = new uint[](generations[pID].ancestorList.length);
        for(uint i = 0; i < generations[pID].ancestorList.length; i++){
            ancestorList[i] = generations[pID].ancestorList[i];
        }
        return ancestorList;
    }

    function getInviteesList(uint pID) external view onlyForCryptoRanch returns(uint[] memory){

        require(generations[pID].inviteesList.length != 0, "You don't have downline!");

        uint[] memory inviteesList = new uint[](generations[pID].inviteesList.length);
        for(uint i = 0; i < generations[pID].inviteesList.length; i++){
            inviteesList[i] = generations[pID].inviteesList[i];
        }
        return inviteesList;
    }

    function getInviteesCount(uint pID) external view returns(uint){

        return generations[pID].inviteesList.length;
    }

    function getAncestorCount(uint pID) external view returns(uint){

        return generations[pID].ancestorList.length;
    }
}


contract TransactionSystem is Ownable{

    using SafeMath for uint;

    uint constant SHEEP_INIT_NUMBER = 10000;
    uint constant SHEEP_INIT_PRICE = 50 finney;

    event OnPriceChange(uint indexed price, uint timestamp);
    event OnFleshUp(uint indexed price, uint fleshUpCount, uint timestamp);
    event OnOrderAdd(address indexed from, uint number, uint timestamp);
    event OnOrderCancel(address indexed from, uint number, uint timestamp);
    event OnSetCryptoRanchAddress(address cryptoRanchAddress,  uint timestamp);


    struct GlobalData {
        uint sheepNum;
        uint sheepPrice;
        uint sysInSaleNum;
        uint sysSoldNum;
        uint[7] priceInterval;
    }
    struct OrderQueue {
        uint[] idList;
        uint front;
    }

    struct Order {
        uint ownerID;
        uint sheepNum;
        uint sheepPrice;
        uint round;
    }

    GlobalData global;
    Order[] sellOrders;
    uint[] private reproductionBlkNums;

    CryptoRanch cryptoRanch = CryptoRanch(0x0);
    address payable cryptoRanchAddress;

    bool isFleshUp = false;
    uint fleshUpCount = 0;
    uint priceCumulativeCount;


    mapping (uint => uint) orderIDByPID;               // pID => orderID
    mapping (uint => OrderQueue) priceOrderQueue;      // price => orders queue on the price level
    mapping (uint => uint) sysPriceSheepNum;           // price => total sheep number of sys on the price level
    mapping (uint => uint) usrPriceSheepNum;           // price => total sheep number of usr orders on the price level

    constructor () public{
        global = GlobalData({
            sheepNum: SHEEP_INIT_NUMBER,
            sheepPrice: SHEEP_INIT_PRICE,
            sysInSaleNum: SHEEP_INIT_NUMBER,
            sysSoldNum: 0,
            priceInterval: [uint256(50 finney), uint256(51 finney), uint256(52 finney), uint256(53 finney), uint256(54 finney), uint256(55 finney), uint256(56 finney)]
            });

        uint initSheepNum = global.sheepNum.div(50);

        for (uint i = 50 finney; i <= 56 finney; i = i.add(1 finney)) {
            sysPriceSheepNum[i] = initSheepNum;
        }

        reproductionBlkNums.push(0);

        priceCumulativeCount = 56 finney;
    }

    modifier onlyForCryptoRanch() {

        require(cryptoRanchAddress == msg.sender, "Only for cryptoRanch contract!");
        _;
    }

    function() payable external{
        cryptoRanchAddress.transfer(msg.value);
    }

    function setCryptoRanchAddress(address payable cryptoRanchAddr) external onlyOwner {

        cryptoRanchAddress = cryptoRanchAddr;
        cryptoRanch = CryptoRanch(cryptoRanchAddress);

        emit OnSetCryptoRanchAddress(cryptoRanchAddress, now);
    }

    function getCryptoRanchAddress() public view returns (address) {

        return cryptoRanchAddress;
    }


    function buySheepFromOrders(uint buyerID, uint balance, uint sheepNum, bool isRebuy) public onlyForCryptoRanch {


        uint addSheepNum = 0; // accumulated sold sheep in this tx
        uint sheepPrice = global.sheepPrice;
        uint totalCost = 0;
        uint cost = 0;
        uint tmpRound = cryptoRanch.getReproductionRound();
        OrderQueue storage Q = priceOrderQueue[sheepPrice];

        while (sheepNum > 0) {
            if (sysPriceSheepNum[sheepPrice] > 0) {
                if (sysPriceSheepNum[sheepPrice] >= sheepNum) {
                    addSheepNum = addSheepNum.add(sheepNum);
                    cost = sheepNum.mul(sheepPrice);  // cost in this turn
                    totalCost = totalCost.add(cost);  // forage fee, cumulated
                    balance = balance.sub(cost);

                    global.sysSoldNum = global.sysSoldNum.add(sheepNum);
                    global.sysInSaleNum = global.sysInSaleNum.sub(sheepNum);
                    sysPriceSheepNum[sheepPrice] = sysPriceSheepNum[sheepPrice].sub(sheepNum);
                    sheepNum = 0;

                    cryptoRanch.processSellerProfit(0, cost);
                    cryptoRanch.addSheepNumber(buyerID, addSheepNum, totalCost, true);

                    if (balance > 0 && isRebuy == false) {
                        uint tmpBalance = balance;
                        balance = 0;
                        cryptoRanch.buyOrderRefund(buyerID, tmpBalance);
                    }

                    if (sysPriceSheepNum[sheepPrice] == 0 && usrPriceSheepNum[sheepPrice] == 0) {
                        changePriceInterval(sheepPrice);
                    }
                    break;

                } else {
                    addSheepNum = addSheepNum.add(sysPriceSheepNum[sheepPrice]);
                    cost = sysPriceSheepNum[sheepPrice].mul(sheepPrice);
                    totalCost = totalCost.add(cost);
                    balance = balance.sub(cost);

                    global.sysSoldNum = global.sysSoldNum.add(sysPriceSheepNum[sheepPrice]);
                    global.sysInSaleNum = global.sysInSaleNum.sub(sysPriceSheepNum[sheepPrice]);
                    sheepNum = sheepNum.sub(sysPriceSheepNum[sheepPrice]);

                    sysPriceSheepNum[sheepPrice] = 0;

                    cryptoRanch.processSellerProfit(0, cost);
                }
            }

            if (usrPriceSheepNum[sheepPrice] == 0) {
                changePriceInterval(sheepPrice);
                sheepPrice = global.sheepPrice;
                Q = priceOrderQueue[sheepPrice]; //point to the orders queue of new price
                if (tmpRound < cryptoRanch.getReproductionRound()) {
                    addSheepNum = addSheepNum.mul(2);
                    tmpRound = cryptoRanch.getReproductionRound();
                }
                continue; // start with system order on new price
            }

            while(sellOrders[Q.idList[Q.front]].sheepNum <= 0) {
                Q.front ++ ;
            }

            uint orderID = Q.idList[Q.front];
            Order storage order = sellOrders[orderID];

            uint realNum = order.sheepNum.mul(2**(cryptoRanch.getReproductionRound().sub(order.round)));

            if (realNum <= sheepNum) {
                addSheepNum = addSheepNum.add(realNum);
                cost = realNum.mul(sheepPrice);
                totalCost = totalCost.add(cost);
                balance = balance.sub(cost);

                global.sysSoldNum = global.sysSoldNum.add(realNum);
                usrPriceSheepNum[sheepPrice] = usrPriceSheepNum[sheepPrice].sub(realNum);

                sheepNum = sheepNum.sub(realNum);

                cryptoRanch.processSellerProfit(order.ownerID, cost);

                orderIDByPID[order.ownerID] = 0;
                delete sellOrders[orderID];
                delete Q.idList[Q.front];
                Q.front++;

                if(usrPriceSheepNum[sheepPrice] == 0 && sheepNum == 0) {
                    cryptoRanch.addSheepNumber(buyerID, addSheepNum, totalCost, true);
                    changePriceInterval(sheepPrice);

                    if (balance > 0 && isRebuy == false) {
                        uint tmpBalance = balance;
                        balance = 0;
                        cryptoRanch.buyOrderRefund(buyerID, tmpBalance);
                    }
                    break;
                }
            } else {
                addSheepNum = addSheepNum.add(sheepNum);
                cost = sheepNum.mul(sheepPrice);
                totalCost = totalCost.add(cost);
                balance = balance.sub(cost);

                global.sysSoldNum = global.sysSoldNum.add(sheepNum);
                usrPriceSheepNum[sheepPrice] = usrPriceSheepNum[sheepPrice].sub(sheepNum);

                sellOrders[orderID].sheepNum = realNum.sub(sheepNum);
                sellOrders[orderID].round = cryptoRanch.getReproductionRound();

                sheepNum = 0;
                cryptoRanch.processSellerProfit(order.ownerID, cost);

                cryptoRanch.addSheepNumber(buyerID, addSheepNum, totalCost, true);
                if (balance > 0 && isRebuy == false) {
                    uint tmpBalance = balance;
                    balance = 0;
                    cryptoRanch.buyOrderRefund(buyerID, tmpBalance);
                }
                break;
            }
        }
    }

    function addNewSellOrder(uint sellerID,  uint sheepNum, uint sheepPrice) public onlyForCryptoRanch {

        require(isFleshUp == false, "isFleshUp");
        require(sheepPrice != global.sheepPrice && sheepPrice > global.sheepPrice && sheepPrice <= global.priceInterval[6], "out of range");

        if (global.sheepPrice < 99 finney && sheepPrice > 99 finney) {
            revert("out of range");
        }
        if (global.sheepPrice >= 99 finney && sheepPrice != 100 finney) {
            revert("0.099 only allowed 0.1 eth");
        }

        if (sysPriceSheepNum[sheepPrice].add(usrPriceSheepNum[sheepPrice]).add(sheepNum).mul(50) > global.sheepNum) {
            revert("no more than 2% global sheepNumber");
        }
        if (global.sheepPrice == 99 finney && sysPriceSheepNum[50 finney].add(usrPriceSheepNum[50 finney]).add(sheepNum).mul(25) > global.sheepNum){
            revert("no more than 2% global sheepNumber");
        }

        require(sellOrders.length == 0 || sellOrders[orderIDByPID[sellerID]].ownerID != sellerID, "already exist");

        cryptoRanch.minusSheepNum(sellerID, sheepNum); //notice

        uint orderID = sellOrders.length;
        if (sheepPrice == 100 finney) {
            sheepNum = sheepNum.mul(2);
            sheepPrice = 50 finney;
            sellOrders.push(Order({
                ownerID: sellerID,
                sheepNum: sheepNum,
                sheepPrice: sheepPrice,
                round: cryptoRanch.getReproductionRound().add(1)
                }));
        } else {
            sellOrders.push(Order({
                ownerID: sellerID,
                sheepNum: sheepNum,
                sheepPrice: sheepPrice,
                round: cryptoRanch.getReproductionRound()
                }));
        }
        orderIDByPID[sellerID] = orderID;
        priceOrderQueue[sheepPrice].idList.push(orderID);
        usrPriceSheepNum[sheepPrice] = usrPriceSheepNum[sheepPrice].add(sheepNum);

        emit OnOrderAdd(cryptoRanch.getAddrByPID(sellerID), sheepNum, now);
    }

    function cancelSellOrder(uint sellerID) public onlyForCryptoRanch {

        require(isFleshUp == false, "isFleshUp");
        uint orderID = orderIDByPID[sellerID];
        require(orderID > 0 && sellOrders.length >= orderID, "Id error!");
        Order storage order = sellOrders[orderID];
        require(order.ownerID == sellerID, "no exist");

        if (global.sheepPrice == 99 finney && order.sheepPrice == 50 finney) {
            revert("0.099 not allowed cancel 0.1 eth order");
        }

        uint tmpPrice = order.sheepPrice;
        uint tmpSheepNum = order.sheepNum.mul(2**(cryptoRanch.getReproductionRound().sub(order.round)));
        delete sellOrders[orderID];

        cryptoRanch.addSheepNumber(sellerID, tmpSheepNum, 0, false);
        usrPriceSheepNum[tmpPrice] = usrPriceSheepNum[tmpPrice].sub(tmpSheepNum);

        orderIDByPID[sellerID] = 0;

        emit OnOrderCancel(cryptoRanch.getAddrByPID(sellerID), tmpSheepNum, now);
    }

    function burnSheepGlobal(uint sheepNum) external onlyForCryptoRanch{

        global.sheepNum = global.sheepNum.sub(sheepNum);
    }

    function determineForwardSheepPrice(uint start) private {

        for (uint i =  start; i < 100 finney; i = i.add(1 finney)) {
            if (sysPriceSheepNum[i] > 0 || usrPriceSheepNum[i] > 0) {
                global.sheepPrice = i;
                return;
            }
        }
    }

    function determinePriceInterval(uint sheepPrice) private {

        if (isFleshUp == false && sheepPrice.add(3 finney) > priceCumulativeCount && priceCumulativeCount < 99 finney) {
            uint newPrice = sheepPrice.add(3 finney);
            uint addSheepNum = global.sysInSaleNum.div(50);
            for (uint i = sheepPrice; i <= newPrice; i = i.add(1 finney)) {
                if (sysPriceSheepNum[i] == 0) sysPriceSheepNum[i] = addSheepNum;
            }
            priceCumulativeCount = newPrice;

            global.priceInterval[0] = newPrice.sub(6 finney);
            global.priceInterval[1] = newPrice.sub(5 finney);
            global.priceInterval[2] = newPrice.sub(4 finney);
            global.priceInterval[3] = newPrice.sub(3 finney);
            global.priceInterval[4] = newPrice.sub(2 finney);
            global.priceInterval[5] = newPrice.sub(1 finney);
            global.priceInterval[6] = newPrice;
        } else if (isFleshUp == false && sheepPrice.sub(3 finney) >= 50 finney && sheepPrice <= 96 finney)  {
            global.priceInterval[0] = sheepPrice.sub(3 finney);
            global.priceInterval[1] = sheepPrice.sub(2 finney);
            global.priceInterval[2] = sheepPrice.sub(1 finney);
            global.priceInterval[3] = sheepPrice;
            global.priceInterval[4] = sheepPrice.add(1 finney);
            global.priceInterval[5] = sheepPrice.add(2 finney);
            global.priceInterval[6] = sheepPrice.add(3 finney);
        } else if (sheepPrice == 99 finney) {
            uint addSheepNum = global.sysInSaleNum.sub(sysPriceSheepNum[99 finney]).div(25);
            sysPriceSheepNum[50 finney] = sysPriceSheepNum[50 finney].mul(2).add(addSheepNum);
            usrPriceSheepNum[50 finney] = usrPriceSheepNum[50 finney].mul(2);

            global.priceInterval[0] = 94 finney;
            global.priceInterval[1] = 95 finney;
            global.priceInterval[2] = 96 finney;
            global.priceInterval[3] = 97 finney;
            global.priceInterval[4] = 98 finney;
            global.priceInterval[5] = 99 finney;
            global.priceInterval[6] = 100 finney;
        }

        emit OnPriceChange(global.sheepPrice, now);
    }

    function changePriceInterval(uint sheepPrice) private {

        if (isFleshUp || global.sysSoldNum.mul(50) >= global.sheepNum) {
            if (isFleshUp == false) fleshUpCount = 0;

            bool haveSheep = false;
            for (uint i = global.priceInterval[0]; i <= global.priceInterval[6]; i = i.add(1 finney)) {
                if (sysPriceSheepNum[i] > 0 || usrPriceSheepNum[i] > 0) {
                    if (haveSheep == false) {
                        haveSheep = true;
                        global.sheepPrice = i; // determine the next price
                        sheepPrice = i;
                    }
                    if (isFleshUp == false) fleshUpCount = fleshUpCount.add(sysPriceSheepNum[i]).add(usrPriceSheepNum[i]);
                    else break;
                }
            }
            isFleshUp = true;      // "Growing" stage start
            global.sysSoldNum = 0; // clear the accumulated sold sheep

            if (fleshUpCount == 0) {
                isFleshUp = false;
                determineForwardSheepPrice(global.priceInterval[0]);
                sheepPrice = global.sheepPrice;
            } else if (haveSheep == false) { // end of the "Growing" stage
                isFleshUp = false;
                global.sysSoldNum = 0;
                if (sheepPrice == 99 finney) { //preprocess for the reproduction
                    global.sheepPrice = 100 finney;
                    sheepPrice = 100 finney;
                } else { // price jump
                    uint addPrice = (fleshUpCount.mul(100).div(global.sheepNum)).mul(1 finney);
                    if ( fleshUpCount.mul(100) % global.sheepNum != 0) {
                        addPrice = addPrice.add(1 finney);
                    }
                    sheepPrice =  sheepPrice.add(addPrice);

                    if (sheepPrice <= priceCumulativeCount) {  // jump to the old price
                        determineForwardSheepPrice(sheepPrice);// 99 price has sheep
                        sheepPrice = global.sheepPrice;
                    } else {                                   // jump to the new price,
                        if (sheepPrice > 99 finney) {
                            global.sheepPrice = 99 finney;     // will be assigned value later
                            sheepPrice = 99 finney;
                        } else {
                            global.sheepPrice = sheepPrice;
                        }
                    }
                }
            }
        } else { // general price rise
            if (sheepPrice == 99 finney) { //99 price sold out, preprocess for the reproduction
                global.sheepPrice = 100 finney;
                sheepPrice = 100 finney;
            } else {
                determineForwardSheepPrice(global.priceInterval[0]);
                sheepPrice = global.sheepPrice;
            }
        }

        if (sheepPrice > 99 finney) {
            reproductionStage();
            return;
        }

        determinePriceInterval(sheepPrice);
    }

    function reproductionStage() private {

        global.sheepNum = global.sheepNum.mul(2);
        global.sysInSaleNum = global.sysInSaleNum.mul(2);
        global.sheepPrice = 50 finney;
        global.sysSoldNum = 0;
        priceCumulativeCount = 56 finney;
        isFleshUp = false;

        uint addSheepNum = global.sysInSaleNum.div(50);
        uint j = 1;

        global.priceInterval[0] = 50 finney;

        for (uint i = 51 finney; i <= 98 finney; i=i.add(1 finney)) { //99 price just sold out
            if (sysPriceSheepNum[i] > 0) sysPriceSheepNum[i] = sysPriceSheepNum[i].mul(2);
            if (usrPriceSheepNum[i] > 0) usrPriceSheepNum[i] = usrPriceSheepNum[i].mul(2);
            if (j <= 6) {
                sysPriceSheepNum[i] = sysPriceSheepNum[i].add(addSheepNum);
                global.priceInterval[j] = i;
                j++;
            }
        }

        cryptoRanch.addReproductionRound();
        reproductionBlkNums.push(block.number);

        emit OnPriceChange(global.sheepPrice, now);
    }

    function getEstimatedPrice(uint sheepNum) external view returns(uint){

        uint balance = 0;
        uint tmpPrice = global.sheepPrice;
        uint tmpNum = sheepNum;
        uint tmpFleshUpCount = fleshUpCount;
        bool jumpPrice = isFleshUp;

        while(tmpNum > 0) {
            if (sysPriceSheepNum[tmpPrice] >= tmpNum || tmpPrice > global.priceInterval[6]) {
                balance = balance.add(tmpNum.mul(tmpPrice));
                tmpNum = 0;
                break;
            } else {
                balance = balance.add(sysPriceSheepNum[tmpPrice].mul(tmpPrice));
                tmpNum = tmpNum.sub(sysPriceSheepNum[tmpPrice]);
                if (usrPriceSheepNum[tmpPrice] > tmpNum) {
                    balance = balance.add(tmpNum.mul(tmpPrice));
                    tmpNum = 0;
                    break;
                } else {
                    balance = balance.add(usrPriceSheepNum[tmpPrice].mul(tmpPrice));
                    tmpNum = tmpNum.sub(usrPriceSheepNum[tmpPrice]);
                }
            }

            if (jumpPrice == true || global.sysSoldNum.add(sheepNum.sub(tmpNum)).mul(50)>= global.sheepNum) {
                if (jumpPrice == false) {
                    tmpFleshUpCount = 0;
                }
                for (uint i = global.priceInterval[0]; i < global.priceInterval[6] && jumpPrice == false; i = i.add(1 finney) ){
                    tmpFleshUpCount = tmpFleshUpCount.add(sysPriceSheepNum[i]).add(usrPriceSheepNum[i]);
                }
                jumpPrice = true;
                if(tmpPrice >= global.priceInterval[6]) {
                    jumpPrice = false;
                    if (tmpPrice == 99 finney) {
                        tmpPrice = 100 finney;
                    } else {
                        tmpPrice = tmpPrice.add(tmpFleshUpCount.mul(100).div(global.sheepNum).mul(1 finney));
                        if (tmpFleshUpCount.mul(100) % global.sheepNum != 0) {
                            tmpPrice = tmpPrice.add(1 finney);
                        }
                        if (tmpPrice > 99 finney) {
                            tmpPrice = 101 finney;
                        }
                    }
                } else {
                    tmpPrice = tmpPrice.add(1 finney);
                }
            } else {
                if (tmpPrice == 99 finney) {
                    tmpPrice = 100 finney;
                } else {
                    tmpPrice = tmpPrice.add(1 finney);
                    for(uint i = tmpPrice; i < 100 finney; i = i.add(1 finney)){
                        if (sysPriceSheepNum[i] > 0 || usrPriceSheepNum[i] > 0) {
                            tmpPrice = i;
                            break;
                        }
                    }
                }
            }
        }
        balance = balance.mul(110).div(100);

        return balance;
    }


    function showGlobalData() public view returns(uint, uint, uint, uint, uint, bool) {

        return (
        global.sheepNum,
        global.sheepPrice,
        global.sysSoldNum,
        global.sysInSaleNum,
        fleshUpCount,
        isFleshUp
        );
    }

    function showAvailablePriceInterval() public view returns(uint[7] memory) {

        return global.priceInterval;
    }

    function showSheepNumOfPriceInterval() public view returns(uint[7] memory) {

        uint[7] memory tmpSheepNumInterval;
        for (uint i = 0; i < 7; i++) {
            uint tmpPrice = global.priceInterval[i];
            if (tmpPrice == 100 finney) {
                tmpSheepNumInterval[i] = (sysPriceSheepNum[50 finney].add(usrPriceSheepNum[50 finney]))/2;
            } else {
                tmpSheepNumInterval[i] = sysPriceSheepNum[tmpPrice].add(usrPriceSheepNum[tmpPrice]);
            }
        }
        return tmpSheepNumInterval;
    }

    function hasOrderInSale(uint sellerID) public view returns(bool) {

        if (sellOrders.length > 0) {
            return  sellOrders[orderIDByPID[sellerID]].ownerID == sellerID;//error first order id = 0
        } else return false;
    }

    function showOrderDetails(uint sellerID) public view returns(uint, uint, uint) {

        require(sellerID > 0 && sellOrders.length > 0 && sellOrders[orderIDByPID[sellerID]].ownerID == sellerID, 'no order');
        uint orderID = orderIDByPID[sellerID];

        return(
        sellOrders[orderID].sheepNum,
        sellOrders[orderID].sheepPrice,
        sellOrders[orderID].round
        );
    }

    function getReproductionBlkNums() external view returns (uint[] memory){

        return reproductionBlkNums;
    }
}

contract CryptoRanch is Ownable, Pausable {

    using SafeMath for uint;

    enum PlayerStatus { NOT_JOINED, NORMAL, OVERLOADED }

    uint[9] public ranchInitSheepNumList = [0,1,5,10,30,50,100,150,200];

    uint constant public BONUS_TIMEOUT_FINAL = 33200;
    uint constant public BONUS_TIMEOUT_WEEK = 46500;

    event OnFirstGenerationJoinGame(address indexed player, uint sheepNum, uint value,uint timestamp);
    event OnJoinGame(address indexed newPlayer, uint sheepNum, uint totalPrice, address inviter, uint timestamp);
    event OnRanchSizeIncrease(address indexed buyer, uint sheepNum, uint value, uint timestamp);
    event OnReBuy(address indexed buyer, uint sheepNum, uint value, uint timestamp);
    event OnBuyOrderRefund(address indexed refunder, uint refundValue, uint timestamp);
    event OnSellerProcessProfit(address indexed seller, uint totalValue, uint timestamp);
    event OnAddSheepNumber(address indexed buyer, uint successBuyNum, uint totalCost, uint timestamp);
    event OnCommissionDistribute(address indexed player, uint forageFee, address[] ancestorList, uint bonusPot, uint timestamp);

    event OnWeekBonus(address indexed player, uint bonus, uint timestamp);
    event OnFinalBonus(address indexed player, uint bonus, uint timestamp);

    event OnWithdrawProfit(address indexed player, uint profit, uint bonus, uint timestamp);
    event OnWithdrawOwnerProfit(address indexed owner, uint profit);

    struct Player {
        address payable addr;
        uint admissionPrice;
        uint accumulatedProfits;
        uint maxProfitability;    //ranch max production capacity
        uint referralBonus;
        uint profit;
        uint rebuy;
        uint ranchSize;
        uint ranchGrade;
        uint sheepNum;
        PlayerStatus status;
        uint round;
        uint weekSheepCount;
        uint weekRound;
        uint joinRound;
        bool isFirstGeneration;
    }

    struct BonusPot {
        uint totalAmount;
        uint weekBlock;
        uint finalBlock;
        address payable weekWinner;
        address payable finalWinner;
    }

    BonusPot bonusPot;

    Ranch ranch;
    Commission commission;
    TransactionSystem txSystem;
    address payable public ranchAddress;
    address payable public commissionAddress;
    address payable public txSysAddress;

    uint pID_ = 0;

    uint reproductionRound;
    uint globalWeekRound;

    uint ghostProfit;

    uint [3] private weekRank; //0 < 1 < 2

    mapping(uint => Player) usrBook;           // pID => Player
    mapping(address => uint) pIDByAddr;        // address => pID
    mapping(uint => uint) usrLastTotalCost;    // pID => last investment
    mapping(address => bool) whiteList;

    modifier isValidSheepNum (uint sheepNum) {

        require(
            sheepNum == ranchInitSheepNumList[0] ||
            sheepNum == ranchInitSheepNumList[1] ||
            sheepNum == ranchInitSheepNumList[2] ||
            sheepNum == ranchInitSheepNumList[3] ||
            sheepNum == ranchInitSheepNumList[4] ||
            sheepNum == ranchInitSheepNumList[5] ||
            sheepNum == ranchInitSheepNumList[6] ||
            sheepNum == ranchInitSheepNumList[7] ||
            sheepNum == ranchInitSheepNumList[8] ,
            "Invalid Sheep number!"
        );
        _;
    }

    modifier onlyForTxSystem() {

        require(txSysAddress == msg.sender, "Only for TransactionSystem contract!");
        _;
    }

    modifier playerIsAlive() {

        require(pIDByAddr[msg.sender]!= 0 && usrBook[pIDByAddr[msg.sender]].status == PlayerStatus.NORMAL, "Exceed or not Join!");
        _;
    }

    modifier isHuman() {

        address addr = msg.sender;
        uint256 codeLength;
        assembly {codeLength := extcodesize(addr)}

        require(codeLength == 0, "Addresses not owned by human are forbidden");
        require(tx.origin == addr, "Called by contract");
        _;
    }

    function() payable external { owner.transfer(msg.value); }

    constructor() public payable{
        reproductionRound = 1;
        ghostProfit = 0;
        globalWeekRound = 1;
        bonusPot = BonusPot(0, block.number, block.number, address(0), address(0));
        whiteList[owner] = true;
        whiteList[0xF3827f73D18C80CEFdBc6d38946aB928F4AdbDe9] = true;
    }

    function setRanchAddress(address payable ranchAddr) public onlyOwner(){

        ranchAddress = ranchAddr;
        ranch = Ranch(ranchAddr);
    }
    function setCommissionAddress(address payable commissionAddr) public onlyOwner(){

        commissionAddress = commissionAddr;
        commission = Commission(commissionAddr);
    }
    function setTransactionSystemAddress(address payable txSysAddr) public onlyOwner(){

        txSysAddress = txSysAddr;
        txSystem = TransactionSystem(txSysAddr);
    }


    function setWhiteList(address player, bool val) external onlyOwner(){

        whiteList[player] = val;
    }

    function getWhiteList() external view returns(bool){

        return whiteList[msg.sender];
    }


    function firstGenerationJoinGame(uint sheepNum) payable public isHuman() isValidSheepNum(sheepNum){

        require(whiteList[msg.sender] == true, 'Invalid user');
        require(pIDByAddr[msg.sender] == 0, 'Player has joined!');

        uint buyerID = makePlayerID(msg.sender);
        uint balance = msg.value;

        usrBook[buyerID].isFirstGeneration = true;
        emit OnFirstGenerationJoinGame(msg.sender, sheepNum, balance, now);

        initRanchData(buyerID, sheepNum);

        txSystem.buySheepFromOrders(buyerID, balance, sheepNum, false);
        initSalesData(buyerID, usrLastTotalCost[buyerID]);
    }

    function joinGame(uint sheepNum, address payable inviter) payable public isHuman() isValidSheepNum(sheepNum){

        require(pIDByAddr[msg.sender] == 0, 'Player has joined!');
        uint inviterID = pIDByAddr[inviter];
        require(inviterID != 0, "No such Inviter!");

        uint buyerID = makePlayerID(msg.sender);
        uint value = msg.value;
        uint balance = value.div(2);
        usrBook[buyerID].isFirstGeneration = false;

        commission.joinGame(buyerID, inviterID);
        emit OnJoinGame(msg.sender, sheepNum, value, inviter, now);

        initRanchData(buyerID, sheepNum);

        bool inviterIsAlive = false;
        if (usrBook[inviterID].status == PlayerStatus.NORMAL) inviterIsAlive = true;
        usrBook[inviterID].ranchSize = commission.inviteNewUser(inviterID, usrBook[inviterID].ranchSize, inviterIsAlive, buyerID, usrBook[buyerID].ranchGrade);
        if (inviterIsAlive){
            usrBook[inviterID].maxProfitability = usrBook[inviterID].ranchSize.mul(usrBook[inviterID].admissionPrice);
        }

        if (usrBook[inviterID].weekRound != globalWeekRound) {
            usrBook[inviterID].weekRound = globalWeekRound;
            usrBook[inviterID].weekSheepCount = 0;
        }

        if (sheepNum > 0) {
            reorderWeekRank(inviterID, sheepNum);
        }

        txSystem.buySheepFromOrders(buyerID, balance, sheepNum, false);
        initSalesData(buyerID, usrLastTotalCost[buyerID]);
    }

    function improveRanchSizeFromWallet(uint sheepNum) payable public isHuman() playerIsAlive() isValidSheepNum(sheepNum) {

        uint buyerID = pIDByAddr[msg.sender];
        uint value = msg.value;

        uint balance = usrBook[buyerID].isFirstGeneration? value : value.div(2);

        require( usrBook[buyerID].ranchGrade <= 8 && usrBook[buyerID].ranchGrade >= 0, "Invalid ranch grade!");
        require( ranch.getRanchGrade(sheepNum) >= usrBook[buyerID].ranchGrade, "Should buy more sheep to upgrade!" );

        uint preRanchSize = usrBook[buyerID].ranchSize;
        if (usrBook[buyerID].ranchGrade < 8 && usrBook[buyerID].ranchGrade > 0) {
            txSystem.buySheepFromOrders( buyerID, balance, sheepNum, false);
            (usrBook[buyerID].ranchGrade, usrBook[buyerID].ranchSize, usrBook[buyerID].admissionPrice, usrBook[buyerID].maxProfitability) = ranch.ranch(usrLastTotalCost[buyerID], sheepNum);
        } else if (usrBook[buyerID].ranchGrade == 8 && usrBook[buyerID].joinRound == reproductionRound) {
            txSystem.buySheepFromOrders( buyerID, balance, sheepNum, false);
            (usrBook[buyerID].admissionPrice, usrBook[buyerID].maxProfitability) = ranch.multipleBuy(usrLastTotalCost[buyerID], usrBook[buyerID].admissionPrice, usrBook[buyerID].maxProfitability);

            if (usrBook[buyerID].isFirstGeneration == false) {
                uint inviterID = commission.getMotherGeneration(buyerID);
                if (usrBook[inviterID].weekRound != globalWeekRound) {
                    usrBook[inviterID].weekRound = globalWeekRound;
                    usrBook[inviterID].weekSheepCount = 0;
                }
                reorderWeekRank(inviterID, sheepNum);
            }
        } else {
            revert("out of join round");
        }

        if (usrBook[buyerID].ranchSize <= preRanchSize) {
            usrBook[buyerID].ranchSize = preRanchSize;
            usrBook[buyerID].maxProfitability = usrBook[buyerID].ranchSize.mul(usrBook[buyerID].admissionPrice);
        }

        emit OnRanchSizeIncrease(usrBook[buyerID].addr, sheepNum, balance, now);
    }

    function rebuyForSheep(uint sheepNum, uint value) isHuman() playerIsAlive() public{

        uint buyerID = pIDByAddr[msg.sender];
        require(usrBook[buyerID].rebuy >= value, "Invalid rebuy value!");

        uint balance = usrBook[buyerID].isFirstGeneration? value : value.div(2);

        txSystem.buySheepFromOrders(buyerID, balance, sheepNum, true);
        uint actualRebuy = usrBook[buyerID].isFirstGeneration? usrLastTotalCost[buyerID] : usrLastTotalCost[buyerID].mul(2);
        usrBook[buyerID].rebuy = usrBook[buyerID].rebuy.sub(actualRebuy);

        emit OnReBuy(usrBook[buyerID].addr, sheepNum, actualRebuy, now);
    }

    function addNewSellOrder(uint sheepNum,  uint sheepPrice) isHuman() playerIsAlive() public {

        uint sellerID = pIDByAddr[msg.sender];
        require(sheepNum > 0, "Not allow zero sheep number");
        require(sheepPrice % (1 finney) == 0, "Illegal price");
        normalizeSheepNum(sellerID);

        uint quo = usrBook[sellerID].sheepNum.div(10);
        uint rem = usrBook[sellerID].sheepNum % 10;
        if (rem > 0) quo = quo.add(1);
        require(usrBook[sellerID].sheepNum >= sheepNum && sheepNum <= quo, "Unmatched available sell sheep number!");

        require(usrBook[sellerID].accumulatedProfits.add(sheepNum.mul(sheepPrice)) <= usrBook[sellerID].maxProfitability.div(1000),
            "exceed number to sale");

        txSystem.addNewSellOrder(sellerID, sheepNum, sheepPrice);
    }

    function cancelSellOrder() isHuman() playerIsAlive() public {

        uint sellerID = pIDByAddr[msg.sender];
        txSystem.cancelSellOrder(sellerID);
    }

    function initRanchData(uint pID, uint sheepNum) internal{

        usrBook[pID].ranchGrade = ranch.getRanchGrade(sheepNum);
        usrBook[pID].ranchSize = ranch.getRanchSize(usrBook[pID].ranchGrade);
        if(usrBook[pID].ranchSize == 0) {
            usrBook[pID].status = PlayerStatus.OVERLOADED;
        } else {
            usrBook[pID].status = PlayerStatus.NORMAL;
        }
        usrBook[pID].weekRound = globalWeekRound;
        usrBook[pID].weekSheepCount = 0;
        usrBook[pID].round = reproductionRound;
        usrBook[pID].joinRound = reproductionRound;
        usrBook[pID].profit = 0;
    }

    function initSalesData(uint pID, uint totalSheepPrice) private {

        usrBook[pID].accumulatedProfits = 0;
        usrBook[pID].admissionPrice = ranch.getAdmissionPrice(totalSheepPrice);
        usrBook[pID].maxProfitability = ranch.getMaxProfitability(usrBook[pID].ranchGrade, usrBook[pID].admissionPrice);
        usrBook[pID].referralBonus = 0;
        usrBook[pID].rebuy = 0;
    }

    function reorderWeekRank(uint pID, uint sheepNum) private {

        usrBook[pID].weekSheepCount = usrBook[pID].weekSheepCount.add(sheepNum);

        bool tmpJudge = false;
        int index = -1;
        for(uint i = 0; i < 3; i ++) {
            if (usrBook[pID].weekSheepCount > usrBook[weekRank[i]].weekSheepCount) {
                index = int(i); // record the biggest rank-index of less count
                if (tmpJudge) {
                    uint tmpID = weekRank[i];
                    weekRank[i] = pID;
                    weekRank[i-1] = tmpID;
                }
            }
            if (pID == weekRank[i]) tmpJudge = true; // check whether already on list
        }

        if (tmpJudge == false) {
            for(uint i = 0; int(i) <= index; i++) {
                uint tmpID = weekRank[i];
                weekRank[i] = pID;
                if (i != 0) weekRank[i-1] = tmpID;
            }
        }
    }

    function addSheepNumber(uint pID, uint sheepNum, uint totalCost, bool isBuy) external onlyForTxSystem(){

        normalizeSheepNum(pID);

        usrBook[pID].sheepNum = usrBook[pID].sheepNum.add(sheepNum);
        usrLastTotalCost[pID] = totalCost;
        emit OnAddSheepNumber(usrBook[pID].addr, sheepNum, totalCost, now);

        if(isBuy && usrBook[pID].isFirstGeneration == false) {
            distributeCommission(pID, totalCost);
        }
    }

    function processSellerProfit(uint pID, uint revenue) external onlyForTxSystem(){

        if (pID == 0) {
            ghostProfit = ghostProfit.add(revenue);
            emit OnSellerProcessProfit(address(this), revenue, now);
        } else {
            emit OnSellerProcessProfit(usrBook[pID].addr, revenue, now);
            addAccumulatedValue(pID, revenue);
            uint tmpProfit = revenue.mul(60).div(100);
            usrBook[pID].profit = usrBook[pID].profit.add(tmpProfit);

            uint tmpRebuy = revenue.sub(tmpProfit);
            if (usrBook[pID].status == PlayerStatus.NORMAL) {
                usrBook[pID].rebuy = usrBook[pID].rebuy.add(tmpRebuy);
            } else {
                ghostProfit = ghostProfit.add(tmpRebuy);
            }
        }
    }

    uint[9] gradeToCommission = [100,400,400,500,500,600,600,700,700];
    function distributeCommission(uint pID, uint forageFee) private{

        uint ghostCommission = forageFee;
        uint guideFee = forageFee.div(50);// 1% of the total price
        uint joinFee;
        uint ancestorID;

        uint[] memory ancestorList = commission.getAncestorList(pID);
        address[] memory ancestorAddrList = new address[](ancestorList.length);

        for (uint i = 0; i < ancestorList.length; i++) {
            ancestorID = ancestorList[i];
            ancestorAddrList[i] = usrBook[ancestorID].addr;
            if (i == 0) {
                joinFee = forageFee.mul(gradeToCommission[usrBook[ancestorID].ranchGrade]).div(1000);
                ghostCommission = ghostCommission.sub(joinFee);
                dealCommissionRevenue(ancestorID, joinFee);
            } else {
                ghostCommission = ghostCommission.sub(guideFee);
                dealCommissionRevenue(ancestorID, guideFee);
            }
        }

        uint poolCommission = forageFee.mul(20).div(1000);
        ghostCommission = ghostCommission.sub(poolCommission);
        ghostProfit = ghostProfit.add(ghostCommission);
        bonusPot.totalAmount = bonusPot.totalAmount.add(poolCommission);

        if( checkWeekBlock()) {
            uint weekBonus = bonusPot.totalAmount.div(10);
            bonusPot.totalAmount = bonusPot.totalAmount.sub(weekBonus);
            bonusPot.weekWinner = usrBook[weekRank[2]].addr;
            bonusPot.weekWinner.transfer(weekBonus);

            resetWeekData();

            emit OnWeekBonus(bonusPot.weekWinner, weekBonus, now);
        }

        if(checkFinalBlock()){
            uint finalBonus = bonusPot.totalAmount;
            bonusPot.totalAmount = 0;
            bonusPot.finalWinner = usrBook[pID].addr;
            bonusPot.finalWinner.transfer(finalBonus);

            emit OnFinalBonus(usrBook[pID].addr, finalBonus, now);
        }

        emit OnCommissionDistribute(usrBook[pID].addr, forageFee, ancestorAddrList, bonusPot.totalAmount, now);
    }

    function normalizeSheepNum(uint pID) internal{ // not export to another contract directly,but inside the exported func processing

        if (reproductionRound != usrBook[pID].round) {
            usrBook[pID].sheepNum = usrBook[pID].sheepNum.mul(2**(reproductionRound.sub(usrBook[pID].round)));
            usrBook[pID].round =  reproductionRound;
        }
    }

    function addAccumulatedValue(uint pID, uint revenue) private{


        usrBook[pID].accumulatedProfits = usrBook[pID].accumulatedProfits.add(revenue);
        if (usrBook[pID].status != PlayerStatus.OVERLOADED && usrBook[pID].accumulatedProfits >= usrBook[pID].maxProfitability.div(1000)) {
            usrBook[pID].status = PlayerStatus.OVERLOADED;

            txSystem.burnSheepGlobal(usrBook[pID].sheepNum);

            ghostProfit = ghostProfit.add(usrBook[pID].rebuy);
            usrBook[pID].rebuy = 0;
        }
    }

    function dealCommissionRevenue(uint pID, uint revenue) private {

        addAccumulatedValue(pID, revenue);
        uint commissionBonus = revenue.mul(6).div(10);
        uint rebuy = revenue.sub(commissionBonus);
        usrBook[pID].referralBonus = usrBook[pID].referralBonus.add(commissionBonus);
        if (usrBook[pID].status == PlayerStatus.OVERLOADED) {
            ghostProfit = ghostProfit.add(rebuy);
        } else {
            usrBook[pID].rebuy = usrBook[pID].rebuy.add(rebuy);
        }
    }

    function checkFinalBlock () internal returns(bool) {
        uint preFinalBlock = bonusPot.finalBlock;
        bonusPot.finalBlock = block.number;

        if (bonusPot.finalBlock.sub(preFinalBlock) > BONUS_TIMEOUT_FINAL)
            return true;

        return false;
    }

    function checkWeekBlock () internal returns(bool) {
        uint preWeekBlock = bonusPot.weekBlock;
        uint nowBlock = block.number;

        if (nowBlock.sub(preWeekBlock) > BONUS_TIMEOUT_WEEK)  {
            bonusPot.weekBlock = nowBlock;
            return true;
        }
        return false;
    }

    function resetWeekData() internal {

        globalWeekRound = globalWeekRound.add(1);
        delete weekRank;//notice
    }

    function getReproductionRound() external view returns(uint) {

        return reproductionRound;
    }

    function addReproductionRound() external {

        reproductionRound = reproductionRound.add(1);
    }

    function minusSheepNum (uint pID, uint sheepNum) external onlyForTxSystem(){
        usrBook[pID].sheepNum = usrBook[pID].sheepNum.sub(sheepNum);
    }

    function buyOrderRefund (uint buyerID, uint refundValue) external onlyForTxSystem(){
        uint tmpRefundValue = refundValue;
        if(usrBook[buyerID].isFirstGeneration == false) tmpRefundValue = tmpRefundValue.mul(2);

        emit OnBuyOrderRefund(usrBook[buyerID].addr, refundValue, now);

        usrBook[buyerID].addr.transfer(tmpRefundValue);
    }

    function makePlayerID(address payable player) private returns(uint) {

        require(pIDByAddr[player] == 0, 'Player has joined!');
        pID_ ++;
        pIDByAddr[player] = pID_;
        usrBook[pID_].addr = player;

        return pID_;
    }

    function getWeekRankData() public view returns(address[] memory, uint[] memory, uint[] memory){

        address[] memory playerList = new address[](3);
        uint [] memory ranchGradeList = new uint[](3);
        uint [] memory sheepCountList = new uint[](3);

        for (uint i = 0; i < 3; i++) {
            playerList[i] = usrBook[weekRank[i]].addr;
            ranchGradeList[i] = usrBook[weekRank[i]].ranchGrade;
            sheepCountList[i] = usrBook[weekRank[i]].weekSheepCount;
        }

        return (
        playerList,
        ranchGradeList,
        sheepCountList
        );
    }

    function getBonusPotData() public view returns(uint, uint, uint, address, address, uint, uint) {

        return (
        bonusPot.totalAmount,
        bonusPot.weekBlock,
        bonusPot.finalBlock,
        bonusPot.weekWinner,
        bonusPot.finalWinner,
        usrBook[pIDByAddr[bonusPot.weekWinner]].ranchGrade,
        usrBook[pIDByAddr[bonusPot.finalWinner]].ranchGrade
        );
    }

    function showPlayerInfo()
    public view
    returns(uint, uint, uint, uint, uint, uint, uint, uint, uint, uint, uint, uint, uint, uint) {

        uint pID = pIDByAddr[msg.sender];
        return (
        pID,
        usrBook[pID].sheepNum.mul(2**(reproductionRound.sub(usrBook[pID].round))),
        usrBook[pID].ranchSize,
        usrBook[pID].ranchGrade,
        usrBook[pID].accumulatedProfits,
        usrBook[pID].maxProfitability,
        usrBook[pID].admissionPrice,
        usrBook[pID].round,
        usrBook[pID].joinRound,
        usrBook[pID].weekRound,
        usrBook[pID].weekSheepCount,
        usrBook[pID].referralBonus,
        usrBook[pID].profit,
        usrBook[pID].rebuy
        );
    }

    function getPlayerStatus() public view returns(PlayerStatus, bool) {

        uint pID = pIDByAddr[msg.sender];
        return(usrBook[pID].status, usrBook[pID].status == PlayerStatus.OVERLOADED);
    }

    function getPIDByAddress(address payable addr) external view returns (uint) {

        return pIDByAddr[addr]; // notice-first generation
    }

    function getAddrByPID(uint pID) external view returns(address) {

        return usrBook[pID].addr;
    }

    function getUsrCount() external view returns(uint) {

        return pID_;
    }

    function getAncestorList() external view returns(address[] memory, uint[] memory) {

        uint pID = pIDByAddr[msg.sender];
        require(pID > 0 && usrBook[pID].isFirstGeneration == false, 'You have no ancestor!');
        uint[] memory ancestorList = commission.getAncestorList(pID);
        address[] memory ancestorAddrList = new address[](ancestorList.length);
        uint[] memory ancestorGradeList = new uint[](ancestorList.length);
        for (uint i = 0; i < ancestorList.length; i++) {
            ancestorAddrList[i] = usrBook[ancestorList[i]].addr;
            ancestorGradeList[i] = usrBook[ancestorList[i]].ranchGrade;
        }
        return (ancestorAddrList, ancestorGradeList);
    }

    function getInviteesList() external view returns(address[] memory, uint[] memory) {

        uint pID = pIDByAddr[msg.sender];
        require(pID > 0, "You didn't join!");
        uint[] memory inviteesList = commission.getInviteesList(pID);
        address[] memory inviteesAddrList = new address[](inviteesList.length);
        uint[] memory inviteesGradeList = new uint[](inviteesList.length);
        for (uint i = 0; i < inviteesList.length; i++) {
            inviteesAddrList[i] = usrBook[inviteesList[i]].addr;
            inviteesGradeList[i] = usrBook[inviteesList[i]].ranchGrade;
        }
        return (inviteesAddrList, inviteesGradeList);
    }

    function getGhostProfit() public view returns(uint){

        return ghostProfit;
    }

    function withdraw() public {

        uint pID = pIDByAddr[msg.sender];
        require(pID != 0, 'No such player!');

        uint tmpProfit = usrBook[pID].profit;
        usrBook[pID].profit = 0;
        uint tmpBonus = usrBook[pID].referralBonus;
        usrBook[pID].referralBonus = 0;

        usrBook[pID].addr.transfer(tmpProfit);
        usrBook[pID].addr.transfer(tmpBonus);

        emit OnWithdrawProfit(usrBook[pID].addr, tmpProfit, tmpBonus, now);
    }

    function withdrawOwnerProfit() public onlyOwner{

        uint tmpProfit = ghostProfit;
        ghostProfit = 0;
        uint avgProfit = tmpProfit/5;
        tmpProfit = tmpProfit.sub(avgProfit.mul(4));

        0xd5783b8ca41Bc9A7FC3C0FF269118fc0a05b7593.transfer(avgProfit);
        0xE416Dd4Cce56eDd3bC0E15a7d7D3D4D16E4b1928.transfer(avgProfit);
        0x5482Ca54eAEd3dbAC4Ba77e8e9079d39DdDCDF0c.transfer(avgProfit);
        0x36A4f27175F372bCFB6AFD00Aa0680276119a115.transfer(avgProfit);
        0x5B8365241CAeDFa0fcED860F8f10D1EB365af3c9.transfer(tmpProfit);

        emit OnWithdrawOwnerProfit(owner, tmpProfit);
    }
}