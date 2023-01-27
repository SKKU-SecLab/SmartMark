
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

library AddressUpgradeable {

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;

library Clones {

    function clone(address implementation) internal returns (address instance) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {

        return predictDeterministicAddress(implementation, salt, address(this));
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

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

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

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

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Upgradeable is IERC165Upgradeable {

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

interface IERC721ReceiverUpgradeable {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


interface IERC721MetadataUpgradeable is IERC721Upgradeable {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;

library StringsUpgradeable {

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


abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


contract ERC721Upgradeable is Initializable, ContextUpgradeable, ERC165Upgradeable, IERC721Upgradeable, IERC721MetadataUpgradeable {

    using AddressUpgradeable for address;
    using StringsUpgradeable for uint256;

    string private _name;

    string private _symbol;

    mapping(uint256 => address) private _owners;

    mapping(address => uint256) private _balances;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    function __ERC721_init(string memory name_, string memory symbol_) internal onlyInitializing {

        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC721_init_unchained(name_, symbol_);
    }

    function __ERC721_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {

        _name = name_;
        _symbol = symbol_;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {

        return
            interfaceId == type(IERC721Upgradeable).interfaceId ||
            interfaceId == type(IERC721MetadataUpgradeable).interfaceId ||
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

        address owner = ERC721Upgradeable.ownerOf(tokenId);
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
        address owner = ERC721Upgradeable.ownerOf(tokenId);
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

        address owner = ERC721Upgradeable.ownerOf(tokenId);

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

        require(ERC721Upgradeable.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
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
        emit Approval(ERC721Upgradeable.ownerOf(tokenId), to, tokenId);
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
            try IERC721ReceiverUpgradeable(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721ReceiverUpgradeable.onERC721Received.selector;
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

    uint256[44] private __gap;
}// MIT

pragma solidity ^0.8.0;


interface IERC721EnumerableUpgradeable is IERC721Upgradeable {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC721EnumerableUpgradeable is Initializable, ERC721Upgradeable, IERC721EnumerableUpgradeable {
    function __ERC721Enumerable_init() internal onlyInitializing {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC721Enumerable_init_unchained();
    }

    function __ERC721Enumerable_init_unchained() internal onlyInitializing {
    }
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    mapping(uint256 => uint256) private _ownedTokensIndex;

    uint256[] private _allTokens;

    mapping(uint256 => uint256) private _allTokensIndex;

    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165Upgradeable, ERC721Upgradeable) returns (bool) {
        return interfaceId == type(IERC721EnumerableUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Upgradeable.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721EnumerableUpgradeable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721Upgradeable.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {

        uint256 lastTokenIndex = ERC721Upgradeable.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
    uint256[46] private __gap;
}// MIT

pragma solidity ^0.8.0;

library SafeCastUpgradeable {

    function toUint224(uint256 value) internal pure returns (uint224) {

        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    function toUint128(uint256 value) internal pure returns (uint128) {

        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    function toUint96(uint256 value) internal pure returns (uint96) {

        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    function toUint64(uint256 value) internal pure returns (uint64) {

        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    function toUint32(uint256 value) internal pure returns (uint32) {

        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    function toUint16(uint256 value) internal pure returns (uint16) {

        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    function toUint8(uint256 value) internal pure returns (uint8) {

        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    function toUint256(int256 value) internal pure returns (uint256) {

        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    function toInt128(int256 value) internal pure returns (int128) {

        require(value >= type(int128).min && value <= type(int128).max, "SafeCast: value doesn't fit in 128 bits");
        return int128(value);
    }

    function toInt64(int256 value) internal pure returns (int64) {

        require(value >= type(int64).min && value <= type(int64).max, "SafeCast: value doesn't fit in 64 bits");
        return int64(value);
    }

    function toInt32(int256 value) internal pure returns (int32) {

        require(value >= type(int32).min && value <= type(int32).max, "SafeCast: value doesn't fit in 32 bits");
        return int32(value);
    }

    function toInt16(int256 value) internal pure returns (int16) {

        require(value >= type(int16).min && value <= type(int16).max, "SafeCast: value doesn't fit in 16 bits");
        return int16(value);
    }

    function toInt8(int256 value) internal pure returns (int8) {

        require(value >= type(int8).min && value <= type(int8).max, "SafeCast: value doesn't fit in 8 bits");
        return int8(value);
    }

    function toInt256(uint256 value) internal pure returns (int256) {

        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}// MIT

pragma solidity ^0.8.0;

library CountersUpgradeable {

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

library MerkleProofUpgradeable {

    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {

        return processProof(proof, leaf) == root;
    }

    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {

        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }
        return computedHash;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal onlyInitializing {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}// contracts/ISpliceStyleNFT.sol
pragma solidity 0.8.10;

struct Allowlist {
  uint32 numReserved;
  uint64 reservedUntil;
  uint8 mintsPerAddress;
  bytes32 merkleRoot;
}

struct Partnership {
  address[] collections;
  uint64 until;
  bool exclusive;
}

struct StyleSettings {
  uint32 mintedOfStyle;
  uint32 cap;
  ISplicePriceStrategy priceStrategy;
  bool salesIsActive;
  bool isFrozen;
  string styleCID;
  uint8 maxInputs;
  address paymentSplitter;
}// contracts/ISplicePriceStrategy.sol
pragma solidity 0.8.10;

interface ISplicePriceStrategy {

  function quote(
    uint256 styleTokenId,
    IERC721[] memory collections,
    uint256[] memory tokenIds
  ) external view returns (uint256);


  function onMinted(uint256 styleTokenId) external;

}// MIT

pragma solidity ^0.8.0;


library SafeMathUpgradeable {

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


interface IERC2981Upgradeable is IERC165Upgradeable {

    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);

}// MIT

pragma solidity ^0.8.0;


abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal onlyInitializing {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
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
    uint256[49] private __gap;
}// MIT
pragma solidity 0.8.10;

library BytesLib {

  function toUint32(bytes memory _bytes, uint256 _start)
    internal
    pure
    returns (uint32)
  {

    require(_bytes.length >= _start + 4, 'toUint32_outOfBounds');
    uint32 tempUint;

    assembly {
      tempUint := mload(add(add(_bytes, 0x4), _start))
    }

    return tempUint;
  }

  function toUint64(bytes memory _bytes, uint256 _start)
    internal
    pure
    returns (uint64)
  {

    require(_bytes.length >= _start + 8, 'toUint64_outOfBounds');
    uint64 tempUint;

    assembly {
      tempUint := mload(add(add(_bytes, 0x8), _start))
    }

    return tempUint;
  }
}// MIT
pragma solidity 0.8.10;

library ArrayLib {

  function contains(address[] memory arr, address item)
    internal
    pure
    returns (bool)
  {

    for (uint256 j = 0; j < arr.length; j++) {
      if (arr[j] == item) return true;
    }
    return false;
  }
}// contracts/Splice.sol


pragma solidity 0.8.10;




contract Splice is
  ERC721Upgradeable,
  OwnableUpgradeable,
  PausableUpgradeable,
  ReentrancyGuardUpgradeable,
  IERC2981Upgradeable
{

  using SafeMathUpgradeable for uint256;
  using StringsUpgradeable for uint32;

  error InsufficientFees();

  error ProvenanceAlreadyUsed();

  error NotAllowedToMint(string reason);

  error NotOwningOrigin();

  uint8 public ROYALTY_PERCENT;

  string private baseUri;

  mapping(bytes32 => uint64) public provenanceToTokenId;

  SpliceStyleNFT public styleNFT;

  address public platformBeneficiary;

  event Withdrawn(address indexed user, uint256 amount);
  event Minted(
    bytes32 indexed origin_hash,
    uint64 indexed tokenId,
    uint32 indexed styleTokenId
  );
  event RoyaltiesUpdated(uint8 royalties);
  event BeneficiaryChanged(address newBeneficiary);

  function initialize(
    string memory baseUri_,
    SpliceStyleNFT initializedStyleNFT_
  ) public initializer {

    __ERC721_init('Splice', 'SPLICE');
    __Ownable_init();
    __Pausable_init();
    __ReentrancyGuard_init();
    ROYALTY_PERCENT = 10;
    platformBeneficiary = msg.sender;
    baseUri = baseUri_;
    styleNFT = initializedStyleNFT_;
  }

  function pause() external onlyOwner {

    _pause();
  }

  function unpause() external onlyOwner {

    _unpause();
  }

  function setBaseUri(string memory newBaseUri) external onlyOwner {

    baseUri = newBaseUri;
  }

  function _baseURI() internal view override returns (string memory) {

    return baseUri;
  }

  function setPlatformBeneficiary(address payable newAddress)
    external
    onlyOwner
  {

    require(address(0) != newAddress, 'must be a real address');
    platformBeneficiary = newAddress;
    emit BeneficiaryChanged(newAddress);
  }

  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(ERC721Upgradeable, IERC165Upgradeable)
    returns (bool)
  {

    return
      interfaceId == type(IERC2981Upgradeable).interfaceId ||
      super.supportsInterface(interfaceId);
  }

  function withdrawEth() external nonReentrant onlyOwner {

    AddressUpgradeable.sendValue(
      payable(platformBeneficiary),
      address(this).balance
    );
  }

  function withdrawERC20(IERC20 token) external nonReentrant onlyOwner {

    bool result = token.transfer(
      platformBeneficiary,
      token.balanceOf(address(this))
    );
    if (!result) revert('the transfer failed');
  }

  function withdrawERC721(IERC721 nftContract, uint256 tokenId)
    external
    nonReentrant
    onlyOwner
  {

    nftContract.transferFrom(address(this), platformBeneficiary, tokenId);
  }

  function styleAndTokenByTokenId(uint256 tokenId)
    public
    pure
    returns (uint32 styleTokenId, uint32 token_tokenId)
  {

    bytes memory tokenIdBytes = abi.encode(tokenId);

    styleTokenId = BytesLib.toUint32(tokenIdBytes, 24);
    token_tokenId = BytesLib.toUint32(tokenIdBytes, 28);
  }

  function contractURI() public pure returns (string memory) {

    return 'https://getsplice.io/contract-metadata';
  }

  function tokenURI(uint256 tokenId)
    public
    view
    override
    returns (string memory)
  {

    require(
      _exists(tokenId),
      'ERC721Metadata: URI query for nonexistent token'
    );

    (uint32 styleTokenId, uint32 spliceTokenId) = styleAndTokenByTokenId(
      tokenId
    );
    if (styleNFT.isFrozen(styleTokenId)) {
      StyleSettings memory settings = styleNFT.getSettings(styleTokenId);
      return
        string(
          abi.encodePacked(
            'ipfs://',
            settings.styleCID,
            '/',
            spliceTokenId.toString()
          )
        );
    } else {
      return super.tokenURI(tokenId);
    }
  }

  function quote(
    uint32 styleTokenId,
    IERC721[] memory nfts,
    uint256[] memory originTokenIds
  ) external view returns (uint256 fee) {

    return styleNFT.quoteFee(styleTokenId, nfts, originTokenIds);
  }

  function updateRoyalties(uint8 royaltyPercentage) external onlyOwner {

    require(royaltyPercentage <= 10, 'royalties must never exceed 10%');
    ROYALTY_PERCENT = royaltyPercentage;
    emit RoyaltiesUpdated(royaltyPercentage);
  }

  function royaltyInfo(uint256 tokenId, uint256 salePrice)
    public
    view
    returns (address receiver, uint256 royaltyAmount)
  {

    (uint32 styleTokenId, ) = styleAndTokenByTokenId(tokenId);
    receiver = styleNFT.getSettings(styleTokenId).paymentSplitter;
    royaltyAmount = (ROYALTY_PERCENT * salePrice).div(100);
  }

  function mint(
    IERC721[] memory originCollections,
    uint256[] memory originTokenIds,
    uint32 styleTokenId,
    bytes32[] memory allowlistProof,
    bytes calldata inputParams
  ) external payable whenNotPaused nonReentrant returns (uint64 tokenId) {

    require(
      styleNFT.isMintable(
        styleTokenId,
        originCollections,
        originTokenIds,
        msg.sender
      )
    );

    if (styleNFT.availableForPublicMinting(styleTokenId) == 0) {
      if (
        allowlistProof.length == 0 ||
        !styleNFT.verifyAllowlistEntryProof(
          styleTokenId,
          allowlistProof,
          msg.sender
        )
      ) {
        revert NotAllowedToMint('no reservations left or proof failed');
      } else {
        styleNFT.decreaseAllowance(styleTokenId, msg.sender);
      }
    }

    uint256 fee = styleNFT.quoteFee(
      styleTokenId,
      originCollections,
      originTokenIds
    );
    if (msg.value < fee) revert InsufficientFees();

    bytes32 _provenanceHash = keccak256(
      abi.encodePacked(originCollections, originTokenIds, styleTokenId)
    );

    if (provenanceToTokenId[_provenanceHash] != 0x0) {
      revert ProvenanceAlreadyUsed();
    }

    uint32 nextStyleMintId = styleNFT.incrementMintedPerStyle(styleTokenId);
    tokenId = BytesLib.toUint64(
      abi.encodePacked(styleTokenId, nextStyleMintId),
      0
    );
    provenanceToTokenId[_provenanceHash] = tokenId;

    for (uint256 i = 0; i < originCollections.length; i++) {
      address _owner = originCollections[i].ownerOf(originTokenIds[i]);
      if (_owner != msg.sender || _owner == address(0)) {
        revert NotOwningOrigin();
      }
    }

    AddressUpgradeable.sendValue(
      payable(styleNFT.getSettings(styleTokenId).paymentSplitter),
      fee
    );

    _safeMint(msg.sender, tokenId);

    emit Minted(
      keccak256(abi.encode(originCollections, originTokenIds)),
      tokenId,
      styleTokenId
    );

    uint256 surplus = msg.value.sub(fee);

    if (surplus > 0 && surplus < 100_000_000 gwei) {
      AddressUpgradeable.sendValue(payable(msg.sender), surplus);
    }

    return tokenId;
  }
}// contracts/SpliceStyleNFT.sol


pragma solidity 0.8.10;



contract SpliceStyleNFT is
  ERC721EnumerableUpgradeable,
  OwnableUpgradeable,
  ReentrancyGuardUpgradeable
{

  using CountersUpgradeable for CountersUpgradeable.Counter;
  using SafeCastUpgradeable for uint256;

  error BadReservationParameters(uint32 reservation, uint32 mintsLeft);
  error AllowlistDurationTooShort(uint256 diff);

  error AllowlistNotOverridable(uint32 styleTokenId);

  error NotControllingStyle(uint32 styleTokenId);

  error StyleIsFullyMinted();

  error SaleNotActive(uint32 styleTokenId);

  error PersonalReservationLimitExceeded(uint32 styleTokenId);

  error NotEnoughTokensToMatchReservation(uint32 styleTokenId);

  error StyleIsFrozen();

  error OriginNotAllowed(string reason);

  error BadMintInput(string reason);

  error CantFreezeAnUncompleteCollection(uint32 mintsLeft);

  error InvalidCID();

  event PermanentURI(string _value, uint256 indexed _id);
  event Minted(uint32 indexed styleTokenId, uint32 cap, string metadataCID);
  event SharesChanged(uint16 percentage);
  event AllowlistInstalled(
    uint32 indexed styleTokenId,
    uint32 reserved,
    uint8 mintsPerAddress,
    uint64 until
  );

  CountersUpgradeable.Counter private _styleTokenIds;

  mapping(address => bool) public isStyleMinter;
  mapping(uint32 => StyleSettings) styleSettings;
  mapping(uint32 => Allowlist) allowlists;

  mapping(uint32 => mapping(address => uint8)) mintsAlreadyAllowed;

  mapping(uint32 => Partnership) private _partnerships;

  uint16 public ARTIST_SHARE;

  Splice public spliceNFT;

  PaymentSplitterController public paymentSplitterController;

  function initialize() public initializer {

    __ERC721_init('Splice Style NFT', 'SPLYLE');
    __ERC721Enumerable_init_unchained();
    __Ownable_init_unchained();
    __ReentrancyGuard_init();
    ARTIST_SHARE = 8500;
  }

  modifier onlyStyleMinter() {

    require(isStyleMinter[msg.sender], 'not allowed to mint styles');
    _;
  }

  modifier onlySplice() {

    require(msg.sender == address(spliceNFT), 'only callable by Splice');
    _;
  }

  modifier controlsStyle(uint32 styleTokenId) {

    if (!isStyleMinter[msg.sender] && msg.sender != ownerOf(styleTokenId)) {
      revert NotControllingStyle(styleTokenId);
    }
    _;
  }

  function updateArtistShare(uint16 share) public onlyOwner {

    require(share <= 10000 && share > 7500, 'we will never take more than 25%');
    ARTIST_SHARE = share;
    emit SharesChanged(share);
  }

  function setPaymentSplitter(PaymentSplitterController ps) external onlyOwner {

    if (address(paymentSplitterController) != address(0)) {
      revert('can only be called once.');
    }
    paymentSplitterController = ps;
  }

  function setSplice(Splice _spliceNFT) external onlyOwner {

    if (address(spliceNFT) != address(0)) {
      revert('can only be called once.');
    }
    spliceNFT = _spliceNFT;
  }

  function toggleStyleMinter(address minter, bool newValue) external onlyOwner {

    isStyleMinter[minter] = newValue;
  }

  function getPartnership(uint32 styleTokenId)
    public
    view
    returns (
      address[] memory collections,
      uint256 until,
      bool exclusive
    )
  {

    Partnership memory p = _partnerships[styleTokenId];
    return (p.collections, p.until, p.exclusive);
  }

  function _metadataURI(string memory metadataCID)
    private
    pure
    returns (string memory)
  {

    return string(abi.encodePacked('ipfs://', metadataCID, '/metadata.json'));
  }

  function tokenURI(uint256 tokenId)
    public
    view
    override
    returns (string memory)
  {

    require(_exists(tokenId), 'nonexistent token');
    return _metadataURI(styleSettings[uint32(tokenId)].styleCID);
  }

  function quoteFee(
    uint32 styleTokenId,
    IERC721[] memory originCollections,
    uint256[] memory originTokenIds
  ) public view returns (uint256 fee) {

    fee = styleSettings[styleTokenId].priceStrategy.quote(
      styleTokenId,
      originCollections,
      originTokenIds
    );
  }

  function getSettings(uint32 styleTokenId)
    public
    view
    returns (StyleSettings memory)
  {

    return styleSettings[styleTokenId];
  }

  function isSaleActive(uint32 styleTokenId) public view returns (bool) {

    return styleSettings[styleTokenId].salesIsActive;
  }

  function toggleSaleIsActive(uint32 styleTokenId, bool newValue)
    external
    controlsStyle(styleTokenId)
  {

    if (isFrozen(styleTokenId)) {
      revert StyleIsFrozen();
    }
    styleSettings[styleTokenId].salesIsActive = newValue;
  }

  function mintsLeft(uint32 styleTokenId) public view returns (uint32) {

    return
      styleSettings[styleTokenId].cap -
      styleSettings[styleTokenId].mintedOfStyle;
  }

  function reservedTokens(uint32 styleTokenId) public view returns (uint32) {

    if (block.timestamp > allowlists[styleTokenId].reservedUntil) {
      return 0;
    }
    return allowlists[styleTokenId].numReserved;
  }

  function availableForPublicMinting(uint32 styleTokenId)
    public
    view
    returns (uint32)
  {

    return
      styleSettings[styleTokenId].cap -
      styleSettings[styleTokenId].mintedOfStyle -
      reservedTokens(styleTokenId);
  }


  function verifyAllowlistEntryProof(
    uint32 styleTokenId,
    bytes32[] memory allowlistProof,
    address requestor
  ) external view returns (bool) {

    return
      MerkleProofUpgradeable.verify(
        allowlistProof,
        allowlists[styleTokenId].merkleRoot,
        keccak256(abi.encodePacked(requestor))
      );
  }

  function decreaseAllowance(uint32 styleTokenId, address requestor)
    external
    nonReentrant
    onlySplice
  {

    if (
      mintsAlreadyAllowed[styleTokenId][requestor] + 1 >
      allowlists[styleTokenId].mintsPerAddress
    ) {
      revert PersonalReservationLimitExceeded(styleTokenId);
    }

    if (allowlists[styleTokenId].numReserved < 1) {
      revert NotEnoughTokensToMatchReservation(styleTokenId);
    }
    allowlists[styleTokenId].numReserved -= 1;
    mintsAlreadyAllowed[styleTokenId][requestor] += 1;
  }

  function addAllowlist(
    uint32 styleTokenId,
    uint32 numReserved_,
    uint8 mintsPerAddress_,
    bytes32 merkleRoot_,
    uint64 reservedUntil_
  ) external controlsStyle(styleTokenId) {

    if (allowlists[styleTokenId].reservedUntil != 0) {
      revert AllowlistNotOverridable(styleTokenId);
    }

    uint32 stillAvailable = mintsLeft(styleTokenId);
    if (
      numReserved_ > stillAvailable || mintsPerAddress_ > stillAvailable //that 2nd edge case is actually not important (minting would fail anyway when cap is exceeded)
    ) {
      revert BadReservationParameters(numReserved_, stillAvailable);
    }

    if (reservedUntil_ < block.timestamp + 1 days) {
      revert AllowlistDurationTooShort(reservedUntil_);
    }

    allowlists[styleTokenId] = Allowlist({
      numReserved: numReserved_,
      merkleRoot: merkleRoot_,
      reservedUntil: reservedUntil_,
      mintsPerAddress: mintsPerAddress_
    });
    emit AllowlistInstalled(
      styleTokenId,
      numReserved_,
      mintsPerAddress_,
      reservedUntil_
    );
  }

  function isMintable(
    uint32 styleTokenId,
    IERC721[] memory originCollections,
    uint256[] memory originTokenIds,
    address minter
  ) public view returns (bool) {

    if (!isSaleActive(styleTokenId)) {
      revert SaleNotActive(styleTokenId);
    }

    if (
      originCollections.length == 0 ||
      originTokenIds.length == 0 ||
      originCollections.length != originTokenIds.length
    ) {
      revert BadMintInput('inconsistent input lengths');
    }

    if (styleSettings[styleTokenId].maxInputs < originCollections.length) {
      revert OriginNotAllowed('too many inputs');
    }

    Partnership memory partnership = _partnerships[styleTokenId];
    bool partnershipIsActive = (partnership.collections.length > 0 &&
      partnership.until > block.timestamp);
    uint8 partner_count = 0;
    for (uint256 i = 0; i < originCollections.length; i++) {
      if (i > 0) {
        if (
          address(originCollections[i]) <= address(originCollections[i - 1])
        ) {
          revert BadMintInput('duplicate or unordered origin input');
        }
      }
      if (partnershipIsActive) {
        if (
          ArrayLib.contains(
            partnership.collections,
            address(originCollections[i])
          )
        ) {
          partner_count++;
        }
      }
    }

    if (partnershipIsActive) {
      if (partnership.exclusive) {
        if (partner_count != originCollections.length) {
          revert OriginNotAllowed('exclusive partnership');
        }
      }
    }

    return true;
  }

  function isFrozen(uint32 styleTokenId) public view returns (bool) {

    return styleSettings[styleTokenId].isFrozen;
  }

  function freeze(uint32 styleTokenId, string memory cid)
    public
    onlyStyleMinter
  {

    if (bytes(cid).length < 46) {
      revert InvalidCID();
    }

    if (mintsLeft(styleTokenId) != 0) {
      revert CantFreezeAnUncompleteCollection(mintsLeft(styleTokenId));
    }

    styleSettings[styleTokenId].salesIsActive = false;
    styleSettings[styleTokenId].styleCID = cid;
    styleSettings[styleTokenId].isFrozen = true;
    emit PermanentURI(tokenURI(styleTokenId), styleTokenId);
  }

  function incrementMintedPerStyle(uint32 styleTokenId)
    public
    onlySplice
    returns (uint32)
  {

    if (!isSaleActive(styleTokenId)) {
      revert SaleNotActive(styleTokenId);
    }

    if (mintsLeft(styleTokenId) == 0) {
      revert StyleIsFullyMinted();
    }
    styleSettings[styleTokenId].mintedOfStyle += 1;
    styleSettings[styleTokenId].priceStrategy.onMinted(styleTokenId);
    return styleSettings[styleTokenId].mintedOfStyle;
  }

  function enablePartnership(
    address[] memory collections,
    uint32 styleTokenId,
    uint64 until,
    bool exclusive
  ) external onlyStyleMinter {

    require(
      styleSettings[styleTokenId].mintedOfStyle == 0,
      'cant add a partnership after minting started'
    );

    _partnerships[styleTokenId] = Partnership({
      collections: collections,
      until: until,
      exclusive: exclusive
    });
  }

  function setupPaymentSplitter(
    uint256 styleTokenId,
    address artist,
    address partner
  ) internal returns (address ps) {

    address[] memory members;
    uint256[] memory shares;

    if (partner != address(0)) {
      members = new address[](3);
      shares = new uint256[](3);
      uint256 splitShare = (10_000 - ARTIST_SHARE) / 2;

      members[0] = artist;
      shares[0] = ARTIST_SHARE;
      members[1] = spliceNFT.platformBeneficiary();
      shares[1] = splitShare;
      members[2] = partner;
      shares[2] = splitShare;
    } else {
      members = new address[](2);
      shares = new uint256[](2);
      members[0] = artist;
      shares[0] = ARTIST_SHARE;
      members[1] = spliceNFT.platformBeneficiary();
      shares[1] = 10_000 - ARTIST_SHARE;
    }

    ps = paymentSplitterController.createSplit(styleTokenId, members, shares);
  }

  function mint(
    uint32 cap_,
    string memory metadataCID_,
    ISplicePriceStrategy priceStrategy_,
    bool salesIsActive_,
    uint8 maxInputs_,
    address artist_,
    address partnershipBeneficiary_
  ) external onlyStyleMinter returns (uint32 styleTokenId) {

    if (bytes(metadataCID_).length < 46) {
      revert InvalidCID();
    }

    if (artist_ == address(0)) {
      artist_ = msg.sender;
    }
    _styleTokenIds.increment();
    styleTokenId = _styleTokenIds.current().toUint32();

    styleSettings[styleTokenId] = StyleSettings({
      mintedOfStyle: 0,
      cap: cap_,
      priceStrategy: priceStrategy_,
      salesIsActive: salesIsActive_,
      isFrozen: false,
      styleCID: metadataCID_,
      maxInputs: maxInputs_,
      paymentSplitter: setupPaymentSplitter(
        styleTokenId,
        artist_,
        partnershipBeneficiary_
      )
    });

    _safeMint(artist_, styleTokenId);
    emit Minted(styleTokenId, cap_, metadataCID_);
  }

  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 tokenId
  ) internal virtual override {

    super._beforeTokenTransfer(from, to, tokenId);
    if (from != address(0) && to != address(0)) {
      paymentSplitterController.replaceShareholder(tokenId, payable(from), to);
    }
  }
}// contracts/ReplaceablePaymentSplitter.sol


pragma solidity 0.8.10;


contract ReplaceablePaymentSplitter is Context, Initializable {

  event PayeeAdded(address indexed account, uint256 shares);
  event PayeeReplaced(
    address indexed old,
    address indexed new_,
    uint256 shares
  );
  event PaymentReleased(address to, uint256 amount);
  event ERC20PaymentReleased(IERC20 indexed token, address to, uint256 amount);
  event PaymentReceived(address from, uint256 amount);

  uint256 private _totalShares;
  uint256 private _totalReleased;

  mapping(address => uint256) private _shares;
  mapping(address => uint256) private _released;
  address[] private _payees;

  mapping(IERC20 => uint256) private _erc20TotalReleased;
  mapping(IERC20 => mapping(address => uint256)) private _erc20Released;

  address private _controller;

  modifier onlyController() {

    require(msg.sender == address(_controller), 'only callable by controller');
    _;
  }

  function initialize(
    address controller,
    address[] memory payees_,
    uint256[] memory shares_
  ) external payable initializer {

    require(controller != address(0), 'controller mustnt be 0');
    _controller = controller;

    uint256 len = payees_.length;
    uint256 __totalShares = _totalShares;
    for (uint256 i = 0; i < len; i++) {
      _addPayee(payees_[i], shares_[i]);
      __totalShares += shares_[i];
    }
    _totalShares = __totalShares;
  }

  receive() external payable virtual {
    emit PaymentReceived(_msgSender(), msg.value);
  }

  function totalShares() public view returns (uint256) {

    return _totalShares;
  }

  function totalReleased() public view returns (uint256) {

    return _totalReleased;
  }

  function totalReleased(IERC20 token) public view returns (uint256) {

    return _erc20TotalReleased[token];
  }

  function shares(address account) public view returns (uint256) {

    return _shares[account];
  }

  function released(address account) public view returns (uint256) {

    return _released[account];
  }

  function released(IERC20 token, address account)
    public
    view
    returns (uint256)
  {

    return _erc20Released[token][account];
  }

  function payee(uint256 index) public view returns (address) {

    return _payees[index];
  }

  function release(address payable account) external virtual {

    require(_shares[account] > 0, 'PaymentSplitter: account has no shares');

    uint256 totalReceived = address(this).balance + totalReleased();
    uint256 payment = _pendingPayment(
      account,
      totalReceived,
      released(account)
    );

    require(payment != 0, 'PaymentSplitter: account is not due payment');

    _released[account] += payment;
    _totalReleased += payment;

    AddressUpgradeable.sendValue(account, payment);
    emit PaymentReleased(account, payment);
  }

  function release(IERC20 token, address account) external virtual {

    require(_shares[account] > 0, 'PaymentSplitter: account has no shares');

    uint256 totalReceived = token.balanceOf(address(this)) +
      totalReleased(token);
    uint256 payment = _pendingPayment(
      account,
      totalReceived,
      released(token, account)
    );

    require(payment != 0, 'PaymentSplitter: account is not due payment');

    _erc20Released[token][account] += payment;
    _erc20TotalReleased[token] += payment;

    SafeERC20.safeTransfer(token, account, payment);
    emit ERC20PaymentReleased(token, account, payment);
  }

  function _pendingPayment(
    address account,
    uint256 totalReceived,
    uint256 alreadyReleased
  ) private view returns (uint256) {

    return (totalReceived * _shares[account]) / _totalShares - alreadyReleased;
  }

  function _addPayee(address account, uint256 shares_) private {

    require(
      account != address(0),
      'PaymentSplitter: account is the zero address'
    );
    require(shares_ > 0, 'PaymentSplitter: shares are 0');
    require(
      _shares[account] == 0,
      'PaymentSplitter: account already has shares'
    );

    _payees.push(account);
    _shares[account] = shares_;
    emit PayeeAdded(account, shares_);
  }

  function replacePayee(address old, address new_) external onlyController {

    uint256 oldShares = _shares[old];
    require(oldShares > 0, 'PaymentSplitter: old account has no shares');
    require(
      new_ != address(0),
      'PaymentSplitter: new account is the zero address'
    );
    require(
      _shares[new_] == 0,
      'PaymentSplitter: new account already has shares'
    );

    uint256 idx = 0;
    while (idx < _payees.length) {
      if (_payees[idx] == old) {
        _payees[idx] = new_;
        _shares[old] = 0;
        _shares[new_] = oldShares;
        _released[new_] = _released[old];
        emit PayeeReplaced(old, new_, oldShares);
        return;
      }
      idx++;
    }
  }

  function due(address account) external view returns (uint256 pending) {

    uint256 totalReceived = address(this).balance + totalReleased();
    return _pendingPayment(account, totalReceived, released(account));
  }

  function due(IERC20 token, address account)
    external
    view
    returns (uint256 pending)
  {

    uint256 totalReceived = token.balanceOf(address(this)) +
      totalReleased(token);
    return _pendingPayment(account, totalReceived, released(token, account));
  }
}// contracts/PaymentSplitterController.sol


pragma solidity 0.8.10;


contract PaymentSplitterController is
  Initializable,
  ReentrancyGuardUpgradeable
{

  mapping(uint256 => ReplaceablePaymentSplitter) public splitters;

  address[] private PAYMENT_TOKENS;

  address private _splitterTemplate;

  address private _owner;

  function initialize(address owner_, address[] memory paymentTokens_)
    public
    initializer
  {

    __ReentrancyGuard_init();
    require(owner_ != address(0), 'initial owner mustnt be 0');
    _owner = owner_;
    PAYMENT_TOKENS = paymentTokens_;

    _splitterTemplate = address(new ReplaceablePaymentSplitter());
  }

  modifier onlyOwner() {

    require(msg.sender == _owner, 'only callable by owner');
    _;
  }

  function createSplit(
    uint256 tokenId,
    address[] memory payees_,
    uint256[] memory shares_
  ) external onlyOwner returns (address ps_address) {

    require(payees_.length == shares_.length, 'p and s len mismatch');
    require(payees_.length > 0, 'no payees');
    require(address(splitters[tokenId]) == address(0), 'ps exists');

    ps_address = Clones.clone(_splitterTemplate);
    ReplaceablePaymentSplitter ps = ReplaceablePaymentSplitter(
      payable(ps_address)
    );
    splitters[tokenId] = ps;
    ps.initialize(address(this), payees_, shares_);
  }

  function withdrawAll(address payable payee, address[] memory splitters_)
    external
    nonReentrant
  {

    for (uint256 i = 0; i < splitters_.length; i++) {
      releaseAll(ReplaceablePaymentSplitter(payable(splitters_[i])), payee);
    }
  }

  function releaseAll(ReplaceablePaymentSplitter ps, address payable account)
    internal
  {

    try ps.release(account) {
    } catch {
    }
    for (uint256 i = 0; i < PAYMENT_TOKENS.length; i++) {
      try ps.release(IERC20(PAYMENT_TOKENS[i]), account) {
      } catch {
      }
    }
  }

  function replaceShareholder(
    uint256 styleTokenId,
    address payable from,
    address to
  ) external onlyOwner nonReentrant {

    ReplaceablePaymentSplitter ps = splitters[styleTokenId];
    releaseAll(ps, from);
    ps.replacePayee(from, to);
  }
}