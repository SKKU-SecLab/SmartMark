pragma solidity 0.5.16;

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


    function getRewardToken() external view returns (IERC20);


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

contract InitializableModule2 is ModuleKeys {

    INexus public constant nexus = INexus(0xAFcE80b19A8cE13DEc0739a1aaB7A028d6845Eb3);

    modifier onlyGovernor() {

        require(msg.sender == _governor(), "Only governor can execute");
        _;
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

contract InitializableRewardsDistributionRecipient is
    IRewardsDistributionRecipient,
    InitializableModule2
{

    function notifyRewardAmount(uint256 reward) external;


    function getRewardToken() external view returns (IERC20);


    address public rewardsDistributor;

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

contract IERC20WithCheckpointing {

    function balanceOf(address _owner) public view returns (uint256);


    function balanceOfAt(address _owner, uint256 _blockNumber) public view returns (uint256);


    function totalSupply() public view returns (uint256);


    function totalSupplyAt(uint256 _blockNumber) public view returns (uint256);

}

contract IIncentivisedVotingLockup is IERC20WithCheckpointing {

    function getLastUserPoint(address _addr)
        external
        view
        returns (
            int128 bias,
            int128 slope,
            uint256 ts
        );


    function createLock(uint256 _value, uint256 _unlockTime) external;


    function withdraw() external;


    function increaseLockAmount(uint256 _value) external;


    function increaseLockLength(uint256 _unlockTime) external;


    function eject(address _user) external;


    function expireContract() external;


    function claimReward() public;


    function earned(address _account) public view returns (uint256);

}


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        callOptionalReturn(
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
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, newAllowance)
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeERC20: decreased allowance below zero"
        );
        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, newAllowance)
        );
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract InitializableReentrancyGuard {

    bool private _notEntered;

    function _initialize() internal {

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

    using SafeMath for uint256;

    uint256 private constant FULL_SCALE = 1e18;

    uint256 private constant RATIO_SCALE = 1e8;

    function getFullScale() internal pure returns (uint256) {

        return FULL_SCALE;
    }

    function getRatioScale() internal pure returns (uint256) {

        return RATIO_SCALE;
    }

    function scaleInteger(uint256 x) internal pure returns (uint256) {

        return x.mul(FULL_SCALE);
    }


    function mulTruncate(uint256 x, uint256 y) internal pure returns (uint256) {

        return mulTruncateScale(x, y, FULL_SCALE);
    }

    function mulTruncateScale(
        uint256 x,
        uint256 y,
        uint256 scale
    ) internal pure returns (uint256) {

        uint256 z = x.mul(y);
        return z.div(scale);
    }

    function mulTruncateCeil(uint256 x, uint256 y) internal pure returns (uint256) {

        uint256 scaled = x.mul(y);
        uint256 ceil = scaled.add(FULL_SCALE.sub(1));
        return ceil.div(FULL_SCALE);
    }

    function divPrecisely(uint256 x, uint256 y) internal pure returns (uint256) {

        uint256 z = x.mul(FULL_SCALE);
        return z.div(y);
    }


    function mulRatioTruncate(uint256 x, uint256 ratio) internal pure returns (uint256 c) {

        return mulTruncateScale(x, ratio, RATIO_SCALE);
    }

    function mulRatioTruncateCeil(uint256 x, uint256 ratio) internal pure returns (uint256) {

        uint256 scaled = x.mul(ratio);
        uint256 ceil = scaled.add(RATIO_SCALE.sub(1));
        return ceil.div(RATIO_SCALE);
    }

    function divRatioPrecisely(uint256 x, uint256 ratio) internal pure returns (uint256 c) {

        uint256 y = x.mul(RATIO_SCALE);
        return y.div(ratio);
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

    using SafeMath for uint256;

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
            r = (r.add(x.div(r))) >> 1;
            r = (r.add(x.div(r))) >> 1;
            r = (r.add(x.div(r))) >> 1;
            r = (r.add(x.div(r))) >> 1;
            r = (r.add(x.div(r))) >> 1;
            r = (r.add(x.div(r))) >> 1;
            r = (r.add(x.div(r))) >> 1; // Seven iterations should be enough
            uint256 r1 = x.div(r);

            return uint256(r < r1 ? r : r1);
        }
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

contract BoostedTokenWrapper is InitializableReentrancyGuard {

    using SafeMath for uint256;
    using StableMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public constant stakingToken = IERC20(0x30647a72Dc82d7Fbb1123EA74716aB8A317Eac19);
    IBoostDirector public constant boostDirector =
        IBoostDirector(0xBa05FD2f20AE15B0D3f20DDc6870FeCa6ACd3592);

    uint256 private _totalBoostedSupply;
    mapping(address => uint256) private _boostedBalances;
    mapping(address => uint256) private _rawBalances;

    uint256 private constant MIN_DEPOSIT = 1e18;
    uint256 private constant MAX_VMTA = 600000e18;
    uint256 private constant MAX_BOOST = 3e18;
    uint256 private constant MIN_BOOST = 1e18;
    uint256 private constant FLOOR = 98e16;
    uint256 public constant boostCoeff = 9;
    uint256 public constant priceCoeff = 1e17;

    function _initialize() internal {

        InitializableReentrancyGuard._initialize();
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

        _rawBalances[_beneficiary] = _rawBalances[_beneficiary].add(_amount);
        stakingToken.safeTransferFrom(msg.sender, address(this), _amount);
    }

    function _withdrawRaw(uint256 _amount) internal nonReentrant {

        _rawBalances[msg.sender] = _rawBalances[msg.sender].sub(_amount);
        stakingToken.safeTransfer(msg.sender, _amount);
    }

    function _reduceRaw(uint256 _amount) internal nonReentrant {

        _rawBalances[msg.sender] = _rawBalances[msg.sender].sub(_amount);
    }

    function _setBoost(address _account) internal {

        uint256 rawBalance = _rawBalances[_account];
        uint256 boostedBalance = _boostedBalances[_account];
        uint256 boost = MIN_BOOST;

        uint256 scaledBalance = (rawBalance * priceCoeff) / 1e18;
        if (rawBalance >= MIN_DEPOSIT) {
            uint256 votingWeight = boostDirector.getBalance(_account);
            boost = _computeBoost(scaledBalance, votingWeight);
        }

        uint256 newBoostedBalance = rawBalance.mulTruncate(boost);

        if (newBoostedBalance != boostedBalance) {
            _totalBoostedSupply = _totalBoostedSupply.sub(boostedBalance).add(newBoostedBalance);
            _boostedBalances[_account] = newBoostedBalance;
        }
    }

    function _computeBoost(uint256 _scaledDeposit, uint256 _votingWeight)
        private
        pure
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
}

contract BoostedSavingsVault_imusd_mainnet_2 is
    IBoostedVaultWithLockup,
    Initializable,
    InitializableRewardsDistributionRecipient,
    BoostedTokenWrapper
{

    using StableMath for uint256;
    using SafeCast for uint256;

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount, address payer);
    event Withdrawn(address indexed user, uint256 amount);
    event Poked(address indexed user);
    event RewardPaid(address indexed user, uint256 reward);

    IERC20 public constant rewardsToken = IERC20(0xa3BeD4E1c75D00fa6f4E5E6922DB7261B5E9AcD2);

    uint64 public constant DURATION = 7 days;
    uint256 public constant LOCKUP = 26 weeks;
    uint64 public constant UNLOCK = 2e17;

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

    function initialize(address _rewardsDistributor) external initializer {

        InitializableRewardsDistributionRecipient._initialize(_rewardsDistributor);
        BoostedTokenWrapper._initialize();
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
                uint256 earned = _earned(_account, data.rewardPerTokenPaid, newRewardPerToken);

                if (earned > 0) {
                    uint256 unlocked = earned.mulTruncate(UNLOCK);
                    uint256 locked = earned.sub(unlocked);

                    userRewards[_account].push(
                        Reward({
                            start: SafeCast.toUint64(LOCKUP.add(data.lastAction)),
                            finish: SafeCast.toUint64(LOCKUP.add(currentTime)),
                            rate: SafeCast.toUint128(locked.div(currentTime.sub(data.lastAction)))
                        })
                    );

                    userData[_account] = UserData({
                        rewardPerTokenPaid: SafeCast.toUint128(newRewardPerToken),
                        rewards: SafeCast.toUint128(unlocked.add(data.rewards)),
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


    function stake(uint256 _amount) external updateReward(msg.sender) updateBoost(msg.sender) {

        _stake(msg.sender, _amount);
    }

    function stake(address _beneficiary, uint256 _amount)
        external
        updateReward(_beneficiary)
        updateBoost(_beneficiary)
    {

        _stake(_beneficiary, _amount);
    }

    function exit() external updateReward(msg.sender) updateBoost(msg.sender) {

        _withdraw(rawBalanceOf(msg.sender));
        (uint256 first, uint256 last) = _unclaimedEpochs(msg.sender);
        _claimRewards(first, last);
    }

    function exit(uint256 _first, uint256 _last)
        external
        updateReward(msg.sender)
        updateBoost(msg.sender)
    {

        _withdraw(rawBalanceOf(msg.sender));
        _claimRewards(_first, _last);
    }

    function withdraw(uint256 _amount) external updateReward(msg.sender) updateBoost(msg.sender) {

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

    function claimReward() external updateReward(msg.sender) updateBoost(msg.sender) {

        uint256 unlocked = userData[msg.sender].rewards;
        userData[msg.sender].rewards = 0;

        if (unlocked > 0) {
            rewardsToken.safeTransfer(msg.sender, unlocked);
            emit RewardPaid(msg.sender, unlocked);
        }
    }

    function claimRewards() external updateReward(msg.sender) updateBoost(msg.sender) {

        (uint256 first, uint256 last) = _unclaimedEpochs(msg.sender);

        _claimRewards(first, last);
    }

    function claimRewards(uint256 _first, uint256 _last)
        external
        updateReward(msg.sender)
        updateBoost(msg.sender)
    {

        _claimRewards(_first, _last);
    }

    function pokeBoost(address _account) external updateReward(_account) updateBoost(_account) {

        emit Poked(_account);
    }


    function _claimRewards(uint256 _first, uint256 _last) internal {

        (uint256 unclaimed, uint256 lastTimestamp) = _unclaimedRewards(msg.sender, _first, _last);
        userClaim[msg.sender] = uint64(lastTimestamp);

        uint256 unlocked = userData[msg.sender].rewards;
        userData[msg.sender].rewards = 0;

        uint256 total = unclaimed.add(unlocked);

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


    function getRewardToken() external view returns (IERC20) {

        return rewardsToken;
    }

    function lastTimeRewardApplicable() public view returns (uint256) {

        return StableMath.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view returns (uint256) {

        (uint256 rewardPerToken_, ) = _rewardPerToken();
        return rewardPerToken_;
    }

    function _rewardPerToken()
        internal
        view
        returns (uint256 rewardPerToken_, uint256 lastTimeRewardApplicable_)
    {

        uint256 lastApplicableTime = lastTimeRewardApplicable(); // + 1 SLOAD
        uint256 timeDelta = lastApplicableTime.sub(lastUpdateTime); // + 1 SLOAD
        if (timeDelta == 0) {
            return (rewardPerTokenStored, lastApplicableTime);
        }
        uint256 rewardUnitsToDistribute = rewardRate.mul(timeDelta); // + 1 SLOAD
        uint256 supply = totalSupply(); // + 1 SLOAD
        if (supply == 0 || rewardUnitsToDistribute == 0) {
            return (rewardPerTokenStored, lastApplicableTime);
        }
        uint256 unitsToDistributePerToken = rewardUnitsToDistribute.divPrecisely(supply);
        return (rewardPerTokenStored.add(unitsToDistributePerToken), lastApplicableTime); // + 1 SLOAD
    }

    function earned(address _account) public view returns (uint256) {

        uint256 newEarned = _earned(
            _account,
            userData[_account].rewardPerTokenPaid,
            rewardPerToken()
        );
        uint256 immediatelyUnlocked = newEarned.mulTruncate(UNLOCK);
        return immediatelyUnlocked.add(userData[_account].rewards);
    }

    function unclaimedRewards(address _account)
        external
        view
        returns (
            uint256 amount,
            uint256 first,
            uint256 last
        )
    {

        (first, last) = _unclaimedEpochs(_account);
        (uint256 unlocked, ) = _unclaimedRewards(_account, first, last);
        amount = unlocked.add(earned(_account));
    }

    function _earned(
        address _account,
        uint256 _userRewardPerTokenPaid,
        uint256 _currentRewardPerToken
    ) internal view returns (uint256) {

        uint256 userRewardDelta = _currentRewardPerToken.sub(_userRewardPerTokenPaid); // + 1 SLOAD
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
                lastClaim >= userRewards[_account][_first.sub(1)].finish,
                "Invalid _first arg: Must claim earlier entries"
            );
        }

        uint256 count = _last.sub(_first).add(1);
        for (uint256 i = 0; i < count; i++) {
            uint256 id = _first.add(i);
            Reward memory rwd = userRewards[_account][id];

            require(currentTime >= rwd.start && lastClaim <= rwd.finish, "Invalid epoch");

            uint256 endTime = StableMath.min(rwd.finish, currentTime);
            uint256 startTime = StableMath.max(rwd.start, lastClaim);
            uint256 unclaimed = endTime.sub(startTime).mul(rwd.rate);

            amount = amount.add(unclaimed);
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
            uint256 mid = (min.add(max).add(1)).div(2);
            if (_lastClaim > userRewards[_account][mid].start) {
                min = mid;
            } else {
                max = mid.sub(1);
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
            uint256 mid = (min.add(max).add(1)).div(2);
            if (now > userRewards[_account][mid].start) {
                min = mid;
            } else {
                max = mid.sub(1);
            }
        }
        return min;
    }


    function notifyRewardAmount(uint256 _reward)
        external
        onlyRewardsDistributor
        updateReward(address(0))
    {

        require(_reward < 1e24, "Cannot notify with more than a million units");

        uint256 currentTime = block.timestamp;
        if (currentTime >= periodFinish) {
            rewardRate = _reward.div(DURATION);
        }
        else {
            uint256 remaining = periodFinish.sub(currentTime);
            uint256 leftover = remaining.mul(rewardRate);
            rewardRate = _reward.add(leftover).div(DURATION);
        }

        lastUpdateTime = currentTime;
        periodFinish = currentTime.add(DURATION);

        emit RewardAdded(_reward);
    }
}