
pragma solidity ^0.7.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
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

interface ILiquidityRegistry {

    struct LiquidityInfo {
        address policyBookAddr;
        uint256 lockedAmount;
        uint256 availableAmount;
        uint256 bmiXRatio; // multiply availableAmount by this num to get stable coin
    }

    struct WithdrawalRequestInfo {
        address policyBookAddr;
        uint256 requestAmount;
        uint256 requestSTBLAmount;
        uint256 availableLiquidity;
        uint256 readyToWithdrawDate;
        uint256 endWithdrawDate;
    }

    struct WithdrawalSetInfo {
        address policyBookAddr;
        uint256 requestAmount;
        uint256 requestSTBLAmount;
        uint256 availableSTBLAmount;
    }

    function tryToAddPolicyBook(address _userAddr, address _policyBookAddr) external;


    function tryToRemovePolicyBook(address _userAddr, address _policyBookAddr) external;


    function removeExpiredWithdrawalRequest(address _userAddr, address _policyBookAddr) external;


    function getPolicyBooksArrLength(address _userAddr) external view returns (uint256);


    function getPolicyBooksArr(address _userAddr)
        external
        view
        returns (address[] memory _resultArr);


    function getLiquidityInfos(
        address _userAddr,
        uint256 _offset,
        uint256 _limit
    ) external view returns (LiquidityInfo[] memory _resultArr);


    function getWithdrawalRequests(
        address _userAddr,
        uint256 _offset,
        uint256 _limit
    ) external view returns (uint256 _arrLength, WithdrawalRequestInfo[] memory _resultArr);


    function registerWithdrawl(address _policyBook, address _users) external;


    function getAllPendingWithdrawalRequestsAmount()
        external
        view
        returns (uint256 _totalWithdrawlAmount);


    function getPendingWithdrawalAmountByPolicyBook(address _policyBook)
        external
        view
        returns (uint256 _totalWithdrawlAmount);

}// MIT
pragma solidity ^0.7.4;

interface IBMICoverStaking {

    struct StakingInfo {
        address policyBookAddress;
        uint256 stakedBMIXAmount;
    }

    struct PolicyBookInfo {
        uint256 totalStakedSTBL;
        uint256 rewardPerBlock;
        uint256 stakingAPY;
        uint256 liquidityAPY;
    }

    struct UserInfo {
        uint256 totalStakedBMIX;
        uint256 totalStakedSTBL;
        uint256 totalBmiReward;
    }

    struct NFTsInfo {
        uint256 nftIndex;
        string uri;
        uint256 stakedBMIXAmount;
        uint256 stakedSTBLAmount;
        uint256 reward;
    }

    function aggregateNFTs(address policyBookAddress, uint256[] calldata tokenIds) external;


    function stakeBMIX(uint256 amount, address policyBookAddress) external;


    function stakeBMIXWithPermit(
        uint256 bmiXAmount,
        address policyBookAddress,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    function stakeBMIXFrom(address user, uint256 amount) external;


    function stakeBMIXFromWithPermit(
        address user,
        uint256 bmiXAmount,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;



    function _stakersPool(uint256 index)
        external
        view
        returns (address policyBookAddress, uint256 stakedBMIXAmount);



    function restakeBMIProfit(uint256 tokenId) external;


    function restakeStakerBMIProfit(address policyBookAddress) external;


    function withdrawBMIProfit(uint256 tokenID) external;


    function withdrawStakerBMIProfit(address policyBookAddress) external;


    function withdrawFundsWithProfit(uint256 tokenID) external;


    function withdrawStakerFundsWithProfit(address policyBookAddress) external;


    function getSlashedBMIProfit(uint256 tokenId) external view returns (uint256);


    function getBMIProfit(uint256 tokenId) external view returns (uint256);


    function getSlashedStakerBMIProfit(
        address staker,
        address policyBookAddress,
        uint256 offset,
        uint256 limit
    ) external view returns (uint256 totalProfit);


    function getStakerBMIProfit(
        address staker,
        address policyBookAddress,
        uint256 offset,
        uint256 limit
    ) external view returns (uint256 totalProfit);


    function totalStaked(address user) external view returns (uint256);


    function totalStakedSTBL(address user) external view returns (uint256);


    function stakedByNFT(uint256 tokenId) external view returns (uint256);


    function stakedSTBLByNFT(uint256 tokenId) external view returns (uint256);


    function balanceOf(address user) external view returns (uint256);


    function ownerOf(uint256 tokenId) external view returns (address);


    function uri(uint256 tokenId) external view returns (string memory);


    function tokenOfOwnerByIndex(address user, uint256 index) external view returns (uint256);

}// MIT
pragma solidity ^0.7.4;


interface ICapitalPool {

    struct PremiumFactors {
        uint256 epochsNumber;
        uint256 premiumPrice;
        uint256 vStblDeployedByRP;
        uint256 vStblOfCP;
        uint256 poolUtilizationRation;
        uint256 premiumPerDeployment;
        uint256 userLeveragePoolsCount;
        IPolicyBookFacade policyBookFacade;
    }

    enum PoolType {COVERAGE, LEVERAGE, REINSURANCE}

    function virtualUsdtAccumulatedBalance() external view returns (uint256);


    function liquidityCushionBalance() external view returns (uint256);


    function addPolicyHoldersHardSTBL(
        uint256 _stblAmount,
        uint256 _epochsNumber,
        uint256 _protocolFee
    ) external returns (uint256);


    function addCoverageProvidersHardSTBL(uint256 _stblAmount) external;


    function addLeverageProvidersHardSTBL(uint256 _stblAmount) external;


    function addReinsurancePoolHardSTBL(uint256 _stblAmount) external;


    function rebalanceLiquidityCushion() external;


    function fundClaim(
        address _claimer,
        uint256 _claimAmount,
        address _policyBookAddress
    ) external returns (uint256);


    function fundReward(address _voter, uint256 _rewardAmount) external returns (uint256);


    function withdrawLiquidity(
        address _sender,
        uint256 _stblAmount,
        bool _isLeveragePool
    ) external returns (uint256);


    function rebalanceDuration() external view returns (uint256);


    function getWithdrawPeriod() external view returns (uint256);

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





contract LiquidityRegistry is ILiquidityRegistry, AbstractDependant {

    using SafeMath for uint256;
    using Math for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    IPolicyBookRegistry public policyBookRegistry;
    IBMICoverStaking public bmiCoverStaking;

    mapping(address => EnumerableSet.AddressSet) private _policyBooks;

    mapping(address => EnumerableSet.AddressSet) private _withdrawlRequestsList;
    EnumerableSet.AddressSet internal _withdrawlRequestUsersList;

    address public capitalPool;

    event PolicyBookAdded(address _userAddr, address _policyBookAddress);
    event PolicyBookRemoved(address _userAddr, address _policyBookAddress);

    modifier onlyEligibleContracts() {

        require(
            msg.sender == address(bmiCoverStaking) ||
                policyBookRegistry.isPolicyBookFacade(msg.sender) ||
                policyBookRegistry.isPolicyBook(msg.sender),
            "LR: Not an eligible contract"
        );
        _;
    }

    modifier onlyCapitalPool() {

        require(msg.sender == capitalPool, "LR: not Capital Pool");
        _;
    }

    function setDependencies(IContractsRegistry _contractsRegistry)
        external
        override
        onlyInjectorOrZero
    {

        policyBookRegistry = IPolicyBookRegistry(
            _contractsRegistry.getPolicyBookRegistryContract()
        );
        bmiCoverStaking = IBMICoverStaking(_contractsRegistry.getBMICoverStakingContract());
        capitalPool = _contractsRegistry.getCapitalPoolContract();
    }

    function tryToAddPolicyBook(address _userAddr, address _policyBookAddr)
        external
        override
        onlyEligibleContracts
    {

        if (
            IERC20(_policyBookAddr).balanceOf(_userAddr) > 0 ||
            bmiCoverStaking.balanceOf(_userAddr) > 0
        ) {
            _policyBooks[_userAddr].add(_policyBookAddr);

            emit PolicyBookAdded(_userAddr, _policyBookAddr);
        }
    }

    function tryToRemovePolicyBook(address _userAddr, address _policyBookAddr)
        external
        override
        onlyEligibleContracts
    {

        if (
            IERC20(_policyBookAddr).balanceOf(_userAddr) == 0 &&
            bmiCoverStaking.balanceOf(_userAddr) == 0 &&
            IPolicyBook(_policyBookAddr).getWithdrawalStatus(_userAddr) ==
            IPolicyBook.WithdrawalStatus.NONE
        ) {
            _policyBooks[_userAddr].remove(_policyBookAddr);

            _withdrawlRequestsList[_userAddr].remove(_policyBookAddr);
            if (_withdrawlRequestsList[_userAddr].length() == 0) {
                _withdrawlRequestUsersList.remove(_userAddr);
            }

            emit PolicyBookRemoved(_userAddr, _policyBookAddr);
        }
    }

    function removeExpiredWithdrawalRequest(address _userAddr, address _policyBookAddr)
        external
        override
        onlyEligibleContracts
    {

        _withdrawlRequestsList[_userAddr].remove(_policyBookAddr);
        if (_withdrawlRequestsList[_userAddr].length() == 0) {
            _withdrawlRequestUsersList.remove(_userAddr);
        }
    }

    function getPolicyBooksArrLength(address _userAddr) external view override returns (uint256) {

        return _policyBooks[_userAddr].length();
    }

    function getPolicyBooksArr(address _userAddr)
        external
        view
        override
        returns (address[] memory _resultArr)
    {

        uint256 _policyBooksArrLength = _policyBooks[_userAddr].length();

        _resultArr = new address[](_policyBooksArrLength);

        for (uint256 i = 0; i < _policyBooksArrLength; i++) {
            _resultArr[i] = _policyBooks[_userAddr].at(i);
        }
    }

    function getLiquidityInfos(
        address _userAddr,
        uint256 _offset,
        uint256 _limit
    ) external view override returns (LiquidityInfo[] memory _resultArr) {

        uint256 _to = (_offset.add(_limit)).min(_policyBooks[_userAddr].length()).max(_offset);

        _resultArr = new LiquidityInfo[](_to - _offset);

        for (uint256 i = _offset; i < _to; i++) {
            address _currentPolicyBookAddr = _policyBooks[_userAddr].at(i);

            (uint256 _lockedAmount, , ) =
                IPolicyBook(_currentPolicyBookAddr).withdrawalsInfo(_userAddr);
            uint256 _availableAmount =
                IERC20(address(_currentPolicyBookAddr)).balanceOf(_userAddr);

            uint256 _bmiXRaito = IPolicyBook(_currentPolicyBookAddr).convertBMIXToSTBL(10**18);

            _resultArr[i - _offset] = LiquidityInfo(
                _currentPolicyBookAddr,
                _lockedAmount,
                _availableAmount,
                _bmiXRaito
            );
        }
    }

    function getWithdrawalRequests(
        address _userAddr,
        uint256 _offset,
        uint256 _limit
    )
        external
        view
        override
        returns (uint256 _arrLength, WithdrawalRequestInfo[] memory _resultArr)
    {

        uint256 _to = (_offset.add(_limit)).min(_policyBooks[_userAddr].length()).max(_offset);

        _resultArr = new WithdrawalRequestInfo[](_to - _offset);

        for (uint256 i = _offset; i < _to; i++) {
            IPolicyBook _currentPolicyBook = IPolicyBook(_policyBooks[_userAddr].at(i));

            (uint256 _requestAmount, uint256 _readyToWithdrawDate, ) =
                _currentPolicyBook.withdrawalsInfo(_userAddr);

            IPolicyBook.WithdrawalStatus _currentStatus =
                _currentPolicyBook.getWithdrawalStatus(_userAddr);

            if (_currentStatus == IPolicyBook.WithdrawalStatus.NONE) {
                continue;
            }

            uint256 _endWithdrawDate;

            if (block.timestamp > _readyToWithdrawDate) {
                _endWithdrawDate = _readyToWithdrawDate.add(
                    _currentPolicyBook.READY_TO_WITHDRAW_PERIOD()
                );
            }

            (uint256 coverTokens, uint256 liquidity) =
                _currentPolicyBook.getNewCoverAndLiquidity();

            _resultArr[_arrLength] = WithdrawalRequestInfo(
                address(_currentPolicyBook),
                _requestAmount,
                _currentPolicyBook.convertBMIXToSTBL(_requestAmount),
                liquidity.sub(coverTokens),
                _readyToWithdrawDate,
                _endWithdrawDate
            );

            _arrLength++;
        }
    }

    function registerWithdrawl(address _policyBook, address _user)
        external
        override
        onlyEligibleContracts
    {

        _withdrawlRequestsList[_user].add(_policyBook);
        _withdrawlRequestUsersList.add(_user);
    }

    function getAllPendingWithdrawalRequestsAmount()
        external
        view
        override
        returns (uint256 _totalWithdrawlAmount)
    {

        IPolicyBook.WithdrawalStatus _currentStatus;

        address _userAddr;
        address policyBookAddr;

        for (uint256 i = 0; i < _withdrawlRequestUsersList.length(); i++) {
            _userAddr = _withdrawlRequestUsersList.at(i);

            for (uint256 j = 0; j < _withdrawlRequestsList[_userAddr].length(); j++) {
                policyBookAddr = _withdrawlRequestsList[_userAddr].at(j);
                IPolicyBook _currentPolicyBook = IPolicyBook(policyBookAddr);

                _currentStatus = _currentPolicyBook.getWithdrawalStatus(_userAddr);

                if (
                    _currentStatus == IPolicyBook.WithdrawalStatus.NONE ||
                    _currentStatus == IPolicyBook.WithdrawalStatus.EXPIRED
                ) {
                    continue;
                }

                (uint256 _requestAmount, uint256 _readyToWithdrawDate, ) =
                    _currentPolicyBook.withdrawalsInfo(_userAddr);

                if (
                    block.timestamp >=
                    _readyToWithdrawDate.sub(
                        ICapitalPool(capitalPool).rebalanceDuration().add(60 * 60)
                    )
                ) {
                    _totalWithdrawlAmount = _totalWithdrawlAmount.add(
                        _currentPolicyBook.convertBMIXToSTBL(_requestAmount)
                    );
                }
            }
        }
    }

    function getPendingWithdrawalAmountByPolicyBook(address _policyBook)
        external
        view
        override
        returns (uint256 _totalWithdrawlAmount)
    {

        IPolicyBook.WithdrawalStatus _currentStatus;

        address _userAddr;

        for (uint256 i = 0; i < _withdrawlRequestUsersList.length(); i++) {
            _userAddr = _withdrawlRequestUsersList.at(i);

            for (uint256 j = 0; j < _withdrawlRequestsList[_userAddr].length(); j++) {
                if (_policyBook == _withdrawlRequestsList[_userAddr].at(j)) {
                    IPolicyBook _currentPolicyBook = IPolicyBook(_policyBook);

                    _currentStatus = _currentPolicyBook.getWithdrawalStatus(_userAddr);

                    if (
                        _currentStatus == IPolicyBook.WithdrawalStatus.NONE ||
                        _currentStatus == IPolicyBook.WithdrawalStatus.EXPIRED
                    ) {
                        continue;
                    }

                    (uint256 _requestAmount, , ) = _currentPolicyBook.withdrawalsInfo(_userAddr);

                    _totalWithdrawlAmount = _totalWithdrawlAmount.add(
                        _currentPolicyBook.convertBMIXToSTBL(_requestAmount)
                    );
                }
            }
        }
    }
}