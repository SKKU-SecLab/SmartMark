pragma solidity 0.8.4;

interface IHarvest {

    function setHarvestRewardVault(address _harvestRewardVault) external;


    function setHarvestRewardPool(address _harvestRewardPool) external;


    function setHarvestPoolToken(address _harvestfToken) external;


    function setFarmToken(address _farmToken) external;


    function updateReward() external;

}// MIT

pragma solidity 0.8.4;

interface IHarvestVault {

    function deposit(uint256 amount) external;


    function withdraw(uint256 numberOfShares) external;

}// MIT

pragma solidity 0.8.4;

interface IMintNoRewardPool {

    function stake(uint256 amount) external;


    function withdraw(uint256 amount) external;


    function earned(address account) external view returns (uint256);


    function lastTimeRewardApplicable() external view returns (uint256);


    function rewardPerToken() external view returns (uint256);


    function rewards(address account) external view returns (uint256);


    function userRewardPerTokenPaid(address account)
        external
        view
        returns (uint256);


    function lastUpdateTime() external view returns (uint256);


    function rewardRate() external view returns (uint256);


    function totalSupply() external view returns (uint256);


    function rewardPerTokenStored() external view returns (uint256);


    function periodFinish() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);

    function getReward() external;

}// MIT
pragma solidity 0.8.4;

interface IStrategy {

    function setTreasury(address payable _feeAddress) external;


    function setCap(uint256 _cap) external;


    function setLockTime(uint256 _lockTime) external;


    function setFeeAddress(address payable _feeAddress) external;


    function setFee(uint256 _fee) external;


    function rescueDust() external;


    function rescueAirdroppedTokens(address _token, address to) external;


    function setSushiswapRouter(address _sushiswapRouter) external;

}// GPL-3.0-or-later
pragma solidity 0.8.4;



interface IUniswapRouter {

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );


    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );


    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);


    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);


    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);


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

}// MIT

pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
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

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}// MIT
pragma solidity ^0.8.0;


contract ReceiptToken is ERC20, Ownable {
    ERC20 public underlyingToken;
    address public underlyingStrategy;

    constructor(address underlyingAddress, address strategy)
        ERC20(
            string(abi.encodePacked("pAT-", ERC20(underlyingAddress).name())),
            string(abi.encodePacked("pAT-", ERC20(underlyingAddress).symbol()))
        )
    {
        underlyingToken = ERC20(underlyingAddress);
        underlyingStrategy = strategy;
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) public onlyOwner {
        _burn(from, amount);
    }
}// MIT
pragma solidity 0.8.4;


contract Storage{
    address public weth;
    address payable public treasuryAddress;
    address payable public feeAddress;
    address public token;
    IUniswapRouter public sushiswapRouter;
    ReceiptToken public receiptToken;

    uint256 internal _minSlippage;
    uint256 public lockTime;
    uint256 public fee;
    uint256 constant feeFactor = uint256(10000);
    uint256 public cap;

}// MIT
pragma solidity 0.8.4;



contract StrategyBase is Storage, Initializable, UUPSUpgradeable, OwnableUpgradeable{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;


    event ReceiptMinted(address indexed user, uint256 amount);
    event ReceiptBurned(address indexed user, uint256 amount);

    function __StrategyBase_init(
      address _sushiswapRouter, address _token,
      address _weth,
      address payable _treasuryAddress,
      address payable _feeAddress,
      uint256 _cap) internal initializer {
        require(_sushiswapRouter != address(0), "ROUTER_0x0");
        require(_token != address(0), "TOKEN_0x0");
        require(_weth != address(0), "WETH_0x0");
        require(_treasuryAddress != address(0), "TREASURY_0x0");
        require(_feeAddress != address(0), "FEE_0x0");
        sushiswapRouter = IUniswapRouter(_sushiswapRouter);
        token = _token;
        weth = _weth;
        treasuryAddress = _treasuryAddress;
        feeAddress = _feeAddress;
        cap = _cap;
        _minSlippage = 10; //0.1%
        lockTime = 1;
        fee = uint256(100);
        __Ownable_init();
    }

    function _authorizeUpgrade(address) internal override onlyOwner {

    }


    function _validateCommon(
        uint256 deadline,
        uint256 amount,
        uint256 _slippage
    ) internal view {
        require(deadline >= block.timestamp, "DEADLINE_ERROR");
        require(amount > 0, "AMOUNT_0");
        require(_slippage >= _minSlippage, "SLIPPAGE_ERROR");
        require(_slippage <= feeFactor, "MAX_SLIPPAGE_ERROR");
    }

    function _validateDeposit(
        uint256 deadline,
        uint256 amount,
        uint256 total,
        uint256 slippage
    ) internal view {
        _validateCommon(deadline, amount, slippage);

        require(total.add(amount) <= cap, "CAP_REACHED");
    }

    function _mintParachainAuctionTokens(uint256 _amount) internal {
        receiptToken.mint(msg.sender, _amount);
        emit ReceiptMinted(msg.sender, _amount);
    }

    function _burnParachainAuctionTokens(uint256 _amount) internal {
        receiptToken.burn(msg.sender, _amount);
        emit ReceiptBurned(msg.sender, _amount);
    }

    function _calculateFee(uint256 _amount) internal view returns (uint256) {
        return _calculatePortion(_amount, fee);
    }

    function _getBalance(address _token) internal view returns (uint256) {
        return IERC20(_token).balanceOf(address(this));
    }

    function _increaseAllowance(
        address _token,
        address _contract,
        uint256 _amount
    ) internal {
        IERC20(_token).safeIncreaseAllowance(address(_contract), _amount);
    }

    function _getRatio(
        uint256 numerator,
        uint256 denominator,
        uint256 precision
    ) internal pure returns (uint256) {
        if (numerator == 0 || denominator == 0) {
            return 0;
        }
        uint256 _numerator = numerator * 10**(precision + 1);
        uint256 _quotient = ((_numerator / denominator) + 5) / 10;
        return (_quotient);
    }

    function _swapTokenToEth(
        address[] memory swapPath,
        uint256 exchangeAmount,
        uint256 deadline,
        uint256 slippage,
        uint256 ethPerToken
    ) internal returns (uint256) {
        uint256[] memory amounts =
            sushiswapRouter.getAmountsOut(exchangeAmount, swapPath);
        uint256 sushiAmount = amounts[amounts.length - 1]; //amount of ETH
        uint256 portion = _calculatePortion(sushiAmount, slippage);
        uint256 calculatedPrice = (exchangeAmount.mul(ethPerToken)).div(10**18);
        uint256 decimals = ERC20(swapPath[0]).decimals();
        if (decimals < 18) {
            calculatedPrice = calculatedPrice.mul(10**(18 - decimals));
        }
        if (sushiAmount > calculatedPrice) {
            require(
                sushiAmount.sub(calculatedPrice) <= portion,
                "PRICE_ERROR_1"
            );
        } else {
            require(
                calculatedPrice.sub(sushiAmount) <= portion,
                "PRICE_ERROR_2"
            );
        }

        _increaseAllowance(
            swapPath[0],
            address(sushiswapRouter),
            exchangeAmount
        );
        uint256[] memory tokenSwapAmounts =
            sushiswapRouter.swapExactTokensForETH(
                exchangeAmount,
                _getMinAmount(sushiAmount, slippage),
                swapPath,
                address(this),
                deadline
            );
        return tokenSwapAmounts[tokenSwapAmounts.length - 1];
    }

    function _swapEthToToken(
        address[] memory swapPath,
        uint256 exchangeAmount,
        uint256 deadline,
        uint256 slippage,
        uint256 tokensPerEth
    ) internal returns (uint256) {
        uint256[] memory amounts =
            sushiswapRouter.getAmountsOut(exchangeAmount, swapPath);
        uint256 sushiAmount = amounts[amounts.length - 1];
        uint256 portion = _calculatePortion(sushiAmount, slippage);
        uint256 calculatedPrice =
            (exchangeAmount.mul(tokensPerEth)).div(10**18);
        uint256 decimals = ERC20(swapPath[0]).decimals();
        if (decimals < 18) {
            calculatedPrice = calculatedPrice.mul(10**(18 - decimals));
        }
        if (sushiAmount > calculatedPrice) {
            require(
                sushiAmount.sub(calculatedPrice) <= portion,
                "PRICE_ERROR_1"
            );
        } else {
            require(
                calculatedPrice.sub(sushiAmount) <= portion,
                "PRICE_ERROR_2"
            );
        }

        uint256[] memory swapResult =
            sushiswapRouter.swapExactETHForTokens{value: exchangeAmount}(
                _getMinAmount(sushiAmount, slippage),
                swapPath,
                address(this),
                deadline
            );

        return swapResult[swapResult.length - 1];
    }

    function _getMinAmount(uint256 amount, uint256 slippage)
        private
        pure
        returns (uint256)
    {
        uint256 portion = _calculatePortion(amount, slippage);
        return amount.sub(portion);
    }

    function _calculatePortion(uint256 _amount, uint256 _fee)
        private
        pure
        returns (uint256)
    {
        return (_amount.mul(_fee)).div(feeFactor);
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "TransferHelper: ETH_TRANSFER_FAILED");
    }
}// MIT

pragma solidity 0.8.4;
contract HarvestStorage {
    struct UserInfo {
        uint256 amountEth; //how much ETH the user entered with; should be 0 for HarvestSC
        uint256 amountToken; //how much Token was obtained by swapping user's ETH
        uint256 amountfToken; //how much fToken was obtained after deposit to vault
        uint256 underlyingRatio; //ratio between obtained fToken and token
        uint256 userTreasuryEth; //how much eth the user sent to treasury
        uint256 userCollectedFees; //how much eth the user sent to fee address
        uint256 timestamp; //first deposit timestamp; used for withdrawal lock time check
        uint256 earnedTokens;
        uint256 earnedRewards; //before fees
        uint256 rewards;
        uint256 userRewardPerTokenPaid;
    }

    address public farmToken;
    address public harvestfToken;
    uint256 public ethDust;
    uint256 public treasueryEthDust;
    uint256 public totalDeposits;
    IMintNoRewardPool public harvestRewardPool;
    IHarvestVault public harvestRewardVault;
    mapping(address => UserInfo) public userInfo;
    uint256 public totalInvested; //total invested
}// MIT
pragma solidity 0.8.4;





contract HarvestBase is HarvestStorage, OwnableUpgradeable, StrategyBase, IHarvest, IStrategy {
    using SafeMath for uint256;

    struct UserDeposits {
        uint256 timestamp;
        uint256 amountfToken;
    }
    struct DepositData {
        address[] swapPath;
        uint256[] swapAmounts;
        uint256 obtainedToken;
        uint256 obtainedfToken;
        uint256 prevfTokenBalance;
    }

    struct WithdrawData {
        uint256 prevDustEthBalance;
        uint256 prevfTokenBalance;
        uint256 prevTokenBalance;
        uint256 obtainedfToken;
        uint256 obtainedToken;
        uint256 feeableToken;
        uint256 feeableEth;
        uint256 totalEth;
        uint256 totalToken;
        uint256 auctionedEth;
        uint256 auctionedToken;
        uint256 rewards;
        uint256 farmBalance;
        uint256 burnAmount;
        uint256 earnedTokens;
        uint256 rewardsInEth;
        uint256 auctionedRewardsInEth;
        uint256 userRewardsInEth;
        uint256 initialAmountfToken;
    }

    event ExtraTokensExchanged(
        address indexed user,
        uint256 tokensAmount,
        uint256 obtainedEth
    );
    event ObtainedInfo(
        address indexed user,
        uint256 underlying,
        uint256 underlyingReceipt
    );

    event RewardsEarned(address indexed user, uint256 amount);
    event ExtraTokens(address indexed user, uint256 amount);


    event RescuedDust(string indexed dustType, uint256 amount);

    event ChangedAddress(
        string indexed addressType,
        address indexed oldAddress,
        address indexed newAddress
    );

    event ChangedValue(
        string indexed valueType,
        uint256 indexed oldValue,
        uint256 indexed newValue
    );


    function __HarvestBase_init(address _harvestRewardVault,address _harvestRewardPool, address _sushiswapRouter,address _harvestfToken,
        address _farmToken, address _token,address _weth,address payable _treasuryAddress, address payable _feeAddress, uint256 _cap) internal initializer  {
        require(_harvestRewardVault != address(0), "VAULT_0x0");
        require(_harvestRewardPool != address(0), "POOL_0x0");
        require(_harvestfToken != address(0), "fTOKEN_0x0");
        require(_farmToken != address(0), "FARM_0x0");

        __Ownable_init();

        __StrategyBase_init(_sushiswapRouter, _token, _weth, _treasuryAddress,  _feeAddress, _cap);
        harvestRewardVault = IHarvestVault(_harvestRewardVault);
        harvestRewardPool = IMintNoRewardPool(_harvestRewardPool);
        harvestfToken = _harvestfToken;
        farmToken = _farmToken;
        receiptToken = new ReceiptToken(token, address(this));
    }
    function setHarvestRewardVault(address _harvestRewardVault)
        external
        override
        onlyOwner
    {
        require(_harvestRewardVault != address(0), "VAULT_0x0");
        emit ChangedAddress(
            "VAULT",
            address(harvestRewardVault),
            _harvestRewardVault
        );
        harvestRewardVault = IHarvestVault(_harvestRewardVault);
    }

    function setHarvestRewardPool(address _harvestRewardPool)
        external
        override
        onlyOwner
    {
        require(_harvestRewardPool != address(0), "POOL_0x0");
        emit ChangedAddress(
            "POOL",
            address(harvestRewardPool),
            _harvestRewardPool
        );
        harvestRewardPool = IMintNoRewardPool(_harvestRewardPool);
    }

    function setSushiswapRouter(address _sushiswapRouter)
        external
        override
        onlyOwner
    {
        require(_sushiswapRouter != address(0), "0x0");
        emit ChangedAddress(
            "SUSHISWAP_ROUTER",
            address(sushiswapRouter),
            _sushiswapRouter
        );
        sushiswapRouter = IUniswapRouter(_sushiswapRouter);
    }

    function setHarvestPoolToken(address _harvestfToken)
        external
        override
        onlyOwner
    {
        require(_harvestfToken != address(0), "TOKEN_0x0");
        emit ChangedAddress("TOKEN", harvestfToken, _harvestfToken);
        harvestfToken = _harvestfToken;
    }

    function setFarmToken(address _farmToken) external override onlyOwner {
        require(_farmToken != address(0), "FARM_0x0");
        emit ChangedAddress("FARM", farmToken, _farmToken);
        farmToken = _farmToken;
    }

    function setTreasury(address payable _feeAddress)
        external
        override
        onlyOwner
    {
        require(_feeAddress != address(0), "0x0");
        emit ChangedAddress(
            "TREASURY",
            address(treasuryAddress),
            address(_feeAddress)
        );
        treasuryAddress = _feeAddress;
    }


    function setCap(uint256 _cap) external override onlyOwner {
        emit ChangedValue("CAP", cap, _cap);
        cap = _cap;
    }

    function setLockTime(uint256 _lockTime) external override onlyOwner {
        require(_lockTime > 0, "TIME_0");
        emit ChangedValue("LOCKTIME", lockTime, _lockTime);
        lockTime = _lockTime;
    }

    function setFeeAddress(address payable _feeAddress)
        external
        override
        onlyOwner
    {
        emit ChangedAddress("FEE", address(feeAddress), address(_feeAddress));
        feeAddress = _feeAddress;
    }

    function setFee(uint256 _fee) external override onlyOwner {
        require(_fee <= uint256(9000), "FEE_TOO_HIGH");
        emit ChangedValue("FEE", fee, _fee);
    }

    function rescueDust() external override onlyOwner {
        if (ethDust > 0) {
            safeTransferETH(treasuryAddress, ethDust);
            treasueryEthDust = treasueryEthDust.add(ethDust);
            emit RescuedDust("ETH", ethDust);
            ethDust = 0;
        }
    }

    function rescueAirdroppedTokens(address _token, address to)
        external
        override
        onlyOwner
    {
        require(_token != address(0), "token_0x0");
        require(to != address(0), "to_0x0");
        require(_token != farmToken, "rescue_reward_error");

        uint256 balanceOfToken = IERC20(_token).balanceOf(address(this));
        require(balanceOfToken > 0, "balance_0");

        require(IERC20(_token).transfer(to, balanceOfToken), "rescue_failed");
    }

    function updateReward() external override onlyOwner {
        harvestRewardPool.getReward();
    }

    function isWithdrawalAvailable(address user) public view returns (bool) {
        if (lockTime > 0) {
            return userInfo[user].timestamp.add(lockTime) <= block.timestamp;
        }
        return true;
    }

    function getPendingRewards(address account) public view returns (uint256) {
        if (account != address(0)) {
            if (userInfo[account].amountfToken == 0) {
                return 0;
            }
            return
                _earned(
                    userInfo[account].amountfToken,
                    userInfo[account].userRewardPerTokenPaid,
                    userInfo[account].rewards
                );
        }
        return 0;
    }

    function _calculateRewards(
        address account,
        uint256 amount,
        uint256 amountfToken
    ) internal view returns (uint256) {
        uint256 rewards = userInfo[account].rewards;
        uint256 farmBalance = IERC20(farmToken).balanceOf(address(this));

        if (amount == 0) {
            if (rewards < farmBalance) {
                return rewards;
            }
            return farmBalance;
        }

        return (amount.mul(rewards)).div(amountfToken);
    }

    function _updateRewards(address account) internal {
        if (account != address(0)) {
            UserInfo storage user = userInfo[account];

            uint256 _stored = harvestRewardPool.rewardPerToken();

            user.rewards = _earned(
                user.amountfToken,
                user.userRewardPerTokenPaid,
                user.rewards
            );
            user.userRewardPerTokenPaid = _stored;
        }
    }

    function _earned(
        uint256 _amountfToken,
        uint256 _userRewardPerTokenPaid,
        uint256 _rewards
    ) internal view returns (uint256) {
        return
            _amountfToken
                .mul(
                harvestRewardPool.rewardPerToken().sub(_userRewardPerTokenPaid)
            )
                .div(1e18)
                .add(_rewards);
    }

    function _validateWithdraw(
        uint256 deadline,
        uint256 amount,
        uint256 amountfToken,
        uint256 receiptBalance,
        uint256 timestamp,
        uint256 slippage
    ) internal view {
        _validateCommon(deadline, amount, slippage);

        require(amountfToken >= amount, "AMOUNT_GREATER_THAN_BALANCE");

        require(receiptBalance >= amountfToken, "RECEIPT_AMOUNT");

        if (lockTime > 0) {
            require(timestamp.add(lockTime) <= block.timestamp, "LOCK_TIME");
        }
    }

    function _depositTokenToHarvestVault(uint256 amount)
        internal
        returns (uint256)
    {
        _increaseAllowance(token, address(harvestRewardVault), amount);

        uint256 prevfTokenBalance = _getBalance(harvestfToken);
        harvestRewardVault.deposit(amount);
        uint256 currentfTokenBalance = _getBalance(harvestfToken);

        require(
            currentfTokenBalance > prevfTokenBalance,
            "DEPOSIT_VAULT_ERROR"
        );

        return currentfTokenBalance.sub(prevfTokenBalance);
    }

    function _withdrawTokenFromHarvestVault(uint256 amount)
        internal
        returns (uint256)
    {
        _increaseAllowance(harvestfToken, address(harvestRewardVault), amount);

        uint256 prevTokenBalance = _getBalance(token);
        harvestRewardVault.withdraw(amount);
        uint256 currentTokenBalance = _getBalance(token);

        require(currentTokenBalance > prevTokenBalance, "WITHDRAW_VAULT_ERROR");

        return currentTokenBalance.sub(prevTokenBalance);
    }

    function _stakefTokenToHarvestPool(uint256 amount) internal {
        _increaseAllowance(harvestfToken, address(harvestRewardPool), amount);
        harvestRewardPool.stake(amount);
    }

    function _unstakefTokenFromHarvestPool(uint256 amount)
        internal
        returns (uint256)
    {
        _increaseAllowance(harvestfToken, address(harvestRewardPool), amount);

        uint256 prevfTokenBalance = _getBalance(harvestfToken);
        harvestRewardPool.withdraw(amount);
        uint256 currentfTokenBalance = _getBalance(harvestfToken);

        require(
            currentfTokenBalance > prevfTokenBalance,
            "WITHDRAW_POOL_ERROR"
        );

        return currentfTokenBalance.sub(prevfTokenBalance);
    }

    function _calculatefTokenRemainings(
        uint256 amount,
        uint256 amountfToken
    ) internal pure returns (uint256, uint256) {
        uint256 burnAmount = amount;
        if (amount < amountfToken) {
            amountfToken = amountfToken.sub(amount);
        } else {
            burnAmount = amountfToken;
            amountfToken = 0;
        }

        return (amountfToken, burnAmount);
    }

    function _calculateFeeableTokens(
        uint256 amountfToken,
        uint256 obtainedToken,
        uint256 amountToken,
        uint256 obtainedfToken,
        uint256 underlyingRatio
    ) internal returns (uint256 feeableToken, uint256 earnedTokens) {
        if (obtainedfToken == amountfToken) {
            if (obtainedToken > amountToken) {
                feeableToken = obtainedToken.sub(amountToken);
            }
        } else {
            uint256 currentRatio = _getRatio(obtainedfToken, obtainedToken, 18);

            if (currentRatio < underlyingRatio) {
                uint256 noOfOriginalTokensForCurrentAmount =
                    (obtainedfToken.mul(10**18)).div(underlyingRatio);
                if (noOfOriginalTokensForCurrentAmount < obtainedToken) {
                    feeableToken = obtainedToken.sub(
                        noOfOriginalTokensForCurrentAmount
                    );
                }
            }
        }

        if (feeableToken > 0) {
            uint256 extraTokensFee = _calculateFee(feeableToken);
            emit ExtraTokens(msg.sender, feeableToken.sub(extraTokensFee));
            earnedTokens = feeableToken.sub(extraTokensFee);
        }
    }

    receive() external payable {}
}// MIT
pragma solidity 0.8.4;


contract HarvestSCBase is StrategyBase, HarvestBase {
    uint256 public totalToken; //total invested eth

    event RewardsExchanged(
        address indexed user,
        string exchangeType, //ETH or Token
        uint256 rewardsAmount,
        uint256 obtainedAmount
    );

    event Deposit(
        address indexed user,
        address indexed origin,
        uint256 amountToken,
        uint256 amountfToken
    );

    event Withdraw(
        address indexed user,
        address indexed origin,
        uint256 amountToken,
        uint256 amountfToken,
        uint256 treasuryAmountEth
    );
}// MIT
pragma solidity 0.8.4;




contract HarvestSC is StrategyBase, HarvestSCBase, ReentrancyGuardUpgradeable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    function initialize(
        address _harvestRewardVault,
        address _harvestRewardPool,
        address _sushiswapRouter,
        address _harvestfToken,
        address _farmToken,
        address _token,
        address _weth,
        address payable _treasuryAddress,
        address payable _feeAddress
    ) external initializer {
        __ReentrancyGuard_init();
        __HarvestBase_init(
            _harvestRewardVault,
            _harvestRewardPool,
            _sushiswapRouter,
            _harvestfToken,
            _farmToken,
            _token,
            _weth,
            _treasuryAddress,
            _feeAddress,
            5000000 * (10**18)
        );
      }


    function deposit(
        uint256 tokenAmount,
        uint256 deadline,
        uint256 slippage
    ) public nonReentrant returns (uint256) {
        _validateDeposit(deadline, tokenAmount, totalToken, slippage);

        _updateRewards(msg.sender);

        IERC20(token).safeTransferFrom(msg.sender, address(this), tokenAmount);

        DepositData memory results;
        UserInfo storage user = userInfo[msg.sender];

        if (user.timestamp == 0) {
            user.timestamp = block.timestamp;
        }

        totalToken = totalToken.add(tokenAmount);
        user.amountToken = user.amountToken.add(tokenAmount);
        results.obtainedToken = tokenAmount;

        results.obtainedfToken = _depositTokenToHarvestVault(
            results.obtainedToken
        );

        _stakefTokenToHarvestPool(results.obtainedfToken);
        user.amountfToken = user.amountfToken.add(results.obtainedfToken);

        _mintParachainAuctionTokens(results.obtainedfToken);

        emit Deposit(
            msg.sender,
            tx.origin,
            results.obtainedToken,
            results.obtainedfToken
        );

        totalDeposits = totalDeposits.add(results.obtainedfToken);

        user.underlyingRatio = _getRatio(
            user.amountfToken,
            user.amountToken,
            18
        );

        return results.obtainedfToken;
    }

    function withdraw(
        uint256 amount,
        uint256 deadline,
        uint256 slippage,
        uint256 ethPerToken,
        uint256 ethPerFarm,
        uint256 tokensPerEth //no of tokens per 1 eth
    ) public nonReentrant returns (uint256) {
        UserInfo storage user = userInfo[msg.sender];
        uint256 receiptBalance = receiptToken.balanceOf(msg.sender);

        _validateWithdraw(
            deadline,
            amount,
            user.amountfToken,
            receiptBalance,
            user.timestamp,
            slippage
        );

        _updateRewards(msg.sender);

        WithdrawData memory results;
        results.initialAmountfToken = user.amountfToken;
        results.prevDustEthBalance = address(this).balance;

        results.obtainedfToken = _unstakefTokenFromHarvestPool(amount);

        harvestRewardPool.getReward(); //transfers FARM to this contract

        uint256 transferableRewards =
            _calculateRewards(msg.sender, amount, results.initialAmountfToken);

        (user.amountfToken, results.burnAmount) = _calculatefTokenRemainings(
            amount,
            results.initialAmountfToken
        );
        _burnParachainAuctionTokens(results.burnAmount);

        results.obtainedToken = _withdrawTokenFromHarvestVault(
            results.obtainedfToken
        );
        emit ObtainedInfo(
            msg.sender,
            results.obtainedToken,
            results.obtainedfToken
        );
        totalDeposits = totalDeposits.sub(results.obtainedfToken);

        results.auctionedToken = 0;
        (results.feeableToken, results.earnedTokens) = _calculateFeeableTokens(
            results.initialAmountfToken,
            results.obtainedToken,
            user.amountToken,
            results.obtainedfToken,
            user.underlyingRatio
        );
        user.earnedTokens = user.earnedTokens.add(results.earnedTokens);
        if (results.obtainedToken <= user.amountToken) {
            user.amountToken = user.amountToken.sub(results.obtainedToken);
        } else {
            user.amountToken = 0;
        }
        results.obtainedToken = results.obtainedToken.sub(results.feeableToken);

        if (results.feeableToken > 0) {
            results.auctionedToken = results.feeableToken.div(2);
            results.feeableToken = results.feeableToken.sub(
                results.auctionedToken
            );
        }
        results.totalToken = results.obtainedToken.add(results.feeableToken);

        address[] memory swapPath = new address[](2);
        swapPath[0] = token;
        swapPath[1] = weth;

        if (results.auctionedToken > 0) {
            uint256 swapAuctionedTokenResult =
                _swapTokenToEth(
                    swapPath,
                    results.auctionedToken,
                    deadline,
                    slippage,
                    ethPerToken
                );
            results.auctionedEth.add(swapAuctionedTokenResult);

            emit ExtraTokensExchanged(
                msg.sender,
                results.auctionedToken,
                swapAuctionedTokenResult
            );
        }


        if (transferableRewards > 0) {
            emit RewardsEarned(msg.sender, transferableRewards);
            user.earnedRewards = user.earnedRewards.add(transferableRewards);

            swapPath[0] = farmToken;

            results.rewardsInEth = _swapTokenToEth(
                swapPath,
                transferableRewards,
                deadline,
                slippage,
                ethPerFarm
            );
            results.auctionedRewardsInEth = results.rewardsInEth.div(2);
            results.userRewardsInEth = results.rewardsInEth.sub(
                results.auctionedRewardsInEth
            );

            results.auctionedEth = results.auctionedEth.add(
                results.auctionedRewardsInEth
            );
            emit RewardsExchanged(
                msg.sender,
                "ETH",
                transferableRewards,
                results.rewardsInEth
            );
        }
        if (results.userRewardsInEth > 0) {
            swapPath[0] = weth;
            swapPath[1] = token;

            uint256 userRewardsEthToTokenResult =
                _swapEthToToken(
                    swapPath,
                    results.userRewardsInEth,
                    deadline,
                    slippage,
                    tokensPerEth
                );
            results.totalToken = results.totalToken.add(
                userRewardsEthToTokenResult
            );

            emit RewardsExchanged(
                msg.sender,
                "Token",
                transferableRewards.div(2),
                userRewardsEthToTokenResult
            );
        }
        user.rewards = user.rewards.sub(transferableRewards);

        if (results.totalToken < totalToken) {
            totalToken = totalToken.sub(results.totalToken);
        } else {
            totalToken = 0;
        }

        if (user.amountfToken == 0) {
            user.amountToken = 0; //1e-18 dust
            user.timestamp = 0;
        }
        user.underlyingRatio = _getRatio(
            user.amountfToken,
            user.amountToken,
            18
        );

        if (fee > 0) {
            uint256 feeToken = _calculateFee(results.totalToken);
            results.totalToken = results.totalToken.sub(feeToken);

            swapPath[0] = token;
            swapPath[1] = weth;

            uint256 feeTokenInEth =
                _swapTokenToEth(
                    swapPath,
                    feeToken,
                    deadline,
                    slippage,
                    ethPerToken
                );

            safeTransferETH(feeAddress, feeTokenInEth);
            user.userCollectedFees = user.userCollectedFees.add(feeTokenInEth);
        }

        IERC20(token).safeTransfer(msg.sender, results.totalToken);

        safeTransferETH(treasuryAddress, results.auctionedEth);
        user.userTreasuryEth = user.userTreasuryEth.add(results.auctionedEth);

        emit Withdraw(
            msg.sender,
            tx.origin,
            results.obtainedToken,
            results.obtainedfToken,
            results.auctionedEth
        );

        if (address(this).balance > results.prevDustEthBalance) {
            ethDust = ethDust.add(
                address(this).balance.sub(results.prevDustEthBalance)
            );
        }

        return results.totalToken;
    }
}