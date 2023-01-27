
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

library Strings {

    bytes16 private constant alphabet = "0123456789abcdef";

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
            buffer[i] = alphabet[value & 0xf];
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


interface IAccessControl {

    function hasRole(bytes32 role, address account) external view returns (bool);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function grantRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function renounceRole(bytes32 role, address account) external;

}

abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping (address => bool) members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if(!hasRole(role, account)) {
            revert(string(abi.encodePacked(
                "AccessControl: account ",
                Strings.toHexString(uint160(account), 20),
                " is missing role ",
                Strings.toHexString(uint256(role), 32)
            )));
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
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
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

pragma solidity ^0.8.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}// MIT

pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;


    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;

}// MIT

pragma solidity ^0.8.0;


interface IERC1155Receiver is IERC165 {


    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        returns(bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns(bytes4);

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


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}// MIT

pragma solidity ^0.8.0;


contract Exchange is
    AccessControl,
    IERC721Receiver,
    IERC1155Receiver,
    ReentrancyGuard
{

    using SafeMath for uint256;

    struct NftTokenInfo {
        address tokenAddress;
        uint256 id;
        uint256 amount;
    }

    bytes32 public SIGNER_ROLE = keccak256("SIGNER_ROLE");

    event ExchangeMadeErc721(
        address seller,
        address buyer,
        address sellTokenAddress,
        uint256 sellId,
        uint256 sellAmount,
        address buyTokenAddress,
        uint256 buyId,
        uint256 buyAmount,
        address[] feeAddresses,
        uint256[] feeAmounts
    );
    event ExchangeMadeErc1155(
        address seller,
        address buyer,
        address sellTokenAddress,
        uint256 sellId,
        uint256 sellAmount,
        address buyTokenAddress,
        uint256 buyId,
        uint256 buyAmount,
        address[] feeAddresses,
        uint256[] feeAmounts
    );

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(SIGNER_ROLE, _msgSender());
    }

    function makeExchangeERC721(
        bytes32 idOrder,
        address[2] calldata SellerBuyer,
        NftTokenInfo calldata tokenToBuy,
        NftTokenInfo calldata tokenToSell,
        address[] calldata feeAddresses,
    	uint256[] calldata feeAmounts,
        bytes calldata signature
    ) external nonReentrant {

        require(
            tokenToBuy.tokenAddress != address(0) && tokenToBuy.amount == 0,
            "Exchange: Wrong tokenToBuy"
        );
        require(
            tokenToSell.tokenAddress != address(0) && tokenToSell.id == 0,
            "Exchange: Wrong tokenToSell"
        );
        require(
            feeAddresses.length == feeAmounts.length,
            "Exchange: Wrong fees"
        );
        _verifySigner(
            idOrder,
            SellerBuyer,
            tokenToBuy,
            tokenToSell,
            feeAddresses,
            feeAmounts,
            signature
        );

        IERC721(tokenToBuy.tokenAddress).safeTransferFrom(
            SellerBuyer[0],
            SellerBuyer[1],
            tokenToBuy.id
        );

        uint256 tokenToSeller = tokenToSell.amount;
        for (uint256 i = 0; i < feeAddresses.length; i = i.add(1)) {
            tokenToSeller = tokenToSeller.sub(uint256(feeAmounts[i]));
            IERC20(tokenToSell.tokenAddress).transferFrom(
                SellerBuyer[1],
                address(feeAddresses[i]),
                uint256(feeAmounts[i])
            );
        }
        IERC20(tokenToSell.tokenAddress).transferFrom(
            SellerBuyer[1],
            SellerBuyer[0],
            tokenToSeller
        );

        emit ExchangeMadeErc721(
            SellerBuyer[0],
            SellerBuyer[1],
            tokenToBuy.tokenAddress,
            tokenToBuy.id,
            tokenToBuy.amount,
            tokenToSell.tokenAddress,
            tokenToSell.id,
            tokenToSell.amount,
            feeAddresses,
            feeAmounts
        );
    }

    function makeExchangeERC1155(
        bytes32 idOrder,
        address[2] calldata SellerBuyer,
        NftTokenInfo calldata tokenToBuy,
        NftTokenInfo calldata tokenToSell,
        address[] calldata feeAddresses,
    	uint256[] calldata feeAmounts,
        bytes calldata signature
    ) external nonReentrant {

        require(
            tokenToBuy.tokenAddress != address(0),
            "Exchange: Wrong tokenToBuy"
        );
        require(
            tokenToSell.tokenAddress != address(0) && tokenToSell.id == 0,
            "Exchange: Wrong tokenToSell"
        );
        require(
            feeAddresses.length == feeAmounts.length,
            "Exchange: Wrong fees"
        );
        _verifySigner(
            idOrder,
            SellerBuyer,
            tokenToBuy,
            tokenToSell,
            feeAddresses,
            feeAmounts,
            signature
        );

        IERC1155(tokenToBuy.tokenAddress).safeTransferFrom(
            SellerBuyer[0],
            SellerBuyer[1],
            tokenToBuy.id,
            tokenToBuy.amount,
            ""
        );

        uint256 tokenToSeller = tokenToSell.amount;
        for (uint256 i = 0; i < feeAddresses.length; i = i.add(1)) {
            tokenToSeller = tokenToSeller.sub(feeAmounts[i]);
            IERC20(tokenToSell.tokenAddress).transferFrom(
                SellerBuyer[1],
                feeAddresses[i],
                feeAmounts[i]
            );
        }

        IERC20(tokenToSell.tokenAddress).transferFrom(
            SellerBuyer[1],
            SellerBuyer[0],
            tokenToSeller
        );

        emit ExchangeMadeErc1155(
            SellerBuyer[0],
            SellerBuyer[1],
            tokenToBuy.tokenAddress,
            tokenToBuy.id,
            tokenToBuy.amount,
            tokenToSell.tokenAddress,
            tokenToSell.id,
            tokenToSell.amount,
            feeAddresses,
            feeAmounts
        );
    }

    function _verifySigner(
        bytes32 idOrder,
        address[2] calldata SellerBuyer,
        NftTokenInfo calldata tokenToBuy,
        NftTokenInfo calldata tokenToSell,
        address[] calldata feeAddresses,
    	uint256[] calldata feeAmounts,
        bytes calldata signature
    ) private view {

        bytes memory message =
            abi.encodePacked(
                idOrder,
                SellerBuyer[0],
                tokenToBuy.tokenAddress,
                tokenToBuy.id,
                tokenToBuy.amount
            );
        message = abi.encodePacked(
            message,
            tokenToSell.tokenAddress,
            tokenToSell.amount
        );
        message = abi.encodePacked(
            message,
            feeAddresses,
            feeAmounts,
            SellerBuyer[1]
        );
        address messageSigner = ECDSA.recover(keccak256(message), signature);
        require(
            hasRole(SIGNER_ROLE, messageSigner),
            "Exchange: Signer should sign transaction"
        );
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {

        return IERC1155Receiver.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external pure override returns (bytes4) {

        return IERC1155Receiver.onERC1155BatchReceived.selector;
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {

        return IERC721Receiver.onERC721Received.selector;
    }
}