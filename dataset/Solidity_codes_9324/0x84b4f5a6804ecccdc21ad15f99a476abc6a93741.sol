pragma solidity 0.8.4;

interface IVeBend {

    struct Point {
        int256 bias;
        int256 slope;
        uint256 ts;
        uint256 blk;
    }

    struct LockedBalance {
        int256 amount;
        uint256 end;
    }

    event Deposit(
        address indexed provider,
        address indexed beneficiary,
        uint256 value,
        uint256 indexed locktime,
        uint256 _type,
        uint256 ts
    );
    event Withdraw(address indexed provider, uint256 value, uint256 ts);

    event Supply(uint256 prevSupply, uint256 supply);

    function createLock(uint256 _value, uint256 _unlockTime) external;


    function createLockFor(
        address _beneficiary,
        uint256 _value,
        uint256 _unlockTime
    ) external;


    function increaseAmount(uint256 _value) external;


    function increaseAmountFor(address _beneficiary, uint256 _value) external;


    function increaseUnlockTime(uint256 _unlockTime) external;


    function checkpointSupply() external;


    function withdraw() external;


    function getLocked(address _addr) external returns (LockedBalance memory);


    function getUserPointEpoch(address _userAddress)
        external
        view
        returns (uint256);


    function epoch() external view returns (uint256);


    function getUserPointHistory(address _userAddress, uint256 _index)
        external
        view
        returns (Point memory);


    function getSupplyPointHistory(uint256 _index)
        external
        view
        returns (Point memory);

}// MIT

pragma solidity ^0.8.0;

abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}// MIT

pragma solidity ^0.8.0;

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
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}// agpl-3.0
pragma solidity 0.8.4;
pragma abicoder v2;





contract VeBend is IVeBend, ReentrancyGuardUpgradeable, OwnableUpgradeable {

    using SafeERC20Upgradeable for IERC20Upgradeable;


    uint256 private constant DEPOSIT_FOR_TYPE = 0;
    uint256 private constant CREATE_LOCK_TYPE = 1;
    uint256 private constant INCREASE_LOCK_AMOUNT = 2;
    uint256 private constant INCREASE_UNLOCK_TIME = 3;

    uint256 public constant WEEK = 7 * 86400; // all future times are rounded by week
    uint256 public constant MAXTIME = 4 * 365 * 86400; // 4 years
    uint256 public constant MULTIPLIER = 10**18;

    address public token;
    uint256 public supply;

    mapping(address => LockedBalance) public locked;

    uint256 public override epoch;
    mapping(uint256 => Point) public supplyPointHistory; // epoch -> unsigned point.
    mapping(address => mapping(uint256 => Point)) public userPointHistory; // user -> Point[user_epoch]
    mapping(address => uint256) public userPointEpoch;
    mapping(uint256 => int256) public slopeChanges; // time -> signed slope change

    string public name;
    string public symbol;
    uint256 public decimals;

    function initialize(address _tokenAddr) external initializer {

        __Ownable_init();
        __ReentrancyGuard_init();
        token = _tokenAddr;
        supplyPointHistory[0] = Point({
            bias: 0,
            slope: 0,
            ts: block.timestamp,
            blk: block.number
        });
        decimals = 18;
        name = "Vote-escrowed BEND";
        symbol = "veBEND";
    }

    function getLocked(address _addr)
        external
        view
        override
        returns (LockedBalance memory)
    {

        return locked[_addr];
    }

    function getUserPointEpoch(address _userAddress)
        external
        view
        override
        returns (uint256)
    {

        return userPointEpoch[_userAddress];
    }

    function getSupplyPointHistory(uint256 _index)
        external
        view
        override
        returns (Point memory)
    {

        return supplyPointHistory[_index];
    }

    function getUserPointHistory(address _userAddress, uint256 _index)
        external
        view
        override
        returns (Point memory)
    {

        return userPointHistory[_userAddress][_index];
    }

    function getLastUserSlope(address _addr) external view returns (int256) {

        uint256 uepoch = userPointEpoch[_addr];
        return userPointHistory[_addr][uepoch].slope;
    }

    function userPointHistoryTs(address _addr, uint256 _idx)
        external
        view
        returns (uint256)
    {

        return userPointHistory[_addr][_idx].ts;
    }

    function lockedEnd(address _addr) external view returns (uint256) {

        return locked[_addr].end;
    }

    struct CheckpointParameters {
        Point userOldPoint;
        Point userNewPoint;
        int256 oldDslope;
        int256 newDslope;
        uint256 epoch;
    }

    function _checkpoint(
        address _addr,
        LockedBalance memory _oldLocked,
        LockedBalance memory _newLocked
    ) internal {

        CheckpointParameters memory _st;
        _st.epoch = epoch;

        if (_addr != address(0)) {
            if (_oldLocked.end > block.timestamp && _oldLocked.amount > 0) {
                _st.userOldPoint.slope = _oldLocked.amount / int256(MAXTIME);
                _st.userOldPoint.bias =
                    _st.userOldPoint.slope *
                    int256(_oldLocked.end - block.timestamp);
            }
            if (_newLocked.end > block.timestamp && _newLocked.amount > 0) {
                _st.userNewPoint.slope = _newLocked.amount / int256(MAXTIME);
                _st.userNewPoint.bias =
                    _st.userNewPoint.slope *
                    int256(_newLocked.end - block.timestamp);
            }

            _st.oldDslope = slopeChanges[_oldLocked.end];
            if (_newLocked.end != 0) {
                if (_newLocked.end == _oldLocked.end) {
                    _st.newDslope = _st.oldDslope;
                } else {
                    _st.newDslope = slopeChanges[_newLocked.end];
                }
            }
        }
        Point memory _lastPoint = Point({
            bias: 0,
            slope: 0,
            ts: block.timestamp,
            blk: block.number
        });
        if (_st.epoch > 0) {
            _lastPoint = supplyPointHistory[_st.epoch];
        }
        uint256 _lastCheckPoint = _lastPoint.ts;
        uint256 _initBlk = _lastPoint.blk;
        uint256 _initTs = _lastPoint.ts;

        uint256 _blockSlope = 0; // dblock/dt
        if (block.timestamp > _lastPoint.ts) {
            _blockSlope =
                (MULTIPLIER * (block.number - _lastPoint.blk)) /
                (block.timestamp - _lastPoint.ts);
        }

        uint256 _ti = (_lastCheckPoint / WEEK) * WEEK;
        for (uint256 i; i < 255; i++) {
            _ti += WEEK;
            int256 d_slope = 0;
            if (_ti > block.timestamp) {
                _ti = block.timestamp;
            } else {
                d_slope = slopeChanges[_ti];
            }
            _lastPoint.bias =
                _lastPoint.bias -
                _lastPoint.slope *
                int256(_ti - _lastCheckPoint);
            _lastPoint.slope += d_slope;
            if (_lastPoint.bias < 0) {
                _lastPoint.bias = 0;
            }
            if (_lastPoint.slope < 0) {
                _lastPoint.slope = 0;
            }
            _lastCheckPoint = _ti;
            _lastPoint.ts = _ti;
            _lastPoint.blk =
                _initBlk +
                ((_blockSlope * (_ti - _initTs)) / MULTIPLIER);
            _st.epoch += 1;
            if (_ti == block.timestamp) {
                _lastPoint.blk = block.number;
                break;
            } else {
                supplyPointHistory[_st.epoch] = _lastPoint;
            }
        }
        epoch = _st.epoch;

        if (_addr != address(0)) {
            _lastPoint.slope += _st.userNewPoint.slope - _st.userOldPoint.slope;
            _lastPoint.bias += _st.userNewPoint.bias - _st.userOldPoint.bias;
            if (_lastPoint.slope < 0) {
                _lastPoint.slope = 0;
            }
            if (_lastPoint.bias < 0) {
                _lastPoint.bias = 0;
            }
        }
        supplyPointHistory[_st.epoch] = _lastPoint;
        if (_addr != address(0)) {
            if (_oldLocked.end > block.timestamp) {
                _st.oldDslope += _st.userOldPoint.slope;
                if (_newLocked.end == _oldLocked.end) {
                    _st.oldDslope -= _st.userNewPoint.slope; // It was a new deposit, not extension
                }
                slopeChanges[_oldLocked.end] = _st.oldDslope;
            }
            if (_newLocked.end > block.timestamp) {
                if (_newLocked.end > _oldLocked.end) {
                    _st.newDslope -= _st.userNewPoint.slope; // old slope disappeared at this point
                    slopeChanges[_newLocked.end] = _st.newDslope;
                }
            }

            uint256 _userEpoch = userPointEpoch[_addr] + 1;

            userPointEpoch[_addr] = _userEpoch;
            _st.userNewPoint.ts = block.timestamp;
            _st.userNewPoint.blk = block.number;
            userPointHistory[_addr][_userEpoch] = _st.userNewPoint;
        }
    }

    function _depositFor(
        address _provider,
        address _beneficiary,
        uint256 _value,
        uint256 _unlockTime,
        LockedBalance memory _lockedBalance,
        uint256 _type
    ) internal {

        LockedBalance memory _locked = LockedBalance(
            _lockedBalance.amount,
            _lockedBalance.end
        );
        LockedBalance memory _oldLocked = LockedBalance(
            _lockedBalance.amount,
            _lockedBalance.end
        );

        uint256 _supplyBefore = supply;
        supply = _supplyBefore + _value;
        _locked.amount = _locked.amount + int256(_value);
        if (_unlockTime != 0) {
            _locked.end = _unlockTime;
        }
        locked[_beneficiary] = _locked;


        _checkpoint(_beneficiary, _oldLocked, _locked);
        if (_value != 0) {
            IERC20Upgradeable(token).safeTransferFrom(
                _provider,
                address(this),
                _value
            );
        }

        emit Deposit(
            _provider,
            _beneficiary,
            _value,
            _locked.end,
            _type,
            block.timestamp
        );
        emit Supply(_supplyBefore, _supplyBefore + _value);
    }

    function checkpointSupply() public override {

        LockedBalance memory _a;
        LockedBalance memory _b;
        _checkpoint(address(0), _a, _b);
    }

    function createLockFor(
        address _beneficiary,
        uint256 _value,
        uint256 _unlockTime
    ) external override {

        _createLock(_beneficiary, _value, _unlockTime);
    }

    function createLock(uint256 _value, uint256 _unlockTime) external override {

        _createLock(msg.sender, _value, _unlockTime);
    }

    function _createLock(
        address _beneficiary,
        uint256 _value,
        uint256 _unlockTime
    ) internal nonReentrant {

        _unlockTime = (_unlockTime / WEEK) * WEEK; // Locktime is rounded down to weeks
        LockedBalance memory _locked = locked[_beneficiary];

        require(_value > 0, "Can't lock zero value");
        require(_locked.amount == 0, "Withdraw old tokens first");
        require(
            _unlockTime > block.timestamp,
            "Can only lock until time in the future"
        );
        require(
            _unlockTime <= block.timestamp + MAXTIME,
            "Voting lock can be 4 years max"
        );

        _depositFor(
            msg.sender,
            _beneficiary,
            _value,
            _unlockTime,
            _locked,
            CREATE_LOCK_TYPE
        );
    }

    function increaseAmount(uint256 _value) external override {

        _increaseAmount(msg.sender, _value);
    }

    function increaseAmountFor(address _beneficiary, uint256 _value)
        external
        override
    {

        _increaseAmount(_beneficiary, _value);
    }

    function _increaseAmount(address _beneficiary, uint256 _value)
        internal
        nonReentrant
    {

        LockedBalance memory _locked = locked[_beneficiary];

        require(_value > 0, "Can't increase zero value");
        require(_locked.amount > 0, "No existing lock found");
        require(
            _locked.end > block.timestamp,
            "Cannot add to expired lock. Withdraw"
        );

        _depositFor(
            msg.sender,
            _beneficiary,
            _value,
            0,
            _locked,
            INCREASE_LOCK_AMOUNT
        );
    }

    function increaseUnlockTime(uint256 _unlockTime)
        external
        override
        nonReentrant
    {

        LockedBalance memory _locked = locked[msg.sender];
        _unlockTime = (_unlockTime / WEEK) * WEEK; // Locktime is rounded down to weeks

        require(_locked.end > block.timestamp, "Lock expired");
        require(_locked.amount > 0, "Nothing is locked");
        require(_unlockTime > _locked.end, "Can only increase lock duration");
        require(
            _unlockTime <= block.timestamp + MAXTIME,
            "Voting lock can be 4 years max"
        );

        _depositFor(
            msg.sender,
            msg.sender,
            0,
            _unlockTime,
            _locked,
            INCREASE_UNLOCK_TIME
        );
    }

    function withdraw() external override nonReentrant {

        LockedBalance memory _locked = LockedBalance(
            locked[msg.sender].amount,
            locked[msg.sender].end
        );

        require(block.timestamp >= _locked.end, "The lock didn't expire");
        uint256 _value = uint256(_locked.amount);

        LockedBalance memory _oldLocked = LockedBalance(
            locked[msg.sender].amount,
            locked[msg.sender].end
        );

        _locked.end = 0;
        _locked.amount = 0;
        locked[msg.sender] = _locked;
        uint256 _supplyBefore = supply;
        supply = _supplyBefore - _value;

        _checkpoint(msg.sender, _oldLocked, _locked);

        IERC20Upgradeable(token).safeTransfer(msg.sender, _value);

        emit Withdraw(msg.sender, _value, block.timestamp);
        emit Supply(_supplyBefore, _supplyBefore - _value);
    }


    function findBlockEpoch(uint256 _block, uint256 _max_epoch)
        internal
        view
        returns (uint256)
    {

        uint256 _min = 0;
        uint256 _max = _max_epoch;
        for (uint256 i; i <= 128; i++) {
            if (_min >= _max) {
                break;
            }
            uint256 _mid = (_min + _max + 1) / 2;
            if (supplyPointHistory[_mid].blk <= _block) {
                _min = _mid;
            } else {
                _max = _mid - 1;
            }
        }
        return _min;
    }

    function balanceOf(address _addr) external view returns (uint256) {

        uint256 _t = block.timestamp;

        uint256 _epoch = userPointEpoch[_addr];
        if (_epoch == 0) {
            return 0;
        } else {
            Point memory _lastPoint = userPointHistory[_addr][_epoch];
            _lastPoint.bias -= _lastPoint.slope * int256(_t - _lastPoint.ts);
            if (_lastPoint.bias < 0) {
                _lastPoint.bias = 0;
            }
            return uint256(_lastPoint.bias);
        }
    }

    function balanceOf(address _addr, uint256 _t)
        external
        view
        returns (uint256)
    {

        if (_t == 0) {
            _t = block.timestamp;
        }

        uint256 _epoch = userPointEpoch[_addr];
        if (_epoch == 0) {
            return 0;
        } else {
            Point memory _lastPoint = userPointHistory[_addr][_epoch];
            _lastPoint.bias -= _lastPoint.slope * int256(_t - _lastPoint.ts);
            if (_lastPoint.bias < 0) {
                _lastPoint.bias = 0;
            }
            return uint256(_lastPoint.bias);
        }
    }

    struct Parameters {
        uint256 min;
        uint256 max;
        uint256 maxEpoch;
        uint256 dBlock;
        uint256 dt;
    }

    function balanceOfAt(address _addr, uint256 _block)
        external
        view
        returns (uint256)
    {

        require(_block <= block.number, "Can't exceed lasted block");

        Parameters memory _st;

        _st.min = 0;
        _st.max = userPointEpoch[_addr];

        for (uint256 i; i <= 128; i++) {
            if (_st.min >= _st.max) {
                break;
            }
            uint256 _mid = (_st.min + _st.max + 1) / 2;
            if (userPointHistory[_addr][_mid].blk <= _block) {
                _st.min = _mid;
            } else {
                _st.max = _mid - 1;
            }
        }
        Point memory _upoint = userPointHistory[_addr][_st.min];

        _st.maxEpoch = epoch;
        uint256 _epoch = findBlockEpoch(_block, _st.maxEpoch);
        Point memory _point = supplyPointHistory[_epoch];
        _st.dBlock = 0;
        _st.dt = 0;
        if (_epoch < _st.maxEpoch) {
            Point memory _point_1 = supplyPointHistory[_epoch + 1];
            _st.dBlock = _point_1.blk - _point.blk;
            _st.dt = _point_1.ts - _point.ts;
        } else {
            _st.dBlock = block.number - _point.blk;
            _st.dt = block.timestamp - _point.ts;
        }
        uint256 block_time = _point.ts;
        if (_st.dBlock != 0) {
            block_time += (_st.dt * (_block - _point.blk)) / _st.dBlock;
        }

        _upoint.bias -= _upoint.slope * int256(block_time - _upoint.ts);
        if (_upoint.bias >= 0) {
            return uint256(_upoint.bias);
        } else {
            return 0;
        }
    }

    function supplyAt(Point memory point, uint256 t)
        internal
        view
        returns (uint256)
    {

        Point memory _lastPoint = point;
        uint256 _ti = (_lastPoint.ts / WEEK) * WEEK;
        for (uint256 i; i < 255; i++) {
            _ti += WEEK;
            int256 d_slope = 0;

            if (_ti > t) {
                _ti = t;
            } else {
                d_slope = slopeChanges[_ti];
            }
            _lastPoint.bias -= _lastPoint.slope * int256(_ti - _lastPoint.ts);

            if (_ti == t) {
                break;
            }
            _lastPoint.slope += d_slope;
            _lastPoint.ts = _ti;
        }

        if (_lastPoint.bias < 0) {
            _lastPoint.bias = 0;
        }
        return uint256(_lastPoint.bias);
    }

    function totalSupply() external view returns (uint256) {

        uint256 _epoch = epoch;
        Point memory _lastPoint = supplyPointHistory[_epoch];

        return supplyAt(_lastPoint, block.timestamp);
    }

    function totalSupply(uint256 _t) external view returns (uint256) {

        if (_t == 0) {
            _t = block.timestamp;
        }

        uint256 _epoch = epoch;
        Point memory _lastPoint = supplyPointHistory[_epoch];

        return supplyAt(_lastPoint, _t);
    }

    function totalSupplyAt(uint256 _block) external view returns (uint256) {

        require(_block <= block.number, "Can't exceed the latest block");
        uint256 _epoch = epoch;
        uint256 _targetEpoch = findBlockEpoch(_block, _epoch);

        Point memory _point = supplyPointHistory[_targetEpoch];
        uint256 dt = 0;
        if (_targetEpoch < _epoch) {
            Point memory _pointNext = supplyPointHistory[_targetEpoch + 1];
            if (_point.blk != _pointNext.blk) {
                dt =
                    ((_block - _point.blk) * (_pointNext.ts - _point.ts)) /
                    (_pointNext.blk - _point.blk);
            }
        } else {
            if (_point.blk != block.number) {
                dt =
                    ((_block - _point.blk) * (block.timestamp - _point.ts)) /
                    (block.number - _point.blk);
            }
        }

        return supplyAt(_point, _point.ts + dt);
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC20Upgradeable {

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
}// MIT

pragma solidity ^0.8.0;

library AddressUpgradeable {

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
}// MIT

pragma solidity ^0.8.0;


library SafeERC20Upgradeable {

    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}