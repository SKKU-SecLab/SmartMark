
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




struct VoSpoolRewardRate {
	uint8 fromTranche;
	uint8 toTranche;
	uint112 rewardPerTranche; // rewards per tranche
}

struct VoSpoolRewardRates {
	VoSpoolRewardRate zero;
	VoSpoolRewardRate one;
}

struct VoSpoolRewardUser {
	uint8 lastRewardRateIndex;
	uint248 earned;
}

struct VoSpoolRewardConfiguration {
	uint240 rewardRatesIndex;
	bool hasRewards;
	uint8 lastSetRewardTranche;
}

contract VoSpoolRewards is SpoolOwnable, IVoSpoolRewards {


	uint256 private constant FULL_POWER_TRANCHES_COUNT = 52 * 3;

	uint256 private constant TRANCHES_PER_WORD = 5;


	address public immutable spoolStaking;

	IVoSPOOL public immutable voSpool;

	VoSpoolRewardConfiguration public voSpoolRewardConfig;

	mapping(uint256 => VoSpoolRewardRates) public voSpoolRewardRates;

	mapping(address => VoSpoolRewardUser) public userRewards;

	mapping(uint256 => uint256) private _tranchePowers;


	constructor(
		address _spoolStaking,
		IVoSPOOL _voSpool,
		ISpoolOwner _spoolOwner
	) SpoolOwnable(_spoolOwner) {
		spoolStaking = _spoolStaking;
		voSpool = _voSpool;
	}


	function updateVoSpoolRewardRate(uint8 toTranche, uint112 rewardPerTranche) external onlyOwner {

		require(rewardPerTranche > 0, "VoSpoolRewards::updateVoSpoolRewardRate: Cannot update reward rate to 0");
		require(
			toTranche <= FULL_POWER_TRANCHES_COUNT,
			"VoSpoolRewards::updateVoSpoolRewardRate: Cannot set rewards after power starts maturing"
		);

		uint8 currentTrancheIndex = uint8(voSpool.getCurrentTrancheIndex());
		require(
			toTranche > currentTrancheIndex,
			"VoSpoolRewards::updateVoSpoolRewardRate: Cannot set rewards for finished tranches"
		);

		uint256 rewardRatesIndex = voSpoolRewardConfig.rewardRatesIndex;

		VoSpoolRewardRate memory voSpoolRewardRate = VoSpoolRewardRate(
			currentTrancheIndex,
			toTranche,
			rewardPerTranche
		);

		if (rewardRatesIndex == 0) {
			voSpoolRewardRates[0].one = voSpoolRewardRate;
			rewardRatesIndex = 1;
		} else {
			VoSpoolRewardRate storage previousRewardRate = _getRewardRate(rewardRatesIndex);

			if (previousRewardRate.toTranche > currentTrancheIndex) {
				if (previousRewardRate.fromTranche == currentTrancheIndex) {
					_setRewardRate(voSpoolRewardRate, rewardRatesIndex);
					voSpoolRewardConfig = VoSpoolRewardConfiguration(uint240(rewardRatesIndex), true, toTranche);
					return;
				}

				previousRewardRate.toTranche = currentTrancheIndex;
			}

			unchecked {
				rewardRatesIndex++;
			}

			_setRewardRate(voSpoolRewardRate, rewardRatesIndex);
		}

		voSpoolRewardConfig = VoSpoolRewardConfiguration(uint240(rewardRatesIndex), true, toTranche);

		emit RewardRateUpdated(
			voSpoolRewardRate.fromTranche,
			voSpoolRewardRate.toTranche,
			voSpoolRewardRate.rewardPerTranche
		);
	}

	function endVoSpoolReward() external onlyOwner {

		uint8 currentTrancheIndex = uint8(voSpool.getCurrentTrancheIndex());
		uint256 rewardRatesIndex = voSpoolRewardConfig.rewardRatesIndex;

		require(rewardRatesIndex > 0, "VoSpoolRewards::endVoSpoolReward: No rewards configured");

		VoSpoolRewardRate storage currentRewardRate = _getRewardRate(rewardRatesIndex);

		require(
			currentRewardRate.toTranche > currentTrancheIndex,
			"VoSpoolRewards::endVoSpoolReward: Rewards already ended"
		);

		emit RewardEnded(
			rewardRatesIndex,
			currentRewardRate.fromTranche,
			currentRewardRate.toTranche,
			currentTrancheIndex
		);

		if (currentRewardRate.fromTranche == currentTrancheIndex) {
			_resetRewardRate(rewardRatesIndex);
			unchecked {
				rewardRatesIndex--;
			}

			if (rewardRatesIndex == 0) {
				voSpoolRewardConfig = VoSpoolRewardConfiguration(0, false, 0);
				return;
			}
		} else {
			currentRewardRate.toTranche = currentTrancheIndex;
		}

		voSpoolRewardConfig = VoSpoolRewardConfiguration(uint240(rewardRatesIndex), false, currentTrancheIndex);
	}


	function flushRewards(address user) external override onlySpoolStaking returns (uint256) {

		uint256 userEarned = userRewards[user].earned;
		if (userEarned > 0) {
			userRewards[user].earned = 0;
		}

		return userEarned;
	}

	function updateRewards(address user) external override onlySpoolStaking returns (uint256) {

		if (voSpoolRewardConfig.rewardRatesIndex == 0) return 0;

		if (voSpoolRewardConfig.hasRewards) {
			_storeVoSpoolForNewIndexes();
		}

		_updateUserVoSpoolRewards(user);

		return userRewards[user].earned;
	}

	function _storeVoSpoolForNewIndexes() private {

		uint256 lastFinishedTrancheIndex = voSpool.getLastFinishedTrancheIndex();
		GlobalGradual memory global = voSpool.getNotUpdatedGlobalGradual();

		if (global.lastUpdatedTrancheIndex >= lastFinishedTrancheIndex) {
			return;
		}

		uint256 lastSetRewardTranche = voSpoolRewardConfig.lastSetRewardTranche;
		uint256 trancheIndex = global.lastUpdatedTrancheIndex;
		do {
			if (trancheIndex >= lastSetRewardTranche) {
				voSpoolRewardConfig.hasRewards = false;
				return;
			}

			trancheIndex++;

			global.totalRawUnmaturedVotingPower += global.totalMaturingAmount;

			_storeTranchePowerForIndex(
				_getMaturingVotingPowerFromRaw(global.totalRawUnmaturedVotingPower),
				trancheIndex
			);
		} while (trancheIndex < lastFinishedTrancheIndex);
	}

	function _updateUserVoSpoolRewards(address user) private {

		UserGradual memory userGradual = voSpool.getNotUpdatedUserGradual(user);
		if (userGradual.maturingAmount == 0) {
			userRewards[user].lastRewardRateIndex = uint8(voSpoolRewardConfig.rewardRatesIndex);
			return;
		}

		uint256 lastFinishedTrancheIndex = voSpool.getLastFinishedTrancheIndex();
		uint256 trancheIndex = userGradual.lastUpdatedTrancheIndex;

		if (trancheIndex < lastFinishedTrancheIndex) {
			VoSpoolRewardUser memory voSpoolRewardUser = userRewards[user];

			VoSpoolRewardRate[] memory voSpoolRewardRatesArray = _getRewardRatesForIndex(
				voSpoolRewardUser.lastRewardRateIndex
			);

			uint256 vsrrI = 0;
			VoSpoolRewardRate memory rewardRate = voSpoolRewardRatesArray[0];

			do {
				unchecked {
					trancheIndex++;
				}

				if (trancheIndex >= rewardRate.toTranche) {
					unchecked {
						vsrrI++;
					}

					if (vsrrI < voSpoolRewardRatesArray.length) {
						rewardRate = voSpoolRewardRatesArray[vsrrI];
					} else {
						break;
					}
				}

				userGradual.rawUnmaturedVotingPower += userGradual.maturingAmount;

				if (trancheIndex >= rewardRate.fromTranche) {
					uint256 userPower = _getMaturingVotingPowerFromRaw(userGradual.rawUnmaturedVotingPower);

					uint256 tranchePowerAtIndex = getTranchePower(trancheIndex);

					if (tranchePowerAtIndex > 0) {
						voSpoolRewardUser.earned += uint248(
							(rewardRate.rewardPerTranche * userPower) / tranchePowerAtIndex
						);
					}
				}

			} while (trancheIndex < lastFinishedTrancheIndex);

			voSpoolRewardUser.lastRewardRateIndex = uint8(voSpoolRewardConfig.rewardRatesIndex);
			userRewards[user] = voSpoolRewardUser;

			emit UserRewardUpdated(user, voSpoolRewardUser.lastRewardRateIndex, voSpoolRewardUser.earned);
		}
	}


	function _setRewardRate(VoSpoolRewardRate memory voSpoolRewardRate, uint256 rewardRatesIndex) private {

		uint256 arrayIndex = rewardRatesIndex / 2;
		uint256 position = rewardRatesIndex % 2;

		if (position == 0) {
			voSpoolRewardRates[arrayIndex].zero = voSpoolRewardRate;
		} else {
			voSpoolRewardRates[arrayIndex].one = voSpoolRewardRate;
		}
	}

	function _resetRewardRate(uint256 rewardRatesIndex) private {

		_setRewardRate(VoSpoolRewardRate(0, 0, 0), rewardRatesIndex);
	}

	function _getRewardRate(uint256 rewardRatesIndex) private view returns (VoSpoolRewardRate storage) {

		uint256 arrayIndex = rewardRatesIndex / 2;
		uint256 position = rewardRatesIndex % 2;

		if (position == 0) {
			return voSpoolRewardRates[arrayIndex].zero;
		} else {
			return voSpoolRewardRates[arrayIndex].one;
		}
	}

	function _getRewardRatesForIndex(uint256 userLastRewardRateIndex)
		private
		view
		returns (VoSpoolRewardRate[] memory)
	{

		if (userLastRewardRateIndex == 0) userLastRewardRateIndex = 1;

		uint256 lastRewardRateIndex = voSpoolRewardConfig.rewardRatesIndex;
		uint256 newRewardRatesCount = lastRewardRateIndex - userLastRewardRateIndex + 1;
		VoSpoolRewardRate[] memory voSpoolRewardRatesArray = new VoSpoolRewardRate[](newRewardRatesCount);

		uint256 j = 0;
		for (uint256 i = userLastRewardRateIndex; i <= lastRewardRateIndex; i++) {
			voSpoolRewardRatesArray[j] = _getRewardRate(i);
			unchecked {
				j++;
			}
		}

		return voSpoolRewardRatesArray;
	}

	function _storeTranchePowerForIndex(uint256 power, uint256 index) private {

		uint256 arrayindex = index / TRANCHES_PER_WORD;

		uint256 globalTranchesPosition = index % TRANCHES_PER_WORD;

		if (globalTranchesPosition == 1) {
			power = power << 48;
		} else if (globalTranchesPosition == 2) {
			power = power << 96;
		} else if (globalTranchesPosition == 3) {
			power = power << 144;
		} else if (globalTranchesPosition == 4) {
			power = power << 192;
		}

		unchecked {
			_tranchePowers[arrayindex] += power;
		}
	}

	function getTranchePower(uint256 index) public view returns (uint256) {

		uint256 arrayindex = index / TRANCHES_PER_WORD;

		uint256 powers = _tranchePowers[arrayindex];

		uint256 globalTranchesPosition = index % TRANCHES_PER_WORD;

		if (globalTranchesPosition == 0) {
			return (powers << 208) >> 208;
		} else if (globalTranchesPosition == 1) {
			return (powers << 160) >> 208;
		} else if (globalTranchesPosition == 2) {
			return (powers << 112) >> 208;
		} else if (globalTranchesPosition == 3) {
			return (powers << 64) >> 208;
		} else {
			return (powers << 16) >> 208;
		}
	}

	function _getMaturingVotingPowerFromRaw(uint256 rawMaturingVotingPower) private pure returns (uint256) {

		return rawMaturingVotingPower / FULL_POWER_TRANCHES_COUNT;
	}


	function _onlySpoolStaking() private view {

		require(msg.sender == spoolStaking, "VoSpoolRewards::_onlySpoolStaking: Insufficient Privileges");
	}


	modifier onlySpoolStaking() {

		_onlySpoolStaking();
		_;
	}
}