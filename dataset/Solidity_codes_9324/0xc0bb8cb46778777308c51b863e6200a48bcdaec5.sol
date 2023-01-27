
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

library MathUtil {

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }
}
interface IStakingProxy {

    function getBalance() external view returns(uint256);


    function withdraw(uint256 _amount) external;


    function stake() external;


    function distribute() external;

}
interface IRewardStaking {

    function stakeFor(address, uint256) external;

    function stake( uint256) external;

    function withdraw(uint256 amount, bool claim) external;

    function withdrawAndUnwrap(uint256 amount, bool claim) external;

    function earned(address account) external view returns (uint256);

    function getReward() external;

    function getReward(address _account, bool _claimExtras) external;

    function extraRewardsLength() external view returns (uint256);

    function extraRewards(uint256 _pid) external view returns (address);

    function rewardToken() external view returns (address);

    function balanceOf(address _account) external view returns (uint256);

}
library BoringMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

        require((c = a + b) >= b, "BoringMath: Add Overflow");
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {

        require((c = a - b) <= a, "BoringMath: Underflow");
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

        require(b == 0 || (c = a * b) / b == a, "BoringMath: Mul Overflow");
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "BoringMath: division by zero");
        return a / b;
    }

    function to128(uint256 a) internal pure returns (uint128 c) {

        require(a <= uint128(-1), "BoringMath: uint128 Overflow");
        c = uint128(a);
    }

    function to64(uint256 a) internal pure returns (uint64 c) {

        require(a <= uint64(-1), "BoringMath: uint64 Overflow");
        c = uint64(a);
    }

    function to32(uint256 a) internal pure returns (uint32 c) {

        require(a <= uint32(-1), "BoringMath: uint32 Overflow");
        c = uint32(a);
    }

    function to40(uint256 a) internal pure returns (uint40 c) {

        require(a <= uint40(-1), "BoringMath: uint40 Overflow");
        c = uint40(a);
    }

    function to112(uint256 a) internal pure returns (uint112 c) {

        require(a <= uint112(-1), "BoringMath: uint112 Overflow");
        c = uint112(a);
    }

    function to224(uint256 a) internal pure returns (uint224 c) {

        require(a <= uint224(-1), "BoringMath: uint224 Overflow");
        c = uint224(a);
    }

    function to208(uint256 a) internal pure returns (uint208 c) {

        require(a <= uint208(-1), "BoringMath: uint208 Overflow");
        c = uint208(a);
    }

    function to216(uint256 a) internal pure returns (uint216 c) {

        require(a <= uint216(-1), "BoringMath: uint216 Overflow");
        c = uint216(a);
    }
}

library BoringMath128 {

    function add(uint128 a, uint128 b) internal pure returns (uint128 c) {

        require((c = a + b) >= b, "BoringMath: Add Overflow");
    }

    function sub(uint128 a, uint128 b) internal pure returns (uint128 c) {

        require((c = a - b) <= a, "BoringMath: Underflow");
    }
}

library BoringMath64 {

    function add(uint64 a, uint64 b) internal pure returns (uint64 c) {

        require((c = a + b) >= b, "BoringMath: Add Overflow");
    }

    function sub(uint64 a, uint64 b) internal pure returns (uint64 c) {

        require((c = a - b) <= a, "BoringMath: Underflow");
    }
}

library BoringMath32 {

    function add(uint32 a, uint32 b) internal pure returns (uint32 c) {

        require((c = a + b) >= b, "BoringMath: Add Overflow");
    }

    function sub(uint32 a, uint32 b) internal pure returns (uint32 c) {

        require((c = a - b) <= a, "BoringMath: Underflow");
    }

    function mul(uint32 a, uint32 b) internal pure returns (uint32 c) {

        require(b == 0 || (c = a * b) / b == a, "BoringMath: Mul Overflow");
    }

    function div(uint32 a, uint32 b) internal pure returns (uint32) {

        require(b > 0, "BoringMath: division by zero");
        return a / b;
    }
}


library BoringMath112 {

    function add(uint112 a, uint112 b) internal pure returns (uint112 c) {

        require((c = a + b) >= b, "BoringMath: Add Overflow");
    }

    function sub(uint112 a, uint112 b) internal pure returns (uint112 c) {

        require((c = a - b) <= a, "BoringMath: Underflow");
    }

    function mul(uint112 a, uint112 b) internal pure returns (uint112 c) {

        require(b == 0 || (c = a * b) / b == a, "BoringMath: Mul Overflow");
    }
    
    function div(uint112 a, uint112 b) internal pure returns (uint112) {

        require(b > 0, "BoringMath: division by zero");
        return a / b;
    }
}

library BoringMath224 {

    function add(uint224 a, uint224 b) internal pure returns (uint224 c) {

        require((c = a + b) >= b, "BoringMath: Add Overflow");
    }

    function sub(uint224 a, uint224 b) internal pure returns (uint224 c) {

        require((c = a - b) <= a, "BoringMath: Underflow");
    }

    function mul(uint224 a, uint224 b) internal pure returns (uint224 c) {

        require(b == 0 || (c = a * b) / b == a, "BoringMath: Mul Overflow");
    }
    
    function div(uint224 a, uint224 b) internal pure returns (uint224) {

        require(b > 0, "BoringMath: division by zero");
        return a / b;
    }
}
interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}
library SafeMathUpgradeable {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}
library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
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

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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

library SafeERC20Upgradeable {

    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;

    function safeTransfer(IERC20Upgradeable token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20Upgradeable token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20Upgradeable token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
library MathUpgradeable {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}




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
        return !AddressUpgradeable.isContract(address(this));
    }
}

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}


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
}


abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
    uint256[49] private __gap;
}
interface IGac {


    function paused() external view returns (bool);

    function hasRole(bytes32 role, address account) external view returns (bool);

    function getRoleMember(bytes32 role, uint256 index) external view returns (address);

}

contract GlobalAccessControlManaged is PausableUpgradeable {

    IGac public gac;

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant UNPAUSER_ROLE = keccak256("UNPAUSER_ROLE");


    function __GlobalAccessControlManaged_init(address _globalAccessControl)
        public
        initializer
    {

        __Pausable_init_unchained();
        gac = IGac(_globalAccessControl);
    }


    function _onlyRole(bytes32 role) internal {

        require(gac.hasRole(role, msg.sender), "GAC: invalid-caller-role");
    }

    modifier gacPausable() {

        require(!gac.paused(), "global-paused");
        require(!paused(), "local-paused");
        _;
    }


    function pause() external {

        require(gac.hasRole(PAUSER_ROLE, msg.sender));
        _pause();
    }

    function unpause() external {

        require(gac.hasRole(UNPAUSER_ROLE, msg.sender));
        _unpause();
    }
}

contract StakedCitadelLocker is
    Initializable,
    ReentrancyGuardUpgradeable,
    GlobalAccessControlManaged
{

    using BoringMath for uint256;
    using BoringMath224 for uint224;
    using BoringMath112 for uint112;
    using BoringMath32 for uint32;
    using SafeERC20Upgradeable for IERC20Upgradeable;


    struct Reward {
        bool useBoost;
        uint40 periodFinish;
        uint208 rewardRate;
        uint40 lastUpdateTime;
        uint208 rewardPerTokenStored;
    }
    struct Balances {
        uint112 locked;
        uint112 boosted;
        uint32 nextUnlockIndex;
    }
    struct LockedBalance {
        uint112 amount;
        uint112 boosted;
        uint32 unlockTime;
    }
    struct EarnedData {
        address token;
        uint256 amount;
    }
    struct Epoch {
        uint224 supply; //epoch boosted supply
        uint32 date; //epoch start date
    }

    bytes32 public constant CONTRACT_GOVERNANCE_ROLE =
        keccak256("CONTRACT_GOVERNANCE_ROLE");

    bytes32 public constant TREASURY_GOVERNANCE_ROLE =
        keccak256("TREASURY_GOVERNANCE_ROLE");

    bytes32 public constant TECH_OPERATIONS_ROLE =
        keccak256("TECH_OPERATIONS_ROLE");

    IERC20Upgradeable public stakingToken; // xCTDL token

    address[] public rewardTokens;
    mapping(address => Reward) public rewardData;

    uint256 public constant rewardsDuration = 86400 * 21; // 21 days

    uint256 public constant lockDuration = 86400 * 7 * 21; // 21 weeks

    mapping(address => mapping(address => bool)) public rewardDistributors;

    mapping(address => mapping(address => uint256))
        public userRewardPerTokenPaid;
    mapping(address => mapping(address => uint256)) public rewards;

    uint256 public lockedSupply;
    uint256 public boostedSupply;
    Epoch[] public epochs;

    mapping(address => Balances) public balances;
    mapping(address => LockedBalance[]) public userLocks;

    address public boostPayment = address(0);
    uint256 public maximumBoostPayment = 0;
    uint256 public boostRate = 10000;
    uint256 public nextMaximumBoostPayment = 0;
    uint256 public nextBoostRate = 10000;
    uint256 public constant denominator = 10000;

    uint256 public minimumStake = 10000;
    uint256 public maximumStake = 10000;
    address public stakingProxy = address(0);
    uint256 public constant stakeOffsetOnLock = 500; //allow broader range for staking when depositing

    uint256 public kickRewardPerEpoch = 100;
    uint256 public kickRewardEpochDelay = 4;

    bool public isShutdown = false;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => mapping(address => uint256)) public cumulativeClaimed;

    mapping(address => uint256) public cumulativeDistributed;


    function initialize(
        address _stakingToken,
        address _gac,
        string calldata name,
        string calldata symbol
    ) public initializer {

        require(_stakingToken != address(0)); // dev: _stakingToken address should not be zero
        stakingToken = IERC20Upgradeable(_stakingToken);

        _name = name;
        _symbol = symbol;
        _decimals = 18;

        uint256 currentEpoch = block.timestamp.div(rewardsDuration).mul(
            rewardsDuration
        );
        epochs.push(Epoch({supply: 0, date: uint32(currentEpoch)}));

        __ReentrancyGuard_init();
        __GlobalAccessControlManaged_init(_gac);
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function version() public view returns (uint256) {

        return 2;
    }


    function addReward(
        address _rewardsToken,
        address _distributor,
        bool _useBoost
    ) public gacPausable {

        _onlyRole(CONTRACT_GOVERNANCE_ROLE);
        require(rewardData[_rewardsToken].lastUpdateTime == 0);
        rewardTokens.push(_rewardsToken);
        rewardData[_rewardsToken].lastUpdateTime = uint40(block.timestamp);
        rewardData[_rewardsToken].periodFinish = uint40(block.timestamp);
        rewardData[_rewardsToken].useBoost = _useBoost;
        rewardDistributors[_rewardsToken][_distributor] = true;
    }

    function approveRewardDistributor(
        address _rewardsToken,
        address _distributor,
        bool _approved
    ) external gacPausable {

        _onlyRole(CONTRACT_GOVERNANCE_ROLE);
        require(rewardData[_rewardsToken].lastUpdateTime > 0);
        rewardDistributors[_rewardsToken][_distributor] = _approved;
    }

    function setStakingContract(address _staking)
        external
        gacPausable
    {   

        _onlyRole(CONTRACT_GOVERNANCE_ROLE);
        require(stakingProxy == address(0), "!assign");

        stakingProxy = _staking;
    }

    function setStakeLimits(uint256 _minimum, uint256 _maximum)
        external
        gacPausable
    {

        _onlyRole(CONTRACT_GOVERNANCE_ROLE);
        require(_minimum <= denominator, "min range");
        require(_maximum <= denominator, "max range");
        require(_minimum <= _maximum, "min range");
        minimumStake = _minimum;
        maximumStake = _maximum;
        updateStakeRatio(0);
    }

    function setBoost(
        uint256 _max,
        uint256 _rate,
        address _receivingAddress
    ) external gacPausable {

        _onlyRole(CONTRACT_GOVERNANCE_ROLE);
        require(_max < 1500, "over max payment"); //max 15%
        require(_rate < 30000, "over max rate"); //max 3x
        require(_receivingAddress != address(0), "invalid address"); //must point somewhere valid
        nextMaximumBoostPayment = _max;
        nextBoostRate = _rate;
        boostPayment = _receivingAddress;
    }

    function setKickIncentive(uint256 _rate, uint256 _delay)
        external
        gacPausable
    {

        _onlyRole(CONTRACT_GOVERNANCE_ROLE);
        require(_rate <= 500, "over max rate"); //max 5% per epoch
        require(_delay >= 2, "min delay"); //minimum 2 epochs of grace
        kickRewardPerEpoch = _rate;
        kickRewardEpochDelay = _delay;
    }

    function shutdown() external {

        _onlyRole(CONTRACT_GOVERNANCE_ROLE);
        isShutdown = true;
    }

    function getRewardTokens() external view returns (address[] memory) {

        uint256 numTokens = rewardTokens.length;
        address[] memory tokens = new address[](numTokens);

        for (uint256 i = 0; i < numTokens; i++) {
            tokens[i] = rewardTokens[i];
        }
        return tokens;
    }

    function getCumulativeClaimedRewards(
        address _account,
        address _rewardsToken
    ) external view returns (uint256) {

        return cumulativeClaimed[_account][_rewardsToken];
    }

    function _rewardPerToken(address _rewardsToken)
        internal
        view
        returns (uint256)
    {

        if (boostedSupply == 0) {
            return rewardData[_rewardsToken].rewardPerTokenStored;
        }
        return
            uint256(rewardData[_rewardsToken].rewardPerTokenStored).add(
                _lastTimeRewardApplicable(
                    rewardData[_rewardsToken].periodFinish
                )
                    .sub(rewardData[_rewardsToken].lastUpdateTime)
                    .mul(rewardData[_rewardsToken].rewardRate)
                    .mul(1e18)
                    .div(
                        rewardData[_rewardsToken].useBoost
                            ? boostedSupply
                            : lockedSupply
                    )
            );
    }

    function _earned(
        address _user,
        address _rewardsToken,
        uint256 _balance
    ) internal view returns (uint256) {

        return
            _balance
                .mul(
                    _rewardPerToken(_rewardsToken).sub(
                        userRewardPerTokenPaid[_user][_rewardsToken]
                    )
                )
                .div(1e18)
                .add(rewards[_user][_rewardsToken]);
    }

    function _lastTimeRewardApplicable(uint256 _finishTime)
        internal
        view
        returns (uint256)
    {

        return MathUpgradeable.min(block.timestamp, _finishTime);
    }

    function lastTimeRewardApplicable(address _rewardsToken)
        public
        view
        returns (uint256)
    {

        return
            _lastTimeRewardApplicable(rewardData[_rewardsToken].periodFinish);
    }

    function rewardPerToken(address _rewardsToken)
        external
        view
        returns (uint256)
    {

        return _rewardPerToken(_rewardsToken);
    }

    function getRewardForDuration(address _rewardsToken)
        external
        view
        returns (uint256)
    {

        return
            uint256(rewardData[_rewardsToken].rewardRate).mul(rewardsDuration);
    }

    function claimableRewards(address _account)
        external
        view
        returns (EarnedData[] memory userRewards)
    {

        userRewards = new EarnedData[](rewardTokens.length);
        Balances storage userBalance = balances[_account];
        uint256 boostedBal = userBalance.boosted;
        for (uint256 i = 0; i < userRewards.length; i++) {
            address token = rewardTokens[i];
            userRewards[i].token = token;
            userRewards[i].amount = _earned(
                _account,
                token,
                rewardData[token].useBoost ? boostedBal : userBalance.locked
            );
        }
        return userRewards;
    }

    function claimableRewardForToken(address _account, address _rewardToken)
        external
        view
        returns (EarnedData memory userReward)
    {

        Balances storage userBalance = balances[_account];
        return
            EarnedData(
                _rewardToken,
                _earned(
                    _account,
                    _rewardToken,
                    rewardData[_rewardToken].useBoost
                        ? userBalance.boosted
                        : userBalance.locked
                )
            );
    }

    function rewardWeightOf(address _user)
        external
        view
        returns (uint256 amount)
    {

        return balances[_user].boosted;
    }

    function lockedBalanceOf(address _user)
        external
        view
        returns (uint256 amount)
    {

        return balances[_user].locked;
    }

    function balanceOf(address _user) external view returns (uint256 amount) {

        LockedBalance[] storage locks = userLocks[_user];
        Balances storage userBalance = balances[_user];
        uint256 nextUnlockIndex = userBalance.nextUnlockIndex;

        amount = balances[_user].boosted;

        uint256 locksLength = locks.length;
        for (uint256 i = nextUnlockIndex; i < locksLength; i++) {
            if (locks[i].unlockTime <= block.timestamp) {
                amount = amount.sub(locks[i].boosted);
            } else {
                break;
            }
        }

        uint256 currentEpoch = block.timestamp.div(rewardsDuration).mul(
            rewardsDuration
        );
        if (
            locksLength > 0 &&
            uint256(locks[locksLength - 1].unlockTime).sub(lockDuration) >
            currentEpoch
        ) {
            amount = amount.sub(locks[locksLength - 1].boosted);
        }

        return amount;
    }

    function balanceAtEpochOf(uint256 _epoch, address _user)
        external
        view
        returns (uint256 amount)
    {

        LockedBalance[] storage locks = userLocks[_user];

        uint256 epochTime = epochs[_epoch].date;
        uint256 cutoffEpoch = epochTime.sub(lockDuration);

        for (uint256 i = locks.length - 1; i + 1 != 0; i--) {
            uint256 lockEpoch = uint256(locks[i].unlockTime).sub(lockDuration);
            if (lockEpoch <= epochTime) {
                if (lockEpoch > cutoffEpoch) {
                    amount = amount.add(locks[i].boosted);
                } else {
                    break;
                }
            }
        }

        return amount;
    }

    function pendingLockOf(address _user)
        external
        view
        returns (uint256 amount)
    {

        LockedBalance[] storage locks = userLocks[_user];

        uint256 locksLength = locks.length;

        uint256 currentEpoch = block.timestamp.div(rewardsDuration).mul(
            rewardsDuration
        );
        if (
            locksLength > 0 &&
            uint256(locks[locksLength - 1].unlockTime).sub(lockDuration) >
            currentEpoch
        ) {
            return locks[locksLength - 1].boosted;
        }

        return 0;
    }

    function pendingLockAtEpochOf(uint256 _epoch, address _user)
        external
        view
        returns (uint256 amount)
    {

        LockedBalance[] storage locks = userLocks[_user];

        uint256 nextEpoch = uint256(epochs[_epoch].date).add(rewardsDuration);

        for (uint256 i = locks.length - 1; i + 1 != 0; i--) {
            uint256 lockEpoch = uint256(locks[i].unlockTime).sub(lockDuration);

            if (lockEpoch == nextEpoch) {
                return locks[i].boosted;
            } else if (lockEpoch < nextEpoch) {
                break;
            }
        }

        return 0;
    }

    function totalSupply() external view returns (uint256 supply) {

        uint256 currentEpoch = block.timestamp.div(rewardsDuration).mul(
            rewardsDuration
        );
        uint256 cutoffEpoch = currentEpoch.sub(lockDuration);
        uint256 epochindex = epochs.length;

        if (uint256(epochs[epochindex - 1].date) > currentEpoch) {
            epochindex--;
        }

        for (uint256 i = epochindex - 1; i + 1 != 0; i--) {
            Epoch storage e = epochs[i];
            if (uint256(e.date) <= cutoffEpoch) {
                break;
            }
            supply = supply.add(e.supply);
        }

        return supply;
    }

    function totalSupplyAtEpoch(uint256 _epoch)
        external
        view
        returns (uint256 supply)
    {

        uint256 epochStart = uint256(epochs[_epoch].date)
            .div(rewardsDuration)
            .mul(rewardsDuration);
        uint256 cutoffEpoch = epochStart.sub(lockDuration);

        for (uint256 i = _epoch; i + 1 != 0; i--) {
            Epoch storage e = epochs[i];
            if (uint256(e.date) <= cutoffEpoch) {
                break;
            }
            supply = supply.add(epochs[i].supply);
        }

        return supply;
    }

    function findEpochId(uint256 _time) external view returns (uint256 epoch) {

        uint256 max = epochs.length - 1;
        uint256 min = 0;

        _time = _time.div(rewardsDuration).mul(rewardsDuration);

        for (uint256 i = 0; i < 128; i++) {
            if (min >= max) break;

            uint256 mid = (min + max + 1) / 2;
            uint256 midEpochBlock = epochs[mid].date;
            if (midEpochBlock == _time) {
                return mid;
            } else if (midEpochBlock < _time) {
                min = mid;
            } else {
                max = mid - 1;
            }
        }
        return min;
    }

    function lockedBalances(address _user)
        external
        view
        returns (
            uint256 total,
            uint256 unlockable,
            uint256 locked,
            LockedBalance[] memory lockData
        )
    {

        LockedBalance[] storage locks = userLocks[_user];
        Balances storage userBalance = balances[_user];
        uint256 nextUnlockIndex = userBalance.nextUnlockIndex;
        uint256 idx;
        for (uint256 i = nextUnlockIndex; i < locks.length; i++) {
            if (locks[i].unlockTime > block.timestamp) {
                if (idx == 0) {
                    lockData = new LockedBalance[](locks.length - i);
                }
                lockData[idx] = locks[i];
                idx++;
                locked = locked.add(locks[i].amount);
            } else {
                unlockable = unlockable.add(locks[i].amount);
            }
        }
        return (userBalance.locked, unlockable, locked, lockData);
    }

    function epochCount() external view returns (uint256) {

        return epochs.length;
    }


    function checkpointEpoch() external {

        _checkpointEpoch();
    }

    function _checkpointEpoch() internal {

        uint256 nextEpoch = block
            .timestamp
            .div(rewardsDuration)
            .mul(rewardsDuration)
            .add(rewardsDuration);
        uint256 epochindex = epochs.length;


        if (epochs[epochindex - 1].date < nextEpoch) {
            while (epochs[epochs.length - 1].date != nextEpoch) {
                uint256 nextEpochDate = uint256(epochs[epochs.length - 1].date)
                    .add(rewardsDuration);
                epochs.push(Epoch({supply: 0, date: uint32(nextEpochDate)}));
            }

            if (boostRate != nextBoostRate) {
                boostRate = nextBoostRate;
            }
            if (maximumBoostPayment != nextMaximumBoostPayment) {
                maximumBoostPayment = nextMaximumBoostPayment;
            }
        }
    }

    function lock(
        address _account,
        uint256 _amount,
        uint256 _spendRatio
    ) external nonReentrant gacPausable updateReward(_account) {

        stakingToken.safeTransferFrom(msg.sender, address(this), _amount);

        _lock(_account, _amount, _spendRatio, false);
    }

    function _lock(
        address _account,
        uint256 _amount,
        uint256 _spendRatio,
        bool _isRelock
    ) internal {

        require(_amount > 0, "Cannot stake 0");
        require(_spendRatio <= maximumBoostPayment, "over max spend");
        require(!isShutdown, "shutdown");

        Balances storage bal = balances[_account];

        _checkpointEpoch();

        uint256 spendAmount = _amount.mul(_spendRatio).div(denominator);
        uint256 boostRatio = boostRate.mul(_spendRatio).div(
            maximumBoostPayment == 0 ? 1 : maximumBoostPayment
        );
        uint112 lockAmount = _amount.sub(spendAmount).to112();
        uint112 boostedAmount = _amount
            .add(_amount.mul(boostRatio).div(denominator))
            .to112();

        bal.locked = bal.locked.add(lockAmount);
        bal.boosted = bal.boosted.add(boostedAmount);

        lockedSupply = lockedSupply.add(lockAmount);
        boostedSupply = boostedSupply.add(boostedAmount);

        uint256 lockEpoch = block.timestamp.div(rewardsDuration).mul(
            rewardsDuration
        );
        if (!_isRelock) {
            lockEpoch = lockEpoch.add(rewardsDuration);
        }
        uint256 unlockTime = lockEpoch.add(lockDuration);
        uint256 idx = userLocks[_account].length;

        if (idx == 0 || userLocks[_account][idx - 1].unlockTime < unlockTime) {
            userLocks[_account].push(
                LockedBalance({
                    amount: lockAmount,
                    boosted: boostedAmount,
                    unlockTime: uint32(unlockTime)
                })
            );
        } else {

            if (userLocks[_account][idx - 1].unlockTime > unlockTime) {
                idx--;
            }

            if (userLocks[_account][idx - 1].unlockTime == unlockTime) {
                LockedBalance storage userL = userLocks[_account][idx - 1];
                userL.amount = userL.amount.add(lockAmount);
                userL.boosted = userL.boosted.add(boostedAmount);
            } else {

                idx = userLocks[_account].length;

                LockedBalance storage userL = userLocks[_account][idx - 1];

                userLocks[_account].push(
                    LockedBalance({
                        amount: userL.amount,
                        boosted: userL.boosted,
                        unlockTime: userL.unlockTime
                    })
                );

                userL.amount = lockAmount;
                userL.boosted = boostedAmount;
                userL.unlockTime = uint32(unlockTime);
            }
        }

        uint256 eIndex = epochs.length - 1;
        if (_isRelock) {
            eIndex--;
        }
        Epoch storage e = epochs[eIndex];
        e.supply = e.supply.add(uint224(boostedAmount));

        if (spendAmount > 0) {
            stakingToken.safeTransfer(boostPayment, spendAmount);
        }

        emit Staked(_account, lockEpoch, _amount, lockAmount, boostedAmount);
    }

    function _processExpiredLocks(
        address _account,
        bool _relock,
        uint256 _spendRatio,
        address _withdrawTo,
        address _rewardAddress,
        uint256 _checkDelay
    ) internal updateReward(_account) {

        LockedBalance[] storage locks = userLocks[_account];
        Balances storage userBalance = balances[_account];
        uint112 locked;
        uint112 boostedAmount;
        uint256 length = locks.length;
        uint256 reward = 0;

        if (
            isShutdown ||
            locks[length - 1].unlockTime <= block.timestamp.sub(_checkDelay)
        ) {
            locked = userBalance.locked;
            boostedAmount = userBalance.boosted;

            userBalance.nextUnlockIndex = length.to32();

            if (_checkDelay > 0) {
                uint256 currentEpoch = block
                    .timestamp
                    .sub(_checkDelay)
                    .div(rewardsDuration)
                    .mul(rewardsDuration);
                uint256 epochsover = currentEpoch
                    .sub(uint256(locks[length - 1].unlockTime))
                    .div(rewardsDuration);
                uint256 rRate = MathUtil.min(
                    kickRewardPerEpoch.mul(epochsover + 1),
                    denominator
                );
                reward = uint256(locks[length - 1].amount).mul(rRate).div(
                    denominator
                );
            }
        } else {
            uint32 nextUnlockIndex = userBalance.nextUnlockIndex;
            for (uint256 i = nextUnlockIndex; i < length; i++) {
                if (locks[i].unlockTime > block.timestamp.sub(_checkDelay))
                    break;

                locked = locked.add(locks[i].amount);
                boostedAmount = boostedAmount.add(locks[i].boosted);

                if (_checkDelay > 0) {
                    uint256 currentEpoch = block
                        .timestamp
                        .sub(_checkDelay)
                        .div(rewardsDuration)
                        .mul(rewardsDuration);
                    uint256 epochsover = currentEpoch
                        .sub(uint256(locks[i].unlockTime))
                        .div(rewardsDuration);
                    uint256 rRate = MathUtil.min(
                        kickRewardPerEpoch.mul(epochsover + 1),
                        denominator
                    );
                    reward = reward.add(
                        uint256(locks[i].amount).mul(rRate).div(denominator)
                    );
                }
                nextUnlockIndex++;
            }
            userBalance.nextUnlockIndex = nextUnlockIndex;
        }
        require(locked > 0, "no exp locks");

        userBalance.locked = userBalance.locked.sub(locked);
        userBalance.boosted = userBalance.boosted.sub(boostedAmount);
        lockedSupply = lockedSupply.sub(locked);
        boostedSupply = boostedSupply.sub(boostedAmount);

        emit Withdrawn(_account, locked, _relock);

        if (reward > 0) {
            allocateCVXForTransfer(uint256(locked));

            locked = locked.sub(reward.to112());

            transferCVX(_rewardAddress, reward, false);

            emit KickReward(_rewardAddress, _account, reward);
        } else if (_spendRatio > 0) {
            allocateCVXForTransfer(
                uint256(locked).mul(_spendRatio).div(denominator)
            );
        }

        if (_relock) {
            _lock(_withdrawTo, locked, _spendRatio, true);
        } else {
            transferCVX(_withdrawTo, locked, true);
        }
    }

    function withdrawExpiredLocksTo(address _withdrawTo)
        external
        nonReentrant
        gacPausable
    {

        _processExpiredLocks(msg.sender, false, 0, _withdrawTo, msg.sender, 0);
    }

    function processExpiredLocks(bool _relock)
        external
        nonReentrant
        gacPausable
    {

        _processExpiredLocks(msg.sender, _relock, 0, msg.sender, msg.sender, 0);
    }

    function kickExpiredLocks(address _account)
        external
        nonReentrant
        gacPausable
    {

        _processExpiredLocks(
            _account,
            false,
            0,
            _account,
            msg.sender,
            rewardsDuration.mul(kickRewardEpochDelay)
        );
    }

    function allocateCVXForTransfer(uint256 _amount) internal {

        uint256 balance = stakingToken.balanceOf(address(this));
    }

    function transferCVX(
        address _account,
        uint256 _amount,
        bool _updateStake
    ) internal {

        allocateCVXForTransfer(_amount);
        stakingToken.safeTransfer(_account, _amount);
    }

    function updateStakeRatio(uint256 _offset) internal {

        if (isShutdown) return;

        uint256 local = stakingToken.balanceOf(address(this));
        uint256 staked = IStakingProxy(stakingProxy).getBalance();
        uint256 total = local.add(staked);

        if (total == 0) return;

        uint256 ratio = staked.mul(denominator).div(total);
        uint256 mean = maximumStake.add(minimumStake).div(2);
        uint256 max = maximumStake.add(_offset);
        uint256 min = MathUpgradeable.min(minimumStake, minimumStake - _offset);
        if (ratio > max) {
            uint256 remove = staked.sub(total.mul(mean).div(denominator));
            IStakingProxy(stakingProxy).withdraw(remove);
        } else if (ratio < min) {
            uint256 increase = total.mul(mean).div(denominator).sub(staked);
            stakingToken.safeTransfer(stakingProxy, increase);
            IStakingProxy(stakingProxy).stake();
        }
    }

    function getReward(address _account, bool _stake)
        public
        nonReentrant
        gacPausable
        updateReward(_account)
    {

        for (uint256 i; i < rewardTokens.length; i++) {
            address _rewardsToken = rewardTokens[i];
            uint256 reward = rewards[_account][_rewardsToken];
            if (reward > 0) {
                rewards[_account][_rewardsToken] = 0;
                IERC20Upgradeable(_rewardsToken).safeTransfer(_account, reward);
                cumulativeClaimed[_account][_rewardsToken] += reward;
                emit RewardPaid(_account, _rewardsToken, reward);
            }
        }
    }

    function getReward(address _account) external {

        getReward(_account, false);
    }


    function _notifyReward(address _rewardsToken, uint256 _reward) internal {

        Reward storage rdata = rewardData[_rewardsToken];

        if (block.timestamp >= rdata.periodFinish) {
            rdata.rewardRate = _reward.div(rewardsDuration).to208();
        } else {
            uint256 remaining = uint256(rdata.periodFinish).sub(
                block.timestamp
            );
            uint256 leftover = remaining.mul(rdata.rewardRate);
            rdata.rewardRate = _reward
                .add(leftover)
                .div(rewardsDuration)
                .to208();
        }

        rdata.lastUpdateTime = block.timestamp.to40();
        rdata.periodFinish = block.timestamp.add(rewardsDuration).to40();
    }

    function notifyRewardAmount(address _rewardsToken, uint256 _reward)
        external
        gacPausable
        updateReward(address(0))
    {

        notifyRewardAmount(_rewardsToken, _reward, bytes32(0));
    }

    function notifyRewardAmount(
        address _rewardsToken,
        uint256 _reward,
        bytes32 _dataTypeHash
    ) public gacPausable updateReward(address(0)) {

        require(rewardDistributors[_rewardsToken][msg.sender]);
        require(_reward > 0, "No reward");

        _notifyReward(_rewardsToken, _reward);

        IERC20Upgradeable(_rewardsToken).safeTransferFrom(
            msg.sender,
            address(this),
            _reward
        );

        cumulativeDistributed[_rewardsToken] += _reward;
        emit RewardAdded(
            msg.sender,
            _rewardsToken,
            _reward,
            _dataTypeHash,
            block.timestamp
        );
    }

    function recoverERC20(address _tokenAddress, uint256 _tokenAmount)
        external
        gacPausable
    {   

        _onlyRole(CONTRACT_GOVERNANCE_ROLE);
        address treasury = gac.getRoleMember(TREASURY_GOVERNANCE_ROLE, 0);

        require(
            _tokenAddress != address(stakingToken),
            "Cannot withdraw staking token"
        );
        require(
            rewardData[_tokenAddress].lastUpdateTime == 0,
            "Cannot withdraw reward token"
        );
        IERC20Upgradeable(_tokenAddress).safeTransfer(treasury, _tokenAmount);
        emit Recovered(_tokenAddress, _tokenAmount);
    }


    modifier updateReward(address _account) {

        {
            Balances storage userBalance = balances[_account];
            uint256 boostedBal = userBalance.boosted;
            for (uint256 i = 0; i < rewardTokens.length; i++) {
                address token = rewardTokens[i];
                rewardData[token].rewardPerTokenStored = _rewardPerToken(token)
                    .to208();
                rewardData[token].lastUpdateTime = _lastTimeRewardApplicable(
                    rewardData[token].periodFinish
                ).to40();
                if (_account != address(0)) {
                    rewards[_account][token] = _earned(
                        _account,
                        token,
                        rewardData[token].useBoost
                            ? boostedBal
                            : userBalance.locked
                    );
                    userRewardPerTokenPaid[_account][token] = rewardData[token]
                        .rewardPerTokenStored;
                }
            }
        }
        _;
    }

    event RewardAdded(
        address account,
        address indexed _token,
        uint256 _reward,
        bytes32 _dataTypeHash,
        uint256 _timestamp
    );
    event Staked(
        address indexed _user,
        uint256 indexed _epoch,
        uint256 _paidAmount,
        uint256 _lockedAmount,
        uint256 _boostedAmount
    );
    event Withdrawn(address indexed _user, uint256 _amount, bool _relocked);
    event KickReward(
        address indexed _user,
        address indexed _kicked,
        uint256 _reward
    );
    event RewardPaid(
        address indexed _user,
        address indexed _rewardsToken,
        uint256 _reward
    );
    event Recovered(address _token, uint256 _amount);
}