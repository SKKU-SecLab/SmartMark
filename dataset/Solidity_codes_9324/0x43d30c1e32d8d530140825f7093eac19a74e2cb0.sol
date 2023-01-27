
pragma solidity ^0.8.0;


interface IUtils {


    enum OrderStatus {
        COMPLETED,
        OPEN,
        CANCELED,
        EXPIRED,
        INVALID
    }
    struct Order {
        uint256 orderId;
        address sender;
        uint256 askAmount;

        address currency;

        address nftContract;

        uint256 tokenId;

        uint256 expiryTime;

        address recipient;

        OrderStatus orderStatus;

        uint256 createdAt;

        uint256 updatedAt;
    }

    struct Bid {
        uint256 bidId;

        address sender;

        uint256 bidAmount;

        address currency;

        address nftContract;

        uint256 tokenId;

        uint256 expiryTime;

        address recipient;

        OrderStatus bidStatus;

        uint256 createdAt;

        uint256 updatedAt;
    }
}// MIT

pragma solidity ^0.8.0;



interface IMarket {

    struct Collaborators {
        address[] _collaborators;
        uint8[] _percentages;
        bool _receiveCollabShare;
    }

    event OrderCreated(uint256 indexed orderId, IUtils.Order order);
    event OrderCompleted(uint256 indexed orderId, IUtils.Order order);
    event OrderRemoved(uint256 indexed orderId, IUtils.Order order);

    event BidAdded(uint256 indexed bidId, IUtils.Bid bid);
    event BidAccepted(uint256 indexed bidId, IUtils.Bid bid);
    event BidRemoved(uint256 indexed bidId, IUtils.Bid bid);

    event CommissionUpdated(uint8 commissionPercentage);
    event UpdateAdminWallet(address indexed _oldWallet, address indexed _newAdminWallet);

    function setAdminAddress(address _newAdminAddress) external returns (bool);


    function setCommissionPercentage(uint8 _commissionPercentage)
        external
        returns (bool);

    function getCommissionPercentage() external view returns (uint8);


    function updateCurrency(address _tokenAddress, bool _status) external returns (bool);



    function updateNFTContract(address _tokenAddress, bool _status) external returns (bool);



    function setOrder(address _nftContract, uint256 _tokenId, address _currency, uint256 _askAmount, uint256 expiryTime) external;

    function getOrder(uint256 _orderId)
        external
        view
        returns (IUtils.Order memory);


    function cancelOrder(uint256 _orderId)
        external
        returns (bool);


    function completeOrder(uint256 _orderId)
        external
        returns (bool);


    function addBid(address _nftContract, uint256 _tokenId, address _currency, uint256 _bidAmount, uint256 expiryTime) external;

    function getBid(uint256 _bidId)
        external
        view
        returns (IUtils.Bid memory);


    function cancelBid(uint256 _bidId)
        external
        returns (bool);


    function acceptBid(uint256 _bidId)
        external
        returns (bool);


} //end of interface  marketplace// MIT

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


library ECDSA {

    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {

        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {

        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {

        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}// MIT

pragma solidity ^0.8.0;

interface IAccessControl {

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

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

    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    function _checkRole(bytes32 role, address account) internal view virtual {
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

    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
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

    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}// MIT

pragma solidity ^0.8.1;

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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}// MIT

pragma solidity ^0.8.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function approve(address to, uint256 tokenId) external;


    function setApprovalForAll(address operator, bool _approved) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function isApprovedForAll(address owner, address operator) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT

pragma solidity ^0.8.0;


contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {

    using Address for address;
    using Strings for uint256;

    string private _name;

    string private _symbol;

    mapping(uint256 => address) private _owners;

    mapping(address => uint256) private _balances;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {

        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner) public view virtual override returns (uint256) {

        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {

        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    function _baseURI() internal view virtual returns (string memory) {

        return "";
    }

    function approve(address to, uint256 tokenId) public virtual override {

        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {

        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        _setApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {

        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {

        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {

        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {

        _safeMint(to, tokenId, "");
    }

    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {

        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _mint(address to, uint256 tokenId) internal virtual {

        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {

        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal virtual {

        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {

        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {

        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

}// MIT

pragma solidity ^0.8.0;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

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
}// MIT

pragma solidity ^0.8.0;


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
}// MIT

pragma solidity ^0.8.0;

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
}// MIT

pragma solidity ^0.8.0;

library Counters {
    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}// MIT

pragma solidity ^0.8.0;






contract CGMarketPlaceContract is IMarket, AccessControl, Pausable {
    using SafeERC20 for IERC20;
    using Counters for Counters.Counter;
    Counters.Counter private _orderIds;
    Counters.Counter private _bidIds;

    address public _adminAddress = 0xAbb590532A0FA89F0DAB20f3C121712957A7976D; // CG VAULT ADDRESS For Commission

    uint8 private _adminCommissionPercentage = 25;

    mapping(uint256 => IUtils.Order) private _orders;

    mapping(uint256 => IUtils.Bid) private _bids;

    mapping(address => bool) public approvedCurrency;

    mapping(address => bool) public approvedNfts;


    uint256 private constant EXPO = 1e18;

    uint256 private constant BASE = 1000 * EXPO;

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function setAdminAddress(address _newAdminWallet) external override returns (bool) {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Caller is not a admin");
        require(_newAdminWallet != address(0), "Admin Wallet cannot be empty address");
        emit UpdateAdminWallet(_adminAddress, _newAdminWallet);
        _adminAddress = _newAdminWallet;
        return true;
    }


    function getCurrentOrderId() public view returns (uint256) {
        return _orderIds.current();
    }

    function getCurrentBidId() public view returns (uint256) {
        return _bidIds.current();
    }

    function setPauseStatus(bool _pauseStatus)
        external
        returns (bool)
    {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Caller is not a admin");
        if (_pauseStatus) {
             _pause();
        } else {
            _unpause();
        }
        return true;
    }

    function setCommissionPercentage(uint8 _commissionPercentage)
        external
        override
        returns (bool)
    {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Caller is not a admin");
        _adminCommissionPercentage = _commissionPercentage;
        emit CommissionUpdated(_adminCommissionPercentage);
        return true;
    }
    function updateCurrency(address _tokenAddress, bool _status) external override returns (bool) {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Caller is not a admin");
        approvedCurrency[_tokenAddress] = _status;
        return true;
    }

    function updateNFTContract(address _tokenAddress, bool _status) external override returns (bool) {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Caller is not a admin");
        approvedNfts[_tokenAddress] = _status;
        return true;
    }

    function getCommissionPercentage()
        external
        view
        override
        returns (uint8)
    {
        return _adminCommissionPercentage;
    } // end of function

    function setOrder(address _nftContract, uint256 _tokenId, address _currency, uint256 _askAmount, uint256 _expiryTime)
        whenNotPaused
        external
        override
    {

        _orderIds.increment();

        require(approvedNfts[_nftContract], "NFT is not approved by admin");
        require(approvedCurrency[_currency], "Currency is not approved by admin");
        require(_askAmount > 0, "Ask Amount Cannot be Zero");
        require(_expiryTime > block.timestamp, "Expiry Time cannot be in Past");
        ERC721 nftContract = ERC721(_nftContract);
        require(nftContract.ownerOf(_tokenId) == msg.sender, "You are not owner of Token Id");
        bool isAllTokenApproved = nftContract.isApprovedForAll(_msgSender(), address(this));
        address approvedSpenderOfToken = nftContract.getApproved(_tokenId);
        require((isAllTokenApproved || approvedSpenderOfToken == address(this)), "Market Contract is not allowed to manage this Token ID");

        uint256 currentOrderId = _orderIds.current();
        IUtils.Order storage order = _orders[currentOrderId];

        order.orderId = currentOrderId;
        order.sender = _msgSender();
        order.askAmount = _askAmount;
        order.currency = _currency;
        order.nftContract = _nftContract;
        order.tokenId = _tokenId;
        order.expiryTime = _expiryTime;
        order.orderStatus = IUtils.OrderStatus.OPEN;
        order.createdAt = block.timestamp;
        order.updatedAt = block.timestamp;

        emit OrderCreated(currentOrderId, order);
    } // end of create order


    function getOrder(uint256 _orderId)
        external
        override
        view
        returns (IUtils.Order memory) {
            return _orders[_orderId];
    }

    function cancelOrder(uint256 _orderId)
        whenNotPaused
        external
        override
        returns (bool) {
        IUtils.Order storage order = _orders[_orderId];
        
        require(order.sender != address(0), "Invalid Order Id");
        require(order.orderStatus == IUtils.OrderStatus.OPEN, "Order status is not Open");
        bool hasAdminRole = hasRole(DEFAULT_ADMIN_ROLE, _msgSender());
        require(order.sender == _msgSender() || hasAdminRole, "You Don't have right to cancel order");

        order.orderStatus = IUtils.OrderStatus.CANCELED;
        emit OrderRemoved(_orderId, order);
        return true;
    } // end of  cancel order

    function completeOrder(uint256 _orderId)
        whenNotPaused
        external
        override
        returns (bool) {

        IUtils.Order storage order = _orders[_orderId];
        
        require(order.sender != address(0), "Invalid Order Id");
        require(order.orderStatus == IUtils.OrderStatus.OPEN, "Order status is not Open");
        IERC20 token = IERC20(order.currency);
        ERC721 nft = ERC721(order.nftContract);
        require(block.timestamp <= order.expiryTime, "Order is expired");
        require(token.balanceOf(_msgSender()) >= order.askAmount, "Not enough funds available to buy");
        require(
            token.allowance(_msgSender(), address(this)) >= order.askAmount,
            "Please Approve Tokens Before You Buy"
        );


        uint256 _amountToDistribute = order.askAmount;
        uint256 adminCommission = (_amountToDistribute *
            (_adminCommissionPercentage * EXPO)) / (BASE);
        uint256 _amount = _amountToDistribute - adminCommission;

        token.safeTransferFrom(_msgSender(), _adminAddress, adminCommission);
        token.safeTransferFrom(_msgSender(), order.sender, _amount);
        nft.transferFrom(order.sender, _msgSender(), order.tokenId);

        order.orderStatus = IUtils.OrderStatus.COMPLETED;
        order.recipient = _msgSender();
        emit OrderCompleted(order.orderId, order);
        return true;
    } // end of function


    function getBid(uint256 _bidId)
        external
        override
        view
        returns (IUtils.Bid memory) {
            return _bids[_bidId];
    }

    function addBid(address _nftContract, uint256 _tokenId, address _currency, uint256 _bidAmount, uint256 _expiryTime)
        whenNotPaused
        external
        override
    {

        _bidIds.increment();

        require(approvedNfts[_nftContract], "NFT is not approved by admin");
        require(approvedCurrency[_currency], "Currency is not approved by admin");
        require(_bidAmount > 0, "Bid Amount Cannot be Zero");
        require(_expiryTime > block.timestamp, "Expiry Time cannot be in Past");
        
        ERC721 nft = ERC721(_nftContract);
        require(nft.ownerOf(_tokenId) != msg.sender, "You Can't Bid on your Own Token");

        IERC20 token = IERC20(_currency);
        require(token.balanceOf(_msgSender()) >= _bidAmount, "Not enough funds available to add bid");
        require(
            token.allowance(_msgSender(), address(this)) >= _bidAmount,
            "Please Approve Tokens Before You Bid"
        );

        uint256 currentBidId = _bidIds.current();
        IUtils.Bid storage bid = _bids[currentBidId];

        bid.bidId = currentBidId;
        bid.sender = _msgSender();
        bid.bidAmount = _bidAmount;
        bid.currency = _currency;
        bid.nftContract = _nftContract;
        bid.tokenId = _tokenId;
        bid.expiryTime = _expiryTime;
        bid.bidStatus = IUtils.OrderStatus.OPEN;
        bid.createdAt = block.timestamp;
        bid.updatedAt = block.timestamp;

        emit BidAdded(currentBidId, bid);
    } // end of create order

    function cancelBid(uint256 _bidId)
        whenNotPaused
        external
        override
        returns (bool) {
        IUtils.Bid storage bid = _bids[_bidId];
        
        require(bid.sender != address(0), "Invalid Bid Id");
        require(bid.bidStatus == IUtils.OrderStatus.OPEN, "Bid status is not Open");
        bool hasAdminRole = hasRole(DEFAULT_ADMIN_ROLE, _msgSender());

        ERC721 nft = ERC721(bid.nftContract);
        require(bid.sender == _msgSender() || nft.ownerOf(bid.tokenId) == _msgSender() || hasAdminRole, "You Don't have right to cancel order");

        bid.bidStatus = IUtils.OrderStatus.CANCELED;
        emit BidRemoved(_bidId, bid);
        return true;
    } // end of  cancel bid

    function acceptBid(uint256 _bidId)
        whenNotPaused
        external
        override
        returns (bool) {

        IUtils.Bid storage bid = _bids[_bidId];
        
        require(bid.sender != address(0), "Invalid Order Id");
        require(bid.bidStatus == IUtils.OrderStatus.OPEN, "Bid status is not Open");
        require(block.timestamp <= bid.expiryTime, "Bid is expired");

        IERC20 token = IERC20(bid.currency);
        ERC721 nft = ERC721(bid.nftContract);
        require(nft.ownerOf(bid.tokenId) == msg.sender, "You are not owner of Token Id");

        require(token.balanceOf(bid.sender) >= bid.bidAmount, "Bidder don't have Enough Funds");
        require(
            token.allowance(bid.sender, address(this)) >= bid.bidAmount,
            "Bidder has not Approved Tokens"
        );

        bool isAllTokenApproved = nft.isApprovedForAll(_msgSender(), address(this));
        address approvedSpenderOfToken = nft.getApproved(bid.tokenId);
        require((isAllTokenApproved || approvedSpenderOfToken == address(this)), "Market Contract is not allowed to manage this Token ID");

        uint256 _amountToDistribute = bid.bidAmount;
        uint256 adminCommission = (_amountToDistribute *
            (_adminCommissionPercentage * EXPO)) / (BASE);
        uint256 _amount = _amountToDistribute - adminCommission;

        nft.transferFrom(_msgSender(), bid.sender, bid.tokenId);
        token.safeTransferFrom(bid.sender, _adminAddress, adminCommission);
        token.safeTransferFrom(bid.sender, _msgSender(), _amount);

        bid.bidStatus = IUtils.OrderStatus.COMPLETED;
        bid.recipient = _msgSender();
        emit BidAccepted(bid.bidId, bid);
        return true;
    } // end of function
} // end of contract