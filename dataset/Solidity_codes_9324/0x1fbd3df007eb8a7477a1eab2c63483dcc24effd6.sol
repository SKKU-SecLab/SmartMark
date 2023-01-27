
pragma solidity 0.8.3;

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

contract EIP712Base {

    struct EIP712Domain {
        string name;
        string version;
        address verifyingContract;
        bytes32 salt;
    }

    bytes32 internal constant EIP712_DOMAIN_TYPEHASH =
        keccak256(
            bytes(
                "EIP712Domain(string name,string version,address verifyingContract,bytes32 salt)"
            )
        );
    bytes32 internal domainSeperator;

    constructor(string memory name) {
        domainSeperator = keccak256(
            abi.encode(
                EIP712_DOMAIN_TYPEHASH,
                keccak256(bytes(name)),
                keccak256(bytes("1")),
                address(this),
                bytes32(getChainId())
            )
        );
    }

    function getDomainSeperator() public view returns (bytes32) {

        return domainSeperator;
    }

    function getChainId() public view returns (uint256) {

        return block.chainid;
    }

    function toTypedMessageHash(bytes32 messageHash)
        internal
        view
        returns (bytes32)
    {

        return
            keccak256(
                abi.encodePacked("\x19\x01", getDomainSeperator(), messageHash)
            );
    }
}

abstract contract NativeMetaTransaction is EIP712Base {
    bytes32 private constant META_TRANSACTION_TYPEHASH =
        keccak256(
            bytes(
                "MetaTransaction(uint256 nonce,address from,bytes functionSignature)"
            )
        );
    event MetaTransactionExecuted(
        address userAddress,
        address payable relayerAddress,
        bytes functionSignature
    );
    mapping(address => uint256) nonces;

    struct MetaTransaction {
        uint256 nonce;
        address from;
        bytes functionSignature;
    }

    function executeMetaTransaction(
        address userAddress,
        bytes memory functionSignature,
        bytes32 sigR,
        bytes32 sigS,
        uint8 sigV
    ) public payable returns (bytes memory) {
        MetaTransaction memory metaTx = MetaTransaction({
            nonce: nonces[userAddress],
            from: userAddress,
            functionSignature: functionSignature
        });

        require(
            verify(userAddress, metaTx, sigR, sigS, sigV),
            "Signer and signature do not match"
        );

        nonces[userAddress] = nonces[userAddress] + 1;

        emit MetaTransactionExecuted(
            userAddress,
            payable(msg.sender),
            functionSignature
        );

        (bool success, bytes memory returnData) = address(this).call(
            abi.encodePacked(functionSignature, userAddress)
        );
        require(success, "Function call not successful");

        return returnData;
    }

    function hashMetaTransaction(MetaTransaction memory metaTx)
        internal
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encode(
                    META_TRANSACTION_TYPEHASH,
                    metaTx.nonce,
                    metaTx.from,
                    keccak256(metaTx.functionSignature)
                )
            );
    }

    function getNonce(address user) public view returns (uint256 nonce) {
        nonce = nonces[user];
    }

    function verify(
        address signer,
        MetaTransaction memory metaTx,
        bytes32 sigR,
        bytes32 sigS,
        uint8 sigV
    ) internal view returns (bool) {
        require(signer != address(0), "NativeMetaTransaction: INVALID_SIGNER");
        return
            signer ==
            ecrecover(
                toTypedMessageHash(hashMetaTransaction(metaTx)),
                sigV,
                sigR,
                sigS
            );
    }
}

abstract contract ContextMixin {
    function msgSender() internal view returns (address payable sender) {
        if (msg.sender == address(this)) {
            bytes memory array = msg.data;
            uint256 index = msg.data.length;
            assembly {
                sender := and(
                    mload(add(array, index)),
                    0xffffffffffffffffffffffffffffffffffffffff
                )
            }
        } else {
            sender = payable(msg.sender);
        }
        return sender;
    }
}

abstract contract Context is ContextMixin {
    function _msgSender() internal view virtual returns (address) {
        return msgSender();
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract ERC20 is NativeMetaTransaction, Context, IERC20 {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) EIP712Base(name_) public {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return 18;
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

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        _approve(sender, _msgSender(), currentAllowance - amount);

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
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
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
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
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

}

abstract contract ERC20Burnable is Context, ERC20 {
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(
            currentAllowance >= amount,
            "ERC20: burn amount exceeds allowance"
        );
        _approve(account, _msgSender(), currentAllowance - amount);
        _burn(account, amount);
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
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
}

library UniswapV2Library {
    function sortTokens(address tokenA, address tokenB)
        internal
        pure
        returns (address token0, address token1)
    {
        require(tokenA != tokenB, "UniswapV2Library: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        require(token0 != address(0), "UniswapV2Library: ZERO_ADDRESS");
    }

    function pairFor(
        bytes32 initCodeHash,
        address factory,
        address tokenA,
        address tokenB
    ) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            hex"ff",
                            factory,
                            keccak256(abi.encodePacked(token0, token1)),
                            initCodeHash // init code hash
                        )
                    )
                )
            )
        );
    }
}


library UniswapV3Library {
    bytes32 internal constant POOL_INIT_CODE_HASH =
        0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54;

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

    function computeAddress(address factory, PoolKey memory key)
        internal
        pure
        returns (address pool)
    {
        require(key.token0 < key.token1);
        pool = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            hex"ff",
                            factory,
                            keccak256(
                                abi.encode(key.token0, key.token1, key.fee)
                            ),
                            POOL_INIT_CODE_HASH
                        )
                    )
                )
            )
        );
    }
}

interface IPLPS {
    function LiquidityProtection_beforeTokenTransfer(
        address _pool,
        address _from,
        address _to,
        uint256 _amount
    ) external;

    function isBlocked(address _pool, address _who)
        external
        view
        returns (bool);

    function unblock(address _pool, address _who) external;
}

abstract contract UsingLiquidityProtectionService {
    bool private protected = true;
    uint64 internal constant HUNDRED_PERCENT = 1e18;
    bytes32 internal constant UNISWAP =
        0x96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f;
    bytes32 internal constant PANCAKESWAP =
        0x00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5;
    bytes32 internal constant QUICKSWAP =
        0x96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f;

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

    function token_transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual;

    function token_balanceOf(address holder)
        internal
        view
        virtual
        returns (uint256);

    function protectionAdminCheck() internal view virtual;

    function liquidityProtectionService()
        internal
        pure
        virtual
        returns (address);

    function uniswapVariety() internal pure virtual returns (bytes32);

    function uniswapVersion() internal pure virtual returns (UniswapVersion);

    function uniswapFactory() internal pure virtual returns (address);

    function counterToken() internal pure virtual returns (address) {
        return 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // WETH
    }

    function uniswapV3Fee() internal pure virtual returns (UniswapV3Fees) {
        return UniswapV3Fees._03;
    }

    function protectionChecker() internal view virtual returns (bool) {
        return ProtectionSwitch_manual();
    }

    function lps() private pure returns (IPLPS) {
        return IPLPS(liquidityProtectionService());
    }

    function LiquidityProtection_beforeTokenTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) internal virtual {
        if (protectionChecker()) {
            if (!protected) {
                return;
            }
            lps().LiquidityProtection_beforeTokenTransfer(
                getLiquidityPool(),
                _from,
                _to,
                _amount
            );
        }
    }

    function revokeBlocked(address[] calldata _holders, address _revokeTo)
        external
        onlyProtectionAdmin()
    {
        require(
            protectionChecker(),
            "UsingLiquidityProtectionService: protection removed"
        );
        protected = false;
        address pool = getLiquidityPool();
        for (uint256 i = 0; i < _holders.length; i++) {
            address holder = _holders[i];
            if (lps().isBlocked(pool, holder)) {
                token_transfer(holder, _revokeTo, token_balanceOf(holder));
            }
        }
        protected = true;
    }

    function LiquidityProtection_unblock(address[] calldata _holders)
        external
        onlyProtectionAdmin()
    {
        require(
            protectionChecker(),
            "UsingLiquidityProtectionService: protection removed"
        );
        address pool = getLiquidityPool();
        for (uint256 i = 0; i < _holders.length; i++) {
            lps().unblock(pool, _holders[i]);
        }
    }

    function disableProtection() external onlyProtectionAdmin() {
        protected = false;
    }

    function isProtected() public view returns (bool) {
        return protected;
    }

    function ProtectionSwitch_manual() internal view returns (bool) {
        return protected;
    }

    function ProtectionSwitch_timestamp(uint256 _timestamp)
        internal
        view
        returns (bool)
    {
        return not(passed(_timestamp));
    }

    function ProtectionSwitch_block(uint256 _block)
        internal
        view
        returns (bool)
    {
        return not(blockPassed(_block));
    }

    function blockPassed(uint256 _block) internal view returns (bool) {
        return _block < block.number;
    }

    function passed(uint256 _timestamp) internal view returns (bool) {
        return _timestamp < block.timestamp;
    }

    function not(bool _condition) internal pure returns (bool) {
        return !_condition;
    }

    function feeToUint24(UniswapV3Fees _fee) internal pure returns (uint24) {
        if (_fee == UniswapV3Fees._03) return 3000;
        if (_fee == UniswapV3Fees._005) return 500;
        return 10000;
    }

    function getLiquidityPool() public view returns (address) {
        if (uniswapVersion() == UniswapVersion.V2) {
            return
                UniswapV2Library.pairFor(
                    uniswapVariety(),
                    uniswapFactory(),
                    address(this),
                    counterToken()
                );
        }
        require(
            uniswapVariety() == UNISWAP,
            "LiquidityProtection: uniswapVariety() can only be UNISWAP for V3."
        );
        return
            UniswapV3Library.computeAddress(
                uniswapFactory(),
                UniswapV3Library.getPoolKey(
                    address(this),
                    counterToken(),
                    feeToUint24(uniswapV3Fee())
                )
            );
    }
}

contract ScaleSwapToken is
    ERC20Burnable,
    Ownable,
    UsingLiquidityProtectionService
{
    function token_transfer(
        address _from,
        address _to,
        uint256 _amount
    ) internal override {
        _transfer(_from, _to, _amount); // Expose low-level token transfer function.
    }

    function token_balanceOf(address _holder)
        internal
        view
        override
        returns (uint256)
    {
        return balanceOf(_holder); // Expose balance check function.
    }

    function protectionAdminCheck() internal view override onlyOwner {} // Must revert to deny access.

    function liquidityProtectionService()
        internal
        pure
        override
        returns (address)
    {
        return 0x0d0e7c27D25160231A4ce475CB9b296A41Aea329;
    }

    function uniswapVariety() internal pure override returns (bytes32) {
        return UNISWAP; // UNISWAP / PANCAKESWAP / QUICKSWAP.
    }

    function uniswapVersion() internal pure override returns (UniswapVersion) {
        return UniswapVersion.V2; // V2 or V3.
    }

    function uniswapFactory() internal pure override returns (address) {
        return 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    }

    function _beforeTokenTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) internal override {
        super._beforeTokenTransfer(_from, _to, _amount);
        LiquidityProtection_beforeTokenTransfer(_from, _to, _amount);
    }


    function protectionChecker() internal view override returns(bool) {
        return ProtectionSwitch_timestamp(1626998399); // Switch off protection on Thursday, July 22, 2021 11:59:59 PM GTM.
    }

    function counterToken() internal pure override returns (address) {
        return 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // WETH
    }

    constructor() ERC20("ScaleSwapToken", "SCA") {
        _mint(owner(), 25000000 * 1e18);
    }
}