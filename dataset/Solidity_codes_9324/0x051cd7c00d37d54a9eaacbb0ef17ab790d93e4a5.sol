
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {

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
}// MIT

pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}pragma solidity ^0.8.0;


contract TokenVesting is Ownable {


    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event TokensReleased(address token, uint256 amount);
    event TokenVestingRevoked(address token);

    address private _beneficiary;

    uint256 private _cliff;
    uint256 private _start;
    uint256 private _duration;

    bool private _revocable;

    mapping (address => uint256) private _released;
    mapping (address => bool) private _revoked;

    constructor (address beneficiary, uint256 start, uint256 cliffDuration, uint256 duration, bool revocable) {
        require(beneficiary != address(0), "TokenVesting: beneficiary is the zero address");
        require(cliffDuration <= duration, "TokenVesting: cliff is longer than duration");
        require(duration > 0, "TokenVesting: duration is 0");
        require(start.add(duration) > block.timestamp, "TokenVesting: final time is before current time");

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

        uint256 unreleased = releasableAmount(token);

        require(unreleased > 0, "TokenVesting: no tokens are due");

        _released[address(token)] = _released[address(token)].add(unreleased);

        token.safeTransfer(_beneficiary, unreleased);

        emit TokensReleased(address(token), unreleased);
    }

    function revoke(IERC20 token) public onlyOwner {

        require(_revocable, "TokenVesting: cannot revoke");
        require(!_revoked[address(token)], "TokenVesting: token already revoked");

        uint256 balance = token.balanceOf(address(this));

        uint256 unreleased = releasableAmount(token);
        uint256 refund = balance.sub(unreleased);

        _revoked[address(token)] = true;

        token.safeTransfer(owner(), refund);

        emit TokenVestingRevoked(address(token));
    }

    function releasableAmount(IERC20 token) public view returns (uint256) {

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
}// GPL-3.0-or-later
pragma solidity 0.8.4;


contract TokenVestingController is Initializable {

    using SafeERC20 for IERC20;

    IERC20 private _token;
    uint256 private _minimumAmountPerContract;
    mapping (address => TokenVesting[]) private _vestings;
    mapping (TokenVesting => address) private _owners;

    function initialize(IERC20 token, uint256 minimumAmountPerContract) external initializer {

        __TokenVestingController_init(token, minimumAmountPerContract);
    }


    function createVesting(address beneficiary, uint256 amount, uint256 start, uint256 cliffDuration, uint256 duration, bool revocable) external {

        require(amount >= _minimumAmountPerContract, "amount less than minimum");
        TokenVesting tokenVesting = new TokenVesting(beneficiary, start, cliffDuration, duration, revocable);
        _vestings[beneficiary].push(tokenVesting);
        _owners[tokenVesting] = msg.sender;
        _token.safeTransferFrom(msg.sender, address(tokenVesting), amount);
    }


    function withdraw() external {

        _withdrawFor(msg.sender);
    }

    function withdrawFor(address beneficiary) external {

        _withdrawFor(beneficiary);
    }

    function revoke(address beneficiary, uint256 index) external {

        _revokeContract(_vestings[beneficiary][index]);
    }

    function revokeContract(TokenVesting tokenVesting) external {

        _revokeContract(tokenVesting);
    }

    function revokeAll(address beneficiary) external {

        uint256 beneficiaryVestingsCount = _vestings[beneficiary].length;
        for (uint256 index = 0; index < beneficiaryVestingsCount; ++index) {
            if (_owners[_vestings[beneficiary][index]] == msg.sender &&
                _vestings[beneficiary][index].revocable() &&
                !_vestings[beneficiary][index].revoked(address(_token))) {
                _safeRevoke(_vestings[beneficiary][index]);
            }
        }
    }

    function totalVestingBalanceOf(address beneficiary) external view returns (uint256 balance) {

        uint256 beneficiaryVestingsCount = _vestings[beneficiary].length;
        for (uint256 index = 0; index < beneficiaryVestingsCount; ++index) {
            balance += _token.balanceOf(address(_vestings[beneficiary][index]));
        }
    }

    function vestedBalanceOf(address beneficiary) external view returns (uint256 balance) {

        uint256 beneficiaryVestingsCount = _vestings[beneficiary].length;
        for (uint256 index = 0; index < beneficiaryVestingsCount; ++index) {
            balance += _vestings[beneficiary][index].releasableAmount(_token);
        }
    }

    function unvestedBalanceOf(address beneficiary) external view returns (uint256 balance) {

        uint256 beneficiaryVestingsCount = _vestings[beneficiary].length;
        for (uint256 index = 0; index < beneficiaryVestingsCount; ++index) {
            balance += _token.balanceOf(address(_vestings[beneficiary][index])) - _vestings[beneficiary][index].releasableAmount(_token);
        }
    }

    function token() external view returns (IERC20) {

        return _token;
    }

    function minimumAmountPerContract() external view returns (uint256) {

        return _minimumAmountPerContract;
    }

    function vestings(address beneficiary, uint256 index) external view returns (TokenVesting) {

        return _vestings[beneficiary][index];
    }

    function owners(TokenVesting tokenVesting) external view returns (address) {

        return _owners[tokenVesting];
    }

    function __TokenVestingController_init(IERC20 token, uint256 minimumAmountPerContract) internal initializer {

        __TokenVestingController_init_unchained(token, minimumAmountPerContract);
    }

    function __TokenVestingController_init_unchained(IERC20 token, uint256 minimumAmountPerContract) internal initializer {

        require(minimumAmountPerContract > 0, "minimum amount per contract not set");

        _token = token;
        _minimumAmountPerContract = minimumAmountPerContract;
    }

    function _withdrawFor(address beneficiary) internal {

        uint256 beneficiaryVestingsCount = _vestings[beneficiary].length;
        for (uint256 index = 0; index < beneficiaryVestingsCount; ++index) {
            if (_vestings[beneficiary][index].releasableAmount(_token) > 0) {
                _vestings[beneficiary][index].release(_token);
            }
        }
    }

    function _revokeContract(TokenVesting tokenVesting) internal {

        require(_owners[tokenVesting] == msg.sender, "Not owner of contract");
        _safeRevoke(tokenVesting);
    }

    function _safeRevoke(TokenVesting tokenVesting) private {

        tokenVesting.revoke(_token);
        _token.safeTransfer(msg.sender, _token.balanceOf(address(this)));
    }
}