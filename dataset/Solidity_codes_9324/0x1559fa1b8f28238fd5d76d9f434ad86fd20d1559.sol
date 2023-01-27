
pragma solidity ^0.8.0;

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
}// MIT
pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;


interface IERC20Mintable is IERC20 {

    function mint(address dst, uint256 amount) external returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC20Burnable is IERC20 {

    function burn(uint256 amount) external returns (bool);

}// MIT
pragma solidity ^0.8.0;


interface IERC20Permit is IERC20 {

    function getDomainSeparator() external view returns (bytes32);

    function DOMAIN_TYPEHASH() external view returns (bytes32);

    function VERSION_HASH() external view returns (bytes32);

    function PERMIT_TYPEHASH() external view returns (bytes32);

    function nonces(address) external view returns (uint);

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;

}// MIT
pragma solidity ^0.8.0;


interface IERC20TransferWithAuth is IERC20 {

    function transferWithAuthorization(address from, address to, uint256 value, uint256 validAfter, uint256 validBefore, bytes32 nonce, uint8 v, bytes32 r, bytes32 s) external;

    function receiveWithAuthorization(address from, address to, uint256 value, uint256 validAfter, uint256 validBefore, bytes32 nonce, uint8 v, bytes32 r, bytes32 s) external;

    function TRANSFER_WITH_AUTHORIZATION_TYPEHASH() external view returns (bytes32);

    function RECEIVE_WITH_AUTHORIZATION_TYPEHASH() external view returns (bytes32);

    event AuthorizationUsed(address indexed authorizer, bytes32 indexed nonce);
}// MIT
pragma solidity ^0.8.0;


interface IERC20SafeAllowance is IERC20 {

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);

}// MIT
pragma solidity ^0.8.0;


interface IERC20Extended is 
    IERC20Metadata, 
    IERC20Mintable, 
    IERC20Burnable, 
    IERC20Permit,
    IERC20TransferWithAuth,
    IERC20SafeAllowance 
{}// MIT

pragma solidity ^0.8.0;


interface IEdenToken is IERC20Extended {

    function maxSupply() external view returns (uint256);

    function updateTokenMetadata(string memory tokenName, string memory tokenSymbol) external returns (bool);

    function metadataManager() external view returns (address);

    function setMetadataManager(address newMetadataManager) external returns (bool);

    event MetadataManagerChanged(address indexed oldManager, address indexed newManager);
    event TokenMetaUpdated(string indexed name, string indexed symbol);
}// MIT
pragma solidity ^0.8.0;

interface IAccessControl {

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

}// MIT
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;

library Strings {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}// MIT
pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT
pragma solidity ^0.8.0;


abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}// MIT
pragma solidity ^0.8.0;


contract EdenToken is AccessControl, IEdenToken {

    string public override name = "Eden";

    string public override symbol = "EDEN";

    uint8 public override constant decimals = 18;

    uint256 public override totalSupply;

    uint256 public constant override maxSupply = 250_000_000e18; // 250 million

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    address public override metadataManager;

    mapping (address => mapping (address => uint256)) public override allowance;

    mapping (address => uint256) public override balanceOf;

    bytes32 public constant override DOMAIN_TYPEHASH = 0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f;
    
    bytes32 public constant override VERSION_HASH = 0xc89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc6;

    bytes32 public constant override PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;

    bytes32 public constant override TRANSFER_WITH_AUTHORIZATION_TYPEHASH = 0x7c7c6cdb67a18743f49ec6fa9b35f50d52ed05cbed4cc592e13b44501c1a2267;

    bytes32 public constant override RECEIVE_WITH_AUTHORIZATION_TYPEHASH = 0xd099cc98ef71107a616c4f0f941f04c322d8e254fe26b3c6668db87aae413de8;

    mapping (address => uint) public override nonces;

    mapping (address => mapping (bytes32 => bool)) public authorizationState;

    constructor(address _admin) {
        metadataManager = _admin;
        emit MetadataManagerChanged(address(0), metadataManager);
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
    }

    function setMetadataManager(address newMetadataManager) external override returns (bool) {

        require(msg.sender == metadataManager, "Eden::setMetadataManager: only MM can change MM");
        emit MetadataManagerChanged(metadataManager, newMetadataManager);
        metadataManager = newMetadataManager;
        return true;
    }

    function mint(address dst, uint256 amount) external override returns (bool) {

        require(hasRole(MINTER_ROLE, msg.sender), "Eden::mint: only minters can mint");
        require(totalSupply + amount <= maxSupply, "Eden::mint: exceeds max supply");
        require(dst != address(0), "Eden::mint: cannot transfer to the zero address");

        totalSupply = totalSupply + amount;
        balanceOf[dst] = balanceOf[dst] + amount;
        emit Transfer(address(0), dst, amount);
        return true;
    }

    function burn(uint256 amount) external override returns (bool) {

        balanceOf[msg.sender] = balanceOf[msg.sender] - amount;
        totalSupply = totalSupply - amount;
        
        emit Transfer(msg.sender, address(0), amount);
        return true;
    }

    function updateTokenMetadata(string memory tokenName, string memory tokenSymbol) external override returns (bool) {

        require(msg.sender == metadataManager, "Eden::updateTokenMeta: only MM can update token metadata");
        name = tokenName;
        symbol = tokenSymbol;
        emit TokenMetaUpdated(name, symbol);
        return true;
    }

    function approve(address spender, uint256 amount) external override returns (bool) {

        _approve(msg.sender, spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        external override
        returns (bool)
    {

        _approve(
            msg.sender, 
            spender, 
            allowance[msg.sender][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external override
        returns (bool)
    {

        _approve(
            msg.sender,
            spender,
            allowance[msg.sender][spender] - subtractedValue
        );
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
    ) external override {

        require(deadline >= block.timestamp, "Eden::permit: signature expired");

        bytes32 encodeData = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline));
        _validateSignedData(owner, encodeData, v, r, s);

        _approve(owner, spender, value);
    }

    function transfer(address dst, uint256 amount) external override returns (bool) {

        _transferTokens(msg.sender, dst, amount);
        return true;
    }

    function transferFrom(address src, address dst, uint256 amount) external override returns (bool) {

        address spender = msg.sender;
        uint256 spenderAllowance = allowance[src][spender];

        if (spender != src && spenderAllowance != type(uint256).max) {
            uint256 newAllowance = spenderAllowance - amount;
            allowance[src][spender] = newAllowance;

            emit Approval(src, spender, newAllowance);
        }

        _transferTokens(src, dst, amount);
        return true;
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
    ) external override {

        require(block.timestamp > validAfter, "Eden::transferWithAuth: auth not yet valid");
        require(block.timestamp < validBefore, "Eden::transferWithAuth: auth expired");
        require(!authorizationState[from][nonce],  "Eden::transferWithAuth: auth already used");

        bytes32 encodeData = keccak256(abi.encode(TRANSFER_WITH_AUTHORIZATION_TYPEHASH, from, to, value, validAfter, validBefore, nonce));
        _validateSignedData(from, encodeData, v, r, s);

        authorizationState[from][nonce] = true;
        emit AuthorizationUsed(from, nonce);

        _transferTokens(from, to, value);
    }

    function receiveWithAuthorization(
        address from,
        address to,
        uint256 value,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override {

        require(to == msg.sender, "Eden::receiveWithAuth: caller must be the payee");
        require(block.timestamp > validAfter, "Eden::receiveWithAuth: auth not yet valid");
        require(block.timestamp < validBefore, "Eden::receiveWithAuth: auth expired");
        require(!authorizationState[from][nonce],  "Eden::receiveWithAuth: auth already used");

        bytes32 encodeData = keccak256(abi.encode(RECEIVE_WITH_AUTHORIZATION_TYPEHASH, from, to, value, validAfter, validBefore, nonce));
        _validateSignedData(from, encodeData, v, r, s);

        authorizationState[from][nonce] = true;
        emit AuthorizationUsed(from, nonce);

        _transferTokens(from, to, value);
    }

    function getDomainSeparator() public view override returns (bytes32) {

        return keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                keccak256(bytes(name)),
                VERSION_HASH,
                block.chainid,
                address(this)
            )
        );
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
        require(recoveredAddress != address(0) && recoveredAddress == signer, "Eden::validateSig: invalid signature");
    }

    function _approve(address owner, address spender, uint256 amount) internal {

        require(owner != address(0), "Eden::_approve: approve from the zero address");
        require(spender != address(0), "Eden::_approve: approve to the zero address");
        allowance[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transferTokens(address from, address to, uint256 value) internal {

        require(to != address(0), "Eden::_transferTokens: cannot transfer to the zero address");

        balanceOf[from] = balanceOf[from] - value;
        balanceOf[to] = balanceOf[to] + value;
        emit Transfer(from, to, value);
    }
}