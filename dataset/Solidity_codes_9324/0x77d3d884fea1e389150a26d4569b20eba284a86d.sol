pragma solidity ^0.8.0;

interface IVotingEscrowDelegate {

    event Withdraw(address indexed addr, uint256 amount, uint256 penaltyRate);

    function withdraw(address addr, uint256 penaltyRate) external;

}// UNLICENSED
pragma solidity ^0.8.0;

interface IVotingEscrow {

    event SetMigrator(address indexed account);
    event SetDelegate(address indexed account, bool isDelegate);
    event Deposit(
        address indexed provider,
        uint256 value,
        uint256 discount,
        uint256 indexed unlockTime,
        int128 indexed _type,
        uint256 ts
    );
    event Cancel(address indexed provider, uint256 value, uint256 discount, uint256 penaltyRate, uint256 ts);
    event Withdraw(address indexed provider, uint256 value, uint256 discount, uint256 ts);
    event Migrate(address indexed provider, uint256 value, uint256 discount, uint256 ts);
    event Supply(uint256 prevSupply, uint256 supply);

    function interval() external view returns (uint256);


    function maxDuration() external view returns (uint256);


    function token() external view returns (address);


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);


    function migrator() external view returns (address);


    function isDelegate(address account) external view returns (bool);


    function supply() external view returns (uint256);


    function migrated(address account) external view returns (bool);


    function delegateAt(address account, uint256 index) external view returns (address);


    function locked(address account)
        external
        view
        returns (
            int128 amount,
            int128 discount,
            uint256 start,
            uint256 end
        );


    function epoch() external view returns (uint256);


    function pointHistory(uint256 epoch)
        external
        view
        returns (
            int128 bias,
            int128 slope,
            uint256 ts,
            uint256 blk
        );


    function userPointHistory(address account, uint256 epoch)
        external
        view
        returns (
            int128 bias,
            int128 slope,
            uint256 ts,
            uint256 blk
        );


    function userPointEpoch(address account) external view returns (uint256);


    function slopeChanges(uint256 epoch) external view returns (int128);


    function delegateLength(address addr) external view returns (uint256);


    function getLastUserSlope(address addr) external view returns (int128);


    function getCheckpointTime(address _addr, uint256 _idx) external view returns (uint256);


    function unlockTime(address _addr) external view returns (uint256);


    function setMigrator(address _migrator) external;


    function setDelegate(address account, bool _isDelegate) external;


    function checkpoint() external;


    function depositFor(address _addr, uint256 _value) external;


    function createLockFor(
        address _addr,
        uint256 _value,
        uint256 _discount,
        uint256 _duration
    ) external;


    function createLock(uint256 _value, uint256 _duration) external;


    function increaseAmountFor(
        address _addr,
        uint256 _value,
        uint256 _discount
    ) external;


    function increaseAmount(uint256 _value) external;


    function increaseUnlockTime(uint256 _duration) external;


    function cancel() external;


    function withdraw() external;


    function migrate() external;


    function balanceOf(address addr) external view returns (uint256);


    function balanceOf(address addr, uint256 _t) external view returns (uint256);


    function balanceOfAt(address addr, uint256 _block) external view returns (uint256);


    function totalSupply() external view returns (uint256);


    function totalSupply(uint256 t) external view returns (uint256);


    function totalSupplyAt(uint256 _block) external view returns (uint256);

}// WTFPL
pragma solidity ^0.8.0;

interface INFT {

    function balanceOf(address owner) external view returns (uint256 balance);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function mint(
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;


    function mintBatch(
        address to,
        uint256[] calldata tokenIds,
        bytes calldata data
    ) external;


    function burn(
        uint256 tokenId,
        uint256 label,
        bytes32 data
    ) external;

}// UNLICENSED
pragma solidity ^0.8.14;


abstract contract VotingEscrowDelegate is IVotingEscrowDelegate {
    address public immutable ve;
    address public immutable token;
    address public immutable discountToken;

    uint256 internal immutable _maxDuration;
    uint256 internal immutable _interval;

    event CreateLock(address indexed account, uint256 amount, uint256 discount, uint256 indexed locktime);
    event IncreaseAmount(address indexed account, uint256 amount, uint256 discount);

    constructor(
        address _ve,
        address _token,
        address _discountToken
    ) {
        ve = _ve;
        token = _token;
        discountToken = _discountToken;

        _maxDuration = IVotingEscrow(_ve).maxDuration();
        _interval = IVotingEscrow(ve).interval();
    }

    modifier eligibleForDiscount {
        require(INFT(discountToken).balanceOf(msg.sender) > 0, "VED: DISCOUNT_TOKEN_NOT_OWNED");
        _;
    }

    function createLockDiscounted(uint256 amount, uint256 duration) external eligibleForDiscount {
        _createLock(amount, duration, true);
    }

    function createLock(uint256 amount, uint256 duration) external {
        _createLock(amount, duration, false);
    }

    function _createLock(
        uint256 amount,
        uint256 duration,
        bool discounted
    ) internal virtual {
        require(duration <= _maxDuration, "VED: DURATION_TOO_LONG");

        uint256 unlockTime = ((block.timestamp + duration) / _interval) * _interval; // rounded down to a multiple of interval
        uint256 _duration = unlockTime - block.timestamp;
        (uint256 amountVE, uint256 amountToken) = _getAmounts(amount, _duration);
        if (discounted) {
            amountVE = (amountVE * 100) / 90;
        }

        emit CreateLock(msg.sender, amountVE, amountVE - amountToken, unlockTime);
        IVotingEscrow(ve).createLockFor(msg.sender, amountVE, amountVE - amountToken, _duration);
    }

    function increaseAmountDiscounted(uint256 amount) external eligibleForDiscount {
        _increaseAmount(amount, true);
    }

    function increaseAmount(uint256 amount) external {
        _increaseAmount(amount, false);
    }

    function _increaseAmount(uint256 amount, bool discounted) internal virtual {
        uint256 unlockTime = IVotingEscrow(ve).unlockTime(msg.sender);
        require(unlockTime > 0, "VED: LOCK_NOT_FOUND");

        (uint256 amountVE, uint256 amountToken) = _getAmounts(amount, unlockTime - block.timestamp);
        if (discounted) {
            amountVE = (amountVE * 100) / 90;
        }

        emit IncreaseAmount(msg.sender, amountVE, amountVE - amountToken);
        IVotingEscrow(ve).increaseAmountFor(msg.sender, amountVE, amountVE - amountToken);
    }

    function _getAmounts(uint256 amount, uint256 duration)
        internal
        view
        virtual
        returns (uint256 amountVE, uint256 amountToken);

    function withdraw(address, uint256) external virtual override {
    }
}// UNLICENSED
pragma solidity ^0.8.14;


contract BoostedVotingEscrowDelegate is VotingEscrowDelegate {

    uint256 public immutable minDuration;
    uint256 public immutable maxBoost;
    uint256 public immutable deadline;

    constructor(
        address _ve,
        address _token,
        address _discountToken,
        uint256 _minDuration,
        uint256 _maxBoost,
        uint256 _deadline
    ) VotingEscrowDelegate(_ve, _token, _discountToken) {
        minDuration = _minDuration;
        maxBoost = _maxBoost;
        deadline = _deadline;
    }

    function _createLock(
        uint256 amountToken,
        uint256 duration,
        bool discounted
    ) internal override {

        require(block.timestamp < deadline, "BVED: EXPIRED");
        require(duration >= minDuration, "BVED: DURATION_TOO_SHORT");

        super._createLock(amountToken, duration, discounted);
    }

    function _increaseAmount(uint256 amountToken, bool discounted) internal override {

        require(block.timestamp < deadline, "BVED: EXPIRED");

        super._increaseAmount(amountToken, discounted);
    }

    function _getAmounts(uint256 amount, uint256 duration)
        internal
        view
        override
        returns (uint256 amountVE, uint256 amountToken)
    {

        amountVE = (amount * maxBoost * duration) / _maxDuration;
        amountToken = amount;
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

}// MIT

pragma solidity ^0.8.1;

library Address {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
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
}// MIT

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
}pragma solidity >=0.5.0;

interface IUniswapV2Pair {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);


    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;


    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);


    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;


    function initialize(address, address) external;

}// UNLICENSED
pragma solidity ^0.8.0;

interface IVotingEscrowMigrator {

    function migrate(
        address account,
        int128 amount,
        int128 discount,
        uint256 start,
        uint256 end,
        address[] calldata delegates
    ) external;

}// UNLICENSED
pragma solidity ^0.8.14;


contract LPVotingEscrowDelegate is VotingEscrowDelegate {

    using SafeERC20 for IERC20;

    struct LockedBalance {
        uint256 amount;
        uint256 end;
    }

    bool internal immutable isToken1;
    uint256 public immutable minAmount;
    uint256 public immutable maxBoost;

    uint256 public lockedTotal;
    mapping(address => uint256) public locked;

    constructor(
        address _ve,
        address _lpToken,
        address _discountToken,
        bool _isToken1,
        uint256 _minAmount,
        uint256 _maxBoost
    ) VotingEscrowDelegate(_ve, _lpToken, _discountToken) {
        isToken1 = _isToken1;
        minAmount = _minAmount;
        maxBoost = _maxBoost;
    }

    function _createLock(
        uint256 amount,
        uint256 duration,
        bool discounted
    ) internal override {

        require(amount >= minAmount, "LSVED: AMOUNT_TOO_LOW");

        super._createLock(amount, duration, discounted);

        lockedTotal += amount;
        locked[msg.sender] += amount;
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
    }

    function _increaseAmount(uint256 amount, bool discounted) internal override {

        require(amount >= minAmount, "LSVED: AMOUNT_TOO_LOW");

        super._increaseAmount(amount, discounted);

        lockedTotal += amount;
        locked[msg.sender] += amount;
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
    }

    function _getAmounts(uint256 amount, uint256)
        internal
        view
        override
        returns (uint256 amountVE, uint256 amountToken)
    {

        (uint112 reserve0, uint112 reserve1, ) = IUniswapV2Pair(token).getReserves();
        uint256 reserve = isToken1 ? uint256(reserve1) : uint256(reserve0);

        uint256 totalSupply = IUniswapV2Pair(token).totalSupply();
        uint256 _amountToken = (amount * reserve) / totalSupply;

        amountVE = _amountToken + (_amountToken * maxBoost * (totalSupply - lockedTotal)) / totalSupply / totalSupply;
        uint256 upperBound = (_amountToken * 333) / 10;
        if (amountVE > upperBound) {
            amountVE = upperBound;
        }
        amountToken = 0;
    }

    function withdraw(address addr, uint256 penaltyRate) external override {

        require(msg.sender == ve, "LSVED: FORBIDDEN");

        uint256 amount = locked[addr];
        require(amount > 0, "LSVED: LOCK_NOT_FOUND");

        lockedTotal -= amount;
        locked[addr] = 0;
        IERC20(token).safeTransfer(addr, (amount * (1e18 - penaltyRate)) / 1e18);

        emit Withdraw(addr, amount, penaltyRate);
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// UNLICENSED
pragma solidity ^0.8.14;

library Integers {

    function toInt128(uint256 u) internal pure returns (int128) {

        return int128(int256(u));
    }

    function toUint256(int128 i) internal pure returns (uint256) {

        return uint256(uint128(i));
    }
}// UNLICENSED
pragma solidity ^0.8.14;




contract VotingEscrow is Ownable, ReentrancyGuard, IVotingEscrow {

    using SafeERC20 for IERC20;
    using Integers for int128;
    using Integers for uint256;

    struct Point {
        int128 bias;
        int128 slope; // - dweight / dt
        uint256 ts;
        uint256 blk; // block
    }

    struct LockedBalance {
        int128 amount;
        int128 discount;
        uint256 start;
        uint256 end;
    }

    int128 public constant DEPOSIT_FOR_TYPE = 0;
    int128 public constant CRETE_LOCK_TYPE = 1;
    int128 public constant INCREASE_LOCK_AMOUNT = 2;
    int128 public constant INCREASE_UNLOCK_TIME = 3;
    uint256 internal constant MULTIPLIER = 1e18;

    uint256 public immutable override interval;
    uint256 public immutable override maxDuration;
    address public immutable override token;
    string public override name;
    string public override symbol;
    uint8 public immutable override decimals;

    address public override migrator;
    mapping(address => bool) public override isDelegate;

    uint256 public override supply;
    mapping(address => bool) public override migrated;
    mapping(address => address[]) public override delegateAt;
    mapping(address => LockedBalance) public override locked;
    uint256 public override epoch;

    mapping(uint256 => Point) public override pointHistory; // epoch -> unsigned point
    mapping(address => mapping(uint256 => Point)) public override userPointHistory; // user -> Point[user_epoch]
    mapping(address => uint256) public override userPointEpoch;
    mapping(uint256 => int128) public override slopeChanges; // time -> signed slope change

    constructor(
        address _token,
        string memory _name,
        string memory _symbol,
        uint256 _interval,
        uint256 _maxDuration
    ) {
        token = _token;
        name = _name;
        symbol = _symbol;
        decimals = IERC20Metadata(_token).decimals();

        interval = _interval;
        maxDuration = (_maxDuration / _interval) * _interval; // rounded down to a multiple of interval

        pointHistory[0].blk = block.number;
        pointHistory[0].ts = block.timestamp;
    }

    modifier beforeMigrated(address addr) {

        require(!migrated[addr], "VE: LOCK_MIGRATED");
        _;
    }

    modifier onlyDelegate {

        require(isDelegate[msg.sender], "VE: NOT_DELEGATE");
        _;
    }

    modifier authorized {

        if (msg.sender != tx.origin) {
            require(isDelegate[msg.sender], "VE: CONTRACT_NOT_DELEGATE");
        }
        _;
    }

    function delegateLength(address addr) external view returns (uint256) {

        return delegateAt[addr].length;
    }

    function getLastUserSlope(address addr) external view override returns (int128) {

        uint256 uepoch = userPointEpoch[addr];
        return userPointHistory[addr][uepoch].slope;
    }

    function getCheckpointTime(address _addr, uint256 _idx) external view override returns (uint256) {

        return userPointHistory[_addr][_idx].ts;
    }

    function unlockTime(address _addr) external view override returns (uint256) {

        return locked[_addr].end;
    }

    function setMigrator(address _migrator) external override onlyOwner {

        require(migrator == address(0), "VE: MIGRATOR_SET");

        migrator = _migrator;

        emit SetMigrator(_migrator);
    }

    function setDelegate(address account, bool _isDelegate) external override onlyOwner {

        isDelegate[account] = _isDelegate;

        emit SetDelegate(account, _isDelegate);
    }

    function _checkpoint(
        address addr,
        LockedBalance memory old_locked,
        LockedBalance memory new_locked
    ) internal {

        Point memory u_old;
        Point memory u_new;
        int128 old_dslope;
        int128 new_dslope;
        uint256 _epoch = epoch;

        if (addr != address(0)) {
            if (old_locked.end > block.timestamp && old_locked.amount > 0) {
                u_old.slope = old_locked.amount / maxDuration.toInt128();
                u_old.bias = u_old.slope * (old_locked.end - block.timestamp).toInt128();
            }
            if (new_locked.end > block.timestamp && new_locked.amount > 0) {
                u_new.slope = new_locked.amount / maxDuration.toInt128();
                u_new.bias = u_new.slope * (new_locked.end - block.timestamp).toInt128();
            }

            old_dslope = slopeChanges[old_locked.end];
            if (new_locked.end != 0) {
                if (new_locked.end == old_locked.end) new_dslope = old_dslope;
                else new_dslope = slopeChanges[new_locked.end];
            }
        }

        Point memory last_point = Point({bias: 0, slope: 0, ts: block.timestamp, blk: block.number});
        if (_epoch > 0) last_point = pointHistory[_epoch];
        uint256 last_checkpoint = last_point.ts;
        Point memory initial_last_point = Point(last_point.bias, last_point.slope, last_point.ts, last_point.blk);
        uint256 block_slope; // dblock/dt
        if (block.timestamp > last_point.ts)
            block_slope = (MULTIPLIER * (block.number - last_point.blk)) / (block.timestamp - last_point.ts);

        {
            uint256 t_i = (last_checkpoint / interval) * interval;
            for (uint256 i; i < 255; i++) {
                t_i += interval;
                int128 d_slope;
                if (t_i > block.timestamp) t_i = block.timestamp;
                else d_slope = slopeChanges[t_i];
                last_point.bias -= last_point.slope * (t_i - last_checkpoint).toInt128();
                last_point.slope += d_slope;
                if (last_point.bias < 0)
                    last_point.bias = 0;
                if (last_point.slope < 0)
                    last_point.slope = 0;
                last_checkpoint = t_i;
                last_point.ts = t_i;
                last_point.blk = initial_last_point.blk + (block_slope * (t_i - initial_last_point.ts)) / MULTIPLIER;
                _epoch += 1;
                if (t_i == block.timestamp) {
                    last_point.blk = block.number;
                    break;
                } else pointHistory[_epoch] = last_point;
            }
        }

        epoch = _epoch;

        if (addr != address(0)) {
            last_point.slope += (u_new.slope - u_old.slope);
            last_point.bias += (u_new.bias - u_old.bias);
            if (last_point.slope < 0) last_point.slope = 0;
            if (last_point.bias < 0) last_point.bias = 0;
        }

        pointHistory[_epoch] = last_point;

        if (addr != address(0)) {
            if (old_locked.end > block.timestamp) {
                old_dslope += u_old.slope;
                if (new_locked.end == old_locked.end) old_dslope -= u_new.slope; // It was a new deposit, not extension
                slopeChanges[old_locked.end] = old_dslope;
            }

            if (new_locked.end > block.timestamp) {
                if (new_locked.end > old_locked.end) {
                    new_dslope -= u_new.slope; // old slope disappeared at this point
                    slopeChanges[new_locked.end] = new_dslope;
                }
            }

            uint256 user_epoch = userPointEpoch[addr] + 1;

            userPointEpoch[addr] = user_epoch;
            u_new.ts = block.timestamp;
            u_new.blk = block.number;
            userPointHistory[addr][user_epoch] = u_new;
        }
    }

    function _depositFor(
        address _addr,
        uint256 _value,
        uint256 _discount,
        uint256 unlock_time,
        LockedBalance memory locked_balance,
        int128 _type
    ) internal {

        LockedBalance memory _locked = locked_balance;
        uint256 supply_before = supply;

        supply = supply_before + _value;
        LockedBalance memory old_locked;
        (old_locked.amount, old_locked.discount, old_locked.start, old_locked.end) = (
            _locked.amount,
            _locked.discount,
            _locked.start,
            _locked.end
        );
        _locked.amount += (_value).toInt128();
        if (_discount != 0) _locked.discount += _discount.toInt128();
        if (unlock_time != 0) {
            if (_locked.start == 0) _locked.start = block.timestamp;
            _locked.end = unlock_time;
        }
        locked[_addr] = _locked;

        _checkpoint(_addr, old_locked, _locked);

        if (_value > _discount) {
            IERC20(token).safeTransferFrom(_addr, address(this), _value - _discount);
        }

        emit Deposit(_addr, _value, _discount, _locked.end, _type, block.timestamp);
        emit Supply(supply_before, supply_before + _value);
    }

    function _pushDelegate(address addr, address delegate) internal {

        bool found;
        address[] storage delegates = delegateAt[addr];
        for (uint256 i; i < delegates.length; ) {
            if (delegates[i] == delegate) found = true;
            unchecked {
                ++i;
            }
        }
        if (!found) delegateAt[addr].push(delegate);
    }

    function checkpoint() external override {

        _checkpoint(address(0), LockedBalance(0, 0, 0, 0), LockedBalance(0, 0, 0, 0));
    }

    function depositFor(address _addr, uint256 _value) external override nonReentrant beforeMigrated(_addr) {

        LockedBalance memory _locked = locked[_addr];

        require(_value > 0, "VE: INVALID_VALUE");
        require(_locked.amount > 0, "VE: LOCK_NOT_FOUND");
        require(_locked.end > block.timestamp, "VE: LOCK_EXPIRED");

        _depositFor(_addr, _value, 0, 0, _locked, DEPOSIT_FOR_TYPE);
    }

    function createLockFor(
        address _addr,
        uint256 _value,
        uint256 _discount,
        uint256 _duration
    ) external override nonReentrant onlyDelegate beforeMigrated(_addr) {

        _pushDelegate(_addr, msg.sender);

        uint256 unlock_time = ((block.timestamp + _duration) / interval) * interval; // Locktime is rounded down to a multiple of interval
        LockedBalance memory _locked = locked[_addr];

        require(_value > 0, "VE: INVALID_VALUE");
        require(_value >= _discount, "VE: DISCOUNT_TOO_HIGH");
        require(_locked.amount == 0, "VE: EXISTING_LOCK_FOUND");
        require(unlock_time > block.timestamp, "VE: UNLOCK_TIME_TOO_EARLY");
        require(unlock_time <= block.timestamp + maxDuration, "VE: UNLOCK_TIME_TOO_LATE");

        _depositFor(_addr, _value, _discount, unlock_time, _locked, CRETE_LOCK_TYPE);
    }

    function createLock(uint256 _value, uint256 _duration)
        external
        override
        nonReentrant
        authorized
        beforeMigrated(msg.sender)
    {

        uint256 unlock_time = ((block.timestamp + _duration) / interval) * interval; // Locktime is rounded down to a multiple of interval
        LockedBalance memory _locked = locked[msg.sender];

        require(_value > 0, "VE: INVALID_VALUE");
        require(_locked.amount == 0, "VE: EXISTING_LOCK_FOUND");
        require(unlock_time > block.timestamp, "VE: UNLOCK_TIME_TOO_EARLY");
        require(unlock_time <= block.timestamp + maxDuration, "VE: UNLOCK_TIME_TOO_LATE");

        _depositFor(msg.sender, _value, 0, unlock_time, _locked, CRETE_LOCK_TYPE);
    }

    function increaseAmountFor(
        address _addr,
        uint256 _value,
        uint256 _discount
    ) external override nonReentrant onlyDelegate beforeMigrated(_addr) {

        _pushDelegate(_addr, msg.sender);

        LockedBalance memory _locked = locked[_addr];

        require(_value > 0, "VE: INVALID_VALUE");
        require(_value >= _discount, "VE: DISCOUNT_TOO_HIGH");
        require(_locked.amount > 0, "VE: LOCK_NOT_FOUND");
        require(_locked.end > block.timestamp, "VE: LOCK_EXPIRED");

        _depositFor(_addr, _value, _discount, 0, _locked, INCREASE_LOCK_AMOUNT);
    }

    function increaseAmount(uint256 _value) external override nonReentrant authorized beforeMigrated(msg.sender) {

        LockedBalance memory _locked = locked[msg.sender];

        require(_value > 0, "VE: INVALID_VALUE");
        require(_locked.amount > 0, "VE: LOCK_NOT_FOUND");
        require(_locked.end > block.timestamp, "VE: LOCK_EXPIRED");

        _depositFor(msg.sender, _value, 0, 0, _locked, INCREASE_LOCK_AMOUNT);
    }

    function increaseUnlockTime(uint256 _duration)
        external
        override
        nonReentrant
        authorized
        beforeMigrated(msg.sender)
    {

        LockedBalance memory _locked = locked[msg.sender];
        uint256 unlock_time = ((_locked.end + _duration) / interval) * interval; // Locktime is rounded down to a multiple of interval

        require(_locked.end > block.timestamp, "VE: LOCK_EXPIRED");
        require(_locked.amount > 0, "VE: LOCK_NOT_FOUND");
        require(_locked.discount == 0, "VE: LOCK_DISCOUNTED");
        require(unlock_time >= _locked.end + interval, "VE: UNLOCK_TIME_TOO_EARLY");
        require(unlock_time <= block.timestamp + maxDuration, "VE: UNLOCK_TIME_TOO_LATE");

        _depositFor(msg.sender, 0, 0, unlock_time, _locked, INCREASE_UNLOCK_TIME);
    }

    function cancel() external override nonReentrant {

        LockedBalance memory _locked = locked[msg.sender];
        require(_locked.amount > 0, "VE: LOCK_NOT_FOUND");
        require(_locked.end > block.timestamp, "VE: LOCK_EXPIRED");

        uint256 penaltyRate = _penaltyRate(_locked.start, _locked.end);
        uint256 supply_before = _clear(_locked, penaltyRate);

        uint256 value = _locked.amount.toUint256();
        uint256 discount = _locked.discount.toUint256();

        IERC20(token).safeTransfer(msg.sender, ((value - discount) * (1e18 - penaltyRate)) / 1e18);

        emit Cancel(msg.sender, value, discount, penaltyRate, block.timestamp);
        emit Supply(supply_before, supply_before - value);
    }

    function _penaltyRate(uint256 start, uint256 end) internal view returns (uint256 penalty) {

        penalty = (1e18 * (end - block.timestamp)) / (end - start);
        if (penalty < 1e18 / 2) penalty = 1e18 / 2;
    }

    function withdraw() external override nonReentrant {

        LockedBalance memory _locked = locked[msg.sender];
        require(block.timestamp >= _locked.end, "VE: LOCK_NOT_EXPIRED");

        uint256 supply_before = _clear(_locked, 0);

        uint256 value = _locked.amount.toUint256();
        uint256 discount = _locked.discount.toUint256();

        if (value > discount) {
            IERC20(token).safeTransfer(msg.sender, value - discount);
        }

        emit Withdraw(msg.sender, value, discount, block.timestamp);
        emit Supply(supply_before, supply_before - value);
    }

    function migrate() external override nonReentrant beforeMigrated(msg.sender) {

        require(migrator != address(0), "VE: MIGRATOR_NOT_SET");

        LockedBalance memory _locked = locked[msg.sender];
        require(_locked.amount > 0, "VE: LOCK_NOT_FOUND");
        require(_locked.end > block.timestamp, "VE: LOCK_EXPIRED");

        address[] memory delegates = delegateAt[msg.sender];
        uint256 supply_before = _clear(_locked, 0);

        uint256 value = _locked.amount.toUint256();
        uint256 discount = _locked.discount.toUint256();

        IVotingEscrowMigrator(migrator).migrate(
            msg.sender,
            _locked.amount,
            _locked.discount,
            _locked.start,
            _locked.end,
            delegates
        );
        migrated[msg.sender] = true;

        if (value > discount) {
            IERC20(token).safeTransfer(migrator, value - discount);
        }

        emit Migrate(msg.sender, value, discount, block.timestamp);
        emit Supply(supply_before, supply_before - value);
    }

    function _clear(LockedBalance memory _locked, uint256 penaltyRate) internal returns (uint256 supply_before) {

        uint256 value = _locked.amount.toUint256();

        locked[msg.sender] = LockedBalance(0, 0, 0, 0);
        supply_before = supply;
        supply = supply_before - value;

        _checkpoint(msg.sender, _locked, LockedBalance(0, 0, 0, 0));

        address[] storage delegates = delegateAt[msg.sender];
        for (uint256 i; i < delegates.length; ) {
            IVotingEscrowDelegate(delegates[i]).withdraw(msg.sender, penaltyRate);
            unchecked {
                ++i;
            }
        }
        delete delegateAt[msg.sender];
    }


    function _findBlockEpoch(uint256 _block, uint256 max_epoch) internal view returns (uint256) {

        uint256 _min;
        uint256 _max = max_epoch;
        for (uint256 i; i < 128; i++) {
            if (_min >= _max) break;
            uint256 _mid = (_min + _max + 1) / 2;
            if (pointHistory[_mid].blk <= _block) _min = _mid;
            else _max = _mid - 1;
        }
        return _min;
    }

    function balanceOf(address addr) public view override returns (uint256) {

        return balanceOf(addr, block.timestamp);
    }

    function balanceOf(address addr, uint256 _t) public view override returns (uint256) {

        uint256 _epoch = userPointEpoch[addr];
        if (_epoch == 0) return 0;
        else {
            Point memory last_point = userPointHistory[addr][_epoch];
            last_point.bias -= last_point.slope * (_t - last_point.ts).toInt128();
            if (last_point.bias < 0) last_point.bias = 0;
            return last_point.bias.toUint256();
        }
    }

    function balanceOfAt(address addr, uint256 _block) external view override returns (uint256) {

        require(_block <= block.number);

        uint256 _min;
        uint256 _max = userPointEpoch[addr];
        for (uint256 i; i < 128; i++) {
            if (_min >= _max) break;
            uint256 _mid = (_min + _max + 1) / 2;
            if (userPointHistory[addr][_mid].blk <= _block) _min = _mid;
            else _max = _mid - 1;
        }

        Point memory upoint = userPointHistory[addr][_min];

        uint256 max_epoch = epoch;
        uint256 _epoch = _findBlockEpoch(_block, max_epoch);
        Point memory point_0 = pointHistory[_epoch];
        uint256 d_block;
        uint256 d_t;
        if (_epoch < max_epoch) {
            Point memory point_1 = pointHistory[_epoch + 1];
            d_block = point_1.blk - point_0.blk;
            d_t = point_1.ts - point_0.ts;
        } else {
            d_block = block.number - point_0.blk;
            d_t = block.timestamp - point_0.ts;
        }
        uint256 block_time = point_0.ts;
        if (d_block != 0) block_time += ((d_t * (_block - point_0.blk)) / d_block);

        upoint.bias -= upoint.slope * (block_time - upoint.ts).toInt128();
        if (upoint.bias >= 0) return upoint.bias.toUint256();
        else return 0;
    }

    function _supplyAt(Point memory point, uint256 t) internal view returns (uint256) {

        Point memory last_point = point;
        uint256 t_i = (last_point.ts / interval) * interval;
        for (uint256 i; i < 255; i++) {
            t_i += interval;
            int128 d_slope;
            if (t_i > t) t_i = t;
            else d_slope = slopeChanges[t_i];
            last_point.bias -= last_point.slope * (t_i - last_point.ts).toInt128();
            if (t_i == t) break;
            last_point.slope += d_slope;
            last_point.ts = t_i;
        }

        if (last_point.bias < 0) last_point.bias = 0;
        return last_point.bias.toUint256();
    }

    function totalSupply() public view override returns (uint256) {

        return totalSupply(block.timestamp);
    }

    function totalSupply(uint256 t) public view override returns (uint256) {

        uint256 _epoch = epoch;
        Point memory last_point = pointHistory[_epoch];
        return _supplyAt(last_point, t);
    }

    function totalSupplyAt(uint256 _block) external view override returns (uint256) {

        require(_block <= block.number);
        uint256 _epoch = epoch;
        uint256 target_epoch = _findBlockEpoch(_block, _epoch);

        Point memory point = pointHistory[target_epoch];
        uint256 dt;
        if (target_epoch < _epoch) {
            Point memory point_next = pointHistory[target_epoch + 1];
            if (point.blk != point_next.blk)
                dt = ((_block - point.blk) * (point_next.ts - point.ts)) / (point_next.blk - point.blk);
        } else if (point.blk != block.number)
            dt = ((_block - point.blk) * (block.timestamp - point.ts)) / (block.number - point.blk);

        return _supplyAt(point, point.ts + dt);
    }
}// UNLICENSED
pragma solidity ^0.8.14;


contract VotingEscrowMigratorMock is IVotingEscrowMigrator {

    using SafeERC20 for IERC20;
    using Integers for int128;
    using Integers for uint256;

    struct LockedBalance {
        int128 amount;
        int128 discount;
        uint256 start;
        uint256 end;
    }

    address public immutable token;
    mapping(address => LockedBalance) public locked;
    mapping(address => address[]) public delegates;

    constructor(address ve) {
        token = IVotingEscrow(ve).token();
    }

    function migrate(
        address account,
        int128 amount,
        int128 discount,
        uint256 start,
        uint256 end,
        address[] calldata _delegates
    ) external override {

        locked[account] = LockedBalance(amount, discount, start, end);
        delegates[account] = _delegates;
    }

    function withdraw() external {

        LockedBalance memory _locked = locked[msg.sender];
        require(block.timestamp >= _locked.end, "VE: LOCK_NOT_EXPIRED");

        uint256 value = _locked.amount.toUint256();
        uint256 discount = _locked.discount.toUint256();

        locked[msg.sender] = LockedBalance(0, 0, 0, 0);

        if (value > discount) {
            IERC20(token).safeTransfer(msg.sender, value - discount);
        }
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function approve(address to, uint256 tokenId) external;


    function setApprovalForAll(address operator, bool _approved) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function isApprovedForAll(address owner, address operator) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT

pragma solidity ^0.8.0;

library Strings {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {

    using Address for address;
    using Strings for uint256;

    string private _name;

    string private _symbol;

    mapping(uint256 => address) private _owners;

    mapping(address => uint256) private _balances;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {

        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner) public view virtual override returns (uint256) {

        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {

        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    function _baseURI() internal view virtual returns (string memory) {

        return "";
    }

    function approve(address to, uint256 tokenId) public virtual override {

        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {

        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        _setApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {

        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {

        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {

        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {

        _safeMint(to, tokenId, "");
    }

    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {

        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _mint(address to, uint256 tokenId) internal virtual {

        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {

        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal virtual {

        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {

        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {

        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

}// WTFPL

pragma solidity ^0.8.14;



contract NFTMock is ERC721, Ownable, INFT {
    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {
    }

    function balanceOf(address owner) public view override(ERC721, INFT) returns (uint256 balance) {
        return ERC721.balanceOf(owner);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override(ERC721, INFT) {
        ERC721.safeTransferFrom(from, to, tokenId);
    }

    function mint(
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external override onlyOwner {
        _safeMint(to, tokenId, data);
    }

    function mintBatch(
        address to,
        uint256[] calldata tokenIds,
        bytes calldata data
    ) external override onlyOwner {
        for (uint256 i; i < tokenIds.length; i++) {
            _safeMint(to, tokenIds[i], data);
        }
    }

    function burn(
        uint256 tokenId,
        uint256,
        bytes32
    ) external override {
        _burn(tokenId);
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}// UNLICENSED
pragma solidity ^0.8.14;


contract ERC20Mock is ERC20 {
    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply
    ) ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
    }
}pragma solidity >=0.5.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}pragma solidity >=0.5.0;

interface IUniswapV2Callee {
    function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external;
}pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function migrator() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
    function setMigrator(address) external;
}pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}pragma solidity >=0.6.2;


interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}// GPL-3.0-or-later

pragma solidity >=0.6.0;

library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}