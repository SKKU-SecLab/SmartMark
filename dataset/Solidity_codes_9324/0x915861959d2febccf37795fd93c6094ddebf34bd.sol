
pragma solidity 0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// AGPL-3.0
pragma solidity 0.8.0;


interface IEverscale {

    struct EverscaleAddress {
        int8 wid;
        uint256 addr;
    }

    struct EverscaleEvent {
        uint64 eventTransactionLt;
        uint32 eventTimestamp;
        bytes eventData;
        int8 configurationWid;
        uint256 configurationAddress;
        int8 eventContractWid;
        uint256 eventContractAddress;
        address proxy;
        uint32 round;
    }
}// AGPL-3.0
pragma solidity 0.8.0;



interface IMultiVault is IEverscale {

    enum Fee { Deposit, Withdraw }
    enum TokenType { Native, Alien }

    struct TokenPrefix {
        uint activation;
        string name;
        string symbol;
    }

    struct TokenMeta {
        string name;
        string symbol;
        uint8 decimals;
    }

    struct Token {
        uint activation;
        bool blacklisted;
        uint depositFee;
        uint withdrawFee;
        bool isNative;
    }

    struct NativeWithdrawalParams {
        EverscaleAddress native;
        TokenMeta meta;
        uint256 amount;
        address recipient;
        uint256 chainId;
    }

    struct AlienWithdrawalParams {
        address token;
        uint256 amount;
        address recipient;
        uint256 chainId;
    }

    struct PendingWithdrawalParams {
        address token;
        uint256 amount;
        uint256 bounty;
    }

    struct PendingWithdrawalId {
        address recipient;
        uint256 id;
    }

    function defaultNativeDepositFee() external view returns (uint);

    function defaultNativeWithdrawFee() external view returns (uint);

    function defaultAlienDepositFee() external view returns (uint);

    function defaultAlienWithdrawFee() external view returns (uint);


    function apiVersion() external view returns (string memory api_version);


    function initialize(
        address _bridge,
        address _governance
    ) external;


    function fees(address token) external view returns (uint);

    function prefixes(address _token) external view returns (TokenPrefix memory);

    function tokens(address _token) external view returns (Token memory);

    function natives(address _token) external view returns (EverscaleAddress memory);


    function setPrefix(
        address token,
        string memory name_prefix,
        string memory symbol_prefix
    ) external;

    function blacklistAddToken(address token) external;

    function blacklistRemoveToken(address token) external;


    function setTokenDepositFee(address token, uint _depositFee) external;

    function setTokenWithdrawFee(address token, uint _withdrawFee) external;


    function setDefaultNativeDepositFee(uint fee) external;

    function setDefaultNativeWithdrawFee(uint fee) external;

    function setDefaultAlienDepositFee(uint fee) external;

    function setDefaultAlienWithdrawFee(uint fee) external;


    function rewards() external view returns (EverscaleAddress memory);


    function configurationAlien() external view returns (EverscaleAddress memory);

    function configurationNative() external view returns (EverscaleAddress memory);


    function withdrawalIds(bytes32) external view returns (bool);

    function bridge() external view returns(address);


    function governance() external view returns (address);

    function guardian() external view returns (address);

    function management() external view returns (address);


    function emergencyShutdown() external view returns (bool);

    function setEmergencyShutdown(bool active) external;


    function setConfigurationAlien(EverscaleAddress memory _configuration) external;

    function setConfigurationNative(EverscaleAddress memory _configuration) external;


    function setGovernance(address _governance) external;

    function acceptGovernance() external;

    function setGuardian(address _guardian) external;

    function setManagement(address _management) external;

    function setRewards(EverscaleAddress memory _rewards) external;


    function pendingWithdrawalsPerUser(address user) external view returns (uint);


    function pendingWithdrawalsTotal(address token) external view returns (uint);


    function pendingWithdrawals(
        address user,
        uint256 id
    ) external view returns (PendingWithdrawalParams memory);


    function setPendingWithdrawalBounty(
        uint256 id,
        uint256 bounty
    ) external;


    function cancelPendingWithdrawal(
        uint256 id,
        uint256 amount,
        EverscaleAddress memory recipient,
        uint bounty
    ) external;


    function forceWithdraw(
        PendingWithdrawalId[] memory pendingWithdrawalIds
    ) external;


    function deposit(
        EverscaleAddress memory recipient,
        address token,
        uint amount
    ) external;


    function deposit(
        EverscaleAddress memory recipient,
        address token,
        uint256 amount,
        uint256 expectedMinBounty,
        PendingWithdrawalId[] memory pendingWithdrawalIds
    ) external;


    function saveWithdrawNative(
        bytes memory payload,
        bytes[] memory signatures
    ) external;


    function saveWithdrawAlien(
        bytes memory payload,
        bytes[] memory signatures
    ) external;


    function saveWithdrawAlien(
        bytes memory payload,
        bytes[] memory signatures,
        uint bounty
    ) external;


    function skim(
        address token,
        bool skim_to_everscale
    ) external;


    function migrateAlienTokenToVault(
        address token,
        address vault
    ) external;


    event PendingWithdrawalCancel(
        address recipient,
        uint256 id,
        uint256 amount
    );

    event PendingWithdrawalUpdateBounty(
        address recipient,
        uint256 id,
        uint256 bounty
    );

    event PendingWithdrawalCreated(
        address recipient,
        uint256 id,
        address token,
        uint256 amount,
        bytes32 payloadId
    );

    event PendingWithdrawalWithdraw(
        address recipient,
        uint256 id,
        uint256 amount
    );

    event PendingWithdrawalFill(
        address recipient,
        uint256 id
    );

    event PendingWithdrawalForce(
        address recipient,
        uint256 id
    );

    event BlacklistTokenAdded(address token);
    event BlacklistTokenRemoved(address token);

    event UpdateDefaultNativeDepositFee(uint fee);
    event UpdateDefaultNativeWithdrawFee(uint fee);
    event UpdateDefaultAlienDepositFee(uint fee);
    event UpdateDefaultAlienWithdrawFee(uint fee);

    event UpdateBridge(address bridge);
    event UpdateConfiguration(TokenType _type, int128 wid, uint256 addr);
    event UpdateRewards(int128 wid, uint256 addr);

    event UpdateTokenDepositFee(address token, uint256 fee);
    event UpdateTokenWithdrawFee(address token, uint256 fee);

    event UpdateGovernance(address governance);
    event UpdateManagement(address management);
    event NewPendingGovernance(address governance);
    event UpdateGuardian(address guardian);

    event EmergencyShutdown(bool active);

    event TokenMigrated(address token, address vault);

    event TokenActivated(
        address token,
        uint activation,
        bool isNative,
        uint depositFee,
        uint withdrawFee
    );

    event TokenCreated(
        address token,
        int8 native_wid,
        uint256 native_addr,
        string name_prefix,
        string symbol_prefix,
        string name,
        string symbol,
        uint8 decimals
    );

    event AlienTransfer(
        uint256 base_chainId,
        uint160 base_token,
        string name,
        string symbol,
        uint8 decimals,
        uint128 amount,
        int8 recipient_wid,
        uint256 recipient_addr
    );

    event NativeTransfer(
        int8 native_wid,
        uint256 native_addr,
        uint128 amount,
        int8 recipient_wid,
        uint256 recipient_addr
    );

    event Deposit(
        TokenType _type,
        address sender,
        address token,
        int8 recipient_wid,
        uint256 recipient_addr,
        uint256 amount,
        uint256 fee
    );

    event Withdraw(
        TokenType _type,
        bytes32 payloadId,
        address token,
        address recipient,
        uint256 amount,
        uint256 fee
    );

    event UpdateTokenPrefix(
        address token,
        string name_prefix,
        string symbol_prefix
    );

    event SkimFee(
        address token,
        bool skim_to_everscale,
        uint256 amount
    );
}// AGPL-3.0
pragma solidity 0.8.0;


interface IMultiVaultToken {

    function initialize(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) external;


    function burn(address account, uint256 amount) external;

    function mint(address account, uint256 amount) external;

}// AGPL-3.0
pragma solidity 0.8.0;

pragma experimental ABIEncoderV2;


interface IBridge is IEverscale {

    struct Round {
        uint32 end;
        uint32 ttl;
        uint32 relays;
        uint32 requiredSignatures;
    }

    function updateMinimumRequiredSignatures(uint32 _minimumRequiredSignatures) external;

    function setConfiguration(EverscaleAddress calldata _roundRelaysConfiguration) external;

    function updateRoundTTL(uint32 _roundTTL) external;


    function isRelay(
        uint32 round,
        address candidate
    ) external view returns (bool);


    function isBanned(
        address candidate
    ) external view returns (bool);


    function isRoundRotten(
        uint32 round
    ) external view returns (bool);


    function verifySignedEverscaleEvent(
        bytes memory payload,
        bytes[] memory signatures
    ) external view returns (uint32);


    function setRoundRelays(
        bytes calldata payload,
        bytes[] calldata signatures
    ) external;


    function forceRoundRelays(
        uint160[] calldata _relays,
        uint32 roundEnd
    ) external;


    function banRelays(
        address[] calldata _relays
    ) external;


    function unbanRelays(
        address[] calldata _relays
    ) external;


    function pause() external;

    function unpause() external;


    function setRoundSubmitter(address _roundSubmitter) external;


    event EmergencyShutdown(bool active);

    event UpdateMinimumRequiredSignatures(uint32 value);
    event UpdateRoundTTL(uint32 value);
    event UpdateRoundRelaysConfiguration(EverscaleAddress configuration);
    event UpdateRoundSubmitter(address _roundSubmitter);

    event NewRound(uint32 indexed round, Round meta);
    event RoundRelay(uint32 indexed round, address indexed relay);
    event BanRelay(address indexed relay, bool status);
}// MIT

pragma solidity 0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
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

pragma solidity 0.8.0;


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
}// AGPL-3.0
pragma solidity 0.8.0;




library MultiVaultLibrary {

    function decodeNativeWithdrawalEventData(
        bytes memory eventData
    ) internal pure returns (IMultiVault.NativeWithdrawalParams memory) {

        (
            int8 native_wid,
            uint256 native_addr,

            string memory name,
            string memory symbol,
            uint8 decimals,

            uint128 amount,
            uint160 recipient,
            uint256 chainId
        ) = abi.decode(
            eventData,
            (
                int8, uint256,
                string, string, uint8,
                uint128, uint160, uint256
            )
        );

        return IMultiVault.NativeWithdrawalParams({
            native: IEverscale.EverscaleAddress(native_wid, native_addr),
            meta: IMultiVault.TokenMeta(name, symbol, decimals),
            amount: amount,
            recipient: address(recipient),
            chainId: chainId
        });
    }

    function decodeAlienWithdrawalEventData(
        bytes memory eventData
    ) internal pure returns (IMultiVault.AlienWithdrawalParams memory) {

        (
            uint160 token,
            uint128 amount,
            uint160 recipient,
            uint256 chainId
        ) = abi.decode(
            eventData,
            (uint160, uint128, uint160, uint256)
        );

        return IMultiVault.AlienWithdrawalParams({
            token: address(token),
            amount: uint256(amount),
            recipient: address(recipient),
            chainId: chainId
        });
    }

    function getNativeToken(
        int8 native_wid,
        uint256 native_addr
    ) internal view returns (address token) {

        token = address(uint160(uint(keccak256(abi.encodePacked(
            hex'ff',
            address(this),
            keccak256(abi.encodePacked(native_wid, native_addr)),
            hex'192c19818bebb5c6c95f5dcb3c3257379fc46fb654780cb06f3211ee77e1a360' // MultiVaultToken init code hash
        )))));
    }
}// MIT

pragma solidity 0.8.0;


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
        return !Address.isContract(address(this));
    }
}// MIT

pragma solidity 0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// AGPL-3.0
pragma solidity 0.8.0;


contract ChainId {

    function getChainID() public view returns (uint256) {

        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }
}// MIT

pragma solidity 0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity 0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity 0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor (address initialOwner) {
        _transferOwnership(initialOwner);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT
pragma solidity 0.8.0;






contract MultiVaultToken is IMultiVaultToken, Context, IERC20, IERC20Metadata, Ownable {

    uint activation;

    constructor() Ownable(_msgSender()) {}

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    function initialize(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) external override {

        require(activation == 0);

        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;

        activation = block.number;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function mint(
        address account,
        uint amount
    ) external override onlyOwner {

        _mint(account, amount);
    }

    function burn(
        address account,
        uint amount
    ) external override onlyOwner {

        _burn(account, amount);
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {

        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
    unchecked {
        _approve(owner, spender, currentAllowance - subtractedValue);
    }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
    unchecked {
        _balances[from] = fromBalance - amount;
    }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
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

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
        unchecked {
            _approve(owner, spender, currentAllowance - amount);
        }
        }
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

}// AGPL-3.0
pragma solidity 0.8.0;







uint constant MAX_BPS = 10_000;
uint constant FEE_LIMIT = MAX_BPS / 2;

uint8 constant DECIMALS_LIMIT = 18;
uint256 constant SYMBOL_LENGTH_LIMIT = 32;
uint256 constant NAME_LENGTH_LIMIT = 32;

string constant DEFAULT_NAME_PREFIX = 'Octus ';
string constant DEFAULT_SYMBOL_PREFIX = 'oct';


string constant API_VERSION = '0.1.3';


contract MultiVault is IMultiVault, ReentrancyGuard, Initializable, ChainId {
    using SafeERC20 for IERC20;

    function getInitHash() public pure returns(bytes32) {
        bytes memory bytecode = type(MultiVaultToken).creationCode;
        return keccak256(abi.encodePacked(bytecode));
    }

    mapping (address => Token) tokens_;
    mapping (address => EverscaleAddress) natives_;

    uint public override defaultNativeDepositFee;
    uint public override defaultNativeWithdrawFee;
    uint public override defaultAlienDepositFee;
    uint public override defaultAlienWithdrawFee;

    bool public override emergencyShutdown;

    address public override bridge;
    mapping(bytes32 => bool) public override withdrawalIds;
    EverscaleAddress rewards_;
    EverscaleAddress configurationNative_;
    EverscaleAddress configurationAlien_;

    address public override governance;
    address pendingGovernance;
    address public override guardian;
    address public override management;

    mapping (address => TokenPrefix) prefixes_;
    mapping (address => uint) public override fees;

    mapping(address => uint) public override pendingWithdrawalsPerUser;
    mapping(address => mapping(uint256 => PendingWithdrawalParams)) pendingWithdrawals_;

    function pendingWithdrawals(
        address user,
        uint256 id
    ) external view override returns (PendingWithdrawalParams memory) {
        return pendingWithdrawals_[user][id];
    }

    mapping(address => uint) public override pendingWithdrawalsTotal;


    modifier tokenNotBlacklisted(address token) {
        require(!tokens_[token].blacklisted);

        _;
    }

    modifier initializeToken(address token) {
        if (tokens_[token].activation == 0) {

            require(
                IERC20Metadata(token).decimals() <= DECIMALS_LIMIT &&
                bytes(IERC20Metadata(token).symbol()).length <= SYMBOL_LENGTH_LIMIT &&
                bytes(IERC20Metadata(token).name()).length <= NAME_LENGTH_LIMIT
            );

            _activateToken(token, false);
        }

        _;
    }

    modifier onlyEmergencyDisabled() {
        require(!emergencyShutdown, "Vault: emergency mode enabled");

        _;
    }

    modifier onlyGovernance() {
        require(msg.sender == governance);

        _;
    }

    modifier onlyPendingGovernance() {
        require(msg.sender == pendingGovernance);

        _;
    }

    modifier onlyGovernanceOrManagement() {
        require(msg.sender == governance || msg.sender == management);

        _;
    }

    modifier onlyGovernanceOrGuardian() {
        require(msg.sender == governance || msg.sender == guardian);

        _;
    }

    modifier withdrawalNotSeenBefore(bytes memory payload) {
        bytes32 withdrawalId = keccak256(payload);

        require(!withdrawalIds[withdrawalId], "Vault: withdraw payload already seen");

        _;

        withdrawalIds[withdrawalId] = true;
    }

    modifier respectFeeLimit(uint fee) {
        require(fee <= FEE_LIMIT);

        _;
    }

    function prefixes(
        address _token
    ) external view override returns (TokenPrefix memory) {
        return prefixes_[_token];
    }

    function tokens(
        address _token
    ) external view override returns (Token memory) {
        return tokens_[_token];
    }

    function natives(
        address _token
    ) external view override returns (EverscaleAddress memory) {
        return natives_[_token];
    }

    function rewards()
        external
        view
        override
    returns (EverscaleAddress memory) {
        return rewards_;
    }

    function configurationNative()
        external
        view
        override
    returns (EverscaleAddress memory) {
        return configurationNative_;
    }

    function configurationAlien()
        external
        view
        override
    returns (EverscaleAddress memory) {
        return configurationAlien_;
    }

    function apiVersion()
        external
        override
        pure
        returns (string memory api_version)
    {
        return API_VERSION;
    }

    function initialize(
        address _bridge,
        address _governance
    ) external override initializer {
        bridge = _bridge;
        emit UpdateBridge(bridge);

        governance = _governance;
        emit UpdateGovernance(governance);
    }

    function setPrefix(
        address token,
        string memory name_prefix,
        string memory symbol_prefix
    ) external override onlyGovernanceOrManagement {
        TokenPrefix memory prefix = prefixes_[token];

        if (prefix.activation == 0) {
            prefix.activation = block.number;
        }

        prefix.name = name_prefix;
        prefix.symbol = symbol_prefix;

        prefixes_[token] = prefix;

        emit UpdateTokenPrefix(token, name_prefix, symbol_prefix);
    }

    function blacklistAddToken(
        address token
    ) public override onlyGovernance tokenNotBlacklisted(token) {
        tokens_[token].blacklisted = true;

        emit BlacklistTokenAdded(token);
    }

    function blacklistRemoveToken(
        address token
    ) external override onlyGovernance {
        require(tokens_[token].blacklisted);

        tokens_[token].blacklisted = false;

        emit BlacklistTokenRemoved(token);
    }

    function setRewards(
        EverscaleAddress memory _rewards
    ) external override onlyGovernance {
        rewards_ = _rewards;

        emit UpdateRewards(rewards_.wid, rewards_.addr);
    }

    function setDefaultNativeDepositFee(
        uint fee
    )
        external
        override
        onlyGovernanceOrManagement
        respectFeeLimit(fee)
    {
        defaultNativeDepositFee = fee;

        emit UpdateDefaultNativeDepositFee(fee);
    }

    function setDefaultNativeWithdrawFee(
        uint fee
    )
        external
        override
        onlyGovernanceOrManagement
        respectFeeLimit(fee)
    {
        defaultNativeWithdrawFee = fee;

        emit UpdateDefaultNativeWithdrawFee(fee);
    }

    function setDefaultAlienDepositFee(
        uint fee
    )
        external
        override
        onlyGovernanceOrManagement
        respectFeeLimit(fee)
    {
        defaultAlienDepositFee = fee;

        emit UpdateDefaultAlienDepositFee(fee);
    }

    function setDefaultAlienWithdrawFee(
        uint fee
    )
        external
        override
        onlyGovernanceOrManagement
        respectFeeLimit(fee)
    {
        defaultAlienWithdrawFee = fee;

        emit UpdateDefaultAlienWithdrawFee(fee);
    }

    function setTokenDepositFee(
        address token,
        uint _depositFee
    )
        public
        override
        onlyGovernanceOrManagement
        respectFeeLimit(_depositFee)
    {
        tokens_[token].depositFee = _depositFee;

        emit UpdateTokenDepositFee(token, _depositFee);
    }

    function setTokenWithdrawFee(
        address token,
        uint _withdrawFee
    )
        public
        override
        onlyGovernanceOrManagement
        respectFeeLimit(_withdrawFee)
    {
        tokens_[token].withdrawFee = _withdrawFee;

        emit UpdateTokenWithdrawFee(token, _withdrawFee);
    }

    function setConfigurationAlien(
        EverscaleAddress memory _configuration
    ) external override onlyGovernance {
        configurationAlien_ = _configuration;

        emit UpdateConfiguration(
            TokenType.Alien,
            _configuration.wid,
            _configuration.addr
        );
    }

    function setConfigurationNative(
        EverscaleAddress memory _configuration
    ) external override onlyGovernance {
        configurationNative_ = _configuration;

        emit UpdateConfiguration(
            TokenType.Native,
            _configuration.wid,
            _configuration.addr
        );
    }

    function setGovernance(
        address _governance
    ) external override onlyGovernance {
        pendingGovernance = _governance;

        emit NewPendingGovernance(pendingGovernance);
    }

    function acceptGovernance()
        external
        override
        onlyPendingGovernance
    {
        governance = pendingGovernance;

        emit UpdateGovernance(governance);
    }

    function setManagement(
        address _management
    )
        external
        override
        onlyGovernance
    {
        management = _management;

        emit UpdateManagement(management);
    }

    function setGuardian(
        address _guardian
    )
        external
        override
        onlyGovernance
    {
        guardian = _guardian;

        emit UpdateGuardian(guardian);
    }

    function setEmergencyShutdown(
        bool active
    ) external override {
        if (active) {
            require(msg.sender == guardian || msg.sender == governance);
        } else {
            require(msg.sender == governance);
        }

        emergencyShutdown = active;

        emit EmergencyShutdown(active);
    }

    function setPendingWithdrawalBounty(
        uint256 id,
        uint256 bounty
    )
        public
        override
    {
        PendingWithdrawalParams memory pendingWithdrawal = pendingWithdrawals_[msg.sender][id];

        require(bounty <= pendingWithdrawal.amount);

        pendingWithdrawals_[msg.sender][id].bounty = bounty;

        emit PendingWithdrawalUpdateBounty(
            msg.sender,
            id,
            bounty
        );
    }

    function forceWithdraw(
        PendingWithdrawalId[] memory pendingWithdrawalIds
    ) external override {
        for (uint i = 0; i < pendingWithdrawalIds.length; i++) {
            PendingWithdrawalId memory pendingWithdrawalId = pendingWithdrawalIds[i];

            PendingWithdrawalParams memory pendingWithdrawal = pendingWithdrawals_[pendingWithdrawalId.recipient][pendingWithdrawalId.id];

            pendingWithdrawals_[pendingWithdrawalId.recipient][pendingWithdrawalId.id].amount = 0;

            IERC20(pendingWithdrawal.token).safeTransfer(
                pendingWithdrawalId.recipient,
                pendingWithdrawal.amount
            );

            emit PendingWithdrawalForce(pendingWithdrawalId.recipient, pendingWithdrawalId.id);
        }
    }

    function cancelPendingWithdrawal(
        uint256 id,
        uint256 amount,
        EverscaleAddress memory recipient,
        uint bounty
    )
        external
        override
        onlyEmergencyDisabled
    {
        PendingWithdrawalParams memory pendingWithdrawal = pendingWithdrawals_[msg.sender][id];

        require(amount > 0 && amount <= pendingWithdrawal.amount);

        pendingWithdrawals_[msg.sender][id].amount -= amount;

        _transferToEverscaleAlien(pendingWithdrawal.token, recipient, amount);

        emit PendingWithdrawalCancel(msg.sender, id, amount);

        setPendingWithdrawalBounty(id, bounty);
    }

    function deposit(
        EverscaleAddress memory recipient,
        address token,
        uint amount
    )
        external
        override
        nonReentrant
        tokenNotBlacklisted(token)
        initializeToken(token)
        onlyEmergencyDisabled
    {
        uint fee = calculateMovementFee(amount, token, Fee.Deposit);

        bool isNative = tokens_[token].isNative;

        if (isNative) {
            IMultiVaultToken(token).burn(
                msg.sender,
                amount
            );

            _transferToEverscaleNative(token, recipient, amount - fee);
        } else {
            IERC20(token).safeTransferFrom(
                msg.sender,
                address(this),
                amount
            );

            _transferToEverscaleAlien(token, recipient, amount - fee);
        }

        _increaseTokenFee(token, fee);

        emit Deposit(
            isNative ? TokenType.Native : TokenType.Alien,
            msg.sender,
            token,
            recipient.wid,
            recipient.addr,
            amount,
            fee
        );
    }

    function deposit(
        EverscaleAddress memory recipient,
        address token,
        uint256 amount,
        uint256 expectedMinBounty,
        PendingWithdrawalId[] memory pendingWithdrawalIds
    ) external override nonReentrant {
        uint amountLeft = amount;
        uint amountPlusBounty = amount;

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        for (uint i = 0; i < pendingWithdrawalIds.length; i++) {
            PendingWithdrawalId memory pendingWithdrawalId = pendingWithdrawalIds[i];
            PendingWithdrawalParams memory pendingWithdrawal = pendingWithdrawals_[pendingWithdrawalId.recipient][pendingWithdrawalId.id];

            require(pendingWithdrawal.amount > 0);
            require(pendingWithdrawal.token == token);

            amountLeft -= pendingWithdrawal.amount;
            amountPlusBounty += pendingWithdrawal.bounty;

            pendingWithdrawals_[pendingWithdrawalId.recipient][pendingWithdrawalId.id].amount = 0;

            emit PendingWithdrawalFill(pendingWithdrawalId.recipient, pendingWithdrawalId.id);

            IERC20(pendingWithdrawal.token).safeTransfer(
                pendingWithdrawalId.recipient,
                pendingWithdrawal.amount - pendingWithdrawal.bounty
            );
        }

        require(amountPlusBounty - amount >= expectedMinBounty);

        uint fee = calculateMovementFee(amount, token, Fee.Deposit);

        _transferToEverscaleAlien(
            token,
            recipient,
            amountPlusBounty - fee
        );

        _increaseTokenFee(token, fee);
    }

    function saveWithdrawNative(
        bytes memory payload,
        bytes[] memory signatures
    )
        external
        override
        nonReentrant
        withdrawalNotSeenBefore(payload)
        onlyEmergencyDisabled
    {
        EverscaleEvent memory _event = _processWithdrawEvent(
            payload,
            signatures,
            configurationNative_
        );

        bytes32 payloadId = keccak256(payload);

        NativeWithdrawalParams memory withdrawal = MultiVaultLibrary.decodeNativeWithdrawalEventData(_event.eventData);

        require(withdrawal.chainId == getChainID());

        address token = _getNativeWithdrawalToken(withdrawal);

        require(!tokens_[token].blacklisted);

        uint256 fee = calculateMovementFee(
            withdrawal.amount,
            token,
            Fee.Withdraw
        );

        IMultiVaultToken(token).mint(
            withdrawal.recipient,
            withdrawal.amount - fee
        );

        _increaseTokenFee(token, fee);

        emit Withdraw(
            TokenType.Native,
            payloadId,
            token,
            withdrawal.recipient,
            withdrawal.amount,
            fee
        );
    }

    function saveWithdrawAlien(
        bytes memory payload,
        bytes[] memory signatures,
        uint bounty
    )
        public
        override
        nonReentrant
        withdrawalNotSeenBefore(payload)
        onlyEmergencyDisabled
    {
        EverscaleEvent memory _event = _processWithdrawEvent(
            payload,
            signatures,
            configurationAlien_
        );

        bytes32 payloadId = keccak256(payload);

        AlienWithdrawalParams memory withdrawal = MultiVaultLibrary.decodeAlienWithdrawalEventData(_event.eventData);

        require(withdrawal.chainId == getChainID());

        require(!tokens_[withdrawal.token].blacklisted);

        uint256 fee = calculateMovementFee(
            withdrawal.amount,
            withdrawal.token,
            Fee.Withdraw
        );

        _increaseTokenFee(withdrawal.token, fee);

        uint withdrawAmount = withdrawal.amount - fee;

        if (IERC20(withdrawal.token).balanceOf(address(this)) < withdrawAmount) {
            uint pendingWithdrawalId = pendingWithdrawalsPerUser[withdrawal.recipient];

            pendingWithdrawalsPerUser[withdrawal.recipient]++;

            pendingWithdrawalsTotal[withdrawal.token] += withdrawAmount;

            pendingWithdrawals_[withdrawal.recipient][pendingWithdrawalId] = PendingWithdrawalParams({
                token: withdrawal.token,
                amount: withdrawAmount,
                bounty: msg.sender == withdrawal.recipient ? bounty : 0
            });

            emit PendingWithdrawalCreated(
                withdrawal.recipient,
                pendingWithdrawalId,
                withdrawal.token,
                withdrawAmount,
                payloadId
            );
        } else {
            IERC20(withdrawal.token).safeTransfer(
                withdrawal.recipient,
                withdrawAmount
            );

            emit Withdraw(
                TokenType.Alien,
                payloadId,
                withdrawal.token,
                withdrawal.recipient,
                withdrawal.amount,
                fee
            );
        }
    }

    function saveWithdrawAlien(
        bytes memory payload,
        bytes[] memory signatures
    )
        external
        override
    {
        saveWithdrawAlien(payload, signatures, 0);
    }

    function skim(
        address token,
        bool skim_to_everscale
    ) external override nonReentrant onlyGovernanceOrManagement {
        uint fee = fees[token];

        require(fee > 0);

        fees[token] = 0;

        bool isNative = tokens_[token].isNative;

        if (skim_to_everscale) {
            if (isNative) {
                _transferToEverscaleNative(token, rewards_, fee);
            } else {
                _transferToEverscaleAlien(token, rewards_, fee);
            }
        } else {
            if (isNative) {
                IMultiVaultToken(token).mint(governance, fee);
            } else {
                IERC20(token).safeTransfer(governance, fee);
            }
        }

        emit SkimFee(token, skim_to_everscale, fee);
    }

    function migrateAlienTokenToVault(
        address token,
        address vault
    )
        external
        override
        onlyGovernance
    {
        require(tokens_[token].activation > 0);
        require(!tokens_[token].isNative);

        tokens_[token].blacklisted = true;

        IERC20(token).safeTransfer(
            vault,
            IERC20(token).balanceOf(address(this))
        );

        emit TokenMigrated(token, vault);
    }

    function calculateMovementFee(
        uint256 amount,
        address _token,
        Fee fee
    ) public view returns (uint256) {
        Token memory token = tokens_[_token];

        uint tokenFee = fee == Fee.Deposit ? token.depositFee : token.withdrawFee;

        return tokenFee * amount / MAX_BPS;
    }

    function getNativeToken(
        int8 native_wid,
        uint256 native_addr
    ) external view returns (address) {
        return MultiVaultLibrary.getNativeToken(native_wid, native_addr);
    }

    function _increaseTokenFee(
        address token,
        uint amount
    ) internal {
        if (amount > 0) fees[token] += amount;
    }

    function _activateToken(
        address token,
        bool isNative
    ) internal {
        uint depositFee = isNative ? defaultNativeDepositFee : defaultAlienDepositFee;
        uint withdrawFee = isNative ? defaultNativeWithdrawFee : defaultAlienWithdrawFee;

        tokens_[token] = Token({
            activation: block.number,
            blacklisted: false,
            isNative: isNative,
            depositFee: depositFee,
            withdrawFee: withdrawFee
        });

        emit TokenActivated(
            token,
            block.number,
            isNative,
            depositFee,
            withdrawFee
        );
    }

    function _transferToEverscaleNative(
        address _token,
        EverscaleAddress memory recipient,
        uint amount
    ) internal {
        EverscaleAddress memory native = natives_[_token];

        emit NativeTransfer(
            native.wid,
            native.addr,
            uint128(amount),
            recipient.wid,
            recipient.addr
        );
    }

    function _transferToEverscaleAlien(
        address _token,
        EverscaleAddress memory recipient,
        uint amount
    ) internal {
        emit AlienTransfer(
            getChainID(),
            uint160(_token),
            IERC20Metadata(_token).name(),
            IERC20Metadata(_token).symbol(),
            IERC20Metadata(_token).decimals(),
            uint128(amount),
            recipient.wid,
            recipient.addr
        );
    }

    function _getNativeWithdrawalToken(
        NativeWithdrawalParams memory withdrawal
    ) internal returns (address token) {
        token = MultiVaultLibrary.getNativeToken(
            withdrawal.native.wid,
            withdrawal.native.addr
        );

        if (tokens_[token].activation == 0) {
            _deployTokenForNative(withdrawal.native, withdrawal.meta);
            _activateToken(token, true);

            natives_[token] = withdrawal.native;
        }
    }

    function _deployTokenForNative(
        EverscaleAddress memory native,
        TokenMeta memory meta
    ) internal returns (address token) {
        bytes memory bytecode = type(MultiVaultToken).creationCode;

        bytes32 salt = keccak256(abi.encodePacked(native.wid, native.addr));

        assembly {
            token := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        TokenPrefix memory prefix = prefixes_[token];

        string memory name_prefix = prefix.activation == 0 ? DEFAULT_NAME_PREFIX : prefix.name;
        string memory symbol_prefix = prefix.activation == 0 ? DEFAULT_SYMBOL_PREFIX : prefix.symbol;

        IMultiVaultToken(token).initialize(
            string(abi.encodePacked(name_prefix, meta.name)),
            string(abi.encodePacked(symbol_prefix, meta.symbol)),
            meta.decimals
        );

        emit TokenCreated(
            token,
            native.wid,
            native.addr,
            name_prefix,
            symbol_prefix,
            meta.name,
            meta.symbol,
            meta.decimals
        );
    }

    function _processWithdrawEvent(
        bytes memory payload,
        bytes[] memory signatures,
        EverscaleAddress memory configuration
    ) internal view returns (EverscaleEvent memory) {
        require(
            IBridge(bridge).verifySignedEverscaleEvent(payload, signatures) == 0,
            "Vault: signatures verification failed"
        );

        (EverscaleEvent memory _event) = abi.decode(payload, (EverscaleEvent));

        require(
            _event.configurationWid == configuration.wid &&
            _event.configurationAddress == configuration.addr
        );

        return _event;
     }
}