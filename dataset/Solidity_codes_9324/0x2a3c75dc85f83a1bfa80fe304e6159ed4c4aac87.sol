
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

struct PoolParameters {
    uint64[] xFeeMint;
    uint64[] yFeeMint;
    uint64[] xFeeBurn;
    uint64[] yFeeBurn;
    uint64[] xHAFeesDeposit;
    uint64[] yHAFeesDeposit;
    uint64[] xHAFeesWithdraw;
    uint64[] yHAFeesWithdraw;
    uint256[] xSlippageFee;
    uint64[] ySlippageFee;
    uint256[] xSlippage;
    uint64[] ySlippage;
    uint256[] xBonusMalusMint;
    uint64[] yBonusMalusMint;
    uint256[] xBonusMalusBurn;
    uint64[] yBonusMalusBurn;
    uint64[] xKeeperFeesClosing;
    uint64[] yKeeperFeesClosing;
    uint64 haFeeDeposit;
    uint64 haFeeWithdraw;
    uint256 capOnStableMinted;
    uint256 maxInterestsDistributed;
    uint64 feesForSLPs;
    uint64 interestsForSLPs;
    uint64 targetHAHedge;
    uint64 limitHAHedge;
    uint64 maxLeverage;
    uint64 maintenanceMargin;
    uint64 lockTime;
    uint64 keeperFeesLiquidationRatio;
    uint256 keeperFeesLiquidationCap;
    uint256 keeperFeesClosingCap;
}

contract OrchestratorOwnable {

    address public owner;

    constructor(address _owner) {
        owner = _owner;
    }

    function setOwner(address _newOwner) external {

        require(msg.sender == owner, "79");
        owner = _newOwner;
    }


    function initCollateral(
        IStableMaster stableMaster,
        IPoolManager poolManager,
        IPerpetualManager perpetualManager,
        IFeeManager feeManager,
        PoolParameters memory p
    ) external {

        require(msg.sender == owner, "79");
        stableMaster.setUserFees(poolManager, p.xFeeMint, p.yFeeMint, 1);
        stableMaster.setUserFees(poolManager, p.xFeeBurn, p.yFeeBurn, 0);

        perpetualManager.setHAFees(p.xHAFeesDeposit, p.yHAFeesDeposit, 1);
        perpetualManager.setHAFees(p.xHAFeesWithdraw, p.yHAFeesWithdraw, 0);

        feeManager.setFees(p.xSlippageFee, p.ySlippageFee, 0);
        feeManager.setFees(p.xBonusMalusMint, p.yBonusMalusMint, 1);
        feeManager.setFees(p.xBonusMalusBurn, p.yBonusMalusBurn, 2);
        feeManager.setFees(p.xSlippage, p.ySlippage, 3);

        feeManager.setHAFees(p.haFeeDeposit, p.haFeeWithdraw);

        stableMaster.setCapOnStableAndMaxInterests(p.capOnStableMinted, p.maxInterestsDistributed, poolManager);
        stableMaster.setIncentivesForSLPs(p.feesForSLPs, p.interestsForSLPs, poolManager);

        perpetualManager.setTargetAndLimitHAHedge(p.targetHAHedge, p.limitHAHedge);
        perpetualManager.setBoundsPerpetual(p.maxLeverage, p.maintenanceMargin);
        perpetualManager.setLockTime(p.lockTime);
        perpetualManager.setKeeperFeesLiquidationRatio(p.keeperFeesLiquidationRatio);
        perpetualManager.setKeeperFeesCap(p.keeperFeesLiquidationCap, p.keeperFeesClosingCap);
        perpetualManager.setKeeperFeesClosing(p.xKeeperFeesClosing, p.yKeeperFeesClosing);

        feeManager.updateHA();
        feeManager.updateUsersSLP();

    }
}