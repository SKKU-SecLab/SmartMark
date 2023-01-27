
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

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function _initOwner (address owner_) internal {
        _owner = owner_;
        emit OwnershipTransferred(address(0), owner_);
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

pragma solidity ^0.8.0;

contract Timer {

    uint private currentTime;

    constructor() {
        currentTime = block.timestamp;
    }

    function setCurrentTime(uint time) external {

        currentTime = time;
    }

    function getCurrentTime() public view returns (uint) {

        return currentTime;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Testable {
    address public timerAddress;

    constructor(address _timerAddress) {
        timerAddress = _timerAddress;
    }

    modifier onlyIfTest {
        require(timerAddress != address(0x0));
        _;
    }

    function setCurrentTime(uint time) external onlyIfTest {
        Timer(timerAddress).setCurrentTime(time);
    }

    function getCurrentTime() public view returns (uint) {
        if (timerAddress != address(0x0)) {
            return Timer(timerAddress).getCurrentTime();
        } else {
            return block.timestamp;
        }
    }
}// MIT

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


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}// MIT

pragma solidity ^0.8.0;


contract ZKTWhiteList is Ownable, Pausable, Initializable, Testable {

    using SafeERC20 for IERC20;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    struct DepositAmount {
        uint value;
        uint released;
        uint startDay;
    }

    IERC20 public zktToken;
    IERC20 public zktrToken;
    uint public constant ONE_DAY = 1 days;

    uint public totalDeposits;
    uint public totalWithdrawals;

    mapping(address => uint) public deposits;
    mapping(address => uint) public withdrawals;
    mapping(address => DepositAmount[]) public depositAmounts;

    uint private locked;
    modifier lock() {

        require(locked == 0, 'ZKTWhiteList: LOCKED');
        locked = 1;
        _;
        locked = 0;
    }

    constructor (address zktToken_, address zktrToken_, address timerAddress_) Testable(timerAddress_){
        zktToken = IERC20(zktToken_);
        zktrToken = IERC20(zktrToken_);
    }

    function initialize(address zktToken_, address zktrToken_, address timerAddress_, address owner_) external initializer {

        zktToken = IERC20(zktToken_);
        zktrToken = IERC20(zktrToken_);
        timerAddress = timerAddress_;
        _initOwner(owner_);
    }

    function deposit(uint amount) external whenNotPaused lock {

        require(amount > 0, "ZKTWhiteList: amount is zero");
        zktrToken.safeTransferFrom(msg.sender, address(this), amount);
        _addDeposit(msg.sender, amount);
        deposits[msg.sender] = deposits[msg.sender] + amount;
        totalDeposits = totalDeposits + amount;
        emit Deposit(msg.sender, amount);
    }

    function withdraw(uint amount) external lock {

        require(amount > 0, "ZKTWhiteList: amount is zero");
        require(amount <= _available(msg.sender, getCurrentTime() / ONE_DAY), "ZKTWhiteList: available is not enough");
        _addReleased(msg.sender, amount);
        withdrawals[msg.sender] = withdrawals[msg.sender] + amount;
        totalWithdrawals = totalWithdrawals + amount;
        zktToken.safeTransfer(msg.sender, amount);
        emit Withdraw(msg.sender, amount);
    }

    function available(address account) external view returns(uint){

        return _available(account, getCurrentTime() / ONE_DAY);
    }

    function pause() public onlyOwner {

        _pause();
    }

    function unpause() public onlyOwner {

        _unpause();
    }

    function _available(address account, uint currentDay) internal view returns(uint){

        uint amount = 0;
        DepositAmount[] storage depositArr = depositAmounts[account];
        uint len = depositArr.length;
        for(uint i = 0; i < len; i++){
            amount = amount + _calcReleasable(depositArr[i].value, depositArr[i].released, depositArr[i].startDay, currentDay);
        }
        return amount;
    }

    function _calcReleasable(uint total, uint released, uint startDay, uint currentDay) internal pure returns (uint){

        if (total <= released) {
            return 0;
        } else if (currentDay <= startDay) {
            return 0;
        } else if (currentDay <= startDay + 56){ // 8 weeks
            uint everyWeek = total / 100;
            return everyWeek * ((currentDay-startDay) / 7) - released;
        } else if (currentDay <= startDay + 356){ // 1 year
            uint everyMonth = total * 2 / 100;
            return (total * 8 / 100) + everyMonth * ((currentDay-startDay-56) / 30) - released;
        } else if (currentDay <= startDay + 1076){ // 2-3 years
            uint everyMonth = total * 3 / 100;
            return (total * 28 / 100) +  everyMonth * ((currentDay-startDay-356) / 30) - released;
        } else { // more than three years
            return total - released;
        }
    }

    function _addDeposit(address account, uint amount) internal {

        uint currentDay = getCurrentTime() / ONE_DAY;
        DepositAmount[] storage depositArr = depositAmounts[account];
        uint len = depositArr.length;
        if (len == 0){
            depositArr.push(DepositAmount({value: amount, released: 0, startDay: currentDay}));
        } else {
            bool isExist = false;
            for(uint i=len-1; i>=0; i--){
                if (depositArr[i].startDay == currentDay){
                    depositArr[i].value = depositArr[i].value + amount;
                    isExist = true;
                    break;
                }
                if (i == 0){
                    break;
                }
            }
            if (!isExist){
                depositArr.push(DepositAmount({value: amount, released: 0, startDay: currentDay}));
            }
        }
    }

    function _addReleased(address account, uint amount) internal {

        uint currentDay = getCurrentTime() / ONE_DAY;
        DepositAmount[] storage depositArr = depositAmounts[account];
        uint i = 0;
        uint tmp = 0;
        uint len = depositArr.length;
        while (i < len){
            uint avail = _calcReleasable(depositArr[i].value, depositArr[i].released, depositArr[i].startDay, currentDay);
            if (avail <= 0) {
                i = i + 1;
            } else {
                tmp = tmp + avail;
                if (tmp > amount){
                    depositArr[i].released = depositArr[i].released + (avail - (tmp - amount));
                    break;
                } else {
                    depositArr[i].released = depositArr[i].released + avail;
                    if (depositArr[i].value <= depositArr[i].released){
                        depositArr[i].value = depositArr[len - 1].value;
                        depositArr[i].released = depositArr[len - 1].released;
                        depositArr[i].startDay = depositArr[len - 1].startDay;
                        depositArr.pop();
                        len = len - 1;
                    } else {
                        i = i + 1;
                    }
                    if (tmp == amount) {
                        break;
                    }
                }
            }
        }
    }
}