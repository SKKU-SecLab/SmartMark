
pragma solidity 0.6.12;

library SafeMath {

    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x + y) >= x, "MATH:ADD_OVERFLOW");
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x - y) <= x, "MATH:SUB_UNDERFLOW");
    }
}


interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

}

interface IFlashMinter {

    function executeOnFlashMint(bytes calldata data) external;

}

contract FlashToken is IERC20 {

    using SafeMath for uint256;

    bytes32 private constant EIP712DOMAIN_HASH = 0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f;

    bytes32 private constant NAME_HASH = 0x345b72c36b14f1cee01efb8ac4b299dc7b8d873e28b4796034548a3d371a4d2f;

    bytes32 private constant VERSION_HASH = 0xc89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc6;

    bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;

    bytes32 public constant TRANSFER_WITH_AUTHORIZATION_TYPEHASH = 0x7c7c6cdb67a18743f49ec6fa9b35f50d52ed05cbed4cc592e13b44501c1a2267;

    string public constant name = "Flash Token";
    string public constant symbol = "FLASH";
    uint8 public constant decimals = 18;

    uint256 public override totalSupply;
    uint256 public flashSupply;

    mapping(address => bool) public minters;

    mapping(address => uint256) public override balanceOf;
    mapping(address => mapping(address => uint256)) public override allowance;

    mapping(address => uint256) public nonces;
    mapping(address => mapping(bytes32 => bool)) public authorizationState;

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event AuthorizationUsed(address indexed authorizer, bytes32 indexed nonce);

    modifier onlyMinter {

        require(minters[msg.sender] == true, "FlashToken:: NOT_MINTER");
        _;
    }

    constructor(address flashProtocol, address flashClaim) public {
        minters[flashProtocol] = true;
        minters[flashClaim] = true;
    }

    function _validateSignedData(
        address signer,
        bytes32 encodeData,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal view {

        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", getDomainSeparator(), encodeData));
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == signer, "FlashToken:: INVALID_SIGNATURE");
    }

    function _mint(address to, uint256 value) internal {

        totalSupply = totalSupply.add(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint256 value) internal {

        balanceOf[from] = balanceOf[from].sub(value);
        totalSupply = totalSupply.sub(value);
        emit Transfer(from, address(0), value);
    }

    function _approve(
        address owner,
        address spender,
        uint256 value
    ) private {

        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(
        address from,
        address to,
        uint256 value
    ) private {

        require(to != address(this) && to != address(0), "FlashToken:: RECEIVER_IS_TOKEN_OR_ZERO");

        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(from, to, value);
    }

    function getChainId() public pure returns (uint256 chainId) {

        assembly {
            chainId := chainid()
        }
    }

    function getDomainSeparator() public view returns (bytes32) {

        return keccak256(abi.encode(EIP712DOMAIN_HASH, NAME_HASH, VERSION_HASH, getChainId(), address(this)));
    }

    function mint(address to, uint256 value) external onlyMinter returns (bool) {

        _mint(to, value);
        return true;
    }

    function burn(uint256 value) external returns (bool) {

        _burn(msg.sender, value);
        return true;
    }

    function approve(address spender, uint256 value) external override returns (bool) {

        _approve(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint256 value) external override returns (bool) {

        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external override returns (bool) {

        uint256 fromAllowance = allowance[from][msg.sender];
        if (fromAllowance != uint256(-1)) {
            allowance[from][msg.sender] = fromAllowance.sub(value);
        }
        _transfer(from, to, value);
        return true;
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {

        require(deadline >= block.timestamp, "FlashToken:: AUTH_EXPIRED");

        bytes32 encodeData = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner], deadline));
        nonces[owner] = nonces[owner].add(1);
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
    ) external {

        require(block.timestamp > validAfter, "FlashToken:: AUTH_NOT_YET_VALID");
        require(block.timestamp < validBefore, "FlashToken:: AUTH_EXPIRED");
        require(!authorizationState[from][nonce], "FlashToken:: AUTH_ALREADY_USED");

        bytes32 encodeData = keccak256(abi.encode(TRANSFER_WITH_AUTHORIZATION_TYPEHASH, from, to, value, validAfter, validBefore, nonce));
        _validateSignedData(from, encodeData, v, r, s);

        authorizationState[from][nonce] = true;
        emit AuthorizationUsed(from, nonce);

        _transfer(from, to, value);
    }

    function flashMint(uint256 value, bytes calldata data) external {

        flashSupply = flashSupply.add(value);
        require(flashSupply <= type(uint112).max, "FlashToken:: SUPPLY_LIMIT_EXCEED");
        balanceOf[msg.sender] = balanceOf[msg.sender].add(value);
        emit Transfer(address(0), msg.sender, value);

        IFlashMinter(msg.sender).executeOnFlashMint(data);

        require(balanceOf[msg.sender] >= value, "FlashToken:: TRANSFER_EXCEED_BALANCE");
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(value);
        flashSupply = flashSupply.sub(value);
        emit Transfer(msg.sender, address(0), value);
    }
}