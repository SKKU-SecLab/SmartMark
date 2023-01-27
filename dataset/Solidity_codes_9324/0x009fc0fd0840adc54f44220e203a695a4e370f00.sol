
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
pragma solidity ^0.7.4;




contract PolicyBookRegistry is IPolicyBookRegistry, AbstractDependant {

    using Math for uint256;
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    address public policyBookFabricAddress;
    address public policyBookAdminAddress;

    mapping(address => address) public override policyBooksByInsuredAddress;
    mapping(address => address) public override policyBookFacades;

    EnumerableSet.AddressSet internal _policyBooks;
    mapping(IPolicyBookFabric.ContractType => EnumerableSet.AddressSet)
        internal _policyBooksByType;

    EnumerableSet.AddressSet internal _whitelistedPolicyBooks;
    mapping(IPolicyBookFabric.ContractType => EnumerableSet.AddressSet)
        internal _whitelistedPolicyBooksByType;

    event Added(address insured, address at);

    modifier onlyPolicyBookFabric() {

        require(
            msg.sender == policyBookFabricAddress,
            "PolicyBookRegistry: Not a PolicyBookFabric"
        );
        _;
    }

    modifier onlyPolicyBookAdmin() {

        require(msg.sender == policyBookAdminAddress, "PolicyBookRegistry: Not a PolicyBookAdmin");
        _;
    }

    function setDependencies(IContractsRegistry _contractsRegistry)
        external
        override
        onlyInjectorOrZero
    {

        policyBookFabricAddress = _contractsRegistry.getPolicyBookFabricContract();
        policyBookAdminAddress = _contractsRegistry.getPolicyBookAdminContract();
    }

    function add(
        address insuredContract,
        IPolicyBookFabric.ContractType contractType,
        address policyBook,
        address facadeAddress
    ) external override onlyPolicyBookFabric {

        require(policyBook != address(0), "PolicyBookRegistry: No PB at address zero");
        require(
            policyBooksByInsuredAddress[insuredContract] == address(0),
            "PolicyBookRegistry: PolicyBook for the contract is already created"
        );

        policyBooksByInsuredAddress[insuredContract] = policyBook;
        policyBookFacades[facadeAddress] = policyBook;

        _policyBooks.add(policyBook);
        _policyBooksByType[contractType].add(policyBook);

        emit Added(insuredContract, policyBook);
    }

    function whitelist(address policyBookAddress, bool whitelisted)
        external
        override
        onlyPolicyBookAdmin
    {

        IPolicyBookFabric.ContractType contractType =
            IPolicyBook(policyBookAddress).contractType();

        if (whitelisted) {
            _whitelistedPolicyBooks.add(policyBookAddress);
            _whitelistedPolicyBooksByType[contractType].add(policyBookAddress);
        } else {
            _whitelistedPolicyBooks.remove(policyBookAddress);
            _whitelistedPolicyBooksByType[contractType].remove(policyBookAddress);
        }
    }

    function getPoliciesPrices(
        address[] calldata policyBooks,
        uint256[] calldata epochsNumbers,
        uint256[] calldata coversTokens
    ) external view override returns (uint256[] memory _durations, uint256[] memory _allowances) {

        require(
            policyBooks.length == epochsNumbers.length &&
                policyBooks.length == coversTokens.length,
            "PolicyBookRegistry: Lengths mismatch"
        );

        _durations = new uint256[](policyBooks.length);
        _allowances = new uint256[](policyBooks.length);

        for (uint256 i = 0; i < policyBooks.length; i++) {
            require(
                isPolicyBook(policyBooks[i]) && !isUserLeveragePool(policyBooks[i]),
                "PolicyBookRegistry: Not a PolicyBook"
            );

            (_durations[i], _allowances[i], ) = IPolicyBookFacade(
                IPolicyBook(policyBooks[i]).policyBookFacade()
            )
                .getPolicyPrice(epochsNumbers[i], coversTokens[i], msg.sender);
        }
    }

    function buyPolicyBatch(
        address[] calldata policyBooks,
        uint256[] calldata epochsNumbers,
        uint256[] calldata coversTokens
    ) external override {

        require(
            policyBooks.length == epochsNumbers.length &&
                policyBooks.length == coversTokens.length,
            "PolicyBookRegistry: Lengths mismatch"
        );

        for (uint256 i = 0; i < policyBooks.length; i++) {
            require(
                isPolicyBook(policyBooks[i]) && !isUserLeveragePool(policyBooks[i]),
                "PolicyBookRegistry: Not a PolicyBook"
            );

            IPolicyBook(policyBooks[i]).policyBookFacade().buyPolicyFor(
                msg.sender,
                epochsNumbers[i],
                coversTokens[i]
            );
        }
    }

    function isPolicyBook(address policyBook) public view override returns (bool) {

        return _policyBooks.contains(policyBook);
    }

    function isPolicyBookFacade(address _facadeAddress) public view override returns (bool) {

        address _policyBookAddress = policyBookFacades[_facadeAddress];
        return isPolicyBook(_policyBookAddress);
    }

    function isUserLeveragePool(address policyBookAddress) public view override returns (bool) {

        bool _isLeveragePool;
        if (_policyBooks.contains(policyBookAddress)) {
            _isLeveragePool = (IPolicyBook(policyBookAddress).contractType() ==
                IPolicyBookFabric.ContractType.VARIOUS);
        }
        return _isLeveragePool;
    }

    function countByType(IPolicyBookFabric.ContractType contractType)
        external
        view
        override
        returns (uint256)
    {

        return _policyBooksByType[contractType].length();
    }

    function count() external view override returns (uint256) {

        return _policyBooks.length();
    }

    function countByTypeWhitelisted(IPolicyBookFabric.ContractType contractType)
        external
        view
        override
        returns (uint256)
    {

        return _whitelistedPolicyBooksByType[contractType].length();
    }

    function countWhitelisted() external view override returns (uint256) {

        return _whitelistedPolicyBooks.length();
    }

    function listByType(
        IPolicyBookFabric.ContractType contractType,
        uint256 offset,
        uint256 limit
    ) public view override returns (address[] memory _policyBooksArr) {

        return _listByType(contractType, offset, limit, _policyBooksByType);
    }

    function list(uint256 offset, uint256 limit)
        public
        view
        override
        returns (address[] memory _policyBooksArr)
    {

        return _list(offset, limit, _policyBooks);
    }

    function listByTypeWhitelisted(
        IPolicyBookFabric.ContractType contractType,
        uint256 offset,
        uint256 limit
    ) public view override returns (address[] memory _policyBooksArr) {

        return _listByType(contractType, offset, limit, _whitelistedPolicyBooksByType);
    }

    function listWhitelisted(uint256 offset, uint256 limit)
        public
        view
        override
        returns (address[] memory _policyBooksArr)
    {

        return _list(offset, limit, _whitelistedPolicyBooks);
    }

    function listWithStatsByType(
        IPolicyBookFabric.ContractType contractType,
        uint256 offset,
        uint256 limit
    )
        external
        view
        override
        returns (address[] memory _policyBooksArr, PolicyBookStats[] memory _stats)
    {

        _policyBooksArr = listByType(contractType, offset, limit);
        _stats = stats(_policyBooksArr);
    }

    function listWithStats(uint256 offset, uint256 limit)
        external
        view
        override
        returns (address[] memory _policyBooksArr, PolicyBookStats[] memory _stats)
    {

        _policyBooksArr = list(offset, limit);
        _stats = stats(_policyBooksArr);
    }

    function listWithStatsByTypeWhitelisted(
        IPolicyBookFabric.ContractType contractType,
        uint256 offset,
        uint256 limit
    )
        external
        view
        override
        returns (address[] memory _policyBooksArr, PolicyBookStats[] memory _stats)
    {

        _policyBooksArr = listByTypeWhitelisted(contractType, offset, limit);
        _stats = stats(_policyBooksArr);
    }

    function listWithStatsWhitelisted(uint256 offset, uint256 limit)
        external
        view
        override
        returns (address[] memory _policyBooksArr, PolicyBookStats[] memory _stats)
    {

        _policyBooksArr = listWhitelisted(offset, limit);
        _stats = stats(_policyBooksArr);
    }

    function _listByType(
        IPolicyBookFabric.ContractType contractType,
        uint256 offset,
        uint256 limit,
        mapping(IPolicyBookFabric.ContractType => EnumerableSet.AddressSet) storage map
    ) internal view returns (address[] memory _policyBooksArr) {

        uint256 to = (offset.add(limit)).min(map[contractType].length()).max(offset);

        _policyBooksArr = new address[](to - offset);

        for (uint256 i = offset; i < to; i++) {
            _policyBooksArr[i - offset] = map[contractType].at(i);
        }
    }

    function _list(
        uint256 offset,
        uint256 limit,
        EnumerableSet.AddressSet storage set
    ) internal view returns (address[] memory _policyBooksArr) {

        uint256 to = (offset.add(limit)).min(set.length()).max(offset);

        _policyBooksArr = new address[](to - offset);

        for (uint256 i = offset; i < to; i++) {
            _policyBooksArr[i - offset] = set.at(i);
        }
    }

    function stats(address[] memory policyBooks)
        public
        view
        override
        returns (PolicyBookStats[] memory _stats)
    {

        _stats = new PolicyBookStats[](policyBooks.length);

        for (uint256 i = 0; i < policyBooks.length; i++) {
            address policyBookAddress;
            if (isUserLeveragePool(policyBooks[i])) {
                policyBookAddress = policyBooks[i];
            } else {
                policyBookAddress = address(IPolicyBook(policyBooks[i]).policyBookFacade());
            }
            (
                _stats[i].symbol,
                _stats[i].insuredContract,
                _stats[i].contractType,
                _stats[i].whitelisted
            ) = IPolicyBookFacade(policyBookAddress).info();

            (
                _stats[i].maxCapacity,
                ,
                _stats[i].totalSTBLLiquidity,
                _stats[i].totalLeveragedLiquidity,
                _stats[i].stakedSTBL,
                _stats[i].APY,
                _stats[i].annualInsuranceCost,
                _stats[i].bmiXRatio
            ) = IPolicyBook(policyBooks[i]).numberStats();
        }
    }

    function policyBookFor(address insuredContract) external view override returns (address) {

        return policyBooksByInsuredAddress[insuredContract];
    }

    function statsByInsuredContracts(address[] calldata insuredContracts)
        external
        view
        override
        returns (PolicyBookStats[] memory _stats)
    {

        _stats = new PolicyBookStats[](insuredContracts.length);

        for (uint256 i = 0; i < insuredContracts.length; i++) {
            (
                _stats[i].symbol,
                _stats[i].insuredContract,
                _stats[i].contractType,
                _stats[i].whitelisted
            ) = IPolicyBookFacade(
                IPolicyBook(policyBooksByInsuredAddress[insuredContracts[i]]).policyBookFacade()
            )
                .info();

            (
                _stats[i].maxCapacity,
                ,
                _stats[i].totalSTBLLiquidity,
                _stats[i].totalLeveragedLiquidity,
                _stats[i].stakedSTBL,
                _stats[i].APY,
                _stats[i].annualInsuranceCost,
                _stats[i].bmiXRatio
            ) = IPolicyBook(policyBooksByInsuredAddress[insuredContracts[i]]).numberStats();
        }
    }
}