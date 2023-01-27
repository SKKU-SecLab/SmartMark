
pragma solidity 0.5.17;


interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

}

library SafeMath {

    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x + y) >= x, "MATH:ADD_OVERFLOW");
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x - y) <= x, "MATH:SUB_UNDERFLOW");
    }
}

contract ANTv2 is IERC20 {

    using SafeMath for uint256;

    bytes32 private constant EIP712DOMAIN_HASH = 0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f;
    bytes32 private constant NAME_HASH = 0x711a8013284a3c0046af6c0d6ed33e8bbc2c7a11d615cf4fdc8b1ac753bda618;
    bytes32 private constant VERSION_HASH = 0xc89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc6;

    bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    bytes32 public constant TRANSFER_WITH_AUTHORIZATION_TYPEHASH = 0x7c7c6cdb67a18743f49ec6fa9b35f50d52ed05cbed4cc592e13b44501c1a2267;

    string public constant name = "Aragon Network Token";
    string public constant symbol = "ANT";
    uint8 public constant decimals = 18;

    address public minter;
    uint256 public totalSupply;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    mapping (address => uint256) public nonces;
    mapping (address => mapping (bytes32 => bool)) public authorizationState;

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event AuthorizationUsed(address indexed authorizer, bytes32 indexed nonce);
    event ChangeMinter(address indexed minter);

    modifier onlyMinter {

        require(msg.sender == minter, "ANTV2:NOT_MINTER");
        _;
    }

    constructor(address initialMinter) public {
        _changeMinter(initialMinter);
    }

    function _validateSignedData(address signer, bytes32 encodeData, uint8 v, bytes32 r, bytes32 s) internal view {

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                getDomainSeparator(),
                encodeData
            )
        );
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == signer, "ANTV2:INVALID_SIGNATURE");
    }

    function _changeMinter(address newMinter) internal {

        minter = newMinter;
        emit ChangeMinter(newMinter);
    }

    function _mint(address to, uint256 value) internal {

        totalSupply = totalSupply.add(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint value) internal {

        balanceOf[from] = balanceOf[from].sub(value);
        totalSupply = totalSupply.sub(value);
        emit Transfer(from, address(0), value);
    }

    function _approve(address owner, address spender, uint256 value) private {

        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(address from, address to, uint256 value) private {

        require(to != address(this) && to != address(0), "ANTV2:RECEIVER_IS_TOKEN_OR_ZERO");

        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(from, to, value);
    }

    function getChainId() public pure returns (uint256 chainId) {

        assembly { chainId := chainid() }
    }

    function getDomainSeparator() public view returns (bytes32) {

        return keccak256(
            abi.encode(
                EIP712DOMAIN_HASH,
                NAME_HASH,
                VERSION_HASH,
                getChainId(),
                address(this)
            )
        );
    }

    function mint(address to, uint256 value) external onlyMinter returns (bool) {

        _mint(to, value);
        return true;
    }

    function changeMinter(address newMinter) external onlyMinter {

        _changeMinter(newMinter);
    }

    function burn(uint256 value) external returns (bool) {

        _burn(msg.sender, value);
        return true;
    }

    function approve(address spender, uint256 value) external returns (bool) {

        _approve(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint256 value) external returns (bool) {

        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool) {

        uint256 fromAllowance = allowance[from][msg.sender];
        if (fromAllowance != uint256(-1)) {
            allowance[from][msg.sender] = fromAllowance.sub(value);
        }
        _transfer(from, to, value);
        return true;
    }

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external {

        require(deadline >= block.timestamp, "ANTV2:AUTH_EXPIRED");

        bytes32 encodeData = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline));
        _validateSignedData(owner, encodeData, v, r, s);

        _approve(owner, spender, value);
    }

    function transferWithAuthorization(
        address from,
        address to,
        uint256 value,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
    {

        require(block.timestamp > validAfter, "ANTV2:AUTH_NOT_YET_VALID");
        require(block.timestamp < validBefore, "ANTV2:AUTH_EXPIRED");
        require(!authorizationState[from][nonce],  "ANTV2:AUTH_ALREADY_USED");

        bytes32 encodeData = keccak256(abi.encode(TRANSFER_WITH_AUTHORIZATION_TYPEHASH, from, to, value, validAfter, validBefore, nonce));
        _validateSignedData(from, encodeData, v, r, s);

        authorizationState[from][nonce] = true;
        emit AuthorizationUsed(from, nonce);

        _transfer(from, to, value);
    }
}

contract ANTv2MultiMinter {

    string private constant ERROR_NOT_OWNER = "ANTV2_MM:NOT_OWNER";
    string private constant ERROR_NOT_MINTER = "ANTV2_MM:NOT_MINTER";

    address public owner;
    ANTv2 public ant;

    mapping (address => bool) public canMint;

    event AddedMinter(address indexed minter);
    event RemovedMinter(address indexed minter);
    event ChangedOwner(address indexed newOwner);

    modifier onlyOwner {

        require(msg.sender == owner, ERROR_NOT_OWNER);
        _;
    }

    modifier onlyMinter {

        require(canMint[msg.sender] || msg.sender == owner, ERROR_NOT_MINTER);
        _;
    }

    constructor(address _owner, ANTv2 _ant) public {
        owner = _owner;
        ant = _ant;
    }

    function mint(address to, uint256 value) external onlyMinter returns (bool) {

        return ant.mint(to, value);
    }

    function addMinter(address minter) external onlyOwner {

        canMint[minter] = true;

        emit AddedMinter(minter);
    }

    function removeMinter(address minter) external onlyOwner {

        canMint[minter] = false;

        emit RemovedMinter(minter);
    }

    function changeMinter(address newMinter) onlyOwner external {

        ant.changeMinter(newMinter);
    }

    function changeOwner(address newOwner) onlyOwner external {

        _changeOwner(newOwner);
    }

    function _changeOwner(address newOwner) internal {

        owner = newOwner;
        
        emit ChangedOwner(newOwner);
    }
}