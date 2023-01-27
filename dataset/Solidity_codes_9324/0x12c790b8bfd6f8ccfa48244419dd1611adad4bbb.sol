



pragma solidity ^0.6.0;

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


pragma solidity ^0.6.0;


library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


pragma solidity ^0.6.0;

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

pragma solidity ^0.6.2;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}


pragma solidity 0.6.12;


contract WBTCexPro {

	using SafeMath for uint256;
	using SafeERC20 for IERC20;
	IERC20 public  investToken;

	uint256 constant public INVEST_MIN_AMOUNT = 1e5; // 0.001 WBTC
	uint256 constant public PERCENTS_DIVIDER =  1e13 ;//1000;
	uint256 constant public BASE_PERCENT = 10e11;
	uint256 constant public MAX_PERCENT = 30*(1e12);
	uint256 constant public MARKETING_FEE = 60*(1e10);
	uint256 constant public PROJECT_FEE = 20*(1e10);
	uint256 constant public DEV_FEE = 20*(1e10);

	uint256 public REFERRAL_PERCENTS = 1e11;
	
	uint256 constant public TIME_STEP = 1 days ; //days
	uint256 constant public BASE_AMOUNT_DALIY = 1e11; // 10w USDT
	uint256 constant public START_POINT = 1606828881; // Singapore time at: 2020-11-11 11:11:11
	uint256 constant public PERCENT_INVEST = 10; // increase percent pre Invest
	uint256 constant public PERCENT_WITHDRAW = 15; // decreased percent pre Withdraw

	uint256 public presentPercent = 1e11;

	uint256 public presentDayAmount = BASE_AMOUNT_DALIY;
	uint256 public presentDaysInterval = 0;

	uint256 public totalLottery; //sum of latest 100 ticker
	uint256 public totalLotteryReward; //sum of 5% of invest

	uint256 public totalUsers;
	uint256 public totalInvested;
	uint256 public totalWithdrawn;
	uint256 public totalDeposits;

	uint256 public announceAt;
	bool public announceWinner; //  announce Winners

	address public marketingAddress;
	address public projectAddress;
	address public devAddress;

	address public rewardPool;
	address public obsoleteExitTo;
	

	struct Deposit {
		uint256 amount;
		uint256 withdrawn;
		uint256 start;
	}

	struct User {
		Deposit[] deposits;
		uint256 checkpoint;
		address referrer;
		uint256 bonus;
		uint256 totalInvested;
		uint256 totalBonus;
		uint256 missedBonus;
		uint256 lotteryBonus;
	}
	struct LotteryTicket {
		address user;
		uint256 amount;
	}

	mapping (address => User) internal users;
	mapping (uint256 => uint256) internal daliyInvestAmount;
	mapping(address => uint256[]) public userLotteryTicker;
	LotteryTicket[] public  lotteryPool;

	event Newbie(address user);
	event NewDeposit(address indexed user, uint256 amount);
	event Withdrawn(address indexed user, uint256 amount);
	event MissBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
	event FeePayed(address indexed user, uint256 totalAmount);
	event WithdrawWinning(address indexed user, uint256 amount);

	constructor(address _investToken, address marketingAddr, address projectAddr, address devAddr, address _obsoleteExitTo) public {
		require(!isContract(marketingAddr) && !isContract(projectAddr));
		investToken = IERC20(_investToken);
		marketingAddress = marketingAddr;
		projectAddress = projectAddr;
		devAddress = devAddr;
		obsoleteExitTo = _obsoleteExitTo;

	}

	function setRewardPool(address _rewardPool) public {

		require(rewardPool == address(0), "Invalid operation");
		rewardPool = _rewardPool;
	}

	function updateTodayAmount(uint daysInterval) private {


		if(daysInterval > presentDaysInterval) {
			uint power = daysInterval - presentDaysInterval;

			for (uint256 index = 0; index < power; index++) {
				presentDayAmount = presentDayAmount.mul(11).div(10);
			}

			presentDaysInterval = daysInterval;
		}
	}

	function invest(address referrer , uint256 _amount) public {

		require(_amount >= INVEST_MIN_AMOUNT, "Less than minimum");
		require(!isContract(msg.sender), "cannot call from contract");
		require(!announceWinner, "Game Over"); // game over!
		
		uint daysInterval = getDaysInterval(); // count days passed
		updateTodayAmount(daysInterval);
	
		uint todayAmount = presentDayAmount.sub(daliyInvestAmount[daysInterval]);
		require(todayAmount>0, "Sold out today");
		uint amount = _amount > todayAmount  ? _amount.sub(todayAmount) : _amount;

		investToken.safeTransferFrom(address(msg.sender), address(this), amount);
		investToken.safeTransfer( address(marketingAddress), amount.mul(MARKETING_FEE).div(PERCENTS_DIVIDER));
		investToken.safeTransfer( address(projectAddress), amount.mul(PROJECT_FEE).div(PERCENTS_DIVIDER));
		investToken.safeTransfer( address(devAddress), amount.mul(DEV_FEE).div(PERCENTS_DIVIDER));
		

		User storage user = users[msg.sender];

		if (user.referrer == address(0) && users[referrer].deposits.length > 0 && referrer != msg.sender) {
			user.referrer = referrer;
		}

		if (user.referrer != address(0)) {

			address upline = user.referrer;
			for (uint256 i = 0; i < 10; i++) {
				if (upline != address(0)) {
					uint256 bonuAmount = amount.mul(REFERRAL_PERCENTS).div(PERCENTS_DIVIDER);
					if (users[upline].totalBonus.add(bonuAmount) <= users[upline].totalInvested) {
						users[upline].bonus = users[upline].bonus.add(bonuAmount);
						users[upline].totalBonus = users[upline].totalBonus.add(bonuAmount);
						
					} else {
						users[upline].missedBonus = users[upline].missedBonus.add(bonuAmount);	
						emit MissBonus(upline, msg.sender, i, bonuAmount);
					}
					upline = users[upline].referrer;
				} else break;
			}

		}

		if (user.deposits.length == 0) {
			user.checkpoint = block.timestamp;
			totalUsers = totalUsers.add(1);
		}

		user.deposits.push(Deposit(amount, 0, block.timestamp));
		user.totalInvested = user.totalInvested.add(amount);

		updateRate(amount, true);
		addLotteryTicket(msg.sender, amount);

		daliyInvestAmount[daysInterval] = daliyInvestAmount[daysInterval].add(amount);

		totalInvested = totalInvested.add(amount);
		totalDeposits = totalDeposits.add(1);
		
		emit NewDeposit(msg.sender, amount);
	}

	function addLotteryTicket(address _user, uint256 _amount) private {

		uint256 index = totalDeposits  % 100;//100  totalDeposits from 0
		LotteryTicket[] storage  lotPool = lotteryPool;

		if (lotPool.length == 100) { //reuse 100
			totalLottery = totalLottery.add(_amount).sub(lotPool[index].amount);
			lotPool[index].amount = _amount;
			lotPool[index].user   = _user;

		} else {
			lotPool.push(LotteryTicket({
				user : _user,
				amount : _amount
			}));
			totalLottery = totalLottery.add(_amount);
		}
		userLotteryTicker[_user].push(index);

		totalLotteryReward = totalLotteryReward.add( _amount.div(20) );
		investToken.safeTransfer( rewardPool, _amount.div(20));
	}

	function withdrawWinning() public {	

		require(announceWinner, "Not allowed");
		
		uint256 winning = winningAmount(msg.sender);
		require(winning > 0, "No winnings");

		User storage user = users[msg.sender];
		user.lotteryBonus = user.lotteryBonus.add(winning);

		investToken.safeTransferFrom( rewardPool , msg.sender, winning);

		emit WithdrawWinning(msg.sender, winning);
	}

	function winningAmount(address _user) public view returns (uint256) {

		uint256[] memory useTickers = userLotteryTicker[_user];

		if (useTickers.length == 0 ) {
			return 0;
		}

		uint userAmount;
		LotteryTicket[] memory lotPool = lotteryPool;
		for (uint256 i = useTickers.length - 1 ; i < useTickers.length; i--) {

			if(lotPool[useTickers[i]].user == _user) {
				userAmount = userAmount.add(lotPool[useTickers[i]].amount);
			}else break;
		}

		return userAmount.mul(totalLotteryReward).div(totalLottery).sub(users[msg.sender].lotteryBonus);

	}

	function withdraw() public {

		require(!announceWinner, "Game Over"); // game over!
		User storage user = users[msg.sender];

		uint256 userPercentRate = presentPercent;

		uint256 totalAmount;
		uint256 dividends;

		for (uint256 i = 0; i < user.deposits.length; i++) {

			if (user.deposits[i].withdrawn < user.deposits[i].amount.mul(30).div(10)) {

				if (user.deposits[i].start > user.checkpoint) {

					dividends = (user.deposits[i].amount.mul(userPercentRate).div(PERCENTS_DIVIDER))
						.mul(block.timestamp.sub(user.deposits[i].start))
						.div(TIME_STEP);

				} else {

					dividends = (user.deposits[i].amount.mul(userPercentRate).div(PERCENTS_DIVIDER))
						.mul(block.timestamp.sub(user.checkpoint))
						.div(TIME_STEP);

				}

				if (user.deposits[i].withdrawn.add(dividends) > user.deposits[i].amount.mul(30).div(10)) {
					dividends = (user.deposits[i].amount.mul(30).div(10)).sub(user.deposits[i].withdrawn);
				}

				user.deposits[i].withdrawn = user.deposits[i].withdrawn.add(dividends); /// changing of storage data
				totalAmount = totalAmount.add(dividends);

			}
		}

		uint256 referralBonus = getUserReferralBonus(msg.sender);
		if (referralBonus > 0) {
			totalAmount = totalAmount.add(referralBonus);
			user.bonus = 0;
		}

		require(totalAmount > 0, "User has no dividends");
		uint256 contractBalance = investToken.balanceOf(address(this));
		if (contractBalance <= totalAmount) {
			totalAmount = contractBalance;
			announceWinner = true;
			announceAt = block.timestamp;
		}

		user.checkpoint = block.timestamp;

		investToken.safeTransfer( msg.sender, totalAmount);

		totalWithdrawn = totalWithdrawn.add(totalAmount);

		updateRate(totalAmount, false);
		emit Withdrawn(msg.sender, totalAmount);

	}

	function getDailyAmount() public view returns (uint256) {

		
		uint256 timePower = getDaysInterval().sub(presentDaysInterval);
		uint presentAmount = presentDayAmount;
		for (uint256 index = 0; index < timePower; index++) { // 10% increase daily
				presentAmount = presentAmount.mul(11).div(10);
		}
		return presentAmount; 
	}

	function getDaysInterval() public view returns (uint256) {

		require(now >= START_POINT, "Not yet started");
		return  now.div(TIME_STEP).sub(START_POINT.div(TIME_STEP));
	}
	function getContractBalance() public view returns (uint256) {

		return investToken.balanceOf(address(this));
	}
	function updateRate(uint256 _amount, bool _invest) private {

		if (_invest) {
			presentPercent = presentPercent.add( _amount.mul(PERCENT_INVEST) );
			if ( presentPercent > MAX_PERCENT ) {
				presentPercent = MAX_PERCENT;
			}
		} else {
			uint decrease = _amount.mul(PERCENT_WITHDRAW);
			if ( presentPercent < BASE_PERCENT.add(decrease) ) {
				presentPercent = BASE_PERCENT;
			} else {
				presentPercent = presentPercent.sub(decrease);
			}
		}
		
	}

	function getUserDividends(address userAddress) public view returns (uint256) {

		User storage user = users[userAddress];

		uint256 userPercentRate = presentPercent;

		uint256 totalDividends;
		uint256 dividends;

		for (uint256 i = 0; i < user.deposits.length; i++) {

			if (user.deposits[i].withdrawn < user.deposits[i].amount.mul(30).div(10)) {

				if (user.deposits[i].start > user.checkpoint) {

					dividends = (user.deposits[i].amount.mul(userPercentRate).div(PERCENTS_DIVIDER))
						.mul(block.timestamp.sub(user.deposits[i].start))
						.div(TIME_STEP);

				} else {

					dividends = (user.deposits[i].amount.mul(userPercentRate).div(PERCENTS_DIVIDER))
						.mul(block.timestamp.sub(user.checkpoint))
						.div(TIME_STEP);

				}

				if (user.deposits[i].withdrawn.add(dividends) > user.deposits[i].amount.mul(30).div(10)) {
					dividends = (user.deposits[i].amount.mul(30).div(10)).sub(user.deposits[i].withdrawn);
				}

				totalDividends = totalDividends.add(dividends);


			}

		}

		return totalDividends;
	}


	function obsoleteExit() public {

		
		require( announceWinner, "Not yet announce winner" );
		
		uint256 step = 3 days;
		require( now > announceAt.add(step), "Not yet ripe" );

		uint256 amount = investToken.balanceOf(rewardPool);
		investToken.safeTransferFrom(rewardPool, obsoleteExitTo, amount);
	}

	function getStartPoint() public pure returns(uint256) {

		return START_POINT;
	} 
	function getUserPercent() public view returns(uint256) {

		return presentPercent.div(1e9);
	}
	function getBasePercent() public pure returns(uint256) {

		return BASE_PERCENT.div(1e9);
	}
	function getContractPercent() public view returns(uint256) {

		return presentPercent.sub(BASE_PERCENT).div(1e9);
	}

	function getTodayAmount() public view returns(uint256) {

		return getDailyAmount().sub(daliyInvestAmount[getDaysInterval()]);
	}

	function getUserCheckpoint(address userAddress) public view returns(uint256) {

		return users[userAddress].checkpoint;
	}

	function getUserMissedBonus(address userAddress) public view returns(uint256) {

		return users[userAddress].missedBonus;
	}

	function getUserTotalBonus(address userAddress) public view returns(uint256) {

		return users[userAddress].totalBonus;
	}

	function getUserReferrer(address userAddress) public view returns(address) {

		return users[userAddress].referrer;
	}

	function getUserReferralBonus(address userAddress) public view returns(uint256) {

		return users[userAddress].bonus;
	}

	function getUserAvailable(address userAddress) public view returns(uint256) {

		return getUserReferralBonus(userAddress).add(getUserDividends(userAddress));
	}

	function getUserDepositInfo(address userAddress, uint256 index) public view returns(uint256, uint256, uint256) {

	    User storage user = users[userAddress];

		return (user.deposits[index].amount, user.deposits[index].withdrawn, user.deposits[index].start);
	}

	function getUserAmountOfDeposits(address userAddress) public view returns(uint256) {

		return users[userAddress].deposits.length;
	}

	function getUserTotalDeposits(address userAddress) public view returns(uint256) {

	    User storage user = users[userAddress];

		uint256 amount;

		for (uint256 i = 0; i < user.deposits.length; i++) {
			amount = amount.add(user.deposits[i].amount);
		}

		return amount;
	}

	function getUserTotalWithdrawn(address userAddress) public view returns(uint256) {

	    User storage user = users[userAddress];

		uint256 amount;

		for (uint256 i = 0; i < user.deposits.length; i++) {
			amount = amount.add(user.deposits[i].withdrawn);
		}

		return amount;
	}

	function isContract(address addr) internal view returns (bool) {

        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

}