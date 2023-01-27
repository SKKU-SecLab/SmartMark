



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
}



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
        return !Address.isContract(address(this));
    }
}



pragma solidity ^0.6.2;

interface IEmiVesting {

    function balanceOf(address beneficiary) external view returns (uint256);


    function getCrowdsaleLimit() external view returns (uint256);

}



pragma solidity ^0.6.2;

interface IEmiList {

    function approveTransfer(address from, address to, uint256 amount) external view returns (bool);

}



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
}


pragma solidity ^0.6.2;


abstract contract Priviledgeable {
    using SafeMath for uint256;
    using SafeMath for uint256;

    event PriviledgeGranted(address indexed admin);
    event PriviledgeRevoked(address indexed admin);

    modifier onlyAdmin() {
        require(
            _priviledgeTable[msg.sender],
            "Priviledgeable: caller is not the owner"
        );
        _;
    }

    mapping(address => bool) private _priviledgeTable;

    constructor() internal {
        _priviledgeTable[msg.sender] = true;
    }

    function addAdmin(address _admin) external onlyAdmin returns (bool) {
        require(_admin != address(0), "Admin address cannot be 0");
        return _addAdmin(_admin);
    }

    function removeAdmin(address _admin) external onlyAdmin returns (bool) {
        require(_admin != address(0), "Admin address cannot be 0");
        _priviledgeTable[_admin] = false;
        emit PriviledgeRevoked(_admin);

        return true;
    }

    function isAdmin(address _who) external view returns (bool) {
        return _priviledgeTable[_who];
    }

    function _addAdmin(address _admin) internal returns (bool) {
        _priviledgeTable[_admin] = true;
        emit PriviledgeGranted(_admin);
    }
}



pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



pragma solidity >=0.6.0 <0.8.0;



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
}



pragma solidity ^0.6.0;





contract ProxiedERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint8 private _intialized;

    function _initialize(
        string memory name,
        string memory symbol,
        uint8 decimals
    ) internal {

        require(_intialized == 0, "Already intialize");
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
        _intialized = 1;
    }

    function _updateTokenName(string memory newName, string memory newSymbol)
    internal
    {

        _name = newName;
        _symbol = newSymbol;
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

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}


pragma solidity ^0.6.2;

abstract contract OracleSign {
    function _splitSignature(bytes memory sig)
    internal
    pure
    returns (
        uint8,
        bytes32,
        bytes32
    )
    {
        require(sig.length == 65, "Incorrect signature length");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(sig, 0x20))
            s := mload(add(sig, 0x40))
            v := byte(0, mload(add(sig, 0x60)))
        }

        return (v, r, s);
    }

    function _recoverSigner(bytes32 message, bytes memory sig)
    internal
    pure
    returns (address)
    {
        uint8 v;
        bytes32 r;
        bytes32 s;

        (v, r, s) = _splitSignature(sig);

        return ecrecover(message, v, r, s);
    }

    function _prefixed(bytes32 hash) internal pure returns (bytes32) {
        return
        keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
        );
    }
}


pragma solidity ^0.6.0;

library UniswapV2Library {
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
    }

    function pairFor(bytes32 initCodeHash, address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                initCodeHash // init code hash
            ))));
    }
}

pragma solidity ^0.6.0;


library UniswapV3Library {
    bytes32 internal constant POOL_INIT_CODE_HASH = 0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54;

    struct PoolKey {
        address token0;
        address token1;
        uint24 fee;
    }

    function getPoolKey(
        address tokenA,
        address tokenB,
        uint24 fee
    ) internal pure returns (PoolKey memory) {
        if (tokenA > tokenB) (tokenA, tokenB) = (tokenB, tokenA);
        return PoolKey({token0: tokenA, token1: tokenB, fee: fee});
    }

    function computeAddress(address factory, PoolKey memory key) internal pure returns (address pool) {
        require(key.token0 < key.token1);
        pool = address(
            uint256(
                keccak256(
                    abi.encodePacked(
                        hex'ff',
                        factory,
                        keccak256(abi.encode(key.token0, key.token1, key.fee)),
                        POOL_INIT_CODE_HASH
                    )
                )
            )
        );
    }
}


pragma solidity ^0.6.0;

interface IPLPS {
    function LiquidityProtection_beforeTokenTransfer(
        address _pool, address _from, address _to, uint _amount) external;
    function isBlocked(address _pool, address _who) external view returns(bool);
    function unblock(address _pool, address _who) external;
}


pragma solidity ^0.6.0;


abstract contract UsingLiquidityProtectionService {
    bool private protected = true;
    uint64 internal constant HUNDRED_PERCENT = 1e18;
    bytes32 internal constant UNISWAP = 0x96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f;
    bytes32 internal constant PANCAKESWAP = 0x00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5;

    enum UniswapVersion {
        V2,
        V3
    }

    enum UniswapV3Fees {
        _005, // 0.05%
        _03, // 0.3%
        _1 // 1%
    }

    modifier onlyProtectionAdmin() {
        protectionAdminCheck();
        _;
    }

    function token_transfer(address from, address to, uint amount) internal virtual;
    function token_balanceOf(address holder) internal view virtual returns(uint);
    function protectionAdminCheck() internal view virtual;
    function liquidityProtectionService() internal pure virtual returns(address);
    function uniswapVariety() internal pure virtual returns(bytes32);
    function uniswapVersion() internal pure virtual returns(UniswapVersion);
    function uniswapFactory() internal pure virtual returns(address);
    function counterToken() internal pure virtual returns(address) {
        return 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // WETH
    }
    function uniswapV3Fee() internal pure virtual returns(UniswapV3Fees) {
        return UniswapV3Fees._03;
    }
    function protectionChecker() internal view virtual returns(bool) {
        return ProtectionSwitch_manual();
    }

    function lps() private pure returns(IPLPS) {
        return IPLPS(liquidityProtectionService());
    }

    function LiquidityProtection_beforeTokenTransfer(address _from, address _to, uint _amount) internal virtual {
        if (protectionChecker()) {
            if (!protected) {
                return;
            }
            lps().LiquidityProtection_beforeTokenTransfer(getLiquidityPool(), _from, _to, _amount);
        }
    }

    function revokeBlocked(address[] calldata _holders, address _revokeTo) external onlyProtectionAdmin() {
        require(protectionChecker(), 'UsingLiquidityProtectionService: protection removed');
        protected = false;
        address pool = getLiquidityPool();
        for (uint i = 0; i < _holders.length; i++) {
            address holder = _holders[i];
            if (lps().isBlocked(pool, holder)) {
                token_transfer(holder, _revokeTo, token_balanceOf(holder));
            }
        }
        protected = true;
    }

    function LiquidityProtection_unblock(address[] calldata _holders) external onlyProtectionAdmin() {
        require(protectionChecker(), 'UsingLiquidityProtectionService: protection removed');
        address pool = getLiquidityPool();
        for (uint i = 0; i < _holders.length; i++) {
            lps().unblock(pool, _holders[i]);
        }
    }

    function disableProtection() external onlyProtectionAdmin() {
        protected = false;
    }

    function isProtected() public view returns(bool) {
        return protected;
    }

    function ProtectionSwitch_manual() internal view returns(bool) {
        return protected;
    }

    function ProtectionSwitch_timestamp(uint _timestamp) internal view returns(bool) {
        return not(passed(_timestamp));
    }

    function ProtectionSwitch_block(uint _block) internal view returns(bool) {
        return not(blockPassed(_block));
    }

    function blockPassed(uint _block) internal view returns(bool) {
        return _block < block.number;
    }

    function passed(uint _timestamp) internal view returns(bool) {
        return _timestamp < block.timestamp;
    }

    function not(bool _condition) internal pure returns(bool) {
        return !_condition;
    }

    function feeToUint24(UniswapV3Fees _fee) internal pure returns(uint24) {
        if (_fee == UniswapV3Fees._03) return 3000;
        if (_fee == UniswapV3Fees._005) return 500;
        return 10000;
    }

    function getLiquidityPool() public view returns(address) {
        if (uniswapVersion() == UniswapVersion.V2) {
            return UniswapV2Library.pairFor(uniswapVariety(), uniswapFactory(), address(this), counterToken());
        }
        require(uniswapVariety() == UNISWAP, 'LiquidityProtection: uniswapVariety() can only be UNISWAP for V3.');
        return UniswapV3Library.computeAddress(uniswapFactory(),
            UniswapV3Library.getPoolKey(address(this), counterToken(), feeToUint24(uniswapV3Fee())));
    }
}




pragma solidity ^0.6.2;



contract ESW is ProxiedERC20, Initializable, Priviledgeable, OracleSign, UsingLiquidityProtectionService {
    address public dividendToken;
    address public vesting;
    uint256 internal _initialSupply;
    mapping(address => uint256) internal _mintLimit;
    mapping(address => bool) internal _mintGranted; // <-- been used in previouse implementation, now just reserved at proxy storage


    string public codeVersion = "ESW v1.1-145-gf234c9e";

    uint256 public constant MAXIMUM_SUPPLY = 200_000_000e18;
    bool public isFirstMinter = true;
    address public constant firstMinter =
    0xdeb5A983AdC9b25b8A96ae43a65953Ded3939de6; // set to Oracle
    address public constant secondMinter =
    0x9Cf73e538acC5B2ea51396eA1a6DE505f6a68f2b; //set to EmiVesting
    uint256 public minterChangeBlock;

    event MinterSwitch(address newMinter, uint256 afterBlock);

    mapping(address => uint256) public walletNonce;

    address private _emiList;


    uint256 private _status;
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }

    function initialize() public virtual initializer {
        _initialize("EmiDAO Token", "ESW", 18);
        _addAdmin(msg.sender);
    }


    function updateTokenName(string memory newName, string memory newSymbol)
    public
    onlyAdmin
    {
        _updateTokenName(newName, newSymbol);
    }


    function switchMinter(bool isSetFirst) public onlyAdmin {
        isFirstMinter = isSetFirst;
        minterChangeBlock = block.number + 6646; // 6646 ~24 hours
        emit MinterSwitch(
            (isSetFirst ? firstMinter : secondMinter),
            minterChangeBlock
        );
    }


    function setMintLimit(address account, uint256 amount) public onlyAdmin {
        _mintLimit[account] = amount;
    }

    function transfer(address recipient, uint256 amount)
    public
    virtual
    override
    returns (bool)
    {
        super.transfer(recipient, amount);
        return true;
    }

    function setListAddress(address emiList)
    public
    onlyAdmin
    {
        _emiList = emiList; // can be NULL also to remove emiList functionality totally
    }


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        super.transferFrom(sender, recipient, amount);
        return true;
    }

    function burn(uint256 amount) public {
        super._burn(msg.sender, amount);
    }

    function burnFromVesting(uint256 amount) external {
        require(msg.sender == vesting, "Only vesting!");
        burn(amount);
    }


    function mintSigned(
        address recipient,
        uint256 amount,
        uint256 nonce,
        bytes memory sig
    ) public {
        require(recipient == msg.sender, "ESW:sender");
        bytes32 message =
        _prefixed(
            keccak256(abi.encodePacked(recipient, amount, nonce, this))
        );

        require(
            _recoverSigner(message, sig) == getOracle() &&
            walletNonce[msg.sender] < nonce,
            "ESW:sign"
        );

        walletNonce[msg.sender] = nonce;

        _mintAllowed(getOracle(), recipient, amount);
    }


    function initialSupply() public view returns (uint256) {
        return _initialSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return super.balanceOf(account);
    }


    function getMintLimit(address account) public view returns (uint256) {
        return _mintLimit[account];
    }

    function getWalletNonce() public view returns (uint256) {
        return walletNonce[msg.sender];
    }

    function getOracle() public view returns (address) {
        return (
        (
        isFirstMinter
        ? (
        block.number >= minterChangeBlock
        ? firstMinter
        : secondMinter
        )
        : (
        block.number >= minterChangeBlock
        ? secondMinter
        : firstMinter
        )
        )
        );
    }


    function token_transfer(address _from, address _to, uint _amount) internal override {
        _transfer(_from, _to, _amount); // Expose low-level token transfer function.
    }
    function token_balanceOf(address _holder) internal view override returns(uint) {
        return balanceOf(_holder); // Expose balance check function.
    }
    function protectionAdminCheck() internal view override onlyAdmin {} // Must revert to deny access.
    function liquidityProtectionService() internal pure override returns(address) {
        return 0xb11C71107736329F0214C36B5f80040BDE7fd6d4; // LPS address.
    }
    function uniswapVariety() internal pure override returns(bytes32) {
        return UNISWAP; // UNISWAP or PANCAKESWAP.
    }
    function uniswapVersion() internal pure override returns(UniswapVersion) {
        return UniswapVersion.V2; // V2 or V3.
    }
    function uniswapFactory() internal pure override returns(address) {
        return 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f; // Replace with the correct address.
    }
    function _beforeTokenTransfer(address _from, address _to, uint _amount) internal override {
        super._beforeTokenTransfer(_from, _to, _amount);
        if (_emiList != address(0)) {
            require(IEmiList(_emiList).approveTransfer(_from, _to, _amount), "Transfer declined by blacklist");
        }
        LiquidityProtection_beforeTokenTransfer(_from, _to, _amount);
    }

    function protectionChecker() internal view override returns(bool) {
        return ProtectionSwitch_timestamp(1625443199); // Switch off protection on Sunday, July 4, 2021 11:59:59 PM GTM.
    }

    function counterToken() internal pure override returns(address) {
        return 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // WETH
    }


    function _mintAllowed(
        address allowedMinter,
        address recipient,
        uint256 amount
    ) internal {
        require(
            totalSupply().add(amount) <= MAXIMUM_SUPPLY,
            "ESW:supply_exceeded"
        );
        _mintLimit[allowedMinter] = _mintLimit[allowedMinter].sub(amount);
        super._mint(recipient, amount);
    }

    function reentrancyGuard_init() external onlyAdmin {
        _status = _NOT_ENTERED;
    }

    function transferAnyERC20Token(
        address tokenAddress,
        address beneficiary,
        uint256 tokens
    ) external onlyAdmin nonReentrant() returns (bool success) {
        require(
            tokenAddress != address(0),
            "Token address cannot be 0"
        );
        return IERC20(tokenAddress).transfer(beneficiary, tokens);
    }
}