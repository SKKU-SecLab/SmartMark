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

}//Unlicense
pragma solidity 0.4.25;


contract X2Restart {

    using SafeMath for uint256;
    mapping(address => uint256) public userDeposit;
    mapping(address => uint256) public userTime;
    mapping(address => uint256) public persentWithdraw;
    address public projectFund = 0xb615E5c6d21Ae628eA4490e2653b9aEb0a3902b5;
    address public charityFund = 0x206448E6C7D9833af63fFe2335cfF49D5f6d0dff;
    uint256 projectPercent = 8;
    uint256 public charityPercent = 1;
    uint256 public chargingTime = 1 hours;
    uint256 public startPercent = 250;
    uint256 public lowPersent = 300;
    uint256 public middlePersent = 350;
    uint256 public highPersent = 375;
    uint256 public stepLow = 1000 ether;
    uint256 public stepMiddle = 2500 ether;
    uint256 public stepHigh = 5000 ether;
    uint256 public countOfInvestors = 0;
    uint256 public countOfCharity = 0;

    modifier isIssetUser() {

        require(userDeposit[msg.sender] > 0, "Deposit not found");
        _;
    }

    modifier timePayment() {

        require(
            now >= userTime[msg.sender].add(chargingTime),
            "Too fast payout request"
        );
        _;
    }

    function collectPercent() internal isIssetUser timePayment {

        address msgSender = msg.sender;
        if ((userDeposit[msgSender].mul(2)) <= persentWithdraw[msgSender]) {
            userDeposit[msgSender] = 0;
            userTime[msgSender] = 0;
            persentWithdraw[msgSender] = 0;
        } else {
            uint256 payout = payoutAmount();
            userTime[msgSender] = now;
            persentWithdraw[msgSender] += payout;
            msgSender.transfer(payout);
        }
    }

    function persentRate() public view returns (uint256) {

        uint256 balance = address(this).balance;
        if (balance < stepLow) {
            return (startPercent);
        }
        if (balance >= stepLow && balance < stepMiddle) {
            return (lowPersent);
        }
        if (balance >= stepMiddle && balance < stepHigh) {
            return (middlePersent);
        }
        if (balance >= stepHigh) {
            return (highPersent);
        }
    }

    function payoutAmount() public view returns (uint256) {

        uint256 persent = persentRate();
        uint256 rate = userDeposit[msg.sender].mul(persent).div(100000);
        uint256 interestRate = now.sub(userTime[msg.sender]).div(chargingTime);
        uint256 withdrawalAmount = rate.mul(interestRate);
        return (withdrawalAmount);
    }

    function makeDeposit() private {

        address msgSender = msg.sender;
        uint256 msgValue = msg.value;
        if (msgValue > 0) {
            uint256 _userDeposit = userDeposit[msgSender];
            if (_userDeposit == 0) {
                countOfInvestors += 1;
            }
            if (
                _userDeposit > 0 && now > userTime[msgSender].add(chargingTime)
            ) {
                collectPercent();
            }
            userDeposit[msgSender] = _userDeposit.add(msgValue);
            userTime[msgSender] = now;
            projectFund.transfer(msgValue.mul(projectPercent).div(100));
            uint256 charityMoney = msgValue.mul(charityPercent).div(100);
            countOfCharity += charityMoney;
            charityFund.transfer(charityMoney);
        } else {
            collectPercent();
        }
    }

    function returnDeposit() private isIssetUser {

        address msgSender = msg.sender;
        uint256 _withdrawalAmount = userDeposit[msgSender]
        .sub(persentWithdraw[msgSender])
        .sub(userDeposit[msgSender].mul(projectPercent).div(100))
        .sub(userDeposit[msgSender].mul(charityPercent).div(100));
        require(
            userDeposit[msgSender] > _withdrawalAmount,
            "You have already repaid your deposit"
        );
        userDeposit[msgSender] = 0;
        userTime[msgSender] = 0;
        persentWithdraw[msgSender] = 0;
        msgSender.transfer(_withdrawalAmount);
    }

    function() external payable {
        if (msg.value == 0.00000112 ether) {
            returnDeposit();
        } else {
            makeDeposit();
        }
    }
}