
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
}// MIT

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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

interface IBeaconUpgradeable {

    function implementation() external view returns (address);

}// MIT

pragma solidity ^0.8.0;

library AddressUpgradeable {

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

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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

    function _upgradeToAndCall(address newImplementation, bytes memory data, bool forceCall) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }
    }

    function _upgradeToAndCallSecure(address newImplementation, bytes memory data, bool forceCall) internal {
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
                abi.encodeWithSignature(
                    "upgradeTo(address)",
                    oldImplementation
                )
            );
            rollbackTesting.value = false;
            require(oldImplementation == _getImplementation(), "ERC1967Upgrade: upgrade breaks further upgrades");
            _setImplementation(newImplementation);
            emit Upgraded(newImplementation);
        }
    }

    function _upgradeBeaconToAndCall(address newBeacon, bytes memory data, bool forceCall) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(IBeaconUpgradeable(newBeacon).implementation(), data);
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
        require(
            AddressUpgradeable.isContract(newBeacon),
            "ERC1967: new beacon is not a contract"
        );
        require(
            AddressUpgradeable.isContract(IBeaconUpgradeable(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    function _functionDelegateCall(address target, bytes memory data) private returns (bytes memory) {
        require(AddressUpgradeable.isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, "Address: low-level delegate call failed");
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract UUPSUpgradeable is Initializable, ERC1967UpgradeUpgradeable {
    function __UUPSUpgradeable_init() internal initializer {
        __ERC1967Upgrade_init_unchained();
        __UUPSUpgradeable_init_unchained();
    }

    function __UUPSUpgradeable_init_unchained() internal initializer {
    }
    function upgradeTo(address newImplementation) external virtual {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallSecure(newImplementation, bytes(""), false);
    }

    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallSecure(newImplementation, data, true);
    }

    function _authorizeUpgrade(address newImplementation) internal virtual;
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;

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

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;

contract LiquidityMiningStorage {

    address public comptroller;

    address[] public rewardTokens;

    mapping(address => bool) public rewardTokensMap;

    struct RewardSpeed {
        uint speed;
        uint start;
        uint end;
    }

    mapping(address => mapping(address => RewardSpeed)) public rewardSupplySpeeds;

    mapping(address => mapping(address => RewardSpeed)) public rewardBorrowSpeeds;

    struct RewardState {
        uint index;
        uint timestamp;
    }

    mapping(address => mapping(address => RewardState)) public rewardSupplyState;

    mapping(address => mapping(address => RewardState)) public rewardBorrowState;

    mapping(address => mapping(address => mapping(address => uint))) public rewardSupplierIndex;

    mapping(address => mapping(address => mapping(address => uint))) public rewardBorrowerIndex;

    mapping(address => mapping(address => uint)) public rewardAccrued;

    mapping(address => bool) public debtors;
}// MIT

pragma solidity ^0.8.0;

interface ComptrollerInterface {

    function getAllMarkets() external view returns (address[] memory);

    function markets(address) external view returns (bool, uint, uint);

    function getAccountLiquidity(address) external view returns (uint, uint, uint);

}// MIT

pragma solidity ^0.8.0;

interface CTokenInterface {

    function balanceOf(address owner) external view returns (uint);

    function borrowBalanceStored(address account) external view returns (uint);

    function borrowIndex() external view returns (uint);

    function totalSupply() external view returns (uint);

    function totalBorrows() external view returns (uint);

}// MIT

pragma solidity ^0.8.0;

interface LiquidityMiningInterface {

    function updateSupplyIndex(address cToken, address[] memory accounts) external;

    function updateBorrowIndex(address cToken, address[] memory accounts) external;

}// MIT

pragma solidity ^0.8.0;


contract LiquidityMining is Initializable, UUPSUpgradeable, OwnableUpgradeable, LiquidityMiningStorage, LiquidityMiningInterface {

    using SafeERC20 for IERC20;

    uint internal constant initialIndex = 1e18;
    address public constant ethAddress = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    event UpdateSupplierRewardIndex(
        address indexed rewardToken,
        address indexed cToken,
        address indexed supplier,
        uint rewards,
        uint supplyIndex
    );

    event UpdateBorrowerRewardIndex(
        address indexed rewardToken,
        address indexed cToken,
        address indexed borrower,
        uint rewards,
        uint borrowIndex
    );

    event UpdateSupplyRewardSpeed(
        address indexed rewardToken,
        address indexed cToken,
        uint indexed speed,
        uint start,
        uint end
    );

    event UpdateBorrowRewardSpeed(
        address indexed rewardToken,
        address indexed cToken,
        uint indexed speed,
        uint start,
        uint end
    );

    event TransferReward(
        address indexed rewardToken,
        address indexed account,
        uint indexed amount
    );

    event UpdateDebtor(
        address indexed account,
        bool indexed isDebtor
    );

    function initialize(address _admin, address _comptroller) initializer public {

        __Ownable_init();

        comptroller = _comptroller;
        transferOwnership(_admin);
    }

    receive() external payable {}


    function updateSupplyIndex(address cToken, address[] memory suppliers) external override {

        updateSupplyIndexInternal(rewardTokens, cToken, suppliers, true);
    }

    function updateBorrowIndex(address cToken, address[] memory borrowers) external override {

        updateBorrowIndexInternal(rewardTokens, cToken, borrowers, true);
    }

    function getBlockTimestamp() public virtual view returns (uint) {

        return block.timestamp;
    }

    function getRewardTokenList() external view returns (address[] memory) {

        return rewardTokens;
    }

    function claimAllRewards(address holder) public {

        address[] memory holders = new address[](1);
        holders[0] = holder;
        address[] memory allMarkets = ComptrollerInterface(comptroller).getAllMarkets();
        return claimRewards(holders, allMarkets, rewardTokens, true, true);
    }

    function claimRewards(address[] memory holders, address[] memory cTokens, address[] memory rewards, bool borrowers, bool suppliers) public {

        for (uint i = 0; i < cTokens.length; i++) {
            address cToken = cTokens[i];
            (bool isListed, , ) = ComptrollerInterface(comptroller).markets(cToken);
            require(isListed, "market must be listed");

            if (borrowers) {
                updateBorrowIndexInternal(rewards, cToken, holders, false);
            }
            if (suppliers) {
                updateSupplyIndexInternal(rewards, cToken, holders, false);
            }
        }

        for (uint i = 0; i < rewards.length; i++) {
            for (uint j = 0; j < holders.length; j++) {
                address rewardToken = rewards[i];
                address holder = holders[j];
                rewardAccrued[rewardToken][holder] = transferReward(rewardToken, holder, rewardAccrued[rewardToken][holder]);
            }
        }
    }

    function updateDebtors(address[] memory accounts) external {

        for (uint i = 0; i < accounts.length; i++) {
            address account = accounts[i];
            (uint err, , uint shortfall) = ComptrollerInterface(comptroller).getAccountLiquidity(account);
            require(err == 0, "failed to get account liquidity from comptroller");

            if (shortfall > 0 && !debtors[account]) {
                debtors[account] = true;
                emit UpdateDebtor(account, true);
            } else if (shortfall == 0 && debtors[account]) {
                debtors[account] = false;
                emit UpdateDebtor(account, false);
            }
        }
    }


    function _addRewardToken(address rewardToken) external onlyOwner {

        require(!rewardTokensMap[rewardToken], "reward token has been added");
        rewardTokensMap[rewardToken] = true;
        rewardTokens.push(rewardToken);
    }

    function _setRewardSupplySpeeds(address rewardToken, address[] memory cTokens, uint[] memory speeds, uint[] memory starts, uint[] memory ends) external onlyOwner {

        _setRewardSpeeds(rewardToken, cTokens, speeds, starts, ends, true);
    }

    function _setRewardBorrowSpeeds(address rewardToken, address[] memory cTokens, uint[] memory speeds, uint[] memory starts, uint[] memory ends) external onlyOwner {

        _setRewardSpeeds(rewardToken, cTokens, speeds, starts, ends, false);
    }


    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}


    function updateSupplyIndexInternal(address[] memory rewards, address cToken, address[] memory suppliers, bool distribute) internal {

        for (uint i = 0; i < rewards.length; i++) {
            require(rewardTokensMap[rewards[i]], "reward token not support");
            updateGlobalSupplyIndex(rewards[i], cToken);
            for (uint j = 0; j < suppliers.length; j++) {
                updateUserSupplyIndex(rewards[i], cToken, suppliers[j], distribute);
            }
        }
    }

    function updateBorrowIndexInternal(address[] memory rewards, address cToken, address[] memory borrowers, bool distribute) internal {

        for (uint i = 0; i < rewards.length; i++) {
            require(rewardTokensMap[rewards[i]], "reward token not support");

            uint marketBorrowIndex = CTokenInterface(cToken).borrowIndex();
            updateGlobalBorrowIndex(rewards[i], cToken, marketBorrowIndex);
            for (uint j = 0; j < borrowers.length; j++) {
                updateUserBorrowIndex(rewards[i], cToken, borrowers[j], marketBorrowIndex, distribute);
            }
        }
    }

    function updateGlobalSupplyIndex(address rewardToken, address cToken) internal {

        RewardState storage supplyState = rewardSupplyState[rewardToken][cToken];
        RewardSpeed memory supplySpeed = rewardSupplySpeeds[rewardToken][cToken];
        uint timestamp = getBlockTimestamp();
        if (timestamp > supplyState.timestamp) {
            if (supplySpeed.speed == 0 || supplySpeed.start > timestamp || supplyState.timestamp > supplySpeed.end) {
                supplyState.timestamp = timestamp;
            } else {
                uint fromTimestamp = max(supplyState.timestamp, supplySpeed.start);
                uint toTimestamp = min(timestamp, supplySpeed.end);
                uint deltaTime = toTimestamp - fromTimestamp;
                uint rewardAccrued = deltaTime * supplySpeed.speed;
                uint totalSupply = CTokenInterface(cToken).totalSupply();
                uint ratio = totalSupply > 0 ? rewardAccrued * 1e18 / totalSupply : 0;
                uint index = supplyState.index + ratio;
                rewardSupplyState[rewardToken][cToken] = RewardState({
                    index: index,
                    timestamp: timestamp
                });
            }
        }
    }

    function updateGlobalBorrowIndex(address rewardToken, address cToken, uint marketBorrowIndex) internal {

        RewardState storage borrowState = rewardBorrowState[rewardToken][cToken];
        RewardSpeed memory borrowSpeed = rewardBorrowSpeeds[rewardToken][cToken];
        uint timestamp = getBlockTimestamp();
        if (timestamp > borrowState.timestamp) {
            if (borrowSpeed.speed == 0 || timestamp < borrowSpeed.start || borrowState.timestamp > borrowSpeed.end) {
                borrowState.timestamp = timestamp;
            } else {
                uint fromTimestamp = max(borrowState.timestamp, borrowSpeed.start);
                uint toTimestamp = min(timestamp, borrowSpeed.end);
                uint deltaTime = toTimestamp - fromTimestamp;
                uint rewardAccrued = deltaTime * borrowSpeed.speed;
                uint totalBorrows = CTokenInterface(cToken).totalBorrows() * 1e18 / marketBorrowIndex;
                uint ratio = totalBorrows > 0 ? rewardAccrued * 1e18 / totalBorrows : 0;
                uint index = borrowState.index + ratio;
                rewardBorrowState[rewardToken][cToken] = RewardState({
                    index: index,
                    timestamp: timestamp
                });
            }
        }
    }

    function updateUserSupplyIndex(address rewardToken, address cToken, address supplier, bool distribute) internal {

        RewardState memory supplyState = rewardSupplyState[rewardToken][cToken];
        uint supplyIndex = supplyState.index;
        uint supplierIndex = rewardSupplierIndex[rewardToken][cToken][supplier];
        rewardSupplierIndex[rewardToken][cToken][supplier] = supplyIndex;

        if (supplierIndex > 0) {
            uint deltaIndex = supplyIndex - supplierIndex;
            uint supplierTokens = CTokenInterface(cToken).balanceOf(supplier);
            uint supplierDelta = supplierTokens * deltaIndex / 1e18;
            uint accruedAmount = rewardAccrued[rewardToken][supplier] + supplierDelta;
            if (distribute) {
                rewardAccrued[rewardToken][supplier] = transferReward(rewardToken, supplier, accruedAmount);
            } else {
                rewardAccrued[rewardToken][supplier] = accruedAmount;
            }
            emit UpdateSupplierRewardIndex(rewardToken, cToken, supplier, supplierDelta, supplyIndex);
        }
    }

    function updateUserBorrowIndex(address rewardToken, address cToken, address borrower, uint marketBorrowIndex, bool distribute) internal {

        RewardState memory borrowState = rewardBorrowState[rewardToken][cToken];
        uint borrowIndex = borrowState.index;
        uint borrowerIndex = rewardBorrowerIndex[rewardToken][cToken][borrower];
        rewardBorrowerIndex[rewardToken][cToken][borrower] = borrowIndex;

        if (borrowerIndex > 0) {
            uint deltaIndex = borrowIndex - borrowerIndex;
            uint borrowerAmount = CTokenInterface(cToken).borrowBalanceStored(borrower) * 1e18 / marketBorrowIndex;
            uint borrowerDelta = borrowerAmount * deltaIndex / 1e18;
            uint accruedAmount = rewardAccrued[rewardToken][borrower] + borrowerDelta;
            if (distribute) {
                rewardAccrued[rewardToken][borrower] = transferReward(rewardToken, borrower, accruedAmount);
            } else {
                rewardAccrued[rewardToken][borrower] = accruedAmount;
            }
            emit UpdateBorrowerRewardIndex(rewardToken, cToken, borrower, borrowerDelta, borrowIndex);
        }
    }

    function transferReward(address rewardToken, address user, uint amount) internal returns (uint) {

        uint remain = rewardToken == ethAddress ? address(this).balance : IERC20(rewardToken).balanceOf(address(this));
        if (amount > 0 && amount <= remain && !debtors[user]) {
            if (rewardToken == ethAddress) {
                payable(user).transfer(amount);
            } else {
                IERC20(rewardToken).safeTransfer(user, amount);
            }
            emit TransferReward(rewardToken, user, amount);
            return 0;
        }
        return amount;
    }

    function _setRewardSpeeds(address rewardToken, address[] memory cTokens, uint[] memory speeds, uint[] memory starts, uint[] memory ends, bool supply) internal {

        uint timestamp = getBlockTimestamp();
        uint numMarkets = cTokens.length;
        require(numMarkets != 0 && numMarkets == speeds.length && numMarkets == starts.length && numMarkets == ends.length, "invalid input");
        require(rewardTokensMap[rewardToken], "reward token was not added");

        for (uint i = 0; i < numMarkets; i++) {
            address cToken = cTokens[i];
            uint speed = speeds[i];
            uint start = starts[i];
            uint end = ends[i];
            if (supply) {
                if (isSupplyRewardStateInit(rewardToken, cToken)) {
                    updateGlobalSupplyIndex(rewardToken, cToken);
                } else {
                    rewardSupplyState[rewardToken][cToken] = RewardState({
                        index: initialIndex,
                        timestamp: timestamp
                    });
                }

                validateRewardContent(rewardSupplySpeeds[rewardToken][cToken], start, end);
                rewardSupplySpeeds[rewardToken][cToken] = RewardSpeed({
                    speed: speed,
                    start: start,
                    end: end
                });
                emit UpdateSupplyRewardSpeed(rewardToken, cToken, speed, start, end);
            } else {
                if (isBorrowRewardStateInit(rewardToken, cToken)) {
                    uint marketBorrowIndex = CTokenInterface(cToken).borrowIndex();
                    updateGlobalBorrowIndex(rewardToken, cToken, marketBorrowIndex);
                } else {
                    rewardBorrowState[rewardToken][cToken] = RewardState({
                        index: initialIndex,
                        timestamp: timestamp
                    });
                }

                validateRewardContent(rewardBorrowSpeeds[rewardToken][cToken], start, end);
                rewardBorrowSpeeds[rewardToken][cToken] = RewardSpeed({
                    speed: speed,
                    start: start,
                    end: end
                });
                emit UpdateBorrowRewardSpeed(rewardToken, cToken, speed, start, end);
            }
        }
    }

    function isSupplyRewardStateInit(address rewardToken, address cToken) internal view returns (bool) {

        return rewardSupplyState[rewardToken][cToken].index != 0 && rewardSupplyState[rewardToken][cToken].timestamp != 0;
    }

    function isBorrowRewardStateInit(address rewardToken, address cToken) internal view returns (bool) {

        return rewardBorrowState[rewardToken][cToken].index != 0 && rewardBorrowState[rewardToken][cToken].timestamp != 0;
    }

    function validateRewardContent(RewardSpeed memory currentSpeed, uint newStart, uint newEnd) internal view {

        uint timestamp = getBlockTimestamp();
        require(newEnd >= timestamp, "the end timestamp must be greater than the current timestamp");
        require(newEnd >= newStart, "the end timestamp must be greater than the start timestamp");
        if (timestamp < currentSpeed.end && timestamp > currentSpeed.start && currentSpeed.start != 0) {
            require(currentSpeed.start == newStart, "cannot change the start timestamp after the reward starts");
        }
    }

    function min(uint a, uint b) internal pure returns (uint) {

        if (a < b) {
            return a;
        }
        return b;
    }

    function max(uint a, uint b) internal pure returns (uint) {

        if (a > b) {
            return a;
        }
        return b;
    }
}