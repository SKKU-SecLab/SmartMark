




pragma solidity ^0.8.0;

interface IAccessControlUpgradeable {

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

}





pragma solidity ^0.8.0;

abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}





pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}





pragma solidity ^0.8.0;

library StringsUpgradeable {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}





pragma solidity ^0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}





pragma solidity ^0.8.0;


abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal initializer {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal initializer {
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
    uint256[50] private __gap;
}





pragma solidity ^0.8.0;





abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {
    }
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        StringsUpgradeable.toHexString(uint160(account), 20),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
    uint256[49] private __gap;
}





pragma solidity ^0.8.0;

interface IBeaconUpgradeable {

    function implementation() external view returns (address);

}





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
}





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
}





pragma solidity ^0.8.2;




abstract contract ERC1967UpgradeUpgradeable is Initializable {
    function __ERC1967Upgrade_init() internal initializer {
        __ERC1967Upgrade_init_unchained();
    }

    function __ERC1967Upgrade_init_unchained() internal initializer {
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
}





pragma solidity ^0.8.0;


abstract contract UUPSUpgradeable is Initializable, ERC1967UpgradeUpgradeable {
    function __UUPSUpgradeable_init() internal initializer {
        __ERC1967Upgrade_init_unchained();
        __UUPSUpgradeable_init_unchained();
    }

    function __UUPSUpgradeable_init_unchained() internal initializer {
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
}





pragma solidity >=0.8.0;

interface Avatar {

	function nativeToken() external view returns (address);


	function nativeReputation() external view returns (address);


	function owner() external view returns (address);

}

interface Controller {

	event RegisterScheme(address indexed _sender, address indexed _scheme);
	event UnregisterScheme(address indexed _sender, address indexed _scheme);

	function genericCall(
		address _contract,
		bytes calldata _data,
		address _avatar,
		uint256 _value
	) external returns (bool, bytes memory);


	function avatar() external view returns (address);


	function unregisterScheme(address _scheme, address _avatar)
		external
		returns (bool);


	function unregisterSelf(address _avatar) external returns (bool);


	function registerScheme(
		address _scheme,
		bytes32 _paramsHash,
		bytes4 _permissions,
		address _avatar
	) external returns (bool);


	function isSchemeRegistered(address _scheme, address _avatar)
		external
		view
		returns (bool);


	function getSchemePermissions(address _scheme, address _avatar)
		external
		view
		returns (bytes4);


	function addGlobalConstraint(
		address _constraint,
		bytes32 _paramHash,
		address _avatar
	) external returns (bool);


	function mintTokens(
		uint256 _amount,
		address _beneficiary,
		address _avatar
	) external returns (bool);


	function externalTokenTransfer(
		address _token,
		address _recipient,
		uint256 _amount,
		address _avatar
	) external returns (bool);


	function sendEther(
		uint256 _amountInWei,
		address payable _to,
		address _avatar
	) external returns (bool);

}

interface GlobalConstraintInterface {

	enum CallPhase {
		Pre,
		Post,
		PreAndPost
	}

	function pre(
		address _scheme,
		bytes32 _params,
		bytes32 _method
	) external returns (bool);


	function when() external returns (CallPhase);

}

interface ReputationInterface {

	function balanceOf(address _user) external view returns (uint256);


	function balanceOfAt(address _user, uint256 _blockNumber)
		external
		view
		returns (uint256);


	function getVotes(address _user) external view returns (uint256);


	function getVotesAt(
		address _user,
		bool _global,
		uint256 _blockNumber
	) external view returns (uint256);


	function totalSupply() external view returns (uint256);


	function totalSupplyAt(uint256 _blockNumber)
		external
		view
		returns (uint256);


	function delegateOf(address _user) external returns (address);

}

interface SchemeRegistrar {

	function proposeScheme(
		Avatar _avatar,
		address _scheme,
		bytes32 _parametersHash,
		bytes4 _permissions,
		string memory _descriptionHash
	) external returns (bytes32);


	event NewSchemeProposal(
		address indexed _avatar,
		bytes32 indexed _proposalId,
		address indexed _intVoteInterface,
		address _scheme,
		bytes32 _parametersHash,
		bytes4 _permissions,
		string _descriptionHash
	);
}

interface IntVoteInterface {

	event NewProposal(
		bytes32 indexed _proposalId,
		address indexed _organization,
		uint256 _numOfChoices,
		address _proposer,
		bytes32 _paramsHash
	);

	event ExecuteProposal(
		bytes32 indexed _proposalId,
		address indexed _organization,
		uint256 _decision,
		uint256 _totalReputation
	);

	event VoteProposal(
		bytes32 indexed _proposalId,
		address indexed _organization,
		address indexed _voter,
		uint256 _vote,
		uint256 _reputation
	);

	event CancelProposal(
		bytes32 indexed _proposalId,
		address indexed _organization
	);
	event CancelVoting(
		bytes32 indexed _proposalId,
		address indexed _organization,
		address indexed _voter
	);

	function propose(
		uint256 _numOfChoices,
		bytes32 _proposalParameters,
		address _proposer,
		address _organization
	) external returns (bytes32);


	function vote(
		bytes32 _proposalId,
		uint256 _vote,
		uint256 _rep,
		address _voter
	) external returns (bool);


	function cancelVote(bytes32 _proposalId) external;


	function getNumberOfChoices(bytes32 _proposalId)
		external
		view
		returns (uint256);


	function isVotable(bytes32 _proposalId) external view returns (bool);


	function voteStatus(bytes32 _proposalId, uint256 _choice)
		external
		view
		returns (uint256);


	function isAbstainAllow() external pure returns (bool);


	function getAllowedRangeOfChoices()
		external
		pure
		returns (uint256 min, uint256 max);

}




pragma solidity >=0.8.0;

library DataTypes {

	struct ReserveData {
		ReserveConfigurationMap configuration;
		uint128 liquidityIndex;
		uint128 variableBorrowIndex;
		uint128 currentLiquidityRate;
		uint128 currentVariableBorrowRate;
		uint128 currentStableBorrowRate;
		uint40 lastUpdateTimestamp;
		address aTokenAddress;
		address stableDebtTokenAddress;
		address variableDebtTokenAddress;
		address interestRateStrategyAddress;
		uint8 id;
	}

	struct ReserveConfigurationMap {
		uint256 data;
	}
	enum InterestRateMode { NONE, STABLE, VARIABLE }
}





pragma solidity >=0.8.0;

pragma experimental ABIEncoderV2;

interface ERC20 {

	function balanceOf(address addr) external view returns (uint256);


	function transfer(address to, uint256 amount) external returns (bool);


	function approve(address spender, uint256 amount) external returns (bool);


	function decimals() external view returns (uint8);


	function mint(address to, uint256 mintAmount) external returns (uint256);


	function totalSupply() external view returns (uint256);


	function allowance(address owner, address spender)
		external
		view
		returns (uint256);


	function transferFrom(
		address sender,
		address recipient,
		uint256 amount
	) external returns (bool);


	function name() external view returns (string memory);


	function symbol() external view returns (string memory);


	event Transfer(address indexed from, address indexed to, uint256 amount);
	event Transfer(
		address indexed from,
		address indexed to,
		uint256 amount,
		bytes data
	);
}

interface cERC20 is ERC20 {

	function mint(uint256 mintAmount) external returns (uint256);


	function redeemUnderlying(uint256 mintAmount) external returns (uint256);


	function redeem(uint256 mintAmount) external returns (uint256);


	function exchangeRateCurrent() external returns (uint256);


	function exchangeRateStored() external view returns (uint256);


	function underlying() external returns (address);

}

interface IGoodDollar is ERC20 {

	function getFees(uint256 value) external view returns (uint256, bool);


	function burn(uint256 amount) external;


	function burnFrom(address account, uint256 amount) external;


	function renounceMinter() external;


	function addMinter(address minter) external;


	function isMinter(address minter) external view returns (bool);


	function transferAndCall(
		address to,
		uint256 value,
		bytes calldata data
	) external returns (bool);


	function formula() external view returns (address);

}

interface IERC2917 is ERC20 {

	event InterestRatePerBlockChanged(uint256 oldValue, uint256 newValue);

	event ProductivityIncreased(address indexed user, uint256 value);

	event ProductivityDecreased(address indexed user, uint256 value);

	function interestsPerBlock() external view returns (uint256);


	function changeInterestRatePerBlock(uint256 value) external returns (bool);


	function getProductivity(address user)
		external
		view
		returns (uint256, uint256);


	function increaseProductivity(address user, uint256 value)
		external
		returns (bool);


	function decreaseProductivity(address user, uint256 value)
		external
		returns (bool);


	function take() external view returns (uint256);


	function takeWithBlock() external view returns (uint256, uint256);


	function mint() external returns (uint256);

}

interface Staking {

	struct Staker {
		uint256 stakedDAI;
		uint256 lastStake;
	}

	function stakeDAI(uint256 amount) external;


	function withdrawStake() external;


	function stakers(address staker) external view returns (Staker memory);

}

interface Uniswap {

	function swapExactETHForTokens(
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external payable returns (uint256[] memory amounts);


	function swapExactTokensForETH(
		uint256 amountIn,
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external returns (uint256[] memory amounts);


	function swapExactTokensForTokens(
		uint256 amountIn,
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external returns (uint256[] memory amounts);


	function WETH() external pure returns (address);


	function factory() external pure returns (address);


	function quote(
		uint256 amountA,
		uint256 reserveA,
		uint256 reserveB
	) external pure returns (uint256 amountB);


	function getAmountIn(
		uint256 amountOut,
		uint256 reserveIn,
		uint256 reserveOut
	) external pure returns (uint256 amountIn);


	function getAmountOut(
		uint256 amountI,
		uint256 reserveIn,
		uint256 reserveOut
	) external pure returns (uint256 amountOut);


	function getAmountsOut(uint256 amountIn, address[] memory path)
		external
		pure
		returns (uint256[] memory amounts);

}

interface UniswapFactory {

	function getPair(address tokenA, address tokenB)
		external
		view
		returns (address);

}

interface UniswapPair {

	function getReserves()
		external
		view
		returns (
			uint112 reserve0,
			uint112 reserve1,
			uint32 blockTimestampLast
		);


	function kLast() external view returns (uint256);


	function token0() external view returns (address);


	function token1() external view returns (address);


	function totalSupply() external view returns (uint256);


	function balanceOf(address owner) external view returns (uint256);

}

interface Reserve {

	function buy(
		address _buyWith,
		uint256 _tokenAmount,
		uint256 _minReturn
	) external returns (uint256);

}

interface IIdentity {

	function isWhitelisted(address user) external view returns (bool);


	function addWhitelistedWithDID(address account, string memory did) external;


	function removeWhitelisted(address account) external;


	function addIdentityAdmin(address account) external returns (bool);


	function setAvatar(address _avatar) external;


	function isIdentityAdmin(address account) external view returns (bool);


	function owner() external view returns (address);


	event WhitelistedAdded(address user);
}

interface IUBIScheme {

	function currentDay() external view returns (uint256);


	function periodStart() external view returns (uint256);


	function hasClaimed(address claimer) external view returns (bool);

}

interface IFirstClaimPool {

	function awardUser(address user) external returns (uint256);


	function claimAmount() external view returns (uint256);

}

interface ProxyAdmin {

	function getProxyImplementation(address proxy)
		external
		view
		returns (address);


	function getProxyAdmin(address proxy) external view returns (address);


	function upgrade(address proxy, address implementation) external;


	function owner() external view returns (address);


	function transferOwnership(address newOwner) external;

}

interface AggregatorV3Interface {

	function decimals() external view returns (uint8);


	function description() external view returns (string memory);


	function version() external view returns (uint256);


	function getRoundData(uint80 _roundId)
		external
		view
		returns (
			uint80 roundId,
			int256 answer,
			uint256 startedAt,
			uint256 updatedAt,
			uint80 answeredInRound
		);


	function latestAnswer() external view returns (int256);

}

interface ILendingPool {

	function deposit(
		address asset,
		uint256 amount,
		address onBehalfOf,
		uint16 referralCode
	) external;


	function withdraw(
		address asset,
		uint256 amount,
		address to
	) external returns (uint256);


	function getReserveData(address asset)
		external
		view
		returns (DataTypes.ReserveData memory);

}

interface IDonationStaking {

	function stakeDonations() external payable;

}

interface INameService {

	function getAddress(string memory _name) external view returns (address);

}

interface IAaveIncentivesController {

	function claimRewards(
		address[] calldata assets,
		uint256 amount,
		address to
	) external returns (uint256);


	function getRewardsBalance(address[] calldata assets, address user)
		external
		view
		returns (uint256);

}

interface IGoodStaking {

	function collectUBIInterest(address recipient)
		external
		returns (
			uint256,
			uint256,
			uint256
		);


	function iToken() external view returns (address);


	function currentGains(
		bool _returnTokenBalanceInUSD,
		bool _returnTokenGainsInUSD
	)
		external
		view
		returns (
			uint256,
			uint256,
			uint256,
			uint256,
			uint256
		);


	function getRewardEarned(address user) external view returns (uint256);


	function getGasCostForInterestTransfer() external view returns (uint256);


	function rewardsMinted(
		address user,
		uint256 rewardsPerBlock,
		uint256 blockStart,
		uint256 blockEnd
	) external returns (uint256);

}

interface IHasRouter {

	function getRouter() external view returns (Uniswap);

}

interface IAdminWallet {

	function addAdmins(address payable[] memory _admins) external;


	function removeAdmins(address[] memory _admins) external;


	function owner() external view returns (address);


	function transferOwnership(address _owner) external;

}





pragma solidity >=0.8.0;



contract DAOContract {

	Controller public dao;

	address public avatar;

	INameService public nameService;

	function _onlyAvatar() internal view {

		require(
			address(dao.avatar()) == msg.sender,
			"only avatar can call this method"
		);
	}

	function setDAO(INameService _ns) internal {

		nameService = _ns;
		updateAvatar();
	}

	function updateAvatar() public {

		dao = Controller(nameService.getAddress("CONTROLLER"));
		avatar = dao.avatar();
	}

	function nativeToken() public view returns (IGoodDollar) {

		return IGoodDollar(nameService.getAddress("GOODDOLLAR"));
	}

	uint256[50] private gap;
}





pragma solidity >=0.8.0;



contract DAOUpgradeableContract is Initializable, UUPSUpgradeable, DAOContract {

	function _authorizeUpgrade(address) internal virtual override {

		_onlyAvatar();
	}
}




pragma solidity >=0.8.0;

contract Reputation is DAOUpgradeableContract, AccessControlUpgradeable {

	bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

	string public name;
	string public symbol;

	uint8 public decimals; //Number of decimals of the smallest unit
	event Mint(address indexed _to, uint256 _amount);
	event Burn(address indexed _from, uint256 _amount);
	uint256 private constant ZERO_HALF_256 = 0xffffffffffffffffffffffffffffffff;


	mapping(address => uint256[]) public balances;

	uint256[] public totalSupplyHistory;

	function initialize(INameService _ns) public initializer {

		__Reputation_init(_ns);
	}

	function __Reputation_init(INameService _ns) internal {

		decimals = 18;
		name = "GoodDAO";
		symbol = "GOOD";
		__Context_init_unchained();
		__ERC165_init_unchained();
		__AccessControl_init_unchained();

		setDAO(_ns);
		_setupRole(DEFAULT_ADMIN_ROLE, address(avatar));
		_setupRole(MINTER_ROLE, address(avatar));
	}

	function _canMint() internal view virtual {

		require(hasRole(MINTER_ROLE, _msgSender()), "Reputation: need minter role");
	}

	function mint(address _user, uint256 _amount) public returns (bool) {

		_canMint();
		_mint(_user, _amount);
		return true;
	}

	function _mint(address _user, uint256 _amount)
		internal
		virtual
		returns (uint256)
	{

		uint256 curTotalSupply = totalSupplyLocalAt(block.number);
		uint256 previousBalanceTo = balanceOfLocalAt(_user, block.number);

		updateValueAtNow(totalSupplyHistory, curTotalSupply + _amount);
		updateValueAtNow(balances[_user], previousBalanceTo + _amount);
		emit Mint(_user, _amount);
		return _amount;
	}

	function burn(address _user, uint256 _amount) public returns (bool) {

		if (_user != _msgSender()) _canMint();
		_burn(_user, _amount);
		return true;
	}

	function _burn(address _user, uint256 _amount)
		internal
		virtual
		returns (uint256)
	{

		uint256 curTotalSupply = totalSupplyLocalAt(block.number);
		uint256 amountBurned = _amount;
		uint256 previousBalanceFrom = balanceOfLocalAt(_user, block.number);
		if (previousBalanceFrom < amountBurned) {
			amountBurned = previousBalanceFrom;
		}
		updateValueAtNow(totalSupplyHistory, curTotalSupply - amountBurned);
		updateValueAtNow(balances[_user], previousBalanceFrom - amountBurned);
		emit Burn(_user, amountBurned);
		return amountBurned;
	}

	function balanceOfLocal(address _owner) public view returns (uint256) {

		return balanceOfLocalAt(_owner, block.number);
	}

	function balanceOfLocalAt(address _owner, uint256 _blockNumber)
		public
		view
		virtual
		returns (uint256)
	{

		if (
			(balances[_owner].length == 0) ||
			(uint128(balances[_owner][0]) > _blockNumber)
		) {
			return 0;
		} else {
			return getValueAt(balances[_owner], _blockNumber);
		}
	}

	function totalSupplyLocal() public view virtual returns (uint256) {

		return totalSupplyLocalAt(block.number);
	}

	function totalSupplyLocalAt(uint256 _blockNumber)
		public
		view
		virtual
		returns (uint256)
	{

		if (
			(totalSupplyHistory.length == 0) ||
			(uint128(totalSupplyHistory[0]) > _blockNumber)
		) {
			return 0;
		} else {
			return getValueAt(totalSupplyHistory, _blockNumber);
		}
	}

	function getValueAt(uint256[] storage checkpoints, uint256 _block)
		internal
		view
		returns (uint256)
	{

		uint256 len = checkpoints.length;
		if (len == 0) {
			return 0;
		}
		uint256 cur = checkpoints[len - 1];
		if (_block >= uint128(cur)) {
			return cur >> 128;
		}

		if (_block < uint128(checkpoints[0])) {
			return 0;
		}

		uint256 min = 0;
		uint256 max = len - 1;
		while (max > min) {
			uint256 mid = (max + min + 1) / 2;
			if (uint128(checkpoints[mid]) <= _block) {
				min = mid;
			} else {
				max = mid - 1;
			}
		}
		return checkpoints[min] >> 128;
	}

	function updateValueAtNow(uint256[] storage checkpoints, uint256 _value)
		internal
	{

		require(uint128(_value) == _value, "reputation overflow"); //check value is in the 128 bits bounderies
		if (
			(checkpoints.length == 0) ||
			(uint128(checkpoints[checkpoints.length - 1]) < block.number)
		) {
			checkpoints.push(uint256(uint128(block.number)) | (_value << 128));
		} else {
			checkpoints[checkpoints.length - 1] = uint256(
				(checkpoints[checkpoints.length - 1] & uint256(ZERO_HALF_256)) |
					(_value << 128)
			);
		}
	}
}




pragma solidity >=0.8.0;


contract GReputation is Reputation {

	bytes32 public constant ROOT_STATE = keccak256("rootState");

	bytes32 public constant DOMAIN_TYPEHASH =
		keccak256(
			"EIP712Domain(string name,uint256 chainId,address verifyingContract)"
		);

	bytes32 public constant DELEGATION_TYPEHASH =
		keccak256("Delegation(address delegate,uint256 nonce,uint256 expiry)");

	struct BlockchainState {
		bytes32 stateHash;
		uint256 hashType;
		uint256 totalSupply;
		uint256 blockNumber;
		uint256[5] __reserevedSpace;
	}

	mapping(address => uint256) public nonces;

	mapping(bytes32 => BlockchainState[]) public blockchainStates;

	mapping(bytes32 => mapping(address => uint256)) public stateHashBalances;

	bytes32[] public activeBlockchains;

	mapping(address => address) public delegates;

	mapping(address => uint256[]) public activeVotes;

	mapping(address => address) public reputationRecipients;

	event DelegateVotesChanged(
		address indexed delegate,
		address indexed delegator,
		uint256 previousBalance,
		uint256 newBalance
	);

	event StateHash(string blockchain, bytes32 merkleRoot, uint256 totalSupply);

	event StateHashProof(
		string blockchain,
		address indexed user,
		uint256 repBalance
	);

	function initialize(
		INameService _ns,
		string calldata _stateId,
		bytes32 _stateHash,
		uint256 _totalSupply
	) external initializer {

		__Reputation_init(_ns);
		if (_totalSupply > 0)
			_setBlockchainStateHash(_stateId, _stateHash, _totalSupply);
	}

	function _canMint() internal view override {

		require(
			_msgSender() == nameService.getAddress("GDAO_CLAIMERS") ||
				_msgSender() == nameService.getAddress("GDAO_STAKING") ||
				_msgSender() == nameService.getAddress("GDAO_STAKERS") ||
				hasRole(MINTER_ROLE, _msgSender()),
			"GReputation: need minter role or be GDAO contract"
		);
	}

	function _mint(address _user, uint256 _amount)
		internal
		override
		returns (uint256)
	{

		address repTarget = reputationRecipients[_user];
		repTarget = repTarget != address(0) ? repTarget : _user;

		super._mint(repTarget, _amount);

		address delegator = delegates[repTarget];
		if (delegator == address(0)) {
			delegates[repTarget] = repTarget;
			delegator = repTarget;
		}
		uint256 previousVotes = getVotesAt(delegator, false, block.number);

		_updateDelegateVotes(
			delegator,
			repTarget,
			previousVotes,
			previousVotes + _amount
		);
		return _amount;
	}

	function _burn(address _user, uint256 _amount)
		internal
		override
		returns (uint256)
	{

		uint256 amountBurned = super._burn(_user, _amount);
		address delegator = delegates[_user];
		delegator = delegator != address(0) ? delegator : _user;
		delegates[_user] = delegator;

		uint256 previousVotes = getVotesAt(delegator, false, block.number);

		_updateDelegateVotes(
			delegator,
			_user,
			previousVotes,
			previousVotes - amountBurned
		);

		return amountBurned;
	}

	function setBlockchainStateHash(
		string memory _id,
		bytes32 _hash,
		uint256 _totalSupply
	) public {

		_onlyAvatar();
		_setBlockchainStateHash(_id, _hash, _totalSupply);
	}

	function _setBlockchainStateHash(
		string memory _id,
		bytes32 _hash,
		uint256 _totalSupply
	) internal {

		bytes32 idHash = keccak256(bytes(_id));

		bool isRootState = idHash == ROOT_STATE;
		require(
			!isRootState || totalSupplyLocalAt(block.number) == 0,
			"rootState already created"
		);
		if (isRootState) {
			updateValueAtNow(totalSupplyHistory, _totalSupply);
		}
		uint256 i = 0;
		for (; !isRootState && i < activeBlockchains.length; i++) {
			if (activeBlockchains[i] == idHash) break;
		}

		if (!isRootState && i == activeBlockchains.length) {
			activeBlockchains.push(idHash);
		}

		BlockchainState memory state;
		state.stateHash = _hash;
		state.totalSupply = _totalSupply;
		state.blockNumber = block.number;
		blockchainStates[idHash].push(state);

		emit StateHash(_id, _hash, _totalSupply);
	}

	function getVotesAt(
		address _user,
		bool _global,
		uint256 _blockNumber
	) public view returns (uint256) {

		uint256 startingBalance = getValueAt(activeVotes[_user], _blockNumber);

		if (_global) {
			for (uint256 i = 0; i < activeBlockchains.length; i++) {
				startingBalance += getVotesAtBlockchain(
					activeBlockchains[i],
					_user,
					_blockNumber
				);
			}
		}

		return startingBalance;
	}

	function getVotes(address _user) public view returns (uint256) {

		return getVotesAt(_user, true, block.number);
	}

	function balanceOf(address _user) public view returns (uint256 balance) {

		return getVotesAt(_user, block.number);
	}

	function getCurrentVotes(address _user) public view returns (uint256) {

		return getVotesAt(_user, true, block.number);
	}

	function getPriorVotes(address _user, uint256 _block)
		public
		view
		returns (uint256)
	{

		return getVotesAt(_user, true, _block);
	}

	function getVotesAt(address _user, uint256 _blockNumber)
		public
		view
		returns (uint256)
	{

		return getVotesAt(_user, true, _blockNumber);
	}

	function totalSupplyLocal(uint256 _blockNumber)
		public
		view
		returns (uint256)
	{

		return totalSupplyLocalAt(_blockNumber);
	}

	function totalSupplyAt(uint256 _blockNumber) public view returns (uint256) {

		uint256 startingSupply = totalSupplyLocalAt(_blockNumber);
		for (uint256 i = 0; i < activeBlockchains.length; i++) {
			startingSupply += totalSupplyAtBlockchain(
				activeBlockchains[i],
				_blockNumber
			);
		}
		return startingSupply;
	}

	function totalSupply() public view returns (uint256) {

		return totalSupplyAt(block.number);
	}

	function getVotesAtBlockchain(
		bytes32 _id,
		address _user,
		uint256 _blockNumber
	) public view returns (uint256) {

		BlockchainState[] storage states = blockchainStates[_id];
		int256 i = int256(states.length);

		if (i == 0) return 0;
		BlockchainState storage state = states[uint256(i - 1)];
		for (i = i - 1; i >= 0; i--) {
			if (state.blockNumber <= _blockNumber) break;
			state = states[uint256(i - 1)];
		}
		if (i < 0) return 0;

		return stateHashBalances[state.stateHash][_user];
	}

	function totalSupplyAtBlockchain(bytes32 _id, uint256 _blockNumber)
		public
		view
		returns (uint256)
	{

		BlockchainState[] storage states = blockchainStates[_id];
		int256 i;
		if (states.length == 0) return 0;
		for (i = int256(states.length - 1); i >= 0; i--) {
			if (states[uint256(i)].blockNumber <= _blockNumber) break;
		}
		if (i < 0) return 0;

		BlockchainState storage state = states[uint256(i)];
		return state.totalSupply;
	}

	function proveBalanceOfAtBlockchain(
		string memory _id,
		address _user,
		uint256 _balance,
		bytes32[] memory _proof,
		uint256 _nodeIndex
	) public returns (bool) {

		bytes32 idHash = keccak256(bytes(_id));
		require(
			blockchainStates[idHash].length > 0,
			"no state found for given _id"
		);
		bytes32 stateHash = blockchainStates[idHash][
			blockchainStates[idHash].length - 1
		].stateHash;

		require(
			stateHashBalances[stateHash][_user] == 0,
			"stateHash already proved"
		);

		bytes32 leafHash = keccak256(abi.encode(_user, _balance));
		bool isProofValid = checkProofOrdered(
			_proof,
			stateHash,
			leafHash,
			_nodeIndex
		);

		require(isProofValid, "invalid merkle proof");

		if (idHash == ROOT_STATE) {
			uint256 curTotalSupply = totalSupplyLocalAt(block.number);
			_mint(_user, _balance);
			updateValueAtNow(totalSupplyHistory, curTotalSupply); // we undo the totalsupply, as we alredy set the totalsupply of the airdrop
		}

		stateHashBalances[stateHash][_user] = _balance;

		emit StateHashProof(_id, _user, _balance);
		return true;
	}

	function delegateOf(address _user) public view returns (address) {

		return delegates[_user];
	}

	function delegateTo(address _delegate) public {

		return _delegateTo(_msgSender(), _delegate);
	}

	function undelegate() public {

		return _delegateTo(_msgSender(), _msgSender());
	}

	function delegateBySig(
		address _delegate,
		uint256 _nonce,
		uint256 _expiry,
		uint8 _v,
		bytes32 _r,
		bytes32 _s
	) public {

		bytes32 domainSeparator = keccak256(
			abi.encode(
				DOMAIN_TYPEHASH,
				keccak256(bytes(name)),
				getChainId(),
				address(this)
			)
		);
		bytes32 structHash = keccak256(
			abi.encode(DELEGATION_TYPEHASH, _delegate, _nonce, _expiry)
		);
		bytes32 digest = keccak256(
			abi.encodePacked("\x19\x01", domainSeparator, structHash)
		);
		address signatory = ecrecover(digest, _v, _r, _s);
		require(
			signatory != address(0),
			"GReputation::delegateBySig: invalid signature"
		);
		require(
			_nonce == nonces[signatory]++,
			"GReputation::delegateBySig: invalid nonce"
		);
		require(
			block.timestamp <= _expiry,
			"GReputation::delegateBySig: signature expired"
		);
		return _delegateTo(signatory, _delegate);
	}

	function _delegateTo(address _user, address _delegate) internal {

		require(
			_delegate != address(0),
			"GReputation::delegate can't delegate to null address"
		);

		address curDelegator = delegates[_user];
		require(curDelegator != _delegate, "already delegating to delegator");

		delegates[_user] = _delegate;

		uint256 coreBalance = balanceOfLocalAt(_user, block.number);
		if (curDelegator != address(0)) {
			uint256 removeVotes = getVotesAt(curDelegator, false, block.number);
			_updateDelegateVotes(
				curDelegator,
				_user,
				removeVotes,
				removeVotes - coreBalance
			);
		}

		uint256 addVotes = getVotesAt(_delegate, false, block.number);
		_updateDelegateVotes(_delegate, _user, addVotes, addVotes + coreBalance);
	}

	function _updateDelegateVotes(
		address _delegate,
		address _delegator,
		uint256 _oldVotes,
		uint256 _newVotes
	) internal {

		updateValueAtNow(activeVotes[_delegate], _newVotes);
		emit DelegateVotesChanged(_delegate, _delegator, _oldVotes, _newVotes);
	}

	function checkProofOrdered(
		bytes32[] memory _proof,
		bytes32 _root,
		bytes32 _hash,
		uint256 _index
	) public pure returns (bool) {


		bytes32 proofElement;
		bytes32 computedHash = _hash;
		uint256 remaining;

		for (uint256 j = 0; j < _proof.length; j++) {
			proofElement = _proof[j];

			remaining = _proof.length - j;

			while (remaining > 0 && _index % 2 == 1 && _index > 2**remaining) {
				_index = _index / 2 + 1;
			}

			if (_index % 2 == 0) {
				computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
				_index = _index / 2;
			} else {
				computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
				_index = _index / 2 + 1;
			}
		}

		return computedHash == _root;
	}

	function getChainId() internal view returns (uint256) {

		uint256 chainId;
		assembly {
			chainId := chainid()
		}
		return chainId;
	}

	function setReputationRecipient(address _target) public {

		reputationRecipients[msg.sender] = _target;
	}

	function restoreState(
		bytes32 _fuseStateHash,
		uint256 _totalSupply,
		address[] calldata _accounts,
		uint256[] calldata _stateValue,
		uint256[] calldata _mintValue
	) public {

		require(activeBlockchains.length == 0, "too late");
		_setBlockchainStateHash("fuse", _fuseStateHash, _totalSupply);
		for (uint256 i = 0; i < _accounts.length; i++) {
			address account = _accounts[i];
			if (_stateValue[i] > 0) {
				stateHashBalances[_fuseStateHash][account] = _stateValue[i];
				emit StateHashProof("fuse", account, _stateValue[i]);
			}
			reputationRecipients[account] = GReputation(
				address(0x3A9299BE789ac3730e4E4c49d6d2Ad1b8BC34DFf)
			).reputationRecipients(account);
			if (_mintValue[i] > 0) _mint(account, _mintValue[i]);
		}
		for (uint256 i = 0; i < _accounts.length; i++) {
			address delegatee = GReputation(
				address(0x3A9299BE789ac3730e4E4c49d6d2Ad1b8BC34DFf)
			).delegateOf(_accounts[i]);
			if (delegatee != address(0) && delegatee != _accounts[i])
				_delegateTo(_accounts[i], delegatee);
		}
	}
}