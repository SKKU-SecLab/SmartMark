
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
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

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


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

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

    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

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
}pragma solidity ^0.6.0;

interface ILockSubscription {
    function processLockEvent(
        address account,
        uint256 lockStart,
        uint256 lockEnd,
        uint256 amount
    ) external;
}pragma solidity ^0.6.0;



contract VeXBE is Initializable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;


    struct Point {
        int128 bias;
        int128 slope; // - dweight / dt
        uint256 ts;
        uint256 blk; // block
    }

    struct LockedBalance {
        int128 amount;
        uint256 end;
    }

    event CommitOwnership(address admin);
    event ApplyOwnership(address admin);
    event Deposit(
        address indexed provider,
        uint256 value,
        uint256 indexed locktime,
        int128 _type,
        uint256 ts
    );
    event Withdraw(address indexed provider, uint256 value, uint256 ts);
    event Supply(uint256 prevSupply, uint256 supply);

    int128 public constant DEPOSIT_FOR_TYPE = 0;
    int128 public constant CREATE_LOCK_TYPE = 1;
    int128 public constant INCREASE_LOCK_AMOUNT = 2;
    int128 public constant INCREASE_UNLOCK_TIME = 3;

    uint256 public constant YEAR = 86400 * 365;
    uint256 public constant WEEK = 7 * 86400; // all future times are rounded by week
    uint256 public constant MAXTIME = 100 * WEEK; // 2 years (23.333 Months)
    uint256 public constant MULTIPLIER = 10**18;

    uint256 public supply;

    mapping(address => LockedBalance) public locked;
    mapping(address => uint256) internal _lockStarts;

    uint256 public epoch;
    mapping(uint256 => Point) public pointHistory; // epoch -> unsigned point /*Point[100000000000000000000000000000]*/

    mapping(address => mapping(uint256 => Point)) public userPointHistory; // user -> Point[user_epoch]

    mapping(address => uint256) public userPointEpoch;
    mapping(uint256 => int128) public slopeChanges; // time -> signed slope change

    address public votingStakingRewards;
    ILockSubscription public registrationMediator;

    address public controller;

    string public name;
    string public symbol;
    string public version;
    uint256 public decimals;

    address public admin;
    address public futureAdmin;

    uint256 public minLockDuration;

    mapping(address => mapping(address => bool)) public createLockAllowance;

    modifier onlyAdmin() {
        require(msg.sender == admin, "!admin");
        _;
    }

    function configure(
        address tokenAddr,
        address _votingStakingRewards,
        address _registrationMediator,
        uint256 _minLockDuration,
        string calldata _name,
        string calldata _symbol,
        string calldata _version
    ) external initializer {
        admin = msg.sender;
        pointHistory[0].blk = block.number;
        pointHistory[0].ts = block.timestamp;
        controller = msg.sender;
        uint256 _decimals = ERC20(tokenAddr).decimals();
        require(_decimals <= 255, "decimalsOverflow");
        decimals = _decimals;
        name = _name;
        symbol = _symbol;
        version = _version;
        votingStakingRewards = _votingStakingRewards;
        registrationMediator = ILockSubscription(_registrationMediator);

        _setMinLockDuration(_minLockDuration);
    }

    function _setMinLockDuration(uint256 _minLockDuration) private {
        require(_minLockDuration < MAXTIME, "!badMinLockDuration");
        minLockDuration = _minLockDuration;
    }

    function setMinLockDuration(uint256 _minLockDuration) external onlyAdmin {
        _setMinLockDuration(_minLockDuration);
    }

    function setVoting(address _votingStakingRewards) external onlyAdmin {
        require(_votingStakingRewards != address(0), "addressIsZero");
        votingStakingRewards = _votingStakingRewards;
    }

    function commitTransferOwnership(address addr) external onlyAdmin {
        futureAdmin = addr;
        emit CommitOwnership(addr);
    }

    function applyTransferOwnership() external onlyAdmin {
        address _admin = futureAdmin;
        require(_admin != address(0), "adminIsZero");
        admin = _admin;
        emit ApplyOwnership(_admin);
    }

    function getLastUserSlope(address addr) external view returns (int128) {
        uint256 uepoch = userPointEpoch[addr];
        return userPointHistory[addr][uepoch].slope;
    }

    function userPointHistoryTs(address addr, uint256 idx)
        external
        view
        returns (uint256)
    {
        return userPointHistory[addr][idx].ts;
    }

    function lockedEnd(address addr) external view returns (uint256) {
        return locked[addr].end;
    }

    function lockStarts(address addr) external view returns (uint256) {
        return _lockStarts[addr];
    }

    function lockedAmount(address addr) external view returns (uint256) {
        return uint256(locked[addr].amount);
    }

    function _checkpoint(
        address addr,
        LockedBalance memory oldLocked,
        LockedBalance memory newLocked
    ) internal {
        Point memory uOld;
        Point memory uNew;
        int128 oldDSlope = 0;
        int128 newDSlope = 0;

        if (addr != address(0)) {
            if (oldLocked.end > block.timestamp && oldLocked.amount > 0) {
                uOld.slope = int128(uint256(oldLocked.amount) / MAXTIME);
                uOld.bias =
                    uOld.slope *
                    int128(oldLocked.end - block.timestamp);
            }
            if (newLocked.end > block.timestamp && newLocked.amount > 0) {
                uNew.slope = int128(uint256(newLocked.amount) / MAXTIME);
                uNew.bias =
                    uNew.slope *
                    int128(newLocked.end - block.timestamp);
            }

            oldDSlope = slopeChanges[oldLocked.end];
            if (newLocked.end != 0) {
                if (newLocked.end == oldLocked.end) {
                    newDSlope = oldDSlope;
                } else {
                    newDSlope = slopeChanges[newLocked.end];
                }
            }
        }
        Point memory lastPoint = Point({
            bias: 0,
            slope: 0,
            ts: block.timestamp,
            blk: block.number
        });
        if (
            epoch > 0 /*_epoch*/
        ) {
            lastPoint = pointHistory[
                epoch /*_epoch*/
            ];
        }


        Point memory initialLastPoint = lastPoint;
        uint256 blockSlope = 0;
        if (block.timestamp > lastPoint.ts) {
            blockSlope =
                (MULTIPLIER * (block.number - lastPoint.blk)) /
                (block.timestamp - lastPoint.ts);
        }

        uint256 tI = (lastPoint.ts / WEEK) * WEEK; /*lastCheckpoint*/

        for (uint256 i = 0; i < 255; i++) {
            tI += WEEK;
            int128 dSlope = 0;

            if (tI > block.timestamp) {
                tI = block.timestamp;
            } else {
                dSlope = slopeChanges[tI];
            }

            lastPoint.bias -=
                lastPoint.slope *
                int128(
                    tI - lastPoint.ts /*lastCheckpoint*/
                );
            lastPoint.slope += dSlope;

            if (lastPoint.bias < 0) {
                lastPoint.bias = 0;
            }

            if (lastPoint.slope < 0) {
                lastPoint.slope = 0;
            }

            lastPoint.ts = tI;
            lastPoint.blk =
                initialLastPoint.blk +
                (blockSlope * (tI - initialLastPoint.ts)) /
                MULTIPLIER;
            epoch += 1; /*_epoch*/

            if (tI == block.timestamp) {
                lastPoint.blk = block.number;
                break;
            } else {
                pointHistory[
                    epoch /*_epoch*/
                ] = lastPoint;
            }
        }


        if (addr != address(0)) {
            lastPoint.slope += (uNew.slope - uOld.slope);
            lastPoint.bias += (uNew.bias - uOld.bias);
            if (lastPoint.slope < 0) {
                lastPoint.slope = 0;
            }
            if (lastPoint.bias < 0) {
                lastPoint.bias = 0;
            }
        }

        pointHistory[
            epoch /*_epoch*/
        ] = lastPoint;

        if (addr != address(0)) {
            if (oldLocked.end > block.timestamp) {
                oldDSlope += uOld.slope;
                if (newLocked.end == oldLocked.end) {
                    oldDSlope -= uNew.slope;
                }
                slopeChanges[oldLocked.end] = oldDSlope;
            }
            if (newLocked.end > block.timestamp) {
                if (newLocked.end > oldLocked.end) {
                    newDSlope -= uNew.slope;
                    slopeChanges[newLocked.end] = newDSlope;
                }
            }


            userPointEpoch[addr] += 1; //= userPointEpoch[addr] + 1/*userEpoch*/;
            uNew.ts = block.timestamp;
            uNew.blk = block.number;
            userPointHistory[addr][
                userPointEpoch[addr] /*userEpoch*/
            ] = uNew;
        }
    }

    function _canConvertInt128(uint256 value) internal pure returns (bool) {
        return value < 2**127;
    }

    function _depositFor(
        address _addr,
        uint256 _value,
        uint256 unlockTime,
        LockedBalance memory lockedBalance,
        int128 _type
    ) internal {
        LockedBalance memory _locked = LockedBalance({
            amount: lockedBalance.amount,
            end: lockedBalance.end
        });
        uint256 supplyBefore = supply;

        supply = supplyBefore.add(_value);
        LockedBalance memory oldLocked = lockedBalance;

        require(_canConvertInt128(_value), "!convertInt128");
        _locked.amount += int128(_value);
        if (unlockTime != 0) {
            _locked.end = unlockTime;
        }
        locked[_addr] = _locked;

        _checkpoint(_addr, oldLocked, _locked);

        require(
            IERC20(votingStakingRewards).balanceOf(_addr) >=
                uint256(_locked.amount),
            "notEnoughStake"
        );

        registrationMediator.processLockEvent(
            _addr,
            _lockStarts[_addr],
            _locked.end,
            uint256(_locked.amount)
        );

        emit Deposit(_addr, _value, _locked.end, _type, block.timestamp);
        emit Supply(supplyBefore, supplyBefore.add(_value));
    }

    function checkpoint() external {
        LockedBalance memory _emptyBalance;
        _checkpoint(address(0), _emptyBalance, _emptyBalance);
    }

    function depositFor(address _addr, uint256 _value) external nonReentrant {
        LockedBalance memory _locked = locked[_addr];
        require(_value > 0, "!zeroValue");
        require(_locked.amount > 0, "!zeroLockedAmount");
        require(_locked.end > block.timestamp, "lockExpired");
        _depositFor(_addr, _value, 0, _locked, DEPOSIT_FOR_TYPE);
    }

    function createLock(uint256 _value, uint256 _unlockTime)
        external
        nonReentrant
    {
        _createLockFor(msg.sender, _value, _unlockTime);
    }

    function setCreateLockAllowance(address _sender, bool _status) external {
        createLockAllowance[msg.sender][_sender] = _status;
    }

    function _createLockFor(
        address _for,
        uint256 _value,
        uint256 _unlockTime
    ) internal {
        uint256 unlockTime = (_unlockTime / WEEK) * WEEK; // # Locktime is rounded down to weeks
        LockedBalance memory _locked = locked[_for];

        require(_value > 0, "!zeroValue");
        require(_locked.amount == 0, "!withdrawOldTokensFirst");
        require(unlockTime > block.timestamp, "!futureTime");
        require(
            unlockTime >= minLockDuration + block.timestamp,
            "!minLockDuration"
        );
        require(
            unlockTime <= block.timestamp.add(MAXTIME),
            "invalidFutureTime"
        );

        _lockStarts[_for] = block.timestamp;

        _depositFor(_for, _value, unlockTime, _locked, CREATE_LOCK_TYPE);
    }

    function createLockFor(
        address _for,
        uint256 _value,
        uint256 _unlockTime
    ) external nonReentrant {
        if (msg.sender != votingStakingRewards) {
            require(createLockAllowance[msg.sender][_for], "!allowed");
        }
        _createLockFor(_for, _value, _unlockTime);
    }

    function increaseAmount(uint256 _value) external nonReentrant {
        LockedBalance memory _locked = locked[msg.sender];
        require(_value > 0, "!zeroValue");
        require(_locked.amount > 0, "!zeroLockedAmount");
        require(_locked.end > block.timestamp, "lockExpired");
        _depositFor(msg.sender, _value, 0, _locked, INCREASE_LOCK_AMOUNT);
    }

    function increaseUnlockTime(uint256 _unlockTime) external nonReentrant {
        LockedBalance memory _locked = locked[msg.sender];
        uint256 unlockTime = (_unlockTime / WEEK) * WEEK; // Locktime is rounded down to weeks

        require(_locked.end > block.timestamp, "lockExpired");
        require(_locked.amount > 0, "!zeroLockedAmount");
        require(unlockTime > _locked.end, "canOnlyIncreaseLockDuration");
        require(
            unlockTime <= block.timestamp.add(MAXTIME),
            "lockOnlyToValidFutureTime"
        );

        _depositFor(msg.sender, 0, unlockTime, _locked, INCREASE_UNLOCK_TIME);
    }

    function withdraw() external nonReentrant {
        LockedBalance memory _locked = locked[msg.sender];
        require(block.timestamp >= _locked.end, "lockDidntExpired");
        uint256 value = uint256(_locked.amount);

        LockedBalance memory oldLocked = _locked;
        _locked.end = 0;
        _locked.amount = 0;
        locked[msg.sender] = _locked;
        uint256 supplyBefore = supply;
        supply = supplyBefore - value;

        _checkpoint(msg.sender, oldLocked, _locked);

        emit Withdraw(msg.sender, value, block.timestamp);
        emit Supply(supplyBefore, supplyBefore - value);
    }

    function findBlockEpoch(uint256 _block, uint256 maxEpoch)
        internal
        view
        returns (uint256)
    {
        uint256 _min = 0;
        uint256 _max = maxEpoch;
        for (uint256 i = 0; i < 128; i++) {
            if (_min >= _max) {
                break;
            }
            uint256 _mid = (_min + _max + 1) / 2;
            if (pointHistory[_mid].blk <= _block) {
                _min = _mid;
            } else {
                _max = _mid - 1;
            }
        }
        return _min;
    }

    function balanceOf(address addr) public view returns (uint256) {
        return balanceOf(addr, block.timestamp);
    }

    function balanceOf(address addr, uint256 _t) public view returns (uint256) {
        uint256 _epoch = userPointEpoch[addr];
        if (_epoch == 0) {
            return 0;
        } else {
            Point memory lastPoint = userPointHistory[addr][_epoch];
            lastPoint.bias -= lastPoint.slope * int128(_t - lastPoint.ts);
            if (lastPoint.bias < 0) {
                lastPoint.bias = 0;
            }
            return uint256(lastPoint.bias);
        }
    }

    function balanceOfAt(address addr, uint256 _block)
        external
        view
        returns (uint256)
    {
        require(_block <= block.number, "onlyPast");

        uint256 _min = 0;
        uint256 _max = userPointEpoch[addr];
        for (uint256 i = 0; i < 128; i++) {
            if (_min >= _max) {
                break;
            }
            uint256 _mid = (_min + _max + 1) / 2;
            if (userPointHistory[addr][_mid].blk <= _block) {
                _min = _mid;
            } else {
                _max = _mid - 1;
            }
        }

        Point memory upoint = userPointHistory[addr][_min];

        uint256 maxEpoch = epoch;
        uint256 _epoch = findBlockEpoch(_block, maxEpoch);
        Point memory point0 = pointHistory[_epoch];
        uint256 dBlock = 0;
        uint256 dT = 0;
        if (_epoch < maxEpoch) {
            Point memory point1 = pointHistory[_epoch + 1];
            dBlock = point1.blk - point0.blk;
            dT = point1.ts - point0.ts;
        } else {
            dBlock = block.number - point0.blk;
            dT = block.timestamp - point0.ts;
        }
        uint256 blockTime = point0.ts;
        if (dBlock != 0) {
            blockTime += (dT * (_block - point0.blk)) / dBlock;
        }

        upoint.bias -= upoint.slope * int128(blockTime - upoint.ts);
        if (upoint.bias >= 0) {
            return uint256(upoint.bias);
        } else {
            return 0;
        }
    }

    function supplyAt(Point memory point, uint256 t)
        internal
        view
        returns (uint256)
    {
        Point memory lastPoint = point;
        uint256 tI = (lastPoint.ts / WEEK) * WEEK;
        for (uint256 i = 0; i < 255; i++) {
            tI += WEEK;
            int128 dSlope = 0;
            if (tI > t) {
                tI = t;
            } else {
                dSlope = slopeChanges[tI];
            }
            lastPoint.bias -= lastPoint.slope * int128(tI - lastPoint.ts);
            if (tI == t) {
                break;
            }
            lastPoint.slope += dSlope;
            lastPoint.ts = tI;
        }

        if (lastPoint.bias < 0) {
            lastPoint.bias = 0;
        }
        return uint256(lastPoint.bias);
    }

    function totalSupply() external view returns (uint256) {
        return totalSupply(block.timestamp);
    }

    function lockedSupply() external view returns (uint256) {
        return supply;
    }

    function totalSupply(uint256 t) public view returns (uint256) {
        uint256 _epoch = epoch;
        Point memory lastPoint = pointHistory[_epoch];
        return supplyAt(lastPoint, t);
    }

    function totalSupplyAt(uint256 _block) external view returns (uint256) {
        require(_block <= block.number, "onlyPastAllowed");
        uint256 _epoch = epoch;
        uint256 targetEpoch = findBlockEpoch(_block, _epoch);

        Point memory point = pointHistory[targetEpoch];
        uint256 dt = 0; // difference in total voting power between _epoch and targetEpoch

        if (targetEpoch < _epoch) {
            Point memory pointNext = pointHistory[targetEpoch + 1];
            if (point.blk != pointNext.blk) {
                dt =
                    ((_block - point.blk) * (pointNext.ts - point.ts)) /
                    (pointNext.blk - point.blk);
            }
        } else {
            if (point.blk != block.number) {
                dt =
                    ((_block - point.blk) * (block.timestamp - point.ts)) /
                    (block.number - point.blk);
            }
        }

        return supplyAt(point, point.ts + dt);
    }

    function changeController(address _newController) external {
        require(msg.sender == controller, "!controller");
        controller = _newController;
    }
}