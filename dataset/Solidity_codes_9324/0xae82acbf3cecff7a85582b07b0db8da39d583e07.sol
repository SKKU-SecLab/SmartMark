
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

        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
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


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


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


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

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

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
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
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {

        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
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

}// MIT

pragma solidity ^0.8.0;


contract ERC721Holder is IERC721Receiver {
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}// MIT
pragma solidity 0.8.13;


contract CyanWrappedNFTV1 is
    AccessControl,
    ERC721,
    ReentrancyGuard,
    ERC721Holder
{
    using Strings for uint256;

    bytes32 public constant CYAN_ROLE = keccak256('CYAN_ROLE');
    bytes32 public constant CYAN_PAYMENT_PLAN_ROLE =
        keccak256('CYAN_PAYMENT_PLAN_ROLE');

    string private baseURI;
    string private baseExtension;

    address private immutable _originalNFT;
    address private _cyanVaultAddress;
    ERC721 private immutable _originalNFTContract;

    event Wrap(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );
    event Unwrap(
        address indexed to,
        uint256 indexed tokenId,
        bool indexed isDefaulted
    );

    constructor(
        address originalNFT,
        address cyanVaultAddress,
        address cyanPaymentPlanContractAddress,
        address cyanSuperAdmin,
        string memory name,
        string memory symbol,
        string memory uri,
        string memory extension
    ) ERC721(name, symbol) {
        _originalNFT = originalNFT;
        _cyanVaultAddress = cyanVaultAddress;
        _originalNFTContract = ERC721(_originalNFT);

        baseURI = uri;
        baseExtension = extension;

        _setupRole(DEFAULT_ADMIN_ROLE, cyanSuperAdmin);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(CYAN_PAYMENT_PLAN_ROLE, cyanPaymentPlanContractAddress);
    }

    function wrap(
        address from,
        address to,
        uint256 tokenId
    ) external nonReentrant onlyRole(CYAN_PAYMENT_PLAN_ROLE) {
        require(to != address(0), 'Wrap to the zero address');
        require(!_exists(tokenId), 'Token already wrapped');

        _safeMint(to, tokenId);
        _originalNFTContract.safeTransferFrom(from, address(this), tokenId);

        emit Wrap(from, to, tokenId);
    }

    function unwrap(uint256 tokenId, bool isDefaulted)
        external
        nonReentrant
        onlyRole(CYAN_PAYMENT_PLAN_ROLE)
    {
        require(_exists(tokenId), 'Token is not wrapped');

        address to;
        if (isDefaulted) {
            to = _cyanVaultAddress;
        } else {
            to = ownerOf(tokenId);
        }

        _burn(tokenId);
        _originalNFTContract.safeTransferFrom(address(this), to, tokenId);

        emit Unwrap(to, tokenId, isDefaulted);
    }

    function exists(uint256 tokenId) external view returns (bool) {
        return _exists(tokenId);
    }

    function getOriginalNFTAddress() external view returns (address) {
        return _originalNFT;
    }

    function getCyanVaultAddress() external view returns (address) {
        return _cyanVaultAddress;
    }

    function updateCyanVaultAddress(address cyanVaultAddress)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(cyanVaultAddress != address(0), 'Zero Cyan Vault address');
        _cyanVaultAddress = cyanVaultAddress;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function _baseExtension() internal view returns (string memory) {
        return baseExtension;
    }

    function setBaseURI(string calldata newBaseURI)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        baseURI = newBaseURI;
    }

    function setBaseExtension(string calldata newBaseExtension)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        baseExtension = newBaseExtension;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        string memory uri = _baseURI();
        if (bytes(uri).length > 0) {
            string memory extension = _baseExtension();
            if (bytes(extension).length > 0) {
                return
                    string(
                        abi.encodePacked(uri, tokenId.toString(), extension)
                    );
            }
            return string(abi.encodePacked(uri, tokenId.toString()));
        }

        return '';
    }

    function withdrawAirDroppedERC721(address contractAddress, uint256 tokenId)
        external
        nonReentrant
        onlyRole(CYAN_ROLE)
    {
        require(
            contractAddress != address(this),
            'Cannot withdraw own wrapped token'
        );
        require(
            contractAddress != _originalNFT,
            'Cannot withdraw original NFT of the wrapper contract'
        );
        ERC721 erc721Contract = ERC721(contractAddress);
        erc721Contract.safeTransferFrom(address(this), msg.sender, tokenId);
    }

    function withdrawAirDroppedERC20(address contractAddress, uint256 amount)
        external
        nonReentrant
        onlyRole(CYAN_ROLE)
    {
        IERC20 erc20Contract = IERC20(contractAddress);
        require(
            erc20Contract.balanceOf(address(this)) >= amount,
            'ERC20 balance not enough'
        );
        erc20Contract.transfer(msg.sender, amount);
    }

    function withdrawApprovedERC20(
        address contractAddress,
        address from,
        uint256 amount
    ) external nonReentrant onlyRole(CYAN_ROLE) {
        IERC20 erc20Contract = IERC20(contractAddress);
        require(
            erc20Contract.allowance(from, address(this)) >= amount,
            'ERC20 allowance not enough'
        );
        erc20Contract.transferFrom(from, msg.sender, amount);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
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


interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}// MIT

pragma solidity ^0.8.0;


contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
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

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

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
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
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
}// MIT
pragma solidity 0.8.13;


contract CyanVaultTokenV1 is AccessControl, ERC20 {
    bytes32 public constant CYAN_VAULT_ROLE = keccak256('CYAN_VAULT_ROLE');

    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        address cyanSuperAdmin
    ) ERC20(name, symbol) {
        _mint(cyanSuperAdmin, initialSupply);
        _setupRole(DEFAULT_ADMIN_ROLE, cyanSuperAdmin);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function mint(address to, uint256 amount)
        external
        onlyRole(CYAN_VAULT_ROLE)
    {
        require(to != address(0), 'Mint to the zero address');
        _mint(to, amount);
    }

    function burn(address from, uint256 amount)
        external
        onlyRole(CYAN_VAULT_ROLE)
    {
        require(balanceOf(from) >= amount, 'Balance not enough');
        _burn(from, amount);
    }

    function burnAdminToken(uint256 amount)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(balanceOf(msg.sender) >= amount, 'Balance not enough');
        _burn(msg.sender, amount);
    }
}// MIT
pragma solidity 0.8.13;

interface IStableSwapSTETH {
    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external payable returns (uint256);

    function get_dy(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);
}// MIT
pragma solidity 0.8.13;



contract CyanVaultV1 is AccessControl, ReentrancyGuard, ERC721Holder, Pausable {
    bytes32 public constant CYAN_ROLE = keccak256("CYAN_ROLE");
    bytes32 public constant CYAN_PAYMENT_PLAN_ROLE =
        keccak256("CYAN_PAYMENT_PLAN_ROLE");
    bytes32 public constant CYAN_BALANCER_ROLE =
        keccak256("CYAN_BALANCER_ROLE");

    event DepositETH(
        address indexed from,
        uint256 ethAmount,
        uint256 tokenAmount
    );
    event Lend(address indexed to, uint256 amount);
    event Earn(uint256 paymentAmount, uint256 profitAmount);
    event NftDefaulted(uint256 unpaidAmount, uint256 estimatedPriceOfNFT);
    event NftLiquidated(uint256 defaultedAssetsAmount, uint256 soldAmount);
    event WithdrawETH(
        address indexed from,
        uint256 ethAmount,
        uint256 tokenAmount
    );
    event GetDefaultedNFT(
        address indexed to,
        address indexed contractAddress,
        uint256 indexed tokenId
    );
    event UpdatedDefaultedNFTAssetAmount(uint256 amount);
    event UpdatedServiceFeePercent(uint256 from, uint256 to);
    event UpdatedSafetyFundPercent(uint256 from, uint256 to);
    event ExchangedEthToStEth(uint256 ethAmount, uint256 receivedStEthAmount);
    event ExchangedStEthToEth(uint256 stEthAmount, uint256 receivedEthAmount);
    event ReceivedETH(uint256 amount, address indexed from);

    address public immutable _cyanVaultTokenAddress;
    CyanVaultTokenV1 private immutable _cyanVaultTokenContract;

    IERC20 private immutable _stEthTokenContract;
    IStableSwapSTETH private immutable _stableSwapSTETHContract;

    uint256 public _safetyFundPercent;

    uint256 public _serviceFeePercent;

    uint256 private REMAINING_AMOUNT;

    uint256 private LOANED_AMOUNT;

    uint256 private DEFAULTED_NFT_ASSET_AMOUNT;

    uint256 private COLLECTED_SERVICE_FEE_AMOUNT;

    constructor(
        address cyanVaultTokenAddress,
        address cyanPaymentPlanAddress,
        address stEthTokenAddress,
        address curveStableSwapStEthAddress,
        address cyanSuperAdmin,
        uint256 safetyFundPercent,
        uint256 serviceFeePercent
    ) payable {
        _cyanVaultTokenAddress = cyanVaultTokenAddress;
        _cyanVaultTokenContract = CyanVaultTokenV1(_cyanVaultTokenAddress);
        _safetyFundPercent = safetyFundPercent;
        _serviceFeePercent = serviceFeePercent;

        LOANED_AMOUNT = 0;
        DEFAULTED_NFT_ASSET_AMOUNT = 0;
        REMAINING_AMOUNT = msg.value;

        _stEthTokenContract = IERC20(stEthTokenAddress);
        _stableSwapSTETHContract = IStableSwapSTETH(
            curveStableSwapStEthAddress
        );

        _setupRole(DEFAULT_ADMIN_ROLE, cyanSuperAdmin);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(CYAN_PAYMENT_PLAN_ROLE, cyanPaymentPlanAddress);
    }

    function depositETH() external payable nonReentrant whenNotPaused {
        require(msg.value > 0, "Must deposit more than 0 ETH");

        uint256 cyanServiceFee = (msg.value * _serviceFeePercent) / 10000;

        uint256 depositedAmount = msg.value - cyanServiceFee;
        uint256 mintAmount = calculateTokenByETH(depositedAmount);

        REMAINING_AMOUNT += depositedAmount;
        COLLECTED_SERVICE_FEE_AMOUNT += cyanServiceFee;
        _cyanVaultTokenContract.mint(msg.sender, mintAmount);

        emit DepositETH(msg.sender, depositedAmount, mintAmount);
    }

    function lend(address to, uint256 amount)
        external
        nonReentrant
        whenNotPaused
        onlyRole(CYAN_PAYMENT_PLAN_ROLE)
    {
        uint256 maxWithdrableAmount = getMaxWithdrawableAmount();
        require(amount <= maxWithdrableAmount, "Not enough ETH in the Vault");

        LOANED_AMOUNT += amount;
        REMAINING_AMOUNT -= amount;
        payable(to).transfer(amount);

        emit Lend(to, amount);
    }

    function earn(uint256 amount, uint256 profit)
        external
        payable
        nonReentrant
        onlyRole(CYAN_PAYMENT_PLAN_ROLE)
    {
        require(msg.value == amount + profit, "Wrong tranfer amount");

        REMAINING_AMOUNT += msg.value;
        if (LOANED_AMOUNT >= amount) {
            LOANED_AMOUNT -= amount;
        } else {
            LOANED_AMOUNT = 0;
        }

        emit Earn(amount, profit);
    }

    function nftDefaulted(uint256 unpaidAmount, uint256 estimatedPriceOfNFT)
        external
        nonReentrant
        onlyRole(CYAN_PAYMENT_PLAN_ROLE)
    {
        DEFAULTED_NFT_ASSET_AMOUNT += estimatedPriceOfNFT;

        if (LOANED_AMOUNT >= unpaidAmount) {
            LOANED_AMOUNT -= unpaidAmount;
        } else {
            LOANED_AMOUNT = 0;
        }

        emit NftDefaulted(unpaidAmount, estimatedPriceOfNFT);
    }

    function liquidateNFT(uint256 totalDefaultedNFTAmount)
        external
        payable
        whenNotPaused
        onlyRole(CYAN_ROLE)
    {
        REMAINING_AMOUNT += msg.value;
        DEFAULTED_NFT_ASSET_AMOUNT = totalDefaultedNFTAmount;

        emit NftLiquidated(msg.value, totalDefaultedNFTAmount);
    }

    function withdraw(uint256 amount) external nonReentrant whenNotPaused {
        require(amount > 0, "Non-positive token amount");

        uint256 balance = _cyanVaultTokenContract.balanceOf(msg.sender);
        require(balance >= amount, "Check the token balance");

        uint256 withdrawableTokenBalance = getWithdrawableBalance(msg.sender);
        require(
            amount <= withdrawableTokenBalance,
            "Not enough active balance in Cyan Vault"
        );

        uint256 withdrawETHAmount = calculateETHByToken(amount);

        REMAINING_AMOUNT -= withdrawETHAmount;
        _cyanVaultTokenContract.burn(msg.sender, amount);
        payable(msg.sender).transfer(withdrawETHAmount);

        emit WithdrawETH(msg.sender, withdrawETHAmount, amount);
    }

    function updateDefaultedNFTAssetAmount(uint256 amount)
        external
        whenNotPaused
        onlyRole(CYAN_ROLE)
    {
        DEFAULTED_NFT_ASSET_AMOUNT = amount;
        emit UpdatedDefaultedNFTAssetAmount(amount);
    }

    function getDefaultedNFT(address contractAddress, uint256 tokenId)
        external
        nonReentrant
        whenNotPaused
        onlyRole(CYAN_ROLE)
    {
        require(contractAddress != address(0), "Zero contract address");

        IERC721 originalContract = IERC721(contractAddress);

        require(
            originalContract.ownerOf(tokenId) == address(this),
            "Vault isn't owner of the token"
        );

        originalContract.safeTransferFrom(address(this), msg.sender, tokenId);

        emit GetDefaultedNFT(msg.sender, contractAddress, tokenId);
    }

    function getWithdrawableBalance(address user)
        public
        view
        returns (uint256)
    {
        uint256 tokenBalance = _cyanVaultTokenContract.balanceOf(user);
        uint256 ethAmountForToken = calculateETHByToken(tokenBalance);
        uint256 maxWithdrawableAmount = getMaxWithdrawableAmount();

        if (ethAmountForToken <= maxWithdrawableAmount) {
            return tokenBalance;
        }
        return calculateTokenByETH(maxWithdrawableAmount);
    }

    function getMaxWithdrawableAmount() public view returns (uint256) {
        uint256 util = ((LOANED_AMOUNT + DEFAULTED_NFT_ASSET_AMOUNT) *
            _safetyFundPercent) / 10000;
        if (REMAINING_AMOUNT > util) {
            return REMAINING_AMOUNT - util;
        }
        return 0;
    }

    function getCurrentAssetAmounts()
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            REMAINING_AMOUNT,
            LOANED_AMOUNT,
            DEFAULTED_NFT_ASSET_AMOUNT,
            COLLECTED_SERVICE_FEE_AMOUNT,
            _stEthTokenContract.balanceOf(address(this))
        );
    }

    function calculateTokenByETH(uint256 amount) public view returns (uint256) {
        (uint256 totalETH, uint256 totalToken) = getTotalEthAndToken();
        return (amount * totalToken) / totalETH;
    }

    function calculateETHByToken(uint256 amount) public view returns (uint256) {
        (uint256 totalETH, uint256 totalToken) = getTotalEthAndToken();
        return (amount * totalETH) / totalToken;
    }

    function getTotalEthAndToken() private view returns (uint256, uint256) {
        uint256 vaultStEthBalance = _stEthTokenContract.balanceOf(
            address(this)
        );
        uint256 stEthInEth = _stableSwapSTETHContract.get_dy(
            1,
            0,
            vaultStEthBalance
        );
        uint256 totalETH = REMAINING_AMOUNT +
            LOANED_AMOUNT +
            DEFAULTED_NFT_ASSET_AMOUNT +
            stEthInEth;
        uint256 totalToken = _cyanVaultTokenContract.totalSupply();

        return (totalETH, totalToken);
    }

    function exchangeEthToStEth(uint256 ethAmount, uint256 minStEthAmount)
        external
        nonReentrant
        onlyRole(CYAN_BALANCER_ROLE)
    {
        require(ethAmount > 0, "Exchanging ETH amount is zero");
        require(
            ethAmount <= REMAINING_AMOUNT,
            "Cannot exchange more than REMAINING_AMOUNT"
        );
        uint256 receivedStEthAmount = _stableSwapSTETHContract.exchange{
            value: ethAmount
        }(0, 1, ethAmount, minStEthAmount);
        REMAINING_AMOUNT -= ethAmount;
        emit ExchangedEthToStEth(ethAmount, receivedStEthAmount);
    }

    function exchangeStEthToEth(uint256 stEthAmount, uint256 minEthAmount)
        external
        nonReentrant
        onlyRole(CYAN_BALANCER_ROLE)
    {
        require(stEthAmount > 0, "Exchanging stETH amount is zero");
        _stEthTokenContract.approve(
            address(_stableSwapSTETHContract),
            stEthAmount
        );
        uint256 receivedEthAmount = _stableSwapSTETHContract.exchange(
            1,
            0,
            stEthAmount,
            minEthAmount
        );
        emit ExchangedStEthToEth(stEthAmount, receivedEthAmount);
    }

    function updateSafetyFundPercent(uint256 safetyFundPercent)
        external
        nonReentrant
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(
            safetyFundPercent <= 10000,
            "Safety fund percent must be equal or less than 100 percent"
        );
        emit UpdatedSafetyFundPercent(_safetyFundPercent, safetyFundPercent);
        _safetyFundPercent = safetyFundPercent;
    }

    function updateServiceFeePercent(uint256 serviceFeePercent)
        external
        nonReentrant
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(
            serviceFeePercent <= 200,
            "Service fee percent must not be greater than 2 percent"
        );
        emit UpdatedServiceFeePercent(_serviceFeePercent, serviceFeePercent);
        _serviceFeePercent = serviceFeePercent;
    }

    function collectServiceFee(uint256 amount)
        external
        nonReentrant
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(
            amount <= COLLECTED_SERVICE_FEE_AMOUNT,
            "Not enough collected service fee"
        );
        COLLECTED_SERVICE_FEE_AMOUNT -= amount;
        payable(msg.sender).transfer(amount);
    }

    function withdrawAirDroppedERC20(address contractAddress, uint256 amount)
        external
        nonReentrant
        onlyRole(CYAN_ROLE)
    {
        require(
            contractAddress != address(_stEthTokenContract),
            "Cannot withdraw stETH"
        );
        IERC20 erc20Contract = IERC20(contractAddress);
        require(
            erc20Contract.balanceOf(address(this)) >= amount,
            "ERC20 balance not enough"
        );
        erc20Contract.transfer(msg.sender, amount);
    }

    function withdrawApprovedERC20(
        address contractAddress,
        address from,
        uint256 amount
    ) external nonReentrant onlyRole(CYAN_ROLE) {
        require(
            contractAddress != address(_stEthTokenContract),
            "Cannot withdraw stETH"
        );
        IERC20 erc20Contract = IERC20(contractAddress);
        require(
            erc20Contract.allowance(from, address(this)) >= amount,
            "ERC20 allowance not enough"
        );
        erc20Contract.transferFrom(from, msg.sender, amount);
    }

    receive() external payable {
        REMAINING_AMOUNT += msg.value;
        emit ReceivedETH(msg.value, msg.sender);
    }

    fallback() external payable {
        REMAINING_AMOUNT += msg.value;
        emit ReceivedETH(msg.value, msg.sender);
    }

    function pause() external nonReentrant onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    function unpause() external nonReentrant onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }
}// MIT
pragma solidity 0.8.13;



contract CyanPaymentPlanV1 is AccessControl, ReentrancyGuard {
    using ECDSA for bytes32;

    bytes32 public constant CYAN_ROLE = keccak256('CYAN_ROLE');
    uint256 private _claimableServiceFee;
    address private _cyanSigner;

    event CreatedBNPL(
        address indexed wNFTContract,
        uint256 indexed tokenId,
        uint256 amount,
        uint256 interestRate
    );
    event FundedBNPL(address indexed wNFTContract, uint256 indexed tokenId);
    event ActivatedBNPL(address indexed wNFTContract, uint256 indexed tokenId);
    event ActivatedAdminFundedBNPL(
        address indexed wNFTContract,
        uint256 indexed tokenId
    );
    event RejectedBNPL(address indexed wNFTContract, uint256 indexed tokenId);
    event CreatedPAWN(
        address indexed wNFTContract,
        uint256 indexed tokenId,
        uint256 amount,
        uint256 interestRate
    );
    event LiquidatedPaymentPlan(
        address indexed wNFTContract,
        uint256 indexed tokenId,
        uint256 estimatedPrice,
        uint256 unpaidAmount,
        address lastOwner
    );
    event Paid(
        address indexed wNFTContract,
        uint256 indexed tokenId,
        address indexed from,
        uint256 amount
    );
    event Completed(
        address indexed wNFTContract,
        uint256 indexed tokenId,
        address indexed from,
        uint256 amount,
        address receiver
    );

    enum PaymentPlanStatus {
        BNPL_CREATED,
        BNPL_FUNDED,
        BNPL_ACTIVE,
        BNPL_DEFAULTED,
        PAWN_ACTIVE,
        PAWN_DEFAULTED
    }
    struct PaymentPlan {
        uint256 amount;
        uint256 interestRate;
        uint256 createdDate;
        uint256 term;
        address createdUserAddress;
        uint8 totalNumberOfPayments;
        uint8 counterPaidPayments;
        PaymentPlanStatus status;
    }

    mapping(address => mapping(uint256 => PaymentPlan)) public _paymentPlan;

    constructor(address cyanSigner, address cyanSuperAdmin) {
        _claimableServiceFee = 0;
        _cyanSigner = cyanSigner;
        _setupRole(DEFAULT_ADMIN_ROLE, cyanSuperAdmin);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function createBNPLPaymentPlan(
        address wNFTContract,
        uint256 wNFTTokenId,
        uint256 amount,
        uint256 interestRate,
        uint256 signedBlockNum,
        uint256 term,
        uint8 totalNumberOfPayments,
        bytes memory signature
    ) external payable nonReentrant {
        verifySignature(
            wNFTContract,
            wNFTTokenId,
            amount,
            interestRate,
            signedBlockNum,
            term,
            totalNumberOfPayments,
            signature
        );
        require(
            signedBlockNum <= block.number,
            'Signed block number must be older'
        );
        require(signedBlockNum + 50 >= block.number, 'Signature expired');
        require(
            _paymentPlan[wNFTContract][wNFTTokenId].totalNumberOfPayments == 0,
            'Payment plan already exists'
        );
        require(amount > 0, 'Price of token is non-positive');
        require(interestRate > 0, 'Interest rate is non-positive');
        require(msg.value > 0, 'Downpayment amount is non-positive');
        require(term > 0, 'Term is non-positive');
        require(
            totalNumberOfPayments > 0,
            'Total number of payments is non-positive'
        );

        CyanWrappedNFTV1 _cyanWrappedNFTV1 = CyanWrappedNFTV1(wNFTContract);
        require(
            _cyanWrappedNFTV1.exists(wNFTTokenId) == false,
            'Token is already wrapped'
        );

        _paymentPlan[wNFTContract][wNFTTokenId] = PaymentPlan(
            amount, //amount
            interestRate, //interestRate
            block.timestamp, // createdDate
            term, //term
            msg.sender, // createdUserAddress
            totalNumberOfPayments, // totalNumberOfPayments
            0, //counterPaidPayments
            PaymentPlanStatus.BNPL_CREATED // status
        );

        (, , , uint256 currentPayment, ) = getNextPayment(
            wNFTContract,
            wNFTTokenId
        );
        require(currentPayment == msg.value, 'Downpayment amount incorrect');

        _paymentPlan[wNFTContract][wNFTTokenId].counterPaidPayments++;

        emit CreatedBNPL(wNFTContract, wNFTTokenId, amount, interestRate);
    }

    function fundBNPL(address wNFTContract, uint256 wNFTTokenId)
        external
        nonReentrant
        onlyRole(CYAN_ROLE)
    {
        require(
            _paymentPlan[wNFTContract][wNFTTokenId].totalNumberOfPayments != 0,
            'No payment plan found'
        );
        require(
            _paymentPlan[wNFTContract][wNFTTokenId].counterPaidPayments == 1,
            'Only downpayment must be paid'
        );
        require(
            _paymentPlan[wNFTContract][wNFTTokenId].status ==
                PaymentPlanStatus.BNPL_CREATED,
            'BNPL payment plan must be at CREATED stage'
        );
        CyanWrappedNFTV1 _cyanWrappedNFTV1 = CyanWrappedNFTV1(wNFTContract);
        require(
            _cyanWrappedNFTV1.exists(wNFTTokenId) == false,
            'Wrapped token exist'
        );

        _paymentPlan[wNFTContract][wNFTTokenId].status = PaymentPlanStatus
            .BNPL_FUNDED;

        address _cyanVaultAddress = _cyanWrappedNFTV1.getCyanVaultAddress();
        CyanVaultV1 _cyanVaultV1 = CyanVaultV1(payable(_cyanVaultAddress));
        _cyanVaultV1.lend(
            msg.sender,
            _paymentPlan[wNFTContract][wNFTTokenId].amount
        );

        emit FundedBNPL(wNFTContract, wNFTTokenId);
    }

    function activateBNPL(address wNFTContract, uint256 wNFTTokenId)
        external
        nonReentrant
        onlyRole(CYAN_ROLE)
    {
        require(
            _paymentPlan[wNFTContract][wNFTTokenId].totalNumberOfPayments != 0,
            'No payment plan found'
        );
        require(
            _paymentPlan[wNFTContract][wNFTTokenId].counterPaidPayments == 1,
            'Only downpayment must be paid'
        );
        require(
            _paymentPlan[wNFTContract][wNFTTokenId].status ==
                PaymentPlanStatus.BNPL_FUNDED,
            'BNPL payment plan must be at FUNDED stage'
        );
        CyanWrappedNFTV1 _cyanWrappedNFTV1 = CyanWrappedNFTV1(wNFTContract);
        require(
            _cyanWrappedNFTV1.exists(wNFTTokenId) == false,
            'Wrapped token exist'
        );

        (
            uint256 payAmountForCollateral,
            uint256 payAmountForInterest,
            uint256 payAmountForService,
            ,

        ) = getNextPayment(wNFTContract, wNFTTokenId);

        _cyanWrappedNFTV1.wrap(
            msg.sender,
            _paymentPlan[wNFTContract][wNFTTokenId].createdUserAddress,
            wNFTTokenId
        );

        _paymentPlan[wNFTContract][wNFTTokenId].status = PaymentPlanStatus
            .BNPL_ACTIVE;

        _claimableServiceFee += payAmountForService;

        address _cyanVaultAddress = _cyanWrappedNFTV1.getCyanVaultAddress();
        transferEarnedAmountToCyanVault(
            _cyanVaultAddress,
            payAmountForCollateral,
            payAmountForInterest
        );

        emit ActivatedBNPL(wNFTContract, wNFTTokenId);
    }

    function activateAdminFundedBNPL(address wNFTContract, uint256 wNFTTokenId)
        external
        nonReentrant
        onlyRole(CYAN_ROLE)
    {
        require(
            _paymentPlan[wNFTContract][wNFTTokenId].totalNumberOfPayments != 0,
            'No payment plan found'
        );
        require(
            _paymentPlan[wNFTContract][wNFTTokenId].counterPaidPayments == 1,
            'Only downpayment must be paid'
        );
        require(
            _paymentPlan[wNFTContract][wNFTTokenId].status ==
                PaymentPlanStatus.BNPL_CREATED,
            'BNPL payment plan must be at CREATED stage'
        );
        CyanWrappedNFTV1 _cyanWrappedNFTV1 = CyanWrappedNFTV1(wNFTContract);
        require(
            _cyanWrappedNFTV1.exists(wNFTTokenId) == false,
            'Wrapped token exist'
        );

        (
            uint256 payAmountForCollateral,
            uint256 payAmountForInterest,
            uint256 payAmountForService,
            ,

        ) = getNextPayment(wNFTContract, wNFTTokenId);

        _cyanWrappedNFTV1.wrap(
            msg.sender,
            _paymentPlan[wNFTContract][wNFTTokenId].createdUserAddress,
            wNFTTokenId
        );

        _paymentPlan[wNFTContract][wNFTTokenId].status = PaymentPlanStatus
            .BNPL_ACTIVE;

        _claimableServiceFee += payAmountForService;

        address _cyanVaultAddress = _cyanWrappedNFTV1.getCyanVaultAddress();
        CyanVaultV1 _cyanVaultV1 = CyanVaultV1(payable(_cyanVaultAddress));
        _cyanVaultV1.lend(
            msg.sender,
            _paymentPlan[wNFTContract][wNFTTokenId].amount
        );
        _cyanVaultV1.earn{value: payAmountForCollateral + payAmountForInterest}(
            payAmountForCollateral,
            payAmountForInterest
        );

        emit ActivatedAdminFundedBNPL(wNFTContract, wNFTTokenId);
    }

    function createPAWNPaymentPlan(
        address wNFTContract,
        uint256 wNFTTokenId,
        uint256 amount,
        uint256 interestRate,
        uint256 signedBlockNum,
        uint256 term,
        uint8 totalNumberOfPayments,
        bytes memory signature
    ) external nonReentrant {
        verifySignature(
            wNFTContract,
            wNFTTokenId,
            amount,
            interestRate,
            signedBlockNum,
            term,
            totalNumberOfPayments,
            signature
        );
        require(
            signedBlockNum <= block.number,
            'Signed block number must be older'
        );
        require(signedBlockNum + 50 >= block.number, 'Signature expired');
        require(
            _paymentPlan[wNFTContract][wNFTTokenId].totalNumberOfPayments == 0,
            'Payment plan already exists'
        );
        require(amount > 0, 'Collateral amount is non-positive');
        require(interestRate > 0, 'Interest rate is non-positive');
        require(term > 0, 'Term is non-positive');
        require(
            totalNumberOfPayments > 0,
            'Total number of payments is non-positive'
        );

        CyanWrappedNFTV1 _cyanWrappedNFTV1 = CyanWrappedNFTV1(wNFTContract);
        require(
            _cyanWrappedNFTV1.exists(wNFTTokenId) == false,
            'Token is already wrapped'
        );

        _paymentPlan[wNFTContract][wNFTTokenId] = PaymentPlan(
            amount, //amount
            interestRate, //interestRate
            block.timestamp + term, // createdDate
            term, //term
            msg.sender, // createdUserAddress
            totalNumberOfPayments, // totalNumberOfPayments
            0, // counterPaidPayments
            PaymentPlanStatus.PAWN_ACTIVE // status
        );

        _cyanWrappedNFTV1.wrap(msg.sender, msg.sender, wNFTTokenId);

        address _cyanVaultAddress = _cyanWrappedNFTV1.getCyanVaultAddress();
        CyanVaultV1 _cyanVaultV1 = CyanVaultV1(payable(_cyanVaultAddress));
        _cyanVaultV1.lend(msg.sender, amount);

        emit CreatedPAWN(wNFTContract, wNFTTokenId, amount, interestRate);
    }

    function liquidate(
        address wNFTContract,
        uint256 wNFTTokenId,
        uint256 estimatedTokenValue
    ) external nonReentrant onlyRole(CYAN_ROLE) {
        require(
            _paymentPlan[wNFTContract][wNFTTokenId].totalNumberOfPayments != 0,
            'No payment plan found'
        );
        require(
            _paymentPlan[wNFTContract][wNFTTokenId].totalNumberOfPayments >
                _paymentPlan[wNFTContract][wNFTTokenId].counterPaidPayments,
            'Total payment done'
        );
        (, , , , uint256 dueDate) = getNextPayment(wNFTContract, wNFTTokenId);

        require(dueDate < block.timestamp, 'Next payment is still due');

        uint256 unpaidAmount = 0;
        for (
            ;
            _paymentPlan[wNFTContract][wNFTTokenId].counterPaidPayments <
            _paymentPlan[wNFTContract][wNFTTokenId].totalNumberOfPayments;
            _paymentPlan[wNFTContract][wNFTTokenId].counterPaidPayments++
        ) {
            (uint256 payAmountForCollateral, , , , ) = getNextPayment(
                wNFTContract,
                wNFTTokenId
            );
            unpaidAmount += payAmountForCollateral;
        }
        require(unpaidAmount > 0, 'Unpaid is non-positive');

        CyanWrappedNFTV1 _cyanWrappedNFTV1 = CyanWrappedNFTV1(wNFTContract);
        require(
            _cyanWrappedNFTV1.exists(wNFTTokenId) == true,
            "Wrapped token doesn't exist"
        );
        address lastOwner = _cyanWrappedNFTV1.ownerOf(wNFTTokenId);
        _cyanWrappedNFTV1.unwrap(
            wNFTTokenId,
            true
        );
        delete _paymentPlan[wNFTContract][wNFTTokenId];

        address _cyanVaultAddress = _cyanWrappedNFTV1.getCyanVaultAddress();
        require(_cyanVaultAddress != address(0), 'Cyan vault has zero address');
        CyanVaultV1 _cyanVaultV1 = CyanVaultV1(payable(_cyanVaultAddress));
        _cyanVaultV1.nftDefaulted(unpaidAmount, estimatedTokenValue);

        emit LiquidatedPaymentPlan(
            wNFTContract,
            wNFTTokenId,
            estimatedTokenValue,
            unpaidAmount,
            lastOwner
        );
    }

    function pay(address wNFTContract, uint256 wNFTTokenId)
        external
        payable
        nonReentrant
    {
        require(
            _paymentPlan[wNFTContract][wNFTTokenId].totalNumberOfPayments != 0,
            'No payment plan found'
        );
        require(
            _paymentPlan[wNFTContract][wNFTTokenId].totalNumberOfPayments >
                _paymentPlan[wNFTContract][wNFTTokenId].counterPaidPayments,
            'Total payment done'
        );
        require(
            _paymentPlan[wNFTContract][wNFTTokenId].status ==
                PaymentPlanStatus.BNPL_ACTIVE ||
                _paymentPlan[wNFTContract][wNFTTokenId].status ==
                PaymentPlanStatus.PAWN_ACTIVE,
            'Payment plan must be at ACTIVE stage'
        );

        (
            uint256 payAmountForCollateral,
            uint256 payAmountForInterest,
            uint256 payAmountForService,
            uint256 currentPayment,
            uint256 dueDate
        ) = getNextPayment(wNFTContract, wNFTTokenId);

        require(currentPayment == msg.value, 'Wrong payment amount');
        require(dueDate >= block.timestamp, 'Payment due date is passed');
        CyanWrappedNFTV1 _cyanWrappedNFTV1 = CyanWrappedNFTV1(wNFTContract);
        require(
            _cyanWrappedNFTV1.exists(wNFTTokenId) == true,
            "Wrapped token doesn't exist"
        );
        _paymentPlan[wNFTContract][wNFTTokenId].counterPaidPayments++;
        _claimableServiceFee += payAmountForService;

        address _cyanVaultAddress = _cyanWrappedNFTV1.getCyanVaultAddress();
        transferEarnedAmountToCyanVault(
            _cyanVaultAddress,
            payAmountForCollateral,
            payAmountForInterest
        );
        if (
            _paymentPlan[wNFTContract][wNFTTokenId].counterPaidPayments ==
            _paymentPlan[wNFTContract][wNFTTokenId].totalNumberOfPayments
        ) {
            address receiver = _cyanWrappedNFTV1.ownerOf(wNFTTokenId);
            _cyanWrappedNFTV1.unwrap(
                wNFTTokenId,
                false
            );
            delete _paymentPlan[wNFTContract][wNFTTokenId];
            emit Completed(
                wNFTContract,
                wNFTTokenId,
                msg.sender,
                msg.value,
                receiver
            );
        } else {
            emit Paid(wNFTContract, wNFTTokenId, msg.sender, msg.value);
        }
    }

    function rejectBNPLPaymentPlan(address wNFTContract, uint256 wNFTTokenId)
        external
        nonReentrant
        onlyRole(CYAN_ROLE)
    {
        require(
            _paymentPlan[wNFTContract][wNFTTokenId].totalNumberOfPayments != 0,
            'No payment plan found'
        );
        require(
            _paymentPlan[wNFTContract][wNFTTokenId].counterPaidPayments == 1,
            'Payment done other than downpayment for this plan'
        );
        require(
            _paymentPlan[wNFTContract][wNFTTokenId].status ==
                PaymentPlanStatus.BNPL_CREATED,
            'BNPL payment plan must be at CREATED stage'
        );
        CyanWrappedNFTV1 _cyanWrappedNFTV1 = CyanWrappedNFTV1(wNFTContract);
        require(
            _cyanWrappedNFTV1.exists(wNFTTokenId) == false,
            'Wrapped token exists'
        );

        (, , , uint256 currentPayment, ) = getNextPayment(
            wNFTContract,
            wNFTTokenId
        );

        payable(_paymentPlan[wNFTContract][wNFTTokenId].createdUserAddress)
            .transfer(currentPayment);
        delete _paymentPlan[wNFTContract][wNFTTokenId];

        emit RejectedBNPL(wNFTContract, wNFTTokenId);
    }

    function rejectBNPLPaymentPlanAfterFunded(
        address wNFTContract,
        uint256 wNFTTokenId
    ) external payable nonReentrant onlyRole(CYAN_ROLE) {
        require(
            _paymentPlan[wNFTContract][wNFTTokenId].totalNumberOfPayments != 0,
            'No payment plan found'
        );
        require(
            _paymentPlan[wNFTContract][wNFTTokenId].counterPaidPayments == 1,
            'Payment done other than downpayment for this plan'
        );
        require(
            _paymentPlan[wNFTContract][wNFTTokenId].status ==
                PaymentPlanStatus.BNPL_FUNDED,
            'BNPL payment plan must be at FUNDED stage'
        );
        require(
            _paymentPlan[wNFTContract][wNFTTokenId].amount == msg.value,
            'Wrong fund return amount'
        );
        CyanWrappedNFTV1 _cyanWrappedNFTV1 = CyanWrappedNFTV1(wNFTContract);
        require(
            _cyanWrappedNFTV1.exists(wNFTTokenId) == false,
            'Wrapped token exists'
        );

        (, , , uint256 currentPayment, ) = getNextPayment(
            wNFTContract,
            wNFTTokenId
        );

        payable(_paymentPlan[wNFTContract][wNFTTokenId].createdUserAddress)
            .transfer(currentPayment);
        delete _paymentPlan[wNFTContract][wNFTTokenId];

        address _cyanVaultAddress = _cyanWrappedNFTV1.getCyanVaultAddress();
        transferEarnedAmountToCyanVault(_cyanVaultAddress, msg.value, 0);

        emit RejectedBNPL(wNFTContract, wNFTTokenId);
    }

    function calculateIndividualPayments(
        uint256 amount,
        uint256 interestRate,
        uint8 numOfPayment
    )
        private
        pure
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        uint256 payAmountForCollateral = amount / numOfPayment;

        uint256 interestFee = (amount * interestRate) / 10000;
        uint256 payAmountForInterest = interestFee / numOfPayment;

        uint256 serviceFee = amount / 40;
        uint256 payAmountForService = serviceFee / numOfPayment;

        uint256 currentPayment = payAmountForCollateral +
            payAmountForInterest +
            payAmountForService;

        return (
            payAmountForCollateral,
            interestFee,
            payAmountForInterest,
            serviceFee,
            payAmountForService,
            currentPayment
        );
    }

    function getNextPayment(address wNFTContract, uint256 wNFTTokenId)
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        require(
            _paymentPlan[wNFTContract][wNFTTokenId].totalNumberOfPayments != 0,
            'No payment plan found'
        );
        PaymentPlan memory plan = _paymentPlan[wNFTContract][wNFTTokenId];
        (
            uint256 payAmountForCollateral,
            uint256 interestFee,
            uint256 payAmountForInterest,
            uint256 serviceFee,
            uint256 payAmountForService,
            uint256 currentPayment
        ) = calculateIndividualPayments(
                plan.amount,
                plan.interestRate,
                plan.totalNumberOfPayments
            );
        if (plan.counterPaidPayments + 1 == plan.totalNumberOfPayments) {
            payAmountForCollateral =
                plan.amount -
                (payAmountForCollateral * plan.counterPaidPayments);
            payAmountForInterest =
                interestFee -
                (payAmountForInterest * plan.counterPaidPayments);
            payAmountForService =
                serviceFee -
                (payAmountForService * plan.counterPaidPayments);
            currentPayment =
                payAmountForCollateral +
                payAmountForInterest +
                payAmountForService;
        }

        return (
            payAmountForCollateral,
            payAmountForInterest,
            payAmountForService,
            currentPayment,
            plan.createdDate + plan.counterPaidPayments * plan.term
        );
    }

    function transferEarnedAmountToCyanVault(
        address cyanVaultAddress,
        uint256 paidTokenPayment,
        uint256 paidInterestFee
    ) private {
        require(cyanVaultAddress != address(0), 'Cyan vault has zero address');
        CyanVaultV1 _cyanVaultV1 = CyanVaultV1(payable(cyanVaultAddress));
        _cyanVaultV1.earn{value: paidTokenPayment + paidInterestFee}(
            paidTokenPayment,
            paidInterestFee
        );
    }

    function getExpectedPaymentPlan(
        uint256 amount,
        uint256 interestRate,
        uint8 numOfPayment
    )
        external
        pure
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        (
            ,
            uint256 interestFee,
            ,
            uint256 serviceFee,
            ,
            uint256 currentPayment
        ) = calculateIndividualPayments(amount, interestRate, numOfPayment);

        uint256 totalPayment = amount + interestFee + serviceFee;
        return (amount, interestFee, serviceFee, currentPayment, totalPayment);
    }

    function getPaymentPlanStatus(address wNFTContract, uint256 wNFTTokenId)
        external
        view
        returns (PaymentPlanStatus)
    {
        require(
            _paymentPlan[wNFTContract][wNFTTokenId].totalNumberOfPayments != 0,
            'No payment plan found'
        );

        (, , , , uint256 dueDate) = getNextPayment(wNFTContract, wNFTTokenId);
        bool isDefaulted = block.timestamp > dueDate;

        if (isDefaulted == true) {
            if (
                _paymentPlan[wNFTContract][wNFTTokenId].status ==
                PaymentPlanStatus.PAWN_ACTIVE
            ) {
                return PaymentPlanStatus.PAWN_DEFAULTED;
            }
            return PaymentPlanStatus.BNPL_DEFAULTED;
        }
        return _paymentPlan[wNFTContract][wNFTTokenId].status;
    }

    function getClaimableServiceFee()
        external
        view
        onlyRole(CYAN_ROLE)
        returns (uint256)
    {
        return _claimableServiceFee;
    }

    function claimServiceFee()
        external
        nonReentrant
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        payable(msg.sender).transfer(_claimableServiceFee);
        _claimableServiceFee = 0;
    }

    function verifySignature(
        address wNFTContract,
        uint256 wNFTTokenId,
        uint256 amount,
        uint256 interestRate,
        uint256 timestamp,
        uint256 term,
        uint8 totalNumberOfPayments,
        bytes memory signature
    ) internal view {
        bytes32 msgHash = keccak256(
            abi.encodePacked(
                wNFTContract,
                wNFTTokenId,
                amount,
                interestRate,
                timestamp,
                term,
                totalNumberOfPayments
            )
        );
        bytes32 signedHash = keccak256(
            abi.encodePacked('\x19Ethereum Signed Message:\n32', msgHash)
        );
        require(
            signedHash.recover(signature) == _cyanSigner,
            'Invalid signature'
        );
    }

    function updateCyanSignerAddress(address cyanSigner)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(cyanSigner != address(0), 'Zero Cyan Signer address');
        _cyanSigner = cyanSigner;
    }
}