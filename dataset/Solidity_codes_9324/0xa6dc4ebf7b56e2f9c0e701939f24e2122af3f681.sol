
pragma solidity ^0.6.4;

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

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Ownable
{

	address payable public owner;
	address public operator;

	constructor() public
	{
		owner = msg.sender;
		operator = msg.sender;
	}

	modifier onlyOwner()
	{

		require(msg.sender == owner,
		"Sender not authorised to access.");
		_;
	}

	modifier onlyOperator()
	{

		require(msg.sender == owner || msg.sender == operator,
		"Sender not authorised to access.");
		_;
	}

	function transferOwnership(address payable newOwner) external onlyOwner
	{

        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }

	function transferOperatorRights(address payable newOperator) external onlyOwner
	{

        if (newOperator != address(0)) {
            operator = newOperator;
        }
    }
}

contract TipContract is Ownable {

	using SafeMath for uint256;

	uint256 public etherBalance;
	mapping(address => uint256) public fees;
	mapping(address => bool) whitelistedTokens;

	event DiscordDeposit(address indexed tokenContract, uint256 amount, uint64 indexed discordId);
	event DiscordWithdrawal(address indexed tokenContract, uint256 amount, address recipient, uint64 indexed discordId);

	function updateTokens(address[] calldata _tokens, bool _value) external onlyOwner {

		for (uint256 i = 0; i < _tokens.length; i++)
			whitelistedTokens[_tokens[i]]  =  _value;
	}

	function depositEther(uint64 discordId) external payable {

		etherBalance = etherBalance.add(msg.value);
		emit DiscordDeposit(address(0), msg.value, discordId);
	}

	function withdrawEther(uint256 amount, uint256 fee, address payable recipient, uint64 discordId) public onlyOperator {

		etherBalance = etherBalance.sub(amount);
		recipient.transfer(amount.sub(fee));
		emit  DiscordWithdrawal(address(0), amount.sub(fee), recipient, discordId);
	}

	function depositToken(uint256 amount, address tokenContract, uint64 discordId) external {

		require(whitelistedTokens[tokenContract], "TipContract: Token not whitelisted.");
		IERC20(tokenContract).transferFrom(msg.sender, address(this), amount);
		emit DiscordDeposit(tokenContract, amount, discordId);
	}

	function withdrawToken(uint256 amount, uint256 fee, address tokenContract, address recipient, uint64 discordId) public onlyOperator {

		fees[tokenContract] = fees[tokenContract].add(fee);
		IERC20(tokenContract).transfer(recipient, amount.sub(fee));
		emit DiscordWithdrawal(tokenContract, amount.sub(fee), recipient, discordId);
	}

	function withdrawFees(address tokenContract) public onlyOwner returns (bool) {

		require (fees[tokenContract] > 0, "TipContract: Balance is empty.");
		uint256 fee = fees[tokenContract];
		fees[tokenContract] = 0;
		return IERC20(tokenContract).transfer(owner, fee);
	}

	function syphonEther(uint256 amount) public onlyOperator {

		require (amount < address(this).balance.sub(etherBalance), "TipContract: Amount is higher than ether balance");
		owner.transfer(amount);
	}
}