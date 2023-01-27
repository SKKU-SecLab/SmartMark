
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


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

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


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
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

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}// GPL-3.0

pragma solidity ^0.8.7;

interface IAccessControl {
    function hasRole(bytes32 role, address account) external view returns (bool);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function grantRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function renounceRole(bytes32 role, address account) external;
}// MIT

pragma solidity ^0.8.7;



abstract contract AccessControlUpgradeable is Initializable, IAccessControl {
    function __AccessControl_init() internal initializer {
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {}

    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    modifier onlyRole(bytes32 role) {
        _checkRole(role, msg.sender);
        _;
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

    function grantRole(bytes32 role, address account) external override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) external override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) external override {
        require(account == msg.sender, "71");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal {
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) internal {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, msg.sender);
        }
    }

    function _revokeRole(bytes32 role, address account) internal {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, msg.sender);
        }
    }

    uint256[49] private __gap;
}// GPL-3.0

pragma solidity ^0.8.7;


interface IAgToken is IERC20Upgradeable {
    function mint(address account, uint256 amount) external;

    function burnFrom(
        uint256 amount,
        address burner,
        address sender
    ) external;

    function burnSelf(uint256 amount, address burner) external;


    function stableMaster() external view returns (address);
}// GPL-3.0

pragma solidity ^0.8.7;

interface ICollateralSettler {
    function triggerSettlement(
        uint256 _oracleValue,
        uint256 _sanRate,
        uint256 _stocksUsers
    ) external;
}// GPL-3.0

pragma solidity ^0.8.7;


interface IFeeManagerFunctions is IAccessControl {

    function updateUsersSLP() external;

    function updateHA() external;


    function deployCollateral(
        address[] memory governorList,
        address guardian,
        address _perpetualManager
    ) external;

    function setFees(
        uint256[] memory xArray,
        uint64[] memory yArray,
        uint8 typeChange
    ) external;

    function setHAFees(uint64 _haFeeDeposit, uint64 _haFeeWithdraw) external;
}

interface IFeeManager is IFeeManagerFunctions {
    function stableMaster() external view returns (address);

    function perpetualManager() external view returns (address);
}// GPL-3.0

pragma solidity ^0.8.7;


interface IERC721 is IERC165 {
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
}

interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);
}// GPL-3.0

pragma solidity ^0.8.7;

interface IOracle {
    function read() external view returns (uint256);

    function readAll() external view returns (uint256 lowerRate, uint256 upperRate);

    function readLower() external view returns (uint256);

    function readUpper() external view returns (uint256);

    function readQuote(uint256 baseAmount) external view returns (uint256);

    function readQuoteLower(uint256 baseAmount) external view returns (uint256);

    function inBase() external view returns (uint256);
}// GPL-3.0

pragma solidity ^0.8.7;


interface IPerpetualManagerFront is IERC721Metadata {
    function openPerpetual(
        address owner,
        uint256 amountBrought,
        uint256 amountCommitted,
        uint256 maxOracleRate,
        uint256 minNetMargin
    ) external returns (uint256 perpetualID);

    function closePerpetual(
        uint256 perpetualID,
        address to,
        uint256 minCashOutAmount
    ) external;

    function addToPerpetual(uint256 perpetualID, uint256 amount) external;

    function removeFromPerpetual(
        uint256 perpetualID,
        uint256 amount,
        address to
    ) external;

    function liquidatePerpetuals(uint256[] memory perpetualIDs) external;

    function forceClosePerpetuals(uint256[] memory perpetualIDs) external;


    function getCashOutAmount(uint256 perpetualID, uint256 rate) external view returns (uint256, uint256);

    function isApprovedOrOwner(address spender, uint256 perpetualID) external view returns (bool);
}

interface IPerpetualManagerFunctions is IAccessControl {

    function deployCollateral(
        address[] memory governorList,
        address guardian,
        IFeeManager feeManager,
        IOracle oracle_
    ) external;

    function setFeeManager(IFeeManager feeManager_) external;

    function setHAFees(
        uint64[] memory _xHAFees,
        uint64[] memory _yHAFees,
        uint8 deposit
    ) external;

    function setTargetAndLimitHAHedge(uint64 _targetHAHedge, uint64 _limitHAHedge) external;

    function setKeeperFeesLiquidationRatio(uint64 _keeperFeesLiquidationRatio) external;

    function setKeeperFeesCap(uint256 _keeperFeesLiquidationCap, uint256 _keeperFeesClosingCap) external;

    function setKeeperFeesClosing(uint64[] memory _xKeeperFeesClosing, uint64[] memory _yKeeperFeesClosing) external;

    function setLockTime(uint64 _lockTime) external;

    function setBoundsPerpetual(uint64 _maxLeverage, uint64 _maintenanceMargin) external;

    function pause() external;

    function unpause() external;


    function setFeeKeeper(uint64 feeDeposit, uint64 feesWithdraw) external;


    function setOracle(IOracle _oracle) external;
}

interface IPerpetualManager is IPerpetualManagerFunctions {
    function poolManager() external view returns (address);

    function oracle() external view returns (address);

    function targetHAHedge() external view returns (uint64);

    function totalHedgeAmount() external view returns (uint256);
}// GPL-3.0

pragma solidity ^0.8.7;


struct StrategyParams {
    uint256 lastReport;
    uint256 totalStrategyDebt;
    uint256 debtRatio;
}

interface IPoolManagerFunctions {

    function deployCollateral(
        address[] memory governorList,
        address guardian,
        IPerpetualManager _perpetualManager,
        IFeeManager feeManager,
        IOracle oracle
    ) external;


    function creditAvailable() external view returns (uint256);

    function debtOutstanding() external view returns (uint256);

    function report(
        uint256 _gain,
        uint256 _loss,
        uint256 _debtPayment
    ) external;


    function addGovernor(address _governor) external;

    function removeGovernor(address _governor) external;

    function setGuardian(address _guardian, address guardian) external;

    function revokeGuardian(address guardian) external;

    function setFeeManager(IFeeManager _feeManager) external;


    function getBalance() external view returns (uint256);

    function getTotalAsset() external view returns (uint256);
}

interface IPoolManager is IPoolManagerFunctions {
    function stableMaster() external view returns (address);

    function perpetualManager() external view returns (address);

    function token() external view returns (address);

    function feeManager() external view returns (address);

    function totalDebt() external view returns (uint256);

    function strategies(address _strategy) external view returns (StrategyParams memory);
}// GPL-3.0

pragma solidity ^0.8.7;


interface ISanToken is IERC20Upgradeable {

    function mint(address account, uint256 amount) external;

    function burnFrom(
        uint256 amount,
        address burner,
        address sender
    ) external;

    function burnSelf(uint256 amount, address burner) external;

    function stableMaster() external view returns (address);

    function poolManager() external view returns (address);
}// GPL-3.0

pragma solidity ^0.8.7;



struct MintBurnData {
    uint64[] xFeeMint;
    uint64[] yFeeMint;
    uint64[] xFeeBurn;
    uint64[] yFeeBurn;
    uint64 targetHAHedge;
    uint64 bonusMalusMint;
    uint64 bonusMalusBurn;
    uint256 capOnStableMinted;
}

struct SLPData {
    uint256 lastBlockUpdated;
    uint256 lockedInterests;
    uint256 maxInterestsDistributed;
    uint256 feesAside;
    uint64 slippageFee;
    uint64 feesForSLPs;
    uint64 slippage;
    uint64 interestsForSLPs;
}

interface IStableMasterFunctions {
    function deploy(
        address[] memory _governorList,
        address _guardian,
        address _agToken
    ) external;


    function accumulateInterest(uint256 gain) external;

    function signalLoss(uint256 loss) external;


    function getStocksUsers() external view returns (uint256 maxCAmountInStable);

    function convertToSLP(uint256 amount, address user) external;


    function getCollateralRatio() external returns (uint256);

    function setFeeKeeper(
        uint64 feeMint,
        uint64 feeBurn,
        uint64 _slippage,
        uint64 _slippageFee
    ) external;


    function updateStocksUsers(uint256 amount, address poolManager) external;


    function setCore(address newCore) external;

    function addGovernor(address _governor) external;

    function removeGovernor(address _governor) external;

    function setGuardian(address newGuardian, address oldGuardian) external;

    function revokeGuardian(address oldGuardian) external;

    function setCapOnStableAndMaxInterests(
        uint256 _capOnStableMinted,
        uint256 _maxInterestsDistributed,
        IPoolManager poolManager
    ) external;

    function setIncentivesForSLPs(
        uint64 _feesForSLPs,
        uint64 _interestsForSLPs,
        IPoolManager poolManager
    ) external;

    function setUserFees(
        IPoolManager poolManager,
        uint64[] memory _xFee,
        uint64[] memory _yFee,
        uint8 _mint
    ) external;

    function setTargetHAHedge(uint64 _targetHAHedge) external;

    function pause(bytes32 agent, IPoolManager poolManager) external;

    function unpause(bytes32 agent, IPoolManager poolManager) external;
}

interface IStableMaster is IStableMasterFunctions {
    function agToken() external view returns (address);

    function collateralMap(IPoolManager poolManager)
        external
        view
        returns (
            IERC20 token,
            ISanToken sanToken,
            IPerpetualManager perpetualManager,
            IOracle oracle,
            uint256 stocksUsers,
            uint256 sanRate,
            uint256 collatBase,
            SLPData memory slpData,
            MintBurnData memory feeData
        );
}// GPL-3.0

pragma solidity ^0.8.7;


interface ICore {
    function revokeStableMaster(address stableMaster) external;

    function addGovernor(address _governor) external;

    function removeGovernor(address _governor) external;

    function setGuardian(address _guardian) external;

    function revokeGuardian() external;

    function governorList() external view returns (address[] memory);

    function stablecoinList() external view returns (address[] memory);

    function guardian() external view returns (address);
}// GPL-3.0

pragma solidity ^0.8.7;

contract FunctionUtils {
    uint256 public constant BASE_TOKENS = 10**18;
    uint256 public constant BASE_PARAMS = 10**9;

    function _piecewiseLinear(
        uint64 x,
        uint64[] memory xArray,
        uint64[] memory yArray
    ) internal pure returns (uint64) {
        if (x >= xArray[xArray.length - 1]) {
            return yArray[xArray.length - 1];
        } else if (x <= xArray[0]) {
            return yArray[0];
        } else {
            uint256 lower;
            uint256 upper = xArray.length - 1;
            uint256 mid;
            while (upper - lower > 1) {
                mid = lower + (upper - lower) / 2;
                if (xArray[mid] <= x) {
                    lower = mid;
                } else {
                    upper = mid;
                }
            }
            if (yArray[upper] > yArray[lower]) {
                return
                    yArray[lower] +
                    ((yArray[upper] - yArray[lower]) * (x - xArray[lower])) /
                    (xArray[upper] - xArray[lower]);
            } else {
                return
                    yArray[lower] -
                    ((yArray[lower] - yArray[upper]) * (x - xArray[lower])) /
                    (xArray[upper] - xArray[lower]);
            }
        }
    }

    modifier onlyCompatibleInputArrays(uint64[] memory xArray, uint64[] memory yArray) {
        require(xArray.length == yArray.length && xArray.length > 0, "5");
        for (uint256 i = 0; i <= yArray.length - 1; i++) {
            require(yArray[i] <= uint64(BASE_PARAMS) && xArray[i] <= uint64(BASE_PARAMS), "6");
            if (i > 0) {
                require(xArray[i] > xArray[i - 1], "7");
            }
        }
        _;
    }

    modifier onlyCompatibleFees(uint64 fees) {
        require(fees <= BASE_PARAMS, "4");
        _;
    }

    modifier zeroCheck(address newAddress) {
        require(newAddress != address(0), "0");
        _;
    }
}// MIT

pragma solidity ^0.8.7;

contract PausableMapUpgradeable {
    event Paused(bytes32 name);

    event Unpaused(bytes32 name);

    mapping(bytes32 => bool) public paused;

    function _pause(bytes32 name) internal {
        require(!paused[name], "18");
        paused[name] = true;
        emit Paused(name);
    }

    function _unpause(bytes32 name) internal {
        require(paused[name], "19");
        paused[name] = false;
        emit Unpaused(name);
    }
}// GPL-3.0

pragma solidity ^0.8.7;





contract StableMasterEvents {
    event SanRateUpdated(address indexed _token, uint256 _newSanRate);

    event StocksUsersUpdated(address indexed _poolManager, uint256 _stocksUsers);

    event MintedStablecoins(address indexed _poolManager, uint256 amount, uint256 amountForUserInStable);

    event BurntStablecoins(address indexed _poolManager, uint256 amount, uint256 redeemInC);


    event CollateralDeployed(
        address indexed _poolManager,
        address indexed _perpetualManager,
        address indexed _sanToken,
        address _oracle
    );

    event CollateralRevoked(address indexed _poolManager);


    event OracleUpdated(address indexed _poolManager, address indexed _oracle);

    event FeeManagerUpdated(address indexed _poolManager, address indexed newFeeManager);

    event CapOnStableAndMaxInterestsUpdated(
        address indexed _poolManager,
        uint256 _capOnStableMinted,
        uint256 _maxInterestsDistributed
    );

    event SLPsIncentivesUpdated(address indexed _poolManager, uint64 _feesForSLPs, uint64 _interestsForSLPs);

    event FeeArrayUpdated(address indexed _poolManager, uint64[] _xFee, uint64[] _yFee, uint8 _type);
}// GPL-3.0

pragma solidity ^0.8.7;


contract StableMasterStorage is StableMasterEvents, FunctionUtils {
    struct Collateral {
        IERC20 token;
        ISanToken sanToken;
        IPerpetualManager perpetualManager;
        IOracle oracle;
        uint256 stocksUsers;
        uint256 sanRate;
        uint256 collatBase;
        SLPData slpData;
        MintBurnData feeData;
    }


    mapping(IPoolManager => Collateral) public collateralMap;

    IAgToken public agToken;

    mapping(address => IPoolManager) internal _contractMap;

    IPoolManager[] internal _managerList;

    ICore internal _core;
}// GPL-3.0

pragma solidity ^0.8.7;


contract StableMasterInternal is StableMasterStorage, PausableMapUpgradeable {
    function _contractMapCheck(Collateral storage col) internal view {
        require(address(col.token) != address(0), "3");
    }

    function _whenNotPaused(bytes32 agent, address poolManager) internal view {
        require(!paused[keccak256(abi.encodePacked(agent, poolManager))], "18");
    }

    function _updateSanRate(uint256 toShare, Collateral storage col) internal {
        uint256 _lockedInterests = col.slpData.lockedInterests;
        if (block.timestamp != col.slpData.lastBlockUpdated && _lockedInterests > 0) {
            uint256 sanMint = col.sanToken.totalSupply();
            if (sanMint != 0) {
                if (_lockedInterests > col.slpData.maxInterestsDistributed) {
                    col.sanRate += (col.slpData.maxInterestsDistributed * BASE_TOKENS) / sanMint;
                    _lockedInterests -= col.slpData.maxInterestsDistributed;
                } else {
                    col.sanRate += (_lockedInterests * BASE_TOKENS) / sanMint;
                    _lockedInterests = 0;
                }
                emit SanRateUpdated(address(col.token), col.sanRate);
            } else {
                _lockedInterests = 0;
            }
        }
        if (toShare != 0) {
            if ((col.slpData.slippageFee == 0) && (col.slpData.feesAside != 0)) {
                toShare += col.slpData.feesAside;
                col.slpData.feesAside = 0;
            } else if (col.slpData.slippageFee != 0) {
                uint256 aside = (toShare * col.slpData.slippageFee) / BASE_PARAMS;
                toShare -= aside;
                col.slpData.feesAside += aside;
            }
            _lockedInterests += toShare;
        }
        col.slpData.lockedInterests = _lockedInterests;
        col.slpData.lastBlockUpdated = block.timestamp;
    }

    function _computeFeeMint(uint256 amount, Collateral storage col) internal view returns (uint256 feeMint) {
        uint64 feeMint64;
        if (col.feeData.xFeeMint.length == 1) {
            feeMint64 = col.feeData.yFeeMint[0];
        } else {
            uint64 hedgeRatio = _computeHedgeRatio(amount + col.stocksUsers, col);
            feeMint64 = _piecewiseLinear(hedgeRatio, col.feeData.xFeeMint, col.feeData.yFeeMint);
        }
        feeMint = (feeMint64 * col.feeData.bonusMalusMint) / BASE_PARAMS;
    }

    function _computeFeeBurn(uint256 amount, Collateral storage col) internal view returns (uint256 feeBurn) {
        uint64 feeBurn64;
        if (col.feeData.xFeeBurn.length == 1) {
            feeBurn64 = col.feeData.yFeeBurn[0];
        } else {
            uint64 hedgeRatio = _computeHedgeRatio(col.stocksUsers - amount, col);
            feeBurn64 = _piecewiseLinear(hedgeRatio, col.feeData.xFeeBurn, col.feeData.yFeeBurn);
        }
        feeBurn = (feeBurn64 * col.feeData.bonusMalusBurn) / BASE_PARAMS;
    }

    function _computeHedgeRatio(uint256 newStocksUsers, Collateral storage col) internal view returns (uint64 ratio) {
        uint256 totalHedgeAmount = col.perpetualManager.totalHedgeAmount();
        newStocksUsers = (col.feeData.targetHAHedge * newStocksUsers) / BASE_PARAMS;
        if (newStocksUsers > totalHedgeAmount) ratio = uint64((totalHedgeAmount * BASE_PARAMS) / newStocksUsers);
        else ratio = uint64(BASE_PARAMS);
    }
}// GPL-3.0

pragma solidity ^0.8.7;


contract StableMaster is StableMasterInternal, IStableMasterFunctions, AccessControlUpgradeable {
    using SafeERC20 for IERC20;

    bytes32 public constant GOVERNOR_ROLE = keccak256("GOVERNOR_ROLE");
    bytes32 public constant GUARDIAN_ROLE = keccak256("GUARDIAN_ROLE");
    bytes32 public constant CORE_ROLE = keccak256("CORE_ROLE");

    bytes32 public constant STABLE = keccak256("STABLE");
    bytes32 public constant SLP = keccak256("SLP");


    function deploy(
        address[] memory governorList,
        address guardian,
        address _agToken
    ) external override onlyRole(CORE_ROLE) {
        for (uint256 i = 0; i < governorList.length; i++) {
            _grantRole(GOVERNOR_ROLE, governorList[i]);
            _grantRole(GUARDIAN_ROLE, governorList[i]);
        }
        _grantRole(GUARDIAN_ROLE, guardian);
        agToken = IAgToken(_agToken);
    }


    function accumulateInterest(uint256 gain) external override {
        Collateral storage col = collateralMap[IPoolManager(msg.sender)];
        _contractMapCheck(col);
        _updateSanRate((gain * col.slpData.interestsForSLPs) / BASE_PARAMS, col);
    }

    function signalLoss(uint256 loss) external override {
        IPoolManager poolManager = IPoolManager(msg.sender);
        Collateral storage col = collateralMap[poolManager];
        _contractMapCheck(col);
        uint256 sanMint = col.sanToken.totalSupply();
        if (sanMint != 0) {
            if (col.sanRate * sanMint + col.slpData.lockedInterests * BASE_TOKENS > loss * BASE_TOKENS) {
                uint256 withdrawFromLoss = col.slpData.lockedInterests;

                if (withdrawFromLoss >= loss) {
                    withdrawFromLoss = loss;
                }

                col.slpData.lockedInterests -= withdrawFromLoss;
                col.sanRate -= ((loss - withdrawFromLoss) * BASE_TOKENS) / sanMint;
            } else {
                col.sanRate = 1;
                col.slpData.lockedInterests = 0;
                _pause(keccak256(abi.encodePacked(SLP, address(poolManager))));
            }
            emit SanRateUpdated(address(col.token), col.sanRate);
        }
    }


    function convertToSLP(uint256 amount, address user) external override {
        IPoolManager poolManager = _contractMap[msg.sender];
        Collateral storage col = collateralMap[poolManager];
        _contractMapCheck(col);
        _whenNotPaused(SLP, address(poolManager));
        _updateSanRate(0, col);
        col.sanToken.mint(user, (amount * BASE_TOKENS) / col.sanRate);
    }

    function setTargetHAHedge(uint64 _targetHAHedge) external override {
        IPoolManager poolManager = _contractMap[msg.sender];
        Collateral storage col = collateralMap[poolManager];
        _contractMapCheck(col);
        col.feeData.targetHAHedge = _targetHAHedge;
    }


    function getStocksUsers() external view override returns (uint256 _stocksUsers) {
        _stocksUsers = collateralMap[_contractMap[msg.sender]].stocksUsers;
    }

    function getCollateralRatio() external view override returns (uint256) {
        uint256 mints = agToken.totalSupply();
        if (mints == 0) {
            return type(uint256).max;
        }
        uint256 val;
        for (uint256 i = 0; i < _managerList.length; i++) {
            val += collateralMap[_managerList[i]].oracle.readQuote(_managerList[i].getTotalAsset());
        }
        return (val * BASE_PARAMS) / mints;
    }


    function setFeeKeeper(
        uint64 _bonusMalusMint,
        uint64 _bonusMalusBurn,
        uint64 _slippage,
        uint64 _slippageFee
    ) external override {
        Collateral storage col = collateralMap[_contractMap[msg.sender]];
        _contractMapCheck(col);

        col.feeData.bonusMalusMint = _bonusMalusMint;
        col.feeData.bonusMalusBurn = _bonusMalusBurn;
        col.slpData.slippage = _slippage;
        col.slpData.slippageFee = _slippageFee;
    }


    function updateStocksUsers(uint256 amount, address poolManager) external override {
        require(msg.sender == address(agToken), "3");
        Collateral storage col = collateralMap[IPoolManager(poolManager)];
        _contractMapCheck(col);
        require(col.stocksUsers >= amount, "4");
        col.stocksUsers -= amount;
        emit StocksUsersUpdated(address(col.token), col.stocksUsers);
    }



    function setCore(address newCore) external override onlyRole(CORE_ROLE) {
        _revokeRole(CORE_ROLE, address(_core));
        _grantRole(CORE_ROLE, newCore);
        _core = ICore(newCore);
    }

    function addGovernor(address governor) external override onlyRole(CORE_ROLE) {
        _grantRole(GOVERNOR_ROLE, governor);
        _grantRole(GUARDIAN_ROLE, governor);

        for (uint256 i = 0; i < _managerList.length; i++) {
            _managerList[i].addGovernor(governor);
        }
    }

    function removeGovernor(address governor) external override onlyRole(CORE_ROLE) {
        _revokeRole(GOVERNOR_ROLE, governor);
        _revokeRole(GUARDIAN_ROLE, governor);

        for (uint256 i = 0; i < _managerList.length; i++) {
            _managerList[i].removeGovernor(governor);
        }
    }

    function setGuardian(address newGuardian, address oldGuardian) external override onlyRole(CORE_ROLE) {
        _revokeRole(GUARDIAN_ROLE, oldGuardian);
        _grantRole(GUARDIAN_ROLE, newGuardian);

        for (uint256 i = 0; i < _managerList.length; i++) {
            _managerList[i].setGuardian(newGuardian, oldGuardian);
        }
    }

    function revokeGuardian(address oldGuardian) external override onlyRole(CORE_ROLE) {
        _revokeRole(GUARDIAN_ROLE, oldGuardian);
        for (uint256 i = 0; i < _managerList.length; i++) {
            _managerList[i].revokeGuardian(oldGuardian);
        }
    }


    function deployCollateral(
        IPoolManager poolManager,
        IPerpetualManager perpetualManager,
        IFeeManager feeManager,
        IOracle oracle,
        ISanToken sanToken
    ) external onlyRole(GOVERNOR_ROLE) {
        require(
            sanToken.stableMaster() == address(this) &&
                sanToken.poolManager() == address(poolManager) &&
                poolManager.stableMaster() == address(this) &&
                perpetualManager.poolManager() == address(poolManager) &&
                feeManager.stableMaster() == address(this),
            "9"
        );
        address token = poolManager.token();
        uint256 collatBase = 10**(IERC20Metadata(token).decimals());
        require(oracle.inBase() == collatBase, "11");
        Collateral storage col = collateralMap[poolManager];
        require(address(col.token) == address(0), "13");

        col.token = IERC20(token);
        col.sanToken = sanToken;
        col.perpetualManager = perpetualManager;
        col.oracle = oracle;
        col.sanRate = BASE_TOKENS;
        col.collatBase = collatBase;

        _contractMap[address(perpetualManager)] = poolManager;
        _contractMap[address(feeManager)] = poolManager;
        _managerList.push(poolManager);

        _pause(keccak256(abi.encodePacked(SLP, address(poolManager))));
        _pause(keccak256(abi.encodePacked(STABLE, address(poolManager))));

        address[] memory governorList = _core.governorList();
        address guardian = _core.guardian();

        poolManager.deployCollateral(governorList, guardian, perpetualManager, feeManager, oracle);
        emit CollateralDeployed(address(poolManager), address(perpetualManager), address(sanToken), address(oracle));
    }

    function revokeCollateral(IPoolManager poolManager, ICollateralSettler settlementContract)
        external
        onlyRole(GOVERNOR_ROLE)
    {
        uint256 indexMet;
        uint256 managerListLength = _managerList.length;
        require(managerListLength >= 1, "10");
        for (uint256 i = 0; i < managerListLength - 1; i++) {
            if (_managerList[i] == poolManager) {
                indexMet = 1;
                _managerList[i] = _managerList[managerListLength - 1];
                break;
            }
        }
        require(indexMet == 1 || _managerList[managerListLength - 1] == poolManager, "10");
        _managerList.pop();
        Collateral memory col = collateralMap[poolManager];

        delete _contractMap[poolManager.feeManager()];
        delete _contractMap[address(col.perpetualManager)];
        delete collateralMap[poolManager];
        emit CollateralRevoked(address(poolManager));

        col.perpetualManager.pause();

        uint256 balance = col.token.balanceOf(address(poolManager));
        col.token.safeTransferFrom(address(poolManager), address(settlementContract), balance);

        uint256 oracleValue = col.oracle.readLower();
        settlementContract.triggerSettlement(oracleValue, col.sanRate, col.stocksUsers);
    }


    function pause(bytes32 agent, IPoolManager poolManager) external override onlyRole(GUARDIAN_ROLE) {
        Collateral storage col = collateralMap[poolManager];
        _contractMapCheck(col);
        _pause(keccak256(abi.encodePacked(agent, address(poolManager))));
    }

    function unpause(bytes32 agent, IPoolManager poolManager) external override onlyRole(GUARDIAN_ROLE) {
        Collateral storage col = collateralMap[poolManager];
        _contractMapCheck(col);
        _unpause(keccak256(abi.encodePacked(agent, address(poolManager))));
    }

    function rebalanceStocksUsers(
        uint256 amount,
        IPoolManager poolManagerUp,
        IPoolManager poolManagerDown
    ) external onlyRole(GUARDIAN_ROLE) {
        Collateral storage colUp = collateralMap[poolManagerUp];
        Collateral storage colDown = collateralMap[poolManagerDown];
        _contractMapCheck(colUp);
        _contractMapCheck(colDown);
        require(colUp.stocksUsers + amount <= colUp.feeData.capOnStableMinted, "8");
        colDown.stocksUsers -= amount;
        colUp.stocksUsers += amount;
        emit StocksUsersUpdated(address(colUp.token), colUp.stocksUsers);
        emit StocksUsersUpdated(address(colDown.token), colDown.stocksUsers);
    }

    function setOracle(IOracle _oracle, IPoolManager poolManager)
        external
        onlyRole(GOVERNOR_ROLE)
        zeroCheck(address(_oracle))
    {
        Collateral storage col = collateralMap[poolManager];
        _contractMapCheck(col);
        require(col.oracle != _oracle, "12");
        require(col.collatBase == _oracle.inBase(), "11");
        col.oracle = _oracle;
        emit OracleUpdated(address(poolManager), address(_oracle));
        col.perpetualManager.setOracle(_oracle);
    }

    function setCapOnStableAndMaxInterests(
        uint256 _capOnStableMinted,
        uint256 _maxInterestsDistributed,
        IPoolManager poolManager
    ) external override onlyRole(GUARDIAN_ROLE) {
        Collateral storage col = collateralMap[poolManager];
        _contractMapCheck(col);
        require(_capOnStableMinted >= col.stocksUsers, "8");
        col.feeData.capOnStableMinted = _capOnStableMinted;
        col.slpData.maxInterestsDistributed = _maxInterestsDistributed;
        emit CapOnStableAndMaxInterestsUpdated(address(poolManager), _capOnStableMinted, _maxInterestsDistributed);
    }

    function setFeeManager(
        address newFeeManager,
        address oldFeeManager,
        IPoolManager poolManager
    ) external onlyRole(GUARDIAN_ROLE) zeroCheck(newFeeManager) {
        Collateral storage col = collateralMap[poolManager];
        _contractMapCheck(col);
        require(_contractMap[oldFeeManager] == poolManager, "10");
        require(newFeeManager != oldFeeManager, "14");
        delete _contractMap[oldFeeManager];
        _contractMap[newFeeManager] = poolManager;
        emit FeeManagerUpdated(address(poolManager), newFeeManager);
        poolManager.setFeeManager(IFeeManager(newFeeManager));
    }

    function setIncentivesForSLPs(
        uint64 _feesForSLPs,
        uint64 _interestsForSLPs,
        IPoolManager poolManager
    ) external override onlyRole(GUARDIAN_ROLE) onlyCompatibleFees(_feesForSLPs) onlyCompatibleFees(_interestsForSLPs) {
        Collateral storage col = collateralMap[poolManager];
        _contractMapCheck(col);
        col.slpData.feesForSLPs = _feesForSLPs;
        col.slpData.interestsForSLPs = _interestsForSLPs;
        emit SLPsIncentivesUpdated(address(poolManager), _feesForSLPs, _interestsForSLPs);
    }

    function setUserFees(
        IPoolManager poolManager,
        uint64[] memory _xFee,
        uint64[] memory _yFee,
        uint8 _mint
    ) external override onlyRole(GUARDIAN_ROLE) onlyCompatibleInputArrays(_xFee, _yFee) {
        Collateral storage col = collateralMap[poolManager];
        _contractMapCheck(col);
        if (_mint > 0) {
            col.feeData.xFeeMint = _xFee;
            col.feeData.yFeeMint = _yFee;
        } else {
            col.feeData.xFeeBurn = _xFee;
            col.feeData.yFeeBurn = _yFee;
        }
        emit FeeArrayUpdated(address(poolManager), _xFee, _yFee, _mint);
    }
}// GPL-3.0

pragma solidity ^0.8.7;


contract StableMasterFront is StableMaster {
    using SafeERC20 for IERC20;


    function initialize(address core_) external zeroCheck(core_) initializer {
        __AccessControl_init();
        _core = ICore(core_);
        _setupRole(CORE_ROLE, core_);
        _setRoleAdmin(CORE_ROLE, CORE_ROLE);
        _setRoleAdmin(GOVERNOR_ROLE, CORE_ROLE);
        _setRoleAdmin(GUARDIAN_ROLE, CORE_ROLE);
    }

    constructor() initializer {}


    function mint(
        uint256 amount,
        address user,
        IPoolManager poolManager,
        uint256 minStableAmount
    ) external {
        Collateral storage col = collateralMap[poolManager];
        _contractMapCheck(col);
        _whenNotPaused(STABLE, address(poolManager));

        col.token.safeTransferFrom(msg.sender, address(poolManager), amount);

        uint256 amountForUserInStable = col.oracle.readQuoteLower(amount);

        uint256 fees = _computeFeeMint(amountForUserInStable, col);

        amountForUserInStable = (amountForUserInStable * (BASE_PARAMS - fees)) / BASE_PARAMS;
        require(amountForUserInStable >= minStableAmount, "15");

        col.stocksUsers += amountForUserInStable;
        require(col.stocksUsers <= col.feeData.capOnStableMinted, "16");

        emit MintedStablecoins(address(poolManager), amount, amountForUserInStable);

        _updateSanRate((amount * fees * col.slpData.feesForSLPs) / (BASE_PARAMS**2), col);

        agToken.mint(user, amountForUserInStable);
    }

    function burn(
        uint256 amount,
        address burner,
        address dest,
        IPoolManager poolManager,
        uint256 minCollatAmount
    ) external {
        Collateral storage col = collateralMap[poolManager];
        _contractMapCheck(col);
        _whenNotPaused(STABLE, address(poolManager));

        require(amount <= col.stocksUsers, "17");

        if (burner == msg.sender) {
            agToken.burnSelf(amount, burner);
        } else {
            agToken.burnFrom(amount, burner, msg.sender);
        }

        uint256 oracleValue = col.oracle.readUpper();

        uint256 amountInC = (amount * col.collatBase) / oracleValue;

        uint256 redeemInC = (amount * (BASE_PARAMS - _computeFeeBurn(amount, col)) * col.collatBase) /
            (oracleValue * BASE_PARAMS);
        require(redeemInC >= minCollatAmount, "15");

        col.stocksUsers -= amount;

        emit BurntStablecoins(address(poolManager), amount, redeemInC);

        _updateSanRate(((amountInC - redeemInC) * col.slpData.feesForSLPs) / BASE_PARAMS, col);

        col.token.safeTransferFrom(address(poolManager), dest, redeemInC);
    }


    function deposit(
        uint256 amount,
        address user,
        IPoolManager poolManager
    ) external {
        Collateral storage col = collateralMap[poolManager];
        _contractMapCheck(col);
        _whenNotPaused(SLP, address(poolManager));
        _updateSanRate(0, col);

        col.token.safeTransferFrom(msg.sender, address(poolManager), amount);
        col.sanToken.mint(user, (amount * BASE_TOKENS) / col.sanRate);
    }

    function withdraw(
        uint256 amount,
        address burner,
        address dest,
        IPoolManager poolManager
    ) external {
        Collateral storage col = collateralMap[poolManager];
        _contractMapCheck(col);
        _whenNotPaused(SLP, address(poolManager));
        _updateSanRate(0, col);

        if (burner == msg.sender) {
            col.sanToken.burnSelf(amount, burner);
        } else {
            col.sanToken.burnFrom(amount, burner, msg.sender);
        }
        uint256 redeemInC = (amount * (BASE_PARAMS - col.slpData.slippage) * col.sanRate) / (BASE_TOKENS * BASE_PARAMS);

        col.token.safeTransferFrom(address(poolManager), dest, redeemInC);
    }
}