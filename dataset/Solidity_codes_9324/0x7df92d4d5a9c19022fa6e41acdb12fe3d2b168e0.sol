
pragma solidity ^0.5.3;

contract ERC223Interface {

    function balanceOf(address who)public view returns (uint);

    function transfer(address to, uint value)public returns (bool success);

    function transfer(address to, uint value, bytes memory data)public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint value);
}

interface ERC223ReceivingContract {

    function tokenFallback(address _from, uint _value, bytes calldata _data) external;

}

library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    return a / b;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Context {

    function _msgSender() internal view returns (address) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes  memory) {

        return msg.data;
    }
}

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() public  {
        _setOwner(_msgSender());
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public  onlyOwner {

        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public  onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {

        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract MaxxerVesting is ERC223ReceivingContract,Ownable {

    using SafeMath for uint256;

    address public maxxerToken;

    address public FOUNDERS_ADDRESS;

    address public ADVISORS_ADDRESS;

    address public TEAM_ADDRESS;

    uint256 constant public FOUNDERS_TOTAL_TOKEN = 270000000 * 10**18;

    uint256 constant public ADVISORS_TOTAL_TOKEN = 36000000 * 10**18;

    uint256 constant public TEAM_TOTAL_TOKEN = 54000000 * 10**18;

    uint256 public FOUNDERS_TOKEN_SENT;

    uint256 public ADVISORS_TOKEN_SENT;

    uint256 public TEAM_TOKEN_SENT;

    uint256 public VESTING_START_TIMESTAMP;

    struct VestingStage {
        uint256 date;
        uint256 foundersTokensUnlocked;
        uint256 advisorsTokensUnlocked;
        uint256 teamTokensUnlocked;
    }

    VestingStage[36] public stages;

    event Withdraw(address _to, uint256 _value);

    constructor (address _maxxerToken,uint256 _vestingStartTimestamp, address _foundersAddress,address _advisorsAddress,address _teamAddress) public {
        maxxerToken = _maxxerToken;
        VESTING_START_TIMESTAMP=_vestingStartTimestamp;
        FOUNDERS_ADDRESS=_foundersAddress;
        ADVISORS_ADDRESS=_advisorsAddress;
        TEAM_ADDRESS=_teamAddress;
        initVestingStages();
    }

    function initVestingStages () internal {
        uint256 month = 30 days;

        stages[0].date = VESTING_START_TIMESTAMP;
        stages[0].foundersTokensUnlocked = 67500010 * 10**18;
        stages[0].advisorsTokensUnlocked = 9000020 * 10**18;
        stages[0].teamTokensUnlocked = 13500030 * 10**18;

        for (uint8 i = 1; i < 36; i++) {
                stages[i].date = stages[i-1].date + month;
                stages[i].foundersTokensUnlocked = stages[i-1].foundersTokensUnlocked.add(5785714 * 10**18);
                stages[i].advisorsTokensUnlocked = stages[i-1].advisorsTokensUnlocked.add(771428 * 10**18);
                stages[i].teamTokensUnlocked = stages[i-1].teamTokensUnlocked.add(1157142 * 10**18);
        }
    }

    function tokenFallback(address, uint _value, bytes calldata) external {

        require(msg.sender == maxxerToken);
        uint256 TOTAL_TOKENS = FOUNDERS_TOTAL_TOKEN.add(ADVISORS_TOTAL_TOKEN).add(TEAM_TOTAL_TOKEN);
        require(_value == TOTAL_TOKENS);
    }

    function withdrawFoundersToken () external onlyOwner {
        uint256 tokensToSend = getAvailableTokensOfFounders();
        require(tokensToSend > 0,"Vesting: No withdrawable tokens available.");
        sendTokens(FOUNDERS_ADDRESS,tokensToSend);
    }

    function withdrawAdvisorsToken () external onlyOwner {
        uint256 tokensToSend = getAvailableTokensOfAdvisors();
        require(tokensToSend > 0,"Vesting: No withdrawable tokens available.");
        sendTokens(ADVISORS_ADDRESS,tokensToSend);
    }

    function withdrawTeamToken () external onlyOwner {
        uint256 tokensToSend = getAvailableTokensOfTeam();
        require(tokensToSend > 0,"Vesting: No withdrawable tokens available.");
        sendTokens(TEAM_ADDRESS,tokensToSend);
    }

    function getAvailableTokensOfFounders () public view returns (uint256 tokensToSend) {
        uint256 tokensUnlocked = getTokensUnlocked(FOUNDERS_ADDRESS);
        tokensToSend = getTokensAmountAllowedToWithdraw(FOUNDERS_ADDRESS,tokensUnlocked);
    }

    function getAvailableTokensOfAdvisors () public view returns (uint256 tokensToSend) {
        uint256 tokensUnlocked = getTokensUnlocked(ADVISORS_ADDRESS);
        tokensToSend = getTokensAmountAllowedToWithdraw(ADVISORS_ADDRESS,tokensUnlocked);
    }

    function getAvailableTokensOfTeam () public view returns (uint256 tokensToSend) {
        uint256 tokensUnlocked = getTokensUnlocked(TEAM_ADDRESS);
        tokensToSend = getTokensAmountAllowedToWithdraw(TEAM_ADDRESS,tokensUnlocked);
    }

    function getTokensUnlocked (address role) private view returns (uint256) {
        uint256 allowedTokens;

        for (uint8 i = 0; i < stages.length; i++) {
            if (now >= stages[i].date) {
                if(role == FOUNDERS_ADDRESS){
                    allowedTokens = stages[i].foundersTokensUnlocked;
                } else if(role == ADVISORS_ADDRESS){
                    allowedTokens = stages[i].advisorsTokensUnlocked;
                } else if(role == TEAM_ADDRESS){
                    allowedTokens = stages[i].teamTokensUnlocked;
                }
            }
        }

        return allowedTokens;
    }

    function getTokensAmountAllowedToWithdraw (address role,uint256 tokensUnlocked) private view returns (uint256) {
        uint256 unsentTokensAmount;
        if(role == FOUNDERS_ADDRESS){
            unsentTokensAmount = tokensUnlocked.sub(FOUNDERS_TOKEN_SENT);
        } else if(role == ADVISORS_ADDRESS){
            unsentTokensAmount = tokensUnlocked.sub(ADVISORS_TOKEN_SENT);
        } else if(role == TEAM_ADDRESS){
            unsentTokensAmount = tokensUnlocked.sub(TEAM_TOKEN_SENT);
        }
        return unsentTokensAmount;
    }

    function sendTokens (address role,uint256 tokensToSend) private {
        if (tokensToSend > 0) {
            if(role == FOUNDERS_ADDRESS){
                FOUNDERS_TOKEN_SENT = FOUNDERS_TOKEN_SENT.add(tokensToSend);
                ERC223Interface(maxxerToken).transfer(FOUNDERS_ADDRESS, tokensToSend);
                emit Withdraw(FOUNDERS_ADDRESS,tokensToSend);
            } else if(role == ADVISORS_ADDRESS){
                ADVISORS_TOKEN_SENT = ADVISORS_TOKEN_SENT.add(tokensToSend);
                ERC223Interface(maxxerToken).transfer(ADVISORS_ADDRESS, tokensToSend);
                emit Withdraw(ADVISORS_ADDRESS,tokensToSend);
            } else if(role == TEAM_ADDRESS){
                TEAM_TOKEN_SENT = TEAM_TOKEN_SENT.add(tokensToSend);
                ERC223Interface(maxxerToken).transfer(TEAM_ADDRESS, tokensToSend);
                emit Withdraw(TEAM_ADDRESS,tokensToSend);
            }
        }
    }
}