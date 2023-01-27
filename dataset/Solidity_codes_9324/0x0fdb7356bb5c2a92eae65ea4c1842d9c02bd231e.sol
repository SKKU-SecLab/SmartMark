
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


interface IShieldMining {
    struct ShieldMiningInfo {
        IERC20 rewardsToken;
        uint8 decimals;
        uint256 firstBlockWithReward;
        uint256 lastBlockWithReward;
        uint256 lastUpdateBlock;
        uint256 rewardTokensLocked;
        uint256 rewardPerTokenStored;
        uint256 totalSupply;
        uint256[] endsOfDistribution;
        uint256 nearestLastBlocksWithReward;
        mapping(uint256 => uint256) rewardPerBlock;
    }

    struct ShieldMiningDeposit {
        address policyBook;
        uint256 amount;
        uint256 duration;
        uint256 depositRewardPerBlock;
        uint256 startBlock;
        uint256 endBlock;
    }

    function blocksWithRewardsPassed(address _policyBook) external view returns (uint256);

    function rewardPerToken(address _policyBook) external view returns (uint256);

    function earned(
        address _policyBook,
        address _userLeveragePool,
        address _account
    ) external view returns (uint256);

    function updateTotalSupply(
        address _policyBook,
        address _userLeveragePool,
        address liquidityProvider
    ) external;

    function associateShieldMining(address _policyBook, address _shieldMiningToken) external;

    function fillShieldMining(
        address _policyBook,
        uint256 _amount,
        uint256 _duration
    ) external;

    function getRewardFor(
        address _userAddress,
        address _policyBook,
        address _userLeveragePool
    ) external;

    function getRewardFor(address _userAddress, address _userLeveragePoolAddress) external;

    function getReward(address _policyBook, address _userLeveragePool) external;

    function getReward(address _userLeveragePoolAddress) external;

    function getShieldTokenAddress(address _policyBook) external view returns (address);

    function getShieldMiningInfo(address _policyBook)
        external
        view
        returns (
            address _rewardsToken,
            uint256 _decimals,
            uint256 _firstBlockWithReward,
            uint256 _lastBlockWithReward,
            uint256 _lastUpdateBlock,
            uint256 _nearestLastBlocksWithReward,
            uint256 _rewardTokensLocked,
            uint256 _rewardPerTokenStored,
            uint256 _rewardPerBlock,
            uint256 _tokenPerDay,
            uint256 _totalSupply
        );

    function getDepositList(
        address _account,
        uint256 _offset,
        uint256 _limit
    ) external view returns (ShieldMiningDeposit[] memory _depositsList);

    function countUsersDeposits(address _account) external view returns (uint256);
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

interface IPriceFeed {
    function howManyBMIsInUSDT(uint256 usdtAmount) external view returns (uint256);

    function howManyUSDTsInBMI(uint256 bmiAmount) external view returns (uint256);
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

interface IRewardsGenerator {
    struct PolicyBookRewardInfo {
        uint256 rewardMultiplier; // includes 5 decimal places
        uint256 totalStaked;
        uint256 lastUpdateBlock;
        uint256 lastCumulativeSum; // includes 100 percentage
        uint256 cumulativeReward; // includes 100 percentage
    }

    struct StakeRewardInfo {
        uint256 lastCumulativeSum; // includes 100 percentage
        uint256 cumulativeReward;
        uint256 stakeAmount;
    }

    function updatePolicyBookShare(uint256 newRewardMultiplier, address policyBook) external;

    function aggregate(
        address policyBookAddress,
        uint256[] calldata nftIndexes,
        uint256 nftIndexTo
    ) external;

    function stake(
        address policyBookAddress,
        uint256 nftIndex,
        uint256 amount
    ) external;

    function getPolicyBookAPY(address policyBookAddress) external view returns (uint256);

    function getPolicyBookRewardMultiplier(address policyBookAddress)
        external
        view
        returns (uint256);

    function getPolicyBookRewardPerBlock(address policyBookAddress)
        external
        view
        returns (uint256);

    function getStakedPolicyBookSTBL(address policyBookAddress) external view returns (uint256);

    function getStakedNFTSTBL(uint256 nftIndex) external view returns (uint256);

    function getReward(address policyBookAddress, uint256 nftIndex)
        external
        view
        returns (uint256);

    function withdrawFunds(address policyBookAddress, uint256 nftIndex) external returns (uint256);

    function withdrawReward(address policyBookAddress, uint256 nftIndex)
        external
        returns (uint256);
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







contract PolicyBookFacade is IPolicyBookFacade, AbstractDependant, Initializable {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Math for uint256;

    uint256 public constant MINUMUM_COVERAGE = 100 * DECIMALS18; // 100 STBL

    uint256 public constant EPOCH_DURATION = 1 weeks;
    uint256 public constant MAXIMUM_EPOCHS = SECONDS_IN_THE_YEAR / EPOCH_DURATION;

    uint256 public constant RISKY_UTILIZATION_RATIO = 80 * PRECISION;
    uint256 public constant MODERATE_UTILIZATION_RATIO = 50 * PRECISION;

    uint256 public constant MINIMUM_REWARD = 15 * PRECISION; // 0.15
    uint256 public constant MAXIMUM_REWARD = 2 * PERCENTAGE_100; // 2.0
    uint256 public constant BASE_REWARD = PERCENTAGE_100; // 1.0

    IPolicyBookAdmin public policyBookAdmin;
    ILeveragePortfolio public reinsurancePool;
    IPolicyBook public override policyBook;
    IShieldMining public shieldMining;
    IPolicyBookRegistry public policyBookRegistry;

    using SafeMath for uint256;

    ILiquidityRegistry public liquidityRegistry;

    address public capitalPoolAddress;
    address public priceFeed;

    uint256 public override VUreinsurnacePool;
    uint256 public override LUreinsurnacePool;
    mapping(address => uint256) public override LUuserLeveragePool;
    uint256 public override totalLeveragedLiquidity;

    uint256 public override userleveragedMPL;
    uint256 public override reinsurancePoolMPL;

    uint256 public override rebalancingThreshold;

    bool public override safePricingModel;

    mapping(address => uint256) public override userLiquidity;

    EnumerableSet.AddressSet internal userLeveragePools;

    IRewardsGenerator public rewardsGenerator;

    IPolicyQuote public policyQuote;

    IClaimingRegistry public claimingRegistry;

    event DeployLeverageFunds(uint256 _deployedAmount);

    modifier onlyCapitalPool() {
        require(msg.sender == capitalPoolAddress, "PBFC: only CapitalPool");
        _;
    }

    modifier onlyPolicyBookAdmin() {
        require(msg.sender == address(policyBookAdmin), "PBFC: Not a PBA");
        _;
    }

    modifier onlyLeveragePortfolio() {
        require(
            msg.sender == address(reinsurancePool) ||
                policyBookRegistry.isUserLeveragePool(msg.sender),
            "PBFC: only LeveragePortfolio"
        );
        _;
    }

    modifier onlyPolicyBookRegistry() {
        require(msg.sender == address(policyBookRegistry), "PBFC: Not a policy book registry");
        _;
    }

    modifier onlyPolicyBook() {
        require(msg.sender == address(policyBook), "PBFC: Not a policy book");
        _;
    }

    function __PolicyBookFacade_init(
        address pbProxy,
        address liquidityProvider,
        uint256 _initialDeposit
    ) external override initializer {
        policyBook = IPolicyBook(pbProxy);
        rebalancingThreshold = DEFAULT_REBALANCING_THRESHOLD;
        userLiquidity[liquidityProvider] = _initialDeposit;
    }

    function setDependencies(IContractsRegistry contractsRegistry)
        external
        override
        onlyInjectorOrZero
    {
        IContractsRegistry _contractsRegistry = IContractsRegistry(contractsRegistry);

        capitalPoolAddress = _contractsRegistry.getCapitalPoolContract();
        policyBookRegistry = IPolicyBookRegistry(
            _contractsRegistry.getPolicyBookRegistryContract()
        );
        liquidityRegistry = ILiquidityRegistry(_contractsRegistry.getLiquidityRegistryContract());
        policyBookAdmin = IPolicyBookAdmin(_contractsRegistry.getPolicyBookAdminContract());
        priceFeed = _contractsRegistry.getPriceFeedContract();
        reinsurancePool = ILeveragePortfolio(_contractsRegistry.getReinsurancePoolContract());
        policyQuote = IPolicyQuote(_contractsRegistry.getPolicyQuoteContract());
        shieldMining = IShieldMining(_contractsRegistry.getShieldMiningContract());
        rewardsGenerator = IRewardsGenerator(_contractsRegistry.getRewardsGeneratorContract());
        claimingRegistry = IClaimingRegistry(_contractsRegistry.getClaimingRegistryContract());
    }

    function buyPolicy(uint256 _epochsNumber, uint256 _coverTokens) external override {
        _buyPolicy(msg.sender, msg.sender, _epochsNumber, _coverTokens, 0, address(0));
    }

    function buyPolicyFor(
        address _holder,
        uint256 _epochsNumber,
        uint256 _coverTokens
    ) external override {
        _buyPolicy(msg.sender, _holder, _epochsNumber, _coverTokens, 0, address(0));
    }

    function buyPolicyFromDistributor(
        uint256 _epochsNumber,
        uint256 _coverTokens,
        address _distributor
    ) external override {
        uint256 _distributorFee = policyBookAdmin.distributorFees(_distributor);
        _buyPolicy(
            msg.sender,
            msg.sender,
            _epochsNumber,
            _coverTokens,
            _distributorFee,
            _distributor
        );
    }

    function buyPolicyFromDistributorFor(
        address _holder,
        uint256 _epochsNumber,
        uint256 _coverTokens,
        address _distributor
    ) external override {
        uint256 _distributorFee = policyBookAdmin.distributorFees(_distributor);
        _buyPolicy(
            msg.sender,
            _holder,
            _epochsNumber,
            _coverTokens,
            _distributorFee,
            _distributor
        );
    }

    function addLiquidity(uint256 _liquidityAmount) external override {
        _addLiquidity(msg.sender, msg.sender, _liquidityAmount, 0);
    }

    function addLiquidityFromDistributorFor(address _liquidityHolderAddr, uint256 _liquidityAmount)
        external
        override
    {
        _addLiquidity(msg.sender, _liquidityHolderAddr, _liquidityAmount, 0);
    }

    function addLiquidityAndStakeFor(
        address _liquidityHolderAddr,
        uint256 _liquidityAmount,
        uint256 _stakeSTBLAmount
    ) external override {
        _addLiquidity(msg.sender, _liquidityHolderAddr, _liquidityAmount, _stakeSTBLAmount);
    }

    function addLiquidityAndStake(uint256 _liquidityAmount, uint256 _stakeSTBLAmount)
        external
        override
    {
        _addLiquidity(msg.sender, msg.sender, _liquidityAmount, _stakeSTBLAmount);
    }

    function _addLiquidity(
        address _liquidityBuyerAddr,
        address _liquidityHolderAddr,
        uint256 _liquidityAmount,
        uint256 _stakeSTBLAmount
    ) internal {
        uint256 _tokensToAdd =
            policyBook.addLiquidity(
                _liquidityBuyerAddr,
                _liquidityHolderAddr,
                _liquidityAmount,
                _stakeSTBLAmount
            );

        _reevaluateProvidedLeverageStable(_liquidityAmount);
        _updateShieldMining(_liquidityHolderAddr, _tokensToAdd, false);
    }

    function _buyPolicy(
        address _policyBuyerAddr,
        address _policyHolderAddr,
        uint256 _epochsNumber,
        uint256 _coverTokens,
        uint256 _distributorFee,
        address _distributor
    ) internal {
        policyBook.buyPolicy(
            _policyBuyerAddr,
            _policyHolderAddr,
            _epochsNumber,
            _coverTokens,
            _distributorFee,
            _distributor
        );

        _deployLeveragedFunds();
    }

    function _reevaluateProvidedLeverageStable(uint256 newAmount) internal {
        uint256 _newAmountPercentage;
        uint256 _totalLiq = policyBook.totalLiquidity();

        if (_totalLiq > 0) {
            _newAmountPercentage = newAmount.mul(PERCENTAGE_100).div(_totalLiq);
        }
        if ((_totalLiq > 0 && _newAmountPercentage > rebalancingThreshold) || _totalLiq == 0) {
            _deployLeveragedFunds();
        }
    }

    function reevaluateProvidedLeverageStable() external override onlyPolicyBook {
        _deployLeveragedFunds();
    }

    function deployLeverageFundsAfterRebalance(
        uint256 deployedAmount,
        ILeveragePortfolio.LeveragePortfolio leveragePool
    ) external override onlyLeveragePortfolio {
        if (leveragePool == ILeveragePortfolio.LeveragePortfolio.USERLEVERAGEPOOL) {
            LUuserLeveragePool[msg.sender] = deployedAmount;
            LUuserLeveragePool[msg.sender] > 0
                ? userLeveragePools.add(msg.sender)
                : userLeveragePools.remove(msg.sender);
        } else {
            LUreinsurnacePool = deployedAmount;
        }
        uint256 _LUuserLeveragePool;
        for (uint256 i = 0; i < userLeveragePools.length(); i++) {
            _LUuserLeveragePool = _LUuserLeveragePool.add(
                LUuserLeveragePool[userLeveragePools.at(i)]
            );
        }
        totalLeveragedLiquidity = VUreinsurnacePool.add(LUreinsurnacePool).add(
            _LUuserLeveragePool
        );
        emit DeployLeverageFunds(deployedAmount);
    }

    function deployVirtualFundsAfterRebalance(uint256 deployedAmount)
        external
        override
        onlyLeveragePortfolio
    {
        VUreinsurnacePool = deployedAmount;
        uint256 _LUuserLeveragePool;
        for (uint256 i = 0; i < userLeveragePools.length(); i++) {
            _LUuserLeveragePool = _LUuserLeveragePool.add(
                LUuserLeveragePool[userLeveragePools.at(i)]
            );
        }
        totalLeveragedLiquidity = VUreinsurnacePool.add(LUreinsurnacePool).add(
            _LUuserLeveragePool
        );
        emit DeployLeverageFunds(deployedAmount);
    }

    function _deployLeveragedFunds() internal {
        uint256 _deployedAmount;

        uint256 _LUuserLeveragePool;

        _deployedAmount = reinsurancePool.deployVirtualStableToCoveragePools();
        VUreinsurnacePool = _deployedAmount;

        _deployedAmount = reinsurancePool.deployLeverageStableToCoveragePools(
            ILeveragePortfolio.LeveragePortfolio.REINSURANCEPOOL
        );
        LUreinsurnacePool = _deployedAmount;

        address[] memory _userLeverageArr =
            policyBookRegistry.listByType(
                IPolicyBookFabric.ContractType.VARIOUS,
                0,
                policyBookRegistry.countByType(IPolicyBookFabric.ContractType.VARIOUS)
            );
        for (uint256 i = 0; i < _userLeverageArr.length; i++) {
            _deployedAmount = ILeveragePortfolio(_userLeverageArr[i])
                .deployLeverageStableToCoveragePools(
                ILeveragePortfolio.LeveragePortfolio.USERLEVERAGEPOOL
            );
            ILeveragePortfolio(_userLeverageArr[i]).forceUpdateBMICoverStakingRewardMultiplier();
            LUuserLeveragePool[_userLeverageArr[i]] = _deployedAmount;
            _deployedAmount > 0
                ? userLeveragePools.add(_userLeverageArr[i])
                : userLeveragePools.remove(_userLeverageArr[i]);

            _LUuserLeveragePool = _LUuserLeveragePool.add(_deployedAmount);
        }

        totalLeveragedLiquidity = VUreinsurnacePool.add(LUreinsurnacePool).add(
            _LUuserLeveragePool
        );
    }

    function _updateShieldMining(
        address liquidityProvider,
        uint256 liquidityAmount,
        bool isWithdraw
    ) internal {
        if (shieldMining.getShieldTokenAddress(address(policyBook)) != address(0)) {
            shieldMining.updateTotalSupply(address(policyBook), address(0), liquidityProvider);
        }

        if (isWithdraw) {
            userLiquidity[liquidityProvider] = userLiquidity[liquidityProvider].sub(
                liquidityAmount
            );
        } else {
            userLiquidity[liquidityProvider] = userLiquidity[liquidityProvider].add(
                liquidityAmount
            );
        }
    }

    function withdrawLiquidity() external override {
        uint256 _withdrawAmount = policyBook.withdrawLiquidity(msg.sender);
        _reevaluateProvidedLeverageStable(_withdrawAmount);
        _updateShieldMining(msg.sender, _withdrawAmount, true);
    }

    function setMPLs(uint256 _userLeverageMPL, uint256 _reinsuranceLeverageMPL)
        external
        override
        onlyPolicyBookAdmin
    {
        userleveragedMPL = _userLeverageMPL;
        reinsurancePoolMPL = _reinsuranceLeverageMPL;
    }

    function setRebalancingThreshold(uint256 _newRebalancingThreshold)
        external
        override
        onlyPolicyBookAdmin
    {
        require(_newRebalancingThreshold > 0, "PBF: threshold can not be 0");
        rebalancingThreshold = _newRebalancingThreshold;
    }

    function setSafePricingModel(bool _safePricingModel) external override onlyPolicyBookAdmin {
        safePricingModel = _safePricingModel;
    }

    function getClaimApprovalAmount(address user) external view override returns (uint256) {
        (uint256 _coverTokens, , , , ) = policyBook.policyHolders(user);
        _coverTokens = DecimalsConverter.convertFrom18(
            _coverTokens.div(100),
            policyBook.stblDecimals()
        );

        return IPriceFeed(priceFeed).howManyBMIsInUSDT(_coverTokens);
    }

    function requestWithdrawal(uint256 _tokensToWithdraw) external override {
        require(_tokensToWithdraw > 0, "PB: Amount is zero");

        IPolicyBook.WithdrawalStatus _withdrawlStatus = policyBook.getWithdrawalStatus(msg.sender);

        require(
            _withdrawlStatus == IPolicyBook.WithdrawalStatus.NONE ||
                _withdrawlStatus == IPolicyBook.WithdrawalStatus.EXPIRED,
            "PBf: ongoing withdrawl request"
        );

        require(
            !claimingRegistry.hasProcedureOngoing(address(policyBook)),
            "PBf: ongoing claim procedure"
        );

        policyBook.requestWithdrawal(_tokensToWithdraw, msg.sender);

        liquidityRegistry.registerWithdrawl(address(policyBook), msg.sender);
    }

    function listUserLeveragePools(uint256 offset, uint256 limit)
        external
        view
        override
        returns (address[] memory _userLeveragePools)
    {
        uint256 to = (offset.add(limit)).min(userLeveragePools.length()).max(offset);

        _userLeveragePools = new address[](to - offset);

        for (uint256 i = offset; i < to; i++) {
            _userLeveragePools[i - offset] = userLeveragePools.at(i);
        }
    }

    function countUserLeveragePools() external view override returns (uint256) {
        return userLeveragePools.length();
    }

    function secondsToEndCurrentEpoch() public view override returns (uint256) {
        uint256 epochNumber =
            block.timestamp.sub(policyBook.epochStartTime()).div(EPOCH_DURATION) + 1;

        return
            epochNumber.mul(EPOCH_DURATION).sub(block.timestamp.sub(policyBook.epochStartTime()));
    }

    function forceUpdateBMICoverStakingRewardMultiplier() external override {
        uint256 rewardMultiplier;

        if (policyBook.whitelisted()) {
            rewardMultiplier = MINIMUM_REWARD;
            uint256 liquidity = policyBook.totalLiquidity();
            uint256 coverTokens = policyBook.totalCoverTokens();

            if (coverTokens > 0 && liquidity > 0) {
                rewardMultiplier = BASE_REWARD;

                uint256 utilizationRatio = coverTokens.mul(PERCENTAGE_100).div(liquidity);

                if (utilizationRatio < MODERATE_UTILIZATION_RATIO) {
                    rewardMultiplier = Math
                        .max(utilizationRatio, PRECISION)
                        .sub(PRECISION)
                        .mul(BASE_REWARD.sub(MINIMUM_REWARD))
                        .div(MODERATE_UTILIZATION_RATIO)
                        .add(MINIMUM_REWARD);
                } else if (utilizationRatio > RISKY_UTILIZATION_RATIO) {
                    rewardMultiplier = MAXIMUM_REWARD
                        .sub(BASE_REWARD)
                        .mul(utilizationRatio.sub(RISKY_UTILIZATION_RATIO))
                        .div(PERCENTAGE_100.sub(RISKY_UTILIZATION_RATIO))
                        .add(BASE_REWARD);
                }
            }
        }

        rewardsGenerator.updatePolicyBookShare(rewardMultiplier.div(10**22), address(policyBook)); // 5 decimal places or zero
    }

    function getPolicyPrice(
        uint256 _epochsNumber,
        uint256 _coverTokens,
        address _holder
    )
        public
        view
        override
        returns (
            uint256 totalSeconds,
            uint256 totalPrice,
            uint256 pricePercentage
        )
    {
        require(_coverTokens >= MINUMUM_COVERAGE, "PB: Wrong cover");
        require(_epochsNumber > 0 && _epochsNumber <= MAXIMUM_EPOCHS, "PB: Wrong epoch duration");

        (uint256 newTotalCoverTokens, uint256 newTotalLiquidity) =
            policyBook.getNewCoverAndLiquidity();

        totalSeconds = secondsToEndCurrentEpoch().add(_epochsNumber.sub(1).mul(EPOCH_DURATION));
        (totalPrice, pricePercentage) = policyQuote.getQuotePredefined(
            totalSeconds,
            _coverTokens,
            newTotalCoverTokens,
            newTotalLiquidity,
            totalLeveragedLiquidity,
            safePricingModel
        );

    }

    function info()
        external
        view
        override
        returns (
            string memory _symbol,
            address _insuredContract,
            IPolicyBookFabric.ContractType _contractType,
            bool _whitelisted
        )
    {
        return (
            ERC20(address(policyBook)).symbol(),
            policyBook.insuranceContractAddress(),
            policyBook.contractType(),
            policyBook.whitelisted()
        );
    }
}