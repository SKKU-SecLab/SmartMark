

pragma solidity ^0.5.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity ^0.5.0;

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
}


pragma solidity >=0.4.24 <0.7.0;


contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

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
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}


pragma solidity ^0.5.5;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
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


pragma solidity ^0.5.0;



library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


pragma solidity 0.5.11;

contract Governable {

    bytes32
        private constant governorPosition = 0x7bea13895fa79d2831e0a9e28edede30099005a50d652d8957cf8a607ee6ca4a;

    bytes32
        private constant pendingGovernorPosition = 0x44c4d30b2eaad5130ad70c3ba6972730566f3e6359ab83e800d905c61b1c51db;

    bytes32
        private constant reentryStatusPosition = 0x53bf423e48ed90e97d02ab0ebab13b2a235a6bfbe9c321847d5c175333ac4535;

    uint256 constant _NOT_ENTERED = 1;
    uint256 constant _ENTERED = 2;

    event PendingGovernorshipTransfer(
        address indexed previousGovernor,
        address indexed newGovernor
    );

    event GovernorshipTransferred(
        address indexed previousGovernor,
        address indexed newGovernor
    );

    constructor() internal {
        _setGovernor(msg.sender);
        emit GovernorshipTransferred(address(0), _governor());
    }

    function governor() public view returns (address) {

        return _governor();
    }

    function _governor() internal view returns (address governorOut) {

        bytes32 position = governorPosition;
        assembly {
            governorOut := sload(position)
        }
    }

    function _pendingGovernor()
        internal
        view
        returns (address pendingGovernor)
    {

        bytes32 position = pendingGovernorPosition;
        assembly {
            pendingGovernor := sload(position)
        }
    }

    modifier onlyGovernor() {

        require(isGovernor(), "Caller is not the Governor");
        _;
    }

    function isGovernor() public view returns (bool) {

        return msg.sender == _governor();
    }

    function _setGovernor(address newGovernor) internal {

        bytes32 position = governorPosition;
        assembly {
            sstore(position, newGovernor)
        }
    }

    modifier nonReentrant() {

        bytes32 position = reentryStatusPosition;
        uint256 _reentry_status;
        assembly {
            _reentry_status := sload(position)
        }

        require(_reentry_status != _ENTERED, "Reentrant call");

        assembly {
            sstore(position, _ENTERED)
        }

        _;

        assembly {
            sstore(position, _NOT_ENTERED)
        }
    }

    function _setPendingGovernor(address newGovernor) internal {

        bytes32 position = pendingGovernorPosition;
        assembly {
            sstore(position, newGovernor)
        }
    }

    function transferGovernance(address _newGovernor) external onlyGovernor {

        _setPendingGovernor(_newGovernor);
        emit PendingGovernorshipTransfer(_governor(), _newGovernor);
    }

    function claimGovernance() external {

        require(
            msg.sender == _pendingGovernor(),
            "Only the pending Governor can complete the claim"
        );
        _changeGovernor(msg.sender);
    }

    function _changeGovernor(address _newGovernor) internal {

        require(_newGovernor != address(0), "New Governor is address(0)");
        emit GovernorshipTransferred(_governor(), _newGovernor);
        _setGovernor(_newGovernor);
    }
}


pragma solidity 0.5.11;


library StableMath {

    using SafeMath for uint256;

    uint256 private constant FULL_SCALE = 1e18;


    function scaleBy(uint256 x, int8 adjustment)
        internal
        pure
        returns (uint256)
    {

        if (adjustment > 0) {
            x = x.mul(10**uint256(adjustment));
        } else if (adjustment < 0) {
            x = x.div(10**uint256(adjustment * -1));
        }
        return x;
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

    function mulTruncateCeil(uint256 x, uint256 y)
        internal
        pure
        returns (uint256)
    {

        uint256 scaled = x.mul(y);
        uint256 ceil = scaled.add(FULL_SCALE.sub(1));
        return ceil.div(FULL_SCALE);
    }

    function divPrecisely(uint256 x, uint256 y)
        internal
        pure
        returns (uint256)
    {

        uint256 z = x.mul(FULL_SCALE);
        return z.div(y);
    }
}


pragma solidity 0.5.11;
pragma experimental ABIEncoderV2;






contract SingleAssetStaking is Initializable, Governable {

    using SafeMath for uint256;
    using StableMath for uint256;
    using SafeERC20 for IERC20;


    IERC20 public stakingToken; // this is both the staking and rewards

    struct Stake {
        uint256 amount; // amount to stake
        uint256 end; // when does the staking period end
        uint256 duration; // the duration of the stake
        uint240 rate; // rate to charge use 248 to reserve 8 bits for the bool
        bool paid;
        uint8 stakeType;
    }

    struct DropRoot {
        bytes32 hash;
        uint256 depth;
    }

    uint256[] public durations; // allowed durations
    uint256[] public rates; // rates that correspond with the allowed durations

    uint256 public totalOutstanding;
    bool public paused;

    mapping(address => Stake[]) public userStakes;

    mapping(uint8 => DropRoot) public dropRoots;

    uint8 constant USER_STAKE_TYPE = 0;
    uint256 constant MAX_STAKES = 256;


    function initialize(
        address _stakingToken,
        uint256[] calldata _durations,
        uint256[] calldata _rates
    ) external onlyGovernor initializer {

        stakingToken = IERC20(_stakingToken);
        _setDurationRates(_durations, _rates);
    }


    function _setDurationRates(
        uint256[] memory _durations,
        uint256[] memory _rates
    ) internal {

        require(
            _rates.length == _durations.length,
            "Mismatch durations and rates"
        );

        for (uint256 i = 0; i < _rates.length; i++) {
            require(_rates[i] < uint240(-1), "Max rate exceeded");
        }

        rates = _rates;
        durations = _durations;

        emit NewRates(msg.sender, rates);
        emit NewDurations(msg.sender, durations);
    }

    function _totalExpectedRewards(Stake[] storage stakes)
        internal
        view
        returns (uint256 total)
    {

        for (uint256 i = 0; i < stakes.length; i++) {
            Stake storage stake = stakes[i];
            if (!stake.paid) {
                total = total.add(stake.amount.mulTruncate(stake.rate));
            }
        }
    }

    function _totalExpected(Stake storage _stake)
        internal
        view
        returns (uint256)
    {

        return _stake.amount.add(_stake.amount.mulTruncate(_stake.rate));
    }

    function _airDroppedStakeClaimed(address account, uint8 stakeType)
        internal
        view
        returns (bool)
    {

        Stake[] storage stakes = userStakes[account];
        for (uint256 i = 0; i < stakes.length; i++) {
            if (stakes[i].stakeType == stakeType) {
                return true;
            }
        }
        return false;
    }

    function _findDurationRate(uint256 duration)
        internal
        view
        returns (uint240)
    {

        for (uint256 i = 0; i < durations.length; i++) {
            if (duration == durations[i]) {
                return uint240(rates[i]);
            }
        }
        return 0;
    }

    function _stake(
        address staker,
        uint8 stakeType,
        uint256 duration,
        uint240 rate,
        uint256 amount
    ) internal {

        require(!paused, "Staking paused");

        Stake[] storage stakes = userStakes[staker];

        uint256 end = block.timestamp.add(duration);

        uint256 i = stakes.length; // start at the end of the current array

        require(i < MAX_STAKES, "Max stakes");

        stakes.length += 1; // grow the array
        while (i != 0 && stakes[i - 1].end > end) {
            stakes[i] = stakes[i - 1];
            i -= 1;
        }

        Stake storage newStake = stakes[i];
        newStake.rate = rate;
        newStake.stakeType = stakeType;
        newStake.end = end;
        newStake.duration = duration;
        newStake.amount = amount;

        totalOutstanding = totalOutstanding.add(_totalExpected(newStake));

        emit Staked(staker, amount, duration, rate);
    }

    function _stakeWithChecks(
        address staker,
        uint256 amount,
        uint256 duration
    ) internal {

        require(amount > 0, "Cannot stake 0");

        uint240 rewardRate = _findDurationRate(duration);
        require(rewardRate > 0, "Invalid duration"); // we couldn't find the rate that correspond to the passed duration

        _stake(staker, USER_STAKE_TYPE, duration, rewardRate, amount);
        stakingToken.safeTransferFrom(staker, address(this), amount);
    }

    modifier requireLiquidity() {

        _;
        require(
            stakingToken.balanceOf(address(this)) >= totalOutstanding,
            "Insufficient rewards"
        );
    }


    function getAllDurations() external view returns (uint256[] memory) {

        return durations;
    }

    function getAllRates() external view returns (uint256[] memory) {

        return rates;
    }

    function getAllStakes(address account)
        external
        view
        returns (Stake[] memory)
    {

        return userStakes[account];
    }

    function durationRewardRate(uint256 _duration)
        external
        view
        returns (uint256)
    {

        return _findDurationRate(_duration);
    }

    function airDroppedStakeClaimed(address account, uint8 stakeType)
        external
        view
        returns (bool)
    {

        return _airDroppedStakeClaimed(account, stakeType);
    }

    function totalStaked(address account)
        external
        view
        returns (uint256 total)
    {

        Stake[] storage stakes = userStakes[account];

        for (uint256 i = 0; i < stakes.length; i++) {
            if (!stakes[i].paid) {
                total = total.add(stakes[i].amount);
            }
        }
    }

    function totalExpectedRewards(address account)
        external
        view
        returns (uint256)
    {

        return _totalExpectedRewards(userStakes[account]);
    }

    function totalCurrentHoldings(address account)
        external
        view
        returns (uint256 total)
    {

        Stake[] storage stakes = userStakes[account];

        for (uint256 i = 0; i < stakes.length; i++) {
            Stake storage stake = stakes[i];
            if (stake.paid) {
                continue;
            } else if (stake.end < block.timestamp) {
                total = total.add(_totalExpected(stake));
            } else {
                total = total.add(
                    stake.amount.add(
                        stake.amount.mulTruncate(stake.rate).mulTruncate(
                            stake
                                .duration
                                .sub(stake.end.sub(block.timestamp))
                                .divPrecisely(stake.duration)
                        )
                    )
                );
            }
        }
    }


    function airDroppedStake(
        uint256 index,
        uint8 stakeType,
        uint256 duration,
        uint256 rate,
        uint256 amount,
        bytes32[] calldata merkleProof
    ) external requireLiquidity {

        require(stakeType != USER_STAKE_TYPE, "Cannot be normal staking");
        require(rate < uint240(-1), "Max rate exceeded");
        require(index < 2**merkleProof.length, "Invalid index");
        DropRoot storage dropRoot = dropRoots[stakeType];
        require(merkleProof.length == dropRoot.depth, "Invalid proof");

        bytes32 node = keccak256(
            abi.encodePacked(
                index,
                stakeType,
                address(this),
                msg.sender,
                duration,
                rate,
                amount
            )
        );
        uint256 path = index;
        for (uint16 i = 0; i < merkleProof.length; i++) {
            if ((path & 0x01) == 1) {
                node = keccak256(abi.encodePacked(merkleProof[i], node));
            } else {
                node = keccak256(abi.encodePacked(node, merkleProof[i]));
            }
            path /= 2;
        }

        require(node == dropRoot.hash, "Stake not approved");

        require(
            !_airDroppedStakeClaimed(msg.sender, stakeType),
            "Already staked"
        );

        _stake(msg.sender, stakeType, duration, uint240(rate), amount);
    }

    function stake(uint256 amount, uint256 duration) external requireLiquidity {

        _stakeWithChecks(msg.sender, amount, duration);
    }

    function stakeWithSender(
        address staker,
        uint256 amount,
        uint256 duration
    ) external returns (bool) {

        require(
            msg.sender == address(stakingToken),
            "Only token contract can make this call"
        );

        _stakeWithChecks(staker, amount, duration);
        return true;
    }

    function exit() external requireLiquidity {

        Stake[] storage stakes = userStakes[msg.sender];
        require(stakes.length > 0, "Nothing staked");

        uint256 totalWithdraw = 0;
        uint256 stakedAmount = 0;
        uint256 l = stakes.length;
        do {
            Stake storage exitStake = stakes[l - 1];
            if (exitStake.end < block.timestamp && exitStake.paid) {
                break;
            }
            if (exitStake.end < block.timestamp) {
                exitStake.paid = true;
                totalWithdraw = totalWithdraw.add(_totalExpected(exitStake));
                stakedAmount = stakedAmount.add(exitStake.amount);
            }
            l--;
        } while (l > 0);
        require(totalWithdraw > 0, "All stakes in lock-up");

        totalOutstanding = totalOutstanding.sub(totalWithdraw);
        emit Withdrawn(msg.sender, totalWithdraw, stakedAmount);
        stakingToken.safeTransfer(msg.sender, totalWithdraw);
    }


    function setPaused(bool _paused) external onlyGovernor {

        paused = _paused;
        emit Paused(msg.sender, paused);
    }

    function setDurationRates(
        uint256[] calldata _durations,
        uint256[] calldata _rates
    ) external onlyGovernor {

        _setDurationRates(_durations, _rates);
    }

    function setAirDropRoot(
        uint8 _stakeType,
        bytes32 _rootHash,
        uint256 _proofDepth
    ) external onlyGovernor {

        require(_stakeType != USER_STAKE_TYPE, "Cannot be normal staking");
        dropRoots[_stakeType].hash = _rootHash;
        dropRoots[_stakeType].depth = _proofDepth;
        emit NewAirDropRootHash(_stakeType, _rootHash, _proofDepth);
    }


    event Staked(
        address indexed user,
        uint256 amount,
        uint256 duration,
        uint256 rate
    );
    event Withdrawn(address indexed user, uint256 amount, uint256 stakedAmount);
    event Paused(address indexed user, bool yes);
    event NewDurations(address indexed user, uint256[] durations);
    event NewRates(address indexed user, uint256[] rates);
    event NewAirDropRootHash(
        uint8 stakeType,
        bytes32 rootHash,
        uint256 proofDepth
    );
}