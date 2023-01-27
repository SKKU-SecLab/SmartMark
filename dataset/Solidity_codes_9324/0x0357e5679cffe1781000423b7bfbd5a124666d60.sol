
pragma solidity ^0.8.1;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

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
}// MIT

pragma solidity ^0.8.0;


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }

    uint256[49] private __gap;
}// MIT

pragma solidity 0.8.13;

interface ISpoolOwner {

    function isSpoolOwner(address user) external view returns(bool);

}// MIT

pragma solidity 0.8.13;


abstract contract SpoolOwnable {
    ISpoolOwner internal immutable spoolOwner;
    
    constructor(ISpoolOwner _spoolOwner) {
        require(
            address(_spoolOwner) != address(0),
            "SpoolOwnable::constructor: Spool owner contract address cannot be 0"
        );

        spoolOwner = _spoolOwner;
    }

    function isSpoolOwner() internal view returns(bool) {
        return spoolOwner.isSpoolOwner(msg.sender);
    }

    function _onlyOwner() internal view {
        require(isSpoolOwner(), "SpoolOwnable::onlyOwner: Caller is not the Spool owner");
    }

    modifier onlyOwner() {
        _onlyOwner();
        _;
    }
}// MIT

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

pragma solidity 0.8.13;


interface ISpoolStaking {


	event Staked(address indexed user, uint256 amount);

	event StakedFor(address indexed stakedFor, address indexed stakedBy, uint256 amount);

	event Unstaked(address indexed user, uint256 amount);
	
	event RewardCompounded(address indexed user, uint256 reward);
	
	event VoRewardCompounded(address indexed user, uint256 reward);

	event RewardPaid(IERC20 token, address indexed user, uint256 reward);

	event VoSpoolRewardPaid(IERC20 token, address indexed user, uint256 reward);

	event RewardAdded(IERC20 indexed token, uint256 amount, uint256 duration);

	event RewardUpdated(IERC20 indexed token, uint256 amount, uint256 leftover, uint256 duration, uint32 periodFinish);

	event RewardRemoved(IERC20 indexed token);

	event PeriodFinishUpdated(IERC20 indexed token, uint32 periodFinish);

	event CanStakeForSet(address indexed account, bool canStakeFor);
}// MIT

pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

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
}// MIT

pragma solidity ^0.8.0;


library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;

library SafeCast {

    function toUint224(uint256 value) internal pure returns (uint224) {

        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    function toUint192(uint256 value) internal pure returns (uint192) {

        require(value <= type(uint192).max, "SafeCast: value doesn't fit in 128 bits");
        return uint192(value);
    }

    function toUint128(uint256 value) internal pure returns (uint128) {

        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }
}// MIT

pragma solidity 0.8.13;

interface IVoSpoolRewards {


	function updateRewards(address user) external returns (uint256);


	function flushRewards(address user) external returns (uint256);



	event RewardRateUpdated(uint8 indexed fromTranche, uint8 indexed toTranche, uint112 rewardPerTranche);

	event RewardEnded(
		uint256 indexed rewardRatesIndex,
		uint8 indexed fromTranche,
		uint8 indexed toTranche,
		uint8 currentTrancheIndex
	);

	event UserRewardUpdated(address indexed user, uint8 lastRewardRateIndex, uint248 earned);
}// MIT

pragma solidity 0.8.13;


struct GlobalGradual {
	uint48 totalMaturedVotingPower;
	uint48 totalMaturingAmount;
	uint56 totalRawUnmaturedVotingPower;
	uint16 lastUpdatedTrancheIndex;
}

struct UserTranchePosition {
	uint16 arrayIndex;
	uint8 position;
}

struct UserGradual {
	uint48 maturedVotingPower; // matured voting amount, power accumulated and older than FULL_POWER_TIME, not accumulating anymore
	uint48 maturingAmount; // total maturing amount (also maximum matured)
	uint56 rawUnmaturedVotingPower; // current user raw unmatured voting power (increases every new tranche), actual unmatured voting power can be calculated as unmaturedVotingPower / FULL_POWER_TRANCHES_COUNT
	UserTranchePosition oldestTranchePosition; // if arrayIndex is 0, user has no tranches (even if `latestTranchePosition` is not empty)
	UserTranchePosition latestTranchePosition; // can only increment, in case of tranche removal, next time user gradually mints we point at tranche at next position
	uint16 lastUpdatedTrancheIndex;
}

interface IVoSPOOL {


	function mint(address, uint256) external;


	function burn(address, uint256) external;


	function mintGradual(address, uint256) external;


	function burnGradual(
		address,
		uint256,
		bool
	) external;


	function updateVotingPower() external;


	function updateUserVotingPower(address user) external;


	function getTotalGradualVotingPower() external returns (uint256);


	function getUserGradualVotingPower(address user) external returns (uint256);


	function getNotUpdatedUserGradual(address user) external view returns (UserGradual memory);


	function getNotUpdatedGlobalGradual() external view returns (GlobalGradual memory);


	function getCurrentTrancheIndex() external view returns (uint16);


	function getLastFinishedTrancheIndex() external view returns (uint16);



	event Minted(address indexed recipient, uint256 amount);

	event Burned(address indexed source, uint256 amount);

	event GradualMinted(address indexed recipient, uint256 amount);

	event GradualBurned(address indexed source, uint256 amount, bool burnAll);

	event GlobalGradualUpdated(
		uint16 indexed lastUpdatedTrancheIndex,
		uint48 totalMaturedVotingPower,
		uint48 totalMaturingAmount,
		uint56 totalRawUnmaturedVotingPower
	);

	event UserGradualUpdated(
		address indexed user,
		uint16 indexed lastUpdatedTrancheIndex,
		uint48 maturedVotingPower,
		uint48 maturingAmount,
		uint56 rawUnmaturedVotingPower
	);

	event MinterSet(address indexed minter, bool set);

	event GradualMinterSet(address indexed minter, bool set);
}// MIT

pragma solidity 0.8.13;


interface IRewardDistributor {


	function payRewards(
		address account,
		IERC20[] memory tokens,
		uint256[] memory amounts
	) external;


	function payReward(
		address account,
		IERC20 token,
		uint256 amount
	) external;



	event RewardPaid(IERC20 token, address indexed account, uint256 amount);
	event RewardRetrieved(IERC20 token, address indexed account, uint256 amount);
	event DistributorUpdated(address indexed user, bool set);
	event PauserUpdated(address indexed user, bool set);
}// MIT

pragma solidity 0.8.13;




struct RewardConfiguration {
	uint32 rewardsDuration;
	uint32 periodFinish;
	uint192 rewardRate; // rewards per second multiplied by accuracy
	uint32 lastUpdateTime;
	uint224 rewardPerTokenStored;
	mapping(address => uint256) userRewardPerTokenPaid;
	mapping(address => uint256) rewards;
}

contract SpoolStaking is ReentrancyGuardUpgradeable, SpoolOwnable, ISpoolStaking {

	using SafeERC20 for IERC20;


	uint256 private constant REWARD_ACCURACY = 1e18;


	IERC20 public immutable stakingToken;

	IVoSPOOL public immutable voSpool;

	IVoSpoolRewards public immutable voSpoolRewards;

	IRewardDistributor public immutable rewardDistributor;

	mapping(IERC20 => RewardConfiguration) public rewardConfiguration;

	IERC20[] public rewardTokens;

	mapping(IERC20 => bool) public tokenBlacklist;

	uint256 public totalStaked;

	mapping(address => uint256) public balances;

	mapping(address => bool) public canStakeFor;

	mapping(address => address) public stakedBy;


	constructor(
		IERC20 _stakingToken,
		IVoSPOOL _voSpool,
		IVoSpoolRewards _voSpoolRewards,
		IRewardDistributor _rewardDistributor,
		ISpoolOwner _spoolOwner
	) SpoolOwnable(_spoolOwner) {
		stakingToken = _stakingToken;
		voSpool = _voSpool;
		voSpoolRewards = _voSpoolRewards;
		rewardDistributor = _rewardDistributor;
	}


	function initialize() external initializer {

		__ReentrancyGuard_init();
	}


	function lastTimeRewardApplicable(IERC20 token) public view returns (uint32) {

		return uint32(_min(block.timestamp, rewardConfiguration[token].periodFinish));
	}

	function rewardPerToken(IERC20 token) public view returns (uint224) {

		RewardConfiguration storage config = rewardConfiguration[token];

		if (totalStaked == 0) return config.rewardPerTokenStored;

		uint256 timeDelta = lastTimeRewardApplicable(token) - config.lastUpdateTime;

		if (timeDelta == 0) return config.rewardPerTokenStored;

		return SafeCast.toUint224(config.rewardPerTokenStored + ((timeDelta * config.rewardRate) / totalStaked));
	}

	function earned(IERC20 token, address account) public view returns (uint256) {

		RewardConfiguration storage config = rewardConfiguration[token];

		uint256 accountStaked = balances[account];

		if (accountStaked == 0) return config.rewards[account];

		uint256 userRewardPerTokenPaid = config.userRewardPerTokenPaid[account];

		return
			((accountStaked * (rewardPerToken(token) - userRewardPerTokenPaid)) / REWARD_ACCURACY) +
			config.rewards[account];
	}

	function rewardTokensCount() external view returns (uint256) {

		return rewardTokens.length;
	}


	function stake(uint256 amount) external nonReentrant updateRewards(msg.sender) {

		_stake(msg.sender, amount);

		stakingToken.safeTransferFrom(msg.sender, address(this), amount);

		emit Staked(msg.sender, amount);
	}

	function _stake(address account, uint256 amount) private {

		require(amount > 0, "SpoolStaking::_stake: Cannot stake 0");

		unchecked {
			totalStaked = totalStaked += amount;
			balances[account] += amount;
		}

		voSpool.mintGradual(account, amount);
	}

	function compound(bool doCompoundVoSpoolRewards) external nonReentrant {

		uint256 reward = _getRewardForCompound(msg.sender, doCompoundVoSpoolRewards);

		if (reward > 0) {
			_updateSpoolRewards(msg.sender);

			if (!doCompoundVoSpoolRewards) {
				_updateVoSpoolReward(msg.sender);
			}

			_stake(msg.sender, reward);
			rewardDistributor.payReward(address(this), stakingToken, reward);
		}
	}

	function unstake(uint256 amount) public nonReentrant notStakedBy updateRewards(msg.sender) {

		require(amount > 0, "SpoolStaking::unstake: Cannot withdraw 0");
		require(amount <= balances[msg.sender], "SpoolStaking::unstake: Cannot unstake more than staked");

		unchecked {
			totalStaked = totalStaked -= amount;
			balances[msg.sender] -= amount;
		}

		stakingToken.safeTransfer(msg.sender, amount);

		if (balances[msg.sender] == 0) {
			voSpool.burnGradual(msg.sender, 0, true);
		} else {
			voSpool.burnGradual(msg.sender, amount, false);
		}

		emit Unstaked(msg.sender, amount);
	}

	function _getRewardForCompound(address account, bool doCompoundVoSpoolRewards)
		internal
		updateReward(stakingToken, account)
		returns (uint256 reward)
	{

		RewardConfiguration storage config = rewardConfiguration[stakingToken];

		reward = config.rewards[account];
		if (reward > 0) {
			config.rewards[account] = 0;
			emit RewardCompounded(msg.sender, reward);
		}

		if (doCompoundVoSpoolRewards) {
			_updateVoSpoolReward(account);
			uint256 voSpoolreward = voSpoolRewards.flushRewards(account);

			if (voSpoolreward > 0) {
				reward += voSpoolreward;
				emit VoRewardCompounded(msg.sender, reward);
			}
		}
	}

	function getRewards(IERC20[] memory tokens, bool doClaimVoSpoolRewards) external nonReentrant notStakedBy {

		for (uint256 i; i < tokens.length; i++) {
			_getReward(tokens[i], msg.sender);
		}

		if (doClaimVoSpoolRewards) {
			_getVoSpoolRewards(msg.sender);
		}
	}

	function getActiveRewards(bool doClaimVoSpoolRewards) external nonReentrant notStakedBy {

		_getActiveRewards(msg.sender);

		if (doClaimVoSpoolRewards) {
			_getVoSpoolRewards(msg.sender);
		}
	}

	function getUpdatedVoSpoolRewardAmount() external returns (uint256 rewards) {

		rewards = voSpoolRewards.updateRewards(msg.sender);
		voSpool.updateUserVotingPower(msg.sender);
	}

	function _getActiveRewards(address account) internal {

		uint256 _rewardTokensCount = rewardTokens.length;
		for (uint256 i; i < _rewardTokensCount; i++) {
			_getReward(rewardTokens[i], account);
		}
	}

	function _getReward(IERC20 token, address account) internal updateReward(token, account) {

		RewardConfiguration storage config = rewardConfiguration[token];

		require(config.rewardsDuration != 0, "SpoolStaking::_getReward: Bad reward token");

		uint256 reward = config.rewards[account];
		if (reward > 0) {
			config.rewards[account] = 0;
			rewardDistributor.payReward(account, token, reward);
			emit RewardPaid(token, account, reward);
		}
	}

	function _getVoSpoolRewards(address account) internal {

		_updateVoSpoolReward(account);
		uint256 reward = voSpoolRewards.flushRewards(account);

		if (reward > 0) {
			rewardDistributor.payReward(account, stakingToken, reward);
			emit VoSpoolRewardPaid(stakingToken, account, reward);
		}
	}


	function stakeFor(address account, uint256 amount)
		external
		nonReentrant
		canStakeForAddress(account)
		updateRewards(account)
	{

		_stake(account, amount);
		stakingToken.safeTransferFrom(msg.sender, address(this), amount);
		stakedBy[account] = msg.sender;

		emit StakedFor(account, msg.sender, amount);
	}

	function allowUnstakeFor(address allowFor) external {

		require(
			(canStakeFor[msg.sender] && stakedBy[allowFor] == msg.sender) || isSpoolOwner(),
			"SpoolStaking::allowUnstakeFor: Cannot allow unstaking for address"
		);
		stakedBy[allowFor] = address(0);
	}

	function addToken(
		IERC20 token,
		uint32 rewardsDuration,
		uint256 reward
	) external onlyOwner {

		RewardConfiguration storage config = rewardConfiguration[token];

		require(!tokenBlacklist[token], "SpoolStaking::addToken: Cannot add blacklisted token");
		require(rewardsDuration != 0, "SpoolStaking::addToken: Reward duration cannot be 0");
		require(config.lastUpdateTime == 0, "SpoolStaking::addToken: Token already added");

		rewardTokens.push(token);

		config.rewardsDuration = rewardsDuration;

		if (reward > 0) {
			_notifyRewardAmount(token, reward);
		}
	}

	function notifyRewardAmount(
		IERC20 token,
		uint32 _rewardsDuration,
		uint256 reward
	) external onlyOwner {

		RewardConfiguration storage config = rewardConfiguration[token];
		config.rewardsDuration = _rewardsDuration;
		require(
			rewardConfiguration[token].lastUpdateTime != 0,
			"SpoolStaking::notifyRewardAmount: Token not yet added"
		);
		_notifyRewardAmount(token, reward);
	}

	function _notifyRewardAmount(IERC20 token, uint256 reward) private updateReward(token, address(0)) {

		RewardConfiguration storage config = rewardConfiguration[token];

		require(
			config.rewardPerTokenStored + (reward * REWARD_ACCURACY) <= type(uint192).max,
			"SpoolStaking::_notifyRewardAmount: Reward amount too big"
		);

		uint32 newPeriodFinish = uint32(block.timestamp) + config.rewardsDuration;

		if (block.timestamp >= config.periodFinish) {
			config.rewardRate = SafeCast.toUint192((reward * REWARD_ACCURACY) / config.rewardsDuration);
			emit RewardAdded(token, reward, config.rewardsDuration);
		} else {
			uint256 remaining = config.periodFinish - block.timestamp;
			uint256 leftover = remaining * config.rewardRate;
			uint192 newRewardRate = SafeCast.toUint192((reward * REWARD_ACCURACY + leftover) / config.rewardsDuration);

			config.rewardRate = newRewardRate;
			emit RewardUpdated(token, reward, leftover, config.rewardsDuration, newPeriodFinish);
		}

		config.lastUpdateTime = uint32(block.timestamp);
		config.periodFinish = newPeriodFinish;
	}

	function updatePeriodFinish(IERC20 token, uint32 timestamp) external onlyOwner updateReward(token, address(0)) {

		if (rewardConfiguration[token].lastUpdateTime > timestamp) {
			rewardConfiguration[token].periodFinish = rewardConfiguration[token].lastUpdateTime;
		} else {
			rewardConfiguration[token].periodFinish = timestamp;
		}

		emit PeriodFinishUpdated(token, rewardConfiguration[token].periodFinish);
	}

	function removeReward(IERC20 token) external onlyOwner onlyFinished(token) updateReward(token, address(0)) {

		_removeReward(token);
	}

	function setCanStakeFor(address account, bool _canStakeFor) external onlyOwner {

		canStakeFor[account] = _canStakeFor;
		emit CanStakeForSet(account, _canStakeFor);
	}

	function recoverERC20(
		IERC20 tokenAddress,
		uint256 tokenAmount,
		address recoverTo
	) external onlyOwner {

		require(tokenAddress != stakingToken, "SpoolStaking::recoverERC20: Cannot withdraw the staking token");
		tokenAddress.safeTransfer(recoverTo, tokenAmount);
	}


	function _updateRewards(address account) private {

		_updateSpoolRewards(account);

		_updateVoSpoolReward(account);
	}

	function _updateSpoolRewards(address account) private {

		uint256 _rewardTokensCount = rewardTokens.length;

		for (uint256 i; i < _rewardTokensCount; i++) _updateReward(rewardTokens[i], account);
	}

	function _updateReward(IERC20 token, address account) private {

		RewardConfiguration storage config = rewardConfiguration[token];
		config.rewardPerTokenStored = rewardPerToken(token);
		config.lastUpdateTime = lastTimeRewardApplicable(token);
		if (account != address(0)) {
			config.rewards[account] = earned(token, account);
			config.userRewardPerTokenPaid[account] = config.rewardPerTokenStored;
		}
	}

	function _updateVoSpoolReward(address account) private {

		voSpoolRewards.updateRewards(account);
		voSpool.updateUserVotingPower(account);
	}

	function _removeReward(IERC20 token) private {

		uint256 _rewardTokensCount = rewardTokens.length;
		for (uint256 i; i < _rewardTokensCount; i++) {
			if (rewardTokens[i] == token) {
				rewardTokens[i] = rewardTokens[_rewardTokensCount - 1];

				rewardTokens.pop();
				emit RewardRemoved(token);
				break;
			}
		}
	}

	function _onlyFinished(IERC20 token) private view {

		require(
			block.timestamp > rewardConfiguration[token].periodFinish,
			"SpoolStaking::_onlyFinished: Reward not finished"
		);
	}

	function _min(uint256 a, uint256 b) private pure returns (uint256) {

		return a > b ? b : a;
	}


	modifier updateReward(IERC20 token, address account) {

		_updateReward(token, account);
		_;
	}

	modifier updateRewards(address account) {

		_updateRewards(account);
		_;
	}

	modifier canStakeForAddress(address account) {

		require(
			canStakeFor[msg.sender] || isSpoolOwner(),
			"SpoolStaking::canStakeForAddress: Cannot stake for other addresses"
		);

		if (balances[account] > 0) {
			require(stakedBy[account] != address(0), "SpoolStaking::canStakeForAddress: Address already staked");

			require(
				stakedBy[account] == msg.sender || isSpoolOwner(),
				"SpoolStaking::canStakeForAddress: Address staked by another address"
			);
		}
		_;
	}

	modifier notStakedBy() {

		require(stakedBy[msg.sender] == address(0), "SpoolStaking::notStakedBy: Cannot withdraw until allowed");
		_;
	}

	modifier onlyFinished(IERC20 token) {

		_onlyFinished(token);
		_;
	}
}