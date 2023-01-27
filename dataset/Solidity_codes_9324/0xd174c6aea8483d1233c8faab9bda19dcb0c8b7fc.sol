
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


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

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


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
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


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
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


interface IERC721Enumerable is IERC721 {
    function totalSupply() external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    function tokenByIndex(uint256 index) external view returns (uint256);
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    mapping(uint256 => uint256) private _ownedTokensIndex;

    uint256[] private _allTokens;

    mapping(uint256 => uint256) private _allTokensIndex;

    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
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
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
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
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC721URIStorage is ERC721 {
    using Strings for uint256;

    mapping(uint256 => string) private _tokenURIs;

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC721Burnable is Context, ERC721 {
    function burn(uint256 tokenId) public virtual {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        _burn(tokenId);
    }
}// MIT

pragma solidity ^0.8.13;


contract BiTSNFTMint is ERC721, ERC721Enumerable, ERC721URIStorage, Pausable, Ownable, ERC721Burnable {


    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {
    }

    function contractURI() public pure returns (string memory) {
        return "https://bitsnft.xyz/contract-metadata.json";
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function safeMint(address to, uint256 tokenId, string memory uri) public onlyOwner {
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function burn(uint256 tokenId) public onlyOwner override(ERC721Burnable) {
        super.burn(tokenId);
    }


    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

}// MIT

pragma solidity ^0.8.0;

library Base64 {
    string internal constant _TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    function encode(bytes memory data) internal pure returns (string memory) {
        if (data.length == 0) return "";

        string memory table = _TABLE;

        string memory result = new string(4 * ((data.length + 2) / 3));

        assembly {
            let tablePtr := add(table, 1)

            let resultPtr := add(result, 32)

            for {
                let dataPtr := data
                let endPtr := add(data, mload(data))
            } lt(dataPtr, endPtr) {

            } {
                dataPtr := add(dataPtr, 3)
                let input := mload(dataPtr)


                mstore8(resultPtr, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance

                mstore8(resultPtr, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance

                mstore8(resultPtr, mload(add(tablePtr, and(shr(6, input), 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance

                mstore8(resultPtr, mload(add(tablePtr, and(input, 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance
            }

            switch mod(mload(data), 3)
            case 1 {
                mstore8(sub(resultPtr, 1), 0x3d)
                mstore8(sub(resultPtr, 2), 0x3d)
            }
            case 2 {
                mstore8(sub(resultPtr, 1), 0x3d)
            }
        }

        return result;
    }
}// MIT
pragma solidity ^0.8.13;

enum DepositUnits {
    MILLI, //0.001
    CENTI, //0.01
    DECI, //0.1
    ONE, //1
    DECA //10
}


struct ContractMeta {
    string mintName;
    string mintDescription;
    string depositSymbol;
    string mintSymbol;
}
struct TokenMeta {
    string userText;
    uint tokenId;
    uint depositAmount;
}
struct SVGMeta {
    string backgroundHue;
    string strokeHue;
    string depositUnitInString;
    string depositUnitName;
    uint256 depositAmount;
    uint8 stringLimit;
    bytes svgLogo;
 
}
struct Seed {
        uint48 scale;
        uint48 rotate;
        uint48 strokeWidth;
        uint48 strokePatternHue;
        uint48 strokeSaturation;
        uint48 strokeLightness;
    }


bytes constant SVG_PREFIX = '<svg viewBox="0 0 250 250" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><defs><filter id="convolve"><feConvolveMatrix kernelMatrix="1 0 0 0 1 0 0 0 -1"/></filter>';

bytes constant CIRCLE_PREFIX = '<g><circle style="stroke-width: 3px; paint-order: stroke; stroke-miterlimit: 1; stroke-dasharray: 2; stroke-linecap: round; stroke-linejoin: round; stroke: ';

bytes constant CIRCLE_SUFFIX = ';" cx="125" cy="125" r="120"/><path d="M 235 125 C 235 64.249 185.751 15 125 15 C 64.249 15 15 64.249 15 125 C 15 185.751 64.249 235 125 235 C 185.751 235 235 185.751 235 125 Z" style="fill: none;" id="reversePath" /><path d="M 235 125 C 235 185.751 185.751 235 125 235 C 64.249 235 15 185.751 15 125 C 15 64.249 64.249 15 125 15 C 185.751 15 235 64.249 235 125 Z" style="fill: none;" id="frontPath"/><path d="M 235 125 C 235 185.751 185.751 235 125 235 C 64.249 235 15 185.751 15 125 C 15 64.249 64.249 15 125 15 C 185.751 15 235 64.249 235 125 Z" style="fill: url(#a);"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 125 125" to="360 125 125" dur="200s" repeatCount="indefinite"></animateTransform></path></g>';

bytes constant META_TEXT_PREFIX = '<text dy="8"><textPath startOffset="518" xlink:href="#reversePath">';

bytes constant USER_TEXT_PREFIX = '<text><textPath startOffset="518" xlink:href="#frontPath">';

bytes constant UNIT_TEXT_PREFIX = '<text style="fill: #eeb32b; font-family: Arial, sans-serif; font-size: 44px; font-weight: 700; text-anchor: middle; filter: url(#convolve);" x="125" y="125">';

bytes constant DeciSVGLogo = '<g transform="matrix(0.05, 0, 0, 0.05, 93 80)" style="fill:#eeb32b;  filter: url(#convolve);"><path  d="M0,449h1235l-999,726 382-1175 382,1175z"></path> </g>';

bytes constant DecaSVGLogo = '<g transform="matrix(0.15, 0, 0, 0.15, 75, 60)" style="filter: url(#convolve);"><path id="path1937" d="m 194.523,678.458 c 0,0 6.614,15.487 26.823,25.989 -36.209,-3.752 -36.209,-3.752 -108.809,-57.715 0,0 -3.961,43.834 -65.931,114.523 C 79.136,654.694 75.553,639.777 50.82,587.956 42.047,570.594 30.667,607.882 32.305,624.901 -29.53,420.944 186.221,344.222 186.221,344.222 l -44.287,-31.509 c 20.25595,6.62233 89.96962,3.75634 153.50245,-7.20475 13.73637,-2.36989 27.18381,-5.11819 39.77998,-8.23083 80.72363,-19.9476 126.48566,-54.85847 -10.72143,-101.02642 0,0 21.142,21.526 18.437,35.256 -4.628,-11.563 -19.559,-15.572 -19.559,-15.572 0,0 10.431,34.842 2.871,51.798 -2.607,-20.123 -35.243,-51.926 -35.243,-51.926 0,0 10.803,53.804 -84.81,50.951 -49.721,-2.147 -71.897,6.645 -88.816,23.42 -13.35,13.235 -16.599,15.452 -22.648,15.452 -6.99,0 -14.588,-4.41 -23.823,-13.827 -3.623,-3.694 -4.508,-6.947 -4.458,-16.388 0.054,-10.16 1.11,-13.324 7.682,-23.017 7.146,-10.539 8.701,-11.632 25.032,-17.595 9.577,-3.498 22.517,-8.674 28.755,-11.504 10.032,-4.55 11.571,-6.067 13.315,-13.132 2.102,-8.513 3.367,-9.416 28.241,-20.158 9.034,-3.902 16.433,-9.726 30.484,-23.992 16.791,-17.049 16.305,-21.761 16.742,-23.997 2.126,-28.576 -56.083,-0.082 -56.083,-0.082 0,0 12.359,-17.964 23.429,-25.727 30.092,-21.101 69.778,-1.523 69.778,-1.523 0,0 68.314,-77.578 165.77,-110.162 -4.705,3.168 -69.582,68.005 -68.519,75.294 13.397,0.29 20.538,7.561 20.538,7.561 -28.037,-1.063 -44.774,25.584 -44.774,25.584 12.987,-7.459 87.718,-18.98 87.718,-18.98 0,0 -10.271,6.69 -9.931,9.762 75.18,-21.638 232.268,-17.322 232.268,-17.322 -55.755,7.685 -163.767,48.154 -163.767,48.154 0,0 79.679,-5.803 125.542,10.257 -44.863,-2.393 -75.326,7.56 -90.639,15.867 58.441,31.073 98.813,129.557 98.813,129.557 0,0 -88.53,-96.203 -122.055,-86.197 0,0 122.684,184.38 14.609,257.953 5.074,-24.572 17.675,-115.897 -19.125,-135.901 -1.7e-4,1.1e-4 -101.13878,78.26401 -161.94176,103.99883 -7.89116,3.33993 -14.60839,6.58636 -20.85065,7.8402 -15.77675,3.16897 -30.17082,7.44327 -43.65559,7.12597 21.981,-7.636 29.573,-21.449 29.573,-21.449 -86.925,-18.187 -113.925,82.813 -96.56,121.846 -25.033,-9.032 -61.144,-53.433 -61.144,-53.433 0,0 5.718,99.022 126.081,85.045 -18.226,10.896 -44.637,22.022 -73.802,20.233 6.416,18.872 131.705,-2.4 139.458,-17.396 3.752,-7.254 21.614,-42.998 -22.813,-57.439 26.645,-14.168 68.57,39.254 68.57,39.254 0,0 7.797,-5.299 44.998,-11.798 37.201,-6.499 -26.332,-18.948 -26.332,-18.948 55.408,-0.583 81.521,9.249 81.521,9.249 9.138,-23.55 -103.337,-82.377 -103.337,-82.377 0,0 496.679,151.096 222.056,350.67 26.711,-67.76 26.813,-84.333 14.947,-119.558 -4.281,-12.708 -9.398,-22.516 -13.124,-25.152 -1.022,-0.723 3.722,8.785 -14.721,22.387 -24.225,-82.769 -127.818,-82.081 -138.267,-76.945 -57.126,22.426 0.696,58.563 26.624,44.009 -15.011,21.304 -58.09,21.02 -58.09,21.02 0,0 54.674,46.147 102.717,25.392 -31.543,77.256 -170.705,-49.23 -170.938,-49.651 -0.233,-0.421 -48.208,16.001 -48.208,16.001 0,0 62.426,51.938 92.265,155.797 C 307.138,721.445 194.523,678.458 194.523,678.458 z m 36.6,-486.846 c 20.22,-21.393 18.625,-24.149 -6.431,-11.109 -14.519,7.557 -39.887,21.442 -37.445,28.562 16.727,0.651 26.759,0.657 26.759,0.657 z" style="fill: #eeb32b;fill-opacity:1;"/></g>';

bytes constant OneSVGLogo = '<g stroke-linejoin="round" transform="matrix(0.15, 0, 0, 0.15, 80, 80)" stroke="#ff4628" stroke-linecap="round" stroke-width="15" style="fill: #eeb32b; filter: url(#convolve);"><path d="m486.47 249.44c17.36-18.58-2.61-52.28-1.19-100.23 1.43-47.87 33.75-64.18 33.75-64.18s-10.33 4.037-6.98 27.38c2.84 19.8 9.13 42.82 23.5 55.58 14.79 12.23 39.12 45.62 30.15 63.45 18.09-6.14 46.27 8.4 67.08 27.68 21.72 20.55 35.63 30.45 50.69 35.26 21.63 6.92 37.47 0.82 37.47 0.82-24.75 21.36-72.19 21.67-103.15 15.92-30.29-5.63-47.2-22.11-74.75-15.8-34.98 11.95-92.86 66.09-181.53 77.64s-298.26-20.39-323.39-46.83c-25.136-26.43-2.101-35.33-3.753-34.14-0.224-0.23 6.034 5.98 133.22 37.5-22.82-3.67-138.2-40.99-137.99-42.53 0.324 0.11 51.896-190.66 94.97-211.04 43.07-20.368 140.96 38.97 216.25 82.99 89.27 52.21 125.84 111.73 145.65 90.53z"></path><path transform="matrix(.85895 0 0 .80874 30.239 43.723)" d="m220 314.51a13.571 12.143 0 1 1 -27.14 0 13.571 12.143 0 1 1 27.14 0z"></path></g>';// MIT
pragma solidity ^0.8.13;


contract BiTSNFTURI is Ownable {
    ContractMeta private _contractMeta;
   
    constructor (string memory name_, string memory description_, string memory depositSymbol_, string memory mintSymbol_) {
        _contractMeta = ContractMeta(name_,description_,depositSymbol_,mintSymbol_);
    }


    function buildImage(TokenMeta memory _tokenMeta, SVGMeta memory _svgMeta, DepositUnits _depositUnit) private view returns (string memory)  {
        Seed memory _seed = generateSeed(_tokenMeta.tokenId, uint(_depositUnit) );
        bytes memory _imgPrefix = generateImagePrefix(_seed);
        bytes memory _circlePrefix = abi.encodePacked(
            CIRCLE_PREFIX,
            _svgMeta.strokeHue,
            '; fill: ',
            _svgMeta.backgroundHue,
            CIRCLE_SUFFIX
        );
        bytes memory _textPrefix = abi.encodePacked('<g style="fill: #eeb32b; font-family: Arial, sans-serif; font-size: 10px; font-weight: 700; text-anchor: middle; filter: url(#convolve);">',
                        META_TEXT_PREFIX,
                        _svgMeta.depositUnitInString);
        bytes memory _textSuffix = abi.encodePacked(' ',
                        _contractMeta.depositSymbol,
                        ' ',
                        Strings.toString(block.timestamp),
                        ' ',
                        Strings.toString(_tokenMeta.tokenId),
                        '</textPath></text>',
                        USER_TEXT_PREFIX,
                        _tokenMeta.userText,
                        '</textPath></text></g>',
                        UNIT_TEXT_PREFIX,
                        _svgMeta.depositUnitName,
                        '</text>',
                        _svgMeta.svgLogo,
                        '</svg>');
        return
            Base64.encode(
                bytes.concat(SVG_PREFIX, _imgPrefix, _circlePrefix, _textPrefix, _textSuffix)
            );
    }

    function createTokenURI(TokenMeta memory _tokenMeta, SVGMeta memory _svgMeta, DepositUnits _depositUnit) public view onlyOwner returns(string memory) {
        bytes memory _metaPre = abi.encodePacked( '{"name":"',
                                _contractMeta.mintName,
                                '", "description":"',
                                _contractMeta.mintDescription,
                                '", "image": "',
                                "data:image/svg+xml;base64,",
                                buildImage(_tokenMeta, _svgMeta, _depositUnit));
        bytes memory _metaAttr = abi.encodePacked('", "attributes": ',
                                "[",
                                '{"trait_type": "Mint Block",',
                                '"value":"',
                                Strings.toString(block.timestamp),
                                '"},',
                                '{"trait_type": "Mint Deposit",',
                                '"value":"',
                                Strings.toString(_tokenMeta.depositAmount),
                                '"},',
                                '{"trait_type": "Message",',
                                '"value":"',
                                _tokenMeta.userText,
                                '"}',
                                "]",
                                "}");
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes.concat(_metaPre, _metaAttr)
                    )
                )
            );
    }


    

    function generateImagePrefix(Seed memory _seed) internal pure returns(bytes memory) {
        uint48 strokePatternHue2 = (_seed.strokePatternHue + 120) < 360 ? _seed.strokePatternHue + 120 : (_seed.strokePatternHue + 120) - 360;
        uint48 strokePatternHue3 = (strokePatternHue2 + 120) < 360 ? strokePatternHue2 + 120 : (strokePatternHue2 + 120) - 360;
        bytes memory _imagePrefix = abi.encodePacked(
            "<pattern id='a' patternUnits='userSpaceOnUse' width='40' height='60' patternTransform='scale(",
            Strings.toString(_seed.scale),
            ") rotate(",
            Strings.toString(_seed.rotate),
            ")'><g fill='none' stroke-width='",
            Strings.toString(_seed.strokeWidth),
            "'><path d='M-4.798 13.573C-3.149 12.533-1.446 11.306 0 10c2.812-2.758 6.18-4.974 10-5 4.183.336 7.193 2.456 10 5 2.86 2.687 6.216 4.952 10 5 4.185-.315 7.35-2.48 10-5 1.452-1.386 3.107-3.085 4.793-4.176'   stroke='hsla(",
            Strings.toString(_seed.strokePatternHue),
            ",50%,50%,1)'/><path d='M-4.798 33.573C-3.149 32.533-1.446 31.306 0 30c2.812-2.758 6.18-4.974 10-5 4.183.336 7.193 2.456 10 5 2.86 2.687 6.216 4.952 10 5 4.185-.315 7.35-2.48 10-5 1.452-1.386 3.107-3.085 4.793-4.176'  stroke='hsla(",
            Strings.toString(strokePatternHue2),
            ",35%,45%,1)' /><path d='M-4.798 53.573C-3.149 52.533-1.446 51.306 0 50c2.812-2.758 6.18-4.974 10-5 4.183.336 7.193 2.456 10 5 2.86 2.687 6.216 4.952 10 5 4.185-.315 7.35-2.48 10-5 1.452-1.386 3.107-3.085 4.793-4.176' stroke='hsla(",
            Strings.toString(strokePatternHue3),
            ",65%,55%,1)'/></g></pattern></defs>"
        );
        return _imagePrefix;
    }


    function generateSeed(uint256 tokenId, uint256 depositUnit) internal view returns (Seed memory) {
        uint256 pseudorandomness = uint256(
            keccak256(abi.encodePacked(blockhash(block.number - 1), tokenId, depositUnit))
        );

        uint48 scaleMax = 9;
        uint48 rotateMax = 360;
        uint48 strokeWidthMax = 9;
        uint48 hueMax = 360;
        uint48 saturationMax = 100;
        

        return Seed({
            scale: uint48(
                uint48(pseudorandomness >> 48) % scaleMax + 2
            ),
            rotate: uint48(
                uint48(pseudorandomness >> 96) % rotateMax
            ),
            strokeWidth: uint48(
                uint48(pseudorandomness >> 144) % strokeWidthMax + 2
            ),
            strokePatternHue: uint48(
                uint48(pseudorandomness >> 192) % hueMax
            ),         
            strokeSaturation: uint48(
                uint48(pseudorandomness >> 184) % saturationMax
            ),           
            strokeLightness: uint48(
                uint48(pseudorandomness >> 176) % saturationMax
            )
        });
    }

}// MIT
pragma solidity ^0.8.13;


contract BiTSNFTBank is Ownable, Pausable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    IERC20Metadata public immutable depositToken;
    uint private immutable _depositTokenDecimals;
    BiTSNFTMint public immutable saMint;
    BiTSNFTURI public immutable saURI;
    uint public mintpremiumPct;
    mapping(uint256 => bytes32) public userTextHashToTokenId;
    mapping(uint256 => uint256) public depositAmountToTokenId;
    string public webUrl = "https://bitsnft.xyz";
    event MintTokenId(address indexed sender, uint256 tokenId);
    event BurnTokenId(address indexed sender, uint256 tokenId);

    constructor(address _depositToken, uint8 _premiumPercent, string memory _mintName, string memory _mintSymbol) {
        depositToken = IERC20Metadata(_depositToken);
        saMint = new BiTSNFTMint(_mintName, _mintSymbol);
        saURI = new BiTSNFTURI(_mintName, string.concat(_mintName,". Redeemable for ", depositToken.symbol()), depositToken.symbol(), _mintSymbol);
        _depositTokenDecimals = (10 ** depositToken.decimals());
        _premiumPercent <= 10? mintpremiumPct = _premiumPercent : mintpremiumPct = 10;
    }

    function pause() public onlyOwner {
        _pause();
        saMint.pause();
    }

    function unpause() public onlyOwner {
        _unpause();
        saMint.unpause();
    }

    function transferMintOwnership(address newOwner) public onlyOwner {
        saMint.transferOwnership(newOwner);
        saURI.transferOwnership(newOwner);
    }

    function setMintPremiumPct(uint8 _premiumPercent) public onlyOwner {
        _premiumPercent <= 10? mintpremiumPct = _premiumPercent : mintpremiumPct = 10;
    }

    function setWebUrl(string memory _webUrl) public onlyOwner {
        webUrl = _webUrl;
    }

    function mintDeposit(string memory _userText, DepositUnits _depositUnit) public whenNotPaused {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();

        require(uint8(_depositUnit) <= 4,"Choose btw 0 and 4"); 

        require(bytes(_userText).length > 0, string.concat("Message string empty!"));     
  
        SVGMeta memory _svgMeta = setMetaByUnit(_depositUnit);

        require(bytes(_userText).length <= _svgMeta.stringLimit, string.concat("Max ",Strings.toString(_svgMeta.stringLimit)," chars!"));
        string memory _userTextUpper = toUpper(_userText);
        require(userTextExists(_userTextUpper) != true, "Text taken!");
        userTextHashToTokenId[tokenId] = keccak256(abi.encodePacked(_userTextUpper));        

        
        uint256 _mintPremium = (_svgMeta.depositAmount * mintpremiumPct)/100;
        uint256 _transferAmount = _svgMeta.depositAmount + _mintPremium;
        require(depositToken.allowance(msg.sender, address(this)) >= _transferAmount, "Check allowance");
        require(_transferAmount > 0,"Zero");

        depositAmountToTokenId[tokenId] = _svgMeta.depositAmount;

        depositToken.transferFrom(msg.sender, address(this), _transferAmount);
        depositToken.transfer(owner(), _mintPremium);

        TokenMeta memory _tokenMeta = TokenMeta(_userTextUpper, tokenId, _svgMeta.depositAmount);
        

        saMint.safeMint(msg.sender, tokenId, saURI.createTokenURI(_tokenMeta, _svgMeta, _depositUnit));      
        emit MintTokenId(msg.sender, tokenId);
    }

    
    function redeemDeposit(uint256 _tokenId) public whenNotPaused {

        require(msg.sender == saMint.ownerOf(_tokenId),"Not owner!");
        saMint.burn(_tokenId);
  
        require(depositAmountToTokenId[_tokenId] <= depositToken.balanceOf(address(this)), "Depleted!");
        depositToken.transfer(msg.sender, depositAmountToTokenId[_tokenId]);
        delete userTextHashToTokenId[_tokenId];
        delete depositAmountToTokenId[_tokenId];
        emit BurnTokenId(msg.sender, _tokenId);
   
    }

    function setMetaByUnit(DepositUnits _depositUnit) private view returns(SVGMeta memory) {
    SVGMeta memory _svgMeta;
     if (DepositUnits.MILLI == _depositUnit) {
         _svgMeta.depositAmount =  _depositTokenDecimals/1000;
         _svgMeta.stringLimit = 4;
         _svgMeta.backgroundHue = "#8B8B8B";
         _svgMeta.strokeHue = "#4B4B4B";
         _svgMeta.depositUnitInString = "0.001";
         _svgMeta.depositUnitName = "MILLI";
         _svgMeta.svgLogo = "";
     }
     if (DepositUnits.CENTI == _depositUnit) {
         _svgMeta.depositAmount = _depositTokenDecimals/100;
         _svgMeta.stringLimit = 8;
         _svgMeta.backgroundHue = "#278AFF";
         _svgMeta.strokeHue = "#274A84";
         _svgMeta.depositUnitInString = "0.01";
         _svgMeta.depositUnitName = "CENTI";
         _svgMeta.svgLogo = "";
     }
     if (DepositUnits.DECI == _depositUnit) {
         _svgMeta.depositAmount = _depositTokenDecimals/10;
         _svgMeta.stringLimit = 16;
         _svgMeta.backgroundHue = "#DF6908";
         _svgMeta.strokeHue = "#763B11";
         _svgMeta.depositUnitInString = "0.1";
         _svgMeta.depositUnitName = "";
         _svgMeta.svgLogo = DeciSVGLogo;
     }
     if (DepositUnits.ONE == _depositUnit) {
         _svgMeta.depositAmount = _depositTokenDecimals;
         _svgMeta.stringLimit = 32;
         _svgMeta.backgroundHue = "#FF4628";
         _svgMeta.strokeHue = "#931B0C";
         _svgMeta.depositUnitInString = "1";
         _svgMeta.depositUnitName = "";
         _svgMeta.svgLogo = OneSVGLogo;
     }
     if (DepositUnits.DECA == _depositUnit) {
         _svgMeta.depositAmount = _depositTokenDecimals*10;
         _svgMeta.stringLimit = 64;
         _svgMeta.backgroundHue = "#000000";
         _svgMeta.strokeHue = "#eeb32b";
         _svgMeta.depositUnitInString = "10";
         _svgMeta.depositUnitName = "";
         _svgMeta.svgLogo = DecaSVGLogo;
     }

     return _svgMeta;

    }

    function userTextExists(string memory _userTextUpper) public view returns (bool) {
        bool result = false;
        uint _totalSupply = _tokenIdCounter.current();

        for (uint256 i=0; i < _totalSupply; ++i) {
            if (
                userTextHashToTokenId[i] == keccak256(abi.encodePacked(_userTextUpper))
            ) {
                result = true;
            }
        }
        return result;
    }

    function toUpper(string memory _base)
        internal
        pure
        returns (string memory) {
        bytes memory _baseBytes = bytes(_base);
        uint length = _baseBytes.length;
        for (uint i=0; i < length; ++i) {
            if (_baseBytes[i] >= 0x61 && _baseBytes[i] <= 0x7A) {
                _baseBytes[i] = bytes1(uint8(_baseBytes[i]) - 32);
            }
        }
        return string(_baseBytes);
    }


}