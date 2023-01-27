pragma solidity 0.8.2;

interface ISavingsContractV3 {

    function redeemAndUnwrap(
        uint256 _amount,
        bool _isCreditAmt,
        uint256 _minAmountOut,
        address _output,
        address _beneficiary,
        address _router,
        bool _isBassetOut
    )
        external
        returns (
            uint256 creditsBurned,
            uint256 massetRedeemed,
            uint256 outputQuantity
        );


    function depositSavings(
        uint256 _underlying,
        address _beneficiary,
        address _referrer
    ) external returns (uint256 creditsIssued);

}

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IBoostedVaultWithLockup {

    function stake(uint256 _amount) external;


    function stake(address _beneficiary, uint256 _amount) external;


    function exit() external;


    function exit(uint256 _first, uint256 _last) external;


    function withdraw(uint256 _amount) external;


    function withdrawAndUnwrap(
        uint256 _amount,
        uint256 _minAmountOut,
        address _output,
        address _beneficiary,
        address _router,
        bool _isBassetOut
    ) external returns (uint256 outputQuantity);


    function claimReward() external;


    function claimRewards() external;


    function claimRewards(uint256 _first, uint256 _last) external;


    function pokeBoost(address _account) external;


    function lastTimeRewardApplicable() external view returns (uint256);


    function rewardPerToken() external view returns (uint256);


    function earned(address _account) external view returns (uint256);


    function unclaimedRewards(address _account)
        external
        view
        returns (
            uint256 amount,
            uint256 first,
            uint256 last
        );

}

contract ModuleKeys {

    bytes32 internal constant KEY_GOVERNANCE =
        0x9409903de1e6fd852dfc61c9dacb48196c48535b60e25abf92acc92dd689078d;
    bytes32 internal constant KEY_STAKING =
        0x1df41cd916959d1163dc8f0671a666ea8a3e434c13e40faef527133b5d167034;
    bytes32 internal constant KEY_PROXY_ADMIN =
        0x96ed0203eb7e975a4cbcaa23951943fa35c5d8288117d50c12b3d48b0fab48d1;

    bytes32 internal constant KEY_ORACLE_HUB =
        0x8ae3a082c61a7379e2280f3356a5131507d9829d222d853bfa7c9fe1200dd040;
    bytes32 internal constant KEY_MANAGER =
        0x6d439300980e333f0256d64be2c9f67e86f4493ce25f82498d6db7f4be3d9e6f;
    bytes32 internal constant KEY_RECOLLATERALISER =
        0x39e3ed1fc335ce346a8cbe3e64dd525cf22b37f1e2104a755e761c3c1eb4734f;
    bytes32 internal constant KEY_META_TOKEN =
        0xea7469b14936af748ee93c53b2fe510b9928edbdccac3963321efca7eb1a57a2;
    bytes32 internal constant KEY_SAVINGS_MANAGER =
        0x12fe936c77a1e196473c4314f3bed8eeac1d757b319abb85bdda70df35511bf1;
    bytes32 internal constant KEY_LIQUIDATOR =
        0x1e9cb14d7560734a61fa5ff9273953e971ff3cd9283c03d8346e3264617933d4;
    bytes32 internal constant KEY_INTEREST_VALIDATOR =
        0xc10a28f028c7f7282a03c90608e38a4a646e136e614e4b07d119280c5f7f839f;
}

interface INexus {

    function governor() external view returns (address);


    function getModule(bytes32 key) external view returns (address);


    function proposeModule(bytes32 _key, address _addr) external;


    function cancelProposedModule(bytes32 _key) external;


    function acceptProposedModule(bytes32 _key) external;


    function acceptProposedModules(bytes32[] calldata _keys) external;


    function requestLockModule(bytes32 _key) external;


    function cancelLockModule(bytes32 _key) external;


    function lockModule(bytes32 _key) external;

}

abstract contract ImmutableModule is ModuleKeys {
    INexus public immutable nexus;

    constructor(address _nexus) {
        require(_nexus != address(0), "Nexus address is zero");
        nexus = INexus(_nexus);
    }

    modifier onlyGovernor() {
        _onlyGovernor();
        _;
    }

    function _onlyGovernor() internal view {
        require(msg.sender == _governor(), "Only governor can execute");
    }

    modifier onlyGovernance() {
        require(
            msg.sender == _governor() || msg.sender == _governance(),
            "Only governance can execute"
        );
        _;
    }

    modifier onlyProxyAdmin() {
        require(msg.sender == _proxyAdmin(), "Only ProxyAdmin can execute");
        _;
    }

    modifier onlyManager() {
        require(msg.sender == _manager(), "Only manager can execute");
        _;
    }

    function _governor() internal view returns (address) {
        return nexus.governor();
    }

    function _governance() internal view returns (address) {
        return nexus.getModule(KEY_GOVERNANCE);
    }

    function _staking() internal view returns (address) {
        return nexus.getModule(KEY_STAKING);
    }

    function _proxyAdmin() internal view returns (address) {
        return nexus.getModule(KEY_PROXY_ADMIN);
    }

    function _metaToken() internal view returns (address) {
        return nexus.getModule(KEY_META_TOKEN);
    }

    function _oracleHub() internal view returns (address) {
        return nexus.getModule(KEY_ORACLE_HUB);
    }

    function _manager() internal view returns (address) {
        return nexus.getModule(KEY_MANAGER);
    }

    function _savingsManager() internal view returns (address) {
        return nexus.getModule(KEY_SAVINGS_MANAGER);
    }

    function _recollateraliser() internal view returns (address) {
        return nexus.getModule(KEY_RECOLLATERALISER);
    }
}

interface IRewardsDistributionRecipient {

    function notifyRewardAmount(uint256 reward) external;


    function getRewardToken() external view returns (IERC20);

}

abstract contract InitializableRewardsDistributionRecipient is
    IRewardsDistributionRecipient,
    ImmutableModule
{
    address public rewardsDistributor;

    constructor(address _nexus) ImmutableModule(_nexus) {}

    function _initialize(address _rewardsDistributor) internal {
        rewardsDistributor = _rewardsDistributor;
    }

    modifier onlyRewardsDistributor() {
        require(msg.sender == rewardsDistributor, "Caller is not reward distributor");
        _;
    }

    function setRewardsDistribution(address _rewardsDistributor) external onlyGovernor {
        rewardsDistributor = _rewardsDistributor;
    }
}

interface IBoostDirector {

    function getBalance(address _user) external returns (uint256);


    function setDirection(
        address _old,
        address _new,
        bool _pokeNew
    ) external;


    function whitelistVaults(address[] calldata _vaults) external;

}

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return
            functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {

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
}

library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, newAllowance)
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(token.approve.selector, spender, newAllowance)
            );
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract InitializableReentrancyGuard {

    bool private _notEntered;

    function _initializeReentrancyGuard() internal {

        _notEntered = true;
    }

    modifier nonReentrant() {

        require(_notEntered, "ReentrancyGuard: reentrant call");

        _notEntered = false;

        _;

        _notEntered = true;
    }
}

library StableMath {

    uint256 private constant FULL_SCALE = 1e18;

    uint256 private constant RATIO_SCALE = 1e8;

    function getFullScale() internal pure returns (uint256) {

        return FULL_SCALE;
    }

    function getRatioScale() internal pure returns (uint256) {

        return RATIO_SCALE;
    }

    function scaleInteger(uint256 x) internal pure returns (uint256) {

        return x * FULL_SCALE;
    }


    function mulTruncate(uint256 x, uint256 y) internal pure returns (uint256) {

        return mulTruncateScale(x, y, FULL_SCALE);
    }

    function mulTruncateScale(
        uint256 x,
        uint256 y,
        uint256 scale
    ) internal pure returns (uint256) {

        return (x * y) / scale;
    }

    function mulTruncateCeil(uint256 x, uint256 y) internal pure returns (uint256) {

        uint256 scaled = x * y;
        uint256 ceil = scaled + FULL_SCALE - 1;
        return ceil / FULL_SCALE;
    }

    function divPrecisely(uint256 x, uint256 y) internal pure returns (uint256) {

        return (x * FULL_SCALE) / y;
    }


    function mulRatioTruncate(uint256 x, uint256 ratio) internal pure returns (uint256 c) {

        return mulTruncateScale(x, ratio, RATIO_SCALE);
    }

    function mulRatioTruncateCeil(uint256 x, uint256 ratio) internal pure returns (uint256) {

        uint256 scaled = x * ratio;
        uint256 ceil = scaled + RATIO_SCALE - 1;
        return ceil / RATIO_SCALE;
    }

    function divRatioPrecisely(uint256 x, uint256 ratio) internal pure returns (uint256 c) {

        return (x * RATIO_SCALE) / ratio;
    }


    function min(uint256 x, uint256 y) internal pure returns (uint256) {

        return x > y ? y : x;
    }

    function max(uint256 x, uint256 y) internal pure returns (uint256) {

        return x > y ? x : y;
    }

    function clamp(uint256 x, uint256 upperBound) internal pure returns (uint256) {

        return x > upperBound ? upperBound : x;
    }
}

library Root {

    function sqrt(uint256 x) internal pure returns (uint256 y) {

        if (x == 0) return 0;
        else {
            uint256 xx = x;
            uint256 r = 1;
            if (xx >= 0x100000000000000000000000000000000) {
                xx >>= 128;
                r <<= 64;
            }
            if (xx >= 0x10000000000000000) {
                xx >>= 64;
                r <<= 32;
            }
            if (xx >= 0x100000000) {
                xx >>= 32;
                r <<= 16;
            }
            if (xx >= 0x10000) {
                xx >>= 16;
                r <<= 8;
            }
            if (xx >= 0x100) {
                xx >>= 8;
                r <<= 4;
            }
            if (xx >= 0x10) {
                xx >>= 4;
                r <<= 2;
            }
            if (xx >= 0x8) {
                r <<= 1;
            }
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1; // Seven iterations should be enough
            uint256 r1 = x / r;
            return uint256(r < r1 ? r : r1);
        }
    }
}

contract BoostedTokenWrapper is InitializableReentrancyGuard {

    using StableMath for uint256;
    using SafeERC20 for IERC20;

    event Transfer(address indexed from, address indexed to, uint256 value);

    string private _name;
    string private _symbol;

    IERC20 public immutable stakingToken;
    IBoostDirector public immutable boostDirector;

    uint256 private _totalBoostedSupply;
    mapping(address => uint256) private _boostedBalances;
    mapping(address => uint256) private _rawBalances;

    uint256 private constant MIN_DEPOSIT = 1e18;
    uint256 private constant MAX_VMTA = 600000e18;
    uint256 private constant MAX_BOOST = 3e18;
    uint256 private constant MIN_BOOST = 1e18;
    uint256 private constant FLOOR = 98e16;
    uint256 public immutable boostCoeff; // scaled by 10
    uint256 public immutable priceCoeff;

    constructor(
        address _stakingToken,
        address _boostDirector,
        uint256 _priceCoeff,
        uint256 _boostCoeff
    ) {
        stakingToken = IERC20(_stakingToken);
        boostDirector = IBoostDirector(_boostDirector);
        priceCoeff = _priceCoeff;
        boostCoeff = _boostCoeff;
    }

    function _initialize(string memory _nameArg, string memory _symbolArg) internal {

        _initializeReentrancyGuard();
        _name = _nameArg;
        _symbol = _symbolArg;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return 18;
    }

    function totalSupply() public view returns (uint256) {

        return _totalBoostedSupply;
    }

    function balanceOf(address _account) public view returns (uint256) {

        return _boostedBalances[_account];
    }

    function rawBalanceOf(address _account) public view returns (uint256) {

        return _rawBalances[_account];
    }

    function getBoost(address _account) public view returns (uint256) {

        return balanceOf(_account).divPrecisely(rawBalanceOf(_account));
    }

    function _stakeRaw(address _beneficiary, uint256 _amount) internal nonReentrant {

        _rawBalances[_beneficiary] += _amount;
        stakingToken.safeTransferFrom(msg.sender, address(this), _amount);
    }

    function _withdrawRaw(uint256 _amount) internal nonReentrant {

        _rawBalances[msg.sender] -= _amount;
        stakingToken.safeTransfer(msg.sender, _amount);
    }

    function _reduceRaw(uint256 _amount) internal nonReentrant {

        _rawBalances[msg.sender] -= _amount;
    }

    function _setBoost(address _account) internal {

        uint256 rawBalance = _rawBalances[_account];
        uint256 boostedBalance = _boostedBalances[_account];
        uint256 boost = MIN_BOOST;

        uint256 scaledBalance = (rawBalance * priceCoeff) / 1e18;
        if (scaledBalance >= MIN_DEPOSIT) {
            uint256 votingWeight = boostDirector.getBalance(_account);
            boost = _computeBoost(scaledBalance, votingWeight);
        }

        uint256 newBoostedBalance = rawBalance.mulTruncate(boost);

        if (newBoostedBalance != boostedBalance) {
            _totalBoostedSupply = _totalBoostedSupply - boostedBalance + newBoostedBalance;
            _boostedBalances[_account] = newBoostedBalance;

            if (newBoostedBalance > boostedBalance) {
                emit Transfer(address(0), _account, newBoostedBalance - boostedBalance);
            } else {
                emit Transfer(_account, address(0), boostedBalance - newBoostedBalance);
            }
        }
    }

    function _computeBoost(uint256 _scaledDeposit, uint256 _votingWeight)
        private
        view
        returns (uint256 boost)
    {

        if (_votingWeight == 0) return MIN_BOOST;

        uint256 sqrt1 = Root.sqrt(_scaledDeposit * 1e6);
        uint256 sqrt2 = Root.sqrt(sqrt1);
        uint256 denominator = sqrt1 * sqrt2;
        boost =
            (((StableMath.min(_votingWeight, MAX_VMTA) * boostCoeff) / 10) * 1e18) /
            denominator;
        boost = StableMath.min(MAX_BOOST, StableMath.max(MIN_BOOST, FLOOR + boost));
    }
}

contract Initializable {

    bool private initialized;

    bool private initializing;

    modifier initializer() {

        require(
            initializing || isConstructor() || !initialized,
            "Contract instance has already been initialized"
        );

        bool isTopLevelCall = !initializing;
        if (isTopLevelCall) {
            initializing = true;
            initialized = true;
        }

        _;

        if (isTopLevelCall) {
            initializing = false;
        }
    }

    function isConstructor() private view returns (bool) {

        address self = address(this);
        uint256 cs;
        assembly {
            cs := extcodesize(self)
        }
        return cs == 0;
    }

    uint256[50] private ______gap;
}

library SafeCast {

    function toUint128(uint256 value) internal pure returns (uint128) {

        require(value < 2**128, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    function toUint64(uint256 value) internal pure returns (uint64) {

        require(value < 2**64, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    function toUint32(uint256 value) internal pure returns (uint32) {

        require(value < 2**32, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    function toUint16(uint256 value) internal pure returns (uint16) {

        require(value < 2**16, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    function toUint8(uint256 value) internal pure returns (uint8) {

        require(value < 2**8, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    function toUint256(int256 value) internal pure returns (uint256) {

        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    function toInt128(int256 value) internal pure returns (int128) {

        require(value >= -2**127 && value < 2**127, "SafeCast: value doesn't fit in 128 bits");
        return int128(value);
    }

    function toInt64(int256 value) internal pure returns (int64) {

        require(value >= -2**63 && value < 2**63, "SafeCast: value doesn't fit in 64 bits");
        return int64(value);
    }

    function toInt32(int256 value) internal pure returns (int32) {

        require(value >= -2**31 && value < 2**31, "SafeCast: value doesn't fit in 32 bits");
        return int32(value);
    }

    function toInt16(int256 value) internal pure returns (int16) {

        require(value >= -2**15 && value < 2**15, "SafeCast: value doesn't fit in 16 bits");
        return int16(value);
    }

    function toInt8(int256 value) internal pure returns (int8) {

        require(value >= -2**7 && value < 2**7, "SafeCast: value doesn't fit in 8 bits");
        return int8(value);
    }

    function toInt256(uint256 value) internal pure returns (int256) {

        require(value < 2**255, "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}

contract BoostedSavingsVault_imbtc_mainnet_2 is
    IBoostedVaultWithLockup,
    Initializable,
    InitializableRewardsDistributionRecipient,
    BoostedTokenWrapper
{

    using SafeERC20 for IERC20;
    using StableMath for uint256;
    using SafeCast for uint256;

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount, address payer);
    event Withdrawn(address indexed user, uint256 amount);
    event Poked(address indexed user);
    event RewardPaid(address indexed user, uint256 reward);

    IERC20 public immutable rewardsToken;

    uint64 public constant DURATION = 7 days;
    uint256 public constant LOCKUP = 26 weeks;
    uint64 public constant UNLOCK = 33e16;

    uint256 public periodFinish;
    uint256 public rewardRate;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    mapping(address => UserData) public userData;
    mapping(address => Reward[]) public userRewards;
    mapping(address => uint64) public userClaim;

    struct UserData {
        uint128 rewardPerTokenPaid;
        uint128 rewards;
        uint64 lastAction;
        uint64 rewardCount;
    }

    struct Reward {
        uint64 start;
        uint64 finish;
        uint128 rate;
    }

    constructor(
        address _nexus,
        address _stakingToken,
        address _boostDirector,
        uint256 _priceCoeff,
        uint256 _coeff,
        address _rewardsToken
    )
        InitializableRewardsDistributionRecipient(_nexus)
        BoostedTokenWrapper(_stakingToken, _boostDirector, _priceCoeff, _coeff)
    {
        rewardsToken = IERC20(_rewardsToken);
    }

    function initialize(
        address _rewardsDistributor,
        string calldata _nameArg,
        string calldata _symbolArg
    ) external initializer {

        InitializableRewardsDistributionRecipient._initialize(_rewardsDistributor);
        BoostedTokenWrapper._initialize(_nameArg, _symbolArg);
    }

    modifier updateReward(address _account) {

        _updateReward(_account);
        _;
    }

    function _updateReward(address _account) internal {

        uint256 currentTime = block.timestamp;
        uint64 currentTime64 = SafeCast.toUint64(currentTime);

        (uint256 newRewardPerToken, uint256 lastApplicableTime) = _rewardPerToken();
        if (newRewardPerToken > 0) {
            rewardPerTokenStored = newRewardPerToken;
            lastUpdateTime = lastApplicableTime;

            if (_account != address(0)) {
                UserData memory data = userData[_account];
                uint256 earned_ = _earned(_account, data.rewardPerTokenPaid, newRewardPerToken);

                if (earned_ > 0) {
                    uint256 unlocked = earned_.mulTruncate(UNLOCK);
                    uint256 locked = earned_ - unlocked;

                    userRewards[_account].push(
                        Reward({
                            start: SafeCast.toUint64(LOCKUP + data.lastAction),
                            finish: SafeCast.toUint64(LOCKUP + currentTime),
                            rate: SafeCast.toUint128(locked / (currentTime - data.lastAction))
                        })
                    );

                    userData[_account] = UserData({
                        rewardPerTokenPaid: SafeCast.toUint128(newRewardPerToken),
                        rewards: SafeCast.toUint128(unlocked + data.rewards),
                        lastAction: currentTime64,
                        rewardCount: data.rewardCount + 1
                    });
                } else {
                    userData[_account] = UserData({
                        rewardPerTokenPaid: SafeCast.toUint128(newRewardPerToken),
                        rewards: data.rewards,
                        lastAction: currentTime64,
                        rewardCount: data.rewardCount
                    });
                }
            }
        } else if (_account != address(0)) {
            userData[_account].lastAction = currentTime64;
        }
    }

    modifier updateBoost(address _account) {

        _;
        _setBoost(_account);
    }


    function stake(uint256 _amount)
        external
        override
        updateReward(msg.sender)
        updateBoost(msg.sender)
    {

        _stake(msg.sender, _amount);
    }

    function stake(address _beneficiary, uint256 _amount)
        external
        override
        updateReward(_beneficiary)
        updateBoost(_beneficiary)
    {

        _stake(_beneficiary, _amount);
    }

    function exit() external override updateReward(msg.sender) updateBoost(msg.sender) {

        _withdraw(rawBalanceOf(msg.sender));
        (uint256 first, uint256 last) = _unclaimedEpochs(msg.sender);
        _claimRewards(first, last);
    }

    function exit(uint256 _first, uint256 _last)
        external
        override
        updateReward(msg.sender)
        updateBoost(msg.sender)
    {

        _withdraw(rawBalanceOf(msg.sender));
        _claimRewards(_first, _last);
    }

    function withdraw(uint256 _amount)
        external
        override
        updateReward(msg.sender)
        updateBoost(msg.sender)
    {

        _withdraw(_amount);
    }

    function withdrawAndUnwrap(
        uint256 _amount,
        uint256 _minAmountOut,
        address _output,
        address _beneficiary,
        address _router,
        bool _isBassetOut
    )
        external
        override
        updateReward(msg.sender)
        updateBoost(msg.sender)
        returns (uint256 outputQuantity)
    {

        require(_amount > 0, "Cannot withdraw 0");

        _reduceRaw(_amount);

        (, , outputQuantity) = ISavingsContractV3(address(stakingToken)).redeemAndUnwrap(
            _amount,
            true,
            _minAmountOut,
            _output,
            _beneficiary,
            _router,
            _isBassetOut
        );

        emit Withdrawn(msg.sender, _amount);
    }

    function claimReward() external override updateReward(msg.sender) updateBoost(msg.sender) {

        uint256 unlocked = userData[msg.sender].rewards;
        userData[msg.sender].rewards = 0;

        if (unlocked > 0) {
            rewardsToken.safeTransfer(msg.sender, unlocked);
            emit RewardPaid(msg.sender, unlocked);
        }
    }

    function claimRewards() external override updateReward(msg.sender) updateBoost(msg.sender) {

        (uint256 first, uint256 last) = _unclaimedEpochs(msg.sender);

        _claimRewards(first, last);
    }

    function claimRewards(uint256 _first, uint256 _last)
        external
        override
        updateReward(msg.sender)
        updateBoost(msg.sender)
    {

        _claimRewards(_first, _last);
    }

    function pokeBoost(address _account)
        external
        override
        updateReward(_account)
        updateBoost(_account)
    {

        emit Poked(_account);
    }


    function _claimRewards(uint256 _first, uint256 _last) internal {

        (uint256 unclaimed, uint256 lastTimestamp) = _unclaimedRewards(msg.sender, _first, _last);
        userClaim[msg.sender] = uint64(lastTimestamp);

        uint256 unlocked = userData[msg.sender].rewards;
        userData[msg.sender].rewards = 0;

        uint256 total = unclaimed + unlocked;

        if (total > 0) {
            rewardsToken.safeTransfer(msg.sender, total);

            emit RewardPaid(msg.sender, total);
        }
    }

    function _stake(address _beneficiary, uint256 _amount) internal {

        require(_amount > 0, "Cannot stake 0");
        require(_beneficiary != address(0), "Invalid beneficiary address");

        _stakeRaw(_beneficiary, _amount);
        emit Staked(_beneficiary, _amount, msg.sender);
    }

    function _withdraw(uint256 _amount) internal {

        require(_amount > 0, "Cannot withdraw 0");
        _withdrawRaw(_amount);
        emit Withdrawn(msg.sender, _amount);
    }


    function getRewardToken() external view override returns (IERC20) {

        return rewardsToken;
    }

    function lastTimeRewardApplicable() public view override returns (uint256) {

        return StableMath.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view override returns (uint256) {

        (uint256 rewardPerToken_, ) = _rewardPerToken();
        return rewardPerToken_;
    }

    function _rewardPerToken()
        internal
        view
        returns (uint256 rewardPerToken_, uint256 lastTimeRewardApplicable_)
    {

        uint256 lastApplicableTime = lastTimeRewardApplicable(); // + 1 SLOAD
        uint256 timeDelta = lastApplicableTime - lastUpdateTime; // + 1 SLOAD
        if (timeDelta == 0) {
            return (rewardPerTokenStored, lastApplicableTime);
        }
        uint256 rewardUnitsToDistribute = rewardRate * timeDelta; // + 1 SLOAD
        uint256 supply = totalSupply(); // + 1 SLOAD
        if (supply == 0 || rewardUnitsToDistribute == 0) {
            return (rewardPerTokenStored, lastApplicableTime);
        }
        uint256 unitsToDistributePerToken = rewardUnitsToDistribute.divPrecisely(supply);
        return (rewardPerTokenStored + unitsToDistributePerToken, lastApplicableTime); // + 1 SLOAD
    }

    function earned(address _account) public view override returns (uint256) {

        uint256 newEarned = _earned(
            _account,
            userData[_account].rewardPerTokenPaid,
            rewardPerToken()
        );
        uint256 immediatelyUnlocked = newEarned.mulTruncate(UNLOCK);
        return immediatelyUnlocked + userData[_account].rewards;
    }

    function unclaimedRewards(address _account)
        external
        view
        override
        returns (
            uint256 amount,
            uint256 first,
            uint256 last
        )
    {

        (first, last) = _unclaimedEpochs(_account);
        (uint256 unlocked, ) = _unclaimedRewards(_account, first, last);
        amount = unlocked + earned(_account);
    }

    function _earned(
        address _account,
        uint256 _userRewardPerTokenPaid,
        uint256 _currentRewardPerToken
    ) internal view returns (uint256) {

        uint256 userRewardDelta = _currentRewardPerToken - _userRewardPerTokenPaid; // + 1 SLOAD
        if (userRewardDelta == 0) {
            return 0;
        }
        uint256 userNewReward = balanceOf(_account).mulTruncate(userRewardDelta); // + 1 SLOAD
        return userNewReward;
    }

    function _unclaimedEpochs(address _account)
        internal
        view
        returns (uint256 first, uint256 last)
    {

        uint64 lastClaim = userClaim[_account];

        uint256 firstUnclaimed = _findFirstUnclaimed(lastClaim, _account);
        uint256 lastUnclaimed = _findLastUnclaimed(_account);

        return (firstUnclaimed, lastUnclaimed);
    }

    function _unclaimedRewards(
        address _account,
        uint256 _first,
        uint256 _last
    ) internal view returns (uint256 amount, uint256 latestTimestamp) {

        uint256 currentTime = block.timestamp;
        uint64 lastClaim = userClaim[_account];

        uint256 totalLen = userRewards[_account].length;
        if (_first == 0 && _last == 0) {
            if (totalLen == 0 || currentTime <= userRewards[_account][0].start) {
                return (0, currentTime);
            }
        }
        if (_first > 0) {
            require(
                lastClaim >= userRewards[_account][_first - 1].finish,
                "Invalid _first arg: Must claim earlier entries"
            );
        }

        uint256 count = _last - _first + 1;
        for (uint256 i = 0; i < count; i++) {
            uint256 id = _first + i;
            Reward memory rwd = userRewards[_account][id];

            require(currentTime >= rwd.start && lastClaim <= rwd.finish, "Invalid epoch");

            uint256 endTime = StableMath.min(rwd.finish, currentTime);
            uint256 startTime = StableMath.max(rwd.start, lastClaim);
            uint256 unclaimed = (endTime - startTime) * rwd.rate;

            amount += unclaimed;
        }

        latestTimestamp = StableMath.min(currentTime, userRewards[_account][_last].finish);
    }

    function _findFirstUnclaimed(uint64 _lastClaim, address _account)
        internal
        view
        returns (uint256 first)
    {

        uint256 len = userRewards[_account].length;
        if (len == 0) return 0;
        uint256 min = 0;
        uint256 max = len - 1;
        for (uint256 i = 0; i < 128; i++) {
            if (min >= max) break;
            uint256 mid = (min + max + 1) / 2;
            if (_lastClaim > userRewards[_account][mid].start) {
                min = mid;
            } else {
                max = mid - 1;
            }
        }
        return min;
    }

    function _findLastUnclaimed(address _account) internal view returns (uint256 first) {

        uint256 len = userRewards[_account].length;
        if (len == 0) return 0;
        uint256 min = 0;
        uint256 max = len - 1;
        for (uint256 i = 0; i < 128; i++) {
            if (min >= max) break;
            uint256 mid = (min + max + 1) / 2;
            if (block.timestamp > userRewards[_account][mid].start) {
                min = mid;
            } else {
                max = mid - 1;
            }
        }
        return min;
    }


    function notifyRewardAmount(uint256 _reward)
        external
        override
        onlyRewardsDistributor
        updateReward(address(0))
    {

        require(_reward < 1e24, "Cannot notify with more than a million units");

        uint256 currentTime = block.timestamp;
        if (currentTime >= periodFinish) {
            rewardRate = _reward / DURATION;
        }
        else {
            uint256 remaining = periodFinish - currentTime;
            uint256 leftover = remaining * rewardRate;
            rewardRate = (_reward + leftover) / DURATION;
        }

        lastUpdateTime = currentTime;
        periodFinish = currentTime + DURATION;

        emit RewardAdded(_reward);
    }
}