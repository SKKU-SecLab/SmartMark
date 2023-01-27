

pragma solidity >=0.6.2 <0.8.0;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{ value: amount }("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {

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

        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(
            data
        );
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {

        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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
}


pragma solidity >=0.4.24 <0.8.0;

abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(
            _initializing || _isConstructor() || !_initialized,
            "Initializable: contract is already initialized"
        );

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
}


pragma solidity >=0.6.0 <0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {}

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    uint256[50] private __gap;
}


pragma solidity >=0.6.0 <0.8.0;

interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


pragma solidity >=0.6.0 <0.8.0;

library SafeMathUpgradeable {

    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {

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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}


pragma solidity >=0.6.0 <0.8.0;

contract ERC20Upgradeable is
    Initializable,
    ContextUpgradeable,
    IERC20Upgradeable
{

    using SafeMathUpgradeable for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    function __ERC20_init(string memory name_, string memory symbol_)
        internal
        initializer
    {

        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_)
        internal
        initializer
    {

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

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {

        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {

        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
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

        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
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

        _balances[account] = _balances[account].sub(
            amount,
            "ERC20: burn amount exceeds balance"
        );
        _totalSupply = _totalSupply.sub(amount);
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

    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    uint256[44] private __gap;
}


pragma solidity >=0.6.0 <0.8.0;

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    uint256[49] private __gap;
}


pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {

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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}


pragma solidity >=0.6.2 <0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{ value: amount }("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {

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

        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(
            data
        );
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {

        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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

    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {

        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
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
}


pragma solidity >=0.6.0 <0.8.0;

library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
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
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeERC20: decreased allowance below zero"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}


pragma solidity =0.7.6;

interface ILiquidVestingToken {

    enum AddType {
        MerkleTree,
        Airdrop
    }

    function initialize(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        address _owner,
        address _factory,
        address _redeemToken,
        uint256 _activationTimestamp,
        uint256 _redeemTimestamp,
        AddType _type
    ) external;


    function overrideFee(uint256 _newFee) external;


    function addRecipient(address _recipient, uint256 _amount) external;


    function addRecipients(
        address[] memory _recipients,
        uint256[] memory _amounts
    ) external;


    function addMerkleRoot(
        bytes32 _merkleRoot,
        uint256 _totalAmount,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external;


    function claimTokensByMerkleProof(
        bytes32[] memory _proof,
        uint256 _rootId,
        address _recipient,
        uint256 _amount
    ) external;


    function claimProjectTokensByFeeCollector() external;


    function redeem(address _recipient, uint256 _amount) external;

}


pragma solidity =0.7.6;
pragma abicoder v2;

interface ILiquidVestingTokenFactory {

    function merkleRootSigner() external view returns (address);


    function feeCollector() external view returns (address);


    function fee() external view returns (uint256);


    function getMinFee() external pure returns (uint256);


    function getMaxFee() external pure returns (uint256);


    function setMerkleRootSigner(address _newMerkleRootSigner) external;


    function setFeeCollector(address _newFeeCollector) external;


    function setFee(uint256 _fee) external;


    function implementation() external view returns (address);


    function createLiquidVestingToken(
        string[] memory name,
        string[] memory symbol,
        address redeemToken,
        uint256[] memory activationTimestamp,
        uint256[] memory redeemTimestamp,
        ILiquidVestingToken.AddType addRecipientsType
    ) external;

}


pragma solidity =0.7.6;

contract LiquidVestingToken is
    ERC20Upgradeable,
    OwnableUpgradeable,
    ILiquidVestingToken
{

    using SafeMathUpgradeable for uint256;
    using SafeERC20 for IERC20;

    uint256 constant PERSENTAGE_RATE = 100000;

    bytes32 public domainSeparator;
    bytes32[] public merkleRoots;
    IERC20 public redeemToken;
    uint256 public overridenFee;
    uint256 public activationTimestamp;
    uint256 public redeemTimestamp;
    address public factory;
    AddType public addRecipientsType;

    mapping(bytes32 => mapping(address => bool)) private merkleRootSpent;

    event Redeemed(address indexed to, uint256 amount);
    event ClaimedByFeeCollector(address indexed to, uint256 amount);

    modifier inType(AddType _type) {

        require(addRecipientsType == _type, "Types do not match");
        _;
    }

    modifier onlyAfterActivation() {

        require(
            block.timestamp >= activationTimestamp,
            "Cannot transfer before activation timestamp"
        );
        _;
    }

    modifier onlyAfterRedeemTimestampHasPassed() {

        require(
            block.timestamp >= redeemTimestamp,
            "Cannot redeem tokens before unlock timestamp"
        );
        _;
    }

    function initialize(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        address _owner,
        address _factory,
        address _redeemToken,
        uint256 _activationTimestamp,
        uint256 _redeemTimestamp,
        AddType _type
    ) external override initializer {

        __Ownable_init();
        transferOwnership(_owner);

        __ERC20_init(_name, _symbol);

        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        domainSeparator = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes(_name)),
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );

        _setupDecimals(_decimals);
        factory = _factory;
        redeemToken = IERC20(_redeemToken);
        addRecipientsType = _type;
        activationTimestamp = _activationTimestamp;
        redeemTimestamp = _redeemTimestamp;
    }

    function overrideFee(uint256 _newFee) external override {

        require(
            _msgSender() == ILiquidVestingTokenFactory(factory).feeCollector(),
            "Caller is not fee collector"
        );
        require(
            _newFee >= ILiquidVestingTokenFactory(factory).getMinFee() &&
                _newFee <= ILiquidVestingTokenFactory(factory).getMaxFee(),
            "Fee goes beyond rank"
        );

        overridenFee = _newFee;
    }

    function addRecipient(address _recipient, uint256 _amount)
        external
        override
        onlyOwner
        inType(AddType.Airdrop)
    {

        require(_recipient != address(0), "Recipient cannot be zero address");

        redeemToken.safeTransferFrom(_msgSender(), address(this), _amount);

        mintTokens(_recipient, _amount);
    }

    function addRecipients(
        address[] memory _recipients,
        uint256[] memory _amounts
    ) external override onlyOwner inType(AddType.Airdrop) {

        require(
            _recipients.length == _amounts.length,
            "Recipients should be the same length with amounts"
        );
        uint256 totalAmount;

        for (uint256 i = 0; i < _recipients.length; i++) {
            totalAmount = totalAmount.add(_amounts[i]);
            mintTokens(_recipients[i], _amounts[i]);
        }
        redeemToken.safeTransferFrom(_msgSender(), address(this), totalAmount);
    }

    function addMerkleRoot(
        bytes32 _merkleRoot,
        uint256 _totalAmount,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external override onlyOwner inType(AddType.MerkleTree) {

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                domainSeparator,
                keccak256(abi.encode(_merkleRoot, _totalAmount))
            )
        );

        address recoveredAddress = ecrecover(digest, _v, _r, _s);

        require(
            recoveredAddress != address(0) &&
                recoveredAddress ==
                ILiquidVestingTokenFactory(factory).merkleRootSigner(),
            "Invalid signature"
        );

        for (uint256 i = 0; i < merkleRoots.length; i++) {
            require(merkleRoots[i] != _merkleRoot, "Merkle root is exist");
        }

        redeemToken.safeTransferFrom(_msgSender(), address(this), _totalAmount);

        merkleRoots.push(_merkleRoot);
    }

    function claimTokensByMerkleProof(
        bytes32[] memory _proof,
        uint256 _rootId,
        address _recipient,
        uint256 _amount
    ) external override inType(AddType.MerkleTree) {

        require(_recipient != address(0), "Recipient cannot be zero address");
        require(
            _rootId < merkleRoots.length,
            "Merkle root with this index does not exists"
        );
        bytes32 root = merkleRoots[_rootId];
        require(
            merkleRootSpent[root][_recipient] != true,
            "User can claim tokens only once"
        );

        require(
            checkProof(
                _proof,
                leafFromAddressAndNumTokens(_recipient, _amount),
                root
            ),
            "Invalid proof"
        );

        mintTokens(_recipient, _amount);

        merkleRootSpent[root][_recipient] = true;

        if (block.timestamp >= redeemTimestamp) {
            redeem(_recipient, _amount);
        }
    }

    function claimProjectTokensByFeeCollector() external override {

        uint256 timestampForClaiming = 365 days;
        require(
            block.timestamp >= redeemTimestamp.add(timestampForClaiming),
            "Cannot claim project tokens before allowed date"
        );
        address feeCollector = ILiquidVestingTokenFactory(factory)
            .feeCollector();
        require(
            _msgSender() == feeCollector,
            "Cannot claim project tokens if caller is not fee collector"
        );

        uint256 amount = redeemToken.balanceOf(address(this));
        redeemToken.safeTransfer(feeCollector, amount);
        emit ClaimedByFeeCollector(feeCollector, amount);
    }

    function redeem(address _recipient, uint256 _amount)
        public
        override
        onlyAfterRedeemTimestampHasPassed
    {

        require(_recipient != address(0), "Recipient cannot be zero address");
        require(_amount > 0, "Amount should be more than 0");

        uint256 amount = IERC20(address(this)).balanceOf(_recipient);
        require(
            _amount <= amount,
            "Cannot burn more than available amount of tokens"
        );

        _burn(_recipient, _amount);

        redeemToken.safeTransfer(_recipient, _amount);

        emit Redeemed(_recipient, _amount);
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        onlyAfterActivation
        returns (bool)
    {

        uint256 feeFromAmount;

        if (overridenFee == 0) {
            feeFromAmount = amount
                .mul(ILiquidVestingTokenFactory(factory).fee())
                .div(PERSENTAGE_RATE);
        } else {
            feeFromAmount = amount.mul(overridenFee).div(PERSENTAGE_RATE);
        }

        super.transfer(
            ILiquidVestingTokenFactory(factory).feeCollector(),
            feeFromAmount
        );
        super.transfer(recipient, amount.sub(feeFromAmount));
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override onlyAfterActivation returns (bool) {

        uint256 feeFromAmount;

        if (overridenFee == 0) {
            feeFromAmount = amount
                .mul(ILiquidVestingTokenFactory(factory).fee())
                .div(PERSENTAGE_RATE);
        } else {
            feeFromAmount = amount.mul(overridenFee).div(PERSENTAGE_RATE);
        }

        super.transferFrom(
            sender,
            ILiquidVestingTokenFactory(factory).feeCollector(),
            feeFromAmount
        );
        super.transferFrom(sender, recipient, amount.sub(feeFromAmount));
        return true;
    }

    function mintTokens(address _recipient, uint256 _amount) internal {

        require(_amount > 0, "Amount should be more than 0");

        _mint(_recipient, _amount);
    }

    function checkProof(
        bytes32[] memory proof,
        bytes32 hash,
        bytes32 root
    ) internal pure returns (bool) {

        bytes32 el;
        bytes32 h = hash;

        for (uint256 i = 0; i <= proof.length - 1; i += 1) {
            el = proof[i];

            if (h < el) {
                h = keccak256(abi.encode(h, el));
            } else {
                h = keccak256(abi.encode(el, h));
            }
        }
        return h == root;
    }

    function leafFromAddressAndNumTokens(address _a, uint256 _n)
        internal
        pure
        returns (bytes32)
    {

        return keccak256(abi.encode(0x01, _a, _n));
    }
}