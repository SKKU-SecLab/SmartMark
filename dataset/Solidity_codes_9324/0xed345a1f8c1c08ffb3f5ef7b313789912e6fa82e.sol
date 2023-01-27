
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


interface IPolicyRegistry {
    struct PolicyInfo {
        uint256 coverAmount;
        uint256 premium;
        uint256 startTime;
        uint256 endTime;
    }

    struct PolicyUserInfo {
        string symbol;
        address insuredContract;
        IPolicyBookFabric.ContractType contractType;
        uint256 coverTokens;
        uint256 startTime;
        uint256 endTime;
        uint256 paid;
    }

    function STILL_CLAIMABLE_FOR() external view returns (uint256);

    function getPoliciesLength(address _userAddr) external view returns (uint256);

    function policyExists(address _userAddr, address _policyBookAddr) external view returns (bool);

    function isPolicyValid(address _userAddr, address _policyBookAddr)
        external
        view
        returns (bool);

    function isPolicyActive(address _userAddr, address _policyBookAddr)
        external
        view
        returns (bool);

    function policyStartTime(address _userAddr, address _policyBookAddr)
        external
        view
        returns (uint256);

    function policyEndTime(address _userAddr, address _policyBookAddr)
        external
        view
        returns (uint256);

    function getPoliciesInfo(
        address _userAddr,
        bool _isActive,
        uint256 _offset,
        uint256 _limit
    )
        external
        view
        returns (
            uint256 _policiesCount,
            address[] memory _policyBooksArr,
            PolicyInfo[] memory _policies,
            IClaimingRegistry.ClaimStatus[] memory _policyStatuses
        );

    function getUsersInfo(address[] calldata _users, address[] calldata _policyBooks)
        external
        view
        returns (PolicyUserInfo[] memory _stats);

    function getPoliciesArr(address _userAddr) external view returns (address[] memory _arr);

    function addPolicy(
        address _userAddr,
        uint256 _coverAmount,
        uint256 _premium,
        uint256 _durationDays
    ) external;

    function removePolicy(address _userAddr) external;
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





contract ClaimingRegistry is IClaimingRegistry, Initializable, AbstractDependant {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;

    uint256 internal constant ANONYMOUS_VOTING_DURATION = 1 weeks;
    uint256 internal constant EXPOSE_VOTE_DURATION = 1 weeks;

    uint256 internal constant PRIVATE_CLAIM_DURATION = 3 days;
    uint256 internal constant VIEW_VERDICT_DURATION = 10 days;
    uint256 public constant READY_TO_WITHDRAW_PERIOD = 8 days;

    IPolicyRegistry public policyRegistry;
    address public claimVotingAddress;

    mapping(address => EnumerableSet.UintSet) internal _myClaims; // claimer -> claim indexes

    mapping(address => mapping(address => uint256)) internal _allClaimsToIndex; // book -> claimer -> index

    mapping(uint256 => ClaimInfo) internal _allClaimsByIndexInfo; // index -> info

    EnumerableSet.UintSet internal _pendingClaimsIndexes;
    EnumerableSet.UintSet internal _allClaimsIndexes;

    uint256 private _claimIndex;

    address internal policyBookAdminAddress;

    ICapitalPool public capitalPool;

    EnumerableSet.UintSet internal _withdrawClaimRequestIndexList;
    mapping(uint256 => ClaimWithdrawalInfo) public override claimWithdrawalInfo; // index -> info
    EnumerableSet.AddressSet internal _withdrawRewardRequestVoterList;
    mapping(address => RewardWithdrawalInfo) public override rewardWithdrawalInfo; // address -> info
    IClaimVoting public claimVoting;
    IPolicyBookRegistry public policyBookRegistry;
    mapping(address => EnumerableSet.UintSet) internal _policyBookClaims; // book -> index
    ERC20 public stblToken;
    uint256 public stblDecimals;

    event AppealPending(address claimer, address policyBookAddress, uint256 claimIndex);
    event ClaimPending(address claimer, address policyBookAddress, uint256 claimIndex);
    event ClaimAccepted(
        address claimer,
        address policyBookAddress,
        uint256 claimAmount,
        uint256 claimIndex
    );
    event ClaimRejected(address claimer, address policyBookAddress, uint256 claimIndex);
    event ClaimExpired(address claimer, address policyBookAddress, uint256 claimIndex);
    event AppealRejected(address claimer, address policyBookAddress, uint256 claimIndex);
    event WithdrawalRequested(
        address _claimer,
        uint256 _claimRefundAmount,
        uint256 _readyToWithdrawDate
    );
    event ClaimWithdrawn(address _claimer, uint256 _claimRefundAmount);
    event RewardWithdrawn(address _voter, uint256 _rewardAmount);

    modifier onlyClaimVoting() {
        require(
            claimVotingAddress == msg.sender,
            "ClaimingRegistry: Caller is not a ClaimVoting contract"
        );
        _;
    }

    modifier onlyPolicyBookAdmin() {
        require(
            policyBookAdminAddress == msg.sender,
            "ClaimingRegistry: Caller is not a PolicyBookAdmin"
        );
        _;
    }

    modifier withExistingClaim(uint256 index) {
        require(claimExists(index), "ClaimingRegistry: This claim doesn't exist");
        _;
    }

    function __ClaimingRegistry_init() external initializer {
        _claimIndex = 1;
    }

    function setDependencies(IContractsRegistry _contractsRegistry)
        external
        override
        onlyInjectorOrZero
    {
        policyRegistry = IPolicyRegistry(_contractsRegistry.getPolicyRegistryContract());
        claimVotingAddress = _contractsRegistry.getClaimVotingContract();
        policyBookAdminAddress = _contractsRegistry.getPolicyBookAdminContract();
        capitalPool = ICapitalPool(_contractsRegistry.getCapitalPoolContract());
        policyBookRegistry = IPolicyBookRegistry(
            _contractsRegistry.getPolicyBookRegistryContract()
        );
        claimVoting = IClaimVoting(_contractsRegistry.getClaimVotingContract());
        stblToken = ERC20(_contractsRegistry.getUSDTContract());
        stblDecimals = stblToken.decimals();
    }

    function _isClaimAwaitingCalculation(uint256 index)
        internal
        view
        withExistingClaim(index)
        returns (bool)
    {
        return (_allClaimsByIndexInfo[index].status == ClaimStatus.PENDING &&
            _allClaimsByIndexInfo[index].dateSubmitted.add(votingDuration(index)) <=
            block.timestamp);
    }

    function _isClaimAppealExpired(uint256 index)
        internal
        view
        withExistingClaim(index)
        returns (bool)
    {
        return (_allClaimsByIndexInfo[index].status == ClaimStatus.REJECTED_CAN_APPEAL &&
            _allClaimsByIndexInfo[index].dateEnded.add(policyRegistry.STILL_CLAIMABLE_FOR()) <=
            block.timestamp);
    }

    function _isClaimExpired(uint256 index) internal view withExistingClaim(index) returns (bool) {
        return (_allClaimsByIndexInfo[index].status == ClaimStatus.PENDING &&
            _allClaimsByIndexInfo[index].dateSubmitted.add(validityDuration(index)) <=
            block.timestamp);
    }

    function anonymousVotingDuration(uint256 index)
        public
        view
        override
        withExistingClaim(index)
        returns (uint256)
    {
        return ANONYMOUS_VOTING_DURATION;
    }

    function votingDuration(uint256 index) public view override returns (uint256) {
        return anonymousVotingDuration(index).add(EXPOSE_VOTE_DURATION);
    }

    function validityDuration(uint256 index)
        public
        view
        override
        withExistingClaim(index)
        returns (uint256)
    {
        return votingDuration(index).add(VIEW_VERDICT_DURATION);
    }

    function anyoneCanCalculateClaimResultAfter(uint256 index)
        public
        view
        override
        returns (uint256)
    {
        return votingDuration(index).add(PRIVATE_CLAIM_DURATION);
    }

    function canBuyNewPolicy(address buyer, address policyBookAddress) external override {
        bool previousEnded = !policyRegistry.isPolicyActive(buyer, policyBookAddress);
        uint256 index = _allClaimsToIndex[policyBookAddress][buyer];

        require(
            (previousEnded &&
                (!claimExists(index) ||
                    (!_pendingClaimsIndexes.contains(index) &&
                        claimStatus(index) != ClaimStatus.REJECTED_CAN_APPEAL))) ||
                (!previousEnded && !claimExists(index)),
            "PB: Claim is pending"
        );

        if (!previousEnded) {
            IPolicyBook(policyBookAddress).endActivePolicy(buyer);
        }
    }

    function canWithdrawLockedBMI(uint256 index) public view returns (bool) {
        return
            (_allClaimsByIndexInfo[index].status == ClaimStatus.EXPIRED) ||
            (_allClaimsByIndexInfo[index].status == ClaimStatus.ACCEPTED &&
                _withdrawClaimRequestIndexList.contains(index) &&
                getClaimWithdrawalStatus(index) == WithdrawalStatus.EXPIRED &&
                !policyRegistry.isPolicyActive(
                    _allClaimsByIndexInfo[index].claimer,
                    _allClaimsByIndexInfo[index].policyBookAddress
                ));
    }

    function getClaimWithdrawalStatus(uint256 index)
        public
        view
        override
        returns (WithdrawalStatus)
    {
        if (claimWithdrawalInfo[index].readyToWithdrawDate == 0) {
            return WithdrawalStatus.NONE;
        }

        if (block.timestamp < claimWithdrawalInfo[index].readyToWithdrawDate) {
            return WithdrawalStatus.PENDING;
        }

        if (
            block.timestamp >=
            claimWithdrawalInfo[index].readyToWithdrawDate.add(READY_TO_WITHDRAW_PERIOD)
        ) {
            return WithdrawalStatus.EXPIRED;
        }

        return WithdrawalStatus.READY;
    }

    function getRewardWithdrawalStatus(address voter)
        public
        view
        override
        returns (WithdrawalStatus)
    {
        if (rewardWithdrawalInfo[voter].readyToWithdrawDate == 0) {
            return WithdrawalStatus.NONE;
        }

        if (block.timestamp < rewardWithdrawalInfo[voter].readyToWithdrawDate) {
            return WithdrawalStatus.PENDING;
        }

        if (
            block.timestamp >=
            rewardWithdrawalInfo[voter].readyToWithdrawDate.add(READY_TO_WITHDRAW_PERIOD)
        ) {
            return WithdrawalStatus.EXPIRED;
        }

        return WithdrawalStatus.READY;
    }

    function hasProcedureOngoing(address poolAddress) external view override returns (bool) {
        if (policyBookRegistry.isUserLeveragePool(poolAddress)) {
            ILeveragePortfolio userLeveragePool = ILeveragePortfolio(poolAddress);
            address[] memory _coveragePools =
                userLeveragePool.listleveragedCoveragePools(
                    0,
                    userLeveragePool.countleveragedCoveragePools()
                );

            for (uint256 i = 0; i < _coveragePools.length; i++) {
                if (_hasProcedureOngoing(_coveragePools[i])) {
                    return true;
                }
            }
        } else {
            if (_hasProcedureOngoing(poolAddress)) {
                return true;
            }
        }
        return false;
    }

    function _hasProcedureOngoing(address policyBookAddress)
        internal
        view
        returns (bool hasProcedure)
    {
        for (uint256 i = 0; i < _policyBookClaims[policyBookAddress].length(); i++) {
            uint256 index = _policyBookClaims[policyBookAddress].at(i);
            ClaimStatus status = claimStatus(index);
            address claimer = _allClaimsByIndexInfo[index].claimer;
            if (
                !(status == ClaimStatus.EXPIRED || // has expired
                    status == ClaimStatus.REJECTED || // has been rejected || appeal expired
                    (status == ClaimStatus.ACCEPTED &&
                        getClaimWithdrawalStatus(index) == WithdrawalStatus.NONE) || // has been accepted and withdrawn or has withdrawn locked BMI at policy end
                    (status == ClaimStatus.ACCEPTED &&
                        getClaimWithdrawalStatus(index) == WithdrawalStatus.EXPIRED &&
                        !policyRegistry.isPolicyActive(claimer, policyBookAddress))) // has been accepted and never withdrawn but cannot request withdraw anymore
            ) {
                return true;
            }
        }
    }

    function submitClaim(
        address claimer,
        address policyBookAddress,
        string calldata evidenceURI,
        uint256 cover,
        bool appeal
    ) external override onlyClaimVoting returns (uint256 _newClaimIndex) {
        uint256 index = _allClaimsToIndex[policyBookAddress][claimer];
        ClaimStatus status =
            _myClaims[claimer].contains(index) ? claimStatus(index) : ClaimStatus.CAN_CLAIM;
        bool active = policyRegistry.isPolicyActive(claimer, policyBookAddress);

        require(
            (!appeal && active && status == ClaimStatus.CAN_CLAIM) ||
                (appeal && status == ClaimStatus.REJECTED_CAN_APPEAL) ||
                (!appeal && active && status == ClaimStatus.EXPIRED) ||
                (!appeal &&
                    active &&
                    (status == ClaimStatus.REJECTED ||
                        (policyRegistry.policyStartTime(claimer, policyBookAddress) >
                            _allClaimsByIndexInfo[index].dateSubmitted &&
                            status == ClaimStatus.ACCEPTED))) ||
                (!appeal &&
                    active &&
                    status == ClaimStatus.ACCEPTED &&
                    !_withdrawClaimRequestIndexList.contains(index)),
            "ClaimingRegistry: The claimer can't submit this claim"
        );

        if (appeal) {
            _allClaimsByIndexInfo[index].status = ClaimStatus.REJECTED;
        }

        _myClaims[claimer].add(_claimIndex);

        _allClaimsToIndex[policyBookAddress][claimer] = _claimIndex;
        _policyBookClaims[policyBookAddress].add(_claimIndex);

        _allClaimsByIndexInfo[_claimIndex] = ClaimInfo(
            claimer,
            policyBookAddress,
            evidenceURI,
            block.timestamp,
            0,
            appeal,
            ClaimStatus.PENDING,
            cover,
            0
        );

        _pendingClaimsIndexes.add(_claimIndex);
        _allClaimsIndexes.add(_claimIndex);

        _newClaimIndex = _claimIndex++;

        if (!appeal) {
            emit ClaimPending(claimer, policyBookAddress, _newClaimIndex);
        } else {
            emit AppealPending(claimer, policyBookAddress, _newClaimIndex);
        }
    }

    function claimExists(uint256 index) public view override returns (bool) {
        return _allClaimsIndexes.contains(index);
    }

    function claimSubmittedTime(uint256 index) external view override returns (uint256) {
        return _allClaimsByIndexInfo[index].dateSubmitted;
    }

    function claimEndTime(uint256 index) external view override returns (uint256) {
        return _allClaimsByIndexInfo[index].dateEnded;
    }

    function isClaimAnonymouslyVotable(uint256 index) external view override returns (bool) {
        return (_pendingClaimsIndexes.contains(index) &&
            _allClaimsByIndexInfo[index].dateSubmitted.add(anonymousVotingDuration(index)) >
            block.timestamp);
    }

    function isClaimExposablyVotable(uint256 index) external view override returns (bool) {
        if (!_pendingClaimsIndexes.contains(index)) {
            return false;
        }

        uint256 dateSubmitted = _allClaimsByIndexInfo[index].dateSubmitted;
        uint256 anonymousDuration = anonymousVotingDuration(index);

        return (dateSubmitted.add(anonymousDuration.add(EXPOSE_VOTE_DURATION)) > block.timestamp &&
            dateSubmitted.add(anonymousDuration) < block.timestamp);
    }

    function isClaimVotable(uint256 index) external view override returns (bool) {
        return (_pendingClaimsIndexes.contains(index) &&
            _allClaimsByIndexInfo[index].dateSubmitted.add(votingDuration(index)) >
            block.timestamp);
    }

    function canClaimBeCalculatedByAnyone(uint256 index) external view override returns (bool) {
        return
            _allClaimsByIndexInfo[index].status == ClaimStatus.PENDING &&
            _allClaimsByIndexInfo[index].dateSubmitted.add(
                anyoneCanCalculateClaimResultAfter(index)
            ) <=
            block.timestamp;
    }

    function isClaimPending(uint256 index) external view override returns (bool) {
        return _pendingClaimsIndexes.contains(index);
    }

    function countPolicyClaimerClaims(address claimer) external view override returns (uint256) {
        return _myClaims[claimer].length();
    }

    function countPendingClaims() external view override returns (uint256) {
        return _pendingClaimsIndexes.length();
    }

    function countClaims() external view override returns (uint256) {
        return _allClaimsIndexes.length();
    }

    function claimOfOwnerIndexAt(address claimer, uint256 orderIndex)
        external
        view
        override
        returns (uint256)
    {
        return _myClaims[claimer].at(orderIndex);
    }

    function pendingClaimIndexAt(uint256 orderIndex) external view override returns (uint256) {
        return _pendingClaimsIndexes.at(orderIndex);
    }

    function claimIndexAt(uint256 orderIndex) external view override returns (uint256) {
        return _allClaimsIndexes.at(orderIndex);
    }

    function claimIndex(address claimer, address policyBookAddress)
        external
        view
        override
        returns (uint256)
    {
        return _allClaimsToIndex[policyBookAddress][claimer];
    }

    function isClaimAppeal(uint256 index) external view override returns (bool) {
        return _allClaimsByIndexInfo[index].appeal;
    }

    function policyStatus(address claimer, address policyBookAddress)
        external
        view
        override
        returns (ClaimStatus)
    {
        if (!policyRegistry.isPolicyActive(claimer, policyBookAddress)) {
            return ClaimStatus.UNCLAIMABLE;
        }

        uint256 index = _allClaimsToIndex[policyBookAddress][claimer];

        if (!_myClaims[claimer].contains(index)) {
            return ClaimStatus.CAN_CLAIM;
        }

        ClaimStatus status = claimStatus(index);
        bool newPolicyBought =
            policyRegistry.policyStartTime(claimer, policyBookAddress) >
                _allClaimsByIndexInfo[index].dateSubmitted;

        if (
            status == ClaimStatus.REJECTED ||
            status == ClaimStatus.EXPIRED ||
            (newPolicyBought && status == ClaimStatus.ACCEPTED)
        ) {
            return ClaimStatus.CAN_CLAIM;
        }

        return status;
    }

    function claimStatus(uint256 index) public view override returns (ClaimStatus) {
        if (_isClaimAppealExpired(index)) {
            return ClaimStatus.REJECTED;
        }
        if (_isClaimExpired(index)) {
            return ClaimStatus.EXPIRED;
        }
        if (_isClaimAwaitingCalculation(index)) {
            return ClaimStatus.AWAITING_CALCULATION;
        }

        return _allClaimsByIndexInfo[index].status;
    }

    function claimOwner(uint256 index) external view override returns (address) {
        return _allClaimsByIndexInfo[index].claimer;
    }

    function claimPolicyBook(uint256 index) external view override returns (address) {
        return _allClaimsByIndexInfo[index].policyBookAddress;
    }

    function claimInfo(uint256 index)
        external
        view
        override
        withExistingClaim(index)
        returns (ClaimInfo memory _claimInfo)
    {
        _claimInfo = ClaimInfo(
            _allClaimsByIndexInfo[index].claimer,
            _allClaimsByIndexInfo[index].policyBookAddress,
            _allClaimsByIndexInfo[index].evidenceURI,
            _allClaimsByIndexInfo[index].dateSubmitted,
            _allClaimsByIndexInfo[index].dateEnded,
            _allClaimsByIndexInfo[index].appeal,
            claimStatus(index),
            _allClaimsByIndexInfo[index].claimAmount,
            _allClaimsByIndexInfo[index].claimRefund
        );
    }

    function getAllPendingClaimsAmount()
        external
        view
        override
        returns (uint256 _totalClaimsAmount)
    {
        WithdrawalStatus _currentStatus;
        uint256 index;

        for (uint256 i = 0; i < _withdrawClaimRequestIndexList.length(); i++) {
            index = _withdrawClaimRequestIndexList.at(i);
            _currentStatus = getClaimWithdrawalStatus(index);

            if (
                _currentStatus == WithdrawalStatus.NONE ||
                _currentStatus == WithdrawalStatus.EXPIRED
            ) {
                continue;
            }

            if (
                block.timestamp >=
                claimWithdrawalInfo[index].readyToWithdrawDate.sub(
                    ICapitalPool(capitalPool).rebalanceDuration().add(60 * 60)
                )
            ) {
                _totalClaimsAmount = _totalClaimsAmount.add(
                    _allClaimsByIndexInfo[index].claimRefund
                );
            }
        }
    }

    function getAllPendingRewardsAmount()
        external
        view
        override
        returns (uint256 _totalRewardsAmount)
    {
        WithdrawalStatus _currentStatus;
        address voter;

        for (uint256 i = 0; i < _withdrawRewardRequestVoterList.length(); i++) {
            voter = _withdrawRewardRequestVoterList.at(i);
            _currentStatus = getRewardWithdrawalStatus(voter);

            if (
                _currentStatus == WithdrawalStatus.NONE ||
                _currentStatus == WithdrawalStatus.EXPIRED
            ) {
                continue;
            }

            if (
                block.timestamp >=
                rewardWithdrawalInfo[voter].readyToWithdrawDate.sub(
                    ICapitalPool(capitalPool).rebalanceDuration().add(60 * 60)
                )
            ) {
                _totalRewardsAmount = _totalRewardsAmount.add(
                    rewardWithdrawalInfo[voter].rewardAmount
                );
            }
        }
    }

    function getClaimableAmounts(uint256[] memory _claimIndexes)
        external
        view
        override
        returns (uint256)
    {
        uint256 _acumulatedClaimAmount;
        for (uint256 i = 0; i < _claimIndexes.length; i++) {
            _acumulatedClaimAmount = _acumulatedClaimAmount.add(
                _allClaimsByIndexInfo[i].claimAmount
            );
        }
        return _acumulatedClaimAmount;
    }

    function _modifyClaim(uint256 index, ClaimStatus status) internal {
        address claimer = _allClaimsByIndexInfo[index].claimer;
        address policyBookAddress = _allClaimsByIndexInfo[index].policyBookAddress;
        uint256 claimAmount = _allClaimsByIndexInfo[index].claimAmount;

        if (status == ClaimStatus.ACCEPTED) {
            _allClaimsByIndexInfo[index].status = ClaimStatus.ACCEPTED;
            _requestClaimWithdrawal(claimer, index);

            emit ClaimAccepted(claimer, policyBookAddress, claimAmount, index);
        } else if (status == ClaimStatus.EXPIRED) {
            _allClaimsByIndexInfo[index].status = ClaimStatus.EXPIRED;

            emit ClaimExpired(claimer, policyBookAdminAddress, index);
        } else if (!_allClaimsByIndexInfo[index].appeal) {
            _allClaimsByIndexInfo[index].status = ClaimStatus.REJECTED_CAN_APPEAL;

            emit ClaimRejected(claimer, policyBookAddress, index);
        } else {
            _allClaimsByIndexInfo[index].status = ClaimStatus.REJECTED;
            delete _allClaimsToIndex[policyBookAddress][claimer];
            _policyBookClaims[policyBookAddress].remove(index);

            emit AppealRejected(claimer, policyBookAddress, index);
        }

        _allClaimsByIndexInfo[index].dateEnded = block.timestamp;

        _pendingClaimsIndexes.remove(index);

        IPolicyBook(_allClaimsByIndexInfo[index].policyBookAddress).commitClaim(
            claimer,
            block.timestamp,
            _allClaimsByIndexInfo[index].status // ACCEPTED, REJECTED_CAN_APPEAL, REJECTED, EXPIRED
        );
    }

    function acceptClaim(uint256 index, uint256 amount) external override onlyClaimVoting {
        require(_isClaimAwaitingCalculation(index), "ClaimingRegistry: The claim is not awaiting");
        _allClaimsByIndexInfo[index].claimRefund = amount;
        _modifyClaim(index, ClaimStatus.ACCEPTED);
    }

    function rejectClaim(uint256 index) external override onlyClaimVoting {
        require(_isClaimAwaitingCalculation(index), "ClaimingRegistry: The claim is not awaiting");

        _modifyClaim(index, ClaimStatus.REJECTED);
    }

    function expireClaim(uint256 index) external override onlyClaimVoting {
        require(_isClaimExpired(index), "ClaimingRegistry: The claim is not expired");

        _modifyClaim(index, ClaimStatus.EXPIRED);
    }

    function updateImageUriOfClaim(uint256 claim_Index, string calldata _newEvidenceURI)
        external
        override
        onlyPolicyBookAdmin
    {
        _allClaimsByIndexInfo[claim_Index].evidenceURI = _newEvidenceURI;
    }

    function requestClaimWithdrawal(uint256 index) external override {
        require(
            claimStatus(index) == IClaimingRegistry.ClaimStatus.ACCEPTED,
            "ClaimingRegistry: Claim is not accepted"
        );
        address claimer = _allClaimsByIndexInfo[index].claimer;
        require(msg.sender == claimer, "ClaimingRegistry: Not allowed to request");
        address policyBookAddress = _allClaimsByIndexInfo[index].policyBookAddress;
        require(
            policyRegistry.isPolicyActive(claimer, policyBookAddress) &&
                policyRegistry.policyStartTime(claimer, policyBookAddress) <
                _allClaimsByIndexInfo[index].dateEnded,
            "ClaimingRegistry: The policy is expired"
        );
        require(
            getClaimWithdrawalStatus(index) == WithdrawalStatus.NONE ||
                getClaimWithdrawalStatus(index) == WithdrawalStatus.EXPIRED,
            "ClaimingRegistry: The claim is already requested"
        );
        _requestClaimWithdrawal(claimer, index);
    }

    function _requestClaimWithdrawal(address claimer, uint256 index) internal {
        _withdrawClaimRequestIndexList.add(index);
        uint256 _readyToWithdrawDate = block.timestamp.add(capitalPool.getWithdrawPeriod());
        bool _committed = claimWithdrawalInfo[index].committed;
        claimWithdrawalInfo[index] = ClaimWithdrawalInfo(_readyToWithdrawDate, _committed);

        emit WithdrawalRequested(
            claimer,
            _allClaimsByIndexInfo[index].claimRefund,
            _readyToWithdrawDate
        );
    }

    function requestRewardWithdrawal(address voter, uint256 rewardAmount)
        external
        override
        onlyClaimVoting
    {
        require(
            getRewardWithdrawalStatus(voter) == WithdrawalStatus.NONE ||
                getRewardWithdrawalStatus(voter) == WithdrawalStatus.EXPIRED,
            "ClaimingRegistry: The reward is already requested"
        );
        _requestRewardWithdrawal(voter, rewardAmount);
    }

    function _requestRewardWithdrawal(address voter, uint256 rewardAmount) internal {
        _withdrawRewardRequestVoterList.add(voter);
        uint256 _readyToWithdrawDate = block.timestamp.add(capitalPool.getWithdrawPeriod());
        rewardWithdrawalInfo[voter] = RewardWithdrawalInfo(rewardAmount, _readyToWithdrawDate);

        emit WithdrawalRequested(voter, rewardAmount, _readyToWithdrawDate);
    }

    function withdrawClaim(uint256 index) public virtual {
        address claimer = _allClaimsByIndexInfo[index].claimer;
        require(claimer == msg.sender, "ClaimingRegistry: Not the claimer");
        require(
            getClaimWithdrawalStatus(index) == WithdrawalStatus.READY,
            "ClaimingRegistry: Withdrawal is not ready"
        );

        address policyBookAddress = _allClaimsByIndexInfo[index].policyBookAddress;

        uint256 claimRefundConverted =
            DecimalsConverter.convertFrom18(
                _allClaimsByIndexInfo[index].claimRefund,
                stblDecimals
            );

        uint256 _actualAmount =
            capitalPool.fundClaim(claimer, claimRefundConverted, policyBookAddress);

        claimRefundConverted = claimRefundConverted.sub(_actualAmount);

        if (!claimWithdrawalInfo[index].committed) {
            IPolicyBook(policyBookAddress).commitWithdrawnClaim(msg.sender);
            claimWithdrawalInfo[index].committed = true;
        }

        if (claimRefundConverted == 0) {
            _allClaimsByIndexInfo[index].claimRefund = 0;
            _withdrawClaimRequestIndexList.remove(index);
            delete claimWithdrawalInfo[index];
        } else {
            _allClaimsByIndexInfo[index].claimRefund = DecimalsConverter.convertTo18(
                claimRefundConverted,
                stblDecimals
            );
            _requestClaimWithdrawal(claimer, index);
        }

        claimVoting.transferLockedBMI(index, claimer);

        emit ClaimWithdrawn(
            msg.sender,
            DecimalsConverter.convertTo18(_actualAmount, stblDecimals)
        );
    }

    function withdrawReward() public {
        require(
            getRewardWithdrawalStatus(msg.sender) == WithdrawalStatus.READY,
            "ClaimingRegistry: Withdrawal is not ready"
        );

        uint256 rewardAmountConverted =
            DecimalsConverter.convertFrom18(
                rewardWithdrawalInfo[msg.sender].rewardAmount,
                stblDecimals
            );

        uint256 _actualAmount = capitalPool.fundReward(msg.sender, rewardAmountConverted);

        rewardAmountConverted = rewardAmountConverted.sub(_actualAmount);

        if (rewardAmountConverted == 0) {
            rewardWithdrawalInfo[msg.sender].rewardAmount = 0;
            _withdrawRewardRequestVoterList.remove(msg.sender);
            delete rewardWithdrawalInfo[msg.sender];
        } else {
            rewardWithdrawalInfo[msg.sender].rewardAmount = DecimalsConverter.convertTo18(
                rewardAmountConverted,
                stblDecimals
            );

            _requestRewardWithdrawal(msg.sender, rewardWithdrawalInfo[msg.sender].rewardAmount);
        }

        emit RewardWithdrawn(
            msg.sender,
            DecimalsConverter.convertTo18(_actualAmount, stblDecimals)
        );
    }

    function withdrawLockedBMI(uint256 index) public virtual {
        address claimer = _allClaimsByIndexInfo[index].claimer;
        require(claimer == msg.sender, "ClaimingRegistry: Not the claimer");

        require(
            canWithdrawLockedBMI(index),
            "ClaimingRegistry: Claim is not expired or can still be withdrawn"
        );

        address policyBookAddress = _allClaimsByIndexInfo[index].policyBookAddress;
        if (claimStatus(index) == ClaimStatus.ACCEPTED) {
            IPolicyBook(policyBookAddress).commitWithdrawnClaim(claimer);
            _withdrawClaimRequestIndexList.remove(index);
            delete claimWithdrawalInfo[index];
        }

        claimVoting.transferLockedBMI(index, claimer);
    }

    function getRepartition(uint256 index) external view returns (uint256 maj, uint256 min) {
        uint256 voteCount = claimVoting.countVoteOnClaim(index);

        if (voteCount != 0) {
            for (uint256 i = 0; i < voteCount; i++) {
                uint256 voteIndex = claimVoting.voteIndexByClaimIndexAt(index, i);
                if (claimVoting.voteStatus(voteIndex) == IClaimVoting.VoteStatus.MAJORITY) {
                    maj = maj.add(1);
                } else if (claimVoting.voteStatus(voteIndex) == IClaimVoting.VoteStatus.MINORITY) {
                    min = min.add(1);
                }
            }
            maj = maj.mul(10**5).div(voteCount);
            min = min.mul(10**5).div(voteCount);
        }
    }
}