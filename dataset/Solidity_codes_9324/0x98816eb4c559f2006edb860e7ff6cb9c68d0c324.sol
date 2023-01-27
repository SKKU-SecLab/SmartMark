
pragma solidity >=0.6.0 <0.8.0;

library ECDSAUpgradeable {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        if (signature.length != 65) {
            revert("ECDSA: invalid signature length");
        }

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        return recover(hash, v, r, s);
    }

    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {

        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ECDSA: invalid signature 's' value");
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
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

abstract contract EIP712Upgradeable is Initializable {
    bytes32 private _HASHED_NAME;
    bytes32 private _HASHED_VERSION;
    bytes32 private constant _TYPE_HASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    function __EIP712_init(string memory name, string memory version) internal initializer {
        __EIP712_init_unchained(name, version);
    }

    function __EIP712_init_unchained(string memory name, string memory version) internal initializer {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
    }

    function _domainSeparatorV4() internal view returns (bytes32) {
        return _buildDomainSeparator(_TYPE_HASH, _EIP712NameHash(), _EIP712VersionHash());
    }

    function _buildDomainSeparator(bytes32 typeHash, bytes32 name, bytes32 version) private view returns (bytes32) {
        return keccak256(
            abi.encode(
                typeHash,
                name,
                version,
                _getChainId(),
                address(this)
            )
        );
    }

    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", _domainSeparatorV4(), structHash));
    }

    function _getChainId() private view returns (uint256 chainId) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        assembly {
            chainId := chainid()
        }
    }

    function _EIP712NameHash() internal virtual view returns (bytes32) {
        return _HASHED_NAME;
    }

    function _EIP712VersionHash() internal virtual view returns (bytes32) {
        return _HASHED_VERSION;
    }
    uint256[50] private __gap;
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

interface IERC20PermitUpgradeable {

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;


    function nonces(address owner) external view returns (uint256);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

}// MIT

pragma solidity >=0.6.0 <0.8.0;


library CountersUpgradeable {

    using SafeMathUpgradeable for uint256;

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {

        counter._value = counter._value.sub(1);
    }
}// MIT

pragma solidity >=0.6.5 <0.8.0;


abstract contract ERC20PermitUpgradeable is Initializable, ERC20Upgradeable, IERC20PermitUpgradeable, EIP712Upgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;

    mapping (address => CountersUpgradeable.Counter) private _nonces;

    bytes32 private _PERMIT_TYPEHASH;

    function __ERC20Permit_init(string memory name) internal initializer {
        __Context_init_unchained();
        __EIP712_init_unchained(name, "1");
        __ERC20Permit_init_unchained(name);
    }

    function __ERC20Permit_init_unchained(string memory name) internal initializer {
        _PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    }

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public virtual override {
        require(block.timestamp <= deadline, "ERC20Permit: expired deadline");

        bytes32 structHash = keccak256(
            abi.encode(
                _PERMIT_TYPEHASH,
                owner,
                spender,
                value,
                _nonces[owner].current(),
                deadline
            )
        );

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSAUpgradeable.recover(hash, v, r, s);
        require(signer == owner, "ERC20Permit: invalid signature");

        _nonces[owner].increment();
        _approve(owner, spender, value);
    }

    function nonces(address owner) public view override returns (uint256) {
        return _nonces[owner].current();
    }

    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _domainSeparatorV4();
    }
    uint256[49] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC20Permit {

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;


    function nonces(address owner) external view returns (uint256);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

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

pragma solidity 0.7.6;

interface IBankStorage {

    function paused() external view returns (bool);


    function underlying() external view returns (address);

}// MIT

pragma solidity 0.7.6;


interface IBank is IBankStorage {

    function strategies(uint256 i) external view returns (address);


    function totalStrategies() external view returns (uint256);


    function underlyingBalance() external view returns (uint256);


    function strategyBalance(uint256 i) external view returns (uint256);


    function investedBalance() external view returns (uint256);


    function virtualBalance() external view returns (uint256);


    function virtualPrice() external view returns (uint256);


    function pause() external;


    function unpause() external;


    function invest(address strategy, uint256 amount) external;


    function investAll(address strategy) external;


    function exit(address strategy, uint256 amount) external;


    function exitAll(address strategy) external;


    function deposit(uint256 amount) external;


    function depositFor(uint256 amount, address recipient) external;


    function withdraw(uint256 amount) external;

}// MIT

pragma solidity 0.7.6;

interface IStrategyStorage {

    function bank() external view returns (address);


    function underlying() external view returns (address);


    function derivative() external view returns (address);


    function reward() external view returns (address);





}// MIT

pragma solidity 0.7.6;


interface IStrategyBase is IStrategyStorage {

    function underlyingBalance() external view returns (uint256);


    function derivativeBalance() external view returns (uint256);


    function rewardBalance() external view returns (uint256);

}// MIT

pragma solidity 0.7.6;


interface IStrategy is IStrategyBase {

    function investedBalance() external view returns (uint256);


    function invest() external;


    function withdraw(uint256 amount) external returns (uint256);


    function withdrawAll() external;

}// MIT

pragma solidity 0.7.6;

interface IManager {

    function token() external view returns (address);


    function buybackFee() external view returns (uint256);


    function managementFee() external view returns (uint256);


    function liquidators(address from, address to) external view returns (address);


    function whitelisted(address _contract) external view returns (bool);


    function banks(uint256 i) external view returns (address);


    function totalBanks() external view returns (uint256);


    function strategies(address bank, uint256 i) external view returns (address);


    function totalStrategies(address bank) external view returns (uint256);


    function withdrawIndex(address bank) external view returns (uint256);


    function setWithdrawIndex(uint256 i) external;


    function rebalance(address bank) external;


    function finance(address bank) external;


    function financeAll(address bank) external;


    function buyback(address from) external;


    function accrueRevenue(
        address bank,
        address underlying,
        uint256 amount
    ) external;


    function exitAll(address bank) external;

}// MIT

pragma solidity 0.7.6;

interface IRegistry {

    function governance() external view returns (address);


    function manager() external view returns (address);

}// MIT

pragma solidity 0.7.6;


library TransferHelper {

    using SafeERC20 for IERC20;

    function safeTokenTransfer(
        address recipient,
        address token,
        uint256 amount
    ) internal returns (uint256) {

        if (amount == 0) {
            return 0;
        }

        uint256 balance = IERC20(token).balanceOf(address(this));
        if (balance < amount) {
            IERC20(token).safeTransfer(recipient, balance);
            return balance;
        } else {
            IERC20(token).safeTransfer(recipient, amount);
            return amount;
        }
    }
}// MIT

pragma solidity 0.7.6;

interface ISubscriber {

    function registry() external view returns (address);


    function governance() external view returns (address);


    function manager() external view returns (address);

}// MIT

pragma solidity 0.7.6;

abstract contract OhUpgradeable {
    function getAddress(bytes32 slot) internal view returns (address _address) {
        assembly {
            _address := sload(slot)
        }
    }

    function getBoolean(bytes32 slot) internal view returns (bool _bool) {
        uint256 bool_;
        assembly {
            bool_ := sload(slot)
        }
        _bool = bool_ == 1;
    }

    function getBytes32(bytes32 slot) internal view returns (bytes32 _bytes32) {
        assembly {
            _bytes32 := sload(slot)
        }
    }

    function getUInt256(bytes32 slot) internal view returns (uint256 _uint) {
        assembly {
            _uint := sload(slot)
        }
    }

    function setAddress(bytes32 slot, address _address) internal {
        assembly {
            sstore(slot, _address)
        }
    }

    function setBytes32(bytes32 slot, bytes32 _bytes32) internal {
        assembly {
            sstore(slot, _bytes32)
        }
    }

    function setBoolean(bytes32 slot, bool _bool) internal {
        uint256 bool_ = _bool ? 1 : 0;
        assembly {
            sstore(slot, bool_)
        }
    }

    function setUInt256(bytes32 slot, uint256 _uint) internal {
        assembly {
            sstore(slot, _uint)
        }
    }
}// MIT

pragma solidity 0.7.6;


abstract contract OhSubscriberUpgradeable is Initializable, OhUpgradeable, ISubscriber {
    bytes32 private constant _REGISTRY_SLOT = 0x1b5717851286d5e98a28354be764b8c0a20eb2fbd059120090ee8bcfe1a9bf6c;

    modifier onlyAuthorized {
        require(msg.sender == governance() || msg.sender == manager(), "Subscriber: Only Authorized");
        _;
    }

    modifier onlyGovernance {
        require(msg.sender == governance(), "Subscriber: Only Governance");
        _;
    }

    constructor() {
        assert(_REGISTRY_SLOT == bytes32(uint256(keccak256("eip1967.subscriber.registry")) - 1));
    }

    function initializeSubscriber(address registry_) internal initializer {
        require(Address.isContract(registry_), "Subscriber: Invalid Registry");
        _setRegistry(registry_);
    }

    function setRegistry(address registry_) external onlyGovernance {
        _setRegistry(registry_);
        require(msg.sender == governance(), "Subscriber: Bad Governance");
    }

    function governance() public view override returns (address) {
        return IRegistry(registry()).governance();
    }

    function manager() public view override returns (address) {
        return IRegistry(registry()).manager();
    }

    function registry() public view override returns (address) {
        return getAddress(_REGISTRY_SLOT);
    }

    function _setRegistry(address registry_) private {
        setAddress(_REGISTRY_SLOT, registry_);
    }
}// MIT

pragma solidity 0.7.6;


abstract contract OhBankStorage is Initializable, OhUpgradeable, IBankStorage {
    bytes32 internal constant _UNDERLYING_SLOT = 0x90773825e4bc2bc5b176633f3046da46e88d251c6a1ff0816162f0a2ed8410ce;
    bytes32 internal constant _PAUSED_SLOT = 0x260da1bd0b3277b5df511eb3ee2570300c0d5002c849b8340104d112bb42b5be;

    constructor() {
        assert(_UNDERLYING_SLOT == bytes32(uint256(keccak256("eip1967.bank.underlying")) - 1));
        assert(_PAUSED_SLOT == bytes32(uint256(keccak256("eip1967.bank.paused")) - 1));
    }

    function initializeStorage(address underlying_) internal initializer {
        _setPaused(false);
        _setUnderlying(underlying_);
    }

    function paused() public view override returns (bool) {
        return getBoolean(_PAUSED_SLOT);
    }

    function underlying() public view override returns (address) {
        return getAddress(_UNDERLYING_SLOT);
    }

    function _setPaused(bool paused_) internal {
        setBoolean(_PAUSED_SLOT, paused_);
    }

    function _setUnderlying(address underlying_) internal {
        setAddress(_UNDERLYING_SLOT, underlying_);
    }
}// MIT

pragma solidity 0.7.6;


contract OhBank is ERC20Upgradeable, ERC20PermitUpgradeable, OhSubscriberUpgradeable, OhBankStorage, IBank {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    event Invest(address strategy, uint256 amount);

    event Deposit(address indexed user, uint256 amount);

    event Withdraw(address indexed user, uint256 amount);

    event Exit(address indexed strategy, uint256 amount);

    event ExitAll(address indexed strategy);

    event Pause(address indexed governance);

    event Unpause(address indexed governance);

    modifier defense {

        require(msg.sender == tx.origin || IManager(manager()).whitelisted(msg.sender), "Bank: Only EOA or whitelisted");
        _;
    }

    constructor() initializer {
        assert(registry() == address(0));
        assert(underlying() == address(0));
    }

    function initializeBank(
        string memory name_,
        string memory symbol_,
        address registry_,
        address underlying_
    ) public initializer {

        uint8 decimals_ = ERC20Upgradeable(underlying_).decimals();
        __ERC20_init(name_, symbol_);
        _setupDecimals(decimals_);

        __ERC20Permit_init(name_);

        initializeSubscriber(registry_);
        initializeStorage(underlying_);
    }

    function strategies(uint256 i) public view override returns (address) {

        return IManager(manager()).strategies(address(this), i);
    }

    function totalStrategies() public view override returns (uint256) {

        return IManager(manager()).totalStrategies(address(this));
    }

    function underlyingBalance() public view override returns (uint256) {

        return IERC20(underlying()).balanceOf(address(this));
    }

    function strategyBalance(uint256 i) public view override returns (uint256) {

        address strategy = strategies(i);
        return IStrategy(strategy).investedBalance();
    }

    function investedBalance() public view override returns (uint256 amount) {

        uint256 length = totalStrategies();
        for (uint256 i = 0; i < length; i++) {
            amount = amount.add(strategyBalance(i));
        }
    }

    function virtualBalance() public view override returns (uint256) {

        return underlyingBalance().add(investedBalance());
    }

    function virtualPrice() public view override returns (uint256) {

        uint256 totalSupply = totalSupply();
        uint256 unit = 10**decimals();
        return totalSupply == 0 ? unit : virtualBalance().mul(unit).div(totalSupply);
    }

    function invest(address strategy, uint256 amount) external override onlyAuthorized {

        _invest(strategy, amount);
    }

    function investAll(address strategy) external override onlyAuthorized {

        _invest(strategy, underlyingBalance());
    }

    function exit(address strategy, uint256 amount) external override onlyAuthorized {

        IStrategy(strategy).withdraw(amount);
        emit Exit(strategy, amount);
    }

    function exitAll(address strategy) external override onlyAuthorized {

        IStrategy(strategy).withdrawAll();
        emit ExitAll(strategy);
    }

    function pause() external override onlyGovernance {

        _setPaused(true);
        emit Pause(msg.sender);
    }

    function unpause() external override onlyGovernance {

        _setPaused(false);
        emit Unpause(msg.sender);
    }

    function deposit(uint256 amount) external override defense {

        _deposit(amount, msg.sender, msg.sender);
    }

    function depositFor(uint256 amount, address recipient) external override defense {

        require(recipient != address(0), "Bank: Invalid Recipient");
        _deposit(amount, msg.sender, recipient);
    }

    function depositWithPermit(
        uint256 amount,
        address recipient,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external defense {

        require(recipient != address(0), "Bank: Invalid Recipient");
        IERC20Permit(underlying()).permit(msg.sender, address(this), amount, deadline, v, r, s);
        _deposit(amount, msg.sender, recipient);
    }

    function withdraw(uint256 shares) external override defense {

        _withdraw(msg.sender, shares);
    }

    function _invest(address strategy, uint256 amount) internal {

        if (amount > 0) {
            TransferHelper.safeTokenTransfer(strategy, underlying(), amount);
        }
        IStrategy(strategy).invest();
        emit Invest(strategy, amount);
    }

    function _deposit(
        uint256 amount,
        address sender,
        address recipient
    ) internal {

        require(totalStrategies() > 0, "Bank: No Strategies");
        require(amount > 0, "Bank: Invalid Deposit");

        uint256 totalSupply = totalSupply();
        uint256 mintAmount = totalSupply == 0 ? amount : amount.mul(totalSupply).div(virtualBalance());

        _mint(recipient, mintAmount);
        IERC20(underlying()).safeTransferFrom(sender, address(this), amount);

        emit Deposit(recipient, amount);
    }

    function _withdraw(address user, uint256 shares) internal {

        require(shares > 0, "Bank: Invalid withdrawal");
        uint256 totalSupply = totalSupply();
        _burn(user, shares);

        uint256 balance = underlyingBalance();
        uint256 withdrawAmount = virtualBalance().mul(shares).div(totalSupply);
        if (withdrawAmount > balance) {
            if (shares == totalSupply) {
                _withdrawAll();
            } else {
                _withdrawRemaining(withdrawAmount.sub(balance));
            }
        }

        TransferHelper.safeTokenTransfer(user, underlying(), withdrawAmount);
        emit Withdraw(user, withdrawAmount);
    }

    function _withdrawAll() internal {

        uint256 length = totalStrategies();
        for (uint256 i = 0; i < length; i++) {
            IStrategy(strategies(i)).withdrawAll();
        }
    }

    function _withdrawRemaining(uint256 amount) internal {

        address manager = manager();
        uint256 index = IManager(manager).withdrawIndex(address(this));
        uint256 length = totalStrategies();
        uint256 i = 0;

        while (i < length && amount > 0) {
            uint256 withdrawn = IStrategy(strategies(index)).withdraw(amount);

            amount = amount.sub(withdrawn);
            i = i + 1;

            if (index - 1 == length) {
                index = 0;
            } else {
                index = index + 1;
            }
        }

        IManager(manager).setWithdrawIndex(index);
    }
}