
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

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
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

pragma solidity 0.8.12;

interface IFeeDistributor {

    function burn(address token) external;

}

interface IFeeDistributorFront {

    function token() external returns (address);


    function claim(address _addr) external returns (uint256);


    function claim(address[20] memory _addr) external returns (bool);

}// GPL-3.0

pragma solidity 0.8.12;

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

pragma solidity 0.8.12;


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

pragma solidity 0.8.12;

interface IAccessControl {

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

}// GPL-3.0

pragma solidity 0.8.12;


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

pragma solidity 0.8.12;


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

pragma solidity 0.8.12;

interface IOracle {

    function read() external view returns (uint256);


    function readAll() external view returns (uint256 lowerRate, uint256 upperRate);


    function readLower() external view returns (uint256);


    function readUpper() external view returns (uint256);


    function readQuote(uint256 baseAmount) external view returns (uint256);


    function readQuoteLower(uint256 baseAmount) external view returns (uint256);


    function inBase() external view returns (uint256);

}// GPL-3.0

pragma solidity 0.8.12;


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

pragma solidity 0.8.12;


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

pragma solidity 0.8.12;



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

pragma solidity 0.8.12;


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

pragma solidity 0.8.12;


interface IVeANGLE {

    function deposit_for(address addr, uint256 amount) external;

}// GPL-2.0-or-later
pragma solidity 0.8.12;


interface IWETH9 is IERC20 {

    function deposit() external payable;


    function withdraw(uint256) external;

}// GPL-3.0

pragma solidity 0.8.12;

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

pragma solidity 0.8.12;

interface ITreasury {

    function isVaultManager(address _vaultManager) external view returns (bool);

}// GPL-3.0

pragma solidity 0.8.12;



struct PaymentData {
    uint256 stablecoinAmountToGive;
    uint256 stablecoinAmountToReceive;
    uint256 collateralAmountToGive;
    uint256 collateralAmountToReceive;
}

struct Vault {
    uint256 collateralAmount;
    uint256 normalizedDebt;
}

enum ActionBorrowType {
    createVault,
    closeVault,
    addCollateral,
    removeCollateral,
    repayDebt,
    borrow,
    getDebtIn,
    permit
}


interface IVaultManagerFunctions {

    function angle(
        ActionBorrowType[] memory actions,
        bytes[] memory datas,
        address from,
        address to
    ) external payable returns (PaymentData memory paymentData);


    function angle(
        ActionBorrowType[] memory actions,
        bytes[] memory datas,
        address from,
        address to,
        address who,
        bytes memory repayData
    ) external payable returns (PaymentData memory paymentData);


    function isApprovedOrOwner(address spender, uint256 vaultID) external view returns (bool);


    function permit(
        address owner,
        address spender,
        bool approved,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

}

interface IVaultManagerStorage {

    function treasury() external view returns (ITreasury);


    function collateral() external view returns (IERC20);


    function vaultIDCount() external view returns (uint256);

}// MIT

pragma solidity 0.8.12;


interface IStETH is IERC20 {

    event Submitted(address sender, uint256 amount, address referral);

    function submit(address) external payable returns (uint256);


    function getSharesByPooledEth(uint256 _ethAmount) external view returns (uint256);

}// GPL-3.0
pragma solidity 0.8.12;


interface IWStETH is IERC20 {

    function stETH() external returns (address);


    function wrap(uint256 _stETHAmount) external returns (uint256);

}// GPL-3.0

pragma solidity 0.8.12;



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
        veANGLEDeposit,
        borrower
    }

    enum SwapType {
        UniswapV3,
        oneINCH,
        WrapStETH,
        None
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

    struct PermitVaultManagerType {
        address vaultManager;
        address owner;
        bool approved;
        uint256 deadline;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    IStETH public constant STETH = IStETH(0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84);
    IWStETH public constant WSTETH = IWStETH(0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0);


    error AlreadyAdded();
    error IncompatibleLengths();
    error InvalidAddress();
    error InvalidCall();
    error InvalidConditions();
    error InvalidReturnMessage();
    error InvalidToken();
    error NotApprovedOrOwner();
    error NotGovernorOrGuardian();
    error TooSmallAmountOut();
    error ZeroAddress();

    constructor() initializer {}



    modifier onlyGovernorOrGuardian() {

        if (msg.sender != governor && msg.sender != guardian) revert NotGovernorOrGuardian();
        _;
    }


    function setGovernorOrGuardian(address admin, bool setGovernor) external onlyGovernorOrGuardian {

        if (admin == address(0)) revert ZeroAddress();
        if (guardian == admin || governor == admin) revert InvalidAddress();
        if (setGovernor) governor = admin;
        else guardian = admin;
        emit AdminChanged(admin, setGovernor);
    }

    function addStableMaster(IERC20 stablecoin, IStableMasterFront stableMaster) external onlyGovernorOrGuardian {

        if (address(stablecoin) == address(0)) revert ZeroAddress();
        if (address(mapStableMasters[stablecoin]) != address(0)) revert AlreadyAdded();
        if (stableMaster.agToken() != address(stablecoin)) revert InvalidToken();
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

        if (poolManagers.length != stablecoins.length || liquidityGauges.length != stablecoins.length)
            revert IncompatibleLengths();
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

        if (collaterals.length != stablecoins.length || stableMasters.length != collaterals.length)
            revert IncompatibleLengths();
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

        if (collaterals.length != stablecoins.length || newLiquidityGauges.length != stablecoins.length)
            revert IncompatibleLengths();
        for (uint256 i = 0; i < stablecoins.length; i++) {
            IStableMasterFront stableMaster = mapStableMasters[stablecoins[i]];
            Pairs storage pairs = mapPoolManagers[stableMaster][collaterals[i]];
            ILiquidityGauge gauge = pairs.gauge;
            ISanToken sanToken = pairs.sanToken;
            if (address(stableMaster) == address(0) || address(pairs.poolManager) == address(0)) revert ZeroAddress();
            pairs.gauge = newLiquidityGauges[i];
            if (address(gauge) != address(0)) {
                sanToken.approve(address(gauge), 0);
            }
            if (address(newLiquidityGauges[i]) != address(0)) {
                if (address(newLiquidityGauges[i].staking_token()) != address(sanToken)) revert InvalidToken();
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

        if (tokens.length != spenders.length || tokens.length != amounts.length) revert IncompatibleLengths();
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
    ) external {

        _claimRewards(gaugeUser, liquidityGauges, perpetualIDs, false, stablecoins, collaterals);
    }

    function claimRewards(
        address user,
        address[] memory liquidityGauges,
        uint256[] memory perpetualIDs,
        address[] memory perpetualManagers
    ) external {

        _claimRewards(user, liquidityGauges, perpetualIDs, true, new address[](perpetualIDs.length), perpetualManagers);
    }

    function mint(
        address user,
        uint256 amount,
        uint256 minStableAmount,
        address stablecoin,
        address collateral
    ) external {

        IERC20(collateral).safeTransferFrom(msg.sender, address(this), amount);
        _mint(user, amount, minStableAmount, false, stablecoin, collateral, IPoolManager(address(0)));
    }

    function burn(
        address dest,
        uint256 amount,
        uint256 minCollatAmount,
        address stablecoin,
        address collateral
    ) external {

        _burn(dest, amount, minCollatAmount, false, stablecoin, collateral, IPoolManager(address(0)));
    }

    function mixer(
        PermitType[] memory paramsPermit,
        TransferType[] memory paramsTransfer,
        ParamsSwapType[] memory paramsSwap,
        ActionType[] memory actions,
        bytes[] calldata data
    ) public payable {

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
                ) = abi.decode(data[i], (address, uint256, address[], uint256[], bool, address[], address[]));

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
                    data[i],
                    (address, address, bool)
                );

                (uint256 amount, IERC20 token) = _claimWeeklyInterest(
                    user,
                    IFeeDistributorFront(feeDistributor),
                    letInContract
                );
                if (address(token) != address(0)) _addToList(listTokens, balanceTokens, address(token), amount);
            } else if (actions[i] == ActionType.veANGLEDeposit) {
                (address user, uint256 amount) = abi.decode(data[i], (address, uint256));

                amount = _computeProportion(amount, listTokens, balanceTokens, address(ANGLE));
                _depositOnLocker(user, amount);
            } else if (actions[i] == ActionType.gaugeDeposit) {
                (address user, uint256 amount, address stakedToken, address gauge, bool shouldClaimRewards) = abi
                    .decode(data[i], (address, uint256, address, address, bool));

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
                ) = abi.decode(data[i], (address, uint256, bool, address, address, address, address));

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
                ) = abi.decode(data[i], (uint256, bool, address, address, address));

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
                ) = abi.decode(data[i], (address, uint256, uint256, bool, address, address, address));

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
                ) = abi.decode(data[i], (address, uint256, uint256, uint256, uint256, bool, address, address));

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
                ) = abi.decode(data[i], (uint256, uint256, bool, address, address));

                amount = _computeProportion(amount, listTokens, balanceTokens, collateral);
                _addToPerpetual(amount, perpetualID, addressProcessed, stablecoinOrPerpetualManager, collateral);
            } else if (actions[i] == ActionType.borrower) {
                (
                    address collateral,
                    address stablecoin,
                    address vaultManager,
                    address to,
                    address who,
                    ActionBorrowType[] memory actionsBorrow,
                    bytes[] memory dataBorrow,
                    bytes memory repayData
                ) = abi.decode(
                        data[i],
                        (address, address, address, address, address, ActionBorrowType[], bytes[], bytes)
                    );
                _parseVaultIDs(actionsBorrow, dataBorrow, vaultManager);
                _changeAllowance(IERC20(collateral), address(vaultManager), type(uint256).max);
                uint256 stablecoinBalance;
                uint256 collateralBalance;
                if (repayData.length > 0) {
                    stablecoinBalance = IERC20(stablecoin).balanceOf(address(this));
                    collateralBalance = IERC20(collateral).balanceOf(address(this));
                }

                PaymentData memory paymentData = _angleBorrower(
                    vaultManager,
                    actionsBorrow,
                    dataBorrow,
                    to,
                    who,
                    repayData
                );

                _changeAllowance(IERC20(collateral), address(vaultManager), 0);

                if (repayData.length > 0) {
                    paymentData.collateralAmountToGive = IERC20(collateral).balanceOf(address(this));
                    paymentData.stablecoinAmountToGive = IERC20(stablecoin).balanceOf(address(this));
                    paymentData.collateralAmountToReceive = collateralBalance;
                    paymentData.stablecoinAmountToReceive = stablecoinBalance;
                }

                if (paymentData.collateralAmountToReceive > paymentData.collateralAmountToGive) {
                    uint256 index = _searchList(listTokens, collateral);
                    balanceTokens[index] -= paymentData.collateralAmountToReceive - paymentData.collateralAmountToGive;
                } else if (
                    paymentData.collateralAmountToReceive < paymentData.collateralAmountToGive &&
                    (to == address(this) || repayData.length > 0)
                ) {
                    _addToList(
                        listTokens,
                        balanceTokens,
                        collateral,
                        paymentData.collateralAmountToGive - paymentData.collateralAmountToReceive
                    );
                }
                if (
                    paymentData.stablecoinAmountToReceive < paymentData.stablecoinAmountToGive &&
                    (to == address(this) || repayData.length > 0)
                ) {
                    _addToList(
                        listTokens,
                        balanceTokens,
                        stablecoin,
                        paymentData.stablecoinAmountToGive - paymentData.stablecoinAmountToReceive
                    );
                }
            }
        }

        for (uint256 i = 0; i < balanceTokens.length; i++) {
            if (balanceTokens[i] > 0) IERC20(listTokens[i]).safeTransfer(msg.sender, balanceTokens[i]);
        }
    }

    function mixerVaultManagerPermit(
        PermitVaultManagerType[] memory paramsPermitVaultManager,
        PermitType[] memory paramsPermit,
        TransferType[] memory paramsTransfer,
        ParamsSwapType[] memory paramsSwap,
        ActionType[] memory actions,
        bytes[] calldata data
    ) external payable {

        for (uint256 i = 0; i < paramsPermitVaultManager.length; i++) {
            if (paramsPermitVaultManager[i].approved) {
                IVaultManagerFunctions(paramsPermitVaultManager[i].vaultManager).permit(
                    paramsPermitVaultManager[i].owner,
                    address(this),
                    true,
                    paramsPermitVaultManager[i].deadline,
                    paramsPermitVaultManager[i].v,
                    paramsPermitVaultManager[i].r,
                    paramsPermitVaultManager[i].s
                );
            } else break;
        }
        mixer(paramsPermit, paramsTransfer, paramsSwap, actions, data);
        for (uint256 i = 0; i < paramsPermitVaultManager.length; i++) {
            if (!paramsPermitVaultManager[i].approved) {
                IVaultManagerFunctions(paramsPermitVaultManager[i].vaultManager).permit(
                    paramsPermitVaultManager[i].owner,
                    address(this),
                    false,
                    paramsPermitVaultManager[i].deadline,
                    paramsPermitVaultManager[i].v,
                    paramsPermitVaultManager[i].r,
                    paramsPermitVaultManager[i].s
                );
            }
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

        if (stablecoins.length != perpetualIDs.length || collateralsOrPerpetualManagers.length != perpetualIDs.length)
            revert IncompatibleLengths();

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

    function _angleBorrower(
        address vaultManager,
        ActionBorrowType[] memory actionsBorrow,
        bytes[] memory dataBorrow,
        address to,
        address who,
        bytes memory repayData
    ) internal returns (PaymentData memory paymentData) {

        return IVaultManagerFunctions(vaultManager).angle(actionsBorrow, dataBorrow, msg.sender, to, who, repayData);
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


    function _parseVaultIDs(
        ActionBorrowType[] memory actionsBorrow,
        bytes[] memory dataBorrow,
        address vaultManager
    ) internal view {

        if (actionsBorrow.length >= _MAX_TOKENS) revert IncompatibleLengths();
        uint256[_MAX_TOKENS] memory vaultIDsToCheckOwnershipOf;
        bool createVaultAction;
        uint256 lastVaultID;
        uint256 vaultIDLength;
        for (uint256 i = 0; i < actionsBorrow.length; i++) {
            uint256 vaultID;
            if (actionsBorrow[i] == ActionBorrowType.createVault) {
                createVaultAction = true;
                continue;
            } else if (
                actionsBorrow[i] == ActionBorrowType.removeCollateral || actionsBorrow[i] == ActionBorrowType.borrow
            ) {
                (vaultID, ) = abi.decode(dataBorrow[i], (uint256, uint256));
            } else if (actionsBorrow[i] == ActionBorrowType.closeVault) {
                vaultID = abi.decode(dataBorrow[i], (uint256));
            } else if (actionsBorrow[i] == ActionBorrowType.getDebtIn) {
                (vaultID, , , ) = abi.decode(dataBorrow[i], (uint256, address, uint256, uint256));
            } else continue;
            if (vaultID == 0) {
                if (createVaultAction) {
                    continue;
                } else {
                    if (lastVaultID == 0) {
                        lastVaultID = IVaultManagerStorage(vaultManager).vaultIDCount();
                    }
                    vaultID = lastVaultID;
                }
            }

            for (uint256 j = 0; j < vaultIDLength; j++) {
                if (vaultIDsToCheckOwnershipOf[j] == vaultID) {
                    continue;
                }
            }
            if (!IVaultManagerFunctions(vaultManager).isApprovedOrOwner(msg.sender, vaultID)) {
                revert NotApprovedOrOwner();
            }
            vaultIDsToCheckOwnershipOf[vaultIDLength] = vaultID;
            vaultIDLength += 1;
        }
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

        if (list[index] == address(0)) revert InvalidConditions();

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
        if (address(stableMaster) == address(0) || address(pairs.poolManager) == address(0)) revert ZeroAddress();

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
        if (address(_pairs.poolManager) != address(0)) revert AlreadyAdded();

        _pairs.poolManager = poolManager;
        _pairs.perpetualManager = IPerpetualManagerFrontWithClaim(address(perpetualManager));
        _pairs.sanToken = sanToken;
        if (address(liquidityGauge) != address(0)) {
            if (address(sanToken) != liquidityGauge.staking_token()) revert InvalidToken();
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
    ) internal returns (uint256) {

        if (address(this).balance >= amount) {
            if (address(inToken) == address(WETH9)) {
                WETH9.deposit{ value: amount }(); // wrap only what is needed to pay
            } else if (address(inToken) == address(WSTETH)) {
                uint256 amountOut = STETH.getSharesByPooledEth(amount);
                (bool success, bytes memory result) = address(WSTETH).call{ value: amount }("");
                if (!success) _revertBytes(result);
                amount = amountOut;
            }
        } else {
            inToken.safeTransferFrom(msg.sender, address(this), amount);
        }
        return _swap(inToken, amount, minAmountOut, swapType, args);
    }

    function _swap(
        IERC20 inToken,
        uint256 amount,
        uint256 minAmountOut,
        SwapType swapType,
        bytes memory args
    ) internal returns (uint256 amountOut) {

        if (swapType == SwapType.UniswapV3) amountOut = _swapOnUniswapV3(inToken, amount, minAmountOut, args);
        else if (swapType == SwapType.oneINCH) amountOut = _swapOn1Inch(inToken, args);
        else if (swapType == SwapType.WrapStETH) amountOut = WSTETH.wrap(amount);
        else if (swapType == SwapType.None) amountOut = amount;
        else revert InvalidCall();
        if (amountOut < minAmountOut) revert TooSmallAmountOut();
    }

    function _swapOnUniswapV3(
        IERC20 inToken,
        uint256 amount,
        uint256 minAmountOut,
        bytes memory path
    ) internal returns (uint256 amountOut) {

        if (!uniAllowedToken[inToken]) {
            inToken.safeApprove(address(uniswapV3Router), type(uint256).max);
            uniAllowedToken[inToken] = true;
        }
        amountOut = uniswapV3Router.exactInput(
            ExactInputParams(path, address(this), block.timestamp, amount, minAmountOut)
        );
    }

    function _swapOn1Inch(
        IERC20 inToken,
        bytes memory payload
    ) internal returns (uint256 amountOut) {

        if (!oneInchAllowedToken[inToken]) {
            inToken.safeApprove(address(oneInch), type(uint256).max);
            oneInchAllowedToken[inToken] = true;
        }

        (bool success, bytes memory result) = oneInch.call(payload);
        if (!success) _revertBytes(result);

        amountOut = abi.decode(result, (uint256));
    }

    function _revertBytes(bytes memory errMsg) internal pure {

        if (errMsg.length > 0) {
            assembly {
                revert(add(32, errMsg), mload(errMsg))
            }
        }
        revert InvalidReturnMessage();
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