
pragma solidity >=0.6.0 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

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
}// MIT

pragma solidity >=0.6.2 <0.8.0;

library Address {

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

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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
}// MIT

pragma solidity >=0.6.0 <0.8.0;


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

pragma solidity >=0.6.0 <0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
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
        return !Address.isContract(address(this));
    }
}// UNLICENSED

pragma solidity =0.6.12;

interface IBaseReward {

    function earned(address account) external view returns (uint256);

    function stake(address _for) external;

    function withdraw(address _for) external;

    function getReward(address _for) external;

    function notifyRewardAmount(uint256 reward) external;

    function addOwner(address _newOwner) external;

    function addOwners(address[] calldata _newOwners) external;

    function removeOwner(address _owner) external;

    function isOwner(address _owner) external view returns (bool);

}// UNLICENSED

pragma solidity =0.6.12;


interface ILendFlareVotingEscrow {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);

}

contract LendFlareVotingEscrowV2 is Initializable, ReentrancyGuard, ILendFlareVotingEscrow {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    uint256 constant WEEK = 1 weeks; // all future times are rounded by week
    uint256 constant MAXTIME = 4 * 365 * 86400; // 4 years
    string constant NAME = "Vote-escrowed LFT";
    string constant SYMBOL = "VeLFT";
    uint8 constant DECIMALS = 18;

    address public token;
    address public rewardManager;

    uint256 public lockedSupply;

    enum DepositTypes {
        DEPOSIT_FOR_TYPE,
        CREATE_LOCK_TYPE,
        INCREASE_LOCK_AMOUNT,
        INCREASE_UNLOCK_TIME
    }

    struct Point {
        int256 bias;
        int256 slope; // dweight / dt
        uint256 timestamp; // timestamp
    }

    struct LockedBalance {
        uint256 amount;
        uint256 end;
    }

    IBaseReward[] public rewardPools;

    mapping(address => LockedBalance) public lockedBalances;
    mapping(address => mapping(uint256 => Point)) public userPointHistory; // user => ( user epoch => point )
    mapping(address => uint256) public userPointEpoch; // user => user epoch

    bool public expired;
    uint256 public epoch;

    mapping(uint256 => Point) public pointHistory; // epoch -> unsigned point.
    mapping(uint256 => int256) public slopeChanges; // time -> signed slope change

    event Deposit(address indexed provider, uint256 value, uint256 indexed locktime, DepositTypes depositTypes, uint256 ts);
    event Withdraw(address indexed provider, uint256 value, uint256 timestamp);
    event TotalSupply(uint256 prevSupply, uint256 supply);

    constructor() public initializer {}

    function initialize(address _token, address _rewardManager) public initializer {

        token = _token;
        rewardManager = _rewardManager;
    }

    modifier onlyRewardManager() {

        require(rewardManager == msg.sender, "LendFlareVotingEscrow: caller is not the rewardManager");
        _;
    }

    function rewardPoolsLength() external view returns (uint256) {

        return rewardPools.length;
    }

    function addRewardPool(address _v) external onlyRewardManager returns (bool) {

        require(_v != address(0), "!_v");

        rewardPools.push(IBaseReward(_v));

        return true;
    }

    function clearRewardPools() external onlyRewardManager {

        delete rewardPools;
    }

    function updateTotalSupply(bytes memory data) public {

        bytes memory callData;

        callData = abi.encodePacked(bytes4(keccak256(bytes("_updateTotalSupply(address[],bool)"))), data);

        (bool success, bytes memory returnData) = address(this).call(callData);
        require(success, string(returnData));
    }

    function _updateTotalSupply(address[] calldata _senders, bool _expired) public {

        require(epoch == 0, "!epoch");

        for (uint256 i = 0; i < _senders.length; i++) {
            LockedBalance storage newLocked = lockedBalances[_senders[i]];

            _updateTotalSupply(_senders[i], newLocked);
        }

        if (_expired) {
            require(!expired, "!expired");

            expired = true;
        }
    }

    function _updateTotalSupply(address _sender, LockedBalance storage _newLocked) internal {

        Point memory userOldPoint;
        Point memory userNewPoint;

        int256 newSlope = 0;

        if (_sender != address(0)) {
            if (_newLocked.end > block.timestamp && _newLocked.amount > 0) {
                userNewPoint.slope = int256(_newLocked.amount / MAXTIME);
                userNewPoint.bias = userNewPoint.slope * int256(_newLocked.end - block.timestamp);
            }
            newSlope = slopeChanges[_newLocked.end];
        }

        Point memory lastPoint = Point({ bias: 0, slope: 0, timestamp: block.timestamp });

        if (epoch > 0) {
            lastPoint = pointHistory[epoch];
        }

        uint256 lastCheckpoint = lastPoint.timestamp;
        uint256 iterativeTime = _floorToWeek(lastCheckpoint);

        for (uint256 i; i < 255; i++) {
            int256 slope = 0;
            iterativeTime += WEEK;

            if (iterativeTime > block.timestamp) {
                iterativeTime = block.timestamp;
            } else {
                slope = slopeChanges[iterativeTime];
            }

            lastPoint.bias -= lastPoint.slope * int256(iterativeTime - lastCheckpoint);
            lastPoint.slope += slope;

            if (lastPoint.bias < 0) {
                lastPoint.bias = 0; // This can happen
            }

            if (lastPoint.slope < 0) {
                lastPoint.slope = 0; // This cannot happen - just in case
            }

            lastCheckpoint = iterativeTime;
            lastPoint.timestamp = iterativeTime;

            epoch++;

            if (iterativeTime == block.timestamp) {
                break;
            } else {
                pointHistory[epoch] = lastPoint;
            }
        }

        if (_sender != address(0)) {
            lastPoint.slope += userNewPoint.slope - userOldPoint.slope;
            lastPoint.bias += userNewPoint.bias - userOldPoint.bias;

            if (lastPoint.slope < 0) {
                lastPoint.slope = 0;
            }
            if (lastPoint.bias < 0) {
                lastPoint.bias = 0;
            }
        }

        pointHistory[epoch] = lastPoint;

        if (_sender != address(0)) {
            newSlope -= userNewPoint.slope; // old slope disappeared at this point
            slopeChanges[_newLocked.end] = newSlope;
        }
    }

    function _checkpointV1(address _sender, LockedBalance storage _newLocked) internal {

        Point storage point = userPointHistory[_sender][++userPointEpoch[_sender]];

        point.timestamp = block.timestamp;

        if (_newLocked.end > block.timestamp) {
            point.slope = int256(_newLocked.amount / MAXTIME);
            point.bias = point.slope * int256(_newLocked.end - block.timestamp);
        }
    }

    function _checkpoint(
        address _sender,
        LockedBalance memory _oldLocked,
        LockedBalance memory _newLocked
    ) internal {

        Point memory userOldPoint;
        Point memory userNewPoint;

        int256 oldSlope = 0;
        int256 newSlope = 0;

        if (_sender != address(0)) {
            if (_oldLocked.end > block.timestamp && _oldLocked.amount > 0) {
                userOldPoint.slope = int256(_oldLocked.amount / MAXTIME);
                userOldPoint.bias = userOldPoint.slope * int256(_oldLocked.end - block.timestamp);
            }

            if (_newLocked.end > block.timestamp && _newLocked.amount > 0) {
                userNewPoint.slope = int256(_newLocked.amount / MAXTIME);
                userNewPoint.bias = userNewPoint.slope * int256(_newLocked.end - block.timestamp);
            }

            oldSlope = slopeChanges[_oldLocked.end];

            if (_newLocked.end != 0) {
                if (_newLocked.end == _oldLocked.end) {
                    newSlope = oldSlope;
                } else {
                    newSlope = slopeChanges[_newLocked.end];
                }
            }
        }

        Point memory lastPoint = Point({ bias: 0, slope: 0, timestamp: block.timestamp });

        if (epoch > 0) {
            lastPoint = pointHistory[epoch];
        }

        uint256 lastCheckpoint = lastPoint.timestamp;
        uint256 iterativeTime = _floorToWeek(lastCheckpoint);

        for (uint256 i; i < 255; i++) {
            int256 slope = 0;

            iterativeTime += WEEK;

            if (iterativeTime > block.timestamp) {
                iterativeTime = block.timestamp;
            } else {
                slope = slopeChanges[iterativeTime];
            }

            lastPoint.bias -= lastPoint.slope * int256(iterativeTime - lastCheckpoint);
            lastPoint.slope += slope;

            if (lastPoint.bias < 0) {
                lastPoint.bias = 0; // This can happen
            }

            if (lastPoint.slope < 0) {
                lastPoint.slope = 0; // This cannot happen - just in case
            }

            lastCheckpoint = iterativeTime;
            lastPoint.timestamp = iterativeTime;

            epoch++;

            if (iterativeTime == block.timestamp) {
                break;
            } else {
                pointHistory[epoch] = lastPoint;
            }
        }

        if (_sender != address(0)) {
            lastPoint.slope += userNewPoint.slope - userOldPoint.slope;
            lastPoint.bias += userNewPoint.bias - userOldPoint.bias;

            if (lastPoint.slope < 0) {
                lastPoint.slope = 0;
            }
            if (lastPoint.bias < 0) {
                lastPoint.bias = 0;
            }
        }

        pointHistory[epoch] = lastPoint;

        if (_sender != address(0)) {
            if (_oldLocked.end > block.timestamp) {
                oldSlope += userOldPoint.slope;

                if (_newLocked.end == _oldLocked.end) {
                    oldSlope -= userNewPoint.slope; // It was a new deposit, not extension
                }

                slopeChanges[_oldLocked.end] = oldSlope;
            }

            if (_newLocked.end > block.timestamp) {
                if (_newLocked.end > _oldLocked.end) {
                    newSlope -= userNewPoint.slope; // old slope disappeared at this point
                    slopeChanges[_newLocked.end] = newSlope;
                }
            }

            uint256 userEpoch = userPointEpoch[_sender] + 1;

            userPointEpoch[_sender] = userEpoch;
            userNewPoint.timestamp = block.timestamp;
            userPointHistory[_sender][userEpoch] = userNewPoint;
        }
    }

    function _depositFor(
        address _sender,
        uint256 _amount,
        uint256 _unlockTime,
        LockedBalance storage _locked,
        DepositTypes _depositTypes
    ) internal {

        uint256 oldLockedSupply = lockedSupply;

        if (_amount > 0) {
            IERC20(token).safeTransferFrom(_sender, address(this), _amount);
        }

        LockedBalance memory oldLocked;

        (oldLocked.amount, oldLocked.end) = (_locked.amount, _locked.end);

        _locked.amount = _locked.amount + _amount;
        lockedSupply = lockedSupply + _amount;

        if (_unlockTime > 0) {
            _locked.end = _unlockTime;
        }

        for (uint256 i = 0; i < rewardPools.length; i++) {
            rewardPools[i].stake(_sender);
        }

        if (expired) {
            _checkpoint(_sender, oldLocked, _locked);
        } else {
            _checkpointV1(_sender, _locked);
        }

        emit Deposit(_sender, _amount, _locked.end, _depositTypes, block.timestamp);
        emit TotalSupply(oldLockedSupply, lockedSupply);
    }

    function deposit(uint256 _amount) external nonReentrant {

        LockedBalance storage locked = lockedBalances[msg.sender];

        require(_amount > 0, "need non-zero value");
        require(locked.amount > 0, "no existing lock found");
        require(locked.end > block.timestamp, "cannot add to expired lock. Withdraw");

        _depositFor(msg.sender, _amount, 0, locked, DepositTypes.DEPOSIT_FOR_TYPE);
    }

    function createLock(uint256 _amount, uint256 _unlockTime) public nonReentrant {

        _unlockTime = _floorToWeek(_unlockTime);

        require(_amount != 0, "Must stake non zero amount");
        require(_unlockTime > block.timestamp, "Can only lock until time in the future");

        LockedBalance storage locked = lockedBalances[msg.sender];

        require(locked.amount == 0, "Withdraw old tokens first");

        uint256 roundedMin = _floorToWeek(block.timestamp) + WEEK;
        uint256 roundedMax = _floorToWeek(block.timestamp) + MAXTIME;

        if (_unlockTime < roundedMin) {
            _unlockTime = roundedMin;
        } else if (_unlockTime > roundedMax) {
            _unlockTime = roundedMax;
        }

        _depositFor(msg.sender, _amount, _unlockTime, locked, DepositTypes.CREATE_LOCK_TYPE);
    }

    function increaseAmount(uint256 _amount) external nonReentrant {

        LockedBalance storage locked = lockedBalances[msg.sender];

        require(_amount != 0, "Must stake non zero amount");
        require(locked.amount != 0, "No existing lock found");
        require(locked.end >= block.timestamp, "Can't add to expired lock. Withdraw old tokens first");

        _depositFor(msg.sender, _amount, 0, locked, DepositTypes.INCREASE_LOCK_AMOUNT);
    }

    function increaseUnlockTime(uint256 _unlockTime) external nonReentrant {

        LockedBalance storage locked = lockedBalances[msg.sender];

        require(locked.amount != 0, "No existing lock found");
        require(locked.end >= block.timestamp, "Lock expired. Withdraw old tokens first");

        uint256 maxUnlockTime = _floorToWeek(block.timestamp) + MAXTIME;
        require(locked.end != maxUnlockTime, "Already locked for maximum time");

        _unlockTime = _floorToWeek(_unlockTime);

        require(_unlockTime <= maxUnlockTime, "Can't lock for more than max time");

        _depositFor(msg.sender, 0, _unlockTime, locked, DepositTypes.INCREASE_UNLOCK_TIME);
    }

    function withdraw() public nonReentrant {

        LockedBalance storage locked = lockedBalances[msg.sender];
        LockedBalance memory oldLocked = locked;

        require(block.timestamp >= locked.end, "The lock didn't expire");

        uint256 oldLockedSupply = lockedSupply;
        uint256 lockedAmount = locked.amount;

        lockedSupply = lockedSupply - lockedAmount;

        locked.amount = 0;
        locked.end = 0;

        if (expired) {
            _checkpoint(msg.sender, oldLocked, locked);
        } else {
            _checkpointV1(msg.sender, locked);
        }

        IERC20(token).safeTransfer(msg.sender, lockedAmount);

        for (uint256 i = 0; i < rewardPools.length; i++) {
            rewardPools[i].withdraw(msg.sender);
        }

        emit Withdraw(msg.sender, lockedAmount, block.timestamp);
        emit TotalSupply(oldLockedSupply, lockedSupply);
    }

    function _floorToWeek(uint256 _t) internal pure returns (uint256) {

        return (_t / WEEK) * WEEK;
    }

    function balanceOf(address _sender) external view override returns (uint256) {

        uint256 t = block.timestamp;
        uint256 userEpoch = userPointEpoch[_sender];

        if (userEpoch == 0) return 0;

        Point storage point = userPointHistory[_sender][userEpoch];

        int256 bias = point.slope * int256(t - point.timestamp);

        if (bias > point.bias) return 0;

        return uint256(point.bias - bias);
    }

    function name() public pure returns (string memory) {

        return NAME;
    }

    function symbol() public pure returns (string memory) {

        return SYMBOL;
    }

    function decimals() public pure returns (uint8) {

        return DECIMALS;
    }

    function supplyAt(Point memory _point, uint256 _t) internal view returns (uint256) {

        uint256 iterativeTime = _floorToWeek(_point.timestamp);

        for (uint256 i; i < 255; i++) {
            int256 slope = 0;

            iterativeTime += WEEK;

            if (iterativeTime > _t) {
                iterativeTime = _t;
            } else {
                slope = slopeChanges[iterativeTime];
            }
            _point.bias -= _point.slope * int256(iterativeTime - _point.timestamp);

            if (iterativeTime == _t) {
                break;
            }
            _point.slope += slope;
            _point.timestamp = iterativeTime;
        }

        if (_point.bias < 0) {
            _point.bias = 0;
        }

        return uint256(_point.bias);
    }

    function totalSupply() public view override returns (uint256) {

        if (expired) {
            return supplyAt(pointHistory[epoch], block.timestamp);
        } else {
            return lockedSupply;
        }
    }
}