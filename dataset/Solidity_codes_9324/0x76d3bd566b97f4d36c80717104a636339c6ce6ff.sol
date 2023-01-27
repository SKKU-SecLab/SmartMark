
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


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

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
}// Unlicense
pragma solidity ^0.8.0;

library Base64 {

    bytes internal constant TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

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
                out := add(out, and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(input, 0x3F))), 0xFF))
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

interface IIERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT
pragma solidity ^0.8.0;


contract ERC165P is IIERC165 {

    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) internal _supportedInterfaces;

    constructor () {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {

        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {

        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}// MIT
pragma solidity ^0.8.0;

pragma abicoder v2;

contract ProjectTokenStorage is ERC165P {

    using Counters for Counters.Counter;

    bytes4 public constant _ERC721_RECEIVED = 0x150b7a02;

    address public _owner;

    string public _name;

    string public _symbol;

    mapping (uint256 => string) public _tokenURIs;

    string public _baseURI;

    mapping (uint256 => address) public _tokenOwner;

    mapping (uint256 => address) public _tokenApprovals;

    mapping (address => Counters.Counter) public _ownedTokensCount;

    mapping (address => mapping (address => bool)) public _operatorApprovals;

    mapping(address => uint256[]) public _ownedTokens;

    mapping(uint256 => uint256) public _ownedTokensIndex;

    uint256[] public _allTokens;

    mapping(uint256 => uint256) public _allTokensIndex;

    bytes4 public constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    bytes4 public constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    bytes4 public constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    bool public pauseProxy;

    modifier onlyOwner() {

        require(_owner == msg.sender, "caller is not the owner");
        _;
    }

}// MIT
pragma solidity ^0.8.0;





contract ProjectToken is ProjectTokenStorage, IERC721, IERC721Metadata, IERC721Enumerable {

    using SafeMath for uint256;
    using Address for address;
    using Strings for uint256;
    using Counters for Counters.Counter;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;

        _registerInterface(_INTERFACE_ID_ERC721);
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    function owner() public view virtual returns (address) {

        return _owner;
    }

    function isOwner(address addr) public view virtual returns (bool) {


        if(_owner == addr) return true;
        else return false;
    }

    function balanceOf(address owner_) public view override returns (uint256) {

        require(owner_ != address(0), "ProjectToken: balance query for the zero address");

        return _ownedTokensCount[owner_].current();
    }
    function ownerOf(uint256 tokenId) public view override returns (address) {

        address owner_ = _tokenOwner[tokenId];
        require(owner_ != address(0), "ProjectToken: owner query for nonexistent token");

        return owner_;
    }
    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }


    function baseURI() public view virtual returns (string memory) {

        return _baseURI;
    }

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


    function svgToBase64(string memory _source) public pure returns (string memory) {

       return Base64.encode(bytes(string(abi.encodePacked(_source))));
    }

    function svgToImageURI(string memory _source) public pure returns (string memory) {

        string memory baseURL = "data:image/svg+xml;base64,";
        string memory svgBase64Encoded = Base64.encode(bytes(string(abi.encodePacked(_source))));
        return string(abi.encodePacked(baseURL, svgBase64Encoded));
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

        require(_exists(tokenId), "ProjectToken: URI query for nonexistent token");
        string memory json = Base64.encode(bytes(string(abi.encodePacked(_tokenURIs[tokenId]))));
        string memory output = string(abi.encodePacked('data:application/json;base64,', json));

        return output;
    }

    function tokenURIValue(uint256 tokenId) public view virtual returns (string memory) {

        require(_exists(tokenId), "ProjectToken: URI query for nonexistent token");

        return _tokenURIs[tokenId];
    }



    function tokenOfOwnerByIndex(address owner_, uint256 index) public view override returns (uint256) {

        require(index < balanceOf(owner_), "ProjectToken: owner index out of bounds");
        return _ownedTokens[owner_][index];
    }

    function totalSupply() public view override returns (uint256) {

        return _allTokens.length;
    }

    function tokenByIndex(uint256 index) public view override returns (uint256) {

        require(index < totalSupply(), "ProjectToken: global index out of bounds");
        return _allTokens[index];
    }

    function tokensOfOwner(address owner_) public view returns (uint256[] memory) {

        return _ownedTokens[owner_];
    }

    function approve(address to, uint256 tokenId) public virtual override {

        address owner_ = ownerOf(tokenId);
        require(to != owner_, "ProjectToken: approval to current owner");

        require(msg.sender == owner_ || isApprovedForAll(owner_, msg.sender),
            "ProjectToken: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {

        require(_exists(tokenId), "ProjectToken: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        require(operator != msg.sender, "ProjectToken: approve to caller");

        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address owner_, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[owner_][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public virtual override {

        require(_isApprovedOrOwner(msg.sender, tokenId), "ProjectToken: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {

        require(_isApprovedOrOwner(msg.sender, tokenId), "ProjectToken: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {

        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ProjectToken: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view returns (bool) {

        address owner_ = _tokenOwner[tokenId];
        return owner_ != address(0);
    }
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {

        require(_exists(tokenId), "ProjectToken: operator query for nonexistent token");
        address owner_ = ownerOf(tokenId);
        return (spender == owner_ || getApproved(tokenId) == spender || isApprovedForAll(owner_, spender));
    }


    function burn(address owner_, uint256 tokenId)  external {

        _burn(owner_, tokenId);
        _removeTokenFromOwnerEnumeration(owner_, tokenId);
        _ownedTokensIndex[tokenId] = 0;
        _removeTokenFromAllTokensEnumeration(tokenId);
    }


    function _burn(address owner_, uint256 tokenId) internal virtual{

        require(ownerOf(tokenId) == owner_, "ProjectToken: burn of token that is not own");
        _beforeTokenTransfer(owner_, address(0), tokenId);
        _clearApproval(tokenId);

        _ownedTokensCount[owner_].decrement();
        _tokenOwner[tokenId] = address(0);

        emit Transfer(owner_, address(0), tokenId);
    }

    function mint(string calldata tokenURI_) external {

        uint256 tokenId = totalSupply();
        _safeMint(msg.sender, tokenId);
        _tokenURIs[tokenId] = tokenURI_;
    }

    function mint(string calldata tokenURI_, bytes memory _data) external {

        uint256 tokenId = totalSupply();
        _safeMint(msg.sender, tokenId, _data);
        _tokenURIs[tokenId] = tokenURI_;
    }


    function _safeMint(address to, uint256 tokenId) internal virtual {

        _safeMint(to, tokenId, "");
    }

    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal virtual {

        _mint(to, tokenId);


        _addTokenToOwnerEnumeration(to, tokenId);

        _addTokenToAllTokensEnumeration(tokenId);

        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ProjectToken: transfer to non ERC721Receiver implementer");

    }


    function _mint(address to, uint256 tokenId) internal virtual {

        require(to != address(0), "ProjectToken: mint to the zero address");
        require(!_exists(tokenId), "ProjectToken: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _tokenOwner[tokenId] = to;
        _ownedTokensCount[to].increment();

        emit Transfer(address(0), to, tokenId);
    }


    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {

        _ownedTokensIndex[tokenId] = _ownedTokens[to].length;
        _ownedTokens[to].push(tokenId);
    }


    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {

        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {


        uint256 lastTokenIndex = _ownedTokens[from].length.sub(1);
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        _ownedTokens[from].pop();

    }

    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {


        uint256 lastTokenIndex = _allTokens.length.sub(1);
        uint256 tokenIndex = _allTokensIndex[tokenId];

        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        _allTokens.pop();
        _allTokensIndex[tokenId] = 0;
    }

    function _clearApproval(uint256 tokenId) private {

        if (_tokenApprovals[tokenId] != address(0)) {
            _tokenApprovals[tokenId] = address(0);
        }
    }

    function _transfer(address from, address to, uint256 tokenId) internal {

        require(ownerOf(tokenId) == from, "ProjectToken: transfer of token that is not own");
        require(to != address(0), "ProjectToken: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _clearApproval(tokenId);

        _ownedTokensCount[from].decrement();
        _ownedTokensCount[to].increment();

        _tokenOwner[tokenId] = to;

        _removeTokenFromOwnerEnumeration(from, tokenId);

        _addTokenToOwnerEnumeration(to, tokenId);

        emit Transfer(from, to, tokenId);
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {

        require(_exists(tokenId), "ProjectToken: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function setTokenURI(uint256 tokenId, string memory _tokenURI) public onlyOwner virtual {

       setTokenURI(tokenId, _tokenURI);
    }

    function _setBaseURI(string memory baseURI_) internal virtual {

        _baseURI = baseURI_;
    }

    function setBaseURI(string memory baseURI_) public onlyOwner virtual {

       _setBaseURI(baseURI_);
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        private returns (bool)
    {

        if (!to.isContract()) {
            return true;
        }
        bytes memory returndata = to.functionCall(abi.encodeWithSelector(
            IERC721Receiver(to).onERC721Received.selector,
            msg.sender,
            from,
            tokenId,
            _data
        ), "ProjectToken: transfer to non ERC721Receiver implementer");
        bytes4 retval = abi.decode(returndata, (bytes4));
        return (retval == _ERC721_RECEIVED);
    }

    function _approve(address to, uint256 tokenId) private {

        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId); // internal owner
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual {


     }


    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC165P) returns (bool) {

        return _supportedInterfaces[interfaceId];
    }



}