



pragma solidity ^0.5.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}




library SafeDecimalMath {

    using SafeMath for uint;

    uint8 public constant decimals = 18;
    uint8 public constant highPrecisionDecimals = 27;

    uint public constant UNIT = 10**uint(decimals);

    uint public constant PRECISE_UNIT = 10**uint(highPrecisionDecimals);
    uint private constant UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR = 10**uint(highPrecisionDecimals - decimals);

    function unit() external pure returns (uint) {

        return UNIT;
    }

    function preciseUnit() external pure returns (uint) {

        return PRECISE_UNIT;
    }

    function multiplyDecimal(uint x, uint y) internal pure returns (uint) {

        return x.mul(y) / UNIT;
    }

    function _multiplyDecimalRound(
        uint x,
        uint y,
        uint precisionUnit
    ) private pure returns (uint) {

        uint quotientTimesTen = x.mul(y) / (precisionUnit / 10);

        if (quotientTimesTen % 10 >= 5) {
            quotientTimesTen += 10;
        }

        return quotientTimesTen / 10;
    }

    function multiplyDecimalRoundPrecise(uint x, uint y) internal pure returns (uint) {

        return _multiplyDecimalRound(x, y, PRECISE_UNIT);
    }

    function multiplyDecimalRound(uint x, uint y) internal pure returns (uint) {

        return _multiplyDecimalRound(x, y, UNIT);
    }

    function divideDecimal(uint x, uint y) internal pure returns (uint) {

        return x.mul(UNIT).div(y);
    }

    function _divideDecimalRound(
        uint x,
        uint y,
        uint precisionUnit
    ) private pure returns (uint) {

        uint resultTimesTen = x.mul(precisionUnit * 10).div(y);

        if (resultTimesTen % 10 >= 5) {
            resultTimesTen += 10;
        }

        return resultTimesTen / 10;
    }

    function divideDecimalRound(uint x, uint y) internal pure returns (uint) {

        return _divideDecimalRound(x, y, UNIT);
    }

    function divideDecimalRoundPrecise(uint x, uint y) internal pure returns (uint) {

        return _divideDecimalRound(x, y, PRECISE_UNIT);
    }

    function decimalToPreciseDecimal(uint i) internal pure returns (uint) {

        return i.mul(UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR);
    }

    function preciseDecimalToDecimal(uint i) internal pure returns (uint) {

        uint quotientTimesTen = i / (UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR / 10);

        if (quotientTimesTen % 10 >= 5) {
            quotientTimesTen += 10;
        }

        return quotientTimesTen / 10;
    }

    function floorsub(uint a, uint b) internal pure returns (uint) {

        return b >= a ? 0 : a - b;
    }

    function signedAbs(int x) internal pure returns (int) {

        return x < 0 ? -x : x;
    }

    function abs(int x) internal pure returns (uint) {

        return uint(signedAbs(x));
    }
}


contract Owned {

    address public owner;
    address public nominatedOwner;

    constructor(address _owner) public {
        require(_owner != address(0), "Owner address cannot be 0");
        owner = _owner;
        emit OwnerChanged(address(0), _owner);
    }

    function nominateNewOwner(address _owner) external onlyOwner {

        nominatedOwner = _owner;
        emit OwnerNominated(_owner);
    }

    function acceptOwnership() external {

        require(msg.sender == nominatedOwner, "You must be nominated before you can accept ownership");
        emit OwnerChanged(owner, nominatedOwner);
        owner = nominatedOwner;
        nominatedOwner = address(0);
    }

    modifier onlyOwner {

        _onlyOwner();
        _;
    }

    function _onlyOwner() private view {

        require(msg.sender == owner, "Only the contract owner may perform this action");
    }

    event OwnerNominated(address newOwner);
    event OwnerChanged(address oldOwner, address newOwner);
}


interface IAddressResolver {

    function getAddress(bytes32 name) external view returns (address);


    function getSynth(bytes32 key) external view returns (address);


    function requireAndGetAddress(bytes32 name, string calldata reason) external view returns (address);

}


interface ISynth {

    function currencyKey() external view returns (bytes32);


    function transferableSynths(address account) external view returns (uint);


    function transferAndSettle(address to, uint value) external returns (bool);


    function transferFromAndSettle(
        address from,
        address to,
        uint value
    ) external returns (bool);


    function burn(address account, uint amount) external;


    function issue(address account, uint amount) external;

}


interface IIssuer {

    function anySynthOrSNXRateIsInvalid() external view returns (bool anyRateInvalid);


    function availableCurrencyKeys() external view returns (bytes32[] memory);


    function availableSynthCount() external view returns (uint);


    function availableSynths(uint index) external view returns (ISynth);


    function canBurnSynths(address account) external view returns (bool);


    function collateral(address account) external view returns (uint);


    function collateralisationRatio(address issuer) external view returns (uint);


    function collateralisationRatioAndAnyRatesInvalid(address _issuer)
        external
        view
        returns (uint cratio, bool anyRateIsInvalid);


    function debtBalanceOf(address issuer, bytes32 currencyKey) external view returns (uint debtBalance);


    function issuanceRatio() external view returns (uint);


    function lastIssueEvent(address account) external view returns (uint);


    function maxIssuableSynths(address issuer) external view returns (uint maxIssuable);


    function minimumStakeTime() external view returns (uint);


    function remainingIssuableSynths(address issuer)
        external
        view
        returns (
            uint maxIssuable,
            uint alreadyIssued,
            uint totalSystemDebt
        );


    function synths(bytes32 currencyKey) external view returns (ISynth);


    function getSynths(bytes32[] calldata currencyKeys) external view returns (ISynth[] memory);


    function synthsByAddress(address synthAddress) external view returns (bytes32);


    function totalIssuedSynths(bytes32 currencyKey, bool excludeOtherCollateral) external view returns (uint);


    function transferableSynthetixAndAnyRateIsInvalid(address account, uint balance)
        external
        view
        returns (uint transferable, bool anyRateIsInvalid);


    function issueSynths(address from, uint amount) external;


    function issueSynthsOnBehalf(
        address issueFor,
        address from,
        uint amount
    ) external;


    function issueMaxSynths(address from) external;


    function issueMaxSynthsOnBehalf(address issueFor, address from) external;


    function burnSynths(address from, uint amount) external;


    function burnSynthsOnBehalf(
        address burnForAddress,
        address from,
        uint amount
    ) external;


    function burnSynthsToTarget(address from) external;


    function burnSynthsToTargetOnBehalf(address burnForAddress, address from) external;


    function burnForRedemption(
        address deprecatedSynthProxy,
        address account,
        uint balance
    ) external;


    function liquidateDelinquentAccount(
        address account,
        uint susdAmount,
        address liquidator
    ) external returns (uint totalRedeemed, uint amountToLiquidate);


    function setCurrentPeriodId(uint128 periodId) external;

}






contract AddressResolver is Owned, IAddressResolver {

    mapping(bytes32 => address) public repository;

    constructor(address _owner) public Owned(_owner) {}


    function importAddresses(bytes32[] calldata names, address[] calldata destinations) external onlyOwner {

        require(names.length == destinations.length, "Input lengths must match");

        for (uint i = 0; i < names.length; i++) {
            bytes32 name = names[i];
            address destination = destinations[i];
            repository[name] = destination;
            emit AddressImported(name, destination);
        }
    }


    function rebuildCaches(MixinResolver[] calldata destinations) external {

        for (uint i = 0; i < destinations.length; i++) {
            destinations[i].rebuildCache();
        }
    }


    function areAddressesImported(bytes32[] calldata names, address[] calldata destinations) external view returns (bool) {

        for (uint i = 0; i < names.length; i++) {
            if (repository[names[i]] != destinations[i]) {
                return false;
            }
        }
        return true;
    }

    function getAddress(bytes32 name) external view returns (address) {

        return repository[name];
    }

    function requireAndGetAddress(bytes32 name, string calldata reason) external view returns (address) {

        address _foundAddress = repository[name];
        require(_foundAddress != address(0), reason);
        return _foundAddress;
    }

    function getSynth(bytes32 key) external view returns (address) {

        IIssuer issuer = IIssuer(repository["Issuer"]);
        require(address(issuer) != address(0), "Cannot find Issuer address");
        return address(issuer.synths(key));
    }


    event AddressImported(bytes32 name, address destination);
}




contract MixinResolver {

    AddressResolver public resolver;

    mapping(bytes32 => address) private addressCache;

    constructor(address _resolver) internal {
        resolver = AddressResolver(_resolver);
    }


    function combineArrays(bytes32[] memory first, bytes32[] memory second)
        internal
        pure
        returns (bytes32[] memory combination)
    {

        combination = new bytes32[](first.length + second.length);

        for (uint i = 0; i < first.length; i++) {
            combination[i] = first[i];
        }

        for (uint j = 0; j < second.length; j++) {
            combination[first.length + j] = second[j];
        }
    }


    function resolverAddressesRequired() public view returns (bytes32[] memory addresses) {}


    function rebuildCache() public {

        bytes32[] memory requiredAddresses = resolverAddressesRequired();
        for (uint i = 0; i < requiredAddresses.length; i++) {
            bytes32 name = requiredAddresses[i];
            address destination =
                resolver.requireAndGetAddress(name, string(abi.encodePacked("Resolver missing target: ", name)));
            addressCache[name] = destination;
            emit CacheUpdated(name, destination);
        }
    }


    function isResolverCached() external view returns (bool) {

        bytes32[] memory requiredAddresses = resolverAddressesRequired();
        for (uint i = 0; i < requiredAddresses.length; i++) {
            bytes32 name = requiredAddresses[i];
            if (resolver.getAddress(name) != addressCache[name] || addressCache[name] == address(0)) {
                return false;
            }
        }

        return true;
    }


    function requireAndGetAddress(bytes32 name) internal view returns (address) {

        address _foundAddress = addressCache[name];
        require(_foundAddress != address(0), string(abi.encodePacked("Missing address: ", name)));
        return _foundAddress;
    }


    event CacheUpdated(bytes32 name, address destination);
}


interface IFlexibleStorage {

    function getUIntValue(bytes32 contractName, bytes32 record) external view returns (uint);


    function getUIntValues(bytes32 contractName, bytes32[] calldata records) external view returns (uint[] memory);


    function getIntValue(bytes32 contractName, bytes32 record) external view returns (int);


    function getIntValues(bytes32 contractName, bytes32[] calldata records) external view returns (int[] memory);


    function getAddressValue(bytes32 contractName, bytes32 record) external view returns (address);


    function getAddressValues(bytes32 contractName, bytes32[] calldata records) external view returns (address[] memory);


    function getBoolValue(bytes32 contractName, bytes32 record) external view returns (bool);


    function getBoolValues(bytes32 contractName, bytes32[] calldata records) external view returns (bool[] memory);


    function getBytes32Value(bytes32 contractName, bytes32 record) external view returns (bytes32);


    function getBytes32Values(bytes32 contractName, bytes32[] calldata records) external view returns (bytes32[] memory);


    function deleteUIntValue(bytes32 contractName, bytes32 record) external;


    function deleteIntValue(bytes32 contractName, bytes32 record) external;


    function deleteAddressValue(bytes32 contractName, bytes32 record) external;


    function deleteBoolValue(bytes32 contractName, bytes32 record) external;


    function deleteBytes32Value(bytes32 contractName, bytes32 record) external;


    function setUIntValue(
        bytes32 contractName,
        bytes32 record,
        uint value
    ) external;


    function setUIntValues(
        bytes32 contractName,
        bytes32[] calldata records,
        uint[] calldata values
    ) external;


    function setIntValue(
        bytes32 contractName,
        bytes32 record,
        int value
    ) external;


    function setIntValues(
        bytes32 contractName,
        bytes32[] calldata records,
        int[] calldata values
    ) external;


    function setAddressValue(
        bytes32 contractName,
        bytes32 record,
        address value
    ) external;


    function setAddressValues(
        bytes32 contractName,
        bytes32[] calldata records,
        address[] calldata values
    ) external;


    function setBoolValue(
        bytes32 contractName,
        bytes32 record,
        bool value
    ) external;


    function setBoolValues(
        bytes32 contractName,
        bytes32[] calldata records,
        bool[] calldata values
    ) external;


    function setBytes32Value(
        bytes32 contractName,
        bytes32 record,
        bytes32 value
    ) external;


    function setBytes32Values(
        bytes32 contractName,
        bytes32[] calldata records,
        bytes32[] calldata values
    ) external;

}




contract MixinSystemSettings is MixinResolver {

    bytes32 internal constant SETTING_CONTRACT_NAME = "SystemSettings";

    bytes32 internal constant SETTING_WAITING_PERIOD_SECS = "waitingPeriodSecs";
    bytes32 internal constant SETTING_PRICE_DEVIATION_THRESHOLD_FACTOR = "priceDeviationThresholdFactor";
    bytes32 internal constant SETTING_ISSUANCE_RATIO = "issuanceRatio";
    bytes32 internal constant SETTING_FEE_PERIOD_DURATION = "feePeriodDuration";
    bytes32 internal constant SETTING_TARGET_THRESHOLD = "targetThreshold";
    bytes32 internal constant SETTING_LIQUIDATION_DELAY = "liquidationDelay";
    bytes32 internal constant SETTING_LIQUIDATION_RATIO = "liquidationRatio";
    bytes32 internal constant SETTING_LIQUIDATION_PENALTY = "liquidationPenalty";
    bytes32 internal constant SETTING_RATE_STALE_PERIOD = "rateStalePeriod";
    bytes32 internal constant SETTING_EXCHANGE_FEE_RATE = "exchangeFeeRate";
    bytes32 internal constant SETTING_EXCHANGE_DYNAMIC_FEE_THRESHOLD = "exchangeDynamicFeeThreshold";
    bytes32 internal constant SETTING_EXCHANGE_DYNAMIC_FEE_WEIGHT_DECAY = "exchangeDynamicFeeWeightDecay";
    bytes32 internal constant SETTING_EXCHANGE_DYNAMIC_FEE_ROUNDS = "exchangeDynamicFeeRounds";
    bytes32 internal constant SETTING_EXCHANGE_MAX_DYNAMIC_FEE = "exchangeMaxDynamicFee";
    bytes32 internal constant SETTING_MINIMUM_STAKE_TIME = "minimumStakeTime";
    bytes32 internal constant SETTING_AGGREGATOR_WARNING_FLAGS = "aggregatorWarningFlags";
    bytes32 internal constant SETTING_TRADING_REWARDS_ENABLED = "tradingRewardsEnabled";
    bytes32 internal constant SETTING_DEBT_SNAPSHOT_STALE_TIME = "debtSnapshotStaleTime";
    bytes32 internal constant SETTING_CROSS_DOMAIN_DEPOSIT_GAS_LIMIT = "crossDomainDepositGasLimit";
    bytes32 internal constant SETTING_CROSS_DOMAIN_ESCROW_GAS_LIMIT = "crossDomainEscrowGasLimit";
    bytes32 internal constant SETTING_CROSS_DOMAIN_REWARD_GAS_LIMIT = "crossDomainRewardGasLimit";
    bytes32 internal constant SETTING_CROSS_DOMAIN_WITHDRAWAL_GAS_LIMIT = "crossDomainWithdrawalGasLimit";
    bytes32 internal constant SETTING_CROSS_DOMAIN_FEE_PERIOD_CLOSE_GAS_LIMIT = "crossDomainCloseGasLimit";
    bytes32 internal constant SETTING_CROSS_DOMAIN_RELAY_GAS_LIMIT = "crossDomainRelayGasLimit";
    bytes32 internal constant SETTING_ETHER_WRAPPER_MAX_ETH = "etherWrapperMaxETH";
    bytes32 internal constant SETTING_ETHER_WRAPPER_MINT_FEE_RATE = "etherWrapperMintFeeRate";
    bytes32 internal constant SETTING_ETHER_WRAPPER_BURN_FEE_RATE = "etherWrapperBurnFeeRate";
    bytes32 internal constant SETTING_WRAPPER_MAX_TOKEN_AMOUNT = "wrapperMaxTokens";
    bytes32 internal constant SETTING_WRAPPER_MINT_FEE_RATE = "wrapperMintFeeRate";
    bytes32 internal constant SETTING_WRAPPER_BURN_FEE_RATE = "wrapperBurnFeeRate";
    bytes32 internal constant SETTING_INTERACTION_DELAY = "interactionDelay";
    bytes32 internal constant SETTING_COLLAPSE_FEE_RATE = "collapseFeeRate";
    bytes32 internal constant SETTING_ATOMIC_MAX_VOLUME_PER_BLOCK = "atomicMaxVolumePerBlock";
    bytes32 internal constant SETTING_ATOMIC_TWAP_WINDOW = "atomicTwapWindow";
    bytes32 internal constant SETTING_ATOMIC_EQUIVALENT_FOR_DEX_PRICING = "atomicEquivalentForDexPricing";
    bytes32 internal constant SETTING_ATOMIC_EXCHANGE_FEE_RATE = "atomicExchangeFeeRate";
    bytes32 internal constant SETTING_ATOMIC_PRICE_BUFFER = "atomicPriceBuffer";
    bytes32 internal constant SETTING_ATOMIC_VOLATILITY_CONSIDERATION_WINDOW = "atomicVolConsiderationWindow";
    bytes32 internal constant SETTING_ATOMIC_VOLATILITY_UPDATE_THRESHOLD = "atomicVolUpdateThreshold";

    bytes32 internal constant CONTRACT_FLEXIBLESTORAGE = "FlexibleStorage";

    enum CrossDomainMessageGasLimits {Deposit, Escrow, Reward, Withdrawal, CloseFeePeriod, Relay}

    struct DynamicFeeConfig {
        uint threshold;
        uint weightDecay;
        uint rounds;
        uint maxFee;
    }

    constructor(address _resolver) internal MixinResolver(_resolver) {}

    function resolverAddressesRequired() public view returns (bytes32[] memory addresses) {

        addresses = new bytes32[](1);
        addresses[0] = CONTRACT_FLEXIBLESTORAGE;
    }

    function flexibleStorage() internal view returns (IFlexibleStorage) {

        return IFlexibleStorage(requireAndGetAddress(CONTRACT_FLEXIBLESTORAGE));
    }

    function _getGasLimitSetting(CrossDomainMessageGasLimits gasLimitType) internal pure returns (bytes32) {

        if (gasLimitType == CrossDomainMessageGasLimits.Deposit) {
            return SETTING_CROSS_DOMAIN_DEPOSIT_GAS_LIMIT;
        } else if (gasLimitType == CrossDomainMessageGasLimits.Escrow) {
            return SETTING_CROSS_DOMAIN_ESCROW_GAS_LIMIT;
        } else if (gasLimitType == CrossDomainMessageGasLimits.Reward) {
            return SETTING_CROSS_DOMAIN_REWARD_GAS_LIMIT;
        } else if (gasLimitType == CrossDomainMessageGasLimits.Withdrawal) {
            return SETTING_CROSS_DOMAIN_WITHDRAWAL_GAS_LIMIT;
        } else if (gasLimitType == CrossDomainMessageGasLimits.Relay) {
            return SETTING_CROSS_DOMAIN_RELAY_GAS_LIMIT;
        } else if (gasLimitType == CrossDomainMessageGasLimits.CloseFeePeriod) {
            return SETTING_CROSS_DOMAIN_FEE_PERIOD_CLOSE_GAS_LIMIT;
        } else {
            revert("Unknown gas limit type");
        }
    }

    function getCrossDomainMessageGasLimit(CrossDomainMessageGasLimits gasLimitType) internal view returns (uint) {

        return flexibleStorage().getUIntValue(SETTING_CONTRACT_NAME, _getGasLimitSetting(gasLimitType));
    }

    function getTradingRewardsEnabled() internal view returns (bool) {

        return flexibleStorage().getBoolValue(SETTING_CONTRACT_NAME, SETTING_TRADING_REWARDS_ENABLED);
    }

    function getWaitingPeriodSecs() internal view returns (uint) {

        return flexibleStorage().getUIntValue(SETTING_CONTRACT_NAME, SETTING_WAITING_PERIOD_SECS);
    }

    function getPriceDeviationThresholdFactor() internal view returns (uint) {

        return flexibleStorage().getUIntValue(SETTING_CONTRACT_NAME, SETTING_PRICE_DEVIATION_THRESHOLD_FACTOR);
    }

    function getIssuanceRatio() internal view returns (uint) {

        return flexibleStorage().getUIntValue(SETTING_CONTRACT_NAME, SETTING_ISSUANCE_RATIO);
    }

    function getFeePeriodDuration() internal view returns (uint) {

        return flexibleStorage().getUIntValue(SETTING_CONTRACT_NAME, SETTING_FEE_PERIOD_DURATION);
    }

    function getTargetThreshold() internal view returns (uint) {

        return flexibleStorage().getUIntValue(SETTING_CONTRACT_NAME, SETTING_TARGET_THRESHOLD);
    }

    function getLiquidationDelay() internal view returns (uint) {

        return flexibleStorage().getUIntValue(SETTING_CONTRACT_NAME, SETTING_LIQUIDATION_DELAY);
    }

    function getLiquidationRatio() internal view returns (uint) {

        return flexibleStorage().getUIntValue(SETTING_CONTRACT_NAME, SETTING_LIQUIDATION_RATIO);
    }

    function getLiquidationPenalty() internal view returns (uint) {

        return flexibleStorage().getUIntValue(SETTING_CONTRACT_NAME, SETTING_LIQUIDATION_PENALTY);
    }

    function getRateStalePeriod() internal view returns (uint) {

        return flexibleStorage().getUIntValue(SETTING_CONTRACT_NAME, SETTING_RATE_STALE_PERIOD);
    }

    function getExchangeFeeRate(bytes32 currencyKey) internal view returns (uint) {

        return
            flexibleStorage().getUIntValue(
                SETTING_CONTRACT_NAME,
                keccak256(abi.encodePacked(SETTING_EXCHANGE_FEE_RATE, currencyKey))
            );
    }

    function getExchangeDynamicFeeConfig() internal view returns (DynamicFeeConfig memory) {

        bytes32[] memory keys = new bytes32[](4);
        keys[0] = SETTING_EXCHANGE_DYNAMIC_FEE_THRESHOLD;
        keys[1] = SETTING_EXCHANGE_DYNAMIC_FEE_WEIGHT_DECAY;
        keys[2] = SETTING_EXCHANGE_DYNAMIC_FEE_ROUNDS;
        keys[3] = SETTING_EXCHANGE_MAX_DYNAMIC_FEE;
        uint[] memory values = flexibleStorage().getUIntValues(SETTING_CONTRACT_NAME, keys);
        return DynamicFeeConfig({threshold: values[0], weightDecay: values[1], rounds: values[2], maxFee: values[3]});
    }


    function getMinimumStakeTime() internal view returns (uint) {

        return flexibleStorage().getUIntValue(SETTING_CONTRACT_NAME, SETTING_MINIMUM_STAKE_TIME);
    }

    function getAggregatorWarningFlags() internal view returns (address) {

        return flexibleStorage().getAddressValue(SETTING_CONTRACT_NAME, SETTING_AGGREGATOR_WARNING_FLAGS);
    }

    function getDebtSnapshotStaleTime() internal view returns (uint) {

        return flexibleStorage().getUIntValue(SETTING_CONTRACT_NAME, SETTING_DEBT_SNAPSHOT_STALE_TIME);
    }

    function getEtherWrapperMaxETH() internal view returns (uint) {

        return flexibleStorage().getUIntValue(SETTING_CONTRACT_NAME, SETTING_ETHER_WRAPPER_MAX_ETH);
    }

    function getEtherWrapperMintFeeRate() internal view returns (uint) {

        return flexibleStorage().getUIntValue(SETTING_CONTRACT_NAME, SETTING_ETHER_WRAPPER_MINT_FEE_RATE);
    }

    function getEtherWrapperBurnFeeRate() internal view returns (uint) {

        return flexibleStorage().getUIntValue(SETTING_CONTRACT_NAME, SETTING_ETHER_WRAPPER_BURN_FEE_RATE);
    }

    function getWrapperMaxTokenAmount(address wrapper) internal view returns (uint) {

        return
            flexibleStorage().getUIntValue(
                SETTING_CONTRACT_NAME,
                keccak256(abi.encodePacked(SETTING_WRAPPER_MAX_TOKEN_AMOUNT, wrapper))
            );
    }

    function getWrapperMintFeeRate(address wrapper) internal view returns (int) {

        return
            flexibleStorage().getIntValue(
                SETTING_CONTRACT_NAME,
                keccak256(abi.encodePacked(SETTING_WRAPPER_MINT_FEE_RATE, wrapper))
            );
    }

    function getWrapperBurnFeeRate(address wrapper) internal view returns (int) {

        return
            flexibleStorage().getIntValue(
                SETTING_CONTRACT_NAME,
                keccak256(abi.encodePacked(SETTING_WRAPPER_BURN_FEE_RATE, wrapper))
            );
    }

    function getInteractionDelay(address collateral) internal view returns (uint) {

        return
            flexibleStorage().getUIntValue(
                SETTING_CONTRACT_NAME,
                keccak256(abi.encodePacked(SETTING_INTERACTION_DELAY, collateral))
            );
    }

    function getCollapseFeeRate(address collateral) internal view returns (uint) {

        return
            flexibleStorage().getUIntValue(
                SETTING_CONTRACT_NAME,
                keccak256(abi.encodePacked(SETTING_COLLAPSE_FEE_RATE, collateral))
            );
    }

    function getAtomicMaxVolumePerBlock() internal view returns (uint) {

        return flexibleStorage().getUIntValue(SETTING_CONTRACT_NAME, SETTING_ATOMIC_MAX_VOLUME_PER_BLOCK);
    }

    function getAtomicTwapWindow() internal view returns (uint) {

        return flexibleStorage().getUIntValue(SETTING_CONTRACT_NAME, SETTING_ATOMIC_TWAP_WINDOW);
    }

    function getAtomicEquivalentForDexPricing(bytes32 currencyKey) internal view returns (address) {

        return
            flexibleStorage().getAddressValue(
                SETTING_CONTRACT_NAME,
                keccak256(abi.encodePacked(SETTING_ATOMIC_EQUIVALENT_FOR_DEX_PRICING, currencyKey))
            );
    }

    function getAtomicExchangeFeeRate(bytes32 currencyKey) internal view returns (uint) {

        return
            flexibleStorage().getUIntValue(
                SETTING_CONTRACT_NAME,
                keccak256(abi.encodePacked(SETTING_ATOMIC_EXCHANGE_FEE_RATE, currencyKey))
            );
    }

    function getAtomicPriceBuffer(bytes32 currencyKey) internal view returns (uint) {

        return
            flexibleStorage().getUIntValue(
                SETTING_CONTRACT_NAME,
                keccak256(abi.encodePacked(SETTING_ATOMIC_PRICE_BUFFER, currencyKey))
            );
    }

    function getAtomicVolatilityConsiderationWindow(bytes32 currencyKey) internal view returns (uint) {

        return
            flexibleStorage().getUIntValue(
                SETTING_CONTRACT_NAME,
                keccak256(abi.encodePacked(SETTING_ATOMIC_VOLATILITY_CONSIDERATION_WINDOW, currencyKey))
            );
    }

    function getAtomicVolatilityUpdateThreshold(bytes32 currencyKey) internal view returns (uint) {

        return
            flexibleStorage().getUIntValue(
                SETTING_CONTRACT_NAME,
                keccak256(abi.encodePacked(SETTING_ATOMIC_VOLATILITY_UPDATE_THRESHOLD, currencyKey))
            );
    }
}


interface IDebtCache {


    function cachedDebt() external view returns (uint);


    function cachedSynthDebt(bytes32 currencyKey) external view returns (uint);


    function cacheTimestamp() external view returns (uint);


    function cacheInvalid() external view returns (bool);


    function cacheStale() external view returns (bool);


    function isInitialized() external view returns (bool);


    function currentSynthDebts(bytes32[] calldata currencyKeys)
        external
        view
        returns (
            uint[] memory debtValues,
            uint futuresDebt,
            uint excludedDebt,
            bool anyRateIsInvalid
        );


    function cachedSynthDebts(bytes32[] calldata currencyKeys) external view returns (uint[] memory debtValues);


    function totalNonSnxBackedDebt() external view returns (uint excludedDebt, bool isInvalid);


    function currentDebt() external view returns (uint debt, bool anyRateIsInvalid);


    function cacheInfo()
        external
        view
        returns (
            uint debt,
            uint timestamp,
            bool isInvalid,
            bool isStale
        );


    function excludedIssuedDebts(bytes32[] calldata currencyKeys) external view returns (uint[] memory excludedDebts);



    function updateCachedSynthDebts(bytes32[] calldata currencyKeys) external;


    function updateCachedSynthDebtWithRate(bytes32 currencyKey, uint currencyRate) external;


    function updateCachedSynthDebtsWithRates(bytes32[] calldata currencyKeys, uint[] calldata currencyRates) external;


    function updateDebtCacheValidity(bool currentlyInvalid) external;


    function purgeCachedSynthDebt(bytes32 currencyKey) external;


    function takeDebtSnapshot() external;


    function recordExcludedDebtChange(bytes32 currencyKey, int256 delta) external;


    function updateCachedsUSDDebt(int amount) external;


    function importExcludedIssuedDebts(IDebtCache prevDebtCache, IIssuer prevIssuer) external;

}


interface IVirtualSynth {

    function balanceOfUnderlying(address account) external view returns (uint);


    function rate() external view returns (uint);


    function readyToSettle() external view returns (bool);


    function secsLeftInWaitingPeriod() external view returns (uint);


    function settled() external view returns (bool);


    function synth() external view returns (ISynth);


    function settle(address account) external;

}


interface IExchanger {

    struct ExchangeEntrySettlement {
        bytes32 src;
        uint amount;
        bytes32 dest;
        uint reclaim;
        uint rebate;
        uint srcRoundIdAtPeriodEnd;
        uint destRoundIdAtPeriodEnd;
        uint timestamp;
    }

    struct ExchangeEntry {
        uint sourceRate;
        uint destinationRate;
        uint destinationAmount;
        uint exchangeFeeRate;
        uint exchangeDynamicFeeRate;
        uint roundIdForSrc;
        uint roundIdForDest;
    }

    function calculateAmountAfterSettlement(
        address from,
        bytes32 currencyKey,
        uint amount,
        uint refunded
    ) external view returns (uint amountAfterSettlement);


    function isSynthRateInvalid(bytes32 currencyKey) external view returns (bool);


    function maxSecsLeftInWaitingPeriod(address account, bytes32 currencyKey) external view returns (uint);


    function settlementOwing(address account, bytes32 currencyKey)
        external
        view
        returns (
            uint reclaimAmount,
            uint rebateAmount,
            uint numEntries
        );


    function hasWaitingPeriodOrSettlementOwing(address account, bytes32 currencyKey) external view returns (bool);


    function feeRateForExchange(bytes32 sourceCurrencyKey, bytes32 destinationCurrencyKey) external view returns (uint);


    function dynamicFeeRateForExchange(bytes32 sourceCurrencyKey, bytes32 destinationCurrencyKey)
        external
        view
        returns (uint feeRate, bool tooVolatile);


    function getAmountsForExchange(
        uint sourceAmount,
        bytes32 sourceCurrencyKey,
        bytes32 destinationCurrencyKey
    )
        external
        view
        returns (
            uint amountReceived,
            uint fee,
            uint exchangeFeeRate
        );


    function priceDeviationThresholdFactor() external view returns (uint);


    function waitingPeriodSecs() external view returns (uint);


    function lastExchangeRate(bytes32 currencyKey) external view returns (uint);


    function exchange(
        address exchangeForAddress,
        address from,
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey,
        address destinationAddress,
        bool virtualSynth,
        address rewardAddress,
        bytes32 trackingCode
    ) external returns (uint amountReceived, IVirtualSynth vSynth);


    function exchangeAtomically(
        address from,
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey,
        address destinationAddress,
        bytes32 trackingCode
    ) external returns (uint amountReceived);


    function settle(address from, bytes32 currencyKey)
        external
        returns (
            uint reclaimed,
            uint refunded,
            uint numEntries
        );


    function suspendSynthWithInvalidRate(bytes32 currencyKey) external;

}


interface IExchangeRates {

    struct RateAndUpdatedTime {
        uint216 rate;
        uint40 time;
    }

    function aggregators(bytes32 currencyKey) external view returns (address);


    function aggregatorWarningFlags() external view returns (address);


    function anyRateIsInvalid(bytes32[] calldata currencyKeys) external view returns (bool);


    function anyRateIsInvalidAtRound(bytes32[] calldata currencyKeys, uint[] calldata roundIds) external view returns (bool);


    function currenciesUsingAggregator(address aggregator) external view returns (bytes32[] memory);


    function effectiveValue(
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey
    ) external view returns (uint value);


    function effectiveValueAndRates(
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey
    )
        external
        view
        returns (
            uint value,
            uint sourceRate,
            uint destinationRate
        );


    function effectiveValueAndRatesAtRound(
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey,
        uint roundIdForSrc,
        uint roundIdForDest
    )
        external
        view
        returns (
            uint value,
            uint sourceRate,
            uint destinationRate
        );


    function effectiveAtomicValueAndRates(
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey
    )
        external
        view
        returns (
            uint value,
            uint systemValue,
            uint systemSourceRate,
            uint systemDestinationRate
        );


    function getCurrentRoundId(bytes32 currencyKey) external view returns (uint);


    function getLastRoundIdBeforeElapsedSecs(
        bytes32 currencyKey,
        uint startingRoundId,
        uint startingTimestamp,
        uint timediff
    ) external view returns (uint);


    function lastRateUpdateTimes(bytes32 currencyKey) external view returns (uint256);


    function rateAndTimestampAtRound(bytes32 currencyKey, uint roundId) external view returns (uint rate, uint time);


    function rateAndUpdatedTime(bytes32 currencyKey) external view returns (uint rate, uint time);


    function rateAndInvalid(bytes32 currencyKey) external view returns (uint rate, bool isInvalid);


    function rateForCurrency(bytes32 currencyKey) external view returns (uint);


    function rateIsFlagged(bytes32 currencyKey) external view returns (bool);


    function rateIsInvalid(bytes32 currencyKey) external view returns (bool);


    function rateIsStale(bytes32 currencyKey) external view returns (bool);


    function rateStalePeriod() external view returns (uint);


    function ratesAndUpdatedTimeForCurrencyLastNRounds(
        bytes32 currencyKey,
        uint numRounds,
        uint roundId
    ) external view returns (uint[] memory rates, uint[] memory times);


    function ratesAndInvalidForCurrencies(bytes32[] calldata currencyKeys)
        external
        view
        returns (uint[] memory rates, bool anyRateInvalid);


    function ratesForCurrencies(bytes32[] calldata currencyKeys) external view returns (uint[] memory);


    function synthTooVolatileForAtomicExchange(bytes32 currencyKey) external view returns (bool);

}


interface ISystemStatus {

    struct Status {
        bool canSuspend;
        bool canResume;
    }

    struct Suspension {
        bool suspended;
        uint248 reason;
    }

    function accessControl(bytes32 section, address account) external view returns (bool canSuspend, bool canResume);


    function requireSystemActive() external view;


    function systemSuspended() external view returns (bool);


    function requireIssuanceActive() external view;


    function requireExchangeActive() external view;


    function requireFuturesActive() external view;


    function requireFuturesMarketActive(bytes32 marketKey) external view;


    function requireExchangeBetweenSynthsAllowed(bytes32 sourceCurrencyKey, bytes32 destinationCurrencyKey) external view;


    function requireSynthActive(bytes32 currencyKey) external view;


    function synthSuspended(bytes32 currencyKey) external view returns (bool);


    function requireSynthsActive(bytes32 sourceCurrencyKey, bytes32 destinationCurrencyKey) external view;


    function systemSuspension() external view returns (bool suspended, uint248 reason);


    function issuanceSuspension() external view returns (bool suspended, uint248 reason);


    function exchangeSuspension() external view returns (bool suspended, uint248 reason);


    function futuresSuspension() external view returns (bool suspended, uint248 reason);


    function synthExchangeSuspension(bytes32 currencyKey) external view returns (bool suspended, uint248 reason);


    function synthSuspension(bytes32 currencyKey) external view returns (bool suspended, uint248 reason);


    function futuresMarketSuspension(bytes32 marketKey) external view returns (bool suspended, uint248 reason);


    function getSynthExchangeSuspensions(bytes32[] calldata synths)
        external
        view
        returns (bool[] memory exchangeSuspensions, uint256[] memory reasons);


    function getSynthSuspensions(bytes32[] calldata synths)
        external
        view
        returns (bool[] memory suspensions, uint256[] memory reasons);


    function getFuturesMarketSuspensions(bytes32[] calldata marketKeys)
        external
        view
        returns (bool[] memory suspensions, uint256[] memory reasons);


    function suspendIssuance(uint256 reason) external;


    function suspendSynth(bytes32 currencyKey, uint256 reason) external;


    function suspendFuturesMarket(bytes32 marketKey, uint256 reason) external;


    function updateAccessControl(
        bytes32 section,
        address account,
        bool canSuspend,
        bool canResume
    ) external;

}


interface IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);


    function totalSupply() external view returns (uint);


    function balanceOf(address owner) external view returns (uint);


    function allowance(address owner, address spender) external view returns (uint);


    function transfer(address to, uint value) external returns (bool);


    function approve(address spender, uint value) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint value
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint value);

    event Approval(address indexed owner, address indexed spender, uint value);
}


interface ICollateralManager {

    function hasCollateral(address collateral) external view returns (bool);


    function isSynthManaged(bytes32 currencyKey) external view returns (bool);


    function long(bytes32 synth) external view returns (uint amount);


    function short(bytes32 synth) external view returns (uint amount);


    function totalLong() external view returns (uint susdValue, bool anyRateIsInvalid);


    function totalShort() external view returns (uint susdValue, bool anyRateIsInvalid);


    function getBorrowRate() external view returns (uint borrowRate, bool anyRateIsInvalid);


    function getShortRate(bytes32 synth) external view returns (uint shortRate, bool rateIsInvalid);


    function getRatesAndTime(uint index)
        external
        view
        returns (
            uint entryRate,
            uint lastRate,
            uint lastUpdated,
            uint newIndex
        );


    function getShortRatesAndTime(bytes32 currency, uint index)
        external
        view
        returns (
            uint entryRate,
            uint lastRate,
            uint lastUpdated,
            uint newIndex
        );


    function exceedsDebtLimit(uint amount, bytes32 currency) external view returns (bool canIssue, bool anyRateIsInvalid);


    function areSynthsAndCurrenciesSet(bytes32[] calldata requiredSynthNamesInResolver, bytes32[] calldata synthKeys)
        external
        view
        returns (bool);


    function areShortableSynthsSet(bytes32[] calldata requiredSynthNamesInResolver, bytes32[] calldata synthKeys)
        external
        view
        returns (bool);


    function getNewLoanId() external returns (uint id);


    function addCollaterals(address[] calldata collaterals) external;


    function removeCollaterals(address[] calldata collaterals) external;


    function addSynths(bytes32[] calldata synthNamesInResolver, bytes32[] calldata synthKeys) external;


    function removeSynths(bytes32[] calldata synths, bytes32[] calldata synthKeys) external;


    function addShortableSynths(bytes32[] calldata requiredSynthNamesInResolver, bytes32[] calldata synthKeys) external;


    function removeShortableSynths(bytes32[] calldata synths) external;



    function incrementLongs(bytes32 synth, uint amount) external;


    function decrementLongs(bytes32 synth, uint amount) external;


    function incrementShorts(bytes32 synth, uint amount) external;


    function decrementShorts(bytes32 synth, uint amount) external;


    function accrueInterest(
        uint interestIndex,
        bytes32 currency,
        bool isShort
    ) external returns (uint difference, uint index);


    function updateBorrowRatesCollateral(uint rate) external;


    function updateShortRatesCollateral(bytes32 currency, uint rate) external;

}


interface IWETH {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);


    function totalSupply() external view returns (uint);


    function balanceOf(address owner) external view returns (uint);


    function allowance(address owner, address spender) external view returns (uint);


    function transfer(address to, uint value) external returns (bool);


    function approve(address spender, uint value) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint value
    ) external returns (bool);


    function deposit() external payable;


    function withdraw(uint amount) external;


    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    event Deposit(address indexed to, uint amount);
    event Withdrawal(address indexed to, uint amount);
}


contract IEtherWrapper {

    function mint(uint amount) external;


    function burn(uint amount) external;


    function distributeFees() external;


    function capacity() external view returns (uint);


    function getReserves() external view returns (uint);


    function totalIssuedSynths() external view returns (uint);


    function calculateMintFee(uint amount) public view returns (uint);


    function calculateBurnFee(uint amount) public view returns (uint);


    function maxETH() public view returns (uint256);


    function mintFeeRate() public view returns (uint256);


    function burnFeeRate() public view returns (uint256);


    function weth() public view returns (IWETH);

}


interface IWrapperFactory {

    function isWrapper(address possibleWrapper) external view returns (bool);


    function createWrapper(
        IERC20 token,
        bytes32 currencyKey,
        bytes32 synthContractName
    ) external returns (address);


    function distributeFees() external;

}


interface IFuturesMarketManager {

    function markets(uint index, uint pageSize) external view returns (address[] memory);


    function numMarkets() external view returns (uint);


    function allMarkets() external view returns (address[] memory);


    function marketForKey(bytes32 marketKey) external view returns (address);


    function marketsForKeys(bytes32[] calldata marketKeys) external view returns (address[] memory);


    function totalDebt() external view returns (uint debt, bool isInvalid);

}








contract BaseDebtCache is Owned, MixinSystemSettings, IDebtCache {

    using SafeMath for uint;
    using SafeDecimalMath for uint;

    uint internal _cachedDebt;
    mapping(bytes32 => uint) internal _cachedSynthDebt;
    mapping(bytes32 => uint) internal _excludedIssuedDebt;
    uint internal _cacheTimestamp;
    bool internal _cacheInvalid = true;

    bool public isInitialized = false; // public to avoid needing an event


    bytes32 internal constant sUSD = "sUSD";
    bytes32 internal constant sETH = "sETH";


    bytes32 private constant CONTRACT_ISSUER = "Issuer";
    bytes32 private constant CONTRACT_EXCHANGER = "Exchanger";
    bytes32 private constant CONTRACT_EXRATES = "ExchangeRates";
    bytes32 private constant CONTRACT_SYSTEMSTATUS = "SystemStatus";
    bytes32 private constant CONTRACT_COLLATERALMANAGER = "CollateralManager";
    bytes32 private constant CONTRACT_ETHER_WRAPPER = "EtherWrapper";
    bytes32 private constant CONTRACT_FUTURESMARKETMANAGER = "FuturesMarketManager";
    bytes32 private constant CONTRACT_WRAPPER_FACTORY = "WrapperFactory";

    constructor(address _owner, address _resolver) public Owned(_owner) MixinSystemSettings(_resolver) {}


    function resolverAddressesRequired() public view returns (bytes32[] memory addresses) {

        bytes32[] memory existingAddresses = MixinSystemSettings.resolverAddressesRequired();
        bytes32[] memory newAddresses = new bytes32[](8);
        newAddresses[0] = CONTRACT_ISSUER;
        newAddresses[1] = CONTRACT_EXCHANGER;
        newAddresses[2] = CONTRACT_EXRATES;
        newAddresses[3] = CONTRACT_SYSTEMSTATUS;
        newAddresses[4] = CONTRACT_COLLATERALMANAGER;
        newAddresses[5] = CONTRACT_WRAPPER_FACTORY;
        newAddresses[6] = CONTRACT_ETHER_WRAPPER;
        newAddresses[7] = CONTRACT_FUTURESMARKETMANAGER;
        addresses = combineArrays(existingAddresses, newAddresses);
    }

    function issuer() internal view returns (IIssuer) {

        return IIssuer(requireAndGetAddress(CONTRACT_ISSUER));
    }

    function exchanger() internal view returns (IExchanger) {

        return IExchanger(requireAndGetAddress(CONTRACT_EXCHANGER));
    }

    function exchangeRates() internal view returns (IExchangeRates) {

        return IExchangeRates(requireAndGetAddress(CONTRACT_EXRATES));
    }

    function systemStatus() internal view returns (ISystemStatus) {

        return ISystemStatus(requireAndGetAddress(CONTRACT_SYSTEMSTATUS));
    }

    function collateralManager() internal view returns (ICollateralManager) {

        return ICollateralManager(requireAndGetAddress(CONTRACT_COLLATERALMANAGER));
    }

    function etherWrapper() internal view returns (IEtherWrapper) {

        return IEtherWrapper(requireAndGetAddress(CONTRACT_ETHER_WRAPPER));
    }

    function futuresMarketManager() internal view returns (IFuturesMarketManager) {

        return IFuturesMarketManager(requireAndGetAddress(CONTRACT_FUTURESMARKETMANAGER));
    }

    function wrapperFactory() internal view returns (IWrapperFactory) {

        return IWrapperFactory(requireAndGetAddress(CONTRACT_WRAPPER_FACTORY));
    }

    function debtSnapshotStaleTime() external view returns (uint) {

        return getDebtSnapshotStaleTime();
    }

    function cachedDebt() external view returns (uint) {

        return _cachedDebt;
    }

    function cachedSynthDebt(bytes32 currencyKey) external view returns (uint) {

        return _cachedSynthDebt[currencyKey];
    }

    function cacheTimestamp() external view returns (uint) {

        return _cacheTimestamp;
    }

    function cacheInvalid() external view returns (bool) {

        return _cacheInvalid;
    }

    function _cacheStale(uint timestamp) internal view returns (bool) {

        return getDebtSnapshotStaleTime() < block.timestamp - timestamp || timestamp == 0;
    }

    function cacheStale() external view returns (bool) {

        return _cacheStale(_cacheTimestamp);
    }

    function _issuedSynthValues(bytes32[] memory currencyKeys, uint[] memory rates)
        internal
        view
        returns (uint[] memory values)
    {

        uint numValues = currencyKeys.length;
        values = new uint[](numValues);
        ISynth[] memory synths = issuer().getSynths(currencyKeys);

        for (uint i = 0; i < numValues; i++) {
            address synthAddress = address(synths[i]);
            require(synthAddress != address(0), "Synth does not exist");
            uint supply = IERC20(synthAddress).totalSupply();
            values[i] = supply.multiplyDecimalRound(rates[i]);
        }

        return (values);
    }

    function _currentSynthDebts(bytes32[] memory currencyKeys)
        internal
        view
        returns (
            uint[] memory snxIssuedDebts,
            uint _futuresDebt,
            uint _excludedDebt,
            bool anyRateIsInvalid
        )
    {

        (uint[] memory rates, bool isInvalid) = exchangeRates().ratesAndInvalidForCurrencies(currencyKeys);
        uint[] memory values = _issuedSynthValues(currencyKeys, rates);
        (uint excludedDebt, bool isAnyNonSnxDebtRateInvalid) = _totalNonSnxBackedDebt(currencyKeys, rates, isInvalid);
        (uint futuresDebt, bool futuresDebtIsInvalid) = futuresMarketManager().totalDebt();

        return (values, futuresDebt, excludedDebt, isInvalid || futuresDebtIsInvalid || isAnyNonSnxDebtRateInvalid);
    }

    function currentSynthDebts(bytes32[] calldata currencyKeys)
        external
        view
        returns (
            uint[] memory debtValues,
            uint futuresDebt,
            uint excludedDebt,
            bool anyRateIsInvalid
        )
    {

        return _currentSynthDebts(currencyKeys);
    }

    function _cachedSynthDebts(bytes32[] memory currencyKeys) internal view returns (uint[] memory) {

        uint numKeys = currencyKeys.length;
        uint[] memory debts = new uint[](numKeys);
        for (uint i = 0; i < numKeys; i++) {
            debts[i] = _cachedSynthDebt[currencyKeys[i]];
        }
        return debts;
    }

    function cachedSynthDebts(bytes32[] calldata currencyKeys) external view returns (uint[] memory snxIssuedDebts) {

        return _cachedSynthDebts(currencyKeys);
    }

    function _excludedIssuedDebts(bytes32[] memory currencyKeys) internal view returns (uint[] memory) {

        uint numKeys = currencyKeys.length;
        uint[] memory debts = new uint[](numKeys);
        for (uint i = 0; i < numKeys; i++) {
            debts[i] = _excludedIssuedDebt[currencyKeys[i]];
        }
        return debts;
    }

    function excludedIssuedDebts(bytes32[] calldata currencyKeys) external view returns (uint[] memory excludedDebts) {

        return _excludedIssuedDebts(currencyKeys);
    }

    function importExcludedIssuedDebts(IDebtCache prevDebtCache, IIssuer prevIssuer) external onlyOwner {

        require(!isInitialized, "already initialized");
        isInitialized = true;

        bytes32[] memory keys = prevIssuer.availableCurrencyKeys();

        require(keys.length > 0, "previous Issuer has no synths");

        uint[] memory debts = prevDebtCache.excludedIssuedDebts(keys);

        for (uint i = 0; i < keys.length; i++) {
            if (debts[i] > 0) {
                _excludedIssuedDebt[keys[i]] = _excludedIssuedDebt[keys[i]].add(debts[i]);
            }
        }
    }

    function totalNonSnxBackedDebt() external view returns (uint excludedDebt, bool isInvalid) {

        bytes32[] memory currencyKeys = issuer().availableCurrencyKeys();
        (uint[] memory rates, bool ratesAreInvalid) = exchangeRates().ratesAndInvalidForCurrencies(currencyKeys);

        return _totalNonSnxBackedDebt(currencyKeys, rates, ratesAreInvalid);
    }

    function _totalNonSnxBackedDebt(
        bytes32[] memory currencyKeys,
        uint[] memory rates,
        bool ratesAreInvalid
    ) internal view returns (uint excludedDebt, bool isInvalid) {

        (uint longValue, bool anyTotalLongRateIsInvalid) = collateralManager().totalLong();
        (uint shortValue, bool anyTotalShortRateIsInvalid) = collateralManager().totalShort();
        isInvalid = ratesAreInvalid || anyTotalLongRateIsInvalid || anyTotalShortRateIsInvalid;
        excludedDebt = longValue.add(shortValue);

        excludedDebt = excludedDebt.add(etherWrapper().totalIssuedSynths());

        for (uint i = 0; i < currencyKeys.length; i++) {
            excludedDebt = excludedDebt.add(_excludedIssuedDebt[currencyKeys[i]].multiplyDecimalRound(rates[i]));
        }

        return (excludedDebt, isInvalid);
    }

    function _currentDebt() internal view returns (uint debt, bool anyRateIsInvalid) {

        bytes32[] memory currencyKeys = issuer().availableCurrencyKeys();
        (uint[] memory rates, bool isInvalid) = exchangeRates().ratesAndInvalidForCurrencies(currencyKeys);

        uint[] memory values = _issuedSynthValues(currencyKeys, rates);
        (uint excludedDebt, bool isAnyNonSnxDebtRateInvalid) = _totalNonSnxBackedDebt(currencyKeys, rates, isInvalid);

        uint numValues = values.length;
        uint total;
        for (uint i; i < numValues; i++) {
            total = total.add(values[i]);
        }

        (uint futuresDebt, bool futuresDebtIsInvalid) = futuresMarketManager().totalDebt();
        total = total.add(futuresDebt);

        total = total < excludedDebt ? 0 : total.sub(excludedDebt);

        return (total, isInvalid || futuresDebtIsInvalid || isAnyNonSnxDebtRateInvalid);
    }

    function currentDebt() external view returns (uint debt, bool anyRateIsInvalid) {

        return _currentDebt();
    }

    function cacheInfo()
        external
        view
        returns (
            uint debt,
            uint timestamp,
            bool isInvalid,
            bool isStale
        )
    {

        uint time = _cacheTimestamp;
        return (_cachedDebt, time, _cacheInvalid, _cacheStale(time));
    }



    function updateCachedSynthDebts(bytes32[] calldata currencyKeys) external {}


    function updateCachedSynthDebtWithRate(bytes32 currencyKey, uint currencyRate) external {}


    function updateCachedSynthDebtsWithRates(bytes32[] calldata currencyKeys, uint[] calldata currencyRates) external {}


    function updateDebtCacheValidity(bool currentlyInvalid) external {}


    function purgeCachedSynthDebt(bytes32 currencyKey) external {}


    function takeDebtSnapshot() external {}


    function recordExcludedDebtChange(bytes32 currencyKey, int256 delta) external {}


    function updateCachedsUSDDebt(int amount) external {}



    function _requireSystemActiveIfNotOwner() internal view {

        if (msg.sender != owner) {
            systemStatus().requireSystemActive();
        }
    }

    modifier requireSystemActiveIfNotOwner() {

        _requireSystemActiveIfNotOwner();
        _;
    }

    function _onlyIssuer() internal view {

        require(msg.sender == address(issuer()), "Sender is not Issuer");
    }

    modifier onlyIssuer() {

        _onlyIssuer();
        _;
    }

    function _onlyIssuerOrExchanger() internal view {

        require(msg.sender == address(issuer()) || msg.sender == address(exchanger()), "Sender is not Issuer or Exchanger");
    }

    modifier onlyIssuerOrExchanger() {

        _onlyIssuerOrExchanger();
        _;
    }

    function _onlyDebtIssuer() internal view {

        bool isWrapper = wrapperFactory().isWrapper(msg.sender);

        bool isOwner = msg.sender == owner;

        require(isOwner || isWrapper, "Only debt issuers may call this");
    }

    modifier onlyDebtIssuer() {

        _onlyDebtIssuer();
        _;
    }
}






contract DebtCache is BaseDebtCache {

    using SafeDecimalMath for uint;

    bytes32 public constant CONTRACT_NAME = "DebtCache";

    constructor(address _owner, address _resolver) public BaseDebtCache(_owner, _resolver) {}

    bytes32 internal constant EXCLUDED_DEBT_KEY = "EXCLUDED_DEBT";
    bytes32 internal constant FUTURES_DEBT_KEY = "FUTURES_DEBT";


    function purgeCachedSynthDebt(bytes32 currencyKey) external onlyOwner {

        require(issuer().synths(currencyKey) == ISynth(0), "Synth exists");
        delete _cachedSynthDebt[currencyKey];
    }

    function takeDebtSnapshot() external requireSystemActiveIfNotOwner {

        bytes32[] memory currencyKeys = issuer().availableCurrencyKeys();
        (uint[] memory values, uint futuresDebt, uint excludedDebt, bool isInvalid) = _currentSynthDebts(currencyKeys);

        uint snxCollateralDebt = futuresDebt;
        _cachedSynthDebt[FUTURES_DEBT_KEY] = futuresDebt;
        uint numValues = values.length;
        for (uint i; i < numValues; i++) {
            uint value = values[i];
            snxCollateralDebt = snxCollateralDebt.add(value);
            _cachedSynthDebt[currencyKeys[i]] = value;
        }

        _cachedSynthDebt[EXCLUDED_DEBT_KEY] = excludedDebt;
        uint newDebt = snxCollateralDebt.floorsub(excludedDebt);
        _cachedDebt = newDebt;
        _cacheTimestamp = block.timestamp;
        emit DebtCacheUpdated(newDebt);
        emit DebtCacheSnapshotTaken(block.timestamp);

        _updateDebtCacheValidity(isInvalid);
    }

    function updateCachedSynthDebts(bytes32[] calldata currencyKeys) external requireSystemActiveIfNotOwner {

        (uint[] memory rates, bool anyRateInvalid) = exchangeRates().ratesAndInvalidForCurrencies(currencyKeys);
        _updateCachedSynthDebtsWithRates(currencyKeys, rates, anyRateInvalid);
    }

    function updateCachedSynthDebtWithRate(bytes32 currencyKey, uint currencyRate) external onlyIssuer {

        bytes32[] memory synthKeyArray = new bytes32[](1);
        synthKeyArray[0] = currencyKey;
        uint[] memory synthRateArray = new uint[](1);
        synthRateArray[0] = currencyRate;
        _updateCachedSynthDebtsWithRates(synthKeyArray, synthRateArray, false);
    }

    function updateCachedSynthDebtsWithRates(bytes32[] calldata currencyKeys, uint[] calldata currencyRates)
        external
        onlyIssuerOrExchanger
    {

        _updateCachedSynthDebtsWithRates(currencyKeys, currencyRates, false);
    }

    function updateDebtCacheValidity(bool currentlyInvalid) external onlyIssuer {

        _updateDebtCacheValidity(currentlyInvalid);
    }

    function recordExcludedDebtChange(bytes32 currencyKey, int256 delta) external onlyDebtIssuer {

        int256 newExcludedDebt = int256(_excludedIssuedDebt[currencyKey]) + delta;

        require(newExcludedDebt >= 0, "Excluded debt cannot become negative");

        _excludedIssuedDebt[currencyKey] = uint(newExcludedDebt);
    }

    function updateCachedsUSDDebt(int amount) external onlyIssuer {

        uint delta = SafeDecimalMath.abs(amount);
        if (amount > 0) {
            _cachedSynthDebt[sUSD] = _cachedSynthDebt[sUSD].add(delta);
            _cachedDebt = _cachedDebt.add(delta);
        } else {
            _cachedSynthDebt[sUSD] = _cachedSynthDebt[sUSD].sub(delta);
            _cachedDebt = _cachedDebt.sub(delta);
        }

        emit DebtCacheUpdated(_cachedDebt);
    }


    function _updateDebtCacheValidity(bool currentlyInvalid) internal {

        if (_cacheInvalid != currentlyInvalid) {
            _cacheInvalid = currentlyInvalid;
            emit DebtCacheValidityChanged(currentlyInvalid);
        }
    }

    function _updateCachedSynthDebtsWithRates(
        bytes32[] memory currencyKeys,
        uint[] memory currentRates,
        bool anyRateIsInvalid
    ) internal {

        uint numKeys = currencyKeys.length;
        require(numKeys == currentRates.length, "Input array lengths differ");

        uint cachedSum;
        uint currentSum;
        uint[] memory currentValues = _issuedSynthValues(currencyKeys, currentRates);

        for (uint i = 0; i < numKeys; i++) {
            bytes32 key = currencyKeys[i];
            uint currentSynthDebt = currentValues[i];

            cachedSum = cachedSum.add(_cachedSynthDebt[key]);
            currentSum = currentSum.add(currentSynthDebt);

            _cachedSynthDebt[key] = currentSynthDebt;
        }

        if (cachedSum != currentSum) {
            uint debt = _cachedDebt;
            debt = debt.add(currentSum).sub(cachedSum);
            _cachedDebt = debt;
            emit DebtCacheUpdated(debt);
        }

        if (anyRateIsInvalid) {
            _updateDebtCacheValidity(anyRateIsInvalid);
        }
    }


    event DebtCacheUpdated(uint cachedDebt);
    event DebtCacheSnapshotTaken(uint timestamp);
    event DebtCacheValidityChanged(bool indexed isInvalid);
}