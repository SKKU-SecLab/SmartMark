
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


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;

interface IERC20Permit {

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;


    function nonces(address owner) external view returns (uint256);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

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

library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        bytes32 r;
        bytes32 s;
        uint8 v;

        if (signature.length == 65) {
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
        } else if (signature.length == 64) {
            assembly {
                let vs := mload(add(signature, 0x40))
                r := mload(add(signature, 0x20))
                s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
                v := add(shr(255, vs), 27)
            }
        } else {
            revert("ECDSA: invalid signature length");
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

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}// MIT

pragma solidity 0.8.3;


contract Governed is Context, Initializable {

    address public governor;
    address private proposedGovernor;

    event UpdatedGovernor(address indexed previousGovernor, address indexed proposedGovernor);

    constructor() {
        address msgSender = _msgSender();
        governor = msgSender;
        emit UpdatedGovernor(address(0), msgSender);
    }

    function _initializeGoverned() internal initializer {

        address msgSender = _msgSender();
        governor = msgSender;
        emit UpdatedGovernor(address(0), msgSender);
    }

    modifier onlyGovernor {

        require(governor == _msgSender(), "not-the-governor");
        _;
    }

    function transferGovernorship(address _proposedGovernor) external onlyGovernor {

        require(_proposedGovernor != address(0), "proposed-governor-is-zero");
        proposedGovernor = _proposedGovernor;
    }

    function acceptGovernorship() external {

        require(proposedGovernor == _msgSender(), "not-the-proposed-governor");
        emit UpdatedGovernor(governor, proposedGovernor);
        governor = proposedGovernor;
        proposedGovernor = address(0);
    }
}// MIT

pragma solidity 0.8.3;


contract Pausable is Context {

    event Paused(address account);
    event Shutdown(address account);
    event Unpaused(address account);
    event Open(address account);

    bool public paused;
    bool public stopEverything;

    modifier whenNotPaused() {

        require(!paused, "paused");
        _;
    }
    modifier whenPaused() {

        require(paused, "not-paused");
        _;
    }

    modifier whenNotShutdown() {

        require(!stopEverything, "shutdown");
        _;
    }

    modifier whenShutdown() {

        require(stopEverything, "not-shutdown");
        _;
    }

    function _pause() internal virtual whenNotPaused {

        paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused whenNotShutdown {

        paused = false;
        emit Unpaused(_msgSender());
    }

    function _shutdown() internal virtual whenNotShutdown {

        stopEverything = true;
        paused = true;
        emit Shutdown(_msgSender());
    }

    function _open() internal virtual whenShutdown {

        stopEverything = false;
        emit Open(_msgSender());
    }
}// MIT

pragma solidity 0.8.3;

interface IAddressList {

    function add(address a) external returns (bool);


    function remove(address a) external returns (bool);


    function get(address a) external view returns (uint256);


    function contains(address a) external view returns (bool);


    function length() external view returns (uint256);


    function grantRole(bytes32 role, address account) external;

}// MIT

pragma solidity 0.8.3;

interface IAddressListFactory {

    function ours(address a) external view returns (bool);


    function listCount() external view returns (uint256);


    function listAt(uint256 idx) external view returns (address);


    function createList() external returns (address listaddr);

}// MIT

pragma solidity 0.8.3;

interface IPoolAccountant {

    function decreaseDebt(address _strategy, uint256 _decreaseBy) external;


    function migrateStrategy(address _old, address _new) external;


    function reportEarning(
        address _strategy,
        uint256 _profit,
        uint256 _loss,
        uint256 _payback
    )
        external
        returns (
            uint256 _actualPayback,
            uint256 _creditLine,
            uint256 _interestFee
        );


    function reportLoss(address _strategy, uint256 _loss) external;


    function availableCreditLimit(address _strategy) external view returns (uint256);


    function excessDebt(address _strategy) external view returns (uint256);


    function getStrategies() external view returns (address[] memory);


    function getWithdrawQueue() external view returns (address[] memory);


    function strategy(address _strategy)
        external
        view
        returns (
            bool _active,
            uint256 _interestFee,
            uint256 _debtRate,
            uint256 _lastRebalance,
            uint256 _totalDebt,
            uint256 _totalLoss,
            uint256 _totalProfit,
            uint256 _debtRatio
        );


    function totalDebt() external view returns (uint256);


    function totalDebtOf(address _strategy) external view returns (uint256);


    function totalDebtRatio() external view returns (uint256);

}// MIT

pragma solidity 0.8.3;

interface IPoolRewards {

    event RewardAdded(uint256 reward);
    event RewardPaid(address indexed user, uint256 reward);

    function claimReward(address) external;


    function notifyRewardAmount(uint256 rewardAmount, uint256 endTime) external;


    function updateReward(address) external;


    function claimable(address) external view returns (uint256);


    function lastTimeRewardApplicable() external view returns (uint256);


    function rewardForDuration() external view returns (uint256);


    function rewardPerToken() external view returns (uint256);

}// MIT

pragma solidity 0.8.3;

interface IStrategy {

    function rebalance() external;


    function sweepERC20(address _fromToken) external;


    function withdraw(uint256 _amount) external;


    function feeCollector() external view returns (address);


    function isReservedToken(address _token) external view returns (bool);


    function migrate(address _newStrategy) external;


    function token() external view returns (address);


    function totalValue() external view returns (uint256);


    function totalValueCurrent() external returns (uint256);


    function pool() external view returns (address);

}// MIT
pragma solidity 0.8.3;

library Errors {

    string public constant INVALID_COLLATERAL_AMOUNT = "1"; // Collateral must be greater than 0
    string public constant INVALID_SHARE_AMOUNT = "2"; // Share must be greater than 0
    string public constant INVALID_INPUT_LENGTH = "3"; // Input array length must be greater than 0
    string public constant INPUT_LENGTH_MISMATCH = "4"; // Input array length mismatch with another array length
    string public constant NOT_WHITELISTED_ADDRESS = "5"; // Caller is not whitelisted to withdraw without fee
    string public constant MULTI_TRANSFER_FAILED = "6"; // Multi transfer of tokens has failed
    string public constant FEE_COLLECTOR_NOT_SET = "7"; // Fee Collector is not set
    string public constant NOT_ALLOWED_TO_SWEEP = "8"; // Token is not allowed to sweep
    string public constant INSUFFICIENT_BALANCE = "9"; // Insufficient balance to performs operations to follow
    string public constant INPUT_ADDRESS_IS_ZERO = "10"; // Input address is zero
    string public constant FEE_LIMIT_REACHED = "11"; // Fee must be less than MAX_BPS
    string public constant ALREADY_INITIALIZED = "12"; // Data structure, contract, or logic already initialized and can not be called again
    string public constant ADD_IN_LIST_FAILED = "13"; // Cannot add address in address list
    string public constant REMOVE_FROM_LIST_FAILED = "14"; // Cannot remove address from address list
    string public constant STRATEGY_IS_ACTIVE = "15"; // Strategy is already active, an inactive strategy is required
    string public constant STRATEGY_IS_NOT_ACTIVE = "16"; // Strategy is not active, an active strategy is required
    string public constant INVALID_STRATEGY = "17"; // Given strategy is not a strategy of this pool
    string public constant DEBT_RATIO_LIMIT_REACHED = "18"; // Debt ratio limit reached. It must be less than MAX_BPS
    string public constant TOTAL_DEBT_IS_NOT_ZERO = "19"; // Strategy total debt must be 0
    string public constant LOSS_TOO_HIGH = "20"; // Strategy reported loss must be less than current debt
}// MIT

pragma solidity 0.8.3;


abstract contract PoolERC20 is Context, IERC20, IERC20Metadata {
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
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

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
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;

        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
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

    function _setName(string memory name_) internal {
        _name = name_;
    }

    function _setSymbol(string memory symbol_) internal {
        _symbol = symbol_;
    }
}// MIT

pragma solidity 0.8.3;


abstract contract PoolERC20Permit is PoolERC20, IERC20Permit {
    bytes32 private constant _EIP712_VERSION = keccak256(bytes("1"));
    bytes32 private constant _EIP712_DOMAIN_TYPEHASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    bytes32 private constant _PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    bytes32 private _CACHED_DOMAIN_SEPARATOR;
    bytes32 private _HASHED_NAME;
    uint256 private _CACHED_CHAIN_ID;

    mapping(address => uint256) public override nonces;

    function _initializePermit(string memory name_) internal {
        _HASHED_NAME = keccak256(bytes(name_));
        _CACHED_CHAIN_ID = block.chainid;
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(_EIP712_DOMAIN_TYPEHASH, _HASHED_NAME, _EIP712_VERSION);
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
        uint256 _currentNonce = nonces[owner];
        bytes32 structHash = keccak256(abi.encode(_PERMIT_TYPEHASH, owner, spender, value, _currentNonce, deadline));
        bytes32 hash = keccak256(abi.encodePacked("\x19\x01", _domainSeparatorV4(), structHash));

        address signer = ECDSA.recover(hash, v, r, s);
        require(signer == owner, "ERC20Permit: invalid signature");
        nonces[owner] = _currentNonce + 1;
        _approve(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _domainSeparatorV4();
    }

    function _domainSeparatorV4() private view returns (bytes32) {
        if (block.chainid == _CACHED_CHAIN_ID) {
            return _CACHED_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(_EIP712_DOMAIN_TYPEHASH, _HASHED_NAME, _EIP712_VERSION);
        }
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 name,
        bytes32 version
    ) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, name, version, block.chainid, address(this)));
    }
}// MIT

pragma solidity 0.8.3;


contract PoolStorageV1 {

    IERC20 public token; // Collateral token

    address public poolAccountant; // PoolAccountant address
    address public poolRewards; // PoolRewards contract address
    address public feeWhitelist; // sol-address-list address which contains whitelisted addresses to withdraw without fee
    address public keepers; // sol-address-list address which contains addresses of keepers
    address public maintainers; // sol-address-list address which contains addresses of maintainers
    address public feeCollector; // Fee collector address
    uint256 public withdrawFee; // Withdraw fee for this pool
    uint256 public decimalConversionFactor; // It can be used in converting value to/from 18 decimals
    bool internal withdrawInETH; // This flag will be used by VETH pool as switch to withdraw ETH or WETH
}// MIT

pragma solidity 0.8.3;


abstract contract PoolShareToken is Initializable, PoolERC20Permit, Governed, Pausable, ReentrancyGuard, PoolStorageV1 {
    using SafeERC20 for IERC20;
    uint256 public constant MAX_BPS = 10_000;

    event Deposit(address indexed owner, uint256 shares, uint256 amount);
    event Withdraw(address indexed owner, uint256 shares, uint256 amount);

    constructor(
        string memory _name,
        string memory _symbol,
        address _token
    ) PoolERC20(_name, _symbol) {
        token = IERC20(_token);
    }

    function _initializePool(
        string memory _name,
        string memory _symbol,
        address _token
    ) internal initializer {
        require(_token != address(0), Errors.INPUT_ADDRESS_IS_ZERO);
        _setName(_name);
        _setSymbol(_symbol);
        _initializePermit(_name);
        token = IERC20(_token);

        uint256 _decimals = IERC20Metadata(_token).decimals();
        decimalConversionFactor = 10**(18 - _decimals);
    }

    function deposit(uint256 _amount) external virtual nonReentrant whenNotPaused {
        _deposit(_amount);
    }

    function depositWithPermit(
        uint256 _amount,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external virtual nonReentrant whenNotPaused {
        IERC20Permit(address(token)).permit(_msgSender(), address(this), _amount, _deadline, _v, _r, _s);
        _deposit(_amount);
    }

    function withdraw(uint256 _shares) external virtual nonReentrant whenNotShutdown {
        _withdraw(_shares);
    }

    function whitelistedWithdraw(uint256 _shares) external virtual nonReentrant whenNotShutdown {
        require(IAddressList(feeWhitelist).contains(_msgSender()), Errors.NOT_WHITELISTED_ADDRESS);
        _withdrawWithoutFee(_shares);
    }

    function multiTransfer(address[] calldata _recipients, uint256[] calldata _amounts) external returns (bool) {
        require(_recipients.length == _amounts.length, Errors.INPUT_LENGTH_MISMATCH);
        for (uint256 i = 0; i < _recipients.length; i++) {
            require(transfer(_recipients[i], _amounts[i]), Errors.MULTI_TRANSFER_FAILED);
        }
        return true;
    }

    function pricePerShare() public view returns (uint256) {
        if (totalSupply() == 0 || totalValue() == 0) {
            return convertFrom18(1e18);
        }
        return (totalValue() * 1e18) / totalSupply();
    }

    function convertFrom18(uint256 _amount) public view virtual returns (uint256) {
        return _amount / decimalConversionFactor;
    }

    function tokensHere() public view virtual returns (uint256) {
        return token.balanceOf(address(this));
    }

    function totalValue() public view virtual returns (uint256);

    function _beforeBurning(uint256 _share) internal virtual returns (uint256) {}

    function _afterBurning(uint256 _amount) internal virtual returns (uint256) {
        token.safeTransfer(_msgSender(), _amount);
        return _amount;
    }

    function _beforeMinting(uint256 _amount) internal virtual {
        token.safeTransferFrom(_msgSender(), address(this), _amount);
    }

    function _afterMinting(uint256 _amount) internal virtual {}

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override {
        if (poolRewards != address(0)) {
            IPoolRewards(poolRewards).updateReward(sender);
            IPoolRewards(poolRewards).updateReward(recipient);
        }
        super._transfer(sender, recipient, amount);
    }

    function _calculateShares(uint256 _amount) internal view returns (uint256) {
        require(_amount != 0, Errors.INVALID_COLLATERAL_AMOUNT);
        uint256 _share = ((_amount * 1e18) / pricePerShare());
        return _amount > ((_share * pricePerShare()) / 1e18) ? _share + 1 : _share;
    }

    function _claimRewards(address _account) internal {
        if (poolRewards != address(0)) {
            IPoolRewards(poolRewards).claimReward(_account);
        }
    }

    function _deposit(uint256 _amount) internal virtual {
        _claimRewards(_msgSender());
        uint256 _shares = _calculateShares(_amount);
        _beforeMinting(_amount);
        _mint(_msgSender(), _shares);
        _afterMinting(_amount);
        emit Deposit(_msgSender(), _shares, _amount);
    }

    function _withdraw(uint256 _shares) internal {
        if (withdrawFee == 0) {
            _withdrawWithoutFee(_shares);
        } else {
            require(_shares != 0, Errors.INVALID_SHARE_AMOUNT);
            _claimRewards(_msgSender());
            uint256 _fee = (_shares * withdrawFee) / MAX_BPS;
            uint256 _sharesAfterFee = _shares - _fee;
            uint256 _amountWithdrawn = _beforeBurning(_sharesAfterFee);
            uint256 _proportionalShares = _calculateShares(_amountWithdrawn);

            if (convertFrom18(_proportionalShares) < convertFrom18(_sharesAfterFee)) {
                _shares = (_proportionalShares * MAX_BPS) / (MAX_BPS - withdrawFee);
                _fee = _shares - _proportionalShares;
                _sharesAfterFee = _proportionalShares;
            }
            _burn(_msgSender(), _sharesAfterFee);
            _transfer(_msgSender(), feeCollector, _fee);
            _afterBurning(_amountWithdrawn);
            emit Withdraw(_msgSender(), _shares, _amountWithdrawn);
        }
    }

    function _withdrawWithoutFee(uint256 _shares) internal {
        require(_shares != 0, Errors.INVALID_SHARE_AMOUNT);
        _claimRewards(_msgSender());
        uint256 _amountWithdrawn = _beforeBurning(_shares);
        uint256 _proportionalShares = _calculateShares(_amountWithdrawn);
        if (convertFrom18(_proportionalShares) < convertFrom18(_shares)) {
            _shares = _proportionalShares;
        }
        _burn(_msgSender(), _shares);
        _afterBurning(_amountWithdrawn);
        emit Withdraw(_msgSender(), _shares, _amountWithdrawn);
    }
}// MIT

pragma solidity 0.8.3;


abstract contract VPoolBase is PoolShareToken {
    using SafeERC20 for IERC20;

    event UpdatedFeeCollector(address indexed previousFeeCollector, address indexed newFeeCollector);
    event UpdatedPoolRewards(address indexed previousPoolRewards, address indexed newPoolRewards);
    event UpdatedWithdrawFee(uint256 previousWithdrawFee, uint256 newWithdrawFee);

    constructor(
        string memory _name,
        string memory _symbol,
        address _token // solhint-disable-next-line no-empty-blocks
    ) PoolShareToken(_name, _symbol, _token) {}

    function _initializeBase(
        string memory _name,
        string memory _symbol,
        address _token,
        address _poolAccountant,
        address _addressListFactory
    ) internal initializer {
        require(_poolAccountant != address(0), Errors.INPUT_ADDRESS_IS_ZERO);
        require(_addressListFactory != address(0), Errors.INPUT_ADDRESS_IS_ZERO);
        _initializePool(_name, _symbol, _token);
        _initializeGoverned();
        _initializeAddressLists(_addressListFactory);
        poolAccountant = _poolAccountant;
    }

    function _initializeAddressLists(address _addressListFactory) internal {
        require(address(keepers) == address(0), Errors.ALREADY_INITIALIZED);
        IAddressListFactory _factory = IAddressListFactory(_addressListFactory);
        feeWhitelist = _factory.createList();
        keepers = _factory.createList();
        maintainers = _factory.createList();
        require(IAddressList(keepers).add(_msgSender()), Errors.ADD_IN_LIST_FAILED);
        require(IAddressList(maintainers).add(_msgSender()), Errors.ADD_IN_LIST_FAILED);
    }

    modifier onlyKeeper() {
        require(IAddressList(keepers).contains(_msgSender()), "not-a-keeper");
        _;
    }

    modifier onlyMaintainer() {
        require(IAddressList(maintainers).contains(_msgSender()), "not-a-maintainer");
        _;
    }


    function migrateStrategy(address _old, address _new) external onlyGovernor {
        require(
            IStrategy(_new).pool() == address(this) && IStrategy(_old).pool() == address(this),
            Errors.INVALID_STRATEGY
        );
        IPoolAccountant(poolAccountant).migrateStrategy(_old, _new);
        IStrategy(_old).migrate(_new);
    }

    function updateFeeCollector(address _newFeeCollector) external onlyGovernor {
        require(_newFeeCollector != address(0), Errors.INPUT_ADDRESS_IS_ZERO);
        emit UpdatedFeeCollector(feeCollector, _newFeeCollector);
        feeCollector = _newFeeCollector;
    }

    function updatePoolRewards(address _newPoolRewards) external onlyGovernor {
        require(_newPoolRewards != address(0), Errors.INPUT_ADDRESS_IS_ZERO);
        emit UpdatedPoolRewards(poolRewards, _newPoolRewards);
        poolRewards = _newPoolRewards;
    }

    function updateWithdrawFee(uint256 _newWithdrawFee) external onlyGovernor {
        require(feeCollector != address(0), Errors.FEE_COLLECTOR_NOT_SET);
        require(_newWithdrawFee <= MAX_BPS, Errors.FEE_LIMIT_REACHED);
        emit UpdatedWithdrawFee(withdrawFee, _newWithdrawFee);
        withdrawFee = _newWithdrawFee;
    }

    function pause() external onlyKeeper {
        _pause();
    }

    function unpause() external onlyKeeper {
        _unpause();
    }

    function shutdown() external onlyKeeper {
        _shutdown();
    }

    function open() external onlyKeeper {
        _open();
    }

    function addInList(address _listToUpdate, address _addressToAdd) external onlyKeeper {
        require(IAddressList(_listToUpdate).add(_addressToAdd), Errors.ADD_IN_LIST_FAILED);
    }

    function removeFromList(address _listToUpdate, address _addressToRemove) external onlyKeeper {
        require(IAddressList(_listToUpdate).remove(_addressToRemove), Errors.REMOVE_FROM_LIST_FAILED);
    }


    function reportEarning(
        uint256 _profit,
        uint256 _loss,
        uint256 _payback
    ) public virtual {
        (uint256 _actualPayback, uint256 _creditLine, uint256 _interestFee) =
            IPoolAccountant(poolAccountant).reportEarning(_msgSender(), _profit, _loss, _payback);
        uint256 _totalPayback = _profit + _actualPayback;
        if (_totalPayback < _creditLine) {
            token.safeTransfer(_msgSender(), _creditLine - _totalPayback);
        } else if (_totalPayback > _creditLine) {
            token.safeTransferFrom(_msgSender(), address(this), _totalPayback - _creditLine);
        }
        if (_interestFee != 0) {
            _mint(_msgSender(), _calculateShares(_interestFee));
        }
    }

    function reportLoss(uint256 _loss) external {
        IPoolAccountant(poolAccountant).reportLoss(_msgSender(), _loss);
    }

    function sweepERC20(address _fromToken) external virtual onlyKeeper {
        require(_fromToken != address(token), Errors.NOT_ALLOWED_TO_SWEEP);
        require(feeCollector != address(0), Errors.FEE_COLLECTOR_NOT_SET);
        IERC20(_fromToken).safeTransfer(feeCollector, IERC20(_fromToken).balanceOf(address(this)));
    }

    function availableCreditLimit(address _strategy) external view returns (uint256) {
        return IPoolAccountant(poolAccountant).availableCreditLimit(_strategy);
    }

    function excessDebt(address _strategy) external view returns (uint256) {
        return IPoolAccountant(poolAccountant).excessDebt(_strategy);
    }

    function getStrategies() public view returns (address[] memory) {
        return IPoolAccountant(poolAccountant).getStrategies();
    }

    function getWithdrawQueue() public view returns (address[] memory) {
        return IPoolAccountant(poolAccountant).getWithdrawQueue();
    }

    function strategy(address _strategy)
        external
        view
        returns (
            bool _active,
            uint256 _interestFee,
            uint256 _debtRate,
            uint256 _lastRebalance,
            uint256 _totalDebt,
            uint256 _totalLoss,
            uint256 _totalProfit,
            uint256 _debtRatio
        )
    {
        return IPoolAccountant(poolAccountant).strategy(_strategy);
    }

    function totalDebt() external view returns (uint256) {
        return IPoolAccountant(poolAccountant).totalDebt();
    }

    function totalDebtOf(address _strategy) public view returns (uint256) {
        return IPoolAccountant(poolAccountant).totalDebtOf(_strategy);
    }

    function totalDebtRatio() external view returns (uint256) {
        return IPoolAccountant(poolAccountant).totalDebtRatio();
    }

    function totalValue() public view override returns (uint256) {
        return IPoolAccountant(poolAccountant).totalDebt() + tokensHere();
    }

    function _withdrawCollateral(uint256 _amount) internal virtual {
        uint256 _debt;
        uint256 _balanceAfter;
        uint256 _balanceBefore;
        uint256 _amountWithdrawn;
        uint256 _amountNeeded = _amount;
        uint256 _totalAmountWithdrawn;
        address[] memory _withdrawQueue = getWithdrawQueue();
        uint256 _len = _withdrawQueue.length;
        for (uint256 i; i < _len; i++) {
            address _strategy = _withdrawQueue[i];
            _debt = totalDebtOf(_strategy);
            if (_debt == 0) {
                continue;
            }
            if (_amountNeeded > _debt) {
                _amountNeeded = _debt;
            }
            _balanceBefore = tokensHere();
            try IStrategy(_strategy).withdraw(_amountNeeded) {} catch {
                continue;
            }
            _balanceAfter = tokensHere();
            _amountWithdrawn = _balanceAfter - _balanceBefore;
            IPoolAccountant(poolAccountant).decreaseDebt(_strategy, _amountWithdrawn);
            _totalAmountWithdrawn += _amountWithdrawn;
            if (_totalAmountWithdrawn >= _amount) {
                break;
            }
            _amountNeeded = _amount - _totalAmountWithdrawn;
        }
    }

    function _beforeBurning(uint256 _share) internal override returns (uint256 actualWithdrawn) {
        uint256 _amount = (_share * pricePerShare()) / 1e18;
        uint256 _balanceNow = tokensHere();
        if (_amount > _balanceNow) {
            _withdrawCollateral(_amount - _balanceNow);
            _balanceNow = tokensHere();
        }
        actualWithdrawn = _balanceNow < _amount ? _balanceNow : _amount;
    }
}// MIT

pragma solidity 0.8.3;


contract VFRPool is VPoolBase {

    address public buffer;

    event BufferSet(address buffer);

    constructor(
        string memory _name,
        string memory _symbol,
        address _token
    ) VPoolBase(_name, _symbol, _token) {}

    function initialize(
        string memory _name,
        string memory _symbol,
        address _token,
        address _poolAccountant,
        address _addressListFactory
    ) public initializer {

        _initializeBase(_name, _symbol, _token, _poolAccountant, _addressListFactory);
    }

    function setBuffer(address _buffer) external onlyGovernor {

        require(_buffer != address(0), "buffer-address-is-zero");
        require(_buffer != buffer, "same-buffer-address");
        buffer = _buffer;
        emit BufferSet(_buffer);
    }
}// MIT

pragma solidity 0.8.3;


contract VFRStablePool is VFRPool {

    string public constant VERSION = "3.0.4";

    uint256 public targetAPY;
    uint256 public startTime;
    uint256 public initialPricePerShare;

    uint256 public predictedAPY;
    uint256 public tolerance;
    bool public depositsHalted;

    event ToleranceSet(uint256 tolerance);
    event Retarget(uint256 targetAPY, uint256 tolerance);

    constructor(
        string memory _name,
        string memory _symbol,
        address _token
    ) VFRPool(_name, _symbol, _token) {}

    function setTolerance(uint256 _tolerance) external onlyGovernor {

        require(_tolerance != 0, "tolerance-value-is-zero");
        require(_tolerance != tolerance, "same-tolerance-value");
        tolerance = _tolerance;
        emit ToleranceSet(_tolerance);
    }

    function retarget(uint256 _apy, uint256 _tolerance) external onlyGovernor {

        targetAPY = _apy;
        startTime = block.timestamp;
        initialPricePerShare = pricePerShare();
        predictedAPY = _apy;
        tolerance = _tolerance;
        emit Retarget(_apy, _tolerance);
    }

    function checkpoint() external onlyKeeper {

        address[] memory strategies = getStrategies();

        uint256 profits;
        for (uint256 i = 0; i < strategies.length; i++) {
            (, uint256 fee, , , uint256 totalDebt, , , ) = IPoolAccountant(poolAccountant).strategy(strategies[i]);
            uint256 totalValue = IStrategy(strategies[i]).totalValueCurrent();
            if (totalValue > totalDebt) {
                uint256 totalProfits = totalValue - totalDebt;
                uint256 actualProfits = totalProfits - ((totalProfits * fee) / MAX_BPS);
                profits += actualProfits;
            }
        }

        if (buffer != address(0)) {
            profits += token.balanceOf(buffer);
        }

        uint256 predictedPricePerShare;
        if (totalSupply() == 0 || totalValue() == 0) {
            predictedPricePerShare = convertFrom18(1e18);
        } else {
            predictedPricePerShare = ((totalValue() + profits) * 1e18) / totalSupply();
        }

        predictedAPY =
            ((predictedPricePerShare - initialPricePerShare) * (1e18 * 365 * 24 * 3600)) /
            (initialPricePerShare * (block.timestamp - startTime));

        predictedAPY = predictedAPY > targetAPY ? targetAPY : predictedAPY;

        depositsHalted = targetAPY - predictedAPY > tolerance;
    }

    function targetPricePerShare() public view returns (uint256) {

        return
            initialPricePerShare +
            ((initialPricePerShare * targetAPY * (block.timestamp - startTime)) / (1e18 * 365 * 24 * 3600));
    }

    function amountToReachTarget(address _strategy) public view returns (uint256) {

        uint256 fromPricePerShare = pricePerShare();
        uint256 toPricePerShare = targetPricePerShare();
        if (fromPricePerShare < toPricePerShare) {
            (, uint256 fee, , , , , , ) = IPoolAccountant(poolAccountant).strategy(_strategy);
            uint256 fromTotalValue = (fromPricePerShare * totalSupply()) / 1e18;
            uint256 toTotalValue = (toPricePerShare * totalSupply()) / 1e18;
            uint256 amountWithoutFee = toTotalValue - fromTotalValue;
            return (amountWithoutFee * MAX_BPS) / (MAX_BPS - fee);
        }
        return 0;
    }

    function _deposit(uint256 _amount) internal override {

        require(!depositsHalted, "pool-under-target");
        super._deposit(_amount);
    }
}