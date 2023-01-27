
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
pragma solidity 0.6.11;


contract TokenVesting is Ownable {


    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event TokensReleased(address token, uint256 amount);
    event TokensReleasedToAccount(address token, address receiver, uint256 amount);
    event VestingRevoked(address token);
    event BeneficiaryChanged(address newBeneficiary);

    address private _beneficiary;

    uint256 private immutable _cliff;
    uint256 private immutable _start;
    uint256 private immutable _duration;

    bool private immutable _revocable;

    mapping (address => uint256) private _released;
    mapping (address => bool) private _revoked;

    constructor (address beneficiary, uint256 start, uint256 cliffDuration, uint256 duration, bool revocable) public {
        require(beneficiary != address(0), "TokenVesting::constructor: beneficiary is the zero address");
        require(cliffDuration <= duration, "TokenVesting::constructor: cliff is longer than duration");
        require(duration > 0, "TokenVesting::constructor: duration is 0");
        require(start.add(duration) > block.timestamp, "TokenVesting::constructor: final time is before current time");

        _beneficiary = beneficiary;
        _revocable = revocable;
        _duration = duration;
        _cliff = start.add(cliffDuration);
        _start = start;
    }

    function beneficiary() public view returns (address) {

        return _beneficiary;
    }

    function cliff() public view returns (uint256) {

        return _cliff;
    }

    function start() public view returns (uint256) {

        return _start;
    }

    function duration() public view returns (uint256) {

        return _duration;
    }

    function revocable() public view returns (bool) {

        return _revocable;
    }

    function released(address token) public view returns (uint256) {

        return _released[token];
    }

    function revoked(address token) public view returns (bool) {

        return _revoked[token];
    }

    function release(IERC20 token) public {

        uint256 unreleased = _releasableAmount(token);

        require(unreleased > 0, "TokenVesting::release: no tokens are due");

        _released[address(token)] = _released[address(token)].add(unreleased);

        token.safeTransfer(_beneficiary, unreleased);

        emit TokensReleased(address(token), unreleased);
    }

    function releaseToAddress(IERC20 token, address receiver, uint256 amount) public {

        require(_msgSender() == _beneficiary, "TokenVesting::setBeneficiary: Not contract beneficiary");
        require(amount > 0, "TokenVesting::_releaseToAddress: amount should be greater than 0");

        require(receiver != address(0), "TokenVesting::_releaseToAddress: receiver is the zero address");

        uint256 unreleased = _releasableAmount(token);

        require(unreleased > 0, "TokenVesting::_releaseToAddress: no tokens are due");

        require(unreleased >= amount, "TokenVesting::_releaseToAddress: enough tokens not vested yet");

        _released[address(token)] = _released[address(token)].add(amount);

        token.safeTransfer(receiver, amount);

        emit TokensReleasedToAccount(address(token), receiver, amount);
    }

    function revoke(IERC20 token) public onlyOwner {

        require(_revocable, "TokenVesting::revoke: cannot revoke");
        require(!_revoked[address(token)], "TokenVesting::revoke: token already revoked");

        uint256 balance = token.balanceOf(address(this));

        uint256 unreleased = _releasableAmount(token);
        uint256 refund = balance.sub(unreleased);

        _revoked[address(token)] = true;

        token.safeTransfer(owner(), refund);

        emit VestingRevoked(address(token));
    }

    function setBeneficiary(address newBeneficiary) public {

        require(_msgSender() == _beneficiary, "TokenVesting::setBeneficiary: Not contract beneficiary");
        require(_beneficiary != newBeneficiary, "TokenVesting::setBeneficiary: Same beneficiary address as old");
        _beneficiary = newBeneficiary;
        emit BeneficiaryChanged(newBeneficiary);
    }

    function _releasableAmount(IERC20 token) private view returns (uint256) {

        return _vestedAmount(token).sub(_released[address(token)]);
    }

    function _vestedAmount(IERC20 token) private view returns (uint256) {

        uint256 currentBalance = token.balanceOf(address(this));
        uint256 totalBalance = currentBalance.add(_released[address(token)]);

        if (block.timestamp < _cliff) {
            return 0;
        } else if (block.timestamp >= _start.add(_duration) || _revoked[address(token)]) {
            return totalBalance;
        } else {
            return totalBalance.mul(block.timestamp.sub(_start)).div(_duration);
        }
    }

    function vestedAmount(IERC20 token) public view returns (uint256) {

        return _vestedAmount(token);
    }
}// MIT

pragma solidity 0.6.11;


contract FundsDistributor is TokenVesting {

    string public identifier;

    constructor(address beneficiary, uint256 start, uint256 cliffDuration, uint256 duration, bool revocable, string memory _identifier) TokenVesting(beneficiary, start, cliffDuration, duration, revocable) public {
      identifier = _identifier;
    }
}// MIT

pragma solidity 0.6.11;


contract FundsDistributorFactory is Ownable{


    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address public immutable pushToken;

    string public identifier;

    uint256 public immutable cliff;

    event DeployFundee(address indexed fundeeAddress, address indexed beneficiaryAddress, uint256 amount);

    event RevokeFundee(address indexed fundeeAddress);

    constructor(address _pushToken, uint256 _start, uint256 _cliffDuration, string memory _identifier) public {
        require(_pushToken != address(0), "FundsDistributorFactory::constructor: pushtoken is the zero address");
        require(_cliffDuration > 0, "FundsDistributorFactory::constructor: cliff duration is 0");
        require(_start.add(_cliffDuration) > block.timestamp, "FundsDistributorFactory::constructor: cliff time is before current time");
        pushToken = _pushToken;
        cliff = _start.add(_cliffDuration);
        identifier = _identifier;
    }

    function deployFundee(address beneficiary, uint256 start, uint256 cliffDuration, uint256 duration, bool revocable, uint256 amount, string memory _identifier) external onlyOwner returns(bool){

        FundsDistributor fundeeContract = new FundsDistributor(beneficiary, start, cliffDuration, duration, revocable, _identifier);
        IERC20 pushTokenInstance = IERC20(pushToken);
        pushTokenInstance.safeTransfer(address(fundeeContract), amount);
        emit DeployFundee(address(fundeeContract), beneficiary, amount);
        return true;
    }

    function revokeFundeeTokens(FundsDistributor fundeeAddress) external onlyOwner returns(bool){

        fundeeAddress.revoke(IERC20(pushToken));
        emit RevokeFundee(address(fundeeAddress));
        return true;
    }

    function withdrawTokens(uint amount) external onlyOwner returns(bool){

        require(block.timestamp > cliff, "FundsDistributorFactory::withdrawTokens: cliff period not complete");
        IERC20 pushTokenInstance = IERC20(pushToken);
        pushTokenInstance.safeTransfer(msg.sender, amount);
        return true;
    }
}