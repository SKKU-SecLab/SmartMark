
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

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


interface IERC721LibBeforeTokenTransferHook {


    function _beforeTokenTransferHook(bytes32 storagePosition, address from, address to, uint256 tokenId) external;


}// MIT

pragma solidity ^0.8.0;



contract OwnableDelegateProxy {}


contract ProxyRegistry {

    mapping(address => OwnableDelegateProxy) public proxies;
}

library ERC721Lib {

    using Address for address;
    using Strings for uint256;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    event Paused(address account);

    event Unpaused(address account);

    struct ERC721Storage {
        string _name;

        string _symbol;

        mapping (uint256 => address) _owners;

        mapping (address => uint256) _balances;

        mapping (uint256 => address) _tokenApprovals;

        mapping (address => mapping (address => bool)) _operatorApprovals;

        mapping(address => mapping(uint256 => uint256)) _ownedTokens;

        mapping(uint256 => uint256) _ownedTokensIndex;

        uint256[] _allTokens;

        mapping(uint256 => uint256) _allTokensIndex;
        
        string _baseURI;

        bool _paused;

        IERC721LibBeforeTokenTransferHook _beforeTokenTransferHookInterface;
        bytes32 _beforeTokenTransferHookStorageSlot;

        address proxyRegistryAddress;

    }

    function init(ERC721Storage storage s, string memory _name, string memory _symbol) external {

        s._name = _name;
        s._symbol = _symbol;
    }
    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {

        return interfaceId == type(IERC721).interfaceId
            || interfaceId == type(IERC721Metadata).interfaceId
            || interfaceId == type(IERC721Enumerable).interfaceId;
    }


    function _balanceOf(ERC721Storage storage s, address owner) internal view returns (uint256) {

        require(owner != address(0), "Balance query for address zero");
        return s._balances[owner];
    }

    function balanceOf(ERC721Storage storage s, address owner) external view returns (uint256) {

        return _balanceOf(s, owner);
    }

    function _ownerOf(ERC721Storage storage s, uint256 tokenId) internal view returns (address) {

        address owner = s._owners[tokenId];
        require(owner != address(0), "Owner query for nonexist. token");
        return owner;
    }

    function ownerOf(ERC721Storage storage s, uint256 tokenId) external view returns (address) {

        return _ownerOf(s, tokenId);
    }

    function name(ERC721Storage storage s) external view returns (string memory) {

        return s._name;
    }

    function symbol(ERC721Storage storage s) external view returns (string memory) {

        return s._symbol;
    }

    function tokenURI(ERC721Storage storage s, uint256 tokenId) external view returns (string memory) {

        require(_exists(s, tokenId), "URI query for nonexistent token");

        return bytes(s._baseURI).length > 0
            ? string(abi.encodePacked(s._baseURI, tokenId.toString()))
            : "";
    }

    function setBaseURI(ERC721Storage storage s, string memory baseTokenURI) external {

        s._baseURI = baseTokenURI;
    }

    function approve(ERC721Storage storage s, address to, uint256 tokenId) external {

        address owner = _ownerOf(s, tokenId);
        require(to != owner, "Approval to current owner");

        require(msg.sender == owner || _isApprovedForAll(s, owner, msg.sender),
            "Not owner nor approved for all"
        );

        _approve(s, to, tokenId);
    }

    function overrideApprove(ERC721Storage storage s, address to, uint256 tokenId) external {

        _approve(s, to, tokenId);
    }

    function _getApproved(ERC721Storage storage s, uint256 tokenId) internal view returns (address) {

        require(_exists(s, tokenId), "Approved query nonexist. token");

        return s._tokenApprovals[tokenId];
    }

    function getApproved(ERC721Storage storage s, uint256 tokenId) external view returns (address) {

        return _getApproved(s, tokenId);
    }

    function setApprovalForAll(ERC721Storage storage s, address operator, bool approved) external {

        require(operator != msg.sender, "Attempted approve to caller");

        s._operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function _isApprovedForAll(ERC721Storage storage s, address owner, address operator) internal view returns (bool) {

        if (s.proxyRegistryAddress != address(0)) {
            ProxyRegistry proxyRegistry = ProxyRegistry(s.proxyRegistryAddress);
            if (address(proxyRegistry.proxies(owner)) == operator) {
                return true;
            }
        }

        return s._operatorApprovals[owner][operator];
    }

    function isApprovedForAll(ERC721Storage storage s, address owner, address operator) external view returns (bool) {

        return _isApprovedForAll(s, owner, operator);
    }

    function transferFrom(ERC721Storage storage s, address from, address to, uint256 tokenId) external {

        require(_isApprovedOrOwner(s, msg.sender, tokenId), "TransferFrom not owner/approved");

        _transfer(s, from, to, tokenId);
    }

    function safeTransferFrom(ERC721Storage storage s, address from, address to, uint256 tokenId) external {

        _safeTransferFrom(s, from, to, tokenId, "");
    }

    function _safeTransferFrom(ERC721Storage storage s, address from, address to, uint256 tokenId, bytes memory _data) internal {

        require(_isApprovedOrOwner(s, msg.sender, tokenId), "TransferFrom not owner/approved");
        _safeTransfer(s, from, to, tokenId, _data);
    }

    function safeTransferFrom(ERC721Storage storage s, address from, address to, uint256 tokenId, bytes memory _data) external {

        _safeTransferFrom(s, from, to, tokenId, _data);
    }

    function _safeTransfer(ERC721Storage storage s, address from, address to, uint256 tokenId, bytes memory _data) internal {

        _transfer(s, from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "Transfer to non ERC721Receiver");
    }

    function directSafeTransfer(ERC721Storage storage s, address from, address to, uint256 tokenId, bytes memory _data) external {

        _safeTransfer(s, from, to, tokenId, _data);
    }

    function _exists(ERC721Storage storage s, uint256 tokenId) internal view returns (bool) {

        return s._owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(ERC721Storage storage s, address spender, uint256 tokenId) internal view returns (bool) {

        require(_exists(s, tokenId), "Operator query nonexist. token");
        address owner = _ownerOf(s, tokenId);
        return (spender == owner || _getApproved(s, tokenId) == spender || _isApprovedForAll(s, owner, spender));
    }

    function _safeMint(ERC721Storage storage s, address to, uint256 tokenId) internal {

        _safeMint(s, to, tokenId, "");
    }

    function _safeMint(ERC721Storage storage s, address to, uint256 tokenId, bytes memory _data) internal {

        _unsafeMint(s, to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "Transfer to non ERC721Receiver");
    }

    function _unsafeMint(ERC721Storage storage s, address to, uint256 tokenId) internal {

        require(to != address(0), "Mint to the zero address");
        require(!_exists(s, tokenId), "Token already minted");

        _beforeTokenTransfer(s, address(0), to, tokenId);

        s._balances[to] += 1;
        s._owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(ERC721Storage storage s, uint256 tokenId) internal {

        address owner = _ownerOf(s, tokenId);

        _beforeTokenTransfer(s, owner, address(0), tokenId);

        _approve(s, address(0), tokenId);

        s._balances[owner] -= 1;
        delete s._owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(ERC721Storage storage s, address from, address to, uint256 tokenId) internal {

        require(_ownerOf(s, tokenId) == from, "TransferFrom not owner/approved");
        require(to != address(0), "Transfer to the zero address");

        _beforeTokenTransfer(s, from, to, tokenId);

        _approve(s, address(0), tokenId);

        s._balances[from] -= 1;
        s._balances[to] += 1;
        s._owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _approve(ERC721Storage storage s, address to, uint256 tokenId) internal {

        s._tokenApprovals[tokenId] = to;
        emit Approval(_ownerOf(s, tokenId), to, tokenId);
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        private returns (bool)
    {

        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver(to).onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("Transfer to non ERC721Receiver");
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


    function tokenOfOwnerByIndex(ERC721Storage storage s, address owner, uint256 index) external view returns (uint256) {

        require(index < _balanceOf(s, owner), "Owner index out of bounds");
        return s._ownedTokens[owner][index];
    }

    function _totalSupply(ERC721Storage storage s) internal view returns (uint256) {

        return s._allTokens.length;
    }

    function totalSupply(ERC721Storage storage s) external view returns (uint256) {

        return s._allTokens.length;
    }

    function tokenByIndex(ERC721Storage storage s, uint256 index) external view returns (uint256) {

        require(index < _totalSupply(s), "Global index out of bounds");
        return s._allTokens[index];
    }

    function _beforeTokenTransfer(ERC721Storage storage s, address from, address to, uint256 tokenId) internal {

        if(address(s._beforeTokenTransferHookInterface) != address(0)) {
            (bool success, ) = address(s._beforeTokenTransferHookInterface).delegatecall(
                abi.encodeWithSelector(s._beforeTokenTransferHookInterface._beforeTokenTransferHook.selector, s._beforeTokenTransferHookStorageSlot, from, to, tokenId)
            );
            if(!success) {
                assembly {
                    let ptr := mload(0x40)
                    let size := returndatasize()
                    returndatacopy(ptr, 0, size)
                    revert(ptr, size)
                }
            }
        }

        require(!_paused(s), "No token transfer while paused");

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(s, tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(s, from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(s, tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(s, to, tokenId);
        }
    }

    function _addTokenToOwnerEnumeration(ERC721Storage storage s, address to, uint256 tokenId) private {

        uint256 length = _balanceOf(s, to);
        s._ownedTokens[to][length] = tokenId;
        s._ownedTokensIndex[tokenId] = length;
    }

    function _addTokenToAllTokensEnumeration(ERC721Storage storage s, uint256 tokenId) private {

        s._allTokensIndex[tokenId] = s._allTokens.length;
        s._allTokens.push(tokenId);
    }

    function _removeTokenFromOwnerEnumeration(ERC721Storage storage s, address from, uint256 tokenId) private {


        uint256 lastTokenIndex = _balanceOf(s, from) - 1;
        uint256 tokenIndex = s._ownedTokensIndex[tokenId];

        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = s._ownedTokens[from][lastTokenIndex];

            s._ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            s._ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        delete s._ownedTokensIndex[tokenId];
        delete s._ownedTokens[from][lastTokenIndex];
    }

    function _removeTokenFromAllTokensEnumeration(ERC721Storage storage s, uint256 tokenId) private {


        uint256 lastTokenIndex = s._allTokens.length - 1;
        uint256 tokenIndex = s._allTokensIndex[tokenId];

        uint256 lastTokenId = s._allTokens[lastTokenIndex];

        s._allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        s._allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        delete s._allTokensIndex[tokenId];
        s._allTokens.pop();
    }


    function _paused(ERC721Storage storage s) internal view returns (bool) {

        return s._paused;
    }

    function paused(ERC721Storage storage s) external view returns (bool) {

        return s._paused;
    }

    modifier whenNotPaused(ERC721Storage storage s) {

        require(!_paused(s), "Pausable: paused");
        _;
    }

    modifier whenPaused(ERC721Storage storage s) {

        require(_paused(s), "Pausable: not paused");
        _;
    }

    function _pause(ERC721Storage storage s) external whenNotPaused(s) {

        s._paused = true;
        emit Paused(msg.sender);
    }

    function _unpause(ERC721Storage storage s) external whenPaused(s) {

        s._paused = false;
        emit Unpaused(msg.sender);
    }

}