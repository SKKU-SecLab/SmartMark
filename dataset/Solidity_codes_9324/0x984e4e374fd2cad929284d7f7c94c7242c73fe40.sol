
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

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

pragma solidity ^0.7.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol) {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}// MIT
pragma solidity ^0.7.4;
pragma experimental ABIEncoderV2;


library DecimalsConverter {
    using SafeMath for uint256;

    function convert(
        uint256 amount,
        uint256 baseDecimals,
        uint256 destinationDecimals
    ) internal pure returns (uint256) {
        if (baseDecimals > destinationDecimals) {
            amount = amount.div(10**(baseDecimals - destinationDecimals));
        } else if (baseDecimals < destinationDecimals) {
            amount = amount.mul(10**(destinationDecimals - baseDecimals));
        }

        return amount;
    }

    function convertTo18(uint256 amount, uint256 baseDecimals) internal pure returns (uint256) {
        if (baseDecimals == 18) return amount;
        return convert(amount, baseDecimals, 18);
    }

    function convertFrom18(uint256 amount, uint256 destinationDecimals)
        internal
        pure
        returns (uint256)
    {
        if (destinationDecimals == 18) return amount;
        return convert(amount, 18, destinationDecimals);
    }
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

interface IPriceFeed {
    function howManyBMIsInUSDT(uint256 usdtAmount) external view returns (uint256);

    function howManyUSDTsInBMI(uint256 bmiAmount) external view returns (uint256);
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



interface IClaimVoting {
    enum VoteStatus {
        ANONYMOUS_PENDING,
        AWAITING_EXPOSURE,
        EXPIRED,
        EXPOSED_PENDING,
        MINORITY,
        MAJORITY,
        RECEIVED
    }

    struct VotingResult {
        uint256 withdrawalAmount;
        uint256 lockedBMIAmount;
        uint256 reinsuranceTokensAmount;
        uint256 votedAverageWithdrawalAmount;
        uint256 votedYesStakedStkBMIAmountWithReputation;
        uint256 votedNoStakedStkBMIAmountWithReputation;
        uint256 allVotedStakedStkBMIAmount;
        uint256 votedYesPercentage;
        EnumerableSet.UintSet voteIndexes;
    }

    struct VotingInst {
        uint256 claimIndex;
        bytes32 finalHash;
        string encryptedVote;
        address voter;
        uint256 voterReputation;
        uint256 suggestedAmount;
        uint256 stakedStkBMIAmount;
        bool accept;
        VoteStatus status;
    }

    struct MyClaimInfo {
        uint256 index;
        address policyBookAddress;
        string evidenceURI;
        bool appeal;
        uint256 claimAmount;
        IClaimingRegistry.ClaimStatus finalVerdict;
        uint256 finalClaimAmount;
        uint256 bmiCalculationReward;
    }

    struct PublicClaimInfo {
        uint256 claimIndex;
        address claimer;
        address policyBookAddress;
        string evidenceURI;
        bool appeal;
        uint256 claimAmount;
        uint256 time;
    }

    struct AllClaimInfo {
        PublicClaimInfo publicClaimInfo;
        IClaimingRegistry.ClaimStatus finalVerdict;
        uint256 finalClaimAmount;
        uint256 bmiCalculationReward;
    }

    struct MyVoteInfo {
        AllClaimInfo allClaimInfo;
        string encryptedVote;
        uint256 suggestedAmount;
        VoteStatus status;
        uint256 time;
    }

    struct VotesUpdatesInfo {
        uint256 bmiReward;
        uint256 stblReward;
        int256 reputationChange;
        int256 stakeChange;
    }

    function voteResults(uint256 voteIndex)
        external
        view
        returns (
            uint256 bmiReward,
            uint256 stblReward,
            int256 reputationChange,
            int256 stakeChange
        );

    function initializeVoting(
        address claimer,
        string calldata evidenceURI,
        uint256 coverTokens,
        bool appeal
    ) external;

    function canUnstake(address user) external view returns (bool);

    function canVote(address user) external view returns (bool);

    function countVoteOnClaim(uint256 claimIndex) external view returns (uint256);

    function lockedBMIAmount(uint256 claimIndex) external view returns (uint256);

    function countVotes(address user) external view returns (uint256);

    function voteIndexByClaimIndexAt(uint256 claimIndex, uint256 orderIndex)
        external
        view
        returns (uint256);

    function voteStatus(uint256 index) external view returns (VoteStatus);

    function whatCanIVoteFor(uint256 offset, uint256 limit)
        external
        returns (uint256 _claimsCount, PublicClaimInfo[] memory _votablesInfo);

    function allClaims(uint256 offset, uint256 limit)
        external
        view
        returns (AllClaimInfo[] memory _allClaimsInfo);

    function myClaims(uint256 offset, uint256 limit)
        external
        view
        returns (MyClaimInfo[] memory _myClaimsInfo);

    function myVotes(uint256 offset, uint256 limit)
        external
        view
        returns (MyVoteInfo[] memory _myVotesInfo);

    function myNotReceivesVotes(address user)
        external
        view
        returns (uint256[] memory claimIndexes, VotesUpdatesInfo[] memory voteRewardInfo);

    function anonymouslyVoteBatch(
        uint256[] calldata claimIndexes,
        bytes32[] calldata finalHashes,
        string[] calldata encryptedVotes
    ) external;

    function exposeVoteBatch(
        uint256[] calldata claimIndexes,
        uint256[] calldata suggestedClaimAmounts,
        bytes32[] calldata hashedSignaturesOfClaims
    ) external;

    function calculateResult(uint256 claimIndex) external;

    function receiveResult() external;

    function transferLockedBMI(uint256 claimIndex, address claimer) external;
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

interface IReputationSystem {
    function setNewReputation(address voter, uint256 newReputation) external;

    function getNewReputation(address voter, uint256 percentageWithPrecision)
        external
        view
        returns (uint256);

    function getNewReputation(uint256 voterReputation, uint256 percentageWithPrecision)
        external
        pure
        returns (uint256);

    function hasVotedOnce(address user) external view returns (bool);

    function isTrustedVoter(address user) external view returns (bool);

    function getTrustedVoterReputationThreshold() external view returns (uint256);

    function reputation(address user) external view returns (uint256);
}// MIT
pragma solidity ^0.7.4;

interface IReinsurancePool {
    function withdrawBMITo(address to, uint256 amount) external;

    function withdrawSTBLTo(address to, uint256 amount) external;

    function addInterestFromDefiProtocols(uint256 intrestAmount) external;
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

interface IStkBMIStaking {
    function stakedStkBMI(address user) external view returns (uint256);

    function totalStakedStkBMI() external view returns (uint256);

    function lockStkBMIFor(address user, uint256 amount) external;

    function lockStkBMI(uint256 amount) external;

    function unlockStkBMI(uint256 amount) external;

    function slashUserTokens(address user, uint256 amount) external;
}// MIT

pragma solidity >=0.6.0 <0.8.0;

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
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC20Upgradeable {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT
pragma solidity ^0.7.4;



interface IVBMI is IERC20Upgradeable, IERC20PermitUpgradeable {
    function unlockStkBMIFor(address user) external;

    function slashUserTokens(address user, uint256 amount) external;
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







contract ClaimVoting is IClaimVoting, Initializable, AbstractDependant {
    using SafeMath for uint256;
    using Math for uint256;
    using EnumerableSet for EnumerableSet.UintSet;

    IPriceFeed public priceFeed;

    IERC20 public bmiToken;
    IReinsurancePool public reinsurancePool;
    IVBMI public vBMI;
    IClaimingRegistry public claimingRegistry;
    IPolicyBookRegistry public policyBookRegistry;
    IReputationSystem public reputationSystem;

    uint256 public stblDecimals;

    uint256 public constant PERCENTAGE_50 = 50 * PRECISION;

    uint256 public constant APPROVAL_PERCENTAGE = 66 * PRECISION;
    uint256 public constant PENALTY_THRESHOLD = 11 * PRECISION;
    uint256 public constant QUORUM = 10 * PRECISION;
    uint256 public constant CALCULATION_REWARD_PER_DAY = PRECISION;

    mapping(uint256 => VotingResult) internal _votings;

    mapping(address => EnumerableSet.UintSet) internal _myNotReceivedVotes;

    mapping(address => EnumerableSet.UintSet) internal _myVotes;

    mapping(address => mapping(uint256 => uint256)) internal _allVotesToIndex;

    mapping(uint256 => VotingInst) internal _allVotesByIndexInst;

    EnumerableSet.UintSet internal _allVotesIndexes;

    uint256 private _voteIndex;

    IStkBMIStaking public stkBMIStaking;

    mapping(uint256 => VotesUpdatesInfo) public override voteResults;

    event AnonymouslyVoted(uint256 claimIndex);
    event VoteExposed(uint256 claimIndex, address voter, uint256 suggestedClaimAmount);
    event VoteCalculated(uint256 claimIndex, address voter, VoteStatus status);
    event RewardsForVoteCalculationSent(address voter, uint256 bmiAmount);
    event RewardsForClaimCalculationSent(address calculator, uint256 bmiAmount);
    event ClaimCalculated(uint256 claimIndex, address calculator);

    modifier onlyPolicyBook() {
        require(policyBookRegistry.isPolicyBook(msg.sender), "CV: Not a PolicyBook");
        _;
    }

    modifier onlyClaimingRegistry() {
        require(msg.sender == address(claimingRegistry), "CV: Not ClaimingRegistry");
        _;
    }

    function _isVoteAwaitingExposure(uint256 index) internal view returns (bool) {
        uint256 claimIndex = _allVotesByIndexInst[index].claimIndex;

        return (_allVotesByIndexInst[index].status == VoteStatus.ANONYMOUS_PENDING &&
            claimingRegistry.isClaimExposablyVotable(claimIndex));
    }

    function _isVoteExpired(uint256 index) internal view returns (bool) {
        uint256 claimIndex = _allVotesByIndexInst[index].claimIndex;

        return (_allVotesByIndexInst[index].status == VoteStatus.ANONYMOUS_PENDING &&
            !claimingRegistry.isClaimVotable(claimIndex));
    }

    function __ClaimVoting_init() external initializer {
        _voteIndex = 1;
    }

    function setDependencies(IContractsRegistry _contractsRegistry)
        external
        override
        onlyInjectorOrZero
    {
        priceFeed = IPriceFeed(_contractsRegistry.getPriceFeedContract());
        claimingRegistry = IClaimingRegistry(_contractsRegistry.getClaimingRegistryContract());
        policyBookRegistry = IPolicyBookRegistry(
            _contractsRegistry.getPolicyBookRegistryContract()
        );
        reputationSystem = IReputationSystem(_contractsRegistry.getReputationSystemContract());
        reinsurancePool = IReinsurancePool(_contractsRegistry.getReinsurancePoolContract());
        bmiToken = IERC20(_contractsRegistry.getBMIContract());
        stkBMIStaking = IStkBMIStaking(_contractsRegistry.getStkBMIStakingContract());

        stblDecimals = ERC20(_contractsRegistry.getUSDTContract()).decimals();
    }

    function initializeVoting(
        address claimer,
        string calldata evidenceURI,
        uint256 coverTokens,
        bool appeal
    ) external override onlyPolicyBook {
        require(coverTokens > 0, "CV: Claimer has no coverage");

        uint256 claimIndex =
            claimingRegistry.submitClaim(claimer, msg.sender, evidenceURI, coverTokens, appeal);

        uint256 onePercentInBMIToLock =
            priceFeed.howManyBMIsInUSDT(
                DecimalsConverter.convertFrom18(coverTokens.div(100), stblDecimals)
            );

        bmiToken.transferFrom(claimer, address(this), onePercentInBMIToLock); // needed approval

        IPolicyBook.PolicyHolder memory policyHolder = IPolicyBook(msg.sender).userStats(claimer);
        uint256 reinsuranceTokensAmount = policyHolder.reinsurancePrice;
        reinsuranceTokensAmount = Math.min(reinsuranceTokensAmount, coverTokens.div(100));

        _votings[claimIndex].withdrawalAmount = coverTokens;
        _votings[claimIndex].lockedBMIAmount = onePercentInBMIToLock;
        _votings[claimIndex].reinsuranceTokensAmount = reinsuranceTokensAmount;
    }

    function canVote(address user) public view override returns (bool) {
        return _myNotReceivedVotes[user].length() == 0;
    }

    function canUnstake(address user) external view override returns (bool) {
        uint256 voteLength = _myVotes[user].length();

        for (uint256 i = 0; i < voteLength; i++) {
            if (voteStatus(_myVotes[user].at(i)) != VoteStatus.RECEIVED) {
                return false;
            }
        }
        return true;
    }

    function countVoteOnClaim(uint256 claimIndex) external view override returns (uint256) {
        return _votings[claimIndex].voteIndexes.length();
    }

    function lockedBMIAmount(uint256 claimIndex) public view override returns (uint256) {
        return _votings[claimIndex].lockedBMIAmount;
    }

    function countVotes(address user) external view override returns (uint256) {
        return _myVotes[user].length();
    }

    function voteIndex(uint256 claimIndex, address user) external view returns (uint256) {
        return _allVotesToIndex[user][claimIndex];
    }

    function getVotingPower(uint256 index) external view returns (uint256) {
        return
            _allVotesByIndexInst[index].voterReputation.mul(
                _allVotesByIndexInst[index].stakedStkBMIAmount
            );
    }

    function voteIndexByClaimIndexAt(uint256 claimIndex, uint256 orderIndex)
        external
        view
        override
        returns (uint256)
    {
        return _votings[claimIndex].voteIndexes.at(orderIndex);
    }

    function voteStatus(uint256 index) public view override returns (VoteStatus) {
        require(_allVotesIndexes.contains(index), "CV: Vote doesn't exist");

        if (_isVoteAwaitingExposure(index)) {
            return VoteStatus.AWAITING_EXPOSURE;
        } else if (_isVoteExpired(index)) {
            return VoteStatus.EXPIRED;
        }

        return _allVotesByIndexInst[index].status;
    }

    function whatCanIVoteFor(uint256 offset, uint256 limit)
        external
        view
        override
        returns (uint256 _claimsCount, PublicClaimInfo[] memory _votablesInfo)
    {
        uint256 to = (offset.add(limit)).min(claimingRegistry.countPendingClaims()).max(offset);
        bool trustedVoter = reputationSystem.isTrustedVoter(msg.sender);

        _claimsCount = 0;

        _votablesInfo = new PublicClaimInfo[](to - offset);

        for (uint256 i = offset; i < to; i++) {
            uint256 index = claimingRegistry.pendingClaimIndexAt(i);

            if (
                _allVotesToIndex[msg.sender][index] == 0 &&
                claimingRegistry.claimOwner(index) != msg.sender &&
                claimingRegistry.isClaimAnonymouslyVotable(index) &&
                (!claimingRegistry.isClaimAppeal(index) || trustedVoter)
            ) {
                IClaimingRegistry.ClaimInfo memory claimInfo = claimingRegistry.claimInfo(index);

                _votablesInfo[_claimsCount].claimIndex = index;
                _votablesInfo[_claimsCount].claimer = claimInfo.claimer;
                _votablesInfo[_claimsCount].policyBookAddress = claimInfo.policyBookAddress;
                _votablesInfo[_claimsCount].evidenceURI = claimInfo.evidenceURI;
                _votablesInfo[_claimsCount].appeal = claimInfo.appeal;
                _votablesInfo[_claimsCount].claimAmount = claimInfo.claimAmount;
                _votablesInfo[_claimsCount].time = claimInfo.dateSubmitted;

                _votablesInfo[_claimsCount].time = _votablesInfo[_claimsCount]
                    .time
                    .add(claimingRegistry.anonymousVotingDuration(index))
                    .sub(block.timestamp);

                _claimsCount++;
            }
        }
    }

    function allClaims(uint256 offset, uint256 limit)
        external
        view
        override
        returns (AllClaimInfo[] memory _allClaimsInfo)
    {
        uint256 to = (offset.add(limit)).min(claimingRegistry.countClaims()).max(offset);

        _allClaimsInfo = new AllClaimInfo[](to - offset);

        for (uint256 i = offset; i < to; i++) {
            uint256 index = claimingRegistry.claimIndexAt(i);

            IClaimingRegistry.ClaimInfo memory claimInfo = claimingRegistry.claimInfo(index);

            _allClaimsInfo[i - offset].publicClaimInfo.claimIndex = index;
            _allClaimsInfo[i - offset].publicClaimInfo.claimer = claimInfo.claimer;
            _allClaimsInfo[i - offset].publicClaimInfo.policyBookAddress = claimInfo
                .policyBookAddress;
            _allClaimsInfo[i - offset].publicClaimInfo.evidenceURI = claimInfo.evidenceURI;
            _allClaimsInfo[i - offset].publicClaimInfo.appeal = claimInfo.appeal;
            _allClaimsInfo[i - offset].publicClaimInfo.claimAmount = claimInfo.claimAmount;
            _allClaimsInfo[i - offset].publicClaimInfo.time = claimInfo.dateSubmitted;

            _allClaimsInfo[i - offset].finalVerdict = claimInfo.status;

            if (
                _allClaimsInfo[i - offset].finalVerdict == IClaimingRegistry.ClaimStatus.ACCEPTED
            ) {
                _allClaimsInfo[i - offset].finalClaimAmount = _votings[index]
                    .votedAverageWithdrawalAmount;
            }

            if (claimingRegistry.canClaimBeCalculatedByAnyone(index)) {
                _allClaimsInfo[i - offset].bmiCalculationReward = _getBMIRewardForCalculation(
                    index
                );
            }
        }
    }

    function myClaims(uint256 offset, uint256 limit)
        external
        view
        override
        returns (MyClaimInfo[] memory _myClaimsInfo)
    {
        uint256 to =
            (offset.add(limit)).min(claimingRegistry.countPolicyClaimerClaims(msg.sender)).max(
                offset
            );

        _myClaimsInfo = new MyClaimInfo[](to - offset);

        for (uint256 i = offset; i < to; i++) {
            uint256 index = claimingRegistry.claimOfOwnerIndexAt(msg.sender, i);

            IClaimingRegistry.ClaimInfo memory claimInfo = claimingRegistry.claimInfo(index);

            _myClaimsInfo[i - offset].index = index;
            _myClaimsInfo[i - offset].policyBookAddress = claimInfo.policyBookAddress;
            _myClaimsInfo[i - offset].evidenceURI = claimInfo.evidenceURI;
            _myClaimsInfo[i - offset].appeal = claimInfo.appeal;
            _myClaimsInfo[i - offset].claimAmount = claimInfo.claimAmount;
            _myClaimsInfo[i - offset].finalVerdict = claimInfo.status;

            if (_myClaimsInfo[i - offset].finalVerdict == IClaimingRegistry.ClaimStatus.ACCEPTED) {
                _myClaimsInfo[i - offset].finalClaimAmount = _votings[index]
                    .votedAverageWithdrawalAmount;
            } else if (
                _myClaimsInfo[i - offset].finalVerdict ==
                IClaimingRegistry.ClaimStatus.AWAITING_CALCULATION
            ) {
                _myClaimsInfo[i - offset].bmiCalculationReward = _getBMIRewardForCalculation(
                    index
                );
            }
        }
    }

    function myVotes(uint256 offset, uint256 limit)
        external
        view
        override
        returns (MyVoteInfo[] memory _myVotesInfo)
    {
        uint256 to = (offset.add(limit)).min(_myVotes[msg.sender].length()).max(offset);

        _myVotesInfo = new MyVoteInfo[](to - offset);

        for (uint256 i = offset; i < to; i++) {
            uint256 voteIndex = _myVotes[msg.sender].at(i);
            uint256 claimIndex = _allVotesByIndexInst[voteIndex].claimIndex;

            IClaimingRegistry.ClaimInfo memory claimInfo = claimingRegistry.claimInfo(claimIndex);

            _myVotesInfo[i - offset].allClaimInfo.publicClaimInfo.claimIndex = claimIndex;
            _myVotesInfo[i - offset].allClaimInfo.publicClaimInfo.claimer = claimInfo.claimer;
            _myVotesInfo[i - offset].allClaimInfo.publicClaimInfo.policyBookAddress = claimInfo
                .policyBookAddress;
            _myVotesInfo[i - offset].allClaimInfo.publicClaimInfo.evidenceURI = claimInfo
                .evidenceURI;
            _myVotesInfo[i - offset].allClaimInfo.publicClaimInfo.appeal = claimInfo.appeal;
            _myVotesInfo[i - offset].allClaimInfo.publicClaimInfo.claimAmount = claimInfo
                .claimAmount;
            _myVotesInfo[i - offset].allClaimInfo.publicClaimInfo.time = claimInfo.dateSubmitted;

            _myVotesInfo[i - offset].allClaimInfo.finalVerdict = claimInfo.status;

            if (
                _myVotesInfo[i - offset].allClaimInfo.finalVerdict ==
                IClaimingRegistry.ClaimStatus.ACCEPTED
            ) {
                _myVotesInfo[i - offset].allClaimInfo.finalClaimAmount = _votings[claimIndex]
                    .votedAverageWithdrawalAmount;
            }

            _myVotesInfo[i - offset].suggestedAmount = _allVotesByIndexInst[voteIndex]
                .suggestedAmount;
            _myVotesInfo[i - offset].status = voteStatus(voteIndex);

            if (_myVotesInfo[i - offset].status == VoteStatus.ANONYMOUS_PENDING) {
                _myVotesInfo[i - offset].time = claimInfo
                    .dateSubmitted
                    .add(claimingRegistry.anonymousVotingDuration(claimIndex))
                    .sub(block.timestamp);
            } else if (_myVotesInfo[i - offset].status == VoteStatus.AWAITING_EXPOSURE) {
                _myVotesInfo[i - offset].encryptedVote = _allVotesByIndexInst[voteIndex]
                    .encryptedVote;
                _myVotesInfo[i - offset].time = claimInfo
                    .dateSubmitted
                    .add(claimingRegistry.votingDuration(claimIndex))
                    .sub(block.timestamp);
            }
        }
    }

    function myNotReceivesVotes(address user)
        public
        view
        override
        returns (uint256[] memory claimIndexes, VotesUpdatesInfo[] memory voteRewardInfo)
    {
        uint256 notReceivedCount = _myNotReceivedVotes[user].length();
        claimIndexes = new uint256[](notReceivedCount);
        voteRewardInfo = new VotesUpdatesInfo[](notReceivedCount);

        for (uint256 i = 0; i < notReceivedCount; i++) {
            uint256 claimIndex = _myNotReceivedVotes[user].at(i);
            uint256 voteIndex = _allVotesToIndex[user][claimIndex];
            claimIndexes[i] = claimIndex;
            voteRewardInfo[i].bmiReward = voteResults[voteIndex].bmiReward;
            voteRewardInfo[i].stblReward = voteResults[voteIndex].stblReward;
            voteRewardInfo[i].reputationChange = voteResults[voteIndex].reputationChange;
            voteRewardInfo[i].stakeChange = voteResults[voteIndex].stakeChange;
        }
    }

    function _calculateAverages(
        uint256 claimIndex,
        uint256 stakedStkBMI,
        uint256 suggestedClaimAmount,
        uint256 reputationWithPrecision,
        bool votedFor
    ) internal {
        VotingResult storage info = _votings[claimIndex];

        if (votedFor) {
            uint256 votedPower = info.votedYesStakedStkBMIAmountWithReputation;
            uint256 voterPower = stakedStkBMI.mul(reputationWithPrecision);
            uint256 totalPower = votedPower.add(voterPower);

            uint256 votedSuggestedPrice = info.votedAverageWithdrawalAmount.mul(votedPower);
            uint256 voterSuggestedPrice = suggestedClaimAmount.mul(voterPower);
            if (totalPower > 0) {
                info.votedAverageWithdrawalAmount = votedSuggestedPrice
                    .add(voterSuggestedPrice)
                    .div(totalPower);
            }
            info.votedYesStakedStkBMIAmountWithReputation = totalPower;
        } else {
            info.votedNoStakedStkBMIAmountWithReputation = info
                .votedNoStakedStkBMIAmountWithReputation
                .add(stakedStkBMI.mul(reputationWithPrecision));
        }

        info.allVotedStakedStkBMIAmount = info.allVotedStakedStkBMIAmount.add(stakedStkBMI);
    }

    function _modifyExposedVote(
        address voter,
        uint256 claimIndex,
        uint256 suggestedClaimAmount,
        bool accept
    ) internal {
        uint256 index = _allVotesToIndex[voter][claimIndex];

        _allVotesByIndexInst[index].finalHash = 0;
        delete _allVotesByIndexInst[index].encryptedVote;

        _allVotesByIndexInst[index].suggestedAmount = suggestedClaimAmount;
        _allVotesByIndexInst[index].accept = accept;
        _allVotesByIndexInst[index].status = VoteStatus.EXPOSED_PENDING;
    }

    function _addAnonymousVote(
        address voter,
        uint256 claimIndex,
        bytes32 finalHash,
        string memory encryptedVote,
        uint256 stakedStkBMI
    ) internal {
        _myVotes[voter].add(_voteIndex);

        _allVotesByIndexInst[_voteIndex].claimIndex = claimIndex;
        _allVotesByIndexInst[_voteIndex].finalHash = finalHash;
        _allVotesByIndexInst[_voteIndex].encryptedVote = encryptedVote;
        _allVotesByIndexInst[_voteIndex].voter = voter;
        _allVotesByIndexInst[_voteIndex].voterReputation = reputationSystem.reputation(voter);
        _allVotesByIndexInst[_voteIndex].stakedStkBMIAmount = stakedStkBMI;

        _allVotesToIndex[voter][claimIndex] = _voteIndex;
        _allVotesIndexes.add(_voteIndex);

        _votings[claimIndex].voteIndexes.add(_voteIndex);

        _voteIndex++;
    }

    function anonymouslyVoteBatch(
        uint256[] calldata claimIndexes,
        bytes32[] calldata finalHashes,
        string[] calldata encryptedVotes
    ) external override {
        require(canVote(msg.sender), "CV: There are reception awaiting votes");
        require(
            claimIndexes.length == finalHashes.length &&
                claimIndexes.length == encryptedVotes.length,
            "CV: Length mismatches"
        );

        uint256 stakedStkBMI = stkBMIStaking.stakedStkBMI(msg.sender);
        require(stakedStkBMI > 0, "CV: 0 staked StkBMI");

        for (uint256 i = 0; i < claimIndexes.length; i++) {
            uint256 claimIndex = claimIndexes[i];

            require(
                claimingRegistry.isClaimAnonymouslyVotable(claimIndex),
                "CV: Anonymous voting is over"
            );
            require(
                claimingRegistry.claimOwner(claimIndex) != msg.sender,
                "CV: Voter is the claimer"
            );
            require(
                !claimingRegistry.isClaimAppeal(claimIndex) ||
                    reputationSystem.isTrustedVoter(msg.sender),
                "CV: Not a trusted voter"
            );
            require(
                _allVotesToIndex[msg.sender][claimIndex] == 0,
                "CV: Already voted for this claim"
            );

            _addAnonymousVote(
                msg.sender,
                claimIndex,
                finalHashes[i],
                encryptedVotes[i],
                stakedStkBMI
            );

            emit AnonymouslyVoted(claimIndex);
        }
    }

    function exposeVoteBatch(
        uint256[] calldata claimIndexes,
        uint256[] calldata suggestedClaimAmounts,
        bytes32[] calldata hashedSignaturesOfClaims
    ) external override {
        require(
            claimIndexes.length == suggestedClaimAmounts.length &&
                claimIndexes.length == hashedSignaturesOfClaims.length,
            "CV: Length mismatches"
        );

        for (uint256 i = 0; i < claimIndexes.length; i++) {
            uint256 claimIndex = claimIndexes[i];
            uint256 voteIndex = _allVotesToIndex[msg.sender][claimIndex];

            require(_allVotesIndexes.contains(voteIndex), "CV: Vote doesn't exist");
            require(_isVoteAwaitingExposure(voteIndex), "CV: Vote is not awaiting");

            bytes32 finalHash =
                keccak256(
                    abi.encodePacked(
                        hashedSignaturesOfClaims[i],
                        _allVotesByIndexInst[voteIndex].encryptedVote,
                        suggestedClaimAmounts[i]
                    )
                );

            require(_allVotesByIndexInst[voteIndex].finalHash == finalHash, "CV: Data mismatches");
            require(
                _votings[claimIndex].withdrawalAmount >= suggestedClaimAmounts[i],
                "CV: Amount exceeds coverage"
            );

            bool voteFor = (suggestedClaimAmounts[i] > 0);

            _calculateAverages(
                claimIndex,
                _allVotesByIndexInst[voteIndex].stakedStkBMIAmount,
                suggestedClaimAmounts[i],
                _allVotesByIndexInst[voteIndex].voterReputation,
                voteFor
            );

            _modifyExposedVote(msg.sender, claimIndex, suggestedClaimAmounts[i], voteFor);

            emit VoteExposed(claimIndex, msg.sender, suggestedClaimAmounts[i]);
        }
    }

    function _getRewardRatio(
        uint256 claimIndex,
        address voter,
        uint256 votedStakedStkBMIAmountWithReputation
    ) internal view returns (uint256) {
        if (votedStakedStkBMIAmountWithReputation < 0) return 0;

        uint256 voteIndex = _allVotesToIndex[voter][claimIndex];

        uint256 voterBMI = _allVotesByIndexInst[voteIndex].stakedStkBMIAmount;
        uint256 voterReputation = _allVotesByIndexInst[voteIndex].voterReputation;

        return
            voterBMI.mul(voterReputation).mul(PERCENTAGE_100).div(
                votedStakedStkBMIAmountWithReputation
            );
    }

    function _calculateMajorityYesVote(
        uint256 claimIndex,
        address voter,
        uint256 oldReputation
    )
        internal
        view
        returns (
            uint256 _stblAmount,
            uint256 _bmiAmount,
            uint256 _newReputation
        )
    {
        VotingResult storage info = _votings[claimIndex];

        uint256 voterRatio =
            _getRewardRatio(claimIndex, voter, info.votedYesStakedStkBMIAmountWithReputation);

        if (claimingRegistry.claimStatus(claimIndex) == IClaimingRegistry.ClaimStatus.ACCEPTED) {
            _stblAmount = info.reinsuranceTokensAmount.mul(voterRatio).div(PERCENTAGE_100);
        } else {
            _bmiAmount = info.lockedBMIAmount.mul(voterRatio).div(PERCENTAGE_100);
        }

        _newReputation = reputationSystem.getNewReputation(oldReputation, info.votedYesPercentage);
    }

    function _calculateMajorityNoVote(
        uint256 claimIndex,
        address voter,
        uint256 oldReputation
    ) internal view returns (uint256 _bmiAmount, uint256 _newReputation) {
        VotingResult storage info = _votings[claimIndex];

        uint256 voterRatio =
            _getRewardRatio(claimIndex, voter, info.votedNoStakedStkBMIAmountWithReputation);

        _bmiAmount = info.lockedBMIAmount.mul(voterRatio).div(PERCENTAGE_100);

        _newReputation = reputationSystem.getNewReputation(
            oldReputation,
            PERCENTAGE_100.sub(info.votedYesPercentage)
        );
    }

    function _calculateMinorityVote(
        uint256 claimIndex,
        address voter,
        uint256 oldReputation
    ) internal view returns (uint256 _bmiPenalty, uint256 _newReputation) {
        uint256 minorityPercentageWithPrecision =
            Math.min(
                _votings[claimIndex].votedYesPercentage,
                PERCENTAGE_100.sub(_votings[claimIndex].votedYesPercentage)
            );

        if (minorityPercentageWithPrecision < PENALTY_THRESHOLD) {
            _bmiPenalty = Math.min(
                stkBMIStaking.stakedStkBMI(voter),
                _allVotesByIndexInst[_allVotesToIndex[voter][claimIndex]]
                    .stakedStkBMIAmount
                    .mul(PENALTY_THRESHOLD.sub(minorityPercentageWithPrecision))
                    .div(PERCENTAGE_100)
            );
        }

        _newReputation = reputationSystem.getNewReputation(
            oldReputation,
            minorityPercentageWithPrecision
        );
    }

    function _calculateVoteResult(uint256 claimIndex) internal {
        for (uint256 i = 0; i < _votings[claimIndex].voteIndexes.length(); i++) {
            uint256 voteIndex = _votings[claimIndex].voteIndexes.at(i);
            address voter = _allVotesByIndexInst[voteIndex].voter;
            uint256 oldReputation = reputationSystem.reputation(voter);

            require(_allVotesIndexes.contains(voteIndex), "CV: Vote doesn't exist");

            uint256 stblAmount;
            uint256 bmiAmount;
            uint256 bmiPenaltyAmount;
            uint256 newReputation;
            VoteStatus status;

            if (_isVoteAwaitingExposure(voteIndex)) {
                bmiPenaltyAmount = _allVotesByIndexInst[_allVotesToIndex[voter][claimIndex]]
                    .stakedStkBMIAmount;
                voteResults[voteIndex].stakeChange = int256(bmiPenaltyAmount);
            } else if (
                _votings[claimIndex].votedYesPercentage >= PERCENTAGE_50 &&
                _allVotesByIndexInst[voteIndex].suggestedAmount > 0
            ) {
                (stblAmount, bmiAmount, newReputation) = _calculateMajorityYesVote(
                    claimIndex,
                    voter,
                    oldReputation
                );

                voteResults[voteIndex].stblReward = stblAmount;

                status = VoteStatus.MAJORITY;
            } else if (
                _votings[claimIndex].votedYesPercentage < PERCENTAGE_50 &&
                _allVotesByIndexInst[voteIndex].suggestedAmount == 0
            ) {
                (bmiAmount, newReputation) = _calculateMajorityNoVote(
                    claimIndex,
                    voter,
                    oldReputation
                );
                status = VoteStatus.MAJORITY;
            } else {
                (bmiPenaltyAmount, newReputation) = _calculateMinorityVote(
                    claimIndex,
                    voter,
                    oldReputation
                );
                voteResults[voteIndex].stakeChange = int256(bmiPenaltyAmount);

                status = VoteStatus.MINORITY;
            }

            _allVotesByIndexInst[voteIndex].status = status;
            voteResults[voteIndex].reputationChange = int256(newReputation);
            voteResults[voteIndex].bmiReward = bmiAmount;

            _myNotReceivedVotes[voter].add(claimIndex);

            emit VoteCalculated(claimIndex, voter, status);
        }
    }

    function _getBMIRewardForCalculation(uint256 claimIndex) internal view returns (uint256) {
        uint256 lockedBMIs = _votings[claimIndex].lockedBMIAmount;
        uint256 timeElapsed =
            claimingRegistry.claimSubmittedTime(claimIndex).add(
                claimingRegistry.anyoneCanCalculateClaimResultAfter(claimIndex)
            );

        if (claimingRegistry.canClaimBeCalculatedByAnyone(claimIndex)) {
            timeElapsed = block.timestamp.sub(timeElapsed);
        } else {
            timeElapsed = timeElapsed.sub(block.timestamp);
        }

        return
            Math.min(
                lockedBMIs,
                lockedBMIs.mul(timeElapsed.mul(CALCULATION_REWARD_PER_DAY.div(1 days))).div(
                    PERCENTAGE_100
                )
            );
    }

    function _sendRewardsForCalculationTo(uint256 claimIndex, address calculator) internal {
        uint256 reward = _getBMIRewardForCalculation(claimIndex);

        _votings[claimIndex].lockedBMIAmount = _votings[claimIndex].lockedBMIAmount.sub(reward);

        bmiToken.transfer(calculator, reward);

        emit RewardsForClaimCalculationSent(calculator, reward);
    }

    function calculateResult(uint256 claimIndex) external override {
        require(
            claimingRegistry.canClaimBeCalculatedByAnyone(claimIndex) ||
                claimingRegistry.claimOwner(claimIndex) == msg.sender,
            "CV: Not allowed to calculate"
        );
        _sendRewardsForCalculationTo(claimIndex, msg.sender);

        if (claimingRegistry.claimStatus(claimIndex) == IClaimingRegistry.ClaimStatus.EXPIRED) {
            claimingRegistry.expireClaim(claimIndex);
        } else {
            require(
                claimingRegistry.claimStatus(claimIndex) ==
                    IClaimingRegistry.ClaimStatus.AWAITING_CALCULATION,
                "CV: Claim is not awaiting"
            );

            _resolveClaim(claimIndex);
            _calculateVoteResult(claimIndex);
        }
    }

    function _resolveClaim(uint256 claimIndex) internal {
        uint256 totalStakedStkBMI = stkBMIStaking.totalStakedStkBMI();

        uint256 allVotedStakedStkBMI = _votings[claimIndex].allVotedStakedStkBMIAmount;

        if (
            allVotedStakedStkBMI == 0 ||
            ((totalStakedStkBMI == 0 ||
                totalStakedStkBMI.mul(QUORUM).div(PERCENTAGE_100) > allVotedStakedStkBMI) &&
                !claimingRegistry.isClaimAppeal(claimIndex))
        ) {
            claimingRegistry.rejectClaim(claimIndex);
        } else {
            uint256 votedYesPower = _votings[claimIndex].votedYesStakedStkBMIAmountWithReputation;
            uint256 votedNoPower = _votings[claimIndex].votedNoStakedStkBMIAmountWithReputation;
            uint256 totalPower = votedYesPower.add(votedNoPower);
            if (totalPower > 0) {
                _votings[claimIndex].votedYesPercentage = votedYesPower.mul(PERCENTAGE_100).div(
                    totalPower
                );
            }

            if (_votings[claimIndex].votedYesPercentage >= APPROVAL_PERCENTAGE) {
                claimingRegistry.acceptClaim(
                    claimIndex,
                    _votings[claimIndex].votedAverageWithdrawalAmount
                );
            } else {
                claimingRegistry.rejectClaim(claimIndex);
            }
        }
        emit ClaimCalculated(claimIndex, msg.sender);
    }

    function receiveResult() external override {
        uint256 notReceivedLength = _myNotReceivedVotes[msg.sender].length();
        uint256 oldReputation = reputationSystem.reputation(msg.sender);

        (uint256 rewardAmount, ) = claimingRegistry.rewardWithdrawalInfo(msg.sender);

        uint256 stblAmount = rewardAmount;
        uint256 bmiAmount;
        int256 bmiPenaltyAmount;
        uint256 newReputation = oldReputation;

        for (uint256 i = 0; i < notReceivedLength; i++) {
            uint256 claimIndex = _myNotReceivedVotes[msg.sender].at(i);
            uint256 voteIndex = _allVotesToIndex[msg.sender][claimIndex];
            stblAmount = stblAmount.add(voteResults[voteIndex].stblReward);
            bmiAmount = bmiAmount.add(voteResults[voteIndex].bmiReward);
            bmiPenaltyAmount += voteResults[voteIndex].stakeChange;
            if (uint256(voteResults[voteIndex].reputationChange) > oldReputation) {
                newReputation = newReputation.add(
                    uint256(voteResults[voteIndex].reputationChange).sub(oldReputation)
                );
            } else if (uint256(voteResults[voteIndex].reputationChange) < oldReputation) {
                newReputation = newReputation.sub(
                    oldReputation.sub(uint256(voteResults[voteIndex].reputationChange))
                );
            }
            _allVotesByIndexInst[voteIndex].status = VoteStatus.RECEIVED;
        }
        if (stblAmount > 0) {
            claimingRegistry.requestRewardWithdrawal(msg.sender, stblAmount);
        }
        if (bmiAmount > 0) {
            bmiToken.transfer(msg.sender, bmiAmount);
        }
        if (bmiPenaltyAmount > 0) {
            stkBMIStaking.slashUserTokens(msg.sender, uint256(bmiPenaltyAmount));
        }
        reputationSystem.setNewReputation(msg.sender, newReputation);

        delete _myNotReceivedVotes[msg.sender];

        emit RewardsForVoteCalculationSent(msg.sender, bmiAmount);
    }

    function transferLockedBMI(uint256 claimIndex, address claimer)
        external
        override
        onlyClaimingRegistry
    {
        uint256 lockedAmount = _votings[claimIndex].lockedBMIAmount;
        require(lockedAmount > 0, "CV: Already withdrawn");
        _votings[claimIndex].lockedBMIAmount = 0;
        bmiToken.transfer(claimer, lockedAmount);
    }
}