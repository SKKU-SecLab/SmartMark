
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
}// MIT

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
}// MIT

pragma solidity ^0.8.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b + (a % b == 0 ? 0 : 1);
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
}pragma solidity =0.8.11;


contract Readable {

    uint32 constant month = 30 days;
    uint32 constant months = month;

    function since(uint _timestamp) internal view returns(uint) {

        if (not(passed(_timestamp))) {
            return 0;
        }
        return block.timestamp - _timestamp;
    }

    function till(uint _timestamp) internal view returns(uint) {

        if (passed(_timestamp)) {
            return 0;
        }
        return _timestamp - block.timestamp;
    }

    function passed(uint _timestamp) internal view returns(bool) {

        return _timestamp < block.timestamp;
    }

    function reached(uint _timestamp) internal view returns(bool) {

        return _timestamp <= block.timestamp;
    }

    function not(bool _condition) internal pure returns(bool) {

        return !_condition;
    }
}

library ExtraMath {

    function toUInt32(uint _a) internal pure returns(uint32) {

        require(_a <= type(uint32).max, 'uint32 overflow');
        return uint32(_a);
    }

    function toUInt88(uint _a) internal pure returns(uint88) {

        require(_a <= type(uint88).max, 'uint88 overflow');
        return uint88(_a);
    }

    function toUInt128(uint _a) internal pure returns(uint128) {

        require(_a <= type(uint128).max, 'uint128 overflow');
        return uint128(_a);
    }
}pragma solidity =0.8.11;



contract RidottoVesting is Ownable, Readable {

    using SafeERC20 for IERC20;

    IERC20 immutable public RDT;
    uint128 constant public HUNDRED_PERCENT = 1000;
    uint32 public TGEdate = 1632846600; // Tuesday, 28 September 2021 16:30:00
    bool public paused;

    uint constant LOCK_TYPES = 7;
    enum LockType {
        Team,
        Rewards,
        Marketing,
        Advisor,
        Ecosystem,
        BugBounty,
        Reserve
    }

    struct LockConfig {
        uint32 releasedAtStart;
        uint32 cliff;
        uint32 duration;
        uint32 period;
    }

    struct Lock {
        uint128 balance;
        uint128 claimed;
    }

    struct DB {
        mapping(LockType => LockConfig) config;
        mapping(address => Lock[LOCK_TYPES]) locks;
    }

    DB internal db;

    constructor(IERC20 rdt, address newOwner) {
        RDT = rdt;
        db.config[LockType.Team] = LockConfig(0, 6 * months, 21 * months, 1);
        db.config[LockType.Rewards] = LockConfig(35, 1 * month, 48 * months, 1);
        db.config[LockType.Marketing] = LockConfig(0, 1 * month, 48 * months, 1);
        db.config[LockType.Advisor] = LockConfig(0, 6 * months, 21 * months, 1);
        db.config[LockType.Ecosystem] = LockConfig(0, 6 * month, 48 * months, 1);
        db.config[LockType.BugBounty] = LockConfig(0, 6 * month, 48 * months, 1);
        db.config[LockType.Reserve] = LockConfig(0, 6 * month, 48 * months, 1);
        transferOwnership(newOwner);
    }

    function getUserInfo(address who) external view returns(Lock[7] memory) {

        return db.locks[who];
    }

    function calcualteReleased(uint128 amount, uint32 releaseStart, LockConfig memory config)
    private view returns(uint128) {

        uint128 atStart = amount * uint128(config.releasedAtStart) / HUNDRED_PERCENT;
        if (not(reached(releaseStart + config.cliff))) {
            return atStart;
        }
        uint128 period = config.period;
        uint128 periods = uint128(since(releaseStart)) / period;
        uint128 released = atStart + ((amount - atStart) * periods * period / config.duration);
        return uint128(Math.min(amount, released));
    }

    function calcualteClaimable(uint128 released, uint128 claimed) private pure returns(uint128) {

        if (released < claimed) {
            return 0;
        }
        return released - claimed;
    }

    function availableToClaim(address who) public view returns(uint128) {

        uint32 releaseStart = TGEdate;
        if (not(reached(releaseStart))) {
            return 0;
        }
        Lock[LOCK_TYPES] memory userLocks = db.locks[who];
        uint128 claimable = 0;
        for (uint8 i = 0; i < LOCK_TYPES; i++) {
            claimable += calcualteClaimable(
                calcualteReleased(userLocks[i].balance, releaseStart, db.config[LockType(i)]),
                userLocks[i].claimed
            );
        }
        return claimable;
    }

    function balanceOf(address who) external view returns(uint) {

        Lock[LOCK_TYPES] memory userLocks = db.locks[who];
        uint128 balances = 0;
        uint128 claimed = 0;
        for (uint8 i = 0; i < LOCK_TYPES; i++) {
            balances += userLocks[i].balance;
            claimed += userLocks[i].claimed;
        }
        if (claimed > balances) {
            return 0;
        }
        return balances - claimed;
    }

    function assign(LockType[] calldata lockTypes, address[] calldata tos, uint128[] calldata amounts)
    external onlyOwner {

        uint len = lockTypes.length;
        require(len == tos.length, 'Invalid tos input');
        require(len == amounts.length, 'Invalid amounts input');
        for (uint i = 0; i < len; i++) {
            LockType lockType = lockTypes[i];
            address to = tos[i];
            uint128 amount = amounts[i];
            db.locks[to][uint8(lockType)].balance += amount;
            emit LockAssigned(to, amount, lockType);
        }
    }

    function revoke(LockType[] calldata lockTypes, address[] calldata whos)
    external onlyOwner {

        uint len = lockTypes.length;
        require(len == whos.length, 'Invalid input');
        for (uint i = 0; i < len; i++) {
            LockType lockType = lockTypes[i];
            address who = whos[i];
            Lock memory lock = db.locks[who][uint8(lockType)];
            uint128 amount = lock.balance - uint128(Math.min(lock.balance, lock.claimed));
            delete db.locks[who][uint8(lockType)];
            emit LockRevoked(who, amount, lockType);
        }
    }

    function setTGEdate(uint32 timestamp) external onlyOwner {

        TGEdate = timestamp;
        emit TGEdateSet(timestamp);
    }

    function pause() external onlyOwner {

        paused = true;
        emit Paused();
    }

    function unpause() external onlyOwner {

        paused = false;
        emit Unpaused();
    }

    function claim() external {

        require(not(paused), 'Paused');
        uint32 releaseStart = TGEdate;
        require(reached(releaseStart), 'Release not started');
        Lock[LOCK_TYPES] memory userLocks = db.locks[msg.sender];
        uint128 claimableSum = 0;
        for (uint8 i = 0; i < LOCK_TYPES; i++) {
            uint128 claimable = calcualteClaimable(
                calcualteReleased(userLocks[i].balance, releaseStart, db.config[LockType(i)]),
                userLocks[i].claimed
            );
            if (claimable == 0) {
                continue;
            }
            db.locks[msg.sender][i].claimed = userLocks[i].claimed + claimable;
            claimableSum += claimable;
            emit Claimed(msg.sender, claimable, LockType(i));
        }
        require(claimableSum > 0, 'Nothing to claim');
        RDT.safeTransfer(msg.sender, claimableSum);
    }

    function recover(IERC20 token, address to, uint amount) external onlyOwner {

        token.safeTransfer(to, amount);
        emit Recovered(token, to, amount);
    }

    event TGEdateSet(uint timestamp);
    event LockAssigned(address user, uint amount, LockType lockType);
    event LockRevoked(address user, uint amount, LockType lockType);
    event Claimed(address user, uint amount, LockType lockType);
    event Paused();
    event Unpaused();
    event Recovered(IERC20 token, address to, uint amount);
}