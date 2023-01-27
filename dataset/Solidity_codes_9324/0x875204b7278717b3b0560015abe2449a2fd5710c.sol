
pragma solidity ^0.7.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(value)));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(value)));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(value)));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint256(_at(set._inner, index)));
    }



    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }
}// MIT

pragma solidity ^0.7.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}// MIT

pragma solidity ^0.7.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
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

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity ^0.7.0;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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

pragma solidity >=0.4.24 <0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

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

    function _isConstructor() private view returns (bool) {
        address self = address(this);
        uint256 cs;
        assembly { cs := extcodesize(self) }
        return cs == 0;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    uint256[49] private __gap;
}// MIT
pragma solidity ^0.7.4;

interface IPolicyBookFabric {

    enum ContractType {CONTRACT, STABLECOIN, SERVICE, EXCHANGE, VARIOUS}

    function create(
        address _contract,
        ContractType _contractType,
        string calldata _description,
        string calldata _projectSymbol,
        uint256 _initialDeposit,
        address _shieldMiningToken
    ) external returns (address);


    function createLeveragePools(
        address _insuranceContract,
        ContractType _contractType,
        string calldata _description,
        string calldata _projectSymbol
    ) external returns (address);

}// MIT
pragma solidity ^0.7.4;
pragma experimental ABIEncoderV2;


interface IClaimingRegistry {

    enum ClaimStatus {
        CAN_CLAIM,
        UNCLAIMABLE,
        PENDING,
        AWAITING_CALCULATION,
        REJECTED_CAN_APPEAL,
        REJECTED,
        ACCEPTED,
        EXPIRED
    }

    struct ClaimInfo {
        address claimer;
        address policyBookAddress;
        string evidenceURI;
        uint256 dateSubmitted;
        uint256 dateEnded;
        bool appeal;
        ClaimStatus status;
        uint256 claimAmount;
        uint256 claimRefund;
    }

    struct ClaimWithdrawalInfo {
        uint256 readyToWithdrawDate;
        bool committed;
    }

    struct RewardWithdrawalInfo {
        uint256 rewardAmount;
        uint256 readyToWithdrawDate;
    }

    enum WithdrawalStatus {NONE, PENDING, READY, EXPIRED}

    function claimWithdrawalInfo(uint256 index)
        external
        view
        returns (uint256 readyToWithdrawDate, bool committed);


    function rewardWithdrawalInfo(address voter)
        external
        view
        returns (uint256 rewardAmount, uint256 readyToWithdrawDate);


    function anonymousVotingDuration(uint256 index) external view returns (uint256);


    function votingDuration(uint256 index) external view returns (uint256);


    function validityDuration(uint256 index) external view returns (uint256);


    function anyoneCanCalculateClaimResultAfter(uint256 index) external view returns (uint256);


    function canBuyNewPolicy(address buyer, address policyBookAddress) external;


    function getClaimWithdrawalStatus(uint256 index) external view returns (WithdrawalStatus);


    function getRewardWithdrawalStatus(address voter) external view returns (WithdrawalStatus);


    function hasProcedureOngoing(address poolAddress) external view returns (bool);


    function submitClaim(
        address user,
        address policyBookAddress,
        string calldata evidenceURI,
        uint256 cover,
        bool appeal
    ) external returns (uint256);


    function claimExists(uint256 index) external view returns (bool);


    function claimSubmittedTime(uint256 index) external view returns (uint256);


    function claimEndTime(uint256 index) external view returns (uint256);


    function isClaimAnonymouslyVotable(uint256 index) external view returns (bool);


    function isClaimExposablyVotable(uint256 index) external view returns (bool);


    function isClaimVotable(uint256 index) external view returns (bool);


    function canClaimBeCalculatedByAnyone(uint256 index) external view returns (bool);


    function isClaimPending(uint256 index) external view returns (bool);


    function countPolicyClaimerClaims(address user) external view returns (uint256);


    function countPendingClaims() external view returns (uint256);


    function countClaims() external view returns (uint256);


    function claimOfOwnerIndexAt(address claimer, uint256 orderIndex)
        external
        view
        returns (uint256);


    function pendingClaimIndexAt(uint256 orderIndex) external view returns (uint256);


    function claimIndexAt(uint256 orderIndex) external view returns (uint256);


    function claimIndex(address claimer, address policyBookAddress)
        external
        view
        returns (uint256);


    function isClaimAppeal(uint256 index) external view returns (bool);


    function policyStatus(address claimer, address policyBookAddress)
        external
        view
        returns (ClaimStatus);


    function claimStatus(uint256 index) external view returns (ClaimStatus);


    function claimOwner(uint256 index) external view returns (address);


    function claimPolicyBook(uint256 index) external view returns (address);


    function claimInfo(uint256 index) external view returns (ClaimInfo memory _claimInfo);


    function getAllPendingClaimsAmount() external view returns (uint256 _totalClaimsAmount);


    function getAllPendingRewardsAmount() external view returns (uint256 _totalRewardsAmount);


    function getClaimableAmounts(uint256[] memory _claimIndexes) external view returns (uint256);


    function acceptClaim(uint256 index, uint256 amount) external;


    function rejectClaim(uint256 index) external;


    function expireClaim(uint256 index) external;


    function updateImageUriOfClaim(uint256 claim_Index, string calldata _newEvidenceURI) external;


    function requestClaimWithdrawal(uint256 index) external;


    function requestRewardWithdrawal(address voter, uint256 rewardAmount) external;

}// MIT
pragma solidity ^0.7.4;

interface IPolicyBookAdmin {

    enum PoolTypes {POLICY_BOOK, POLICY_FACADE, LEVERAGE_POOL}

    function getUpgrader() external view returns (address);


    function getImplementationOfPolicyBook(address policyBookAddress) external returns (address);


    function getImplementationOfPolicyBookFacade(address policyBookFacadeAddress)
        external
        returns (address);


    function getCurrentPolicyBooksImplementation() external view returns (address);


    function getCurrentPolicyBooksFacadeImplementation() external view returns (address);


    function getCurrentUserLeverageImplementation() external view returns (address);


    function whitelist(address policyBookAddress, bool whitelisted) external;


    function whitelistDistributor(address _distributor, uint256 _distributorFee) external;


    function blacklistDistributor(address _distributor) external;


    function isWhitelistedDistributor(address _distributor) external view returns (bool);


    function distributorFees(address _distributor) external view returns (uint256);


    function listDistributors(uint256 offset, uint256 limit)
        external
        view
        returns (address[] memory _distributors, uint256[] memory _distributorsFees);


    function countDistributors() external view returns (uint256);


    function setPolicyBookFacadeMPLs(
        address _facadeAddress,
        uint256 _userLeverageMPL,
        uint256 _reinsuranceLeverageMPL
    ) external;


    function setPolicyBookFacadeRebalancingThreshold(
        address _facadeAddress,
        uint256 _newRebalancingThreshold
    ) external;


    function setPolicyBookFacadeSafePricingModel(address _facadeAddress, bool _safePricingModel)
        external;


    function setLeveragePortfolioRebalancingThreshold(
        address _LeveragePoolAddress,
        uint256 _newRebalancingThreshold
    ) external;


    function setLeveragePortfolioProtocolConstant(
        address _LeveragePoolAddress,
        uint256 _targetUR,
        uint256 _d_ProtocolConstant,
        uint256 _a1_ProtocolConstant,
        uint256 _max_ProtocolConstant
    ) external;


    function setUserLeverageMaxCapacities(address _userLeverageAddress, uint256 _maxCapacities)
        external;


    function setUserLeverageA2_ProtocolConstant(
        address _userLeverageAddress,
        uint256 _a2_ProtocolConstant
    ) external;


    function setupPricingModel(
        uint256 _highRiskRiskyAssetThresholdPercentage,
        uint256 _lowRiskRiskyAssetThresholdPercentage,
        uint256 _highRiskMinimumCostPercentage,
        uint256 _lowRiskMinimumCostPercentage,
        uint256 _minimumInsuranceCost,
        uint256 _lowRiskMaxPercentPremiumCost,
        uint256 _lowRiskMaxPercentPremiumCost100Utilization,
        uint256 _highRiskMaxPercentPremiumCost,
        uint256 _highRiskMaxPercentPremiumCost100Utilization
    ) external;

}// MIT
pragma solidity ^0.7.4;


interface IPolicyBookRegistry {

    struct PolicyBookStats {
        string symbol;
        address insuredContract;
        IPolicyBookFabric.ContractType contractType;
        uint256 maxCapacity;
        uint256 totalSTBLLiquidity;
        uint256 totalLeveragedLiquidity;
        uint256 stakedSTBL;
        uint256 APY;
        uint256 annualInsuranceCost;
        uint256 bmiXRatio;
        bool whitelisted;
    }

    function policyBooksByInsuredAddress(address insuredContract) external view returns (address);


    function policyBookFacades(address facadeAddress) external view returns (address);


    function add(
        address insuredContract,
        IPolicyBookFabric.ContractType contractType,
        address policyBook,
        address facadeAddress
    ) external;


    function whitelist(address policyBookAddress, bool whitelisted) external;


    function getPoliciesPrices(
        address[] calldata policyBooks,
        uint256[] calldata epochsNumbers,
        uint256[] calldata coversTokens
    ) external view returns (uint256[] memory _durations, uint256[] memory _allowances);


    function buyPolicyBatch(
        address[] calldata policyBooks,
        uint256[] calldata epochsNumbers,
        uint256[] calldata coversTokens
    ) external;


    function isPolicyBook(address policyBook) external view returns (bool);


    function isPolicyBookFacade(address _facadeAddress) external view returns (bool);


    function isUserLeveragePool(address policyBookAddress) external view returns (bool);


    function countByType(IPolicyBookFabric.ContractType contractType)
        external
        view
        returns (uint256);


    function count() external view returns (uint256);


    function countByTypeWhitelisted(IPolicyBookFabric.ContractType contractType)
        external
        view
        returns (uint256);


    function countWhitelisted() external view returns (uint256);


    function listByType(
        IPolicyBookFabric.ContractType contractType,
        uint256 offset,
        uint256 limit
    ) external view returns (address[] memory _policyBooksArr);


    function list(uint256 offset, uint256 limit)
        external
        view
        returns (address[] memory _policyBooksArr);


    function listByTypeWhitelisted(
        IPolicyBookFabric.ContractType contractType,
        uint256 offset,
        uint256 limit
    ) external view returns (address[] memory _policyBooksArr);


    function listWhitelisted(uint256 offset, uint256 limit)
        external
        view
        returns (address[] memory _policyBooksArr);


    function listWithStatsByType(
        IPolicyBookFabric.ContractType contractType,
        uint256 offset,
        uint256 limit
    ) external view returns (address[] memory _policyBooksArr, PolicyBookStats[] memory _stats);


    function listWithStats(uint256 offset, uint256 limit)
        external
        view
        returns (address[] memory _policyBooksArr, PolicyBookStats[] memory _stats);


    function listWithStatsByTypeWhitelisted(
        IPolicyBookFabric.ContractType contractType,
        uint256 offset,
        uint256 limit
    ) external view returns (address[] memory _policyBooksArr, PolicyBookStats[] memory _stats);


    function listWithStatsWhitelisted(uint256 offset, uint256 limit)
        external
        view
        returns (address[] memory _policyBooksArr, PolicyBookStats[] memory _stats);


    function stats(address[] calldata policyBooks)
        external
        view
        returns (PolicyBookStats[] memory _stats);


    function policyBookFor(address insuredContract) external view returns (address);


    function statsByInsuredContracts(address[] calldata insuredContracts)
        external
        view
        returns (PolicyBookStats[] memory _stats);

}// MIT
pragma solidity ^0.7.4;

interface IContractsRegistry {

    function getAMMRouterContract() external view returns (address);


    function getAMMBMIToETHPairContract() external view returns (address);


    function getAMMBMIToUSDTPairContract() external view returns (address);


    function getSushiSwapMasterChefV2Contract() external view returns (address);


    function getWrappedTokenContract() external view returns (address);


    function getUSDTContract() external view returns (address);


    function getBMIContract() external view returns (address);


    function getPriceFeedContract() external view returns (address);


    function getPolicyBookRegistryContract() external view returns (address);


    function getPolicyBookFabricContract() external view returns (address);


    function getBMICoverStakingContract() external view returns (address);


    function getBMICoverStakingViewContract() external view returns (address);


    function getBMITreasury() external view returns (address);


    function getRewardsGeneratorContract() external view returns (address);


    function getBMIUtilityNFTContract() external view returns (address);


    function getNFTStakingContract() external view returns (address);


    function getLiquidityBridgeContract() external view returns (address);


    function getClaimingRegistryContract() external view returns (address);


    function getPolicyRegistryContract() external view returns (address);


    function getLiquidityRegistryContract() external view returns (address);


    function getClaimVotingContract() external view returns (address);


    function getReinsurancePoolContract() external view returns (address);


    function getLeveragePortfolioViewContract() external view returns (address);


    function getCapitalPoolContract() external view returns (address);


    function getPolicyBookAdminContract() external view returns (address);


    function getPolicyQuoteContract() external view returns (address);


    function getBMIStakingContract() external view returns (address);


    function getSTKBMIContract() external view returns (address);


    function getStkBMIStakingContract() external view returns (address);


    function getVBMIContract() external view returns (address);


    function getLiquidityMiningStakingETHContract() external view returns (address);


    function getLiquidityMiningStakingUSDTContract() external view returns (address);


    function getReputationSystemContract() external view returns (address);


    function getDefiProtocol1Contract() external view returns (address);


    function getAaveLendPoolAddressProvdierContract() external view returns (address);


    function getAaveATokenContract() external view returns (address);


    function getDefiProtocol2Contract() external view returns (address);


    function getCompoundCTokenContract() external view returns (address);


    function getCompoundComptrollerContract() external view returns (address);


    function getDefiProtocol3Contract() external view returns (address);


    function getYearnVaultContract() external view returns (address);


    function getYieldGeneratorContract() external view returns (address);


    function getShieldMiningContract() external view returns (address);

}// MIT
pragma solidity ^0.7.4;

interface ILeveragePortfolio {

    enum LeveragePortfolio {USERLEVERAGEPOOL, REINSURANCEPOOL}
    struct LevFundsFactors {
        uint256 netMPL;
        uint256 netMPLn;
        address policyBookAddr;
    }

    function targetUR() external view returns (uint256);


    function d_ProtocolConstant() external view returns (uint256);


    function a_ProtocolConstant() external view returns (uint256);


    function max_ProtocolConstant() external view returns (uint256);


    function deployLeverageStableToCoveragePools(LeveragePortfolio leveragePoolType)
        external
        returns (uint256);


    function deployVirtualStableToCoveragePools() external returns (uint256);


    function setRebalancingThreshold(uint256 threshold) external;


    function setProtocolConstant(
        uint256 _targetUR,
        uint256 _d_ProtocolConstant,
        uint256 _a1_ProtocolConstant,
        uint256 _max_ProtocolConstant
    ) external;



    function totalLiquidity() external view returns (uint256);


    function addPolicyPremium(uint256 epochsNumber, uint256 premiumAmount) external;


    function listleveragedCoveragePools(uint256 offset, uint256 limit)
        external
        view
        returns (address[] memory _coveragePools);


    function countleveragedCoveragePools() external view returns (uint256);


    function updateLiquidity(uint256 _lostLiquidity) external;


    function forceUpdateBMICoverStakingRewardMultiplier() external;

}// MIT
pragma solidity ^0.7.4;


interface IPolicyBookFacade {

    function buyPolicy(uint256 _epochsNumber, uint256 _coverTokens) external;


    function buyPolicyFor(
        address _holder,
        uint256 _epochsNumber,
        uint256 _coverTokens
    ) external;


    function policyBook() external view returns (IPolicyBook);


    function userLiquidity(address account) external view returns (uint256);


    function forceUpdateBMICoverStakingRewardMultiplier() external;


    function getPolicyPrice(
        uint256 _epochsNumber,
        uint256 _coverTokens,
        address _buyer
    )
        external
        view
        returns (
            uint256 totalSeconds,
            uint256 totalPrice,
            uint256 pricePercentage
        );


    function secondsToEndCurrentEpoch() external view returns (uint256);


    function VUreinsurnacePool() external view returns (uint256);


    function LUreinsurnacePool() external view returns (uint256);


    function LUuserLeveragePool(address userLeveragePool) external view returns (uint256);


    function totalLeveragedLiquidity() external view returns (uint256);


    function userleveragedMPL() external view returns (uint256);


    function reinsurancePoolMPL() external view returns (uint256);


    function rebalancingThreshold() external view returns (uint256);


    function safePricingModel() external view returns (bool);


    function __PolicyBookFacade_init(
        address pbProxy,
        address liquidityProvider,
        uint256 initialDeposit
    ) external;


    function buyPolicyFromDistributor(
        uint256 _epochsNumber,
        uint256 _coverTokens,
        address _distributor
    ) external;


    function buyPolicyFromDistributorFor(
        address _buyer,
        uint256 _epochsNumber,
        uint256 _coverTokens,
        address _distributor
    ) external;


    function addLiquidity(uint256 _liquidityAmount) external;


    function addLiquidityFromDistributorFor(address _user, uint256 _liquidityAmount) external;


    function addLiquidityAndStakeFor(
        address _liquidityHolderAddr,
        uint256 _liquidityAmount,
        uint256 _stakeSTBLAmount
    ) external;


    function addLiquidityAndStake(uint256 _liquidityAmount, uint256 _stakeSTBLAmount) external;


    function withdrawLiquidity() external;


    function deployLeverageFundsAfterRebalance(
        uint256 deployedAmount,
        ILeveragePortfolio.LeveragePortfolio leveragePool
    ) external;


    function deployVirtualFundsAfterRebalance(uint256 deployedAmount) external;


    function reevaluateProvidedLeverageStable() external;


    function setMPLs(uint256 _userLeverageMPL, uint256 _reinsuranceLeverageMPL) external;


    function setRebalancingThreshold(uint256 _newRebalancingThreshold) external;


    function setSafePricingModel(bool _safePricingModel) external;


    function getClaimApprovalAmount(address user) external view returns (uint256);


    function requestWithdrawal(uint256 _tokensToWithdraw) external;


    function listUserLeveragePools(uint256 offset, uint256 limit)
        external
        view
        returns (address[] memory _userLeveragePools);


    function countUserLeveragePools() external view returns (uint256);


    function info()
        external
        view
        returns (
            string memory _symbol,
            address _insuredContract,
            IPolicyBookFabric.ContractType _contractType,
            bool _whitelisted
        );

}// MIT
pragma solidity ^0.7.4;


interface IPolicyBook {

    enum WithdrawalStatus {NONE, PENDING, READY, EXPIRED}

    struct PolicyHolder {
        uint256 coverTokens;
        uint256 startEpochNumber;
        uint256 endEpochNumber;
        uint256 paid;
        uint256 reinsurancePrice;
    }

    struct WithdrawalInfo {
        uint256 withdrawalAmount;
        uint256 readyToWithdrawDate;
        bool withdrawalAllowed;
    }

    struct BuyPolicyParameters {
        address buyer;
        address holder;
        uint256 epochsNumber;
        uint256 coverTokens;
        uint256 distributorFee;
        address distributor;
    }

    function policyHolders(address _holder)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        );


    function policyBookFacade() external view returns (IPolicyBookFacade);


    function setPolicyBookFacade(address _policyBookFacade) external;


    function EPOCH_DURATION() external view returns (uint256);


    function stblDecimals() external view returns (uint256);


    function READY_TO_WITHDRAW_PERIOD() external view returns (uint256);


    function whitelisted() external view returns (bool);


    function epochStartTime() external view returns (uint256);


    function insuranceContractAddress() external view returns (address _contract);


    function contractType() external view returns (IPolicyBookFabric.ContractType _type);


    function totalLiquidity() external view returns (uint256);


    function totalCoverTokens() external view returns (uint256);





    function withdrawalsInfo(address _userAddr)
        external
        view
        returns (
            uint256 _withdrawalAmount,
            uint256 _readyToWithdrawDate,
            bool _withdrawalAllowed
        );


    function __PolicyBook_init(
        address _insuranceContract,
        IPolicyBookFabric.ContractType _contractType,
        string calldata _description,
        string calldata _projectSymbol
    ) external;


    function whitelist(bool _whitelisted) external;


    function getEpoch(uint256 time) external view returns (uint256);


    function convertBMIXToSTBL(uint256 _amount) external view returns (uint256);


    function convertSTBLToBMIX(uint256 _amount) external view returns (uint256);


    function submitClaimAndInitializeVoting(string calldata evidenceURI) external;


    function submitAppealAndInitializeVoting(string calldata evidenceURI) external;


    function commitClaim(
        address claimer,
        uint256 claimEndTime,
        IClaimingRegistry.ClaimStatus status
    ) external;


    function commitWithdrawnClaim(address claimer) external;


    function getNewCoverAndLiquidity()
        external
        view
        returns (uint256 newTotalCoverTokens, uint256 newTotalLiquidity);


    function buyPolicy(
        address _buyer,
        address _holder,
        uint256 _epochsNumber,
        uint256 _coverTokens,
        uint256 _distributorFee,
        address _distributor
    ) external returns (uint256, uint256);


    function endActivePolicy(address _holder) external;


    function updateEpochsInfo() external;


    function addLiquidityFor(address _liquidityHolderAddr, uint256 _liqudityAmount) external;


    function addLiquidity(
        address _liquidityBuyerAddr,
        address _liquidityHolderAddr,
        uint256 _liquidityAmount,
        uint256 _stakeSTBLAmount
    ) external returns (uint256);


    function getAvailableBMIXWithdrawableAmount(address _userAddr) external view returns (uint256);


    function getWithdrawalStatus(address _userAddr) external view returns (WithdrawalStatus);


    function requestWithdrawal(uint256 _tokensToWithdraw, address _user) external;



    function unlockTokens() external;


    function withdrawLiquidity(address sender) external returns (uint256);


    function updateLiquidity(uint256 _newLiquidity) external;


    function getAPY() external view returns (uint256);


    function userStats(address _user) external view returns (PolicyHolder memory);


    function numberStats()
        external
        view
        returns (
            uint256 _maxCapacities,
            uint256 _buyPolicyCapacity,
            uint256 _totalSTBLLiquidity,
            uint256 _totalLeveragedLiquidity,
            uint256 _stakedSTBL,
            uint256 _annualProfitYields,
            uint256 _annualInsuranceCost,
            uint256 _bmiXRatio
        );

}// MIT
pragma solidity ^0.7.4;


interface IUserLeveragePool {

    enum WithdrawalStatus {NONE, PENDING, READY, EXPIRED}

    struct WithdrawalInfo {
        uint256 withdrawalAmount;
        uint256 readyToWithdrawDate;
        bool withdrawalAllowed;
    }

    struct BMIMultiplierFactors {
        uint256 poolMultiplier;
        uint256 leverageProvided;
        uint256 multiplier;
    }

    function contractType() external view returns (IPolicyBookFabric.ContractType _type);


    function userLiquidity(address account) external view returns (uint256);


    function a2_ProtocolConstant() external view returns (uint256);


    function EPOCH_DURATION() external view returns (uint256);


    function READY_TO_WITHDRAW_PERIOD() external view returns (uint256);


    function epochStartTime() external view returns (uint256);


    function withdrawalsInfo(address _userAddr)
        external
        view
        returns (
            uint256 _withdrawalAmount,
            uint256 _readyToWithdrawDate,
            bool _withdrawalAllowed
        );


    function __UserLeveragePool_init(
        IPolicyBookFabric.ContractType _contractType,
        string calldata _description,
        string calldata _projectSymbol
    ) external;


    function getEpoch(uint256 time) external view returns (uint256);


    function convertBMIXToSTBL(uint256 _amount) external view returns (uint256);


    function convertSTBLToBMIX(uint256 _amount) external view returns (uint256);


    function getNewCoverAndLiquidity()
        external
        view
        returns (uint256 newTotalCoverTokens, uint256 newTotalLiquidity);


    function updateEpochsInfo() external;


    function secondsToEndCurrentEpoch() external view returns (uint256);


    function addLiquidity(uint256 _liqudityAmount) external;



    function addLiquidityAndStake(uint256 _liquidityAmount, uint256 _stakeSTBLAmount) external;


    function getAvailableBMIXWithdrawableAmount(address _userAddr) external view returns (uint256);


    function getWithdrawalStatus(address _userAddr) external view returns (WithdrawalStatus);


    function requestWithdrawal(uint256 _tokensToWithdraw) external;



    function unlockTokens() external;


    function withdrawLiquidity() external;


    function getAPY() external view returns (uint256);


    function whitelisted() external view returns (bool);


    function whitelist(bool _whitelisted) external;


    function setMaxCapacities(uint256 _maxCapacities) external;


    function setA2_ProtocolConstant(uint256 _a2_ProtocolConstant) external;


    function numberStats()
        external
        view
        returns (
            uint256 _maxCapacities,
            uint256 _buyPolicyCapacity,
            uint256 _totalSTBLLiquidity,
            uint256 _totalLeveragedLiquidity,
            uint256 _stakedSTBL,
            uint256 _annualProfitYields,
            uint256 _annualInsuranceCost,
            uint256 _bmiXRatio
        );


    function info()
        external
        view
        returns (
            string memory _symbol,
            address _insuredContract,
            IPolicyBookFabric.ContractType _contractType,
            bool _whitelisted
        );

}// MIT
pragma solidity ^0.7.4;

interface IPolicyQuote {

    function getQuotePredefined(
        uint256 _durationSeconds,
        uint256 _tokens,
        uint256 _totalCoverTokens,
        uint256 _totalLiquidity,
        uint256 _totalLeveragedLiquidity,
        bool _safePricingModel
    ) external view returns (uint256, uint256);


    function getQuote(
        uint256 _durationSeconds,
        uint256 _tokens,
        address _policyBookAddr
    ) external view returns (uint256);


    function setupPricingModel(
        uint256 _highRiskRiskyAssetThresholdPercentage,
        uint256 _lowRiskRiskyAssetThresholdPercentage,
        uint256 _highRiskMinimumCostPercentage,
        uint256 _lowRiskMinimumCostPercentage,
        uint256 _minimumInsuranceCost,
        uint256 _lowRiskMaxPercentPremiumCost,
        uint256 _lowRiskMaxPercentPremiumCost100Utilization,
        uint256 _highRiskMaxPercentPremiumCost,
        uint256 _highRiskMaxPercentPremiumCost100Utilization
    ) external;


    function getMINUR(bool _safePricingModel) external view returns (uint256 _minUR);

}// MIT
pragma solidity ^0.7.4;


abstract contract AbstractDependant {
    bytes32 private constant _INJECTOR_SLOT =
        0xd6b8f2e074594ceb05d47c27386969754b6ad0c15e5eb8f691399cd0be980e76;

    modifier onlyInjectorOrZero() {
        address _injector = injector();

        require(_injector == address(0) || _injector == msg.sender, "Dependant: Not an injector");
        _;
    }

    function setInjector(address _injector) external onlyInjectorOrZero {
        bytes32 slot = _INJECTOR_SLOT;

        assembly {
            sstore(slot, _injector)
        }
    }

    function setDependencies(IContractsRegistry) external virtual;

    function injector() public view returns (address _injector) {
        bytes32 slot = _INJECTOR_SLOT;

        assembly {
            _injector := sload(slot)
        }
    }
}// MIT

pragma solidity ^0.7.0;

abstract contract Proxy {
    function _delegate(address implementation) internal {
        assembly {
            calldatacopy(0, 0, calldatasize())

            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    function _implementation() internal virtual view returns (address);

    function _fallback() internal {
        _beforeFallback();
        _delegate(_implementation());
    }

    fallback () payable external {
        _fallback();
    }

    receive () payable external {
        _fallback();
    }

    function _beforeFallback() internal virtual {
    }
}// MIT

pragma solidity ^0.7.0;


contract UpgradeableProxy is Proxy {

    constructor(address _logic, bytes memory _data) payable {
        assert(_IMPLEMENTATION_SLOT == bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1));
        _setImplementation(_logic);
        if(_data.length > 0) {
            (bool success,) = _logic.delegatecall(_data);
            require(success);
        }
    }

    event Upgraded(address indexed implementation);

    bytes32 private constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    function _implementation() internal override view returns (address impl) {

        bytes32 slot = _IMPLEMENTATION_SLOT;
        assembly {
            impl := sload(slot)
        }
    }

    function _upgradeTo(address newImplementation) internal {

        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    function _setImplementation(address newImplementation) private {

        require(Address.isContract(newImplementation), "UpgradeableProxy: new implementation is not a contract");

        bytes32 slot = _IMPLEMENTATION_SLOT;

        assembly {
            sstore(slot, newImplementation)
        }
    }
}// MIT

pragma solidity ^0.7.0;


contract TransparentUpgradeableProxy is UpgradeableProxy {

    constructor(address _logic, address _admin, bytes memory _data) payable UpgradeableProxy(_logic, _data) {
        assert(_ADMIN_SLOT == bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1));
        _setAdmin(_admin);
    }

    event AdminChanged(address previousAdmin, address newAdmin);

    bytes32 private constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    modifier ifAdmin() {

        if (msg.sender == _admin()) {
            _;
        } else {
            _fallback();
        }
    }

    function admin() external ifAdmin returns (address) {

        return _admin();
    }

    function implementation() external ifAdmin returns (address) {

        return _implementation();
    }

    function changeAdmin(address newAdmin) external ifAdmin {

        require(newAdmin != address(0), "TransparentUpgradeableProxy: new admin is the zero address");
        emit AdminChanged(_admin(), newAdmin);
        _setAdmin(newAdmin);
    }

    function upgradeTo(address newImplementation) external ifAdmin {

        _upgradeTo(newImplementation);
    }

    function upgradeToAndCall(address newImplementation, bytes calldata data) external payable ifAdmin {

        _upgradeTo(newImplementation);
        (bool success,) = newImplementation.delegatecall(data);
        require(success);
    }

    function _admin() internal view returns (address adm) {

        bytes32 slot = _ADMIN_SLOT;
        assembly {
            adm := sload(slot)
        }
    }

    function _setAdmin(address newAdmin) private {

        bytes32 slot = _ADMIN_SLOT;

        assembly {
            sstore(slot, newAdmin)
        }
    }

    function _beforeFallback() internal override virtual {

        require(msg.sender != _admin(), "TransparentUpgradeableProxy: admin cannot fallback to proxy target");
        super._beforeFallback();
    }
}// MIT
pragma solidity ^0.7.4;


contract Upgrader {

    address private immutable _owner;

    modifier onlyOwner() {

        require(_owner == msg.sender, "DependencyInjector: Not an owner");
        _;
    }

    constructor() {
        _owner = msg.sender;
    }

    function upgrade(address what, address to) external onlyOwner {

        TransparentUpgradeableProxy(payable(what)).upgradeTo(to);
    }

    function upgradeAndCall(
        address what,
        address to,
        bytes calldata data
    ) external onlyOwner {

        TransparentUpgradeableProxy(payable(what)).upgradeToAndCall(to, data);
    }

    function getImplementation(address what) external onlyOwner returns (address) {

        return TransparentUpgradeableProxy(payable(what)).implementation();
    }
}// MIT
pragma solidity ^0.7.4;

uint256 constant SECONDS_IN_THE_YEAR = 365 * 24 * 60 * 60; // 365 days * 24 hours * 60 minutes * 60 seconds
uint256 constant DAYS_IN_THE_YEAR = 365;
uint256 constant MAX_INT = type(uint256).max;

uint256 constant DECIMALS18 = 10**18;

uint256 constant PRECISION = 10**25;
uint256 constant PERCENTAGE_100 = 100 * PRECISION;

uint256 constant BLOCKS_PER_DAY = 6450;
uint256 constant BLOCKS_PER_YEAR = BLOCKS_PER_DAY * 365;

uint256 constant APY_TOKENS = DECIMALS18;

uint256 constant PROTOCOL_PERCENTAGE = 20 * PRECISION;

uint256 constant DEFAULT_REBALANCING_THRESHOLD = 10**23;

uint256 constant EPOCH_DAYS_AMOUNT = 7;// MIT
pragma solidity ^0.7.4;






contract PolicyBookAdmin is IPolicyBookAdmin, OwnableUpgradeable, AbstractDependant {

    using Math for uint256;
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    IContractsRegistry public contractsRegistry;
    IPolicyBookRegistry public policyBookRegistry;

    Upgrader internal upgrader;
    address private policyBookImplementationAddress;

    address private policyBookFacadeImplementationAddress;
    address private userLeverageImplementationAddress;

    IClaimingRegistry internal claimingRegistry;
    EnumerableSet.AddressSet private _whitelistedDistributors;
    mapping(address => uint256) public override distributorFees;

    event PolicyBookWhitelisted(address policyBookAddress, bool trigger);
    event DistributorWhitelisted(address distributorAddress, uint256 distributorFee);
    event DistributorBlacklisted(address distributorAddress);
    event UpdatedImageURI(uint256 claimIndex, string oldImageUri, string newImageUri);

    uint256 public constant MAX_DISTRIBUTOR_FEE = 20 * PRECISION;

    IPolicyQuote public policyQuote;

    function __PolicyBookAdmin_init(
        address _policyBookImplementationAddress,
        address _policyBookFacadeImplementationAddress,
        address _userLeverageImplementationAddress
    ) external initializer {

        require(_policyBookImplementationAddress != address(0), "PBA: PB Zero address");
        require(_policyBookFacadeImplementationAddress != address(0), "PBA: PBF Zero address");
        require(_userLeverageImplementationAddress != address(0), "PBA: PBF Zero address");

        __Ownable_init();

        upgrader = new Upgrader();

        policyBookImplementationAddress = _policyBookImplementationAddress;
        policyBookFacadeImplementationAddress = _policyBookFacadeImplementationAddress;
        userLeverageImplementationAddress = _userLeverageImplementationAddress;
    }

    function setDependencies(IContractsRegistry _contractsRegistry)
        external
        override
        onlyInjectorOrZero
    {

        contractsRegistry = _contractsRegistry;

        policyBookRegistry = IPolicyBookRegistry(
            _contractsRegistry.getPolicyBookRegistryContract()
        );
        claimingRegistry = IClaimingRegistry(_contractsRegistry.getClaimingRegistryContract());

        policyQuote = IPolicyQuote(_contractsRegistry.getPolicyQuoteContract());
    }

    function injectDependenciesToExistingPolicies(
        uint256 offset,
        uint256 limit,
        PoolTypes _poolType
    ) external onlyOwner {

        address[] memory _policies = policyBookRegistry.list(offset, limit);
        IContractsRegistry _contractsRegistry = contractsRegistry;

        uint256 to = (offset.add(limit)).min(_policies.length).max(offset);

        for (uint256 i = offset; i < to; i++) {
            address _pool;
            if (_poolType == PoolTypes.POLICY_BOOK || _poolType == PoolTypes.POLICY_FACADE) {
                if (policyBookRegistry.isUserLeveragePool(_policies[i])) continue;
                _pool = _policies[i];
                if (_poolType == PoolTypes.POLICY_FACADE) {
                    IPolicyBook _policyBook = IPolicyBook(_pool);
                    _pool = address(_policyBook.policyBookFacade());
                }
            } else {
                if (!policyBookRegistry.isUserLeveragePool(_policies[i])) continue;
                _pool = _policies[i];
            }

            AbstractDependant dependant = AbstractDependant(_pool);

            if (dependant.injector() == address(0)) {
                dependant.setInjector(address(this));
            }

            dependant.setDependencies(_contractsRegistry);
        }
    }

    function getUpgrader() external view override returns (address) {

        require(address(upgrader) != address(0), "PolicyBookAdmin: Bad upgrader");

        return address(upgrader);
    }

    function getImplementationOfPolicyBook(address policyBookAddress)
        external
        override
        returns (address)
    {

        require(
            policyBookRegistry.isPolicyBook(policyBookAddress),
            "PolicyBookAdmin: Not a PolicyBook"
        );

        return upgrader.getImplementation(policyBookAddress);
    }

    function getImplementationOfPolicyBookFacade(address policyBookFacadeAddress)
        external
        override
        returns (address)
    {

        require(
            policyBookRegistry.isPolicyBookFacade(policyBookFacadeAddress),
            "PolicyBookAdmin: Not a PolicyBookFacade"
        );

        return upgrader.getImplementation(policyBookFacadeAddress);
    }

    function getCurrentPolicyBooksImplementation() external view override returns (address) {

        return policyBookImplementationAddress;
    }

    function getCurrentPolicyBooksFacadeImplementation() external view override returns (address) {

        return policyBookFacadeImplementationAddress;
    }

    function getCurrentUserLeverageImplementation() external view override returns (address) {

        return userLeverageImplementationAddress;
    }

    function _setPolicyBookImplementation(address policyBookImpl) internal {

        if (policyBookImplementationAddress != policyBookImpl) {
            policyBookImplementationAddress = policyBookImpl;
        }
    }

    function _setPolicyBookFacadeImplementation(address policyBookFacadeImpl) internal {

        if (policyBookFacadeImplementationAddress != policyBookFacadeImpl) {
            policyBookFacadeImplementationAddress = policyBookFacadeImpl;
        }
    }

    function _setUserLeverageImplementation(address userLeverageImpl) internal {

        if (userLeverageImplementationAddress != userLeverageImpl) {
            userLeverageImplementationAddress = userLeverageImpl;
        }
    }

    function upgradePolicyBooks(
        address policyBookImpl,
        uint256 offset,
        uint256 limit
    ) external onlyOwner {

        _upgradePolicyBooks(policyBookImpl, offset, limit, "");
    }

    function upgradePolicyBooksAndCall(
        address policyBookImpl,
        uint256 offset,
        uint256 limit,
        string calldata functionSignature
    ) external onlyOwner {

        _upgradePolicyBooks(policyBookImpl, offset, limit, functionSignature);
    }

    function _upgradePolicyBooks(
        address policyBookImpl,
        uint256 offset,
        uint256 limit,
        string memory functionSignature
    ) internal {

        require(policyBookImpl != address(0), "PolicyBookAdmin: Zero address");
        require(Address.isContract(policyBookImpl), "PolicyBookAdmin: Invalid address");

        _setPolicyBookImplementation(policyBookImpl);

        address[] memory _policies = policyBookRegistry.list(offset, limit);

        for (uint256 i = 0; i < _policies.length; i++) {
            if (!policyBookRegistry.isUserLeveragePool(_policies[i])) {
                if (bytes(functionSignature).length > 0) {
                    upgrader.upgradeAndCall(
                        _policies[i],
                        policyBookImpl,
                        abi.encodeWithSignature(functionSignature)
                    );
                } else {
                    upgrader.upgrade(_policies[i], policyBookImpl);
                }
            }
        }
    }

    function upgradePolicyBookFacades(
        address policyBookFacadeImpl,
        uint256 offset,
        uint256 limit
    ) external onlyOwner {

        _upgradePolicyBookFacades(policyBookFacadeImpl, offset, limit, "");
    }

    function upgradePolicyBookFacadesAndCall(
        address policyBookFacadeImpl,
        uint256 offset,
        uint256 limit,
        string calldata functionSignature
    ) external onlyOwner {

        _upgradePolicyBookFacades(policyBookFacadeImpl, offset, limit, functionSignature);
    }

    function _upgradePolicyBookFacades(
        address policyBookFacadeImpl,
        uint256 offset,
        uint256 limit,
        string memory functionSignature
    ) internal {

        require(policyBookFacadeImpl != address(0), "PolicyBookAdmin: Zero address");
        require(Address.isContract(policyBookFacadeImpl), "PolicyBookAdmin: Invalid address");

        _setPolicyBookFacadeImplementation(policyBookFacadeImpl);

        address[] memory _policies = policyBookRegistry.list(offset, limit);

        for (uint256 i = 0; i < _policies.length; i++) {
            if (!policyBookRegistry.isUserLeveragePool(_policies[i])) {
                IPolicyBook _policyBook = IPolicyBook(_policies[i]);
                address policyBookFacade =
                    address(IPolicyBookFacade(_policyBook.policyBookFacade()));
                if (bytes(functionSignature).length > 0) {
                    upgrader.upgradeAndCall(
                        policyBookFacade,
                        policyBookFacadeImpl,
                        abi.encodeWithSignature(functionSignature)
                    );
                } else {
                    upgrader.upgrade(policyBookFacade, policyBookFacadeImpl);
                }
            }
        }
    }

    function upgradeUserLeveragePools(
        address userLeverageImpl,
        uint256 offset,
        uint256 limit
    ) external onlyOwner {

        _upgradeUserLeveragePools(userLeverageImpl, offset, limit, "");
    }

    function upgradeUserLeveragePoolsAndCall(
        address userLeverageImpl,
        uint256 offset,
        uint256 limit,
        string calldata functionSignature
    ) external onlyOwner {

        _upgradeUserLeveragePools(userLeverageImpl, offset, limit, functionSignature);
    }

    function _upgradeUserLeveragePools(
        address userLeverageImpl,
        uint256 offset,
        uint256 limit,
        string memory functionSignature
    ) internal {

        require(userLeverageImpl != address(0), "PolicyBookAdmin: Zero address");
        require(Address.isContract(userLeverageImpl), "PolicyBookAdmin: Invalid address");

        _setUserLeverageImplementation(userLeverageImpl);

        address[] memory _policies =
            policyBookRegistry.listByType(IPolicyBookFabric.ContractType.VARIOUS, offset, limit);

        for (uint256 i = 0; i < _policies.length; i++) {
            if (policyBookRegistry.isUserLeveragePool(_policies[i])) {
                if (bytes(functionSignature).length > 0) {
                    upgrader.upgradeAndCall(
                        _policies[i],
                        userLeverageImpl,
                        abi.encodeWithSignature(functionSignature)
                    );
                } else {
                    upgrader.upgrade(_policies[i], userLeverageImpl);
                }
            }
        }
    }

    function whitelist(address policyBookAddress, bool whitelisted) public override onlyOwner {

        require(policyBookRegistry.isPolicyBook(policyBookAddress), "PolicyBookAdmin: Not a PB");

        IPolicyBook(policyBookAddress).whitelist(whitelisted);
        policyBookRegistry.whitelist(policyBookAddress, whitelisted);

        emit PolicyBookWhitelisted(policyBookAddress, whitelisted);
    }

    function whitelistDistributor(address _distributor, uint256 _distributorFee)
        external
        override
        onlyOwner
    {

        require(_distributor != address(0), "PBAdmin: Null is forbidden");
        require(_distributorFee > 0, "PBAdmin: Fee cannot be 0");

        require(_distributorFee <= MAX_DISTRIBUTOR_FEE, "PBAdmin: Fee is over max cap");

        _whitelistedDistributors.add(_distributor);
        distributorFees[_distributor] = _distributorFee;

        emit DistributorWhitelisted(_distributor, _distributorFee);
    }

    function blacklistDistributor(address _distributor) external override onlyOwner {

        _whitelistedDistributors.remove(_distributor);
        delete distributorFees[_distributor];

        emit DistributorBlacklisted(_distributor);
    }

    function isWhitelistedDistributor(address _distributor) external view override returns (bool) {

        return _whitelistedDistributors.contains(_distributor);
    }

    function listDistributors(uint256 offset, uint256 limit)
        external
        view
        override
        returns (address[] memory _distributors, uint256[] memory _distributorsFees)
    {

        return _listDistributors(offset, limit, _whitelistedDistributors);
    }

    function _listDistributors(
        uint256 offset,
        uint256 limit,
        EnumerableSet.AddressSet storage set
    ) internal view returns (address[] memory _distributors, uint256[] memory _distributorsFees) {

        uint256 to = (offset.add(limit)).min(set.length()).max(offset);

        _distributors = new address[](to - offset);
        _distributorsFees = new uint256[](to - offset);

        for (uint256 i = offset; i < to; i++) {
            _distributors[i - offset] = set.at(i);
            _distributorsFees[i - offset] = distributorFees[_distributors[i]];
        }
    }

    function countDistributors() external view override returns (uint256) {

        return _whitelistedDistributors.length();
    }

    function whitelistBatch(address[] calldata policyBooksAddresses, bool[] calldata whitelists)
        external
        onlyOwner
    {

        require(
            policyBooksAddresses.length == whitelists.length,
            "PolicyBookAdmin: Length mismatch"
        );

        for (uint256 i = 0; i < policyBooksAddresses.length; i++) {
            whitelist(policyBooksAddresses[i], whitelists[i]);
        }
    }

    function updateImageUriOfClaim(uint256 _claimIndex, string calldata _newEvidenceURI)
        public
        onlyOwner
    {

        IClaimingRegistry.ClaimInfo memory claimInfo = claimingRegistry.claimInfo(_claimIndex);
        string memory oldEvidenceURI = claimInfo.evidenceURI;

        claimingRegistry.updateImageUriOfClaim(_claimIndex, _newEvidenceURI);

        emit UpdatedImageURI(_claimIndex, oldEvidenceURI, _newEvidenceURI);
    }

    function setPolicyBookFacadeMPLs(
        address _facadeAddress,
        uint256 _userLeverageMPL,
        uint256 _reinsuranceLeverageMPL
    ) external override onlyOwner {

        IPolicyBookFacade(_facadeAddress).setMPLs(_userLeverageMPL, _reinsuranceLeverageMPL);
    }

    function setPolicyBookFacadeRebalancingThreshold(
        address _facadeAddress,
        uint256 _newRebalancingThreshold
    ) external override onlyOwner {

        IPolicyBookFacade(_facadeAddress).setRebalancingThreshold(_newRebalancingThreshold);
    }

    function setPolicyBookFacadeSafePricingModel(address _facadeAddress, bool _safePricingModel)
        external
        override
        onlyOwner
    {

        IPolicyBookFacade(_facadeAddress).setSafePricingModel(_safePricingModel);
    }

    function setLeveragePortfolioRebalancingThreshold(
        address _LeveragePoolAddress,
        uint256 _newRebalancingThreshold
    ) external override onlyOwner {

        ILeveragePortfolio(_LeveragePoolAddress).setRebalancingThreshold(_newRebalancingThreshold);
    }

    function setLeveragePortfolioProtocolConstant(
        address _LeveragePoolAddress,
        uint256 _targetUR,
        uint256 _d_ProtocolConstant,
        uint256 _a1_ProtocolConstant,
        uint256 _max_ProtocolConstant
    ) external override onlyOwner {

        ILeveragePortfolio(_LeveragePoolAddress).setProtocolConstant(
            _targetUR,
            _d_ProtocolConstant,
            _a1_ProtocolConstant,
            _max_ProtocolConstant
        );
    }

    function setUserLeverageMaxCapacities(address _userLeverageAddress, uint256 _maxCapacities)
        external
        override
        onlyOwner
    {

        IUserLeveragePool(_userLeverageAddress).setMaxCapacities(_maxCapacities);
    }

    function setUserLeverageA2_ProtocolConstant(
        address _userLeverageAddress,
        uint256 _a2_ProtocolConstant
    ) external override onlyOwner {

        IUserLeveragePool(_userLeverageAddress).setA2_ProtocolConstant(_a2_ProtocolConstant);
    }

    function setupPricingModel(
        uint256 _highRiskRiskyAssetThresholdPercentage,
        uint256 _lowRiskRiskyAssetThresholdPercentage,
        uint256 _highRiskMinimumCostPercentage,
        uint256 _lowRiskMinimumCostPercentage,
        uint256 _minimumInsuranceCost,
        uint256 _lowRiskMaxPercentPremiumCost,
        uint256 _lowRiskMaxPercentPremiumCost100Utilization,
        uint256 _highRiskMaxPercentPremiumCost,
        uint256 _highRiskMaxPercentPremiumCost100Utilization
    ) external override onlyOwner {

        policyQuote.setupPricingModel(
            _highRiskRiskyAssetThresholdPercentage,
            _lowRiskRiskyAssetThresholdPercentage,
            _highRiskMinimumCostPercentage,
            _lowRiskMinimumCostPercentage,
            _minimumInsuranceCost,
            _lowRiskMaxPercentPremiumCost,
            _lowRiskMaxPercentPremiumCost100Utilization,
            _highRiskMaxPercentPremiumCost,
            _highRiskMaxPercentPremiumCost100Utilization
        );
    }
}