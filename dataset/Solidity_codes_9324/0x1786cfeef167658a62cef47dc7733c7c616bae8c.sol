
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
pragma solidity ^0.7.4;
pragma experimental ABIEncoderV2;

interface IContractsRegistry {
    function liquidityBridgeImplementation() external view returns (address);

    function getUniswapRouterContract() external view returns (address);

    function getUniswapBMIToETHPairContract() external view returns (address);

    function getWETHContract() external view returns (address);

    function getUSDTContract() external view returns (address);

    function getBMIContract() external view returns (address);

    function getPriceFeedContract() external view returns (address);

    function getPolicyBookRegistryContract() external view returns (address);

    function getPolicyBookFabricContract() external view returns (address);

    function getBMICoverStakingContract() external view returns (address);

    function getLegacyRewardsGeneratorContract() external view returns (address);

    function getRewardsGeneratorContract() external view returns (address);

    function getBMIUtilityNFTContract() external view returns (address);

    function getLiquidityMiningContract() external view returns (address);

    function getClaimingRegistryContract() external view returns (address);

    function getPolicyRegistryContract() external view returns (address);

    function getLiquidityRegistryContract() external view returns (address);

    function getClaimVotingContract() external view returns (address);

    function getReinsurancePoolContract() external view returns (address);

    function getLiquidityBridgeContract() external view returns (address);

    function getContractsRegistryV2Contract() external view returns (address);

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

    function getPolicyBookAPY(address policyBookAddress) external view returns (uint256);

    function restakeBMIProfit(uint256 tokenId) external;

    function restakeStakerBMIProfit(address policyBookAddress) external;

    function withdrawBMIProfit(uint256 tokenID) external;

    function withdrawStakerBMIProfit(address policyBookAddress) external;

    function migrateWitdrawFundsWithProfit(address _sender, uint256 tokenId)
        external
        returns (uint256);

    function withdrawFundsWithProfit(uint256 tokenID) external;

    function withdrawStakerFundsWithProfit(address policyBookAddress) external;

    function stakingInfoByToken(uint256 tokenID) external view returns (StakingInfo memory);

    function stakingInfoByStaker(
        address staker,
        address[] calldata policyBooksAddresses,
        uint256 offset,
        uint256 limit
    )
        external
        view
        returns (
            PolicyBookInfo[] memory policyBooksInfo,
            UserInfo[] memory usersInfo,
            uint256[] memory nftsCount,
            NFTsInfo[][] memory nftsInfo
        );

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

    function policyBookByNFT(uint256 tokenId) external view returns (address);

    function balanceOf(address user) external view returns (uint256);

    function ownerOf(uint256 tokenId) external view returns (address);

    function tokenOfOwnerByIndex(address user, uint256 index) external view returns (uint256);
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


interface ISTKBMIToken is IERC20Upgradeable {
    function mint(address account, uint256 amount) external;

    function burn(address account, uint256 amount) external;
}// MIT

pragma solidity ^0.7.4;


interface IBMIStaking {
    event StakedBMI(uint256 stakedBMI, uint256 mintedStkBMI, address indexed recipient);
    event BMIWithdrawn(uint256 amountBMI, uint256 burnedStkBMI, address indexed recipient);

    event UnusedRewardPoolRevoked(address recipient, uint256 amount);
    event RewardPoolRevoked(address recipient, uint256 amount);

    event BMIMigratedToV2(uint256 amountBMI, uint256 burnedStkBMI, address indexed recipient);

    struct WithdrawalInfo {
        uint256 coolDownTimeEnd;
        uint256 amountBMIRequested;
    }

    function stakeWithPermit(
        uint256 _amountBMI,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external;

    function stakeFor(address _user, uint256 _amountBMI) external;

    function stake(uint256 _amountBMI) external;

    function maturityAt() external view returns (uint256);

    function isBMIRewardUnlocked() external view returns (bool);

    function whenCanWithdrawBMIReward(address _address) external view returns (uint256);

    function unlockTokensToWithdraw(uint256 _amountBMIUnlock) external;

    function withdraw() external;

    function migrateStakeToV2(address _user)
        external
        returns (uint256 amountBMI, uint256 _amountStkBMI);

    function getWithdrawalInfo(address _userAddr)
        external
        view
        returns (
            uint256 _amountBMIRequested,
            uint256 _amountStkBMI,
            uint256 _unlockPeriod,
            uint256 _availableFor
        );

    function addToPool(uint256 _amount) external;

    function stakingReward(uint256 _amount) external view returns (uint256);

    function getStakedBMI(address _address) external view returns (uint256);

    function getAPY() external view returns (uint256);

    function setRewardPerBlock(uint256 _amount) external;

    function revokeRewardPool(uint256 _amount) external;

    function revokeUnusedRewardPool() external;
}// MIT
pragma solidity ^0.7.4;

interface ILiquidityBridge {
    event BMIMigratedToV2(uint256 amountBMI, uint256 burnedStkBMI, address indexed recipient);
    event MigratedBMIStakers(uint256 migratedCount);
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

    function isMigrating() external view returns (bool);
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

    function extractLiquidity() external;

    function getUserBMIXStakeInfo(address _sendere) external returns (uint256, uint256);

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

    function forceUpdateBMICoverStakingRewardMultiplier() external;

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

    function getUserAvailableSTBL(address _userAddr) external view returns (uint256);

    function getWithdrawalStatus(address _userAddr) external view returns (WithdrawalStatus);

    function requestWithdrawal(uint256 _tokensToWithdraw) external;

    function requestWithdrawalWithPermit(
        uint256 _tokensToWithdraw,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external;

    function unlockTokens() external;

    function migrateRequestWithdrawal(address _sender, uint256 _tokensToBurn)
        external
        returns (uint256 _sbtlAmount);

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

    function removePolicy(address _policy, address _userAddr) external;
}// MIT

pragma solidity ^0.7.4;


interface IV2BMIStaking {
    event StakedBMI(uint256 stakedBMI, uint256 mintedStkBMI, address indexed recipient);
    event BMIWithdrawn(uint256 amountBMI, uint256 burnedStkBMI, address indexed recipient);

    event UnusedRewardPoolRevoked(address recipient, uint256 amount);
    event RewardPoolRevoked(address recipient, uint256 amount);

    struct WithdrawalInfo {
        uint256 coolDownTimeEnd;
        uint256 amountBMIRequested;
    }

    function stakeWithPermit(
        uint256 _amountBMI,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external;

    function stakeFor(address _user, uint256 _amountBMI) external;

    function stake(uint256 _amountBMI) external;

    function maturityAt() external view returns (uint256);

    function isBMIRewardUnlocked() external view returns (bool);

    function whenCanWithdrawBMIReward(address _address) external view returns (uint256);

    function unlockTokensToWithdraw(uint256 _amountBMIUnlock) external;

    function withdraw() external;

    function getWithdrawalInfo(address _userAddr)
        external
        view
        returns (
            uint256 _amountBMIRequested,
            uint256 _amountStkBMI,
            uint256 _unlockPeriod,
            uint256 _availableFor
        );

    function addToPool(uint256 _amount) external;

    function stakingReward(uint256 _amount) external view returns (uint256);

    function getStakedBMI(address _address) external view returns (uint256);

    function getAPY() external view returns (uint256);

    function setRewardPerBlock(uint256 _amount) external;

    function revokeRewardPool(uint256 _amount) external;

    function revokeUnusedRewardPool() external;
}// MIT
pragma solidity ^0.7.4;

interface IV2ContractsRegistry {
    function addProxyContract(bytes32 name, address contractAddress) external;

    function upgradeContract(bytes32 name, address contractAddress) external;

    function injectDependencies(bytes32 name) external;

    function getUniswapRouterContract() external view returns (address);

    function getUniswapBMIToETHPairContract() external view returns (address);

    function getUniswapBMIToUSDTPairContract() external view returns (address);

    function getSushiswapRouterContract() external view returns (address);

    function getSushiswapBMIToETHPairContract() external view returns (address);

    function getSushiswapBMIToUSDTPairContract() external view returns (address);

    function getSushiSwapMasterChefV2Contract() external view returns (address);

    function getWETHContract() external view returns (address);

    function getUSDTContract() external view returns (address);

    function getBMIContract() external view returns (address);

    function getPriceFeedContract() external view returns (address);

    function getPolicyBookRegistryContract() external view returns (address);

    function getPolicyBookFabricContract() external view returns (address);

    function getBMICoverStakingContract() external view returns (address);

    function getBMICoverStakingViewContract() external view returns (address);

    function getLegacyRewardsGeneratorContract() external view returns (address);

    function getRewardsGeneratorContract() external view returns (address);

    function getBMIUtilityNFTContract() external view returns (address);

    function getNFTStakingContract() external view returns (address);

    function getLiquidityBridgeContract() external view returns (address);

    function getLiquidityMiningContract() external view returns (address);

    function getClaimingRegistryContract() external view returns (address);

    function getPolicyRegistryContract() external view returns (address);

    function getLiquidityRegistryContract() external view returns (address);

    function getClaimVotingContract() external view returns (address);

    function getReinsurancePoolContract() external view returns (address);

    function getLeveragePortfolioViewContract() external view returns (address);

    function getCapitalPoolContract() external view returns (address);

    function getPolicyBookAdminContract() external view returns (address);

    function getPolicyQuoteContract() external view returns (address);

    function getLegacyBMIStakingContract() external view returns (address);

    function getBMIStakingContract() external view returns (address);

    function getSTKBMIContract() external view returns (address);

    function getVBMIContract() external view returns (address);

    function getLegacyLiquidityMiningStakingContract() external view returns (address);

    function getLiquidityMiningStakingETHContract() external view returns (address);

    function getLiquidityMiningStakingUSDTContract() external view returns (address);

    function getReputationSystemContract() external view returns (address);

    function getAaveProtocolContract() external view returns (address);

    function getAaveLendPoolAddressProvdierContract() external view returns (address);

    function getAaveATokenContract() external view returns (address);

    function getCompoundProtocolContract() external view returns (address);

    function getCompoundCTokenContract() external view returns (address);

    function getCompoundComptrollerContract() external view returns (address);

    function getYearnProtocolContract() external view returns (address);

    function getYearnVaultContract() external view returns (address);

    function getYieldGeneratorContract() external view returns (address);

    function getShieldMiningContract() external view returns (address);
}// MIT
pragma solidity ^0.7.4;


interface IV2PolicyBook {
    function policyBookFacade() external view returns (address);

    function addLiquidityFor(address _liquidityHolderAddr, uint256 _liqudityAmount) external;











































}// MIT
pragma solidity ^0.7.4;

interface IV2PolicyBookFacade {
    function addLiquidityAndStakeFor(
        address _liquidityHolderAddr,
        uint256 _liquidityAmount,
        uint256 _stakeSTBLAmount
    ) external;

    function buyPolicyFor(
        address _holder,
        uint256 _epochsNumber,
        uint256 _coverTokens
    ) external;





























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
        return convert(amount, baseDecimals, 18);
    }

    function convertFrom18(uint256 amount, uint256 destinationDecimals)
        internal
        pure
        returns (uint256)
    {
        return convert(amount, 18, destinationDecimals);
    }
}// MIT
pragma solidity ^0.7.4;



contract LiquidityBridge is ILiquidityBridge, OwnableUpgradeable, AbstractDependant {
    using SafeMath for uint256;
    using SafeERC20 for ERC20;
    using Math for uint256;

    address public v1bmiStakingAddress;
    address public v2bmiStakingAddress;
    address public v1bmiCoverStakingAddress;
    address public v2bmiCoverStakingAddress;
    address public v1policyBookFabricAddress;
    address public v2contractsRegistryAddress;
    address public v1contractsRegistryAddress;
    address public v1policyRegistryAddress;
    address public v1policyBookRegistryAddress;
    address public v2policyBoo2RegistryAddress;

    address public admin;

    uint256 public counter;
    uint256 public stblDecimals;

    IERC20 public bmiToken;
    ERC20 public stblToken;

    mapping(address => mapping(address => bool)) public migrateAddLiquidity;
    mapping(address => mapping(address => bool)) public migratedCoverStaking;
    mapping(address => address) public upgradedPolicies;
    mapping(address => uint256) public extractedLiquidity;

    event MigrationAllowanceSetUp(address policybook, uint256 newAllowance);
    event LiquidityCollected(address v1PolicyBook, address v2PolicyBook, uint256 amount);
    event LiquidityMigrated(uint256 migratedCount, address poolAddress, address userAddress);
    event SkippedRequest(uint256 reason, address poolAddress, address userAddress);
    event MigratedAddedLiquidity(address pool, address user, uint256 tetherAmount);

    function __LiquidityBridge_init() external initializer {
        __Ownable_init();
    }

    function setDependencies(IContractsRegistry _contractsRegistry) external override {
        v1contractsRegistryAddress = 0x8050c5a46FC224E3BCfa5D7B7cBacB1e4010118d;
        v2contractsRegistryAddress = 0x45269F7e69EE636067835e0DfDd597214A1de6ea;

        require(
            msg.sender == v1contractsRegistryAddress || msg.sender == v2contractsRegistryAddress,
            "Dependant: Not an injector"
        );

        IContractsRegistry _v1contractsRegistry = IContractsRegistry(v1contractsRegistryAddress);
        IV2ContractsRegistry _v2contractsRegistry =
            IV2ContractsRegistry(v2contractsRegistryAddress);

        v1bmiStakingAddress = _v1contractsRegistry.getBMIStakingContract();
        v2bmiStakingAddress = _v2contractsRegistry.getBMIStakingContract();

        v1bmiCoverStakingAddress = _v1contractsRegistry.getBMICoverStakingContract();
        v2bmiCoverStakingAddress = _v2contractsRegistry.getBMICoverStakingContract();

        v1policyBookFabricAddress = _v1contractsRegistry.getPolicyBookFabricContract();

        v1policyRegistryAddress = _v1contractsRegistry.getPolicyRegistryContract();

        v1policyBookRegistryAddress = _v1contractsRegistry.getPolicyBookRegistryContract();
        v2policyBoo2RegistryAddress = _v2contractsRegistry.getPolicyBookRegistryContract();

        bmiToken = IERC20(_v1contractsRegistry.getBMIContract());
        stblToken = ERC20(_contractsRegistry.getUSDTContract());

        stblDecimals = stblToken.decimals();
    }

    modifier onlyAdmins() {
        require(_msgSender() == admin || _msgSender() == owner(), "not in admins");
        _;
    }

    modifier guardEmptyPolicies(address v1Policy) {
        require(hasRecievingPolicy(upgradedPolicies[v1Policy]), "No recieving policy set");
        _;
    }

    function hasRecievingPolicy(address v1Policy) public returns (bool) {
        if (upgradedPolicies[v1Policy] == address(0)) {
            return false;
        }
        return true;
    }

    function checkBalances(bool checkLiquidityBridge)
        external
        view
        returns (
            address[] memory policyBooksV1,
            uint256[] memory balanceV1,
            address[] memory policyBooksV2,
            uint256[] memory balanceV2
        )
    {
        address[] memory policyBooks =
            IPolicyBookRegistry(v1policyBookRegistryAddress).list(0, 33);

        policyBooksV1 = new address[](policyBooks.length);
        policyBooksV2 = new address[](policyBooks.length);
        balanceV1 = new uint256[](policyBooks.length);
        balanceV2 = new uint256[](policyBooks.length);

        for (uint256 i = 0; i < policyBooks.length; i++) {
            if (policyBooks[i] == address(0)) {
                break;
            }

            policyBooksV1[i] = policyBooks[i];
            balanceV1[i] = stblToken.balanceOf(policyBooksV1[i]);
            policyBooksV2[i] = upgradedPolicies[policyBooks[i]];

            if (checkLiquidityBridge) {
                balanceV2[i] = stblToken.balanceOf(address(this));
            } else {
                if (policyBooksV2[i] != address(0)) {
                    balanceV2[i] = stblToken.balanceOf(policyBooksV2[i]);
                }
            }
        }
    }

    function collectPolicyBooksLiquidity(uint256 _offset, uint256 _limit) external onlyOwner {
        address[] memory _policyBooks =
            IPolicyBookRegistry(v1policyBookRegistryAddress).list(_offset, _limit);

        uint256 _to = (_offset.add(_limit)).min(_policyBooks.length).max(_offset);

        for (uint256 i = _offset; i < _to; i++) {
            address _policyBook = _policyBooks[i];

            if (_policyBook == address(0)) {
                break;
            }
            if (upgradedPolicies[_policyBook] == address(0)) {
                continue;
            }

            uint256 _pbBalance = stblToken.balanceOf(_policyBook);

            if (_pbBalance > 0) {
                extractedLiquidity[_policyBook].add(_pbBalance);
                IPolicyBook(_policyBook).extractLiquidity();
            }
            emit LiquidityCollected(_policyBook, upgradedPolicies[_policyBook], _pbBalance);
        }
    }

    function setMigrationStblApprovals(uint256 _offset, uint256 _limit) external onlyOwner {
        address[] memory _policyBooks =
            IPolicyBookRegistry(v1policyBookRegistryAddress).list(_offset, _limit);

        uint256 _to = (_offset.add(_limit)).min(_policyBooks.length).max(_offset);

        for (uint256 i = _offset; i < _to; i++) {
            address _v1policyBook = _policyBooks[i];
            address _v2policyBook = upgradedPolicies[_v1policyBook];

            if (_v2policyBook == address(0)) {
                continue;
            }

            uint256 _currentApproval = stblToken.allowance(address(this), _v2policyBook);

            if (extractedLiquidity[_v1policyBook] > _currentApproval) {
                if (_currentApproval > 0) {
                    stblToken.safeApprove(_v2policyBook, 0);
                }

                stblToken.safeApprove(_v2policyBook, extractedLiquidity[_v1policyBook]);
                emit MigrationAllowanceSetUp(_v2policyBook, extractedLiquidity[_v1policyBook]);
            }
        }
    }

    function setAdmin(address _admin) external onlyOwner {
        admin = _admin;
    }

    function linkV2Policies(address[] calldata v1policybooks, address[] calldata v2policybooks)
        external
        onlyAdmins
    {
        for (uint256 i = 0; i < v1policybooks.length; i++) {
            upgradedPolicies[v1policybooks[i]] = v2policybooks[i];
        }
    }

    function _unlockAllowances() internal {
        if (bmiToken.allowance(address(this), v2bmiStakingAddress) == 0) {
            bmiToken.approve(v2bmiStakingAddress, uint256(-1));
        }

        if (bmiToken.allowance(address(this), v2bmiCoverStakingAddress) == 0) {
            bmiToken.approve(v2bmiStakingAddress, uint256(-1));
        }
    }

    function unlockStblAllowanceFor(address _spender, uint256 _amount) external onlyAdmins {
        _unlockStblAllowanceFor(_spender, _amount);
    }

    function _unlockStblAllowanceFor(address _spender, uint256 _amount) internal {
        uint256 _allowance = stblToken.allowance(address(this), _spender);

        if (_allowance < _amount) {
            if (_allowance > 0) {
                stblToken.safeApprove(_spender, 0);
            }

            stblToken.safeIncreaseAllowance(_spender, _amount);
        }
    }

    function validatePolicyHolder(address[] calldata _poolAddress, address[] calldata _userAddress)
        external
        view
        returns (uint256[] memory _indexes, uint256 _counter)
    {
        uint256 _counter = 0;
        uint256[] memory _indexes = new uint256[](_poolAddress.length);

        for (uint256 i = 0; i < _poolAddress.length; i++) {
            IPolicyBook.PolicyHolder memory data =
                IPolicyBook(_poolAddress[i]).userStats(_userAddress[i]);
            if (data.startEpochNumber == 0) {
                _indexes[_counter] = i;
                _counter++;
            }
        }
    }

    function purchasePolicyFor(address _v1Policy, address _sender)
        external
        onlyAdmins
        guardEmptyPolicies(_v1Policy)
        returns (bool)
    {
        IPolicyBook.PolicyHolder memory data = IPolicyBook(_v1Policy).userStats(_sender);

        if (data.startEpochNumber != 0) {
            uint256 _currentEpoch = IPolicyBook(_v1Policy).getEpoch(block.timestamp);

            uint256 _epochNumbers = data.endEpochNumber.sub(_currentEpoch);

            address facade = IV2PolicyBook(upgradedPolicies[_v1Policy]).policyBookFacade();

            IV2PolicyBookFacade(facade).buyPolicyFor(_sender, _epochNumbers, data.coverTokens);

            return true;
        }

        return false;
    }

    function migrateAddedLiquidity(
        address[] calldata _poolAddress,
        address[] calldata _userAddress
    ) external onlyAdmins {
        require(_poolAddress.length == _userAddress.length, "Missmatch inputs lenght");
        uint256 maxGasSpent = 0;
        uint256 i;

        for (i = 0; i < _poolAddress.length; i++) {
            uint256 gasStart = gasleft();

            if (upgradedPolicies[_poolAddress[i]] == address(0)) {
                emit SkippedRequest(0, _poolAddress[i], _userAddress[i]);
                continue;
            }

            migrateStblLiquidity(_poolAddress[i], _userAddress[i]);
            counter++;

            emit LiquidityMigrated(counter, _poolAddress[i], _userAddress[i]);

            uint256 gasEnd = gasleft();
            maxGasSpent = (gasStart - gasEnd) > maxGasSpent ? (gasStart - gasEnd) : maxGasSpent;

            if (gasEnd < maxGasSpent) {
                break;
            }
        }
    }

    function migrateStblLiquidity(address _pool, address _sender)
        public
        onlyAdmins
        guardEmptyPolicies(_pool)
        returns (bool)
    {

        (uint256 _tokensToBurn, uint256 _stblAmountTether) =
            IPolicyBook(_pool).getUserBMIXStakeInfo(_sender);

        IPolicyBook(_pool).migrateRequestWithdrawal(_sender, _tokensToBurn);

        if (_stblAmountTether > 0) {
            uint256 _stblAmountStnd =
                DecimalsConverter.convertTo18(_stblAmountTether, stblDecimals);

            address _v2Policy = upgradedPolicies[_pool];
            address facade = IV2PolicyBook(_v2Policy).policyBookFacade();

            IV2PolicyBookFacade(facade).addLiquidityAndStakeFor(
                _sender,
                _stblAmountStnd,
                _stblAmountStnd
            );

            emit MigratedAddedLiquidity(_pool, _sender, _stblAmountTether);
            migrateAddLiquidity[_pool][_sender] = true;
        }
    }

    function migrateBMIStakes(address[] calldata _poolAddress, address[] calldata _userAddress)
        external
        onlyAdmins
    {
        require(_poolAddress.length == _userAddress.length, "Missmatch inputs lenght");
        uint256 maxGasSpent = 0;
        uint256 i;

        for (i = 0; i < _poolAddress.length; i++) {
            uint256 gasStart = gasleft();

            if (upgradedPolicies[_poolAddress[i]] == address(0)) {
                emit SkippedRequest(0, _poolAddress[i], _userAddress[i]);
                continue;
            }

            migrateBMICoverStaking(_poolAddress[i], _userAddress[i]);
            counter++;

            emit LiquidityMigrated(counter, _poolAddress[i], _userAddress[i]);

            uint256 gasEnd = gasleft();
            maxGasSpent = (gasStart - gasEnd) > maxGasSpent ? (gasStart - gasEnd) : maxGasSpent;

            if (gasEnd < maxGasSpent) {
                break;
            }
        }
    }

    function migrateBMIStake(address _sender, uint256 _bmiRewards) internal returns (bool) {
        (uint256 _amountBMI, uint256 _burnedStkBMI) =
            IBMIStaking(v1bmiStakingAddress).migrateStakeToV2(_sender);

        if (_amountBMI > 0) {
            require(false, "contracts/LiquidityBridgeMigV2.sol 363");
            IV2BMIStaking(v2bmiStakingAddress).stakeFor(_sender, _amountBMI + _bmiRewards);
        }

        emit BMIMigratedToV2(_amountBMI + _bmiRewards, _burnedStkBMI, _sender);
    }

    function migrateBMICoverStaking(address _policyBook, address _sender)
        public
        onlyAdmins
        returns (uint256 _bmiRewards)
    {
        if (migratedCoverStaking[_policyBook][_sender]) {
            return 0;
        }

        uint256 nftAmount = IBMICoverStaking(v1bmiCoverStakingAddress).balanceOf(_sender);
        IBMICoverStaking.StakingInfo memory _stakingInfo;
        uint256[] memory _policyNfts = new uint256[](nftAmount);
        uint256 _nftCount = 0;

        for (uint256 i = 0; i < nftAmount; i++) {
            uint256 nftIndex =
                IBMICoverStaking(v1bmiCoverStakingAddress).tokenOfOwnerByIndex(_sender, i);

            _stakingInfo = IBMICoverStaking(v1bmiCoverStakingAddress).stakingInfoByToken(nftIndex);

            _policyNfts[_nftCount] = nftIndex;
            _nftCount++;
        }

        for (uint256 j = 0; j < _nftCount; j++) {
            uint256 _bmi =
                IBMICoverStaking(v1bmiCoverStakingAddress).migrateWitdrawFundsWithProfit(
                    _sender,
                    _policyNfts[j]
                );

            _bmiRewards += _bmi;
        }

        migrateBMIStake(_sender, _bmiRewards);
        migratedCoverStaking[_policyBook][_sender] = true;
    }
}