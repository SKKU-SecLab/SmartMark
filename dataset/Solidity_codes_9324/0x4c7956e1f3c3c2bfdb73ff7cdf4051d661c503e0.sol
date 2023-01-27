pragma solidity ^0.7.4;
pragma experimental ABIEncoderV2;

uint256 constant SECONDS_IN_THE_YEAR = 365 * 24 * 60 * 60; // 365 days * 24 hours * 60 minutes * 60 seconds
uint256 constant DAYS_IN_THE_YEAR = 365;
uint256 constant MAX_INT = type(uint256).max;

uint256 constant DECIMALS18 = 10**18;

uint256 constant PRECISION = 10**25;
uint256 constant PERCENTAGE_100 = 100 * PRECISION;

uint256 constant BLOCKS_PER_DAY = 6450;
uint256 constant BLOCKS_PER_YEAR = BLOCKS_PER_DAY * 365;

uint256 constant APY_TOKENS = DECIMALS18;

uint256 constant PROTOCOL_PERCENTAGE = 20 * PRECISION;

uint256 constant DEFAULT_REBALANCING_THRESHOLD = 10**23;

uint256 constant EPOCH_DAYS_AMOUNT = 7;// MIT

pragma solidity ^0.7.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}// MIT

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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

pragma solidity ^0.7.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol) {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

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

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}// MIT

pragma solidity ^0.7.0;


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
pragma solidity ^0.7.4;


library DecimalsConverter {
    using SafeMath for uint256;

    function convert(
        uint256 amount,
        uint256 baseDecimals,
        uint256 destinationDecimals
    ) internal pure returns (uint256) {
        if (baseDecimals > destinationDecimals) {
            amount = amount.div(10**(baseDecimals - destinationDecimals));
        } else if (baseDecimals < destinationDecimals) {
            amount = amount.mul(10**(destinationDecimals - baseDecimals));
        }

        return amount;
    }

    function convertTo18(uint256 amount, uint256 baseDecimals) internal pure returns (uint256) {
        return convert(amount, baseDecimals, 18);
    }

    function convertFrom18(uint256 amount, uint256 destinationDecimals)
        internal
        pure
        returns (uint256)
    {
        return convert(amount, 18, destinationDecimals);
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
        address self = address(this);
        uint256 cs;
        assembly { cs := extcodesize(self) }
        return cs == 0;
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

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
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

    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
    uint256[44] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC20PermitUpgradeable {
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

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

pragma solidity >=0.6.0 <0.8.0;


abstract contract EIP712Upgradeable is Initializable {
    bytes32 private _HASHED_NAME;
    bytes32 private _HASHED_VERSION;
    bytes32 private constant _TYPE_HASH =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );


    function __EIP712_init(string memory name, string memory version) internal initializer {
        __EIP712_init_unchained(name, version);
    }

    function __EIP712_init_unchained(string memory name, string memory version)
        internal
        initializer
    {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
    }

    function _domainSeparatorV4() internal view returns (bytes32) {
        return _buildDomainSeparator(_TYPE_HASH, _EIP712NameHash(), _EIP712VersionHash());
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 name,
        bytes32 version
    ) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, name, version, _getChainId(), address(this)));
    }

    function _hashTypedDataV4(bytes32 structHash) internal view returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", _domainSeparatorV4(), structHash));
    }

    function _getChainId() private view returns (uint256 chainId) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        assembly {
            chainId := chainid()
        }
    }

    function _EIP712NameHash() internal view virtual returns (bytes32) {
        return _HASHED_NAME;
    }

    function _EIP712VersionHash() internal view virtual returns (bytes32) {
        return _HASHED_VERSION;
    }

    uint256[50] private __gap;
}// MIT

pragma solidity >=0.6.5 <0.8.0;


abstract contract ERC20PermitUpgradeable is
    Initializable,
    ERC20Upgradeable,
    IERC20PermitUpgradeable,
    EIP712Upgradeable
{
    using CountersUpgradeable for CountersUpgradeable.Counter;

    mapping(address => CountersUpgradeable.Counter) private _nonces;

    bytes32 private _PERMIT_TYPEHASH;

    function __ERC20Permit_init(string memory name) internal initializer {
        __Context_init_unchained();
        __EIP712_init_unchained(name, "1");
        __ERC20Permit_init_unchained(name);
    }

    function __ERC20Permit_init_unchained(string memory name) internal initializer {
        _PERMIT_TYPEHASH = keccak256(
            "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
        );
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual override {
        require(block.timestamp <= deadline, "ERC20Permit: expired deadline");

        bytes32 structHash =
            keccak256(
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

        address signer = recover(hash, v, r, s);
        require(signer == owner, "ERC20Permit: invalid signature");

        _nonces[owner].increment();
        _approve(owner, spender, value);
    }

    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        require(
            uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0,
            "ECDSA: invalid signature 's' value"
        );
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    function nonces(address owner) public view override returns (uint256) {
        return _nonces[owner].current();
    }

    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _domainSeparatorV4();
    }

    uint256[49] private __gap;
}// MIT
pragma solidity ^0.7.4;

interface IPolicyBookFabric {
    enum ContractType {CONTRACT, STABLECOIN, SERVICE, EXCHANGE, VARIOUS}

    function create(
        address _contract,
        ContractType _contractType,
        string calldata _description,
        string calldata _projectSymbol,
        uint256 _initialDeposit,
        address _shieldMiningToken
    ) external returns (address);

    function createLeveragePools(
        ContractType _contractType,
        string calldata _description,
        string calldata _projectSymbol
    ) external returns (address);
}// MIT
pragma solidity ^0.7.4;


interface IClaimingRegistry {
    enum ClaimStatus {
        CAN_CLAIM,
        UNCLAIMABLE,
        PENDING,
        AWAITING_CALCULATION,
        REJECTED_CAN_APPEAL,
        REJECTED,
        ACCEPTED
    }

    struct ClaimInfo {
        address claimer;
        address policyBookAddress;
        string evidenceURI;
        uint256 dateSubmitted;
        uint256 dateEnded;
        bool appeal;
        ClaimStatus status;
        uint256 claimAmount;
    }

    function anonymousVotingDuration(uint256 index) external view returns (uint256);

    function votingDuration(uint256 index) external view returns (uint256);

    function anyoneCanCalculateClaimResultAfter(uint256 index) external view returns (uint256);

    function canBuyNewPolicy(address buyer, address policyBookAddress)
        external
        view
        returns (bool);

    function submitClaim(
        address user,
        address policyBookAddress,
        string calldata evidenceURI,
        uint256 cover,
        bool appeal
    ) external returns (uint256);

    function claimExists(uint256 index) external view returns (bool);

    function claimSubmittedTime(uint256 index) external view returns (uint256);

    function claimEndTime(uint256 index) external view returns (uint256);

    function isClaimAnonymouslyVotable(uint256 index) external view returns (bool);

    function isClaimExposablyVotable(uint256 index) external view returns (bool);

    function isClaimVotable(uint256 index) external view returns (bool);

    function canClaimBeCalculatedByAnyone(uint256 index) external view returns (bool);

    function isClaimPending(uint256 index) external view returns (bool);

    function countPolicyClaimerClaims(address user) external view returns (uint256);

    function countPendingClaims() external view returns (uint256);

    function countClaims() external view returns (uint256);

    function claimOfOwnerIndexAt(address claimer, uint256 orderIndex)
        external
        view
        returns (uint256);

    function pendingClaimIndexAt(uint256 orderIndex) external view returns (uint256);

    function claimIndexAt(uint256 orderIndex) external view returns (uint256);

    function claimIndex(address claimer, address policyBookAddress)
        external
        view
        returns (uint256);

    function isClaimAppeal(uint256 index) external view returns (bool);

    function policyStatus(address claimer, address policyBookAddress)
        external
        view
        returns (ClaimStatus);

    function claimStatus(uint256 index) external view returns (ClaimStatus);

    function claimOwner(uint256 index) external view returns (address);

    function claimPolicyBook(uint256 index) external view returns (address);

    function claimInfo(uint256 index) external view returns (ClaimInfo memory _claimInfo);

    function getAllPendingClaimsAmount() external view returns (uint256 _totalClaimsAmount);

    function getClaimableAmounts(uint256[] memory _claimIndexes) external view returns (uint256);

    function acceptClaim(uint256 index) external;

    function rejectClaim(uint256 index) external;

    function updateImageUriOfClaim(uint256 _claimIndex, string calldata _newEvidenceURI) external;
}// MIT
pragma solidity ^0.7.4;

interface ILeveragePortfolio {
    enum LeveragePortfolio {USERLEVERAGEPOOL, REINSURANCEPOOL}
    struct LevFundsFactors {
        uint256 netMPL;
        uint256 netMPLn;
        address policyBookAddr;
    }

    function targetUR() external view returns (uint256);

    function d_ProtocolConstant() external view returns (uint256);

    function a_ProtocolConstant() external view returns (uint256);

    function max_ProtocolConstant() external view returns (uint256);

    function deployLeverageStableToCoveragePools(LeveragePortfolio leveragePoolType)
        external
        returns (uint256);

    function deployVirtualStableToCoveragePools() external returns (uint256);

    function setRebalancingThreshold(uint256 threshold) external;

    function setProtocolConstant(
        uint256 _targetUR,
        uint256 _d_ProtocolConstant,
        uint256 _a_ProtocolConstant,
        uint256 _max_ProtocolConstant
    ) external;


    function totalLiquidity() external view returns (uint256);

    function addPolicyPremium(uint256 epochsNumber, uint256 premiumAmount) external;

    function listleveragedCoveragePools(uint256 offset, uint256 limit)
        external
        view
        returns (address[] memory _coveragePools);

    function countleveragedCoveragePools() external view returns (uint256);
}// MIT
pragma solidity ^0.7.4;


interface IPolicyBookFacade {
    function buyPolicy(uint256 _epochsNumber, uint256 _coverTokens) external;

    function buyPolicyFor(
        address _holder,
        uint256 _epochsNumber,
        uint256 _coverTokens
    ) external;

    function policyBook() external view returns (IPolicyBook);

    function userLiquidity(address account) external view returns (uint256);

    function VUreinsurnacePool() external view returns (uint256);

    function LUreinsurnacePool() external view returns (uint256);

    function LUuserLeveragePool(address userLeveragePool) external view returns (uint256);

    function totalLeveragedLiquidity() external view returns (uint256);

    function userleveragedMPL() external view returns (uint256);

    function reinsurancePoolMPL() external view returns (uint256);

    function rebalancingThreshold() external view returns (uint256);

    function safePricingModel() external view returns (bool);

    function __PolicyBookFacade_init(
        address pbProxy,
        address liquidityProvider,
        uint256 initialDeposit
    ) external;

    function buyPolicyFromDistributor(
        uint256 _epochsNumber,
        uint256 _coverTokens,
        address _distributor
    ) external;

    function buyPolicyFromDistributorFor(
        address _buyer,
        uint256 _epochsNumber,
        uint256 _coverTokens,
        address _distributor
    ) external;

    function addLiquidity(uint256 _liquidityAmount) external;

    function addLiquidityFromDistributorFor(address _user, uint256 _liquidityAmount) external;

    function addLiquidityAndStake(uint256 _liquidityAmount, uint256 _stakeSTBLAmount) external;

    function withdrawLiquidity() external;

    function getPoolsData()
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            address
        );

    function deployLeverageFundsAfterRebalance(
        uint256 deployedAmount,
        ILeveragePortfolio.LeveragePortfolio leveragePool
    ) external;

    function deployVirtualFundsAfterRebalance(uint256 deployedAmount) external;

    function setMPLs(uint256 _userLeverageMPL, uint256 _reinsuranceLeverageMPL) external;

    function setRebalancingThreshold(uint256 _newRebalancingThreshold) external;

    function setSafePricingModel(bool _safePricingModel) external;

    function getClaimApprovalAmount(address user) external view returns (uint256);

    function requestWithdrawal(uint256 _tokensToWithdraw) external;
}// MIT
pragma solidity ^0.7.4;


interface IPolicyBook {
    enum WithdrawalStatus {NONE, PENDING, READY, EXPIRED}

    struct PolicyHolder {
        uint256 coverTokens;
        uint256 startEpochNumber;
        uint256 endEpochNumber;
        uint256 paid;
        uint256 reinsurancePrice;
    }

    struct WithdrawalInfo {
        uint256 withdrawalAmount;
        uint256 readyToWithdrawDate;
        bool withdrawalAllowed;
    }

    struct BuyPolicyParameters {
        address buyer;
        address holder;
        uint256 epochsNumber;
        uint256 coverTokens;
        uint256 distributorFee;
        address distributor;
    }

    function policyHolders(address _holder)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        );

    function policyBookFacade() external view returns (IPolicyBookFacade);

    function setPolicyBookFacade(address _policyBookFacade) external;

    function EPOCH_DURATION() external view returns (uint256);

    function stblDecimals() external view returns (uint256);

    function READY_TO_WITHDRAW_PERIOD() external view returns (uint256);

    function whitelisted() external view returns (bool);

    function epochStartTime() external view returns (uint256);

    function insuranceContractAddress() external view returns (address _contract);

    function contractType() external view returns (IPolicyBookFabric.ContractType _type);

    function totalLiquidity() external view returns (uint256);

    function totalCoverTokens() external view returns (uint256);




    function withdrawalsInfo(address _userAddr)
        external
        view
        returns (
            uint256 _withdrawalAmount,
            uint256 _readyToWithdrawDate,
            bool _withdrawalAllowed
        );

    function __PolicyBook_init(
        address _insuranceContract,
        IPolicyBookFabric.ContractType _contractType,
        string calldata _description,
        string calldata _projectSymbol
    ) external;

    function whitelist(bool _whitelisted) external;

    function getEpoch(uint256 time) external view returns (uint256);

    function convertBMIXToSTBL(uint256 _amount) external view returns (uint256);

    function convertSTBLToBMIX(uint256 _amount) external view returns (uint256);

    function submitClaimAndInitializeVoting(string calldata evidenceURI) external;

    function submitAppealAndInitializeVoting(string calldata evidenceURI) external;

    function commitClaim(
        address claimer,
        uint256 claimAmount,
        uint256 claimEndTime,
        IClaimingRegistry.ClaimStatus status
    ) external;

    function forceUpdateBMICoverStakingRewardMultiplier() external;

    function getNewCoverAndLiquidity()
        external
        view
        returns (uint256 newTotalCoverTokens, uint256 newTotalLiquidity);

    function getPolicyPrice(
        uint256 _epochsNumber,
        uint256 _coverTokens,
        address _buyer
    )
        external
        view
        returns (
            uint256 totalSeconds,
            uint256 totalPrice,
            uint256 pricePercentage
        );

    function buyPolicy(
        address _buyer,
        address _holder,
        uint256 _epochsNumber,
        uint256 _coverTokens,
        uint256 _distributorFee,
        address _distributor
    ) external returns (uint256, uint256);

    function updateEpochsInfo() external;

    function secondsToEndCurrentEpoch() external view returns (uint256);

    function addLiquidityFor(address _liquidityHolderAddr, uint256 _liqudityAmount) external;

    function addLiquidity(
        address _liquidityBuyerAddr,
        address _liquidityHolderAddr,
        uint256 _liquidityAmount,
        uint256 _stakeSTBLAmount
    ) external;

    function getAvailableBMIXWithdrawableAmount(address _userAddr) external view returns (uint256);

    function getWithdrawalStatus(address _userAddr) external view returns (WithdrawalStatus);

    function requestWithdrawal(uint256 _tokensToWithdraw, address _user) external;


    function unlockTokens() external;

    function withdrawLiquidity(address sender) external returns (uint256);

    function getAPY() external view returns (uint256);

    function userStats(address _user) external view returns (PolicyHolder memory);

    function numberStats()
        external
        view
        returns (
            uint256 _maxCapacities,
            uint256 _totalSTBLLiquidity,
            uint256 _totalLeveragedLiquidity,
            uint256 _stakedSTBL,
            uint256 _annualProfitYields,
            uint256 _annualInsuranceCost,
            uint256 _bmiXRatio
        );

    function info()
        external
        view
        returns (
            string memory _symbol,
            address _insuredContract,
            IPolicyBookFabric.ContractType _contractType,
            bool _whitelisted
        );
}// MIT
pragma solidity ^0.7.4;

interface IBMICoverStaking {
    struct StakingInfo {
        address policyBookAddress;
        uint256 stakedBMIXAmount;
    }

    struct PolicyBookInfo {
        uint256 totalStakedSTBL;
        uint256 rewardPerBlock;
        uint256 stakingAPY;
        uint256 liquidityAPY;
    }

    struct UserInfo {
        uint256 totalStakedBMIX;
        uint256 totalStakedSTBL;
        uint256 totalBmiReward;
    }

    struct NFTsInfo {
        uint256 nftIndex;
        string uri;
        uint256 stakedBMIXAmount;
        uint256 stakedSTBLAmount;
        uint256 reward;
    }

    function aggregateNFTs(address policyBookAddress, uint256[] calldata tokenIds) external;

    function stakeBMIX(uint256 amount, address policyBookAddress) external;

    function stakeBMIXWithPermit(
        uint256 bmiXAmount,
        address policyBookAddress,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function stakeBMIXFrom(address user, uint256 amount) external;

    function stakeBMIXFromWithPermit(
        address user,
        uint256 bmiXAmount,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    function _stakersPool(uint256 index)
        external
        view
        returns (address policyBookAddress, uint256 stakedBMIXAmount);


    function restakeBMIProfit(uint256 tokenId) external;

    function restakeStakerBMIProfit(address policyBookAddress) external;

    function withdrawBMIProfit(uint256 tokenID) external;

    function withdrawStakerBMIProfit(address policyBookAddress) external;

    function withdrawFundsWithProfit(uint256 tokenID) external;

    function withdrawStakerFundsWithProfit(address policyBookAddress) external;

    function getSlashedBMIProfit(uint256 tokenId) external view returns (uint256);

    function getBMIProfit(uint256 tokenId) external view returns (uint256);

    function getSlashedStakerBMIProfit(
        address staker,
        address policyBookAddress,
        uint256 offset,
        uint256 limit
    ) external view returns (uint256 totalProfit);

    function getStakerBMIProfit(
        address staker,
        address policyBookAddress,
        uint256 offset,
        uint256 limit
    ) external view returns (uint256 totalProfit);

    function totalStaked(address user) external view returns (uint256);

    function totalStakedSTBL(address user) external view returns (uint256);

    function stakedByNFT(uint256 tokenId) external view returns (uint256);

    function stakedSTBLByNFT(uint256 tokenId) external view returns (uint256);

    function balanceOf(address user) external view returns (uint256);

    function ownerOf(uint256 tokenId) external view returns (address);

    function uri(uint256 tokenId) external view returns (string memory);

    function tokenOfOwnerByIndex(address user, uint256 index) external view returns (uint256);
}// MIT
pragma solidity ^0.7.4;

interface ICapitalPool {
    struct PremiumFactors {
        uint256 stblAmount;
        uint256 premiumDurationInDays;
        uint256 premiumPrice;
        uint256 lStblDeployedByLP;
        uint256 vStblDeployedByRP;
        uint256 vStblOfCP;
        uint256 premiumPerDeployment;
        uint256 participatedlStblDeployedByLP;
        address userLeveragePoolAddress;
    }

    function virtualUsdtAccumulatedBalance() external view returns (uint256);

    function addPolicyHoldersHardSTBL(
        uint256 _stblAmount,
        uint256 _epochsNumber,
        uint256 _protocolFee
    ) external returns (uint256);

    function addCoverageProvidersHardSTBL(uint256 _stblAmount) external;

    function addLeverageProvidersHardSTBL(uint256 _stblAmount) external;

    function addReinsurancePoolHardSTBL(uint256 _stblAmount) external;

    function rebalanceLiquidityCushion() external;

    function fundClaim(address _claimer, uint256 _stblAmount) external;

    function withdrawLiquidity(
        address _sender,
        uint256 _stblAmount,
        bool _isLeveragePool
    ) external;
}// MIT
pragma solidity ^0.7.4;


interface IBMICoverStakingView {
    function getPolicyBookAPY(address policyBookAddress) external view returns (uint256);

    function policyBookByNFT(uint256 tokenId) external view returns (address);

    function stakingInfoByStaker(
        address staker,
        address[] calldata policyBooksAddresses,
        uint256 offset,
        uint256 limit
    )
        external
        view
        returns (
            IBMICoverStaking.PolicyBookInfo[] memory policyBooksInfo,
            IBMICoverStaking.UserInfo[] memory usersInfo,
            uint256[] memory nftsCount,
            IBMICoverStaking.NFTsInfo[][] memory nftsInfo
        );

    function stakingInfoByToken(uint256 tokenId)
        external
        view
        returns (IBMICoverStaking.StakingInfo memory);

}// MIT
pragma solidity ^0.7.4;

interface IContractsRegistry {
    function getUniswapRouterContract() external view returns (address);

    function getUniswapBMIToETHPairContract() external view returns (address);

    function getUniswapBMIToUSDTPairContract() external view returns (address);

    function getSushiswapRouterContract() external view returns (address);

    function getSushiswapBMIToETHPairContract() external view returns (address);

    function getSushiswapBMIToUSDTPairContract() external view returns (address);

    function getSushiSwapMasterChefV2Contract() external view returns (address);

    function getWETHContract() external view returns (address);

    function getUSDTContract() external view returns (address);

    function getBMIContract() external view returns (address);

    function getPriceFeedContract() external view returns (address);

    function getPolicyBookRegistryContract() external view returns (address);

    function getPolicyBookFabricContract() external view returns (address);

    function getBMICoverStakingContract() external view returns (address);

    function getBMICoverStakingViewContract() external view returns (address);

    function getLegacyRewardsGeneratorContract() external view returns (address);

    function getRewardsGeneratorContract() external view returns (address);

    function getBMIUtilityNFTContract() external view returns (address);

    function getNFTStakingContract() external view returns (address);

    function getLiquidityMiningContract() external view returns (address);

    function getClaimingRegistryContract() external view returns (address);

    function getPolicyRegistryContract() external view returns (address);

    function getLiquidityRegistryContract() external view returns (address);

    function getClaimVotingContract() external view returns (address);

    function getReinsurancePoolContract() external view returns (address);

    function getLeveragePortfolioViewContract() external view returns (address);

    function getCapitalPoolContract() external view returns (address);

    function getPolicyBookAdminContract() external view returns (address);

    function getPolicyQuoteContract() external view returns (address);

    function getLegacyBMIStakingContract() external view returns (address);

    function getBMIStakingContract() external view returns (address);

    function getSTKBMIContract() external view returns (address);

    function getVBMIContract() external view returns (address);

    function getLegacyLiquidityMiningStakingContract() external view returns (address);

    function getLiquidityMiningStakingETHContract() external view returns (address);

    function getLiquidityMiningStakingUSDTContract() external view returns (address);

    function getReputationSystemContract() external view returns (address);

    function getAaveProtocolContract() external view returns (address);

    function getAaveLendPoolAddressProvdierContract() external view returns (address);

    function getAaveATokenContract() external view returns (address);

    function getCompoundProtocolContract() external view returns (address);

    function getCompoundCTokenContract() external view returns (address);

    function getCompoundComptrollerContract() external view returns (address);

    function getYearnProtocolContract() external view returns (address);

    function getYearnVaultContract() external view returns (address);

    function getYieldGeneratorContract() external view returns (address);

    function getShieldMiningContract() external view returns (address);
}// MIT
pragma solidity ^0.7.4;


interface IPolicyRegistry {
    struct PolicyInfo {
        uint256 coverAmount;
        uint256 premium;
        uint256 startTime;
        uint256 endTime;
    }

    struct PolicyUserInfo {
        string symbol;
        address insuredContract;
        IPolicyBookFabric.ContractType contractType;
        uint256 coverTokens;
        uint256 startTime;
        uint256 endTime;
        uint256 paid;
    }

    function STILL_CLAIMABLE_FOR() external view returns (uint256);

    function getPoliciesLength(address _userAddr) external view returns (uint256);

    function policyExists(address _userAddr, address _policyBookAddr) external view returns (bool);

    function isPolicyActive(address _userAddr, address _policyBookAddr)
        external
        view
        returns (bool);

    function policyStartTime(address _userAddr, address _policyBookAddr)
        external
        view
        returns (uint256);

    function policyEndTime(address _userAddr, address _policyBookAddr)
        external
        view
        returns (uint256);

    function getPoliciesInfo(
        address _userAddr,
        bool _isActive,
        uint256 _offset,
        uint256 _limit
    )
        external
        view
        returns (
            uint256 _policiesCount,
            address[] memory _policyBooksArr,
            PolicyInfo[] memory _policies,
            IClaimingRegistry.ClaimStatus[] memory _policyStatuses
        );

    function getUsersInfo(address[] calldata _users, address[] calldata _policyBooks)
        external
        view
        returns (PolicyUserInfo[] memory _stats);

    function getPoliciesArr(address _userAddr) external view returns (address[] memory _arr);

    function addPolicy(
        address _userAddr,
        uint256 _coverAmount,
        uint256 _premium,
        uint256 _durationDays
    ) external;

    function removePolicy(address _userAddr) external;
}// MIT
pragma solidity ^0.7.4;


interface IClaimVoting {
    enum VoteStatus {
        ANONYMOUS_PENDING,
        AWAITING_EXPOSURE,
        EXPIRED,
        EXPOSED_PENDING,
        AWAITING_CALCULATION,
        MINORITY,
        MAJORITY
    }

    struct VotingResult {
        uint256 withdrawalAmount;
        uint256 lockedBMIAmount;
        uint256 reinsuranceTokensAmount;
        uint256 votedAverageWithdrawalAmount;
        uint256 votedYesStakedBMIAmountWithReputation;
        uint256 votedNoStakedBMIAmountWithReputation;
        uint256 allVotedStakedBMIAmount;
        uint256 votedYesPercentage;
    }

    struct VotingInst {
        uint256 claimIndex;
        bytes32 finalHash;
        string encryptedVote;
        address voter;
        uint256 voterReputation;
        uint256 suggestedAmount;
        uint256 stakedBMIAmount;
        bool accept;
        VoteStatus status;
    }

    struct MyClaimInfo {
        uint256 index;
        address policyBookAddress;
        string evidenceURI;
        bool appeal;
        uint256 claimAmount;
        IClaimingRegistry.ClaimStatus finalVerdict;
        uint256 finalClaimAmount;
        uint256 bmiCalculationReward;
    }

    struct PublicClaimInfo {
        uint256 claimIndex;
        address claimer;
        address policyBookAddress;
        string evidenceURI;
        bool appeal;
        uint256 claimAmount;
        uint256 time;
    }

    struct AllClaimInfo {
        PublicClaimInfo publicClaimInfo;
        IClaimingRegistry.ClaimStatus finalVerdict;
        uint256 finalClaimAmount;
        uint256 bmiCalculationReward;
    }

    struct MyVoteInfo {
        AllClaimInfo allClaimInfo;
        string encryptedVote;
        uint256 suggestedAmount;
        VoteStatus status;
        uint256 time;
    }

    struct VotesUpdatesInfo {
        uint256 bmiReward;
        uint256 stblReward;
        int256 reputationChange;
        int256 stakeChange;
    }

    function initializeVoting(
        address claimer,
        string calldata evidenceURI,
        uint256 coverTokens,
        bool appeal
    ) external;

    function canWithdraw(address user) external view returns (bool);

    function canVote(address user) external view returns (bool);

    function countVotes(address user) external view returns (uint256);

    function voteStatus(uint256 index) external view returns (VoteStatus);

    function whatCanIVoteFor(uint256 offset, uint256 limit)
        external
        returns (uint256 _claimsCount, PublicClaimInfo[] memory _votablesInfo);

    function allClaims(uint256 offset, uint256 limit)
        external
        view
        returns (AllClaimInfo[] memory _allClaimsInfo);

    function myClaims(uint256 offset, uint256 limit)
        external
        view
        returns (MyClaimInfo[] memory _myClaimsInfo);

    function myVotes(uint256 offset, uint256 limit)
        external
        view
        returns (MyVoteInfo[] memory _myVotesInfo);

    function myVotesUpdates(uint256 offset, uint256 limit)
        external
        view
        returns (
            uint256 _votesUpdatesCount,
            uint256[] memory _claimIndexes,
            VotesUpdatesInfo memory _myVotesUpdatesInfo
        );

    function anonymouslyVoteBatch(
        uint256[] calldata claimIndexes,
        bytes32[] calldata finalHashes,
        string[] calldata encryptedVotes
    ) external;

    function exposeVoteBatch(
        uint256[] calldata claimIndexes,
        uint256[] calldata suggestedClaimAmounts,
        bytes32[] calldata hashedSignaturesOfClaims
    ) external;

    function calculateVoterResultBatch(uint256[] calldata claimIndexes) external;

    function calculateVotingResultBatch(uint256[] calldata claimIndexes) external;
}// MIT
pragma solidity ^0.7.4;

interface ILiquidityMining {
    struct TeamDetails {
        string teamName;
        address referralLink;
        uint256 membersNumber;
        uint256 totalStakedAmount;
        uint256 totalReward;
    }

    struct UserInfo {
        address userAddr;
        string teamName;
        uint256 stakedAmount;
        uint256 mainNFT; // 0 or NFT index if available
        uint256 platinumNFT; // 0 or NFT index if available
    }

    struct UserRewardsInfo {
        string teamName;
        uint256 totalBMIReward; // total BMI reward
        uint256 availableBMIReward; // current claimable BMI reward
        uint256 incomingPeriods; // how many month are incoming
        uint256 timeToNextDistribution; // exact time left to next distribution
        uint256 claimedBMI; // actual number of claimed BMI
        uint256 mainNFTAvailability; // 0 or NFT index if available
        uint256 platinumNFTAvailability; // 0 or NFT index if available
        bool claimedNFTs; // true if user claimed NFTs
    }

    struct MyTeamInfo {
        TeamDetails teamDetails;
        uint256 myStakedAmount;
        uint256 teamPlace;
    }

    struct UserTeamInfo {
        address teamAddr;
        uint256 stakedAmount;
        uint256 countOfRewardedMonth;
        bool isNFTDistributed;
    }

    struct TeamInfo {
        string name;
        uint256 totalAmount;
        address[] teamLeaders;
    }

    function startLiquidityMiningTime() external view returns (uint256);

    function getTopTeams() external view returns (TeamDetails[] memory teams);

    function getTopUsers() external view returns (UserInfo[] memory users);

    function getAllTeamsLength() external view returns (uint256);

    function getAllTeamsDetails(uint256 _offset, uint256 _limit)
        external
        view
        returns (TeamDetails[] memory _teamDetailsArr);

    function getMyTeamsLength() external view returns (uint256);

    function getMyTeamMembers(uint256 _offset, uint256 _limit)
        external
        view
        returns (address[] memory _teamMembers, uint256[] memory _memberStakedAmount);

    function getAllUsersLength() external view returns (uint256);

    function getAllUsersInfo(uint256 _offset, uint256 _limit)
        external
        view
        returns (UserInfo[] memory _userInfos);

    function getMyTeamInfo() external view returns (MyTeamInfo memory _myTeamInfo);

    function getRewardsInfo(address user)
        external
        view
        returns (UserRewardsInfo memory userRewardInfo);

    function createTeam(string calldata _teamName) external;

    function deleteTeam() external;

    function joinTheTeam(address _referralLink) external;

    function getSlashingPercentage() external view returns (uint256);

    function investSTBL(uint256 _tokensAmount, address _policyBookAddr) external;

    function distributeNFT() external;

    function checkPlatinumNFTReward(address _userAddr) external view returns (uint256);

    function checkMainNFTReward(address _userAddr) external view returns (uint256);

    function distributeBMIReward() external;

    function getTotalUserBMIReward(address _userAddr) external view returns (uint256);

    function checkAvailableBMIReward(address _userAddr) external view returns (uint256);

    function isLMLasting() external view returns (bool);

    function isLMEnded() external view returns (bool);

    function getEndLMTime() external view returns (uint256);
}// MIT
pragma solidity ^0.7.4;

interface IPolicyQuote {
    function getQuotePredefined(
        uint256 _durationSeconds,
        uint256 _tokens,
        uint256 _totalCoverTokens,
        uint256 _totalLiquidity,
        uint256 _totalLeveragedLiquidity,
        bool _safePricingModel
    ) external view returns (uint256, uint256);

    function getQuote(
        uint256 _durationSeconds,
        uint256 _tokens,
        address _policyBookAddr
    ) external view returns (uint256);

    function setupPricingModel(
        uint256 _riskyAssetThresholdPercentage,
        uint256 _minimumCostPercentage,
        uint256 _minimumInsuranceCost,
        uint256 _lowRiskMaxPercentPremiumCost,
        uint256 _lowRiskMaxPercentPremiumCost100Utilization,
        uint256 _highRiskMaxPercentPremiumCost,
        uint256 _highRiskMaxPercentPremiumCost100Utilization
    ) external;

    function getMINUR(bool _safePricingModel) external view returns (uint256 _minUR);
}// MIT
pragma solidity ^0.7.4;

interface IRewardsGenerator {
    struct PolicyBookRewardInfo {
        uint256 rewardMultiplier; // includes 5 decimal places
        uint256 totalStaked;
        uint256 lastUpdateBlock;
        uint256 lastCumulativeSum; // includes 100 percentage
        uint256 cumulativeReward; // includes 100 percentage
    }

    struct StakeRewardInfo {
        uint256 lastCumulativeSum; // includes 100 percentage
        uint256 cumulativeReward;
        uint256 stakeAmount;
    }

    function updatePolicyBookShare(uint256 newRewardMultiplier) external;

    function aggregate(
        address policyBookAddress,
        uint256[] calldata nftIndexes,
        uint256 nftIndexTo
    ) external;

    function migrationStake(
        address policyBookAddress,
        uint256 nftIndex,
        uint256 amount,
        uint256 currentReward
    ) external;

    function stake(
        address policyBookAddress,
        uint256 nftIndex,
        uint256 amount
    ) external;

    function getPolicyBookAPY(address policyBookAddress) external view returns (uint256);

    function getPolicyBookRewardMultiplier(address policyBookAddress)
        external
        view
        returns (uint256);

    function getPolicyBookRewardPerBlock(address policyBookAddress)
        external
        view
        returns (uint256);

    function getStakedPolicyBookSTBL(address policyBookAddress) external view returns (uint256);

    function getStakedNFTSTBL(uint256 nftIndex) external view returns (uint256);

    function getReward(address policyBookAddress, uint256 nftIndex)
        external
        view
        returns (uint256);

    function withdrawFunds(address policyBookAddress, uint256 nftIndex) external returns (uint256);

    function withdrawReward(address policyBookAddress, uint256 nftIndex)
        external
        returns (uint256);
}// MIT
pragma solidity ^0.7.4;

interface ILiquidityRegistry {
    struct LiquidityInfo {
        address policyBookAddr;
        uint256 lockedAmount;
        uint256 availableAmount;
        uint256 bmiXRatio; // multiply availableAmount by this num to get stable coin
    }

    struct WithdrawalRequestInfo {
        address policyBookAddr;
        uint256 requestAmount;
        uint256 requestSTBLAmount;
        uint256 availableLiquidity;
        uint256 readyToWithdrawDate;
        uint256 endWithdrawDate;
    }

    struct WithdrawalSetInfo {
        address policyBookAddr;
        uint256 requestAmount;
        uint256 requestSTBLAmount;
        uint256 availableSTBLAmount;
    }

    function tryToAddPolicyBook(address _userAddr, address _policyBookAddr) external;

    function tryToRemovePolicyBook(address _userAddr, address _policyBookAddr) external;

    function getPolicyBooksArrLength(address _userAddr) external view returns (uint256);

    function getPolicyBooksArr(address _userAddr)
        external
        view
        returns (address[] memory _resultArr);

    function getLiquidityInfos(
        address _userAddr,
        uint256 _offset,
        uint256 _limit
    ) external view returns (LiquidityInfo[] memory _resultArr);

    function getWithdrawalRequests(
        address _userAddr,
        uint256 _offset,
        uint256 _limit
    ) external view returns (uint256 _arrLength, WithdrawalRequestInfo[] memory _resultArr);

    function getWithdrawalSet(
        address _userAddr,
        uint256 _offset,
        uint256 _limit
    ) external view returns (uint256 _arrLength, WithdrawalSetInfo[] memory _resultArr);

    function registerWithdrawl(address _policyBook, address _users) external;

    function getAllPendingWithdrawalRequestsAmount()
        external
        returns (uint256 _totalWithdrawlAmount);
}// MIT
pragma solidity ^0.7.4;

interface INFTStaking {
    function lockNFT(uint256 _nftId) external;

    function unlockNFT(uint256 _nftId) external;

    function getUserReductionMultiplier(address _user) external view returns (uint256);

    function enabledlockingNFTs() external view returns (bool);

    function enableLockingNFTs(bool _enabledlockingNFTs) external;
}// MIT
pragma solidity ^0.7.4;


abstract contract AbstractDependant {
    bytes32 private constant _INJECTOR_SLOT =
        0xd6b8f2e074594ceb05d47c27386969754b6ad0c15e5eb8f691399cd0be980e76;

    modifier onlyInjectorOrZero() {
        address _injector = injector();

        require(_injector == address(0) || _injector == msg.sender, "Dependant: Not an injector");
        _;
    }

    function setInjector(address _injector) external onlyInjectorOrZero {
        bytes32 slot = _INJECTOR_SLOT;

        assembly {
            sstore(slot, _injector)
        }
    }

    function setDependencies(IContractsRegistry) external virtual;

    function injector() public view returns (address _injector) {
        bytes32 slot = _INJECTOR_SLOT;

        assembly {
            _injector := sload(slot)
        }
    }
}// MIT
pragma solidity ^0.7.4;







contract PolicyBook is IPolicyBook, ERC20PermitUpgradeable, AbstractDependant {
    using SafeERC20 for ERC20;
    using SafeMath for uint256;
    using Math for uint256;

    uint256 public constant MINUMUM_COVERAGE = 100 * DECIMALS18; // 100 STBL
    uint256 public constant ANNUAL_COVERAGE_TOKENS = MINUMUM_COVERAGE * 10; // 1000 STBL

    uint256 public constant RISKY_UTILIZATION_RATIO = 80 * PRECISION;
    uint256 public constant MODERATE_UTILIZATION_RATIO = 50 * PRECISION;

    uint256 public constant PREMIUM_DISTRIBUTION_EPOCH = 1 days;
    uint256 public constant MAX_PREMIUM_DISTRIBUTION_EPOCHS = 90;

    uint256 public constant MINIMUM_REWARD = 15 * PRECISION; // 0.15
    uint256 public constant MAXIMUM_REWARD = 2 * PERCENTAGE_100; // 2.0
    uint256 public constant BASE_REWARD = PERCENTAGE_100; // 1.0

    uint256 public constant override EPOCH_DURATION = 1 weeks;
    uint256 public constant MAXIMUM_EPOCHS = SECONDS_IN_THE_YEAR / EPOCH_DURATION;
    uint256 public constant VIRTUAL_EPOCHS = 2;

    uint256 public constant WITHDRAWAL_PERIOD = 8 days;
    uint256 public constant override READY_TO_WITHDRAW_PERIOD = 2 days;

    bool public override whitelisted;

    uint256 public override epochStartTime;
    uint256 public lastDistributionEpoch;

    uint256 public lastPremiumDistributionEpoch;
    int256 public lastPremiumDistributionAmount;

    address public override insuranceContractAddress;
    IPolicyBookFabric.ContractType public override contractType;

    ERC20 public stblToken;
    IPolicyRegistry public policyRegistry;
    IBMICoverStaking public bmiCoverStaking;
    IRewardsGenerator public rewardsGenerator;
    ILiquidityMining public liquidityMining;
    IClaimVoting public claimVoting;
    IClaimingRegistry public claimingRegistry;
    ILiquidityRegistry public liquidityRegistry;
    address public reinsurancePoolAddress;
    IPolicyQuote public policyQuote;
    address public policyBookAdmin;
    address public policyBookRegistry;
    address public policyBookFabricAddress;

    uint256 public override totalLiquidity;
    uint256 public override totalCoverTokens;

    mapping(address => WithdrawalInfo) public override withdrawalsInfo;
    mapping(address => PolicyHolder) public override policyHolders;
    mapping(address => uint256) public liquidityFromLM;
    mapping(uint256 => uint256) public epochAmounts;
    mapping(uint256 => int256) public premiumDistributionDeltas;

    uint256 public override stblDecimals;

    INFTStaking public nftStaking;
    IBMICoverStakingView public bmiCoverStakingView;
    ICapitalPool public capitalPool;
    IPolicyBookFacade public override policyBookFacade;

    event LiquidityAdded(
        address _liquidityHolder,
        uint256 _liquidityAmount,
        uint256 _newTotalLiquidity
    );
    event WithdrawalRequested(
        address _liquidityHolder,
        uint256 _tokensToWithdraw,
        uint256 _readyToWithdrawDate
    );
    event LiquidityWithdrawn(
        address _liquidityHolder,
        uint256 _tokensToWithdraw,
        uint256 _newTotalLiquidity
    );
    event PolicyBought(
        address _policyHolder,
        uint256 _coverTokens,
        uint256 _price,
        uint256 _newTotalCoverTokens,
        address _distributor
    );
    event CoverageChanged(uint256 _newTotalCoverTokens);

    modifier onlyClaimVoting() {
        require(_msgSender() == address(claimVoting), "PB: Not a CV");
        _;
    }

    modifier onlyPolicyBookFacade() {
        require(_msgSender() == address(policyBookFacade), "PB: Not a PBFc");
        _;
    }

    modifier onlyPolicyBookFabric() {
        require(_msgSender() == policyBookFabricAddress, "PB: Not PBF");
        _;
    }

    modifier onlyPolicyBookAdmin() {
        require(_msgSender() == policyBookAdmin, "PB: Not a PBA");
        _;
    }

    modifier onlyLiquidityAdders() {
        require(
            _msgSender() == address(liquidityMining) ||
                _msgSender() == policyBookFabricAddress ||
                _msgSender() == address(policyBookFacade),
            "PB: Not allowed"
        );
        _;
    }

    modifier updateBMICoverStakingReward() {
        _;
        forceUpdateBMICoverStakingRewardMultiplier();
    }

    modifier withPremiumsDistribution() {
        _distributePremiums();
        _;
    }

    function _distributePremiums() internal {
        uint256 lastEpoch = lastPremiumDistributionEpoch;
        uint256 currentEpoch = _getPremiumDistributionEpoch();

        if (currentEpoch > lastEpoch) {
            (
                lastPremiumDistributionAmount,
                lastPremiumDistributionEpoch,
                totalLiquidity
            ) = _getPremiumsDistribution(lastEpoch, currentEpoch);
        }
    }

    function __PolicyBook_init(
        address _insuranceContract,
        IPolicyBookFabric.ContractType _contractType,
        string calldata _description,
        string calldata _projectSymbol
    ) external override initializer {
        string memory fullSymbol = string(abi.encodePacked("bmiV2", _projectSymbol, "Cover"));
        __ERC20Permit_init(fullSymbol);
        __ERC20_init(_description, fullSymbol);

        insuranceContractAddress = _insuranceContract;
        contractType = _contractType;

        epochStartTime = block.timestamp;
        lastDistributionEpoch = 1;

        lastPremiumDistributionEpoch = _getPremiumDistributionEpoch();
    }

    function setPolicyBookFacade(address _policyBookFacade)
        external
        override
        onlyPolicyBookFabric
    {
        policyBookFacade = IPolicyBookFacade(_policyBookFacade);
    }

    function setDependencies(IContractsRegistry _contractsRegistry)
        external
        override
        onlyInjectorOrZero
    {
        stblToken = ERC20(_contractsRegistry.getUSDTContract());
        bmiCoverStaking = IBMICoverStaking(_contractsRegistry.getBMICoverStakingContract());
        bmiCoverStakingView = IBMICoverStakingView(
            _contractsRegistry.getBMICoverStakingViewContract()
        );
        rewardsGenerator = IRewardsGenerator(_contractsRegistry.getRewardsGeneratorContract());
        liquidityMining = ILiquidityMining(_contractsRegistry.getLiquidityMiningContract());
        claimVoting = IClaimVoting(_contractsRegistry.getClaimVotingContract());
        policyRegistry = IPolicyRegistry(_contractsRegistry.getPolicyRegistryContract());
        reinsurancePoolAddress = _contractsRegistry.getReinsurancePoolContract();
        capitalPool = ICapitalPool(_contractsRegistry.getCapitalPoolContract());
        policyQuote = IPolicyQuote(_contractsRegistry.getPolicyQuoteContract());
        claimingRegistry = IClaimingRegistry(_contractsRegistry.getClaimingRegistryContract());
        liquidityRegistry = ILiquidityRegistry(_contractsRegistry.getLiquidityRegistryContract());
        policyBookAdmin = _contractsRegistry.getPolicyBookAdminContract();
        policyBookRegistry = _contractsRegistry.getPolicyBookRegistryContract();
        policyBookFabricAddress = _contractsRegistry.getPolicyBookFabricContract();
        nftStaking = INFTStaking(_contractsRegistry.getNFTStakingContract());
        stblDecimals = stblToken.decimals();
    }

    function whitelist(bool _whitelisted)
        external
        override
        onlyPolicyBookAdmin
        updateBMICoverStakingReward
    {
        whitelisted = _whitelisted;
    }

    function getEpoch(uint256 time) public view override returns (uint256) {
        return time.sub(epochStartTime).div(EPOCH_DURATION) + 1;
    }

    function _getPremiumDistributionEpoch() internal view returns (uint256) {
        return block.timestamp / PREMIUM_DISTRIBUTION_EPOCH;
    }

    function _getSTBLToBMIXRatio(uint256 currentLiquidity) internal view returns (uint256) {
        uint256 _currentTotalSupply = totalSupply();

        if (_currentTotalSupply == 0) {
            return PERCENTAGE_100;
        }

        return currentLiquidity.mul(PERCENTAGE_100).div(_currentTotalSupply);
    }

    function convertBMIXToSTBL(uint256 _amount) public view override returns (uint256) {
        (, uint256 currentLiquidity) = getNewCoverAndLiquidity();

        return _amount.mul(_getSTBLToBMIXRatio(currentLiquidity)).div(PERCENTAGE_100);
    }

    function convertSTBLToBMIX(uint256 _amount) public view override returns (uint256) {
        (, uint256 currentLiquidity) = getNewCoverAndLiquidity();

        return _amount.mul(PERCENTAGE_100).div(_getSTBLToBMIXRatio(currentLiquidity));
    }

    function _submitClaimAndInitializeVoting(string memory evidenceURI, bool appeal) internal {
        uint256 cover = policyHolders[_msgSender()].coverTokens;
        uint256 virtualEndEpochNumber =
            policyHolders[_msgSender()].endEpochNumber + VIRTUAL_EPOCHS;

        if (!appeal) {
            epochAmounts[virtualEndEpochNumber] = epochAmounts[virtualEndEpochNumber].sub(cover);
        } else {
            uint256 claimIndex = claimingRegistry.claimIndex(_msgSender(), address(this));
            uint256 endLockEpoch =
                Math.max(
                    getEpoch(claimingRegistry.claimEndTime(claimIndex)) + 1,
                    virtualEndEpochNumber
                );

            epochAmounts[endLockEpoch] = epochAmounts[endLockEpoch].sub(cover);
        }

        claimVoting.initializeVoting(_msgSender(), evidenceURI, cover, appeal);
    }

    function submitClaimAndInitializeVoting(string calldata evidenceURI) external override {
        _submitClaimAndInitializeVoting(evidenceURI, false);
    }

    function submitAppealAndInitializeVoting(string calldata evidenceURI) external override {
        _submitClaimAndInitializeVoting(evidenceURI, true);
    }

    function commitClaim(
        address claimer,
        uint256 claimAmount,
        uint256 claimEndTime,
        IClaimingRegistry.ClaimStatus status
    ) external override onlyClaimVoting withPremiumsDistribution updateBMICoverStakingReward {
        updateEpochsInfo();

        if (status == IClaimingRegistry.ClaimStatus.ACCEPTED) {
            uint256 newTotalCover = totalCoverTokens.sub(claimAmount);

            totalCoverTokens = newTotalCover;
            uint256 liquidity = totalLiquidity.sub(claimAmount);
            totalLiquidity = liquidity;

            capitalPool.fundClaim(
                claimer,
                DecimalsConverter.convertFrom18(claimAmount, stblDecimals)
            );

            emit LiquidityWithdrawn(claimer, claimAmount, liquidity);

            delete policyHolders[claimer];
            policyRegistry.removePolicy(claimer);
        } else if (status == IClaimingRegistry.ClaimStatus.REJECTED_CAN_APPEAL) {
            uint256 endUnlockEpoch =
                Math.max(
                    getEpoch(claimEndTime) + 1,
                    policyHolders[claimer].endEpochNumber + VIRTUAL_EPOCHS
                );

            epochAmounts[endUnlockEpoch] = epochAmounts[endUnlockEpoch].add(
                policyHolders[claimer].coverTokens
            );
        } else {
            uint256 virtualEndEpochNumber =
                policyHolders[claimer].endEpochNumber.add(VIRTUAL_EPOCHS);

            if (lastDistributionEpoch <= virtualEndEpochNumber) {
                epochAmounts[virtualEndEpochNumber] = epochAmounts[virtualEndEpochNumber].add(
                    policyHolders[claimer].coverTokens
                );
            } else {
                uint256 newTotalCover = totalCoverTokens.sub(claimAmount);
                totalCoverTokens = newTotalCover;

                emit CoverageChanged(newTotalCover);
            }
        }
    }

    function _getPremiumsDistribution(uint256 lastEpoch, uint256 currentEpoch)
        internal
        view
        returns (
            int256 currentDistribution,
            uint256 distributionEpoch,
            uint256 newTotalLiquidity
        )
    {
        currentDistribution = lastPremiumDistributionAmount;
        newTotalLiquidity = totalLiquidity;
        distributionEpoch = Math.min(
            currentEpoch,
            lastEpoch + MAX_PREMIUM_DISTRIBUTION_EPOCHS + 1
        );

        for (uint256 i = lastEpoch + 1; i <= distributionEpoch; i++) {
            currentDistribution += premiumDistributionDeltas[i];
            newTotalLiquidity = newTotalLiquidity.add(uint256(currentDistribution));
        }
    }

    function forceUpdateBMICoverStakingRewardMultiplier() public override {
        uint256 rewardMultiplier;

        if (whitelisted) {
            rewardMultiplier = MINIMUM_REWARD;
            uint256 liquidity = totalLiquidity;
            uint256 coverTokens = totalCoverTokens;

            if (coverTokens > 0 && liquidity > 0) {
                rewardMultiplier = BASE_REWARD;

                uint256 utilizationRatio = coverTokens.mul(PERCENTAGE_100).div(liquidity);

                if (utilizationRatio < MODERATE_UTILIZATION_RATIO) {
                    rewardMultiplier = Math
                        .max(utilizationRatio, PRECISION)
                        .sub(PRECISION)
                        .mul(BASE_REWARD.sub(MINIMUM_REWARD))
                        .div(MODERATE_UTILIZATION_RATIO)
                        .add(MINIMUM_REWARD);
                } else if (utilizationRatio > RISKY_UTILIZATION_RATIO) {
                    rewardMultiplier = MAXIMUM_REWARD
                        .sub(BASE_REWARD)
                        .mul(utilizationRatio.sub(RISKY_UTILIZATION_RATIO))
                        .div(PERCENTAGE_100.sub(RISKY_UTILIZATION_RATIO))
                        .add(BASE_REWARD);
                }
            }
        }

        rewardsGenerator.updatePolicyBookShare(rewardMultiplier.div(10**22)); // 5 decimal places or zero
    }

    function getNewCoverAndLiquidity()
        public
        view
        override
        returns (uint256 newTotalCoverTokens, uint256 newTotalLiquidity)
    {
        newTotalLiquidity = totalLiquidity;
        newTotalCoverTokens = totalCoverTokens;

        uint256 lastEpoch = lastPremiumDistributionEpoch;
        uint256 currentEpoch = _getPremiumDistributionEpoch();

        if (currentEpoch > lastEpoch) {
            (, , newTotalLiquidity) = _getPremiumsDistribution(lastEpoch, currentEpoch);
        }

        uint256 newDistributionEpoch = Math.min(getEpoch(block.timestamp), MAXIMUM_EPOCHS);

        for (uint256 i = lastDistributionEpoch; i < newDistributionEpoch; i++) {
            newTotalCoverTokens = newTotalCoverTokens.sub(epochAmounts[i]);
        }
    }

    function getPolicyPrice(
        uint256 _epochsNumber,
        uint256 _coverTokens,
        address _holder
    )
        public
        view
        override
        returns (
            uint256 totalSeconds,
            uint256 totalPrice,
            uint256 pricePercentage
        )
    {
        require(_coverTokens >= MINUMUM_COVERAGE, "PB: Wrong cover");
        require(_epochsNumber > 0 && _epochsNumber <= MAXIMUM_EPOCHS, "PB: Wrong epoch duration");

        (uint256 newTotalCoverTokens, uint256 newTotalLiquidity) = getNewCoverAndLiquidity();

        totalSeconds = secondsToEndCurrentEpoch().add(_epochsNumber.sub(1).mul(EPOCH_DURATION));
        (totalPrice, pricePercentage) = policyQuote.getQuotePredefined(
            totalSeconds,
            _coverTokens,
            newTotalCoverTokens,
            newTotalLiquidity,
            policyBookFacade.totalLeveragedLiquidity(),
            policyBookFacade.safePricingModel()
        );

        uint256 _reductionMultiplier = nftStaking.getUserReductionMultiplier(_holder);
        if (_reductionMultiplier > 0) {
            totalPrice = totalPrice.sub(totalPrice.mul(_reductionMultiplier).div(PERCENTAGE_100));
        }
    }

    function buyPolicy(
        address _buyer,
        address _holder,
        uint256 _epochsNumber,
        uint256 _coverTokens,
        uint256 _distributorFee,
        address _distributor
    ) external override returns (uint256, uint256) {
        return
            _buyPolicy(
                BuyPolicyParameters(
                    _buyer,
                    _holder,
                    _epochsNumber,
                    _coverTokens,
                    _distributorFee,
                    _distributor
                )
            );
    }

    function _buyPolicy(BuyPolicyParameters memory parameters)
        internal
        onlyPolicyBookFacade
        withPremiumsDistribution
        updateBMICoverStakingReward
        returns (uint256, uint256)
    {
        require(
            !policyRegistry.isPolicyActive(parameters.holder, address(this)),
            "PB: The holder already exists"
        );
        require(
            claimingRegistry.canBuyNewPolicy(parameters.holder, address(this)),
            "PB: Claim is pending"
        );

        updateEpochsInfo();

        uint256 _totalCoverTokens = totalCoverTokens.add(parameters.coverTokens);

        require(totalLiquidity >= _totalCoverTokens, "PB: Not enough liquidity");

        (uint256 _totalSeconds, uint256 _totalPrice, uint256 pricePercentage) =
            getPolicyPrice(parameters.epochsNumber, parameters.coverTokens, parameters.holder);


        uint256 _distributorFeeAmount;
        if (parameters.distributorFee > 0) {
            _distributorFeeAmount = _totalPrice.mul(parameters.distributorFee).div(PERCENTAGE_100);
        }

        uint256 _reinsurancePrice =
            _totalPrice.mul(PROTOCOL_PERCENTAGE).div(PERCENTAGE_100).sub(_distributorFeeAmount);

        uint256 _price = _totalPrice.sub(_distributorFeeAmount);

        _addPolicyHolder(parameters, _totalPrice, _reinsurancePrice);

        totalCoverTokens = _totalCoverTokens;

        if (_distributorFeeAmount > 0) {
            stblToken.safeTransferFrom(
                parameters.buyer,
                parameters.distributor,
                DecimalsConverter.convertFrom18(_distributorFeeAmount, stblDecimals)
            );
        }
        stblToken.safeTransferFrom(
            parameters.buyer,
            address(capitalPool),
            DecimalsConverter.convertFrom18(_price, stblDecimals)
        );
        _price = capitalPool.addPolicyHoldersHardSTBL(
            DecimalsConverter.convertFrom18(_price, stblDecimals),
            parameters.epochsNumber,
            DecimalsConverter.convertFrom18(_reinsurancePrice, stblDecimals)
        );

        _addPolicyPremiumToDistributions(
            _totalSeconds.add(VIRTUAL_EPOCHS * EPOCH_DURATION),
            _price
        );

        policyRegistry.addPolicy(parameters.holder, parameters.coverTokens, _price, _totalSeconds);

        emit PolicyBought(
            parameters.holder,
            parameters.coverTokens,
            _totalPrice,
            _totalCoverTokens,
            parameters.distributor
        );

        return (_price, pricePercentage);
    }

    function _addPolicyHolder(
        BuyPolicyParameters memory parameters,
        uint256 _totalPrice,
        uint256 _reinsurancePrice
    ) internal {
        uint256 _currentEpochNumber = getEpoch(block.timestamp);
        uint256 _endEpochNumber = _currentEpochNumber.add(parameters.epochsNumber.sub(1));
        uint256 _virtualEndEpochNumber = _endEpochNumber + VIRTUAL_EPOCHS;

        policyHolders[parameters.holder] = PolicyHolder(
            parameters.coverTokens,
            _currentEpochNumber,
            _endEpochNumber,
            _totalPrice,
            _reinsurancePrice
        );

        epochAmounts[_virtualEndEpochNumber] = epochAmounts[_virtualEndEpochNumber].add(
            parameters.coverTokens
        );
    }

    function _addPolicyPremiumToDistributions(uint256 _totalSeconds, uint256 _distributedAmount)
        internal
    {
        uint256 distributionEpochs = _totalSeconds.add(1).div(PREMIUM_DISTRIBUTION_EPOCH).max(1);

        int256 distributedPerEpoch = int256(_distributedAmount.div(distributionEpochs));
        uint256 nextEpoch = _getPremiumDistributionEpoch() + 1;

        premiumDistributionDeltas[nextEpoch] += distributedPerEpoch;
        premiumDistributionDeltas[nextEpoch + distributionEpochs] -= distributedPerEpoch;
    }

    function updateEpochsInfo() public override {
        uint256 _lastDistributionEpoch = lastDistributionEpoch;
        uint256 _newDistributionEpoch =
            Math.min(getEpoch(block.timestamp), _lastDistributionEpoch + MAXIMUM_EPOCHS);

        if (_lastDistributionEpoch < _newDistributionEpoch) {
            uint256 _newTotalCoverTokens = totalCoverTokens;

            for (uint256 i = _lastDistributionEpoch; i < _newDistributionEpoch; i++) {
                _newTotalCoverTokens = _newTotalCoverTokens.sub(epochAmounts[i]);
                delete epochAmounts[i];
            }

            lastDistributionEpoch = _newDistributionEpoch;
            totalCoverTokens = _newTotalCoverTokens;

            emit CoverageChanged(_newTotalCoverTokens);
        }
    }

    function secondsToEndCurrentEpoch() public view override returns (uint256) {
        uint256 epochNumber = block.timestamp.sub(epochStartTime).div(EPOCH_DURATION) + 1;

        return epochNumber.mul(EPOCH_DURATION).sub(block.timestamp.sub(epochStartTime));
    }

    function addLiquidityFor(address _liquidityHolderAddr, uint256 _liquidityAmount)
        external
        override
    {
        addLiquidity(_liquidityHolderAddr, _liquidityHolderAddr, _liquidityAmount, 0);
    }

    function addLiquidity(
        address _liquidityBuyerAddr,
        address _liquidityHolderAddr,
        uint256 _liquidityAmount,
        uint256 _stakeSTBLAmount
    ) public override onlyLiquidityAdders withPremiumsDistribution updateBMICoverStakingReward {
        if (_stakeSTBLAmount > 0) {
            require(_stakeSTBLAmount <= _liquidityAmount, "PB: Wrong staking amount");
        }
        uint256 stblLiquidity = DecimalsConverter.convertFrom18(_liquidityAmount, stblDecimals);
        require(stblLiquidity > 0, "PB: Liquidity amount is zero");

        updateEpochsInfo();

        if (_msgSender() != policyBookFabricAddress) {
            stblToken.safeTransferFrom(_liquidityBuyerAddr, address(capitalPool), stblLiquidity);
        }
        capitalPool.addCoverageProvidersHardSTBL(stblLiquidity);

        if (_msgSender() == address(liquidityMining)) {
            liquidityFromLM[_liquidityHolderAddr] = liquidityFromLM[_liquidityHolderAddr].add(
                _liquidityAmount
            );
        }

        _mint(_liquidityHolderAddr, convertSTBLToBMIX(_liquidityAmount));
        uint256 liquidity = totalLiquidity.add(_liquidityAmount);
        totalLiquidity = liquidity;

        liquidityRegistry.tryToAddPolicyBook(_liquidityHolderAddr, address(this));
        if (_stakeSTBLAmount > 0) {
            bmiCoverStaking.stakeBMIXFrom(
                _liquidityHolderAddr,
                convertSTBLToBMIX(_stakeSTBLAmount)
            );
        }

        emit LiquidityAdded(_liquidityHolderAddr, _liquidityAmount, liquidity);
    }

    function getAvailableBMIXWithdrawableAmount(address _userAddr)
        external
        view
        override
        returns (uint256)
    {
        (uint256 newTotalCoverTokens, uint256 newTotalLiquidity) = getNewCoverAndLiquidity();

        return
            convertSTBLToBMIX(
                Math.min(
                    newTotalLiquidity.sub(newTotalCoverTokens),
                    _getUserAvailableSTBL(_userAddr)
                )
            );
    }

    function _getUserAvailableSTBL(address _userAddr) internal view returns (uint256) {
        uint256 availableSTBL =
            convertBMIXToSTBL(
                balanceOf(_userAddr).add(withdrawalsInfo[_userAddr].withdrawalAmount)
            );

        if (block.timestamp < liquidityMining.getEndLMTime()) {
            uint256 lmLiquidity = liquidityFromLM[_userAddr];

            availableSTBL = availableSTBL <= lmLiquidity ? 0 : availableSTBL - lmLiquidity;
        }

        return availableSTBL;
    }

    function getWithdrawalStatus(address _userAddr)
        public
        view
        override
        returns (WithdrawalStatus)
    {
        uint256 readyToWithdrawDate = withdrawalsInfo[_userAddr].readyToWithdrawDate;

        if (readyToWithdrawDate == 0) {
            return WithdrawalStatus.NONE;
        }

        if (block.timestamp < readyToWithdrawDate) {
            return WithdrawalStatus.PENDING;
        }

        if (
            block.timestamp >= readyToWithdrawDate.add(READY_TO_WITHDRAW_PERIOD) &&
            !withdrawalsInfo[_userAddr].withdrawalAllowed
        ) {
            return WithdrawalStatus.EXPIRED;
        }

        return WithdrawalStatus.READY;
    }

    function requestWithdrawal(uint256 _tokensToWithdraw, address _user)
        external
        override
        onlyPolicyBookFacade
        withPremiumsDistribution
    {
        require(_tokensToWithdraw > 0, "PB: Amount is zero");

        uint256 _stblTokensToWithdraw = convertBMIXToSTBL(_tokensToWithdraw);
        uint256 _availableSTBLBalance = _getUserAvailableSTBL(_user);

        require(_availableSTBLBalance >= _stblTokensToWithdraw, "PB: Wrong announced amount");

        updateEpochsInfo();

        require(
            totalLiquidity >= totalCoverTokens.add(_stblTokensToWithdraw),
            "PB: Not enough free liquidity"
        );

        _lockTokens(_user, _tokensToWithdraw);

        uint256 _readyToWithdrawDate = block.timestamp.add(WITHDRAWAL_PERIOD);

        withdrawalsInfo[_user] = WithdrawalInfo(_tokensToWithdraw, _readyToWithdrawDate, false);

        emit WithdrawalRequested(_user, _tokensToWithdraw, _readyToWithdrawDate);
    }

    function _lockTokens(address _userAddr, uint256 _neededTokensToLock) internal {
        uint256 _currentLockedTokens = withdrawalsInfo[_userAddr].withdrawalAmount;

        if (_currentLockedTokens > _neededTokensToLock) {
            this.transfer(_userAddr, _currentLockedTokens - _neededTokensToLock);
        } else if (_currentLockedTokens < _neededTokensToLock) {
            this.transferFrom(
                _userAddr,
                address(this),
                _neededTokensToLock - _currentLockedTokens
            );
        }
    }

    function unlockTokens() external override {
        uint256 _lockedAmount = withdrawalsInfo[_msgSender()].withdrawalAmount;

        require(_lockedAmount > 0, "PB: Amount is zero");

        this.transfer(_msgSender(), _lockedAmount);
        delete withdrawalsInfo[_msgSender()];
    }

    function withdrawLiquidity(address sender)
        external
        override
        onlyPolicyBookFacade
        withPremiumsDistribution
        updateBMICoverStakingReward
        returns (uint256)
    {
        require(
            getWithdrawalStatus(sender) == WithdrawalStatus.READY,
            "PB: Withdrawal is not ready"
        );

        updateEpochsInfo();

        uint256 liquidity = totalLiquidity;
        uint256 _currentWithdrawalAmount = withdrawalsInfo[sender].withdrawalAmount;
        uint256 _tokensToWithdraw =
            Math.min(_currentWithdrawalAmount, convertSTBLToBMIX(liquidity.sub(totalCoverTokens)));

        uint256 _stblTokensToWithdraw = convertBMIXToSTBL(_tokensToWithdraw);
        capitalPool.withdrawLiquidity(
            sender,
            DecimalsConverter.convertFrom18(_stblTokensToWithdraw, stblDecimals),
            false
        );

        _burn(address(this), _tokensToWithdraw);
        liquidity = liquidity.sub(_stblTokensToWithdraw);

        _currentWithdrawalAmount = _currentWithdrawalAmount.sub(_tokensToWithdraw);

        if (_currentWithdrawalAmount == 0) {
            delete withdrawalsInfo[sender];
            liquidityRegistry.tryToRemovePolicyBook(sender, address(this));
        } else {
            withdrawalsInfo[sender].withdrawalAllowed = true;
            withdrawalsInfo[sender].withdrawalAmount = _currentWithdrawalAmount;
        }

        totalLiquidity = liquidity;

        emit LiquidityWithdrawn(sender, _stblTokensToWithdraw, liquidity);

        return _tokensToWithdraw;
    }

    function getAPY() public view override returns (uint256) {
        uint256 lastEpoch = lastPremiumDistributionEpoch;
        uint256 currentEpoch = _getPremiumDistributionEpoch();
        int256 premiumDistributionAmount = lastPremiumDistributionAmount;

        if (currentEpoch > lastEpoch) {
            (premiumDistributionAmount, currentEpoch, ) = _getPremiumsDistribution(
                lastEpoch,
                currentEpoch
            );
        }

        premiumDistributionAmount += premiumDistributionDeltas[currentEpoch + 1];

        return
            uint256(premiumDistributionAmount).mul(365).mul(10**7).div(
                convertBMIXToSTBL(totalSupply()).add(APY_TOKENS)
            );
    }

    function userStats(address _user) external view override returns (PolicyHolder memory) {
        return policyHolders[_user];
    }

    function numberStats()
        external
        view
        override
        returns (
            uint256 _maxCapacities,
            uint256 _totalSTBLLiquidity,
            uint256 _totalLeveragedLiquidity,
            uint256 _stakedSTBL,
            uint256 _annualProfitYields,
            uint256 _annualInsuranceCost,
            uint256 _bmiXRatio
        )
    {
        uint256 newTotalCoverTokens;

        (newTotalCoverTokens, _totalSTBLLiquidity) = getNewCoverAndLiquidity();
        _maxCapacities = _totalSTBLLiquidity - newTotalCoverTokens;

        _stakedSTBL = rewardsGenerator.getStakedPolicyBookSTBL(address(this));
        _annualProfitYields = getAPY().add(bmiCoverStakingView.getPolicyBookAPY(address(this)));

        uint256 possibleCoverage = Math.min(ANNUAL_COVERAGE_TOKENS, _maxCapacities);
        _totalLeveragedLiquidity = policyBookFacade.totalLeveragedLiquidity();

        if (possibleCoverage >= MINUMUM_COVERAGE) {
            (_annualInsuranceCost, ) = policyQuote.getQuotePredefined(
                SECONDS_IN_THE_YEAR,
                possibleCoverage,
                newTotalCoverTokens,
                _totalSTBLLiquidity,
                _totalLeveragedLiquidity,
                policyBookFacade.safePricingModel()
            );

            _annualInsuranceCost = _annualInsuranceCost
                .mul(ANNUAL_COVERAGE_TOKENS.mul(PRECISION).div(possibleCoverage))
                .div(PRECISION)
                .div(10);
        }

        _bmiXRatio = convertBMIXToSTBL(10**18);
    }

    function info()
        external
        view
        override
        returns (
            string memory _symbol,
            address _insuredContract,
            IPolicyBookFabric.ContractType _contractType,
            bool _whitelisted
        )
    {
        return (symbol(), insuranceContractAddress, contractType, whitelisted);
    }
}