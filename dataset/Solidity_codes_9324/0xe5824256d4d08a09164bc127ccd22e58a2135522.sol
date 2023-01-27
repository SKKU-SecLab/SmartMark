
pragma solidity >=0.4.22 <0.6.0;

interface token {

    function transfer(address receiver, uint amount) external;

}

contract wPGO_Presale {

    address public beneficiary;
    uint public softCap;
    uint public hardCap;
    uint public amountRaised;
    uint public deadline;
    uint public price;
    token public tokenReward;
    mapping(address => uint256) public balanceOf;
    bool fundingGoalReached = false;
    bool presaleClosed = false;
    uint WPGO = 100000000;
    uint tokenBalance = 2000000 * WPGO;

    event GoalReached(address recipient, uint totalAmountRaised);
    event FundTransfer(address backer, uint amount, bool isContribution);

    constructor(
        address ifSuccessfulSendTo,
        uint softCapInFinney,
        uint hardCapInFinney,
        uint durationInMinutes,
        uint etherCostOfEachToken,
        address addressOfTokenUsedAsReward
    ) public {
        beneficiary = ifSuccessfulSendTo;
        softCap = softCapInFinney * 1 ether;
        hardCap = hardCapInFinney * 1 ether;
        deadline = now + durationInMinutes * 1 minutes;
        price = etherCostOfEachToken * 1 szabo;
        tokenReward = token(addressOfTokenUsedAsReward);
    }

    function () payable external {
        require(!presaleClosed);
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        amountRaised += amount;
        uint tokenAmount;
        tokenAmount = amount / price * WPGO;
        tokenReward.transfer(msg.sender, tokenAmount);
        tokenBalance -= tokenAmount;
        emit FundTransfer(msg.sender, amount, true);
    }

    modifier afterDeadline() { if (now >= deadline) _; }


    function checkGoalReached() public afterDeadline {

        if (amountRaised >= softCap){
            fundingGoalReached = true;
            emit GoalReached(beneficiary, amountRaised);
        }
        presaleClosed = true;
    }


    function safeWithdrawalEther() public afterDeadline {

        if (!fundingGoalReached && presaleClosed) {
            uint amount = balanceOf[msg.sender];
            balanceOf[msg.sender] = 0;
            if (amount > 0) {
                if (msg.sender.send(amount)) {
                   emit FundTransfer(msg.sender, amount, false);
                } else {
                    balanceOf[msg.sender] = amount;
                }
            }
        }

        if (fundingGoalReached && beneficiary == msg.sender && presaleClosed) {
            if (msg.sender.send(amountRaised)) {
               emit FundTransfer(beneficiary, amountRaised, false);
            } else {
                fundingGoalReached = false;
            }
        }
    }

    function safeWithdrawalWPGO() public afterDeadline {

        if (beneficiary == msg.sender && presaleClosed) {
            tokenReward.transfer(msg.sender, tokenBalance);
            tokenBalance = 0;
        }
    }
}