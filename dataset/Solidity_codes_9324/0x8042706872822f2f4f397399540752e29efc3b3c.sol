
pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;


interface IUniswapV2Router {

	function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);


	function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint256[] memory amounts);

}// AGPL-3.0-or-later

pragma solidity ^0.8.0;


contract Authority {

	
	address[] public authorities;
	mapping(address => bool) public isAuthority;

	constructor() {
		authorities.push(msg.sender);
		isAuthority[msg.sender] = true;
	}

	modifier onlySuperAuthority() {

		require(authorities[0] == msg.sender, "Authority: Only Super Authority");
		_;
	}
	
	modifier onlyAuthority() {

		require(isAuthority[msg.sender], "Authority: Only Authority");
		_;
	}

	function addAuthority(address _new, bool _change) external onlySuperAuthority {

		require(!isAuthority[_new], "Authoritys: Already authority");
		isAuthority[_new] = true;
		if (_change) {
			authorities.push(authorities[0]);
			authorities[0] = _new;
		} else {
			authorities.push(_new);
		}
	}

	function removeAuthority(address _new) external onlySuperAuthority {

		require(isAuthority[_new], "Authority: Not authority");
		require(_new != authorities[0], "Authority: Cannot remove super authority");
		for (uint i = 1; i < authorities.length; i++) {
			if (authorities[i] == _new) {
				authorities[i] = authorities[authorities.length - 1];
				authorities.pop();
				break;
			}
		}
		isAuthority[_new] = false;
	}

	function getAuthoritiesSize() external view returns(uint) {

		return authorities.length;
	}
}// MIT

pragma solidity ^0.8.0;


interface IStaking {

	function stake(uint256 _amount, address _recipient) external;

}// MIT

pragma solidity ^0.8.0;



contract Logic is Authority {

	event CreatedNode(address indexed from, uint count, uint price);
	event ClaimedNode(address indexed from, uint count, uint claimed, bool staked);

	address public immutable yeti;
	address public immutable bigFoot;
	address public splitter;
	address public treasury;
	address public staking;

	address public immutable router;
	address public immutable stable;

	mapping(uint => uint) public lastClaimTime; // token id to last claim time

	uint public price = 100 * 10**6; // usdc 6 decimals
	uint public constant PRICE_INCR = 100 * 10**6; // usdc 6 decimals
	uint public constant REF_PRICE_INCR = 100;

	uint public dailyRewards;
	uint public constant DAY = 1 days;

	uint public constant REF_RATIO = 10000;

	uint private constant MAX_UINT256 = type(uint256).max;

	bool public presale = true;
	mapping(address => bool) public whitelisted;

	bool public applyLp = true;
	uint public lpRate;
	
	bool public applyTreasury = true;
	uint public treasuryRate;
	
	constructor(
		address[] memory addresses,
		uint[] memory rates,
		uint _dailyRewards
	) {
		bigFoot = addresses[0];
		yeti = addresses[1];
		splitter = addresses[2];
		treasury = addresses[3];
		staking = addresses[4];
		router = addresses[5];
		stable = addresses[6];

		lpRate = rates[0];
		treasuryRate = rates[1];

		dailyRewards = _dailyRewards;
	}

	modifier onlyYeti() {

		require(msg.sender == yeti, "Logic: onlyYeti");
		_;
	}

	function init() external onlyAuthority {

		IERC20(stable).approve(router, MAX_UINT256);
		IERC20(bigFoot).approve(router, MAX_UINT256);
	}

	function safeMint(address sender, uint tokenId) external onlyYeti {

		uint priceStack = price; // gas

		if ((tokenId + 1) % REF_PRICE_INCR == 0) {
			unchecked { price += PRICE_INCR; }
		}

		IERC20(stable).transferFrom(sender, address(this), priceStack);

		uint balance = IERC20(stable).balanceOf(address(this));

		if (!presale) {
			lastClaimTime[tokenId] = block.timestamp;

			if (applyLp) {
				uint lpAmount = balance * lpRate / REF_RATIO;
				swapAndAdd(lpAmount);
			}

			if (applyTreasury) {
				uint treasuryAmount = balance * treasuryRate / REF_RATIO;
				IERC20(stable).transfer(treasury, treasuryAmount);
			}
		} else {
			require(whitelisted[sender], "Logic: Address not whitelisted");

			uint treasuryAmount = balance * (lpRate + treasuryRate) / REF_RATIO;
			IERC20(stable).transfer(treasury, treasuryAmount);
		}
		
		safeTransferSplitter(stable);
		safeTransferSplitter(bigFoot);

		emit CreatedNode(sender, 1, priceStack);
	}

	function safeClaim(address sender, uint tokenId, bool stake) external onlyYeti {

		if (lastClaimTime[tokenId] == 0) { // presale
			require(!presale, "Logic: Presale ongoing");
			lastClaimTime[tokenId] = block.timestamp;
			return;
		}
		
		uint amount = pendingOf(tokenId);

		lastClaimTime[tokenId] = block.timestamp;

		if (amount == 0)
			return;

		if (stake)
			IStaking(staking).stake(amount, sender);
		else
			IERC20(bigFoot).transferFrom(treasury, sender, amount);
		
		emit ClaimedNode(sender, 1, amount, stake);
	}
	
	function safeMintBatch(
		address sender, 
		uint[] calldata tokenIds
	) 
		external 
		onlyYeti 
	{

		uint finalPrice;
		uint priceStack = price; // gas
		bool _presale = presale; // gas

		for (uint i = 0; i < tokenIds.length; i++) {
			unchecked { finalPrice += priceStack; }

			if ((tokenIds[i] + 1) % REF_PRICE_INCR == 0) {
				unchecked { 
					price += PRICE_INCR;
					priceStack += PRICE_INCR;
				}
			}

			if (!_presale)
				lastClaimTime[tokenIds[i]] = block.timestamp;
		}

		IERC20(stable).transferFrom(sender, address(this), finalPrice);
			
		uint balance = IERC20(stable).balanceOf(address(this));

		if (!_presale) {
			if (applyLp) {
				uint lpAmount = balance * lpRate / REF_RATIO;
				swapAndAdd(lpAmount);
			}

			if (applyTreasury) {
				uint treasuryAmount = balance * treasuryRate / REF_RATIO;
				IERC20(stable).transfer(treasury, treasuryAmount);
			}
		} else {
			require(whitelisted[sender], "Logic: Address not whitelisted");

			uint treasuryAmount = balance * (lpRate + treasuryRate) / REF_RATIO;
			IERC20(stable).transfer(treasury, treasuryAmount);
		}
		
		safeTransferSplitter(stable);
		safeTransferSplitter(bigFoot);

		emit CreatedNode(sender, tokenIds.length, finalPrice);
	}
	
	function safeClaimBatch(
		address sender, 
		uint[] calldata tokenIds, 
		bool stake
	) 
		external 
		onlyYeti 
	{

		uint amount;

		for (uint i = 0; i < tokenIds.length; i++) {
			uint tokenId = tokenIds[i]; // gas

			if (lastClaimTime[tokenId] == 0) { // presale
				require(!presale, "Logic: Presale ongoing");
				lastClaimTime[tokenId] = block.timestamp;
			} else {
				unchecked { amount += pendingOf(tokenId); }
				lastClaimTime[tokenId] = block.timestamp;
			}
		}
		
		if (amount == 0)
			return;

		if (stake)
			IStaking(staking).stake(amount, sender);
		else
			IERC20(bigFoot).transferFrom(treasury, sender, amount);
		
		emit ClaimedNode(sender, tokenIds.length, amount, stake);
	}

	function setApplyLp(bool _new) external onlyAuthority {

		applyLp = _new;
	}
	
	function setLpRate(uint _new) external onlyAuthority {

		lpRate = _new;
	}

	function setApplyTreasury(bool _new) external onlyAuthority {

		applyTreasury = _new;
	}
	
	function setTreasuryRate(uint _new) external onlyAuthority {

		treasuryRate = _new;
	}
	
	function setDailyRewards(uint _new) external onlyAuthority {

		dailyRewards = _new;
	}
	
	function setPresale(bool _new) external onlyAuthority {

		presale = _new;
	}
	
	function setWhitelisted(address[] calldata _addr, bool _new) external onlyAuthority {

		for (uint i = 0; i < _addr.length; i++) {
			whitelisted[_addr[i]] = _new;
		}
	}

	function pendingOf(uint tokenId) public view returns (uint) {

		return dailyRewards * (block.timestamp - lastClaimTime[tokenId]) / DAY;
	}

	function safeTransferSplitter(address token) internal {

		IERC20 erc20 = IERC20(token); // gas
		uint balance = erc20.balanceOf(address(this));
		if (balance > 0)
			erc20.transfer(splitter, balance);
	}

	function swapAndAdd(uint amount) internal {

		uint swappedHalf = amount / 2;
		uint otherHalf = amount - swappedHalf;
		uint amountOut = swapExactTokensForTokens(swappedHalf);
		addLiquidity(otherHalf, amountOut);
	}

	function swapExactTokensForTokens(uint amount) internal returns (uint){

		address[] memory path = new address[](2);
		path[0] = stable;
		path[1] = bigFoot;
		return IUniswapV2Router(router).swapExactTokensForTokens(
			amount,
			0,
			path,
			address(this),
			block.timestamp
		)[1];
	}

	function addLiquidity(uint _stableAmount, uint _bigFootAmount) internal {

		IUniswapV2Router(router).addLiquidity(
			stable,
			bigFoot,
			_stableAmount,
			_bigFootAmount,
			0,
			0,
			treasury,
			block.timestamp
		);
	}
}