
pragma solidity 0.8.1;

interface ISupplyController {

	function mintIncentive(address addr) external;

	function mintableIncentive(address addr) external view returns (uint);

	function mint(address token, address owner, uint amount) external;

	function changeSupplyController(address newSupplyController) external;

}

interface IADXToken {

	function transfer(address to, uint256 amount) external returns (bool);

	function transferFrom(address from, address to, uint256 amount) external returns (bool);

	function approve(address spender, uint256 amount) external returns (bool);

	function balanceOf(address spender) external view returns (uint);

	function allowance(address owner, address spender) external view returns (uint);

	function totalSupply() external returns (uint);

	function supplyController() external view returns (ISupplyController);

	function changeSupplyController(address newSupplyController) external;

	function mint(address owner, uint amount) external;

}


interface IERCDecimals {

	function decimals() external view returns (uint);

}

interface IChainlink {

	function latestAnswer() external view returns (uint);

}

interface IUniswapSimple {

	function WETH() external pure returns (address);

	function swapTokensForExactTokens(
		uint amountOut,
		uint amountInMax,
		address[] calldata path,
		address to,
		uint deadline
	) external returns (uint[] memory amounts);

}

contract StakingPool {

	string public constant name = "AdEx Staking Token";
	uint8 public constant decimals = 18;
	string public constant symbol = "ADX-STAKING";

	uint public totalSupply;
	mapping(address => uint) private balances;
	mapping(address => mapping(address => uint)) private allowed;

	bytes32 public DOMAIN_SEPARATOR;
	bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
	mapping(address => uint) public nonces;

	event Approval(address indexed owner, address indexed spender, uint amount);
	event Transfer(address indexed from, address indexed to, uint amount);

	function balanceOf(address owner) external view returns (uint balance) {

		return balances[owner];
	}

	function transfer(address to, uint amount) external returns (bool success) {

		require(to != address(this), "BAD_ADDRESS");
		balances[msg.sender] = balances[msg.sender] - amount;
		balances[to] = balances[to] + amount;
		emit Transfer(msg.sender, to, amount);
		return true;
	}

	function transferFrom(address from, address to, uint amount) external returns (bool success) {

		balances[from] = balances[from] - amount;
		allowed[from][msg.sender] = allowed[from][msg.sender] - amount;
		balances[to] = balances[to] + amount;
		emit Transfer(from, to, amount);
		return true;
	}

	function approve(address spender, uint amount) external returns (bool success) {

		allowed[msg.sender][spender] = amount;
		emit Approval(msg.sender, spender, amount);
		return true;
	}

	function allowance(address owner, address spender) external view returns (uint remaining) {

		return allowed[owner][spender];
	}

	function permit(address owner, address spender, uint amount, uint deadline, uint8 v, bytes32 r, bytes32 s) external {

		require(deadline >= block.timestamp, "DEADLINE_EXPIRED");
		bytes32 digest = keccak256(abi.encodePacked(
			"\x19\x01",
			DOMAIN_SEPARATOR,
			keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, amount, nonces[owner]++, deadline))
		));
		address recoveredAddress = ecrecover(digest, v, r, s);
		require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNATURE");
		allowed[owner][spender] = amount;
		emit Approval(owner, spender, amount);
	}

	function innerMint(address owner, uint amount) internal {

		totalSupply = totalSupply + amount;
		balances[owner] = balances[owner] + amount;
		emit Transfer(address(0), owner, amount);
	}
	function innerBurn(address owner, uint amount) internal {

		totalSupply = totalSupply - amount;
		balances[owner] = balances[owner] - amount;
		emit Transfer(owner, address(0), amount);
	}

	uint public timeToUnbond = 20 days;
	uint public rageReceivedPromilles = 700;

	IUniswapSimple public uniswap; // = IUniswapSimple(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
	IChainlink public ADXUSDOracle; // = IChainlink(0x231e764B44b2C1b7Ca171fa8021A24ed520Cde10);

	IADXToken public immutable ADXToken;
	address public guardian;
	address public validator;
	address public governance;

	mapping (address => bool) public whitelistedClaimTokens;

	mapping (bytes32 => uint) public commitments;
	mapping (address => uint) public lockedShares;
	struct UnbondCommitment {
		address owner;
		uint shares;
		uint unlocksAt;
	}

	uint public maxDailyPenaltiesPromilles;
	uint public limitLastReset;
	uint public limitRemaining;

	event LogLeave(address indexed owner, uint shares, uint unlocksAt, uint maxTokens);
	event LogWithdraw(address indexed owner, uint shares, uint unlocksAt, uint maxTokens, uint receivedTokens);
	event LogRageLeave(address indexed owner, uint shares, uint maxTokens, uint receivedTokens);
	event LogNewGuardian(address newGuardian);
	event LogClaim(address tokenAddr, address to, uint amountInUSD, uint burnedValidatorShares, uint usedADX, uint totalADX, uint totalShares);
	event LogPenalize(uint burnedADX);

	constructor(IADXToken token, IUniswapSimple uni, IChainlink oracle, address guardianAddr, address validatorStakingWallet, address governanceAddr, address claimToken) {
		ADXToken = token;
		uniswap = uni;
		ADXUSDOracle = oracle;
		guardian = guardianAddr;
		validator = validatorStakingWallet;
		governance = governanceAddr;
		whitelistedClaimTokens[claimToken] = true;

		uint chainId;
		assembly {
			chainId := chainid()
		}
		DOMAIN_SEPARATOR = keccak256(
			abi.encode(
				keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
				keccak256(bytes(name)),
				keccak256(bytes("1")),
				chainId,
				address(this)
			)
		);
	}

	function setGovernance(address addr) external {

		require(governance == msg.sender, "NOT_GOVERNANCE");
		governance = addr;
	}
	function setDailyPenaltyMax(uint max) external {

		require(governance == msg.sender, "NOT_GOVERNANCE");
		require(max <= 200, "DAILY_PENALTY_TOO_LARGE");
		maxDailyPenaltiesPromilles = max;
		resetLimits();
	}
	function setRageReceived(uint rageReceived) external {

		require(governance == msg.sender, "NOT_GOVERNANCE");
		require(rageReceived <= 1000, "TOO_LARGE");
		rageReceivedPromilles = rageReceived;
	}
	function setTimeToUnbond(uint time) external {

		require(governance == msg.sender, "NOT_GOVERNANCE");
		require(time >= 1 days && time <= 30 days, "BOUNDS");
		timeToUnbond = time;
	}
	function setGuardian(address newGuardian) external {

		require(governance == msg.sender, "NOT_GOVERNANCE");
		guardian = newGuardian;
		emit LogNewGuardian(newGuardian);
	}
	function setWhitelistedClaimToken(address token, bool whitelisted) external {

		require(governance == msg.sender, "NOT_GOVERNANCE");
		whitelistedClaimTokens[token] = whitelisted;
	}

	function shareValue() external view returns (uint) {

		if (totalSupply == 0) return 0;
		return ((ADXToken.balanceOf(address(this)) + ADXToken.supplyController().mintableIncentive(address(this)))
			* 1e18)
			/ totalSupply;
	}

	function innerEnter(address recipient, uint amount) internal {

		ADXToken.supplyController().mintIncentive(address(this));

		uint totalADX = ADXToken.balanceOf(address(this));

		if (totalSupply == 0 || totalADX == 0) {
			innerMint(recipient, amount);
		} else {
			uint256 newShares = (amount * totalSupply) / totalADX;
			innerMint(recipient, newShares);
		}
		require(ADXToken.transferFrom(msg.sender, address(this), amount));
	}

	function enter(uint amount) external {

		innerEnter(msg.sender, amount);
	}

	function enterTo(address recipient, uint amount) external {

		innerEnter(recipient, amount);
	}

	function unbondingCommitmentWorth(address owner, uint shares, uint unlocksAt) external view returns (uint) {

		if (totalSupply == 0) return 0;
		bytes32 commitmentId = keccak256(abi.encode(UnbondCommitment({ owner: owner, shares: shares, unlocksAt: unlocksAt })));
		uint maxTokens = commitments[commitmentId];
		uint totalADX = ADXToken.balanceOf(address(this));
		uint currentTokens = (shares * totalADX) / totalSupply;
		return currentTokens > maxTokens ? maxTokens : currentTokens;
	}

	function leave(uint shares, bool skipMint) external {

		if (!skipMint) ADXToken.supplyController().mintIncentive(address(this));

		require(shares <= balances[msg.sender] - lockedShares[msg.sender], "INSUFFICIENT_SHARES");
		uint totalADX = ADXToken.balanceOf(address(this));
		uint maxTokens = (shares * totalADX) / totalSupply;
		uint unlocksAt = block.timestamp + timeToUnbond;
		bytes32 commitmentId = keccak256(abi.encode(UnbondCommitment({ owner: msg.sender, shares: shares, unlocksAt: unlocksAt })));
		require(commitments[commitmentId] == 0, "COMMITMENT_EXISTS");

		commitments[commitmentId] = maxTokens;
		lockedShares[msg.sender] += shares;

		emit LogLeave(msg.sender, shares, unlocksAt, maxTokens);
	}

	function withdraw(uint shares, uint unlocksAt, bool skipMint) external {

		if (!skipMint) ADXToken.supplyController().mintIncentive(address(this));

		require(block.timestamp > unlocksAt, "UNLOCK_TOO_EARLY");
		bytes32 commitmentId = keccak256(abi.encode(UnbondCommitment({ owner: msg.sender, shares: shares, unlocksAt: unlocksAt })));
		uint maxTokens = commitments[commitmentId];
		require(maxTokens > 0, "NO_COMMITMENT");
		uint totalADX = ADXToken.balanceOf(address(this));
		uint currentTokens = (shares * totalADX) / totalSupply;
		uint receivedTokens = currentTokens > maxTokens ? maxTokens : currentTokens;

		commitments[commitmentId] = 0;
		lockedShares[msg.sender] -= shares;

		innerBurn(msg.sender, shares);
		require(ADXToken.transfer(msg.sender, receivedTokens));

		emit LogWithdraw(msg.sender, shares, unlocksAt, maxTokens, receivedTokens);
	}

	function rageLeave(uint shares, bool skipMint) external {

		if (!skipMint) ADXToken.supplyController().mintIncentive(address(this));

		uint totalADX = ADXToken.balanceOf(address(this));
		uint adxAmount = (shares * totalADX) / totalSupply;
		uint receivedTokens = (adxAmount * rageReceivedPromilles) / 1000;
		innerBurn(msg.sender, shares);
		require(ADXToken.transfer(msg.sender, receivedTokens));

		emit LogRageLeave(msg.sender, shares, adxAmount, receivedTokens);
	}

	function claim(address tokenOut, address to, uint amount) external {

		require(msg.sender == guardian, "NOT_GUARDIAN");

		resetLimits();

		uint totalADX = ADXToken.balanceOf(address(this));

		require(whitelistedClaimTokens[tokenOut], "TOKEN_NOT_WHITELISTED");

		address[] memory path = new address[](3);
		path[0] = address(ADXToken);
		path[1] = uniswap.WETH();
		path[2] = tokenOut;


		uint price = ADXUSDOracle.latestAnswer();
		uint multiplier = 1.05e26 / (10 ** IERCDecimals(tokenOut).decimals());
		uint adxAmountMax = (amount * multiplier) / price;
		require(adxAmountMax < totalADX, "INSUFFICIENT_ADX");
		uint[] memory amounts = uniswap.swapTokensForExactTokens(amount, adxAmountMax, path, to, block.timestamp);

		uint adxAmountUsed = amounts[0];

		uint sharesNeeded = (adxAmountUsed * totalSupply) / totalADX;
		uint toBurn = sharesNeeded < balances[validator] ? sharesNeeded : balances[validator];
		if (toBurn > 0) innerBurn(validator, toBurn);

		require(limitRemaining >= adxAmountUsed, "LIMITS");
		limitRemaining -= adxAmountUsed;

		emit LogClaim(tokenOut, to, amount, toBurn, adxAmountUsed, totalADX, totalSupply);
	}

	function penalize(uint adxAmount) external {

		require(msg.sender == guardian, "NOT_GUARDIAN");
		resetLimits();
		require(limitRemaining >= adxAmount, "LIMITS");
		limitRemaining -= adxAmount;
		require(ADXToken.transfer(address(0), adxAmount));
		emit LogPenalize(adxAmount);
	}

	function resetLimits() internal {

		if (block.timestamp - limitLastReset > 24 hours) {
			limitLastReset = block.timestamp;
			limitRemaining = (ADXToken.balanceOf(address(this)) * maxDailyPenaltiesPromilles) / 1000;
		}
	}
}