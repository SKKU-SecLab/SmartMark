
pragma solidity 0.8.2;


interface ILiquidator {

    function createLiquidation(
        address _integration,
        address _sellToken,
        address _bAsset,
        bytes calldata _uniswapPath,
        bytes calldata _uniswapPathReversed,
        uint256 _trancheAmount,
        uint256 _minReturn,
        address _mAsset,
        bool _useAave
    ) external;


    function updateBasset(
        address _integration,
        address _bAsset,
        bytes calldata _uniswapPath,
        bytes calldata _uniswapPathReversed,
        uint256 _trancheAmount,
        uint256 _minReturn
    ) external;


    function deleteLiquidation(address _integration) external;


    function triggerLiquidation(address _integration) external;


    function claimStakedAave() external;


    function triggerLiquidationAave() external;

}

interface ISavingsManager {

    function distributeUnallocatedInterest(address _mAsset) external;


    function depositLiquidation(address _mAsset, uint256 _liquidation) external;


    function collectAndStreamInterest(address _mAsset) external;


    function collectAndDistributeInterest(address _mAsset) external;


    function lastBatchCollected(address _mAsset) external view returns (uint256);

}

struct BassetPersonal {
    address addr;
    address integrator;
    bool hasTxFee; // takes a byte in storage
    BassetStatus status;
}

enum BassetStatus {
    Default,
    Normal,
    BrokenBelowPeg,
    BrokenAbovePeg,
    Blacklisted,
    Liquidating,
    Liquidated,
    Failed
}

struct BassetData {
    uint128 ratio;
    uint128 vaultBalance;
}

abstract contract IMasset {
    function mint(
        address _input,
        uint256 _inputQuantity,
        uint256 _minOutputQuantity,
        address _recipient
    ) external virtual returns (uint256 mintOutput);

    function mintMulti(
        address[] calldata _inputs,
        uint256[] calldata _inputQuantities,
        uint256 _minOutputQuantity,
        address _recipient
    ) external virtual returns (uint256 mintOutput);

    function getMintOutput(address _input, uint256 _inputQuantity)
        external
        view
        virtual
        returns (uint256 mintOutput);

    function getMintMultiOutput(address[] calldata _inputs, uint256[] calldata _inputQuantities)
        external
        view
        virtual
        returns (uint256 mintOutput);

    function swap(
        address _input,
        address _output,
        uint256 _inputQuantity,
        uint256 _minOutputQuantity,
        address _recipient
    ) external virtual returns (uint256 swapOutput);

    function getSwapOutput(
        address _input,
        address _output,
        uint256 _inputQuantity
    ) external view virtual returns (uint256 swapOutput);

    function redeem(
        address _output,
        uint256 _mAssetQuantity,
        uint256 _minOutputQuantity,
        address _recipient
    ) external virtual returns (uint256 outputQuantity);

    function redeemMasset(
        uint256 _mAssetQuantity,
        uint256[] calldata _minOutputQuantities,
        address _recipient
    ) external virtual returns (uint256[] memory outputQuantities);

    function redeemExactBassets(
        address[] calldata _outputs,
        uint256[] calldata _outputQuantities,
        uint256 _maxMassetQuantity,
        address _recipient
    ) external virtual returns (uint256 mAssetRedeemed);

    function getRedeemOutput(address _output, uint256 _mAssetQuantity)
        external
        view
        virtual
        returns (uint256 bAssetOutput);

    function getRedeemExactBassetsOutput(
        address[] calldata _outputs,
        uint256[] calldata _outputQuantities
    ) external view virtual returns (uint256 mAssetAmount);

    function getBasket() external view virtual returns (bool, bool);

    function getBasset(address _token)
        external
        view
        virtual
        returns (BassetPersonal memory personal, BassetData memory data);

    function getBassets()
        external
        view
        virtual
        returns (BassetPersonal[] memory personal, BassetData[] memory data);

    function bAssetIndexes(address) external view virtual returns (uint8);

    function getPrice() external view virtual returns (uint256 price, uint256 k);

    function collectInterest() external virtual returns (uint256 swapFeesGained, uint256 newSupply);

    function collectPlatformInterest()
        external
        virtual
        returns (uint256 mintAmount, uint256 newSupply);

    function setCacheSize(uint256 _cacheSize) external virtual;

    function setFees(uint256 _swapFee, uint256 _redemptionFee) external virtual;

    function setTransferFeesFlag(address _bAsset, bool _flag) external virtual;

    function migrateBassets(address[] calldata _bAssets, address _newIntegration) external virtual;
}

interface IStakedAave {

    function COOLDOWN_SECONDS() external returns (uint256);


    function UNSTAKE_WINDOW() external returns (uint256);


    function stake(address to, uint256 amount) external;


    function redeem(address to, uint256 amount) external;


    function cooldown() external;


    function claimRewards(address to, uint256 amount) external;


    function stakersCooldowns(address staker) external returns (uint256);

}

interface IUniswapV3SwapRouter {

    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);


    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);


    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    function exactOutputSingle(ExactOutputSingleParams calldata params) external payable returns (uint256 amountIn);


    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    function exactOutput(ExactOutputParams calldata params) external payable returns (uint256 amountIn);

}

interface IUniswapV3Quoter {

    function quoteExactInput(bytes memory path, uint256 amountIn) external returns (uint256 amountOut);


    function quoteExactInputSingle(
        address tokenIn,
        address tokenOut,
        uint24 fee,
        uint256 amountIn,
        uint160 sqrtPriceLimitX96
    ) external returns (uint256 amountOut);


    function quoteExactOutput(bytes memory path, uint256 amountOut) external returns (uint256 amountIn);


    function quoteExactOutputSingle(
        address tokenIn,
        address tokenOut,
        uint24 fee,
        uint256 amountOut,
        uint160 sqrtPriceLimitX96
    ) external returns (uint256 amountIn);

}

interface IClaimRewards {

    function claimRewards() external;

}

contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  function isConstructor() private view returns (bool) {

    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}

contract ModuleKeysStorage {

    bytes32 private DEPRECATED_KEY_GOVERNANCE;
    bytes32 private DEPRECATED_KEY_STAKING;
    bytes32 private DEPRECATED_KEY_PROXY_ADMIN;
    bytes32 private DEPRECATED_KEY_ORACLE_HUB;
    bytes32 private DEPRECATED_KEY_MANAGER;
    bytes32 private DEPRECATED_KEY_RECOLLATERALISER;
    bytes32 private DEPRECATED_KEY_META_TOKEN;
    bytes32 private DEPRECATED_KEY_SAVINGS_MANAGER;
}

contract ModuleKeys {

    bytes32 internal constant KEY_GOVERNANCE =
        0x9409903de1e6fd852dfc61c9dacb48196c48535b60e25abf92acc92dd689078d;
    bytes32 internal constant KEY_STAKING =
        0x1df41cd916959d1163dc8f0671a666ea8a3e434c13e40faef527133b5d167034;
    bytes32 internal constant KEY_PROXY_ADMIN =
        0x96ed0203eb7e975a4cbcaa23951943fa35c5d8288117d50c12b3d48b0fab48d1;

    bytes32 internal constant KEY_ORACLE_HUB =
        0x8ae3a082c61a7379e2280f3356a5131507d9829d222d853bfa7c9fe1200dd040;
    bytes32 internal constant KEY_MANAGER =
        0x6d439300980e333f0256d64be2c9f67e86f4493ce25f82498d6db7f4be3d9e6f;
    bytes32 internal constant KEY_RECOLLATERALISER =
        0x39e3ed1fc335ce346a8cbe3e64dd525cf22b37f1e2104a755e761c3c1eb4734f;
    bytes32 internal constant KEY_META_TOKEN =
        0xea7469b14936af748ee93c53b2fe510b9928edbdccac3963321efca7eb1a57a2;
    bytes32 internal constant KEY_SAVINGS_MANAGER =
        0x12fe936c77a1e196473c4314f3bed8eeac1d757b319abb85bdda70df35511bf1;
    bytes32 internal constant KEY_LIQUIDATOR =
        0x1e9cb14d7560734a61fa5ff9273953e971ff3cd9283c03d8346e3264617933d4;
    bytes32 internal constant KEY_INTEREST_VALIDATOR =
        0xc10a28f028c7f7282a03c90608e38a4a646e136e614e4b07d119280c5f7f839f;
}

interface INexus {

    function governor() external view returns (address);


    function getModule(bytes32 key) external view returns (address);


    function proposeModule(bytes32 _key, address _addr) external;


    function cancelProposedModule(bytes32 _key) external;


    function acceptProposedModule(bytes32 _key) external;


    function acceptProposedModules(bytes32[] calldata _keys) external;


    function requestLockModule(bytes32 _key) external;


    function cancelLockModule(bytes32 _key) external;


    function lockModule(bytes32 _key) external;

}

abstract contract ImmutableModule is ModuleKeys {
    INexus public immutable nexus;

    constructor(address _nexus) {
        require(_nexus != address(0), "Nexus address is zero");
        nexus = INexus(_nexus);
    }

    modifier onlyGovernor() {
        _onlyGovernor();
        _;
    }

    function _onlyGovernor() internal view {
        require(msg.sender == _governor(), "Only governor can execute");
    }

    modifier onlyGovernance() {
        require(
            msg.sender == _governor() || msg.sender == _governance(),
            "Only governance can execute"
        );
        _;
    }

    function _governor() internal view returns (address) {
        return nexus.governor();
    }

    function _governance() internal view returns (address) {
        return nexus.getModule(KEY_GOVERNANCE);
    }

    function _savingsManager() internal view returns (address) {
        return nexus.getModule(KEY_SAVINGS_MANAGER);
    }

    function _recollateraliser() internal view returns (address) {
        return nexus.getModule(KEY_RECOLLATERALISER);
    }

    function _liquidator() internal view returns (address) {
        return nexus.getModule(KEY_LIQUIDATOR);
    }

    function _proxyAdmin() internal view returns (address) {
        return nexus.getModule(KEY_PROXY_ADMIN);
    }
}

interface IBasicToken {

    function decimals() external view returns (uint8);

}

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

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
}

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
}

contract Liquidator is ILiquidator, Initializable, ModuleKeysStorage, ImmutableModule {

    using SafeERC20 for IERC20;

    event LiquidationModified(address indexed integration);
    event LiquidationEnded(address indexed integration);
    event Liquidated(address indexed sellToken, address mUSD, uint256 mUSDAmount, address buyToken);
    event ClaimedStakedAave(uint256 rewardsAmount);
    event RedeemedAave(uint256 redeemedAmount);

    address private deprecated_nexus;
    address public deprecated_mUSD;
    address public deprecated_curve;
    address public deprecated_uniswap;
    uint256 private deprecated_interval = 7 days;
    mapping(address => DeprecatedLiquidation) public deprecated_liquidations;
    mapping(address => uint256) public deprecated_minReturn;

    mapping(address => Liquidation) public liquidations;
    address[] public aaveIntegrations;
    uint256 public totalAaveBalance;

    address public immutable stkAave;
    address public immutable aaveToken;
    IUniswapV3SwapRouter public immutable uniswapRouter;
    IUniswapV3Quoter public immutable uniswapQuoter;
    address public immutable compToken;
    address public immutable alchemixToken;

    struct DeprecatedLiquidation {
        address sellToken;
        address bAsset;
        int128 curvePosition;
        address[] uniswapPath;
        uint256 lastTriggered;
        uint256 trancheAmount;
    }

    struct Liquidation {
        address sellToken;
        address bAsset;
        bytes uniswapPath;
        bytes uniswapPathReversed;
        uint256 lastTriggered;
        uint256 trancheAmount; // The max amount of bAsset units to buy each week, with token decimals
        uint256 minReturn;
        address mAsset;
        uint256 aaveBalance;
    }

    constructor(
        address _nexus,
        address _stkAave,
        address _aaveToken,
        address _uniswapRouter,
        address _uniswapQuoter,
        address _compToken,
        address _alchemixToken
    ) ImmutableModule(_nexus) {
        require(_stkAave != address(0), "Invalid stkAAVE address");
        stkAave = _stkAave;

        require(_aaveToken != address(0), "Invalid AAVE address");
        aaveToken = _aaveToken;

        require(_uniswapRouter != address(0), "Invalid Uniswap Router address");
        uniswapRouter = IUniswapV3SwapRouter(_uniswapRouter);

        require(_uniswapQuoter != address(0), "Invalid Uniswap Quoter address");
        uniswapQuoter = IUniswapV3Quoter(_uniswapQuoter);

        require(_compToken != address(0), "Invalid COMP address");
        compToken = _compToken;

        require(_alchemixToken != address(0), "Invalid ALCX address");
        alchemixToken = _alchemixToken;
    }

    function initialize() external initializer {

        IERC20(aaveToken).safeApprove(address(uniswapRouter), type(uint256).max);
        IERC20(compToken).safeApprove(address(uniswapRouter), type(uint256).max);
    }

    function upgrade() external {

        IERC20(alchemixToken).safeApprove(address(uniswapRouter), type(uint256).max);
    }


    function createLiquidation(
        address _integration,
        address _sellToken,
        address _bAsset,
        bytes calldata _uniswapPath,
        bytes calldata _uniswapPathReversed,
        uint256 _trancheAmount,
        uint256 _minReturn,
        address _mAsset,
        bool _useAave
    ) external override onlyGovernance {

        require(liquidations[_integration].sellToken == address(0), "Liquidation already exists");

        require(
            _integration != address(0) &&
                _sellToken != address(0) &&
                _bAsset != address(0) &&
                _minReturn > 0,
            "Invalid inputs"
        );
        require(_validUniswapPath(_sellToken, _bAsset, _uniswapPath), "Invalid uniswap path");
        require(
            _validUniswapPath(_bAsset, _sellToken, _uniswapPathReversed),
            "Invalid uniswap path reversed"
        );

        liquidations[_integration] = Liquidation({
            sellToken: _sellToken,
            bAsset: _bAsset,
            uniswapPath: _uniswapPath,
            uniswapPathReversed: _uniswapPathReversed,
            lastTriggered: 0,
            trancheAmount: _trancheAmount,
            minReturn: _minReturn,
            mAsset: _mAsset,
            aaveBalance: 0
        });
        if (_useAave) {
            aaveIntegrations.push(_integration);
        }

        if (_mAsset != address(0)) {
            IERC20(_bAsset).safeApprove(_mAsset, 0);
            IERC20(_bAsset).safeApprove(_mAsset, type(uint256).max);

            address savings = _savingsManager();
            IERC20(_mAsset).safeApprove(savings, 0);
            IERC20(_mAsset).safeApprove(savings, type(uint256).max);
        }

        emit LiquidationModified(_integration);
    }

    function updateBasset(
        address _integration,
        address _bAsset,
        bytes calldata _uniswapPath,
        bytes calldata _uniswapPathReversed,
        uint256 _trancheAmount,
        uint256 _minReturn
    ) external override onlyGovernance {

        Liquidation memory liquidation = liquidations[_integration];

        address oldBasset = liquidation.bAsset;
        require(oldBasset != address(0), "Liquidation does not exist");

        require(_minReturn > 0, "Must set some minimum value");
        require(_bAsset != address(0), "Invalid bAsset");
        require(
            _validUniswapPath(liquidation.sellToken, _bAsset, _uniswapPath),
            "Invalid uniswap path"
        );
        require(
            _validUniswapPath(_bAsset, liquidation.sellToken, _uniswapPathReversed),
            "Invalid uniswap path reversed"
        );

        liquidations[_integration].bAsset = _bAsset;
        liquidations[_integration].uniswapPath = _uniswapPath;
        liquidations[_integration].trancheAmount = _trancheAmount;
        liquidations[_integration].minReturn = _minReturn;

        emit LiquidationModified(_integration);
    }

    function _validUniswapPath(
        address _sellToken,
        address _bAsset,
        bytes calldata _uniswapPath
    ) internal pure returns (bool) {

        uint256 len = _uniswapPath.length;
        require(_uniswapPath.length >= 43, "Uniswap path too short");
        return
            keccak256(abi.encodePacked(_sellToken)) ==
            keccak256(abi.encodePacked(_uniswapPath[0:20])) &&
            keccak256(abi.encodePacked(_bAsset)) ==
            keccak256(abi.encodePacked(_uniswapPath[len - 20:len]));
    }

    function deleteLiquidation(address _integration) external override onlyGovernance {

        Liquidation memory liquidation = liquidations[_integration];
        require(liquidation.bAsset != address(0), "Liquidation does not exist");

        delete liquidations[_integration];

        emit LiquidationEnded(_integration);
    }


    function triggerLiquidation(address _integration) external override {

        Liquidation memory liquidation = liquidations[_integration];

        address bAsset = liquidation.bAsset;
        require(bAsset != address(0), "Liquidation does not exist");

        require(block.timestamp > liquidation.lastTriggered + 7 days, "Must wait for interval");
        liquidations[_integration].lastTriggered = block.timestamp;

        address sellToken = liquidation.sellToken;

        uint256 integrationBal = IERC20(sellToken).balanceOf(_integration);
        if (integrationBal > 0) {
            IERC20(sellToken).safeTransferFrom(_integration, address(this), integrationBal);
        }

        uint256 sellTokenBal = IERC20(sellToken).balanceOf(address(this));
        require(sellTokenBal > 0, "No sell tokens to liquidate");
        require(liquidation.trancheAmount > 0, "Liquidation has been paused");
        uint256 sellAmount =
            uniswapQuoter.quoteExactOutput(
                liquidation.uniswapPathReversed,
                liquidation.trancheAmount
            );

        if (sellTokenBal < sellAmount) {
            sellAmount = sellTokenBal;
        }

        uint256 sellTokenDec = IBasicToken(sellToken).decimals();
        uint256 minOut = (sellAmount * liquidation.minReturn) / (10**sellTokenDec);
        require(minOut > 0, "Must have some price floor");
        IUniswapV3SwapRouter.ExactInputParams memory param =
            IUniswapV3SwapRouter.ExactInputParams(
                liquidation.uniswapPath,
                address(this),
                block.timestamp,
                sellAmount,
                minOut
            );
        uniswapRouter.exactInput(param);

        address mAsset = liquidation.mAsset;
        if (mAsset != address(0)) {
            uint256 minted = _mint(bAsset, mAsset);

            address savings = _savingsManager();
            ISavingsManager(savings).depositLiquidation(mAsset, minted);

            emit Liquidated(sellToken, mAsset, minted, bAsset);
        } else {
            IERC20 bAssetToken = IERC20(bAsset);
            uint256 bAssetBal = bAssetToken.balanceOf(address(this));
            bAssetToken.transfer(_integration, bAssetBal);

            emit Liquidated(sellToken, mAsset, bAssetBal, bAsset);
        }
    }

    function claimStakedAave() external override {

        uint256 totalAaveBalanceMemory = totalAaveBalance;
        if (totalAaveBalanceMemory > 0) {
            IStakedAave stkAaveContract = IStakedAave(stkAave);
            uint256 cooldownStartTime = stkAaveContract.stakersCooldowns(address(this));
            uint256 cooldownPeriod = stkAaveContract.COOLDOWN_SECONDS();
            uint256 unstakeWindow = stkAaveContract.UNSTAKE_WINDOW();

            require(
                block.timestamp > cooldownStartTime + cooldownPeriod,
                "Last claim cooldown not ended"
            );
            require(
                block.timestamp > cooldownStartTime + cooldownPeriod + unstakeWindow,
                "Must liquidate last claim"
            );
        }

        uint256 len = aaveIntegrations.length;
        for (uint256 i = 0; i < len; i++) {
            address integrationAdddress = aaveIntegrations[i];

            IClaimRewards(integrationAdddress).claimRewards();

            uint256 integrationBal = IERC20(stkAave).balanceOf(integrationAdddress);
            if (integrationBal > 0) {
                IERC20(stkAave).safeTransferFrom(
                    integrationAdddress,
                    address(this),
                    integrationBal
                );
            }
            liquidations[integrationAdddress].aaveBalance += integrationBal;
            totalAaveBalanceMemory += integrationBal;
        }

        totalAaveBalance = totalAaveBalanceMemory;

        IStakedAave(stkAave).cooldown();

        emit ClaimedStakedAave(totalAaveBalanceMemory);
    }

    function triggerLiquidationAave() external override {

        require(tx.origin == msg.sender, "Must be EOA");
        require(totalAaveBalance > 0, "Must claim before liquidation");

        IStakedAave(stkAave).redeem(address(this), type(uint256).max);

        uint256 totalAaveToLiquidate = IERC20(aaveToken).balanceOf(address(this));
        require(totalAaveToLiquidate > 0, "No Aave redeemed from stkAave");

        uint256 len = aaveIntegrations.length;
        for (uint256 i = 0; i < len; i++) {
            address _integration = aaveIntegrations[i];
            Liquidation memory liquidation = liquidations[_integration];

            uint256 aaveSellAmount =
                (liquidation.aaveBalance * totalAaveToLiquidate) / totalAaveBalance;
            address bAsset = liquidation.bAsset;
            if (aaveSellAmount == 0 || bAsset == address(0)) {
                continue;
            }

            liquidations[_integration].aaveBalance = 0;

            uint256 minBassetsOut = (aaveSellAmount * liquidation.minReturn) / 1e18;
            require(minBassetsOut > 0, "Must have some price floor");
            IUniswapV3SwapRouter.ExactInputParams memory param =
                IUniswapV3SwapRouter.ExactInputParams(
                    liquidation.uniswapPath,
                    address(this),
                    block.timestamp + 1,
                    aaveSellAmount,
                    minBassetsOut
                );
            uniswapRouter.exactInput(param);

            address mAsset = liquidation.mAsset;
            if (mAsset != address(0)) {
                uint256 minted = _mint(bAsset, mAsset);

                address savings = _savingsManager();
                ISavingsManager(savings).depositLiquidation(mAsset, minted);

                emit Liquidated(aaveToken, mAsset, minted, bAsset);
            } else {
                IERC20 bAssetToken = IERC20(bAsset);
                uint256 bAssetBal = bAssetToken.balanceOf(address(this));
                bAssetToken.transfer(_integration, bAssetBal);

                emit Liquidated(aaveToken, mAsset, bAssetBal, bAsset);
            }
        }

        totalAaveBalance = 0;
    }

    function _mint(address _bAsset, address _mAsset) internal returns (uint256 minted) {

        uint256 bAssetBal = IERC20(_bAsset).balanceOf(address(this));

        uint256 bAssetDec = IBasicToken(_bAsset).decimals();
        uint256 minOut = (bAssetBal * 90e16) / (10**bAssetDec);
        minted = IMasset(_mAsset).mint(_bAsset, bAssetBal, minOut, address(this));
    }
}