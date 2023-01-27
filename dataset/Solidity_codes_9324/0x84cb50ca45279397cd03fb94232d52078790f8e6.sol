


pragma solidity ^0.8.0;

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



pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}



pragma solidity ^0.8.0;

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

        (bool success, ) = recipient.call{value: amount}("");
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

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

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



pragma solidity ^0.8.0;



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

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
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
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
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
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


pragma solidity ^0.8.0;

abstract contract Initializable {
    bool private initialized;

    bool private initializing;

    modifier initializer() {
        require(
            initializing || !initialized,
            "Initializable: contract is already initialized"
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

    uint256[50] private ______gap;
}


pragma solidity ^0.8.0;

contract Governable {

    bytes32 private constant governorPosition =
        0x7bea13895fa79d2831e0a9e28edede30099005a50d652d8957cf8a607ee6ca4a;

    bytes32 private constant pendingGovernorPosition =
        0x44c4d30b2eaad5130ad70c3ba6972730566f3e6359ab83e800d905c61b1c51db;

    bytes32 private constant reentryStatusPosition =
        0x53bf423e48ed90e97d02ab0ebab13b2a235a6bfbe9c321847d5c175333ac4535;

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

    constructor() {
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


pragma solidity ^0.8.0;



library StableMath {

    using SafeMath for uint256;

    uint256 private constant FULL_SCALE = 1e18;


    function scaleBy(
        uint256 x,
        uint256 to,
        uint256 from
    ) internal pure returns (uint256) {

        if (to > from) {
            x = x.mul(10**(to - from));
        } else if (to < from) {
            x = x.div(10**(from - to));
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


pragma solidity ^0.8.0;







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

    address public transferAgent;


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
            require(_rates[i] < type(uint240).max, "Max rate exceeded");
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

        stakes.push(); // grow the array
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
        require(rate < type(uint240).max, "Max rate exceeded");
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

    function transferStakes(
        address _frmAccount,
        address _dstAccount,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) external {

        require(transferAgent == msg.sender, "must be transfer agent");
        Stake[] storage dstStakes = userStakes[_dstAccount];
        require(dstStakes.length == 0, "Dest stakes must be empty");
        require(_frmAccount != address(0), "from account not set");
        Stake[] storage stakes = userStakes[_frmAccount];
        require(stakes.length > 0, "Nothing to transfer");

        bytes32 hash = keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n64",
                abi.encodePacked(
                    "tran",
                    address(this),
                    _frmAccount,
                    _dstAccount
                )
            )
        );
        require(ecrecover(hash, v, r, s) == _frmAccount, "Transfer not authed");

        userStakes[_dstAccount] = stakes;
        delete userStakes[_frmAccount];
        emit StakesTransfered(_frmAccount, _dstAccount, stakes.length);
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

    function setTransferAgent(address _agent) external onlyGovernor {

        transferAgent = _agent;
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
    event StakesTransfered(
        address indexed fromUser,
        address toUser,
        uint256 numStakes
    );
}