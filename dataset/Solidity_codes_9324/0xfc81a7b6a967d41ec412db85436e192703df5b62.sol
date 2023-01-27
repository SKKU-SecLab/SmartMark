pragma solidity ^0.7.4;
pragma experimental ABIEncoderV2;

uint256 constant SECONDS_IN_THE_YEAR = 365 * 24 * 60 * 60; // 365 days * 24 hours * 60 minutes * 60 seconds
uint256 constant MAX_INT = type(uint256).max;

uint256 constant DECIMALS18 = 10**18;

uint256 constant PRECISION = 10**25;
uint256 constant PERCENTAGE_100 = 100 * PRECISION;

uint256 constant BLOCKS_PER_DAY = 6450;
uint256 constant BLOCKS_PER_YEAR = BLOCKS_PER_DAY * 365;

uint256 constant APY_TOKENS = DECIMALS18;// MIT

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

pragma solidity >=0.6.0 <0.8.0;

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


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
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

pragma solidity >=0.6.0 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity >=0.6.2 <0.8.0;


interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;


    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;

}// MIT

pragma solidity >=0.6.0 <0.8.0;


interface IERC1155Receiver is IERC165 {


    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        returns(bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns(bytes4);

}// MIT

pragma solidity >=0.6.0 <0.8.0;


abstract contract ERC165 is IERC165 {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;


abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    constructor() internal {
        _registerInterface(
            ERC1155Receiver(0).onERC1155Received.selector ^
            ERC1155Receiver(0).onERC1155BatchReceived.selector
        );
    }
}// MIT
pragma solidity ^0.7.4;

interface IPolicyBookFabric {

    enum ContractType {CONTRACT, STABLECOIN, SERVICE, EXCHANGE}

    function create(
        address _contract,
        ContractType _contractType,
        string calldata _description,
        string calldata _projectSymbol,
        uint256 _initialDeposit
    ) external returns (address);

}// MIT
pragma solidity ^0.7.4;


interface IClaimingRegistry {

    enum ClaimStatus {
        CAN_CLAIM,
        UNCLAIMABLE,
        PENDING,
        AWAITING_CALCULATION,
        REJECTED_CAN_APPEAL,
        REJECTED,
        ACCEPTED
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
    }

    function anonymousVotingDuration(uint256 index) external view returns (uint256);


    function votingDuration(uint256 index) external view returns (uint256);


    function anyoneCanCalculateClaimResultAfter(uint256 index) external view returns (uint256);


    function canBuyNewPolicy(address buyer, address policyBookAddress)
        external
        view
        returns (bool);


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


    function acceptClaim(uint256 index) external;


    function rejectClaim(uint256 index) external;

}// MIT
pragma solidity ^0.7.4;


interface IPolicyBook {

    enum WithdrawalStatus {NONE, PENDING, READY, EXPIRED}

    struct PolicyHolder {
        uint256 coverTokens;
        uint256 startEpochNumber;
        uint256 endEpochNumber;
        uint256 paid;
    }

    struct WithdrawalInfo {
        uint256 withdrawalAmount;
        uint256 readyToWithdrawDate;
        bool withdrawalAllowed;
    }

    function EPOCH_DURATION() external view returns (uint256);


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


    function getClaimApprovalAmount(address user) external view returns (uint256);


    function submitClaimAndInitializeVoting(string calldata evidenceURI) external;


    function submitAppealAndInitializeVoting(string calldata evidenceURI) external;


    function commitClaim(
        address claimer,
        uint256 claimAmount,
        uint256 claimEndTime,
        IClaimingRegistry.ClaimStatus status
    ) external;


    function getNewCoverAndLiquidity()
        external
        view
        returns (uint256 newTotalCoverTokens, uint256 newTotalLiquidity);


    function getPolicyPrice(uint256 _epochsNumber, uint256 _coverTokens)
        external
        view
        returns (uint256 totalSeconds, uint256 totalPrice);


    function buyPolicyFor(
        address _buyer,
        uint256 _epochsNumber,
        uint256 _coverTokens
    ) external;


    function buyPolicy(uint256 _durationSeconds, uint256 _coverTokens) external;


    function updateEpochsInfo() external;


    function secondsToEndCurrentEpoch() external view returns (uint256);


    function addLiquidity(uint256 _liqudityAmount) external;


    function addLiquidityFor(address _liquidityHolderAddr, uint256 _liqudityAmount) external;


    function addLiquidityAndStake(uint256 _liquidityAmount, uint256 _stakeSTBLAmount) external;


    function getAvailableBMIXWithdrawableAmount(address _userAddr) external view returns (uint256);


    function getWithdrawalStatus(address _userAddr) external view returns (WithdrawalStatus);


    function requestWithdrawal(uint256 _tokensToWithdraw) external;


    function requestWithdrawalWithPermit(
        uint256 _tokensToWithdraw,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external;


    function unlockTokens() external;


    function withdrawLiquidity() external;


    function getAPY() external view returns (uint256);


    function userStats(address _user) external view returns (PolicyHolder memory);


    function numberStats()
        external
        view
        returns (
            uint256 _maxCapacities,
            uint256 _totalSTBLLiquidity,
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

interface IContractsRegistry {

    function getUniswapRouterContract() external view returns (address);


    function getUniswapBMIToETHPairContract() external view returns (address);


    function getWETHContract() external view returns (address);


    function getUSDTContract() external view returns (address);


    function getBMIContract() external view returns (address);


    function getPriceFeedContract() external view returns (address);


    function getPolicyBookRegistryContract() external view returns (address);


    function getPolicyBookFabricContract() external view returns (address);


    function getBMICoverStakingContract() external view returns (address);


    function getRewardsGeneratorContract() external view returns (address);


    function getBMIUtilityNFTContract() external view returns (address);


    function getLiquidityMiningContract() external view returns (address);


    function getClaimingRegistryContract() external view returns (address);


    function getPolicyRegistryContract() external view returns (address);


    function getLiquidityRegistryContract() external view returns (address);


    function getClaimVotingContract() external view returns (address);


    function getReinsurancePoolContract() external view returns (address);


    function getPolicyBookAdminContract() external view returns (address);


    function getPolicyQuoteContract() external view returns (address);


    function getLegacyBMIStakingContract() external view returns (address);


    function getBMIStakingContract() external view returns (address);


    function getSTKBMIContract() external view returns (address);


    function getVBMIContract() external view returns (address);


    function getLegacyLiquidityMiningStakingContract() external view returns (address);


    function getLiquidityMiningStakingContract() external view returns (address);


    function getReputationSystemContract() external view returns (address);

}// MIT
pragma solidity ^0.7.4;

interface ILiquidityMining {

    struct TeamDetails {
        string teamName;
        address referralLink;
        uint256 membersNumber;
        uint256 totalStakedAmount;
        uint256 totalReward;
    }

    struct UserInfo {
        address userAddr;
        string teamName;
        uint256 stakedAmount;
        uint256 mainNFT; // 0 or NFT index if available
        uint256 platinumNFT; // 0 or NFT index if available
    }

    struct UserRewardsInfo {
        string teamName;
        uint256 totalBMIReward; // total BMI reward
        uint256 availableBMIReward; // current claimable BMI reward
        uint256 incomingPeriods; // how many month are incoming
        uint256 timeToNextDistribution; // exact time left to next distribution
        uint256 claimedBMI; // actual number of claimed BMI
        uint256 mainNFTAvailability; // 0 or NFT index if available
        uint256 platinumNFTAvailability; // 0 or NFT index if available
        bool claimedNFTs; // true if user claimed NFTs
    }

    struct MyTeamInfo {
        TeamDetails teamDetails;
        uint256 myStakedAmount;
        uint256 teamPlace;
    }

    struct UserTeamInfo {
        address teamAddr;
        uint256 stakedAmount;
        uint256 countOfRewardedMonth;
        bool isNFTDistributed;
    }

    struct TeamInfo {
        string name;
        uint256 totalAmount;
        address[] teamLeaders;
    }

    function startLiquidityMiningTime() external view returns (uint256);


    function getTopTeams() external view returns (TeamDetails[] memory teams);


    function getTopUsers() external view returns (UserInfo[] memory users);


    function getAllTeamsLength() external view returns (uint256);


    function getAllTeamsDetails(uint256 _offset, uint256 _limit)
        external
        view
        returns (TeamDetails[] memory _teamDetailsArr);


    function getMyTeamsLength() external view returns (uint256);


    function getMyTeamMembers(uint256 _offset, uint256 _limit)
        external
        view
        returns (address[] memory _teamMembers, uint256[] memory _memberStakedAmount);


    function getAllUsersLength() external view returns (uint256);


    function getAllUsersInfo(uint256 _offset, uint256 _limit)
        external
        view
        returns (UserInfo[] memory _userInfos);


    function getMyTeamInfo() external view returns (MyTeamInfo memory _myTeamInfo);


    function getRewardsInfo(address user)
        external
        view
        returns (UserRewardsInfo memory userRewardInfo);


    function createTeam(string calldata _teamName) external;


    function deleteTeam() external;


    function joinTheTeam(address _referralLink) external;


    function getSlashingPercentage() external view returns (uint256);


    function investSTBL(uint256 _tokensAmount, address _policyBookAddr) external;


    function distributeNFT() external;


    function checkPlatinumNFTReward(address _userAddr) external view returns (uint256);


    function checkMainNFTReward(address _userAddr) external view returns (uint256);


    function distributeBMIReward() external;


    function getTotalUserBMIReward(address _userAddr) external view returns (uint256);


    function checkAvailableBMIReward(address _userAddr) external view returns (uint256);


    function isLMLasting() external view returns (bool);


    function isLMEnded() external view returns (bool);


    function getEndLMTime() external view returns (uint256);

}// MIT
pragma solidity ^0.7.4;


interface IPolicyBookRegistry {

    struct PolicyBookStats {
        string symbol;
        address insuredContract;
        IPolicyBookFabric.ContractType contractType;
        uint256 maxCapacity;
        uint256 totalSTBLLiquidity;
        uint256 stakedSTBL;
        uint256 APY;
        uint256 annualInsuranceCost;
        uint256 bmiXRatio;
        bool whitelisted;
    }

    function add(
        address insuredContract,
        IPolicyBookFabric.ContractType contractType,
        address policyBook
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





contract LiquidityMining is
    ILiquidityMining,
    OwnableUpgradeable,
    ERC1155Receiver,
    AbstractDependant
{

    using Math for uint256;
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    address[] public leaderboard;
    address[] public topUsers;

    EnumerableSet.AddressSet internal allUsers;
    EnumerableSet.AddressSet internal teamsArr;

    uint256 public override startLiquidityMiningTime;

    uint256 public constant PLATINUM_NFT_ID = 1;
    uint256 public constant GOLD_NFT_ID = 2;
    uint256 public constant SILVER_NFT_ID = 3;
    uint256 public constant BRONZE_NFT_ID = 4;

    uint256 public constant TOP_1_REWARD = 150000 * DECIMALS18;
    uint256 public constant TOP_2_5_REWARD = 50000 * DECIMALS18;
    uint256 public constant TOP_6_10_REWARD = 20000 * DECIMALS18;
    uint256 public constant MAX_MONTH_TO_GET_REWARD = 5;

    uint256 public constant MAX_GROUP_LEADERS_SIZE = 10;
    uint256 public constant MAX_LEADERBOARD_SIZE = 10;
    uint256 public constant MAX_TOP_USERS_SIZE = 5;
    uint256 public constant LM_DURATION = 2 weeks;

    uint256 public constant FIRST_MAX_SLASHING_FEE = 50 * PRECISION;
    uint256 public constant SECOND_MAX_SLASHING_FEE = 99 * PRECISION;
    uint256 public constant SECOND_SLASHING_DURATION = 10 minutes;

    uint256 public constant ONE_MONTH = 30 days;

    IERC20 public bmiToken;
    IERC1155 public liquidityMiningNFT;
    IPolicyBookRegistry public policyBookRegistry;

    mapping(address => TeamInfo) public teamInfos;

    mapping(address => UserTeamInfo) public usersTeamInfo;

    mapping(string => bool) public existingNames;

    mapping(address => EnumerableSet.AddressSet) private teamsMembers;

    event TeamCreated(address _referralLink, string _name);
    event TeamDeleted(address _referralLink, string _name);
    event MemberAdded(address _referralLink, address _newMember, uint256 _membersNumber);
    event TeamInvested(address _referralLink, address _stblInvestor, uint256 _tokensAmount);
    event LeaderboardUpdated(uint256 _index, address _prevLink, address _newReferralLink);
    event TopUsersUpdated(uint256 _index, address _prevAddr, address _newAddr);
    event RewardSent(address _referralLink, address _address, uint256 _reward);
    event NFTSent(address _address, uint256 _nftIndex);

    function __LiquidityMining_init() external initializer {

        __Ownable_init();
    }

    function setDependencies(IContractsRegistry _contractsRegistry)
        external
        override
        onlyInjectorOrZero
    {

        bmiToken = IERC20(_contractsRegistry.getBMIContract());
        liquidityMiningNFT = IERC1155(_contractsRegistry.getBMIUtilityNFTContract());
        policyBookRegistry = IPolicyBookRegistry(
            _contractsRegistry.getPolicyBookRegistryContract()
        );
    }

    function startLiquidityMining() external onlyOwner {

        require(startLiquidityMiningTime == 0, "LM: start liquidity mining is already set");

        startLiquidityMiningTime = block.timestamp;
    }

    function getTopTeams() external view override returns (TeamDetails[] memory teams) {

        uint256 leaderboradSize = leaderboard.length;

        teams = new TeamDetails[](leaderboradSize);

        for (uint256 i = 0; i < leaderboradSize; i++) {
            teams[i] = _getTeamDetails(leaderboard[i]);
        }
    }

    function getTopUsers() external view override returns (UserInfo[] memory users) {

        uint256 topUsersSize = topUsers.length;

        users = new UserInfo[](topUsersSize);

        for (uint256 i = 0; i < topUsersSize; i++) {
            address _currentUserAddr = topUsers[i];

            users[i] = UserInfo(
                _currentUserAddr,
                teamInfos[usersTeamInfo[_currentUserAddr].teamAddr].name,
                usersTeamInfo[_currentUserAddr].stakedAmount,
                checkMainNFTReward(_currentUserAddr),
                checkPlatinumNFTReward(_currentUserAddr)
            );
        }
    }

    function getAllTeamsLength() external view override returns (uint256) {

        return teamsArr.length();
    }

    function getAllTeamsDetails(uint256 _offset, uint256 _limit)
        external
        view
        override
        returns (TeamDetails[] memory _teamDetailsArr)
    {

        uint256 _to = (_offset.add(_limit)).min(teamsArr.length()).max(_offset);

        _teamDetailsArr = new TeamDetails[](_to - _offset);

        for (uint256 i = _offset; i < _to; i++) {
            _teamDetailsArr[i - _offset] = _getTeamDetails(teamsArr.at(i));
        }
    }

    function getMyTeamsLength() external view override returns (uint256) {

        return teamsMembers[usersTeamInfo[msg.sender].teamAddr].length();
    }

    function getMyTeamMembers(uint256 _offset, uint256 _limit)
        external
        view
        override
        returns (address[] memory _teamMembers, uint256[] memory _memberStakedAmount)
    {

        EnumerableSet.AddressSet storage _members =
            teamsMembers[usersTeamInfo[msg.sender].teamAddr];

        uint256 _to = (_offset.add(_limit)).min(_members.length()).max(_offset);
        uint256 _size = _to - _offset;

        _teamMembers = new address[](_size);
        _memberStakedAmount = new uint256[](_size);

        for (uint256 i = _offset; i < _to; i++) {
            address _currentMember = _members.at(i);
            _teamMembers[i - _offset] = _currentMember;
            _memberStakedAmount[i - _offset] = usersTeamInfo[_currentMember].stakedAmount;
        }
    }

    function getAllUsersLength() external view override returns (uint256) {

        return allUsers.length();
    }

    function getAllUsersInfo(uint256 _offset, uint256 _limit)
        external
        view
        override
        returns (UserInfo[] memory _userInfos)
    {

        uint256 _to = (_offset.add(_limit)).min(allUsers.length()).max(_offset);

        _userInfos = new UserInfo[](_to - _offset);

        for (uint256 i = _offset; i < _to; i++) {
            address _currentUserAddr = allUsers.at(i);

            _userInfos[i - _offset] = UserInfo(
                _currentUserAddr,
                teamInfos[usersTeamInfo[_currentUserAddr].teamAddr].name,
                usersTeamInfo[_currentUserAddr].stakedAmount,
                checkMainNFTReward(_currentUserAddr),
                checkPlatinumNFTReward(_currentUserAddr)
            );
        }
    }

    function getMyTeamInfo() external view override returns (MyTeamInfo memory _myTeamInfo) {

        UserTeamInfo storage userTeamInfo = usersTeamInfo[msg.sender];

        _myTeamInfo.teamDetails = _getTeamDetails(userTeamInfo.teamAddr);
        _myTeamInfo.myStakedAmount = userTeamInfo.stakedAmount;
        _myTeamInfo.teamPlace = _getIndexInTheLeaderboard(_myTeamInfo.teamDetails.referralLink);
    }

    function _getTeamDetails(address _teamAddr)
        internal
        view
        returns (TeamDetails memory _teamDetails)
    {

        _teamDetails = TeamDetails(
            teamInfos[_teamAddr].name,
            _teamAddr,
            teamsMembers[_teamAddr].length(),
            teamInfos[_teamAddr].totalAmount,
            _getTeamReward(_getIndexInTheLeaderboard(_teamAddr))
        );
    }

    function getRewardsInfo(address user)
        external
        view
        override
        returns (UserRewardsInfo memory userRewardInfo)
    {

        if (!isLMEnded()) {
            return userRewardInfo; // empty
        }

        userRewardInfo.teamName = teamInfos[usersTeamInfo[user].teamAddr].name;

        userRewardInfo.totalBMIReward = getTotalUserBMIReward(user);
        userRewardInfo.availableBMIReward = checkAvailableBMIReward(user);

        uint256 elapsedSeconds = block.timestamp.sub(getEndLMTime());
        uint256 elapsedMonths = elapsedSeconds.div(ONE_MONTH).add(1);

        userRewardInfo.incomingPeriods = MAX_MONTH_TO_GET_REWARD > elapsedMonths
            ? MAX_MONTH_TO_GET_REWARD - elapsedMonths
            : 0;

        userRewardInfo.timeToNextDistribution = userRewardInfo.incomingPeriods > 0
            ? ONE_MONTH - elapsedSeconds.mod(ONE_MONTH)
            : 0;

        userRewardInfo.claimedBMI = usersTeamInfo[user]
            .countOfRewardedMonth
            .mul(userRewardInfo.totalBMIReward)
            .div(MAX_MONTH_TO_GET_REWARD);

        userRewardInfo.mainNFTAvailability = checkMainNFTReward(user);
        userRewardInfo.platinumNFTAvailability = checkPlatinumNFTReward(user);

        userRewardInfo.claimedNFTs = usersTeamInfo[user].isNFTDistributed;
    }

    function createTeam(string calldata _teamName) external override {

        require(isLMLasting(), "LM: LME didn't start or finished");
        require(
            bytes(_teamName).length != 0 && bytes(_teamName).length <= 50,
            "LM: Team name is too long/short"
        );
        require(
            usersTeamInfo[msg.sender].teamAddr == address(0),
            "LM: The user is already in the team"
        );
        require(!existingNames[_teamName], "LM: Team name already exists");

        teamInfos[msg.sender].name = _teamName;
        usersTeamInfo[msg.sender].teamAddr = msg.sender;

        teamsArr.add(msg.sender);
        teamsMembers[msg.sender].add(msg.sender);
        existingNames[_teamName] = true;

        allUsers.add(msg.sender);

        emit TeamCreated(msg.sender, _teamName);
    }

    function deleteTeam() external override {

        require(teamsMembers[msg.sender].length() == 1, "LM: Unable to delete a team");
        require(usersTeamInfo[msg.sender].stakedAmount == 0, "LM: Unable to remove a team");

        string memory _teamName = teamInfos[msg.sender].name;

        teamsArr.remove(msg.sender);
        delete usersTeamInfo[msg.sender];
        delete teamsMembers[msg.sender];
        delete teamInfos[msg.sender].name;
        delete existingNames[_teamName];

        allUsers.remove(msg.sender);

        emit TeamDeleted(msg.sender, _teamName);
    }

    function joinTheTeam(address _referralLink) external override {

        require(_referralLink != address(0), "LM: Invalid referral link");
        require(teamsArr.contains(_referralLink), "LM: There is no such team");
        require(
            usersTeamInfo[msg.sender].teamAddr == address(0),
            "LM: The user is already in the team"
        );

        teamsMembers[_referralLink].add(msg.sender);

        usersTeamInfo[msg.sender].teamAddr = _referralLink;

        allUsers.add(msg.sender);

        emit MemberAdded(_referralLink, msg.sender, teamsMembers[_referralLink].length());
    }

    function getSlashingPercentage() public view override returns (uint256) {

        uint256 endLMTime = getEndLMTime();

        if (block.timestamp + SECOND_SLASHING_DURATION < endLMTime) {
            uint256 elapsed = block.timestamp.sub(startLiquidityMiningTime);
            uint256 feePerSecond =
                FIRST_MAX_SLASHING_FEE.div(LM_DURATION.sub(SECOND_SLASHING_DURATION));

            return elapsed.mul(feePerSecond);
        } else {
            uint256 elapsed = block.timestamp.sub(endLMTime.sub(SECOND_SLASHING_DURATION));
            uint256 feePerSecond =
                SECOND_MAX_SLASHING_FEE.sub(FIRST_MAX_SLASHING_FEE).div(SECOND_SLASHING_DURATION);

            return
                Math.min(
                    elapsed.mul(feePerSecond).add(FIRST_MAX_SLASHING_FEE),
                    SECOND_MAX_SLASHING_FEE
                );
        }
    }

    function investSTBL(uint256 _tokensAmount, address _policyBookAddr) external override {

        require(_tokensAmount > 0, "LM: Tokens amount is zero");
        require(isLMLasting(), "LM: LME didn't start or finished");
        require(
            policyBookRegistry.isPolicyBook(_policyBookAddr),
            "LM: Can't invest to not a PolicyBook"
        );

        address _userTeamAddr = usersTeamInfo[msg.sender].teamAddr;
        uint256 _userStakedAmount = usersTeamInfo[msg.sender].stakedAmount;

        require(_userTeamAddr != address(0), "LM: User is without a team");

        uint256 _finalTokensAmount =
            _tokensAmount.sub(_tokensAmount.mul(getSlashingPercentage()).div(PERCENTAGE_100));

        require(_finalTokensAmount > 0, "LM: Final tokens amount is zero");

        teamInfos[_userTeamAddr].totalAmount = teamInfos[_userTeamAddr].totalAmount.add(
            _finalTokensAmount
        );

        usersTeamInfo[msg.sender].stakedAmount = _userStakedAmount.add(_finalTokensAmount);

        _updateTopUsers();
        _updateLeaderboard(_userTeamAddr);
        _updateGroupLeaders(_userTeamAddr);

        emit TeamInvested(_userTeamAddr, msg.sender, _finalTokensAmount);

        IPolicyBook(_policyBookAddr).addLiquidityFor(msg.sender, _tokensAmount);
    }

    function distributeNFT() external override {

        require(isLMEnded(), "LM: LME didn't start or still going");

        UserTeamInfo storage _userTeamInfo = usersTeamInfo[msg.sender];

        require(!_userTeamInfo.isNFTDistributed, "LM: NFT is already distributed");

        _userTeamInfo.isNFTDistributed = true;

        uint256 _indexInTheTeam = _getIndexInTheGroupLeaders(msg.sender);

        if (
            _indexInTheTeam != MAX_GROUP_LEADERS_SIZE &&
            _getIndexInTheLeaderboard(_userTeamInfo.teamAddr) != MAX_LEADERBOARD_SIZE
        ) {
            _sendMainNFT(_indexInTheTeam, msg.sender);
        }

        _sendPlatinumNFT(msg.sender);
    }

    function checkPlatinumNFTReward(address _userAddr) public view override returns (uint256) {

        if (isLMEnded() && _getIndexInTopUsers(_userAddr) != MAX_TOP_USERS_SIZE) {
            return PLATINUM_NFT_ID;
        }

        return 0;
    }

    function checkMainNFTReward(address _userAddr) public view override returns (uint256) {

        uint256 placeInsideTeam = _getIndexInTheGroupLeaders(_userAddr);

        if (
            isLMEnded() &&
            placeInsideTeam != MAX_GROUP_LEADERS_SIZE &&
            _getIndexInTheLeaderboard(usersTeamInfo[_userAddr].teamAddr) != MAX_LEADERBOARD_SIZE
        ) {
            return _getMainNFTReward(placeInsideTeam);
        }

        return 0;
    }

    function distributeBMIReward() external override {

        require(isLMEnded(), "LM: LME didn't start or still going");

        address _teamAddr = usersTeamInfo[msg.sender].teamAddr;
        uint256 _userReward = checkAvailableBMIReward(msg.sender);

        if (_userReward == 0) {
            revert("LM: No BMI reward available");
        }

        bmiToken.transfer(msg.sender, _userReward);
        emit RewardSent(_teamAddr, msg.sender, _userReward);

        usersTeamInfo[msg.sender].countOfRewardedMonth += _getAvailableMonthForReward(msg.sender);
    }

    function getTotalUserBMIReward(address _userAddr) public view override returns (uint256) {

        if (!isLMEnded()) {
            return 0;
        }

        address _teamAddr = usersTeamInfo[_userAddr].teamAddr;
        uint256 _staked = usersTeamInfo[_userAddr].stakedAmount;
        uint256 _currentGroupIndex = _getIndexInTheLeaderboard(_teamAddr);

        if (_currentGroupIndex == MAX_LEADERBOARD_SIZE || _staked == 0) {
            return 0;
        }

        uint256 _userRewardPercent =
            _calculatePercentage(_staked, teamInfos[_teamAddr].totalAmount);
        uint256 _userReward =
            _getTeamReward(_currentGroupIndex).mul(_userRewardPercent).div(PERCENTAGE_100);

        return _userReward;
    }

    function checkAvailableBMIReward(address _userAddr) public view override returns (uint256) {

        uint256 _availableMonthCount = _getAvailableMonthForReward(_userAddr);

        if (_availableMonthCount == 0) {
            return 0;
        }

        return
            getTotalUserBMIReward(_userAddr).mul(_availableMonthCount).div(
                MAX_MONTH_TO_GET_REWARD
            );
    }

    function isLMLasting() public view override returns (bool) {

        return startLiquidityMiningTime != 0 && getEndLMTime() >= block.timestamp;
    }

    function isLMEnded() public view override returns (bool) {

        return startLiquidityMiningTime != 0 && getEndLMTime() < block.timestamp;
    }

    function getEndLMTime() public view override returns (uint256) {

        return startLiquidityMiningTime.add(LM_DURATION);
    }

    function _getMainNFTReward(uint256 place) internal view returns (uint256) {

        if (!isLMEnded() || place == MAX_GROUP_LEADERS_SIZE) {
            return 0;
        }

        if (place == 0) {
            return GOLD_NFT_ID;
        } else if (place < 4) {
            return SILVER_NFT_ID;
        } else {
            return BRONZE_NFT_ID;
        }
    }

    function _sendMainNFT(uint256 _index, address _userAddr) internal {

        uint256 _nftIndex = _getMainNFTReward(_index);

        liquidityMiningNFT.safeTransferFrom(address(this), _userAddr, _nftIndex, 1, "");

        emit NFTSent(_userAddr, _nftIndex);
    }

    function _sendPlatinumNFT(address _userAddr) internal {

        uint256 _topUsersLength = topUsers.length;

        for (uint256 i = 0; i < _topUsersLength; i++) {
            if (_userAddr == topUsers[i]) {
                liquidityMiningNFT.safeTransferFrom(
                    address(this),
                    _userAddr,
                    PLATINUM_NFT_ID,
                    1,
                    ""
                );
                emit NFTSent(_userAddr, PLATINUM_NFT_ID);

                break;
            }
        }
    }

    function _calculatePercentage(uint256 _part, uint256 _amount) internal pure returns (uint256) {

        if (_amount == 0) {
            return 0;
        }

        return _part.mul(PERCENTAGE_100).div(_amount);
    }

    function _getTeamReward(uint256 place) internal view returns (uint256) {

        if (!isLMEnded() || place == MAX_LEADERBOARD_SIZE) {
            return 0;
        }

        if (place == 0) {
            return TOP_1_REWARD;
        } else if (place > 0 && place < 5) {
            return TOP_2_5_REWARD;
        } else {
            return TOP_6_10_REWARD;
        }
    }

    function _getAvailableMonthForReward(address _userAddr) internal view returns (uint256) {

        return
            Math
                .min(
                (block.timestamp.sub(getEndLMTime())).div(ONE_MONTH).add(1),
                MAX_MONTH_TO_GET_REWARD
            )
                .sub(usersTeamInfo[_userAddr].countOfRewardedMonth);
    }

    function _getIndexInTopUsers(address _userAddr) internal view returns (uint256) {

        uint256 _topUsersLength = topUsers.length;

        for (uint256 i = 0; i < _topUsersLength; i++) {
            if (_userAddr == topUsers[i]) {
                return i;
            }
        }

        return MAX_TOP_USERS_SIZE;
    }

    function _getIndexInTheGroupLeaders(address _userAddr) internal view returns (uint256) {

        address _referralLink = usersTeamInfo[_userAddr].teamAddr;
        uint256 _size = teamInfos[_referralLink].teamLeaders.length;

        for (uint256 i = 0; i < _size; i++) {
            if (_userAddr == teamInfos[_referralLink].teamLeaders[i]) {
                return i;
            }
        }

        return MAX_GROUP_LEADERS_SIZE;
    }

    function _getIndexInTheLeaderboard(address _referralLink) internal view returns (uint256) {

        uint256 _leaderBoardLength = leaderboard.length;

        for (uint256 i = 0; i < _leaderBoardLength; i++) {
            if (_referralLink == leaderboard[i]) {
                return i;
            }
        }

        return MAX_LEADERBOARD_SIZE;
    }

    function _updateLeaderboard(address _referralLink) internal {

        uint256 _leaderBoardLength = leaderboard.length;

        if (_leaderBoardLength == 0) {
            leaderboard.push(_referralLink);
            emit LeaderboardUpdated(0, address(0), _referralLink);
            return;
        }

        uint256 _currentGroupIndex = _getIndexInTheLeaderboard(_referralLink);

        if (_currentGroupIndex == MAX_LEADERBOARD_SIZE) {
            _currentGroupIndex = _leaderBoardLength++;
            leaderboard.push(_referralLink);
        }

        if (_currentGroupIndex == 0) {
            return;
        }

        address[] memory _addresses = leaderboard;
        uint256 _currentIndex = _currentGroupIndex - 1;
        uint256 _currentTeamAmount = teamInfos[_referralLink].totalAmount;

        if (_currentTeamAmount > teamInfos[_addresses[_currentIndex]].totalAmount) {
            while (_currentTeamAmount > teamInfos[_addresses[_currentIndex]].totalAmount) {
                address _tmpLink = _addresses[_currentIndex];
                _addresses[_currentIndex] = _referralLink;
                _addresses[_currentIndex + 1] = _tmpLink;

                if (_currentIndex == 0) {
                    break;
                }

                _currentIndex--;
            }

            leaderboard = _addresses;

            emit LeaderboardUpdated(_currentIndex, _addresses[_currentIndex + 1], _referralLink);
        }

        if (_leaderBoardLength > MAX_LEADERBOARD_SIZE) {
            leaderboard.pop();
        }
    }

    function _updateTopUsers() internal {

        uint256 _topUsersLength = topUsers.length;

        if (_topUsersLength == 0) {
            topUsers.push(msg.sender);
            emit TopUsersUpdated(0, address(0), msg.sender);
            return;
        }

        uint256 _currentIndex = _getIndexInTopUsers(msg.sender);

        if (_currentIndex == MAX_TOP_USERS_SIZE) {
            _currentIndex = _topUsersLength++;
            topUsers.push(msg.sender);
        }

        if (_currentIndex == 0) {
            return;
        }

        address[] memory _addresses = topUsers;
        uint256 _tmpIndex = _currentIndex - 1;
        uint256 _currentUserAmount = usersTeamInfo[msg.sender].stakedAmount;

        if (_currentUserAmount > usersTeamInfo[_addresses[_tmpIndex]].stakedAmount) {
            while (_currentUserAmount > usersTeamInfo[_addresses[_tmpIndex]].stakedAmount) {
                address _tmpAddr = _addresses[_tmpIndex];
                _addresses[_tmpIndex] = msg.sender;
                _addresses[_tmpIndex + 1] = _tmpAddr;

                if (_tmpIndex == 0) {
                    break;
                }

                _tmpIndex--;
            }

            topUsers = _addresses;

            emit TopUsersUpdated(_tmpIndex, _addresses[_tmpIndex + 1], msg.sender);
        }

        if (_topUsersLength > MAX_TOP_USERS_SIZE) {
            topUsers.pop();
        }
    }

    function _updateGroupLeaders(address _referralLink) internal {

        uint256 _groupLeadersSize = teamInfos[_referralLink].teamLeaders.length;

        if (_groupLeadersSize == 0) {
            teamInfos[_referralLink].teamLeaders.push(msg.sender);
            return;
        }

        uint256 _currentIndex = _getIndexInTheGroupLeaders(msg.sender);

        if (_currentIndex == MAX_GROUP_LEADERS_SIZE) {
            _currentIndex = _groupLeadersSize++;
            teamInfos[_referralLink].teamLeaders.push(msg.sender);
        }

        if (_currentIndex == 0) {
            return;
        }

        address[] memory _addresses = teamInfos[_referralLink].teamLeaders;
        uint256 _tmpIndex = _currentIndex - 1;
        uint256 _currentUserAmount = usersTeamInfo[msg.sender].stakedAmount;

        if (_currentUserAmount > usersTeamInfo[_addresses[_tmpIndex]].stakedAmount) {
            while (_currentUserAmount > usersTeamInfo[_addresses[_tmpIndex]].stakedAmount) {
                address _tmpAddr = _addresses[_tmpIndex];
                _addresses[_tmpIndex] = msg.sender;
                _addresses[_tmpIndex + 1] = _tmpAddr;

                if (_tmpIndex == 0) {
                    break;
                }

                _tmpIndex--;
            }

            teamInfos[_referralLink].teamLeaders = _addresses;
        }

        if (_groupLeadersSize > MAX_GROUP_LEADERS_SIZE) {
            teamInfos[_referralLink].teamLeaders.pop();
        }
    }

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external pure override returns (bytes4) {

        return 0xf23a6e61;
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external pure override returns (bytes4) {

        return 0xbc197c81;
    }
}