
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

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
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

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// MIT
pragma solidity 0.7.6;


contract Readable {

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
}// MIT
pragma solidity 0.7.6;
pragma abicoder v2;



contract BulkStaking is Ownable, Readable {

    using SafeMath for *;
    using ExtraMath for *;
    using SafeERC20 for IERC20;

    IERC20 immutable public BULK;

    uint public constant RELEASE_DATE = 1628164800;
    uint public constant STRATEGIC = RELEASE_DATE - 75 days;
    uint public constant STRATEGIC_PERIOD = 375 days;
    uint public constant PRIVATE = RELEASE_DATE - 100 days;
    uint public constant PRIVATE_PERIOD = 400 days;
    uint public constant INSTITUTIONAL = RELEASE_DATE - 30 days;
    uint public constant INSTITUTIONAL_PERIOD = 600 days;

    uint public constant WITHDRAW_TIMEOUT = 30 days;

    struct Lock {
        uint128 strategicSale;
        uint128 privateSale;
        uint128 institutionalSale;
        uint128 claimed;
        uint88 secondary;
        uint88 requested;
        uint32 readyAt;
    }

    struct DB {
        mapping(address => Lock) locked;
        uint totalBalance;
    }

    DB internal db;

    constructor(IERC20 bulk, address newOwner) {
        BULK = bulk;
        transferOwnership(newOwner);
    }

    function getUserInfo(address who) external view returns(Lock memory) {

        return db.locked[who];
    }

    function getTotalBalance() external view returns(uint) {

        return db.totalBalance;
    }

    function calcualteReleased(uint amount, uint releaseStart, uint releasePeriod)
    private view returns(uint) {

        uint released = amount.mul(since(releaseStart)) / releasePeriod;
        return Math.min(amount, released);
    }

    function availableToClaim(address who) public view returns(uint) {

        if (not(reached(RELEASE_DATE))) {
            return 0;
        }
        Lock memory user = db.locked[who];
        uint releasedStrategic = calcualteReleased(
            user.strategicSale, STRATEGIC, STRATEGIC_PERIOD);
        uint releasedPrivate = calcualteReleased(
            user.privateSale, PRIVATE, PRIVATE_PERIOD);
        uint releasedInstitutional = calcualteReleased(
            user.institutionalSale, INSTITUTIONAL, INSTITUTIONAL_PERIOD);
        uint released = releasedStrategic.add(releasedPrivate).add(releasedInstitutional);
        if (user.claimed >= released) {
            return 0;
        }
        return released.sub(user.claimed);
    }

    function availableToWithdraw(address who) public view returns(uint) {

        Lock storage user = db.locked[who];
        uint readyAt = user.readyAt;
        uint requested = user.requested;
        if (readyAt > 0 && passed(readyAt)) {
            return requested;
        }
        return 0;
    }

    function balanceOf(address who) external view returns(uint) {

        Lock memory user = db.locked[who];
        return user.strategicSale.add(user.privateSale).add(user.institutionalSale)
            .add(user.secondary).sub(user.claimed).sub(availableToWithdraw(who));
    }

    function assignStrategic(address[] calldata tos, uint[] calldata amounts)
    external onlyOwner {

        uint len = tos.length;
        require(len == amounts.length, 'Invalid input');
        uint total = 0;
        for (uint i = 0; i < len; i++) {
            address to = tos[i];
            uint amount = amounts[i];
            db.locked[to].strategicSale =
                db.locked[to].strategicSale.add(amount).toUInt128();
            total = total.add(amount);
            emit StrategicAssigned(to, amount);
        }
        db.totalBalance = db.totalBalance.add(total);
        BULK.safeTransferFrom(msg.sender, address(this), total);
    }

    function assignPrivate(address[] calldata tos, uint[] calldata amounts)
    external onlyOwner {

        uint len = tos.length;
        require(len == amounts.length, 'Invalid input');
        uint total = 0;
        for (uint i = 0; i < len; i++) {
            address to = tos[i];
            uint amount = amounts[i];
            db.locked[to].privateSale =
                db.locked[to].privateSale.add(amount).toUInt128();
            total = total.add(amount);
            emit PrivateAssigned(to, amount);
        }
        db.totalBalance = db.totalBalance.add(total);
        BULK.safeTransferFrom(msg.sender, address(this), total);
    }

    function assignInstitutional(address[] calldata tos, uint[] calldata amounts)
    external onlyOwner {

        uint len = tos.length;
        require(len == amounts.length, 'Invalid input');
        uint total = 0;
        for (uint i = 0; i < len; i++) {
            address to = tos[i];
            uint amount = amounts[i];
            db.locked[to].institutionalSale =
                db.locked[to].institutionalSale.add(amount).toUInt128();
            total = total.add(amount);
            emit InstitutionalAssigned(to, amount);
        }
        db.totalBalance = db.totalBalance.add(total);
        BULK.safeTransferFrom(msg.sender, address(this), total);
    }

    function claim() public {

        uint claimable = availableToClaim(msg.sender);
        require(claimable > 0, 'Nothing to claim');
        Lock storage user = db.locked[msg.sender];
        user.claimed = user.claimed.add(claimable).toUInt128();
        db.totalBalance = db.totalBalance.sub(claimable);
        BULK.safeTransfer(msg.sender, claimable);
        emit Claimed(msg.sender, claimable);
    }

    function stake(uint amount) external {

        Lock storage user = db.locked[msg.sender];
        user.secondary = user.secondary.add(amount).toUInt88();
        user.readyAt = 0;
        user.requested = 0;
        db.totalBalance = db.totalBalance.add(amount);
        BULK.safeTransferFrom(msg.sender, address(this), amount);
        emit Staked(msg.sender, amount);
    }

    function restake() external {

        Lock storage user = db.locked[msg.sender];
        uint requested = user.requested;
        user.readyAt = 0;
        user.requested = 0;
        emit Restaked(msg.sender, requested);
    }

    function requestWithdrawal(uint amount) external {

        require(amount > 0, 'Amount must be positive');
        if(availableToWithdraw(msg.sender) > 0) {
            withdraw();
        }
        Lock storage user = db.locked[msg.sender];
        uint readyAt = user.readyAt;
        uint requested = user.requested;
        uint newRequested = requested.add(amount);
        require(user.secondary >= newRequested, 'Insufficient balance to withdraw');
        uint timeLeft = till(readyAt).mul(requested).add(
            amount.mul(WITHDRAW_TIMEOUT)).div(newRequested);
        uint newReadyAt = block.timestamp.add(timeLeft);
        user.readyAt = newReadyAt.toUInt32();
        user.requested = newRequested.toUInt88();
        emit WithdrawRequested(msg.sender, amount, newReadyAt);
    }

    function withdraw() public {

        uint withdrawable = availableToWithdraw(msg.sender);
        require(withdrawable > 0, 'Nothing to withdraw');
        Lock storage user = db.locked[msg.sender];
        user.secondary = user.secondary.sub(withdrawable).toUInt88();
        user.readyAt = 0;
        user.requested = 0;
        db.totalBalance = db.totalBalance.sub(withdrawable);
        BULK.safeTransfer(msg.sender, withdrawable);
        emit Withdrawn(msg.sender, withdrawable);
    }

    function withdrawEarly(address who, uint amount) external onlyOwner {

        Lock storage user = db.locked[who];
        user.secondary = user.secondary.sub(amount).toUInt88();
        user.readyAt = 0;
        user.requested = 0;
        db.totalBalance = db.totalBalance.sub(amount);
        BULK.safeTransfer(msg.sender, amount);
        emit WithdrawnEarly(who, amount);
    }

    function claimEarly(address who, uint amount) external onlyOwner {

        Lock storage user = db.locked[who];
        Lock memory userData = user;
        uint unclaimed = userData.strategicSale.add(userData.privateSale)
            .add(userData.institutionalSale).sub(userData.claimed);
        require(amount <= unclaimed, 'Insufficient unclaimed');
        user.claimed = user.claimed.add(amount).toUInt128();
        db.totalBalance = db.totalBalance.sub(amount);
        BULK.safeTransfer(msg.sender, amount);
        emit ClaimedEarly(who, amount);
    }

    function claimAndWithdraw() external {

        claim();
        if (availableToWithdraw(msg.sender) == 0) {
            return;
        }
        withdraw();
    }

    function recover(IERC20 token, address to, uint amount) external onlyOwner {

        if (token == BULK) {
            require(BULK.balanceOf(address(this)).sub(db.totalBalance) >= amount,
                'Not enough to recover');
        }
        token.safeTransfer(to, amount);
        emit Recovered(token, to, amount);
    }

    event StrategicAssigned(address user, uint amount);
    event PrivateAssigned(address user, uint amount);
    event InstitutionalAssigned(address user, uint amount);
    event Claimed(address user, uint amount);
    event Staked(address user, uint amount);
    event Restaked(address user, uint amount);
    event WithdrawRequested(address user, uint amount, uint readyAt);
    event Withdrawn(address user, uint amount);
    event WithdrawnEarly(address user, uint amount);
    event ClaimedEarly(address user, uint amount);
    event Recovered(IERC20 token, address to, uint amount);
}