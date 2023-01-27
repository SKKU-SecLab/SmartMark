
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

pragma solidity ^0.7.0;


library SafeERC20 {
    using SafeMath for uint256;
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
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
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
pragma experimental ABIEncoderV2;

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

interface IYieldGenerator {
    enum DefiProtocols {DefiProtocol1, DefiProtocol2, DefiProtocol3}
    enum Networks {ETH, BSC, POL}

    struct DefiProtocol {
        uint256 targetAllocation;
        uint256 currentAllocation;
        uint256 rebalanceWeight;
        uint256 depositedAmount;
        bool whiteListed;
        bool threshold;
        bool withdrawMax;
        uint256 totalValue;
        uint256 depositCost;
    }

    function totalDeposit() external returns (uint256);

    function protocolsNumber() external returns (uint256);

    function deposit(uint256 amount) external returns (uint256);

    function withdraw(uint256 amount) external returns (uint256);

    function setProtocolSettings(
        bool[] calldata whitelisted,
        uint256[] calldata allocations,
        uint256[] calldata depositCost
    ) external;

    function claimRewards() external;

    function defiProtocol(uint256 index)
        external
        view
        returns (
            uint256 _targetAllocation,
            uint256 _currentAllocation,
            uint256 _rebalanceWeight,
            uint256 _depositedAmount,
            bool _whiteListed,
            bool _threshold,
            uint256 _totalValue,
            uint256 _depositCost
        );

    function reevaluateDefiProtocolBalances()
        external
        returns (uint256 _totalDeposit, uint256 _lostAmount);

    function defiHardRebalancing() external;
}// MIT
pragma solidity ^0.7.4;


interface IDefiProtocol {
    function totalValue() external view returns (uint256);

    function stablecoin() external view returns (ERC20);

    function deposit(uint256 amount) external;

    function withdraw(uint256 amountInUnderlying) external returns (uint256 actualAmountWithdrawn);

    function claimRewards() external;

    function setRewards(address newValue) external;

    function getOneDayGain() external view returns (uint256);

    function updateTotalValue() external returns (uint256);

    function updateTotalDeposit(uint256 _lostAmount) external;
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





contract YieldGenerator is IYieldGenerator, OwnableUpgradeable, AbstractDependant {
    using SafeERC20 for ERC20;
    using SafeMath for uint256;
    using Math for uint256;

    uint256 public constant ETH_PROTOCOLS_NUMBER = 3;
    uint256 public constant BSC_PROTOCOLS_NUMBER = 0;
    uint256 public constant POL_PROTOCOLS_NUMBER = 0;

    ERC20 public stblToken;
    ICapitalPool public capitalPool;

    uint256 public override totalDeposit;
    uint256 public whitelistedProtocols;

    mapping(uint256 => DefiProtocol) internal defiProtocols;
    mapping(uint256 => address) public defiProtocolsAddresses;
    uint256[] internal availableProtocols;
    uint256[] internal _selectedProtocols;

    uint256 public override protocolsNumber;

    event DefiDeposited(
        uint256 indexed protocolIndex,
        uint256 amount,
        uint256 depositedPercentage
    );
    event DefiWithdrawn(uint256 indexed protocolIndex, uint256 amount, uint256 withdrawPercentage);

    modifier onlyCapitalPool() {
        require(_msgSender() == address(capitalPool), "YG: Not a capital pool contract");
        _;
    }

    modifier updateDefiProtocols(uint256 amount, bool isDeposit) {
        _updateDefiProtocols(amount, isDeposit);
        _;
    }

    function __YieldGenerator_init(Networks _network) external initializer {
        __Ownable_init();

        uint256 networkIndex = uint256(_network);
        if (networkIndex == uint256(Networks.ETH)) {
            protocolsNumber = ETH_PROTOCOLS_NUMBER;
        } else if (networkIndex == uint256(Networks.BSC)) {
            protocolsNumber = BSC_PROTOCOLS_NUMBER;
        } else if (networkIndex == uint256(Networks.POL)) {
            protocolsNumber = POL_PROTOCOLS_NUMBER;
        }
    }

    function setDependencies(IContractsRegistry _contractsRegistry)
        external
        override
        onlyInjectorOrZero
    {
        stblToken = ERC20(_contractsRegistry.getUSDTContract());
        capitalPool = ICapitalPool(_contractsRegistry.getCapitalPoolContract());
        if (protocolsNumber >= 1) {
            defiProtocolsAddresses[uint256(DefiProtocols.DefiProtocol1)] = _contractsRegistry
                .getDefiProtocol1Contract();
        }
        if (protocolsNumber >= 2) {
            defiProtocolsAddresses[uint256(DefiProtocols.DefiProtocol2)] = _contractsRegistry
                .getDefiProtocol2Contract();
        }
        if (protocolsNumber >= 3) {
            defiProtocolsAddresses[uint256(DefiProtocols.DefiProtocol3)] = _contractsRegistry
                .getDefiProtocol3Contract();
        }
    }

    function deposit(uint256 amount) external override onlyCapitalPool returns (uint256) {
        if (amount == 0 && _getCurrentvSTBLVolume() == 0) return 0;
        return _aggregateDepositWithdrawFunction(amount, true);
    }

    function withdraw(uint256 amount) external override onlyCapitalPool returns (uint256) {
        if (amount == 0 && _getCurrentvSTBLVolume() == 0) return 0;
        return _aggregateDepositWithdrawFunction(amount, false);
    }

    function updateProtocolNumbers(uint256 _protocolsNumber) external onlyOwner {
        require(_protocolsNumber > 0 && _protocolsNumber <= 5, "YG: protocol number is invalid");

        protocolsNumber = _protocolsNumber;
    }

    function setProtocolSettings(
        bool[] calldata whitelisted,
        uint256[] calldata allocations,
        uint256[] calldata depositCost
    ) external override onlyOwner {
        require(
            whitelisted.length == protocolsNumber &&
                allocations.length == protocolsNumber &&
                depositCost.length == protocolsNumber,
            "YG: Invlaid arr length"
        );

        whitelistedProtocols = 0;
        bool _whiteListed;
        for (uint256 i = 0; i < protocolsNumber; i++) {
            _whiteListed = whitelisted[i];

            if (_whiteListed) {
                whitelistedProtocols = whitelistedProtocols.add(1);
            }

            defiProtocols[i].targetAllocation = allocations[i];

            defiProtocols[i].whiteListed = _whiteListed;
            defiProtocols[i].depositCost = depositCost[i];
        }
    }

    function claimRewards() external override onlyOwner {
        for (uint256 i = 0; i < protocolsNumber; i++) {
            IDefiProtocol(defiProtocolsAddresses[i]).claimRewards();
        }
    }

    function getOneDayGain(uint256 index) public view returns (uint256) {
        return IDefiProtocol(defiProtocolsAddresses[index]).getOneDayGain();
    }

    function defiProtocol(uint256 index)
        external
        view
        override
        returns (
            uint256 _targetAllocation,
            uint256 _currentAllocation,
            uint256 _rebalanceWeight,
            uint256 _depositedAmount,
            bool _whiteListed,
            bool _threshold,
            uint256 _totalValue,
            uint256 _depositCost
        )
    {
        _targetAllocation = defiProtocols[index].targetAllocation;
        _currentAllocation = _calcProtocolCurrentAllocation(index);
        _rebalanceWeight = defiProtocols[index].rebalanceWeight;
        _depositedAmount = defiProtocols[index].depositedAmount;
        _whiteListed = defiProtocols[index].whiteListed;
        _threshold = defiProtocols[index].threshold;
        _totalValue = IDefiProtocol(defiProtocolsAddresses[index]).totalValue();
        _depositCost = defiProtocols[index].depositCost;
    }

    function _aggregateDepositWithdrawFunction(uint256 amount, bool isDeposit)
        internal
        updateDefiProtocols(amount, isDeposit)
        returns (uint256 _actualAmount)
    {
        if (availableProtocols.length == 0) {
            return _actualAmount;
        }

        uint256 _protocolsNo = _howManyProtocols(amount, isDeposit);
        if (_protocolsNo == 1) {
            _actualAmount = _aggregateDepositWithdrawFunctionForOneProtocol(amount, isDeposit);
        } else if (_protocolsNo > 1) {
            delete _selectedProtocols;

            uint256 _totalWeight = _calcTotalWeight(_protocolsNo, isDeposit);

            if (_selectedProtocols.length > 0) {
                for (uint256 i = 0; i < _selectedProtocols.length; i++) {
                    _actualAmount = _actualAmount.add(
                        _aggregateDepositWithdrawFunctionForMultipleProtocol(
                            isDeposit,
                            amount,
                            i,
                            _totalWeight
                        )
                    );
                }
            }
        }
    }

    function _aggregateDepositWithdrawFunctionForOneProtocol(uint256 amount, bool isDeposit)
        internal
        returns (uint256 _actualAmount)
    {
        uint256 _protocolIndex;
        if (isDeposit) {
            _protocolIndex = _getProtocolOfMaxWeight();
            _depoist(_protocolIndex, amount, PERCENTAGE_100);
            _actualAmount = amount;
        } else {
            _protocolIndex = _getProtocolOfMinWeight();
            _actualAmount = _withdraw(_protocolIndex, amount, PERCENTAGE_100);
        }
    }

    function _aggregateDepositWithdrawFunctionForMultipleProtocol(
        bool isDeposit,
        uint256 amount,
        uint256 index,
        uint256 _totalWeight
    ) internal returns (uint256 _actualAmount) {
        uint256 _protocolRebalanceAllocation =
            _calcRebalanceAllocation(_selectedProtocols[index], _totalWeight);

        if (isDeposit) {
            uint256 _depoistedAmount =
                amount.mul(_protocolRebalanceAllocation).div(PERCENTAGE_100);
            _depoist(_selectedProtocols[index], _depoistedAmount, _protocolRebalanceAllocation);
            _actualAmount = _depoistedAmount;
        } else {
            _actualAmount = _withdraw(
                _selectedProtocols[index],
                amount.mul(_protocolRebalanceAllocation).div(PERCENTAGE_100),
                _protocolRebalanceAllocation
            );
        }
    }

    function _calcTotalWeight(uint256 _protocolsNo, bool isDeposit)
        internal
        returns (uint256 _totalWeight)
    {
        uint256 _protocolIndex;
        for (uint256 i = 0; i < _protocolsNo; i++) {
            if (availableProtocols.length == 0) {
                break;
            }
            if (isDeposit) {
                _protocolIndex = _getProtocolOfMaxWeight();
            } else {
                _protocolIndex = _getProtocolOfMinWeight();
            }
            _totalWeight = _totalWeight.add(defiProtocols[_protocolIndex].rebalanceWeight);
            _selectedProtocols.push(_protocolIndex);
        }
    }

    function _depoist(
        uint256 _protocolIndex,
        uint256 _amount,
        uint256 _depositedPercentage
    ) internal {
        stblToken.safeTransferFrom(_msgSender(), defiProtocolsAddresses[_protocolIndex], _amount);

        IDefiProtocol(defiProtocolsAddresses[_protocolIndex]).deposit(_amount);

        defiProtocols[_protocolIndex].depositedAmount = defiProtocols[_protocolIndex]
            .depositedAmount
            .add(_amount);

        totalDeposit = totalDeposit.add(_amount);

        emit DefiDeposited(_protocolIndex, _amount, _depositedPercentage);
    }

    function _withdraw(
        uint256 _protocolIndex,
        uint256 _amount,
        uint256 _withdrawnPercentage
    ) internal returns (uint256) {
        uint256 _actualAmountWithdrawn;
        uint256 allocatedFunds = defiProtocols[_protocolIndex].depositedAmount;

        if (allocatedFunds == 0) return _actualAmountWithdrawn;

        if (allocatedFunds < _amount) {
            _amount = allocatedFunds;
        }

        _actualAmountWithdrawn = IDefiProtocol(defiProtocolsAddresses[_protocolIndex]).withdraw(
            _amount
        );

        defiProtocols[_protocolIndex].depositedAmount = defiProtocols[_protocolIndex]
            .depositedAmount
            .sub(_actualAmountWithdrawn);

        totalDeposit = totalDeposit.sub(_actualAmountWithdrawn);

        emit DefiWithdrawn(_protocolIndex, _actualAmountWithdrawn, _withdrawnPercentage);

        return _actualAmountWithdrawn;
    }

    function _howManyProtocols(uint256 rebalanceAmount, bool isDeposit)
        internal
        view
        returns (uint256)
    {
        uint256 _no1;
        if (isDeposit) {
            _no1 = whitelistedProtocols.mul(rebalanceAmount);
        } else {
            _no1 = protocolsNumber.mul(rebalanceAmount);
        }

        uint256 _no2 = _getCurrentvSTBLVolume();

        return _no1.add(_no2 - 1).div(_no2);
    }

    function _updateDefiProtocols(uint256 amount, bool isDeposit) internal {
        delete availableProtocols;

        for (uint256 i = 0; i < protocolsNumber; i++) {
            uint256 _targetAllocation = defiProtocols[i].targetAllocation;
            uint256 _currentAllocation = _calcProtocolCurrentAllocation(i);
            uint256 _diffAllocation;

            if (isDeposit) {
                if (_targetAllocation > _currentAllocation) {
                    _diffAllocation = _targetAllocation.sub(_currentAllocation);
                } else if (_currentAllocation >= _targetAllocation) {
                    _diffAllocation = 0;
                }
                _reevaluateThreshold(i, _diffAllocation.mul(amount).div(PERCENTAGE_100));
            } else {
                if (_currentAllocation > _targetAllocation) {
                    _diffAllocation = _currentAllocation.sub(_targetAllocation);
                    defiProtocols[i].withdrawMax = true;
                } else if (_targetAllocation >= _currentAllocation) {
                    _diffAllocation = _targetAllocation.sub(_currentAllocation);
                    defiProtocols[i].withdrawMax = false;
                }
            }

            defiProtocols[i].rebalanceWeight = _diffAllocation.mul(_getCurrentvSTBLVolume()).div(
                PERCENTAGE_100
            );

            if (
                isDeposit
                    ? defiProtocols[i].rebalanceWeight > 0 &&
                        defiProtocols[i].whiteListed &&
                        defiProtocols[i].threshold
                    : _currentAllocation > 0
            ) {
                availableProtocols.push(i);
            }
        }
    }

    function _getProtocolOfMaxWeight() internal returns (uint256) {
        uint256 _largest;
        uint256 _protocolIndex;
        uint256 _indexToDelete;

        for (uint256 i = 0; i < availableProtocols.length; i++) {
            if (defiProtocols[availableProtocols[i]].rebalanceWeight > _largest) {
                _largest = defiProtocols[availableProtocols[i]].rebalanceWeight;
                _protocolIndex = availableProtocols[i];
                _indexToDelete = i;
            }
        }

        availableProtocols[_indexToDelete] = availableProtocols[availableProtocols.length - 1];
        availableProtocols.pop();

        return _protocolIndex;
    }

    function _getProtocolOfMinWeight() internal returns (uint256) {
        uint256 _maxWeight;
        for (uint256 i = 0; i < availableProtocols.length; i++) {
            if (defiProtocols[availableProtocols[i]].rebalanceWeight > _maxWeight) {
                _maxWeight = defiProtocols[availableProtocols[i]].rebalanceWeight;
            }
        }

        uint256 _smallest = _maxWeight;
        uint256 _largest;
        uint256 _maxProtocolIndex;
        uint256 _maxIndexToDelete;
        uint256 _minProtocolIndex;
        uint256 _minIndexToDelete;

        for (uint256 i = 0; i < availableProtocols.length; i++) {
            if (
                defiProtocols[availableProtocols[i]].rebalanceWeight <= _smallest &&
                !defiProtocols[availableProtocols[i]].withdrawMax
            ) {
                _smallest = defiProtocols[availableProtocols[i]].rebalanceWeight;
                _minProtocolIndex = availableProtocols[i];
                _minIndexToDelete = i;
            } else if (
                defiProtocols[availableProtocols[i]].rebalanceWeight > _largest &&
                defiProtocols[availableProtocols[i]].withdrawMax
            ) {
                _largest = defiProtocols[availableProtocols[i]].rebalanceWeight;
                _maxProtocolIndex = availableProtocols[i];
                _maxIndexToDelete = i;
            }
        }
        if (_largest > 0) {
            availableProtocols[_maxIndexToDelete] = availableProtocols[
                availableProtocols.length - 1
            ];
            availableProtocols.pop();
            return _maxProtocolIndex;
        } else {
            availableProtocols[_minIndexToDelete] = availableProtocols[
                availableProtocols.length - 1
            ];
            availableProtocols.pop();
            return _minProtocolIndex;
        }
    }

    function _calcProtocolCurrentAllocation(uint256 _protocolIndex)
        internal
        view
        returns (uint256 _currentAllocation)
    {
        uint256 _depositedAmount = defiProtocols[_protocolIndex].depositedAmount;
        uint256 _currentvSTBLVolume = _getCurrentvSTBLVolume();
        if (_currentvSTBLVolume > 0) {
            _currentAllocation = _depositedAmount.mul(PERCENTAGE_100).div(_currentvSTBLVolume);
        }
    }

    function _calcRebalanceAllocation(uint256 _protocolIndex, uint256 _totalWeight)
        internal
        view
        returns (uint256)
    {
        return defiProtocols[_protocolIndex].rebalanceWeight.mul(PERCENTAGE_100).div(_totalWeight);
    }

    function _getCurrentvSTBLVolume() internal view returns (uint256) {
        return
            capitalPool.virtualUsdtAccumulatedBalance().sub(capitalPool.liquidityCushionBalance());
    }

    function _reevaluateThreshold(uint256 _protocolIndex, uint256 depositAmount) internal {
        uint256 _protocolOneDayGain = getOneDayGain(_protocolIndex);

        uint256 _oneDayReturn = _protocolOneDayGain.mul(depositAmount).div(PRECISION);

        uint256 _depositCost = defiProtocols[_protocolIndex].depositCost;

        if (_oneDayReturn < _depositCost) {
            defiProtocols[_protocolIndex].threshold = false;
        } else if (_oneDayReturn >= _depositCost) {
            defiProtocols[_protocolIndex].threshold = true;
        }
    }

    function reevaluateDefiProtocolBalances()
        external
        override
        returns (uint256 _totalDeposit, uint256 _lostAmount)
    {
        _totalDeposit = totalDeposit;

        uint256 _totalValue;
        uint256 _depositedAmount;
        for (uint256 index = 0; index < protocolsNumber; index++) {
            if (index == uint256(DefiProtocols.DefiProtocol2)) {
                IDefiProtocol(defiProtocolsAddresses[index]).updateTotalValue();
            }

            _totalValue = IDefiProtocol(defiProtocolsAddresses[index]).totalValue();
            _depositedAmount = defiProtocols[index].depositedAmount;

            if (_totalValue < _depositedAmount) {
                _lostAmount = _lostAmount.add((_depositedAmount.sub(_totalValue)));
            }
        }
    }

    function defiHardRebalancing() external override onlyCapitalPool {
        uint256 _totalValue;
        uint256 _depositedAmount;
        uint256 _lostAmount;
        uint256 _totalLostAmount;
        for (uint256 index = 0; index < protocolsNumber; index++) {
            _totalValue = IDefiProtocol(defiProtocolsAddresses[index]).totalValue();

            _depositedAmount = defiProtocols[index].depositedAmount;

            if (_totalValue < _depositedAmount) {
                _lostAmount = _depositedAmount.sub(_totalValue);
                defiProtocols[index].depositedAmount = _depositedAmount.sub(_lostAmount);
                IDefiProtocol(defiProtocolsAddresses[index]).updateTotalDeposit(_lostAmount);
                _totalLostAmount = _totalLostAmount.add(_lostAmount);
            }
        }

        totalDeposit = totalDeposit.sub(_totalLostAmount);
    }
}