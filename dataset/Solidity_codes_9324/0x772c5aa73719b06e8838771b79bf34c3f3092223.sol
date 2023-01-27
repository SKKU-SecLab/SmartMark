pragma solidity ^0.5.13;


contract Staking {

	constructor(address _stakingToken, uint256 _emissionRate) public {
		erc20 = TOKEN(address(_stakingToken)); // set the staking token
		admin = msg.sender; // set the admin
		emissionRate = _emissionRate; // set the default emission rate (admin can change this later)

		stakeOptions[0] = StakeOption(30 days, 50); // 50% after 30 days
		stakeOptions[1] = StakeOption(60 days, 125); // 125% after 60 days
		stakeOptions[2] = StakeOption(90 days, 238); // 238% after 90 days
	}

	using SafeMath for uint256;

	TOKEN erc20;

	address payable admin;

	uint256 public totalBalance;

	uint256 public emissionRate;

	mapping(address => Provider) public provider;

	mapping(address => Stake[]) public stakes;

	mapping(uint8 => StakeOption) public stakeOptions;

	modifier isAdmin() {

		require(admin == msg.sender, "Admin only function");
		_;
	}

	event Deposit(address _user, uint256 _amount, uint256 _timestamp);
	event Withdraw(address _user, uint256 _amount, uint256 _timestamp);
	event ExtendedStake(address _user, uint256 _amount, uint8 _stakeOption, uint256 _timestamp);
	event StakeEndWithBonus(address _user, uint256 _bonus, uint256 _timestamp);
	event StakeEndWithPenalty(address _user, uint256 _amount, uint256 _timestamp);
	event ClaimDrip(address _user, uint256 _amount, uint256 _timestamp);
	event Airdrop(address _sender, uint256 _amount, uint256 _timestamp);
	event EmissionRateChanged(uint256 _newEmissionRate);

	struct Stake {
		uint256 amount; // amount of tokens staked
		uint32 unlockDate; // unlocks at this timestamp
		uint8 stakeBonus; // the +% bonus this stake gives
	}

	struct StakeOption {
		uint32 duration;
		uint8 bonusPercent;
	}

	struct Provider {
		uint256 commitAmount; // user's extended stake aka. the locked amount
		uint256 balance; // user's available balance (to extended stake or to withdraw)
		uint256 dripBalance; // total drips collected before last deposit
		uint32 lastUpdateAt; // timestamp for last update when dripBalance was calculated
	}

	function depositIntoPool(uint256 _depositAmount) public {

		require(
			erc20.transferFrom(msg.sender, address(this), _depositAmount) == true,
			"transferFrom did not succeed. Are we approved?"
		);

		Provider storage user = provider[msg.sender];

		if (user.balance > 0) {
			user.dripBalance = dripBalance(msg.sender);
		}

		uint256 balanceToAdd = SafeMath.sub(_depositAmount, SafeMath.div(_depositAmount, 50));
		user.balance = SafeMath.add(user.balance, balanceToAdd);

		user.lastUpdateAt = uint32(now);
		totalBalance = SafeMath.add(totalBalance, balanceToAdd);

		emit Deposit(msg.sender, _depositAmount, now);
	}

	function withdrawFromPool(uint256 _amount) public {

		Provider storage user = provider[msg.sender];
		uint256 availableBalance = SafeMath.sub(user.balance, user.commitAmount);
		require(_amount <= availableBalance, "Amount withdrawn exceeds available balance");

		claimDrip();

		uint256 amountToWithdraw = SafeMath.div(SafeMath.mul(_amount, 49), 50);

		uint256 contractBalance = erc20.balanceOf(address(this));

		uint256 amountToSend =
			SafeMath.div(SafeMath.mul(contractBalance, amountToWithdraw), totalBalance);

		user.balance = SafeMath.sub(user.balance, _amount);
		totalBalance = SafeMath.sub(totalBalance, _amount);

		erc20.transfer(msg.sender, amountToSend);

		emit Withdraw(msg.sender, _amount, now);
	}

	function extendedStake(uint256 _amount, uint8 _stakeOption) public {

		require(_stakeOption <= 2, "Invalid staking option");

		Provider storage user = provider[msg.sender];

		uint256 availableBalance = SafeMath.sub(user.balance, user.commitAmount);
		require(_amount <= availableBalance, "Stake amount exceeds available balance");

		uint32 unlockDate = uint32(now) + stakeOptions[_stakeOption].duration;
		uint8 stakeBonus = stakeOptions[_stakeOption].bonusPercent;

		user.commitAmount = SafeMath.add(user.commitAmount, _amount);

		stakes[msg.sender].push(Stake(_amount, unlockDate, stakeBonus));

		emit ExtendedStake(msg.sender, _amount, _stakeOption, now);
	}

	function claimStake(uint256 _stakeId) public {

		uint256 playerStakeCount = stakes[msg.sender].length;
		require(_stakeId < playerStakeCount, "Stake does not exist");

		Stake memory stake = stakes[msg.sender][_stakeId];
		require(stake.amount > 0, "Invalid stake amount");

		if (playerStakeCount > 1) {
			stakes[msg.sender][_stakeId] = stakes[msg.sender][playerStakeCount - 1];
		}
		delete stakes[msg.sender][playerStakeCount - 1];
		stakes[msg.sender].length--;

		Provider storage user = provider[msg.sender];

		if (stake.unlockDate <= now) {
			uint256 balanceToAdd = SafeMath.div(SafeMath.mul(stake.amount, stake.stakeBonus), 100);
			totalBalance = SafeMath.add(totalBalance, balanceToAdd);
			user.commitAmount = SafeMath.sub(user.commitAmount, stake.amount);
			user.balance = SafeMath.add(user.balance, balanceToAdd);
			emit StakeEndWithBonus(msg.sender, balanceToAdd, now);
		} else {
			uint256 weightToRemove = SafeMath.div(SafeMath.mul(3, stake.amount), 20);
			user.balance = SafeMath.sub(user.balance, weightToRemove);
			totalBalance = SafeMath.sub(totalBalance, weightToRemove);
			user.commitAmount = SafeMath.sub(user.commitAmount, stake.amount);
			emit StakeEndWithPenalty(msg.sender, weightToRemove, now);
		}
	}

	function claimDrip() public {

		Provider storage user = provider[msg.sender];
		uint256 amountToSend = dripBalance(msg.sender);
		user.dripBalance = 0;
		user.lastUpdateAt = uint32(now);
		erc20.transfer(msg.sender, amountToSend);
		emit ClaimDrip(msg.sender, amountToSend, now);
	}

	function airdrop(uint256 _amount) external {

		require(
			erc20.transferFrom(msg.sender, address(this), _amount) == true,
			"transferFrom did not succeed. Are we approved?"
		);
		emit Airdrop(msg.sender, _amount, now);
	}

	function changeEmissionRate(uint256 _emissionRate) external isAdmin {

		if (emissionRate != _emissionRate) {
			emissionRate = _emissionRate;
			emit EmissionRateChanged(_emissionRate);
		}
	}

	function withdrawETH() external isAdmin {

		admin.transfer(address(this).balance);
	}

	function transferAdmin(address _newAdmin) external isAdmin {

		admin = address(uint160(_newAdmin));
	}

	function withdrawERC20(TOKEN token) public isAdmin {

		require(address(token) != address(0), "Invalid address");
		require(address(token) != address(erc20), "Cannot withdraw the staking token");
		uint256 balance = token.balanceOf(address(this));
		token.transfer(admin, balance);
	}

	function _unDebitedDrips(Provider memory user) internal view returns (uint256) {

		return
			SafeMath.div(
				SafeMath.mul(
					SafeMath.mul(SafeMath.sub(now, uint256(user.lastUpdateAt)), emissionRate),
					user.balance
				),
				1e18
			);
	}

	function dripBalance(address _user) public view returns (uint256) {

		Provider memory user = provider[_user];
		return SafeMath.add(user.dripBalance, _unDebitedDrips(user));
	}

	function stakesOf(address _user) public view returns (uint256[3][] memory) {

		uint256 userStakeCount = stakes[_user].length;
		uint256[3][] memory data = new uint256[3][](userStakeCount);
		for (uint256 i = 0; i < userStakeCount; i++) {
			Stake memory stake = stakes[_user][i];
			data[i][0] = stake.amount;
			data[i][1] = stake.unlockDate;
			data[i][2] = stake.stakeBonus;
		}
		return (data);
	}
}

contract TOKEN {

	function balanceOf(address account) external view returns (uint256);


	function transfer(address recipient, uint256 amount) external returns (bool);


	function transferFrom(
		address sender,
		address recipient,
		uint256 amount
	) external returns (bool);

}

library SafeMath {

	function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

		if (a == 0) {
			return 0;
		}
		c = a * b;
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

	function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

		c = a + b;
		assert(c >= a);
		return c;
	}
}