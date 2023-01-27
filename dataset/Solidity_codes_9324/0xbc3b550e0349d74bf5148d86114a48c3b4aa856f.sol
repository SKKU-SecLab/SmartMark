
pragma solidity 0.8.6;


struct BassetPersonal {
    address addr;
    address integrator;
    bool hasTxFee; // takes a byte in storage
    BassetStatus status;
}

struct BassetData {
    uint128 ratio;
    uint128 vaultBalance;
}

enum BassetStatus {
    Default,
    Normal,
    BrokenBelowPeg,
    BrokenAbovePeg,
    Blacklisted,
    Liquidating,
    Liquidated,
    Fail
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
}

interface ISavingsContractV2 {

    function redeem(uint256 _amount) external returns (uint256 massetReturned);


    function creditBalances(address) external view returns (uint256); // V1 & V2 (use balanceOf)



    function depositInterest(uint256 _amount) external; // V1 & V2


    function depositSavings(uint256 _amount) external returns (uint256 creditsIssued); // V1 & V2


    function depositSavings(uint256 _amount, address _beneficiary)
        external
        returns (uint256 creditsIssued); // V2


    function redeemCredits(uint256 _amount) external returns (uint256 underlyingReturned); // V2


    function redeemUnderlying(uint256 _amount) external returns (uint256 creditsBurned); // V2


    function exchangeRate() external view returns (uint256); // V1 & V2


    function balanceOfUnderlying(address _user) external view returns (uint256 underlying); // V2


    function underlyingToCredits(uint256 _underlying) external view returns (uint256 credits); // V2


    function creditsToUnderlying(uint256 _credits) external view returns (uint256 underlying); // V2


    function underlying() external view returns (IERC20 underlyingMasset); // V2

}

interface IRevenueRecipient {

    function notifyRedistributionAmount(address _mAsset, uint256 _amount) external;


    function depositToPool(address[] calldata _mAssets, uint256[] calldata _percentages) external;

}

interface ISavingsManager {

    function distributeUnallocatedInterest(address _mAsset) external;


    function depositLiquidation(address _mAsset, uint256 _liquidation) external;


    function collectAndStreamInterest(address _mAsset) external;


    function collectAndDistributeInterest(address _mAsset) external;


    function lastBatchCollected(address _mAsset) external view returns (uint256);

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

abstract contract PausableModule is ImmutableModule {
    event Paused(address account);

    event Unpaused(address account);

    bool internal _paused = false;

    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    constructor(address _nexus) ImmutableModule(_nexus) {
        _paused = false;
    }

    function paused() external view returns (bool) {
        return _paused;
    }

    function pause() external onlyGovernor whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    function unpause() external onlyGovernor whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {

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
}

library StableMath {

    uint256 private constant FULL_SCALE = 1e18;

    uint256 private constant RATIO_SCALE = 1e8;

    function getFullScale() internal pure returns (uint256) {

        return FULL_SCALE;
    }

    function getRatioScale() internal pure returns (uint256) {

        return RATIO_SCALE;
    }

    function scaleInteger(uint256 x) internal pure returns (uint256) {

        return x * FULL_SCALE;
    }


    function mulTruncate(uint256 x, uint256 y) internal pure returns (uint256) {

        return mulTruncateScale(x, y, FULL_SCALE);
    }

    function mulTruncateScale(
        uint256 x,
        uint256 y,
        uint256 scale
    ) internal pure returns (uint256) {

        return (x * y) / scale;
    }

    function mulTruncateCeil(uint256 x, uint256 y) internal pure returns (uint256) {

        uint256 scaled = x * y;
        uint256 ceil = scaled + FULL_SCALE - 1;
        return ceil / FULL_SCALE;
    }

    function divPrecisely(uint256 x, uint256 y) internal pure returns (uint256) {

        return (x * FULL_SCALE) / y;
    }


    function mulRatioTruncate(uint256 x, uint256 ratio) internal pure returns (uint256 c) {

        return mulTruncateScale(x, ratio, RATIO_SCALE);
    }

    function mulRatioTruncateCeil(uint256 x, uint256 ratio) internal pure returns (uint256) {

        uint256 scaled = x * ratio;
        uint256 ceil = scaled + RATIO_SCALE - 1;
        return ceil / RATIO_SCALE;
    }

    function divRatioPrecisely(uint256 x, uint256 ratio) internal pure returns (uint256 c) {

        return (x * RATIO_SCALE) / ratio;
    }


    function min(uint256 x, uint256 y) internal pure returns (uint256) {

        return x > y ? y : x;
    }

    function max(uint256 x, uint256 y) internal pure returns (uint256) {

        return x > y ? x : y;
    }

    function clamp(uint256 x, uint256 upperBound) internal pure returns (uint256) {

        return x > upperBound ? upperBound : x;
    }
}

library YieldValidator {

    uint256 private constant SECONDS_IN_YEAR = 365 days;
    uint256 private constant THIRTY_MINUTES = 30 minutes;

    uint256 private constant MAX_APY = 15e18;
    uint256 private constant TEN_BPS = 1e15;

    function validateCollection(
        uint256 _newSupply,
        uint256 _interest,
        uint256 _timeSinceLastCollection
    ) internal pure returns (uint256 extrapolatedAPY) {

        return
            validateCollection(_newSupply, _interest, _timeSinceLastCollection, MAX_APY, TEN_BPS);
    }

    function validateCollection(
        uint256 _newSupply,
        uint256 _interest,
        uint256 _timeSinceLastCollection,
        uint256 _maxApy,
        uint256 _baseApy
    ) internal pure returns (uint256 extrapolatedAPY) {

        uint256 protectedTime = _timeSinceLastCollection == 0 ? 1 : _timeSinceLastCollection;

        uint256 oldSupply = _newSupply - _interest;
        uint256 percentageIncrease = (_interest * 1e18) / oldSupply;

        uint256 yearsSinceLastCollection = (protectedTime * 1e18) / SECONDS_IN_YEAR;

        extrapolatedAPY = (percentageIncrease * 1e18) / yearsSinceLastCollection;

        if (protectedTime > THIRTY_MINUTES) {
            require(extrapolatedAPY < _maxApy, "Interest protected from inflating past maxAPY");
        } else {
            require(percentageIncrease < _baseApy, "Interest protected from inflating past 10 Bps");
        }
    }
}

contract SavingsManager is ISavingsManager, PausableModule {

    using StableMath for uint256;
    using SafeERC20 for IERC20;

    event RevenueRecipientSet(address indexed mAsset, address recipient);
    event SavingsContractAdded(address indexed mAsset, address savingsContract);
    event SavingsContractUpdated(address indexed mAsset, address savingsContract);
    event SavingsRateChanged(uint256 newSavingsRate);
    event StreamsFrozen();
    event LiquidatorDeposited(address indexed mAsset, uint256 amount);
    event InterestCollected(
        address indexed mAsset,
        uint256 interest,
        uint256 newTotalSupply,
        uint256 apy
    );
    event InterestDistributed(address indexed mAsset, uint256 amountSent);
    event RevenueRedistributed(address indexed mAsset, address recipient, uint256 amount);

    mapping(address => ISavingsContractV2) public savingsContracts;
    mapping(address => IRevenueRecipient) public revenueRecipients;
    mapping(address => uint256) public lastPeriodStart;
    mapping(address => uint256) public lastCollection;
    mapping(address => uint256) public periodYield;

    uint256 private savingsRate;
    uint256 private immutable DURATION; // measure in days. eg 1 days or 7 days
    uint256 private constant ONE_DAY = 1 days;
    uint256 private constant THIRTY_MINUTES = 30 minutes;
    bool private streamsFrozen = false;
    mapping(address => Stream) public liqStream;
    mapping(address => Stream) public yieldStream;
    mapping(address => uint256) public override lastBatchCollected;

    enum StreamType {
        liquidator,
        yield
    }

    struct Stream {
        uint256 end;
        uint256 rate;
    }

    constructor(
        address _nexus,
        address[] memory _mAssets,
        address[] memory _savingsContracts,
        address[] memory _revenueRecipients,
        uint256 _savingsRate,
        uint256 _duration
    ) PausableModule(_nexus) {
        uint256 len = _mAssets.length;
        require(
            _savingsContracts.length == len && _revenueRecipients.length == len,
            "Invalid inputs"
        );
        for (uint256 i = 0; i < len; i++) {
            _updateSavingsContract(_mAssets[i], _savingsContracts[i]);
            emit SavingsContractAdded(_mAssets[i], _savingsContracts[i]);

            revenueRecipients[_mAssets[i]] = IRevenueRecipient(_revenueRecipients[i]);
            emit RevenueRecipientSet(_mAssets[i], _revenueRecipients[i]);
        }
        savingsRate = _savingsRate;
        DURATION = _duration;
    }

    modifier onlyLiquidator() {

        require(msg.sender == _liquidator(), "Only liquidator can execute");
        _;
    }

    modifier whenStreamsNotFrozen() {

        require(!streamsFrozen, "Streaming is currently frozen");
        _;
    }


    function addSavingsContract(address _mAsset, address _savingsContract) external onlyGovernor {

        require(
            address(savingsContracts[_mAsset]) == address(0),
            "Savings contract already exists"
        );
        _updateSavingsContract(_mAsset, _savingsContract);
        emit SavingsContractAdded(_mAsset, _savingsContract);
    }

    function updateSavingsContract(address _mAsset, address _savingsContract)
        external
        onlyGovernor
    {

        require(
            address(savingsContracts[_mAsset]) != address(0),
            "Savings contract does not exist"
        );
        _updateSavingsContract(_mAsset, _savingsContract);
        emit SavingsContractUpdated(_mAsset, _savingsContract);
    }

    function _updateSavingsContract(address _mAsset, address _savingsContract) internal {

        require(_mAsset != address(0) && _savingsContract != address(0), "Must be valid address");
        savingsContracts[_mAsset] = ISavingsContractV2(_savingsContract);

        IERC20(_mAsset).safeApprove(address(_savingsContract), 0);
        IERC20(_mAsset).safeApprove(address(_savingsContract), type(uint256).max);
    }

    function freezeStreams() external onlyGovernor whenStreamsNotFrozen {

        streamsFrozen = true;

        emit StreamsFrozen();
    }

    function setRevenueRecipient(address _mAsset, address _recipient) external onlyGovernor {

        revenueRecipients[_mAsset] = IRevenueRecipient(_recipient);

        emit RevenueRecipientSet(_mAsset, _recipient);
    }

    function setSavingsRate(uint256 _savingsRate) external onlyGovernor {

        require(_savingsRate >= 25e16 && _savingsRate <= 1e18, "Must be a valid rate");
        savingsRate = _savingsRate;
        emit SavingsRateChanged(_savingsRate);
    }

    function depositLiquidation(address _mAsset, uint256 _liquidated)
        external
        override
        whenNotPaused
        onlyLiquidator
        whenStreamsNotFrozen
    {

        _collectAndDistributeInterest(_mAsset);

        IERC20(_mAsset).safeTransferFrom(_liquidator(), address(this), _liquidated);

        uint256 leftover = _unstreamedRewards(_mAsset, StreamType.liquidator);
        _initialiseStream(_mAsset, StreamType.liquidator, _liquidated + leftover, DURATION);

        emit LiquidatorDeposited(_mAsset, _liquidated);
    }

    function collectAndStreamInterest(address _mAsset)
        external
        override
        whenNotPaused
        whenStreamsNotFrozen
    {

        _collectAndDistributeInterest(_mAsset);

        uint256 currentTime = block.timestamp;
        uint256 previousBatch = lastBatchCollected[_mAsset];
        uint256 timeSincePreviousBatch = currentTime - previousBatch;
        require(timeSincePreviousBatch > 6 hours, "Cannot deposit twice in 6 hours");
        lastBatchCollected[_mAsset] = currentTime;

        (uint256 interestCollected, uint256 totalSupply) = IMasset(_mAsset)
        .collectPlatformInterest();

        if (interestCollected > 0) {
            uint256 apy = YieldValidator.validateCollection(
                totalSupply,
                interestCollected,
                timeSincePreviousBatch
            );

            uint256 leftover = _unstreamedRewards(_mAsset, StreamType.yield);
            _initialiseStream(_mAsset, StreamType.yield, interestCollected + leftover, ONE_DAY);

            emit InterestCollected(_mAsset, interestCollected, totalSupply, apy);
        } else {
            emit InterestCollected(_mAsset, interestCollected, totalSupply, 0);
        }
    }

    function _unstreamedRewards(address _mAsset, StreamType _stream)
        internal
        view
        returns (uint256 leftover)
    {

        uint256 lastUpdate = lastCollection[_mAsset];

        Stream memory stream = _stream == StreamType.liquidator
            ? liqStream[_mAsset]
            : yieldStream[_mAsset];
        uint256 unclaimedSeconds = 0;
        if (lastUpdate < stream.end) {
            unclaimedSeconds = stream.end - lastUpdate;
        }
        return unclaimedSeconds * stream.rate;
    }

    function _initialiseStream(
        address _mAsset,
        StreamType _stream,
        uint256 _amount,
        uint256 _duration
    ) internal {

        uint256 currentTime = block.timestamp;
        uint256 rate = _amount / _duration;
        uint256 end = currentTime + _duration;
        if (_stream == StreamType.liquidator) {
            liqStream[_mAsset] = Stream(end, rate);
        } else {
            yieldStream[_mAsset] = Stream(end, rate);
        }

        require(lastCollection[_mAsset] == currentTime, "Stream data must be up to date");
    }


    function collectAndDistributeInterest(address _mAsset) external override whenNotPaused {

        _collectAndDistributeInterest(_mAsset);
    }

    function _collectAndDistributeInterest(address _mAsset) internal {

        ISavingsContractV2 savingsContract = savingsContracts[_mAsset];
        require(address(savingsContract) != address(0), "Must have a valid savings contract");

        uint256 recentPeriodStart = lastPeriodStart[_mAsset];
        uint256 previousCollection = lastCollection[_mAsset];
        lastCollection[_mAsset] = block.timestamp;

        IMasset mAsset = IMasset(_mAsset);
        (uint256 interestCollected, uint256 totalSupply) = mAsset.collectInterest();

        uint256 timeSincePeriodStart = StableMath.max(1, block.timestamp - recentPeriodStart);
        uint256 timeSinceLastCollection = StableMath.max(1, block.timestamp - previousCollection);

        uint256 inflationOperand = interestCollected;
        if (timeSinceLastCollection > THIRTY_MINUTES) {
            lastPeriodStart[_mAsset] = block.timestamp;
            periodYield[_mAsset] = 0;
        }
        else if (timeSincePeriodStart > THIRTY_MINUTES) {
            lastPeriodStart[_mAsset] = previousCollection;
            periodYield[_mAsset] = interestCollected;
        }
        else {
            inflationOperand = periodYield[_mAsset] + interestCollected;
            periodYield[_mAsset] = inflationOperand;
        }

        uint256 newReward = _unclaimedRewards(_mAsset, previousCollection);
        if (interestCollected > 0 || newReward > 0) {
            require(
                IERC20(_mAsset).balanceOf(address(this)) >= interestCollected + newReward,
                "Must receive mUSD"
            );

            uint256 extrapolatedAPY = YieldValidator.validateCollection(
                totalSupply,
                inflationOperand,
                timeSinceLastCollection
            );

            emit InterestCollected(_mAsset, interestCollected, totalSupply, extrapolatedAPY);

            uint256 saversShare = (interestCollected + newReward).mulTruncate(savingsRate);

            savingsContract.depositInterest(saversShare);

            emit InterestDistributed(_mAsset, saversShare);
        } else {
            emit InterestCollected(_mAsset, 0, totalSupply, 0);
        }
    }

    function _unclaimedRewards(address _mAsset, uint256 _previousCollection)
        internal
        view
        returns (uint256)
    {

        Stream memory liq = liqStream[_mAsset];
        uint256 unclaimedSeconds_liq = _unclaimedSeconds(_previousCollection, liq.end);
        uint256 subtotal_liq = unclaimedSeconds_liq * liq.rate;

        Stream memory yield = yieldStream[_mAsset];
        uint256 unclaimedSeconds_yield = _unclaimedSeconds(_previousCollection, yield.end);
        uint256 subtotal_yield = unclaimedSeconds_yield * yield.rate;

        return subtotal_liq + subtotal_yield;
    }

    function _unclaimedSeconds(uint256 _lastUpdate, uint256 _end) internal view returns (uint256) {

        uint256 currentTime = block.timestamp;
        uint256 unclaimedSeconds = 0;

        if (currentTime <= _end) {
            unclaimedSeconds = currentTime - _lastUpdate;
        } else if (_lastUpdate < _end) {
            unclaimedSeconds = _end - _lastUpdate;
        }
        return unclaimedSeconds;
    }


    function distributeUnallocatedInterest(address _mAsset) external override {

        IRevenueRecipient recipient = revenueRecipients[_mAsset];
        require(address(recipient) != address(0), "Must have valid recipient");

        IERC20 mAsset = IERC20(_mAsset);
        uint256 balance = mAsset.balanceOf(address(this));
        uint256 leftover_liq = _unstreamedRewards(_mAsset, StreamType.liquidator);
        uint256 leftover_yield = _unstreamedRewards(_mAsset, StreamType.yield);

        uint256 unallocated = balance - leftover_liq - leftover_yield;

        mAsset.approve(address(recipient), unallocated);
        recipient.notifyRedistributionAmount(_mAsset, unallocated);

        emit RevenueRedistributed(_mAsset, address(recipient), unallocated);
    }
}