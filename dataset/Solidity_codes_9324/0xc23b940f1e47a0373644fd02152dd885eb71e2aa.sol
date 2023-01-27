
pragma solidity ^0.8.0;

library ClonesUpgradeable {

    function clone(address implementation) internal returns (address instance) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {

        return predictDeterministicAddress(implementation, salt, address(this));
    }
}// MIT

pragma solidity ^0.8.0;

library AddressUpgradeable {

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


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

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

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal onlyInitializing {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
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
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

interface IERC20Upgradeable {

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


interface IERC20MetadataUpgradeable is IERC20Upgradeable {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;


contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable, IERC20MetadataUpgradeable {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    function __ERC20_init(string memory name_, string memory symbol_) internal onlyInitializing {

        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {

        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    uint256[45] private __gap;
}// MIT

pragma solidity ^0.8.0;


library SafeERC20Upgradeable {

    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;

library MathUpgradeable {

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


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

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


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

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
}// GPL-3.0
pragma solidity 0.8.7;

interface ILiquidityGauge {
	struct Reward {
		address token;
		address distributor;
		uint256 period_finish;
		uint256 rate;
		uint256 last_update;
		uint256 integral;
	}

	function deposit_reward_token(address _rewardToken, uint256 _amount) external;

	function claim_rewards_for(address _user, address _recipient) external;


	function deposit(uint256 _value, address _addr) external;

	function reward_tokens(uint256 _i) external view returns (address);

	function reward_data(address _tokenReward) external view returns (Reward memory);

	function balanceOf(address) external returns (uint256);

	function claimable_reward(address _user, address _reward_token) external view returns (uint256);

	function user_checkpoint(address _user) external returns (bool);
}// MIT
pragma solidity 0.8.7;

interface ILocker {
	function createLock(uint256, uint256) external;

	function increaseAmount(uint256) external;

	function increaseUnlockTime(uint256) external;

	function release() external;

	function claimRewards(address,address) external;

	function claimFXSRewards(address) external;

	function execute(
		address,
		uint256,
		bytes calldata
	) external returns (bool, bytes memory);

	function setGovernance(address) external;

	function voteGaugeWeight(address, uint256) external;

	function setAngleDepositor(address) external;

	function setFxsDepositor(address) external;
}// MIT
pragma solidity 0.8.7;


contract BaseAccumulator {
	using SafeERC20 for IERC20;
	address public governance;
	address public locker;
	address public tokenReward;
	address public gauge;

	event GaugeSet(address oldGauge, address newGauge);
	event RewardNotified(address gauge, address tokenReward, uint256 amount);
	event LockerSet(address oldLocker, address newLocker);
	event GovernanceSet(address oldGov, address newGov);
	event TokenRewardSet(address oldTr, address newTr);
	event TokenDeposited(address token, uint256 amount);
	event ERC20Rescued(address token, uint256 amount);

	constructor(address _tokenReward) {
		tokenReward = _tokenReward;
		governance = msg.sender;
	}


	function notifyExtraReward(address _tokenReward, uint256 _amount) external {
		require(msg.sender == governance, "!gov");
		_notifyReward(_tokenReward, _amount);
	}

	function notifyAllExtraReward(address _tokenReward) external {
		require(msg.sender == governance, "!gov");
		uint256 amount = IERC20(_tokenReward).balanceOf(address(this));
		_notifyReward(_tokenReward, amount);
	}

	function _notifyReward(address _tokenReward, uint256 _amount) internal {
		require(gauge != address(0), "gauge not set");
		require(_amount > 0, "set an amount > 0");
		uint256 balanceBefore = IERC20(_tokenReward).balanceOf(address(this));
		require(balanceBefore >= _amount, "amount not enough");
		if (ILiquidityGauge(gauge).reward_data(_tokenReward).distributor != address(0)) {
			IERC20(_tokenReward).approve(gauge, _amount);
			ILiquidityGauge(gauge).deposit_reward_token(_tokenReward, _amount);
			uint256 balanceAfter = IERC20(_tokenReward).balanceOf(address(this));
			require(balanceBefore - balanceAfter == _amount, "wrong amount notified");
			emit RewardNotified(gauge, _tokenReward, _amount);
		}
	}

	function depositToken(address _token, uint256 _amount) external {
		require(_amount > 0, "set an amount > 0");
		IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);
		emit TokenDeposited(_token, _amount);
	}

	function setGauge(address _gauge) external {
		require(msg.sender == governance, "!gov");
		require(_gauge != address(0), "can't be zero address");
		emit GaugeSet(gauge, _gauge);
		gauge = _gauge;
	}

	function setGovernance(address _governance) external {
		require(msg.sender == governance, "!gov");
		require(_governance != address(0), "can't be zero address");
		emit GovernanceSet(governance, _governance);
		governance = _governance;
	}

	function setLocker(address _locker) external {
		require(msg.sender == governance, "!gov");
		require(_locker != address(0), "can't be zero address");
		emit LockerSet(locker, _locker);
		locker = _locker;
	}

	function setTokenReward(address _tokenReward) external {
		require(msg.sender == governance, "!gov");
		require(_tokenReward != address(0), "can't be zero address");
		emit TokenRewardSet(tokenReward, _tokenReward);
		tokenReward = _tokenReward;
	}

	function rescueERC20(
		address _token,
		uint256 _amount,
		address _recipient
	) external {
		require(msg.sender == governance, "!gov");
		require(_amount > 0, "set an amount > 0");
		require(_recipient != address(0), "can't be zero address");
		IERC20(_token).safeTransfer(_recipient, _amount);
		emit ERC20Rescued(_token, _amount);
	}
}// MIT
pragma solidity 0.8.7;


contract AngleAccumulator is BaseAccumulator {
	constructor(address _tokenReward) BaseAccumulator(_tokenReward) {}

	function claimAndNotify(uint256 _amount) external {
		require(locker != address(0), "locker not set");
		ILocker(locker).claimRewards(tokenReward, address(this));
		_notifyReward(tokenReward, _amount);
	}

	function claimAndNotifyAll() external {
		require(locker != address(0), "locker not set");
		ILocker(locker).claimRewards(tokenReward, address(this));
		uint256 amount = IERC20(tokenReward).balanceOf(address(this));
		_notifyReward(tokenReward, amount);
	}
}// MIT
pragma solidity 0.8.7;

interface IMultiRewards {
	function balanceOf(address) external returns (uint256);

	function stakeFor(address, uint256) external;

	function withdrawFor(address, uint256) external;

	function notifyRewardAmount(address, uint256) external;

	function mintFor(address recipient, uint256 amount) external;

	function burnFrom(address _from, uint256 _amount) external;

	function stakeOf(address account) external view returns (uint256);
}// MIT
pragma solidity 0.8.7;

contract BaseStrategy {
	ILocker locker;
	address public governance;
	address public rewardsReceiver;
	uint256 public veSDTFee;
	address public veSDTFeeProxy;
	uint256 public accumulatorFee;
	uint256 public claimerReward;
	uint256 public constant BASE_FEE = 10000;
	mapping(address => address) public gauges;
	mapping(address => bool) public vaults;
	mapping(address => uint256) public perfFee;
	mapping(address => address) public multiGauges;

	event Deposited(address _gauge, address _token, uint256 _amount);
	event Withdrawn(address _gauge, address _token, uint256 _amount);
	event Claimed(address _gauge, address _token, uint256 _amount);
	event VaultToggled(address _vault, bool _newState);
	event GaugeSet(address _gauge, address _token);

	modifier onlyGovernance() {
		require(msg.sender == governance, "!governance");
		_;
	}
	modifier onlyApprovedVault() {
		require(vaults[msg.sender], "!approved vault");
		_;
	}

	constructor(
		ILocker _locker,
		address _governance,
		address _receiver
	) public {
		locker = _locker;
		governance = _governance;
		rewardsReceiver = _receiver;
	}

	function deposit(address _token, uint256 _amount) external virtual onlyApprovedVault {}

	function withdraw(address _token, uint256 _amount) external virtual onlyApprovedVault {}

	function claim(address _gauge) external virtual {}

	function toggleVault(address _vault) external virtual onlyGovernance {}

	function setGauge(address _token, address _gauge) external virtual onlyGovernance {}

	function setMultiGauge(address _gauge, address _multiGauge) external virtual onlyGovernance {}
}// MIT
pragma solidity 0.8.7;

contract AngleStrategy is BaseStrategy {
	using SafeERC20 for IERC20;
	AngleAccumulator public accumulator;
	struct ClaimerReward {
		address rewardToken;
		uint256 amount;
	}
	enum MANAGEFEE {
		PERFFEE,
		VESDTFEE,
		ACCUMULATORFEE,
		CLAIMERREWARD
	}

	constructor(
		ILocker _locker,
		address _governance,
		address _receiver,
		AngleAccumulator _accumulator,
		address _veSDTFeeProxy
	) BaseStrategy(_locker, _governance, _receiver) {
		veSDTFee = 500; // %5
		accumulatorFee = 800; // %8
		claimerReward = 50; //%0.5
		accumulator = _accumulator;
		veSDTFeeProxy = _veSDTFeeProxy;
	}

	function deposit(address _token, uint256 _amount) public override onlyApprovedVault {
		IERC20(_token).transferFrom(msg.sender, address(locker), _amount);
		address gauge = gauges[_token];
		require(gauge != address(0), "!gauge");
		locker.execute(_token, 0, abi.encodeWithSignature("approve(address,uint256)", gauge, 0));
		locker.execute(_token, 0, abi.encodeWithSignature("approve(address,uint256)", gauge, _amount));

		(bool success, ) = locker.execute(gauge, 0, abi.encodeWithSignature("deposit(uint256)", _amount));
		require(success, "Deposit failed!");
		emit Deposited(gauge, _token, _amount);
	}

	function withdraw(address _token, uint256 _amount) public override onlyApprovedVault {
		uint256 _before = IERC20(_token).balanceOf(address(locker));
		address gauge = gauges[_token];
		require(gauge != address(0), "!gauge");
		(bool success, ) = locker.execute(gauge, 0, abi.encodeWithSignature("withdraw(uint256)", _amount));
		require(success, "Transfer failed!");
		uint256 _after = IERC20(_token).balanceOf(address(locker));

		uint256 _net = _after - _before;
		(success, ) = locker.execute(_token, 0, abi.encodeWithSignature("transfer(address,uint256)", msg.sender, _net));
		require(success, "Transfer failed!");
		emit Withdrawn(gauge, _token, _amount);
	}

	function claim(address _token) external override {
		address gauge = gauges[_token];
		require(gauge != address(0), "!gauge");
		(bool success, ) = locker.execute(gauge, 0, abi.encodeWithSignature("user_checkpoint(address)", address(locker)));
		require(success, "Checkpoint failed!");
		(success, ) = locker.execute(
			gauge,
			0,
			abi.encodeWithSignature("claim_rewards(address,address)", address(locker), address(this))
		);
		require(success, "Claim failed!");
		for (uint8 i = 0; i < 8; i++) {
			address rewardToken = ILiquidityGauge(gauge).reward_tokens(i);
			if (rewardToken == address(0)) {
				break;
			}
			uint256 rewardsBalance = IERC20(rewardToken).balanceOf(address(this));
			uint256 multisigFee = (rewardsBalance * perfFee[gauge]) / BASE_FEE;
			uint256 accumulatorPart = (rewardsBalance * accumulatorFee) / BASE_FEE;
			uint256 veSDTPart = (rewardsBalance * veSDTFee) / BASE_FEE;
			uint256 claimerPart = (rewardsBalance * claimerReward) / BASE_FEE;
			IERC20(rewardToken).approve(address(accumulator), accumulatorPart);
			accumulator.depositToken(rewardToken, accumulatorPart);
			IERC20(rewardToken).transfer(rewardsReceiver, multisigFee);
			IERC20(rewardToken).transfer(veSDTFeeProxy, veSDTPart);
			IERC20(rewardToken).transfer(msg.sender, claimerPart);
			uint256 netRewards = rewardsBalance - multisigFee - accumulatorPart - veSDTPart - claimerPart;
			IERC20(rewardToken).approve(multiGauges[gauge], netRewards);
			IMultiRewards(multiGauges[gauge]).notifyRewardAmount(rewardToken, netRewards);
			emit Claimed(gauge, rewardToken, rewardsBalance);
		}
	}

	function claimerPendingRewards(address _token) external view returns (ClaimerReward[] memory) {
		ClaimerReward[] memory pendings = new ClaimerReward[](8);
		address gauge = gauges[_token];
		for (uint8 i = 0; i < 8; i++) {
			address rewardToken = ILiquidityGauge(gauge).reward_tokens(i);
			if (rewardToken == address(0)) {
				break;
			}
			uint256 rewardsBalance = ILiquidityGauge(gauge).claimable_reward(address(locker), rewardToken);
			uint256 pendingAmount = (rewardsBalance * claimerReward) / BASE_FEE;
			ClaimerReward memory pendingReward = ClaimerReward(rewardToken, pendingAmount);
			pendings[i] = pendingReward;
		}
		return pendings;
	}

	function toggleVault(address _vault) external override onlyGovernance {
		vaults[_vault] = !vaults[_vault];
		emit VaultToggled(_vault, vaults[_vault]);
	}

	function setGauge(address _token, address _gauge) external override onlyGovernance {
		gauges[_token] = _gauge;
		emit GaugeSet(_gauge, _token);
	}

	function setMultiGauge(address _gauge, address _multiGauge) external override onlyGovernance {
		multiGauges[_gauge] = _multiGauge;
	}

	function setVeSDTProxy(address _newVeSDTProxy) external onlyGovernance {
		veSDTFeeProxy = _newVeSDTProxy;
	}

	function setAccumulator(address _newAccumulator) external onlyGovernance {
		accumulator = AngleAccumulator(_newAccumulator);
	}

	function setRewardsReceiver(address _newRewardsReceiver) external onlyGovernance {
		rewardsReceiver = _newRewardsReceiver;
	}

	function setGovernance(address _newGovernance) external onlyGovernance {
		governance = _newGovernance;
	}

	function manageFee(
		MANAGEFEE _manageFee,
		address _gauge,
		uint256 _newFee
	) external onlyGovernance {
		if (_manageFee == MANAGEFEE.PERFFEE) {
			require(_gauge != address(0), "zero address");
			perfFee[_gauge] = _newFee;
		} else if (_manageFee == MANAGEFEE.VESDTFEE) {
			veSDTFee = _newFee;
		} else if (_manageFee == MANAGEFEE.ACCUMULATORFEE) {
			accumulatorFee = _newFee;
		} else if (_manageFee == MANAGEFEE.CLAIMERREWARD) {
			claimerReward = _newFee;
		}
	}

	function execute(
		address to,
		uint256 value,
		bytes calldata data
	) external onlyGovernance returns (bool, bytes memory) {
		(bool success, bytes memory result) = to.call{ value: value }(data);
		return (success, result);
	}
}//MIT
pragma solidity ^0.8.7;


contract AngleVault is ERC20Upgradeable {
	using SafeERC20Upgradeable for ERC20Upgradeable;
	using AddressUpgradeable for address;

	ERC20Upgradeable public token;
	address public governance;
	uint256 public withdrawalFee;
	address public multiRewardsGauge;
	AngleStrategy public angleStrategy;
	uint256 public min;
	uint256 public constant max = 10000;
	event Earn(address _token, uint256 _amount);
	event Deposit(address _depositor, uint256 _amount);
	event Withdraw(address _depositor, uint256 _amount);

	function init(
		ERC20Upgradeable _token,
		address _governance,
		string memory name_,
		string memory symbol_,
		AngleStrategy _angleStrategy
	) public initializer {
		__ERC20_init(name_, symbol_);
		token = _token;
		governance = _governance;
		withdrawalFee = 50; // %0.5
		min = 10000;
		angleStrategy = _angleStrategy;
	}

	function deposit(uint256 _amount) public {
		require(address(multiRewardsGauge) != address(0), "Gauge not yet initialized");
		token.safeTransferFrom(msg.sender, address(this), _amount);
		_mint(address(this), _amount);
		ERC20Upgradeable(address(this)).approve(multiRewardsGauge, _amount);
		IMultiRewards(multiRewardsGauge).stakeFor(msg.sender, _amount);
		IMultiRewards(multiRewardsGauge).mintFor(msg.sender, _amount);
		emit Deposit(msg.sender, _amount);
	}

	function depositAll() external {
		deposit(token.balanceOf(msg.sender));
	}

	function withdraw(uint256 _shares) public {
		uint256 userTotalShares = IMultiRewards(multiRewardsGauge).stakeOf(msg.sender);
		require(_shares <= userTotalShares, "Not enough staked");
		IMultiRewards(multiRewardsGauge).withdrawFor(msg.sender, _shares);
		_burn(address(this), _shares);
		uint256 tokenBalance = token.balanceOf(address(this));
		uint256 withdrawFee;
		if (_shares > tokenBalance) {
			uint256 amountToWithdraw = _shares - tokenBalance;
			angleStrategy.withdraw(address(token), amountToWithdraw);
			withdrawFee = (amountToWithdraw * withdrawalFee) / 10000;
			token.safeTransfer(governance, withdrawFee);
		}
		IMultiRewards(multiRewardsGauge).burnFrom(msg.sender, _shares);
		token.safeTransfer(msg.sender, _shares - withdrawFee);
		emit Withdraw(msg.sender, _shares - withdrawFee);
	}

	function withdrawAll() external {
		withdraw(balanceOf(msg.sender));
	}

	function setGovernance(address _governance) external {
		require(msg.sender == governance, "!governance");
		governance = _governance;
	}

	function setGaugeMultiRewards(address _multiRewardsGauge) external {
		require(msg.sender == governance, "!governance");
		multiRewardsGauge = _multiRewardsGauge;
	}

	function setAngleStrategy(AngleStrategy _newStrat) external {
		require(msg.sender == governance, "!governance");
		angleStrategy = _newStrat;
	}

	function decimals() public view override returns (uint8) {
		return token.decimals();
	}

	function setWithdrawnFee(uint256 _newFee) external {
		require(msg.sender == governance, "!governance");
		withdrawalFee = _newFee;
	}

	function setMin(uint256 _min) external {
		require(msg.sender == governance, "!governance");
		min = _min;
	}

	function available() public view returns (uint256) {
		return (token.balanceOf(address(this)) * min) / max;
	}

	function earn() external {
		uint256 tokenBalance = available();
		token.increaseAllowance(address(angleStrategy), tokenBalance);
		angleStrategy.deposit(address(token), tokenBalance);
		emit Earn(address(token), tokenBalance);
	}
}// MIT
pragma solidity 0.8.7;


contract GaugeMultiRewards is ReentrancyGuardUpgradeable, PausableUpgradeable, ERC20Upgradeable {
	using SafeERC20Upgradeable for ERC20Upgradeable;


	struct Reward {
		address rewardsDistributor;
		uint256 rewardsDuration;
		uint256 periodFinish;
		uint256 rewardRate;
		uint256 lastUpdateTime;
		uint256 rewardPerTokenStored;
	}

	ERC20Upgradeable public stakingToken;
	address public vault;

	mapping(address => Reward) public rewardData;

	address public governance;
	address[] public rewardTokens;

	mapping(address => mapping(address => uint256)) public userRewardPerTokenPaid;
	mapping(address => mapping(address => uint256)) public rewards;

	uint256 private _totalStake;
	uint256 public derivedSupply;

	mapping(address => uint256) private _stakes;
	mapping(address => uint256) public derivedBalances;


	function init(
		address _stakingToken,
		address _vault,
		address _governance,
		string memory _name,
		string memory _symbol
	) public initializer {
		__ERC20_init(_name, _symbol);
		governance = _governance;
		stakingToken = ERC20Upgradeable(_stakingToken);
		vault = _vault;
	}

	function addReward(
		address _rewardsToken,
		address _rewardsDistributor,
		uint256 _rewardsDuration
	) public onlyGovernance {
		require(rewardData[_rewardsToken].rewardsDuration == 0);
		rewardTokens.push(_rewardsToken);
		rewardData[_rewardsToken].rewardsDistributor = _rewardsDistributor;
		rewardData[_rewardsToken].rewardsDuration = _rewardsDuration;
	}


	function totalStaked() external view returns (uint256) {
		return _totalStake;
	}

	function stakeOf(address account) external view returns (uint256) {
		return _stakes[account];
	}

	function lastTimeRewardApplicable(address _rewardsToken) public view returns (uint256) {
		return MathUpgradeable.min(block.timestamp, rewardData[_rewardsToken].periodFinish);
	}

	function rewardPerToken(address _rewardsToken) public view returns (uint256) {
		if (_totalStake == 0) {
			return rewardData[_rewardsToken].rewardPerTokenStored;
		}
		return
			rewardData[_rewardsToken].rewardPerTokenStored +
			(((lastTimeRewardApplicable(_rewardsToken) - rewardData[_rewardsToken].lastUpdateTime) *
				rewardData[_rewardsToken].rewardRate *
				(10**stakingToken.decimals())) / _totalStake); // from 1e18
	}

	function earned(address _account, address _rewardsToken) public view returns (uint256) {
		uint256 userBalance = _stakes[_account];

		return
			(userBalance * (rewardPerToken(_rewardsToken) - userRewardPerTokenPaid[_account][_rewardsToken])) /
			(10**stakingToken.decimals()) +
			rewards[_account][_rewardsToken];
	}

	function getRewardForDuration(address _rewardsToken) external view returns (uint256) {
		return rewardData[_rewardsToken].rewardRate * rewardData[_rewardsToken].rewardsDuration;
	}


	function setRewardsDistributor(address _rewardsToken, address _rewardsDistributor) external onlyGovernance {
		rewardData[_rewardsToken].rewardsDistributor = _rewardsDistributor;
	}

	function _stake(uint256 amount, address account) internal nonReentrant whenNotPaused updateReward(account) {
		require(amount > 0, "Cannot stake 0");
		_totalStake = _totalStake + amount;
		_stakes[account] = _stakes[account] + amount;
		stakingToken.safeTransferFrom(msg.sender, address(this), amount);
		emit Staked(account, amount);
	}

	function _withdraw(uint256 amount, address account) internal nonReentrant updateReward(account) {
		require(amount > 0, "Cannot withdraw 0");
		_totalStake = _totalStake - amount;
		_stakes[account] = _stakes[account] - amount;
		stakingToken.safeTransfer(msg.sender, amount);
		emit Withdrawn(account, amount);
	}

	function stakeFor(address account, uint256 amount) external onlyVault {
		_stake(amount, account);
	}

	function withdrawFor(address account, uint256 amount) external onlyVault {
		_withdraw(amount, account);
	}

	function getRewardFor(address account) public nonReentrant updateReward(account) {
		for (uint256 i; i < rewardTokens.length; i++) {
			address _rewardsToken = rewardTokens[i];
			uint256 reward = rewards[account][_rewardsToken];
			if (reward > 0) {
				rewards[account][_rewardsToken] = 0;
				ERC20Upgradeable(_rewardsToken).safeTransfer(account, reward);
				emit RewardPaid(account, _rewardsToken, reward);
			}
		}
	}


	function setGovernance(address _governance) public onlyGovernance {
		governance = _governance;
	}

	function notifyRewardAmount(address _rewardsToken, uint256 reward) external updateReward(address(0)) {
		require(rewardData[_rewardsToken].rewardsDistributor == msg.sender);
		ERC20Upgradeable(_rewardsToken).safeTransferFrom(msg.sender, address(this), reward);

		if (block.timestamp >= rewardData[_rewardsToken].periodFinish) {
			rewardData[_rewardsToken].rewardRate = reward / rewardData[_rewardsToken].rewardsDuration;
		} else {
			uint256 remaining = rewardData[_rewardsToken].periodFinish - block.timestamp;
			uint256 leftover = remaining * rewardData[_rewardsToken].rewardRate;
			rewardData[_rewardsToken].rewardRate = (reward + leftover) / rewardData[_rewardsToken].rewardsDuration;
		}

		rewardData[_rewardsToken].lastUpdateTime = block.timestamp;
		rewardData[_rewardsToken].periodFinish = block.timestamp + rewardData[_rewardsToken].rewardsDuration;
		emit RewardAdded(reward);
	}

	function recoverERC20(
		address tokenAddress,
		uint256 tokenAmount,
		address destination
	) external onlyGovernance {
		require(tokenAddress != address(stakingToken), "Cannot withdraw staking token");
		require(rewardData[tokenAddress].lastUpdateTime == 0, "Cannot withdraw reward token");
		ERC20Upgradeable(tokenAddress).safeTransfer(destination, tokenAmount);
		emit Recovered(tokenAddress, tokenAmount);
	}

	function setRewardsDuration(address _rewardsToken, uint256 _rewardsDuration) external {
		require(block.timestamp > rewardData[_rewardsToken].periodFinish, "Reward period still active");
		require(rewardData[_rewardsToken].rewardsDistributor == msg.sender);
		require(_rewardsDuration > 0, "Reward duration must be non-zero");
		rewardData[_rewardsToken].rewardsDuration = _rewardsDuration;
		emit RewardsDurationUpdated(_rewardsToken, rewardData[_rewardsToken].rewardsDuration);
	}

	function mintFor(address _recipient, uint256 _amount) external onlyVault {
		_mint(_recipient, _amount);
	}

	function burnFrom(address _from, uint256 _amount) external onlyVault {
		_burn(_from, _amount);
	}

	function decimals() public view override returns (uint8) {
		return stakingToken.decimals();
	}


	modifier updateReward(address account) {
		for (uint256 i; i < rewardTokens.length; i++) {
			address token = rewardTokens[i];
			rewardData[token].rewardPerTokenStored = rewardPerToken(token);
			rewardData[token].lastUpdateTime = lastTimeRewardApplicable(token);
			if (account != address(0)) {
				rewards[account][token] = earned(account, token);
				userRewardPerTokenPaid[account][token] = rewardData[token].rewardPerTokenStored;
			}
		}
		_;
	}

	modifier onlyGovernance() {
		require(msg.sender == governance, "!gov");
		_;
	}

	modifier onlyVault() {
		require(msg.sender == vault, "!vault");
		_;
	}


	event RewardAdded(uint256 reward);
	event Staked(address indexed user, uint256 amount);
	event Withdrawn(address indexed user, uint256 amount);
	event RewardPaid(address indexed user, address indexed rewardsToken, uint256 reward);
	event RewardsDurationUpdated(address token, uint256 newDuration);
	event Recovered(address token, uint256 amount);
}// MIT
pragma solidity 0.8.7;


contract AngleVaultFactory {
	using ClonesUpgradeable for address;

	address public vaultImpl = address(new AngleVault());
	address public gaugeImpl = address(new GaugeMultiRewards());

	event VaultDeployed(address proxy, address lpToken, address impl);
	event GaugeDeployed(address proxy, address stakeToken, address impl);

	function cloneAndInit(
		ERC20Upgradeable _vaultLPToken,
		address _vaultGovernance,
		string memory _vaultName,
		string memory _vaultSymbol,
		AngleStrategy _vaultAngleStrategy,
		address _gaugeGovernance,
		string memory _gaugeName,
		string memory _gaugeSymbol
	) public {
		address vaultImplAddress = _cloneAndInitVault(
			vaultImpl,
			_vaultLPToken,
			_vaultGovernance,
			_vaultName,
			_vaultSymbol,
			_vaultAngleStrategy
		);
		address gaugeImplAddress = _cloneAndInitGauge(
			gaugeImpl,
			vaultImplAddress,
			_gaugeGovernance,
			_gaugeName,
			_gaugeSymbol
		);
		AngleVault(vaultImplAddress).setGaugeMultiRewards(gaugeImplAddress);
		AngleVault(vaultImplAddress).setGovernance(_vaultGovernance);
	}

	function _cloneAndInitVault(
		address _impl,
		ERC20Upgradeable _lpToken,
		address _governance,
		string memory _name,
		string memory _symbol,
		AngleStrategy _angleStrategy
	) internal returns (address) {
		AngleVault deployed = cloneVault(
			_impl,
			_lpToken,
			keccak256(abi.encodePacked(_governance, _name, _symbol, _angleStrategy))
		);
		deployed.init(_lpToken, address(this), _name, _symbol, _angleStrategy);
		return address(deployed);
	}

	function _cloneAndInitGauge(
		address _impl,
		address _stakingToken,
		address _governance,
		string memory _name,
		string memory _symbol
	) internal returns (address) {
		GaugeMultiRewards deployed = cloneGauge(
			_impl,
			_stakingToken,
			keccak256(abi.encodePacked(_governance, _name, _symbol))
		);
		deployed.init(_stakingToken, _stakingToken, _governance, _name, _symbol);
		return address(deployed);
	}

	function cloneVault(
		address _impl,
		ERC20Upgradeable _lpToken,
		bytes32 _paramsHash
	) internal returns (AngleVault) {
		address deployed = address(_impl).cloneDeterministic(keccak256(abi.encodePacked(address(_lpToken), _paramsHash)));
		emit VaultDeployed(deployed, address(_lpToken), _impl);
		return AngleVault(deployed);
	}

	function cloneGauge(
		address _impl,
		address _stakingToken,
		bytes32 _paramsHash
	) internal returns (GaugeMultiRewards) {
		address deployed = address(_impl).cloneDeterministic(
			keccak256(abi.encodePacked(address(_stakingToken), _paramsHash))
		);
		emit GaugeDeployed(deployed, _stakingToken, _impl);
		return GaugeMultiRewards(deployed);
	}

	function predictAddress(
		address _impl,
		IERC20 _token,
		bytes32 _paramsHash
	) public view returns (address) {
		return address(_impl).predictDeterministicAddress(keccak256(abi.encodePacked(address(_token), _paramsHash)));
	}
}