
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

}// MIT

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



contract CoreEvents {

    event StableMasterDeployed(address indexed _stableMaster, address indexed _agToken);

    event StableMasterRevoked(address indexed _stableMaster);

    event GovernorRoleGranted(address indexed governor);

    event GovernorRoleRevoked(address indexed governor);

    event GuardianRoleChanged(address indexed oldGuardian, address indexed newGuardian);

    event CoreChanged(address indexed newCore);
}// GPL-3.0

pragma solidity ^0.8.7;


contract Core is CoreEvents, ICore {

    mapping(address => bool) public governorMap;

    mapping(address => bool) public deployedStableMasterMap;

    address public override guardian;

    address[] internal _stablecoinList;

    address[] internal _governorList;

    modifier onlyGovernor() {

        require(governorMap[msg.sender], "1");
        _;
    }

    modifier onlyGuardian() {

        require(governorMap[msg.sender] || msg.sender == guardian, "1");
        _;
    }

    modifier zeroCheck(address newAddress) {

        require(newAddress != address(0), "0");
        _;
    }


    constructor(address _governor, address _guardian) {
        require(_guardian != address(0) && _governor != address(0), "0");
        require(_guardian != _governor, "39");
        _governorList.push(_governor);
        guardian = _guardian;
        governorMap[_governor] = true;

        emit GovernorRoleGranted(_governor);
        emit GuardianRoleChanged(address(0), _guardian);
    }



    function setCore(ICore newCore) external onlyGovernor zeroCheck(address(newCore)) {

        require(address(this) != address(newCore), "40");
        require(guardian == newCore.guardian(), "41");
        uint256 governorListLength = _governorList.length;
        address[] memory _newCoreGovernorList = newCore.governorList();
        uint256 stablecoinListLength = _stablecoinList.length;
        address[] memory _newStablecoinList = newCore.stablecoinList();
        require(
            governorListLength == _newCoreGovernorList.length && stablecoinListLength == _newStablecoinList.length,
            "42"
        );
        uint256 indexMet;
        for (uint256 i = 0; i < governorListLength; i++) {
            if (!governorMap[_newCoreGovernorList[i]]) {
                indexMet = 1;
                break;
            }
        }
        for (uint256 i = 0; i < stablecoinListLength; i++) {
            if (_stablecoinList[i] != _newStablecoinList[i]) {
                indexMet = 1;
                break;
            }
        }
        require(indexMet == 0, "43");
        for (uint256 i = 0; i < stablecoinListLength; i++) {
            IStableMaster(_stablecoinList[i]).setCore(address(newCore));
        }
        emit CoreChanged(address(newCore));
    }

    function deployStableMaster(address agToken) external onlyGovernor zeroCheck(agToken) {

        address stableMaster = IAgToken(agToken).stableMaster();
        require(!deployedStableMasterMap[stableMaster], "44");

        _stablecoinList.push(stableMaster);
        deployedStableMasterMap[stableMaster] = true;

        IStableMaster(stableMaster).deploy(_governorList, guardian, agToken);

        emit StableMasterDeployed(address(stableMaster), agToken);
    }

    function revokeStableMaster(address stableMaster) external override onlyGovernor {

        uint256 stablecoinListLength = _stablecoinList.length;
        require(stablecoinListLength >= 1, "45");
        uint256 indexMet;
        for (uint256 i = 0; i < stablecoinListLength - 1; i++) {
            if (_stablecoinList[i] == stableMaster) {
                indexMet = 1;
                _stablecoinList[i] = _stablecoinList[stablecoinListLength - 1];
                break;
            }
        }
        require(indexMet == 1 || _stablecoinList[stablecoinListLength - 1] == stableMaster, "45");
        _stablecoinList.pop();
        emit StableMasterRevoked(stableMaster);
    }


    function addGovernor(address _governor) external override onlyGovernor zeroCheck(_governor) {

        require(!governorMap[_governor], "46");
        governorMap[_governor] = true;
        _governorList.push(_governor);
        for (uint256 i = 0; i < _stablecoinList.length; i++) {
            IStableMaster(_stablecoinList[i]).addGovernor(_governor);
        }

        emit GovernorRoleGranted(_governor);
    }

    function removeGovernor(address _governor) external override onlyGovernor {

        uint256 governorListLength = _governorList.length;
        require(governorListLength > 1, "47");
        uint256 indexMet;
        for (uint256 i = 0; i < governorListLength - 1; i++) {
            if (_governorList[i] == _governor) {
                indexMet = 1;
                _governorList[i] = _governorList[governorListLength - 1];
                break;
            }
        }
        require(indexMet == 1 || _governorList[governorListLength - 1] == _governor, "48");
        _governorList.pop();
        delete governorMap[_governor];
        for (uint256 i = 0; i < _stablecoinList.length; i++) {
            IStableMaster(_stablecoinList[i]).removeGovernor(_governor);
        }

        emit GovernorRoleRevoked(_governor);
    }


    function setGuardian(address _newGuardian) external override onlyGuardian zeroCheck(_newGuardian) {

        require(!governorMap[_newGuardian], "39");
        require(guardian != _newGuardian, "49");
        address oldGuardian = guardian;
        guardian = _newGuardian;
        for (uint256 i = 0; i < _stablecoinList.length; i++) {
            IStableMaster(_stablecoinList[i]).setGuardian(_newGuardian, oldGuardian);
        }
        emit GuardianRoleChanged(oldGuardian, _newGuardian);
    }

    function revokeGuardian() external override onlyGuardian {

        address oldGuardian = guardian;
        guardian = address(0);
        for (uint256 i = 0; i < _stablecoinList.length; i++) {
            IStableMaster(_stablecoinList[i]).revokeGuardian(oldGuardian);
        }
        emit GuardianRoleChanged(oldGuardian, address(0));
    }


    function governorList() external view override returns (address[] memory) {

        return _governorList;
    }

    function stablecoinList() external view override returns (address[] memory) {

        return _stablecoinList;
    }
}