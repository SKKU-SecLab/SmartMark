
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


abstract contract ERC721BurnableUpgradeable is Initializable, ContextUpgradeable, ERC721Upgradeable {
    function __ERC721Burnable_init() internal onlyInitializing {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC721Burnable_init_unchained();
    }

    function __ERC721Burnable_init_unchained() internal onlyInitializing {
    }
    function burn(uint256 tokenId) public virtual {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        _burn(tokenId);
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.9;

struct Bag {
    uint64 totalManaProduced;
    uint64 mintCount;
}

struct Crystal {
    uint16 attunement;
    uint64 lastClaim;
    uint16 focus;
    uint32 focusManaProduced;
    uint32 regNum;
    uint16 lvlClaims;
}

interface ICrystalsMetadata {

    function tokenURI(uint256 tokenId) external view returns (string memory);

}

interface ICrystals {

    function crystalsMap(uint256 tokenID) external view returns (Crystal memory);

    function bags(uint256 tokenID) external view returns (Bag memory);

    function getResonance(uint256 tokenId) external view returns (uint32);

    function getSpin(uint256 tokenId) external view returns (uint32);

    function claimableMana(uint256 tokenID) external view returns (uint32);

    function availableClaims(uint256 tokenId) external view returns (uint8);

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    function transferFrom(address from, address to, uint256 tokenId) external;

}

library Base64 {

    bytes internal constant TABLE =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    function encode(bytes memory data) internal pure returns (string memory) {

        uint256 len = data.length;
        if (len == 0) return "";

        uint256 encodedLen = 4 * ((len + 2) / 3);

        bytes memory result = new bytes(encodedLen + 32);

        bytes memory table = TABLE;

        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)

            for {
                let i := 0
            } lt(i, len) {

            } {
                i := add(i, 3)
                let input := and(mload(add(data, i)), 0xffffff)

                let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
                out := shl(8, out)
                out := add(
                    out,
                    and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF)
                )
                out := shl(8, out)
                out := add(
                    out,
                    and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF)
                )
                out := shl(8, out)
                out := add(
                    out,
                    and(mload(add(tablePtr, and(input, 0x3F))), 0xFF)
                )
                out := shl(224, out)

                mstore(resultPtr, out)

                resultPtr := add(resultPtr, 4)
            }

            switch mod(len, 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }

            mstore(result, encodedLen)
        }

        return string(result);
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
}/*

 ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄       ▄▄▄▄▄▄▄▄▄▄   ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄ 
▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌     ▐░░░░░░░░░░▌ ▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌
▐░█▀▀▀▀▀▀▀█░▌ ▀▀▀▀█░█▀▀▀▀ ▐░█▀▀▀▀▀▀▀▀▀  ▀▀▀▀█░█▀▀▀▀      ▐░█▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀█░▌ ▀▀▀▀█░█▀▀▀▀ ▐░█▀▀▀▀▀▀▀█░▌
▐░▌       ▐░▌     ▐░▌     ▐░▌               ▐░▌          ▐░▌       ▐░▌▐░▌       ▐░▌     ▐░▌     ▐░▌       ▐░▌
▐░█▄▄▄▄▄▄▄█░▌     ▐░▌     ▐░█▄▄▄▄▄▄▄▄▄      ▐░▌          ▐░▌       ▐░▌▐░█▄▄▄▄▄▄▄█░▌     ▐░▌     ▐░█▄▄▄▄▄▄▄█░▌
▐░░░░░░░░░░░▌     ▐░▌     ▐░░░░░░░░░░░▌     ▐░▌          ▐░▌       ▐░▌▐░░░░░░░░░░░▌     ▐░▌     ▐░░░░░░░░░░░▌
▐░█▀▀▀▀█░█▀▀      ▐░▌     ▐░█▀▀▀▀▀▀▀▀▀      ▐░▌          ▐░▌       ▐░▌▐░█▀▀▀▀▀▀▀█░▌     ▐░▌     ▐░█▀▀▀▀▀▀▀█░▌
▐░▌     ▐░▌       ▐░▌     ▐░▌               ▐░▌          ▐░▌       ▐░▌▐░▌       ▐░▌     ▐░▌     ▐░▌       ▐░▌
▐░▌      ▐░▌  ▄▄▄▄█░█▄▄▄▄ ▐░▌               ▐░▌          ▐░█▄▄▄▄▄▄▄█░▌▐░▌       ▐░▌     ▐░▌     ▐░▌       ▐░▌
▐░▌       ▐░▌▐░░░░░░░░░░░▌▐░▌               ▐░▌          ▐░░░░░░░░░░▌ ▐░▌       ▐░▌     ▐░▌     ▐░▌       ▐░▌
 ▀         ▀  ▀▀▀▀▀▀▀▀▀▀▀  ▀                 ▀            ▀▀▀▀▀▀▀▀▀▀   ▀         ▀       ▀       ▀         ▀ 
     by chris and tony                                                                                                       
*/


pragma solidity ^0.8.9;


struct RiftBag {
        uint16 charges;
        uint32 chargesUsed;
        uint16 level;
        uint64 xp;
        uint64 lastChargePurchase;
    }

interface IRiftData {

    function bags(uint256 bagId) external view returns (RiftBag memory);

    function addCharges(uint16 charges, uint256 bagId) external;

    function removeCharges(uint16 charges, uint256 bagId) external;

    function updateLevel(uint16 level, uint256 bagId) external;

    function updateXP(uint64 xp, uint256 bagId) external;

    function addKarma(uint64 k, address holder) external;

    function removeKarma(uint64 k, address holder) external;

    function updateLastChargePurchase(uint64 time, uint256 bagId) external;

    function karma(address holder) external view returns (uint64);

    function karmaTotal() external view returns (uint256);

    function karmaHolders() external view returns (uint256);

}

contract RiftData is IRiftData, OwnableUpgradeable {

    mapping(address => bool) public riftControllers;

    uint256 public karmaTotal;
    uint256 public karmaHolders;

    mapping(uint256 => RiftBag) internal _bags;
    mapping(address => uint64) public karma;

     function initialize() public initializer {

        __Ownable_init();
     }

    function addRiftController(address addr) external onlyOwner {

        riftControllers[addr] = true;
    }

    function removeRiftController(address addr) external onlyOwner {

        riftControllers[addr] = false;
    }

    modifier onlyRiftController() {

        require(riftControllers[msg.sender], "NO!");
        _;
    }

    function bags(uint256 bagId) external view override returns (RiftBag memory) {

        return _bags[bagId];
    }

    function getBags(uint256[] calldata bagIds) external view returns (RiftBag[] memory output) {

        for(uint256 i = 0; i < bagIds.length; i++) {
            output[i] = _bags[bagIds[i]];
        }

        return output;
    }

    function addCharges(uint16 charges, uint256 bagId) external override onlyRiftController {

        _bags[bagId].charges += charges;
    }

    function removeCharges(uint16 charges, uint256 bagId) external override onlyRiftController {

        require(_bags[bagId].charges >= charges, "Not enough charges");
        _bags[bagId].charges -= charges;
        _bags[bagId].chargesUsed += charges;
    }

    function updateLevel(uint16 level, uint256 bagId) external override onlyRiftController {

        _bags[bagId].level = level;
    }

    function updateXP(uint64 xp, uint256 bagId) external override onlyRiftController {

        _bags[bagId].xp = xp;
    }

    function addKarma(uint64 k, address holder) external override onlyRiftController {

        if (karma[holder] == 0) { karmaHolders += 1; }
        karmaTotal += k;
        karma[holder] += k;
    }

    function removeKarma(uint64 k, address holder) external override onlyRiftController {

        k > karma[holder] ? karma[holder] = 0 : karma[holder] -= k;
    }

    function updateLastChargePurchase(uint64 time, uint256 bagId) external override onlyRiftController {

        _bags[bagId].lastChargePurchase = time;
    }
}// MIT

pragma solidity ^0.8.9;


interface IRift {

    function riftLevel() external view returns (uint32);

    function setupNewBag(uint256 bagId) external;

    function useCharge(uint16 amount, uint256 bagId, address from) external;

    function bags(uint256 bagId) external view returns (RiftBag memory);

    function awardXP(uint32 bagId, uint16 xp) external;

    function isBagHolder(uint256 bagId, address owner) external;

}

struct BagProgress {
    uint32 lastCompletedStep;
    bool completedQuest;
}

struct BurnableObject {
    uint64 power;
    uint32 mana;
    uint16 xp;
}

interface IRiftBurnable {

    function burnObject(uint256 tokenId) external view returns (BurnableObject memory);

}

interface IMana {

    function ccMintTo(address recipient, uint256 amount) external;

    function burn(address from, uint256 amount) external;

}/*

▄▄▄█████▓ ██░ ██ ▓█████     ██▀███   ██▓  █████▒▄▄▄█████▓   (for Adventurers)
▓  ██▒ ▓▒▓██░ ██▒▓█   ▀    ▓██ ▒ ██▒▓██▒▓██   ▒ ▓  ██▒ ▓▒
▒ ▓██░ ▒░▒██▀▀██░▒███      ▓██ ░▄█ ▒▒██▒▒████ ░ ▒ ▓██░ ▒░
░ ▓██▓ ░ ░▓█ ░██ ▒▓█  ▄    ▒██▀▀█▄  ░██░░▓█▒  ░ ░ ▓██▓ ░ 
  ▒██▒ ░ ░▓█▒░██▓░▒████▒   ░██▓ ▒██▒░██░░▒█░      ▒██▒ ░ 
  ▒ ░░    ▒ ░░▒░▒░░ ▒░ ░   ░ ▒▓ ░▒▓░░▓   ▒ ░      ▒ ░░   
    ░     ▒ ░▒░ ░ ░ ░  ░     ░▒ ░ ▒░ ▒ ░ ░          ░    
  ░       ░  ░░ ░   ░        ░░   ░  ▒ ░ ░ ░      ░      
          ░  ░  ░   ░  ░      ░      ░                   
                                                         
    by chris and tony
    
*/

pragma solidity ^0.8.9;




contract Rift is Initializable, ReentrancyGuardUpgradeable, PausableUpgradeable, OwnableUpgradeable {


    event AddCharge(address indexed owner, uint256 indexed tokenId, uint16 amount, uint16 forLvl);
    event AwardXP(uint256 indexed tokenId, uint256 amount);
    event UseCharge(address indexed owner, address indexed riftObject, uint256 indexed tokenId, uint16 amount);
    event ObjectSacrificed(address indexed owner, address indexed object, uint256 tokenId, uint256 indexed bagId, uint256 powerIncrease);

    IERC721 public iLoot;
    IERC721 public iMLoot;
    IERC721 public iGLoot;
    IMana public iMana;
    IRiftData public iRiftData;
    uint32 constant glootOffset = 9997460;

    string public description;

    uint32 public riftLevel;
    uint256 public riftPower;

    uint8 internal riftLevelIncreasePercentage; 
    uint8 internal riftLevelDecreasePercentage; 
    uint256 internal riftLevelMinThreshold;
    uint256 internal riftLevelMaxThreshold;
    uint256 internal riftCallibratedTime; 

    uint64 public riftObjectsSacrificed;

    mapping(uint16 => uint16) public levelChargeAward;
    mapping(address => bool) public riftObjects;
    mapping(address => bool) public riftQuests;
    mapping(address => BurnableObject) public staticBurnObjects;
    address[] public riftObjectsArr;
    address[] public staticBurnableArr;

    function initialize(address lootAddr, address mlootAddr, address glootAddr) public initializer {

        __Ownable_init();
        __Pausable_init();
        __ReentrancyGuard_init();

        iLoot = IERC721(lootAddr);
        iMLoot = IERC721(mlootAddr);
        iGLoot = IERC721(glootAddr);

        description = "The Rift inbetween";

        riftLevel = 2;
        riftLevelIncreasePercentage = 10; 
        riftLevelDecreasePercentage = 9;
        riftLevelMinThreshold = 21000;
        riftLevelMaxThreshold = 33100;
        riftPower = 35000;
        riftObjectsSacrificed = 0;
        riftCallibratedTime = block.timestamp;
    }

    function ownerSetDescription(string memory desc) external onlyOwner {

        description = desc;
    }

     function ownerSetManaAddress(address addr) external onlyOwner {

        iMana = IMana(addr);
    }

    function ownerSetRiftData(address addr) external onlyOwner {

        iRiftData = IRiftData(addr);
    }

    function addRiftQuest(address addr) external onlyOwner {

        riftQuests[addr] = true;
    }

    function removeRiftQuest(address addr) external onlyOwner {

        riftQuests[addr] = false;
    }

    function addRiftObject(address controller) external onlyOwner {

        riftObjects[controller] = true;
        riftObjectsArr.push(controller);
    }

    function removeRiftObject(address controller) external onlyOwner {

        riftObjects[controller] = false;
    }

    function addStaticBurnable(address burnable, uint64 _power, uint32 _mana, uint16 _xp) external onlyOwner {

        staticBurnObjects[burnable] = BurnableObject({
            power: _power,
            mana: _mana,
            xp: _xp
        });
        staticBurnableArr.push(burnable);
    }

    function setPaused(bool _paused) external onlyOwner {

        if (_paused) _pause();
        else _unpause();
    }

    function ownerWithdraw() external onlyOwner {

        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    function ownerSetLevelChargeAward(uint16 level, uint16 charges) external onlyOwner {

        levelChargeAward[level] = charges;
    }


    function isBagHolder(uint256 bagId, address owner) _isBagHolder(bagId, owner) external view {}


    function bags(uint256 bagId) external view returns (RiftBag memory) {

        return iRiftData.bags(bagId);
    }
    

    function buyCharge(uint256 bagId) external
        _isBagHolder(bagId, _msgSender()) 
        whenNotPaused 
        nonReentrant {

        require(block.timestamp - iRiftData.bags(bagId).lastChargePurchase > 1 days, "Too soon"); 
        require(riftLevel > 0, "rift has no power");
        iMana.burn(_msgSender(), iRiftData.bags(bagId).level * ((bagId < 8001 || bagId > glootOffset) ? 100 : 10));
        _chargeBag(bagId, 1, iRiftData.bags(bagId).level);
        iRiftData.updateLastChargePurchase(uint64(block.timestamp), bagId);
    }

    function useCharge(uint16 amount, uint256 bagId, address from) 
        _isBagHolder(bagId, from) 
        external 
        whenNotPaused 
        nonReentrant 
    {

        require(riftObjects[msg.sender], "Not of the Rift");
        iRiftData.removeCharges(amount, bagId);
        
        emit UseCharge(from, _msgSender(), bagId, amount);
    }

    function awardXP(uint32 bagId, uint16 xp) external nonReentrant whenNotPaused {

        require(riftQuests[msg.sender], "only the worthy");
        _awardXP(bagId, xp);
    }

    function _awardXP(uint32 bagId, uint16 xp) internal {

        RiftBag memory bag = iRiftData.bags(bagId);
        uint16 newlvl = bag.level;

        if (bag.level == 0) {
            newlvl = 1;
            _chargeBag(bagId, levelChargeAward[newlvl], newlvl);
        }
        

        uint64 _xp = uint64(xp + bag.xp);

        while (_xp >= xpRequired(newlvl)) {
            _xp -= xpRequired(newlvl);
            newlvl += 1;
            _chargeBag(bagId, levelChargeAward[newlvl], newlvl);
        }

        iRiftData.updateXP(_xp, bagId);
        iRiftData.updateLevel(newlvl, bagId);
        emit AwardXP(bagId, xp);
    }

    function xpRequired(uint32 level) public pure returns (uint64) {

        if (level == 1) { return 65; }
        else if (level == 2) { return 130; }
        else if (level == 3) { return 260; }
        
        return uint64(260*(115**(level-3))/(100**(level-3)));
    }

    function _chargeBag(uint256 bagId, uint16 charges, uint16 forLvl) internal {

        if (riftLevel == 0) {
            return; // no power in the rift
        }
        if (charges == 0) {
            charges = forLvl/10;
            charges += forLvl%5 == 0 ? 1 : 0; // bonus on every fifth lvl
            charges += forLvl%10 == 0 ? 1 : 0; // bonus bonus on every tenth
        }
        if ((charges * forLvl) > riftPower) {
            riftPower = 0;
        } else {
            riftPower -= (charges * forLvl);
        }
        iRiftData.addCharges(charges, bagId);
        emit AddCharge(_msgSender(), bagId, charges, forLvl);
    }

    function setupNewBag(uint256 bagId) external whenNotPaused {

        if (iRiftData.bags(bagId).level == 0) {
            iRiftData.updateLevel(1, bagId);    
            _chargeBag(bagId,levelChargeAward[1], 1);
        }        
    }

    function growTheRift(address burnableAddr, uint256 tokenId, uint256 bagId) _isBagHolder(bagId, _msgSender()) external whenNotPaused {

        require(riftObjects[burnableAddr], "Not of the Rift");
        require(IERC721(burnableAddr).ownerOf(tokenId) == _msgSender(), "Must be yours");
        
        ERC721BurnableUpgradeable(burnableAddr).burn(tokenId);
        _rewardBurn(burnableAddr, tokenId, bagId, IRiftBurnable(burnableAddr).burnObject(tokenId));
    }

    function growTheRiftStatic(address burnableAddr, uint256 tokenId, uint256 bagId) _isBagHolder(bagId, _msgSender()) external whenNotPaused {

        require(IERC721(burnableAddr).ownerOf(tokenId) == _msgSender(), "Must be yours");

        IERC721(burnableAddr).transferFrom(_msgSender(), 0x000000000000000000000000000000000000dEaD, tokenId);
        _rewardBurn(burnableAddr, tokenId, bagId, staticBurnObjects[burnableAddr]);
    }

    function growTheRiftRewards(address burnableAddr, uint256 tokenId) external view returns (BurnableObject memory) {

        return IRiftBurnable(burnableAddr).burnObject(tokenId);
    }

    function _rewardBurn(address burnableAddr, uint256 tokenId, uint256 bagId, BurnableObject memory bo) internal {


        riftPower += bo.power;
        iRiftData.addKarma(bo.power, _msgSender());
        riftObjectsSacrificed += 1;     

        _awardXP(uint32(bagId), bo.xp);
        iMana.ccMintTo(_msgSender(), bo.mana);
        emit ObjectSacrificed(_msgSender(), burnableAddr, tokenId, bagId, bo.power);
    }


    function recalibrateRift() external whenNotPaused {

        require(block.timestamp - riftCallibratedTime >= 1 hours, "wait");
        if (riftPower >= riftLevelMaxThreshold) {
            riftLevel += 1;
            uint256 riftLevelPower = riftLevelMaxThreshold - riftLevelMinThreshold;
            riftLevelMinThreshold = riftLevelMaxThreshold;
            riftLevelMaxThreshold += riftLevelPower + (riftLevelPower * riftLevelIncreasePercentage)/100;
        } else if (riftPower < riftLevelMinThreshold) {
            if (riftLevel == 1) {
                riftLevel = 0;
                riftLevelMinThreshold = 0;
                riftLevelMaxThreshold = 10000;
            } else {
                riftLevel -= 1;
                uint256 riftLevelPower = riftLevelMaxThreshold - riftLevelMinThreshold;
                riftLevelMaxThreshold = riftLevelMinThreshold;
                riftLevelMinThreshold -= riftLevelPower + (riftLevelPower * riftLevelDecreasePercentage)/100;
            }
        }

        iMana.ccMintTo(msg.sender, (block.timestamp - riftCallibratedTime) / (3600) * 10 * riftLevel);
        riftCallibratedTime = block.timestamp;
    }


     modifier _isBagHolder(uint256 bagId, address owner) {

        if (bagId < 8001) {
            require(iLoot.ownerOf(bagId) == owner, "UNAUTH");
        } else if (bagId > glootOffset) {
            require(iGLoot.ownerOf(bagId - glootOffset) == owner, "UNAUTH");
        } else {
            require(iMLoot.ownerOf(bagId) == owner, "UNAUTH");
        }
        _;
    }
}