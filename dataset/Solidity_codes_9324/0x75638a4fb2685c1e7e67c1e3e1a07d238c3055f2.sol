
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


interface ILeveragePortfolioView {
    function calcM(uint256 poolUR, address leveragePoolAddress) external view returns (uint256);

    function calcMaxLevFunds(ILeveragePortfolio.LevFundsFactors memory factors)
        external
        view
        returns (uint256);

    function calcBMIMultiplier(IUserLeveragePool.BMIMultiplierFactors memory factors)
        external
        view
        returns (uint256);

    function getPolicyBookFacade(address _policybookAddress)
        external
        view
        returns (IPolicyBookFacade _coveragePool);

    function calcNetMPLn(
        ILeveragePortfolio.LeveragePortfolio leveragePoolType,
        address _policyBookFacade
    ) external view returns (uint256 _netMPLn);

    function calcMaxVirtualFunds(address policyBookAddress, uint256 vStableWeight)
        external
        returns (uint256 _amountToDeploy, uint256 _maxAmount);

    function calcvStableFormulaforAllPools() external view returns (uint256);
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






contract CapitalPool is ICapitalPool, OwnableUpgradeable, AbstractDependant {
    using SafeERC20 for ERC20;
    using SafeMath for uint256;
    using Math for uint256;

    uint256 public constant ADDITIONAL_WITHDRAW_PERIOD = 1 days;

    IClaimingRegistry public claimingRegistry;
    IPolicyBookRegistry public policyBookRegistry;
    IYieldGenerator public yieldGenerator;
    ILeveragePortfolio public reinsurancePool;
    ILiquidityRegistry public liquidityRegistry;
    ILeveragePortfolioView public leveragePortfolioView;
    ERC20 public stblToken;

    uint256 public reinsurancePoolBalance;
    mapping(address => uint256) public leveragePoolBalance;
    mapping(address => uint256) public regularCoverageBalance;
    uint256 public hardUsdtAccumulatedBalance;
    uint256 public override virtualUsdtAccumulatedBalance;
    uint256 public override liquidityCushionBalance;
    address public maintainer;

    uint256 public stblDecimals;

    bool public isLiqCushionPaused;
    bool public automaticHardRebalancing;

    uint256 public override rebalanceDuration;
    bool private deployFundsToDefi;

    event PoolBalancesUpdated(
        uint256 hardUsdtAccumulatedBalance,
        uint256 virtualUsdtAccumulatedBalance,
        uint256 liquidityCushionBalance,
        uint256 reinsurancePoolBalance
    );

    event LiquidityCushionRebalanced(
        uint256 liquidityNeede,
        uint256 liquidityWithdraw,
        uint256 liquidityDeposit
    );

    modifier broadcastBalancing() {
        _;
        emit PoolBalancesUpdated(
            hardUsdtAccumulatedBalance,
            virtualUsdtAccumulatedBalance,
            liquidityCushionBalance,
            reinsurancePoolBalance
        );
    }

    modifier onlyPolicyBook() {
        require(policyBookRegistry.isPolicyBook(msg.sender), "CAPL: Not a PolicyBook");
        _;
    }

    modifier onlyReinsurancePool() {
        require(
            address(reinsurancePool) == _msgSender(),
            "RP: Caller is not a reinsurance pool contract"
        );
        _;
    }

    modifier onlyClaimingRegistry() {
        require(
            address(claimingRegistry) == _msgSender(),
            "CP: Caller is not claiming registry contract"
        );
        _;
    }

    modifier onlyMaintainer() {
        require(_msgSender() == maintainer, "CP: not maintainer");
        _;
    }

    function __CapitalPool_init() external initializer {
        __Ownable_init();
        maintainer = _msgSender();
        rebalanceDuration = 3 days;
        deployFundsToDefi = true;
    }

    function setDependencies(IContractsRegistry _contractsRegistry)
        external
        override
        onlyInjectorOrZero
    {
        claimingRegistry = IClaimingRegistry(_contractsRegistry.getClaimingRegistryContract());
        policyBookRegistry = IPolicyBookRegistry(
            _contractsRegistry.getPolicyBookRegistryContract()
        );
        stblToken = ERC20(_contractsRegistry.getUSDTContract());
        yieldGenerator = IYieldGenerator(_contractsRegistry.getYieldGeneratorContract());
        reinsurancePool = ILeveragePortfolio(_contractsRegistry.getReinsurancePoolContract());
        liquidityRegistry = ILiquidityRegistry(_contractsRegistry.getLiquidityRegistryContract());
        leveragePortfolioView = ILeveragePortfolioView(
            _contractsRegistry.getLeveragePortfolioViewContract()
        );
        stblDecimals = stblToken.decimals();
    }

    function addPolicyHoldersHardSTBL(
        uint256 _stblAmount,
        uint256 _epochsNumber,
        uint256 _protocolFee
    ) external override onlyPolicyBook broadcastBalancing returns (uint256) {
        PremiumFactors memory factors;

        factors.vStblOfCP = regularCoverageBalance[_msgSender()];
        factors.premiumPrice = _stblAmount.sub(_protocolFee);

        factors.policyBookFacade = IPolicyBookFacade(IPolicyBook(_msgSender()).policyBookFacade());

        factors.vStblDeployedByRP = DecimalsConverter.convertFrom18(
            factors.policyBookFacade.VUreinsurnacePool(),
            stblDecimals
        );

        factors.userLeveragePoolsCount = factors.policyBookFacade.countUserLeveragePools();
        factors.epochsNumber = _epochsNumber;

        uint256 reinsurancePoolPremium;
        uint256 coveragePoolPremium;

        if (factors.vStblDeployedByRP == 0 && factors.userLeveragePoolsCount == 0) {
            coveragePoolPremium = factors.premiumPrice;
        } else {
            (reinsurancePoolPremium, coveragePoolPremium) = _calcPremiumForAllPools(factors);
        }

        uint256 reinsurancePoolTotalPremium = reinsurancePoolPremium.add(_protocolFee);
        reinsurancePoolBalance = reinsurancePoolBalance.add(reinsurancePoolTotalPremium);
        reinsurancePool.addPolicyPremium(
            _epochsNumber,
            DecimalsConverter.convertTo18(reinsurancePoolTotalPremium, stblDecimals)
        );

        regularCoverageBalance[_msgSender()] = regularCoverageBalance[_msgSender()].add(
            coveragePoolPremium
        );
        hardUsdtAccumulatedBalance = hardUsdtAccumulatedBalance.add(_stblAmount);
        virtualUsdtAccumulatedBalance = virtualUsdtAccumulatedBalance.add(_stblAmount);
        return DecimalsConverter.convertTo18(coveragePoolPremium, stblDecimals);
    }

    function _calcPremiumForAllPools(PremiumFactors memory factors)
        internal
        returns (uint256 reinsurancePoolPremium, uint256 coveragePoolPremium)
    {
        uint256 _totalCoverTokens =
            DecimalsConverter.convertFrom18(
                (IPolicyBook(_msgSender())).totalCoverTokens(),
                stblDecimals
            );

        factors.poolUtilizationRation = _totalCoverTokens.mul(PERCENTAGE_100).div(
            factors.vStblOfCP
        );

        uint256 _participatedLeverageAmounts;

        if (factors.userLeveragePoolsCount > 0) {
            address[] memory _userLeverageArr =
                factors.policyBookFacade.listUserLeveragePools(0, factors.userLeveragePoolsCount);

            for (uint256 i = 0; i < _userLeverageArr.length; i++) {
                _participatedLeverageAmounts = _participatedLeverageAmounts.add(
                    clacParticipatedLeverageAmount(factors, _userLeverageArr[i])
                );
            }
        }
        uint256 totalLiqforPremium =
            factors.vStblOfCP.add(factors.vStblDeployedByRP).add(_participatedLeverageAmounts);

        factors.premiumPerDeployment = (factors.premiumPrice.mul(PRECISION)).div(
            totalLiqforPremium
        );

        reinsurancePoolPremium = _calcReinsurancePoolPremium(factors);

        if (factors.userLeveragePoolsCount > 0) {
            _calcUserLeveragePoolPremium(factors);
        }
        coveragePoolPremium = _calcCoveragePoolPremium(factors);
    }

    function addCoverageProvidersHardSTBL(uint256 _stblAmount)
        external
        override
        onlyPolicyBook
        broadcastBalancing
    {
        regularCoverageBalance[_msgSender()] = regularCoverageBalance[_msgSender()].add(
            _stblAmount
        );
        hardUsdtAccumulatedBalance = hardUsdtAccumulatedBalance.add(_stblAmount);
        virtualUsdtAccumulatedBalance = virtualUsdtAccumulatedBalance.add(_stblAmount);
    }

    function addLeverageProvidersHardSTBL(uint256 _stblAmount)
        external
        override
        onlyPolicyBook
        broadcastBalancing
    {
        leveragePoolBalance[_msgSender()] = leveragePoolBalance[_msgSender()].add(_stblAmount);
        hardUsdtAccumulatedBalance = hardUsdtAccumulatedBalance.add(_stblAmount);
        virtualUsdtAccumulatedBalance = virtualUsdtAccumulatedBalance.add(_stblAmount);
    }

    function addReinsurancePoolHardSTBL(uint256 _stblAmount)
        external
        override
        onlyReinsurancePool
        broadcastBalancing
    {
        reinsurancePoolBalance = reinsurancePoolBalance.add(_stblAmount);
        hardUsdtAccumulatedBalance = hardUsdtAccumulatedBalance.add(_stblAmount);
        virtualUsdtAccumulatedBalance = virtualUsdtAccumulatedBalance.add(_stblAmount);
    }

    function rebalanceLiquidityCushion() public override broadcastBalancing onlyMaintainer {
        require(!isLiqCushionPaused, "CP: liqudity cushion is pasued");

        (, uint256 _lostAmount) = yieldGenerator.reevaluateDefiProtocolBalances();

        if (_lostAmount > 0) {
            isLiqCushionPaused = true;
            if (automaticHardRebalancing) {
                defiHardRebalancing();
            }
        }

        if (isLiqCushionPaused) {
            hardUsdtAccumulatedBalance = hardUsdtAccumulatedBalance.add(liquidityCushionBalance);
            liquidityCushionBalance = 0;
            return;
        }

        uint256 _pendingClaimAmount = claimingRegistry.getAllPendingClaimsAmount();
        uint256 _pendingRewardAmount = claimingRegistry.getAllPendingRewardsAmount();

        uint256 _pendingWithdrawlAmount =
            liquidityRegistry.getAllPendingWithdrawalRequestsAmount();

        uint256 _requiredLiquidity =
            _pendingWithdrawlAmount.add(_pendingClaimAmount).add(_pendingRewardAmount);

        _requiredLiquidity = DecimalsConverter.convertFrom18(_requiredLiquidity, stblDecimals);

        (uint256 _deposit, uint256 _withdraw) = getDepositAndWithdraw(_requiredLiquidity);

        liquidityCushionBalance = _requiredLiquidity;

        hardUsdtAccumulatedBalance = 0;

        uint256 _actualAmount;
        if (_deposit > 0) {
            stblToken.safeApprove(address(yieldGenerator), 0);
            stblToken.safeApprove(address(yieldGenerator), _deposit);

            _actualAmount = yieldGenerator.deposit(_deposit);
            if (_actualAmount < _deposit) {
                hardUsdtAccumulatedBalance = hardUsdtAccumulatedBalance.add(
                    (_deposit.sub(_actualAmount))
                );
            }
        } else if (_withdraw > 0) {
            _actualAmount = yieldGenerator.withdraw(_withdraw);
            if (_actualAmount < _withdraw) {
                liquidityCushionBalance = liquidityCushionBalance.sub(
                    (_withdraw.sub(_actualAmount))
                );
            }
        }

        emit LiquidityCushionRebalanced(_requiredLiquidity, _withdraw, _deposit);
    }

    function setRebalanceDuration(uint256 _rebalanceDuration) public onlyOwner {
        require(_rebalanceDuration <= 7 days, "CP: invalid rebalance duration");
        rebalanceDuration = _rebalanceDuration;
    }

    function defiHardRebalancing() public onlyOwner {
        (uint256 _totalDeposit, uint256 _lostAmount) =
            yieldGenerator.reevaluateDefiProtocolBalances();

        if (_lostAmount > 0 && _totalDeposit > _lostAmount) {
            uint256 _lostPercentage =
                _lostAmount.mul(PERCENTAGE_100).div(virtualUsdtAccumulatedBalance);

            address[] memory _policyBooksArr =
                policyBookRegistry.list(0, policyBookRegistry.count());
            for (uint256 i = 0; i < _policyBooksArr.length; i++) {
                if (policyBookRegistry.isUserLeveragePool(_policyBooksArr[i])) continue;

                _updatePoolLiquidity(_policyBooksArr[i], 0, _lostPercentage, PoolType.COVERAGE);
            }

            address[] memory _userLeverageArr =
                policyBookRegistry.listByType(
                    IPolicyBookFabric.ContractType.VARIOUS,
                    0,
                    policyBookRegistry.countByType(IPolicyBookFabric.ContractType.VARIOUS)
                );

            for (uint256 i = 0; i < _userLeverageArr.length; i++) {
                _updatePoolLiquidity(_userLeverageArr[i], 0, _lostPercentage, PoolType.LEVERAGE);
            }
            yieldGenerator.defiHardRebalancing();
        }
    }

    function _updatePoolLiquidity(
        address _poolAddress,
        uint256 _lostAmount,
        uint256 _lostPercentage,
        PoolType poolType
    ) internal {
        IPolicyBook _pool = IPolicyBook(_poolAddress);

        if (_lostPercentage > 0) {
            uint256 _currentLiquidity = _pool.totalLiquidity();
            _lostAmount = _currentLiquidity.mul(_lostPercentage).div(PERCENTAGE_100);
        }
        _pool.updateLiquidity(_lostAmount);

        uint256 _stblLostAmount = DecimalsConverter.convertFrom18(_lostAmount, stblDecimals);

        if (poolType == PoolType.COVERAGE) {
            regularCoverageBalance[_poolAddress] = regularCoverageBalance[_poolAddress].sub(
                _stblLostAmount
            );
        } else if (poolType == PoolType.LEVERAGE) {
            leveragePoolBalance[_poolAddress] = leveragePoolBalance[_poolAddress].sub(
                _stblLostAmount
            );
        } else if (poolType == PoolType.REINSURANCE) {
            reinsurancePoolBalance = reinsurancePoolBalance.sub(_stblLostAmount);
        }

        if (_lostPercentage > 0) {
            virtualUsdtAccumulatedBalance = virtualUsdtAccumulatedBalance.sub(_stblLostAmount);
        }
    }

    function fundClaim(
        address _claimer,
        uint256 _stblClaimAmount,
        address _policyBookAddress
    ) external override onlyClaimingRegistry returns (uint256 _actualAmount) {
        _actualAmount = _withdrawFromLiquidityCushion(_claimer, _stblClaimAmount);

        _dispatchLiquidities(
            _policyBookAddress,
            DecimalsConverter.convertTo18(_actualAmount, stblDecimals)
        );
    }

    function _dispatchLiquidities(address _policyBookAddress, uint256 _claimAmount) internal {
        IPolicyBook policyBook = IPolicyBook(_policyBookAddress);
        IPolicyBookFacade policyBookFacade = policyBook.policyBookFacade();

        uint256 totalCoveragedLiquidity = policyBook.totalLiquidity();
        uint256 totalLeveragedLiquidity = policyBookFacade.totalLeveragedLiquidity();
        uint256 totalPoolLiquidity = totalCoveragedLiquidity.add(totalLeveragedLiquidity);

        uint256 coverageContribution =
            totalCoveragedLiquidity.mul(PERCENTAGE_100).div(totalPoolLiquidity);
        uint256 coverageLoss = _claimAmount.mul(coverageContribution).div(PERCENTAGE_100);
        _updatePoolLiquidity(_policyBookAddress, coverageLoss, 0, PoolType.COVERAGE);

        address[] memory _userLeverageArr =
            policyBookFacade.listUserLeveragePools(0, policyBookFacade.countUserLeveragePools());
        for (uint256 i = 0; i < _userLeverageArr.length; i++) {
            uint256 leverageContribution =
                policyBookFacade.LUuserLeveragePool(_userLeverageArr[i]).mul(PERCENTAGE_100).div(
                    totalPoolLiquidity
                );
            uint256 leverageLoss = _claimAmount.mul(leverageContribution).div(PERCENTAGE_100);
            _updatePoolLiquidity(_userLeverageArr[i], leverageLoss, 0, PoolType.LEVERAGE);
        }

        uint256 reinsuranceContribution =
            (policyBookFacade.LUreinsurnacePool().add(policyBookFacade.VUreinsurnacePool()))
                .mul(PERCENTAGE_100)
                .div(totalPoolLiquidity);
        uint256 reinsuranceLoss = _claimAmount.mul(reinsuranceContribution).div(PERCENTAGE_100);
        _updatePoolLiquidity(address(reinsurancePool), reinsuranceLoss, 0, PoolType.REINSURANCE);
    }

    function fundReward(address _voter, uint256 _stblRewardAmount)
        external
        override
        onlyClaimingRegistry
        returns (uint256 _actualAmount)
    {
        _actualAmount = _withdrawFromLiquidityCushion(_voter, _stblRewardAmount);

        _updatePoolLiquidity(
            address(reinsurancePool),
            DecimalsConverter.convertTo18(_actualAmount, stblDecimals),
            0,
            PoolType.REINSURANCE
        );
    }

    function withdrawLiquidity(
        address _sender,
        uint256 _stblAmount,
        bool _isLeveragePool
    ) external override onlyPolicyBook broadcastBalancing returns (uint256 _actualAmount) {
        _actualAmount = _withdrawFromLiquidityCushion(_sender, _stblAmount);

        if (_isLeveragePool) {
            leveragePoolBalance[_msgSender()] = leveragePoolBalance[_msgSender()].sub(
                _actualAmount
            );
        } else {
            regularCoverageBalance[_msgSender()] = regularCoverageBalance[_msgSender()].sub(
                _actualAmount
            );
        }
    }

    function setMaintainer(address _newMainteiner) public onlyOwner {
        require(_newMainteiner != address(0), "CP: invalid maintainer address");
        maintainer = _newMainteiner;
    }

    function pauseLiquidityCushionRebalancing(bool _paused) public onlyOwner {
        require(_paused != isLiqCushionPaused, "CP: invalid paused state");

        isLiqCushionPaused = _paused;

        if (isLiqCushionPaused) {
            hardUsdtAccumulatedBalance = hardUsdtAccumulatedBalance.add(liquidityCushionBalance);
            liquidityCushionBalance = 0;
        }
    }

    function automateHardRebalancing(bool _isAutomatic) public onlyOwner {
        require(_isAutomatic != automaticHardRebalancing, "CP: invalid state");

        automaticHardRebalancing = _isAutomatic;
    }

    function allowDeployFundsToDefi(bool _deployFundsToDefi) public onlyOwner {
        require(_deployFundsToDefi != deployFundsToDefi, "CP: invalid input");

        if (!_deployFundsToDefi) {
            require(yieldGenerator.totalDeposit() == 0, "CP: Can't disable deploy funds");
        }

        deployFundsToDefi = _deployFundsToDefi;

        if (isLiqCushionPaused != !deployFundsToDefi) {
            pauseLiquidityCushionRebalancing(!deployFundsToDefi);
        }
    }

    function _withdrawFromLiquidityCushion(address _sender, uint256 _stblAmount)
        internal
        broadcastBalancing
        returns (uint256 _actualAmount)
    {
        if (!deployFundsToDefi) {
            require(hardUsdtAccumulatedBalance >= _stblAmount, "CP: insuficient liquidity");
            hardUsdtAccumulatedBalance = hardUsdtAccumulatedBalance.sub(_stblAmount);
            _actualAmount = _stblAmount;
        } else {
            require(!isLiqCushionPaused, "CP: withdraw is pasued");

            if (_stblAmount > liquidityCushionBalance) {
                uint256 _diffAmount = _stblAmount.sub(liquidityCushionBalance);
                if (hardUsdtAccumulatedBalance >= _diffAmount) {
                    hardUsdtAccumulatedBalance = hardUsdtAccumulatedBalance.sub(_diffAmount);
                    liquidityCushionBalance = liquidityCushionBalance.add(_diffAmount);
                } else if (hardUsdtAccumulatedBalance > 0) {
                    liquidityCushionBalance = liquidityCushionBalance.add(
                        hardUsdtAccumulatedBalance
                    );
                    hardUsdtAccumulatedBalance = 0;
                }
            }
            require(liquidityCushionBalance > 0, "CP: insuficient liquidity");

            _actualAmount = Math.min(_stblAmount, liquidityCushionBalance);

            liquidityCushionBalance = liquidityCushionBalance.sub(_actualAmount);
        }

        virtualUsdtAccumulatedBalance = virtualUsdtAccumulatedBalance.sub(_actualAmount);

        stblToken.safeTransfer(_sender, _actualAmount);
    }

    function _calcReinsurancePoolPremium(PremiumFactors memory factors)
        internal
        pure
        returns (uint256)
    {
        return (factors.premiumPerDeployment.mul(factors.vStblDeployedByRP).div(PRECISION));
    }

    function _calcUserLeveragePoolPremium(PremiumFactors memory factors) internal {
        address[] memory _userLeverageArr =
            factors.policyBookFacade.listUserLeveragePools(0, factors.userLeveragePoolsCount);

        uint256 premium;
        uint256 _participatedLeverageAmount;
        for (uint256 i = 0; i < _userLeverageArr.length; i++) {
            _participatedLeverageAmount = clacParticipatedLeverageAmount(
                factors,
                _userLeverageArr[i]
            );
            premium = (
                factors.premiumPerDeployment.mul(_participatedLeverageAmount).div(PRECISION)
            );

            leveragePoolBalance[_userLeverageArr[i]] = leveragePoolBalance[_userLeverageArr[i]]
                .add(premium);
            ILeveragePortfolio(_userLeverageArr[i]).addPolicyPremium(
                factors.epochsNumber,
                DecimalsConverter.convertTo18(premium, stblDecimals)
            );
        }
    }

    function clacParticipatedLeverageAmount(
        PremiumFactors memory factors,
        address userLeveragePool
    ) internal view returns (uint256) {
        return
            DecimalsConverter
                .convertFrom18(
                factors.policyBookFacade.LUuserLeveragePool(userLeveragePool),
                stblDecimals
            )
                .mul(leveragePortfolioView.calcM(factors.poolUtilizationRation, userLeveragePool))
                .div(PERCENTAGE_100);
    }

    function _calcCoveragePoolPremium(PremiumFactors memory factors)
        internal
        pure
        returns (uint256)
    {
        return factors.premiumPerDeployment.mul(factors.vStblOfCP).div(PRECISION);
    }

    function getDepositAndWithdraw(uint256 _requiredLiquidity)
        internal
        view
        returns (uint256 deposit, uint256 withdraw)
    {
        uint256 _availableBalance = hardUsdtAccumulatedBalance.add(liquidityCushionBalance);

        if (_requiredLiquidity > _availableBalance) {
            withdraw = _requiredLiquidity.sub(_availableBalance);
        } else if (_requiredLiquidity < _availableBalance) {
            deposit = _availableBalance.sub(_requiredLiquidity);
        }
    }

    function getWithdrawPeriod() external view override returns (uint256) {
        return rebalanceDuration + ADDITIONAL_WITHDRAW_PERIOD;
    }
}