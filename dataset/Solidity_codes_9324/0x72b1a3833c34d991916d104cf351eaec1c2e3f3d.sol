

pragma solidity 0.8.9;

abstract contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    modifier onlyOwner() {
        require(owner == msg.sender, 'NOT_OWNER');
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), 'ZERO_ADDR');

        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

interface IERC20BurnFrom {

    function burnFrom(address account, uint256 amount) external;

}

contract EternalStorage {

    mapping(bytes32 => uint256) private _uintStorage;
    mapping(bytes32 => string) private _stringStorage;
    mapping(bytes32 => address) private _addressStorage;
    mapping(bytes32 => bytes) private _bytesStorage;
    mapping(bytes32 => bool) private _boolStorage;
    mapping(bytes32 => int256) private _intStorage;

    function getUint(bytes32 key) public view returns (uint256) {

        return _uintStorage[key];
    }

    function getString(bytes32 key) public view returns (string memory) {

        return _stringStorage[key];
    }

    function getAddress(bytes32 key) public view returns (address) {

        return _addressStorage[key];
    }

    function getBytes(bytes32 key) public view returns (bytes memory) {

        return _bytesStorage[key];
    }

    function getBool(bytes32 key) public view returns (bool) {

        return _boolStorage[key];
    }

    function getInt(bytes32 key) public view returns (int256) {

        return _intStorage[key];
    }

    function _setUint(bytes32 key, uint256 value) internal {

        _uintStorage[key] = value;
    }

    function _setString(bytes32 key, string memory value) internal {

        _stringStorage[key] = value;
    }

    function _setAddress(bytes32 key, address value) internal {

        _addressStorage[key] = value;
    }

    function _setBytes(bytes32 key, bytes memory value) internal {

        _bytesStorage[key] = value;
    }

    function _setBool(bytes32 key, bool value) internal {

        _boolStorage[key] = value;
    }

    function _setInt(bytes32 key, int256 value) internal {

        _intStorage[key] = value;
    }

    function _deleteUint(bytes32 key) internal {

        delete _uintStorage[key];
    }

    function _deleteString(bytes32 key) internal {

        delete _stringStorage[key];
    }

    function _deleteAddress(bytes32 key) internal {

        delete _addressStorage[key];
    }

    function _deleteBytes(bytes32 key) internal {

        delete _bytesStorage[key];
    }

    function _deleteBool(bytes32 key) internal {

        delete _boolStorage[key];
    }

    function _deleteInt(bytes32 key) internal {

        delete _intStorage[key];
    }
}

contract DepositHandler {

    uint256 internal constant IS_NOT_LOCKED = uint256(0);
    uint256 internal constant IS_LOCKED = uint256(1);

    uint256 internal _lockedStatus = IS_NOT_LOCKED;

    modifier noReenter() {

        require(_lockedStatus == IS_NOT_LOCKED);

        _lockedStatus = IS_LOCKED;
        _;
        _lockedStatus = IS_NOT_LOCKED;
    }

    function execute(address callee, bytes calldata data)
        external
        noReenter
        returns (bool success, bytes memory returnData)
    {

        (success, returnData) = callee.call(data);
    }

    function destroy(address etherDestination) external noReenter {

        selfdestruct(payable(etherDestination));
    }
}

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
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract ERC20 is Context, IERC20 {

    mapping(address => uint256) public override balanceOf;

    mapping(address => mapping(address => uint256)) public override allowance;

    uint256 public override totalSupply;

    string public name;
    string public symbol;

    uint8 public immutable decimals;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) {
        name = name_;
        symbol = symbol_;
        decimals = decimals_;
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
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
        _approve(sender, _msgSender(), allowance[sender][_msgSender()] - amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, allowance[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, allowance[_msgSender()][spender] - subtractedValue);
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), 'ZERO_ADDR');
        require(recipient != address(0), 'ZERO_ADDR');

        _beforeTokenTransfer(sender, recipient, amount);

        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), 'ZERO_ADDR');

        _beforeTokenTransfer(address(0), account, amount);

        totalSupply += amount;
        balanceOf[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), 'ZERO_ADDR');

        _beforeTokenTransfer(account, address(0), amount);

        balanceOf[account] -= amount;
        totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), 'ZERO_ADDR');
        require(spender != address(0), 'ZERO_ADDR');

        allowance[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}

abstract contract ERC20Permit is ERC20 {
    bytes32 public DOMAIN_SEPARATOR;

    string private constant EIP191_PREFIX_FOR_EIP712_STRUCTURED_DATA = '\x19\x01';

    bytes32 private constant DOMAIN_TYPE_SIGNATURE_HASH =
        bytes32(0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f);

    bytes32 private constant PERMIT_SIGNATURE_HASH =
        bytes32(0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9);

    mapping(address => uint256) public nonces;

    constructor(string memory name) {
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                DOMAIN_TYPE_SIGNATURE_HASH,
                keccak256(bytes(name)),
                keccak256(bytes('1')),
                block.chainid,
                address(this)
            )
        );
    }

    function permit(
        address issuer,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        require(block.timestamp < deadline, 'EXPIRED');
        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, 'INV_S');
        require(v == 27 || v == 28, 'INV_V');

        bytes32 digest = keccak256(
            abi.encodePacked(
                EIP191_PREFIX_FOR_EIP712_STRUCTURED_DATA,
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(PERMIT_SIGNATURE_HASH, issuer, spender, value, nonces[issuer]++, deadline))
            )
        );

        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress == issuer, 'INV_SIG');

        _approve(issuer, spender, value);
    }
}

contract MintableCappedERC20 is ERC20, ERC20Permit, Ownable, IERC20BurnFrom {
    uint256 public cap;

    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals,
        uint256 capacity
    ) ERC20(name, symbol, decimals) ERC20Permit(name) Ownable() {
        cap = capacity;
    }

    function mint(address account, uint256 amount) public onlyOwner {
        uint256 capacity = cap;
        require(capacity == 0 || totalSupply + amount <= capacity, 'CAP_EXCEEDED');

        _mint(account, amount);
    }

    function burnFrom(address account, uint256 amount) external onlyOwner {
        _approve(account, owner, allowance[account][owner] - amount);
        _burn(account, amount);
    }
}

contract BurnableMintableCappedERC20 is MintableCappedERC20 {
    bytes32 private constant PREFIX_TOKEN_FROZEN =
        bytes32(0x1a7261d3a36c4ce4235d10859911c9444a6963a3591ec5725b96871d9810626b);

    bytes32 private constant KEY_ALL_TOKENS_FROZEN =
        bytes32(0x75a31d1ce8e5f9892188befc328d3b9bd3fa5037457e881abc21f388471b8d96);

    event Frozen(address indexed owner);
    event Unfrozen(address indexed owner);

    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals,
        uint256 capacity
    ) MintableCappedERC20(name, symbol, decimals, capacity) {}

    function depositAddress(bytes32 salt) public view returns (address) {
        return
            address(
                uint160(
                    uint256(
                        keccak256(
                            abi.encodePacked(
                                bytes1(0xff),
                                owner,
                                salt,
                                keccak256(abi.encodePacked(type(DepositHandler).creationCode))
                            )
                        )
                    )
                )
            );
    }

    function burn(bytes32 salt) public onlyOwner {
        address account = depositAddress(salt);
        _burn(account, balanceOf[account]);
    }

    function _beforeTokenTransfer(
        address,
        address,
        uint256
    ) internal view override {
        require(!EternalStorage(owner).getBool(KEY_ALL_TOKENS_FROZEN), 'IS_FROZEN');
        require(!EternalStorage(owner).getBool(keccak256(abi.encodePacked(PREFIX_TOKEN_FROZEN, symbol))), 'IS_FROZEN');
    }
}

contract TokenDeployer {
    function deployToken(
        string memory name,
        string memory symbol,
        uint8 decimals,
        uint256 cap,
        bytes32 salt
    ) external returns (address tokenAddress) {
        tokenAddress = address(new BurnableMintableCappedERC20{ salt: salt }(name, symbol, decimals, cap));
    }
}