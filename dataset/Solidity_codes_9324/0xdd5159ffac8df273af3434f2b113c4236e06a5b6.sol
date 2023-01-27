

pragma solidity 0.4.25;


library SafeMath {


    function mul(uint256 a, uint256 b) internal pure returns(uint256) {

        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns(uint256) {

        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns(uint256) {

        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns(uint256) {

        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract ReentrancyGuard {


    uint256 private _guardCounter;

    constructor() internal {
        _guardCounter = 1;
    }

    modifier nonReentrant() {

        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter);
    }

}

contract OPTIMAX is ReentrancyGuard {

    using SafeMath for uint;
    mapping(address => uint) public userDeposit;
    mapping(address => address) public userReferral;
    mapping(address => uint) public refferalCollected;
    mapping(address => uint) public usersCashback;
    mapping(address => uint) public userTime;
    mapping(address => uint) public persentWithdraw;
    mapping(address => bool) public alreadyDeposited;
    address public marketingFund = 0xB2a0280d1Aff4DDc5BC53fCfFDD4B2E8bA0bbac8;
    address public devFund = 0xaE232535a8B0EB649e6223c113BB4e291fE368A7;
    uint marketingPercent = 14;
    uint public devPercent = 6;
    uint public refPercent = 4;
    uint public chargingTime = 12 hours;
    
    uint public persent = 1000;

    uint public countOfInvestors = 0;
    uint public countOfDev = 0;
    
    uint public minDepCashBackLevel1 = 100 finney;
    uint public maxDepCashBackLevel1 = 3 ether;
    uint public maxDepCashBackLevel2 = 7 ether;
    uint public maxDepCashBackLevel3 = 10000 ether;
    
    uint public beginCashBackTime1 = 1587556800;     // begin of the action 22.04.2020
    uint public endCashBackTime1 = 1587643200;       // end of the action 23.04.2020
    uint public cashbackPercent1level1 = 25;       // cashback persent 25 = 2.5%
    uint public cashbackPercent1level2 = 35;       // cashback persent 35 = 3.5%
    uint public cashbackPercent1level3 = 50;       // cashback persent 50 = 5%

    uint public beginCashBackTime2 = 1588334400;     // begin of the action 01.05.2020
    uint public endCashBackTime2 = 1588507200;       // end of the action 03.05.2020
    uint public cashbackPercent2level1 = 30;       
    uint public cashbackPercent2level2 = 50;       
    uint public cashbackPercent2level3 = 70;       

    uint public beginCashBackTime3 = 1589198400;     // begin of the action 11.05.2020 
    uint public endCashBackTime3 = 1589457600;       // end of the action 14.05.2020
    uint public cashbackPercent3level1 = 50;       
    uint public cashbackPercent3level2 = 80;       
    uint public cashbackPercent3level3 = 100;      

    uint public beginCashBackTime4 = 1590235200;     // begin of the action 23.05.2020
    uint public endCashBackTime4 = 1590494400;       // end of the action 26.05.2020 
    uint public cashbackPercent4level1 = 70;       
    uint public cashbackPercent4level2 = 100;       
    uint public cashbackPercent4level3 = 150;      

    uint public beginCashBackTime5 = 1591358400;     // begin of the action 05.06.2020
    uint public endCashBackTime5 = 1591617600;       // end of the action 08.06.2020 
    uint public cashbackPercent5level1 = 25;       
    uint public cashbackPercent5level2 = 35;       
    uint public cashbackPercent5level3 = 50;      

    uint public beginCashBackTime6 = 1592654400;     // begin of the action 20.06.2020 
    uint public endCashBackTime6 = 1592913600;       // end of the action 23.06.2020
    uint public cashbackPercent6level1 = 30;       
    uint public cashbackPercent6level2 = 50;       
    uint public cashbackPercent6level3 = 70;      

    uint public beginCashBackTime7 = 1594382400;     // begin of the action 10.07.2020
    uint public endCashBackTime7 = 1594728000;       // end of the action 14.07.2020
    uint public cashbackPercent7level1 = 50;       
    uint public cashbackPercent7level2 = 80;       
    uint public cashbackPercent7level3 = 100;      

    uint public beginCashBackTime8 = 1595764800;     // begin of the action 26.07.2020
    uint public endCashBackTime8 = 1596110400;       // end of the action 30.07.2020
    uint public cashbackPercent8level1 = 70;       
    uint public cashbackPercent8level2 = 100;       
    uint public cashbackPercent8level3 = 150;      


    modifier isIssetUser() {

        require(userDeposit[msg.sender] > 0, "Deposit not found");
        _;
    }

    modifier timePayment() {

        require(now >= userTime[msg.sender].add(chargingTime), "Too fast payout request");
        _;
    }

    function() external payable {
        require (msg.sender != marketingFund && msg.sender != devFund);
        makeDeposit();
    }


    function makeDeposit() nonReentrant private {

        if (usersCashback[msg.sender] > 0) collectCashback();
        if (msg.value > 0) {

            if (!alreadyDeposited[msg.sender]) {
                countOfInvestors += 1;
                address referrer = bytesToAddress(msg.data);
                if (referrer != msg.sender) userReferral[msg.sender] = referrer;
                alreadyDeposited[msg.sender] = true;
            }

            if (userReferral[msg.sender] != address(0)) {
                uint refAmount = msg.value.mul(refPercent).div(100);
                userReferral[msg.sender].transfer(refAmount);
                refferalCollected[userReferral[msg.sender]] = refferalCollected[userReferral[msg.sender]].add(refAmount);
            }

            if (userDeposit[msg.sender] > 0 && now > userTime[msg.sender].add(chargingTime)) {
                collectPercent();
            }

            userDeposit[msg.sender] = userDeposit[msg.sender].add(msg.value);
            userTime[msg.sender] = now;
            chargeCashBack();

            marketingFund.transfer(msg.value.mul(marketingPercent).div(100));
            uint devMoney = msg.value.mul(devPercent).div(100);
            countOfDev = countOfDev.add(devMoney);
            devFund.transfer(devMoney);

        } else {
            collectPercent();
        }
    }

    function collectCashback() private {

        uint val = usersCashback[msg.sender];
        usersCashback[msg.sender] = 0;
        msg.sender.transfer(val);
    }

    function chargeCashBack() private {

        uint cashbackValue = 0;
        if ( (now >= beginCashBackTime1) && (now<=endCashBackTime1) ){
            if ( (msg.value >= minDepCashBackLevel1) && (msg.value <= maxDepCashBackLevel1) ) cashbackValue = msg.value.mul(cashbackPercent1level1).div(1000);
            if ( (msg.value > maxDepCashBackLevel1) && (msg.value <= maxDepCashBackLevel2) ) cashbackValue = msg.value.mul(cashbackPercent1level2).div(1000);
            if ( (msg.value > maxDepCashBackLevel2) && (msg.value <= maxDepCashBackLevel3) ) cashbackValue = msg.value.mul(cashbackPercent1level3).div(1000);
        }
        if ( (now >= beginCashBackTime2) && (now<=endCashBackTime2) ){
            if ( (msg.value >= minDepCashBackLevel1) && (msg.value <= maxDepCashBackLevel1) ) cashbackValue = msg.value.mul(cashbackPercent2level1).div(1000);
            if ( (msg.value > maxDepCashBackLevel1) && (msg.value <= maxDepCashBackLevel2) ) cashbackValue = msg.value.mul(cashbackPercent2level2).div(1000);
            if ( (msg.value > maxDepCashBackLevel2) && (msg.value <= maxDepCashBackLevel3) ) cashbackValue = msg.value.mul(cashbackPercent2level3).div(1000);
        }
        if ( (now >= beginCashBackTime3) && (now<=endCashBackTime3) ){
            if ( (msg.value >= minDepCashBackLevel1) && (msg.value <= maxDepCashBackLevel1) ) cashbackValue = msg.value.mul(cashbackPercent3level1).div(1000);
            if ( (msg.value > maxDepCashBackLevel1) && (msg.value <= maxDepCashBackLevel2) ) cashbackValue = msg.value.mul(cashbackPercent3level2).div(1000);
            if ( (msg.value > maxDepCashBackLevel2) && (msg.value <= maxDepCashBackLevel3) ) cashbackValue = msg.value.mul(cashbackPercent3level3).div(1000);
        }
        if ( (now >= beginCashBackTime4) && (now<=endCashBackTime4) ){
            if ( (msg.value >= minDepCashBackLevel1) && (msg.value <= maxDepCashBackLevel1) ) cashbackValue = msg.value.mul(cashbackPercent4level1).div(1000);
            if ( (msg.value > maxDepCashBackLevel1) && (msg.value <= maxDepCashBackLevel2) ) cashbackValue = msg.value.mul(cashbackPercent4level2).div(1000);
            if ( (msg.value > maxDepCashBackLevel2) && (msg.value <= maxDepCashBackLevel3) ) cashbackValue = msg.value.mul(cashbackPercent4level3).div(1000);
        }
        if ( (now >= beginCashBackTime5) && (now<=endCashBackTime5) ){
            if ( (msg.value >= minDepCashBackLevel1) && (msg.value <= maxDepCashBackLevel1) ) cashbackValue = msg.value.mul(cashbackPercent5level1).div(1000);
            if ( (msg.value > maxDepCashBackLevel1) && (msg.value <= maxDepCashBackLevel2) ) cashbackValue = msg.value.mul(cashbackPercent5level2).div(1000);
            if ( (msg.value > maxDepCashBackLevel2) && (msg.value <= maxDepCashBackLevel3) ) cashbackValue = msg.value.mul(cashbackPercent5level3).div(1000);
        }
        if ( (now >= beginCashBackTime6) && (now<=endCashBackTime6) ){
            if ( (msg.value >= minDepCashBackLevel1) && (msg.value <= maxDepCashBackLevel1) ) cashbackValue = msg.value.mul(cashbackPercent6level1).div(1000);
            if ( (msg.value > maxDepCashBackLevel1) && (msg.value <= maxDepCashBackLevel2) ) cashbackValue = msg.value.mul(cashbackPercent6level2).div(1000);
            if ( (msg.value > maxDepCashBackLevel2) && (msg.value <= maxDepCashBackLevel3) ) cashbackValue = msg.value.mul(cashbackPercent6level3).div(1000);
        }
        if ( (now >= beginCashBackTime7) && (now<=endCashBackTime7) ){
            if ( (msg.value >= minDepCashBackLevel1) && (msg.value <= maxDepCashBackLevel1) ) cashbackValue = msg.value.mul(cashbackPercent7level1).div(1000);
            if ( (msg.value > maxDepCashBackLevel1) && (msg.value <= maxDepCashBackLevel2) ) cashbackValue = msg.value.mul(cashbackPercent7level2).div(1000);
            if ( (msg.value > maxDepCashBackLevel2) && (msg.value <= maxDepCashBackLevel3) ) cashbackValue = msg.value.mul(cashbackPercent7level3).div(1000);
        }
        if ( (now >= beginCashBackTime8) && (now<=endCashBackTime8) ){
            if ( (msg.value >= minDepCashBackLevel1) && (msg.value <= maxDepCashBackLevel1) ) cashbackValue = msg.value.mul(cashbackPercent8level1).div(1000);
            if ( (msg.value > maxDepCashBackLevel1) && (msg.value <= maxDepCashBackLevel2) ) cashbackValue = msg.value.mul(cashbackPercent8level2).div(1000);
            if ( (msg.value > maxDepCashBackLevel2) && (msg.value <= maxDepCashBackLevel3) ) cashbackValue = msg.value.mul(cashbackPercent8level3).div(1000);
        }

        usersCashback[msg.sender] = usersCashback[msg.sender].add(cashbackValue);
    }
    
    function collectPercent() isIssetUser timePayment internal {

        if ((userDeposit[msg.sender].mul(15).div(10)) <= persentWithdraw[msg.sender]) {
            userDeposit[msg.sender] = 0;
            userTime[msg.sender] = 0;
            persentWithdraw[msg.sender] = 0;
        } else {
            uint payout = payoutAmount();
            userTime[msg.sender] = now;
            persentWithdraw[msg.sender] += payout;
            msg.sender.transfer(payout);
        }
    }


    function bytesToAddress(bytes bys) private pure returns (address addr) {

        assembly {
            addr := mload(add(bys, 20))
        }
    }

    function payoutAmount() public view returns(uint) {

        uint rate = userDeposit[msg.sender].mul(persent).div(100000);
        uint interestRate = now.sub(userTime[msg.sender]).div(chargingTime);
        uint withdrawalAmount = rate.mul(interestRate).add(usersCashback[msg.sender]);
        return (withdrawalAmount);
    }

    function userPayoutAmount(address _user) public view returns(uint) {

        uint rate = userDeposit[_user].mul(persent).div(100000);
        uint interestRate = now.sub(userTime[_user]).div(chargingTime);
        uint withdrawalAmount = rate.mul(interestRate).add(usersCashback[_user]);
        return (withdrawalAmount);
    }

    function getInvestedAmount(address investor) public view returns(uint) {

        return userDeposit[investor];
    }
    
    function getLastDepositeTime(address investor) public view returns(uint) {

        return userTime[investor];
    }
    
    function getPercentWitdraw(address investor) public view returns(uint) {

        return persentWithdraw[investor];
    }
    
    function getRefferalsCollected(address refferal) public view returns(uint) {

        return refferalCollected[refferal];
    }
    
}