
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


library SafeCast {


    function toUint128(uint256 value) internal pure returns (uint128) {

        require(value < 2**128, "SafeCast: value doesn\'t fit in 128 bits");
        return uint128(value);
    }

    function toUint64(uint256 value) internal pure returns (uint64) {

        require(value < 2**64, "SafeCast: value doesn\'t fit in 64 bits");
        return uint64(value);
    }

    function toUint32(uint256 value) internal pure returns (uint32) {

        require(value < 2**32, "SafeCast: value doesn\'t fit in 32 bits");
        return uint32(value);
    }

    function toUint16(uint256 value) internal pure returns (uint16) {

        require(value < 2**16, "SafeCast: value doesn\'t fit in 16 bits");
        return uint16(value);
    }

    function toUint8(uint256 value) internal pure returns (uint8) {

        require(value < 2**8, "SafeCast: value doesn\'t fit in 8 bits");
        return uint8(value);
    }

    function toUint256(int256 value) internal pure returns (uint256) {

        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    function toInt128(int256 value) internal pure returns (int128) {

        require(value >= -2**127 && value < 2**127, "SafeCast: value doesn\'t fit in 128 bits");
        return int128(value);
    }

    function toInt64(int256 value) internal pure returns (int64) {

        require(value >= -2**63 && value < 2**63, "SafeCast: value doesn\'t fit in 64 bits");
        return int64(value);
    }

    function toInt32(int256 value) internal pure returns (int32) {

        require(value >= -2**31 && value < 2**31, "SafeCast: value doesn\'t fit in 32 bits");
        return int32(value);
    }

    function toInt16(int256 value) internal pure returns (int16) {

        require(value >= -2**15 && value < 2**15, "SafeCast: value doesn\'t fit in 16 bits");
        return int16(value);
    }

    function toInt8(int256 value) internal pure returns (int8) {

        require(value >= -2**7 && value < 2**7, "SafeCast: value doesn\'t fit in 8 bits");
        return int8(value);
    }

    function toInt256(uint256 value) internal pure returns (int256) {

        require(value < 2**255, "SafeCast: value doesn't fit in an int256");
        return int256(value);
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

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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

pragma solidity ^0.7.0;

interface INewPremiaFeeDiscount {

    function migrate(address _user, uint256 _amount, uint256 _stakePeriod, uint256 _lockedUntil) external;

}//MIT
pragma solidity ^0.7.0;

interface IERC2612Permit {

    function permit(
        address owner,
        address spender,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    function nonces(address owner) external view returns (uint256);

}// MIT

pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;



contract PremiaFeeDiscount is Ownable, ReentrancyGuard {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using SafeCast for uint256;

    struct UserInfo {
        uint256 balance;      // Balance staked by user
        uint64 stakePeriod;   // Stake period selected by user
        uint64 lockedUntil;   // Timestamp at which the lock ends
    }

    struct StakeLevel {
        uint256 amount;       // Amount to stake
        uint256 discount;     // Discount when amount is reached
    }

    IERC20 public xPremia;

    uint256 private constant _inverseBasisPoint = 1e4;

    mapping (address => UserInfo) public userInfo;
    mapping (uint256 => uint256) public stakePeriods;

    uint256[] public existingStakePeriods;

    INewPremiaFeeDiscount public newContract;

    StakeLevel[] public stakeLevels;


    event Staked(address indexed user, uint256 amount, uint256 stakePeriod, uint256 lockedUntil);
    event Unstaked(address indexed user, uint256 amount);
    event StakeMigrated(address indexed user, address newContract, uint256 amount, uint256 stakePeriod, uint256 lockedUntil);


    constructor(IERC20 _xPremia) {
        xPremia = _xPremia;
    }



    function setNewContract(INewPremiaFeeDiscount _newContract) external onlyOwner {

        newContract = _newContract;
    }

    function setStakePeriod(uint256 _secondsLocked, uint256 _multiplier) external onlyOwner {

        if (_isInArray(_secondsLocked, existingStakePeriods)) {
            existingStakePeriods.push(_secondsLocked);
        }

        stakePeriods[_secondsLocked] = _multiplier;
    }

    function setStakeLevels(StakeLevel[] memory _stakeLevels) external onlyOwner {

        for (uint256 i=0; i < _stakeLevels.length; i++) {
            if (i > 0) {
                require(_stakeLevels[i].amount > _stakeLevels[i-1].amount && _stakeLevels[i].discount > _stakeLevels[i-1].discount, "Wrong stake level");
            }
        }

        delete stakeLevels;

        for (uint256 i=0; i < _stakeLevels.length; i++) {
            stakeLevels.push(_stakeLevels[i]);
        }
    }



    function migrateStake() external nonReentrant {

        require(address(newContract) != address(0), "Migration disabled");

        UserInfo memory user = userInfo[msg.sender];
        require(user.balance > 0, "No stake");

        delete userInfo[msg.sender];

        xPremia.safeIncreaseAllowance(address(newContract), user.balance);
        newContract.migrate(msg.sender, user.balance, user.stakePeriod, user.lockedUntil);
        emit StakeMigrated(msg.sender, address(newContract), user.balance, user.stakePeriod, user.lockedUntil);
    }

    function stakeWithPermit(uint256 _amount, uint256 _period, uint256 _deadline, uint8 _v, bytes32 _r, bytes32 _s) external {

        IERC2612Permit(address(xPremia)).permit(msg.sender, address(this), _amount, _deadline, _v, _r, _s);
        stake(_amount, _period);
    }

    function stake(uint256 _amount, uint256 _period) public nonReentrant {

        require(stakePeriods[_period] > 0, "Stake period does not exists");
        UserInfo storage user = userInfo[msg.sender];

        uint256 lockedUntil = block.timestamp.add(_period);
        require(lockedUntil > user.lockedUntil, "Cannot add stake with lower stake period");

        xPremia.safeTransferFrom(msg.sender, address(this), _amount);
        user.balance = user.balance.add(_amount);
        user.lockedUntil = lockedUntil.toUint64();
        user.stakePeriod = _period.toUint64();

        emit Staked(msg.sender, _amount, _period, lockedUntil);
    }

    function unstake(uint256 _amount) external nonReentrant {

        UserInfo storage user = userInfo[msg.sender];

        require(stakePeriods[user.stakePeriod] == 0 || user.lockedUntil <= block.timestamp, "Stake still locked");

        user.balance = user.balance.sub(_amount);
        xPremia.safeTransfer(msg.sender, _amount);

        emit Unstaked(msg.sender, _amount);
    }



    function stakeLevelsLength() external view returns(uint256) {

        return stakeLevels.length;
    }

    function getStakeAmountWithBonus(address _user) public view returns(uint256) {

        UserInfo memory user = userInfo[_user];
        return user.balance.mul(stakePeriods[user.stakePeriod]).div(_inverseBasisPoint);
    }

    function getDiscount(address _user) external view returns(uint256) {

        uint256 userBalance = getStakeAmountWithBonus(_user);

        for (uint256 i=0; i < stakeLevels.length; i++) {
            StakeLevel memory level = stakeLevels[i];

            if (userBalance < level.amount) {
                uint256 amountPrevLevel;
                uint256 discountPrevLevel;

                if (i > 0) {
                    amountPrevLevel = stakeLevels[i - 1].amount;
                    discountPrevLevel = stakeLevels[i - 1].discount;
                } else {
                    amountPrevLevel = 0;
                    discountPrevLevel = 0;
                }

                uint256 remappedDiscount = level.discount.sub(discountPrevLevel);

                uint256 remappedAmount = level.amount.sub(amountPrevLevel);
                uint256 remappedBalance = userBalance.sub(amountPrevLevel);
                uint256 levelProgress = remappedBalance.mul(_inverseBasisPoint).div(remappedAmount);

                return discountPrevLevel.add(remappedDiscount.mul(levelProgress).div(_inverseBasisPoint));
            }
        }

        return stakeLevels[stakeLevels.length - 1].discount;
    }



    function _isInArray(uint256 _value, uint256[] memory _array) internal pure returns(bool) {

        uint256 length = _array.length;
        for (uint256 i = 0; i < length; ++i) {
            if (_array[i] == _value) {
                return true;
            }
        }

        return false;
    }
}