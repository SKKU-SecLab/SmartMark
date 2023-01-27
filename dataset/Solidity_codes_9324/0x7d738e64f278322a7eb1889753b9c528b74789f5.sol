
pragma solidity ^0.8.0;

interface IERC20Upgradeable {

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


interface IERC20MetadataUpgradeable is IERC20Upgradeable {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

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


contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable, IERC20MetadataUpgradeable {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    function __ERC20_init(string memory name_, string memory symbol_) internal onlyInitializing {

        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {

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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    uint256[45] private __gap;
}// MIT

pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

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
pragma solidity 0.8.10;


interface IERC20WithDecimals is IERC20 {

    function decimals() external view returns (uint256);

}// MIT
pragma solidity 0.8.10;

interface IProtocolConfig {

    function protocolFee() external view returns (uint256);


    function protocolAddress() external view returns (address);

}// MIT
pragma solidity 0.8.10;


interface IPortfolio is IERC20Upgradeable {

    function endDate() external view returns (uint256);


    function underlyingToken() external view returns (IERC20WithDecimals);


    function value() external view returns (uint256);


    function deposit(uint256 amount, bytes memory metadata) external;


    function withdraw(uint256 amount, bytes memory metadata) external returns (uint256 withdrawnAmount);

}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

}// MIT
pragma solidity 0.8.10;


interface IFinancialInstrument is IERC721 {

    function principal(uint256 instrumentId) external view returns (uint256);


    function underlyingToken(uint256 instrumentId) external view returns (IERC20);


    function recipient(uint256 instrumentId) external view returns (address);

}// MIT
pragma solidity 0.8.10;


interface IDebtInstrument is IFinancialInstrument {

    function endDate(uint256 instrumentId) external view returns (uint256);


    function repay(uint256 instrumentId, uint256 amount) external;

}// MIT
pragma solidity 0.8.10;


enum BulletLoanStatus {
    Issued,
    FullyRepaid,
    Defaulted,
    Resolved
}

interface IBulletLoans is IDebtInstrument {

    struct LoanMetadata {
        IERC20 underlyingToken;
        BulletLoanStatus status;
        uint256 principal;
        uint256 totalDebt;
        uint256 amountRepaid;
        uint256 duration;
        uint256 repaymentDate;
        address recipient;
    }

    function loans(uint256 id)
        external
        view
        returns (
            IERC20,
            BulletLoanStatus,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            address
        );


    function createLoan(
        IERC20 _underlyingToken,
        uint256 principal,
        uint256 totalDebt,
        uint256 duration,
        address recipient
    ) external returns (uint256);


    function markLoanAsDefaulted(uint256 instrumentId) external;


    function markLoanAsResolved(uint256 instrumentId) external;


    function updateLoanParameters(
        uint256 instrumentId,
        uint256 newTotalDebt,
        uint256 newRepaymentDate
    ) external;


    function updateLoanParameters(
        uint256 instrumentId,
        uint256 newTotalDebt,
        uint256 newRepaymentDate,
        bytes memory borrowerSignature
    ) external;

}// MIT
pragma solidity 0.8.10;

interface ILenderVerifier {

    function isAllowed(
        address lender,
        uint256 amount,
        bytes memory signature
    ) external view returns (bool);

}// MIT
pragma solidity 0.8.10;


enum ManagedPortfolioStatus {
    Open,
    Frozen,
    Closed
}

interface IManagedPortfolio is IPortfolio {

    function initialize(
        string memory __name,
        string memory __symbol,
        address _manager,
        IERC20WithDecimals _underlyingToken,
        IBulletLoans _bulletLoans,
        IProtocolConfig _protocolConfig,
        ILenderVerifier _lenderVerifier,
        uint256 _duration,
        uint256 _maxSize,
        uint256 _managerFee
    ) external;


    function managerFee() external view returns (uint256);


    function maxSize() external view returns (uint256);


    function createBulletLoan(
        uint256 loanDuration,
        address borrower,
        uint256 principalAmount,
        uint256 repaymentAmount
    ) external;


    function setEndDate(uint256 newEndDate) external;


    function markLoanAsDefaulted(uint256 instrumentId) external;


    function getStatus() external view returns (ManagedPortfolioStatus);


    function getOpenLoanIds() external view returns (uint256[] memory);

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

    function _upgradeToAndCallSecure(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        address oldImplementation = _getImplementation();

        _setImplementation(newImplementation);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(newImplementation, data);
        }

        StorageSlot.BooleanSlot storage rollbackTesting = StorageSlot.getBooleanSlot(_ROLLBACK_SLOT);
        if (!rollbackTesting.value) {
            rollbackTesting.value = true;
            Address.functionDelegateCall(
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


abstract contract UUPSUpgradeable is ERC1967Upgrade {
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
}// MIT
pragma solidity 0.8.10;

interface IManageable {

    function manager() external view returns (address);

}// MIT
pragma solidity 0.8.10;


contract Manageable is IManageable {

    address public manager;
    address public pendingManager;

    event ManagementTransferred(address indexed oldManager, address indexed newManager);

    modifier onlyManager() {

        require(manager == msg.sender, "Manageable: Caller is not the manager");
        _;
    }

    constructor(address _manager) {
        _setManager(_manager);
    }

    function transferManagement(address newManager) external onlyManager {

        pendingManager = newManager;
    }

    function claimManagement() external {

        require(pendingManager == msg.sender, "Manageable: Caller is not the pending manager");
        _setManager(pendingManager);
        pendingManager = address(0);
    }

    function _setManager(address newManager) internal {

        address oldManager = manager;
        manager = newManager;
        emit ManagementTransferred(oldManager, newManager);
    }
}// MIT
pragma solidity 0.8.10;


abstract contract InitializableManageable is UUPSUpgradeable, Manageable, Initializable {
    constructor(address _manager) Manageable(_manager) initializer {}

    function initialize(address _manager) internal initializer {
        _setManager(_manager);
    }

    function _authorizeUpgrade(address) internal override onlyManager {}
}// MIT
pragma solidity 0.8.10;


contract ManagedPortfolio is ERC20Upgradeable, InitializableManageable, IERC721Receiver, IManagedPortfolio {

    using SafeERC20 for IERC20WithDecimals;

    uint256 internal constant YEAR = 365 days;
    uint256 public constant MAX_LOANS_NUMBER = 100;

    uint256[] private _loans;

    IERC20WithDecimals public underlyingToken;
    IBulletLoans public bulletLoans;
    IProtocolConfig public protocolConfig;
    ILenderVerifier public lenderVerifier;

    uint256 public endDate;
    uint256 public maxSize;
    uint256 public totalDeposited;
    uint256 public latestRepaymentDate;
    uint256 public defaultedLoansCount;
    uint256 public managerFee;

    event Deposited(address indexed lender, uint256 amount);

    event Withdrawn(address indexed lender, uint256 sharesAmount, uint256 receivedAmount);

    event BulletLoanCreated(uint256 id, uint256 loanDuration, address borrower, uint256 principalAmount, uint256 repaymentAmount);

    event BulletLoanDefaulted(uint256 id);

    event ManagerFeeChanged(uint256 newManagerFee);

    event MaxSizeChanged(uint256 newMaxSize);

    event EndDateChanged(uint256 newEndDate);

    event LenderVerifierChanged(ILenderVerifier newLenderVerifier);

    modifier onlyOpened() {

        require(getStatus() == ManagedPortfolioStatus.Open, "ManagedPortfolio: Portfolio is not opened");
        _;
    }

    modifier onlyClosed() {

        require(getStatus() == ManagedPortfolioStatus.Closed, "ManagedPortfolio: Portfolio is not closed");
        _;
    }

    constructor() InitializableManageable(msg.sender) {}

    function initialize(
        string memory _name,
        string memory _symbol,
        address _manager,
        IERC20WithDecimals _underlyingToken,
        IBulletLoans _bulletLoans,
        IProtocolConfig _protocolConfig,
        ILenderVerifier _lenderVerifier,
        uint256 _duration,
        uint256 _maxSize,
        uint256 _managerFee
    ) external initializer {

        InitializableManageable.initialize(_manager);
        ERC20Upgradeable.__ERC20_init(_name, _symbol);
        underlyingToken = _underlyingToken;
        bulletLoans = _bulletLoans;
        protocolConfig = _protocolConfig;
        lenderVerifier = _lenderVerifier;
        endDate = block.timestamp + _duration;
        maxSize = _maxSize;
        managerFee = _managerFee;
    }

    function deposit(uint256 depositAmount, bytes memory metadata) external onlyOpened {

        require(lenderVerifier.isAllowed(msg.sender, depositAmount, metadata), "ManagedPortfolio: Lender is not allowed to deposit");
        require(depositAmount >= 10**underlyingToken.decimals(), "ManagedPortfolio: Deposit amount is too small");
        totalDeposited += depositAmount;
        require(totalDeposited <= maxSize, "ManagedPortfolio: Portfolio is full");

        _mint(msg.sender, getAmountToMint(depositAmount));
        underlyingToken.safeTransferFrom(msg.sender, address(this), depositAmount);

        emit Deposited(msg.sender, depositAmount);
    }

    function withdraw(uint256 sharesAmount, bytes memory) external onlyClosed returns (uint256) {

        uint256 liquidFunds = underlyingToken.balanceOf(address(this));
        uint256 amountToWithdraw = (sharesAmount * liquidFunds) / totalSupply();
        _burn(msg.sender, sharesAmount);
        underlyingToken.safeTransfer(msg.sender, amountToWithdraw);

        emit Withdrawn(msg.sender, sharesAmount, amountToWithdraw);

        return amountToWithdraw;
    }

    function createBulletLoan(
        uint256 loanDuration,
        address borrower,
        uint256 principalAmount,
        uint256 repaymentAmount
    ) external onlyManager {

        require(getStatus() != ManagedPortfolioStatus.Closed, "ManagedPortfolio: Cannot create loan when Portfolio is closed");
        require(_loans.length < MAX_LOANS_NUMBER, "ManagedPortfolio: Maximum loans number has been reached");
        uint256 repaymentDate = block.timestamp + loanDuration;
        _onLoanRepaymentDateChange(repaymentDate);
        uint256 protocolFee = protocolConfig.protocolFee();
        uint256 managersPart = (managerFee * principalAmount * loanDuration) / YEAR / 10000;
        uint256 protocolsPart = (protocolFee * principalAmount * loanDuration) / YEAR / 10000;
        uint256 loanId = bulletLoans.createLoan(underlyingToken, principalAmount, repaymentAmount, loanDuration, borrower);
        _loans.push(loanId);

        underlyingToken.safeTransfer(borrower, principalAmount);
        underlyingToken.safeTransfer(manager, managersPart);
        underlyingToken.safeTransfer(protocolConfig.protocolAddress(), protocolsPart);

        emit BulletLoanCreated(loanId, loanDuration, borrower, principalAmount, repaymentAmount);
    }

    function setManagerFee(uint256 _managerFee) external onlyManager {

        managerFee = _managerFee;
        emit ManagerFeeChanged(_managerFee);
    }

    function setLenderVerifier(ILenderVerifier _lenderVerifier) external onlyManager {

        lenderVerifier = _lenderVerifier;
        emit LenderVerifierChanged(_lenderVerifier);
    }

    function setMaxSize(uint256 _maxSize) external onlyManager {

        maxSize = _maxSize;
        emit MaxSizeChanged(_maxSize);
    }

    function setEndDate(uint256 newEndDate) external onlyManager {

        require(newEndDate < endDate, "ManagedPortfolio: End date can only be decreased");
        require(newEndDate >= latestRepaymentDate, "ManagedPortfolio: End date cannot be less than max loan default date");
        endDate = newEndDate;
        emit EndDateChanged(newEndDate);
    }

    function value() public view returns (uint256) {

        return liquidValue() + illiquidValue();
    }

    function getStatus() public view returns (ManagedPortfolioStatus) {

        if (block.timestamp > endDate) {
            return ManagedPortfolioStatus.Closed;
        }
        if (defaultedLoansCount > 0) {
            return ManagedPortfolioStatus.Frozen;
        }
        return ManagedPortfolioStatus.Open;
    }

    function getAmountToMint(uint256 amount) public view returns (uint256) {

        uint256 _totalSupply = totalSupply();
        if (_totalSupply == 0) {
            return (amount * 10**decimals()) / (10**underlyingToken.decimals());
        } else {
            return (amount * _totalSupply) / value();
        }
    }

    function getOpenLoanIds() external view returns (uint256[] memory) {

        return _loans;
    }

    function illiquidValue() public view returns (uint256) {

        uint256 _value = 0;
        for (uint256 i = 0; i < _loans.length; i++) {
            (
                ,
                BulletLoanStatus status,
                uint256 principal,
                uint256 totalDebt,
                uint256 amountRepaid,
                uint256 duration,
                uint256 repaymentDate,

            ) = bulletLoans.loans(_loans[i]);
            if (status != BulletLoanStatus.Issued || amountRepaid >= totalDebt) {
                continue;
            }
            if (repaymentDate <= block.timestamp || totalDebt < principal) {
                _value += totalDebt - amountRepaid;
            } else {
                _value +=
                    ((totalDebt - principal) * (block.timestamp + duration - repaymentDate)) /
                    duration +
                    principal -
                    amountRepaid;
            }
        }
        return _value;
    }

    function liquidValue() public view returns (uint256) {

        return underlyingToken.balanceOf(address(this));
    }

    function markLoanAsDefaulted(uint256 instrumentId) external onlyManager {

        defaultedLoansCount++;
        bulletLoans.markLoanAsDefaulted(instrumentId);
        emit BulletLoanDefaulted(instrumentId);
    }

    function updateLoanParameters(
        uint256 instrumentId,
        uint256 newTotalDebt,
        uint256 newRepaymentDate
    ) external onlyManager {

        _onLoanRepaymentDateChange(newRepaymentDate);
        bulletLoans.updateLoanParameters(instrumentId, newTotalDebt, newRepaymentDate);
    }

    function updateLoanParameters(
        uint256 instrumentId,
        uint256 newTotalDebt,
        uint256 newRepaymentDate,
        bytes memory borrowerSignature
    ) external onlyManager {

        _onLoanRepaymentDateChange(newRepaymentDate);
        bulletLoans.updateLoanParameters(instrumentId, newTotalDebt, newRepaymentDate, borrowerSignature);
    }

    function markLoanAsResolved(uint256 instrumentId) external onlyManager {

        defaultedLoansCount--;
        bulletLoans.markLoanAsResolved(instrumentId);
    }

    function _onLoanRepaymentDateChange(uint256 newRepaymentDate) private {

        require(newRepaymentDate <= endDate, "ManagedPortfolio: Loan end date is greater than Portfolio end date");
        if (newRepaymentDate > latestRepaymentDate) {
            latestRepaymentDate = newRepaymentDate;
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256
    ) internal virtual override {

        require(from == address(0) || to == address(0), "ManagedPortfolio: transfer of LP tokens prohibited");
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {

        return IERC721Receiver.onERC721Received.selector;
    }
}