
pragma solidity ^0.8.0;

library AddressUpgradeable {

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

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal onlyInitializing {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

interface IBeaconUpgradeable {

    function implementation() external view returns (address);

}// MIT

pragma solidity ^0.8.0;

library StorageSlotUpgradeable {

    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {

        assembly {
            r.slot := slot
        }
    }
}// MIT

pragma solidity ^0.8.2;


abstract contract ERC1967UpgradeUpgradeable is Initializable {
    function __ERC1967Upgrade_init() internal onlyInitializing {
        __ERC1967Upgrade_init_unchained();
    }

    function __ERC1967Upgrade_init_unchained() internal onlyInitializing {
    }
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    event Upgraded(address indexed implementation);

    function _getImplementation() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    function _setImplementation(address newImplementation) private {
        require(AddressUpgradeable.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }
    }

    function _upgradeToAndCallSecure(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        address oldImplementation = _getImplementation();

        _setImplementation(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }

        StorageSlotUpgradeable.BooleanSlot storage rollbackTesting = StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT);
        if (!rollbackTesting.value) {
            rollbackTesting.value = true;
            _functionDelegateCall(
                newImplementation,
                abi.encodeWithSignature("upgradeTo(address)", oldImplementation)
            );
            rollbackTesting.value = false;
            require(oldImplementation == _getImplementation(), "ERC1967Upgrade: upgrade breaks further upgrades");
            _upgradeTo(newImplementation);
        }
    }

    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    event AdminChanged(address previousAdmin, address newAdmin);

    function _getAdmin() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }

    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    event BeaconUpgraded(address indexed beacon);

    function _getBeacon() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value;
    }

    function _setBeacon(address newBeacon) private {
        require(AddressUpgradeable.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            AddressUpgradeable.isContract(IBeaconUpgradeable(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(IBeaconUpgradeable(newBeacon).implementation(), data);
        }
    }

    function _functionDelegateCall(address target, bytes memory data) private returns (bytes memory) {
        require(AddressUpgradeable.isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return AddressUpgradeable.verifyCallResult(success, returndata, "Address: low-level delegate call failed");
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract UUPSUpgradeable is Initializable, ERC1967UpgradeUpgradeable {
    function __UUPSUpgradeable_init() internal onlyInitializing {
        __ERC1967Upgrade_init_unchained();
        __UUPSUpgradeable_init_unchained();
    }

    function __UUPSUpgradeable_init_unchained() internal onlyInitializing {
    }
    address private immutable __self = address(this);

    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallSecure(newImplementation, new bytes(0), false);
    }

    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallSecure(newImplementation, data, true);
    }

    function _authorizeUpgrade(address newImplementation) internal virtual;
    uint256[50] private __gap;
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

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b + (a % b == 0 ? 0 : 1);
    }
}// contracts/TokenVesting.sol
pragma solidity 0.8.11;



contract TokenVesting is UUPSUpgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable {

	using SafeERC20 for IERC20;
	struct VestingSchedule {
		bool initialized;
		bool revocable;
		bool revoked;
		address beneficiary;
		uint32 cliff;
		uint32 start;
		uint32 duration;
		uint32 slicePeriodSeconds;
		uint128 amountTotal;
		uint128 immediatelyReleasableAmount;
		uint128 released;
	}

	address internal _token;
	address internal _treasury;

	bytes32[] internal vestingSchedulesIds;
	mapping(bytes32 => VestingSchedule) internal vestingSchedules;
	uint256 internal vestingSchedulesTotalAmount;
	mapping(address => uint256) internal holdersVestingCount;

	event VestingScheduleCreated(address indexed _by, address indexed _beneficiary, bytes32 indexed _vestingScheduleId, VestingSchedule _schedule);
	event Released(address indexed _by, address indexed _to, bytes32 indexed _vestingScheduleId, uint256 _amount);
	event Revoked(address indexed _by, address indexed _beneficiary, bytes32 indexed _vestingScheduleId);
	event TreasuryUpdated(address indexed _by, address indexed _oldVal, address indexed _newVal);

	modifier onlyIfVestingScheduleExists(bytes32 vestingScheduleId) {

		require(vestingSchedules[vestingScheduleId].initialized == true);
		_;
	}

	modifier onlyIfVestingScheduleNotRevoked(bytes32 vestingScheduleId) {

		require(vestingSchedules[vestingScheduleId].initialized == true);
		require(vestingSchedules[vestingScheduleId].revoked == false);
		_;
	}

	function postConstruct(address token_, address treasury_) public virtual initializer {

		require(token_ != address(0x0));
		_token = token_;
		_treasury = treasury_;

		__Ownable_init();
		__ReentrancyGuard_init();
	}



	function getVestingSchedulesCountByBeneficiary(address _beneficiary) public view virtual returns (uint256) {

		return holdersVestingCount[_beneficiary];
	}

	function getVestingIdAtIndex(uint256 index) public view virtual returns (bytes32) {

		require(index < getVestingSchedulesCount(), "TokenVesting: index out of bounds");
		return vestingSchedulesIds[index];
	}

	function getVestingScheduleByAddressAndIndex(
		address holder,
		uint256 index
	) public view virtual returns (VestingSchedule memory) {

		return getVestingSchedule(computeVestingScheduleIdForAddressAndIndex(holder, index));
	}


	function getVestingSchedulesTotalAmount() external view virtual returns (uint256) {

		return vestingSchedulesTotalAmount;
	}

	function getToken() public view virtual returns (address) {

		return address(_token);
	}

	function getTreasury() public view virtual returns (address) {

		return _treasury;
	}

	function setTreasury(address treasury_) public virtual onlyOwner {

		emit TreasuryUpdated(msg.sender, _treasury, treasury_);
		_treasury = treasury_;
	}

	function createVestingSchedule(
		address _beneficiary,
		uint32 _start,
		uint32 _cliff,
		uint32 _duration,
		uint32 _slicePeriodSeconds,
		bool _revocable,
		uint128 _amount,
		uint128 _immediatelyReleasableAmount
	) public virtual onlyOwner {

		require(_duration > 0, "TokenVesting: duration must be > 0");
		require(_amount > 0, "TokenVesting: amount must be > 0");
		require(_immediatelyReleasableAmount <= _amount, "TokenVesting: immediatelyReleasableAmount must be <= amount");
		require(_slicePeriodSeconds >= 1, "TokenVesting: slicePeriodSeconds must be >= 1");
		bytes32 vestingScheduleId = this.computeNextVestingScheduleIdForHolder(_beneficiary);
		uint32 cliff = _start + _cliff;
		vestingSchedules[vestingScheduleId] = VestingSchedule(
			true,
			_revocable,
			false,
			_beneficiary,
			cliff,
			_start,
			_duration,
			_slicePeriodSeconds,
			_amount,
			_immediatelyReleasableAmount,
			0
		);
		vestingSchedulesTotalAmount = vestingSchedulesTotalAmount + _amount;
		vestingSchedulesIds.push(vestingScheduleId);
		uint256 currentVestingCount = holdersVestingCount[_beneficiary];
		holdersVestingCount[_beneficiary] = currentVestingCount + 1;

		emit VestingScheduleCreated(msg.sender, _beneficiary, vestingScheduleId, vestingSchedules[vestingScheduleId]);
	}

	function revoke(
		bytes32 vestingScheduleId
	) public virtual onlyOwner onlyIfVestingScheduleNotRevoked(vestingScheduleId) {

		VestingSchedule storage vestingSchedule = vestingSchedules[vestingScheduleId];
		require(vestingSchedule.revocable == true, "TokenVesting: vesting is not revocable");
		uint128 vestedAmount = _computeReleasableAmount(vestingSchedule);
		if (vestedAmount > 0) {
			release(vestingScheduleId, vestedAmount);
		}
		uint256 unreleased = vestingSchedule.amountTotal - vestingSchedule.released;
		vestingSchedulesTotalAmount = vestingSchedulesTotalAmount - unreleased;
		vestingSchedule.revoked = true;

		emit Revoked(msg.sender, vestingSchedule.beneficiary, vestingScheduleId);
	}

	function release(
		bytes32 vestingScheduleId,
		uint128 amount
	) public virtual nonReentrant onlyIfVestingScheduleNotRevoked(vestingScheduleId) {

		VestingSchedule storage vestingSchedule = vestingSchedules[vestingScheduleId];
		bool isBeneficiary = msg.sender == vestingSchedule.beneficiary;
		bool isOwner = msg.sender == owner();
		require(
			isBeneficiary || isOwner,
			"TokenVesting: only beneficiary and owner can release vested tokens"
		);
		uint256 vestedAmount = _computeReleasableAmount(vestingSchedule);
		require(vestedAmount >= amount, "TokenVesting: cannot release tokens, not enough vested tokens");
		vestingSchedule.released = vestingSchedule.released + amount;
		address payable beneficiaryPayable = payable(vestingSchedule.beneficiary);
		vestingSchedulesTotalAmount = vestingSchedulesTotalAmount - amount;
		IERC20(_token).safeTransferFrom(_treasury, beneficiaryPayable, amount);

		emit Released(msg.sender, beneficiaryPayable, vestingScheduleId, amount);
	}

	function getVestingSchedulesCount() public view virtual returns (uint256) {

		return vestingSchedulesIds.length;
	}

	function computeReleasableAmount(
		bytes32 vestingScheduleId
	) public view virtual onlyIfVestingScheduleExists(vestingScheduleId) returns (uint256) {

		VestingSchedule storage vestingSchedule = vestingSchedules[vestingScheduleId];
		return _computeReleasableAmount(vestingSchedule);
	}

	function getVestingSchedule(bytes32 vestingScheduleId) public view virtual returns (VestingSchedule memory) {

		return vestingSchedules[vestingScheduleId];
	}

	function computeNextVestingScheduleIdForHolder(address holder) public view virtual returns (bytes32) {

		return computeVestingScheduleIdForAddressAndIndex(holder, holdersVestingCount[holder]);
	}

	function getLastVestingScheduleForHolder(address holder) public view virtual returns (VestingSchedule memory) {

		return vestingSchedules[computeVestingScheduleIdForAddressAndIndex(holder, holdersVestingCount[holder] - 1)];
	}

	function computeVestingScheduleIdForAddressAndIndex(
		address holder, uint256 index
	) public pure virtual returns (bytes32) {

		return keccak256(abi.encodePacked(holder, index));
	}

	function _computeReleasableAmount(VestingSchedule memory vestingSchedule) internal view virtual returns (uint128) {

		uint256 currentTime = getCurrentTime();
		if (currentTime < vestingSchedule.start || vestingSchedule.revoked == true) {
			return 0;
		} else if (currentTime < vestingSchedule.cliff) {
			return vestingSchedule.immediatelyReleasableAmount - vestingSchedule.released;
		} else if (currentTime >= vestingSchedule.start + vestingSchedule.duration) {
			return vestingSchedule.amountTotal - vestingSchedule.released;
		} else {
			uint256 timeFromStart = currentTime - vestingSchedule.start;
			uint256 secondsPerSlice = vestingSchedule.slicePeriodSeconds;
			uint256 vestedSlicePeriods = timeFromStart / secondsPerSlice;
			uint256 vestedSeconds = vestedSlicePeriods * secondsPerSlice;
			uint256 vestedAmount = (vestingSchedule.amountTotal - vestingSchedule.immediatelyReleasableAmount)
				* vestedSeconds / vestingSchedule.duration
				+ vestingSchedule.immediatelyReleasableAmount
				- vestingSchedule.released;
			return uint128(vestedAmount);
		}
	}

	function getCurrentTime() internal virtual view returns (uint256) {

		return block.timestamp;
	}

	function _authorizeUpgrade(address) internal virtual override onlyOwner {}

}