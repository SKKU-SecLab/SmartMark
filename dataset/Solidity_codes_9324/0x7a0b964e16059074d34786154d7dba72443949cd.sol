
pragma solidity 0.4.24;

contract ERC20TokenInterface {


    function totalSupply () external constant returns (uint);
    function balanceOf (address tokenOwner) external constant returns (uint balance);
    function transfer (address to, uint tokens) external returns (bool success);
    function transferFrom (address from, address to, uint tokens) external returns (bool success);

}

library SafeMath {


    function mul (uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b);
        return c;
    }
    
    function div (uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
    
    function sub (uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        return a - b;
    }

    function add (uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        require(c >= a);
        return c;
    }

}


contract dlafTokensVesting {


    using SafeMath for uint256;

    ERC20TokenInterface public dlafToken;

    address public withdrawAddress;

    struct VestingStage {
        uint256 date;
        uint256 tokensUnlockedPercentage;
    }

    VestingStage[6] public stages;

    uint256 public vestingStartTimestamp = 1659182400;

    uint256 public initialTokensBalance;

    uint256 public tokensSent;

    event Withdraw(uint256 amount, uint256 timestamp);

    modifier onlyWithdrawAddress () {

        require(msg.sender == withdrawAddress);
        _;
    }

    constructor (ERC20TokenInterface token, address withdraw) public {
        dlafToken = token;
        withdrawAddress = withdraw;
        initVestingStages();
    }
    
    function () external {
        withdrawTokens();
    }

    function getAvailableTokensToWithdraw () public view returns (uint256 tokensToSend) {
        uint256 tokensUnlockedPercentage = getTokensUnlockedPercentage();
        if (tokensUnlockedPercentage >= 100) {
            tokensToSend = dlafToken.balanceOf(this);
        } else {
            tokensToSend = getTokensAmountAllowedToWithdraw(tokensUnlockedPercentage);
        }
    }

    function getStageAttributes (uint8 index) public view returns (uint256 date, uint256 tokensUnlockedPercentage) {
        return (stages[index].date, stages[index].tokensUnlockedPercentage);
    }

    function initVestingStages () internal {
        
        uint256 month = 30 days;
        stages[0].date = vestingStartTimestamp;
        stages[1].date = vestingStartTimestamp + month *2;
        stages[2].date = vestingStartTimestamp + month *3;
        stages[3].date = vestingStartTimestamp + month *4;
        stages[4].date = vestingStartTimestamp + month *5;
        stages[5].date = vestingStartTimestamp + month *6;

        stages[0].tokensUnlockedPercentage = 16;
        stages[1].tokensUnlockedPercentage = 32;
        stages[2].tokensUnlockedPercentage = 48;
        stages[3].tokensUnlockedPercentage = 64;
        stages[4].tokensUnlockedPercentage = 80;
        stages[5].tokensUnlockedPercentage = 100;
    }

    function withdrawTokens () onlyWithdrawAddress private {
        if (initialTokensBalance == 0) {
            setInitialTokensBalance();
        }
        uint256 tokensToSend = getAvailableTokensToWithdraw();
        sendTokens(tokensToSend);
    }

    function setInitialTokensBalance () private {
        initialTokensBalance = dlafToken.balanceOf(this);
    }

    function sendTokens (uint256 tokensToSend) private {
        if (tokensToSend > 0) {
            tokensSent = tokensSent.add(tokensToSend);
            dlafToken.transfer(withdrawAddress, tokensToSend);
            emit Withdraw(tokensToSend, now);
        }
    }

    function getTokensAmountAllowedToWithdraw (uint256 tokensUnlockedPercentage) private view returns (uint256) {
        uint256 totalTokensAllowedToWithdraw = initialTokensBalance.mul(tokensUnlockedPercentage).div(100);
        uint256 unsentTokensAmount = totalTokensAllowedToWithdraw.sub(tokensSent);
        return unsentTokensAmount;
    }

    function getTokensUnlockedPercentage () private view returns (uint256) {
        uint256 allowedPercent;
        
        for (uint8 i = 0; i < stages.length; i++) {
            if (now >= stages[i].date) {
                allowedPercent = stages[i].tokensUnlockedPercentage;
            }
        }
        
        return allowedPercent;
    }
}

contract dlafTeamVesting is dlafTokensVesting {

    constructor(ERC20TokenInterface token, address withdraw) dlafTokensVesting(token, withdraw) public {}
}