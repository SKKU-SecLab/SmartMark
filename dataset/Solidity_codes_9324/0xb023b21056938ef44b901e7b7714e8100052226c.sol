
pragma solidity 0.4.25;
 interface token {

    function transfer(address receiver, uint amount) external;

}

contract Crowdsale {

    address public beneficiary = msg.sender; //受益人地址，测试时为合约创建者
    uint public fundingGoal;  //众筹目标，单位是ether
    uint public amountRaised; //已筹集金额数量， 单位是ether
    uint public deadline; //截止时间
    uint public price;  //代币价格
    token public tokenReward;   // 要卖的token
    bool public fundingGoalReached = false;  //达成众筹目标
    bool public crowdsaleClosed = false; //众筹关闭


    mapping(address => uint256) public balance; //保存众筹地址及对应的以太币数量

    event GoalReached(address _beneficiary, uint _amountRaised);

    event FundTransfer(address _backer, uint _amount, bool _isContribution);

    constructor(
        uint fundingGoalInEthers,
        uint durationInMinutes,
        uint TokenCostOfEachether,
        address addressOfTokenUsedAsReward
    )  public {
        fundingGoal = fundingGoalInEthers * 1 ether;
        deadline = now + durationInMinutes * 1 minutes;
        price = TokenCostOfEachether ; //1个以太币可以买几个代币
        tokenReward = token(addressOfTokenUsedAsReward); 
    }


    function () payable public {

        require(!crowdsaleClosed);
        uint amount = msg.value;

        balance[msg.sender] += amount;

        amountRaised += amount;

         tokenReward.transfer(msg.sender, amount * price);
         emit FundTransfer(msg.sender, amount, true);
    }

    modifier afterDeadline() { if (now >= deadline) _; }


    function checkGoalReached() afterDeadline public {

        if (amountRaised >= fundingGoal){
            fundingGoalReached = true;
          emit  GoalReached(beneficiary, amountRaised);
        }

        crowdsaleClosed = true;
    }
    function backtoken(uint backnum) public{

        uint amount = backnum * 10 ** 18;
        tokenReward.transfer(beneficiary, amount);
       emit FundTransfer(beneficiary, amount, true);
    }
    
    function backeth() public{

        beneficiary.transfer(amountRaised);
        emit FundTransfer(beneficiary, amountRaised, true);
    }

    function safeWithdrawal() afterDeadline public {


        if (!fundingGoalReached) {
            uint amount = balance[msg.sender];

            if (amount > 0) {
                beneficiary.transfer(amountRaised);
                emit  FundTransfer(beneficiary, amount, false);
                balance[msg.sender] = 0;
            }
        }

        if (fundingGoalReached && beneficiary == msg.sender) {

            beneficiary.transfer(amountRaised);

          emit  FundTransfer(beneficiary, amount, false);
        }
    }
}