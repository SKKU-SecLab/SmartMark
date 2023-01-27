
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
}// UNLICENSED

pragma solidity =0.6.12;


contract LendFlareTokenLocker is ReentrancyGuard {

    using SafeERC20 for IERC20;

    address public owner;
    address public token;
    uint256 public start_time;
    uint256 public end_time;

    mapping(address => uint256) public initial_locked;
    mapping(address => uint256) public total_claimed;
    mapping(address => uint256) public disabled_at;

    uint256 public initial_locked_supply;
    uint256 public unallocated_supply;

    event Fund(address indexed recipient, uint256 amount);
    event Claim(address indexed recipient, uint256 amount);
    event ToggleDisable(address recipient, bool disabled);
    event SetOwner(address owner);

    constructor(
        address _owner,
        address _token,
        uint256 _start_time,
        uint256 _end_time
    ) public {
        require(
            _start_time >= block.timestamp,
            "_start_time >= block.timestamp"
        );
        require(_end_time > _start_time, "_end_time > _start_time");

        owner = _owner;
        token = _token;
        start_time = _start_time;
        end_time = _end_time;
    }

    function setOwner(address _owner) external {

        require(
            msg.sender == owner,
            "LendFlareTokenLocker: !authorized setOwner"
        );

        owner = _owner;

        emit SetOwner(_owner);
    }

    function addTokens(uint256 _amount) public {

        require(
            msg.sender == owner,
            "LendFlareTokenLocker: !authorized addTokens"
        );

        IERC20(token).safeTransferFrom(msg.sender, address(this), _amount);
        unallocated_supply += _amount;
    }

    function fund(address[] memory _recipients, uint256[] memory _amounts)
        public
    {

        require(msg.sender == owner, "LendFlareTokenLocker: !authorized fund");
        require(
            _recipients.length == _amounts.length,
            "_recipients != _amounts"
        );

        uint256 _total_amount;

        for (uint256 i = 0; i < _amounts.length; i++) {
            uint256 amount = _amounts[i];
            address recipient = _recipients[i];

            if (recipient == address(0)) {
                break;
            }

            _total_amount += amount;

            initial_locked[recipient] += amount;
            emit Fund(recipient, amount);
        }

        initial_locked_supply += _total_amount;
        unallocated_supply -= _total_amount;
    }

    function toggleDisable(address _recipient) public {

        require(
            msg.sender == owner,
            "LendFlareTokenLocker: !authorized toggleDisable"
        );

        bool is_enabled = disabled_at[_recipient] == 0;

        if (is_enabled) {
            disabled_at[_recipient] = block.timestamp;
        } else {
            disabled_at[_recipient] = 0;
        }

        emit ToggleDisable(_recipient, is_enabled);
    }

    function claim() public nonReentrant {

        address recipient = msg.sender;
        uint256 t = disabled_at[recipient];

        if (t == 0) {
            t = block.timestamp;
        }

        uint256 claimable = _totalVestedOf(recipient, t) -
            total_claimed[recipient];

        total_claimed[recipient] += claimable;

        IERC20(token).safeTransfer(recipient, claimable);

        emit Claim(recipient, claimable);
    }

    function _totalVestedOf(address _recipient, uint256 _time)
        internal
        view
        returns (uint256)
    {

        if (_time == 0) _time = block.timestamp;

        uint256 locked = initial_locked[_recipient];

        if (_time < start_time) {
            return 0;
        }

        return
            min(
                (locked * (_time - start_time)) / (end_time - start_time),
                locked
            );
    }

    function vestedSupply() public view returns (uint256) {

        uint256 locked = initial_locked_supply;

        if (block.timestamp < start_time) {
            return 0;
        }

        return
            min(
                (locked * (block.timestamp - start_time)) /
                    (end_time - start_time),
                locked
            );
    }

    function lockedSupply() public view returns (uint256) {

        return initial_locked_supply - vestedSupply();
    }

    function availableOf(address _recipient) public view returns (uint256) {

        uint256 t = disabled_at[_recipient];

        if (t == 0) {
            t = block.timestamp;
        }

        return _totalVestedOf(_recipient, t) - total_claimed[_recipient];
    }

    function lockedOf(address _recipient) public view returns (uint256) {

        return
            initial_locked[_recipient] -
            _totalVestedOf(_recipient, block.timestamp);
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }
}

contract LendFlareTokenLockerFactory {

    uint256 public totalLockers;
    mapping(uint256 => address) public lockers;

    address public owner;

    event CreateLocker(
        uint256 indexed uniqueId,
        address indexed locker,
        string description
    );

    constructor() public {
        owner = msg.sender;
    }

    function setOwner(address _owner) external {

        require(
            msg.sender == owner,
            "LendFlareTokenLockerFactory: !authorized setOwner"
        );

        owner = _owner;
    }

    function createLocker(
        uint256 _uniqueId,
        address _token,
        uint256 _start_time,
        uint256 _end_time,
        address _owner,
        string calldata description
    ) external returns (address) {

        require(
            msg.sender == owner,
            "LendFlareTokenLockerFactory: !authorized createLocker"
        );
        require(lockers[_uniqueId] == address(0), "!_uniqueId");

        LendFlareTokenLocker locker = new LendFlareTokenLocker(
            _owner,
            _token,
            _start_time,
            _end_time
        );

        lockers[_uniqueId] = address(locker);

        totalLockers++;

        emit CreateLocker(_uniqueId, address(locker), description);
    }
}