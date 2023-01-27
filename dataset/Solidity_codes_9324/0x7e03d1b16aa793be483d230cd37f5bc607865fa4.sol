
pragma solidity 0.5.8;

contract ERC20TokenInterface {


    function totalSupply () external view returns (uint);
    function balanceOf (address tokenOwner) external view returns (uint balance);
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

contract TwoYearDreamTokensVesting {


    function vestingRules () internal {

        uint256 year = halfOfYear * 2;
        stages[0].date = vestingStartUnixTimestamp;                     // Right after initialization
        stages[1].date = vestingStartUnixTimestamp + halfOfYear;        // 1/2 years after initialization
        stages[2].date = vestingStartUnixTimestamp + year;              // 1 year after initialization
        stages[3].date = vestingStartUnixTimestamp + year + halfOfYear; // 1 + 1/2 years after initialization
        stages[4].date = vestingStartUnixTimestamp + (year * 2);        // 2 years after initialization
        stages[0].tokensUnlockedPercentage = 10;    // 0.1%
        stages[1].tokensUnlockedPercentage = 2500;  // 25%
        stages[2].tokensUnlockedPercentage = 5000;  // 50%
        stages[3].tokensUnlockedPercentage = 7500;  // 75%
        stages[4].tokensUnlockedPercentage = 10000; // 100%

    }

    using SafeMath for uint256;

    ERC20TokenInterface public dreamToken;

    address payable public withdrawalAddress = address(0x0);
    
    uint256 public constant halfOfYear = 182 days + 15 hours; // x2 = ~365.25 days in a year

    struct VestingStage {
        uint256 date;
        uint256 tokensUnlockedPercentage;
    }

    VestingStage[5] public stages;

    uint256 public initialTokensBalance;

    uint256 public tokensSent;

    uint256 public vestingStartUnixTimestamp;

    address public deployer;

    modifier deployerOnly { require(msg.sender == deployer); _; }

    modifier whenInitialized { require(withdrawalAddress != address(0x0)); _; }

    modifier whenNotInitialized { require(withdrawalAddress == address(0x0)); _; }


    event Withdraw(uint256 amount, uint256 timestamp);

    constructor (ERC20TokenInterface addr) public {
        dreamToken = addr;
        deployer = msg.sender;
    }

    function () external {
        withdrawTokens();
    }

    function initializeVestingFor (address payable account) external deployerOnly whenNotInitialized {
        initialTokensBalance = dreamToken.balanceOf(address(this));
        require(initialTokensBalance != 0);
        withdrawalAddress = account;
        vestingStartUnixTimestamp = block.timestamp;
        vestingRules();
    }

    function getAvailableTokensToWithdraw () public view returns (uint256) {
        uint256 tokensUnlockedPercentage = getTokensUnlockedPercentage();
        if (tokensUnlockedPercentage >= 10000) {
            return dreamToken.balanceOf(address(this));
        } else {
            return getTokensAmountAllowedToWithdraw(tokensUnlockedPercentage);
        }
    }

    function withdrawTokens () private whenInitialized {
        uint256 tokensToSend = getAvailableTokensToWithdraw();
        sendTokens(tokensToSend);
        if (dreamToken.balanceOf(address(this)) == 0) { // When all tokens were sent, destroy this smart contract
            selfdestruct(withdrawalAddress);
        }
    }

    function sendTokens (uint256 tokensToSend) private {
        if (tokensToSend == 0) {
            return;
        }
        tokensSent = tokensSent.add(tokensToSend); // Update tokensSent variable to send correct amount later
        dreamToken.transfer(withdrawalAddress, tokensToSend); // Send allowed number of tokens
        emit Withdraw(tokensToSend, now); // Emitting a notification that tokens were withdrawn
    }

    function getTokensAmountAllowedToWithdraw (uint256 tokensUnlockedPercentage) private view returns (uint256) {
        uint256 totalTokensAllowedToWithdraw = initialTokensBalance.mul(tokensUnlockedPercentage).div(10000);
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