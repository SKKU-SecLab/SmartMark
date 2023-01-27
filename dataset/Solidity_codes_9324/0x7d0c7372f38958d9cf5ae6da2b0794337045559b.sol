
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
}// BUSL-1.1

pragma solidity 0.8.11;


interface IController {


    function strategies(uint256 i) external view returns (address);


    function validStrategy(address strategy) external view returns (bool);


    function validVault(address vault) external view returns (bool);


    function getStrategiesCount() external view returns(uint8);


    function supportedUnderlying(IERC20 underlying)
        external
        view
        returns (bool);


    function getAllStrategies() external view returns (address[] memory);


    function verifyStrategies(address[] calldata _strategies) external view;


    function transferToSpool(
        address transferFrom,
        uint256 amount
    ) external;


    function checkPaused() external view;



    event EmergencyWithdrawStrategy(address indexed strategy);
    event EmergencyRecipientUpdated(address indexed recipient);
    event EmergencyWithdrawerUpdated(address indexed withdrawer, bool set);
    event PauserUpdated(address indexed user, bool set);
    event UnpauserUpdated(address indexed user, bool set);
    event VaultCreated(address indexed vault, address underlying, address[] strategies, uint256[] proportions,
        uint16 vaultFee, address riskProvider, int8 riskTolerance);
    event StrategyAdded(address strategy);
    event StrategyRemoved(address strategy);
    event VaultInvalid(address vault);
    event DisableStrategy(address strategy);
}// BUSL-1.1

pragma solidity 0.8.11;

interface ISpoolOwner {

    function isSpoolOwner(address user) external view returns(bool);

}// BUSL-1.1

pragma solidity 0.8.11;


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


    function _onlyOwner() private view {
        require(isSpoolOwner(), "SpoolOwnable::onlyOwner: Caller is not the Spool owner");
    }

    modifier onlyOwner() {
        _onlyOwner();
        _;
    }
}// BUSL-1.1

pragma solidity 0.8.11;


abstract contract BaseConstants {
    uint256 internal constant FULL_PERCENT = 100_00;

    uint256 internal constant ACCURACY = 10**30;
}

abstract contract USDC {
    IERC20 internal constant USDC_ADDRESS = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
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

pragma solidity 0.8.11;

library Hash {

    function hashReallocationTable(uint256[][] memory reallocationTable) internal pure returns(bytes32) {

        return keccak256(abi.encode(reallocationTable));
    }

    function hashStrategies(address[] memory strategies) internal pure returns(bytes32) {

        return keccak256(abi.encodePacked(strategies));
    }

    function sameStrategies(address[] memory strategies1, address[] memory strategies2) internal pure returns(bool) {

        return hashStrategies(strategies1) == hashStrategies(strategies2);
    }

    function sameStrategies(address[] memory strategies, bytes32 strategiesHash) internal pure returns(bool) {

        return hashStrategies(strategies) == strategiesHash;
    }
}// BUSL-1.1

pragma solidity 0.8.11;

struct SwapData {
    uint256 slippage; // min amount out
    bytes path; // 1st byte is action, then path 
}// BUSL-1.1

pragma solidity 0.8.11;


interface ISpoolExternal {


    function deposit(address strategy, uint128 amount, uint256 index) external;


    function withdraw(address strategy, uint256 vaultProportion, uint256 index) external;


    function fastWithdrawStrat(address strat, address underlying, uint256 shares, uint256[] calldata slippages, SwapData[] calldata swapData) external returns(uint128);


    function redeem(address strat, uint256 index) external returns (uint128, uint128);


    function redeemUnderlying(uint128 amount) external;


    function redeemReallocation(address[] calldata vaultStrategies, uint256 depositProportions, uint256 index) external;


    function removeShares(address[] calldata vaultStrategies, uint256 vaultProportion) external returns(uint128[] memory);

}// BUSL-1.1

pragma solidity 0.8.11;

interface ISpoolReallocation {

    event StartReallocation(uint24 indexed index);
}// BUSL-1.1

pragma solidity 0.8.11;

interface ISpoolDoHardWork {


    event DoHardWorkStrategyCompleted(address indexed strat, uint256 indexed index);
}// BUSL-1.1

pragma solidity 0.8.11;

interface ISpoolStrategy {


    function getUnderlying(address strat) external returns (uint128);

    
    function getVaultTotalUnderlyingAtIndex(address strat, uint256 index) external view returns(uint128);


    function addStrategy(address strat) external;


    function disableStrategy(address strategy, bool skipDisable) external;


    function runDisableStrategy(address strategy) external;


    function emergencyWithdraw(
        address strat,
        address withdrawRecipient,
        uint256[] calldata data
    ) external;

}// BUSL-1.1

pragma solidity 0.8.11;

interface ISpoolBase {


    function getCompletedGlobalIndex() external view returns(uint24);


    function getActiveGlobalIndex() external view returns(uint24);


    function isMidReallocation() external view returns (bool);



    event ReallocationTableUpdated(
        uint24 indexed index,
        bytes32 reallocationTableHash
    );

    event ReallocationTableUpdatedWithTable(
        uint24 indexed index,
        bytes32 reallocationTableHash,
        uint256[][] reallocationTable
    );
    
    event DoHardWorkCompleted(uint24 indexed index);

    event SetAllocationProvider(address actor, bool isAllocationProvider);
    event SetIsDoHardWorker(address actor, bool isDoHardWorker);
}// BUSL-1.1

pragma solidity 0.8.11;


interface ISpool is ISpoolExternal, ISpoolReallocation, ISpoolDoHardWork, ISpoolStrategy, ISpoolBase {}// BUSL-1.1


pragma solidity 0.8.11;


interface IRiskProviderRegistry {


    function isProvider(address provider) external view returns (bool);


    function getRisk(address riskProvider, address strategy) external view returns (uint8);


    function getRisks(address riskProvider, address[] memory strategies) external view returns (uint8[] memory);



    event RiskAssessed(address indexed provider, address indexed strategy, uint8 riskScore);
    event ProviderAdded(address provider);
    event ProviderRemoved(address provider);
}// BUSL-1.1

pragma solidity 0.8.11;


interface IBaseStrategy {

    function underlying() external view returns (IERC20);


    function getStrategyBalance() external view returns (uint128);


    function getStrategyUnderlyingWithRewards() external view returns(uint128);


    function process(uint256[] calldata, bool, SwapData[] calldata) external;


    function processReallocation(uint256[] calldata, ProcessReallocationData calldata) external returns(uint128);


    function processDeposit(uint256[] calldata) external;


    function fastWithdraw(uint128, uint256[] calldata, SwapData[] calldata) external returns(uint128);


    function claimRewards(SwapData[] calldata) external;


    function emergencyWithdraw(address recipient, uint256[] calldata data) external;


    function initialize() external;


    function disable() external;



    event Slippage(address strategy, IERC20 underlying, bool isDeposit, uint256 amountIn, uint256 amountOut);
}

struct ProcessReallocationData {
    uint128 sharesToWithdraw;
    uint128 optimizedShares;
    uint128 optimizedWithdrawnAmount;
}// BUSL-1.1

pragma solidity 0.8.11;

interface IVaultRestricted {

    
    function reallocate(
        address[] calldata vaultStrategies,
        uint256 newVaultProportions,
        uint256 finishedIndex,
        uint24 activeIndex
    ) external returns (uint256[] memory, uint256);


    function payFees(uint256 profit) external returns (uint256 feesPaid);



    event Reallocate(uint24 indexed index, uint256 newProportions);
}// BUSL-1.1

pragma solidity 0.8.11;

interface IVaultIndexActions {



    struct IndexAction {
        uint128 depositAmount;
        uint128 withdrawShares;
    }

    struct LastIndexInteracted {
        uint128 index1;
        uint128 index2;
    }

    struct Redeem {
        uint128 depositShares;
        uint128 withdrawnAmount;
    }


    event VaultRedeem(uint indexed globalIndex);
    event UserRedeem(address indexed member, uint indexed globalIndex);
}// BUSL-1.1

pragma solidity 0.8.11;


interface IRewardDrip {


    struct RewardConfiguration {
        uint32 rewardsDuration;
        uint32 periodFinish;
        uint192 rewardRate; // rewards per second multiplied by accuracy
        uint32 lastUpdateTime;
        uint224 rewardPerTokenStored;
        mapping(address => uint256) userRewardPerTokenPaid;
        mapping(address => uint256) rewards;
    }


    function getActiveRewards(address account) external;

    function tokenBlacklist(IERC20 token) view external returns(bool);


    
    event RewardPaid(IERC20 token, address indexed user, uint256 reward);
    event RewardAdded(IERC20 indexed token, uint256 amount, uint256 duration);
    event RewardExtended(IERC20 indexed token, uint256 amount, uint256 leftover, uint256 duration, uint32 periodFinish);
    event RewardRemoved(IERC20 indexed token);
    event PeriodFinishUpdated(IERC20 indexed token, uint32 periodFinish);
}// BUSL-1.1

pragma solidity 0.8.11;

struct VaultDetails {
    address underlying;
    address[] strategies;
    uint256[] proportions;
    address creator;
    uint16 vaultFee;
    address riskProvider;
    int8 riskTolerance;
    string name;
}

struct VaultInitializable {
    string name;
    address owner;
    uint16 fee;
    address[] strategies;
    uint256[] proportions;
}// BUSL-1.1

pragma solidity 0.8.11;


interface IVaultBase {


    function initialize(VaultInitializable calldata vaultInitializable) external;



    struct User {
        uint128 instantDeposit; // used for calculating rewards
        uint128 activeDeposit; // users deposit after deposit process and claim
        uint128 owed; // users owed underlying amount after withdraw has been processed and claimed
        uint128 withdrawnDeposits; // users withdrawn deposit, used to calculate performance fees
        uint128 shares; // users shares after deposit process and claim
    }


    event Claimed(address indexed member, uint256 claimAmount);
    event Deposit(address indexed member, uint256 indexed index, uint256 amount);
    event Withdraw(address indexed member, uint256 indexed index, uint256 shares);
    event WithdrawFast(address indexed member, uint256 shares);
    event StrategyRemoved(uint256 i, address strategy);
    event TransferVaultOwner(address owner);
    event LowerVaultFee(uint16 fee);
    event UpdateName(string name);
}// BUSL-1.1

pragma solidity 0.8.11;


struct VaultImmutables {
    IERC20 underlying;
    address riskProvider;
    int8 riskTolerance;
}

interface IVaultImmutable {


    function underlying() external view returns (IERC20);


    function riskProvider() external view returns (address);


    function riskTolerance() external view returns (int8);

}// BUSL-1.1

pragma solidity 0.8.11;


interface IVault is IVaultRestricted, IVaultIndexActions, IRewardDrip, IVaultBase, IVaultImmutable {}// MIT


pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {

        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {

        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}// BUSL-1.1

pragma solidity 0.8.11;

interface IStrategyRegistry {



    function upgradeToAndCall(address strategy, bytes calldata data) external;

    function changeAdmin(address newAdmin) external;

    function addStrategy(address strategy) external;

    function getImplementation(address strategy) view external returns (address);



    event AdminChanged(address previousAdmin, address newAdmin);

    event StrategyUpgraded(address strategy, address newImplementation);

    event StrategyRegistered(address strategy);
}// MIT

pragma solidity ^0.8.0;

abstract contract Proxy {
    function _delegate(address implementation) internal virtual {
        assembly {
            calldatacopy(0, 0, calldatasize())

            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    function _implementation() internal view virtual returns (address);

    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    fallback() external payable virtual {
        _fallback();
    }

    receive() external payable virtual {
        _fallback();
    }

    function _beforeFallback() internal virtual {}
}// MIT

pragma solidity ^0.8.0;

interface IBeacon {

    function implementation() external view returns (address);

}// MIT

pragma solidity ^0.8.0;

library StorageSlot {

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


abstract contract ERC1967Upgrade {
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    event Upgraded(address indexed implementation);

    function _getImplementation() internal view returns (address) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    function _setImplementation(address newImplementation) private {
        require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
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
            Address.functionDelegateCall(newImplementation, data);
        }
    }

    function _upgradeToAndCallUUPS(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        if (StorageSlot.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822Proxiable(newImplementation).proxiableUUID() returns (bytes32 slot) {
                require(slot == _IMPLEMENTATION_SLOT, "ERC1967Upgrade: unsupported proxiableUUID");
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
        }
    }

    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    event AdminChanged(address previousAdmin, address newAdmin);

    function _getAdmin() internal view returns (address) {
        return StorageSlot.getAddressSlot(_ADMIN_SLOT).value;
    }

    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlot.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    event BeaconUpgraded(address indexed beacon);

    function _getBeacon() internal view returns (address) {
        return StorageSlot.getAddressSlot(_BEACON_SLOT).value;
    }

    function _setBeacon(address newBeacon) private {
        require(Address.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            Address.isContract(IBeacon(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlot.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(IBeacon(newBeacon).implementation(), data);
        }
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC1967Proxy is Proxy, ERC1967Upgrade {

    constructor(address _logic, bytes memory _data) payable {
        assert(_IMPLEMENTATION_SLOT == bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1));
        _upgradeToAndCall(_logic, _data, false);
    }

    function _implementation() internal view virtual override returns (address impl) {

        return ERC1967Upgrade._getImplementation();
    }
}// MIT

pragma solidity ^0.8.0;


contract TransparentUpgradeableProxy is ERC1967Proxy {

    constructor(
        address _logic,
        address admin_,
        bytes memory _data
    ) payable ERC1967Proxy(_logic, _data) {
        assert(_ADMIN_SLOT == bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1));
        _changeAdmin(admin_);
    }

    modifier ifAdmin() {

        if (msg.sender == _getAdmin()) {
            _;
        } else {
            _fallback();
        }
    }

    function admin() external ifAdmin returns (address admin_) {

        admin_ = _getAdmin();
    }

    function implementation() external ifAdmin returns (address implementation_) {

        implementation_ = _implementation();
    }

    function changeAdmin(address newAdmin) external virtual ifAdmin {

        _changeAdmin(newAdmin);
    }

    function upgradeTo(address newImplementation) external ifAdmin {

        _upgradeToAndCall(newImplementation, bytes(""), false);
    }

    function upgradeToAndCall(address newImplementation, bytes calldata data) external payable ifAdmin {

        _upgradeToAndCall(newImplementation, data, true);
    }

    function _admin() internal view virtual returns (address) {

        return _getAdmin();
    }

    function _beforeFallback() internal virtual override {

        require(msg.sender != _getAdmin(), "TransparentUpgradeableProxy: admin cannot fallback to proxy target");
        super._beforeFallback();
    }
}// BUSL-1.1

pragma solidity 0.8.11;


contract VaultTransparentUpgradeableProxy is TransparentUpgradeableProxy, IVaultImmutable {

    IERC20 public override immutable underlying;

    address public override immutable riskProvider;

    int8 public override immutable riskTolerance;

    constructor(
        address _logic,
        address admin_,
        VaultImmutables memory vaultImmutables
    ) TransparentUpgradeableProxy(_logic, admin_, "") payable {
        underlying = vaultImmutables.underlying;
        riskProvider = vaultImmutables.riskProvider;
        riskTolerance = vaultImmutables.riskTolerance;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
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
}// MIT

pragma solidity ^0.8.0;


contract ProxyAdmin is Ownable {

    function getProxyImplementation(TransparentUpgradeableProxy proxy) public view virtual returns (address) {

        (bool success, bytes memory returndata) = address(proxy).staticcall(hex"5c60da1b");
        require(success);
        return abi.decode(returndata, (address));
    }

    function getProxyAdmin(TransparentUpgradeableProxy proxy) public view virtual returns (address) {

        (bool success, bytes memory returndata) = address(proxy).staticcall(hex"f851a440");
        require(success);
        return abi.decode(returndata, (address));
    }

    function changeProxyAdmin(TransparentUpgradeableProxy proxy, address newAdmin) public virtual onlyOwner {

        proxy.changeAdmin(newAdmin);
    }

    function upgrade(TransparentUpgradeableProxy proxy, address implementation) public virtual onlyOwner {

        proxy.upgradeTo(implementation);
    }

    function upgradeAndCall(
        TransparentUpgradeableProxy proxy,
        address implementation,
        bytes memory data
    ) public payable virtual onlyOwner {

        proxy.upgradeToAndCall{value: msg.value}(implementation, data);
    }
}// BUSL-1.1

pragma solidity 0.8.11;




contract Controller is IController, SpoolOwnable, BaseConstants, Pausable {

    using SafeERC20 for IERC20;


    uint256 public constant MAX_VAULT_CREATOR_FEE = 20_00;

    uint256 public constant MAX_DAO_VAULT_CREATOR_FEE = 60_00;

    uint256 public constant MAX_VAULT_STRATEGIES = 18;

    int8 public constant MIN_RISK_TOLERANCE = -10;

    int8 public constant MAX_RISK_TOLERANCE = 10;


    ISpool public immutable spool;
    
    IRiskProviderRegistry public immutable riskRegistry;

    IStrategyRegistry internal immutable strategyRegistry;

    address internal immutable proxyAdmin;

    address public immutable vaultImplementation;

    address[] public override strategies;

    bytes32 public strategiesHash;

    uint256 public totalVaults;
    
    address public emergencyRecipient;

    bool private _initialized;

    mapping(IERC20 => bool) public override supportedUnderlying;

    mapping(address => bool) public override validVault;

    mapping(address => bool) public override validStrategy;

    mapping(address => bool) public isEmergencyWithdrawer;

    mapping(address => bool) public isPauser;

    mapping(address => bool) public isUnpauser;

    constructor(
        ISpoolOwner _spoolOwner,
        IRiskProviderRegistry _riskRegistry,
        ISpool _spool,
        IStrategyRegistry _strategyRegistry,
        address _vaultImplementation,
        address _proxyAdmin
    )
        SpoolOwnable(_spoolOwner)
    {
        require(
            _riskRegistry != IRiskProviderRegistry(address(0)) &&
            _spool != ISpool(address(0)) &&
            _vaultImplementation != address(0) &&
            _strategyRegistry != IStrategyRegistry(address(0)) &&
            _proxyAdmin != address(0),
            "Controller::constructor: Risk Provider, Spool, Strategy registry, Proxy admin or Vault Implementation addresses cannot be 0"
        );

        riskRegistry = _riskRegistry;
        spool = _spool;
        vaultImplementation = _vaultImplementation;
        strategyRegistry = _strategyRegistry;
        proxyAdmin = _proxyAdmin;
    }

    function initialize() onlyOwner initializer external {

        _updateStrategiesHash(strategies);
    }


    function checkPaused() external view whenNotPaused {}


    function getAllStrategies()
        external
        view
        override
        returns (address[] memory)
    {

        return strategies;
    }

    function getStrategiesCount() external override view returns(uint8) {

        return uint8(strategies.length);
    }

    function verifyStrategies(address[] calldata _strategies) external override view {

        require(Hash.sameStrategies(_strategies, strategiesHash), "Controller::verifyStrategies: Incorrect strategies");
    }


    function pause() onlyPauser external {

        _pause();
    }

    function unpause() onlyUnpauser external {

        _unpause();
    }

    function createVault(
        VaultDetails calldata details
    ) external returns (address vault) {

        require(
            details.creator != address(0),
            "Controller::createVault: Missing vault creator"
        );
        require(
            supportedUnderlying[IERC20(details.underlying)],
            "Controller::createVault: Unsupported currency"
        );
        require(
            details.strategies.length > 0 && details.strategies.length <= MAX_VAULT_STRATEGIES,
            "Controller::createVault: Invalid number of strategies"
        );
        require(
            details.strategies.length == details.proportions.length,
            "Controller::createVault: Improper setup"
        );

        uint256 total;
        for (uint256 i = 0; i < details.strategies.length; i++) {
            for (uint256 j = i+1; j < details.strategies.length; j++) {
                require(details.strategies[i] != details.strategies[j], "Controller::createVault: Strategies not unique");
            }

            require(
                validStrategy[details.strategies[i]],
                "Controller::createVault: Unsupported strategy"
            );
            IBaseStrategy strategy = IBaseStrategy(details.strategies[i]);

            require(
                strategy.underlying() == IERC20(details.underlying),
                "Controller::createVault: Incorrect currency for strategy"
            );

            total += details.proportions[i];
        }

        require(
            total == FULL_PERCENT,
            "Controller::createVault: Improper allocations"
        );

        require(
            details.vaultFee <= MAX_VAULT_CREATOR_FEE ||
            (details.vaultFee <= MAX_DAO_VAULT_CREATOR_FEE && isSpoolOwner()),
            "Controller::createVault: High owner fee"
        );

        require(
            riskRegistry.isProvider(details.riskProvider),
            "Controller::createVault: Invalid risk provider"
        );

        require(
            details.riskTolerance >= MIN_RISK_TOLERANCE &&
            details.riskTolerance <= MAX_RISK_TOLERANCE,
            "Controller::createVault: Incorrect Risk Tolerance"
        );

        vault = _createVault(details);

        validVault[vault] = true;
        totalVaults++;

        _emitVaultCreated(vault, details);
    }

    function _emitVaultCreated(address vault, VaultDetails calldata details) private {

        emit VaultCreated(
            vault,
            details.underlying,
            details.strategies,
            details.proportions,
            details.vaultFee,
            details.riskProvider,
            details.riskTolerance
        );
    }

    function _createVault(
        VaultDetails calldata vaultDetails
    ) private returns (address vault) {

        vault = address(
            new VaultTransparentUpgradeableProxy(
                vaultImplementation,
                proxyAdmin,
                _getVaultImmutables(vaultDetails)
            )
        );

        IVault(vault).initialize(_getVaultInitializable(vaultDetails));
    }

    function _getVaultImmutables(VaultDetails calldata vaultDetails) private pure returns (VaultImmutables memory) {

        return VaultImmutables(
            IERC20(vaultDetails.underlying),
            vaultDetails.riskProvider,
            vaultDetails.riskTolerance
        );
    }

    function _getVaultInitializable(VaultDetails calldata vaultDetails) private pure returns (VaultInitializable memory) {

        return VaultInitializable(
            vaultDetails.name,
            vaultDetails.creator,
            vaultDetails.vaultFee,
            vaultDetails.strategies,
            vaultDetails.proportions
        );
    }

    function getRewards(IVault[] calldata vaults) external {

        IVault vault;
        for (uint256 i = 0; i < vaults.length; i++) {
            vault = vaults[i];
            if (!validVault[address(vault)]) {
                emit VaultInvalid(address(vault));
                continue;
            }
            vaults[i].getActiveRewards(msg.sender);
        }
    }


    function transferToSpool(address transferFrom, uint256 amount) external override onlyVault {

        IVault(msg.sender).underlying().safeTransferFrom(transferFrom, address(spool), amount);
    }

    function addStrategy(
        address strategy,
        address[] memory allStrategies
    )
        external
        onlyOwner
        validStrategiesOrEmpty(allStrategies)
    {

        require(
            !validStrategy[strategy],
            "Controller::addStrategy: Strategy already registered"
        );

        validStrategy[strategy] = true;

        IERC20 underlying = IBaseStrategy(strategy).underlying();
        supportedUnderlying[underlying] = true;

        strategyRegistry.addStrategy(strategy);
        spool.addStrategy(strategy);

        strategies.push(strategy);

        if (allStrategies.length == 0) {
            _updateStrategiesHash(strategies);
        } else {
            allStrategies = _addStrategy(allStrategies, strategy);
            _updateStrategiesHash(allStrategies);
        }

        emit StrategyAdded(strategy);
    }

    function _addStrategy(address[] memory currentStrategies, address strategy) private pure returns(address[] memory) {

        address[] memory newStrategies = new address[](currentStrategies.length + 1);
        for(uint256 i = 0; i < currentStrategies.length; i++) {
            newStrategies[i] = currentStrategies[i];
        }

        newStrategies[newStrategies.length - 1] = strategy;

        return newStrategies;
    }

    function removeStrategyAndWithdraw(
        address strategy,
        bool skipDisable,
        uint256[] calldata data,
        address[] calldata allStrategies
    )
        external
        onlyEmergencyWithdrawer
    {

        _removeStrategy(strategy, skipDisable, allStrategies);
        _emergencyWithdraw(strategy, data);
    }

    function removeStrategy(
        address strategy,
        bool skipDisable,
        address[] calldata allStrategies
    )
        external
        onlyEmergencyWithdrawer
    {

        _removeStrategy(strategy, skipDisable, allStrategies);
    }

    function emergencyWithdraw(
        address strategy,
        uint256[] calldata data
    ) 
        external
        onlyEmergencyWithdrawer
    {

        require(
            !validStrategy[strategy],
            "VaultRegistry::removeStrategy: Strategy should not be valid"
        );

        _emergencyWithdraw(strategy, data);
    }

    function _removeStrategy(
        address strategy,
        bool skipDisable,
        address[] calldata allStrategies
    )
        private
        validStrategiesOrEmpty(allStrategies)
    {

        require(
            validStrategy[strategy],
            "Controller::removeStrategy: Strategy is not registered"
        );

        spool.disableStrategy(strategy, skipDisable);

        validStrategy[strategy] = false;

        if (allStrategies.length == 0) {
            _removeStrategyStorage(strategy);
        } else {
            _removeStrategyCalldata(allStrategies, strategy);
        }

        emit StrategyRemoved(strategy);
    }

    function _removeStrategyStorage(address strategy) private {

        uint256 lastEntry = strategies.length - 1;
        for (uint256 i = 0; i < lastEntry; i++) {
            if (strategies[i] == strategy) {
                strategies[i] = strategies[lastEntry];
                break;
            }
        }

        strategies.pop();

        _updateStrategiesHash(strategies);
    }

    function _removeStrategyCalldata(address[] calldata allStrategies, address strategy) private {

        uint256 lastEntry = allStrategies.length - 1;
        address[] memory newStrategies = allStrategies[0:lastEntry];

        for (uint256 i = 0; i < lastEntry; i++) {
            if (allStrategies[i] == strategy) {
                strategies[i] = allStrategies[lastEntry];
                newStrategies[i] = allStrategies[lastEntry];
                break;
            }
        }

        strategies.pop();

        _updateStrategiesHash(newStrategies);
    }

    function _emergencyWithdraw(
        address strategy,
        uint256[] calldata data
    )
        private
    {

        spool.emergencyWithdraw(
            strategy,
            _getEmergencyRecipient(),
            data
        );

        emit EmergencyWithdrawStrategy(strategy);
    }

    function _getEmergencyRecipient() private view returns(address _emergencyRecipient) {

        _emergencyRecipient = emergencyRecipient;

        if (_emergencyRecipient == address(0)) {
            _emergencyRecipient = msg.sender;
        }
    }

    function runDisableStrategy(address strategy)
        external
        onlyEmergencyWithdrawer
    {

        require(
            !validStrategy[strategy],
            "Controller::runDisableStrategy: Strategy is still valid"
        );

        spool.runDisableStrategy(strategy);
        emit DisableStrategy(strategy);
    }

    function setEmergencyWithdrawer(address user, bool _isEmergencyWithdrawer) external onlyOwner {

        isEmergencyWithdrawer[user] = _isEmergencyWithdrawer;
        emit EmergencyWithdrawerUpdated(user, _isEmergencyWithdrawer);
    }

    function setPauser(address user, bool _set) external onlyOwner {

        isPauser[user] = _set;
        emit PauserUpdated(user, _set);
    }

    function setUnpauser(address user, bool _set) external onlyOwner {

        isUnpauser[user] = _set;
        emit UnpauserUpdated(user, _set);
    }

    function setEmergencyRecipient(address _emergencyRecipient) external onlyOwner {

        emergencyRecipient = _emergencyRecipient;
        emit EmergencyRecipientUpdated(_emergencyRecipient);
    }


    function _updateStrategiesHash(address[] memory _strategies) private {

        strategiesHash = Hash.hashStrategies(_strategies);
    }

    function _onlyVault() private view {

        require(
            validVault[msg.sender],
            "Controller::_onlyVault: Can only be invoked by vault"
        );
    }

    function _onlyEmergencyWithdrawer() private view {

        require(
            isEmergencyWithdrawer[msg.sender] || isSpoolOwner(),
            "Controller::_onlyEmergencyWithdrawer: Can only be invoked by the emergency withdrawer"
        );
    }

    function _validStrategiesOrEmpty(address[] memory _strategies) private view {

        require(
            _strategies.length == 0 ||
            Hash.sameStrategies(_strategies, strategiesHash),
            "Controller::_validStrategiesOrEmpty: Strategies do not match"
        );
    }

    function _onlyPauser() private view {

        require(
            isPauser[msg.sender] || isSpoolOwner(),
            "Controller::_onlyPauser: Can only be invoked by pauser"
        );
    }

    function _onlyUnpauser() private view {

        require(
            isUnpauser[msg.sender] || isSpoolOwner(),
            "Controller::_onlyUnpauser: Can only be invoked by unpauser"
        );
    }


    modifier onlyVault() {

        _onlyVault();
        _;
    }

    modifier onlyEmergencyWithdrawer() {

        _onlyEmergencyWithdrawer();
        _;
    }

    modifier validStrategiesOrEmpty(address[] memory allStrategies) {

        _validStrategiesOrEmpty(allStrategies);
        _;
    }

    modifier onlyPauser() {

        _onlyPauser();
        _;
    }

    modifier onlyUnpauser() {

        _onlyUnpauser();
        _;
    }

    modifier initializer() {

        require(!_initialized, "Controller::initializer: Can only be initialized once");
        _;
        _initialized = true;
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC1822Proxiable {

    function proxiableUUID() external view returns (bytes32);

}