
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;

library Strings {

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

}// GPL-3.0

pragma solidity ^0.8.7;



abstract contract AccessControl is Context, IAccessControl {
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
        _checkRole(role, _msgSender());
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
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
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
        require(account == _msgSender(), "71");

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
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) internal {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
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

}

interface IPerpetualManagerFrontWithClaim is IPerpetualManagerFront, IPerpetualManager {

    function getReward(uint256 perpetualID) external;

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




contract FeeManagerEvents {

    event UserAndSLPFeesUpdated(
        uint256 _collatRatio,
        uint64 _bonusMalusMint,
        uint64 _bonusMalusBurn,
        uint64 _slippage,
        uint64 _slippageFee
    );

    event FeeMintUpdated(uint256[] _xBonusMalusMint, uint64[] _yBonusMalusMint);

    event FeeBurnUpdated(uint256[] _xBonusMalusBurn, uint64[] _yBonusMalusBurn);

    event SlippageUpdated(uint256[] _xSlippage, uint64[] _ySlippage);

    event SlippageFeeUpdated(uint256[] _xSlippageFee, uint64[] _ySlippageFee);

    event HaFeesUpdated(uint64 _haFeeDeposit, uint64 _haFeeWithdraw);
}// GPL-3.0

pragma solidity ^0.8.7;


contract FeeManagerStorage is FeeManagerEvents {

    uint64 public constant BASE_PARAMS_CASTED = 10**9;

    IStableMaster public stableMaster;

    IPerpetualManager public perpetualManager;


    uint256[] public xBonusMalusMint;
    uint64[] public yBonusMalusMint;
    uint256[] public xBonusMalusBurn;
    uint64[] public yBonusMalusBurn;

    uint256[] public xSlippage;
    uint64[] public ySlippage;
    uint256[] public xSlippageFee;
    uint64[] public ySlippageFee;

    uint64 public haFeeDeposit;
    uint64 public haFeeWithdraw;
}// GPL-3.0

pragma solidity ^0.8.7;


contract FeeManager is FeeManagerStorage, IFeeManagerFunctions, AccessControl, Initializable {

    bytes32 public constant POOLMANAGER_ROLE = keccak256("POOLMANAGER_ROLE");
    bytes32 public constant GUARDIAN_ROLE = keccak256("GUARDIAN_ROLE");

    constructor(IPoolManager _poolManager) {
        stableMaster = IStableMaster(_poolManager.stableMaster());
        _setupRole(POOLMANAGER_ROLE, address(_poolManager));

        _setRoleAdmin(POOLMANAGER_ROLE, POOLMANAGER_ROLE);
        _setRoleAdmin(GUARDIAN_ROLE, POOLMANAGER_ROLE);
    }

    function deployCollateral(
        address[] memory governorList,
        address guardian,
        address _perpetualManager
    ) external override onlyRole(POOLMANAGER_ROLE) initializer {

        for (uint256 i = 0; i < governorList.length; i++) {
            _grantRole(GUARDIAN_ROLE, governorList[i]);
        }
        _grantRole(GUARDIAN_ROLE, guardian);
        perpetualManager = IPerpetualManager(_perpetualManager);
    }


    function updateUsersSLP() external override {

        uint256 collatRatio = stableMaster.getCollateralRatio();
        uint64 bonusMalusMint = _piecewiseLinearCollatRatio(collatRatio, xBonusMalusMint, yBonusMalusMint);
        uint64 bonusMalusBurn = _piecewiseLinearCollatRatio(collatRatio, xBonusMalusBurn, yBonusMalusBurn);
        uint64 slippage = _piecewiseLinearCollatRatio(collatRatio, xSlippage, ySlippage);
        uint64 slippageFee = _piecewiseLinearCollatRatio(collatRatio, xSlippageFee, ySlippageFee);

        emit UserAndSLPFeesUpdated(collatRatio, bonusMalusMint, bonusMalusBurn, slippage, slippageFee);
        stableMaster.setFeeKeeper(bonusMalusMint, bonusMalusBurn, slippage, slippageFee);
    }


    function updateHA() external override {

        emit HaFeesUpdated(haFeeDeposit, haFeeWithdraw);
        perpetualManager.setFeeKeeper(haFeeDeposit, haFeeWithdraw);
    }


    function setFees(
        uint256[] memory xArray,
        uint64[] memory yArray,
        uint8 typeChange
    ) external override onlyRole(GUARDIAN_ROLE) {

        require(xArray.length == yArray.length && yArray.length > 0, "5");
        for (uint256 i = 0; i <= yArray.length - 1; i++) {
            if (i > 0) {
                require(xArray[i] > xArray[i - 1], "7");
            }
        }
        if (typeChange == 1) {
            xBonusMalusMint = xArray;
            yBonusMalusMint = yArray;
            emit FeeMintUpdated(xBonusMalusMint, yBonusMalusMint);
        } else if (typeChange == 2) {
            xBonusMalusBurn = xArray;
            yBonusMalusBurn = yArray;
            emit FeeBurnUpdated(xBonusMalusBurn, yBonusMalusBurn);
        } else if (typeChange == 3) {
            xSlippage = xArray;
            ySlippage = yArray;
            _checkSlippageCompatibility();
            emit SlippageUpdated(xSlippage, ySlippage);
        } else {
            xSlippageFee = xArray;
            ySlippageFee = yArray;
            _checkSlippageCompatibility();
            emit SlippageFeeUpdated(xSlippageFee, ySlippageFee);
        }
    }

    function setHAFees(uint64 _haFeeDeposit, uint64 _haFeeWithdraw) external override onlyRole(GUARDIAN_ROLE) {

        haFeeDeposit = _haFeeDeposit;
        haFeeWithdraw = _haFeeWithdraw;
    }

    function _checkSlippageCompatibility() internal view {

        if (xSlippage.length >= 1 && xSlippageFee.length >= 1) {
            for (uint256 i = 0; i <= ySlippageFee.length - 1; i++) {
                if (ySlippageFee[i] > 0) {
                    require(ySlippageFee[i] <= BASE_PARAMS_CASTED, "37");
                    require(_piecewiseLinearCollatRatio(xSlippageFee[i], xSlippage, ySlippage) > 0, "38");
                }
            }
        }
    }

    function _piecewiseLinearCollatRatio(
        uint256 x,
        uint256[] storage xArray,
        uint64[] storage yArray
    ) internal view returns (uint64 y) {

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
            uint256 yCasted;
            if (yArray[upper] > yArray[lower]) {
                yCasted =
                    yArray[lower] +
                    ((yArray[upper] - yArray[lower]) * (x - xArray[lower])) /
                    (xArray[upper] - xArray[lower]);
            } else {
                yCasted =
                    yArray[lower] -
                    ((yArray[lower] - yArray[upper]) * (x - xArray[lower])) /
                    (xArray[upper] - xArray[lower]);
            }
            y = uint64(yCasted);
        }
    }
}