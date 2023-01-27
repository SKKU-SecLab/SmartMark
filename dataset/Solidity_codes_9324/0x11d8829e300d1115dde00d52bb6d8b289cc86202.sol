
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


library SafeERC20Upgradeable {

    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
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
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
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


abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

interface IInvestmentStrategy {

    struct Investment {
        address token;
        uint256 amount;
    }

    function makeInvestment(Investment[] calldata _investments, bytes calldata _data)
        external
        returns (uint256);


    function withdrawInvestment(Investment[] calldata _investments, bytes calldata _data) external;


    function claimTokens(bytes calldata _data) external returns (address);


    function investmentAmount(address _token) external view returns (uint256);

}// MIT
pragma solidity ^0.8.0;


interface IMosaicHolding {

    event FoundsInvested(address indexed strategy, address indexed admin, uint256 cTokensReceived);

    event InvestmentWithdrawn(address indexed strategy, address indexed admin);

    event RebalancingThresholdChanged(
        address indexed admin,
        address indexed token,
        uint256 oldAmount,
        uint256 newAmount
    );

    event RebalancingInitiated(
        address indexed by,
        address indexed token,
        address indexed receiver,
        uint256 amount
    );

    event TokenClaimed(address indexed strategy, address indexed rewardTokenAddress);

    event SaveFundsStarted(address owner, address token, address receiver);

    event LiquidityMoved(address indexed to, address indexed tokenAddress, uint256 amount);

    event SaveFundsLockUpTimerStarted(address owner, uint256 time, uint256 durationToChangeTime);

    event SaveFundsLockUpTimeSet(address owner, uint256 time, uint256 durationToChangeTime);

    event ETHTransfered(address receiver, uint256 amount);

    function getTokenLiquidity(address _token, address[] calldata _investmentStrategies)
        external
        view
        returns (uint256);


    function saveFundsLockupTime() external view returns (uint256);


    function newSaveFundsLockUpTime() external view returns (uint256);


    function durationToChangeTimer() external view returns (uint256);


    function transfer(
        address _token,
        address _receiver,
        uint256 _amount
    ) external;


    function transferETH(address _receiver, uint256 _amount) external;


    function setUniqRole(bytes32 _role, address _address) external;


    function approve(
        address _spender,
        address _token,
        uint256 _amount
    ) external;


    function startSaveFunds(address _token, address _to) external;


    function executeSaveFunds() external;


    function startSaveFundsLockUpTimerChange(uint256 _time) external;


    function setSaveFundsLockUpTime() external;


    function invest(
        IInvestmentStrategy.Investment[] calldata _investments,
        address _investmentStrategy,
        bytes calldata _data
    ) external;


    function withdrawInvestment(
        IInvestmentStrategy.Investment[] calldata _investments,
        address _investmentStrategy,
        bytes calldata _data
    ) external;


    function coverWithdrawRequest(
        address[] calldata _investmentStrategies,
        bytes[] calldata _data,
        address _token,
        uint256 _amount
    ) external;


    function claim(address _investmentStrategy, bytes calldata _data) external;

}// MIT

pragma solidity ^0.8.0;

interface IMosaicExchange {

    function swap(
        address _tokenA,
        address _tokenB,
        uint256 _amountIn,
        uint256 _amountOut,
        bytes calldata _data
    ) external returns (uint256);


    function getAmountsOut(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn,
        bytes calldata _data
    ) external returns (uint256);

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


interface IReceiptBase is IERC20 {

    function burn(address _from, uint256 _amount) external;


    function mint(address _to, uint256 _amount) external;


    function underlyingToken() external returns (address);

}// MIT

pragma solidity ^0.8.0;

interface ITokenFactory {

    function createIOU(
        address _underlyingAddress,
        string calldata _tokenName,
        address _owner
    ) external returns (address);


    function createReceipt(
        address _underlyingAddress,
        string calldata _tokenName,
        address _owner
    ) external returns (address);

}// MIT

pragma solidity ^0.8.0;

interface IVaultConfigBase {

    event TokenCreated(address _underlyingToken);

    function getMosaicHolding() external view returns (address);


    function setTokenFactoryAddress(address _tokenFactoryAddress) external;


    function setVault(address _vault) external;

}// MIT

pragma solidity ^0.8.0;


interface IMosaicVaultConfig is IVaultConfigBase {

    event MinFeeChanged(uint256 newMinFee);
    event MaxFeeChanged(uint256 newMaxFee);
    event MinLiquidityBlockChanged(uint256 newMinLimitLiquidityBlocks);
    event MaxLiquidityBlockChanged(uint256 newMaxLimitLiquidityBlocks);
    event LockupTimeChanged(address indexed owner, uint256 oldVal, uint256 newVal, string valType);
    event TokenWhitelisted(
        address indexed erc20,
        address indexed newIou,
        address indexed newReceipt
    );
    event TokenWhitelistRemoved(address indexed erc20);
    event RemoteTokenAdded(
        address indexed erc20,
        address indexed remoteErc20,
        uint256 indexed remoteNetworkID,
        uint256 remoteTokenRatio
    );
    event RemoteTokenRemoved(address indexed erc20, uint256 indexed remoteNetworkID);

    event PauseNetwork(address admin, uint256 networkID);

    event UnpauseNetwork(address admin, uint256 networkID);

    event AMMAdded(uint256 _id, address indexed _address);

    event AMMRemoved(uint256 _id);

    struct WhitelistedToken {
        uint256 minTransferAllowed;
        uint256 maxTransferAllowed;
        address underlyingIOUAddress;
        address underlyingReceiptAddress;
    }

    function passiveLiquidityLocktime() external view returns (uint256);


    function minFee() external view returns (uint256);


    function maxFee() external view returns (uint256);


    function maxLimitLiquidityBlocks() external view returns (uint256);


    function minLimitLiquidityBlocks() external view returns (uint256);


    function wethAddress() external view returns (address);


    function remoteTokenAddress(uint256 _id, address _token) external view returns (address);


    function remoteTokenRatio(uint256 _id, address _token) external view returns (uint256);


    function supportedAMMs(uint256 _ammID) external view returns (address);


    function pausedNetwork(uint256) external view returns (bool);


    function ableToPerformSmallBalanceSwap() external view returns (bool);


    function supportedMosaicNativeSwappers(uint256 _mosaicNativeSwapperID)
        external
        view
        returns (address);


    function setPassiveLiquidityLocktime(uint256 _locktime) external;


    function setWethAddress(
        address _weth,
        uint256 _minTransferAmount,
        uint256 _maxTransferAmount
    ) external;


    function getUnderlyingIOUAddress(address _token) external view returns (address);


    function getUnderlyingReceiptAddress(address _token) external view returns (address);


    function addSupportedAMM(uint256 _ammID, address _ammAddress) external;


    function removeSupportedAMM(uint256 _ammID) external;


    function changeRemoteTokenRatio(
        address _tokenAddress,
        uint256 _remoteNetworkID,
        uint256 _remoteTokenRatio
    ) external;


    function addWhitelistedToken(
        address _tokenAddress,
        uint256 _minTransferAmount,
        uint256 _maxTransferAmount
    ) external;


    function removeWhitelistedToken(address _token) external;


    function addTokenInNetwork(
        address _tokenAddress,
        address _tokenAddressRemote,
        uint256 _remoteNetworkID,
        uint256 _remoteTokenRatio
    ) external;


    function removeTokenInNetwork(address _tokenAddress, uint256 _remoteNetworkID) external;


    function setMinFee(uint256 _newMinFee) external;


    function setMaxFee(uint256 _newMaxFee) external;


    function setMinLimitLiquidityBlocks(uint256 _newMinLimitLiquidityBlocks) external;


    function setMaxLimitLiquidityBlocks(uint256 _newMaxLimitLiquidityBlocks) external;


    function generateId() external returns (bytes32);


    function inTokenTransferLimits(address, uint256) external view returns (bool);


    function pauseNetwork(uint256 _networkID) external;


    function unpauseNetwork(uint256 _networkID) external;


    function setAbleToPerformSmallBalanceSwap(bool _flag) external;


    function addSupportedMosaicNativeSwapper(
        uint256 _mosaicNativeSwapperID,
        address _mosaicNativeSwapperAddress
    ) external;


    function removeSupportedMosaicNativeSwapper(uint256 _mosaicNativeSwapperID) external;

}// MIT

pragma solidity ^0.8.0;

interface IWETH {

    function deposit() external payable;


    function withdraw(uint256 _wad) external;


    function balanceOf(address _account) external view returns (uint256);


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);

}// MIT

pragma solidity ^0.8.0;


interface IMosaicVault {

    event TransferInitiated(
        address indexed owner,
        address indexed erc20,
        address remoteTokenAddress,
        uint256 indexed remoteNetworkID,
        uint256 value,
        address remoteDestinationAddress,
        bytes32 uniqueId,
        uint256 maxTransferDelay,
        address tokenOut,
        uint256 ammID,
        uint256 amountOutMin,
        bool _swapToNative
    );

    event WithdrawalCompleted(
        address indexed accountTo,
        uint256 amount,
        uint256 netAmount,
        address indexed tokenAddress,
        bytes32 indexed uniqueId,
        bool swapToNative
    );

    event TransferFundsRefunded(
        address indexed tokenAddress,
        address indexed user,
        uint256 amount,
        uint256 fullAmount,
        bytes32 indexed uniqueId
    );
    event FundsDigested(address indexed tokenAddress, uint256 amount);

    event FeeTaken(
        address indexed owner,
        address indexed user,
        address indexed token,
        uint256 amount,
        uint256 fee,
        uint256 baseFee,
        uint256 totalFee,
        bytes32 uniqueId
    );

    event DepositActiveLiquidity(
        address indexed tokenAddress,
        address indexed provider,
        uint256 amount,
        uint256 blocks
    );

    event DepositPassiveLiquidity(
        address indexed tokenAddress,
        address indexed provider,
        uint256 amount
    );

    event LiquidityWithdrawn(
        address indexed user,
        address indexed tokenIn,
        address indexed tokenOut,
        uint256 amountIn,
        uint256 requestedAmountIn,
        uint256 amountOut,
        uint256 baseFee,
        uint256 mosaicFee,
        bool swapToNative,
        bytes32 id
    );

    event LiquidityRefunded(
        address indexed tokenAddress,
        address indexed receiptAddress,
        address indexed user,
        uint256 amount,
        bytes32 uniqueId
    );

    event WithdrawRequest(
        address indexed user,
        address receiptToken,
        address indexed tokenIn,
        uint256 amountIn,
        address indexed tokenOut,
        address remoteTokenInAddress,
        address destinationAddress,
        uint256 ammId,
        uint256 destinationNetworkID,
        bytes data,
        bytes32 uniqueId,
        WithdrawRequestData _withdrawData
    );

    event RelayerSet(address indexed _old, address indexed _new);
    event ConfigSet(address indexed _old, address indexed _new);

    enum TransferState {
        UNKNOWN, // Default state
        SUCCESS,
        REFUNDED
    }

    struct WithdrawRequestData {
        uint256 amountOutMin;
        uint256 maxDelay;
        bool _swapToNative;
    }

    struct WithdrawData {
        uint256 feePercentage;
        uint256 baseFee;
        address[] investmentStrategies;
        bytes[] investmentStrategiesData;
        uint256 ammId;
        bytes32 id;
        uint256 amountToSwapToNative;
        uint256 minAmountOutNative;
        uint256 nativeSwapperId;
    }

    function setRelayer(address _relayer) external;


    function setVaultConfig(address _vaultConfig) external;


    function vaultConfig() external view returns (IMosaicVaultConfig);


    function provideActiveLiquidity(
        uint256 _amount,
        address _tokenAddress,
        uint256 _blocksForActiveLiquidity
    ) external payable;


    function providePassiveLiquidity(uint256 _amount, address _tokenAddress) external payable;


    function withdrawLiquidityRequest(
        address _receiptToken,
        uint256 _amountIn,
        address _tokenOut,
        address _destinationAddress,
        uint256 _ammID,
        bytes calldata _data,
        uint256 _destinationNetworkId,
        WithdrawRequestData calldata _withdrawRequestData
    ) external returns (bytes32 transferId);


    function withdrawLiquidity(
        address _accountTo,
        uint256 _amount,
        uint256 _requestedAmount,
        address _tokenIn,
        address _tokenOut,
        uint256 _amountOutMin,
        WithdrawData calldata _withdrawData,
        bytes calldata _data
    ) external;


    function withdrawTo(
        address _accountTo,
        uint256 _amount,
        address _tokenIn,
        address _tokenOut,
        uint256 _amountOutMin,
        WithdrawData calldata _withdrawData,
        bytes calldata _data
    ) external;


    function revertLiquidityWithdrawalRequest(
        address _user,
        uint256 _amount,
        address _receiptToken,
        bytes32 _id
    ) external;


    function transferERC20ToLayer(
        uint256 _amount,
        address _tokenAddress,
        address _remoteDestinationAddress,
        uint256 _remoteNetworkID,
        uint256 _maxTransferDelay,
        address _tokenOut,
        uint256 _remoteAmmId,
        uint256 _amountOutMin,
        bool _swapToNative
    ) external returns (bytes32 transferId);


    function transferETHToLayer(
        address _remoteDestinationAddress,
        uint256 _remoteNetworkID,
        uint256 _maxTransferDelay,
        address _tokenOut,
        uint256 _remoteAmmId,
        uint256 _amountOutMin,
        bool _swapToNative
    ) external payable returns (bytes32 transferId);


    function refundTransferFunds(
        address _token,
        address _user,
        uint256 _amount,
        uint256 _originalAmount,
        bytes32 _id,
        address[] calldata _investmentStrategies,
        bytes[] calldata _investmentStrategiesData
    ) external;


    function digestFunds(address _token) external;



    function pause() external;



    function unpause() external;

}// MIT
pragma solidity ^0.8.0;

interface IMosaicNativeSwapper {

    event SwappedToNative(address _tokenIn, uint256 amountIn, uint256 amountOut, address addressTo);

    function swapToNative(
        address _tokenIn,
        uint256 _amount,
        uint256 _minAmountOut,
        address _to,
        bytes calldata _data
    ) external returns (uint256);

}// MIT

pragma solidity ^0.8.0;

library FeeOperations {

    uint256 internal constant FEE_FACTOR = 10000;

    function getFeeAbsolute(uint256 amount, uint256 fee) internal pure returns (uint256) {

        return (amount * fee) / FEE_FACTOR;
    }
}// MIT
pragma solidity ^0.8.0;




contract MosaicVault is
    IMosaicVault,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable,
    PausableUpgradeable
{

    using SafeERC20Upgradeable for IERC20Upgradeable;

    struct DepositInfo {
        address token;
        uint256 amount;
    }

    struct TemporaryWithdrawData {
        address tokenIn;
        address remoteTokenIn;
        bytes32 id;
    }

    mapping(bytes32 => bool) public hasBeenWithdrawn;

    mapping(bytes32 => bool) public hasBeenRefunded;

    mapping(address => mapping(address => uint256)) private activeLiquidityAvailableAfterBlock;

    mapping(address => mapping(address => uint256)) public passiveLiquidityAvailableAfterTimestamp;

    mapping(bytes32 => DepositInfo) public deposits;

    bytes32 public lastWithdrawID;

    bytes32 public lastRefundedID;

    address public relayer;

    IMosaicVaultConfig public override vaultConfig;

    function initialize(address _mosaicVaultConfig) public initializer {

        __Ownable_init();
        __Pausable_init();
        __ReentrancyGuard_init();

        vaultConfig = IMosaicVaultConfig(_mosaicVaultConfig);
    }

    function setRelayer(address _relayer) external override onlyOwner {

        emit RelayerSet(relayer, _relayer);
        relayer = _relayer;
    }

    function setVaultConfig(address _vaultConfig) external override onlyOwner {

        emit ConfigSet(address(vaultConfig), _vaultConfig);
        vaultConfig = IMosaicVaultConfig(_vaultConfig);
    }

    function provideActiveLiquidity(
        uint256 _amount,
        address _tokenAddress,
        uint256 _blocksForActiveLiquidity
    )
        public
        payable
        override
        nonReentrant
        whenNotPaused
        inBlockApproveRange(_blocksForActiveLiquidity)
    {

        require(_amount > 0 || msg.value > 0, "ERR: AMOUNT");
        if (msg.value > 0) {
            require(
                vaultConfig.getUnderlyingIOUAddress(vaultConfig.wethAddress()) != address(0),
                "ERR: WETH"
            );
            _provideLiquidity(msg.value, vaultConfig.wethAddress(), _blocksForActiveLiquidity);
        } else {
            require(_tokenAddress != address(0), "ERR: INVALID");
            require(vaultConfig.getUnderlyingIOUAddress(_tokenAddress) != address(0), "ERR: TOKEN");
            _provideLiquidity(_amount, _tokenAddress, _blocksForActiveLiquidity);
        }
    }

    function providePassiveLiquidity(uint256 _amount, address _tokenAddress)
        external
        payable
        override
        nonReentrant
        whenNotPaused
    {

        require(_amount > 0 || msg.value > 0, "ERR: AMOUNT");
        if (msg.value > 0) {
            require(
                vaultConfig.getUnderlyingReceiptAddress(vaultConfig.wethAddress()) != address(0),
                "ERR: WETH "
            );
            _provideLiquidity(msg.value, vaultConfig.wethAddress(), 0);
        } else {
            require(_tokenAddress != address(0), "ERR: INVALID");
            require(
                vaultConfig.getUnderlyingReceiptAddress(_tokenAddress) != address(0),
                "ERR: TOKEN"
            );
            _provideLiquidity(_amount, _tokenAddress, 0);
        }
    }

    function _provideLiquidity(
        uint256 _amount,
        address _tokenAddress,
        uint256 _blocksForActiveLiquidity
    ) private {

        uint256 finalAmount = _amount;
        if (msg.value > 0) {
            uint256 previousWethAmount = IWETH(_tokenAddress).balanceOf(address(this));
            IWETH(_tokenAddress).deposit{value: msg.value}();
            uint256 currentWethAmount = IWETH(_tokenAddress).balanceOf(address(this));
            finalAmount = currentWethAmount - previousWethAmount;
            require(finalAmount >= msg.value, "ERR: WRAP");

            IERC20Upgradeable(_tokenAddress).safeTransfer(
                vaultConfig.getMosaicHolding(),
                finalAmount
            );
        } else {
            IERC20Upgradeable(_tokenAddress).safeTransferFrom(
                msg.sender,
                vaultConfig.getMosaicHolding(),
                finalAmount
            );
        }
        if (_blocksForActiveLiquidity > 0) {
            IReceiptBase(vaultConfig.getUnderlyingIOUAddress(_tokenAddress)).mint(
                msg.sender,
                finalAmount
            );
            _updateActiveLiquidityAvailableAfterBlock(_tokenAddress, _blocksForActiveLiquidity);
            emit DepositActiveLiquidity(
                _tokenAddress,
                msg.sender,
                finalAmount,
                _blocksForActiveLiquidity
            );
        } else {
            IReceiptBase(vaultConfig.getUnderlyingReceiptAddress(_tokenAddress)).mint(
                msg.sender,
                finalAmount
            );
            _updatePassiveLiquidityAvailableAfterTimestamp(_tokenAddress);
            emit DepositPassiveLiquidity(_tokenAddress, msg.sender, finalAmount);
        }
    }

    function _updateActiveLiquidityAvailableAfterBlock(
        address _token,
        uint256 _blocksForActiveLiquidity
    ) private {

        uint256 _availableAfter = activeLiquidityAvailableAfterBlock[msg.sender][_token];
        uint256 _newAvailability = block.number + _blocksForActiveLiquidity;
        if (_availableAfter < _newAvailability) {
            activeLiquidityAvailableAfterBlock[msg.sender][_token] = _newAvailability;
        }
    }

    function _updatePassiveLiquidityAvailableAfterTimestamp(address _token) private {

        uint256 _availableAfter = passiveLiquidityAvailableAfterTimestamp[msg.sender][_token];
        uint256 _newAvailability = block.timestamp + vaultConfig.passiveLiquidityLocktime();
        if (_availableAfter < _newAvailability) {
            passiveLiquidityAvailableAfterTimestamp[msg.sender][_token] = _newAvailability;
        }
    }

    function withdrawLiquidityRequest(
        address _receiptToken,
        uint256 _amountIn,
        address _tokenOut,
        address _destinationAddress,
        uint256 _ammID,
        bytes calldata _data,
        uint256 _destinationNetworkId,
        WithdrawRequestData calldata _withdrawRequestData
    ) external override nonReentrant returns (bytes32) {

        require(_amountIn > 0, "ERR: AMOUNT");
        require(paused() == false, "ERR: PAUSED");
        require(vaultConfig.pausedNetwork(_destinationNetworkId) == false, "ERR: PAUSED NETWORK");

        TemporaryWithdrawData memory tempData = _getTemporaryWithdrawData(
            _receiptToken,
            _tokenOut,
            _destinationNetworkId
        );

        require(IReceiptBase(_receiptToken).balanceOf(msg.sender) >= _amountIn, "ERR: BALANCE");
        IReceiptBase(_receiptToken).burn(msg.sender, _amountIn);

        emit WithdrawRequest(
            msg.sender,
            _receiptToken,
            tempData.tokenIn,
            _amountIn,
            _tokenOut,
            tempData.remoteTokenIn,
            _destinationAddress,
            _ammID,
            _destinationNetworkId,
            _data,
            tempData.id,
            _withdrawRequestData
        );

        return tempData.id;
    }

    function _getTemporaryWithdrawData(
        address _receiptToken,
        address _tokenOut,
        uint256 _networkId
    ) private validAddress(_tokenOut) returns (TemporaryWithdrawData memory) {

        address tokenIn = IReceiptBase(_receiptToken).underlyingToken();
        address remoteTokenIn;
        if (_networkId != block.chainid) {
            remoteTokenIn = vaultConfig.remoteTokenAddress(_networkId, tokenIn);
            require(remoteTokenIn != address(0), "ERR: TOKEN");
        } else {
            remoteTokenIn = tokenIn;
        }

        if (vaultConfig.getUnderlyingIOUAddress(tokenIn) == _receiptToken) {
            require(
                activeLiquidityAvailableAfterBlock[msg.sender][tokenIn] <= block.number,
                "ERR: LIQUIDITY"
            );
        } else if (vaultConfig.getUnderlyingReceiptAddress(tokenIn) == _receiptToken) {
            require(
                passiveLiquidityAvailableAfterTimestamp[msg.sender][tokenIn] <= block.timestamp,
                "ERR: LIQUIDITY"
            );
            require(remoteTokenIn == _tokenOut, "ERR: TOKEN OUT");
        } else {
            revert("ERR: TOKEN NOT WHITELISTED");
        }
        return TemporaryWithdrawData(tokenIn, remoteTokenIn, vaultConfig.generateId());
    }

    function withdrawLiquidity(
        address _accountTo,
        uint256 _amount,
        uint256 _requestedAmount,
        address _tokenIn,
        address _tokenOut,
        uint256 _amountOutMin,
        WithdrawData calldata _withdrawData,
        bytes calldata _data
    ) external override {

        uint256 withdrawAmount = _withdraw(
            _accountTo,
            _amount,
            _tokenIn,
            _tokenOut,
            _amountOutMin,
            _withdrawData,
            _data
        );

        emit LiquidityWithdrawn(
            _accountTo,
            _tokenIn,
            _tokenOut,
            _amount,
            _requestedAmount,
            withdrawAmount,
            _withdrawData.baseFee,
            _withdrawData.feePercentage,
            _withdrawData.amountToSwapToNative > 0,
            _withdrawData.id
        );
    }

    function withdrawTo(
        address _accountTo,
        uint256 _amount,
        address _tokenIn,
        address _tokenOut,
        uint256 _amountOutMin,
        WithdrawData calldata _withdrawData,
        bytes calldata _data
    ) external override {

        uint256 withdrawAmount = _withdraw(
            _accountTo,
            _amount,
            _tokenIn,
            _tokenOut,
            _amountOutMin,
            _withdrawData,
            _data
        );

        emit WithdrawalCompleted(
            _accountTo,
            _amount,
            withdrawAmount,
            _tokenOut,
            _withdrawData.id,
            _withdrawData.amountToSwapToNative > 0
        );
    }

    function _withdraw(
        address _accountTo,
        uint256 _amount,
        address _tokenIn,
        address _tokenOut,
        uint256 _amountOutMin,
        WithdrawData memory _withdrawData,
        bytes calldata _data
    )
        internal
        onlyWhitelistedToken(_tokenIn)
        validAddress(_tokenOut)
        nonReentrant
        onlyOwnerOrRelayer
        whenNotPaused
        returns (uint256 withdrawAmount)
    {

        IMosaicHolding mosaicHolding = IMosaicHolding(vaultConfig.getMosaicHolding());
        require(hasBeenWithdrawn[_withdrawData.id] == false, "ERR: WITHDRAWN");
        if (_tokenOut == _tokenIn) {
            require(
                mosaicHolding.getTokenLiquidity(_tokenIn, _withdrawData.investmentStrategies) >=
                    _amount,
                "ERR: VAULT BAL"
            );
        }
        if (_withdrawData.amountToSwapToNative > 0) {
            require(vaultConfig.ableToPerformSmallBalanceSwap(), "ERR: UNABLE");
        }
        require(_withdrawData.amountToSwapToNative <= _amount, "ERR: TOO HIGH");
        hasBeenWithdrawn[_withdrawData.id] = true;
        lastWithdrawID = _withdrawData.id;

        withdrawAmount = _takeFees(
            _tokenIn,
            _amount,
            _accountTo,
            _withdrawData.id,
            _withdrawData.baseFee,
            _withdrawData.feePercentage
        );

        mosaicHolding.coverWithdrawRequest(
            _withdrawData.investmentStrategies,
            _withdrawData.investmentStrategiesData,
            _tokenIn,
            withdrawAmount
        );
        if (_withdrawData.amountToSwapToNative > 0) {
            if (_withdrawData.amountToSwapToNative > withdrawAmount) {
                _withdrawData.amountToSwapToNative = withdrawAmount;
            }
            swapToNativeAndTransfer(
                _tokenIn,
                _accountTo,
                _withdrawData.amountToSwapToNative,
                _withdrawData.minAmountOutNative,
                _withdrawData.nativeSwapperId
            );
            withdrawAmount -= _withdrawData.amountToSwapToNative;
        }

        if (_tokenOut != _tokenIn) {
            withdrawAmount = _swap(
                withdrawAmount,
                _amountOutMin,
                _tokenIn,
                _tokenOut,
                _withdrawData.ammId,
                _data
            );
        }

        mosaicHolding.transfer(_tokenOut, _accountTo, withdrawAmount);
    }

    function swapToNativeAndTransfer(
        address _tokenIn,
        address _accountTo,
        uint256 _amountToNative,
        uint256 _minAmountOutNative,
        uint256 _nativeSwapperId
    ) internal {

        address mosaicNativeSwapperAddress = vaultConfig.supportedMosaicNativeSwappers(
            _nativeSwapperId
        );
        require(mosaicNativeSwapperAddress != address(0), "ERR: NOT SET");
        IMosaicNativeSwapper mosaicNativeSwapper = IMosaicNativeSwapper(mosaicNativeSwapperAddress);

        IMosaicHolding(vaultConfig.getMosaicHolding()).transfer(
            _tokenIn,
            address(this),
            _amountToNative
        );

        IERC20Upgradeable(_tokenIn).safeIncreaseAllowance(
            mosaicNativeSwapperAddress,
            _amountToNative
        );
        mosaicNativeSwapper.swapToNative(
            _tokenIn,
            _amountToNative,
            _minAmountOutNative,
            _accountTo,
            ""
        );
    }

    function revertLiquidityWithdrawalRequest(
        address _user,
        uint256 _amount,
        address _receiptToken,
        bytes32 _id
    ) external override onlyOwnerOrRelayer nonReentrant {

        require(_amount > 0, "ERR: AMOUNT");
        require(hasBeenRefunded[_id] == false, "REFUNDED");

        address tokenAddress = IReceiptBase(_receiptToken).underlyingToken();
        hasBeenRefunded[_id] = true;
        lastRefundedID = _id;

        require(
            tokenAddress != address(0) &&
                (vaultConfig.getUnderlyingReceiptAddress(tokenAddress) != address(0) ||
                    vaultConfig.getUnderlyingIOUAddress(tokenAddress) != address(0)),
            "ERR: TOKEN NOT WHITELISTED"
        );

        if (vaultConfig.getUnderlyingIOUAddress(tokenAddress) == _receiptToken) {
            IReceiptBase(vaultConfig.getUnderlyingIOUAddress(tokenAddress)).mint(_user, _amount);
        } else if (vaultConfig.getUnderlyingReceiptAddress(tokenAddress) == _receiptToken) {
            IReceiptBase(vaultConfig.getUnderlyingReceiptAddress(tokenAddress)).mint(
                _user,
                _amount
            );
        }

        emit LiquidityRefunded(tokenAddress, _receiptToken, _user, _amount, _id);
    }

    function _takeFees(
        address _token,
        uint256 _amount,
        address _accountTo,
        bytes32 _withdrawRequestId,
        uint256 _baseFee,
        uint256 _feePercentage
    ) private returns (uint256) {

        if (_baseFee > 0) {
            IMosaicHolding(vaultConfig.getMosaicHolding()).transfer(_token, relayer, _baseFee);
        }
        uint256 fee = 0;
        if (_feePercentage > 0) {
            require(
                _feePercentage >= vaultConfig.minFee() && _feePercentage <= vaultConfig.maxFee(),
                "ERR: OUT OF RANGE"
            );

            fee = FeeOperations.getFeeAbsolute(_amount, _feePercentage);

            IMosaicHolding(vaultConfig.getMosaicHolding()).transfer(
                _token,
                vaultConfig.getMosaicHolding(),
                fee
            );
        }

        uint256 totalFee = _baseFee + fee;
        require(totalFee < _amount, "ERR: FEE AMOUNT");
        if (totalFee > 0) {
            emit FeeTaken(
                msg.sender,
                _accountTo,
                _token,
                _amount,
                fee,
                _baseFee,
                fee + _baseFee,
                _withdrawRequestId
            );
        }
        return _amount - totalFee;
    }

    function _swap(
        uint256 _amountIn,
        uint256 _amountOutMin,
        address _tokenIn,
        address _tokenOut,
        uint256 _ammID,
        bytes memory _data
    ) private returns (uint256) {

        address mosaicHolding = vaultConfig.getMosaicHolding();
        IMosaicHolding(mosaicHolding).transfer(_tokenIn, address(this), _amountIn);
        address ammAddress = vaultConfig.supportedAMMs(_ammID);
        require(ammAddress != address(0), "ERR: AMM");

        IERC20Upgradeable(_tokenIn).safeApprove(ammAddress, _amountIn);

        uint256 amountToSend = IMosaicExchange(ammAddress).swap(
            _tokenIn,
            _tokenOut,
            _amountIn,
            _amountOutMin,
            _data
        );
        require(amountToSend >= _amountOutMin, "ERR: PRICE");
        IERC20Upgradeable(_tokenOut).safeTransfer(mosaicHolding, amountToSend);
        return amountToSend;
    }

    function transferERC20ToLayer(
        uint256 _amount,
        address _tokenAddress,
        address _remoteDestinationAddress,
        uint256 _remoteNetworkID,
        uint256 _maxTransferDelay,
        address _tokenOut,
        uint256 _remoteAmmId,
        uint256 _amountOutMin,
        bool _swapToNative
    )
        external
        override
        onlyWhitelistedRemoteTokens(_remoteNetworkID, _tokenAddress)
        nonReentrant
        whenNotPausedNetwork(_remoteNetworkID)
        returns (bytes32 transferId)
    {

        require(_amount > 0, "ERR: AMOUNT");

        transferId = vaultConfig.generateId();

        uint256[3] memory ammConfig;
        ammConfig[0] = _remoteAmmId;
        ammConfig[1] = _maxTransferDelay;
        ammConfig[2] = _amountOutMin;

        _transferERC20ToLayer(
            _amount,
            _tokenAddress,
            _remoteDestinationAddress,
            _remoteNetworkID,
            _tokenOut,
            ammConfig,
            transferId,
            _swapToNative
        );
    }

    function transferETHToLayer(
        address _remoteDestinationAddress,
        uint256 _remoteNetworkID,
        uint256 _maxTransferDelay,
        address _tokenOut,
        uint256 _remoteAmmId,
        uint256 _amountOutMin,
        bool _swapToNative
    )
        external
        payable
        override
        nonReentrant
        whenNotPausedNetwork(_remoteNetworkID)
        returns (bytes32 transferId)
    {

        require(msg.value > 0, "ERR: AMOUNT");
        address weth = vaultConfig.wethAddress();
        require(weth != address(0), "ERR: WETH");
        require(
            vaultConfig.getUnderlyingIOUAddress(weth) != address(0),
            "ERR: WETH NOT WHITELISTED"
        );
        require(
            vaultConfig.remoteTokenAddress(_remoteNetworkID, weth) != address(0),
            "ERR: ETH NOT WHITELISTED REMOTE"
        );

        uint256[3] memory ammConfig;
        ammConfig[0] = _remoteAmmId;
        ammConfig[1] = _maxTransferDelay;
        ammConfig[2] = _amountOutMin;

        transferId = vaultConfig.generateId();
        _transferERC20ToLayer(
            msg.value,
            vaultConfig.wethAddress(),
            _remoteDestinationAddress,
            _remoteNetworkID,
            _tokenOut,
            ammConfig,
            transferId,
            _swapToNative
        );
    }

    function _transferERC20ToLayer(
        uint256 _amount,
        address _tokenAddress,
        address _remoteDestinationAddress,
        uint256 _remoteNetworkID,
        address _tokenOut,
        uint256[3] memory _ammConfig, // 0 - amm id , 1 - delay, 2, amount out
        bytes32 _id,
        bool _swapToNative
    ) private inTokenTransferLimits(_tokenAddress, _amount) {

        if (_tokenAddress == vaultConfig.wethAddress()) {
            IWETH(_tokenAddress).deposit{value: _amount}();
            IERC20Upgradeable(_tokenAddress).safeTransfer(vaultConfig.getMosaicHolding(), _amount);
        } else {
            IERC20Upgradeable(_tokenAddress).safeTransferFrom(
                msg.sender,
                vaultConfig.getMosaicHolding(),
                _amount
            );
        }

        deposits[_id] = DepositInfo({token: _tokenAddress, amount: _amount});

        emit TransferInitiated(
            msg.sender,
            _tokenAddress,
            vaultConfig.remoteTokenAddress(_remoteNetworkID, _tokenAddress),
            _remoteNetworkID,
            _amount,
            _remoteDestinationAddress,
            _id,
            _ammConfig[1],
            _tokenOut,
            _ammConfig[0],
            _ammConfig[2],
            _swapToNative
        );
    }

    function refundTransferFunds(
        address _token,
        address _user,
        uint256 _amount,
        uint256 _originalAmount,
        bytes32 _id,
        address[] calldata _investmentStrategies,
        bytes[] calldata _investmentStrategiesData
    ) external override nonReentrant onlyOwnerOrRelayer {

        require(hasBeenRefunded[_id] == false, "ERR: REFUNDED");

        require(
            IMosaicHolding(vaultConfig.getMosaicHolding()).getTokenLiquidity(
                _token,
                _investmentStrategies
            ) >= _amount,
            "ERR: BAL"
        );

        require(
            deposits[_id].token == _token && deposits[_id].amount == _originalAmount,
            "ERR: DEPOSIT"
        );

        hasBeenRefunded[_id] = true;
        lastRefundedID = _id;

        IMosaicHolding mosaicHolding = IMosaicHolding(vaultConfig.getMosaicHolding());
        mosaicHolding.coverWithdrawRequest(
            _investmentStrategies,
            _investmentStrategiesData,
            _token,
            _amount
        );
        mosaicHolding.transfer(_token, _user, _amount);

        delete deposits[_id];

        emit TransferFundsRefunded(_token, _user, _amount, _originalAmount, _id);
    }

    function digestFunds(address _token) external override onlyOwner validAddress(_token) {

        uint256 balance = IERC20Upgradeable(_token).balanceOf(address(this));
        require(balance > 0, "ERR: BAL");
        IERC20Upgradeable(_token).safeTransfer(vaultConfig.getMosaicHolding(), balance);
        emit FundsDigested(_token, balance);
    }

    receive() external payable {
        provideActiveLiquidity(0, address(0), vaultConfig.maxLimitLiquidityBlocks());
    }

    function pause() external override whenNotPaused onlyOwner {

        _pause();
    }

    function unpause() external override whenPaused onlyOwner {

        _unpause();
    }

    modifier validAddress(address _address) {

        require(_address != address(0), "ERR: INVALID ADDRESS");
        _;
    }

    modifier onlyWhitelistedToken(address _tokenAddress) {

        require(
            vaultConfig.getUnderlyingIOUAddress(_tokenAddress) != address(0),
            "ERR: TOKEN NOT WHITELISTED"
        );
        _;
    }

    modifier onlyWhitelistedRemoteTokens(uint256 _networkID, address _tokenAddress) {

        require(
            vaultConfig.remoteTokenAddress(_networkID, _tokenAddress) != address(0),
            "ERR: TOKEN NOT WHITELISTED DESTINATION"
        );
        _;
    }

    modifier whenNotPausedNetwork(uint256 _networkID) {

        require(paused() == false, "ERR: PAUSED");
        require(vaultConfig.pausedNetwork(_networkID) == false, "ERR: PAUSED NETWORK");
        _;
    }

    modifier onlyOwnerOrRelayer() {

        require(_msgSender() == owner() || _msgSender() == relayer, "ERR: PERMISSIONS");
        _;
    }

    modifier inTokenTransferLimits(address _token, uint256 _amount) {

        require(vaultConfig.inTokenTransferLimits(_token, _amount), "ERR: TRANSFER LIMITS");
        _;
    }

    modifier inBlockApproveRange(uint256 _blocksForActiveLiquidity) {

        require(
            _blocksForActiveLiquidity >= vaultConfig.minLimitLiquidityBlocks() &&
                _blocksForActiveLiquidity <= vaultConfig.maxLimitLiquidityBlocks(),
            "ERR: BLOCK RANGE"
        );
        _;
    }
}