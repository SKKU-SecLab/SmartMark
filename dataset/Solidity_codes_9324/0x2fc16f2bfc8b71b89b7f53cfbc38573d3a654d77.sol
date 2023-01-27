
pragma solidity ^0.8.0;

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

pragma solidity ^0.8.0;

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

pragma solidity ^0.8.0;


library SafeERC20 {

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

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
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

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT

pragma solidity ^0.8.0;

interface IAbyssLockup {


    function deposited(address token) external view returns (uint256);


    function divFactor(address token) external view returns (uint256);


    function freeDeposits() external returns (uint256);


    function externalTransfer(address token, address sender, address recipient, uint256 amount, uint256 abyssRequired) external returns (bool);


    function resetData(address token) external returns (bool);


    function updateData(address token, uint256 balance, uint256 divFactor_) external returns (bool);

}// MIT

pragma solidity ^0.8.0;


contract AbyssSafeBase is ReentrancyGuard, Ownable {

    using Address for address;
    using SafeERC20 for IERC20;

    IERC20 public tokenContract;
    IAbyssLockup public lockupContract;
    uint256 private _unlockTime;
    uint256 private _abyssRequired;

    bool public disabled;

    struct Data {
        uint256 deposited;
        uint256 divFactorDeposited;
        uint256 requested;
        uint256 divFactorRequested;
        uint256 timestamp;
    }

    struct Token {
        bool disabled;
        bool approved;
        uint256 deposited;
        uint256 divFactorDeposited;
        uint256 requested;
        uint256 divFactorRequested;
    }

    mapping (address => mapping (address => Data)) private _data;
    mapping (address => Token) private _tokens;

    mapping (address => uint256) private _rates;

    constructor(address token, address lockup, uint256 unlockTime_, uint256 abyssRequired_) {
        tokenContract = IERC20(address(token));
        lockupContract = IAbyssLockup(address(lockup));
        _unlockTime = unlockTime_;
        _abyssRequired = abyssRequired_;
    }


    function abyssRequired() public view returns (uint256) {

        return _abyssRequired;
    }

    function rate(address account) public view returns (uint256) {

        return _rates[account];
    }

    function timestamp(address account, address token) public view returns (uint256) {

        return _data[account][token].timestamp;
    }

    function deposited(address account, address token) public view returns (uint256) {

        return _data[account][token].deposited;
    }

    function requested(address account, address token) public view returns (uint256) {

        return _data[account][token].requested;
    }

    function divFactorDeposited(address account, address token) public view returns (uint256) {

        return _data[account][token].divFactorDeposited;
    }

    function divFactorRequested(address account, address token) public view returns (uint256) {

        return _data[account][token].divFactorRequested;
    }

    function totalDeposited(address token) public view returns (uint256) {

        return _tokens[token].deposited;
    }

    function totalRequested(address token) public view returns (uint256) {

        return _tokens[token].requested;
    }

    function totalDivFactorDeposited(address token) public view returns (uint256) {

        return _tokens[token].divFactorDeposited;
    }

    function totalDivFactorRequested(address token) public view returns (uint256) {

        return _tokens[token].divFactorRequested;
    }

    function isTokenDisabled(address token) public view returns (bool) {

        return _tokens[token].disabled;
    }

    function isManager(address manager) public view returns (bool) {

        return _tokens[manager].approved;
    }

    function unlockTime() external virtual view returns (uint256) {

        return _unlockTime;
    }


    function deposit(address token, uint256 amount, address receiver) public nonReentrant isAllowed(msg.sender, token) returns (bool) {

        require(disabled == false && _tokens[token].disabled == false, "AbyssSafe: disabled");
        if (receiver == 0x0000000000000000000000000000000000000000) {
            receiver = msg.sender;
        }
        require(Address.isContract(receiver) == false, "AbyssSafe: receiver cannot be a smart contract");
        require(Address.isContract(token) == true, "AbyssSafe: token must be a smart contract");

        uint256 _tempFreeDeposits;

        if (_abyssRequired > 0 && token != address(tokenContract)) {
            _tempFreeDeposits = lockupContract.freeDeposits();
            require(_tempFreeDeposits > 0 || tokenContract.balanceOf(msg.sender) >= _abyssRequired, "AbyssSafe: not enough Abyss");
        }

        require(IERC20(address(token)).allowance(msg.sender, address(lockupContract)) > amount, "AbyssSafe: you need to approve token first");
        require(IERC20(address(token)).balanceOf(msg.sender) >= amount && amount > 0, "AbyssSafe: you cannot lock this amount");

        if (_tokens[token].approved == false) {

            SafeERC20.safeApprove(IERC20(address(token)), address(lockupContract), 115792089237316195423570985008687907853269984665640564039457584007913129639935);
            require(IERC20(address(token)).allowance(address(this), address(lockupContract)) > 0, "AbyssSafe: allowance issue");
            _tokens[token].approved = true;
        }

        uint256 _tempBalanceSafe = IERC20(address(token)).balanceOf(address(this));

        if (_tokens[token].deposited != _tempBalanceSafe) {
            if (_tokens[token].deposited > 0) {
                calcDivFactorDepositedTotal(token, _tempBalanceSafe);
            } else {
                lockupContract.externalTransfer(token, address(this), owner(), _tempBalanceSafe, 0);
                _tempBalanceSafe = 0;
            }
        }

        if (_tokens[token].divFactorDeposited == 0) {
            _tokens[token].divFactorDeposited = 1e36;
        }

        if (_data[receiver][token].divFactorDeposited == 0) {
            _data[receiver][token].divFactorDeposited = _tokens[token].divFactorDeposited;
        } else if (_data[receiver][token].divFactorDeposited != _tokens[token].divFactorDeposited) {
            calcDivFactorDeposited(receiver, token);
        }

        if (_tempFreeDeposits > 0) {
            _rates[receiver] = 0;
        } else {
            _rates[receiver] = _abyssRequired;
        }

        lockupContract.externalTransfer(token, msg.sender, address(this), amount, _abyssRequired);

        uint256 _tempBalanceSafeAfter = IERC20(address(token)).balanceOf(address(this));

        if (_tempBalanceSafe + amount != _tempBalanceSafeAfter) {
            amount = _tempBalanceSafeAfter - _tempBalanceSafe;
        }

        _data[receiver][token].deposited = _data[receiver][token].deposited + amount;

        _tokens[token].deposited = _tokens[token].deposited + amount;

        emit Deposit(receiver, msg.sender, token, amount);
        return true;
    }

    function request(address token, uint256 amount) external nonReentrant isAllowed(msg.sender, token) returns (bool) {

        require(
            _rates[msg.sender] == 0 ||
            token == address(tokenContract) ||
            tokenContract.balanceOf(msg.sender) >= _rates[msg.sender],
            "AbyssSafe: not enough Abyss");
        require(_data[msg.sender][token].requested == 0, "AbyssSafe: you already requested");
        require(_data[msg.sender][token].deposited > 0, "AbyssSafe: nothing to withdraw");

        uint256 _tempBalanceSafe = IERC20(address(token)).balanceOf(address(this));

        if (_tokens[token].deposited != _tempBalanceSafe) {
                calcDivFactorDepositedTotal(token, _tempBalanceSafe);
        }

        if (_data[msg.sender][token].divFactorDeposited != _tokens[token].divFactorDeposited) {
            calcDivFactorDeposited(msg.sender, token);

            if (_data[msg.sender][token].deposited == 0) {
                delete _data[msg.sender][token].divFactorDeposited;
                delete _data[msg.sender][token].divFactorRequested;
                return true;
            }
        }

        uint256 _tempLockupBalance = IERC20(address(token)).balanceOf(address(lockupContract));
        uint256 _tempDepositedLockup = IAbyssLockup(address(lockupContract)).deposited(token);
        uint256 _tempLockupDivFactor = IAbyssLockup(address(lockupContract)).divFactor(token);

        if (_tempLockupBalance == 0) {
            delete _tokens[token].requested;
            delete _tokens[token].divFactorRequested;
            lockupContract.resetData(token);
        }
        if (_tempDepositedLockup != _tempLockupBalance) {
            if (_tempDepositedLockup > 0) {
                _tempLockupDivFactor = calcDivFactorLockup(_tempLockupDivFactor, _tempLockupBalance, _tempDepositedLockup);
            } else {
                lockupContract.externalTransfer(token, address(lockupContract), owner(), _tempLockupBalance, 0);
                _tempLockupBalance = 0;
            }
        }

        if (_tokens[token].divFactorRequested != _tempLockupDivFactor) {
            if (_tokens[token].divFactorRequested != 0) {
                _tokens[token].requested = _tokens[token].requested * _tempLockupDivFactor / _tokens[token].divFactorRequested;
            }
            _tokens[token].divFactorRequested = _tempLockupDivFactor;
        } else if (_tempLockupDivFactor == 0) {
            _tempLockupDivFactor = 1e36;
            _tokens[token].divFactorRequested = 1e36;
        }

        _data[msg.sender][token].divFactorRequested = _tokens[token].divFactorRequested;

        if (_data[msg.sender][token].deposited < amount || amount == 0) {
            amount = _data[msg.sender][token].deposited;
        }

        _tokens[token].deposited = _tokens[token].deposited - amount;

        if (amount == _data[msg.sender][token].deposited) {
            delete _data[msg.sender][token].deposited;
            delete _data[msg.sender][token].divFactorDeposited;
            if (_tokens[token].deposited == 0) {
                delete _tokens[token].divFactorDeposited;
            }
        } else {
            _data[msg.sender][token].deposited = _data[msg.sender][token].deposited - amount;
        }

        _data[msg.sender][token].timestamp = block.timestamp + _unlockTime;

        lockupContract.externalTransfer(token, address(this), address(lockupContract), amount, 0);

        uint256 _tempLockupBalanceAfter = IERC20(address(token)).balanceOf(address(lockupContract));

        if (_tempLockupBalance + amount != _tempLockupBalanceAfter) {
            amount = _tempLockupBalanceAfter - _tempLockupBalance;
        }

        _tempLockupBalance = _tempLockupBalance + amount;

        lockupContract.updateData(token, _tempLockupBalance, _tempLockupDivFactor);

        _tokens[token].requested = _tokens[token].requested + amount;

        _data[msg.sender][token].requested = amount;

        _tempLockupBalance = _tempLockupBalance + amount;

        emit Request(msg.sender, token, amount, _data[msg.sender][token].timestamp);
        return true;
    }

    function cancel(address token) external nonReentrant isAllowed(msg.sender, token) returns (bool) {

        require(_data[msg.sender][token].requested > 0, "AbyssSafe: nothing to cancel");

        uint256 _tempAmount = _data[msg.sender][token].requested;

        uint256 _tempLockupBalance = IERC20(address(token)).balanceOf(address(lockupContract));
        uint256 _tempLockupBalance2;
        uint256 _tempBalanceSafe = IERC20(address(token)).balanceOf(address(this));
        uint256 _tempDepositedLockup = IAbyssLockup(address(lockupContract)).deposited(token);
        uint256 _tempLockupDivFactor = IAbyssLockup(address(lockupContract)).divFactor(token);
        uint256 _tempTimestamp = _data[msg.sender][token].timestamp;

        if (_tempLockupBalance == 0) {
            delete _data[msg.sender][token].requested;
            delete _data[msg.sender][token].divFactorRequested;
            delete _tokens[token].requested;
            delete _tokens[token].divFactorRequested;
            lockupContract.resetData(token);
            return true;
        }

        if (_tokens[token].deposited != _tempBalanceSafe) {
            if (_tokens[token].deposited > 0) {
                calcDivFactorDepositedTotal(token, _tempBalanceSafe);
            } else {
                lockupContract.externalTransfer(token, address(this), owner(), _tempBalanceSafe, 0);
                _tempBalanceSafe = 0;
            }
        }

        if (_tokens[token].divFactorDeposited == 0) {
            _tokens[token].divFactorDeposited = 1e36;
        }

        if (_data[msg.sender][token].divFactorDeposited != _tokens[token].divFactorDeposited) {
            if (_data[msg.sender][token].divFactorDeposited == 0) {
                _data[msg.sender][token].divFactorDeposited = _tokens[token].divFactorDeposited;
            } else {
                calcDivFactorDeposited(msg.sender, token);
            }
        }

        if (_tempDepositedLockup != _tempLockupBalance) {
            _tempLockupDivFactor = calcDivFactorLockup(_tempLockupDivFactor, _tempLockupBalance, _tempDepositedLockup);
        }

        if (_tokens[token].divFactorRequested != _tempLockupDivFactor) {
            calcDivFactorRequestedTotal(token, _tempLockupDivFactor);
        }

        if (_data[msg.sender][token].divFactorRequested != _tokens[token].divFactorRequested) {
            _tempAmount = calcDivFactorRequested(_tempLockupDivFactor, _data[msg.sender][token].divFactorRequested, _tempAmount);

            if (_tokens[token].requested < _tempAmount) {
                _tempAmount = _tokens[token].requested;
            }
            _data[msg.sender][token].divFactorRequested = _tokens[token].divFactorRequested;
        }

        delete _data[msg.sender][token].divFactorRequested;

        _tokens[token].requested = _tokens[token].requested - _tempAmount;

        if (_tokens[token].requested == 0) {
            delete _tokens[token].divFactorRequested;
        }

        _data[msg.sender][token].deposited = _data[msg.sender][token].deposited + _tempAmount;

        delete _data[msg.sender][token].requested;

        _tempLockupBalance2 = _tempLockupBalance - _tempAmount;

        if (_tempLockupBalance2 == 0) {
            _tempLockupDivFactor = 1;
        }

        delete _data[msg.sender][token].timestamp;

        lockupContract.externalTransfer(token, address(lockupContract), address(this), _tempAmount, 0);
        lockupContract.updateData(token, _tempLockupBalance2, _tempLockupDivFactor);


        _tempLockupBalance2 = IERC20(address(token)).balanceOf(address(this));

        if (_tempBalanceSafe + _tempAmount != _tempLockupBalance2) {
            _tempAmount = _tempLockupBalance2 - _tempBalanceSafe;
        }

        _tokens[token].deposited = _tokens[token].deposited + _tempAmount;

        emit Cancel(msg.sender, token, _tempAmount, _tempTimestamp);
        return true;
    }

    function withdraw(address token) external nonReentrant isAllowed(msg.sender, token) returns (bool) {

        require(
            _rates[msg.sender] == 0 ||
            token == address(tokenContract) ||
            tokenContract.balanceOf(msg.sender) >= _rates[msg.sender],
            "AbyssSafe: not enough Abyss");
        require(_data[msg.sender][token].requested > 0, "AbyssSafe: request withdraw first");
        require(_data[msg.sender][token].timestamp <= block.timestamp, "AbyssSafe: patience you must have!");

        uint256 _tempAmount = _data[msg.sender][token].requested;
        uint256 _tempLockupBalance = IERC20(address(token)).balanceOf(address(lockupContract));
        uint256 _tempLockupBalance2;
        uint256 _tempDepositedLockup = IAbyssLockup(address(lockupContract)).deposited(token);
        uint256 _tempLockupDivFactor = IAbyssLockup(address(lockupContract)).divFactor(token);

        if (_tempLockupBalance == 0) {
            delete _data[msg.sender][token].requested;
            delete _data[msg.sender][token].divFactorRequested;
            delete _tokens[token].requested;
            delete _tokens[token].divFactorRequested;
            lockupContract.resetData(token);
            return true;
        }

        if (_tempDepositedLockup != _tempLockupBalance) {
            _tempLockupDivFactor = calcDivFactorLockup(_tempLockupDivFactor, _tempLockupBalance, _tempDepositedLockup);
        }

        if (_tokens[token].divFactorRequested != _tempLockupDivFactor) {
            calcDivFactorRequestedTotal(token, _tempLockupDivFactor);
        }

        if (_data[msg.sender][token].divFactorRequested != _tokens[token].divFactorRequested) {
            _tempAmount = calcDivFactorRequested(_tempLockupDivFactor, _data[msg.sender][token].divFactorRequested, _tempAmount);

            if (_tokens[token].requested < _tempAmount) {
                _tempAmount = _tokens[token].requested;
            }

        }

        delete _data[msg.sender][token].divFactorRequested;

        _tokens[token].requested = _tokens[token].requested - _tempAmount;

        if (_tokens[token].requested == 0) {
            delete _tokens[token].divFactorRequested;
        }

        delete _data[msg.sender][token].requested;

        if (_tempAmount == 0) {
            delete _data[msg.sender][token].timestamp;
            return true;
        }

        _tempLockupBalance2 = _tempLockupBalance - _tempAmount;

        if (_tempLockupBalance2 == 0) {
            _tempLockupDivFactor = 1;
        }

        lockupContract.externalTransfer(token, address(lockupContract), msg.sender, _tempAmount, 0);
        lockupContract.updateData(token, _tempLockupBalance2, _tempLockupDivFactor);

        _tempLockupBalance2 = IERC20(address(token)).balanceOf(address(lockupContract));

        if (_tempLockupBalance != _tempLockupBalance2 + _tempAmount) {
            _tempAmount = _tempLockupBalance - _tempLockupBalance2;
        }

        emit Withdraw(msg.sender, token, _tempAmount, _data[msg.sender][token].timestamp);

        delete _data[msg.sender][token].timestamp;
        return true;

    }


    function calcDivFactorDepositedTotal(address _token, uint256 _balanceSafe) internal {

        _tokens[_token].divFactorDeposited = _tokens[_token].divFactorDeposited * _balanceSafe / _tokens[_token].deposited;
        _tokens[_token].deposited = _balanceSafe;
    }

    function calcDivFactorRequestedTotal(address _token, uint256 _lockupDivFactor) internal {

        _tokens[_token].requested = _tokens[_token].requested * _lockupDivFactor / _tokens[_token].divFactorRequested;
        _tokens[_token].divFactorRequested = _lockupDivFactor;
    }

    function calcDivFactorDeposited(address _owner, address _token) internal {

        _data[_owner][_token].deposited = _data[_owner][_token].deposited * _tokens[_token].divFactorDeposited / _data[_owner][_token].divFactorDeposited;
        _data[_owner][_token].divFactorDeposited = _tokens[_token].divFactorDeposited;
    }

    function calcDivFactorRequested(uint256 _lockupDivFactor, uint256 _divFactorRequested, uint256 _amount) internal pure returns (uint256) {

        return _amount * _lockupDivFactor / _divFactorRequested;
    }

    function calcDivFactorLockup(uint256 _lockupDivFactor, uint256 _lockupBalance, uint256 _lockupDeposited) internal pure returns (uint256) {

        return _lockupDivFactor * _lockupBalance / _lockupDeposited;
    }


    function initialize(address lockupContract_) external onlyOwner returns (bool) {

        require(address(lockupContract) == address(0), "AbyssSafe: already initialized");
        lockupContract = IAbyssLockup(lockupContract_);
        return true;
    }

    function setup(address token, bool tokenDisabled, bool globalDisabled, uint256 abyssRequired_) external onlyManager(msg.sender) returns (bool) {

        disabled = globalDisabled;
        if (token != address(this)) {
            _tokens[token].disabled = tokenDisabled;
        }
        _abyssRequired = abyssRequired_;
        return true;
    }

    function setManager(address manager) external onlyOwner returns (bool) {


        if (_tokens[manager].approved == false) {
            _tokens[manager].approved = true;
        } else {
            _tokens[manager].approved = false;
        }
        return true;
    }

    function withdrawLostTokens(address token) external onlyOwner returns (bool) {

        uint256 _tempBalance = IERC20(address(token)).balanceOf(address(this));

        if (_tokens[token].deposited == 0 && _tempBalance > 0) {
            SafeERC20.safeTransfer(IERC20(address(token)), msg.sender, _tempBalance);
        }

        return true;
    }

    function manualApprove(address token) external returns (bool) {

        SafeERC20.safeApprove(IERC20(address(token)), address(lockupContract), 115792089237316195423570985008687907853269984665640564039457584007913129639935);
        return true;
    }

    modifier isAllowed(address account, address token) {

        require(account != token, "AbyssSafe: you shall not pass!");
        _;
    }

    modifier onlyManager(address account) {

        require(_tokens[account].approved || account == owner(), "AbyssSafe: you shall not pass!");
        _;
    }

    event Deposit(address indexed user, address indexed depositor, address token, uint256 amount);
    event Request(address indexed user, address token, uint256 amount, uint256 timestamp);
    event Cancel(address indexed user, address token, uint256 amount, uint256 timestamp);
    event Withdraw(address indexed user, address token, uint256 amount, uint256 timestamp);
}/*
░█████╗░██████╗░██╗░░░██╗░██████╗░██████╗  ███████╗██╗███╗░░██╗░█████╗░███╗░░██╗░█████╗░███████╗
██╔══██╗██╔══██╗╚██╗░██╔╝██╔════╝██╔════╝  ██╔════╝██║████╗░██║██╔══██╗████╗░██║██╔══██╗██╔════╝
███████║██████╦╝░╚████╔╝░╚█████╗░╚█████╗░  █████╗░░██║██╔██╗██║███████║██╔██╗██║██║░░╚═╝█████╗░░
██╔══██║██╔══██╗░░╚██╔╝░░░╚═══██╗░╚═══██╗  ██╔══╝░░██║██║╚████║██╔══██║██║╚████║██║░░██╗██╔══╝░░
██║░░██║██████╦╝░░░██║░░░██████╔╝██████╔╝  ██║░░░░░██║██║░╚███║██║░░██║██║░╚███║╚█████╔╝███████╗
╚═╝░░╚═╝╚═════╝░░░░╚═╝░░░╚═════╝░╚═════╝░  ╚═╝░░░░░╚═╝╚═╝░░╚══╝╚═╝░░╚═╝╚═╝░░╚══╝░╚════╝░╚══════╝
*/


pragma solidity ^0.8.0;


contract AbyssSafe14 is AbyssSafeBase {

    uint256 public override constant unlockTime = 1209600; // mainnet

    constructor(address token, address lockup, uint256 abyssRequired) AbyssSafeBase(token, lockup, unlockTime, abyssRequired) {
    }
}