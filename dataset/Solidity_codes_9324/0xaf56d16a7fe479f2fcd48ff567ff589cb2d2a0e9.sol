
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


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

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



struct Tranche {
	uint48 amount;
}

struct GlobalTranches {
	Tranche zero;
	Tranche one;
	Tranche two;
	Tranche three;
	Tranche four;
}

struct UserTranche {
	uint48 amount;
	uint16 index;
}

struct UserTranches {
	UserTranche zero;
	UserTranche one;
	UserTranche two;
	UserTranche three;
}

contract VoSPOOL is SpoolOwnable, IVoSPOOL, IERC20Metadata {


	uint256 private constant TRIM_SIZE = 10**12;
	uint256 private constant TRANCHES_PER_WORD = 5;

	uint256 public constant TRANCHE_TIME = 1 weeks;
	uint256 public constant FULL_POWER_TRANCHES_COUNT = 52 * 3;
	uint256 public constant FULL_POWER_TIME = TRANCHE_TIME * FULL_POWER_TRANCHES_COUNT;

	string public constant name = "Spool DAO Voting Token";
	string public constant symbol = "voSPOOL";
	uint8 public constant decimals = 18;


	uint256 public immutable firstTrancheStartTime;

	mapping(address => bool) public minters;
	mapping(address => bool) public gradualMinters;

	uint256 public totalInstantPower;
	mapping(address => uint256) public userInstantPower;

	GlobalGradual private _globalGradual;
	mapping(uint256 => GlobalTranches) public indexedGlobalTranches;

	mapping(address => UserGradual) private _userGraduals;
	mapping(address => mapping(uint256 => UserTranches)) public userTranches;


	constructor(ISpoolOwner _spoolOwner, uint256 _firstTrancheEndTime) SpoolOwnable(_spoolOwner) {
		require(
			_firstTrancheEndTime > block.timestamp,
			"voSPOOL::constructor: First tranche end time must be in the future"
		);
		require(
			_firstTrancheEndTime < block.timestamp + TRANCHE_TIME,
			"voSPOOL::constructor: First tranche end time must be less than full tranche time in the future"
		);

		unchecked {
			firstTrancheStartTime = _firstTrancheEndTime - TRANCHE_TIME;
		}
	}


	function totalSupply() external view override returns (uint256) {

		(GlobalGradual memory global, ) = _getUpdatedGradual();
		return totalInstantPower + _getTotalGradualVotingPower(global);
	}

	function balanceOf(address account) external view override returns (uint256) {

		(UserGradual memory _userGradual, ) = _getUpdatedGradualUser(account);

		return userInstantPower[account] + _getUserGradualVotingPower(_userGradual);
	}

	function transfer(address, uint256) external pure override returns (bool) {

		revert("voSPOOL::transfer: Prohibited Action");
	}

	function transferFrom(
		address,
		address,
		uint256
	) external pure override returns (bool) {

		revert("voSPOOL::transferFrom: Prohibited Action");
	}

	function approve(address, uint256) external pure override returns (bool) {

		revert("voSPOOL::approve: Prohibited Action");
	}

	function allowance(address, address) external pure override returns (uint256) {

		revert("voSPOOL::allowance: Prohibited Action");
	}


	function mint(address to, uint256 amount) external onlyMinter {

		totalInstantPower += amount;
		unchecked {
			userInstantPower[to] += amount;
		}
		emit Minted(to, amount);
	}

	function burn(address from, uint256 amount) external onlyMinter {

		require(userInstantPower[from] >= amount, "voSPOOL:burn: User instant power balance too low");
		unchecked {
			userInstantPower[from] -= amount;
			totalInstantPower -= amount;
		}
		emit Burned(from, amount);
	}



	function getTotalGradualVotingPower() external view returns (uint256) {

		(GlobalGradual memory global, ) = _getUpdatedGradual();
		return _getTotalGradualVotingPower(global);
	}

	function getGlobalGradual() external view returns (GlobalGradual memory) {

		(GlobalGradual memory global, ) = _getUpdatedGradual();
		return global;
	}

	function getNotUpdatedGlobalGradual() external view returns (GlobalGradual memory) {

		return _globalGradual;
	}

	function getUserGradualVotingPower(address user) external view returns (uint256) {

		(UserGradual memory _userGradual, ) = _getUpdatedGradualUser(user);
		return _getUserGradualVotingPower(_userGradual);
	}

	function getUserGradual(address user) external view returns (UserGradual memory) {

		(UserGradual memory _userGradual, ) = _getUpdatedGradualUser(user);
		return _userGradual;
	}

	function getNotUpdatedUserGradual(address user) external view returns (UserGradual memory) {

		return _userGraduals[user];
	}

	function getCurrentTrancheIndex() public view returns (uint16) {

		return _getTrancheIndex(block.timestamp);
	}

	function getTrancheIndex(uint256 time) external view returns (uint256) {

		require(
			time >= firstTrancheStartTime,
			"voSPOOL::getTrancheIndex: Time must be more or equal to the first tranche time"
		);

		return _getTrancheIndex(time);
	}

	function _getTrancheIndex(uint256 time) private view returns (uint16) {

		unchecked {
			return uint16(((time - firstTrancheStartTime) / TRANCHE_TIME) + 1);
		}
	}

	function getNextTrancheEndTime() external view returns (uint256) {

		return getTrancheEndTime(getCurrentTrancheIndex());
	}

	function getTrancheEndTime(uint256 trancheIndex) public view returns (uint256) {

		return firstTrancheStartTime + trancheIndex * TRANCHE_TIME;
	}

	function getLastFinishedTrancheIndex() public view returns (uint16) {

		unchecked {
			return getCurrentTrancheIndex() - 1;
		}
	}


	function mintGradual(address to, uint256 amount) external onlyGradualMinter updateGradual updateGradualUser(to) {

		uint48 trimmedAmount = _trim(amount);
		_mintGradual(to, trimmedAmount);
		emit GradualMinted(to, amount);
	}

	function _mintGradual(address to, uint48 trimmedAmount) private {

		if (trimmedAmount == 0) {
			return;
		}

		UserGradual memory _userGradual = _userGraduals[to];

		_userGradual.maturingAmount += trimmedAmount;
		_globalGradual.totalMaturingAmount += trimmedAmount;

		UserTranche memory latestTranche = _getUserTranche(to, _userGradual.latestTranchePosition);

		uint16 currentTrancheIndex = getCurrentTrancheIndex();

		bool isFirstGradualMint = !_hasTranches(_userGradual);

		if (isFirstGradualMint || latestTranche.index < currentTrancheIndex) {
			UserTranchePosition memory nextTranchePosition = _getNextUserTranchePosition(
				_userGradual.latestTranchePosition
			);

			if (isFirstGradualMint) {
				_userGradual.oldestTranchePosition = nextTranchePosition;
			}

			_userGradual.latestTranchePosition = nextTranchePosition;

			latestTranche = UserTranche(trimmedAmount, currentTrancheIndex);
		} else {
			latestTranche.amount += trimmedAmount;
		}

		_addGlobalTranche(latestTranche.index, trimmedAmount);

		_setUserTranche(to, _userGradual.latestTranchePosition, latestTranche);
		_userGraduals[to] = _userGradual;
	}

	function _addGlobalTranche(uint256 index, uint48 amount) private {

		Tranche storage tranche = _getTranche(index);
		tranche.amount += amount;
	}

	function _setUserTranche(
		address user,
		UserTranchePosition memory userTranchePosition,
		UserTranche memory tranche
	) private {

		UserTranches storage _userTranches = userTranches[user][userTranchePosition.arrayIndex];

		if (userTranchePosition.position == 0) {
			_userTranches.zero = tranche;
		} else if (userTranchePosition.position == 1) {
			_userTranches.one = tranche;
		} else if (userTranchePosition.position == 2) {
			_userTranches.two = tranche;
		} else {
			_userTranches.three = tranche;
		}
	}


	function burnGradual(
		address from,
		uint256 amount,
		bool burnAll
	) external onlyGradualMinter updateGradual updateGradualUser(from) {

		UserGradual memory _userGradual = _userGraduals[from];
		uint48 userTotalGradualAmount = _userGradual.maturedVotingPower + _userGradual.maturingAmount;

		if (_userGradual.maturedVotingPower > 0) {
			_globalGradual.totalMaturedVotingPower -= _userGradual.maturedVotingPower;
			_userGradual.maturedVotingPower = 0;
		}

		if (_userGradual.maturingAmount > 0) {
			_globalGradual.totalMaturingAmount -= _userGradual.maturingAmount;
			_userGradual.maturingAmount = 0;
		}

		if (_userGradual.rawUnmaturedVotingPower > 0) {
			_globalGradual.totalRawUnmaturedVotingPower -= _userGradual.rawUnmaturedVotingPower;
			_userGradual.rawUnmaturedVotingPower = 0;
		}

		if (_hasTranches(_userGradual)) {
			uint256 fromIndex = _userGradual.oldestTranchePosition.arrayIndex;
			uint256 toIndex = _userGradual.latestTranchePosition.arrayIndex;

			for (uint256 i = fromIndex; i <= toIndex; i++) {
				_deleteUserTranchesFromGlobal(userTranches[from][i]);
				delete userTranches[from][i];
			}
		}

		_userGradual.oldestTranchePosition = UserTranchePosition(0, 0);

		_userGraduals[from] = _userGradual;

		emit GradualBurned(from, amount, burnAll);

		if (!burnAll) {
			uint48 trimmedAmount = _trimRoundUp(amount);

			if (userTotalGradualAmount > trimmedAmount) {
				unchecked {
					uint48 userAmountLeft = userTotalGradualAmount - trimmedAmount;
					_mintGradual(from, userAmountLeft);
				}
			}
		}
	}

	function _deleteUserTranchesFromGlobal(UserTranches memory _userTranches) private {

		_removeUserTrancheFromGlobal(_userTranches.zero);
		_removeUserTrancheFromGlobal(_userTranches.one);
		_removeUserTrancheFromGlobal(_userTranches.two);
		_removeUserTrancheFromGlobal(_userTranches.three);
	}

	function _removeUserTrancheFromGlobal(UserTranche memory userTranche) private {

		if (userTranche.amount > 0) {
			Tranche storage tranche = _getTranche(userTranche.index);
			tranche.amount -= userTranche.amount;
		}
	}


	function updateVotingPower() external override onlyGradualMinter {

		_updateGradual();
	}

	function _updateGradual() private {

		(GlobalGradual memory global, bool didUpdate) = _getUpdatedGradual();

		if (didUpdate) {
			_globalGradual = global;
			emit GlobalGradualUpdated(
				global.lastUpdatedTrancheIndex,
				global.totalMaturedVotingPower,
				global.totalMaturingAmount,
				global.totalRawUnmaturedVotingPower
			);
		}
	}

	function _getUpdatedGradual() private view returns (GlobalGradual memory global, bool didUpdate) {

		uint256 lastFinishedTrancheIndex = getLastFinishedTrancheIndex();
		global = _globalGradual;

		while (global.lastUpdatedTrancheIndex < lastFinishedTrancheIndex) {
			global.lastUpdatedTrancheIndex++;
			_updateGradualForTrancheIndex(global);
			didUpdate = true;
		}
	}

	function _updateGradualForTrancheIndex(GlobalGradual memory global) private view {

		global.totalRawUnmaturedVotingPower += global.totalMaturingAmount;

		if (global.lastUpdatedTrancheIndex >= FULL_POWER_TRANCHES_COUNT) {
			uint256 maturedIndex = global.lastUpdatedTrancheIndex - FULL_POWER_TRANCHES_COUNT + 1;

			uint48 newMaturedVotingPower = _getTranche(maturedIndex).amount;

			if (newMaturedVotingPower > 0) {
				uint56 newMaturedAsRawUnmatured = _getMaturedAsRawUnmaturedAmount(newMaturedVotingPower);
				global.totalRawUnmaturedVotingPower -= newMaturedAsRawUnmatured;

				global.totalMaturingAmount -= newMaturedVotingPower;
				global.totalMaturedVotingPower += newMaturedVotingPower;
			}
		}
	}


	function updateUserVotingPower(address user) external override onlyGradualMinter {

		_updateGradual();
		_updateGradualUser(user);
	}

	function _updateGradualUser(address user) private {

		(UserGradual memory _userGradual, bool didUpdate) = _getUpdatedGradualUser(user);
		if (didUpdate) {
			_userGraduals[user] = _userGradual;
			emit UserGradualUpdated(
				user,
				_userGradual.lastUpdatedTrancheIndex,
				_userGradual.maturedVotingPower,
				_userGradual.maturingAmount,
				_userGradual.rawUnmaturedVotingPower
			);
		}
	}

	function _getUpdatedGradualUser(address user) private view returns (UserGradual memory, bool) {

		UserGradual memory _userGradual = _userGraduals[user];
		uint16 lastFinishedTrancheIndex = getLastFinishedTrancheIndex();

		if (_userGradual.lastUpdatedTrancheIndex == lastFinishedTrancheIndex) {
			return (_userGradual, false);
		}

		if (_hasTranches(_userGradual)) {
			uint16 lastMaturedIndex = _getLastMaturedIndex();
			if (lastMaturedIndex > 0) {
				UserTranche memory oldestTranche = _getUserTranche(user, _userGradual.oldestTranchePosition);
				while (_hasTranches(_userGradual) && oldestTranche.index <= lastMaturedIndex) {
					_matureOldestUsersTranche(_userGradual, oldestTranche);
					oldestTranche = _getUserTranche(user, _userGradual.oldestTranchePosition);
				}
			}

			if (_isMaturing(_userGradual, lastFinishedTrancheIndex)) {
				uint56 indexesPassed = lastFinishedTrancheIndex - _userGradual.lastUpdatedTrancheIndex;

				_userGradual.rawUnmaturedVotingPower += _userGradual.maturingAmount * indexesPassed;
				_userGradual.lastUpdatedTrancheIndex = lastFinishedTrancheIndex;
			}
		}

		_userGradual.lastUpdatedTrancheIndex = lastFinishedTrancheIndex;

		return (_userGradual, true);
	}

	function _matureOldestUsersTranche(UserGradual memory _userGradual, UserTranche memory oldestTranche) private pure {

		uint16 fullyMaturedFinishedIndex = _getFullyMaturedAtFinishedIndex(oldestTranche.index);

		uint48 newMaturedVotingPower = oldestTranche.amount;

		uint56 indexesPassed = fullyMaturedFinishedIndex - _userGradual.lastUpdatedTrancheIndex;
		_userGradual.rawUnmaturedVotingPower += _userGradual.maturingAmount * indexesPassed;

		uint56 newMaturedAsRawUnmatured = _getMaturedAsRawUnmaturedAmount(newMaturedVotingPower);

		_userGradual.rawUnmaturedVotingPower -= newMaturedAsRawUnmatured;
		_userGradual.maturedVotingPower += newMaturedVotingPower;
		_userGradual.maturingAmount -= newMaturedVotingPower;

		_setNextOldestUserTranchePosition(_userGradual);

		_userGradual.lastUpdatedTrancheIndex = fullyMaturedFinishedIndex;
	}

	function _getFullyMaturedAtFinishedIndex(uint256 index) private pure returns (uint16) {

		return uint16(index + FULL_POWER_TRANCHES_COUNT - 1);
	}

	function _setNextOldestUserTranchePosition(UserGradual memory _userGradual) private pure {

		if (
			_userGradual.oldestTranchePosition.arrayIndex == _userGradual.latestTranchePosition.arrayIndex &&
			_userGradual.oldestTranchePosition.position == _userGradual.latestTranchePosition.position
		) {
			_userGradual.oldestTranchePosition = UserTranchePosition(0, 0);
		} else {
			_userGradual.oldestTranchePosition = _getNextUserTranchePosition(_userGradual.oldestTranchePosition);
		}
	}


	function _getTotalGradualVotingPower(GlobalGradual memory global) private pure returns (uint256) {

		return
			_untrim(global.totalMaturedVotingPower) +
			_getMaturingVotingPowerFromRaw(_untrim(global.totalRawUnmaturedVotingPower));
	}

	function _getTranche(uint256 index) private view returns (Tranche storage) {

		uint256 arrayindex = index / TRANCHES_PER_WORD;

		GlobalTranches storage globalTranches = indexedGlobalTranches[arrayindex];

		uint256 globalTranchesPosition = index % TRANCHES_PER_WORD;

		if (globalTranchesPosition == 0) {
			return globalTranches.zero;
		} else if (globalTranchesPosition == 1) {
			return globalTranches.one;
		} else if (globalTranchesPosition == 2) {
			return globalTranches.two;
		} else if (globalTranchesPosition == 3) {
			return globalTranches.three;
		} else {
			return globalTranches.four;
		}
	}


	function _getUserTranche(address user, UserTranchePosition memory userTranchePosition)
		private
		view
		returns (UserTranche memory tranche)
	{

		UserTranches storage _userTranches = userTranches[user][userTranchePosition.arrayIndex];

		if (userTranchePosition.position == 0) {
			tranche = _userTranches.zero;
		} else if (userTranchePosition.position == 1) {
			tranche = _userTranches.one;
		} else if (userTranchePosition.position == 2) {
			tranche = _userTranches.two;
		} else {
			tranche = _userTranches.three;
		}
	}

	function _getLastMaturedIndex() private view returns (uint16 lastMaturedIndex) {

		uint256 currentTrancheIndex = getCurrentTrancheIndex();
		if (currentTrancheIndex > FULL_POWER_TRANCHES_COUNT) {
			unchecked {
				lastMaturedIndex = uint16(currentTrancheIndex - FULL_POWER_TRANCHES_COUNT);
			}
		}
	}

	function _getUserGradualVotingPower(UserGradual memory _userGradual) private pure returns (uint256) {

		return
			_untrim(_userGradual.maturedVotingPower) +
			_getMaturingVotingPowerFromRaw(_untrim(_userGradual.rawUnmaturedVotingPower));
	}

	function _getNextUserTranchePosition(UserTranchePosition memory currentTranchePosition)
		private
		pure
		returns (UserTranchePosition memory nextTranchePosition)
	{

		if (currentTranchePosition.arrayIndex == 0) {
			nextTranchePosition.arrayIndex = 1;
		} else {
			if (currentTranchePosition.position < 3) {
				nextTranchePosition.arrayIndex = currentTranchePosition.arrayIndex;
				nextTranchePosition.position = currentTranchePosition.position + 1;
			} else {
				nextTranchePosition.arrayIndex = currentTranchePosition.arrayIndex + 1;
			}
		}
	}

	function _isMaturing(UserGradual memory _userGradual, uint256 lastFinishedTrancheIndex)
		private
		pure
		returns (bool)
	{

		return _userGradual.lastUpdatedTrancheIndex < lastFinishedTrancheIndex && _hasTranches(_userGradual);
	}

	function _hasTranches(UserGradual memory _userGradual) private pure returns (bool hasTranches) {

		if (_userGradual.oldestTranchePosition.arrayIndex > 0) {
			hasTranches = true;
		}
	}


	function _trim(uint256 amount) private pure returns (uint48) {

		return uint48(amount / TRIM_SIZE);
	}

	function _trimRoundUp(uint256 amount) private pure returns (uint48 trimmedAmount) {

		trimmedAmount = _trim(amount);
		if (_untrim(trimmedAmount) < amount) {
			unchecked {
				trimmedAmount++;
			}
		}
	}

	function _untrim(uint256 trimmedAmount) private pure returns (uint256) {

		unchecked {
			return trimmedAmount * TRIM_SIZE;
		}
	}

	function _getMaturingVotingPowerFromRaw(uint256 rawMaturingVotingPower) private pure returns (uint256) {

		return rawMaturingVotingPower / FULL_POWER_TRANCHES_COUNT;
	}

	function _getMaturedAsRawUnmaturedAmount(uint48 amount) private pure returns (uint56) {

		unchecked {
			return uint56(amount * FULL_POWER_TRANCHES_COUNT);
		}
	}


	function setMinter(address _minter, bool _set) external onlyOwner {

		require(_minter != address(0), "voSPOOL::setMinter: minter cannot be the zero address");
		minters[_minter] = _set;
		emit MinterSet(_minter, _set);
	}

	function setGradualMinter(address _gradualMinter, bool _set) external onlyOwner {

		require(_gradualMinter != address(0), "voSPOOL::setGradualMinter: gradual minter cannot be the zero address");
		gradualMinters[_gradualMinter] = _set;
		emit GradualMinterSet(_gradualMinter, _set);
	}


	function _onlyMinter() private view {

		require(minters[msg.sender], "voSPOOL::_onlyMinter: Insufficient Privileges");
	}

	function _onlyGradualMinter() private view {

		require(gradualMinters[msg.sender], "voSPOOL::_onlyGradualMinter: Insufficient Privileges");
	}


	modifier onlyMinter() {

		_onlyMinter();
		_;
	}

	modifier onlyGradualMinter() {

		_onlyGradualMinter();
		_;
	}

	modifier updateGradual() {

		_updateGradual();
		_;
	}

	modifier updateGradualUser(address user) {

		_updateGradualUser(user);
		_;
	}
}