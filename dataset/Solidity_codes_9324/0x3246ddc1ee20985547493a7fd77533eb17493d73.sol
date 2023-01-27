
pragma solidity ^0.7.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.7.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// UNLICENSED
pragma solidity ^0.7.5;


interface ISportsIconPrivateVesting {


	event LogTokensClaimed(address claimer, uint256 tokensClaimed);

	function token() external view returns(IERC20);

	function vestedTokensOf(address) external view returns(uint256);

	function claimedOf(address) external view returns(uint256);


	function freeTokens(address) external view returns(uint256);


	function claim() external returns(uint256);


}// UNLICENSED
pragma solidity ^0.7.5;


contract SportsIconPrivateVesting is ISportsIconPrivateVesting {

    using SafeMath for uint256;

    mapping(address => uint256) public override vestedTokensOf;
    mapping(address => uint256) public vestedTokensOfPrivileged;
    mapping(address => uint256) public override claimedOf;
    IERC20 public override token;
    uint256 private startTime;
    uint256 public vestingPeriod;

    constructor(
        address _tokenAddress,
        address[] memory holders,
        uint256[] memory balances,
        address[] memory privilegedHolders,
        uint256[] memory privilegedBalances,
        uint256 _vestingPeriod
    ) {
        require(
            (holders.length == balances.length) &&
                (privilegedHolders.length == privilegedBalances.length),
            "Constructor :: Holders and balances differ"
        );
        require(
            _tokenAddress != address(0x0),
            "Constructor :: Invalid token address"
        );
        require(_vestingPeriod > 0, "Constructor :: Invalid vesting period");

        token = IERC20(_tokenAddress);

        for (uint256 i = 0; i < holders.length; i++) {
            if ((i <= privilegedHolders.length - 1) && (privilegedHolders.length > 0)) {
                vestedTokensOfPrivileged[privilegedHolders[i]] = privilegedBalances[i];
            }

            vestedTokensOf[holders[i]] = balances[i];
        }

        vestingPeriod = _vestingPeriod;
        startTime = block.timestamp;
    }

    function freeTokens(address user) public view override returns (uint256) {

        uint256 owed = calculateOwed(user);
        return owed.sub(claimedOf[user]);
    }

    function claim() external override returns (uint256) {

        uint256 tokens = freeTokens(msg.sender);
        claimedOf[msg.sender] = claimedOf[msg.sender].add(tokens);

        require(token.transfer(msg.sender, tokens), "Claim :: Transfer failed");

        emit LogTokensClaimed(msg.sender, tokens);

        return tokens;
    }

    function calculateOwed(address user) internal view returns (uint256) {

        if (vestedTokensOfPrivileged[user] > 0) {
            return vestedTokensOfPrivileged[user];
        }

        uint256 periodsPassed = ((block.timestamp.sub(startTime)).div(30 days));
        if (periodsPassed > vestingPeriod) {
            periodsPassed = vestingPeriod;
        }
        uint256 vestedTokens = vestedTokensOf[user];
        uint256 initialUnlock = vestedTokens.div(10);
        uint256 remainder = vestedTokens.sub(initialUnlock);
        uint256 monthlyUnlock = periodsPassed.mul(remainder).div(vestingPeriod);
        return initialUnlock.add(monthlyUnlock);
    }
}