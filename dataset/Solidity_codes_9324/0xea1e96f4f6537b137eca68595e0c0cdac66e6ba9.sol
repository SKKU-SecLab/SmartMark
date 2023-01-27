
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

interface IERC20Upgradeable {

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

library SafeMathUpgradeable {

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

library AddressUpgradeable {

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


library SafeERC20Upgradeable {

    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;

    function safeTransfer(IERC20Upgradeable token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20Upgradeable token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20Upgradeable token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity >=0.4.24 <0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

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

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable {

    using SafeMathUpgradeable for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    function __ERC20_init(string memory name_, string memory symbol_) internal initializer {

        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal initializer {

        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

    uint256[44] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;


abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}// BUSL-1.1
pragma solidity 0.6.12;

contract BlockLock {

    uint256 private constant BLOCK_LOCK_COUNT = 6;
    mapping(address => uint256) public lastLockedBlock;
    mapping(address => bool) public blockLockExempt;

    function _lock(address lockAddress) internal {

        if (!blockLockExempt[lockAddress]) {
            lastLockedBlock[lockAddress] = block.number + BLOCK_LOCK_COUNT;
        }
    }

    function _exemptFromBlockLock(address lockAddress) internal {

        blockLockExempt[lockAddress] = true;
    }

    function _removeBlockLockExemption(address lockAddress) internal {

        blockLockExempt[lockAddress] = false;
    }

    modifier notLocked(address lockAddress) {

        require(lastLockedBlock[lockAddress] <= block.number, "Address is temporarily locked");
        _;
    }
}//MIT
pragma solidity 0.6.12;

interface IxTokenManager {

    function addManager(address manager, address fund) external;


    function removeManager(address manager, address fund) external;


    function isManager(address manager, address fund) external view returns (bool);


    function setRevenueController(address controller) external;


    function isRevenueController(address caller) external view returns (bool);

}// ISC

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

interface IAlphaStaking {

    event SetWorker(address worker);
    event Stake(address owner, uint256 share, uint256 amount);
    event Unbond(address owner, uint256 unbondTime, uint256 unbondShare);
    event Withdraw(address owner, uint256 withdrawShare, uint256 withdrawAmount);
    event CancelUnbond(address owner, uint256 unbondTime, uint256 unbondShare);
    event Reward(address worker, uint256 rewardAmount);
    event Extract(address governor, uint256 extractAmount);

    struct Data {
        uint256 status;
        uint256 share;
        uint256 unbondTime;
        uint256 unbondShare;
    }

    function STATUS_READY() external view returns (uint256);


    function STATUS_UNBONDING() external view returns (uint256);


    function UNBONDING_DURATION() external view returns (uint256);


    function WITHDRAW_DURATION() external view returns (uint256);


    function alpha() external view returns (address);


    function getStakeValue(address user) external view returns (uint256);


    function totalAlpha() external view returns (uint256);


    function totalShare() external view returns (uint256);


    function stake(uint256 amount) external;


    function unbond(uint256 share) external;


    function withdraw() external;


    function users(address user) external view returns (Data calldata);

}// ISC

pragma solidity 0.6.12;

interface IWETH {

    function deposit() external payable;


    function transfer(address to, uint256 value) external returns (bool);


    function withdraw(uint256) external;

}// ISC

pragma solidity 0.6.12;

interface IOneInchLiquidityProtocol {

    function swap(
        address src,
        address dst,
        uint256 amount,
        uint256 minReturn,
        address referral
    ) external payable returns (uint256 result);


    function swapFor(
        address src,
        address dst,
        uint256 amount,
        uint256 minReturn,
        address referral,
        address payable receiver
    ) external payable returns (uint256 result);

}// ISC

pragma solidity 0.6.12;

interface IStakingProxy {

    function initialize(address alphaStaking) external;


    function getTotalStaked() external view returns (uint256);


    function getUnbondingAmount() external view returns (uint256);


    function getLastUnbondingTimestamp() external view returns (uint256);


    function getWithdrawableAmount() external view returns (uint256);


    function isUnbonding() external view returns (bool);


    function withdraw() external returns (uint256);


    function stake(uint256 amount) external;


    function unbond() external;


    function withdrawToken(address token) external;

}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IBeacon {

    function implementation() external view returns (address);

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

pragma solidity >=0.6.0 <0.8.0;


contract UpgradeableBeacon is IBeacon, Ownable {

    address private _implementation;

    event Upgraded(address indexed implementation);

    constructor(address implementation_) public {
        _setImplementation(implementation_);
    }

    function implementation() public view virtual override returns (address) {

        return _implementation;
    }

    function upgradeTo(address newImplementation) public virtual onlyOwner {

        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    function _setImplementation(address newImplementation) private {

        require(Address.isContract(newImplementation), "UpgradeableBeacon: implementation is not a contract");
        _implementation = newImplementation;
    }
}// ISC

pragma solidity 0.6.12;


contract StakingProxyBeacon is UpgradeableBeacon {

    constructor(address _implementation) public UpgradeableBeacon(_implementation) {}
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Proxy {
    function _delegate(address implementation) internal virtual {
        assembly {
            calldatacopy(0, 0, calldatasize())

            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    function _implementation() internal view virtual returns (address);

    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    fallback () external payable virtual {
        _fallback();
    }

    receive () external payable virtual {
        _fallback();
    }

    function _beforeFallback() internal virtual {
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract BeaconProxy is Proxy {

    bytes32 private constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    constructor(address beacon, bytes memory data) public payable {
        assert(_BEACON_SLOT == bytes32(uint256(keccak256("eip1967.proxy.beacon")) - 1));
        _setBeacon(beacon, data);
    }

    function _beacon() internal view virtual returns (address beacon) {

        bytes32 slot = _BEACON_SLOT;
        assembly {
            beacon := sload(slot)
        }
    }

    function _implementation() internal view virtual override returns (address) {

        return IBeacon(_beacon()).implementation();
    }

    function _setBeacon(address beacon, bytes memory data) internal virtual {

        require(
            Address.isContract(beacon),
            "BeaconProxy: beacon is not a contract"
        );
        require(
            Address.isContract(IBeacon(beacon).implementation()),
            "BeaconProxy: beacon implementation is not a contract"
        );
        bytes32 slot = _BEACON_SLOT;

        assembly {
            sstore(slot, beacon)
        }

        if (data.length > 0) {
            Address.functionDelegateCall(_implementation(), data, "BeaconProxy: function call failed");
        }
    }
}// ISC

pragma solidity 0.6.12;


contract StakingProxyProxy is BeaconProxy {

    constructor(address _beacon) public BeaconProxy(_beacon, "") {}
}// ISC

pragma solidity 0.6.12;



contract StakingFactory is Ownable {

    address public stakingProxyBeacon;
    address payable[] public stakingProxyProxies;

    constructor(address _stakingProxyBeacon) public {
        stakingProxyBeacon = _stakingProxyBeacon;
    }

    function deployProxy() external onlyOwner returns (address) {

        StakingProxyProxy proxy = new StakingProxyProxy(stakingProxyBeacon);
        stakingProxyProxies.push(address(proxy));
        return address(proxy);
    }

    function getStakingProxyProxiesLength() external view returns (uint256) {

        return stakingProxyProxies.length;
    }
}// ISC

pragma solidity 0.6.12;




interface IxALPHA {

    enum SwapMode {
        SUSHISWAP,
        UNISWAP_V3
    }

    struct FeeDivisors {
        uint256 mintFee;
        uint256 burnFee;
        uint256 claimFee;
    }

    event Stake(uint256 proxyIndex, uint256 timestamp, uint256 amount);
    event Unbond(uint256 proxyIndex, uint256 timestamp, uint256 amount);
    event Claim(uint256 proxyIndex, uint256 amount);
    event FeeDivisorsSet(uint256 mintFee, uint256 burnFee, uint256 claimFee);
    event FeeWithdraw(uint256 fee);
    event UpdateSwapRouter(SwapMode version);
    event UpdateUniswapV3AlphaPoolFee(uint24 fee);
    event UpdateStakedBalance(uint256 totalStaked);

    function initialize(
        string calldata _symbol,
        IWETH _wethToken,
        IERC20 _alphaToken,
        address _alphaStaking,
        StakingFactory _stakingFactory,
        IxTokenManager _xTokenManager,
        address _uniswapRouter,
        address _sushiswapRouter,
        FeeDivisors calldata _feeDivisors
    ) external;


    function mint(uint256 minReturn) external payable;


    function mintWithToken(uint256 alphaAmount) external;


    function calculateMintAmount(uint256 incrementalAlpha, uint256 totalSupply)
        external
        view
        returns (uint256 mintAmount);


    function burn(
        uint256 tokenAmount,
        bool redeemForEth,
        uint256 minReturn
    ) external;


    function getNav() external view returns (uint256);


    function getBufferBalance() external view returns (uint256);


    function getFundBalances() external view returns (uint256, uint256);


    function getWithdrawableAmount(uint256 proxyIndex) external view returns (uint256);


    function stake(
        uint256 proxyIndex,
        uint256 amount,
        bool force
    ) external;


    function updateStakedBalance() external;


    function unbond(uint256 proxyIndex, bool force) external;


    function claimUnbonded(uint256 proxyIndex) external;


    function pauseContract() external;


    function unpauseContract() external;


    function emergencyUnbond() external;


    function emergencyClaim() external;


    function setFeeDivisors(
        uint256 mintFeeDivisor,
        uint256 burnFeeDivisor,
        uint256 claimFeeDivisor
    ) external;


    function updateSwapRouter(SwapMode version) external;


    function updateUniswapV3AlphaPoolFee(uint24 fee) external;


    function withdrawNativeToken() external;


    function withdrawTokenFromProxy(uint256 proxyIndex, address token) external;


    function withdrawFees() external;

}// ISC

pragma solidity 0.6.12;

interface IUniswapV2Router01 {

    function factory() external pure returns (address);


    function WETH() external pure returns (address);


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );


    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );


    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);


    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);


    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);


    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);


    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);


    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);


    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);


    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);


    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);


    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);


    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);

}

interface IUniswapV2Router02 is IUniswapV2Router01 {

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);


    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);


    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;


    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;


    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

}// GPL-2.0-or-later
pragma solidity 0.6.12;


interface IUniswapV3SwapRouter {

    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);


    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);


    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    function exactOutputSingle(ExactOutputSingleParams calldata params) external payable returns (uint256 amountIn);


    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    function exactOutput(ExactOutputParams calldata params) external payable returns (uint256 amountIn);

}// ISC

pragma solidity 0.6.12;





contract xALPHA is Initializable, ERC20Upgradeable, OwnableUpgradeable, PausableUpgradeable, IxALPHA, BlockLock {

    using SafeMathUpgradeable for uint256;
    using SafeERC20Upgradeable for SafeERC20Upgradeable;
    using SafeERC20 for IERC20;

    uint256 private constant LIQUIDATION_TIME_PERIOD = 4 weeks;
    uint256 private constant INITIAL_SUPPLY_MULTIPLIER = 10;
    uint256 private constant STAKING_PROXIES_AMOUNT = 5;
    uint256 private constant MAX_UINT = 2**256 - 1;

    address private constant ETH_ADDRESS = address(0);
    IWETH private weth;
    IERC20 private alphaToken;
    StakingFactory private stakingFactory;
    address private stakingProxyImplementation;

    uint256 public totalStakedBalance;

    uint256 public adminActiveTimestamp;
    uint256 public withdrawableAlphaFees;
    uint256 public emergencyUnbondTimestamp;
    uint256 public lastStakeTimestamp;

    IxTokenManager private xTokenManager; // xToken manager contract
    address private uniswapRouter;
    address private sushiswapRouter;
    SwapMode private swapMode;
    FeeDivisors public feeDivisors;
    uint24 public v3AlphaPoolFee;

    function initialize(
        string calldata _symbol,
        IWETH _wethToken,
        IERC20 _alphaToken,
        address _alphaStaking,
        StakingFactory _stakingFactory,
        IxTokenManager _xTokenManager,
        address _uniswapRouter,
        address _sushiswapRouter,
        FeeDivisors calldata _feeDivisors
    ) external override initializer {

        __Context_init_unchained();
        __Ownable_init_unchained();
        __Pausable_init_unchained();
        __ERC20_init_unchained("xALPHA", _symbol);

        weth = _wethToken;
        alphaToken = _alphaToken;
        stakingFactory = _stakingFactory;
        xTokenManager = _xTokenManager;
        uniswapRouter = _uniswapRouter;
        sushiswapRouter = _sushiswapRouter;
        updateSwapRouter(SwapMode.UNISWAP_V3);

        alphaToken.safeApprove(sushiswapRouter, MAX_UINT);
        IERC20(address(weth)).safeApprove(sushiswapRouter, MAX_UINT);

        alphaToken.safeApprove(uniswapRouter, MAX_UINT);
        IERC20(address(weth)).safeApprove(uniswapRouter, MAX_UINT);

        v3AlphaPoolFee = 10000;

        _setFeeDivisors(_feeDivisors.mintFee, _feeDivisors.burnFee, _feeDivisors.claimFee);

        for (uint256 i = 0; i < STAKING_PROXIES_AMOUNT; ++i) {
            stakingFactory.deployProxy();

            IStakingProxy(stakingFactory.stakingProxyProxies(i)).initialize(_alphaStaking);
        }
    }


    function mint(uint256 minReturn) external payable override whenNotPaused notLocked(msg.sender) {

        require(msg.value > 0, "Must send ETH");
        _lock(msg.sender);

        uint256 alphaAmount = _swapETHforALPHAInternal(msg.value, minReturn);

        uint256 fee = _calculateFee(alphaAmount, feeDivisors.mintFee);
        _incrementWithdrawableAlphaFees(fee);

        return _mintInternal(alphaAmount.sub(fee));
    }

    function mintWithToken(uint256 alphaAmount) external override whenNotPaused notLocked(msg.sender) {

        require(alphaAmount > 0, "Must send token");
        _lock(msg.sender);

        alphaToken.safeTransferFrom(msg.sender, address(this), alphaAmount);

        uint256 fee = _calculateFee(alphaAmount, feeDivisors.mintFee);
        _incrementWithdrawableAlphaFees(fee);

        return _mintInternal(alphaAmount.sub(fee));
    }

    function _mintInternal(uint256 _incrementalAlpha) private {

        uint256 mintAmount = calculateMintAmount(_incrementalAlpha, totalSupply());

        return super._mint(msg.sender, mintAmount);
    }

    function calculateMintAmount(uint256 incrementalAlpha, uint256 totalSupply)
        public
        view
        override
        returns (uint256 mintAmount)
    {

        if (totalSupply == 0) return incrementalAlpha.mul(INITIAL_SUPPLY_MULTIPLIER);
        uint256 previousNav = getNav().sub(incrementalAlpha);
        mintAmount = incrementalAlpha.mul(totalSupply).div(previousNav);
    }

    function burn(
        uint256 tokenAmount,
        bool redeemForEth,
        uint256 minReturn
    ) external override notLocked(msg.sender) {

        require(tokenAmount > 0, "Must send xALPHA");
        _lock(msg.sender);

        (uint256 stakedBalance, uint256 bufferBalance) = getFundBalances();
        uint256 alphaHoldings = stakedBalance.add(bufferBalance);
        uint256 proRataAlpha = alphaHoldings.mul(tokenAmount).div(totalSupply());

        require(proRataAlpha <= bufferBalance, "Insufficient exit liquidity");
        super._burn(msg.sender, tokenAmount);

        uint256 fee = _calculateFee(proRataAlpha, feeDivisors.burnFee);
        _incrementWithdrawableAlphaFees(fee);

        uint256 withdrawAmount = proRataAlpha.sub(fee);

        if (redeemForEth) {
            uint256 ethAmount = _swapALPHAForETHInternal(withdrawAmount, minReturn);
            (bool success, ) = msg.sender.call{ value: ethAmount }(new bytes(0));
            require(success, "ETH burn transfer failed");
        } else {
            alphaToken.safeTransfer(msg.sender, withdrawAmount);
        }
    }

    function transfer(address recipient, uint256 amount) public override notLocked(msg.sender) returns (bool) {

        return super.transfer(recipient, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override notLocked(sender) returns (bool) {

        return super.transferFrom(sender, recipient, amount);
    }

    function _swapETHforALPHAInternal(uint256 ethAmount, uint256 minReturn) private returns (uint256) {

        uint256 deadline = MAX_UINT;

        if (swapMode == SwapMode.SUSHISWAP) {
            IUniswapV2Router02 routerV2 = IUniswapV2Router02(sushiswapRouter);

            address[] memory path = new address[](2);
            path[0] = address(weth);
            path[1] = address(alphaToken);

            uint256[] memory amounts = routerV2.swapExactETHForTokens{ value: ethAmount }(
                minReturn,
                path,
                address(this),
                deadline
            );

            return amounts[1];
        } else {
            IUniswapV3SwapRouter routerV3 = IUniswapV3SwapRouter(uniswapRouter);

            weth.deposit{ value: ethAmount }();

            IUniswapV3SwapRouter.ExactInputSingleParams memory params = IUniswapV3SwapRouter.ExactInputSingleParams({
                tokenIn: address(weth),
                tokenOut: address(alphaToken),
                fee: v3AlphaPoolFee,
                recipient: address(this),
                deadline: deadline,
                amountIn: ethAmount,
                amountOutMinimum: minReturn,
                sqrtPriceLimitX96: 0
            });

            uint256 amountOut = routerV3.exactInputSingle(params);

            return amountOut;
        }
    }

    function _swapALPHAForETHInternal(uint256 alphaAmount, uint256 minReturn) private returns (uint256) {

        uint256 deadline = MAX_UINT;

        if (swapMode == SwapMode.SUSHISWAP) {
            IUniswapV2Router02 routerV2 = IUniswapV2Router02(sushiswapRouter);

            address[] memory path = new address[](2);
            path[0] = address(alphaToken);
            path[1] = address(weth);

            uint256[] memory amounts = routerV2.swapExactTokensForETH(
                alphaAmount,
                minReturn,
                path,
                address(this),
                deadline
            );

            return amounts[1];
        } else {
            IUniswapV3SwapRouter routerV3 = IUniswapV3SwapRouter(uniswapRouter);

            IUniswapV3SwapRouter.ExactInputSingleParams memory params = IUniswapV3SwapRouter.ExactInputSingleParams({
                tokenIn: address(alphaToken),
                tokenOut: address(weth),
                fee: v3AlphaPoolFee,
                recipient: address(this),
                deadline: deadline,
                amountIn: alphaAmount,
                amountOutMinimum: minReturn,
                sqrtPriceLimitX96: 0
            });

            uint256 amountOut = routerV3.exactInputSingle(params);

            weth.withdraw(amountOut);

            return amountOut;
        }
    }


    function getNav() public view override returns (uint256) {

        return totalStakedBalance.add(getBufferBalance());
    }

    function getBufferBalance() public view override returns (uint256) {

        return alphaToken.balanceOf(address(this)).sub(withdrawableAlphaFees);
    }

    function getFundBalances() public view override returns (uint256, uint256) {

        return (totalStakedBalance, getBufferBalance());
    }

    function getWithdrawableAmount(uint256 proxyIndex) public view override returns (uint256) {

        require(proxyIndex < stakingFactory.getStakingProxyProxiesLength(), "Invalid index");
        return IStakingProxy(stakingFactory.stakingProxyProxies(proxyIndex)).getWithdrawableAmount();
    }

    function getWithdrawableFees() public view returns (address feeAsset, uint256 feeAmount) {

        feeAsset = address(alphaToken);
        feeAmount = withdrawableAlphaFees;
    }

    function stake(
        uint256 proxyIndex,
        uint256 amount,
        bool force
    ) public override onlyOwnerOrManager {

        _certifyAdmin();

        _stake(proxyIndex, amount, force);

        updateStakedBalance();
    }

    function updateStakedBalance() public override onlyOwnerOrManager {

        uint256 _totalStakedBalance;

        for (uint256 i = 0; i < stakingFactory.getStakingProxyProxiesLength(); i++) {
            _totalStakedBalance = _totalStakedBalance.add(
                IStakingProxy(stakingFactory.stakingProxyProxies(i)).getTotalStaked()
            );
        }

        totalStakedBalance = _totalStakedBalance;

        emit UpdateStakedBalance(totalStakedBalance);
    }

    function unbond(uint256 proxyIndex, bool force) public override onlyOwnerOrManager {

        _certifyAdmin();
        _unbond(proxyIndex, force);
    }

    function claimUnbonded(uint256 proxyIndex) public override onlyOwnerOrManager {

        _certifyAdmin();
        _claim(proxyIndex);

        updateStakedBalance();
    }

    function _stake(
        uint256 proxyIndex,
        uint256 amount,
        bool force
    ) private {

        require(amount > 0, "Cannot stake zero tokens");
        require(
            !IStakingProxy(stakingFactory.stakingProxyProxies(proxyIndex)).isUnbonding() || force,
            "Cannot stake during unbonding"
        );

        lastStakeTimestamp = block.timestamp;

        alphaToken.safeTransfer(address(stakingFactory.stakingProxyProxies(proxyIndex)), amount);
        IStakingProxy(stakingFactory.stakingProxyProxies(proxyIndex)).stake(amount);

        emit Stake(proxyIndex, block.timestamp, amount);
    }

    function _unbond(uint256 proxyIndex, bool force) internal {

        require(
            !IStakingProxy(stakingFactory.stakingProxyProxies(proxyIndex)).isUnbonding() || force,
            "Cannot unbond during unbonding"
        );

        IStakingProxy(stakingFactory.stakingProxyProxies(proxyIndex)).unbond();

        emit Unbond(
            proxyIndex,
            block.timestamp,
            IStakingProxy(stakingFactory.stakingProxyProxies(proxyIndex)).getUnbondingAmount()
        );
    }

    function _claim(uint256 proxyIndex) internal {

        require(IStakingProxy(stakingFactory.stakingProxyProxies(proxyIndex)).isUnbonding(), "Not unbonding");

        uint256 claimedAmount = IStakingProxy(stakingFactory.stakingProxyProxies(proxyIndex)).withdraw();

        emit Claim(proxyIndex, claimedAmount);
    }

    function _calculateFee(uint256 _value, uint256 _feeDivisor) internal pure returns (uint256 fee) {

        if (_feeDivisor > 0) {
            fee = _value.div(_feeDivisor);
        }
    }

    function _incrementWithdrawableAlphaFees(uint256 _feeAmount) private {

        withdrawableAlphaFees = withdrawableAlphaFees.add(_feeAmount);
    }


    function pauseContract() public override onlyOwnerOrManager {

        _pause();
    }

    function unpauseContract() public override onlyOwnerOrManager {

        _unpause();
    }

    function emergencyUnbond() external override {

        require(adminActiveTimestamp.add(LIQUIDATION_TIME_PERIOD) < block.timestamp, "Liquidation time not elapsed");

        uint256 thirtyThreeDaysAgo = block.timestamp - 33 days;
        require(emergencyUnbondTimestamp < thirtyThreeDaysAgo, "In unbonding period");

        emergencyUnbondTimestamp = block.timestamp;

        for (uint256 i = 0; i < stakingFactory.getStakingProxyProxiesLength(); i++) {
            _unbond(i, true);
        }
    }

    function emergencyClaim() external override {

        require(adminActiveTimestamp.add(LIQUIDATION_TIME_PERIOD) < block.timestamp, "Liquidation time not elapsed");
        require(emergencyUnbondTimestamp != 0, "Emergency unbond not called");

        emergencyUnbondTimestamp = 0;

        for (uint256 i = 0; i < stakingFactory.getStakingProxyProxiesLength(); i++) {
            _claim(i);
        }
    }


    function setFeeDivisors(
        uint256 mintFeeDivisor,
        uint256 burnFeeDivisor,
        uint256 claimFeeDivisor
    ) public override onlyOwner {

        _setFeeDivisors(mintFeeDivisor, burnFeeDivisor, claimFeeDivisor);
    }

    function _setFeeDivisors(
        uint256 _mintFeeDivisor,
        uint256 _burnFeeDivisor,
        uint256 _claimFeeDivisor
    ) private {

        require(_mintFeeDivisor == 0 || _mintFeeDivisor >= 50, "Invalid fee");
        require(_burnFeeDivisor == 0 || _burnFeeDivisor >= 100, "Invalid fee");
        require(_claimFeeDivisor >= 25, "Invalid fee");
        feeDivisors.mintFee = _mintFeeDivisor;
        feeDivisors.burnFee = _burnFeeDivisor;
        feeDivisors.claimFee = _claimFeeDivisor;

        emit FeeDivisorsSet(_mintFeeDivisor, _burnFeeDivisor, _claimFeeDivisor);
    }

    function _certifyAdmin() private {

        adminActiveTimestamp = block.timestamp;
    }

    function updateSwapRouter(SwapMode version) public override onlyOwnerOrManager {

        require(version == SwapMode.SUSHISWAP || version == SwapMode.UNISWAP_V3, "Invalid swap router version");

        swapMode = version;

        emit UpdateSwapRouter(version);
    }

    function updateUniswapV3AlphaPoolFee(uint24 fee) external override onlyOwnerOrManager {

        v3AlphaPoolFee = fee;

        emit UpdateUniswapV3AlphaPoolFee(v3AlphaPoolFee);
    }

    function withdrawNativeToken() public override onlyOwnerOrManager {

        uint256 tokenBal = balanceOf(address(this));
        require(tokenBal > 0, "No tokens to withdraw");
        IERC20(address(this)).safeTransfer(msg.sender, tokenBal);
    }

    function withdrawTokenFromProxy(uint256 proxyIndex, address token) external override onlyOwnerOrManager {

        IStakingProxy(stakingFactory.stakingProxyProxies(proxyIndex)).withdrawToken(token);
        IERC20(token).safeTransfer(msg.sender, IERC20(token).balanceOf(address(this)));
    }

    function withdrawFees() public override {

        require(xTokenManager.isRevenueController(msg.sender), "Callable only by Revenue Controller");

        uint256 alphaFees = withdrawableAlphaFees;
        withdrawableAlphaFees = 0;
        alphaToken.safeTransfer(msg.sender, alphaFees);

        emit FeeWithdraw(alphaFees);
    }

    function exemptFromBlockLock(address lockAddress) external onlyOwnerOrManager {

        _exemptFromBlockLock(lockAddress);
    }

    function removeBlockLockExemption(address lockAddress) external onlyOwnerOrManager {

        _removeBlockLockExemption(lockAddress);
    }

    modifier onlyOwnerOrManager() {

        require(msg.sender == owner() || xTokenManager.isManager(msg.sender, address(this)), "Non-admin caller");
        _;
    }

    receive() external payable {
        require(msg.sender != tx.origin, "Errant ETH deposit");
    }
}