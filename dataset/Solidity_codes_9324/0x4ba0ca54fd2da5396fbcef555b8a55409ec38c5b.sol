
pragma solidity ^0.4.24;

contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "Mul failed");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "Div failed");
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "Sub failed");
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "Add failed");

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "Math failed");
        return a % b;
    }
}
library SafeMath64 {

    function mul(uint64 a, uint64 b) internal pure returns (uint64) {

        if (a == 0) {
            return 0;
        }

        uint64 c = a * b;
        require(c / a == b, "Mul failed");

        return c;
    }

    function div(uint64 a, uint64 b) internal pure returns (uint64) {

        require(b > 0, "Div failed");
        uint64 c = a / b;

        return c;
    }

    function sub(uint64 a, uint64 b) internal pure returns (uint64) {

        require(b <= a, "Sub failed");
        uint64 c = a - b;

        return c;
    }

    function add(uint64 a, uint64 b) internal pure returns (uint64) {

        uint64 c = a + b;
        require(c >= a, "Add failed");

        return c;
    }

    function mod(uint64 a, uint64 b) internal pure returns (uint64) {

        require(b != 0, "mod failed");
        return a % b;
    }
}
interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address who) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    function transfer(address to, uint256 value) external returns (bool);


    function approve(address spender, uint256 value) external returns (bool);


    function transferFrom(address from, address to, uint256 value) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}
library SafeERC20 {

    using SafeMath for uint256;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        require(token.transfer(to, value), "Transfer failed");
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        require(token.transferFrom(from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(msg.sender, spender) == 0));
        require(token.approve(spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        require(token.approve(spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        require(token.approve(spender, newAllowance));
    }
}
contract TokenVesting is Ownable {

    using SafeMath for uint256;
    using SafeMath64 for uint64;
    using SafeERC20 for IERC20;

    uint64 constant internal SECONDS_PER_MONTH = 2628000;

    event TokensReleased(uint256 amount);
    event TokenVestingRevoked(uint256 amount);

    address private _beneficiary;
    IERC20 private _token;

    uint64 private _cliff;
    uint64 private _start;
    uint64 private _vestingDuration;

    bool private _revocable;
    bool private _revoked;

    uint256 private _released;

    uint64[] private _monthTimestamps;
    uint256 private _tokensPerMonth;


    constructor (address beneficiary, IERC20 token, uint64 start, uint64 cliffDuration, uint64 vestingDuration, bool revocable, uint256 totalTokens) public {
        require(beneficiary != address(0));
        require(token != address(0));
        require(cliffDuration < vestingDuration);
        require(start > 0);
        require(vestingDuration > 0);
        require(start.add(vestingDuration) > block.timestamp);
        _beneficiary = beneficiary;
        _token = token;
        _revocable = revocable;
        _vestingDuration = vestingDuration;
        _cliff = start.add(cliffDuration);
        _start = start;

        uint64 totalReleasingTime = vestingDuration.sub(cliffDuration);
        require(totalReleasingTime.mod(SECONDS_PER_MONTH) == 0);
        uint64 releasingMonths = totalReleasingTime.div(SECONDS_PER_MONTH);
        require(totalTokens.mod(releasingMonths) == 0);
        _tokensPerMonth = totalTokens.div(releasingMonths);
    
        for (uint64 month = 0; month < releasingMonths; month++) {
            uint64 monthTimestamp = uint64(start.add(cliffDuration).add(month.mul(SECONDS_PER_MONTH)).add(SECONDS_PER_MONTH));
            _monthTimestamps.push(monthTimestamp);
        }
    }

    function beneficiary() public view returns (address) {

        return _beneficiary;
    }
    function token() public view returns (address) {

        return _token;
    }
    function cliff() public view returns (uint256) {

        return _cliff;
    }
    function start() public view returns (uint256) {

        return _start;
    }
    function vestingDuration() public view returns (uint256) {

        return _vestingDuration;
    }
    function monthsToVest() public view returns (uint256) {

        return _monthTimestamps.length;
    }
    function amountVested() public view returns (uint256) {

        uint256 vested = 0;

        for (uint256 month = 0; month < _monthTimestamps.length; month++) {
            uint256 monthlyVestTimestamp = _monthTimestamps[month];
            if (monthlyVestTimestamp > 0 && block.timestamp >= monthlyVestTimestamp) {
                vested = vested.add(_tokensPerMonth);
            }
        }

        return vested;
    }
    function revocable() public view returns (bool) {

        return _revocable;
    }
    function released() public view returns (uint256) {

        return _released;
    }
    function revoked() public view returns (bool) {

        return _revoked;
    }

    function release() public {

        require(block.timestamp > _cliff, "Cliff hasnt started yet.");
        uint256 amountToSend = 0;

        for (uint256 month = 0; month < _monthTimestamps.length; month++) {
            uint256 monthlyVestTimestamp = _monthTimestamps[month];
            if (monthlyVestTimestamp > 0) {
                if (block.timestamp >= monthlyVestTimestamp) {
                    _monthTimestamps[month] = 0;
                    amountToSend = amountToSend.add(_tokensPerMonth);
                } else {
                    break;
                }
            }
        }

        require(amountToSend > 0, "No tokens to release");

        _released += amountToSend;
        _token.safeTransfer(_beneficiary, amountToSend);
        emit TokensReleased(amountToSend);
    }

    function revoke() public onlyOwner {

        require(_revocable, "This vest cannot be revoked");
        require(!_revoked, "This vest has already been revoked");

        _revoked = true;
        uint256 amountToSend = 0;
        for (uint256 month = 0; month < _monthTimestamps.length; month++) {
            uint256 monthlyVestTimestamp = _monthTimestamps[month];
            if (block.timestamp <= monthlyVestTimestamp) {
                _monthTimestamps[month] = 0;
                amountToSend = amountToSend.add(_tokensPerMonth);
            }
        }

        require(amountToSend > 0, "No tokens to revoke");

        _token.safeTransfer(owner(), amountToSend);
        emit TokenVestingRevoked(amountToSend);
    }
}