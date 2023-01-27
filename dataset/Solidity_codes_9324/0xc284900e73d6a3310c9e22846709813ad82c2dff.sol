
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
}// GPL-3.0

pragma solidity ^0.8.7;

interface IFeeDistributor {

    function burn(address token) external;

}

interface IFeeDistributorFront {

    function token() external returns (address);


    function claim(address _addr) external returns (uint256);


    function claim(address[20] memory _addr) external returns (bool);

}// GPL-3.0

pragma solidity ^0.8.7;

interface ILiquidityGauge {

    function staking_token() external returns (address stakingToken);


    function deposit_reward_token(address _rewardToken, uint256 _amount) external;


    function deposit(
        uint256 _value,
        address _addr,
        bool _claim_rewards
    ) external;


    function claim_rewards(address _addr) external;


    function claim_rewards(address _addr, address _receiver) external;

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

interface IAccessControl {

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

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

}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

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


interface IStableMasterFront {

    function mint(
        uint256 amount,
        address user,
        IPoolManager poolManager,
        uint256 minStableAmount
    ) external;


    function burn(
        uint256 amount,
        address burner,
        address dest,
        IPoolManager poolManager,
        uint256 minCollatAmount
    ) external;


    function deposit(
        uint256 amount,
        address user,
        IPoolManager poolManager
    ) external;


    function withdraw(
        uint256 amount,
        address burner,
        address dest,
        IPoolManager poolManager
    ) external;


    function agToken() external returns (address);

}// GPL-3.0

pragma solidity ^0.8.7;


interface IVeANGLE {

    function deposit_for(address addr, uint256 amount) external;

}// GPL-2.0-or-later
pragma solidity ^0.8.7;


interface IWETH9 is IERC20 {

    function deposit() external payable;


    function withdraw(uint256) external;

}// GPL-3.0

pragma solidity ^0.8.7;

struct ExactInputParams {
    bytes path;
    address recipient;
    uint256 deadline;
    uint256 amountIn;
    uint256 amountOutMinimum;
}

interface IUniswapV3Router {

    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);

}

interface IUniswapV2Router {

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);


    function swapExactTokensForTokens(
        uint256 swapAmount,
        uint256 minExpected,
        address[] calldata path,
        address receiver,
        uint256 swapDeadline
    ) external;

}// GPL-3.0

pragma solidity ^0.8.7;



contract AngleRouter is Initializable, ReentrancyGuardUpgradeable {

    using SafeERC20 for IERC20;
    uint256 public constant BASE_PARAMS = 10**9;

    uint256 private constant _MAX_TOKENS = 10;
    IWETH9 public constant WETH9 = IWETH9(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IERC20 public constant ANGLE = IERC20(0x31429d1856aD1377A8A0079410B297e1a9e214c2);
    IVeANGLE public constant VEANGLE = IVeANGLE(0x0C462Dbb9EC8cD1630f1728B2CFD2769d09f0dd5);


    enum ActionType {
        claimRewards,
        claimWeeklyInterest,
        gaugeDeposit,
        withdraw,
        mint,
        deposit,
        openPerpetual,
        addToPerpetual,
        veANGLEDeposit
    }

    enum SwapType {
        UniswapV3,
        oneINCH
    }

    struct ParamsSwapType {
        IERC20 inToken;
        address collateral;
        uint256 amountIn;
        uint256 minAmountOut;
        bytes args;
        SwapType swapType;
    }

    struct TransferType {
        IERC20 inToken;
        uint256 amountIn;
    }

    struct Pairs {
        IPoolManager poolManager;
        IPerpetualManagerFrontWithClaim perpetualManager;
        ISanToken sanToken;
        ILiquidityGauge gauge;
    }

    struct PermitType {
        address token;
        address owner;
        uint256 value;
        uint256 deadline;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }


    event AdminChanged(address indexed admin, bool setGovernor);
    event StablecoinAdded(address indexed stableMaster);
    event StablecoinRemoved(address indexed stableMaster);
    event CollateralToggled(address indexed stableMaster, address indexed poolManager, address indexed liquidityGauge);
    event SanTokenLiquidityGaugeUpdated(address indexed sanToken, address indexed newLiquidityGauge);
    event Recovered(address indexed tokenAddress, address indexed to, uint256 amount);


    mapping(IERC20 => IStableMasterFront) public mapStableMasters;
    mapping(IStableMasterFront => mapping(IERC20 => Pairs)) public mapPoolManagers;
    mapping(IERC20 => bool) public uniAllowedToken;
    mapping(IERC20 => bool) public oneInchAllowedToken;


    address public governor;
    address public guardian;
    IUniswapV3Router public uniswapV3Router;
    address public oneInch;

    uint256[50] private __gap;

    constructor() initializer {}

    function initialize(
        address _governor,
        address _guardian,
        IUniswapV3Router _uniswapV3Router,
        address _oneInch,
        IStableMasterFront existingStableMaster,
        IPoolManager[] calldata existingPoolManagers,
        ILiquidityGauge[] calldata existingLiquidityGauges
    ) public initializer {

        require(
            address(_uniswapV3Router) != address(0) &&
                _oneInch != address(0) &&
                _governor != address(0) &&
                _guardian != address(0),
            "0"
        );
        require(_governor != _guardian, "49");
        require(existingPoolManagers.length == existingLiquidityGauges.length, "104");
        mapStableMasters[
            IERC20(address(IStableMaster(address(existingStableMaster)).agToken()))
        ] = existingStableMaster;
        governor = _governor;
        guardian = _guardian;
        uniswapV3Router = _uniswapV3Router;
        oneInch = _oneInch;

        ANGLE.safeApprove(address(VEANGLE), type(uint256).max);

        for (uint256 i = 0; i < existingPoolManagers.length; i++) {
            _addPair(existingStableMaster, existingPoolManagers[i], existingLiquidityGauges[i]);
        }
    }


    modifier onlyGovernorOrGuardian() {

        require(msg.sender == governor || msg.sender == guardian, "115");
        _;
    }


    function setGovernorOrGuardian(address admin, bool setGovernor) external onlyGovernorOrGuardian {

        require(admin != address(0), "0");
        require(guardian != admin && governor != admin, "49");
        if (setGovernor) governor = admin;
        else guardian = admin;
        emit AdminChanged(admin, setGovernor);
    }

    function addStableMaster(IERC20 stablecoin, IStableMasterFront stableMaster) external onlyGovernorOrGuardian {

        require(address(stablecoin) != address(0), "0");
        require(address(mapStableMasters[stablecoin]) == address(0), "114");
        require(stableMaster.agToken() == address(stablecoin), "20");
        mapStableMasters[stablecoin] = stableMaster;
        emit StablecoinAdded(address(stableMaster));
    }

    function removeStableMaster(IERC20 stablecoin) external onlyGovernorOrGuardian {

        IStableMasterFront stableMaster = mapStableMasters[stablecoin];
        delete mapStableMasters[stablecoin];
        emit StablecoinRemoved(address(stableMaster));
    }

    function addPairs(
        IERC20[] calldata stablecoins,
        IPoolManager[] calldata poolManagers,
        ILiquidityGauge[] calldata liquidityGauges
    ) external onlyGovernorOrGuardian {

        require(poolManagers.length == stablecoins.length && liquidityGauges.length == stablecoins.length, "104");
        for (uint256 i = 0; i < stablecoins.length; i++) {
            IStableMasterFront stableMaster = mapStableMasters[stablecoins[i]];
            _addPair(stableMaster, poolManagers[i], liquidityGauges[i]);
        }
    }

    function removePairs(
        IERC20[] calldata stablecoins,
        IERC20[] calldata collaterals,
        IStableMasterFront[] calldata stableMasters
    ) external onlyGovernorOrGuardian {

        require(collaterals.length == stablecoins.length && stableMasters.length == collaterals.length, "104");
        Pairs memory pairs;
        IStableMasterFront stableMaster;
        for (uint256 i = 0; i < stablecoins.length; i++) {
            if (address(stableMasters[i]) == address(0))
                (stableMaster, pairs) = _getInternalContracts(stablecoins[i], collaterals[i]);
            else {
                stableMaster = stableMasters[i];
                pairs = mapPoolManagers[stableMaster][collaterals[i]];
            }
            delete mapPoolManagers[stableMaster][collaterals[i]];
            _changeAllowance(collaterals[i], address(stableMaster), 0);
            _changeAllowance(collaterals[i], address(pairs.perpetualManager), 0);
            if (address(pairs.gauge) != address(0)) pairs.sanToken.approve(address(pairs.gauge), 0);
            emit CollateralToggled(address(stableMaster), address(pairs.poolManager), address(pairs.gauge));
        }
    }

    function setLiquidityGauges(
        IERC20[] calldata stablecoins,
        IERC20[] calldata collaterals,
        ILiquidityGauge[] calldata newLiquidityGauges
    ) external onlyGovernorOrGuardian {

        require(collaterals.length == stablecoins.length && newLiquidityGauges.length == stablecoins.length, "104");
        for (uint256 i = 0; i < stablecoins.length; i++) {
            IStableMasterFront stableMaster = mapStableMasters[stablecoins[i]];
            Pairs storage pairs = mapPoolManagers[stableMaster][collaterals[i]];
            ILiquidityGauge gauge = pairs.gauge;
            ISanToken sanToken = pairs.sanToken;
            require(address(stableMaster) != address(0) && address(pairs.poolManager) != address(0), "0");
            pairs.gauge = newLiquidityGauges[i];
            if (address(gauge) != address(0)) {
                sanToken.approve(address(gauge), 0);
            }
            if (address(newLiquidityGauges[i]) != address(0)) {
                require(address(newLiquidityGauges[i].staking_token()) == address(sanToken), "20");
                sanToken.approve(address(newLiquidityGauges[i]), type(uint256).max);
            }
            emit SanTokenLiquidityGaugeUpdated(address(sanToken), address(newLiquidityGauges[i]));
        }
    }

    function changeAllowance(
        IERC20[] calldata tokens,
        address[] calldata spenders,
        uint256[] calldata amounts
    ) external onlyGovernorOrGuardian {

        require(tokens.length == spenders.length && tokens.length == amounts.length, "104");
        for (uint256 i = 0; i < tokens.length; i++) {
            _changeAllowance(tokens[i], spenders[i], amounts[i]);
        }
    }

    function recoverERC20(
        address tokenAddress,
        address to,
        uint256 tokenAmount
    ) external onlyGovernorOrGuardian {

        IERC20(tokenAddress).safeTransfer(to, tokenAmount);
        emit Recovered(tokenAddress, to, tokenAmount);
    }


    function claimRewards(
        address gaugeUser,
        address[] memory liquidityGauges,
        uint256[] memory perpetualIDs,
        address[] memory stablecoins,
        address[] memory collaterals
    ) external nonReentrant {

        _claimRewards(gaugeUser, liquidityGauges, perpetualIDs, false, stablecoins, collaterals);
    }

    function claimRewards(
        address user,
        address[] memory liquidityGauges,
        uint256[] memory perpetualIDs,
        address[] memory perpetualManagers
    ) external nonReentrant {

        _claimRewards(user, liquidityGauges, perpetualIDs, true, new address[](perpetualIDs.length), perpetualManagers);
    }

    function gaugeDeposit(
        address user,
        uint256 amount,
        ILiquidityGauge gauge,
        bool shouldClaimRewards,
        IERC20 token
    ) external nonReentrant {

        token.safeTransferFrom(msg.sender, address(this), amount);
        _gaugeDeposit(user, amount, gauge, shouldClaimRewards);
    }

    function mint(
        address user,
        uint256 amount,
        uint256 minStableAmount,
        address stablecoin,
        address collateral
    ) external nonReentrant {

        IERC20(collateral).safeTransferFrom(msg.sender, address(this), amount);
        _mint(user, amount, minStableAmount, false, stablecoin, collateral, IPoolManager(address(0)));
    }

    function mint(
        address user,
        uint256 amount,
        uint256 minStableAmount,
        address stableMaster,
        address collateral,
        address poolManager
    ) external nonReentrant {

        IERC20(collateral).safeTransferFrom(msg.sender, address(this), amount);
        _mint(user, amount, minStableAmount, true, stableMaster, collateral, IPoolManager(poolManager));
    }

    function burn(
        address dest,
        uint256 amount,
        uint256 minCollatAmount,
        address stablecoin,
        address collateral
    ) external nonReentrant {

        _burn(dest, amount, minCollatAmount, false, stablecoin, collateral, IPoolManager(address(0)));
    }

    function deposit(
        address user,
        uint256 amount,
        address stablecoin,
        address collateral
    ) external nonReentrant {

        IERC20(collateral).safeTransferFrom(msg.sender, address(this), amount);
        _deposit(user, amount, false, stablecoin, collateral, IPoolManager(address(0)), ISanToken(address(0)));
    }

    function deposit(
        address user,
        uint256 amount,
        address stableMaster,
        address collateral,
        IPoolManager poolManager,
        ISanToken sanToken
    ) external nonReentrant {

        IERC20(collateral).safeTransferFrom(msg.sender, address(this), amount);
        _deposit(user, amount, true, stableMaster, collateral, poolManager, sanToken);
    }

    function openPerpetual(
        address owner,
        uint256 margin,
        uint256 amountCommitted,
        uint256 maxOracleRate,
        uint256 minNetMargin,
        bool addressProcessed,
        address stablecoinOrPerpetualManager,
        address collateral
    ) external nonReentrant {

        IERC20(collateral).safeTransferFrom(msg.sender, address(this), margin);
        _openPerpetual(
            owner,
            margin,
            amountCommitted,
            maxOracleRate,
            minNetMargin,
            addressProcessed,
            stablecoinOrPerpetualManager,
            collateral
        );
    }

    function addToPerpetual(
        uint256 margin,
        uint256 perpetualID,
        bool addressProcessed,
        address stablecoinOrPerpetualManager,
        address collateral
    ) external nonReentrant {

        IERC20(collateral).safeTransferFrom(msg.sender, address(this), margin);
        _addToPerpetual(margin, perpetualID, addressProcessed, stablecoinOrPerpetualManager, collateral);
    }

    function mixer(
        PermitType[] memory paramsPermit,
        TransferType[] memory paramsTransfer,
        ParamsSwapType[] memory paramsSwap,
        ActionType[] memory actions,
        bytes[] calldata datas
    ) external payable nonReentrant {

        for (uint256 i = 0; i < paramsPermit.length; i++) {
            IERC20PermitUpgradeable(paramsPermit[i].token).permit(
                paramsPermit[i].owner,
                address(this),
                paramsPermit[i].value,
                paramsPermit[i].deadline,
                paramsPermit[i].v,
                paramsPermit[i].r,
                paramsPermit[i].s
            );
        }

        address[_MAX_TOKENS] memory listTokens;
        uint256[_MAX_TOKENS] memory balanceTokens;

        for (uint256 i = 0; i < paramsTransfer.length; i++) {
            paramsTransfer[i].inToken.safeTransferFrom(msg.sender, address(this), paramsTransfer[i].amountIn);
            _addToList(listTokens, balanceTokens, address(paramsTransfer[i].inToken), paramsTransfer[i].amountIn);
        }

        for (uint256 i = 0; i < paramsSwap.length; i++) {
            uint256 amountOut = _transferAndSwap(
                paramsSwap[i].inToken,
                paramsSwap[i].amountIn,
                paramsSwap[i].minAmountOut,
                paramsSwap[i].swapType,
                paramsSwap[i].args
            );
            _addToList(listTokens, balanceTokens, address(paramsSwap[i].collateral), amountOut);
        }

        for (uint256 i = 0; i < actions.length; i++) {
            if (actions[i] == ActionType.claimRewards) {
                (
                    address user,
                    uint256 proportionToBeTransferred,
                    address[] memory claimLiquidityGauges,
                    uint256[] memory claimPerpetualIDs,
                    bool addressProcessed,
                    address[] memory stablecoins,
                    address[] memory collateralsOrPerpetualManagers
                ) = abi.decode(datas[i], (address, uint256, address[], uint256[], bool, address[], address[]));

                uint256 amount = ANGLE.balanceOf(user);

                _claimRewards(
                    user,
                    claimLiquidityGauges,
                    claimPerpetualIDs,
                    addressProcessed,
                    stablecoins,
                    collateralsOrPerpetualManagers
                );
                if (proportionToBeTransferred > 0) {
                    amount = ANGLE.balanceOf(user) - amount;
                    amount = (amount * proportionToBeTransferred) / BASE_PARAMS;
                    ANGLE.safeTransferFrom(msg.sender, address(this), amount);
                    _addToList(listTokens, balanceTokens, address(ANGLE), amount);
                }
            } else if (actions[i] == ActionType.claimWeeklyInterest) {
                (address user, address feeDistributor, bool letInContract) = abi.decode(
                    datas[i],
                    (address, address, bool)
                );

                (uint256 amount, IERC20 token) = _claimWeeklyInterest(
                    user,
                    IFeeDistributorFront(feeDistributor),
                    letInContract
                );
                if (address(token) != address(0)) _addToList(listTokens, balanceTokens, address(token), amount);
            } else if (actions[i] == ActionType.veANGLEDeposit) {
                (address user, uint256 amount) = abi.decode(datas[i], (address, uint256));

                amount = _computeProportion(amount, listTokens, balanceTokens, address(ANGLE));
                _depositOnLocker(user, amount);
            } else if (actions[i] == ActionType.gaugeDeposit) {
                (address user, uint256 amount, address stakedToken, address gauge, bool shouldClaimRewards) = abi
                    .decode(datas[i], (address, uint256, address, address, bool));

                amount = _computeProportion(amount, listTokens, balanceTokens, stakedToken);
                _gaugeDeposit(user, amount, ILiquidityGauge(gauge), shouldClaimRewards);
            } else if (actions[i] == ActionType.deposit) {
                (
                    address user,
                    uint256 amount,
                    bool addressProcessed,
                    address stablecoinOrStableMaster,
                    address collateral,
                    address poolManager,
                    address sanToken
                ) = abi.decode(datas[i], (address, uint256, bool, address, address, address, address));

                amount = _computeProportion(amount, listTokens, balanceTokens, collateral);
                (amount, sanToken) = _deposit(
                    user,
                    amount,
                    addressProcessed,
                    stablecoinOrStableMaster,
                    collateral,
                    IPoolManager(poolManager),
                    ISanToken(sanToken)
                );

                if (amount > 0) _addToList(listTokens, balanceTokens, sanToken, amount);
            } else if (actions[i] == ActionType.withdraw) {
                (
                    uint256 amount,
                    bool addressProcessed,
                    address stablecoinOrStableMaster,
                    address collateralOrPoolManager,
                    address sanToken
                ) = abi.decode(datas[i], (uint256, bool, address, address, address));

                amount = _computeProportion(amount, listTokens, balanceTokens, sanToken);
                (amount, collateralOrPoolManager) = _withdraw(
                    amount,
                    addressProcessed,
                    stablecoinOrStableMaster,
                    collateralOrPoolManager
                );
                _addToList(listTokens, balanceTokens, collateralOrPoolManager, amount);
            } else if (actions[i] == ActionType.mint) {
                (
                    address user,
                    uint256 amount,
                    uint256 minStableAmount,
                    bool addressProcessed,
                    address stablecoinOrStableMaster,
                    address collateral,
                    address poolManager
                ) = abi.decode(datas[i], (address, uint256, uint256, bool, address, address, address));

                amount = _computeProportion(amount, listTokens, balanceTokens, collateral);
                _mint(
                    user,
                    amount,
                    minStableAmount,
                    addressProcessed,
                    stablecoinOrStableMaster,
                    collateral,
                    IPoolManager(poolManager)
                );
            } else if (actions[i] == ActionType.openPerpetual) {
                (
                    address user,
                    uint256 amount,
                    uint256 amountCommitted,
                    uint256 extremeRateOracle,
                    uint256 minNetMargin,
                    bool addressProcessed,
                    address stablecoinOrPerpetualManager,
                    address collateral
                ) = abi.decode(datas[i], (address, uint256, uint256, uint256, uint256, bool, address, address));

                amount = _computeProportion(amount, listTokens, balanceTokens, collateral);

                _openPerpetual(
                    user,
                    amount,
                    amountCommitted,
                    extremeRateOracle,
                    minNetMargin,
                    addressProcessed,
                    stablecoinOrPerpetualManager,
                    collateral
                );
            } else if (actions[i] == ActionType.addToPerpetual) {
                (
                    uint256 amount,
                    uint256 perpetualID,
                    bool addressProcessed,
                    address stablecoinOrPerpetualManager,
                    address collateral
                ) = abi.decode(datas[i], (uint256, uint256, bool, address, address));

                amount = _computeProportion(amount, listTokens, balanceTokens, collateral);
                _addToPerpetual(amount, perpetualID, addressProcessed, stablecoinOrPerpetualManager, collateral);
            }
        }

        for (uint256 i = 0; i < balanceTokens.length; i++) {
            if (balanceTokens[i] > 0) IERC20(listTokens[i]).safeTransfer(msg.sender, balanceTokens[i]);
        }
    }

    receive() external payable {}


    function _claimRewards(
        address gaugeUser,
        address[] memory liquidityGauges,
        uint256[] memory perpetualIDs,
        bool addressProcessed,
        address[] memory stablecoins,
        address[] memory collateralsOrPerpetualManagers
    ) internal {

        require(
            stablecoins.length == perpetualIDs.length && collateralsOrPerpetualManagers.length == perpetualIDs.length,
            "104"
        );

        for (uint256 i = 0; i < liquidityGauges.length; i++) {
            ILiquidityGauge(liquidityGauges[i]).claim_rewards(gaugeUser);
        }

        for (uint256 i = 0; i < perpetualIDs.length; i++) {
            IPerpetualManagerFrontWithClaim perpManager;
            if (addressProcessed) perpManager = IPerpetualManagerFrontWithClaim(collateralsOrPerpetualManagers[i]);
            else {
                (, Pairs memory pairs) = _getInternalContracts(
                    IERC20(stablecoins[i]),
                    IERC20(collateralsOrPerpetualManagers[i])
                );
                perpManager = pairs.perpetualManager;
            }
            perpManager.getReward(perpetualIDs[i]);
        }
    }

    function _depositOnLocker(address user, uint256 amount) internal {

        VEANGLE.deposit_for(user, amount);
    }

    function _claimWeeklyInterest(
        address user,
        IFeeDistributorFront _feeDistributor,
        bool letInContract
    ) internal returns (uint256 amount, IERC20 token) {

        amount = _feeDistributor.claim(user);
        if (letInContract) {
            token = IERC20(_feeDistributor.token());
            token.safeTransferFrom(msg.sender, address(this), amount);
        } else {
            amount = 0;
        }
    }

    function _gaugeDeposit(
        address user,
        uint256 amount,
        ILiquidityGauge gauge,
        bool shouldClaimRewards
    ) internal {

        gauge.deposit(amount, user, shouldClaimRewards);
    }

    function _mint(
        address user,
        uint256 amount,
        uint256 minStableAmount,
        bool addressProcessed,
        address stablecoinOrStableMaster,
        address collateral,
        IPoolManager poolManager
    ) internal {

        IStableMasterFront stableMaster;
        (stableMaster, poolManager) = _mintBurnContracts(
            addressProcessed,
            stablecoinOrStableMaster,
            collateral,
            poolManager
        );
        stableMaster.mint(amount, user, poolManager, minStableAmount);
    }

    function _burn(
        address dest,
        uint256 amount,
        uint256 minCollatAmount,
        bool addressProcessed,
        address stablecoinOrStableMaster,
        address collateral,
        IPoolManager poolManager
    ) internal {

        IStableMasterFront stableMaster;
        (stableMaster, poolManager) = _mintBurnContracts(
            addressProcessed,
            stablecoinOrStableMaster,
            collateral,
            poolManager
        );
        stableMaster.burn(amount, msg.sender, dest, poolManager, minCollatAmount);
    }

    function _deposit(
        address user,
        uint256 amount,
        bool addressProcessed,
        address stablecoinOrStableMaster,
        address collateral,
        IPoolManager poolManager,
        ISanToken sanToken
    ) internal returns (uint256 addedAmount, address) {

        IStableMasterFront stableMaster;
        if (addressProcessed) {
            stableMaster = IStableMasterFront(stablecoinOrStableMaster);
        } else {
            Pairs memory pairs;
            (stableMaster, pairs) = _getInternalContracts(IERC20(stablecoinOrStableMaster), IERC20(collateral));
            poolManager = pairs.poolManager;
            sanToken = pairs.sanToken;
        }

        if (user == address(this)) {
            addedAmount = sanToken.balanceOf(address(this));
            stableMaster.deposit(amount, address(this), poolManager);
            addedAmount = sanToken.balanceOf(address(this)) - addedAmount;
        } else {
            stableMaster.deposit(amount, user, poolManager);
        }
        return (addedAmount, address(sanToken));
    }

    function _withdraw(
        uint256 amount,
        bool addressProcessed,
        address stablecoinOrStableMaster,
        address collateralOrPoolManager
    ) internal returns (uint256 withdrawnAmount, address) {

        IStableMasterFront stableMaster;
        IPoolManager poolManager;
        if (addressProcessed) {
            stableMaster = IStableMasterFront(stablecoinOrStableMaster);
            poolManager = IPoolManager(collateralOrPoolManager);
            collateralOrPoolManager = poolManager.token();
        } else {
            Pairs memory pairs;
            (stableMaster, pairs) = _getInternalContracts(
                IERC20(stablecoinOrStableMaster),
                IERC20(collateralOrPoolManager)
            );
            poolManager = pairs.poolManager;
        }
        withdrawnAmount = IERC20(collateralOrPoolManager).balanceOf(address(this));

        stableMaster.withdraw(amount, address(this), address(this), poolManager);

        withdrawnAmount = IERC20(collateralOrPoolManager).balanceOf(address(this)) - withdrawnAmount;

        return (withdrawnAmount, collateralOrPoolManager);
    }

    function _openPerpetual(
        address owner,
        uint256 margin,
        uint256 amountCommitted,
        uint256 maxOracleRate,
        uint256 minNetMargin,
        bool addressProcessed,
        address stablecoinOrPerpetualManager,
        address collateral
    ) internal returns (uint256 perpetualID) {

        if (!addressProcessed) {
            (, Pairs memory pairs) = _getInternalContracts(IERC20(stablecoinOrPerpetualManager), IERC20(collateral));
            stablecoinOrPerpetualManager = address(pairs.perpetualManager);
        }

        return
            IPerpetualManagerFrontWithClaim(stablecoinOrPerpetualManager).openPerpetual(
                owner,
                margin,
                amountCommitted,
                maxOracleRate,
                minNetMargin
            );
    }

    function _addToPerpetual(
        uint256 margin,
        uint256 perpetualID,
        bool addressProcessed,
        address stablecoinOrPerpetualManager,
        address collateral
    ) internal {

        if (!addressProcessed) {
            (, Pairs memory pairs) = _getInternalContracts(IERC20(stablecoinOrPerpetualManager), IERC20(collateral));
            stablecoinOrPerpetualManager = address(pairs.perpetualManager);
        }
        IPerpetualManagerFrontWithClaim(stablecoinOrPerpetualManager).addToPerpetual(perpetualID, margin);
    }


    function _searchList(address[_MAX_TOKENS] memory list, address searchFor) internal pure returns (uint256 index) {

        uint256 i;
        while (i < list.length && list[i] != address(0)) {
            if (list[i] == searchFor) return i;
            i++;
        }
        return i;
    }

    function _addToList(
        address[_MAX_TOKENS] memory list,
        uint256[_MAX_TOKENS] memory balances,
        address searchFor,
        uint256 amount
    ) internal pure {

        uint256 index = _searchList(list, searchFor);
        if (list[index] == address(0)) list[index] = searchFor;
        balances[index] += amount;
    }

    function _computeProportion(
        uint256 proportion,
        address[_MAX_TOKENS] memory list,
        uint256[_MAX_TOKENS] memory balances,
        address searchFor
    ) internal pure returns (uint256 amount) {

        uint256 index = _searchList(list, searchFor);

        require(list[index] != address(0), "33");

        amount = (proportion * balances[index]) / BASE_PARAMS;
        balances[index] -= amount;
    }

    function _getInternalContracts(IERC20 stablecoin, IERC20 collateral)
        internal
        view
        returns (IStableMasterFront stableMaster, Pairs memory pairs)
    {

        stableMaster = mapStableMasters[stablecoin];
        pairs = mapPoolManagers[stableMaster][collateral];
        require(address(stableMaster) != address(0) && address(pairs.poolManager) != address(0), "0");

        return (stableMaster, pairs);
    }

    function _mintBurnContracts(
        bool addressProcessed,
        address stablecoinOrStableMaster,
        address collateral,
        IPoolManager poolManager
    ) internal view returns (IStableMasterFront, IPoolManager) {

        IStableMasterFront stableMaster;
        if (addressProcessed) {
            stableMaster = IStableMasterFront(stablecoinOrStableMaster);
        } else {
            Pairs memory pairs;
            (stableMaster, pairs) = _getInternalContracts(IERC20(stablecoinOrStableMaster), IERC20(collateral));
            poolManager = pairs.poolManager;
        }
        return (stableMaster, poolManager);
    }

    function _addPair(
        IStableMasterFront stableMaster,
        IPoolManager poolManager,
        ILiquidityGauge liquidityGauge
    ) internal {

        (IERC20 collateral, ISanToken sanToken, IPerpetualManager perpetualManager, , , , , , ) = IStableMaster(
            address(stableMaster)
        ).collateralMap(poolManager);

        Pairs storage _pairs = mapPoolManagers[stableMaster][collateral];
        require(address(_pairs.poolManager) == address(0), "114");

        _pairs.poolManager = poolManager;
        _pairs.perpetualManager = IPerpetualManagerFrontWithClaim(address(perpetualManager));
        _pairs.sanToken = sanToken;
        if (address(liquidityGauge) != address(0)) {
            require(address(sanToken) == liquidityGauge.staking_token(), "20");
            _pairs.gauge = liquidityGauge;
            sanToken.approve(address(liquidityGauge), type(uint256).max);
        }
        _changeAllowance(collateral, address(stableMaster), type(uint256).max);
        _changeAllowance(collateral, address(perpetualManager), type(uint256).max);
        emit CollateralToggled(address(stableMaster), address(poolManager), address(liquidityGauge));
    }

    function _changeAllowance(
        IERC20 token,
        address spender,
        uint256 amount
    ) internal {

        uint256 currentAllowance = token.allowance(address(this), spender);
        if (currentAllowance < amount) {
            token.safeIncreaseAllowance(spender, amount - currentAllowance);
        } else if (currentAllowance > amount) {
            token.safeDecreaseAllowance(spender, currentAllowance - amount);
        }
    }

    function _transferAndSwap(
        IERC20 inToken,
        uint256 amount,
        uint256 minAmountOut,
        SwapType swapType,
        bytes memory args
    ) internal returns (uint256 amountOut) {

        if (address(inToken) == address(WETH9) && address(this).balance >= amount) {
            WETH9.deposit{ value: amount }(); // wrap only what is needed to pay
        } else {
            inToken.safeTransferFrom(msg.sender, address(this), amount);
        }
        if (swapType == SwapType.UniswapV3) amountOut = _swapOnUniswapV3(inToken, amount, minAmountOut, args);
        else if (swapType == SwapType.oneINCH) amountOut = _swapOn1Inch(inToken, minAmountOut, args);
        else require(false, "3");

        return amountOut;
    }

    function _swapOnUniswapV3(
        IERC20 inToken,
        uint256 amount,
        uint256 minAmountOut,
        bytes memory path
    ) internal returns (uint256 amountOut) {

        if (!uniAllowedToken[inToken]) {
            inToken.safeIncreaseAllowance(address(uniswapV3Router), type(uint256).max);
            uniAllowedToken[inToken] = true;
        }
        amountOut = uniswapV3Router.exactInput(
            ExactInputParams(path, address(this), block.timestamp, amount, minAmountOut)
        );
    }

    function _swapOn1Inch(
        IERC20 inToken,
        uint256 minAmountOut,
        bytes memory payload
    ) internal returns (uint256 amountOut) {

        if (!oneInchAllowedToken[inToken]) {
            inToken.safeIncreaseAllowance(address(oneInch), type(uint256).max);
            oneInchAllowedToken[inToken] = true;
        }

        (bool success, bytes memory result) = oneInch.call(payload);
        if (!success) _revertBytes(result);

        amountOut = abi.decode(result, (uint256));
        require(amountOut >= minAmountOut, "15");
    }

    function _revertBytes(bytes memory errMsg) internal pure {

        if (errMsg.length > 0) {
            assembly {
                revert(add(32, errMsg), mload(errMsg))
            }
        }
        revert("117");
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC20PermitUpgradeable {

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    function nonces(address owner) external view returns (uint256);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

}